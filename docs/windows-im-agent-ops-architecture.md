# Windows IM 智能体运维方案

> 最后更新: 2026-05-16（已实施）
>
> 目标: 通过飞书控制 Windows 主控智能体，使用 DeepSeek V4 Flash 云端模型，统一运维 Windows 与 Arch 主机。
>
> 实施状态: 核心链路已跑通，n8n 待配置工作流。

## 1. 方案结论

当前建议收敛为下面这套最小可用架构：

```text
飞书
  ↓
LangBot (Windows :5300)
  ↓
DeepSeek V4 Flash (thinking disabled)
  ↓
Windows 主控机 (192.168.3.10)
  ├─ MCP: win-ops (6 个工具)
  │     ├─ win_status / win_service / win_eventlog
  │     ├─ arch_status / arch_service / arch_podman
  ├─ n8n: 审批、定时任务、审计 (:5678)
  ├─ win-agent-scripts (PowerShell)
  └─ SSH → devops@archan (192.168.1.10)
         └─ arch-agent-{status,service,podman,dev}
```

这套方案的重点不是“找一个全包智能体平台”，而是把职责拆开：

- `飞书` 负责唯一人机入口。
- `LangBot` 负责 IM 接入、会话、消息路由、调用模型。
- `Ollama` 负责本地模型推理。
- `云模型` 只在本地模型不够强或不可用时兜底。
- `n8n` 不负责主对话，只负责审批、定时巡检、审计。
- `Windows` 和 `Arch` 上的真正运维动作，都通过受限脚本或受限接口执行。

## 2. 为什么这样收敛

目标是简单、稳定、可控，而不是功能最多。

- 如果把 IM、工作流、模型推理、运维执行都塞进一个平台，排障会很痛苦。
- 如果让本地 7B/8B 模型直接接管高风险运维，稳定性不够。
- 如果让机器人直接拿管理员 PowerShell 或 `root` SSH，权限边界太差。

这套方案的好处：

- 本地模型可承担大部分日常问答、日志总结、低风险操作。
- 云模型只在必要时介入，成本和网络依赖都可控。
- IM 入口、模型、审批、执行层彼此独立，后面替换组件不伤整体。
- Windows 主控机既可以跑图形界面，也可以兼顾本地模型服务。

## 3. 组件职责

### 3.1 IM 入口

优先选 `飞书`。

原因：

- 中国大陆可达性和交互能力都比较稳。
- 官方机器人/应用能力完整，适合做正式入口。
- 后续要加审批卡片、按钮确认、状态回报比较方便。

不建议把个人微信当正式运维入口。稳定性、合规性和封号风险都不合适。

### 3.2 Bot 层

优先选 `LangBot`。

职责：

- 接收飞书消息
- 维护会话上下文
- 路由到本地模型或云模型
- 调用固定工具或工作流
- 把执行结果回发到 IM

`LangBot` 负责“会话和路由”，不负责直接拿高权限运维整台机器。

### 3.3 本地模型层

Windows 上优先用 `Ollama`。

推荐本地模型：

- `Qwen3-8B`: 默认通用运维问答模型
- `Qwen2.5-Coder-7B`: 更适合写脚本、改配置、看代码

建议用法：

- 本地模型负责状态查询、日志总结、低风险命令建议、简单脚本生成
- 云模型负责复杂排障、长链路分析、高风险变更前复核

### 3.4 云模型兜底

优先保留一个稳定的云端 provider。

推荐顺序：

- `DeepSeek`: 大陆环境下接入和成本都更顺手
- `OpenAI`: 作为高质量备用

切换条件：

- 本地模型回答质量明显不足
- 需要更强的工具调用或长上下文
- 需要在高风险动作前做二次推理
- 本地推理服务不可用

### 3.5 工作流与审批层

保留 `n8n`，但只做下面几类事情：

- 高风险操作审批
- 定时巡检
- 审计记录
- 多步骤自动化编排

不要让 `n8n` 承担主聊天入口，否则链路会变复杂。

### 3.6 执行层

执行层分成两块：

- `Windows 本机执行层`
- `Arch 远程执行层`

都应采用“固定脚本 + 受限账户 + 明确参数”的方式，不要暴露通用 shell。

## 4. 推荐拓扑

