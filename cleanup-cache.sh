#!/bin/bash

# Laravel Cache Cleanup Script for Production
# Clears caches and old files to prevent memory buildup
# Add to crontab: 0 2 * * * /home/ubuntu/cleanup-cache.sh >> /home/ubuntu/cleanup.log 2>&1

PROJECT_DIR="/home/ubuntu/cinch-ecommerce"

echo "=== Starting cache cleanup at $(date) ==="
cd $PROJECT_DIR

# Clear Laravel caches
echo "Clearing Laravel caches..."
docker compose exec -T app php artisan cache:clear
docker compose exec -T app php artisan config:clear
docker compose exec -T app php artisan route:clear
docker compose exec -T app php artisan view:clear

# Clear old sessions (keep last 7 days)
echo "Cleaning old sessions..."
docker compose exec -T app find storage/framework/sessions -type f -mtime +7 -delete 2>/dev/null

# Clear old logs (keep last 7 days)
echo "Cleaning old logs..."
docker compose exec -T app find storage/logs -name "*.log" -type f -mtime +7 -delete 2>/dev/null

# Optimize autoloader
echo "Optimizing autoloader..."
docker compose exec -T app composer dump-autoload -o --no-dev 2>/dev/null || echo "Composer optimize skipped"

# Restart PHP-FPM to clear memory
echo "Restarting PHP-FPM..."
docker compose restart app

echo "=== Cache cleanup completed at $(date) ==="
echo ""

