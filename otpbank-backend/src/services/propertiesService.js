const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const propertiesService = {
  // Получить все объекты недвижимости пользователя
  listByUser: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, type, name, address, area_sqm, monthly_payment, 
              cashback_percent, has_mortgage, mortgage_amount, mortgage_bank,
              created_at
       FROM user_properties
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );
    return rows.map((r) => ({
      id: r.id,
      type: r.type,
      name: r.name,
      address: r.address,
      areaSqm: r.area_sqm,
      monthlyPayment: r.monthly_payment,
      cashbackPercent: r.cashback_percent,
      hasMortgage: r.has_mortgage,
      mortgageAmount: r.mortgage_amount,
      mortgageBank: r.mortgage_bank,
      createdAt: r.created_at
    }));
  },

  // Создать новый объект недвижимости
  create: async (userId, dto) => {
    const type = dto?.type?.toString().trim() || '';
    const name = dto?.name?.toString().trim() || '';
    const address = dto?.address?.toString().trim() || null;
    const areaSqm = dto?.areaSqm !== undefined ? Number(dto.areaSqm) : null;
    const monthlyPayment = dto?.monthlyPayment !== undefined ? Number(dto.monthlyPayment) : null;
    const cashbackPercent = dto?.cashbackPercent !== undefined ? Number(dto.cashbackPercent) : 0;
    const hasMortgage = dto?.hasMortgage === true;
    const mortgageAmount = dto?.mortgageAmount !== undefined ? Number(dto.mortgageAmount) : null;
    const mortgageBank = dto?.mortgageBank?.toString().trim() || null;

    if (!type || !['house', 'apartment', 'country_house'].includes(type)) {
      throw new ApiError(400, 'validation_error', 'Некорректный тип недвижимости');
    }
    if (!name) {
      throw new ApiError(400, 'validation_error', 'Название обязательно');
    }

    const { rows } = await pool.query(
      `INSERT INTO user_properties (user_id, type, name, address, area_sqm, monthly_payment,
                                    cashback_percent, has_mortgage, mortgage_amount, mortgage_bank)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING id, type, name, address, area_sqm, monthly_payment, 
                 cashback_percent, has_mortgage, mortgage_amount, mortgage_bank`,
      [userId, type, name, address, areaSqm, monthlyPayment, cashbackPercent, 
       hasMortgage, mortgageAmount, mortgageBank]
    );

    const r = rows[0];
    return {
      id: r.id,
      type: r.type,
      name: r.name,
      address: r.address,
      areaSqm: r.area_sqm,
      monthlyPayment: r.monthly_payment,
      cashbackPercent: r.cashback_percent,
      hasMortgage: r.has_mortgage,
      mortgageAmount: r.mortgage_amount,
      mortgageBank: r.mortgage_bank
    };
  },

  // Получить детали объекта
  getById: async (userId, propertyId) => {
    const { rows } = await pool.query(
      `SELECT id, type, name, address, area_sqm, monthly_payment, 
              cashback_percent, has_mortgage, mortgage_amount, mortgage_bank
       FROM user_properties
       WHERE user_id = $1 AND id = $2
       LIMIT 1`,
      [userId, propertyId]
    );

    const r = rows[0];
    if (!r) throw new ApiError(404, 'not_found', 'Объект не найден');

    return {
      id: r.id,
      type: r.type,
      name: r.name,
      address: r.address,
      areaSqm: r.area_sqm,
      monthlyPayment: r.monthly_payment,
      cashbackPercent: r.cashback_percent,
      hasMortgage: r.has_mortgage,
      mortgageAmount: r.mortgage_amount,
      mortgageBank: r.mortgage_bank
    };
  },

  // Обновить объект
  update: async (userId, propertyId, dto) => {
    const { rows } = await pool.query(
      `UPDATE user_properties
       SET name = COALESCE($3, name),
           address = COALESCE($4, address),
           area_sqm = COALESCE($5, area_sqm),
           monthly_payment = COALESCE($6, monthly_payment),
           cashback_percent = COALESCE($7, cashback_percent),
           has_mortgage = COALESCE($8, has_mortgage),
           mortgage_amount = COALESCE($9, mortgage_amount),
           mortgage_bank = COALESCE($10, mortgage_bank),
           updated_at = now()
       WHERE user_id = $1 AND id = $2
       RETURNING id, type, name, address, area_sqm, monthly_payment, 
                 cashback_percent, has_mortgage, mortgage_amount, mortgage_bank`,
      [userId, propertyId, 
       dto?.name, dto?.address, dto?.areaSqm, dto?.monthlyPayment,
       dto?.cashbackPercent, dto?.hasMortgage, dto?.mortgageAmount, dto?.mortgageBank]
    );

    const r = rows[0];
    if (!r) throw new ApiError(404, 'not_found', 'Объект не найден');

    return {
      id: r.id,
      type: r.type,
      name: r.name,
      address: r.address,
      areaSqm: r.area_sqm,
      monthlyPayment: r.monthly_payment,
      cashbackPercent: r.cashback_percent,
      hasMortgage: r.has_mortgage,
      mortgageAmount: r.mortgage_amount,
      mortgageBank: r.mortgage_bank
    };
  },

  // Удалить объект
  delete: async (userId, propertyId) => {
    const { rowCount } = await pool.query(
      `DELETE FROM user_properties WHERE user_id = $1 AND id = $2`,
      [userId, propertyId]
    );
    if (rowCount === 0) throw new ApiError(404, 'not_found', 'Объект не найден');
    return { ok: true };
  }
};

module.exports = { propertiesService };
