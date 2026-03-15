const { pool } = require('../db/pool');
const { ApiError } = require('../utils/apiError');

const vehiclesService = {
  // Получить все ТС пользователя
  listByUser: async (userId) => {
    const { rows } = await pool.query(
      `SELECT id, type, brand, model, year, license_plate, monthly_fuel_cost,
              monthly_insurance, monthly_parking, cashback_percent,
              has_loan, loan_amount, loan_bank, created_at
       FROM user_vehicles
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );
    return rows.map((r) => ({
      id: r.id,
      type: r.type,
      brand: r.brand,
      model: r.model,
      year: r.year,
      licensePlate: r.license_plate,
      monthlyFuelCost: r.monthly_fuel_cost,
      monthlyInsurance: r.monthly_insurance,
      monthlyParking: r.monthly_parking,
      cashbackPercent: r.cashback_percent,
      hasLoan: r.has_loan,
      loanAmount: r.loan_amount,
      loanBank: r.loan_bank,
      createdAt: r.created_at
    }));
  },

  // Создать новое ТС
  create: async (userId, dto) => {
    const type = dto?.type?.toString().trim() || '';
    const brand = dto?.brand?.toString().trim() || '';
    const model = dto?.model?.toString().trim() || '';
    const year = dto?.year !== undefined ? Number(dto.year) : null;
    const licensePlate = dto?.licensePlate?.toString().trim() || null;
    const monthlyFuelCost = dto?.monthlyFuelCost !== undefined ? Number(dto.monthlyFuelCost) : null;
    const monthlyInsurance = dto?.monthlyInsurance !== undefined ? Number(dto.monthlyInsurance) : null;
    const monthlyParking = dto?.monthlyParking !== undefined ? Number(dto.monthlyParking) : null;
    const cashbackPercent = dto?.cashbackPercent !== undefined ? Number(dto.cashbackPercent) : 0;
    const hasLoan = dto?.hasLoan === true;
    const loanAmount = dto?.loanAmount !== undefined ? Number(dto.loanAmount) : null;
    const loanBank = dto?.loanBank?.toString().trim() || null;

    if (!type || !['car', 'motorcycle', 'truck'].includes(type)) {
      throw new ApiError(400, 'validation_error', 'Некорректный тип транспорта');
    }
    if (!brand || !model) {
      throw new ApiError(400, 'validation_error', 'Марка и модель обязательны');
    }

    const { rows } = await pool.query(
      `INSERT INTO user_vehicles (user_id, type, brand, model, year, license_plate,
                                  monthly_fuel_cost, monthly_insurance, monthly_parking,
                                  cashback_percent, has_loan, loan_amount, loan_bank)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
       RETURNING id, type, brand, model, year, license_plate, monthly_fuel_cost,
                 monthly_insurance, monthly_parking, cashback_percent,
                 has_loan, loan_amount, loan_bank`,
      [userId, type, brand, model, year, licensePlate, monthlyFuelCost, 
       monthlyInsurance, monthlyParking, cashbackPercent, hasLoan, loanAmount, loanBank]
    );

    const r = rows[0];
    return {
      id: r.id,
      type: r.type,
      brand: r.brand,
      model: r.model,
      year: r.year,
      licensePlate: r.license_plate,
      monthlyFuelCost: r.monthly_fuel_cost,
      monthlyInsurance: r.monthly_insurance,
      monthlyParking: r.monthly_parking,
      cashbackPercent: r.cashback_percent,
      hasLoan: r.has_loan,
      loanAmount: r.loan_amount,
      loanBank: r.loan_bank
    };
  },

  // Получить детали ТС
  getById: async (userId, vehicleId) => {
    const { rows } = await pool.query(
      `SELECT id, type, brand, model, year, license_plate, monthly_fuel_cost,
              monthly_insurance, monthly_parking, cashback_percent,
              has_loan, loan_amount, loan_bank
       FROM user_vehicles
       WHERE user_id = $1 AND id = $2
       LIMIT 1`,
      [userId, vehicleId]
    );

    const r = rows[0];
    if (!r) throw new ApiError(404, 'not_found', 'Транспорт не найден');

    return {
      id: r.id,
      type: r.type,
      brand: r.brand,
      model: r.model,
      year: r.year,
      licensePlate: r.license_plate,
      monthlyFuelCost: r.monthly_fuel_cost,
      monthlyInsurance: r.monthly_insurance,
      monthlyParking: r.monthly_parking,
      cashbackPercent: r.cashback_percent,
      hasLoan: r.has_loan,
      loanAmount: r.loan_amount,
      loanBank: r.loan_bank
    };
  },

  // Обновить ТС
  update: async (userId, vehicleId, dto) => {
    const { rows } = await pool.query(
      `UPDATE user_vehicles
       SET brand = COALESCE($3, brand),
           model = COALESCE($4, model),
           year = COALESCE($5, year),
           license_plate = COALESCE($6, license_plate),
           monthly_fuel_cost = COALESCE($7, monthly_fuel_cost),
           monthly_insurance = COALESCE($8, monthly_insurance),
           monthly_parking = COALESCE($9, monthly_parking),
           cashback_percent = COALESCE($10, cashback_percent),
           has_loan = COALESCE($11, has_loan),
           loan_amount = COALESCE($12, loan_amount),
           loan_bank = COALESCE($13, loan_bank),
           updated_at = now()
       WHERE user_id = $1 AND id = $2
       RETURNING id, type, brand, model, year, license_plate, monthly_fuel_cost,
                 monthly_insurance, monthly_parking, cashback_percent,
                 has_loan, loan_amount, loan_bank`,
      [userId, vehicleId, dto?.brand, dto?.model, dto?.year, dto?.licensePlate,
       dto?.monthlyFuelCost, dto?.monthlyInsurance, dto?.monthlyParking,
       dto?.cashbackPercent, dto?.hasLoan, dto?.loanAmount, dto?.loanBank]
    );

    const r = rows[0];
    if (!r) throw new ApiError(404, 'not_found', 'Транспорт не найден');

    return {
      id: r.id,
      type: r.type,
      brand: r.brand,
      model: r.model,
      year: r.year,
      licensePlate: r.license_plate,
      monthlyFuelCost: r.monthly_fuel_cost,
      monthlyInsurance: r.monthly_insurance,
      monthlyParking: r.monthly_parking,
      cashbackPercent: r.cashback_percent,
      hasLoan: r.has_loan,
      loanAmount: r.loan_amount,
      loanBank: r.loan_bank
    };
  },

  // Удалить ТС
  delete: async (userId, vehicleId) => {
    const { rowCount } = await pool.query(
      `DELETE FROM user_vehicles WHERE user_id = $1 AND id = $2`,
      [userId, vehicleId]
    );
    if (rowCount === 0) throw new ApiError(404, 'not_found', 'Транспорт не найден');
    return { ok: true };
  }
};

module.exports = { vehiclesService };
