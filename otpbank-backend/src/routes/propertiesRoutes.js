const express = require('express');
const { propertiesController } = require('../controllers/propertiesController');
const { authRequired } = require('../middlewares/auth');

const router = express.Router();

// Все роуты требуют авторизации
router.use(authRequired);

// CRUD для недвижимости
router.get('/', propertiesController.list);
router.post('/', propertiesController.create);
router.get('/:id', propertiesController.getById);
router.patch('/:id', propertiesController.update);
router.delete('/:id', propertiesController.delete);

module.exports = { propertiesRoutes: router };
