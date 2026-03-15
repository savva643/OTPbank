const express = require('express');
const { requireAuth } = require('../../middleware/auth');

const router = express.Router();

// Магазины с бонусами
const STORES = [
  {
    id: 'magnit',
    name: 'Магнит',
    logo: '/assets/stores/magnit.png',
    color: '#C51A1A',
    cashbackPercent: 5,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 5% на продукты',
  },
  {
    id: 'pyaterochka',
    name: 'Пятёрочка',
    logo: '/assets/stores/pyaterochka.png',
    color: '#D81B1B',
    cashbackPercent: 3,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 3% на все покупки',
  },
  {
    id: 'samokat',
    name: 'Самокат',
    logo: '/assets/stores/samokat.png',
    color: '#FF6B35',
    cashbackPercent: 7,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 7% на доставку',
  },
  {
    id: 'lenta',
    name: 'Лента',
    logo: '/assets/stores/lenta.png',
    color: '#0077C8',
    cashbackPercent: 4,
    bonusRate: '1 балл = 2 ₽',
    description: 'Кэшбэк 4% + двойные баллы',
  },
  {
    id: 'auchan',
    name: 'Ашан',
    logo: '/assets/stores/auchan.png',
    color: '#D81B60',
    cashbackPercent: 2,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 2% на всё',
  },
  {
    id: 'ozon',
    name: 'Ozon',
    logo: '/assets/stores/ozon.png',
    color: '#005BFF',
    cashbackPercent: 6,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 6% на маркетплейс',
  },
  {
    id: 'wildberries',
    name: 'Wildberries',
    logo: '/assets/stores/wildberries.png',
    color: '#8B5CF6',
    cashbackPercent: 4,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 4% на fashion',
  },
  {
    id: 'yandexeda',
    name: 'Яндекс Еда',
    logo: '/assets/stores/yandexeda.png',
    color: '#FCB900',
    cashbackPercent: 8,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 8% на еду',
  },
];

// GET /bonuses/stores - список магазинов с бонусами
router.get('/stores', requireAuth, (req, res) => {
  res.json({
    items: STORES,
    total: STORES.length,
  });
});

// GET /bonuses/balance - баланс бонусов пользователя
router.get('/balance', requireAuth, (req, res) => {
  // В реальном приложении здесь будет запрос к БД
  res.json({
    points: 1250,
    currency: '₽',
    equivalent: 1250,
    expiringSoon: 150,
    expiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
  });
});

// GET /bonuses/transactions - история начисления/списания
router.get('/transactions', requireAuth, (req, res) => {
  const transactions = [
    {
      id: '1',
      type: 'earn',
      storeName: 'Магнит',
      amount: 45,
      date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
      description: 'Покупка на 900 ₽',
    },
    {
      id: '2',
      type: 'earn',
      storeName: 'Самокат',
      amount: 84,
      date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
      description: 'Покупка на 1200 ₽',
    },
    {
      id: '3',
      type: 'redeem',
      storeName: 'Пятёрочка',
      amount: -100,
      date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
      description: 'Списание баллов',
    },
  ];
  
  res.json({
    items: transactions,
    total: transactions.length,
  });
});

module.exports = router;
