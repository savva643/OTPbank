CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ BEGIN
  CREATE TYPE account_type AS ENUM ('debit', 'credit', 'savings');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE card_status AS ENUM ('active', 'frozen', 'blocked');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE tx_status AS ENUM ('pending', 'success', 'failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE tx_type AS ENUM ('income', 'expense');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text UNIQUE NOT NULL,
  email text,
  name text,
  full_name text,
  last_name text,
  first_name text,
  middle_name text,
  gender text,
  birth_date date,
  avatar_url text,
  password_hash text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

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
  account_number text,
  bic text,
  bank_name text,
  corr_account text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);

CREATE TABLE IF NOT EXISTS cards (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_type text NOT NULL,
  label text,
  card_type_name text,
  masked_pan text NOT NULL,
  cvc text,
  status card_status NOT NULL DEFAULT 'active',
  bg_color1 text,
  bg_color2 text,
  pin_hash text,
  limit_per_tx numeric(14,2),
  limit_per_day numeric(14,2),
  is_main boolean NOT NULL DEFAULT false,
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

CREATE UNIQUE INDEX IF NOT EXISTS uq_product_offers_product_title ON product_offers(product_id, title);

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

CREATE UNIQUE INDEX IF NOT EXISTS uq_product_features_product_title ON product_features(product_id, title);

CREATE TABLE IF NOT EXISTS product_widgets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  type text NOT NULL,
  title text,
  subtitle text,
  icon text,
  bg_color text,
  border_color text,
  cta_label text,
  cta_action text,
  cta_payload text,
  payload jsonb,
  sort_order int NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_product_widgets_product_sort ON product_widgets(product_id, is_active, sort_order, created_at DESC);

CREATE TABLE IF NOT EXISTS scenarios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_scenarios_title ON scenarios(title);

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
  code text UNIQUE,
  title text NOT NULL,
  mini_image_url text,
  media_type text NOT NULL,
  media_url text NOT NULL,
  story_text text,
  cta_label text,
  cta_action text,
  cta_payload text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_stories_title ON stories(title);

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

CREATE TABLE IF NOT EXISTS user_properties (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('house', 'apartment', 'country_house')),
    name text NOT NULL,
    address text,
    area_sqm numeric(10,2),
    monthly_payment numeric(14,2),
    cashback_percent numeric(5,2) DEFAULT 0,
    has_mortgage boolean DEFAULT false,
    mortgage_amount numeric(14,2),
    mortgage_bank text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_vehicles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('car', 'motorcycle', 'truck')),
    brand text NOT NULL,
    model text NOT NULL,
    year integer,
    license_plate text,
    monthly_fuel_cost numeric(14,2),
    monthly_insurance numeric(14,2),
    monthly_parking numeric(14,2),
    cashback_percent numeric(5,2) DEFAULT 0,
    has_loan boolean DEFAULT false,
    loan_amount numeric(14,2),
    loan_bank text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS autopayments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    property_id uuid REFERENCES user_properties(id) ON DELETE CASCADE,
    vehicle_id uuid REFERENCES user_vehicles(id) ON DELETE CASCADE,
    name text NOT NULL,
    category text NOT NULL CHECK (category IN (
        'internet', 'utilities', 'electricity', 'gas', 'water', 
        'security', 'parking', 'fuel', 'insurance', 'maintenance',
        'tax', 'loan', 'rent', 'phone', 'tv', 'other'
    )),
    amount numeric(14,2) NOT NULL,
    currency text DEFAULT '₽',
    payment_day integer NOT NULL CHECK (payment_day BETWEEN 1 AND 31),
    is_active boolean DEFAULT true,
    card_id uuid REFERENCES cards(id) ON DELETE SET NULL,
    account_id uuid REFERENCES accounts(id) ON DELETE SET NULL,
    provider_name text,
    provider_account text,
    cashback_percent numeric(5,2) DEFAULT 0,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT property_or_vehicle CHECK (
        (property_id IS NOT NULL AND vehicle_id IS NULL) OR
        (property_id IS NULL AND vehicle_id IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_user_properties_user_id ON user_properties(user_id);
CREATE INDEX IF NOT EXISTS idx_user_vehicles_user_id ON user_vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_autopayments_user_id ON autopayments(user_id);
CREATE INDEX IF NOT EXISTS idx_autopayments_property_id ON autopayments(property_id);
CREATE INDEX IF NOT EXISTS idx_autopayments_vehicle_id ON autopayments(vehicle_id);

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
ON CONFLICT (product_id, title) DO NOTHING;

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
VALUES
  (
    (SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1),
    'banner',
    'Инвесткопилка',
    'Округляйте покупки и копите незаметно',
    'sparkles',
    '#FFF3E8FF',
    '#66E9D5FF',
    'Подключить',
    'open',
    'invest_piggy',
    jsonb_build_object('gradient', jsonb_build_array('#C4FF2E', '#F1F5F9', '#FFFFFF')),
    10
  ),
  (
    (SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1),
    'card',
    'Округление покупок',
    'Автопополнение из сдачи после каждой покупки.',
    'coins',
    '#FFFFFF',
    '#F1F5F9',
    'Подробнее',
    'open',
    'rounding',
    NULL,
    20
  ),
  (
    (SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1),
    'faq',
    'Вопросы и ответы',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    jsonb_build_object(
      'items', jsonb_build_array(
        jsonb_build_object('q', 'Сколько стоит подключение?', 'a', 'Подключение бесплатное.'),
        jsonb_build_object('q', 'Можно отключить в любой момент?', 'a', 'Да, в настройках продукта.')
      )
    ),
    30
  ),
  (
    (SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1),
    'stepper',
    'Как подключить',
    NULL,
    NULL,
    NULL,
    NULL,
    'Открыть',
    'open',
    'invest_piggy',
    jsonb_build_object(
      'steps', jsonb_build_array(
        'Выберите счёт списания',
        'Настройте округление',
        'Нажмите «Подключить»'
      )
    ),
    40
  )
ON CONFLICT DO NOTHING;

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Карта для путешествий',
  'Оформите карту и получайте бонусы в поездках',
  'flight',
  '#FFFFEDD5',
  '#66FFEDD5',
  'Оформить карту',
  'card_issue',
  'travel',
  jsonb_build_object('gradient', jsonb_build_array('#FF7D32', '#9E6FC3')),
  10
FROM products p
WHERE lower(p.name) IN ('дебетовая карта для путешествий', 'путешествия')
  AND NOT EXISTS (
    SELECT 1
    FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner' AND w.cta_action = 'card_issue'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'card',
  'Кэшбэк до 10%',
  'Покажем подробные условия начисления кэшбэка.',
  'percent',
  '#FFFFFF',
  '#F1F5F9',
  'Условия',
  'show_toast',
  'Условия кэшбэка скоро появятся в приложении',
  NULL,
  20
FROM products p
WHERE lower(p.name) IN ('дебетовая карта для путешествий', 'путешествия')
  AND NOT EXISTS (
    SELECT 1
    FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'card' AND w.cta_action = 'show_toast' AND w.title = 'Кэшбэк до 10%'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'card',
  'Копилка на отпуск',
  'Откладывайте автоматически — подключим позже отдельный экран копилки.',
  'savings',
  '#FFFFFF',
  '#F1F5F9',
  'Открыть',
  'open_screen',
  'invest_piggy',
  NULL,
  30
FROM products p
WHERE lower(p.name) IN ('дебетовая карта для путешествий', 'путешествия')
  AND NOT EXISTS (
    SELECT 1
    FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'card' AND w.cta_action = 'open_screen' AND w.title = 'Копилка на отпуск'
  );

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
ON CONFLICT (product_id, title) DO NOTHING;

INSERT INTO scenarios (title, description)
VALUES
  ('Путешествия', 'Карты, обмен валют и страховки для поездок'),
  ('Сбережения', 'Накопления, цели и удобные инструменты контроля бюджета')
ON CONFLICT (title) DO NOTHING;

INSERT INTO scenario_products (scenario_id, product_id)
SELECT s.id, p.id
FROM scenarios s
JOIN products p ON (
  (s.title = 'Путешествия' AND p.name IN ('Дебетовая карта для путешествий', 'Обмен валют')) OR
  (s.title = 'Сбережения' AND p.name IN ('Накопительный счёт'))
)
ON CONFLICT DO NOTHING;

INSERT INTO stories (code, title, mini_image_url, media_type, media_url, story_text, cta_label, cta_action, cta_payload, is_active)
VALUES
  (
    'swarovski',
    'Сваровски',
    'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif',
    'gif',
    'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif',
    'Приложение созданное командой Сваровски',
    'Круто!',
    'close',
    NULL,
    true
  ),
  (
    'otp-card',
    'Дебетовая ОТП Карта',
    '/stories/14-lama-main.png',
    'photo',
    '/stories/14-lama-main.png',
    'Приятный кэшбэк до 3 000 ₽ каждый месяц!',
    'Оформить',
    'open_product',
    'otp-debit-card',
    true
  ),
  (
    'internship',
    'Стажировка',
    '/stories/off-5.png',
    'photo',
    '/stories/off-5.png',
    'Приходи в наши офисы и устраивайся на стажировку',
    'Подробнее',
    'open_tab',
    '3',
    true
  )
ON CONFLICT (title) DO UPDATE SET
  code = EXCLUDED.code,
  mini_image_url = EXCLUDED.mini_image_url,
  media_type = EXCLUDED.media_type,
  media_url = EXCLUDED.media_url,
  story_text = EXCLUDED.story_text,
  cta_label = EXCLUDED.cta_label,
  cta_action = EXCLUDED.cta_action,
  cta_payload = EXCLUDED.cta_payload,
  is_active = true;

UPDATE stories
SET code = CASE
  WHEN title = 'Swarovski' THEN 'swarovski'
  WHEN title = 'Дебетовая ОТП Карта' THEN 'otp-card'
  WHEN title = 'Стажировка' THEN 'internship'
  ELSE code
END,
mini_image_url = CASE
  WHEN title = 'Swarovski' THEN 'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif'
  WHEN title = 'Дебетовая ОТП Карта' THEN '/stories/14-lama-main.png'
  WHEN title = 'Стажировка' THEN '/stories/off-5.png'
  ELSE mini_image_url
END,
media_type = CASE
  WHEN title = 'Swarovski' THEN 'gif'
  ELSE 'photo'
END,
media_url = CASE
  WHEN title = 'Swarovski' THEN 'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif'
  WHEN title = 'Дебетовая ОТП Карта' THEN '/stories/14-lama-main.png'
  WHEN title = 'Стажировка' THEN '/stories/off-5.png'
  ELSE media_url
END,
story_text = CASE
  WHEN title = 'Swarovski' THEN 'Приложение созданное командой Сваровски'
  WHEN title = 'Дебетовая ОТП Карта' THEN 'Приятный кэшбэк до 3 000 ₽ каждый месяц!'
  WHEN title = 'Стажировка' THEN 'Приходи в наши офисы и устраивайся на стажировку'
  ELSE story_text
END,
cta_label = CASE
  WHEN title = 'Swarovski' THEN 'Круто!'
  WHEN title = 'Дебетовая ОТП Карта' THEN 'Оформить'
  ELSE cta_label
END,
cta_action = CASE
  WHEN title = 'Swarovski' THEN 'close'
  WHEN title = 'Дебетовая ОТП Карта' THEN 'open_product'
  ELSE cta_action
END,
cta_payload = CASE
  WHEN title = 'Дебетовая ОТП Карта' THEN 'otp-debit-card'
  ELSE cta_payload
END
WHERE code IS NULL OR code IN ('swarovski', 'otp-card', 'internship');

-- ============================================
-- ТИПЫ КАРТ (для выпуска в приложении)
-- ============================================
CREATE TABLE IF NOT EXISTS card_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    card_design VARCHAR(50),
    daily_limit NUMERIC(15, 2) DEFAULT 100000,
    monthly_limit NUMERIC(15, 2) DEFAULT 1000000,
    has_cashback BOOLEAN DEFAULT false,
    has_bonuses BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO card_types (code, name, description, card_design, has_cashback, has_bonuses) VALUES
    ('standard', 'Стандарт', 'Обычная дебетовая карта для повседневных покупок', 'purple', true, false),
    ('premium', 'Премиум', 'Премиальная карта с повышенным кэшбэком и привилегиями', 'gold', true, true),
    ('travel', 'Для путешествий', 'Карта с выгодным курсом для путешествий и страховкой', 'blue', true, false),
    ('online', 'Для покупок', 'Карта для безопасных онлайн-покупок', 'green', true, false),
    ('kids', 'Детская', 'Карта для детей с контролем родителей', 'yellow', false, true),
    ('credit_standard', 'Кредитная Стандарт', 'Кредитная карта с льготным периодом 50 дней', 'purple_dark', false, false),
    ('credit_premium', 'Кредитная Премиум', 'Премиальная кредитная карта с повышенным лимитом', 'gold_dark', false, false),
    ('virtual', 'Виртуальная', 'Виртуальная карта для онлайн-покупок', 'virtual', true, false)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    card_design = EXCLUDED.card_design,
    has_cashback = EXCLUDED.has_cashback,
    has_bonuses = EXCLUDED.has_bonuses,
    updated_at = CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_card_types_code ON card_types(code);

-- Добавляем поле card_type_id в cards если нужно
ALTER TABLE cards ADD COLUMN IF NOT EXISTS card_type_id INTEGER REFERENCES card_types(id);

-- ============================================
-- КАТЕГОРИИ ПЛАТЕЖЕЙ
-- ============================================
CREATE TABLE IF NOT EXISTS payment_categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    icon_name VARCHAR(50),
    background_color VARCHAR(7) DEFAULT '#F1F5F9',
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO payment_categories (code, name, icon_name, background_color, display_order) VALUES
    ('mobile', 'Мобильная связь', 'phone_android', '#C8E1FC', 1),
    ('utilities', 'ЖКХ', 'apartment', '#9E6FC3', 2),
    ('internet', 'Интернет и ТВ', 'wifi', '#FF7D32', 3),
    ('fines', 'Штрафы и налоги', 'receipt_long', '#F59E0B', 4),
    ('government', 'Госуслуги', 'account_balance', '#0EA5E9', 5),
    ('transport', 'Транспорт', 'directions_car', '#C4FF2E', 6),
    ('education', 'Образование', 'school', '#8B5CF6', 7),
    ('health', 'Здоровье', 'local_hospital', '#EF4444', 8),
    ('insurance', 'Страхование', 'shield', '#F97316', 9),
    ('finance', 'Финансы', 'account_balance_wallet', '#84CC16', 10),
    ('entertainment', 'Развлечения', 'sports_esports', '#EC4899', 11),
    ('shopping', 'Шопинг', 'shopping_bag', '#06B6D4', 12)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    icon_name = EXCLUDED.icon_name,
    background_color = EXCLUDED.background_color,
    display_order = EXCLUDED.display_order;

CREATE INDEX IF NOT EXISTS idx_payment_categories_code ON payment_categories(code);
CREATE INDEX IF NOT EXISTS idx_payment_categories_order ON payment_categories(display_order);
CREATE INDEX IF NOT EXISTS idx_payment_categories_active ON payment_categories(is_active);

-- ============================================
-- УСЛУГИ/ОРГАНИЗАЦИИ ДЛЯ ПЛАТЕЖЕЙ
-- ============================================
CREATE TABLE IF NOT EXISTS payment_services (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INTEGER REFERENCES payment_categories(id) ON DELETE CASCADE,
    icon_color VARCHAR(9) DEFAULT '#FF0000',
    bg_color VARCHAR(9) DEFAULT '#33FF0000',
    image_url TEXT,
    is_popular BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Мобильная связь
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular, display_order)
SELECT 'mts', 'МТС', 'Мобильная связь', pc.id, '#FFFF0033', '#33FF0033', true, 1 FROM payment_categories pc WHERE pc.code = 'mobile';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular, display_order)
SELECT 'beeline', 'Билайн', 'Мобильная связь', pc.id, '#FFFECC00', '#33FECC00', true, 2 FROM payment_categories pc WHERE pc.code = 'mobile';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular, display_order)
SELECT 'megafon', 'МегаФон', 'Мобильная связь', pc.id, '#FF00B2E5', '#3300B2E5', true, 3 FROM payment_categories pc WHERE pc.code = 'mobile';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular, display_order)
SELECT 'tele2', 'Tele2', 'Мобильная связь', pc.id, '#FFFF9900', '#33FF9900', true, 4 FROM payment_categories pc WHERE pc.code = 'mobile';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular, display_order)
SELECT 'yota', 'Yota', 'Мобильная связь', pc.id, '#FF00B2E5', '#3300B2E5', false, 5 FROM payment_categories pc WHERE pc.code = 'mobile';

