-- Migration: align users full_name usage + make seed tables idempotent

SET client_encoding TO 'UTF8';

-- 1) users: backfill name from full_name if needed
UPDATE users
SET name = split_part(trim(full_name), ' ', 1)
WHERE (name IS NULL OR trim(name) = '')
  AND full_name IS NOT NULL
  AND trim(full_name) <> '';

-- 1.0) users: store full name parts
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS middle_name text;

UPDATE users
SET
  last_name = NULLIF(split_part(trim(full_name), ' ', 1), ''),
  first_name = NULLIF(split_part(trim(full_name), ' ', 2), ''),
  middle_name = NULLIF(split_part(trim(full_name), ' ', 3), '')
WHERE full_name IS NOT NULL
  AND trim(full_name) <> ''
  AND (last_name IS NULL OR first_name IS NULL);

-- If name contains multiple words or equals full_name, keep short name = first_name (or fallback)
UPDATE users
SET name = COALESCE(NULLIF(first_name, ''), NULLIF(split_part(trim(full_name), ' ', 1), ''), name)
WHERE full_name IS NOT NULL
  AND trim(full_name) <> ''
  AND (
    name IS NULL OR trim(name) = '' OR
    name = full_name OR
    position(' ' in trim(name)) > 0
  );

-- 1.1) cards: add UI styling columns if missing
ALTER TABLE cards ADD COLUMN IF NOT EXISTS label text;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS bg_color1 text;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS bg_color2 text;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS pin_hash text;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS cvc text;

-- 1.1.0) cards: extend status enum for blocking
ALTER TYPE card_status ADD VALUE IF NOT EXISTS 'blocked';

-- 1.1.a) accounts: requisites fields
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS account_number text;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS bic text;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS bank_name text;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS corr_account text;

UPDATE accounts
SET bank_name = COALESCE(bank_name, 'OTPbank')
WHERE bank_name IS NULL;

UPDATE accounts
SET bic = COALESCE(bic, '044525225')
WHERE bic IS NULL;

UPDATE accounts
SET corr_account = COALESCE(corr_account, '30101810400000000225')
WHERE corr_account IS NULL;

-- Generate 20-digit account number from id if missing
UPDATE accounts
SET account_number = substring(translate(md5(id::text), 'abcdef', '123456') || translate(md5(user_id::text), 'abcdef', '123456'), 1, 20)
WHERE account_number IS NULL OR trim(account_number) = '';

-- 1.1.1) cards: normalize legacy product_type values
UPDATE cards
SET product_type = CASE
  WHEN product_type = 'debit_card' THEN 'debit'
  WHEN product_type = 'credit_card' THEN 'credit'
  ELSE product_type
END
WHERE product_type IN ('debit_card', 'credit_card');

-- 1.1.2) cards: backfill styling fields for existing rows
UPDATE cards
SET label = COALESCE(label,
  CASE
    WHEN product_type = 'credit' THEN 'Кредитная'
    WHEN product_type = 'travel' THEN 'Путешествия'
    ELSE 'Дебетовая'
  END
),
bg_color1 = COALESCE(bg_color1,
  CASE
    WHEN product_type = 'credit' THEN '#9E6FC3'
    WHEN product_type = 'travel' THEN '#C4FF2E'
    ELSE '#0F172A'
  END
),
bg_color2 = COALESCE(bg_color2,
  CASE
    WHEN product_type = 'credit' THEN '#4F46E5'
    WHEN product_type = 'travel' THEN '#C8E1FC'
    ELSE '#1E293B'
  END
)
WHERE label IS NULL OR bg_color1 IS NULL OR bg_color2 IS NULL;

-- 1.1.3) cards: backfill demo CVC
UPDATE cards
SET cvc = COALESCE(cvc, '123')
WHERE cvc IS NULL OR trim(cvc) = '';

-- 1.2) stories: add code column for media generator
ALTER TABLE stories ADD COLUMN IF NOT EXISTS code text;
ALTER TABLE stories ADD COLUMN IF NOT EXISTS cta_label text;
ALTER TABLE stories ADD COLUMN IF NOT EXISTS cta_action text;
ALTER TABLE stories ADD COLUMN IF NOT EXISTS cta_payload text;
CREATE UNIQUE INDEX IF NOT EXISTS uq_stories_code ON stories(code);

-- 1.3) stories: backfill code + switch URLs to local generated media
UPDATE stories
SET code = CASE
  WHEN title = 'Для вас' THEN 'for-you'
  WHEN title = 'Кэшбэк 10%' THEN 'cashback10'
  WHEN title = 'Новое в приложении' THEN 'updates'
  ELSE code
