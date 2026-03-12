const { scenariosService } = require('../services/scenariosService');

const scenariosController = {
  list: async (req, res, next) => {
    try {
      const data = await scenariosService.list();
      res.json(data);
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const data = await scenariosService.getById(req.params.id);
      res.json(data);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { scenariosController };
