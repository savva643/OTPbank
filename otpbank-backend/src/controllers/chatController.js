const { chatService } = require('../services/chatService');

const chatController = {
  listMessages: async (req, res, next) => {
    try {
      const items = await chatService.listMessages(req.user.id);
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  sendMessage: async (req, res, next) => {
    try {
      const item = await chatService.sendMessage(req.user.id, req.body);
      res.status(201).json(item);
    } catch (e) {
      next(e);
    }
  }
};

module.exports = { chatController };
