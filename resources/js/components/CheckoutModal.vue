<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4"
    @click.self="$emit('close')"
  >
    <div class="bg-gray-800 rounded-lg shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-auto border border-gray-700">
      <div class="flex justify-between items-center p-6 border-b border-gray-700">
        <h2 class="text-2xl font-bold text-white">Checkout</h2>
        <button @click="$emit('close')" class="text-gray-400 hover:text-white text-2xl">&times;</button>
      </div>

      <form @submit.prevent="submitOrder" class="p-6 space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1 text-gray-300">Full Name *</label>
          <input
            v-model="form.customer_name"
            required
            class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          >
        </div>
        <div>
          <label class="block text-sm font-medium mb-1 text-gray-300">Email *</label>
          <input
            v-model="form.customer_email"
            type="email"
            required
            class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          >
        </div>
        <div>
          <label class="block text-sm font-medium mb-1 text-gray-300">Phone</label>
          <input
            v-model="form.customer_phone"
            type="tel"
            class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          >
        </div>
        <div>
          <label class="block text-sm font-medium mb-1 text-gray-300">Shipping Address *</label>
          <textarea
            v-model="form.shipping_address"
            required
            rows="3"
            class="w-full px-4 py-2 bg-gray-700 border border-gray-600 text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          ></textarea>
        </div>

        <div class="border-t border-gray-700 pt-4">
          <h3 class="font-semibold mb-2 text-white">Order Summary</h3>
          <div
            v-for="item in cart"
            :key="item.id"
            class="flex justify-between text-sm mb-1 text-gray-300"
          >
            <span>{{ item.name }} x {{ item.quantity }}</span>
            <span>${{ (item.price * item.quantity).toFixed(2) }}</span>
          </div>
          <div class="flex justify-between font-bold text-lg mt-2 pt-2 border-t border-gray-700">
            <span class="text-white">Total:</span>
            <span class="bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
              ${{ total.toFixed(2) }}
            </span>
          </div>
        </div>

        <button
          type="submit"
          :disabled="submitting"
          class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg text-lg font-semibold hover:from-purple-700 hover:to-pink-700 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ submitting ? 'Processing...' : 'Place Order' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CheckoutModal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    cart: {
      type: Array,
      required: true
    },
    submitting: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'submit'],
  data() {
    return {
      form: {
        customer_name: '',
        customer_email: '',
        customer_phone: '',
        shipping_address: ''
      }
    }
  },
  computed: {
    total() {
      return this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    }
  },
  methods: {
    submitOrder() {
      this.$emit('submit', { ...this.form });
      this.resetForm();
    },
    resetForm() {
      this.form = {
        customer_name: '',
        customer_email: '',
        customer_phone: '',
        shipping_address: ''
      };
    }
  }
}
</script>

