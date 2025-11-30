<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4"
    @click.self="$emit('close')"
  >
    <div class="bg-gray-800 rounded-lg shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden border border-gray-700">
      <div class="flex justify-between items-center p-6 border-b border-gray-700">
        <h2 class="text-2xl font-bold text-white">Shopping Cart</h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-white text-2xl">&times;</button>
      </div>

      <div class="p-6 overflow-y-auto" style="max-height: calc(90vh - 200px)">
        <div v-if="cart.length === 0" class="text-center py-12">
          <p class="text-gray-400 text-lg">Your cart is empty</p>
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="item in cart"
            :key="item.id"
            class="flex gap-4 p-4 border border-gray-700 rounded-lg bg-gray-750"
          >
            <img
              :src="item.image || 'https://via.placeholder.com/100'"
              :alt="item.name"
              class="w-20 h-20 object-cover rounded"
            >
            <div class="flex-1">
              <h3 class="font-semibold text-white">{{ item.name }}</h3>
              <p class="text-purple-400 font-bold">${{ item.price }}</p>
              <div class="flex items-center gap-2 mt-2">
                <button
                  @click="$emit('update-quantity', { id: item.id, quantity: item.quantity - 1 })"
                  class="w-8 h-8 bg-gray-700 text-white rounded hover:bg-gray-600 transition"
                >
                  -
                </button>
                <span class="w-12 text-center text-white">{{ item.quantity }}</span>
                <button
                  @click="$emit('update-quantity', { id: item.id, quantity: item.quantity + 1 })"
                  class="w-8 h-8 bg-gray-700 text-white rounded hover:bg-gray-600 transition"
                >
                  +
                </button>
              </div>
            </div>
            <div class="text-right">
              <p class="font-bold text-lg text-white">${{ (item.price * item.quantity).toFixed(2) }}</p>
              <button
                @click="$emit('remove-item', item.id)"
                class="text-red-400 hover:text-red-300 text-sm mt-2"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="cart.length > 0" class="p-6 border-t border-gray-700 bg-gray-750">
        <div class="flex justify-between items-center mb-4">
          <span class="text-xl font-semibold text-white">Total:</span>
          <span class="text-2xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            ${{ total.toFixed(2) }}
          </span>
        </div>
        <button
          @click="$emit('checkout')"
          class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg text-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition shadow-lg"
        >
          Proceed to Checkout
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CartModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    cart: {
      type: Array,
      required: true
    }
  },
  emits: ['close', 'update-quantity', 'remove-item', 'checkout'],
  computed: {
    total() {
      return this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    }
  }
}
</script>

