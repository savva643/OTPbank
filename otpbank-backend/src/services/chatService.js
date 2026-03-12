const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');
const { sendToUser } = require('../realtime/chatHub');

const chatService = {
  listMessages: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, sender, message, created_at
       FROM chat_messages
       WHERE user_id = $1
       ORDER BY created_at ASC
       LIMIT 200`,
      [userId]
    );

    return rows.map((m) => ({
      id: m.id,
      sender: m.sender,
      message: m.message,
      createdAt: m.created_at
    }));
  },

  sendMessage: async (userId, dto) => {
    const message = String(dto.message || '').trim();
    if (!message) throw new ApiError(400, 'validation_error', 'message обязателен');

    const { rows } = await pool.query(
      `INSERT INTO chat_messages (user_id, sender, message)
       VALUES ($1, 'user', $2)
       RETURNING id, sender, message, created_at`,
      [userId, message]
    );

    const m = rows[0];

    const payload = {
      id: m.id,
      sender: m.sender,
      message: m.message,
      createdAt: m.created_at
    };

    sendToUser(userId, { type: 'chat.message', data: payload });

    return payload;
  }
};

module.exports = { chatService };
