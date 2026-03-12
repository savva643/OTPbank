const { pool } = require('../db/pool');

const widgetsService = {
  getCashback: async (userId) => {
    const { rows } = await pool.query(
      `SELECT balance
       FROM cashback
       WHERE user_id = $1
       LIMIT 1`,
      [userId]
    );

    const bal = rows[0] ? rows[0].balance : 0;
    return { balance: String(bal) };
  },

  getBonuses: async (userId) => {
    const { rows } = await pool.query(
      `SELECT points
       FROM bonuses
       WHERE user_id = $1
       LIMIT 1`,
      [userId]
    );

    const points = rows[0] ? rows[0].points : 0;
    return { points };
  }
};

module.exports = { widgetsService };
