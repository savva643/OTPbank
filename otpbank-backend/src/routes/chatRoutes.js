const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { chatController } = require('../controllers/chatController');

const chatRoutes = express.Router();

chatRoutes.get('/messages', authRequired, chatController.listMessages);
chatRoutes.post('/messages', authRequired, chatController.sendMessage);

module.exports = { chatRoutes };
