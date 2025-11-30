<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\User;

class EcommerceFeatureTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_list_all_products()
    {
        // Arrange: Create some products
        Product::factory()->count(5)->create();

        // Act: Call the product listing endpoint
        $response = $this->getJson('/api/products');

        // Assert: Check if the response contains the products
        $response->assertStatus(200)
                 ->assertJsonCount(5, 'data');
    }

    /** @test */
    public function it_can_place_an_order()
    {
        // Arrange: Create a user and some products
        $user = User::factory()->create();
        $products = Product::factory()->count(3)->create();

        $orderData = [
            'user_id' => $user->id,
            'customer_name' => 'John Doe',
            'customer_email' => 'john.doe@example.com',
            'shipping_address' => '123 Main Street, Springfield',
            'items' => $products->map(function ($product) {
                return [
                    'product_id' => $product->id,
                    'quantity' => 2,
                ];
            })->toArray(),
        ];

        // Act: Call the order placement endpoint
        $response = $this->postJson('/api/orders', $orderData);

        // Assert: Check if the order was created successfully
        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'data' => [
                         'id',
                         'user_id',
                         'customer_name',
                         'customer_email',
                         'shipping_address',
                         'total',
                         'items' => [
                             '*' => [
                                 'product_id',
                                 'quantity',
                                 'price',
                             ],
                         ],
                     ],
                 ]);

        $this->assertDatabaseHas('orders', [
            'user_id' => $user->id,
            'customer_name' => 'John Doe',
            'customer_email' => 'john.doe@example.com',
            'shipping_address' => '123 Main Street, Springfield',
        ]);

        $this->assertDatabaseCount('order_items', 3);
    }
}
