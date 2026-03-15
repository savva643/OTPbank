const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const userService = {
  getProfile: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, name, phone, email, avatar_url
             , full_name
             , first_name
             , last_name
             , middle_name
       FROM users
       WHERE id = $1
       LIMIT 1`,
      [userId]
    );

    const user = rows[0];
    if (!user) throw new ApiError(404, 'not_found', 'Пользователь не найден');

    return {
      id: user.id,
      name: user.name,
      fullName: user.full_name,
      firstName: user.first_name,
      lastName: user.last_name,
      middleName: user.middle_name,
      phone: user.phone,
      email: user.email,
      avatarUrl: user.avatar_url
    };
  },

  updateProfile: async (userId, dto) => {
    const name = dto.name !== undefined ? String(dto.name).trim() : null;
    const phone = dto.phone !== undefined ? (dto.phone ? String(dto.phone).trim() : null) : null;
    const email = dto.email !== undefined ? (dto.email ? String(dto.email).trim().toLowerCase() : null) : null;

    if (name !== null && !name) throw new ApiError(400, 'validation_error', 'name не может быть пустым');

    try {
      const { rows } = await pool.query(
        `UPDATE users
         SET name = COALESCE($2, name),
             phone = COALESCE($3, phone),
             email = COALESCE($4, email),
             updated_at = now()
         WHERE id = $1
         RETURNING id, name, phone, email, avatar_url`,
        [userId, name, phone, email]
      );

      const u = rows[0];
      if (!u) throw new ApiError(404, 'not_found', 'Пользователь не найден');

      return {
        id: u.id,
        name: u.name,
        phone: u.phone,
        email: u.email,
        avatarUrl: u.avatar_url
      };
    } catch (e) {
      if (e && e.code === '23505') throw new ApiError(409, 'conflict', 'Телефон или email уже используется');
      throw e;
    }
  },

  updateAvatar: async (userId, dto) => {
    const avatarUrl = String(dto.avatarUrl || dto.avatar_url || '').trim();
    if (!avatarUrl) throw new ApiError(400, 'validation_error', 'avatarUrl обязателен');

    const { rows } = await pool.query(
      `UPDATE users
       SET avatar_url = $2,
           updated_at = now()
       WHERE id = $1
       RETURNING id, name, phone, email, avatar_url`,
      [userId, avatarUrl]
    );

    const u = rows[0];
    if (!u) throw new ApiError(404, 'not_found', 'Пользователь не найден');

    return {
      id: u.id,
      name: u.name,
      phone: u.phone,
      email: u.email,
      avatarUrl: u.avatar_url
    };
  }
};

module.exports = { userService };
