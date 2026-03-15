const express = require('express');
const { requireAuth } = require('../middlewares/auth');
const { notificationsController } = require('../controllers/notificationsController');

const router = express.Router();

// GET /notifications - список уведомлений
router.get('/', requireAuth, notificationsController.getNotifications);

// PATCH /notifications/:id/read - отметить как прочитанное
router.patch('/:id/read', requireAuth, notificationsController.markAsRead);

// PATCH /notifications/read-all - отметить все как прочитанные
router.patch('/read-all', requireAuth, notificationsController.markAllAsRead);

// DELETE /notifications/:id - удалить уведомление
router.delete('/:id', requireAuth, notificationsController.deleteNotification);

module.exports = { notificationsRoutes: router };