END
WHERE code IS NULL OR trim(code) = '';

UPDATE stories
SET mini_image_url = CASE
  WHEN code = 'for-you' THEN 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Chinggis_Khan_hillside_portrait.JPG/168px-Chinggis_Khan_hillside_portrait.JPG'
  WHEN code = 'cashback10' THEN 'https://media.giphy.com/media/3o7aD2saalBwwftBIY/giphy.gif'
  WHEN code = 'updates' THEN 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Taj_Mahal_in_March_2004.jpg/168px-Taj_Mahal_in_March_2004.jpg'
  ELSE mini_image_url
END,
media_url = CASE
  WHEN code = 'for-you' THEN 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Chinggis_Khan_hillside_portrait.JPG/1080px-Chinggis_Khan_hillside_portrait.JPG'
  WHEN code = 'cashback10' THEN 'https://media.giphy.com/media/3o7aD2saalBwwftBIY/giphy.gif'
  WHEN code = 'updates' THEN 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Taj_Mahal_in_March_2004.jpg/1080px-Taj_Mahal_in_March_2004.jpg'
  ELSE media_url
END,
media_type = CASE
  WHEN code = 'cashback10' THEN 'gif'
  ELSE 'photo'
END
WHERE (mini_image_url IS NULL OR trim(mini_image_url) = '' OR mini_image_url LIKE 'http%')
   OR (media_url IS NULL OR trim(media_url) = '' OR media_url LIKE 'http%');

UPDATE stories
SET cta_label = COALESCE(cta_label,
  CASE
    WHEN code = 'for-you' THEN U&'\041E\0442\043A\0440\044B\0442\044C \0432\0438\0442\0440\0438\043D\0443'
    WHEN code = 'cashback10' THEN U&'\041F\043E\043D\044F\0442\043D\043E'
    WHEN code = 'updates' THEN U&'\041E\043A'
    ELSE NULL
  END
),
cta_action = COALESCE(cta_action,
  CASE
    WHEN code = 'for-you' THEN 'open_showcase'
    WHEN code = 'cashback10' THEN 'close'
    WHEN code = 'updates' THEN 'close'
    ELSE NULL
  END
),
cta_payload = COALESCE(cta_payload, NULL)
WHERE code IN ('for-you', 'cashback10', 'updates');

-- If cta_label already broken (question marks), overwrite with safe ASCII
UPDATE stories
SET cta_label = CASE
  WHEN code = 'for-you' THEN U&'\041E\0442\043A\0440\044B\0442\044C \0432\0438\0442\0440\0438\043D\0443'
  WHEN code = 'cashback10' THEN U&'\041F\043E\043D\044F\0442\043D\043E'
  WHEN code = 'updates' THEN U&'\041E\043A'
  ELSE cta_label
END
WHERE code IN ('for-you', 'cashback10', 'updates')
  AND (
    cta_label LIKE '%?%'
    OR cta_label IN ('Open showcase', 'Got it', 'OK')
    OR cta_label ~ '^[\x00-\x7F]+$'
  );

-- 2) product_offers unique constraint to support ON CONFLICT (product_id, title)
CREATE UNIQUE INDEX IF NOT EXISTS uq_product_offers_product_title ON product_offers(product_id, title);

-- 3) product_features unique constraint to support ON CONFLICT (product_id, title)
CREATE UNIQUE INDEX IF NOT EXISTS uq_product_features_product_title ON product_features(product_id, title);

-- 3.1) product_widgets: configurable product page blocks
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

-- Demo CTAs for Travel product and Cashback
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

-- More realistic bank products + CTAs
INSERT INTO product_categories (name)
VALUES
  ('Бизнес'),
  ('Страхование')
ON CONFLICT (name) DO NOTHING;

INSERT INTO products (category_id, name, description, image_url)
VALUES
  ((SELECT id FROM product_categories WHERE name = 'Ежедневные траты' LIMIT 1), 'Дебетовая карта Cashback', 'До 5% кэшбэк в выбранных категориях', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Ежедневные траты' LIMIT 1), 'Кредитная карта', 'Льготный период и рассрочка', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Страхование' LIMIT 1), 'Страхование путешествий', 'Покрытие здоровья и багажа в поездках', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Страхование' LIMIT 1), 'Страхование авто', 'КАСКО/ОСАГО с оформлением онлайн', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Бизнес' LIMIT 1), 'Расчётный счёт для бизнеса', 'Счёт, эквайринг и переводы без лишних комиссий', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Подписки' LIMIT 1), 'OTP Premium+', 'Премиум-сервисы: кэшбэк, переводы, консьерж', NULL)
