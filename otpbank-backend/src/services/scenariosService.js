const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const scenariosService = {
  list: async () => {
    const { rows } = await pool.query(
      `SELECT id, title, description
       FROM scenarios
       ORDER BY created_at DESC`
    );

    return {
      items: rows.map((s) => ({
        id: s.id,
        title: s.title,
        description: s.description
      }))
    };
  },

  getById: async (scenarioId) => {
    const scenarioRes = await pool.query(
      `SELECT id, title, description
       FROM scenarios
       WHERE id = $1
       LIMIT 1`,
      [scenarioId]
    );

    const scenario = scenarioRes.rows[0];
    if (!scenario) throw new ApiError(404, 'not_found', 'Сценарий не найден');

    const productsRes = await pool.query(
      `SELECT p.id, p.name, p.description, p.image_url,
              c.id as category_id, c.name as category_name
       FROM scenario_products sp
       JOIN products p ON p.id = sp.product_id
       LEFT JOIN product_categories c ON c.id = p.category_id
       WHERE sp.scenario_id = $1
       ORDER BY p.created_at DESC`,
      [scenarioId]
    );

    return {
      id: scenario.id,
      title: scenario.title,
      description: scenario.description,
      products: productsRes.rows.map((p) => ({
        id: p.id,
        name: p.name,
        description: p.description,
        imageUrl: p.image_url,
        category: p.category_id ? { id: p.category_id, name: p.category_name } : null
      })),
      tools: []
    };
  }
};

module.exports = { scenariosService };
