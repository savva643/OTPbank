const { investmentsService } = require('../services/investmentsService');
const { marketSimService } = require('../services/marketSimService');

const investmentsController = {
  getPortfolio: async (req, res, next) => {
    try {
      const data = await investmentsService.getPortfolio(req.user.id);
      res.json(data);
    } catch (e) {
      next(e);
    }
  },

  listAssets: async (req, res, next) => {
    try {
      const items = await investmentsService.listAssets(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  listInstruments: async (req, res, next) => {
    try {
      const items = marketSimService.listInstruments();
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  getQuotes: async (req, res, next) => {
    try {
      const raw = req.query.tickers;
      const tickers = typeof raw === 'string' ? raw.split(',').map((x) => x.trim()).filter(Boolean) : [];
      marketSimService.assertTickersValid(tickers);
      const items = marketSimService.getQuotes(tickers);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  getPredictions: async (req, res, next) => {
    try {
      const raw = req.query.tickers;
      const tickers = typeof raw === 'string' ? raw.split(',').map((x) => x.trim()).filter(Boolean) : [];
      marketSimService.assertTickersValid(tickers);
      const items = marketSimService.getPredictions(tickers);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { investmentsController };
