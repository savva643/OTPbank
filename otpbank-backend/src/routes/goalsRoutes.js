const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { goalsController } = require('../controllers/goalsController');

const goalsRoutes = express.Router();

goalsRoutes.get('/', authRequired, goalsController.list);
goalsRoutes.post('/', authRequired, goalsController.create);
goalsRoutes.put('/:id', authRequired, goalsController.update);
goalsRoutes.delete('/:id', authRequired, goalsController.remove);

module.exports = { goalsRoutes };
