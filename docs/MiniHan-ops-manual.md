# MiniHan 运维手册

最后更新：2026-05-17

## 主机概览

- 主机名：`MiniHan`
- 系统：Windows 11 (10.0.26200)
- 用户：`minihan\han`，Administrators 组成员
- LAN IP：`192.168.3.10`（静态，网关 `192.168.3.1`）
- SSH：Mac 侧 `ssh han@192.168.3.10`，仅公钥认证
- Tailscale：Tailscale v1.98.1 (TBD)

## SSH 访问

| 项目 | 值 |
|------|-----|
| 端口 | 22 |
| 认证 | 公钥仅，密码和 KbdInteractive 禁用 |
| 服务 | `Automatic` 开机自启 |
| 防火墙 | 入站放行 |

## 网络

| 接口 | IP |
|------|-----|
| 以太网 2 | 静态 `192.168.3.10/24` (gw `192.168.3.1`) |
| 代理 | WinHTTP `http://192.168.1.10:7890` |
| 环境变量 | `HTTP_PROXY`=`HTTPS_PROXY`=`http://192.168.1.10:7890` |
| NO_PROXY | `localhost,127.0.0.1,192.168.3.0/24,.local` |

## 电源

- 休眠：关闭
- 睡眠 (S1/S2/S3)：禁用
- S0 Modern Standby：`ALLOWSTANDBY=0` 禁止进入
- 混合睡眠：关闭
- 无人值守超时：`0`（永不）

## Windows 更新

- Active Hours：08:00--02:00
- 登录用户时自动重启：禁止
- 模式：通知下载和安装

## 运行时

| 组件 | 版本 |
|------|------|
| Python | 3.12.10 |
| Node.js | 24.15.0 |
| uv | 0.11.14 |

## 常用命令

```cmd
rem 电源
powercfg /a
powercfg /qh SCHEME_CURRENT SUB_SLEEP

rem 代理
curl http://192.168.1.10:7890
```
