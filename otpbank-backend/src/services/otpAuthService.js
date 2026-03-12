const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../db/pool');
const { env } = require('../config/env');
const { ApiError } = require('../utils/apiError');
const { smsAeroService } = require('./smsAeroService');

async function assertSchemaReady() {
  const { rows } = await pool.query(`SELECT to_regclass('public.users') AS users_table;`);
  if (!rows[0] || !rows[0].users_table) {
    throw new ApiError(
      500,
      'schema_not_initialized',
      'Схема БД не инициализирована. Запусти Postgres с init SQL (docker-entrypoint-initdb.d/01_init.sql).'
    );
  }
}

function normalizePhone(phone) {
  return String(phone || '').replace(/\D/g, '');
}

function generateCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function signAccessToken(userId) {
  if (!env.jwtSecret) throw new ApiError(500, 'misconfigured', 'JWT_SECRET не задан');
  return jwt.sign({}, env.jwtSecret, { subject: userId, expiresIn: '7d' });
}

function signRegistrationToken(phone) {
  if (!env.jwtSecret) throw new ApiError(500, 'misconfigured', 'JWT_SECRET не задан');
  return jwt.sign({ type: 'registration', phone }, env.jwtSecret, { expiresIn: '15m' });
}

function generateMaskedPan() {
  const last4 = Math.floor(1000 + Math.random() * 9000);
  return `**** **** **** ${last4}`;
}

async function createDefaultUserArtifacts(tx, userId) {
  const accountRes = await tx.query(
    `INSERT INTO accounts (user_id, type, title, balance, currency)
     VALUES ($1, 'debit', 'Основной счёт', 0, 'RUB')
     RETURNING id`,
    [userId]
  );

  const accountId = accountRes.rows[0].id;

  await tx.query(
    `INSERT INTO cards (account_id, user_id, product_type, masked_pan, status, limit_per_tx, limit_per_day)
     VALUES ($1, $2, $3, $4, 'active', 50000, 200000)`,
    [accountId, userId, 'debit_card', generateMaskedPan()]
  );

  await tx.query(
    `INSERT INTO bonuses (user_id, points)
     VALUES ($1, 0)
     ON CONFLICT (user_id) DO NOTHING`,
    [userId]
  );

  await tx.query(
    `INSERT INTO cashback (user_id, balance)
     VALUES ($1, 0)
     ON CONFLICT (user_id) DO NOTHING`,
    [userId]
  );
}

