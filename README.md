# Network Monitor

监控网络稳定性，区分 WiFi 问题还是运营商问题，每小时记录一次网速。

## 依赖

```bash
brew install speedtest-cli
```

## 使用

```bash
chmod +x network_monitor.sh
nohup ./network_monitor.sh &
```

## 查看日志

日志按天保存在 `logs/` 目录，文件名格式：`logs/2026-04-07.log`

```bash
# 实时查看今天的日志
tail -f logs/$(date '+%Y-%m-%d').log

# 只看异常
grep -v "正常" logs/$(date '+%Y-%m-%d').log
```

## 停止

```bash
kill $(cat monitor.pid)
```

## 日志格式

```
2026-04-07 10:00:00 | 路由器:通 | 外网:断 | 运营商/WAN问题
--- 网速测试 2026-04-07 11:00:00 ---
Ping: 12.34 ms
Download: 98.76 Mbit/s
Upload: 45.67 Mbit/s
```

- **WiFi/路由器问题**：路由器不通，问题在本地
- **运营商/WAN问题**：路由器通但外网断，问题在运营商