```text
你
  ↓
飞书
  ↓
LangBot
  ↓
Windows 主控机
  ├─ Ollama
  ├─ Cloud provider fallback
  ├─ n8n
  ├─ win-agent-scripts
  └─ SSH client
       ↓
       Arch 主机
         ├─ devops 受限用户
         ├─ arch-agent-scripts
         ├─ Podman 开发容器
         └─ 开发容器内的 Codex / OpenCode / Goose worker
```

## 5. Windows 主控机建议

Windows 主控机承担四件事：

- 跑 `LangBot`
- 跑 `Ollama`
- 跑 `n8n`
- 作为运维调度器去管理 Arch 和家里的 Windows 节点

推荐做法：

- 用图形界面正常维护系统和本地模型
- 把所有后台服务做成长期驻留服务
- 不把业务状态散落在桌面手工启动脚本里

如果这台机器有核显 + `RX 7600 XT`：

- 桌面显示优先走核显
- 本地模型推理固定走 `7600 XT`
- 模型服务空闲时允许显卡低功耗待机

## 6. Arch 主机建议

Arch 主机是被管端，不是主控端。

建议职责：

- 跑开发容器
- 提供代码和构建环境
- 提供受限 SSH 入口
- 提供固定运维脚本

不建议让 Windows 主控智能体直接拿 Arch 的 `root` shell。

推荐结构：

```text
/srv/workspaces/
  ├─ project-a
  ├─ project-b
  └─ dotfiles

/srv/state/
  ├─ dev-agents
  └─ service-state

/usr/local/bin/
  ├─ arch-agent-status
  ├─ arch-agent-service
  ├─ arch-agent-podman
  └─ arch-agent-dev
```

## 7. Windows 常驻节点本机配置

如果 Windows 这台机器要长期作为主控智能体或被管节点运行，建议把本机配置收敛到下面这些状态。

### 7.1 已建议落地的状态

- 使用固定本地账户，例如 `han`
- 使用静态 IP
- `sshd` 开机自启
- SSH 只保留公钥登录
- 关闭休眠
- 禁止系统自动睡眠
- 网络类型改为 `Private`

### 7.2 推荐保留的系统组件

下面这些一般不要删：

- `Microsoft Edge`
- `Microsoft Edge WebView2 Runtime`
- `Microsoft Visual C++ Runtime`

原因很简单：它们经常被系统组件、登录页、安装器和第三方应用依赖。

### 7.3 可以优先清理的内容

如果确认不用，可以删：

- `Google Chrome`
- `Logi Options+`
- `Logi Plugin Service`
- 消费类内置应用，例如新闻、天气、Xbox、待办、Outlook for Windows、Clipchamp

原则：

- 优先删“消费类软件”和“重复浏览器”
- 不要删系统运行库
- 不要为了极限精简破坏远程维护能力

### 7.4 电源建议

如果这台机器要长期在线，电源策略要偏“服务器化”：

- 关闭休眠
- 睡眠超时设为 `Never`
- 显示器是否关闭无所谓，但系统本身不要进入睡眠
- 如果是桌面 + 本地推理双用途机器，可以允许关屏，不允许睡眠

推荐目标：

```text
休眠: Off
睡眠: Never
显示器: 可关
系统待机: 禁止
```

### 7.5 SSH 建议

推荐状态：

- `sshd` 服务设为 `Automatic`
- 禁用 `PasswordAuthentication`
- 禁用 `KbdInteractiveAuthentication`
- 只允许公钥登录
- 管理员账户使用 `C:\ProgramData\ssh\administrators_authorized_keys`

如果后面角色稳定，建议再做一步：

- 单独创建一个非管理员 SSH 运维用户
- 管理员账户只保留本地救援用途

### 7.6 更新与重启建议

Windows 作为常驻节点，最烦的不是更新本身，而是自动重启打断任务。

建议：

- 配置 `Active Hours`
- 关闭无人值守时的自动重启
- 重大更新前手工确认
- 如果后面接入 `n8n`，把“更新前通知”和“更新后健康检查”做成固定流程

### 7.7 网络建议

推荐状态：

- 网卡使用静态 IPv4
- 网络配置文件为 `Private`
- SSH 入站规则显式放行
- 如果后面接入 WireGuard 或 Tailscale，不要依赖 DHCP 地址做远程管理

### 7.8 启动项建议

常驻智能体机器的启动项应该尽量少。

建议保留：

- `SecurityHealth`
- 你明确需要的驱动/输入设备服务

