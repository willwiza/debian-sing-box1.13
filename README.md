<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# \# 🪿 Debian Sing-Box 1.13 部署手册

<p align="center">
  <img src="https://img.shields.io/badge/Sing--Box-v1.13.0--alpha.17-62039a?style=for-the-badge&logo=sing-box&logoColor=white" />
  <img src="https://img.shields.io/badge/OS-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white" />
  <img src="https://img.shields.io/badge/Open%20Source-%E2%9D%A4-brightgreen?style=for-the-badge" />
</p>
<p align="center">
  <a href="https://github.com/willwiza">
    <img src="https://img.shields.io/badge/GitHub-willwiza-181717?style=flat-square&logo=github&logoColor=white" />
  </a>
  <a href="https://willwiza.dpdns.org">
    <img src="https://img.shields.io/badge/Blog-willwiza.dpdns.org-blue?style=flat-square&logo=rss&logoColor=white" />
  </a>
</p>

---

### 📢 完全开源说明

本仓库所涉及的所有安装脚本、配置文件模板及部署思路 **完全开源且透明**。

* **无加密**: 所有脚本均可直接查看。
* **无后门**: 仅作为个人技术笔记分享，不包含任何预编译的私有二进制文件。
* **自由使用**: 欢迎任何形式的 Fork、修改与分发，请遵循开源精神，共同进步。

---

### 🔗 传送门

