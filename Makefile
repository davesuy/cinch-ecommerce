.PHONY: help up down restart build logs shell mysql-shell artisan composer npm migrate seed cache-clear backup restore clean install

# Default target
help:
	@echo "Cinch E-Commerce - Docker Helper Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make install         - Initial setup (build, start, install dependencies)"
	@echo "  make up              - Start all containers"
	@echo "  make down            - Stop all containers"
	@echo "  make restart         - Restart all containers"
	@echo "  make build           - Rebuild containers"
	@echo "  make logs            - View all logs"
	@echo "  make shell           - Access app container shell"
	@echo "  make mysql-shell     - Access MySQL shell"
	@echo "  make artisan CMD=\"\" - Run artisan command (e.g., make artisan CMD=\"migrate\")"
	@echo "  make composer CMD=\"\"- Run composer command"
	@echo "  make npm CMD=\"\"     - Run npm command"
	@echo "  make migrate         - Run database migrations"
	@echo "  make seed            - Run database seeders"
	@echo "  make cache-clear     - Clear all caches"
	@echo "  make backup          - Backup database"
	@echo "  make restore FILE=\"\"- Restore database from file"
	@echo "  make clean           - Remove all containers and volumes"
	@echo ""

# Initial setup
install:
	@echo "Starting initial setup..."
	@if [ ! -f .env ]; then cp .env.example .env; fi
	docker compose up -d --build
	@echo "Waiting for MySQL to be ready..."
	@sleep 10
	docker compose exec -T app composer install --no-interaction
	docker compose exec -T app php artisan key:generate --no-interaction
	docker compose exec -T app php artisan migrate --force
	docker compose exec -T app php artisan storage:link
	docker compose exec -T app npm install
	docker compose exec -T app npm run build
	docker compose exec -T app chown -R www-data:www-data /var/www/html/storage
	docker compose exec -T app chown -R www-data:www-data /var/www/html/bootstrap/cache
	docker compose exec -T app chmod -R 775 /var/www/html/storage
	docker compose exec -T app chmod -R 775 /var/www/html/bootstrap/cache
	@echo ""
	@echo "Setup complete! Application is running at http://localhost"

# Start containers
up:
	docker compose up -d

# Stop containers
down:
	docker compose down

# Restart containers
restart:
	docker compose restart

# Rebuild containers
build:
	docker compose down
	docker compose build --no-cache
	docker compose up -d

# View logs
logs:
	docker compose logs -f

# Access app shell
shell:
	docker compose exec app bash

# Access MySQL shell
mysql-shell:
	docker compose exec mysql mysql -u cinch_user -psecret cinch_db

# Run artisan command
artisan:
	docker compose exec app php artisan $(CMD)

# Run composer command
composer:
	docker compose exec app composer $(CMD)

# Run npm command
npm:
	docker compose exec app npm $(CMD)

# Run migrations
migrate:
	docker compose exec app php artisan migrate

# Run seeders
seed:
	docker compose exec app php artisan db:seed

# Clear cache
cache-clear:
	docker compose exec app php artisan cache:clear
	docker compose exec app php artisan config:clear
	docker compose exec app php artisan view:clear
	docker compose exec app php artisan route:clear

# Backup database
backup:
	@BACKUP_FILE=backup-$$(date +%Y%m%d-%H%M%S).sql; \
	echo "Creating backup: $$BACKUP_FILE"; \
	docker compose exec mysql mysqldump -u cinch_user -psecret cinch_db > $$BACKUP_FILE; \
	echo "Backup saved to: $$BACKUP_FILE"

# Restore database
restore:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make restore FILE=backup.sql"; \
	else \
		echo "Restoring database from: $(FILE)"; \
		docker compose exec -T mysql mysql -u cinch_user -psecret cinch_db < $(FILE); \
		echo "Database restored"; \
	fi

# Clean everything
clean:
	@echo "This will remove all containers and volumes. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	docker compose down -v

# Check status
status:
	docker compose ps

# View app logs only
logs-app:
	docker compose logs -f app

# View nginx logs only
logs-nginx:
	docker compose logs -f nginx

# View mysql logs only
logs-mysql:
	docker compose logs -f mysql

# Run tests
test:
	docker compose exec app php artisan test

# Optimize for production
optimize:
	docker compose exec app php artisan config:cache
	docker compose exec app php artisan route:cache
	docker compose exec app php artisan view:cache
	docker compose exec app composer install --no-dev --optimize-autoloader

