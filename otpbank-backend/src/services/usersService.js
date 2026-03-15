const { pool } = require('../db/pool');

async function findByPhone(phone) {
  const sql = `
    SELECT id, first_name, last_name, middle_name, phone
    FROM users
    WHERE phone = $1
    LIMIT 1
  `;
  const result = await pool.query(sql, [phone]);
  return result.rows[0] || null;
}

module.exports = {
  findByPhone,
};