-- ЖКХ
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'mosenergosbyt', 'Мосэнергосбыт', 'Электроэнергия', pc.id, '#FFF59E0B', '#33F59E0B', true FROM payment_categories pc WHERE pc.code = 'utilities';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'gazprom_mezhregiongaz', 'Газпром Межрегионгаз', 'Газоснабжение', pc.id, '#FFEF4444', '#33EF4444', true FROM payment_categories pc WHERE pc.code = 'utilities';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'mosvodokanal', 'Мосводоканал', 'Водоснабжение', pc.id, '#FF3B82F6', '#333B82F6', true FROM payment_categories pc WHERE pc.code = 'utilities';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'mosobleirc', 'МособлЕИРЦ', 'Единый расчетный центр', pc.id, '#FF8B5CF6', '#338B5CF6', false FROM payment_categories pc WHERE pc.code = 'utilities';

-- Интернет
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'rostelecom', 'Ростелеком', 'Интернет и ТВ', pc.id, '#FF910A60', '#33910A60', true FROM payment_categories pc WHERE pc.code = 'internet';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'domru', 'Дом.ru', 'Интернет и ТВ', pc.id, '#FFEF4444', '#33EF4444', true FROM payment_categories pc WHERE pc.code = 'internet';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'mts_internet', 'МТС Интернет', 'Домашний интернет', pc.id, '#FFFF0033', '#33FF0033', true FROM payment_categories pc WHERE pc.code = 'internet';

