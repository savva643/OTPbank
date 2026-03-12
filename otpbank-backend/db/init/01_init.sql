CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ BEGIN
  CREATE TYPE account_type AS ENUM ('debit', 'credit', 'savings');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE card_status AS ENUM ('active', 'frozen');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE tx_status AS ENUM ('pending', 'success', 'failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE tx_type AS ENUM ('income', 'expense');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text UNIQUE,
  email text UNIQUE,
  name text NOT NULL,
  full_name text,
  gender text,
  birth_date date,
  avatar_url text,
  password_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS gender text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date date;

CREATE TABLE IF NOT EXISTS auth_otp_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text NOT NULL,
  code_hash text NOT NULL,
  expires_at timestamptz NOT NULL,
  attempts int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_auth_otp_codes_phone ON auth_otp_codes(phone);
CREATE INDEX IF NOT EXISTS idx_auth_otp_codes_expires ON auth_otp_codes(expires_at);

CREATE TABLE IF NOT EXISTS accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type account_type NOT NULL,
  title text,
  balance numeric(14,2) NOT NULL DEFAULT 0,
  currency char(3) NOT NULL DEFAULT 'RUB',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);

CREATE TABLE IF NOT EXISTS cards (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_type text NOT NULL,
  masked_pan text NOT NULL,
  status card_status NOT NULL DEFAULT 'active',
  limit_per_tx numeric(14,2),
  limit_per_day numeric(14,2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_cards_user_id ON cards(user_id);
CREATE INDEX IF NOT EXISTS idx_cards_account_id ON cards(account_id);

CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  account_id uuid REFERENCES accounts(id) ON DELETE SET NULL,
  card_id uuid REFERENCES cards(id) ON DELETE SET NULL,
  merchant_name text,
  category text,
  amount numeric(14,2) NOT NULL,
  currency char(3) NOT NULL DEFAULT 'RUB',
  status tx_status NOT NULL DEFAULT 'success',
  type tx_type NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_time ON transactions(user_id, occurred_at DESC);

CREATE TABLE IF NOT EXISTS goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name text NOT NULL,
  icon text,
  target_amount numeric(14,2) NOT NULL,
  saved_amount numeric(14,2) NOT NULL DEFAULT 0,
  currency char(3) NOT NULL DEFAULT 'RUB',
  deadline date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);

ALTER TABLE goals ADD COLUMN IF NOT EXISTS icon text;
ALTER TABLE goals ADD COLUMN IF NOT EXISTS currency char(3) NOT NULL DEFAULT 'RUB';

CREATE TABLE IF NOT EXISTS investments_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  asset_type text NOT NULL,
  ticker text,
  name text,
  quantity numeric(18,8) NOT NULL DEFAULT 0,
  avg_price numeric(14,4) NOT NULL DEFAULT 0,
  currency char(3) NOT NULL DEFAULT 'RUB',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_investments_assets_user_id ON investments_assets(user_id);

CREATE TABLE IF NOT EXISTS product_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES product_categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  image_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);

CREATE UNIQUE INDEX IF NOT EXISTS uq_products_category_name ON products(category_id, name);

