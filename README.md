# 🛒 Cinch E-Commerce System

A modern e-commerce platform built with **Laravel 11**, **Vue.js 3**, **MySQL**, and **Docker**.

## ✨ Features

- **Product Catalog** - Browse, search, and filter products  
- **Shopping Cart** - Add to cart with persistent storage (localStorage)  
- **Checkout System** - Customer information and order placement  
- **Email Notifications** - Automated order confirmation emails  
- **Inventory Management** - Real-time stock tracking and auto-deduction  
- **Responsive Dark UI** - Modern dark-themed interface with Tailwind CSS  

## 🚀 Tech Stack

- **Backend**: Laravel 11, PHP 8.2+
- **Frontend**: Vue.js 3 (Composition API), Vite
- **Database**: MySQL 8.0
- **Styling**: Tailwind CSS (Dark Theme)
- **Email**: Laravel Mail with SMTP (Gmail)
- **Containerization**: Docker & Docker Compose

## 📦 What's Included

### Backend
- RESTful API endpoints for products and orders
- Product, Order, and OrderItem models with relationships
- Order validation and stock management
- Email notifications with HTML templates
- Database seeders with 10 sample products

### Frontend
- Complete Vue.js 3 single-page application
- Product listing with search and category filters
- Shopping cart with quantity management
- Checkout form with validation
- Order confirmation display
- Responsive grid layout

## 🐳 Quick Setup

### Prerequisites
- Docker Desktop installed and running
- Git installed

### Installation
```bash
# Clone the repository
git clone https://github.com/davesuy/cinch-ecommerce.git
cd cinch-ecommerce

# Copy environment file
cp .env.example .env

# Run automated setup
bash setup-ecommerce.sh
```

The setup script will:
- Start Docker containers (Nginx, PHP-FPM, MySQL)
- Install all PHP and Node dependencies
- Generate application key
- Run migrations and seed 10 sample products
- Build frontend assets
- Set proper permissions

### Access the Application
🌐 **Web Application**: http://localhost  
📦 **Sample Products**: 10 products pre-seeded

## 🎯 Using the Application

1. **Browse Products** - Visit http://localhost
2. **Search & Filter** - Use search bar and category filter
3. **View Details** - Click "View Details" on any product
4. **Add to Cart** - Click cart icon to view items
5. **Checkout** - Fill customer info and place order
6. **Confirmation** - See order success message
7. **Check Email** - View order email in logs

## 🛠️ Common Commands

### Docker
```bash
docker compose up -d              # Start containers
docker compose down               # Stop containers
docker compose restart            # Restart all services
docker compose logs -f            # View live logs
docker compose ps                 # Check container status
```

### Laravel
```bash
docker compose exec app php artisan migrate       # Run migrations
docker compose exec app php artisan db:seed       # Seed database
docker compose exec app php artisan cache:clear   # Clear cache
docker compose exec app php artisan config:clear  # Clear config cache
```

### Rebuild Assets
```bash
docker compose exec app npm run build    # Production build
```

## 📋 API Endpoints

### Products
- `GET /api/products` - List all products (with optional search & category filter)
- `GET /api/products/{id}` - Get single product details

### Orders  
- `POST /api/orders` - Create new order

**Example: Create Order**
```bash
curl -X POST http://localhost/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "John Doe",
    "customer_email": "john@example.com",
    "shipping_address": "123 Main St, City, State 12345",
    "items": [
      {"product_id": 1, "quantity": 2}
    ]
  }'
```

## 🎨 Frontend Architecture

Built with **Vue.js 3** using Composition API:
- `App.vue` - Main application component
- `ProductCard.vue` - Product grid item
- `ProductDetail.vue` - Single product view
- `Cart.vue` - Shopping cart modal
- `Checkout.vue` - Checkout form
- `OrderSuccess.vue` - Order confirmation

## 🗄️ Database Schema

**Products**: id, name, description, price, stock, image, category  
**Orders**: id, customer details, total, status  
**Order Items**: id, order_id, product_id, quantity, price

## 📧 Email Configuration

### Current Setup (Development)
Emails are logged to `storage/logs/laravel.log` by default using `MAIL_MAILER=log` in `.env`.

### Enable Real Emails with Gmail

1. **Create Gmail App Password**
   - Enable 2-Factor Authentication on your Gmail account
   - Go to https://myaccount.google.com/apppasswords
   - Generate a new App Password

2. **Update .env file**
   ```env
   MAIL_MAILER=smtp
   MAIL_HOST=smtp.gmail.com
   MAIL_PORT=587
   MAIL_USERNAME=your_email@gmail.com
   MAIL_PASSWORD=your_16_char_app_password
   MAIL_ENCRYPTION=tls
   MAIL_FROM_ADDRESS="your_email@gmail.com"
   MAIL_FROM_NAME="Cinch E-Commerce"
   ```

