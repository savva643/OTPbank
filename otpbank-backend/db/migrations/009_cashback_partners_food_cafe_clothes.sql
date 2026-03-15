-- Миграция: Дополнение партнеров кэшбэка (еда/кафе/одежда) + проставление логотипов
-- Дата: 2026-03-15
-- Описание: идемпотентно добавляет/обновляет партнеров и обновляет logo_url для тех, у кого есть файлы логотипов

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
  -- Еда и продукты
  ('pyaterochka', 'Пятёрочка', 'Сеть продуктовых магазинов', 'food', 1.5, 1.0),
  ('magnit', 'Магнит', 'Сеть продуктовых магазинов', 'food', 1.5, 1.0),
  ('lenta', 'Лента', 'Гипермаркеты', 'food', 2.0, 1.0),
  ('auchan', 'Ашан', 'Гипермаркеты', 'food', 2.0, 1.0),
  ('perekrestok', 'Перекрёсток', 'Сеть супермаркетов', 'food', 1.5, 1.0),
  ('samokat', 'Самокат', 'Доставка продуктов', 'food_delivery', 3.0, 1.5),
  ('yandex_eda', 'Яндекс Еда', 'Доставка еды', 'food_delivery', 5.0, 2.0),
  ('delivery', 'Delivery Club', 'Доставка еды', 'food_delivery', 5.0, 2.0),

  -- Кафе и рестораны
  ('dodo', 'Додо Пицца', 'Сеть пиццерий', 'cafe', 3.0, 1.5),
  ('burger_king', 'Burger King', 'Сеть ресторанов быстрого питания', 'cafe', 2.0, 1.0),
  ('kfc', 'KFC', 'Сеть ресторанов быстрого питания', 'cafe', 2.0, 1.0),
  ('mcdonalds', 'McDonald''s', 'Сеть ресторанов быстрого питания', 'cafe', 2.0, 1.0),
  ('starbucks', 'Starbucks', 'Сеть кофеен', 'cafe', 3.0, 1.5),
  ('shokoladnitsa', 'Шоколадница', 'Сеть кофеен', 'cafe', 3.0, 1.5),

  -- Одежда и обувь
  ('wildberries', 'Wildberries', 'Маркетплейс одежды и товаров', 'clothes', 3.0, 1.5),
  ('ozon', 'Ozon', 'Маркетплейс', 'clothes', 3.0, 1.5)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  cashback_percent = EXCLUDED.cashback_percent,
  bonus_multiplier = EXCLUDED.bonus_multiplier;

-- Проставляем logo_url только тем, у кого реально есть файлы в public/logos/cashback
UPDATE cashback_partners SET logo_url = '/logos/cashback/five.png' WHERE code = 'pyaterochka';
UPDATE cashback_partners SET logo_url = '/logos/cashback/magnit.png' WHERE code = 'magnit';
UPDATE cashback_partners SET logo_url = '/logos/cashback/lenta.png' WHERE code = 'lenta';
UPDATE cashback_partners SET logo_url = '/logos/cashback/samokat.png' WHERE code = 'samokat';
UPDATE cashback_partners SET logo_url = '/logos/cashback/auchan.png' WHERE code = 'auchan';
UPDATE cashback_partners SET logo_url = '/logos/cashback/perekrestok.png' WHERE code = 'perekrestok';
UPDATE cashback_partners SET logo_url = '/logos/cashback/ya_eda.png' WHERE code = 'yandex_eda';
UPDATE cashback_partners SET logo_url = '/logos/cashback/dodopizza.png' WHERE code = 'dodo';
UPDATE cashback_partners SET logo_url = '/logos/cashback/burger_king.png' WHERE code = 'burger_king';
UPDATE cashback_partners SET logo_url = '/logos/cashback/mcdonalds.png' WHERE code = 'mcdonalds';
UPDATE cashback_partners SET logo_url = '/logos/cashback/wildberries.png' WHERE code = 'wildberries';
UPDATE cashback_partners SET logo_url = '/logos/cashback/ozon.png' WHERE code = 'ozon';
