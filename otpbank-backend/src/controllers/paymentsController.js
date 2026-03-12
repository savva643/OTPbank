const { paymentsService } = require('../services/paymentsService');

const paymentsController = {
  cardTransfer: async (req, res, next) => {
    try {
      const result = await paymentsService.cardTransfer(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  phoneTransfer: async (req, res, next) => {
    try {
      const result = await paymentsService.phoneTransfer(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  sbpTransfer: async (req, res, next) => {
    try {
      const result = await paymentsService.sbpTransfer(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  payBills: async (req, res, next) => {
    try {
      const result = await paymentsService.payBills(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  mobileTopUp: async (req, res, next) => {
    try {
      const result = await paymentsService.mobileTopUp(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  nfcStart: async (req, res, next) => {
    try {
      const result = await paymentsService.nfcStart(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  nfcConfirm: async (req, res, next) => {
    try {
      const result = await paymentsService.nfcConfirm(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  },
  qrScan: async (req, res, next) => {
    try {
      const result = await paymentsService.qrScan(req.user.id, req.body);
      res.json(result);
    } catch (e) {
      next(e);
    }
  },
  qrPay: async (req, res, next) => {
    try {
      const result = await paymentsService.qrPay(req.user.id, req.body);
      res.status(201).json(result);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { paymentsController };
