#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cinch E-Commerce Setup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Starting Docker containers...${NC}"
docker compose up -d --build

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to start Docker containers${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker containers started${NC}"
echo ""

# Wait for MySQL to be ready
echo -e "${YELLOW}Step 2: Waiting for MySQL to be ready...${NC}"
sleep 10
echo -e "${GREEN}✓ MySQL is ready${NC}"
echo ""

# Install Composer dependencies
echo -e "${YELLOW}Step 3: Installing PHP dependencies...${NC}"
docker compose exec -T app composer install --no-interaction

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install PHP dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✓ PHP dependencies installed${NC}"
echo ""

# Install NPM dependencies
echo -e "${YELLOW}Step 4: Installing Node dependencies...${NC}"
docker compose exec -T app npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install Node dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node dependencies installed${NC}"
echo ""

# Generate application key if needed
echo -e "${YELLOW}Step 5: Generating application key...${NC}"
docker compose exec -T app php artisan key:generate --no-interaction
echo -e "${GREEN}✓ Application key generated${NC}"
echo ""

# Run migrations and seed
echo -e "${YELLOW}Step 6: Setting up database...${NC}"
docker compose exec -T app php artisan migrate:fresh --seed --force

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to setup database${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Database setup complete${NC}"
echo ""

# Build frontend assets
echo -e "${YELLOW}Step 7: Building frontend assets...${NC}"
docker compose exec -T app npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to build frontend assets${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Frontend assets built${NC}"
echo ""

# Create storage link
echo -e "${YELLOW}Step 8: Creating storage link...${NC}"
docker compose exec -T app php artisan storage:link
echo -e "${GREEN}✓ Storage link created${NC}"
echo ""

# Set permissions
echo -e "${YELLOW}Step 9: Setting permissions...${NC}"
docker compose exec -T app chown -R www-data:www-data /var/www/html/storage
docker compose exec -T app chown -R www-data:www-data /var/www/html/bootstrap/cache
docker compose exec -T app chmod -R 775 /var/www/html/storage
docker compose exec -T app chmod -R 775 /var/www/html/bootstrap/cache
echo -e "${GREEN}✓ Permissions set${NC}"
echo ""

# Display success message
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Your e-commerce application is now running!"
echo ""
echo -e "🌐 Application URL: ${GREEN}http://localhost${NC}"
echo -e "📧 Mail Driver: ${YELLOW}Check .env file (default: log)${NC}"
echo ""
echo -e "Sample products have been seeded to the database."
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo -e "  View logs:          docker compose logs -f"
echo -e "  Stop containers:    docker compose down"
echo -e "  Restart:            docker compose restart"
echo -e "  Access shell:       docker compose exec app bash"
echo ""
echo -e "${GREEN}Happy selling! 🛒${NC}"

