const { propertiesService } = require('../services/propertiesService');

const propertiesController = {
  list: async (req, res, next) => {
    try {
      const items = await propertiesService.listByUser(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  create: async (req, res, next) => {
    try {
      const item = await propertiesService.create(req.user.id, req.body);
      res.status(201).json(item);
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const item = await propertiesService.getById(req.user.id, req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  update: async (req, res, next) => {
    try {
      const item = await propertiesService.update(req.user.id, req.params.id, req.body);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  delete: async (req, res, next) => {
    try {
      await propertiesService.delete(req.user.id, req.params.id);
      res.json({ ok: true });
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { propertiesController };
