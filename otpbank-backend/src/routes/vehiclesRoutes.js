const express = require('express');
const { vehiclesController } = require('../controllers/vehiclesController');
const { authRequired } = require('../middlewares/auth');

const router = express.Router();

router.use(authRequired);

router.get('/', vehiclesController.list);
router.post('/', vehiclesController.create);
router.get('/:id', vehiclesController.getById);
router.patch('/:id', vehiclesController.update);
router.delete('/:id', vehiclesController.delete);

module.exports = { vehiclesRoutes: router };
