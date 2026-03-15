const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { accountsController } = require('../controllers/accountsController');

const accountsRoutes = express.Router();

accountsRoutes.get('/', authRequired, accountsController.list);
accountsRoutes.get('/:id', authRequired, accountsController.getById);
accountsRoutes.post('/', authRequired, accountsController.create);

module.exports = { accountsRoutes };
