const { productsService } = require('../services/productsService');

const productsController = {
  showcase: async (req, res, next) => {
    try {
      const data = await productsService.showcase();
      res.json(data);
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const data = await productsService.getByIdWithDetails(req.params.id);
      res.json(data);
    } catch (e) {
      next(e);
    }
  },

  list: async (req, res, next) => {
    try {
      const data = await productsService.list();
      res.json(data);
    } catch (e) {
      next(e);
    }
  },

  getByCategory: async (req, res, next) => {
    try {
      const data = await productsService.getByCategory(req.params.id);
      res.json(data);
    } catch (e) {
      next(e);
    }
  },

  getRecommended: async (req, res, next) => {
    try {
      const item = await productsService.getRecommended(req.user.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { productsController };
