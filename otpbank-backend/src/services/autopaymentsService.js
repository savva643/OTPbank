const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const autopaymentsService = {
  // Получить все автоплатежи пользователя
  listByUser: async (userId) => {
    const { rows } = await pool.query(
      `SELECT a.id, a.property_id, a.vehicle_id, a.name, a.category, a.amount, 
              a.currency, a.payment_day, a.is_active, a.card_id, a.account_id,
              a.provider_name, a.provider_account, a.cashback_percent, a.notes,
              COALESCE(p.name, v.brand || ' ' || v.model) as parent_name
       FROM autopayments a
       LEFT JOIN user_properties p ON p.id = a.property_id
       LEFT JOIN user_vehicles v ON v.id = a.vehicle_id
       WHERE a.user_id = $1
       ORDER BY a.payment_day, a.name`,
      [userId]
    );
    return rows.map((r) => ({
      id: r.id,
      propertyId: r.property_id,
      vehicleId: r.vehicle_id,
      parentName: r.parent_name,
      name: r.name,
      category: r.category,
      amount: r.amount,
      currency: r.currency,
      paymentDay: r.payment_day,
      isActive: r.is_active,
      cardId: r.card_id,
      accountId: r.account_id,
      providerName: r.provider_name,
      providerAccount: r.provider_account,
      cashbackPercent: r.cashback_percent,
      notes: r.notes
    }));
  },

  // Получить автоплатежи для конкретного объекта
  listByProperty: async (userId, propertyId) => {
    const { rows } = await pool.query(
      `SELECT id, name, category, amount, currency, payment_day, is_active,
              card_id, account_id, provider_name, provider_account, cashback_percent, notes
       FROM autopayments
       WHERE user_id = $1 AND property_id = $2
       ORDER BY payment_day, name`,
      [userId, propertyId]
    );
    return rows.map((r) => ({
      id: r.id,
      name: r.name,
      category: r.category,
      amount: r.amount,
      currency: r.currency,
      paymentDay: r.payment_day,
      isActive: r.is_active,
      cardId: r.card_id,
      accountId: r.account_id,
      providerName: r.provider_name,
      providerAccount: r.provider_account,
      cashbackPercent: r.cashback_percent,
      notes: r.notes
    }));
  },

  // Получить автоплатежи для конкретного ТС
  listByVehicle: async (userId, vehicleId) => {
    const { rows } = await pool.query(
      `SELECT id, name, category, amount, currency, payment_day, is_active,
              card_id, account_id, provider_name, provider_account, cashback_percent, notes
       FROM autopayments
       WHERE user_id = $1 AND vehicle_id = $2
       ORDER BY payment_day, name`,
      [userId, vehicleId]
    );
    return rows.map((r) => ({
      id: r.id,
      name: r.name,
      category: r.category,
      amount: r.amount,
      currency: r.currency,
      paymentDay: r.payment_day,
      isActive: r.is_active,
      cardId: r.card_id,
      accountId: r.account_id,
      providerName: r.provider_name,
      providerAccount: r.provider_account,
      cashbackPercent: r.cashback_percent,
      notes: r.notes
    }));
  },

  // Создать автоплатёж
  create: async (userId, dto) => {
    const propertyId = dto?.propertyId || null;
    const vehicleId = dto?.vehicleId || null;
    const name = dto?.name?.toString().trim() || '';
    const category = dto?.category?.toString().trim() || '';
    const amount = dto?.amount !== undefined ? Number(dto.amount) : null;
    const currency = dto?.currency?.toString().trim() || '₽';
    const paymentDay = dto?.paymentDay !== undefined ? Number(dto.paymentDay) : null;
    const isActive = dto?.isActive !== false;
    const cardId = dto?.cardId || null;
    const accountId = dto?.accountId || null;
    const providerName = dto?.providerName?.toString().trim() || null;
    const providerAccount = dto?.providerAccount?.toString().trim() || null;
    const cashbackPercent = dto?.cashbackPercent !== undefined ? Number(dto.cashbackPercent) : 0;
    const notes = dto?.notes?.toString().trim() || null;

    const validCategories = ['internet', 'utilities', 'electricity', 'gas', 'water', 
      'security', 'parking', 'fuel', 'insurance', 'maintenance', 'tax', 'loan', 'rent', 'phone', 'tv', 'other'];

    if (!name) throw new ApiError(400, 'validation_error', 'Название обязательно');
    if (!category || !validCategories.includes(category)) {
      throw new ApiError(400, 'validation_error', 'Некорректная категория');
    }
    if (amount === null || amount < 0) throw new ApiError(400, 'validation_error', 'Сумма обязательна');
    if (!paymentDay || paymentDay < 1 || paymentDay > 31) {
      throw new ApiError(400, 'validation_error', 'День платежа должен быть от 1 до 31');
    }
    if (!propertyId && !vehicleId) {
      throw new ApiError(400, 'validation_error', 'Укажите объект недвижимости или транспорт');
    }

    const { rows } = await pool.query(
      `INSERT INTO autopayments (user_id, property_id, vehicle_id, name, category, amount, currency,
                                  payment_day, is_active, card_id, account_id, provider_name, 
                                  provider_account, cashback_percent, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
       RETURNING id, name, category, amount, currency, payment_day, is_active, 
                 provider_name, provider_account, cashback_percent, notes`,
      [userId, propertyId, vehicleId, name, category, amount, currency, 
       paymentDay, isActive, cardId, accountId, providerName, providerAccount, cashbackPercent, notes]
    );

    const r = rows[0];
    return {
      id: r.id,
      name: r.name,
      category: r.category,
      amount: r.amount,
      currency: r.currency,
      paymentDay: r.payment_day,
      isActive: r.is_active,
      providerName: r.provider_name,
      providerAccount: r.provider_account,
      cashbackPercent: r.cashback_percent,
      notes: r.notes
    };
  },

  // Обновить автоплатёж
  update: async (userId, autopaymentId, dto) => {
    const { rows } = await pool.query(
      `UPDATE autopayments
       SET name = COALESCE($3, name),
           category = COALESCE($4, category),
           amount = COALESCE($5, amount),
           currency = COALESCE($6, currency),
           payment_day = COALESCE($7, payment_day),
           is_active = COALESCE($8, is_active),
           card_id = COALESCE($9, card_id),
           account_id = COALESCE($10, account_id),
           provider_name = COALESCE($11, provider_name),
           provider_account = COALESCE($12, provider_account),
           cashback_percent = COALESCE($13, cashback_percent),
           notes = COALESCE($14, notes),
           updated_at = now()
       WHERE user_id = $1 AND id = $2
       RETURNING id, name, category, amount, currency, payment_day, is_active, 
                 provider_name, provider_account, cashback_percent, notes`,
      [userId, autopaymentId, dto?.name, dto?.category, dto?.amount, dto?.currency,
       dto?.paymentDay, dto?.isActive, dto?.cardId, dto?.accountId, 
       dto?.providerName, dto?.providerAccount, dto?.cashbackPercent, dto?.notes]
    );

    const r = rows[0];
    if (!r) throw new ApiError(404, 'not_found', 'Автоплатёж не найден');

    return {
      id: r.id,
      name: r.name,
      category: r.category,
      amount: r.amount,
      currency: r.currency,
      paymentDay: r.payment_day,
      isActive: r.is_active,
      providerName: r.provider_name,
      providerAccount: r.provider_account,
      cashbackPercent: r.cashback_percent,
      notes: r.notes
    };
  },

  // Удалить автоплатёж
  delete: async (userId, autopaymentId) => {
    const { rowCount } = await pool.query(
      `DELETE FROM autopayments WHERE user_id = $1 AND id = $2`,
      [userId, autopaymentId]
    );
    if (rowCount === 0) throw new ApiError(404, 'not_found', 'Автоплатёж не найден');
    return { ok: true };
  }
};

module.exports = { autopaymentsService };
