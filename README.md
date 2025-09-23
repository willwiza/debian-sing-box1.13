# debian-sing-box1.13
蔡鹅🪿出品必出炖锅/////个人使用记录，过分详细，不喜勿喷/////蔡鹅🪿出品必出炖锅
安装sing-box客户端(目前是预发布版)

第1步：下载 sing-box1.13 二进制文件 可按照网址自行替换版本
wget https://github.com/SagerNet/sing-box/releases/download/v1.13.0-alpha.17/sing-box-1.13.0-alpha.17-linux-amd64.tar.gz
####或者下载ssh上传到root目录
第2步：解压缩下载的文件
tar -xf sing-box-1.13.0-alpha.17-linux-amd64.tar.gz
第3步：安装 sing-box
cd /root/sing-box-1.13.0-alpha.17-linux-amd64
# 将可执行文件移动到 /usr/local/bin
sudo mv sing-box /usr/local/bin/
第4步：验证安装
sing-box version

这是一个非常好的问题。下面是在 Debian 系统上完整安装和配置 sing-box 客户端的详细步骤。

第1步：下载 sing-box 二进制文件
首先，你需要从 GitHub 下载 sing-box 的最新稳定版本。通常，amd64 是大多数桌面和服务器的首选架构。

打开终端，并使用 wget 命令下载文件。

Bash

wget https://github.com/SagerNet/sing-box/releases/download/v1.13.0/sing-box-1.13.0-linux-amd64.tar.gz
提示：如果你需要其他架构（如 arm64），请在 GitHub Releases 页面找到对应的链接并替换上面的 URL。

解压下载的文件：

Bash

tar -xf sing-box-1.13.0-linux-amd64.tar.gz
这会创建一个名为 sing-box-1.13.0-linux-amd64 的文件夹。

第2步：安装 sing-box
将 sing-box 可执行文件移动到系统的可执行路径中，这样你可以在任何位置运行它。

进入解压后的文件夹：

Bash

cd sing-box-1.13.0-linux-amd64
将可执行文件移动到 /usr/local/bin：

Bash

sudo mv sing-box /usr/local/bin/
验证安装：
运行以下命令来确认 sing-box 已经正确安装：

Bash

sing-box version
如果它输出了版本号，例如 v1.13.0，则说明安装成功。

第3步：创建配置文件

1.创建配置文件夹:
sudo mkdir -p /etc/sing-box
2.创建配置文件：
sudo nano /etc/sing-box/config.json
####默认权限恢复###sudo chmod 644 /etc/sing-box/config.json

第4步：创建 systemd 服务

tun模式配置
1.创建服务文件：
更改sing-box.service配置内容（开机自动开启ip转发）

nano /lib/systemd/system/sing-box.service

2.粘贴以下内容 sing-box.service

3.启用并启动服务：(最后一步，请先配置好节点文件)

sudo systemctl daemon-reload      # 重新加载 systemd 配置

sudo systemctl enable sing-box    # 设置开机自启

sudo systemctl start sing-box     # 立即启动服务

运行前可以测试文件语法：
sing-box check -c /etc/sing-box/config.json

4.##debian一键安装命令:可选
##bash <(curl -fsSL [https://sing-box.app/deb-install.sh](https://sing-box.app/deb-install.sh))

5.可选 防火墙规则
tun模式-相应的配置文件
sudo nano /etc/sing-box/tun/nftables.sh

#根据自己模式复制配置文件到运行目录

cp -f /etc/sing-box/tun/nftables.sh /etc/sing-box

cp -f /etc/sing-box/tun/config.json /etc/sing-box
或者

cp -f /etc/sing-box/tun/* /etc/sing-box

/usr/local/bin/sing-box -D /var/lib/sing-box -C /etc/sing-box check     #测试配置文件合法性

tproxy模式-相应的配置文件
sudo nano /etc/sing-box/tproxy/nftables.sh

cp -f /etc/sing-box/tproxy/nftables.sh /etc/sing-box

cp -f /etc/sing-box/tproxy/config.json /etc/sing-box

或者

cp -f /etc/sing-box/tproxy/* /etc/sing-box
