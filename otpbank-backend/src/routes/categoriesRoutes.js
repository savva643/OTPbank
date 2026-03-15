const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { categoriesController } = require('../controllers/categoriesController');

const categoriesRoutes = express.Router();

// Get all payment categories
categoriesRoutes.get('/', authRequired, categoriesController.getCategories);

// Search services across all categories
categoriesRoutes.get('/services/search', authRequired, categoriesController.searchServices);

// Get services by category ID
categoriesRoutes.get('/:categoryId/services', authRequired, categoriesController.getServicesByCategory);

module.exports = { categoriesRoutes };
