const { accountsService } = require('../services/accountsService');

const accountsController = {
  list: async (req, res, next) => {
    try {
      const items = await accountsService.listByUser(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const item = await accountsService.getById(req.user.id, req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  create: async (req, res, next) => {
    try {
      const item = await accountsService.create(req.user.id, req.body);
      res.status(201).json(item);
    } catch (e) {
      next(e);
    }
  },
};

module.exports = { accountsController };
