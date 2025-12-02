#!/bin/bash

# Post-Reboot Fix Script
# Run this after EC2 instance reboots to fix Laravel cache issues
# Usage: ./post-reboot-fix.sh

PROJECT_DIR="/home/ubuntu/app"

echo "==================================="
echo "  POST-REBOOT FIX"
echo "==================================="
echo ""

cd $PROJECT_DIR

echo "📋 Checking container status..."
docker compose ps

echo ""
echo "🧹 Clearing corrupted Laravel cache..."
docker exec cinch_app php artisan optimize:clear

echo ""
echo "⚡ Rebuilding cache for production..."
docker exec cinch_app php artisan config:cache
docker exec cinch_app php artisan view:cache

echo ""
echo "✅ Testing application..."
sleep 2
curl -I http://localhost | head -5

echo ""
echo "==================================="
echo "  ✅ FIX COMPLETE!"
echo "==================================="
echo ""
echo "Website should now be accessible at:"
echo "http://51.21.234.223"

