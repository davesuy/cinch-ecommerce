<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\OrderController;
use Illuminate\Support\Facades\DB;

Route::get('/', function () {
    return view('app');
});

// Test route to check database
Route::get('/test-db', function () {
    try {
        $count = DB::table('products')->count();
        $products = DB::table('products')->limit(3)->get();
        return response()->json([
            'status' => 'success',
            'count' => $count,
            'products' => $products,
            'message' => 'Database is working!'
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
});

// API Routes for Products
Route::prefix('api')->group(function () {
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);
    Route::get('/categories', [ProductController::class, 'categories']);

    // API Routes for Orders
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);
});
