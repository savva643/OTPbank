const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

function parseIntSafe(v, def) {
  const n = Number.parseInt(String(v), 10);
  return Number.isFinite(n) ? n : def;
}

const transactionsService = {
  list: async (userId, query) => {
    const limit = Math.min(100, Math.max(1, parseIntSafe(query.limit, 50)));
    const offset = Math.max(0, parseIntSafe(query.offset, 0));

    const where = ['t.user_id = $1'];
    const params = [userId];

    if (query.accountId) {
      params.push(String(query.accountId));
      where.push(`t.account_id = $${params.length}`);
    }

    if (query.cardId) {
      params.push(String(query.cardId));
      where.push(`t.card_id = $${params.length}`);
    }

    if (query.type) {
      params.push(String(query.type));
      where.push(`t.type = $${params.length}`);
    }

    if (query.status) {
      params.push(String(query.status));
      where.push(`t.status = $${params.length}`);
    }

    if (query.category) {
      params.push(String(query.category));
      where.push(`t.category = $${params.length}`);
    }

    if (query.from) {
      params.push(String(query.from));
      where.push(`t.occurred_at >= $${params.length}::timestamptz`);
    }

    if (query.to) {
      params.push(String(query.to));
      where.push(`t.occurred_at <= $${params.length}::timestamptz`);
    }

    if (query.q) {
      params.push(`%${String(query.q)}%`);
      where.push(`(t.merchant_name ILIKE $${params.length} OR t.category ILIKE $${params.length})`);
    }

    params.push(limit);
    params.push(offset);

    const sql = `
      SELECT t.id, t.merchant_name, t.category, t.amount, t.currency, t.occurred_at, t.status, t.type
      FROM transactions t
      WHERE ${where.join(' AND ')}
      ORDER BY t.occurred_at DESC
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `;

    const { rows } = await pool.query(sql, params);

    return {
      items: rows.map((t) => ({
        id: t.id,
        merchantName: t.merchant_name,
        category: t.category,
        amount: String(t.amount),
        currency: t.currency,
        date: t.occurred_at,
        status: t.status,
        type: t.type
      })),
      limit,
      offset
    };
  },

  getById: async (userId, txId) => {
    const { rows } = await pool.query(
      `SELECT id, merchant_name, category, amount, currency, occurred_at, status, type, account_id, card_id
       FROM transactions
       WHERE user_id = $1 AND id = $2
       LIMIT 1`,
      [userId, txId]
    );

    const t = rows[0];
    if (!t) throw new ApiError(404, 'not_found', 'Транзакция не найдена');

    return {
      id: t.id,
      merchantName: t.merchant_name,
      category: t.category,
      amount: String(t.amount),
      currency: t.currency,
      date: t.occurred_at,
      status: t.status,
      type: t.type,
      accountId: t.account_id,
      cardId: t.card_id
    };
  }
};

module.exports = { transactionsService };
