const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { storiesController } = require('../controllers/storiesController');

const storiesRoutes = express.Router();

storiesRoutes.get('/', authRequired, storiesController.list);
storiesRoutes.get('/:id', authRequired, storiesController.getById);

module.exports = { storiesRoutes };
