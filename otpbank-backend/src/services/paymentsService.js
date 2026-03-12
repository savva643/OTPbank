const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

function asAmount(v, field) {
  const n = Number(v);
  if (!Number.isFinite(n) || n <= 0) throw new ApiError(400, 'validation_error', `${field} должен быть > 0`);
  return n;
}

async function getDefaultAccountId(userId) {
  const { rows } = await pool.query(
    `SELECT id
     FROM accounts
     WHERE user_id = $1
     ORDER BY created_at ASC
     LIMIT 1`,
    [userId]
  );

  if (!rows[0]) throw new ApiError(400, 'no_accounts', 'У пользователя нет счетов');
  return rows[0].id;
}

async function assertAccountOwned(userId, accountId) {
  const { rowCount } = await pool.query(
    `SELECT 1 FROM accounts WHERE user_id = $1 AND id = $2`,
    [userId, accountId]
  );
  if (rowCount === 0) throw new ApiError(404, 'not_found', 'Счёт не найден');
}

async function getCardForAccount(userId, accountId) {
  const { rows } = await pool.query(
    `SELECT id
     FROM cards
     WHERE user_id = $1 AND account_id = $2
     ORDER BY created_at ASC
     LIMIT 1`,
    [userId, accountId]
  );
  return rows[0] ? rows[0].id : null;
}

async function createExpenseTx({ userId, accountId, cardId, amount, merchantName, category }) {
  await pool.query('BEGIN');
  try {
    const balanceRes = await pool.query(
      `SELECT balance, currency
       FROM accounts
       WHERE user_id = $1 AND id = $2
       FOR UPDATE`,
      [userId, accountId]
    );

    const acc = balanceRes.rows[0];
    if (!acc) throw new ApiError(404, 'not_found', 'Счёт не найден');

    const newBalance = Number(acc.balance) - amount;

    await pool.query(
      `UPDATE accounts
       SET balance = $3,
           updated_at = now()
       WHERE user_id = $1 AND id = $2`,
      [userId, accountId, newBalance]
    );

    const txRes = await pool.query(
      `INSERT INTO transactions (user_id, account_id, card_id, merchant_name, category, amount, currency, status, type)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'success', 'expense')
       RETURNING id, occurred_at`,
      [userId, accountId, cardId, merchantName, category, amount, acc.currency]
    );

    await pool.query('COMMIT');

    return {
      transactionId: txRes.rows[0].id,
      occurredAt: txRes.rows[0].occurred_at,
      accountId,
      newBalance: String(newBalance),
      currency: acc.currency
    };
  } catch (e) {
    try {
      await pool.query('ROLLBACK');
    } catch (_) {
      // ignore
    }
    throw e;
  }
}

const paymentsService = {
  cardTransfer: async (userId, dto) => {
    const amount = asAmount(dto.amount, 'amount');
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);
    const cardId = await getCardForAccount(userId, accountId);

    return createExpenseTx({
      userId,
      accountId,
      cardId,
      amount,
      merchantName: 'Перевод на карту',
      category: 'transfer'
    });
  },

  phoneTransfer: async (userId, dto) => {
    const amount = asAmount(dto.amount, 'amount');
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);
    const cardId = await getCardForAccount(userId, accountId);

    return createExpenseTx({
      userId,
      accountId,
      cardId,
      amount,
      merchantName: `Перевод по телефону ${dto.phone || ''}`.trim(),
      category: 'transfer'
    });
  },

  sbpTransfer: async (userId, dto) => {
    const amount = asAmount(dto.amount, 'amount');
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);
    const cardId = await getCardForAccount(userId, accountId);

    return createExpenseTx({
      userId,
      accountId,
      cardId,
      amount,
      merchantName: `СБП ${dto.phone || ''}`.trim(),
      category: 'sbp'
    });
  },

  payBills: async (userId, dto) => {
    const amount = asAmount(dto.amount, 'amount');
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);
    const cardId = await getCardForAccount(userId, accountId);

    return createExpenseTx({
      userId,
      accountId,
      cardId,
      amount,
      merchantName: 'Оплата услуг',
      category: 'bills'
    });
  },

  mobileTopUp: async (userId, dto) => {
    const amount = asAmount(dto.amount, 'amount');
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);
    const cardId = await getCardForAccount(userId, accountId);

    return createExpenseTx({
      userId,
      accountId,
      cardId,
      amount,
      merchantName: `Пополнение телефона ${dto.phone || ''}`.trim(),
      category: 'mobile'
    });
  },

  nfcStart: async (userId, dto) => {
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);

    return {
      sessionId: `nfc_${Date.now()}`,
      accountId
    };
  },

  nfcConfirm: async (userId, dto) => {
    const amount = asAmount(dto.amount, 'amount');
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);
    const cardId = await getCardForAccount(userId, accountId);

    return createExpenseTx({
      userId,
      accountId,
      cardId,
      amount,
      merchantName: 'NFC оплата',
      category: 'nfc'
    });
  },

  qrScan: async (userId, dto) => {
    const qr = String(dto.qr || dto.data || '').trim();

    return {
      merchant: 'QR Merchant',
      amount: dto.amount !== undefined ? String(dto.amount) : null,
      invoiceId: qr ? `inv_${qr.slice(0, 12)}` : `inv_${Date.now()}`
    };
  },

  qrPay: async (userId, dto) => {
    const amount = asAmount(dto.amount, 'amount');
    const accountId = dto.accountId || (await getDefaultAccountId(userId));
    await assertAccountOwned(userId, accountId);
    const cardId = await getCardForAccount(userId, accountId);

    return createExpenseTx({
      userId,
      accountId,
      cardId,
      amount,
      merchantName: dto.merchant || 'QR оплата',
      category: 'qr'
    });
  }
};

module.exports = { paymentsService };