-- Штрафы
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'gibdd', 'Штрафы ГИБДД', 'Административные штрафы', pc.id, '#FFF59E0B', '#33F59E0B', true FROM payment_categories pc WHERE pc.code = 'fines';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'parking', 'Штрафы парковки', 'Московский паркинг', pc.id, '#FFEF4444', '#33EF4444', true FROM payment_categories pc WHERE pc.code = 'fines';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'fns', 'Налоги ФНС', 'Налоговые платежи', pc.id, '#FF0EA5E9', '#330EA5E9', true FROM payment_categories pc WHERE pc.code = 'fines';

-- Госуслуги
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'gosuslugi', 'Госуслуги', 'Портал госуслуг', pc.id, '#FF0EA5E9', '#330EA5E9', true FROM payment_categories pc WHERE pc.code = 'government';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'fssp', 'Судебные задолженности', 'ФССП России', pc.id, '#FFDC2626', '#33DC2626', false FROM payment_categories pc WHERE pc.code = 'government';

-- Транспорт
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'troika', 'Тройка', 'Пополнение карты', pc.id, '#FFC4FF2E', '#33C4FF2E', true FROM payment_categories pc WHERE pc.code = 'transport';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'parkon', 'Паркон', 'Оплата парковки', pc.id, '#FF84CC16', '#3384CC16', true FROM payment_categories pc WHERE pc.code = 'transport';