* **个人博客:** [willwiza.dpdns.org](https://willwiza.dpdns.org)
* **GitHub:** [@willwiza](https://github.com/willwiza)

> **蔡鹅🪿出品必出炖锅**
> *个人使用记录，过分详细，不喜勿喷。*

---

## 📂 目录导航

- [📦 安装二进制文件](#-%E5%AE%89%E8%A3%85%E4%BA%8C%E8%BF%9B%E5%88%B6%E6%96%87%E4%BB%B6)
- [⚙️ 配置文件管理](#-%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E7%AE%A1%E7%90%86)
- [🚀 Systemd 自动化服务](#-systemd-%E8%87%AA%E5%8A%A8%E5%8C%96%E6%9C%8D%E5%8A%A1)
- [🔄 模式快速切换](#-%E6%A8%A1%E5%BC%8F%E5%BF%AB%E9%80%9F%E5%88%87%E6%8D%A2)
- [⚖️ 开源协议](#-%E5%BC%80%E6%BA%90%E5%8D%8F%E8%AE%AE)

---

## 📦 1. 安装二进制文件

### 下载与解压

根据硬件架构下载对应的版本（以 `amd64` 为例）：

```bash
# 下载指定版本 (目前为 v1.13 预发布版)
wget [https://github.com/SagerNet/sing-box/releases/download/v1.13.0-alpha.17/sing-box-1.13.0-alpha.17-linux-amd64.tar.gz](https://github.com/SagerNet/sing-box/releases/download/v1.13.0-alpha.17/sing-box-1.13.0-alpha.17-linux-amd64.tar.gz)

# 解压文件
tar -xf sing-box-1.13.0-alpha.17-linux-amd64.tar.gz

部署到系统路径
Bash
cd sing-box-1.13.0-alpha.17-linux-amd64
sudo mv sing-box /usr/local/bin/

# 验证安装是否成功
sing-box version

⚙️ 2. 配置文件管理
创建目录
Bash
sudo mkdir -p /etc/sing-box/tun
sudo mkdir -p /etc/sing-box/tproxy

配置文件与权限
Bash
sudo nano /etc/sing-box/config.json

# 权限加固 (默认 644)
sudo chmod 644 /etc/sing-box/config.json

🚀 3. Systemd 自动化服务
[!IMPORTANT]
此服务配置包含 ExecStartPre 指令，会自动开启 IPv4/IPv6 转发，无需手动修改 sysctl。
创建服务文件
Bash
sudo nano /lib/systemd/system/sing-box.service

写入服务配置
Ini, TOML
[Unit]
Description=sing-box service
Documentation=[https://sing-box.app](https://sing-box.app)
After=network.target nss-lookup.target

[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
ExecStartPre=/sbin/sysctl -w net.ipv4.ip_forward=1
ExecStartPre=/sbin/sysctl -w net.ipv6.conf.all.forwarding=1
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure
RestartSec=18s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target

🔄 4. 模式快速切换
利用目录分级管理不同的运行模式：
模式
快捷同步命令
TUN 模式
cp -f /etc/sing-box/tun/* /etc/sing-box/
TProxy 模式
cp -f /etc/sing-box/tproxy/* /etc/sing-box/
操作流程：
修改子目录配置 -> 2. 执行 cp 覆盖 -> 3. 重启服务。
Bash
sudo systemctl restart sing-box

⚖️ 5. 开源协议
本项目采用[MIT License](https://www.google.com/search?q=LICENSE)协议开源。你可以自由地使用、修改和分发。
Made with ❤️ by[willwiza](https://www.google.com/url?sa=E&source=gmail&q=https://github.com/willwiza)| 蔡鹅🪿出品   输出完整github readme.md 文件

```markdown
# 🪿 Debian Sing-Box 1.13 部署手册

<p align="center">
  <img src="https://img.shields.io/badge/Sing--Box-v1.13.0--alpha.17-62039a?style=for-the-badge&logo=sing-box&logoColor=white" />
  <img src="https://img.shields.io/badge/OS-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white" />
  <img src="https://img.shields.io/badge/Open%20Source-%E2%9D%A4-brightgreen?style=for-the-badge" />
</p>

<p align="center">
  <a href="https://github.com/willwiza">
    <img src="https://img.shields.io/badge/GitHub-willwiza-181717?style=flat-square&logo=github&logoColor=white" />
  </a>
  <a href="https://willwiza.dpdns.org">
    <img src="https://img.shields.io/badge/Blog-willwiza.dpdns.org-blue?style=flat-square&logo=rss&logoColor=white" />
  </a>
</p>

---

### 📢 完全开源说明

本仓库所涉及的所有安装脚本、配置文件模板及部署思路 **完全开源且透明**。  
- **无加密**：所有脚本均可直接查看与审计。  
- **无后门**：仅作为个人技术笔记分享，不包含任何预编译的私有二进制文件。[web:31]  
- **自由使用**：欢迎任何形式的 Fork、修改与分发，请遵循开源精神，共同进步。[web:31]

> 本仓库不打包 sing-box 二进制文件，仅提供安装与配置思路；sing-box 本体请从上游项目获取。[web:10][web:19]

---

### 🔗 传送门

- **个人博客**：[`willwiza.dpdns.org`](https://willwiza.dpdns.org)  
- **GitHub**：[@willwiza](https://github.com/willwiza)

> **蔡鹅🪿出品必出炖锅**  
> 个人使用记录，过分详细，不喜勿喷。

---

## 📂 目录导航

- [📦 安装二进制文件](#-1-安装二进制文件)
- [⚙️ 配置文件管理](#️-2-配置文件管理)
- [🚀 systemd 自动化服务](#-3-systemd-自动化服务)
- [🔄 模式快速切换](#-4-模式快速切换)
- [⚖️ 开源协议](#-5-开源协议)

---

## 📦 1. 安装二进制文件

### 下载与解压

根据硬件架构下载对应版本（以 `amd64` 为例，可替换为其他架构和版本）：[web:25]

```bash
# 下载指定版本 (当前示例为 v1.13 预发布版)
wget https://github.com/SagerNet/sing-box/releases/download/v1.13.0-alpha.17/sing-box-1.13.0-alpha.17-linux-amd64.tar.gz

# 解压文件
tar -xf sing-box-1.13.0-alpha.17-linux-amd64.tar.gz
```

> 也可以在本地下载后，通过 SSH 上传到服务器（例如 `/root` 目录）。[web:25]

### 部署到系统路径

```bash
cd sing-box-1.13.0-alpha.17-linux-amd64
sudo mv sing-box /usr/local/bin/
```

验证安装是否成功：

```bash
sing-box version
```

若输出版本号（例如 `v1.13.0-alpha.17`），说明安装成功。

---

## ⚙️ 2. 配置文件管理

### 创建目录

```bash
sudo mkdir -p /etc/sing-box/tun
sudo mkdir -p /etc/sing-box/tproxy
```


### 主配置文件与权限

```bash
sudo nano /etc/sing-box/config.json

# 权限加固 (默认 644)
sudo chmod 644 /etc/sing-box/config.json
```

建议将不同模式的配置文件（如 `tun/config.json`、`tproxy/config.json`）独立存放后，再按需同步至主运行目录 `/etc/sing-box/`。

---

## 🚀 3. systemd 自动化服务

> **IMPORTANT**
> 此服务配置包含 `ExecStartPre` 指令，会自动开启 IPv4/IPv6 转发，无需手动修改 `sysctl.conf`。[web:10]

### 创建服务文件

```bash
sudo nano /lib/systemd/system/sing-box.service
```

写入以下服务配置：

```ini
[Unit]
Description=sing-box service
Documentation=https://sing-box.app
After=network.target nss-lookup.target

[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
ExecStartPre=/sbin/sysctl -w net.ipv4.ip_forward=1
ExecStartPre=/sbin/sysctl -w net.ipv6.conf.all.forwarding=1
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure
RestartSec=18s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
```


### 启用与管理服务

```bash
# 重载 systemd 配置
sudo systemctl daemon-reload

# 设置开机自启
sudo systemctl enable sing-box

# 启动 / 重启 / 停止
sudo systemctl start sing-box
sudo systemctl restart sing-box
sudo systemctl stop sing-box
```

配置检查与日志查看：

```bash
# 检查配置文件语法
sing-box check -c /etc/sing-box/config.json

# 查看运行日志
journalctl -u sing-box -e
```


---

## 🔄 4. 模式快速切换

利用目录分级来管理不同运行模式的配置：


| 模式 | 快捷同步命令 |
| :-- | :-- |
| **TUN 模式** | `cp -f /etc/sing-box/tun/* /etc/sing-box/` |
| **TProxy 模式** | `cp -f /etc/sing-box/tproxy/* /etc/sing-box/` |

操作推荐流程：

1. 在子目录中编辑并保存对应模式的配置。
2. 使用 `cp` 命令将配置覆盖同步到 `/etc/sing-box/`。
3. 重启服务使新配置生效：
```bash
sudo systemctl restart sing-box
```

> TUN 与 TProxy 模式的 nftables / iptables 规则需根据自身网络拓扑进行调整。[web:13][web:14]

---

## ⚖️ 5. 开源协议

本项目（指本仓库内所有脚本、示例配置与文档）采用 **MIT License** 协议开源，你可以自由地使用、复制、修改和分发本仓库内容，但需在再分发时保留原始版权与许可声明。[web:15]

- 上游项目 **sing-box** 由 SagerNet 维护，是一个通用代理平台，遵循 **GPL-3.0-or-later（附名称使用/关联限制条款）** 授权，具体请以其官方仓库中的 `LICENSE` 为准。[web:10][web:19][web:33]
- 本仓库不修改、也不分发 sing-box 源码或二进制，因此仅对“部署脚本与文档部分”使用 MIT 协议进行授权，不影响上游项目的 GPL 授权条款。[web:10][web:15]

> 简单说：**上游 sing-box 按 GPL，仓库里的笔记和脚本按 MIT，各管各的，互不冲突。**[web:10][web:33]

---

### ❤️ Made with love

Made with ❤️ by [willwiza](https://github.com/willwiza) | 蔡鹅🪿出品
欢迎 Issue / PR 交流与改进配置思路。

```
<span style="display:none">[^1][^2]</span>

<div align="center">⁂</div>

[^1]: https://img.shields.io/badge/Sing--Box-v1.13.0--alpha.17-62039a?style=for-the-badge&logo=sing-box&logoColor=white
[^2]: https://img.shields.io/badge/OS-Debian-A81D33?style=for-the-badg```

