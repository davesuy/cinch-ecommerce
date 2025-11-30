<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4"
    @click.self="$emit('close')"
  >
    <div class="bg-gray-800 rounded-lg shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-auto border border-gray-700">
      <div class="flex justify-between items-center p-6 border-b border-gray-700">
        <h2 class="text-2xl font-bold text-white">Product Details</h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-white text-2xl">&times;</button>
      </div>

      <div v-if="loading" class="p-12 text-center">
        <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-purple-500"></div>
        <p class="mt-4 text-gray-400">Loading product details...</p>
      </div>

      <div v-else-if="product" class="p-6">
        <div class="grid md:grid-cols-2 gap-8">
          <!-- Product Image -->
          <div>
            <img
              :src="product.image || 'https://via.placeholder.com/600x400'"
              :alt="product.name"
              class="w-full rounded-lg shadow-lg"
            >
          </div>

          <!-- Product Info -->
          <div class="space-y-4">
            <div>
              <span
                v-if="product.category"
                class="inline-block bg-gradient-to-r from-purple-600 to-pink-600 text-white text-sm px-4 py-1 rounded-full mb-3"
              >
                {{ product.category }}
              </span>
              <h3 class="text-3xl font-bold text-white mb-2">{{ product.name }}</h3>
              <p class="text-gray-300 text-base leading-relaxed">{{ product.description }}</p>
            </div>

            <div class="border-t border-gray-700 pt-4">
              <div class="flex justify-between items-center mb-4">
                <span class="text-4xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
                  ${{ product.price }}
                </span>
                <div class="text-right">
                  <span class="text-sm text-gray-400 block">Availability:</span>
                  <span
                    :class="product.stock > 0 ? 'text-green-400' : 'text-red-400'"
                    class="font-semibold"
                  >
                    {{ product.stock > 0 ? `${product.stock} in stock` : 'Out of Stock' }}
                  </span>
                </div>
              </div>

              <div v-if="product.stock > 0" class="space-y-4">
                <div>
                  <label class="block text-sm font-medium mb-2 text-gray-300">Quantity:</label>
                  <div class="flex items-center gap-4">
                    <button
                      @click="decrementQuantity"
                      class="w-12 h-12 bg-gray-700 text-white rounded-lg hover:bg-gray-600 transition text-xl font-bold"
                    >
                      -
                    </button>
                    <input
                      v-model.number="selectedQuantity"
                      type="number"
                      min="1"
                      :max="product.stock"
                      class="w-20 text-center px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 text-xl font-semibold"
                    >
                    <button
                      @click="incrementQuantity"
                      class="w-12 h-12 bg-gray-700 text-white rounded-lg hover:bg-gray-600 transition text-xl font-bold"
                    >
                      +
                    </button>
                  </div>
                </div>

                <button
                  @click="addToCart"
                  class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-4 rounded-lg text-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition shadow-lg"
                >
                  Add to Cart
                </button>
              </div>

              <div v-else>
                <button
                  disabled
                  class="w-full bg-gray-600 text-gray-400 px-6 py-4 rounded-lg text-lg font-semibold cursor-not-allowed"
                >
                  Out of Stock
                </button>
              </div>
            </div>

            <!-- Additional Product Information -->
            <div class="border-t border-gray-700 pt-4">
              <h4 class="text-lg font-semibold text-white mb-3">Product Information</h4>
              <div class="space-y-2 text-sm">
                <div class="flex justify-between">
                  <span class="text-gray-400">Product ID:</span>
                  <span class="text-white font-medium">#{{ product.id }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Category:</span>
                  <span class="text-white font-medium">{{ product.category || 'N/A' }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Status:</span>
                  <span class="text-white font-medium">{{ product.is_active ? 'Active' : 'Inactive' }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProductDetailModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    product: {
      type: Object,
      default: null
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'add-to-cart'],
  data() {
    return {
      selectedQuantity: 1
    }
  },
  watch: {
    product(newProduct) {
      if (newProduct) {
        this.selectedQuantity = 1;
      }
    }
  },
  methods: {
    incrementQuantity() {
      if (this.selectedQuantity < this.product.stock) {
        this.selectedQuantity++;
      }
    },
    decrementQuantity() {
      if (this.selectedQuantity > 1) {
        this.selectedQuantity--;
      }
    },
    addToCart() {
      this.$emit('add-to-cart', {
        product: this.product,
        quantity: this.selectedQuantity
      });
      this.$emit('close');
    }
  }
}
</script>

