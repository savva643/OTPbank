const { pool } = require('../db/pool');

/**
 * Service for managing payment categories and services/organizations
 * Now uses real database tables instead of mock data
 */

async function getCategories() {
  try {
    const { rows } = await pool.query(
      `SELECT id, code, name, icon_name as icon, background_color as color
       FROM payment_categories 
       WHERE is_active = true 
       ORDER BY display_order, name`
    );
    return rows;
  } catch (error) {
    console.error('Error fetching categories:', error);
    // Fallback to empty array if DB error
    return [];
  }
}

async function getServicesByCategory(categoryCode) {
  try {
    const { rows } = await pool.query(
      `SELECT ps.code as id,
              ps.name,
              ps.description,
              pc.code as "categoryId",
              ps.icon_color as "iconColor",
              ps.bg_color as "bgColor",
              ps.image_url as "imageUrl",
              pc.icon_name as icon
       FROM payment_services ps
       JOIN payment_categories pc ON ps.category_id = pc.id
       WHERE pc.code = $1 AND ps.is_active = true
       ORDER BY ps.is_popular DESC, ps.display_order, ps.name`,
      [categoryCode]
    );
    return rows;
  } catch (error) {
    console.error('Error fetching services by category:', error);
    return [];
  }
}

async function searchServices(query) {
  try {
    const lowerQuery = `%${query.toLowerCase()}%`;
    const { rows } = await pool.query(
      `SELECT ps.code as id,
              ps.name,
              ps.description,
              pc.code as "categoryId",
              ps.icon_color as "iconColor",
              ps.bg_color as "bgColor",
              ps.image_url as "imageUrl",
              pc.icon_name as icon
       FROM payment_services ps
       JOIN payment_categories pc ON ps.category_id = pc.id
       WHERE ps.is_active = true 
         AND (LOWER(ps.name) LIKE $1 OR LOWER(ps.description) LIKE $1)
       ORDER BY ps.is_popular DESC, ps.name`,
      [lowerQuery]
    );
    return rows;
  } catch (error) {
    console.error('Error searching services:', error);
    return [];
  }
}

module.exports = {
  categoriesService: {
    getCategories,
    getServicesByCategory,
    searchServices,
  },
};
