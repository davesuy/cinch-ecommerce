#!/bin/bash

# Post-Reboot Fix Script
# Run this after EC2 instance reboots to fix Docker daemon and Laravel cache issues
# Usage: ./post-reboot-fix.sh

PROJECT_DIR="/home/ubuntu/app"

echo "==================================="
echo "  POST-REBOOT FIX"
echo "==================================="
echo ""

cd $PROJECT_DIR

echo "🔧 Fixing Docker daemon..."
# Fix hostname resolution
echo "127.0.0.1 ip-10-0-1-123" | sudo tee -a /etc/hosts

# Restart Docker
sudo systemctl restart docker

# Check if restart succeeded
if sudo systemctl is-active --quiet docker; then
    echo "✅ Docker started successfully."
else
    echo "❌ Docker failed to start. Checking logs..."
    sudo journalctl -u docker -n 50
    echo "Manual intervention required. Exiting."
    exit 1
fi

# Ensure user is in docker group
sudo usermod -aG docker ubuntu

echo ""
echo "📋 Checking container status..."
docker compose ps

echo ""
echo "🧹 Clearing corrupted Laravel cache..."
docker exec cinch_app php artisan config:clear
docker exec cinch_app php artisan route:clear
docker exec cinch_app php artisan view:clear
docker exec cinch_app php artisan cache:clear

echo ""
echo "🔄 Restarting app container to clear in-memory state..."
docker compose restart app

echo ""
echo "⏳ Waiting for app to restart..."
sleep 5

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
echo "Note: Log out and back in for Docker group changes to take effect."
