const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const storiesService = {
  list: async () => {
    const { rows } = await pool.query(
      `SELECT id, code, title, mini_image_url, created_at
       FROM stories
       WHERE is_active = true
       ORDER BY created_at DESC`
    );

    return rows.map((s) => ({
      id: s.id,
      code: s.code,
      title: s.title,
      miniImageUrl: s.mini_image_url,
      createdAt: s.created_at
    }));
  },

  getById: async (id) => {
    const storyId = String(id || '').trim();
    if (!storyId) throw new ApiError(400, 'validation_error', 'id обязателен');

    const { rows } = await pool.query(
      `SELECT id, code, title, mini_image_url, media_type, media_url, story_text
              , cta_label, cta_action, cta_payload
              , created_at
       FROM stories
       WHERE id = $1 AND is_active = true
       LIMIT 1`,
      [storyId]
    );

    const s = rows[0];
    if (!s) throw new ApiError(404, 'not_found', 'Сторис не найден');

    return {
      id: s.id,
      code: s.code,
      title: s.title,
      miniImageUrl: s.mini_image_url,
      mediaType: s.media_type,
      mediaUrl: s.media_url,
      storyText: s.story_text,
      ctaLabel: s.cta_label,
      ctaAction: s.cta_action,
      ctaPayload: s.cta_payload,
      createdAt: s.created_at
    };
  }
};

module.exports = { storiesService };
