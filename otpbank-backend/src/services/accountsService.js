const { pool } = require('../db/pool');

const accountsService = {
  listByUser: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, balance, currency, type
       FROM accounts
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );

    return rows.map((r) => ({
      id: r.id,
      balance: String(r.balance),
      currency: r.currency,
      productType: r.type
    }));
  }
};

module.exports = { accountsService };
