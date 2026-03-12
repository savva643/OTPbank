const { goalsService } = require('../services/goalsService');

const goalsController = {
  list: async (req, res, next) => {
    try {
      const items = await goalsService.list(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  create: async (req, res, next) => {
    try {
      const item = await goalsService.create(req.user.id, req.body);
      res.status(201).json(item);
    } catch (e) {
      next(e);
    }
  },

  update: async (req, res, next) => {
    try {
      const item = await goalsService.update(req.user.id, req.params.id, req.body);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  remove: async (req, res, next) => {
    try {
      await goalsService.remove(req.user.id, req.params.id);
      res.status(204).send();
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { goalsController };
