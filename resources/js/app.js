import './bootstrap';
import { createApp } from 'vue';
import ProductCard al from './components/ProductDetailModal.vue';
import CartModal from './components/CartModal.vue';
import CheckoutModal from './components/CheckoutModal.vue';
import OrderSuccessModal from './components/OrderSuccessModal.vue';
import { productService, orderService } from './services/api';
import { cartStorage, cartHelpers } from './utils/cart';
from './components/ProductCard.vue';
import ProductDetailMod
const app = createApp({
  components: {
    ProductCard,
    ProductDetailModal,
    CartModal,
    CheckoutModal,
    OrderSuccessModal
  },

  data() {
    return {
      // Product data
      products: [],
      categories: [],
      selectedProduct: null,

      // Cart data
      cart: [],

      // UI state
      loading: true,
      error: null,
      productDetailLoading: false,
      orderSubmitting: false,

      // Modal visibility
      showCart: false,
      showProductDetail: false,
      showCheckout: false,
      showOrderSuccess: false,

      // Filters
      searchQuery: '',
      selectedCategory: '',

      // Order data
      lastOrder: null
    }
  },

  computed: {
    filteredProducts() {
      let result = [...this.products];

      if (this.selectedCategory) {
        result = result.filter(p => p.category === this.selectedCategory);
      }

      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase().trim();
        result = result.filter(p =>
          p.name.toLowerCase().includes(query) ||
          p.description.toLowerCase().includes(query)
        );
      }

      return result;
    },

    cartItemCount() {
      return cartHelpers.calculateItemCount(this.cart);
    },

    cartTotal() {
      return cartHelpers.calculateTotal(this.cart);
    }
  },

  async mounted() {
    await this.initializeApp();
  },

  methods: {
    /**
     * Initialize application - load products, categories, and cart
     */
    async initializeApp() {
      await Promise.all([
        this.fetchProducts(),
        this.fetchCategories()
      ]);
      this.loadCart();
    },

    /**
     * Fetch all products from API
     */
    async fetchProducts() {
      try {
        this.loading = true;
        this.error = null;
        const response = await productService.getAll();

        if (response.success) {
          this.products = response.data || [];
        }
      } catch (error) {
        console.error('Error fetching products:', error);
        this.error = 'Failed to load products. Please refresh the page.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Fetch product categories from API
     */
    async fetchCategories() {
      try {
        const response = await productService.getCategories();
        if (response.success) {
          this.categories = response.data || [];
        }
      } catch (error) {
        console.error('Error fetching categories:', error);
      }
    },

    /**
     * View product details
     * @param {Number} productId - Product ID
     */
    async viewProductDetail(productId) {
      try {
        this.productDetailLoading = true;
        this.showProductDetail = true;

        const response = await productService.getById(productId);

        if (response.success) {
          this.selectedProduct = response.data;
        }
      } catch (error) {
        console.error('Error fetching product details:', error);
        this.error = 'Failed to load product details';
        this.showProductDetail = false;
      } finally {
        this.productDetailLoading = false;
      }
    },

    /**
     * Close product detail modal
     */
    closeProductDetail() {
      this.showProductDetail = false;
      this.selectedProduct = null;
    },

    /**
     * Add product to cart (quick add from card)
     * @param {Object} product - Product object
     */
    addToCart(product) {
      this.cart = cartHelpers.addItem(this.cart, product, 1);
      this.saveCart();
    },

    /**
     * Add product to cart from detail modal
     * @param {Object} data - Contains product and quantity
     */
    addToCartFromDetail(data) {
      const { product, quantity } = data;
      this.cart = cartHelpers.addItem(this.cart, product, quantity);
      this.saveCart();
      this.showCart = true;
    },

    /**
     * Update cart item quantity
     * @param {Object} data - Contains id and quantity
     */
    updateCartQuantity(data) {
      const { id, quantity } = data;
      this.cart = cartHelpers.updateQuantity(this.cart, id, quantity);
      this.saveCart();
    },

    /**
     * Remove item from cart
     * @param {Number} productId - Product ID
     */
    removeFromCart(productId) {
      this.cart = cartHelpers.removeItem(this.cart, productId);
      this.saveCart();
    },

    /**
     * Save cart to localStorage
     */
    saveCart() {
      cartStorage.save(this.cart);
    },

    /**
     * Load cart from localStorage
     */
    loadCart() {
      this.cart = cartStorage.load();
    },

    /**
     * Clear cart
     */
    clearCart() {
      this.cart = [];
      cartStorage.clear();
    },

    /**
     * Proceed to checkout
     */
    proceedToCheckout() {
      this.showCart = false;
      this.showCheckout = true;
    },

    /**
     * Submit order
     * @param {Object} formData - Customer information
     */
    async submitOrder(formData) {
      try {
        this.orderSubmitting = true;

        const orderData = {
          ...formData,
          items: this.cart.map(item => ({
            product_id: item.id,
            quantity: item.quantity
          }))
        };

        const response = await orderService.create(orderData);

        if (response.success) {
          this.lastOrder = response.data;
          this.clearCart();
          this.showCheckout = false;
          this.showOrderSuccess = true;
        }
      } catch (error) {
        console.error('Error placing order:', error);
        const errorMessage = error.response?.data?.message || 'Failed to place order. Please try again.';
        alert(errorMessage);
      } finally {
        this.orderSubmitting = false;
      }
    },

    /**
     * Close order success modal
     */
    closeOrderSuccess() {
      this.showOrderSuccess = false;
      this.lastOrder = null;
    }
  },

  template: `
    <div class="min-h-screen bg-gray-900">
      <!-- Header -->
      <header class="bg-gray-800 text-white shadow-2xl border-b border-gray-700">
        <div class="container mx-auto px-4 py-6">
          <div class="flex justify-between items-center">
            <h1 class="text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
              🛒 Cinch E-Commerce
            </h1>
            <button
              @click="showCart = true"
              class="relative bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-2 rounded-lg hover:from-purple-700 hover:to-pink-700 transition-all shadow-lg"
            >
              🛒 Cart
              <span
                v-if="cartItemCount > 0"
                class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold shadow-lg"
              >
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
          <button
            @click="fetchProducts"
            class="mt-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-2 rounded-lg hover:from-purple-700 hover:to-pink-700"
          >
            Retry
          </button>
        </div>

        <!-- No Products -->
        <div v-else-if="filteredProducts.length === 0" class="text-center py-12">
          <p class="text-gray-400 text-lg">No products found.</p>
        </div>

        <!-- Products Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <ProductCard
            v-for="product in filteredProducts"
            :key="product.id"
            :product="product"
            @view-details="viewProductDetail"
            @add-to-cart="addToCart"
          />
        </div>
      </main>

      <!-- Modals -->
      <ProductDetailModal
        :show="showProductDetail"
        :product="selectedProduct"
        :loading="productDetailLoading"
        @close="closeProductDetail"
        @add-to-cart="addToCartFromDetail"
      />

      <CartModal
        :show="showCart"
        :cart="cart"
        @close="showCart = false"
        @update-quantity="updateCartQuantity"
        @remove-item="removeFromCart"
        @checkout="proceedToCheckout"
      />

      <CheckoutModal
        :show="showCheckout"
        :cart="cart"
        :submitting="orderSubmitting"
        @close="showCheckout = false"
        @submit="submitOrder"
      />

      <OrderSuccessModal
        :show="showOrderSuccess"
        :order="lastOrder"
        @close="closeOrderSuccess"
      />
    </div>
  `
});

app.mount('#app');