ON CONFLICT (category_id, name) DO NOTHING;

-- Debit card Cashback -> issue card
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Дебетовая карта Cashback',
  'Кэшбэк каждый месяц — выпуск онлайн за 1 минуту',
  'percent',
  '#FFF1F5F9',
  '#66E2E8F0',
  'Оформить карту',
  'card_issue',
  'debit',
  jsonb_build_object('gradient', jsonb_build_array('#0F172A', '#9E6FC3')),
  10
FROM products p
WHERE lower(p.name) = 'дебетовая карта cashback'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner' AND w.cta_action = 'card_issue'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'card',
  'Как начисляется кэшбэк',
  'Покажем условия и примеры расчёта (демо).',
  'info',
  '#FFFFFF',
  '#F1F5F9',
  'Условия',
  'show_toast',
  'Условия кэшбэка: категории + лимиты (демо)',
  NULL,
  20
FROM products p
WHERE lower(p.name) = 'дебетовая карта cashback'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'card' AND w.title = 'Как начисляется кэшбэк'
  );

-- Credit card -> issue card (credit)
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Кредитная карта',
  'Льготный период до 120 дней (демо)',
  'bolt',
  '#FFF5F3FF',
  '#66E9D5FF',
  'Оформить карту',
  'card_issue',
  'credit',
  jsonb_build_object('gradient', jsonb_build_array('#9E6FC3', '#4F46E5')),
  10
FROM products p
WHERE lower(p.name) = 'кредитная карта'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner' AND w.cta_action = 'card_issue'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'stepper',
  'Как оформить',
  NULL,
  'check',
  '#FFFFFF',
  '#F1F5F9',
  'Заполнить заявку',
  'show_toast',
  'Заявка на кредитную карту отправлена (демо)',
  jsonb_build_object('steps', jsonb_build_array('Выберите счёт', 'Подтвердите выпуск', 'Получите карту в приложении')),
  20
FROM products p
WHERE lower(p.name) = 'кредитная карта'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'stepper' AND w.title = 'Как оформить'
  );

-- Insurance products -> show_toast
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Страхование путешествий',
  'Покрытие здоровья и багажа за границей',
  'shield',
  '#FFF1F5F9',
  '#66E2E8F0',
  'Оформить полис',
  'show_toast',
  'Оформление страховки будет доступно в следующей версии (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#0F172A', '#FF7D32')),
  10
FROM products p
WHERE lower(p.name) = 'страхование путешествий'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'card',
  'Что входит',
  'Медицинская помощь, багаж, задержка рейса (демо).',
  'info',
  '#FFFFFF',
  '#F1F5F9',
  'Смотреть',
  'show_toast',
  'Покрытие: здоровье/багаж/рейс (демо)',
  NULL,
  20
FROM products p
WHERE lower(p.name) = 'страхование путешествий'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'card' AND w.title = 'Что входит'
  );

-- Business account -> show_toast/open_screen
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Расчётный счёт для бизнеса',
  'Откройте счёт онлайн и принимайте платежи',
  'business',
  '#FFF1F5F9',
  '#66E2E8F0',
  'Открыть счёт',
  'show_toast',
  'Заявка на бизнес-счёт отправлена (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#0F172A', '#1E293B')),
  10
FROM products p
WHERE lower(p.name) = 'расчётный счёт для бизнеса'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

-- Premium subscription -> open investments as demo feature + show_toast
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'OTP Premium+',
  'Кэшбэк, переводы и сервисы без комиссий',
  'star',
  '#FFF5F3FF',
  '#66E9D5FF',
  'Подключить',
  'show_toast',
  'Premium подключён (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#9E6FC3', '#0F172A')),
  10
FROM products p
WHERE lower(p.name) = 'otp premium+'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'card',
  'Инвестиции для Premium',
  'Откройте рынок инструментов (демо-экран).',
  'chart',
  '#FFFFFF',
  '#F1F5F9',
  'Открыть',
  'open_screen',
  'investments',
  NULL,
  20
FROM products p
WHERE lower(p.name) = 'otp premium+'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'card' AND w.cta_action = 'open_screen' AND w.cta_payload = 'investments'
  );

