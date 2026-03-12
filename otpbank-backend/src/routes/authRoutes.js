const express = require('express');
const { authController } = require('../controllers/authController');

const authRoutes = express.Router();

authRoutes.post('/register', authController.register);
authRoutes.post('/login', authController.login);
authRoutes.post('/otp/request', authController.otpRequest);
authRoutes.post('/otp/verify', authController.otpVerify);
authRoutes.post('/complete-registration', authController.completeRegistration);

module.exports = { authRoutes };
