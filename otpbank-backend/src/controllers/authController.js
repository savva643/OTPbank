const { authService } = require('../services/authService');
const { otpAuthService } = require('../services/otpAuthService');

const authController = {
  register: async (req, res, next) => {
    try {
      const result = await authService.register(req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  login: async (req, res, next) => {
    try {
      const result = await authService.login(req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  },
  otpRequest: async (req, res, next) => {
    try {
      const result = await otpAuthService.requestCode(req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  },
  otpVerify: async (req, res, next) => {
    try {
      const result = await otpAuthService.verifyCode(req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  },
  completeRegistration: async (req, res, next) => {
    try {
      const result = await otpAuthService.completeRegistration(req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { authController };
