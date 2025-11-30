# 🛒 Cinch E-Commerce System

A modern e-commerce platform built with **Laravel 11**, **Vue.js 3**, **MySQL**, and **Docker**.

## ✨ Features

- Product catalog with search and filters
- Shopping cart with localStorage persistence
- Customer checkout and order placement
- Email notifications for orders
- Real-time inventory management
- Responsive dark UI with Tailwind CSS

## 🚀 Tech Stack

- **Backend**: Laravel 11, PHP 8.2+
- **Frontend**: Vue.js 3 (Composition API), Vite
- **Database**: MySQL 8.0
- **Styling**: Tailwind CSS
- **Containerization**: Docker & Docker Compose

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

# Start Docker containers
docker compose up -d

# Install dependencies
docker compose exec app composer install
docker compose exec app npm install

# Setup application
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --seed
docker compose exec app npm run build

# Set permissions
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
docker compose exec app chmod -R 775 storage bootstrap/cache
```

### Access the Application
🌐 **Application**: http://localhost  
📦 **Sample Products**: 10 products pre-seeded

## 🛠️ Development Commands

```bash
# Start/stop containers
docker compose up -d
docker compose down

# Clear caches
docker compose exec app php artisan cache:clear
docker compose exec app php artisan config:clear

# Run migrations
docker compose exec app php artisan migrate

# Rebuild frontend
docker compose exec app npm run dev    # Development
docker compose exec app npm run build  # Production

# View logs
docker compose logs -f app
```

## 📋 API Endpoints

- `GET /api/products` - List all products (with search & filters)
- `GET /api/products/{id}` - Get product details
- `POST /api/orders` - Create new order

**Example Order:**
```json
{
  "customer_name": "John Doe",
  "customer_email": "john@example.com",
  "shipping_address": "123 Main St, City, State 12345",
  "items": [
    {"product_id": 1, "quantity": 2}
  ]
}
```

## 📧 Email Configuration

Development mode logs emails to `storage/logs/laravel.log`.

For production with Gmail:

1. Create Gmail App Password at https://myaccount.google.com/apppasswords
2. Update `.env`:
   ```env
   MAIL_MAILER=smtp
   MAIL_HOST=smtp.gmail.com
   MAIL_PORT=587
   MAIL_USERNAME=your_email@gmail.com
   MAIL_PASSWORD=your_app_password
   MAIL_ENCRYPTION=tls
   MAIL_FROM_ADDRESS="your_email@gmail.com"
   MAIL_FROM_NAME="Cinch E-Commerce"
   ```
3. Clear cache: `docker compose exec app php artisan config:clear`

## ☁️ DevOps & Infrastructure

### AWS CloudFormation Template

This project includes a complete **Infrastructure as Code** solution using AWS CloudFormation (`cloudformation-template.yaml`).

**Features:**
- **Automated VPC Setup** - Creates isolated network with public/private subnets
- **EC2 Instance Provisioning** - Auto-configures Ubuntu server with Docker pre-installed
- **Security Groups** - Pre-configured firewall rules for HTTP, HTTPS, and SSH
- **Optional RDS MySQL** - Managed database option for production workloads
- **S3 Integration** - Optional storage bucket for static assets
- **Auto-scaling Ready** - Template structured for easy scaling modifications
- **Cost-Optimized** - Configurable instance types (t3.micro free tier eligible)

**Deploy with AWS CLI:**
```bash
aws cloudformation create-stack \
  --stack-name cinch-ecommerce \
  --template-body file://cloudformation-template.yaml \
  --parameters \
    ParameterKey=KeyName,ParameterValue=your-key-pair \
    ParameterKey=InstanceType,ParameterValue=t3.micro \
  --capabilities CAPABILITY_IAM
```

**DevOps Skills Demonstrated:**
- Infrastructure as Code (IaC) with CloudFormation
- Docker containerization and orchestration
- CI/CD ready deployment structure
- Security best practices (security groups, IAM roles)
- Network architecture (VPC, subnets, routing)
- Database management (RDS integration)
- Cost optimization strategies

## 🔧 Troubleshooting

**Products not loading:**
```bash
docker compose exec app php artisan migrate:fresh --seed
docker compose exec app php artisan cache:clear
```

**Permission errors:**
```bash
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
docker compose exec app chmod -R 775 storage bootstrap/cache
```

**Build issues:**
```bash
docker compose exec app rm -rf node_modules
docker compose exec app npm install
docker compose exec app npm run build
```

## 📄 License

This project is open-source and available under the MIT License.

