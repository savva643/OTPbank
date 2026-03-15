// Иконки для разных типов уведомлений
const NOTIFICATION_ICONS = {
  payment: 'payment',
  transfer: 'swap_horiz',
  bonus: 'stars',
  security: 'security',
  info: 'info',
  promo: 'local_offer',
  account: 'account_balance',
  card: 'credit_card',
};

// Тестовые уведомления
const MOCK_NOTIFICATIONS = [
  {
    id: '1',
    type: 'payment',
    title: 'Успешная оплата',
    message: 'Оплачено 899 ₽ в Магнит',
    icon: 'payment',
    isRead: false,
    createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
    action: {
      type: 'receipt',
      data: { transactionId: 'tx_123' },
    },
  },
  {
    id: '2',
    type: 'bonus',
    title: 'Начислены бонусы',
    message: '+45 баллов за покупку в Магнит',
    icon: 'stars',
    isRead: false,
    createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
    action: {
      type: 'bonuses',
    },
  },
  {
    id: '3',
    type: 'transfer',
    title: 'Перевод выполнен',
    message: '500 ₽ переведены Ивану И.',
    icon: 'swap_horiz',
    isRead: true,
    createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    action: {
      type: 'transaction',
      data: { transactionId: 'tx_456' },
    },
  },
  {
    id: '4',
    type: 'promo',
    title: 'Новая акция',
    message: 'Кэшбэк 10% в Самокате до конца недели!',
    icon: 'local_offer',
    isRead: false,
    createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    action: {
      type: 'promo',
      data: { storeId: 'samokat' },
    },
  },
  {
    id: '5',
    type: 'security',
    title: 'Вход в приложение',
    message: 'Новый вход с устройства iPhone 13',
    icon: 'security',
    isRead: true,
    createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    action: {
      type: 'security',
    },
  },
  {
    id: '6',
    type: 'account',
    title: 'Зачисление',
    message: 'На счёт поступило 15 000 ₽',
    icon: 'account_balance',
    isRead: true,
    createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
    action: {
      type: 'account',
      data: { accountId: 'acc_123' },
    },
  },
];

const notificationsController = {
  // GET /notifications
  getNotifications: async (req, res, next) => {
    try {
      const userId = req.user.id;
      const { limit = 20, offset = 0, unreadOnly = false } = req.query;
      
      // В реальном приложении - запрос к БД
      let notifications = MOCK_NOTIFICATIONS;
      
      if (unreadOnly === 'true') {
        notifications = notifications.filter(n => !n.isRead);
      }
      
      const total = notifications.length;
      const unreadCount = notifications.filter(n => !n.isRead).length;
      
      // Сортировка по дате (новые первые)
      notifications.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      
      const paginated = notifications.slice(parseInt(offset), parseInt(offset) + parseInt(limit));
      
      res.json({
        items: paginated,
        total,
        unreadCount,
        limit: parseInt(limit),
        offset: parseInt(offset),
      });
    } catch (err) {
      next(err);
    }
  },

  // PATCH /notifications/:id/read
  markAsRead: async (req, res, next) => {
    try {
      const { id } = req.params;
      // В реальном приложении - обновление в БД
      const notification = MOCK_NOTIFICATIONS.find(n => n.id === id);
      if (notification) {
        notification.isRead = true;
      }
      res.json({ success: true });
    } catch (err) {
      next(err);
    }
  },

  // PATCH /notifications/read-all
  markAllAsRead: async (req, res, next) => {
    try {
      // В реальном приложении - обновление в БД
      MOCK_NOTIFICATIONS.forEach(n => n.isRead = true);
      res.json({ success: true, markedCount: MOCK_NOTIFICATIONS.length });
    } catch (err) {
      next(err);
    }
  },

  // DELETE /notifications/:id
  deleteNotification: async (req, res, next) => {
    try {
      const { id } = req.params;
      // В реальном приложении - удаление из БД
      const index = MOCK_NOTIFICATIONS.findIndex(n => n.id === id);
      if (index > -1) {
        MOCK_NOTIFICATIONS.splice(index, 1);
      }
      res.json({ success: true });
    } catch (err) {
      next(err);
    }
  },
};

module.exports = { notificationsController, NOTIFICATION_ICONS };
