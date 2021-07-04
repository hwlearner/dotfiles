local appInputMap = {
  ["com.openai.codex"] = { kind = "sourceID", value = "com.apple.inputmethod.SCIM.ITABC" },
  ["com.microsoft.VSCode"] = { kind = "layout", value = "ABC" },
  ["com.mitchellh.ghostty"] = { kind = "layout", value = "ABC" },
}

local function switchInputForApp(app)
  if not app then
    return
  end

  local bundleID = app:bundleID()
  local target = appInputMap[bundleID]
  if not target then
    return
  end

  local ok = false
  if target.kind == "sourceID" then
    local current = hs.keycodes.currentSourceID()
    if current == target.value then
      return
    end
    ok = hs.keycodes.currentSourceID(target.value)
  elseif target.kind == "layout" then
    local current = hs.keycodes.currentLayout()
    if current == target.value then
      return
    end
    ok = hs.keycodes.setLayout(target.value)
  end

  if ok then
    return
  end

  hs.notify.new({
    title = "Hammerspoon Input Switch",
    informativeText = "Failed to switch input source for " .. (bundleID or "unknown app"),
  }):send()
end

local watcher = hs.application.watcher.new(function(_, eventType, app)
  if eventType == hs.application.watcher.activated then
    switchInputForApp(app)
  end
end)

watcher:start()
