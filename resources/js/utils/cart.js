const CART_STORAGE_KEY = 'cart';

export const cartStorage = {
  /**
   * Save cart to localStorage
   * @param {Array} cart - Cart items array
   */
  save(cart) {
    try {
      localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
    } catch (error) {
      console.error('Error saving cart to localStorage:', error);
    }
  },

  /**
   * Load cart from localStorage
   * @returns {Array} Cart items
   */
  load() {
    try {
      const saved = localStorage.getItem(CART_STORAGE_KEY);
      return saved ? JSON.parse(saved) : [];
    } catch (error) {
      console.error('Error loading cart from localStorage:', error);
      return [];
    }
  },

  /**
   * Clear cart from localStorage
   */
  clear() {
    try {
      localStorage.removeItem(CART_STORAGE_KEY);
    } catch (error) {
      console.error('Error clearing cart from localStorage:', error);
    }
  }
};

export const cartHelpers = {
  /**
   * Calculate total cart value
   * @param {Array} cart - Cart items
   * @returns {Number} Total price
   */
  calculateTotal(cart) {
    return cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  },

  /**
   * Calculate total items count
   * @param {Array} cart - Cart items
   * @returns {Number} Total quantity
   */
  calculateItemCount(cart) {
    return cart.reduce((sum, item) => sum + item.quantity, 0);
  },

  /**
   * Add item to cart or update quantity if exists
   * @param {Array} cart - Current cart
   * @param {Object} product - Product to add
   * @param {Number} quantity - Quantity to add
   * @returns {Array} Updated cart
   */
  addItem(cart, product, quantity = 1) {
    const existingItem = cart.find(item => item.id === product.id);

    if (existingItem) {
      existingItem.quantity += quantity;
      return [...cart];
    }

    return [
      ...cart,
      {
        id: product.id,
        name: product.name,
        price: parseFloat(product.price),
        image: product.image,
        quantity: quantity
      }
    ];
  },

  /**
   * Update item quantity in cart
   * @param {Array} cart - Current cart
   * @param {Number} productId - Product ID
   * @param {Number} quantity - New quantity
   * @returns {Array} Updated cart
   */
  updateQuantity(cart, productId, quantity) {
    if (quantity <= 0) {
      return cart.filter(item => item.id !== productId);
    }

    return cart.map(item =>
      item.id === productId
        ? { ...item, quantity }
        : item
    );
  },

  /**
   * Remove item from cart
   * @param {Array} cart - Current cart
   * @param {Number} productId - Product ID to remove
   * @returns {Array} Updated cart
   */
  removeItem(cart, productId) {
    return cart.filter(item => item.id !== productId);
  }
};

