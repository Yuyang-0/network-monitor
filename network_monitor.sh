#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
PID_FILE="$SCRIPT_DIR/monitor.pid"
ROUTER="192.168.1.1"

# 防止重复运行
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "已在运行中 (PID: $(cat "$PID_FILE"))"
    exit 1
fi

mkdir -p "$LOG_DIR"
echo $$ > "$PID_FILE"
trap "rm -f '$PID_FILE'" EXIT

get_log() {
    echo "$LOG_DIR/$(date '+%Y-%m-%d').log"
}

echo "开始监控: $(date)" >> "$(get_log)"

COUNTER=0

while true; do
    TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LOG=$(get_log)

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