-- Финансы (переводы между банками)
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'sber', 'Сбербанк', 'Пополнение счета', pc.id, '#FF1AB248', '#331AB248', true FROM payment_categories pc WHERE pc.code = 'finance';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'tinkoff', 'Тинькофф', 'Пополнение счета', pc.id, '#FFFFDD2D', '#33FFDD2D', true FROM payment_categories pc WHERE pc.code = 'finance';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'vtb', 'ВТБ', 'Пополнение счета', pc.id, '#FF032973', '#33032973', true FROM payment_categories pc WHERE pc.code = 'finance';
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'alfa', 'Альфа-Банк', 'Пополнение счета', pc.id, '#FFED1C24', '#33ED1C24', true FROM payment_categories pc WHERE pc.code = 'finance';

-- Привязка логотипов к услугам (добавленные логотипы)
UPDATE payment_services SET image_url = '/logos/services/mts.png' WHERE code = 'mts';
UPDATE payment_services SET image_url = '/logos/services/mts.png' WHERE code = 'mts_internet'; -- то же лого
UPDATE payment_services SET image_url = '/logos/services/beeline.png' WHERE code = 'beeline';
UPDATE payment_services SET image_url = '/logos/services/megafon.png' WHERE code = 'megafon';
UPDATE payment_services SET image_url = '/logos/services/tele2.png' WHERE code = 'tele2';
UPDATE payment_services SET image_url = '/logos/services/yota.png' WHERE code = 'yota';
UPDATE payment_services SET image_url = '/logos/services/mosenergysbit.png' WHERE code = 'mosenergosbyt';
UPDATE payment_services SET image_url = '/logos/services/regiongaz.png' WHERE code = 'gazprom_mezhregiongaz';
UPDATE payment_services SET image_url = '/logos/services/mosvodochanel.png' WHERE code = 'mosvodokanal';
UPDATE payment_services SET image_url = '/logos/services/mosobleric.png' WHERE code = 'mosobleirc';
UPDATE payment_services SET image_url = '/logos/services/rostelecom.png' WHERE code = 'rostelecom';
UPDATE payment_services SET image_url = '/logos/services/domru.png' WHERE code = 'domru';
UPDATE payment_services SET image_url = '/logos/services/sber.png' WHERE code = 'sber';
UPDATE payment_services SET image_url = '/logos/services/tbank.png' WHERE code = 'tinkoff'; -- Т-Банк (бывший Тинькофф)
UPDATE payment_services SET image_url = '/logos/services/vtb.png' WHERE code = 'vtb';
UPDATE payment_services SET image_url = '/logos/services/alfa.png' WHERE code = 'alfa';
UPDATE payment_services SET image_url = '/logos/services/gibdd.png' WHERE code = 'gibdd';
UPDATE payment_services SET image_url = '/logos/services/gosuslugi.png' WHERE code = 'gosuslugi';
UPDATE payment_services SET image_url = '/logos/services/troika.png' WHERE code = 'troika';

