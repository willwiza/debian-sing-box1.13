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
2.粘贴以下内容

[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target network-online.target

[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStartPre=/bin/sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
ExecStart=/usr/local/bin/sing-box -D /var/lib/sing-box -C /etc/sing-box run
ExecReload=/bin/kill -HUP $MAINPID
ExecStartPost=bash /etc/sing-box/nftables.sh set
ExecStop=bash /etc/sing-box/nftables.sh clear
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target


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
############################################
#!/bin/bash

# =========================================================================
# sing-box 1.13 TUN 模式 nftables 脚本
# -------------------------------------------------------------------------
# 说明:
#   该脚本用于配置 nftables 规则，将所有流量透明代理到 sing-box 的 TUN 接口。
#   请以 root 身份运行此脚本。
# =========================================================================

if [ $# != 1 ]
then
    echo "使用方法: $(basename "$0") <set|clear>"
    exit 1
fi

# --- 变量配置区 ---
# 设备的默认出站网络接口，脚本自动获取
INTERFACE=$(ip route show default | awk '/default/ {print $5}')
# sing-box 的 TUN 接口名称，例如 tun0
sing_box_tun_name="tun0"

# 路由标记，用于识别需要代理的流量
PROXY_MARK=1
# 路由表 ID
PROXY_TABLE=100

# 忽略代理的 IP 地址 (局域网和保留地址)
# 你可以在这里添加你不想走代理的 IP 段
ReservedIP4='{ 127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, 100.64.0.0/10, 169.254.0.0/16, 172.16.0.0/12, 224.0.0.0/4, 240.0.0.0/4, 255.255.255.255/32 }'
ReservedIP6='{ ::1/128, fe80::/10, fc00::/7 }'

# =========================================================================
# 请勿修改以下内容，除非你了解其作用
# =========================================================================

nftrule=$(cat <<EOF
table inet sing-box {
    chain prerouting_tun {
        type filter hook prerouting priority mangle; policy accept;
       # 确保所有目的端口为 22 的 TCP 流量不被代理
        meta l4proto tcp th dport 22 accept comment "绕过SSH流量"        
        # 绕过保留 IP
        ip daddr $ReservedIP4 accept
        ip6 daddr $ReservedIP6 accept
        
        # 绕过 sing-box 自身发出的流量，防止循环
        iifname $sing_box_tun_name accept

        # 设置标记，将所有 TCP 和 UDP 流量重定向到 TUN 接口
        meta l4proto { tcp, udp } meta mark set $PROXY_MARK accept
    }

    chain output_tun {
        type route hook output priority mangle; policy accept;

        # 绕过保留 IP
        ip daddr $ReservedIP4 accept
        ip6 daddr $ReservedIP6 accept

        # 绕过 sing-box 自身发出的流量
        oifname != $INTERFACE accept
        
        # 将所有 TCP 和 UDP 流量标记
        meta l4proto { tcp, udp } meta mark set $PROXY_MARK accept
    }
}
EOF
)

function clear_rules() {
    echo "正在清空 iptables 和 nftables 规则..."
    
    # 清空 ip rule
    ip -f inet rule del fwmark $PROXY_MARK lookup $PROXY_TABLE 2>/dev/null
    ip -f inet route del local default dev $sing_box_tun_name table $PROXY_TABLE 2>/dev/null

    # 清空 nftables 规则集
    nft flush ruleset
}

function set_rules() {
    # 启用 IP 转发
    #sysctl -w net.ipv4.ip_forward=1 > /dev/null
    
    # 创建路由规则和路由表
    echo "正在配置路由规则..."
    ip -f inet rule add fwmark $PROXY_MARK lookup $PROXY_TABLE
    ip -f inet route add local default dev $sing_box_tun_name table $PROXY_TABLE
    
    # 将 nftables 规则写入系统
    echo "正在配置 nftables 规则..."
    echo "$nftrule" | nft -f -

    echo "nftables 脚本执行完毕。请确保 sing-box 已在 TUN 模式下运行。"
}

if [ "$1" = 'set' ]; then
    clear_rules
    set_rules
elif [ "$1" = 'clear' ]; then
    clear_rules
else
    echo "参数错误: 只接受 'set' 或 'clear'"
    exit 1
fi

##########################################
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
