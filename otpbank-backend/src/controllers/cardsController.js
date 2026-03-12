const { cardsService } = require('../services/cardsService');

const cardsController = {
  list: async (req, res, next) => {
    try {
      const items = await cardsService.listByUser(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },
  getById: async (req, res, next) => {
    try {
      const item = await cardsService.getById(req.user.id, req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },
  freeze: async (req, res, next) => {
    try {
      const item = await cardsService.setStatus(req.user.id, req.params.id, 'frozen');
      res.json(item);
    } catch (e) {
      next(e);
    }
  },
  unfreeze: async (req, res, next) => {
    try {
      const item = await cardsService.setStatus(req.user.id, req.params.id, 'active');
      res.json(item);
    } catch (e) {
      next(e);
    }
  },
  updateLimits: async (req, res, next) => {
    try {
      const item = await cardsService.updateLimits(req.user.id, req.params.id, req.body);
      res.json(item);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { cardsController };
