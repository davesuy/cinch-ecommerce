<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4"
    @click.self="$emit('close')"
  >
    <div class="bg-gray-800 rounded-lg shadow-2xl max-w-2xl w-full border border-gray-700">
      <div class="text-center p-8 border-b border-gray-700">
        <div class="mx-auto w-16 h-16 bg-gradient-to-r from-green-400 to-emerald-500 rounded-full flex items-center justify-center mb-4 shadow-lg">
          <span class="text-3xl">✓</span>
        </div>
        <h2 class="text-3xl font-bold text-white mb-2">Order Placed Successfully!</h2>
        <p class="text-gray-400">
          Thank you for your order. A confirmation email has been sent to
          <span class="font-semibold text-purple-400">{{ order?.customer_email }}</span>
        </p>
      </div>

      <div class="p-8">
        <div class="bg-gray-750 rounded-lg p-6 mb-6 border border-gray-700">
          <h3 class="text-lg font-semibold mb-4 text-white">Order Details</h3>
          <div class="space-y-2">
            <div class="flex justify-between">
              <span class="text-gray-400">Order Number:</span>
              <span class="font-semibold text-white">#{{ order?.id }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">Total Amount:</span>
              <span class="font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent text-xl">
                ${{ parseFloat(order?.total || 0).toFixed(2) }}
              </span>
            </div>
          </div>
        </div>

        <button
          @click="$emit('close')"
          class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg text-lg font-semibold hover:from-purple-700 hover:to-pink-700 shadow-lg"
        >
          Continue Shopping
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'OrderSuccessModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    order: {
      type: Object,
      default: null
    }
  },
  emits: ['close']
}
</script>

