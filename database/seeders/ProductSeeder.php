<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $products = [
            [
                'name' => 'Wireless Bluetooth Headphones',
                'description' => 'High-quality wireless headphones with noise cancellation and 30-hour battery life. Perfect for music lovers and professionals.',
                'price' => 79.99,
                'stock' => 50,
                'category' => 'Electronics',
                'image' => 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'Smart Watch Pro',
                'description' => 'Feature-rich smartwatch with fitness tracking, heart rate monitor, and smartphone notifications. Water-resistant up to 50 meters.',
                'price' => 199.99,
                'stock' => 30,
                'category' => 'Electronics',
                'image' => 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'Laptop Backpack',
                'description' => 'Durable and stylish backpack with padded laptop compartment, fits up to 15.6" laptops. Multiple pockets for organization.',
                'price' => 49.99,
                'stock' => 75,
                'category' => 'Accessories',
                'image' => 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'Mechanical Gaming Keyboard',
                'description' => 'RGB backlit mechanical keyboard with customizable keys and anti-ghosting technology. Perfect for gamers and typists.',
                'price' => 89.99,
                'stock' => 40,
                'category' => 'Electronics',
                'image' => 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'Wireless Mouse',
                'description' => 'Ergonomic wireless mouse with adjustable DPI and long battery life. Compatible with Windows, Mac, and Linux.',
                'price' => 29.99,
                'stock' => 100,
                'category' => 'Electronics',
                'image' => 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'USB-C Hub',
                'description' => '7-in-1 USB-C hub with HDMI, USB 3.0, SD card reader, and power delivery. Essential for modern laptops.',
                'price' => 39.99,
                'stock' => 60,
                'category' => 'Accessories',
                'image' => 'https://images.unsplash.com/photo-1625948515291-69613efd103f?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'Portable Phone Charger',
                'description' => '20,000mAh power bank with fast charging and dual USB ports. Keep your devices charged on the go.',
                'price' => 34.99,
                'stock' => 80,
                'category' => 'Accessories',
                'image' => 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'Webcam HD 1080p',
                'description' => 'Full HD webcam with auto-focus and built-in microphone. Perfect for video conferencing and streaming.',
                'price' => 59.99,
                'stock' => 45,
                'category' => 'Electronics',
                'image' => 'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'Desk Organizer Set',
                'description' => 'Modern desk organizer with compartments for pens, papers, and accessories. Keeps your workspace tidy.',
                'price' => 24.99,
                'stock' => 90,
                'category' => 'Office',
                'image' => 'https://images.unsplash.com/photo-1611269154421-4e27233ac5c7?w=500',
                'is_active' => true,
            ],
            [
                'name' => 'LED Desk Lamp',
                'description' => 'Adjustable LED desk lamp with multiple brightness levels and color temperatures. Energy-efficient and eye-friendly.',
                'price' => 44.99,
                'stock' => 55,
                'category' => 'Office',
                'image' => 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=500',
                'is_active' => true,
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}

