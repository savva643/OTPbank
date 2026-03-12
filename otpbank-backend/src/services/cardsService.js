const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const cardsService = {
  listByUser: async (userId) => {
    const { rows } = await pool.query(
      `SELECT c.id, c.account_id, c.product_type, c.masked_pan, c.status,
              a.balance, a.currency
       FROM cards c
       JOIN accounts a ON a.id = c.account_id
       WHERE c.user_id = $1
       ORDER BY c.created_at DESC`,
      [userId]
    );

    return rows.map((r) => ({
      id: r.id,
      accountId: r.account_id,
      balance: String(r.balance),
      currency: r.currency,
      maskedCardNumber: r.masked_pan,
      productType: r.product_type,
      status: r.status
    }));
  },

  getById: async (userId, cardId) => {
    const { rows } = await pool.query(
      `SELECT c.id, c.account_id, c.product_type, c.masked_pan, c.status,
              c.limit_per_tx, c.limit_per_day,
              a.balance, a.currency
       FROM cards c
       JOIN accounts a ON a.id = c.account_id
       WHERE c.user_id = $1 AND c.id = $2
       LIMIT 1`,
      [userId, cardId]
    );

    const r = rows[0];
    if (!r) throw new ApiError(404, 'not_found', 'Карта не найдена');

    return {
      id: r.id,
      accountId: r.account_id,
      productType: r.product_type,
      maskedCardNumber: r.masked_pan,
      status: r.status,
      balance: String(r.balance),
      currency: r.currency,
      limits: {
        perTransaction: r.limit_per_tx !== null ? String(r.limit_per_tx) : null,
        perDay: r.limit_per_day !== null ? String(r.limit_per_day) : null
      }
    };
  },

  setStatus: async (userId, cardId, status) => {
    if (status !== 'active' && status !== 'frozen') {
      throw new ApiError(400, 'validation_error', 'Некорректный статус карты');
    }

    const { rows } = await pool.query(
      `UPDATE cards
       SET status = $3, updated_at = now()
       WHERE user_id = $1 AND id = $2
       RETURNING id, account_id, product_type, masked_pan, status, limit_per_tx, limit_per_day`,
      [userId, cardId, status]
    );

    const c = rows[0];
    if (!c) throw new ApiError(404, 'not_found', 'Карта не найдена');

    return {
      id: c.id,
      accountId: c.account_id,
      productType: c.product_type,
      maskedCardNumber: c.masked_pan,
      status: c.status,
      limits: {
        perTransaction: c.limit_per_tx !== null ? String(c.limit_per_tx) : null,
        perDay: c.limit_per_day !== null ? String(c.limit_per_day) : null
      }
    };
  },

  updateLimits: async (userId, cardId, dto) => {
    const perTransaction = dto && dto.perTransaction !== undefined ? Number(dto.perTransaction) : null;
    const perDay = dto && dto.perDay !== undefined ? Number(dto.perDay) : null;

    if (perTransaction !== null && (!Number.isFinite(perTransaction) || perTransaction < 0)) {
      throw new ApiError(400, 'validation_error', 'Некорректный лимит perTransaction');
    }

    if (perDay !== null && (!Number.isFinite(perDay) || perDay < 0)) {
      throw new ApiError(400, 'validation_error', 'Некорректный лимит perDay');
    }

    const { rows } = await pool.query(
      `UPDATE cards
       SET limit_per_tx = COALESCE($3, limit_per_tx),
           limit_per_day = COALESCE($4, limit_per_day),
           updated_at = now()
       WHERE user_id = $1 AND id = $2
       RETURNING id, account_id, product_type, masked_pan, status, limit_per_tx, limit_per_day`,
      [userId, cardId, perTransaction, perDay]
    );

    const c = rows[0];
    if (!c) throw new ApiError(404, 'not_found', 'Карта не найдена');

    return {
      id: c.id,
      accountId: c.account_id,
      productType: c.product_type,
      maskedCardNumber: c.masked_pan,
      status: c.status,
      limits: {
        perTransaction: c.limit_per_tx !== null ? String(c.limit_per_tx) : null,
        perDay: c.limit_per_day !== null ? String(c.limit_per_day) : null
      }
    };
  }
};

module.exports = { cardsService };
