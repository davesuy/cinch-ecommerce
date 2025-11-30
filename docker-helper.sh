#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Cinch E-Commerce Docker Helper ===${NC}\n"

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: docker compose is not installed or Docker is not running${NC}"
    echo -e "${YELLOW}Please install Docker Desktop and make sure it's running${NC}"
    exit 1
fi

# Menu function
show_menu() {
    echo -e "${YELLOW}Select an option:${NC}"
    echo "1)  Start containers"
    echo "2)  Stop containers"
    echo "3)  Restart containers"
    echo "4)  View logs (all)"
    echo "5)  View app logs"
    echo "6)  View MySQL logs"
    echo "7)  View Nginx logs"
    echo "8)  Access app shell"
    echo "9)  Access MySQL shell"
    echo "10) Run migrations"
    echo "11) Run seeders"
    echo "12) Clear cache"
    echo "13) Run artisan command"
    echo "14) Run composer command"
    echo "15) Install npm packages"
    echo "16) Build assets"
    echo "17) Database backup"
    echo "18) Database restore"
    echo "19) Check container status"
    echo "20) Rebuild containers"
    echo "21) Remove all containers and volumes"
    echo "0)  Exit"
    echo ""
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice: " choice
    echo ""

    case $choice in
        1)
            echo -e "${BLUE}Starting containers...${NC}"
            docker compose up -d
            ;;
        2)
            echo -e "${BLUE}Stopping containers...${NC}"
            docker compose down
            ;;
        3)
            echo -e "${BLUE}Restarting containers...${NC}"
            docker compose restart
            ;;
        4)
            echo -e "${BLUE}Viewing all logs (Ctrl+C to exit)...${NC}"
            docker compose logs -f
            ;;
        5)
            echo -e "${BLUE}Viewing app logs (Ctrl+C to exit)...${NC}"
            docker compose logs -f app
            ;;
        6)
            echo -e "${BLUE}Viewing MySQL logs (Ctrl+C to exit)...${NC}"
            docker compose logs -f mysql
            ;;
        7)
            echo -e "${BLUE}Viewing Nginx logs (Ctrl+C to exit)...${NC}"
            docker compose logs -f nginx
            ;;
        8)
            echo -e "${BLUE}Accessing app shell...${NC}"
            docker compose exec app bash
            ;;
        9)
            echo -e "${BLUE}Accessing MySQL shell...${NC}"
            docker compose exec mysql mysql -u cinch_user -psecret cinch_db
            ;;
        10)
            echo -e "${BLUE}Running migrations...${NC}"
            docker compose exec app php artisan migrate
            ;;
        11)
            echo -e "${BLUE}Running seeders...${NC}"
            docker compose exec app php artisan db:seed
            ;;
        12)
            echo -e "${BLUE}Clearing cache...${NC}"
            docker compose exec app php artisan cache:clear
            docker compose exec app php artisan config:clear
            docker compose exec app php artisan view:clear
            docker compose exec app php artisan route:clear
            ;;
        13)
            read -p "Enter artisan command (without 'php artisan'): " cmd
            docker compose exec app php artisan $cmd
            ;;
        14)
            read -p "Enter composer command (without 'composer'): " cmd
            docker compose exec app composer $cmd
            ;;
        15)
            echo -e "${BLUE}Installing npm packages...${NC}"
            docker compose exec app npm install
            ;;
        16)
            echo -e "${BLUE}Building assets...${NC}"
            docker compose exec app npm run build
            ;;
        17)
            BACKUP_FILE="backup-$(date +%Y%m%d-%H%M%S).sql"
            echo -e "${BLUE}Creating database backup: $BACKUP_FILE${NC}"
            docker compose exec mysql mysqldump -u cinch_user -psecret cinch_db > $BACKUP_FILE
            echo -e "${GREEN}Backup saved to: $BACKUP_FILE${NC}"
            ;;
        18)
            read -p "Enter backup file path: " backup_file
            if [ -f "$backup_file" ]; then
                echo -e "${BLUE}Restoring database from: $backup_file${NC}"
                docker compose exec -T mysql mysql -u cinch_user -psecret cinch_db < $backup_file
                echo -e "${GREEN}Database restored${NC}"
            else
                echo -e "${RED}Backup file not found${NC}"
            fi
            ;;
        19)
            echo -e "${BLUE}Container status:${NC}"
            docker compose ps
            ;;
        20)
            echo -e "${YELLOW}This will rebuild all containers. Continue? (y/n)${NC}"
            read -p "" confirm
            if [ "$confirm" = "y" ]; then
                echo -e "${BLUE}Rebuilding containers...${NC}"
                docker compose down
                docker compose build --no-cache
                docker compose up -d
            fi
            ;;
        21)
            echo -e "${RED}WARNING: This will remove all containers and volumes! Continue? (y/n)${NC}"
            read -p "" confirm
            if [ "$confirm" = "y" ]; then
                echo -e "${BLUE}Removing containers and volumes...${NC}"
                docker compose down -v
                echo -e "${GREEN}Done${NC}"
            fi
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac

    echo ""
    read -p "Press Enter to continue..."
    echo ""
done

