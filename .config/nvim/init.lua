--[[
=============================================================================
  init.lua — Neovim 配置入口
=============================================================================
  加载顺序：
    1. init.lua（当前文件）
    2. lua/config/options.lua   → 基础设置
    3. lua/config/keymaps.lua   → 按键映射
    4. lua/config/lazy.lua      → 包管理器 lazy.nvim 的安装和启动
    5. lua/plugins/*.lua        → 各插件配置（由 lazy.nvim 自动加载）
=============================================================================
]]


-- 加载基础配置
require("config.options")
require("config.keymaps")

-- 启动包管理器
require("config.lazy")
