#!/bin/bash
# Apply Memory Optimization Fix for EC2 Instance
# This script fixes the 502 Bad Gateway issue caused by memory exhaustion

set -e

echo "========================================="
echo "Memory Optimization Deployment Script"
echo "========================================="
echo ""

# Configuration
APP_DIR="/home/ubuntu/app"
BACKUP_DIR="/home/ubuntu/backups/$(date +%Y%m%d_%H%M%S)"

# Check if we're on the EC2 instance
if [ ! -d "$APP_DIR" ]; then
    echo "Error: $APP_DIR not found. Are you on the EC2 instance?"
    exit 1
fi

# Create backup directory
echo "Creating backup..."
mkdir -p "$BACKUP_DIR"
sudo cp -r "$APP_DIR/docker" "$BACKUP_DIR/" 2>/dev/null || true
sudo cp "$APP_DIR/docker-compose.yml" "$BACKUP_DIR/" 2>/dev/null || true
sudo cp "$APP_DIR/docker-compose.prod.yml" "$BACKUP_DIR/" 2>/dev/null || true
echo "✅ Backup created at: $BACKUP_DIR"
echo ""

# Add swap space (2GB) to prevent OOM kills
echo "Setting up swap space..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

    # Make swap permanent
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    fi

    # Optimize swap usage
    sudo sysctl vm.swappiness=10
    sudo sysctl vm.vfs_cache_pressure=50

    # Make sysctl settings permanent
    if ! grep -q 'vm.swappiness' /etc/sysctl.conf; then
        echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
        echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
    fi

    echo "✅ Swap space created and configured"
else
    echo "✅ Swap space already exists"
fi
echo ""

# Show current memory status
echo "Current memory status:"
free -h
echo ""

# Stop containers gracefully
echo "Stopping Docker containers..."
cd "$APP_DIR"
sudo docker compose down
echo "✅ Containers stopped"
echo ""

# Update PHP configuration
echo "Updating PHP configuration..."
sudo tee "$APP_DIR/docker/php/local.ini" > /dev/null << 'EOF'
upload_max_filesize=40M
post_max_size=40M
memory_limit=128M
max_execution_time=60
max_input_time=60

; OPcache settings to improve performance and reduce memory usage
opcache.enable=1
opcache.memory_consumption=64
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.validate_timestamps=0

; Realpath cache to reduce filesystem calls
realpath_cache_size=4096K
realpath_cache_ttl=600
EOF
echo "✅ PHP configuration updated"
echo ""

# Update PHP-FPM configuration
echo "Updating PHP-FPM configuration..."
sudo tee "$APP_DIR/docker/php/www.conf" > /dev/null << 'EOF'
[www]
; Process manager settings optimized for low-memory EC2 instances
; Reduces max_children to prevent memory exhaustion and 502 errors
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.max_requests = 500
pm.process_idle_timeout = 10s

; Resource limits
request_terminate_timeout = 60s
rlimit_files = 1024
rlimit_core = 0

; Logging for debugging
catch_workers_output = yes
decorate_workers_output = no
EOF
echo "✅ PHP-FPM configuration updated"
echo ""

# Update MySQL production configuration
echo "Updating MySQL configuration..."
sudo tee "$APP_DIR/docker/mysql/my.prod.cnf" > /dev/null << 'EOF'
[mysqld]
# Production MySQL configuration optimized for t2.micro (1GB RAM)
default_authentication_plugin = mysql_native_password

# Memory optimization for low-memory instances
max_connections = 30
innodb_buffer_pool_size = 128M
innodb_log_file_size = 32M
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 2
skip-name-resolve

# Performance tuning
query_cache_type = 0
query_cache_size = 0
table_open_cache = 100
max_heap_table_size = 16M
tmp_table_size = 16M

# Logging (disable general log in production)
general_log = 0
slow_query_log = 1
slow_query_log_file = /var/lib/mysql/slow.log
long_query_time = 2

# Connection settings
wait_timeout = 28800
interactive_timeout = 28800
max_allowed_packet = 16M

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Binary logging
server-id = 1
log_bin = /var/lib/mysql/mysql-bin.log
binlog_expire_logs_seconds = 604800
max_binlog_size = 100M
EOF
echo "✅ MySQL configuration updated"
echo ""

# Update docker-compose.prod.yml with stricter memory limits
echo "Updating docker-compose.prod.yml..."
sudo tee "$APP_DIR/docker-compose.prod.yml" > /dev/null << 'EOF'
# Docker Compose for Production - Memory Optimized
# This file extends docker-compose.yml for production-specific configurations
# Use: docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

version: '3.8'

services:
  app:
    restart: always
    environment:
      APP_ENV: production
      APP_DEBUG: "false"
    # Reduced memory limits to prevent OOM on t2.micro
    deploy:
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M
    volumes:
      - ./storage:/var/www/html/storage
      - ./bootstrap/cache:/var/www/html/bootstrap/cache
      - ./docker/php/local.ini:/usr/local/etc/php/conf.d/local.ini
      - ./docker/php/www.conf:/usr/local/etc/php-fpm.d/zz-custom.conf

  mysql:
    restart: always
    deploy:
      resources:
        limits:
          memory: 384M
        reservations:
          memory: 256M
    ports: []
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/my.prod.cnf:/etc/mysql/my.cnf
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}

  nginx:
    restart: always
    deploy:
      resources:
        limits:
          memory: 64M
        reservations:
          memory: 32M
    volumes:
      - ./public:/var/www/html/public:ro
      - ./docker/nginx/production.conf:/etc/nginx/conf.d/default.conf

  redis:
    image: redis:7-alpine
    container_name: cinch_redis
    restart: always
    deploy:
      resources:
        limits:
          memory: 64M
        reservations:
          memory: 32M
    volumes:
      - redis_data:/data
    networks:
      - cinch_network
    command: redis-server --appendonly yes --maxmemory 48mb --maxmemory-policy allkeys-lru
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      timeout: 5s
      retries: 10

volumes:
  redis_data:
    driver: local
EOF
echo "✅ docker-compose.prod.yml updated"
echo ""

# Clear Laravel caches before restart
echo "Clearing Laravel caches..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm app php artisan optimize:clear 2>/dev/null || echo "Cache clear skipped (containers not running)"
echo ""

# Start containers with new configuration
echo "Starting Docker containers with optimized configuration..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --force-recreate
echo "✅ Containers started"
echo ""

# Wait for containers to be ready
echo "Waiting for containers to be ready..."
sleep 10
echo ""

# Clear Laravel caches after restart
echo "Rebuilding Laravel caches..."
sudo docker exec cinch_app php artisan optimize:clear
sudo docker exec cinch_app php artisan config:cache
sudo docker exec cinch_app php artisan route:cache
sudo docker exec cinch_app php artisan view:cache
echo "✅ Caches rebuilt"
echo ""

# Show container status
echo "Container status:"
sudo docker ps
echo ""

# Show final memory status
echo "Final memory status:"
free -h
echo ""

echo "========================================="
echo "✅ Memory optimization completed!"
echo "========================================="
echo ""
echo "Summary of changes:"
echo "  • Added 2GB swap space"
echo "  • Reduced PHP memory limit to 128M"
echo "  • Limited PHP-FPM to 5 workers (was 10)"
echo "  • Reduced MySQL buffer pool to 128M (was 256M)"
echo "  • Set container memory limits (total ~768M)"
echo "  • Enabled OPcache for better performance"
echo ""
echo "Your application should now be stable!"
echo "Monitor with: sudo docker stats"
echo ""

