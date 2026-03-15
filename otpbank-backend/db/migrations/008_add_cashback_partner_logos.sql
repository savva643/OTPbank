-- Миграция: Привязка логотипов к партнерам кэшбэка
-- Дата: 2026-03-15
-- Описание: Обновляет logo_url для партнеров кэшбэка с добавленными логотипами

CREATE TABLE IF NOT EXISTS cashback_partners (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url TEXT,
    category VARCHAR(50),
    cashback_percent NUMERIC(5,2) DEFAULT 0,
    bonus_multiplier NUMERIC(5,2) DEFAULT 1.0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO cashback_partners (code, name, description, category, cashback_percent, bonus_multiplier)
VALUES
  ('pyaterochka', 'Пятёрочка', 'Сеть продуктовых магазинов', 'food', 1.5, 1.0),
  ('magnit', 'Магнит', 'Сеть продуктовых магазинов', 'food', 1.5, 1.0),
  ('lenta', 'Лента', 'Гипермаркеты', 'food', 2.0, 1.0),
  ('samokat', 'Самокат', 'Доставка продуктов', 'food_delivery', 3.0, 1.5)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  cashback_percent = EXCLUDED.cashback_percent,
  bonus_multiplier = EXCLUDED.bonus_multiplier;

UPDATE cashback_partners SET logo_url = '/logos/cashback/five.png' WHERE code = 'pyaterochka';
UPDATE cashback_partners SET logo_url = '/logos/cashback/magnit.png' WHERE code = 'magnit';
UPDATE cashback_partners SET logo_url = '/logos/cashback/lenta.png' WHERE code = 'lenta';
UPDATE cashback_partners SET logo_url = '/logos/cashback/samokat.png' WHERE code = 'samokat';
