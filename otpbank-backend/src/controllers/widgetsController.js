const { widgetsService } = require('../services/widgetsService');

const widgetsController = {
  cashback: async (req, res, next) => {
    try {
      const data = await widgetsService.getCashback(req.user.id);
      res.json(data);
    } catch (e) {
      next(e);
    }
  },
  bonuses: async (req, res, next) => {
    try {
      const data = await widgetsService.getBonuses(req.user.id);
      res.json(data);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { widgetsController };