CREATE TABLE IF NOT EXISTS product_offers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  kicker text,
  title text NOT NULL,
  description text,
  image_url text,
  bg_color text,
  border_color text,
  cta_label text,
  cta_color text,
  sort_order int NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_product_offers_active_sort ON product_offers(is_active, sort_order, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_offers_product_id ON product_offers(product_id);

CREATE TABLE IF NOT EXISTS product_features (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  icon text,
  sort_order int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_product_features_product_sort ON product_features(product_id, sort_order);

CREATE TABLE IF NOT EXISTS scenarios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS scenario_products (
  scenario_id uuid NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  PRIMARY KEY (scenario_id, product_id)
);

CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sender text NOT NULL,
  message text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_user_time ON chat_messages(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS stories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  mini_image_url text,
  media_type text NOT NULL,
  media_url text NOT NULL,
  story_text text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stories_active_time ON stories(is_active, created_at DESC);

CREATE TABLE IF NOT EXISTS bonuses (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  points int NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS cashback (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  balance numeric(14,2) NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code text NOT NULL UNIQUE,
  invited_count int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO product_categories (name)
VALUES
  ('Путешествия'),
  ('Покупка авто'),
  ('Покупка жилья'),
  ('Сбережения'),
  ('Инвестиции'),
  ('Семейные финансы'),
  ('Подписки'),
  ('Ежедневные траты')
ON CONFLICT (name) DO NOTHING;

INSERT INTO products (category_id, name, description, image_url)
VALUES
  ((SELECT id FROM product_categories WHERE name = 'Путешествия' LIMIT 1), 'Дебетовая карта для путешествий', 'Повышенный кэшбэк за авиабилеты и отели', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Путешествия' LIMIT 1), 'Обмен валют', 'Выгодный курс и минимальная комиссия', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Сбережения' LIMIT 1), 'Накопительный счёт', 'Проценты на остаток каждый день', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Инвестиции' LIMIT 1), 'Инвесткопилка', 'Автопополнение и подбор портфеля', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Покупка жилья' LIMIT 1), 'Ипотека', 'Подбор условий и предварительное одобрение онлайн', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Покупка авто' LIMIT 1), 'Автокредит', 'Онлайн-заявка и индивидуальный срок/взнос', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Ежедневные траты' LIMIT 1), 'Кредит наличными', 'Быстрое решение и прозрачный график платежей', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Ежедневные траты' LIMIT 1), 'Займ до зарплаты', 'Малые суммы на короткий срок без визита в офис', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Подписки' LIMIT 1), 'OTP Premium', 'Повышенный кэшбэк и сервисы без комиссий', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Семейные финансы' LIMIT 1), 'Семейный счёт', 'Общий бюджет и лимиты по участникам', NULL)
ON CONFLICT (category_id, name) DO NOTHING;

INSERT INTO product_offers (product_id, kicker, title, description, image_url, bg_color, border_color, cta_label, cta_color, sort_order)
VALUES
  ((SELECT id FROM products WHERE name = 'Дебетовая карта для путешествий' LIMIT 1), 'ВАШИ ПУТЕШЕСТВИЯ', 'Путешествия', 'Кэшбэк за билеты, страховка и бизнес-залы', NULL, '#66C8E1FC', '#33C8E1FC', 'Подробнее', '#FF7D32', 10),
  ((SELECT id FROM products WHERE name = 'Ипотека' LIMIT 1), 'НЕДВИЖИМОСТЬ', 'Ипотека 6%', 'Предварительное одобрение онлайн и подбор условий', NULL, '#FFF1F5F9', '#7FE2E8F0', 'Рассчитать', '#0F172A', 20),
  ((SELECT id FROM products WHERE name = 'Автокредит' LIMIT 1), 'АВТО', 'Автокредит', 'Одобрение онлайн, срок и первый взнос под ваш бюджет', NULL, '#FFFFEDD5', '#66FFEDD5', 'Подобрать', '#0F172A', 30),
  ((SELECT id FROM products WHERE name = 'Кредит наличными' LIMIT 1), 'КРЕДИТ', 'Кредит наличными', 'Ставка от 9.9% и платёж без комиссий', NULL, '#1A9E6FC3', '#339E6FC3', 'Оформить', '#4F46E5', 40),
  ((SELECT id FROM products WHERE name = 'Займ до зарплаты' LIMIT 1), 'ЗАЙМЫ', 'Займ до зарплаты', 'Быстрое решение и минимум документов', NULL, '#FFF8FAFC', '#7FF1F5F9', 'Получить', '#FF7D32', 50),
  ((SELECT id FROM products WHERE name = 'Накопительный счёт' LIMIT 1), 'СБЕРЕЖЕНИЯ', 'Накопительный счёт', 'Проценты ежедневно и пополнение без ограничений', NULL, '#1AC4FF2E', '#33C4FF2E', 'Открыть', '#0F172A', 60),
  ((SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1), 'ИНВЕСТИЦИИ', 'Инвесткопилка', 'Округляйте покупки и инвестируйте незаметно', NULL, '#FFF3E8FF', '#66E9D5FF', 'Подключить', '#9E6FC3', 70),
  ((SELECT id FROM products WHERE name = 'OTP Premium' LIMIT 1), 'ПОДПИСКИ', 'Премиум', 'Платежи без комиссий и повышенный кэшбэк', NULL, '#FF0F172A', '#331E293B', 'Подключить', '#C4FF2E', 80),
  ((SELECT id FROM products WHERE name = 'Семейный счёт' LIMIT 1), 'СЕМЬЯ', 'Семейный счёт', 'Общий бюджет, лимиты и прозрачные расходы', NULL, '#FFDBEAFE', '#66DBEAFE', 'Создать', '#2563EB', 90)
ON CONFLICT DO NOTHING;

INSERT INTO product_features (product_id, title, description, icon, sort_order)
VALUES
  ((SELECT id FROM products WHERE name = 'Дебетовая карта для путешествий' LIMIT 1), 'Кэшбэк на путешествия', 'До 10% на билеты и отели в выбранных категориях', 'flight', 10),
  ((SELECT id FROM products WHERE name = 'Дебетовая карта для путешествий' LIMIT 1), 'Бизнес-залы', 'Доступ в VIP-залы при выполнении условий программы', 'lounge', 20),
  ((SELECT id FROM products WHERE name = 'Дебетовая карта для путешествий' LIMIT 1), 'Копилка для поездок', 'Автопополнение накопительного счёта на будущие путешествия', 'savings', 30),
  ((SELECT id FROM products WHERE name = 'Ипотека' LIMIT 1), 'Предодобрение', 'Ответ по заявке онлайн — без визита в офис', 'check', 10),
  ((SELECT id FROM products WHERE name = 'Ипотека' LIMIT 1), 'Новостройки/вторичка', 'Подбор подходящей программы под вашу цель', 'home', 20),
  ((SELECT id FROM products WHERE name = 'Автокредит' LIMIT 1), 'Калькулятор платежа', 'Подбор срока и взноса для комфортного ежемесячного платежа', 'car', 10),
  ((SELECT id FROM products WHERE name = 'Автокредит' LIMIT 1), 'КАСКО/ОСАГО', 'Подключение страховок и сервисов при оформлении', 'shield', 20),
  ((SELECT id FROM products WHERE name = 'Кредит наличными' LIMIT 1), 'Досрочное погашение', 'Погашайте досрочно без штрафов (по условиям тарифа)', 'bolt', 10),
  ((SELECT id FROM products WHERE name = 'Займ до зарплаты' LIMIT 1), 'Быстрое получение', 'Деньги на карту после решения по заявке', 'timer', 10),
  ((SELECT id FROM products WHERE name = 'Накопительный счёт' LIMIT 1), 'Проценты ежедневно', 'Начисление процентов каждый день на остаток', 'percent', 10),
  ((SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1), 'Округление покупок', 'Автоматические пополнения из сдачи', 'coins', 10),
  ((SELECT id FROM products WHERE name = 'OTP Premium' LIMIT 1), 'Повышенный кэшбэк', 'Больше кэшбэка в популярных категориях', 'sparkles', 10),
  ((SELECT id FROM products WHERE name = 'Семейный счёт' LIMIT 1), 'Лимиты по участникам', 'Настраивайте лимиты и доступы для каждого', 'users', 10)
ON CONFLICT DO NOTHING;

INSERT INTO scenarios (title, description)
VALUES
  ('Путешествия', 'Карты, обмен валют и страховки для поездок'),
  ('Сбережения', 'Накопления, цели и удобные инструменты контроля бюджета')
ON CONFLICT DO NOTHING;

INSERT INTO scenario_products (scenario_id, product_id)
SELECT s.id, p.id
FROM scenarios s
JOIN products p ON (
  (s.title = 'Путешествия' AND p.name IN ('Дебетовая карта для путешествий', 'Обмен валют')) OR
  (s.title = 'Сбережения' AND p.name IN ('Накопительный счёт'))
)
ON CONFLICT DO NOTHING;

INSERT INTO stories (title, mini_image_url, media_type, media_url, story_text)
VALUES
  ('Для вас', NULL, 'photo', 'https://placehold.co/1080x1920/png', 'Подборка предложений и полезных возможностей'),
  ('Кэшбэк 10%', NULL, 'gif', 'https://placehold.co/1080x1920/gif', 'Акция действует для выбранных категорий'),
  ('Новое в приложении', NULL, 'video', 'https://placehold.co/1080x1920/mp4', 'Обновления и улучшения интерфейса')
ON CONFLICT DO NOTHING;
