const { vehiclesService } = require('../services/vehiclesService');

const vehiclesController = {
  list: async (req, res, next) => {
    try {
      const items = await vehiclesService.listByUser(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  create: async (req, res, next) => {
    try {
      const item = await vehiclesService.create(req.user.id, req.body);
      res.status(201).json(item);
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const item = await vehiclesService.getById(req.user.id, req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  update: async (req, res, next) => {
    try {
      const item = await vehiclesService.update(req.user.id, req.params.id, req.body);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  delete: async (req, res, next) => {
    try {
      await vehiclesService.delete(req.user.id, req.params.id);
      res.json({ ok: true });
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { vehiclesController };
