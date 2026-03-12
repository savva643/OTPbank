const { userService } = require('../services/userService');

const userController = {
  getProfile: async (req, res, next) => {
    try {
      const profile = await userService.getProfile(req.user.id);
      res.json(profile);
    } catch (e) {
      next(e);
    }
  },
  updateProfile: async (req, res, next) => {
    try {
      const profile = await userService.updateProfile(req.user.id, req.body);
      res.json(profile);
    } catch (e) {
      next(e);
    }
  },
  updateAvatar: async (req, res, next) => {
    try {
      const profile = await userService.updateAvatar(req.user.id, req.body);
      res.json(profile);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { userController };
