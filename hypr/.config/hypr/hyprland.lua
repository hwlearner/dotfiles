--[=[
                                   Hyprland Lua 配置文件
                              用于学习 Lua 语法和 Hyprland 配置

  Hyprland 0.55+ 原生支持 Lua 配置。如果此文件存在，Hyprland 将自动加载它
  并忽略旧的 hyprland.conf。

  快捷键风格：仿 i3/sway，使用 SUPER (Windows) 键作为主修饰键。
  配色方案：Catppuccin Mocha
  终端：ghostty

  快速参考：
    - hl.env()         设置环境变量
    - hl.config()      通用/装饰/输入/布局配置
    - hl.monitor()     显示器设置
    - hl.bind()        快捷键绑定
    - hl.window_rule() 窗口规则
    - hl.on()          事件钩子（如自动启动）
]=]


hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Catppuccin-Mocha")
hl.env("HYPRCURSOR_THEME", "Catppuccin-Mocha")
hl.env("GTK_IM_MODULE", "fcitx5")
hl.env("QT_IM_MODULE", "fcitx5")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx5")

-- Qt 统一主题（Kvantum）
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
-- ============================================================
-- 变量定义
-- ============================================================
local mainMod  = "SUPER"   -- Windows 键（主修饰键）
local terminal = "ghostty" -- 默认终端

-- Catppuccin Mocha 配色表
-- ============================================================
local c = {
    rosewater = "rgba(f5e0dcee)",
    flamingo  = "rgba(f2cdcdee)",
    pink      = "rgba(f5c2e7ee)",
    mauve     = "rgba(cba6f7ee)",
    red       = "rgba(f38ba8ee)",
    maroon    = "rgba(eba0acee)",
    peach     = "rgba(fab387ee)",
    yellow    = "rgba(f9e2afee)",
    green     = "rgba(a6e3a1ee)",
    teal      = "rgba(94e2d5ee)",
    sky       = "rgba(89dcebee)",
    sapphire  = "rgba(74c7ecee)",
    blue      = "rgba(89b4faee)",
    lavender  = "rgba(b4befeee)",
    text      = "rgba(cdd6f4ee)",
    subtext1  = "rgba(bac2deee)",
    subtext0  = "rgba(a6adc8ee)",
    overlay2  = "rgba(9399b2ee)",
    overlay1  = "rgba(7f849cee)",
    overlay0  = "rgba(6c7086ee)",
    surface2  = "rgba(585b70ee)",
    surface1  = "rgba(45475aee)",
    surface0  = "rgba(313244ee)",
    base      = "rgba(1e1e2eee)",
    mantle    = "rgba(181825ee)",
    crust     = "rgba(11111bee)",
}

-- ============================================================
-- 通用设置（间距、边框、配色、布局）
-- ============================================================
hl.config({
    general = {
        -- 窗口间距（像素）
        gaps_in  = 5,
        gaps_out = 10,

        -- 默认边框宽度
        border_size = 0,

        -- 边框颜色：活跃窗口用 catppuccin 渐变，非活跃用半透明 surface0
        col = {
            active_border   = { colors = { c.mauve, c.blue }, angle = 45 },
            inactive_border = c.surface0,
        },

        -- 允许通过拖拽边框和间距来调整窗口大小
        resize_on_border = true,

        -- 禁止画面撕裂（NVIDIA 用户保持 false）
        allow_tearing = false,

        -- 默认布局：dwindle（二叉分裂），也可改为 "master"
        layout = "dwindle",
    },
})

-- ============================================================
-- 窗口装饰（圆角、透明度、阴影、模糊）
-- ============================================================
hl.config({
    decoration = {
        -- 圆角半径
        rounding       = 12,
        rounding_power = 2,

        -- 透明度：活跃窗口近乎不透明，非活跃窗口半透明
        active_opacity   = 0.95,
        inactive_opacity = 0.80,

        -- 窗口阴影
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,  -- 0xAARRGGBB 格式
        },

        -- 背景模糊
        blur = {
            enabled   = true,
            size      = 10,
            passes    = 3,
            contrast  = 0.9,
            brightness = 0.8,
            vibrancy  = 0.2,
            new_optimizations = true,
            popups = true,
            popups_ignorealpha = 0.2,
            xray = true,
        },
    },
})

-- ============================================================
-- Noctalia 模糊（ext-background-effect-v1 协议会限定区域）
-- ============================================================
hl.layer_rule({
    match = { namespace = "noctalia-background-.*$" },
    ignore_alpha = 0.3,
    blur = true,
    blur_popups = true,
})



-- ============================================================
-- 动画曲线与动画设置
-- ============================================================
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- ============================================================
-- Dwindle 布局设置
-- ============================================================
hl.config({
    dwindle = {
        preserve_split = true, -- 保持 split 方向
    },
})

-- ============================================================
-- Master 布局设置（切换布局时生效）
-- ============================================================
hl.config({
    master = {
        new_status = "master", -- 新窗口默认成为主窗口
    },
})

-- ============================================================
-- 杂项
-- ============================================================
hl.config({
    misc = {
        force_default_wallpaper = -1,    -- -1 允许 Hyprland 壁纸；设为 0 或 1 禁用
        disable_hyprland_logo   = false,
        disable_splash_rendering  = true,
    },
})

