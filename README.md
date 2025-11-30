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

## 📁 Project structure

A quick overview of the important folders and files in this repository:

- `app/` - Laravel backend: controllers, models, mailables and providers.
  - `Http/Controllers/` - controllers handling HTTP and API requests (e.g. ProductController, OrderController).
  - `Models/` - Eloquent models (Product, Order, OrderItem, User).
- `bootstrap/` - framework bootstrap files.
- `config/` - Laravel configuration files.
- `database/` - migrations, factories and seeders (sample product seeder included).
- `public/` - the web root; built frontend assets live in `public/build` after Vite build.
- `resources/` - frontend and view resources.
  - `resources/views/` - Blade templates (server-rendered pages / email templates).
  - `resources/js/` - Vue.js frontend source:
    - `app.js` - main entry (mounts Vue and wires components/services)
    - `components/` - Single File Components (ProductCard.vue, ProductDetailModal.vue, CartModal.vue, CheckoutModal.vue, OrderSuccessModal.vue)
    - `services/` - `api.js` (centralized API service layer)
    - `utils/` - small utility modules (`cart.js` for localStorage/cart helpers)
  - `resources/css/` - Tailwind / custom CSS.
- `routes/`
  - `api.php` - API routes (recommended for all API endpoints).
  - `web.php` - web routes (page routes that return Blade views).
- `cloudformation-template.yaml` - AWS CloudFormation template (kept intentionally to demonstrate DevOps/IaC skills).
- `Dockerfile`, `docker-compose.yml` - containerization config.
- `composer.json`, `package.json` - PHP & JS dependencies.
- `tests/` - PHPUnit tests for backend (feature/unit tests).

## 🛠️ How I coded it — architecture & decisions

This project follows an API-first, component-driven approach with clear separation between backend and frontend:

Backend (Laravel)
- API routes are defined in `routes/api.php` (keeps API endpoints separate from view routes in `web.php`). Using the `api` middleware group makes it easy to change auth or throttling for API traffic.
- Controllers follow single-responsibility: each controller delegates business logic to models and simple services where appropriate. Eloquent models define the relationships (e.g. Order -> OrderItem -> Product).
- Validation is handled via Form Requests (or controller validation) to keep controllers thin and improve reuse and testability.
- Migrations and seeders live in `database/` so the schema and sample data are reproducible — useful for CI and local dev.
- Emails are sent with Laravel Mailables (see `app/Mail/OrderPlaced.php`) and logged to `storage/logs` in local/dev environments.

Frontend (Vue 3 + Vite)
- The frontend is modularized with Small, focused Single File Components under `resources/js/components/` to improve testability and reusability.
- `resources/js/services/api.js` is the single place for all HTTP calls (using fetch or axios). This keeps components clean and simplifies error handling and mocking in tests.
- `resources/js/utils/cart.js` contains pure helper functions (save/load cart to localStorage, calculate totals). Keeping these pure eases unit testing.
- `resources/js/app.js` bootstraps the Vue app and registers components; heavy logic is pushed to components, services, or utils.
- Tailwind CSS is used for utility-first styling; the design is responsive and lightweight.

DevOps & Deploy
- `cloudformation-template.yaml` documents an IaC approach for provisioning VPC, EC2 (with Docker), optional RDS, and S3. It's kept in the repo as a demonstration of DevOps capability.
- Docker and docker-compose are used for local development parity (services: app, db, optionally phpmyadmin).

Testing & Quality
- PHPUnit is configured (see `phpunit.xml`) for backend tests; add feature tests for critical flows (place order, product listing).
- Frontend components can be covered with unit tests (Vitest / Jest) if you add a test harness.

Security & Environment
- Sensitive values are kept in `.env` and should never be committed. The `cloudformation-template.yaml` is parameterized so secrets are not hard-coded.

Tips for contributors
- Use `routes/api.php` for any new API endpoints. Keep `web.php` limited to page/view routes.
- Add business-logic-heavy code to services (or the `app/` layer) rather than bloating controllers or components.
- Run `npm run dev` (inside container or locally) and `php artisan migrate --seed` when setting up.

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
