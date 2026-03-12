const { storiesService } = require('../services/storiesService');

const storiesController = {
  list: async (req, res, next) => {
    try {
      const items = await storiesService.list();
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const item = await storiesService.getById(req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { storiesController };