建议清理：

- OneDrive 残留启动项
- Edge 自动启动项
- 各类消费类 App 的启动项
- 不必要的厂商下载助手

### 7.9 常驻运行的最小检查清单

每次改完系统后，至少确认这几项：

- `ssh han@<ip>` 可以免密登录
- `whoami` 返回预期账户
- `powercfg /a` 不再出现休眠可用
- `Get-Service sshd` 为 `Running`
- 网络类型为 `Private`
- 静态 IP 没漂移

## 8. 最小权限边界

这是整个方案里最重要的部分。

### 8.1 Windows 侧

- 给 `LangBot`、`n8n`、模型服务单独的服务账户或明确运行身份
- 不直接给 Bot 管理员权限
- 本机运维动作通过固定 PowerShell 脚本执行

### 8.2 Arch 侧

- 单独创建 `devops` 用户
- 禁止密码登录，只允许 SSH key
- `authorized_keys` 绑定固定 wrapper command
- 只允许有限的 `sudo` 命令
- 不开放直接 `root` SSH

### 8.3 审批边界

以下操作必须经过 `n8n` 二次确认：

- 重启主机
- 修改网络配置
- 修改防火墙
- 删除容器
- 删除快照或备份
- 系统升级
- 停止关键服务

## 9. 推荐命令边界

主控智能体不应自由生成任意命令，而应调用固定动作。

Windows 本机可暴露的动作示例：

- `win-status`
- `win-service restart <name>`
- `win-eventlog tail <channel>`
- `win-ollama status`

Arch 可暴露的动作示例：

- `arch-status`
- `arch-service restart <name>`
- `arch-podman ps`
- `arch-dev list`
- `arch-dev run <container> <task>`
- `arch-git status <repo>`

如果后面需要更强的统一接口，再把这些固定动作包装成 MCP server。

第一版不需要先上 MCP。

## 10. 模型路由策略

建议把模型路由写得简单明确：

- 默认走 `Qwen3-8B`
- 代码和脚本任务优先 `Qwen2.5-Coder-7B`
- 高风险动作前切换到云模型复核
- 本地模型不可用时自动切到云模型

推荐判定规则：

- 查询类任务：本地模型
- 总结类任务：本地模型
- 简单运维动作：本地模型出建议，执行层按白名单落地
- 复杂排障：云模型
- 高风险变更：云模型 + `n8n` 审批

## 11. 最小部署顺序

建议按下面顺序实施，不要一开始上太多层。

1. ⏭️ 在 Windows 上部署 `Ollama`（已跳过，直接使用 DeepSeek 云端）
2. ✅ 在 Windows 上部署 `LangBot`，打通飞书消息收发
3. ✅ 接入 DeepSeek V4 Flash，修复 thinking mode 冲突
4. ✅ 在 Windows 上实现固定 PowerShell 运维脚本（3 个）
5. ✅ 在 Arch 上实现受限 `devops` 用户和固定脚本（4 个）
6. ✅ 用 `SSH + 强制命令 wrapper` 打通 Arch 远程执行
7. ✅ 实现 MCP server `win-ops`，注册到 LangBot（6 个工具）
8. ⏳ `n8n` 已安装，待配置审批/定时/审计工作流

## 12. 第一版不要做的事

- 不要让 IM 机器人直接拿管理员权限
- 不要让本地 8B 模型单独决定高风险运维动作
- 不要先做分布式 agent mesh
- 不要先做复杂的 MCP 编排层
- 不要同时引入太多 IM 平台

第一版先把“飞书单入口 + Windows 主控 + Arch 被管 + 本地模型主力 + 云模型备用”跑稳。

## 13. 后续扩展方向

第一版稳定后，再考虑下面这些增强：

- 把固定脚本包装成 MCP server
- 给开发容器增加独立 agent worker
- 把定时健康检查和备份校验全部接进 `n8n`
- 接入日志、监控、告警系统
- 给高风险操作增加回滚预案和自动摘要

## 14. 一句话结论

当前实施方案：

`飞书 + LangBot + DeepSeek V4 Flash + MCP(win-ops) + n8n(待配置) + Windows/Arch 受限执行层`

核心链路已跑通。飞书发消息 → LangBot 路由 → DeepSeek 决策 → MCP 工具调用 → PowerShell/SSH 执行 → 结果回飞书。
