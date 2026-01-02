# Debian 安装与配置 sing-box v1.13

---
> 🪿 **蔡鹅出品，必出炖锅**  
> 个人使用记录，过分详细，不喜勿喷。

本仓库记录 Debian 系统上 **sing-box v1.13** 的手动安装、systemd 管理和 TUN/TProxy 配置全过程。[memory:3][web:13]

## 🚀 快速开始

- **手动安装**：下载二进制 → 配置 systemd。
- **一键脚本**：`bash <(curl -fsSL https://sing-box.app/deb-install.sh)`。
- **模式**：TUN / TProxy + nftables。

## 📦 一、安装客户端

### 🔴 预发布版 (v1.13.0-alpha.17)

```bash
wget https://github.com/SagerNet/sing-box/releases/download/v1.13.0-alpha.17/sing-box-1.13.0-alpha.17-linux-amd64.tar.gz
tar -xf sing-box-1.13.0-alpha.17-linux-amd64.tar.gz
cd sing-box-1.13.0-alpha.17-linux-amd64
sudo mv sing-box /usr/local/bin/
sing-box version
```


### 🟢 稳定版 (v1.13.0)

```bash
wget https://github.com/SagerNet/sing-box/releases/download/v1.13.0/sing-box-1.13.0-linux-amd64.tar.gz
# 同上解压&安装步骤
```


## ⚙️ 二、配置与 systemd 服务

### 1. 配置目录

```bash
sudo mkdir -p /etc/sing-box
sudo nano /etc/sing-box/config.json  # 填入节点配置
sudo chmod 644 /etc/sing-box/config.json
```


### 2. 服务文件

```bash
sudo nano /lib/systemd/system/sing-box.service
```

```ini
[Unit]
Description=Sing-box Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure
RestartSec=5
User=root
WorkingDirectory=/var/lib/sing-box

[Install]
WantedBy=multi-user.target
```


### 3. 启动服务

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now sing-box
sing-box check -c /etc/sing-box/config.json  # ✅ 测试
journalctl -u sing-box -e  # 📄 日志
```


## 🔒 三、防火墙模式配置

| 模式 | 步骤 |
| :-- | :-- |
| **TUN** | `sudo nano /etc/sing-box/tun/nftables.sh`<br>`cp -f /etc/sing-box/tun/* /etc/sing-box/`<br>`sing-box -D /var/lib/sing-box -C /etc/sing-box check` |
| **TProxy** | `sudo nano /etc/sing-box/tproxy/nftables.sh`<br>`cp -f /etc/sing-box/tproxy/* /etc/sing-box/` |

> ⚠️ **启用 IP 转发**：`sysctl -w net.ipv4.ip_forward=1`（持久化 `/etc/sysctl.conf`）。[memory:2]

## 🎯 四、一键安装脚本

```bash
bash <(curl -fsSL https://sing-box.app/deb-install.sh)
```

自动安装最新版 + systemd 支持。[web:12]

## 📋 五、常用命令速查

```bash
# 检查配置
sing-box check -c /etc/sing-box/config.json

# 服务管理
systemctl {start|stop|restart|status} sing-box

# 调试运行
sing-box run -c /etc/sing-box/config.json

# 日志查看
journalctl -u sing-box -e -f
```


## ⚖️ 六、开源协议说明

```
├── 本仓库脚本&文档：MIT License（自由 fork/PR）
└── sing-box 上游：GPL-3.0-or-later（SagerNet 维护）
    └ 遵守：分发需开源代码，不暗示官方关联
```

[详情见上游 LICENSE][web:13][web:24]

## 🪿 七、蔡鹅碎碎念

- 🔥 **火候**：系统调教如炖锅，慢工出细活。
- 💾 **备份**：改 config.json 前，先 `cp config.json config.json.bak`。
- 🤝 **交流**：欢迎 Issue/PR 分享你的优化方案！

---

**🌐 关注更新**：
[![微博/博客](https://img.shields.io/badge/%E5%8D%9A%E5%AE%A2-willwiza.dpdns.org-brightgreen?style=flat-square&logo=weibo)](http://willwiza.dpdns.org)
[![GitHub](https://img.shields.io/badge/GitHub-willwiza-181717?style=flat-square&logo=github)](https://github.com/willwiza)

**Made with ❤️ by 蔡小白🪿** [conversation_history:7][memory:4]

```