CREATE INDEX IF NOT EXISTS idx_payment_services_code ON payment_services(code);
CREATE INDEX IF NOT EXISTS idx_payment_services_category ON payment_services(category_id);
CREATE INDEX IF NOT EXISTS idx_payment_services_popular ON payment_services(is_popular);
CREATE INDEX IF NOT EXISTS idx_payment_services_active ON payment_services(is_active);

-- ============================================
-- МАГАЗИНЫ/ПАРТНЕРЫ ДЛЯ КЭШБЭКА И БОНУСОВ
-- ============================================
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

INSERT INTO cashback_partners (code, name, description, category, cashback_percent, bonus_multiplier) VALUES
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
    ('ozon', 'Ozon', 'Маркетплейс', 'clothes', 3.0, 1.5),
    ('lamoda', 'Lamoda', 'Онлайн-магазин одежды', 'clothes', 4.0, 2.0),
    ('sportmaster', 'Спортмастер', 'Спортивные товары', 'clothes', 3.0, 1.5),
    -- Электроника
    ('mvideo', 'М.Видео', 'Электроника и бытовая техника', 'electronics', 2.0, 1.0),
    ('eldorado', 'Эльдорадо', 'Электроника и бытовая техника', 'electronics', 2.0, 1.0),
    ('dns', 'DNS', 'Цифровая и бытовая техника', 'electronics', 2.0, 1.0),
    ('citilink', 'Ситилинк', 'Компьютерная техника', 'electronics', 2.0, 1.0),
    -- Авто
    ('shell', 'Shell', 'АЗС', 'fuel', 2.0, 1.0),
    ('bp', 'BP', 'АЗС', 'fuel', 2.0, 1.0),
    ('rosneft', 'Роснефть', 'АЗС', 'fuel', 2.0, 1.0),
    ('lukoil', 'Лукойл', 'АЗС', 'fuel', 2.0, 1.0),
    ('gazpromneft', 'Газпромнефть', 'АЗС', 'fuel', 2.0, 1.0),
    -- Красота и здоровье
    ('riv_gosh', 'Рив Гош', 'Парфюмерия и косметика', 'beauty', 3.0, 1.5),
    ('letual', 'Л''Этуаль', 'Парфюмерия и косметика', 'beauty', 3.0, 1.5),
    ('apteka_ru', 'Аптека.ру', 'Онлайн-аптека', 'health', 2.0, 1.0),
    ('eapteka', 'Еаптека', 'Онлайн-аптека', 'health', 2.0, 1.0),
    -- Развлечения
    ('kinopoisk', 'Кинопоиск', 'Онлайн-кинотеатр', 'entertainment', 5.0, 2.0),
    ('ivi', 'Иви', 'Онлайн-кинотеатр', 'entertainment', 5.0, 2.0),
    ('okko', 'Okko', 'Онлайн-кинотеатр', 'entertainment', 5.0, 2.0),
    ('yandex_plus', 'Яндекс Плюс', 'Подписка на сервисы Яндекса', 'entertainment', 5.0, 2.0),
    -- Транспорт и путешествия
    ('yandex_go', 'Яндекс Go', 'Такси и каршеринг', 'transport', 3.0, 1.5),
    ('citydrive', 'CityDrive', 'Каршеринг', 'transport', 3.0, 1.5),
    ('delimobil', 'Делимобиль', 'Каршеринг', 'transport', 3.0, 1.5),
    ('tutu', 'Туту.ру', 'Билеты на транспорт', 'travel', 2.0, 1.0),
    ('ozon_travel', 'Ozon Travel', 'Путешествия и отели', 'travel', 3.0, 1.5)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category = EXCLUDED.category,
    cashback_percent = EXCLUDED.cashback_percent,
    bonus_multiplier = EXCLUDED.bonus_multiplier;

-- Привязка логотипов к партнерам кэшбэка (добавленные логотипы)
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

CREATE INDEX IF NOT EXISTS idx_cashback_partners_code ON cashback_partners(code);
CREATE INDEX IF NOT EXISTS idx_cashback_partners_category ON cashback_partners(category);
CREATE INDEX IF NOT EXISTS idx_cashback_partners_active ON cashback_partners(is_active);

COMMENT ON TABLE card_types IS 'Типы карт для выпуска в приложении';
COMMENT ON TABLE payment_categories IS 'Категории платежей (ЖКХ, мобильная связь и т.д.)';
COMMENT ON TABLE payment_services IS 'Услуги и организации для оплаты';
COMMENT ON TABLE cashback_partners IS 'Магазины-партнеры для кэшбэка и бонусов';
