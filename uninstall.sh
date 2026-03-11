#!/bin/bash

# 没 root 权限啥也干不了
if [ "$EUID" -ne 0 ]; then
  echo "权限不足，请使用 sudo 或 root 用户运行。"
  exit
fi

echo ">> 启动『撤防程序』，正在还原系统环境..."

# 1. 清理定时任务
# 删掉那个每个月 1 号凌晨更新 IP 库的闹钟
sed -i '/ipset flush china_ip/d' /etc/crontab
echo ">> 定时更新引擎已拆除。"

# 2. 探测环境并还原规则
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    echo ">> 正在从 UFW 体系中剥离防御逻辑..."
    
    # 删掉 UFW 启动前的私活文件
    rm -f /etc/ufw/before.init
    
    # 把写在 before.rules 里的那几行拦截代码删掉
    sed -i '/china_ip/d' /etc/ufw/before.rules
    
    # 让 UFW 重启加载，清空内存残留
    ufw reload > /dev/null 2>&1
else
    echo ">> 正在还原原生 iptables 规则..."
    
    # 按照之前添加的逻辑，把那四道门精准拆掉
    iptables -D INPUT -i lo -j ACCEPT 2>/dev/null
    iptables -D INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null
    iptables -D INPUT -m set --match-set china_ip src -j ACCEPT 2>/dev/null
    iptables -D INPUT -p tcp --dport 22 -m set ! --match-set china_ip src -j DROP 2>/dev/null
    
    # 保存一下此时清空后的状态
    if command -v netfilter-persistent >/dev/null 2>&1; then
        netfilter-persistent save > /dev/null 2>&1
    fi
fi

# 3. 销毁 IP 字典
# 既然不拦截了，内存里的这八千多个 IP 段也就没用了
ipset destroy china_ip 2>/dev/null
# 删掉硬盘上的物理备份
rm -f /etc/iptables/ipsets
echo ">> 地域白名单字典已物理销毁。"

echo ">> 卸载完成！系统已回归初始防御状态。"
