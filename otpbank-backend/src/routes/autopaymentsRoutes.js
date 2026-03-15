const express = require('express');
const { autopaymentsController } = require('../controllers/autopaymentsController');
const { authRequired } = require('../middlewares/auth');

const router = express.Router();

router.use(authRequired);

router.get('/', autopaymentsController.list);
router.post('/', autopaymentsController.create);
router.get('/:id', autopaymentsController.getById);
router.patch('/:id', autopaymentsController.update);
router.delete('/:id', autopaymentsController.delete);

// Автоплатежи для конкретного объекта
router.get('/property/:propertyId', autopaymentsController.listByProperty);
router.get('/vehicle/:vehicleId', autopaymentsController.listByVehicle);

module.exports = { autopaymentsRoutes: router };
