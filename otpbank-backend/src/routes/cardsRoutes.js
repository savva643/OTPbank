const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { cardsController } = require('../controllers/cardsController');

const cardsRoutes = express.Router();

cardsRoutes.get('/', authRequired, cardsController.list);
cardsRoutes.get('/:id', authRequired, cardsController.getById);
cardsRoutes.get('/:id/requisites', authRequired, cardsController.getRequisites);
cardsRoutes.post('/issue', authRequired, cardsController.issue);
cardsRoutes.post('/:id/freeze', authRequired, cardsController.freeze);
cardsRoutes.post('/:id/unfreeze', authRequired, cardsController.unfreeze);
cardsRoutes.post('/:id/block', authRequired, cardsController.block);
cardsRoutes.post('/:id/unblock', authRequired, cardsController.unblock);
cardsRoutes.post('/:id/limits', authRequired, cardsController.updateLimits);
cardsRoutes.post('/:id/pin', authRequired, cardsController.updatePin);

module.exports = { cardsRoutes };
