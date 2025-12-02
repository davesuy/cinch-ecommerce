#!/bin/bash

# Production Deployment Script for EC2
# This script deploys updates and applies 502 fix configurations
# Run on EC2: cd /home/ubuntu/cinch-ecommerce && ./deploy-production.sh

set -e  # Exit on error

echo "==================================="
echo "  CINCH E-COMMERCE DEPLOYMENT"
echo "==================================="
echo ""

PROJECT_DIR="/home/ubuntu/cinch-ecommerce"
cd $PROJECT_DIR

# Pull latest code
echo "📥 Pulling latest code from Git..."
git pull origin main

# Make scripts executable
echo "🔧 Setting script permissions..."
chmod +x monitor-system.sh cleanup-cache.sh deploy-production.sh

# Rebuild and restart containers
echo "🐳 Rebuilding Docker containers..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache

echo "🚀 Starting containers..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Wait for containers to be ready
echo "⏳ Waiting for containers to start..."
sleep 10

# Run Laravel optimizations
echo "⚡ Running Laravel optimizations..."
docker compose exec -T app php artisan config:cache
docker compose exec -T app php artisan route:cache
docker compose exec -T app php artisan view:cache
docker compose exec -T app php artisan optimize

# Run migrations (if any)
echo "📊 Running database migrations..."
docker compose exec -T app php artisan migrate --force

# Set proper permissions
echo "🔐 Setting storage permissions..."
docker compose exec -T app chown -R www-data:www-data storage bootstrap/cache
docker compose exec -T app chmod -R 775 storage bootstrap/cache

# Verify containers are running
echo ""
echo "✅ Checking container status..."
docker compose ps

# Show memory usage
echo ""
echo "💾 Current memory usage:"
free -h

echo ""
echo "==================================="
echo "  ✅ DEPLOYMENT COMPLETE!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Set up monitoring cron job:"
echo "   crontab -e"
echo "   Add: */5 * * * * $PROJECT_DIR/monitor-system.sh"
echo ""
echo "2. Set up cleanup cron job:"
echo "   crontab -e"
echo "   Add: 0 2 * * * $PROJECT_DIR/cleanup-cache.sh >> /home/ubuntu/cleanup.log 2>&1"
echo ""
echo "3. Monitor logs:"
echo "   tail -f /home/ubuntu/system-monitor.log"
echo ""

