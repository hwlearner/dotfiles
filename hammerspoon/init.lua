local log = hs.logger.new("inputswitch", "info")

local state = _G.__appInputSwitcherState or {}
_G.__appInputSwitcherState = state

local appInputMap = {
  ["com.openai.codex"] = { sourceID = "com.apple.inputmethod.SCIM.ITABC", label = "Pinyin - ABC" },
  ["com.microsoft.VSCode"] = { layout = "ABC", label = "ABC" },
  ["com.mitchellh.ghostty"] = { layout = "ABC", label = "ABC" },
}

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

stopHandle("appWatcher")
stopHandle("caffeinateWatcher")
clearPendingSync()

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

state.appWatcher = hs.application.watcher.new(function(_, eventType)
  if eventType ~= hs.application.watcher.activated then
    return
  end

  clearPendingSync()
  state.pendingSync = hs.timer.doAfter(0.15, function()
    state.pendingSync = nil
    syncFrontmostApp()
  end)
end)

state.caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
  if eventType == hs.caffeinate.watcher.systemDidWake
    or eventType == hs.caffeinate.watcher.screensDidUnlock then
    syncFrontmostApp()
  end
end)

state.appWatcher:start()
state.caffeinateWatcher:start()

syncFrontmostApp()
log.i("Input switcher loaded")
