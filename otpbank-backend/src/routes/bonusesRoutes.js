const express = require('express');
const { requireAuth } = require('../middlewares/auth');
const { bonusesController } = require('../controllers/bonusesController');

const router = express.Router();

// GET /bonuses/stores - список магазинов с бонусами
router.get('/stores', requireAuth, bonusesController.getStores);

// GET /bonuses/balance - баланс бонусов пользователя
router.get('/balance', requireAuth, bonusesController.getBalance);

// GET /bonuses/transactions - история начисления/списания
router.get('/transactions', requireAuth, bonusesController.getTransactions);

module.exports = { bonusesRoutes: router };
