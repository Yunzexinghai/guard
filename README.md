# 🛡️ Guard
**Ubuntu 服务器自动化初始化 & 地域复合防御脚本**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Ubuntu-orange.svg)](https://ubuntu.com/)

这是一款为 Ubuntu 准备的"懒人"初始化工具。它在帮你装好常用排错工具的同时，利用 `ipset` 在内核层面构筑了一道地域防线：**除了中国大陆的 IP，谁也别想碰你的 22 端口。**

---

## 🌟 核心功能

- **🧰 工具开箱即用**：自动安装 `curl`、`git`、`vim`、`htop`、`lsof`、`net-tools` 等必备小软件。
- **🧱 地域硬核拦截**：基于 `ipset` 哈希字典，极速匹配国内 IP 段。海外扫描器在第一关就会被直接丢弃（DROP）。
- **🧠 智能环境适配**：自动识别 `UFW` 或原生 `iptables` 环境，无缝注入规则，不破坏系统原有生态。
- **🔄 无人值守更新**：内置 Crontab 引擎，每月 1 号凌晨自动更新国内 IP 数据库，始终保持精准。

---

## 🚀 快速开始

### 1. 一键部署

在全新的 Ubuntu 机器上，使用 root 权限执行以下命令：

```bash
bash <(curl -sL https://raw.githubusercontent.com/Yunzexinghai/guard/main/init.sh)
```

### 2. 一键卸载

如果你需要回归系统原始状态，执行以下命令即可全自动清理残留：

```bash
bash <(curl -sL https://raw.githubusercontent.com/Yunzexinghai/guard/main/uninstall.sh)
```

---

## 🔍 运行逻辑

**优先级保证**：脚本强制将"放行本地回环"与"放行已建立连接"置于最高优先级，确保你当前的 SSH 不会因脚本执行而断开。

**双轨并行**：

- **UFW 环境**：通过 `before.init` 和 `before.rules` 注入，受 UFW 统一管理。
- **原生环境**：通过 `iptables-persistent` 固化，直接写入内核。

**精准打击**：防御范围仅限 22 端口。你后续部署的 Web 业务（80/443）或 Docker 容器均不受影响。

---

## 📝 常见问题

**Q：我会把自己锁在外面吗？**

A：不会。只要你是从国内 IP 连入的，或者连接已经建立，脚本会通过白名单和状态检测保住你的连接。

**Q：它会弄乱我的网站或者 Docker 吗？**

A：放心，它只盯着 22 端口（SSH）看。你跑的网页（80/443）或者 Docker 容器的路由，该怎么走还怎么走，互不干扰。

**Q：可以自定义安装的小软件吗？**

A：当然。直接修改 `init.sh` 顶部的 `COMMON_TOOLS` 变量，想加什么随你便。

---

如果觉得好用，请点个 ⭐️ Star 鼓励一下，发现 Bug 随时提 Issue 拍砖！