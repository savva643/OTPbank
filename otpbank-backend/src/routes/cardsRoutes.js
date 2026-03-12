const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { cardsController } = require('../controllers/cardsController');

const cardsRoutes = express.Router();

cardsRoutes.get('/', authRequired, cardsController.list);
cardsRoutes.get('/:id', authRequired, cardsController.getById);
cardsRoutes.post('/:id/freeze', authRequired, cardsController.freeze);
cardsRoutes.post('/:id/unfreeze', authRequired, cardsController.unfreeze);
cardsRoutes.post('/:id/limits', authRequired, cardsController.updateLimits);

module.exports = { cardsRoutes };
