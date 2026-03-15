const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

function genAccountNumber(id, userId) {
  const crypto = require('crypto');
  const a = crypto.createHash('md5').update(String(id)).digest('hex');
  const b = crypto.createHash('md5').update(String(userId)).digest('hex');
  const raw = (a + b).replace(/[a-f]/g, (ch) => {
    const map = { a: '1', b: '2', c: '3', d: '4', e: '5', f: '6' };
    return map[ch] || ch;
  });
  return raw.slice(0, 20);
}

const accountsService = {
  listByUser: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, title, balance, currency, type
       FROM accounts
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );

    return rows.map((r) => ({
      id: r.id,
      title: r.title,
      balance: String(r.balance),
      currency: r.currency,
      productType: r.type
    }));
  },

  getById: async (userId, accountId) => {
    const { rows } = await pool.query(
      `SELECT id, title, balance, currency, type, account_number, bic, bank_name, corr_account
       FROM accounts
       WHERE user_id = $1 AND id = $2
       LIMIT 1`,
      [userId, accountId]
    );

    const a = rows[0];
    if (!a) {
      const { ApiError } = require('../utils/apiError');
      throw new ApiError(404, 'not_found', 'Счёт не найден');
    }

    return {
      id: a.id,
      title: a.title,
      balance: String(a.balance),
      currency: a.currency,
      productType: a.type,
      requisites: {
        accountNumber: a.account_number,
        bic: a.bic,
        bankName: a.bank_name,
        corrAccount: a.corr_account,
      },
    };
  }
  ,

  create: async (userId, dto) => {
    const typeRaw = dto.type ?? dto.productType ?? dto.accountType;
    const type = typeRaw ? String(typeRaw).trim().toLowerCase() : 'debit';
    if (!['debit', 'credit', 'savings'].includes(type)) {
      throw new ApiError(400, 'validation_error', 'type должен быть одним из: debit, credit, savings');
    }

    const currencyRaw = dto.currency ?? dto.ccy;
    const currency = currencyRaw ? String(currencyRaw).trim().toUpperCase() : 'RUB';
    if (!/^[A-Z]{3}$/.test(currency)) {
      throw new ApiError(400, 'validation_error', 'currency должна быть в формате ISO (например RUB)');
    }

    const titleRaw = dto.title ?? dto.name;
    const title = titleRaw ? String(titleRaw).trim() : null;
    if (title !== null && !title) throw new ApiError(400, 'validation_error', 'title не может быть пустым');

    const defaultTitle = type === 'savings' ? 'Накопительный счёт' : type === 'credit' ? 'Кредитный счёт' : 'Счёт';

    const { rows } = await pool.query(
      `INSERT INTO accounts (user_id, type, title, balance, currency, bank_name, bic, corr_account)
       VALUES ($1, $2::account_type, $3, 0, $4, 'OTPbank', '044525225', '30101810400000000225')
       RETURNING id, title, balance, currency, type`,
      [userId, type, title || defaultTitle, currency]
    );

    const a = rows[0];
    const accountNumber = genAccountNumber(a.id, userId);
    await pool.query(
      `UPDATE accounts
       SET account_number = COALESCE(NULLIF(account_number, ''), $3)
       WHERE user_id = $1 AND id = $2`,
      [userId, a.id, accountNumber]
    );

    return {
      id: a.id,
      title: a.title,
      balance: String(a.balance),
      currency: a.currency,
      productType: a.type,
    };
  }
};

module.exports = { accountsService };
