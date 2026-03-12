const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { productsController } = require('../controllers/productsController');

const productsRoutes = express.Router();

productsRoutes.get('/showcase', authRequired, productsController.showcase);
productsRoutes.get('/:id', authRequired, productsController.getById);
productsRoutes.get('/', authRequired, productsController.list);
productsRoutes.get('/category/:id', authRequired, productsController.getByCategory);
productsRoutes.get('/recommended', authRequired, productsController.getRecommended);

module.exports = { productsRoutes };
