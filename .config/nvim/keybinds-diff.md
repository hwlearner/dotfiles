# 快捷键差异对照 — 当前配置 vs LazyVim

> 当前配置是基于 lazy.nvim 的手写配置，非 LazyVim 发行版。
> 此文档列出 LazyVim 有但我们没有的快捷键，供后续按需添加参考。

## 已有覆盖（与 LazyVim 对齐的部分）

| 分类 | 按键 | 作用 |
|------|------|------|
| 导航 | `j`/`k` | 智能折行移动 |
| 窗口 | `<C-h/j/k/l>` | 窗口跳转 |
| 窗口 | `<C-方向键>` | 调整大小 |
| 窗口 | `<leader>-` / `<leader>\|` / `<leader>wd` | 分屏/关闭 |
| Buffer | `<S-h>`/`<S-l>` / `<leader>bb/bd/bo` | 切换/删除 buffer |
| 保存 | `<C-s>` | 保存 |
| 搜索 | `<esc>` / `n`/`N` | 取消高亮 + 居中 |
| 编辑 | `<A-j/k>` | 行移动 |
| 编辑 | `</>` in visual | 缩进保持选中 |
| 退出 | `<leader>qq` | 全部退出 |
| 格式化 | `<leader>cf` | 格式化 |
| LSP | `K` `gd` `gr` `gI` `gy` | 悬停/定义/引用/实现/类型定义 |
| LSP | `<leader>ca` / `<leader>cr` | code action / 重命名 |
| 诊断 | `<leader>cd` `]d` `[d` | 诊断浮窗/跳转 |
| Git | `]h` `[h` / `<leader>ghs/r/b/d` | hunk 导航/操作 |
| Mason | `<leader>cm` | LSP 安装器 |
| 包管理 | `<leader>l` | lazy.nvim 插件管理 |
| which-key | `<leader>?` | 显示当前按键 |

## 缺失 — 无需额外插件

以下快捷键只需加一行映射，不依赖新插件。

### 文件/编辑

| 按键 | 作用 | 实现 |
|------|------|------|
| `<leader>fn` | 新建空白文件 | `<cmd>enew<cr>` |
| `<leader>ur` | 重绘屏幕 + 取消高亮 | `<cmd>nohlsearch\|diffupdate\|normal! <C-L><CR>` |
| `<leader>K` | 查看关键词文档 | `<cmd>norm! K<cr>` |
| `,`/`.`/`;` (i) | 插入模式下标点后加 undo 断点 | `,.<c-g>u` / `;.<c-g>u` |

### Buffer

| 按键 | 作用 | 备注 |
|------|------|------|
| `[b`/`]b` | buffer 前后切换 | `<S-h/l>` 的备选风格 |
| `<leader>bD` | 删除 buffer 并关闭窗口 | 比 `:bdelete` 彻底 |
| `<leader>\`` | 切换到上一个 buffer | `<leader>bb` 的备选键 |

### Quickfix / Location

| 按键 | 作用 |
|------|------|
| `<leader>xl` | 切换 location list |
| `<leader>xq` | 切换 quickfix list |
| `[q`/`]q` | 上/下一个 quickfix 项 |

### 诊断

| 按键 | 作用 | 对比已有 |
|------|------|---------|
| `]e`/`[e` | 下一个 error（按 severity） | `]d`/`[d` 不区分 severity |
| `]w`/`[w` | 下一个 warning | 同上 |

### Tab

| 按键 | 作用 |
|------|------|
| `<leader><tab><tab>` | 新建 tab |
| `<leader><tab>d` | 关闭 tab |
| `<leader><tab>l` | 最后一个 tab |
| `<leader><tab>f` | 第一个 tab |
| `<leader><tab>]` | 下一个 tab |
| `<leader><tab>[` | 上一个 tab |
| `<leader><tab>o` | 关闭其他 tab |

## 缺失 — 需要额外插件

以下快捷键依赖用户尚未安装的插件（或系统工具）。

| 按键 | 作用 | 需安装 |
|------|------|--------|
| `<leader>gg` | Lazygit | lazygit（系统工具）+ Snacks.nvim |
| `<leader>ft` | 打开终端终端 | toggleterm / Snacks.terminal |
| `<leader>wm` / `<leader>uz` | 窗口最大化 / Zen 模式 | zen-mode.nvim / Snacks.zen |
| `gco`/`gcO` | 注释上下行 | Comment.nvim |
| `<leader>us` | 拼写检查开关 | (vim 内置 spell，可直接绑) |
| `<leader>uw` | 折行开关 | (vim 内置 wrap，可直接绑) |
| `<leader>ud` | 诊断显示开关 | (vim.diagnostic 可直接控制) |
| `<leader>ul` | 行号开关 | (vim.opt.number 可直接控制) |
| `<leader>ub` | 深浅色切换 | (vim.opt.background 可直接控制) |
| 其余 `<leader>u*` toggle | 各种 UI 开关 | Snacks.nvim（LazyVim 核心库） |