3. **Clear cache and restart**
   ```bash
   docker compose exec app php artisan config:clear
   docker compose restart app
   ```

### Alternative: Mailtrap (Testing)
For testing without sending real emails:
1. Sign up at https://mailtrap.io (free)
2. Update `.env` with Mailtrap SMTP credentials
3. All emails will be captured in Mailtrap inbox

## 🔧 Troubleshooting

### Products not loading
```bash
# Reseed database
docker compose exec app php artisan migrate:fresh --seed

# Clear caches
docker compose exec app php artisan config:clear
docker compose exec app php artisan cache:clear

# Restart services
docker compose restart
```

### Permission errors
```bash
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
docker compose exec app chmod -R 775 storage bootstrap/cache
```

### Frontend build issues
```bash
docker compose exec app rm -rf node_modules
docker compose exec app npm install
docker compose exec app npm run build
```

## ☁️ Production Deployment (AWS EC2)

### Prerequisites
- AWS Account
- EC2 Key Pair created
- AWS CLI configured (optional)

### Manual Deployment Steps

1. **Launch EC2 Instance**
   - Use Ubuntu 22.04 LTS
   - t2.micro or larger
   - Open ports: 22 (SSH), 80 (HTTP), 443 (HTTPS)

2. **Install Docker on EC2**
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker ubuntu
   
   # Log out and back in
   exit
   ssh -i your-key.pem ubuntu@your-ec2-ip
   ```

3. **Deploy Application**
   ```bash
   # Clone repository
   cd ~
   git clone https://github.com/davesuy/cinch-ecommerce.git app
   cd app
   
   # Copy and configure .env
   cp .env.example .env
   nano .env  # Update APP_URL, DB settings, MAIL settings
   
   # Install dependencies
   sudo docker compose exec -T app composer install --optimize-autoloader
   
   # Copy built assets from local or build on server
   # If building on server, you'll need Node.js
   
   # Setup database
   sudo docker compose exec -T app php artisan key:generate
   sudo docker compose exec -T app php artisan migrate --force
   sudo docker compose exec -T app php artisan db:seed --force
   
   # Set permissions
   sudo chown -R www-data:www-data storage bootstrap/cache
   sudo chmod -R 775 storage bootstrap/cache
   
   # Clear caches
   sudo docker compose exec -T app php artisan config:clear
   sudo docker compose exec -T app php artisan cache:clear
   ```

4. **Access Application**
   - Visit: `http://your-ec2-ip`

### Using CloudFormation (Automated)

A CloudFormation template (`cloudformation-template.yaml`) is included for automated infrastructure setup. It creates:
- VPC with public/private subnets
- EC2 instance with Docker pre-installed
- Security groups
- Optional: RDS MySQL database
- Optional: S3 bucket for storage

```bash
aws cloudformation create-stack \
  --stack-name cinch-ecommerce \
  --template-body file://cloudformation-template.yaml \
  --parameters \
    ParameterKey=KeyName,ParameterValue=your-key-pair \
    ParameterKey=UseRDS,ParameterValue=No \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

**Note**: Set `UseRDS=No` to install MySQL in Docker (free tier friendly).

### Database Connection with Sequel Ace

To connect to production database from your local machine:

**Connection Type**: SSH

- **SSH Host**: Your EC2 IP
- **SSH User**: ubuntu
- **SSH Key**: Path to your .pem file
- **SSH Port**: 22
- **MySQL Host**: 127.0.0.1
- **Username**: root (or check .env)
- **Password**: Check .env DB_PASSWORD
- **Database**: cinch_ecommerce (or check .env)
- **Port**: 3306

## 📝 Project Structure

```
├── app/
│   ├── Http/Controllers/     # ProductController, OrderController
│   ├── Mail/                 # OrderPlaced mailable
│   └── Models/               # Product, Order, OrderItem
├── database/
│   ├── migrations/           # Schema definitions
│   └── seeders/              # ProductSeeder (10 products)
├── resources/
│   ├── js/
│   │   └── app.js           # Complete Vue.js app
│   └── views/
│       ├── welcome.blade.php # Main layout
│       └── emails/          # Order confirmation template
├── routes/
│   └── web.php              # API routes
├── docker-compose.yml       # Main Docker configuration
├── docker-compose.prod.yml  # Production overrides
└── setup-ecommerce.sh       # Automated setup script
```

## 📄 License

This project is built for demonstration purposes using Laravel 11 framework.

---

**Built with ❤️ using Laravel 11, Vue.js 3, MySQL, and Docker**

