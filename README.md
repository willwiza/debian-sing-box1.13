Debian 安装与配置单机


Debian 安装与配置 sing-box v1.13
🪿蔡鹅出品，必出炖锅
个人使用记录，过分详细，不喜勿喷。

简介
本项目记录了 Debian 系统上手动安装、配置及通过 systemd 管理单机客户端的完整过程，适合有一定 Linux 基础的用户参考。[web:3]

一、安装单机客户端
1.预发布版安装示例
下载 sing-box 1.13 预发布版二进制文件（可自行替换为其他版本）：[web:1]

wget https://github.com/SagerNet/sing-box/releases/download/v1.13.0-alpha.17/sing-box-1.13.0-alpha.17-linux-amd64.tar.gz
也可以在本地下载后，通过SSH上传到服务器的/root目录。

解压：

tar -xf sing-box-1.13.0-alpha.17-linux-amd64.tar.gz
移动执行文件到系统路径（示例/root以为下载目录）：

cd /root/sing-box-1.13.0-alpha.17-linux-amd64
sudo mv sing-box /usr/local/bin/
验证安装：

sing-box version
若输出版本号（如v1.13.0-alpha.17），说明安装成功。

2. 稳定版安装示例
下载 sing-box 稳定版 1.13.0（可替换为最新版本）：[web:3][web:25]

wget https://github.com/SagerNet/sing-box/releases/download/v1.13.0/sing-box-1.13.0-linux-amd64.tar.gz
解压：

tar -xf sing-box-1.13.0-linux-amd64.tar.gz
进入目录并安装：

cd sing-box-1.13.0-linux-amd64
sudo mv sing-box /usr/local/bin/
验证：

sing-box version
二、创建配置文件
创建配置目录：
sudo mkdir -p /etc/sing-box
创建主配置文件：
sudo nano /etc/sing-box/config.json
（任选）恢复/设置默认权限：
sudo chmod 644 /etc/sing-box/config.json
可以在保存前先准备好你的节点配置（如：TUN/TProxy 等模式的JSON文件）。

三、创建systemd服务（TUN模式示例）
1.创建服务文件
sudo nano /lib/systemd/system/sing-box.service
示例内容（请修改路径与参数）：[web:1]

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
首先启动自动开启 IP 转发，可在此处调用脚本或在系统级别开启 sysctl 设置。

2. 启用与启动服务
sudo systemctl daemon-reload      # 重新加载 systemd 配置
sudo systemctl enable sing-box    # 设置开机自启
sudo systemctl start sing-box     # 立即启动服务
运行前可以测试配置文件语法：

sing-box check -c /etc/sing-box/config.json
若配置错误，可通过以下命令查看日志：

journalctl -u sing-box -e
四、Debian一键安装（可选）
官方提供了简单的一键脚本，适合手动搬运二进制的场景：[web:8][web:25]

bash <(curl -fsSL https://sing-box.app/deb-install.sh)
脚本会自动下载并安装最新可用版本，具体行为与官方文档与脚本相同。[web:8]

五、防火墙与模式配置
以下以 nftables + sing-box 为例，按模式分别说明需要复制的文件位置。

1.TUN模式
编辑TUN模式的nftables规则脚本：

sudo nano /etc/sing-box/tun/nftables.sh
将对应模式下的配置复制到运行目录：

# 复制单个文件
cp -f /etc/sing-box/tun/nftables.sh /etc/sing-box
cp -f /etc/sing-box/tun/config.json /etc/sing-box

# 或者一次性复制整个目录内容
cp -f /etc/sing-box/tun/* /etc/sing-box
配置测试合法性：

/usr/local/bin/sing-box -D /var/lib/sing-box -C /etc/sing-box check
请确保内核已启用TUN支持，并正确设置路由及IP转发。

2.TProxy模式
编辑 TProxy 模式 nftables 规则脚本：

sudo nano /etc/sing-box/tproxy/nftables.sh
复制对应文件到运行目录：

cp -f /etc/sing-box/tproxy/nftables.sh /etc/sing-box
cp -f /etc/sing-box/tproxy/config.json /etc/sing-box

# 或者一次性复制整个目录内容
cp -f /etc/sing-box/tproxy/* /etc/sing-box
TProxy模式通常配置透明代理、防火墙策略以及策略路由使用，具体规则可按实际网络拓扑调整。[web:13][web:14]

六、开源与版权说明
本仓库快照个人学习与使用记录，不包含sing-box源代码，仅引用其公开释放的二进制与官方文档链接。[web:19]
sing-box 项目由 SagerNet 维护，使用GPL-3.0-or-later（带名称使用/关联附加条款）授权，具体条款请以上游项目 LICENSE 分别：[web:10][web:16][web:13][web:26]
使用、本地构建或分发单盒时，应遵守 GPLv3 附加条款，包括但不限于在分发修改版本时公开完整源代码，并不得在默认许可情况下使用或暗示与原项目的名称关联。[web:10][web:16]
如果你在自己的仓库中包含sing-box的二进制或修改后的源码，请务必在项目根目录添加完整的LICENSE文件，并在README中明确标明使用的开源许可证。[web:15][web:21]
简单理解：本README只是一个使用笔记，真正的开源协议归属于上游单盒项目；如要做二次开发或集成发布，请认真阅读并遵守GPL-3.0-or-later相关要求。[web:10][web:16]

七、常用命令备忘
检查配置文件（在配置目录中）：
cd /etc/sing-box
sing-box check
指定配置路径进行检查：
sing-box check -c /etc/sing-box/config.json
以服务方式运行：
systemctl start sing-box
systemctl stop sing-box
systemctl restart sing-box
独立前台运行（调试用）：
sing-box run -c /etc/sing-box/config.json
八、碎碎念
🪿蔡养小记：

炖锅讲究火候，折腾系统也一样，慢工出细活。
配置修改配置前，记得先备份原来的config.json，出锅翻车时好快速回滚。
如果你也有更优雅的 Debian + sing-box 配置方式，欢迎自行 Fork 后补充说明。
Made with ❤️ by willwiza | 蔡小白🪿出品
