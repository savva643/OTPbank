// Магазины с бонусами
const { pool } = require('../db/pool');

const STORES = [
  {
    id: 'magnit',
    name: 'Магнит',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Magnit_logo.svg/1200px-Magnit_logo.svg.png',
    color: '#C51A1A',
    cashbackPercent: 5,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 5% на продукты',
  },
  {
    id: 'pyaterochka',
    name: 'Пятёрочка',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Pyaterochka_logo.svg/2560px-Pyaterochka_logo.svg.png',
    color: '#D81B1B',
    cashbackPercent: 3,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 3% на все покупки',
  },
  {
    id: 'samokat',
    name: 'Самокат',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Samokat_logo.svg/2560px-Samokat_logo.svg.png',
    color: '#FF6B35',
    cashbackPercent: 7,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 7% на доставку',
  },
  {
    id: 'lenta',
    name: 'Лента',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Lenta_logo.svg/2560px-Lenta_logo.svg.png',
    color: '#0077C8',
    cashbackPercent: 4,
    bonusRate: '1 балл = 2 ₽',
    description: 'Кэшбэк 4% + двойные баллы',
  },
  {
    id: 'auchan',
    name: 'Ашан',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Auchan_logo.svg/2560px-Auchan_logo.svg.png',
    color: '#D81B60',
    cashbackPercent: 2,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 2% на всё',
  },
  {
    id: 'ozon',
    name: 'Ozon',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Ozon_logo.svg/2560px-Ozon_logo.svg.png',
    color: '#005BFF',
    cashbackPercent: 6,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 6% на маркетплейс',
  },
  {
    id: 'wildberries',
    name: 'Wildberries',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Wildberries_logo.svg/2560px-Wildberries_logo.svg.png',
    color: '#8B5CF6',
    cashbackPercent: 4,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 4% на fashion',
  },
  {
    id: 'yandexeda',
    name: 'Яндекс Еда',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Yandex_Eda_icon.svg/1200px-Yandex_Eda_icon.svg.png',
    color: '#FCB900',
    cashbackPercent: 8,
    bonusRate: '1 балл = 1 ₽',
    description: 'Кэшбэк 8% на еду',
  },
];

const bonusesController = {
  // GET /bonuses/stores
  getStores: async (req, res, next) => {
    try {
      try {
        const { rows } = await pool.query(
          `SELECT code, name, description, logo_url, cashback_percent
           FROM cashback_partners
           WHERE is_active = true
           ORDER BY cashback_percent DESC, name`
        );

        const items = rows.map((r) => ({
          id: r.code,
          name: r.name,
          logo: r.logo_url,
          color: '#0F172A',
          cashbackPercent: Number(r.cashback_percent ?? 0),
          bonusRate: '1 балл = 1 ₽',
          description: r.description,
        }));

        if (items.length > 0) {
          return res.json({ items, total: items.length });
        }
      } catch (_) {
        // fallback to mocked stores
      }

      res.json({ items: STORES, total: STORES.length });
    } catch (err) {
      next(err);
    }
  },

  // GET /bonuses/balance
  getBalance: async (req, res, next) => {
    try {
      const userId = req.user.id;
      // В реальном приложении здесь будет запрос к БД
      res.json({
        points: 1250,
        currency: '₽',
        equivalent: 1250,
        expiringSoon: 150,
        expiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      });
    } catch (err) {
      next(err);
    }
  },

  // GET /bonuses/transactions
  getTransactions: async (req, res, next) => {
    try {
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
    } catch (err) {
      next(err);
    }
  },
};

module.exports = { bonusesController, STORES };
