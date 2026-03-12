const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { investmentsController } = require('../controllers/investmentsController');

const investmentsRoutes = express.Router();

investmentsRoutes.get('/portfolio', authRequired, investmentsController.getPortfolio);
investmentsRoutes.get('/assets', authRequired, investmentsController.listAssets);
investmentsRoutes.get('/instruments', authRequired, investmentsController.listInstruments);
investmentsRoutes.get('/quotes', authRequired, investmentsController.getQuotes);
investmentsRoutes.get('/predictions', authRequired, investmentsController.getPredictions);

module.exports = { investmentsRoutes };