-- ============================================================
-- 输入设备配置
-- ============================================================
hl.config({
    input = {
        -- 键盘布局（可改为 "cn", "de" 等）
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        -- 鼠标跟随焦点
        follow_mouse = 1,

        -- 鼠标灵敏度（-1.0 ~ 1.0，0 为默认）
        sensitivity = 0,

        -- 触摸板设置
        touchpad = {
            natural_scroll = true,  -- 自然滚动（macOS 风格）
            clickfinger_behavior = false,
            tap_to_click = true,    -- 轻触点击
        },
    },
})

-- ============================================================
-- 快捷键（i3/sway 风格）
-- ============================================================
-- 格式：hl.bind("修饰键 + 按键", hl.dsp.动作, { 选项 })
-- 选项：
--   { repeating = true }  — 长按重复触发
--   { locked = true }     — 锁屏后仍有效
--   { mouse = true }      — 鼠标绑定
--
--  快捷键                    功能
--  ────────────────────────  ──────────────────────────────
--   $mod + Return            打开终端 (ghostty)
--   $mod + q                 关闭当前窗口
--   $mod + d                 打开启动器 (Noctalia)
--   $mod + h/j/k/l           焦点向左/下/上/右（vim 风格）
--   $mod + Shift + h/j/k/l   窗口向左/下/上/右移动
--   $mod + 1-9               切换到工作区 1-9
--   $mod + Shift + 1-9       移动窗口到工作区 1-9
--   $mod + f                 全屏切换
--   $mod + Shift + Space     切换窗口浮动/平铺
--   $mod + r                 进入 resize 模式（hjkl 调整大小，ESC 退出）
--   $mod + Shift + q         退出 Hyprland
--   $mod + Shift + c         重载配置
--   $mod + v                 切换 split 方向
--   $mod + Tab               循环切换窗口焦点
--   Print                    截图（hyprshot 区域选择）
--   $mod + Print             截图（hyprshot 当前窗口）
--   $mod + Shift + Print     截图（hyprshot 当前显示器）

-- 启动终端
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))

-- 关闭窗口
hl.bind(mainMod .. " + q", hl.dsp.window.close())

-- 打开启动器 (Noctalia Launcher)
hl.bind(mainMod .. " + d", hl.dsp.exec_cmd("quickshell ipc -c noctalia-shell call launcher toggle"))

-- 焦点移动（vim 风格：hjkl）
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))

-- 窗口移动
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))

-- 工作区切换与窗口移动（循环生成 1-9）
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

-- 全屏
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen())

-- 切换浮动/平铺
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))

-- 进入 resize 子模式
hl.bind(mainMod .. " + r", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("h", hl.dsp.window.resize({ x = -30, y = 0, relative = true }),  { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 30, relative = true }),   { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -30, relative = true }),  { repeating = true })
    hl.bind("l", hl.dsp.window.resize({ x = 30, y = 0, relative = true }),   { repeating = true })
    -- 按任意未绑定键或 ESC 退出 resize 模式
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

hl.bind(mainMod .. " + SHIFT + q", hl.dsp.exit())

-- 重载配置
hl.bind(mainMod .. " + SHIFT + c", hl.dsp.exec_cmd("hyprctl reload"))

-- 切换 split 方向（dwindle 布局下有效）
hl.bind(mainMod .. " + v", hl.dsp.layout("togglesplit"))

-- 切换布局（dwindle ↔ master）
hl.bind(mainMod .. " + s", hl.dsp.layout("togglelayout"))

-- 循环切换窗口焦点
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next({ }))
-- Noctalia 控制中心里有 WiFi 面板，impala 已删除
-- 截图
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))

-- 鼠标拖拽移动/调整窗口
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- 多媒体快捷键（音量 + 亮度）
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- ============================================================
-- 窗口规则
-- ============================================================

-- 浮动窗口：pinentry（密码输入）, pavucontrol（音量）, Qt 设置, 蓝牙
hl.window_rule({
    name  = "float-pinentry",
    match = { class = "pinentry" },
    float = true,
})

hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "pavucontrol" },
    float = true,
})

hl.window_rule({
    name  = "float-qt5ct",
    match = { class = "qt5ct" },
    float = true,
})

hl.window_rule({
    name  = "float-qt6ct",
    match = { class = "qt6ct" },
    float = true,
})

hl.window_rule({
    name  = "float-blueman",
    match = { class = "blueman-manager" },
    float = true,
})


-- 修复 XWayland 拖拽问题
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- ============================================================
-- 自动启动（exec-once 等价）
-- ============================================================
hl.on("hyprland.start", function()
    -- Noctalia Shell
    hl.exec_cmd("quickshell -c noctalia-shell")

    -- fcitx5 输入法（systemd 管理，自动处理僵尸/崩溃）
    hl.exec_cmd("systemctl --user start fcitx5")
    hl.exec_cmd("sh -c 'sleep 4 && gdbus call --session -d org.fcitx.Fcitx5 -o /controller -m org.fcitx.Fcitx.Controller1.SetCurrentIM pinyin'")

    -- xdg-desktop-portal-hyprland
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")

    -- 剪贴板（Noctalia 启动器集成）
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
