local log = hs.logger.new("inputswitch", "info")

local state = _G.__appInputSwitcherState or {}
_G.__appInputSwitcherState = state

local tmuxBin = "/opt/homebrew/bin/tmux"

-- ============================================================================
-- App bundle ID → input method (for non-Ghostty apps)
-- ============================================================================
local appInputMap = {
  ["com.openai.codex"] = { sourceID = "com.apple.inputmethod.SCIM.ITABC", label = "Pinyin - ABC" },
  ["ai.opencode.desktop"] = { sourceID = "com.apple.inputmethod.SCIM.ITABC", label = "Pinyin - ABC" },
  ["com.microsoft.VSCode"] = { layout = "ABC", label = "ABC" },
  ["dev.zed.Zed"] = { layout = "ABC", label = "ABC" },
  -- Ghostty is handled separately (see below)
}

-- ============================================================================
-- Helpers
-- ============================================================================

local function stopHandle(name)
  local handle = state[name]
  if not handle then
    return
  end
  handle:stop()
  state[name] = nil
end

local function clearPendingSync()
  local timer = state.pendingSync
  if not timer then
    return
  end
  timer:stop()
  state.pendingSync = nil
end

-- Stop all on reload
stopHandle("appWatcher")
stopHandle("caffeinateWatcher")
stopHandle("ghosttyPoller")
if state.ghosttyWinFilter then
  state.ghosttyWinFilter:stop()
  state.ghosttyWinFilter = nil
end
clearPendingSync()
state.lastGhosttyTitle = nil

local function targetIsActive(target)
  if target.sourceID and hs.keycodes.currentSourceID() == target.sourceID then
    return true
  end
  if target.layout and hs.keycodes.currentLayout() == target.layout then
    return true
  end
  return false
end

local function applyTarget(target)
  if target.sourceID and hs.keycodes.currentSourceID(target.sourceID) then
    return true
  end
  if target.layout and hs.keycodes.setLayout(target.layout) then
    return true
  end
  return false
end

local function frontmostBundleID()
  local app = hs.application.frontmostApplication()
  return app and app:bundleID() or nil
end

--- Switch input for a Ghostty window by reading its title text.
--- - Title contains "deepseek" -> Pinyin
--- - Otherwise (tmux, shell, etc.) -> ABC
local function switchInputForGhosttyWindow()
  if frontmostBundleID() ~= "com.mitchellh.ghostty" then return end

  local win = hs.window.focusedWindow()
  if not win then return end

  -- AXTitle works for Ghostty's custom titlebar; win:title() is a useful fallback.
  local title = win:title()
  local ax = hs.axuielement.windowElement(win)
  if ax then
    local axTitle = ax:attributeValue("AXTitle")
    if type(axTitle) == "string" and axTitle ~= "" then
      title = axTitle
    end
  end
  if title ~= state.lastGhosttyTitle then
    state.lastGhosttyTitle = title
    log.i("Ghostty title: " .. tostring(title))
  end

  if title and type(title) == "string" and title ~= "" then
    if title:lower():find("deepseek") then
      local target = { sourceID = "com.apple.inputmethod.SCIM.ITABC", label = "Pinyin - ABC" }
      if not targetIsActive(target) and applyTarget(target) then
        log.i("Ghostty [" .. title .. "] -> Pinyin")
      end
      if not targetIsActive(target) then
        log.ef("Failed to switch Ghostty [%s] to Pinyin", title)
      end
      return
    end
  end

  -- Default: ABC (tmux, plain shell, etc.)
  local target = { layout = "ABC", label = "ABC" }
  if not targetIsActive(target) then
    if applyTarget(target) and targetIsActive(target) then
      log.i("Ghostty [" .. tostring(title or "?") .. "] -> ABC (default)")
    else
      log.ef("Failed to switch Ghostty [%s] to ABC", title or "?")
    end
  end
end

local function scheduleGhosttyWindowSync()
  clearPendingSync()
  state.pendingSync = hs.timer.doAfter(0.15, function()
    state.pendingSync = nil
    switchInputForGhosttyWindow()
  end)
end

local function switchInputForApp(app, attemptsLeft)
  if not app then
    return
  end

  local bundleID = app:bundleID()
  local target = appInputMap[bundleID]
  if not target or targetIsActive(target) then
    return
  end

  if applyTarget(target) and targetIsActive(target) then
    log.df("Switched input for %s to %s", bundleID, target.label or "target input")
    return
  end

  if attemptsLeft > 1 then
    clearPendingSync()
    state.pendingSync = hs.timer.doAfter(0.2, function()
      state.pendingSync = nil
      switchInputForApp(hs.application.frontmostApplication(), attemptsLeft - 1)
    end)
    return
  end

  log.ef("Failed to switch input for %s", bundleID or "unknown app")
  hs.notify.new({
    title = "Hammerspoon Input Switch",
    informativeText = "Failed to switch input source for " .. (bundleID or "unknown app"),
  }):send()
end

local function syncFrontmostApp()
  switchInputForApp(hs.application.frontmostApplication(), 3)
end

-- ============================================================================
-- App activation watcher
-- Ghostty → tmux-based routing; other apps → bundle ID map.
-- ============================================================================
state.appWatcher = hs.application.watcher.new(function(_, eventType)
  if eventType ~= hs.application.watcher.activated then
    return
  end

  clearPendingSync()

  local app = hs.application.frontmostApplication()
  if app and app:bundleID() == "com.mitchellh.ghostty" then
    scheduleGhosttyWindowSync()
  else
    state.pendingSync = hs.timer.doAfter(0.15, function()
      state.pendingSync = nil
      syncFrontmostApp()
    end)
  end
end)

-- ============================================================================
-- Window focus filter (for Ghostty)
-- Handles switching between Ghostty windows (same app, different tmux states).
-- ============================================================================
state.ghosttyWinFilter = hs.window.filter.new()
state.ghosttyWinFilter:subscribe(hs.window.filter.windowFocused, function(window, app)
  if not window or not app then return end
  if app:bundleID() ~= "com.mitchellh.ghostty" then return end

  scheduleGhosttyWindowSync()
end)

-- Polling is a fallback for Ghostty/tmux title changes and same-app window switches
-- that do not always produce a reliable hs.window.filter event.
state.ghosttyPoller = hs.timer.new(0.5, function()
  if frontmostBundleID() == "com.mitchellh.ghostty" then
    switchInputForGhosttyWindow()
  end
end)

-- ============================================================================
-- System wake / unlock: re-sync current app's input
-- ============================================================================
state.caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
  if eventType == hs.caffeinate.watcher.systemDidWake
    or eventType == hs.caffeinate.watcher.screensDidUnlock then
    syncFrontmostApp()
    switchInputForGhosttyWindow()
  end
end)

state.appWatcher:start()
state.caffeinateWatcher:start()
state.ghosttyPoller:start()
-- ghosttyWinFilter starts automatically via subscribe()

-- Initial sync
syncFrontmostApp()
switchInputForGhosttyWindow()

log.i("Input switcher loaded")
