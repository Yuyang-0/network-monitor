#!/bin/bash
LOG=~/network_log.txt
ROUTER="192.168.1.1"

echo "开始监控: $(date)" >> "$LOG"
echo "时间 | 路由器 | 外网 | 结论" >> "$LOG"

COUNTER=0

while true; do
    TIME=$(date '+%Y-%m-%d %H:%M:%S')

    # 测路由器连通性
    if curl -s --max-time 2 "http://$ROUTER" > /dev/null 2>&1; then
        R="通"
    else
        R="断"
    fi

    # 测外网连通性
    if curl -s --max-time 3 "https://www.baidu.com" > /dev/null; then
        O="通"
    else
        O="断"
    fi

    # 判断问题在哪
    if [ "$R" = "断" ]; then
        REASON="WiFi/路由器问题"
    elif [ "$O" = "断" ]; then
        REASON="运营商/WAN问题"
    else
        REASON="正常"
    fi

    echo "$TIME | 路由器:$R | 外网:$O | $REASON" >> "$LOG"

    # 每60分钟测一次网速
    COUNTER=$((COUNTER + 1))
    if [ $((COUNTER % 60)) -eq 0 ]; then
        echo "--- 网速测试 $TIME ---" >> "$LOG"
        speedtest --simple >> "$LOG" 2>&1
    fi

    sleep 60
done
