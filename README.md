# 🛒 Cinch E-Commerce System

A full-featured e-commerce platform built with **Laravel 11**, **Vue.js 3**, **MySQL**, and **Docker**.

## ✨ Features

✅ **Product Catalog** - Browse, search, and filter products  
✅ **Shopping Cart** - Add to cart with persistent storage (localStorage)  
✅ **Checkout System** - Customer information and order placement  
✅ **Email Notifications** - Automated order confirmation emails  
✅ **Inventory Management** - Real-time stock tracking and auto-deduction  
✅ **Responsive Design** - Mobile-friendly interface with Tailwind CSS  

## 🚀 Tech Stack

- **Backend**: Laravel 11, PHP 8.2
- **Frontend**: Vue.js 3 (Composition API), Vite
- **Database**: MySQL 8.0
- **Styling**: Tailwind CSS
- **Email**: Laravel Mail (configurable SMTP/log)
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

### Automated Installation (Recommended)
```bash
bash setup-ecommerce.sh
```

This will:
- Start Docker containers
- Install all dependencies
- Run migrations and seed 10 sample products
- Build frontend assets
- Set proper permissions

### Manual Installation
```bash
# 1. Start Docker containers
docker compose up -d --build

# 2. Install PHP dependencies
docker compose exec app composer install

# 3. Install Node dependencies  
docker compose exec app npm install

# 4. Run migrations and seed database
docker compose exec app php artisan migrate:fresh --seed

# 5. Build frontend assets
docker compose exec app npm run build

# 6. Set permissions
docker compose exec app chown -R www-data:www-data storage
docker compose exec app chmod -R 775 storage
```

### Access the Application
🌐 **Web Application**: http://localhost  
📧 **Email Logs**: `docker compose exec app tail -f storage/logs/laravel.log`

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
docker compose restart            # Restart all
docker compose logs -f            # View logs
docker compose exec app bash     # Access shell
```

### Laravel
```bash
docker compose exec app php artisan migrate       # Run migrations
docker compose exec app php artisan db:seed       # Seed database
docker compose exec app php artisan cache:clear  # Clear cache
docker compose exec app php artisan route:list   # List routes
```

### Frontend
```bash
docker compose exec app npm run build    # Production build
docker compose exec app npm run dev      # Development mode
```

## 📋 API Endpoints

### Products
- `GET /api/products` - List all products (with optional search & category filter)
- `GET /api/products/{id}` - Get single product details
- `GET /api/categories` - List all categories

### Orders  
- `POST /api/orders` - Create new order
- `GET /api/orders/{id}` - Get order details

Example: Create an order
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
Emails are logged to `storage/logs/laravel.log` instead of being sent. This is controlled by `MAIL_MAILER=log` in `.env`.

### To Send Real Emails

**Option 1: Mailtrap (Recommended for Testing)**
1. Sign up at https://mailtrap.io (free)
2. Get your SMTP credentials from the inbox
3. Update `.env`:
   ```env
   MAIL_MAILER=smtp
   MAIL_HOST=sandbox.smtp.mailtrap.io
   MAIL_PORT=2525
   MAIL_USERNAME=your_mailtrap_username
   MAIL_PASSWORD=your_mailtrap_password
   MAIL_ENCRYPTION=tls
   MAIL_FROM_ADDRESS="noreply@cinch-ecommerce.com"
   MAIL_FROM_NAME="Cinch E-Commerce"
   ```

**Option 2: Gmail (For Real Delivery)**
1. Enable 2FA on Gmail
2. Create App Password at https://myaccount.google.com/apppasswords
3. Update `.env`:
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

**After updating .env:**
```bash
docker compose exec app php artisan config:clear
docker compose restart app
```

**📖 See EMAIL_SETUP_GUIDE.md for detailed instructions and more options (SendGrid, Mailgun, etc.)**

## 🎓 Sample Data

The system includes 10 pre-seeded products:
- 5 Electronics (Headphones, Smart Watch, Keyboard, etc.)
- 3 Accessories (Backpack, USB Hub, Charger)
- 2 Office items (Organizer, LED Lamp)

## 💡 For Development

Run Vite in dev mode for hot reload:
```bash
docker compose exec app npm run dev
```

Then access: http://localhost:5173

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
docker compose exec app chown -R www-data:www-data storage
docker compose exec app chmod -R 775 storage
```

### Frontend build issues
```bash
docker compose exec app rm -rf node_modules
docker compose exec app npm install
docker compose exec app npm run build
```

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
│       ├── app.blade.php    # Main layout
│       └── emails/          # Order confirmation template
├── routes/
│   └── web.php              # API routes
└── docker-compose.yml       # Docker configuration
```

## 📄 License

This project is built for demonstration purposes using Laravel 11 framework.

---

**Built with ❤️ using Laravel 11, Vue.js 3, MySQL, and Docker**

