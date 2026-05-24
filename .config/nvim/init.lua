--[[
=============================================================================
  init.lua — Neovim 配置入口
=============================================================================
  加载顺序：
    1. init.lua（当前文件）
    2. lua/config/options.lua   → 基础设置
    3. lua/config/keymaps.lua   → 按键映射
    4. plugin/*.lua              → 所有插件（由 Neovim 自动加载）
                                  （使用 vim.pack 原生包管理器）
=============================================================================
]]

-- 开启 vim.loader（加速 Lua 模块加载，建议作为 init.lua 第一行）
vim.loader.enable()

-- 加载基础配置
require("config.options")
require("config.keymaps")

-- 插件由 Neovim 自动从 plugin/ 目录加载
-- 不再需要手动 require 包管理器
