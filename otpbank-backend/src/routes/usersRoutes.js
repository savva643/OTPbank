const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { usersController } = require('../controllers/usersController');

const usersRoutes = express.Router();

usersRoutes.get('/search', authRequired, usersController.searchByPhone);

module.exports = { usersRoutes };
