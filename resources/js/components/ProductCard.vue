<template>
  <div class="bg-gray-800 rounded-lg shadow-xl overflow-hidden hover:shadow-2xl hover:scale-105 transition-all border border-gray-700">
    <img
      :src="product.image || 'https://via.placeholder.com/400x300'"
      :alt="product.name"
      class="w-full h-48 object-cover cursor-pointer"
      @click="$emit('view-details', product.id)"
    >
    <div class="p-4">
      <span
        v-if="product.category"
        class="inline-block bg-gradient-to-r from-purple-600 to-pink-600 text-white text-xs px-3 py-1 rounded-full mb-2"
      >
        {{ product.category }}
      </span>
      <h3
        class="font-bold text-lg mb-2 text-white cursor-pointer hover:text-purple-400 transition"
        @click="$emit('view-details', product.id)"
      >
        {{ product.name }}
      </h3>
      <p class="text-gray-400 text-sm mb-3 line-clamp-2">{{ product.description }}</p>
      <div class="flex justify-between items-center mb-3">
        <span class="text-2xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
          ${{ product.price }}
        </span>
        <span class="text-sm text-gray-400">Stock: {{ product.stock }}</span>
      </div>
      <div class="space-y-2">
        <button
          @click="$emit('view-details', product.id)"
          class="w-full bg-gray-700 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition-all font-semibold border border-gray-600"
        >
          View Details
        </button>
        <button
          @click="$emit('add-to-cart', product)"
          :disabled="product.stock === 0"
          class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-4 py-2 rounded-lg hover:from-purple-700 hover:to-pink-700 transition-all disabled:from-gray-600 disabled:to-gray-700 disabled:cursor-not-allowed font-semibold shadow-lg"
        >
          {{ product.stock === 0 ? 'Out of Stock' : 'Quick Add to Cart' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProductCard',
  props: {
    product: {
      type: Object,
      required: true
    }
  },
  emits: ['view-details', 'add-to-cart']
}
</script>

