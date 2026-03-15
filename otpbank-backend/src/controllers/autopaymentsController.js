const { autopaymentsService } = require('../services/autopaymentsService');

const autopaymentsController = {
  list: async (req, res, next) => {
    try {
      const items = await autopaymentsService.listByUser(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  listByProperty: async (req, res, next) => {
    try {
      const items = await autopaymentsService.listByProperty(req.user.id, req.params.propertyId);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  listByVehicle: async (req, res, next) => {
    try {
      const items = await autopaymentsService.listByVehicle(req.user.id, req.params.vehicleId);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  create: async (req, res, next) => {
    try {
      const item = await autopaymentsService.create(req.user.id, req.body);
      res.status(201).json(item);
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const item = await autopaymentsService.getById(req.user.id, req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  update: async (req, res, next) => {
    try {
      const item = await autopaymentsService.update(req.user.id, req.params.id, req.body);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  delete: async (req, res, next) => {
    try {
      await autopaymentsService.delete(req.user.id, req.params.id);
      res.json({ ok: true });
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { autopaymentsController };
