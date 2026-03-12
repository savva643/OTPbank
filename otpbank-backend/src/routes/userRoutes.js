const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { userController } = require('../controllers/userController');

const userRoutes = express.Router();

userRoutes.get('/profile', authRequired, userController.getProfile);
userRoutes.put('/profile', authRequired, userController.updateProfile);
userRoutes.put('/avatar', authRequired, userController.updateAvatar);

module.exports = { userRoutes };
