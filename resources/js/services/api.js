import axios from 'axios';

const API_BASE_URL = '/api';

export const productService = {
  /**
   * Fetch all products with optional filters
   * @param {Object} params - Query parameters (search, category)
   * @returns {Promise}
   */
  async getAll(params = {}) {
    const response = await axios.get(`${API_BASE_URL}/products`, { params });
    return response.data;
  },

  /**
   * Fetch single product by ID
   * @param {Number} id - Product ID
   * @returns {Promise}
   */
  async getById(id) {
    const response = await axios.get(`${API_BASE_URL}/products/${id}`);
    return response.data;
  },

  /**
   * Fetch all product categories
   * @returns {Promise}
   */
  async getCategories() {
    const response = await axios.get(`${API_BASE_URL}/categories`);
    return response.data;
  }
};

export const orderService = {
  /**
   * Create a new order
   * @param {Object} orderData - Order data including customer info and items
   * @returns {Promise}
   */
  async create(orderData) {
    const response = await axios.post(`${API_BASE_URL}/orders`, orderData);
    return response.data;
  },

  /**
   * Fetch order by ID
   * @param {Number} id - Order ID
   * @returns {Promise}
   */
  async getById(id) {
    const response = await axios.get(`${API_BASE_URL}/orders/${id}`);
    return response.data;
  }
};

