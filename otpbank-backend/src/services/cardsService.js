const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');
const bcrypt = require('bcryptjs');
const { env } = require('../config/env');

function generateMaskedPan() {
  const last4 = String(Math.floor(1000 + Math.random() * 9000));
  return `**** **** **** ${last4}`;
}

function generateCvc() {
  return String(Math.floor(100 + Math.random() * 900));
}

function generatePan() {
  let pan = '';
  for (let i = 0; i < 16; i++) {
    pan += String(Math.floor(Math.random() * 10));
  }
  return pan;
}

function colorsForProductType(productType) {
  const t = String(productType || '').trim().toLowerCase();
  if (t === 'travel') return { bg1: '#FF7D32', bg2: '#9E6FC3' };
  if (t === 'credit' || t === 'credit_card') return { bg1: '#9E6FC3', bg2: '#4F46E5' };
  return { bg1: '#0F172A', bg2: '#1E293B' };
}

const cardsService = {
  listByUser: async (userId) => {
    const { rows } = await pool.query(
      `SELECT c.id, c.account_id, c.product_type, c.label, c.card_type_name, c.masked_pan, c.status,
              c.bg_color1, c.bg_color2, c.is_main,
              a.title as account_title,
              a.balance, a.currency
       FROM cards c
       JOIN accounts a ON a.id = c.account_id
       WHERE c.user_id = $1
       ORDER BY c.is_main DESC, c.created_at DESC`,
      [userId]
    );

    return rows.map((r) => ({
      id: r.id,
      accountId: r.account_id,
      accountTitle: r.account_title,
      cardTypeName: r.card_type_name,
      balance: String(r.balance),
      currency: r.currency,
      maskedCardNumber: r.masked_pan,
      productType: r.product_type,
      label: r.label,
      bgColor1: r.bg_color1,
      bgColor2: r.bg_color2,
      status: r.status,
      isMain: r.is_main === true
    }));
  },

  issueCard: async (userId, dto) => {
    const accountId = dto && dto.accountId !== undefined ? String(dto.accountId).trim() : '';
    const productType = dto && dto.productType !== undefined ? String(dto.productType).trim() : '';
    const label = dto && dto.label !== undefined ? String(dto.label).trim() : null;

    if (!accountId) throw new ApiError(400, 'validation_error', 'accountId обязателен');
    if (!productType) throw new ApiError(400, 'validation_error', 'productType обязателен');

    const accRes = await pool.query(
      `SELECT id
       FROM accounts
       WHERE user_id = $1 AND id = $2
       LIMIT 1`,
      [userId, accountId]
    );
    if (!accRes.rows[0]) throw new ApiError(404, 'not_found', 'Счёт не найден');

    // Проверяем, есть ли уже карты для этого счёта
    const existingCardsRes = await pool.query(
      `SELECT COUNT(*) as count FROM cards WHERE account_id = $1`,
      [accountId]
    );
    const isMain = existingCardsRes.rows[0].count === '0';

    const maskedPan = generateMaskedPan();
    const pan = generatePan();
    const cvc = generateCvc();
    const colors = colorsForProductType(productType);

    // Определяем тип карты для отображения (понятные названия)
    const cardTypeName = (() => {
      if (productType === 'debit') return 'Дебетовая карта';
      if (productType === 'credit' || productType === 'credit_card') return 'Кредитная карта';
      if (productType === 'travel') return 'Карта путешествий';
      if (productType === 'kids') return 'Детская карта';
      return 'Карта МИР';
    })();

    const { rows } = await pool.query(
      `INSERT INTO cards (account_id, user_id, product_type, card_type_name, label, masked_pan, pan, cvc, status, bg_color1, bg_color2, is_main)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'active', $9, $10, $11)
       RETURNING id, account_id, product_type, card_type_name, label, masked_pan, cvc, bg_color1, bg_color2, status, is_main`,
      [accountId, userId, productType, cardTypeName, label, maskedPan, pan, cvc, colors.bg1, colors.bg2, isMain]
    );

    const c = rows[0];
    return {
      id: c.id,
      accountId: c.account_id,
      productType: c.product_type,
      cardTypeName: c.card_type_name,
      label: c.label,
      maskedCardNumber: c.masked_pan,
      bgColor1: c.bg_color1,
      bgColor2: c.bg_color2,
      status: c.status,
      isMain: c.is_main === true
    };
  },

  getRequisites: async (userId, cardId) => {
    const { rows } = await pool.query(
      `SELECT c.id, c.cvc, c.pan
       FROM cards c
       WHERE c.user_id = $1 AND c.id = $2
       LIMIT 1`,
      [userId, cardId]
    );

    const r = rows[0];
    if (!r) throw new ApiError(404, 'not_found', 'Карта не найдена');

    const result = {
      id: r.id,
      cvc: r.cvc
    };

    if (env.exposeFullPan) {
      result.fullPan = r.pan;
    }

    return result;
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
    if (status !== 'active' && status !== 'frozen' && status !== 'blocked') {
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
  ,

  setPin: async (userId, cardId, dto) => {
    const pin = dto && dto.pin !== undefined ? String(dto.pin).trim() : '';
    if (!/^\d{4}$/.test(pin)) {
      throw new ApiError(400, 'validation_error', 'PIN должен состоять из 4 цифр');
    }

    const pinHash = await bcrypt.hash(pin, 10);

    const { rows } = await pool.query(
      `UPDATE cards
       SET pin_hash = $3, updated_at = now()
       WHERE user_id = $1 AND id = $2
       RETURNING id, account_id, product_type, masked_pan, status, limit_per_tx, limit_per_day`,
      [userId, cardId, pinHash]
    );

    const c = rows[0];
    if (!c) throw new ApiError(404, 'not_found', 'Карта не найдена');

    return {
      ok: true,
      card: {
        id: c.id,
        accountId: c.account_id,
        productType: c.product_type,
        maskedCardNumber: c.masked_pan,
        status: c.status,
        limits: {
          perTransaction: c.limit_per_tx !== null ? String(c.limit_per_tx) : null,
          perDay: c.limit_per_day !== null ? String(c.limit_per_day) : null
        }
      }
    };
  }
};

module.exports = { cardsService };
