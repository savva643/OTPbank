const { transactionsService } = require('../services/transactionsService');

const transactionsController = {
  list: async (req, res, next) => {
    try {
      const data = await transactionsService.list(req.user.id, req.query);
      res.json(data);
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const item = await transactionsService.getById(req.user.id, req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { transactionsController };