-- Demo CTAs for credits/loans/mortgage/auto (no backend logic needed)
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Ипотека',
  'Подберём программу и покажем пример платежа (демо)',
  'home',
  '#FFF1F5F9',
  '#66E2E8F0',
  'Рассчитать',
  'show_toast',
  'Расчёт ипотеки: ставка/срок/платёж (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#0F172A', '#64748B')),
  10
FROM products p
WHERE lower(p.name) = 'ипотека'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'stepper',
  'Как получить предодобрение',
  NULL,
  'check',
  '#FFFFFF',
  '#F1F5F9',
  'Оставить заявку',
  'show_toast',
  'Заявка на ипотеку отправлена (демо)',
  jsonb_build_object('steps', jsonb_build_array('Заполните анкету', 'Подтвердите доход', 'Получите решение онлайн')),
  20
FROM products p
WHERE lower(p.name) = 'ипотека'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'stepper' AND w.title = 'Как получить предодобрение'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Автокредит',
  'Рассчитаем платёж и оформим заявку (демо)',
  'car',
  '#FFF1F5F9',
  '#66E2E8F0',
  'Рассчитать',
  'show_toast',
  'Калькулятор автокредита (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#0F172A', '#0EA5E9')),
  10
FROM products p
WHERE lower(p.name) = 'автокредит'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'card',
  'КАСКО и ОСАГО',
  'Поможем оформить страховку вместе с кредитом (демо).',
  'shield',
  '#FFFFFF',
  '#F1F5F9',
  'Оформить',
  'show_toast',
  'Оформление страховки авто (демо)',
  NULL,
  20
FROM products p
WHERE lower(p.name) = 'автокредит'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'card' AND w.title = 'КАСКО и ОСАГО'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Кредит наличными',
  'Сумма до 3 000 000 ₽ — решение за 2 минуты (демо)',
  'bolt',
  '#FFF5F3FF',
  '#66E9D5FF',
  'Взять деньги',
  'show_toast',
  'Заявка на кредит наличными отправлена (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#9E6FC3', '#0F172A')),
  10
FROM products p
WHERE lower(p.name) = 'кредит наличными'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'stepper',
  'Как получить',
  NULL,
  'check',
  '#FFFFFF',
  '#F1F5F9',
  'Оставить заявку',
  'show_toast',
  'Заявка на кредит наличными отправлена (демо)',
  jsonb_build_object('steps', jsonb_build_array('Введите сумму', 'Подтвердите данные', 'Получите решение')),
  20
FROM products p
WHERE lower(p.name) = 'кредит наличными'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'stepper' AND w.title = 'Как получить'
  );

INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Займ до зарплаты',
  'Быстро: небольшая сумма на короткий срок (демо)',
  'bolt',
  '#FFF1F5F9',
  '#66E2E8F0',
  'Получить займ',
  'show_toast',
  'Заявка на займ до зарплаты отправлена (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#0F172A', '#FF7D32')),
  10
FROM products p
WHERE lower(p.name) = 'займ до зарплаты'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

-- Currency exchange -> demo
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'banner',
  'Обмен валют',
  'Курс и конвертация онлайн (демо)',
  'currency_exchange',
  '#FFF1F5F9',
  '#66E2E8F0',
  'Обменять',
  'show_toast',
  'Обмен валют: выбери валюту и сумму (демо)',
  jsonb_build_object('gradient', jsonb_build_array('#0EA5E9', '#0F172A')),
  10
FROM products p
WHERE lower(p.name) = 'обмен валют'
  AND NOT EXISTS (
    SELECT 1 FROM product_widgets w
    WHERE w.product_id = p.id AND w.type = 'banner'
  );

-- Investments CTA for Invest Piggy (open investments screen)
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
SELECT
  p.id,
  'card',
  'Рынок инструментов',
  'Валюты, акции и крипто (демо-экран).',
  'chart',
  '#FFFFFF',
  '#F1F5F9',
  'Открыть',
  'open_screen',
  'investments',
  NULL,
  50
FROM products p
WHERE lower(p.name) = 'инвесткопилка'
  AND NOT EXISTS (
    SELECT 1
    FROM product_widgets w
    WHERE w.product_id = p.id AND w.cta_action = 'open_screen' AND w.cta_payload = 'investments'
  );

-- 4) scenarios unique constraint to support ON CONFLICT (title)
CREATE UNIQUE INDEX IF NOT EXISTS uq_scenarios_title ON scenarios(title);

-- 5) stories unique constraint to support ON CONFLICT (title)
CREATE UNIQUE INDEX IF NOT EXISTS uq_stories_title ON stories(title);
