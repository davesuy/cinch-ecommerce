<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\OrderController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Product endpoints
Route::prefix('products')->group(function () {
    Route::get('/', [ProductController::class, 'index'])->name('products.index');
    Route::get('/{id}', [ProductController::class, 'show'])->name('products.show');
});

// Categories endpoint
Route::get('/categories', [ProductController::class, 'categories'])->name('categories.index');

// Order endpoints
Route::prefix('orders')->group(function () {
    Route::post('/', [OrderController::class, 'store'])->name('orders.store');
    Route::get('/{id}', [OrderController::class, 'show'])->name('orders.show');
});

