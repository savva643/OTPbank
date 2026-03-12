const express = require('express');
const { healthRoutes } = require('./healthRoutes');
const { authRoutes } = require('./authRoutes');
const { userRoutes } = require('./userRoutes');
const { accountsRoutes } = require('./accountsRoutes');
const { cardsRoutes } = require('./cardsRoutes');
const { widgetsRoutes } = require('./widgetsRoutes');
const { productsRoutes } = require('./productsRoutes');
const { scenariosRoutes } = require('./scenariosRoutes');
const { goalsRoutes } = require('./goalsRoutes');
const { investmentsRoutes } = require('./investmentsRoutes');
const { transactionsRoutes } = require('./transactionsRoutes');
const { chatRoutes } = require('./chatRoutes');
const { paymentsRoutes } = require('./paymentsRoutes');
const { storiesRoutes } = require('./storiesRoutes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/user', userRoutes);
router.use('/accounts', accountsRoutes);
router.use('/cards', cardsRoutes);
router.use('/widgets', widgetsRoutes);
router.use('/products', productsRoutes);
router.use('/scenarios', scenariosRoutes);
router.use('/goals', goalsRoutes);
router.use('/investments', investmentsRoutes);
router.use('/transactions', transactionsRoutes);
router.use('/chat', chatRoutes);
router.use('/payments', paymentsRoutes);
router.use('/stories', storiesRoutes);

module.exports = { router };
