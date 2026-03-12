const { accountsService } = require('../services/accountsService');

const accountsController = {
  list: async (req, res, next) => {
    try {
      const items = await accountsService.listByUser(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { accountsController };
