#!/bin/bash

# 没 root 权限啥也干不了
if [ "$EUID" -ne 0 ]; then
  echo "权限不足，请使用 sudo 或 root 用户运行。"
  exit
fi

echo ">> 启动『撤防程序』，正在还原系统环境..."

# 1. 拆除定时炸弹
sed -i '/ipset flush china_ip/d' /etc/crontab
echo ">> 定时更新引擎已拆除。"

# 2. 严格按环境隔离剥离规则
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    echo ">> 正在从 UFW 体系中剥离防御逻辑..."
    
    rm -f /etc/ufw/before.init
    sed -i '/china_ip/d' /etc/ufw/before.rules
    
    ufw reload > /dev/null 2>&1
    echo ">> UFW 专属配置清理完毕。"
else
    echo ">> 正在还原原生 iptables 规则..."
    
    iptables -D INPUT -i lo -j ACCEPT 2>/dev/null
    iptables -D INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null
    iptables -D INPUT -m set --match-set china_ip src -j ACCEPT 2>/dev/null
    iptables -D INPUT -p tcp --dport 22 -m set ! --match-set china_ip src -j DROP 2>/dev/null
    
    if command -v netfilter-persistent >/dev/null 2>&1; then
        netfilter-persistent save > /dev/null 2>&1
    fi
    echo ">> 原生 iptables 规则抹除完毕。"
fi

# 3. 最后安全销毁字典（必须等防火墙解绑后执行）
ipset destroy china_ip 2>/dev/null
rm -f /etc/iptables/ipsets
echo ">> 地域白名单字典已物理销毁。"

echo ">> 卸载完成！系统已回归初始防御状态。"
