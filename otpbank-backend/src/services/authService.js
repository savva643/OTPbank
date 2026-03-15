const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../db/pool');
const { env } = require('../config/env');
const { ApiError } = require('../utils/apiError');

async function assertSchemaReady() {
  const { rows } = await pool.query(
    `SELECT to_regclass('public.users') AS users_table;`
  );

  if (!rows[0] || !rows[0].users_table) {
    throw new ApiError(
      500,
      'schema_not_initialized',
      'Схема БД не инициализирована. Запусти Postgres с init SQL (docker-entrypoint-initdb.d/01_init.sql).'
    );
  }
}

function generateMaskedPan() {
  const last4 = Math.floor(1000 + Math.random() * 9000);
  return `**** **** **** ${last4}`;
}

function generateCvc() {
  return String(Math.floor(100 + Math.random() * 900));
}

function signAccessToken(userId) {
  if (!env.jwtSecret) throw new ApiError(500, 'misconfigured', 'JWT_SECRET не задан');
  return jwt.sign({}, env.jwtSecret, { subject: userId, expiresIn: '7d' });
}

const authService = {
  register: async (dto) => {
    await assertSchemaReady();

    const name = String(dto.name || '').trim();
    const phone = dto.phone ? String(dto.phone).trim() : null;
    const email = dto.email ? String(dto.email).trim().toLowerCase() : null;
    const password = String(dto.password || '');

    if (!name) throw new ApiError(400, 'validation_error', 'name обязателен');
    if (!password || password.length < 4) throw new ApiError(400, 'validation_error', 'password слишком короткий');

    const passwordHash = await bcrypt.hash(password, 10);

    try {
      await pool.query('BEGIN');

      const { rows } = await pool.query(
        `INSERT INTO users (name, phone, email, password_hash)
         VALUES ($1, $2, $3, $4)
         RETURNING id, name, phone, email, avatar_url`,
        [name, phone, email, passwordHash]
      );

      const user = rows[0];

      const accountRes = await pool.query(
        `INSERT INTO accounts (user_id, type, title, balance, currency)
         VALUES ($1, 'debit', 'Основной счёт', 0, 'RUB')
         RETURNING id`,
        [user.id]
      );

      const accountId = accountRes.rows[0].id;

      await pool.query(
        `INSERT INTO cards (account_id, user_id, product_type, masked_pan, cvc, status, limit_per_tx, limit_per_day)
         VALUES ($1, $2, $3, $4, $5, 'active', 50000, 200000)`,
        [accountId, user.id, 'debit_card', generateMaskedPan(), generateCvc()]
      );

      await pool.query(
        `INSERT INTO bonuses (user_id, points)
         VALUES ($1, 0)
         ON CONFLICT (user_id) DO NOTHING`,
        [user.id]
      );

      await pool.query(
        `INSERT INTO cashback (user_id, balance)
         VALUES ($1, 0)
         ON CONFLICT (user_id) DO NOTHING`,
        [user.id]
      );

      await pool.query('COMMIT');

      const accessToken = signAccessToken(user.id);

      return { accessToken, user };
    } catch (e) {
      try {
        await pool.query('ROLLBACK');
      } catch (_) {
        // ignore
      }

      if (e && e.code === '23505') throw new ApiError(409, 'conflict', 'Пользователь уже существует');
      throw e;
    }
  },

  login: async (dto) => {
    await assertSchemaReady();

    const login = String(dto.login || '').trim();
    const password = String(dto.password || '');

    if (!login) throw new ApiError(400, 'validation_error', 'login обязателен');
    if (!password) throw new ApiError(400, 'validation_error', 'password обязателен');

    const { rows } = await pool.query(
      `SELECT id, name, phone, email, avatar_url, password_hash
       FROM users
       WHERE phone = $1 OR email = $1
       LIMIT 1`,
      [login]
    );

    const row = rows[0];
    if (!row) throw new ApiError(401, 'unauthorized', 'Неверные учетные данные');

    const ok = await bcrypt.compare(password, row.password_hash);
    if (!ok) throw new ApiError(401, 'unauthorized', 'Неверные учетные данные');

    const accessToken = signAccessToken(row.id);

    return {
      accessToken,
      user: {
        id: row.id,
        name: row.name,
        phone: row.phone,
        email: row.email,
        avatarUrl: row.avatar_url
      }
    };
  }
};

module.exports = { authService };
