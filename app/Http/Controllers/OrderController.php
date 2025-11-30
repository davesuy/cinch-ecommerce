<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Mail\OrderPlaced;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    /**
     * Store a newly created order.
     */
    public function store(Request $request): JsonResponse
    {
        // Validate the request
        $validator = Validator::make($request->all(), [
            'customer_name' => 'required|string|max:255',
            'customer_email' => 'required|email|max:255',
            'customer_phone' => 'nullable|string|max:20',
            'shipping_address' => 'required|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            DB::beginTransaction();

            // Check stock availability for all items
            $items = $request->items;
            $orderTotal = 0;

            foreach ($items as $item) {
                $product = Product::find($item['product_id']);

                if (!$product) {
                    throw new \Exception("Product with ID {$item['product_id']} not found.");
                }

                if (!$product->isInStock($item['quantity'])) {
                    throw new \Exception("Product '{$product->name}' is out of stock or insufficient quantity available.");
                }

                $orderTotal += $product->price * $item['quantity'];
            }

            // Create the order
            $order = Order::create([
                'customer_name' => $request->customer_name,
                'customer_email' => $request->customer_email,
                'customer_phone' => $request->customer_phone,
                'shipping_address' => $request->shipping_address,
                'total' => $orderTotal,
                'status' => 'pending',
            ]);

            // Create order items and update stock
            foreach ($items as $item) {
                $product = Product::find($item['product_id']);

                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity' => $item['quantity'],
                    'price' => $product->price,
                ]);

                // Decrease product stock
                $product->decreaseStock($item['quantity']);
            }

            DB::commit();

            // Load order items with product details
            $order->load('orderItems.product');

            // Send email notification
            try {
                Mail::to($order->customer_email)->send(new OrderPlaced($order));
            } catch (\Exception $e) {
                // Log email error but don't fail the order
                \Log::error('Failed to send order email: ' . $e->getMessage());
            }

            return response()->json([
                'success' => true,
                'message' => 'Order placed successfully',
                'data' => $order
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to create order: ' . $e->getMessage()
            ], 400);
        }
    }

    /**
     * Display the specified order.
     */
    public function show(string $id): JsonResponse
    {
        $order = Order::with('orderItems.product')->find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $order
        ]);
    }
}

