#以下为可选 防火墙规则 tun模式下可以不用，请使用 sing-box_no_nft.service替换sing-box.service
#tun模式-相应的配置文件
#sudo nano /etc/sing-box/tun/nftables.sh
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
