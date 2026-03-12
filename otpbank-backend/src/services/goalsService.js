const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

function toProgressPercent(saved, target) {
  const s = Number(saved || 0);
  const t = Number(target || 0);
  if (!Number.isFinite(s) || !Number.isFinite(t) || t <= 0) return 0;
  const p = (s / t) * 100;
  return Math.max(0, Math.min(100, Math.round(p)));
}

const goalsService = {
  list: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, name, icon, target_amount, saved_amount, currency, deadline
       FROM goals
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );

    return rows.map((g) => ({
      id: g.id,
      name: g.name,
      icon: g.icon,
      targetAmount: String(g.target_amount),
      savedAmount: String(g.saved_amount),
      currency: g.currency,
      deadline: g.deadline,
      progressPercent: toProgressPercent(g.saved_amount, g.target_amount)
    }));
  },

  create: async (userId, dto) => {
    const name = String(dto.name || dto.goalName || '').trim();
    const icon = dto.icon !== undefined && dto.icon !== null ? String(dto.icon).trim() : null;
    const targetAmount = Number(dto.targetAmount ?? dto.target_amount ?? dto.target);
    const savedAmount = dto.savedAmount !== undefined ? Number(dto.savedAmount) : 0;
    const currencyRaw = dto.currency ?? dto.ccy;
    const currency = currencyRaw ? String(currencyRaw).trim().toUpperCase() : 'RUB';
    const deadline = dto.deadline ? String(dto.deadline) : null;

    if (!name) throw new ApiError(400, 'validation_error', 'name обязателен');
    if (!Number.isFinite(targetAmount) || targetAmount <= 0) {
      throw new ApiError(400, 'validation_error', 'targetAmount должен быть > 0');
    }
    if (!Number.isFinite(savedAmount) || savedAmount < 0) {
      throw new ApiError(400, 'validation_error', 'savedAmount должен быть >= 0');
    }
    if (icon !== null && !icon) throw new ApiError(400, 'validation_error', 'icon не может быть пустым');
    if (!/^[A-Z]{3}$/.test(currency)) throw new ApiError(400, 'validation_error', 'currency должна быть в формате ISO (например RUB)');

    const { rows } = await pool.query(
      `INSERT INTO goals (user_id, name, icon, target_amount, saved_amount, currency, deadline)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, name, icon, target_amount, saved_amount, currency, deadline`,
      [userId, name, icon, targetAmount, savedAmount, currency, deadline]
    );

    const g = rows[0];
    return {
      id: g.id,
      name: g.name,
      icon: g.icon,
      targetAmount: String(g.target_amount),
      savedAmount: String(g.saved_amount),
      currency: g.currency,
      deadline: g.deadline,
      progressPercent: toProgressPercent(g.saved_amount, g.target_amount)
    };
  },

  update: async (userId, goalId, dto) => {
    const name = dto.name !== undefined ? String(dto.name).trim() : null;
    const icon = dto.icon !== undefined ? (dto.icon === null ? null : String(dto.icon).trim()) : null;
    const targetAmount = dto.targetAmount !== undefined ? Number(dto.targetAmount) : null;
    const savedAmount = dto.savedAmount !== undefined ? Number(dto.savedAmount) : null;
    const currency = dto.currency !== undefined ? String(dto.currency).trim().toUpperCase() : null;
    const deadlineProvided = dto.deadline !== undefined;
    const deadlineValue = deadlineProvided ? (dto.deadline ? String(dto.deadline) : null) : null;

    if (name !== null && !name) throw new ApiError(400, 'validation_error', 'name не может быть пустым');
    if (icon !== null && !icon) throw new ApiError(400, 'validation_error', 'icon не может быть пустым');
    if (targetAmount !== null && (!Number.isFinite(targetAmount) || targetAmount <= 0)) {
      throw new ApiError(400, 'validation_error', 'targetAmount должен быть > 0');
    }
    if (savedAmount !== null && (!Number.isFinite(savedAmount) || savedAmount < 0)) {
      throw new ApiError(400, 'validation_error', 'savedAmount должен быть >= 0');
    }
    if (currency !== null && !/^[A-Z]{3}$/.test(currency)) {
      throw new ApiError(400, 'validation_error', 'currency должна быть в формате ISO (например RUB)');
    }

    const { rows } = await pool.query(
      `UPDATE goals
       SET name = COALESCE($3, name),
           icon = COALESCE($4, icon),
           target_amount = COALESCE($5, target_amount),
           saved_amount = COALESCE($6, saved_amount),
           currency = COALESCE($7, currency),
           deadline = CASE WHEN $8 THEN $9::date ELSE deadline END,
           updated_at = now()
       WHERE user_id = $1 AND id = $2
       RETURNING id, name, icon, target_amount, saved_amount, currency, deadline`,
      [userId, goalId, name, icon, targetAmount, savedAmount, currency, deadlineProvided, deadlineValue]
    );

    const g = rows[0];
    if (!g) throw new ApiError(404, 'not_found', 'Цель не найдена');

    return {
      id: g.id,
      name: g.name,
      icon: g.icon,
      targetAmount: String(g.target_amount),
      savedAmount: String(g.saved_amount),
      currency: g.currency,
      deadline: g.deadline,
      progressPercent: toProgressPercent(g.saved_amount, g.target_amount)
    };
  },

  remove: async (userId, goalId) => {
    const res = await pool.query(
      `DELETE FROM goals
       WHERE user_id = $1 AND id = $2`,
      [userId, goalId]
    );

    if (res.rowCount === 0) throw new ApiError(404, 'not_found', 'Цель не найдена');
  }
};

module.exports = { goalsService };
