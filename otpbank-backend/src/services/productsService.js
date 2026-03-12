const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const productsService = {
  showcase: async () => {
    const { rows } = await pool.query(
      `SELECT o.id,
              o.product_id,
              o.kicker,
              o.title,
              o.description,
              o.image_url,
              o.bg_color,
              o.border_color,
              o.cta_label,
              o.cta_color,
              o.sort_order,
              p.name as product_name,
              p.description as product_description,
              p.image_url as product_image_url,
              c.id as category_id,
              c.name as category_name
       FROM product_offers o
       JOIN products p ON p.id = o.product_id
       LEFT JOIN product_categories c ON c.id = p.category_id
       WHERE o.is_active = true
       ORDER BY o.sort_order ASC, o.created_at DESC`
    );

    return {
      items: rows.map((r) => ({
        id: r.id,
        productId: r.product_id,
        kicker: r.kicker,
        title: r.title,
        description: r.description,
        imageUrl: r.image_url,
        bgColor: r.bg_color,
        borderColor: r.border_color,
        ctaLabel: r.cta_label,
        ctaColor: r.cta_color,
        product: {
          id: r.product_id,
          name: r.product_name,
          description: r.product_description,
          imageUrl: r.product_image_url,
          category: r.category_id ? { id: r.category_id, name: r.category_name } : null
        }
      }))
    };
  },

  getByIdWithDetails: async (id) => {
    const productId = String(id || '').trim();
    if (!productId) throw new ApiError(400, 'validation_error', 'id обязателен');

    const productRes = await pool.query(
      `SELECT p.id, p.name, p.description, p.image_url,
              c.id as category_id, c.name as category_name
       FROM products p
       LEFT JOIN product_categories c ON c.id = p.category_id
       WHERE p.id = $1
       LIMIT 1`,
      [productId]
    );

    const p = productRes.rows[0];
    if (!p) throw new ApiError(404, 'not_found', 'Продукт не найден');

    const featuresRes = await pool.query(
      `SELECT id, title, description, icon, sort_order
       FROM product_features
       WHERE product_id = $1
       ORDER BY sort_order ASC, created_at ASC`,
      [productId]
    );

    const offersRes = await pool.query(
      `SELECT id, kicker, title, description, image_url, bg_color, border_color, cta_label, cta_color, sort_order
       FROM product_offers
       WHERE product_id = $1 AND is_active = true
       ORDER BY sort_order ASC, created_at DESC`,
      [productId]
    );

    return {
      id: p.id,
      name: p.name,
      description: p.description,
      imageUrl: p.image_url,
      category: p.category_id ? { id: p.category_id, name: p.category_name } : null,
      features: featuresRes.rows.map((f) => ({
        id: f.id,
        title: f.title,
        description: f.description,
        icon: f.icon,
        sortOrder: f.sort_order
      })),
      offers: offersRes.rows.map((o) => ({
        id: o.id,
        kicker: o.kicker,
        title: o.title,
        description: o.description,
        imageUrl: o.image_url,
        bgColor: o.bg_color,
        borderColor: o.border_color,
        ctaLabel: o.cta_label,
        ctaColor: o.cta_color,
        sortOrder: o.sort_order
      }))
    };
  },

  list: async () => {
    const categoriesRes = await pool.query(
      `SELECT id, name
       FROM product_categories
       ORDER BY name ASC`
    );

    const productsRes = await pool.query(
      `SELECT id, category_id, name, description, image_url
       FROM products
       ORDER BY created_at DESC`
    );

    const productsByCat = new Map();
    for (const p of productsRes.rows) {
      const key = p.category_id;
      if (!productsByCat.has(key)) productsByCat.set(key, []);
      productsByCat.get(key).push({
        id: p.id,
        name: p.name,
        description: p.description,
        imageUrl: p.image_url
      });
    }

    const items = categoriesRes.rows.map((c) => ({
      id: c.id,
      name: c.name,
      offers: productsByCat.get(c.id) || []
    }));

    return { items };
  },

  getByCategory: async (categoryId) => {
    const catRes = await pool.query(
      `SELECT id, name
       FROM product_categories
       WHERE id = $1
       LIMIT 1`,
      [categoryId]
    );

    const category = catRes.rows[0];
    if (!category) throw new ApiError(404, 'not_found', 'Категория не найдена');

    const { rows } = await pool.query(
      `SELECT id, name, description, image_url
       FROM products
       WHERE category_id = $1
       ORDER BY created_at DESC`,
      [categoryId]
    );

    return {
      category: { id: category.id, name: category.name },
      offers: rows.map((p) => ({
        id: p.id,
        name: p.name,
        description: p.description,
        imageUrl: p.image_url
      }))
    };
  },

  getRecommended: async (userId) => {
    const { rows } = await pool.query(
      `SELECT p.id, p.name, p.description, p.image_url,
              c.id as category_id, c.name as category_name
       FROM products p
       LEFT JOIN product_categories c ON c.id = p.category_id
       ORDER BY p.created_at DESC
       LIMIT 1`
    );

    const p = rows[0];
    if (!p) {
      return {
        id: null,
        title: 'Рекомендаций пока нет',
        description: null,
        category: null
      };
    }

    return {
      id: p.id,
      title: p.name,
      description: p.description,
      category: p.category_id
        ? { id: p.category_id, name: p.category_name }
        : null
    };
  }
};

module.exports = { productsService };
