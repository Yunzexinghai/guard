#!/bin/bash

# 拦截非 root 权限的无效执行
if [ "$EUID" -ne 0 ]; then
  echo "权限不足，请直接使用 root 用户或加上 sudo 执行本脚本。"
  exit
fi

echo ">> 正在唤醒系统更新引擎，拉取最新软件源..."
apt update > /dev/null 2>&1

echo ">> 正在为你挂载日常排错所需的『瑞士军刀』..."
COMMON_TOOLS="curl wget git vim htop unzip net-tools lsof jq tree"
apt install -y $COMMON_TOOLS > /dev/null 2>&1

echo ">> 基础工具装配完毕。准备构筑核心地域防御网..."
apt install -y ipset > /dev/null 2>&1
mkdir -p /etc/iptables

echo ">> 正在向运行内存灌装中国大陆 IP 字典，并物理刻录至硬盘..."
ipset create china_ip hash:net -exist
ipset flush china_ip
curl -s http://www.ipdeny.com/ipblocks/data/countries/cn.zone | sed -e 's/^/add china_ip /' | ipset -! restore
ipset save > /etc/iptables/ipsets

echo ">> 正在主板上挂载『每月 1 号凌晨』的自动换血引擎..."
CRON_CMD='0 0 1 * * root /usr/sbin/ipset flush china_ip && /usr/bin/curl -s http://www.ipdeny.com/ipblocks/data/countries/cn.zone | sed -e "s/^/add china_ip /" | /usr/sbin/ipset -! restore && /usr/sbin/ipset save > /etc/iptables/ipsets'
if ! grep -q "ipset flush china_ip" /etc/crontab; then
    echo "$CRON_CMD" >> /etc/crontab
fi

# 核心隔离区：严格判定接管者
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    echo ">> 探测到系统由 UFW 接管前台，启动融合改造模式..."

    cat << 'EOF' > /etc/ufw/before.init
#!/bin/sh
case "$1" in
start)
    /usr/sbin/ipset restore < /etc/iptables/ipsets || true
    ;;
stop)
    ;;
esac
EOF
    chmod +x /etc/ufw/before.init

    # 【关键修复点】：将锚点改到链声明完毕之后
    if ! grep -q "china_ip" /etc/ufw/before.rules; then
        sed -i '/^# End required lines/a \
-A ufw-before-input -m set --match-set china_ip src -j ACCEPT\n\
-A ufw-before-input -p tcp --dport 22 -m set ! --match-set china_ip src -j DROP' /etc/ufw/before.rules
    fi

    ufw reload > /dev/null 2>&1
    echo ">> UFW 底层规则注销完毕，防御网已无缝植入！"

else
    echo ">> 探测到系统为原生纯净环境，启动 iptables 物理刻录模式..."
    apt install -y iptables-persistent ipset-persistent > /dev/null 2>&1

    # 大扫除，防止规则反复堆叠
    iptables -D INPUT -i lo -j ACCEPT 2>/dev/null
    iptables -D INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null
    iptables -D INPUT -m set --match-set china_ip src -j ACCEPT 2>/dev/null
    iptables -D INPUT -p tcp --dport 22 -m set ! --match-set china_ip src -j DROP 2>/dev/null

    # 重新立起大门
    iptables -I INPUT 1 -i lo -j ACCEPT
    iptables -I INPUT 2 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -I INPUT 3 -m set --match-set china_ip src -j ACCEPT
    iptables -I INPUT 4 -p tcp --dport 22 -m set ! --match-set china_ip src -j DROP

    netfilter-persistent save > /dev/null 2>&1
    echo ">> 原生防护网已死死焊在硬盘底层！"
fi

echo ">> 部署彻底完成！你的机器现在固若金汤且工具齐全。"
