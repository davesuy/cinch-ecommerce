#!/bin/bash

# System Monitoring Script for Production EC2 Instance
# Monitors memory, containers, and automatically restarts on critical issues
# Add to crontab: */5 * * * * /home/ubuntu/monitor-system.sh

LOG_FILE="/home/ubuntu/system-monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
PROJECT_DIR="/home/ubuntu/app"

echo "=== System Status at $TIMESTAMP ===" >> $LOG_FILE

# Memory usage
echo "Memory Usage:" >> $LOG_FILE
free -h >> $LOG_FILE

# Docker container status
echo -e "\nDocker Containers:" >> $LOG_FILE
cd $PROJECT_DIR && docker compose ps >> $LOG_FILE 2>&1

# Container memory usage
echo -e "\nContainer Memory Usage:" >> $LOG_FILE
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" >> $LOG_FILE

# Check for 502 errors in Nginx logs
echo -e "\nRecent 502 Errors:" >> $LOG_FILE
cd $PROJECT_DIR && docker compose logs --tail=50 nginx 2>/dev/null | grep "502" | tail -5 >> $LOG_FILE

# Check PHP-FPM process count
echo -e "\nPHP-FPM Processes:" >> $LOG_FILE
docker exec cinch_app ps aux 2>/dev/null | grep php-fpm | wc -l >> $LOG_FILE

echo -e "\n================================\n" >> $LOG_FILE

# Alert if memory is low (less than 200MB available)
AVAILABLE_MEM=$(free -m | awk 'NR==2{print $7}')
if [ "$AVAILABLE_MEM" -lt 200 ]; then
    echo "WARNING: Low memory detected ($AVAILABLE_MEM MB available) at $TIMESTAMP" >> $LOG_FILE

    # Optional: Restart containers if memory is critically low
    if [ "$AVAILABLE_MEM" -lt 100 ]; then
        echo "CRITICAL: Restarting containers due to low memory at $TIMESTAMP" >> $LOG_FILE
        cd $PROJECT_DIR && docker compose restart app
        echo "Container restart completed at $(date '+%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
    fi
fi

# Check if containers are running, restart if needed
CONTAINER_STATUS=$(cd $PROJECT_DIR && docker compose ps --format json | grep -c "running")
if [ "$CONTAINER_STATUS" -lt 3 ]; then
    echo "WARNING: Not all containers are running at $TIMESTAMP" >> $LOG_FILE
    cd $PROJECT_DIR && docker compose up -d
    echo "Containers restarted at $(date '+%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
fi

# Keep log file size manageable (keep last 1000 lines)
if [ -f "$LOG_FILE" ]; then
    tail -1000 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