const otpAuthService = {
  requestCode: async ({ phone }) => {
    await assertSchemaReady();

    const normalized = normalizePhone(phone);
    if (!normalized) throw new ApiError(400, 'validation_error', 'phone обязателен');

    const code = generateCode();
    const codeHash = await bcrypt.hash(code, 10);
    const ttlSeconds = 5 * 60;

    await pool.query('DELETE FROM auth_otp_codes WHERE phone = $1', [normalized]);

    await pool.query(
      `INSERT INTO auth_otp_codes (phone, code_hash, expires_at, attempts)
       VALUES ($1, $2, now() + ($3::int * interval '1 second'), 0)`,
      [normalized, codeHash, ttlSeconds]
    );

    await smsAeroService.sendOtp({ phone: normalized, code });

    return {
      ok: true,
      expiresInSec: ttlSeconds
    };
  },

  verifyCode: async ({ phone, code }) => {
    await assertSchemaReady();

    const normalized = normalizePhone(phone);
    const inputCode = String(code || '').trim();

    if (!normalized) throw new ApiError(400, 'validation_error', 'phone обязателен');
    if (!inputCode) throw new ApiError(400, 'validation_error', 'code обязателен');

    const { rows } = await pool.query(
      `SELECT id, code_hash, expires_at, attempts
       FROM auth_otp_codes
       WHERE phone = $1
       ORDER BY created_at DESC
       LIMIT 1`,
      [normalized]
    );

    const row = rows[0];
    if (!row) throw new ApiError(400, 'otp_invalid', 'Код не найден');

    if (new Date(row.expires_at).getTime() < Date.now()) {
      await pool.query('DELETE FROM auth_otp_codes WHERE id = $1', [row.id]);
      throw new ApiError(400, 'otp_expired', 'Код истёк');
    }

    if (Number(row.attempts || 0) >= 5) throw new ApiError(429, 'otp_locked', 'Слишком много попыток');

    const ok = await bcrypt.compare(inputCode, row.code_hash);
    if (!ok) {
      await pool.query('UPDATE auth_otp_codes SET attempts = attempts + 1 WHERE id = $1', [row.id]);
      throw new ApiError(400, 'otp_invalid', 'Неверный код');
    }

    await pool.query('DELETE FROM auth_otp_codes WHERE phone = $1', [normalized]);

    const userRes = await pool.query(
      `SELECT id, name, phone, email, avatar_url
       FROM users
       WHERE phone = $1
       LIMIT 1`,
      [normalized]
    );

    const u = userRes.rows[0];

    if (u) {
      const accessToken = signAccessToken(u.id);
      return {
        isNew: false,
        accessToken,
        user: {
          id: u.id,
          name: u.name,
          phone: u.phone,
          email: u.email,
          avatarUrl: u.avatar_url
        }
      };
    }

    return {
      isNew: true,
      registrationToken: signRegistrationToken(normalized)
    };
  },

  completeRegistration: async ({ registrationToken, fullName, email, gender, birthDate, avatarUrl }) => {
    await assertSchemaReady();

    if (!registrationToken) throw new ApiError(400, 'validation_error', 'registrationToken обязателен');
    if (!env.jwtSecret) throw new ApiError(500, 'misconfigured', 'JWT_SECRET не задан');

    let payload;
    try {
      payload = jwt.verify(String(registrationToken), env.jwtSecret);
    } catch (_) {
      throw new ApiError(401, 'unauthorized', 'registrationToken недействителен');
    }

    if (!payload || payload.type !== 'registration' || !payload.phone) {
      throw new ApiError(401, 'unauthorized', 'registrationToken недействителен');
    }

    const phone = normalizePhone(payload.phone);
    if (!phone) throw new ApiError(400, 'validation_error', 'phone обязателен');

    const safeFullName = String(fullName || '').trim();
    const safeEmail = email ? String(email).trim().toLowerCase() : null;
    const safeGender = gender ? String(gender).trim() : null;
    const safeBirthDate = birthDate ? String(birthDate).trim() : null;
    const safeAvatarUrl = avatarUrl ? String(avatarUrl).trim() : null;

    if (!safeFullName) throw new ApiError(400, 'validation_error', 'fullName обязателен');

    const randomPassword = `${Date.now()}_${Math.random()}`;
    const passwordHash = await bcrypt.hash(randomPassword, 10);

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const { rows } = await client.query(
        `INSERT INTO users (name, full_name, phone, email, gender, birth_date, avatar_url, password_hash)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING id, name, phone, email, avatar_url`,
        [
          safeFullName,
          safeFullName,
          phone,
          safeEmail,
          safeGender,
          safeBirthDate ? safeBirthDate : null,
          safeAvatarUrl,
          passwordHash
        ]
      );

      const user = rows[0];

      await createDefaultUserArtifacts(client, user.id);

      await client.query('COMMIT');

      const accessToken = signAccessToken(user.id);

      return {
        accessToken,
        user: {
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          avatarUrl: user.avatar_url
        }
      };
    } catch (e) {
      try {
        await client.query('ROLLBACK');
      } catch (_) {
        // ignore
      }

      if (e && e.code === '23505') throw new ApiError(409, 'conflict', 'Телефон или email уже используется');
      throw e;
    } finally {
      client.release();
    }
  }
};

module.exports = { otpAuthService };
