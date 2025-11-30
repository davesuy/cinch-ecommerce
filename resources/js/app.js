import './bootstrap';
import { createApp } from 'vue';
import axios from 'axios';

const app = createApp({
  data() {
    return {
      products: [],
      cart: [],
      loading: true,
      error: null,
      showCart: false,
      searchQuery: '',
      selectedCategory: '',
      categories: [],
      checkoutForm: {
        customer_name: '',
        customer_email: '',
        customer_phone: '',
        shipping_address: ''
      },
      showCheckout: false,
      orderPlaced: false,
      lastOrder: null
    }
  },
  computed: {
    filteredProducts() {
      let result = this.products;

      if (this.selectedCategory) {
        result = result.filter(p => p.category === this.selectedCategory);
      }

      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        result = result.filter(p =>
          p.name.toLowerCase().includes(query) ||
          p.description.toLowerCase().includes(query)
        );
      }

      return result;
    },
    cartItemCount() {
      return this.cart.reduce((sum, item) => sum + item.quantity, 0);
    },
    cartTotal() {
      return this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    }
  },
  async mounted() {
    await this.fetchProducts();
    await this.fetchCategories();
    this.loadCartFromStorage();
  },
  methods: {
    async fetchProducts() {
      try {
        this.loading = true;
        this.error = null;
        const response = await axios.get('/api/products');
        if (response.data.success) {
          this.products = response.data.data || [];
        }
      } catch (error) {
        console.error('Error:', error);
        this.error = 'Failed to load products. Please refresh the page.';
      } finally {
        this.loading = false;
      }
    },
    async fetchCategories() {
      try {
        const response = await axios.get('/api/categories');
        if (response.data.success) {
          this.categories = response.data.data || [];
        }
      } catch (error) {
        console.error('Error fetching categories:', error);
      }
    },
    addToCart(product) {
      const existing = this.cart.find(item => item.id === product.id);
      if (existing) {
        existing.quantity++;
      } else {
        this.cart.push({
          id: product.id,
          name: product.name,
          price: parseFloat(product.price),
          image: product.image,
          quantity: 1
        });
      }
      this.saveCartToStorage();
    },
    updateCartQuantity(productId, quantity) {
      const item = this.cart.find(item => item.id === productId);
      if (item && quantity > 0) {
        item.quantity = quantity;
        this.saveCartToStorage();
      }
    },
    removeFromCart(productId) {
      this.cart = this.cart.filter(item => item.id !== productId);
      this.saveCartToStorage();
    },
    saveCartToStorage() {
      localStorage.setItem('cart', JSON.stringify(this.cart));
    },
    loadCartFromStorage() {
      const saved = localStorage.getItem('cart');
      if (saved) {
        try {
          this.cart = JSON.parse(saved);
        } catch (e) {
          console.error('Error loading cart:', e);
        }
      }
    },
    proceedToCheckout() {
      this.showCart = false;
      this.showCheckout = true;
    },
    async submitOrder() {
      try {
        const orderData = {
          ...this.checkoutForm,
          items: this.cart.map(item => ({
            product_id: item.id,
            quantity: item.quantity
          }))
        };

        const response = await axios.post('/api/orders', orderData);

        if (response.data.success) {
          this.lastOrder = response.data.data;
          this.cart = [];
          localStorage.removeItem('cart');
          this.showCheckout = false;
          this.orderPlaced = true;

          // Reset form
          this.checkoutForm = {
            customer_name: '',
            customer_email: '',
            customer_phone: '',
            shipping_address: ''
          };
        }
      } catch (error) {
        console.error('Error placing order:', error);
        alert('Failed to place order: ' + (error.response?.data?.message || 'Unknown error'));
      }
    }
  },
  template: `
    <div class="min-h-screen bg-gray-900">
      <!-- Header -->
      <header class="bg-gray-800 text-white shadow-2xl border-b border-gray-700">
        <div class="container mx-auto px-4 py-6">
          <div class="flex justify-between items-center">
            <h1 class="text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">🛒 Cinch E-Commerce</h1>
            <button @click="showCart = true"
                    class="relative bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-2 rounded-lg hover:from-purple-700 hover:to-pink-700 transition-all shadow-lg">
              🛒 Cart
              <span v-if="cartItemCount > 0"
                    class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold shadow-lg">
                {{ cartItemCount }}
              </span>
            </button>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <main class="container mx-auto px-4 py-8">
        <!-- Filters -->
        <div class="mb-6 flex gap-4 flex-wrap">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search products..."
            class="flex-1 min-w-[200px] px-4 py-3 bg-gray-800 border border-gray-700 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 placeholder-gray-400"
          >
          <select
            v-model="selectedCategory"
            class="px-4 py-3 bg-gray-800 border border-gray-700 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          >
            <option value="">All Categories</option>
            <option v-for="category in categories" :key="category" :value="category">
              {{ category }}
            </option>
          </select>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-purple-500"></div>
          <p class="mt-4 text-gray-400">Loading products...</p>
        </div>

        <!-- Error State -->
        <div v-else-if="error" class="text-center py-12">
          <p class="text-red-400 text-lg">{{ error }}</p>
          <button @click="fetchProducts" class="mt-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-2 rounded-lg hover:from-purple-700 hover:to-pink-700">
            Retry
          </button>
        </div>

        <!-- No Products -->
        <div v-else-if="filteredProducts.length === 0" class="text-center py-12">
          <p class="text-gray-400 text-lg">No products found.</p>
        </div>

        <!-- Products Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <div v-for="product in filteredProducts" :key="product.id"
               class="bg-gray-800 rounded-lg shadow-xl overflow-hidden hover:shadow-2xl hover:scale-105 transition-all border border-gray-700">
            <img :src="product.image || 'https://via.placeholder.com/400x300'"
                 :alt="product.name"
                 class="w-full h-48 object-cover">
            <div class="p-4">
              <span v-if="product.category"
                    class="inline-block bg-gradient-to-r from-purple-600 to-pink-600 text-white text-xs px-3 py-1 rounded-full mb-2">
                {{ product.category }}
              </span>
              <h3 class="font-bold text-lg mb-2 text-white">{{ product.name }}</h3>
              <p class="text-gray-400 text-sm mb-3 line-clamp-2">{{ product.description }}</p>
              <div class="flex justify-between items-center mb-3">
                <span class="text-2xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">\${{ product.price }}</span>
                <span class="text-sm text-gray-400">Stock: {{ product.stock }}</span>
              </div>
              <button @click="addToCart(product)"
                      :disabled="product.stock === 0"
                      class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-4 py-3 rounded-lg hover:from-purple-700 hover:to-pink-700 transition-all disabled:from-gray-600 disabled:to-gray-700 disabled:cursor-not-allowed font-semibold shadow-lg">
                {{ product.stock === 0 ? 'Out of Stock' : 'Add to Cart' }}
              </button>
            </div>
          </div>
        </div>
      </main>

      <!-- Cart Modal -->
      <div v-if="showCart" class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4">
        <div class="bg-gray-800 rounded-lg shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden border border-gray-700">
          <div class="flex justify-between items-center p-6 border-b border-gray-700">
            <h2 class="text-2xl font-bold text-white">Shopping Cart</h2>
            <button @click="showCart = false" class="text-gray-400 hover:text-white text-2xl">&times;</button>
          </div>

          <div class="p-6 overflow-y-auto" style="max-height: calc(90vh - 200px)">
            <div v-if="cart.length === 0" class="text-center py-12">
              <p class="text-gray-400 text-lg">Your cart is empty</p>
            </div>

            <div v-else class="space-y-4">
              <div v-for="item in cart" :key="item.id" class="flex gap-4 p-4 border border-gray-700 rounded-lg bg-gray-750">
                <img :src="item.image || 'https://via.placeholder.com/100'"
                     :alt="item.name"
                     class="w-20 h-20 object-cover rounded">
                <div class="flex-1">
                  <h3 class="font-semibold text-white">{{ item.name }}</h3>
                  <p class="text-purple-400 font-bold">\${{ item.price }}</p>
                  <div class="flex items-center gap-2 mt-2">
                    <button @click="updateCartQuantity(item.id, item.quantity - 1)"
                            class="w-8 h-8 bg-gray-700 text-white rounded hover:bg-gray-600 transition">-</button>
                    <span class="w-12 text-center text-white">{{ item.quantity }}</span>
                    <button @click="updateCartQuantity(item.id, item.quantity + 1)"
                            class="w-8 h-8 bg-gray-700 text-white rounded hover:bg-gray-600 transition">+</button>
                  </div>
                </div>
                <div class="text-right">
                  <p class="font-bold text-lg text-white">\${{ (item.price * item.quantity).toFixed(2) }}</p>
                  <button @click="removeFromCart(item.id)"
                          class="text-red-400 hover:text-red-300 text-sm mt-2">Remove</button>
                </div>
              </div>
            </div>
          </div>

          <div v-if="cart.length > 0" class="p-6 border-t border-gray-700 bg-gray-750">
            <div class="flex justify-between items-center mb-4">
              <span class="text-xl font-semibold text-white">Total:</span>
              <span class="text-2xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
                \${{ cartTotal.toFixed(2) }}
              </span>
            </div>
            <button @click="proceedToCheckout"
                    class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg text-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition shadow-lg">
              Proceed to Checkout
            </button>
          </div>
        </div>
      </div>

      <!-- Checkout Modal -->
      <div v-if="showCheckout" class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4">
        <div class="bg-gray-800 rounded-lg shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-auto border border-gray-700">
          <div class="flex justify-between items-center p-6 border-b border-gray-700">
            <h2 class="text-2xl font-bold text-white">Checkout</h2>
            <button @click="showCheckout = false" class="text-gray-400 hover:text-white text-2xl">&times;</button>
          </div>

          <form @submit.prevent="submitOrder" class="p-6 space-y-4">
            <div>
              <label class="block text-sm font-medium mb-1 text-gray-300">Full Name *</label>
              <input v-model="checkoutForm.customer_name" required
                     class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
            </div>
            <div>
              <label class="block text-sm font-medium mb-1 text-gray-300">Email *</label>
              <input v-model="checkoutForm.customer_email" type="email" required
                     class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
            </div>
            <div>
              <label class="block text-sm font-medium mb-1 text-gray-300">Phone</label>
              <input v-model="checkoutForm.customer_phone" type="tel"
                     class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500">
            </div>
            <div>
              <label class="block text-sm font-medium mb-1 text-gray-300">Shipping Address *</label>
              <textarea v-model="checkoutForm.shipping_address" required rows="3"
                        class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"></textarea>
            </div>

            <div class="border-t border-gray-700 pt-4">
              <h3 class="font-semibold mb-2 text-white">Order Summary</h3>
              <div v-for="item in cart" :key="item.id" class="flex justify-between text-sm mb-1 text-gray-300">
                <span>{{ item.name }} x {{ item.quantity }}</span>
                <span>\${{ (item.price * item.quantity).toFixed(2) }}</span>
              </div>
              <div class="flex justify-between font-bold text-lg mt-2 pt-2 border-t border-gray-700">
                <span class="text-white">Total:</span>
                <span class="bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">\${{ cartTotal.toFixed(2) }}</span>
              </div>
            </div>

            <button type="submit"
                    class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg text-lg font-semibold hover:from-purple-700 hover:to-pink-700 shadow-lg">
              Place Order
            </button>
          </form>
        </div>
      </div>

      <!-- Order Success Modal -->
      <div v-if="orderPlaced" class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4">
        <div class="bg-gray-800 rounded-lg shadow-2xl max-w-2xl w-full border border-gray-700">
          <div class="text-center p-8 border-b border-gray-700">
            <div class="mx-auto w-16 h-16 bg-gradient-to-r from-green-400 to-emerald-500 rounded-full flex items-center justify-center mb-4 shadow-lg">
              <span class="text-3xl">✓</span>
            </div>
            <h2 class="text-3xl font-bold text-white mb-2">Order Placed Successfully!</h2>
            <p class="text-gray-400">
              Thank you for your order. A confirmation email has been sent to
              <span class="font-semibold text-purple-400">{{ lastOrder?.customer_email }}</span>
            </p>
          </div>

          <div class="p-8">
            <div class="bg-gray-750 rounded-lg p-6 mb-6 border border-gray-700">
              <h3 class="text-lg font-semibold mb-4 text-white">Order Details</h3>
              <div class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-gray-400">Order Number:</span>
                  <span class="font-semibold text-white">#{{ lastOrder?.id }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Total Amount:</span>
                  <span class="font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent text-xl">\${{ parseFloat(lastOrder?.total || 0).toFixed(2) }}</span>
                </div>
              </div>
            </div>

            <button @click="orderPlaced = false"
                    class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg text-lg font-semibold hover:from-purple-700 hover:to-pink-700 shadow-lg">
              Continue Shopping
            </button>
          </div>
        </div>
      </div>
    </div>
  `
});

app.mount('#app');
