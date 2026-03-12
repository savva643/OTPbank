const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { transactionsController } = require('../controllers/transactionsController');

const transactionsRoutes = express.Router();

transactionsRoutes.get('/', authRequired, transactionsController.list);
transactionsRoutes.get('/:id', authRequired, transactionsController.getById);

module.exports = { transactionsRoutes };
