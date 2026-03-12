const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { scenariosController } = require('../controllers/scenariosController');

const scenariosRoutes = express.Router();

scenariosRoutes.get('/', authRequired, scenariosController.list);
scenariosRoutes.get('/:id', authRequired, scenariosController.getById);

module.exports = { scenariosRoutes };
