const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { widgetsController } = require('../controllers/widgetsController');

const widgetsRoutes = express.Router();

widgetsRoutes.get('/cashback', authRequired, widgetsController.cashback);
widgetsRoutes.get('/bonuses', authRequired, widgetsController.bonuses);

module.exports = { widgetsRoutes };
