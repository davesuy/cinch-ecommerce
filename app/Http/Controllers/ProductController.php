<?php
namespace App\Http\Controllers;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
class ProductController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Product::where('is_active', true);
        if ($request->has('category') && $request->category) {
            $query->where('category', $request->category);
        }
        if ($request->has('search') && $request->search) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }
        $products = $query->orderBy('created_at', 'desc')->get();
        return response()->json([
            'success' => true,
            'data' => $products
        ]);
    }
    public function show(string $id): JsonResponse
    {
        $product = Product::where('is_active', true)->find($id);
        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found'
            ], 404);
        }
        return response()->json([
            'success' => true,
            'data' => $product
        ]);
    }
    public function categories(): JsonResponse
    {
        $categories = Product::where('is_active', true)
            ->whereNotNull('category')
            ->distinct()
            ->pluck('category');
        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }
}
