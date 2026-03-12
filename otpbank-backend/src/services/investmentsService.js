const { pool } = require('../db/pool');

const investmentsService = {
  listAssets: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, asset_type, ticker, name, quantity, avg_price, currency
       FROM investments_assets
       WHERE user_id = $1
       ORDER BY updated_at DESC`,
      [userId]
    );

    return rows.map((a) => ({
      id: a.id,
      type: a.asset_type,
      ticker: a.ticker,
      name: a.name,
      quantity: String(a.quantity),
      avgPrice: String(a.avg_price),
      currency: a.currency
    }));
  },

  getPortfolio: async (userId) => {
    const { rows } = await pool.query(
      `SELECT COALESCE(SUM(quantity * avg_price), 0) AS value
       FROM investments_assets
       WHERE user_id = $1`,
      [userId]
    );

    const value = rows[0] ? rows[0].value : 0;

    return {
      value: String(value),
      currency: 'RUB',
      dailyChange: '0',
      dailyChangePercent: 0
    };
  }
};

module.exports = { investmentsService };
