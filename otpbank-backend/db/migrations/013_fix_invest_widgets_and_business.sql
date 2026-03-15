-- Миграция: Исправление дублирующихся виджетов в Инвесткопилке
-- Дата: 2026-03-15
-- Описание: Удаляет дублирующиеся виджеты и добавляет бизнес-продукты

-- ============================================
-- 1. Удаляем дублирующиеся виджеты Инвесткопилки
-- ============================================

-- Удаляем дубликаты виджетов для Инвесткопилки (оставляем только один набор)
DELETE FROM product_widgets 
WHERE product_id = (SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1)
  AND ctid NOT IN (
    SELECT MIN(ctid) 
    FROM product_widgets 
    WHERE product_id = (SELECT id FROM products WHERE name = 'Инвесткопилка' LIMIT 1)
    GROUP BY type, title
  );

-- ============================================
-- 2. Добавляем бизнес-категорию и продукты
-- ============================================

-- Добавляем категорию для бизнеса
INSERT INTO product_categories (name) VALUES ('Бизнес')
ON CONFLICT (name) DO NOTHING;

-- Добавляем бизнес-продукты
INSERT INTO products (category_id, name, description, image_url)
VALUES
  ((SELECT id FROM product_categories WHERE name = 'Бизнес' LIMIT 1), 'Бизнес-счёт', 'Расчётный счёт для ИП и малого бизнеса', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Бизнес' LIMIT 1), 'Овердрафт для бизнеса', 'Кредитная линия на расчётном счёте', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Бизнес' LIMIT 1), 'Бизнес-карта', 'Корпоративная карта для расходов', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Бизнес' LIMIT 1), 'Рко', 'Расчётно-кассовое обслуживание', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Бизнес' LIMIT 1), 'Эквайринг', 'Приём платежей картой', NULL),
  ((SELECT id FROM product_categories WHERE name = 'Бизнес' LIMIT 1), 'Зарплатный проект', 'Выплата зарплаты сотрудникам', NULL)
ON CONFLICT (category_id, name) DO NOTHING;

-- Добавляем офферы для бизнес-продуктов
INSERT INTO product_offers (product_id, kicker, title, description, image_url, bg_color, border_color, cta_label, cta_color, sort_order)
VALUES
  ((SELECT id FROM products WHERE name = 'Бизнес-счёт' LIMIT 1), 'МАЛЫЙ БИЗНЕС', 'Бизнес-счёт', 'Открытие за 5 минут без посещения банка', NULL, '#FFF1F5F9', '#7FE2E8F0', 'Открыть', '#0F172A', 10),
  ((SELECT id FROM products WHERE name = 'Овердрафт для бизнеса' LIMIT 1), 'ФИНАНСИРОВАНИЕ', 'Овердрафт', 'Кредитная линия до 5 млн ₽', NULL, '#FFFFEDD5', '#66FFEDD5', 'Подробнее', '#FF7D32', 20),
  ((SELECT id FROM products WHERE name = 'Бизнес-карта' LIMIT 1), 'КАРТЫ', 'Бизнес-карта', 'Кешбэк до 3% на бизнес-расходы', NULL, '#1AC4FF2E', '#33C4FF2E', 'Оформить', '#0F172A', 30),
  ((SELECT id FROM products WHERE name = 'Эквайринг' LIMIT 1), 'ПРИЁМ ПЛАТЕЖЕЙ', 'Эквайринг', 'Ставка от 1.5% на приём карт', NULL, '#1A9E6FC3', '#339E6FC3', 'Подключить', '#4F46E5', 40),
  ((SELECT id FROM products WHERE name = 'Зарплатный проект' LIMIT 1), 'СОТРУДНИКИ', 'Зарплатный проект', 'Бесплатное обслуживание до 10 сотрудников', NULL, '#FFDBEAFE', '#66DBEAFE', 'Рассчитать', '#2563EB', 50)
ON CONFLICT (product_id, title) DO NOTHING;

-- Добавляем виджеты для бизнес-продуктов
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
VALUES
  (
    (SELECT id FROM products WHERE name = 'Бизнес-счёт' LIMIT 1),
    'banner',
    'Бизнес-счёт',
    'Откройте счёт онлайн за 5 минут без визита в банк',
    'business',
    '#FFF3E8FF',
    '#66E9D5FF',
    'Открыть',
    'open',
    'business_account',
    jsonb_build_object('gradient', jsonb_build_array('#C4FF2E', '#F1F5F9', '#FFFFFF')),
    10
  ),
  (
    (SELECT id FROM products WHERE name = 'Бизнес-счёт' LIMIT 1),
    'card',
    'Тарифы РКО',
    'От 0 ₽ в месяц при обороте до 1 млн ₽',
    'account_balance',
    '#FFFFFF',
    '#F1F5F9',
    'Тарифы',
    'show_toast',
    'Тарифы подробнее в приложении',
    NULL,
    20
  ),
  (
    (SELECT id FROM products WHERE name = 'Эквайринг' LIMIT 1),
    'banner',
    'Эквайринг',
    'Приём платежей картой онлайн и офлайн',
    'credit_card',
    '#FFFFEDD5',
    '#66FFEDD5',
    'Подключить',
    'open',
    'acquiring',
    jsonb_build_object('gradient', jsonb_build_array('#FF7D32', '#9E6FC3')),
    10
  ),
  (
    (SELECT id FROM products WHERE name = 'Овердрафт для бизнеса' LIMIT 1),
    'card',
    'Лимит до 5 млн',
    'Проценты только на использованную сумму',
    'trending_up',
    '#FFFFFF',
    '#F1F5F9',
    'Подробнее',
    'open',
    'overdraft',
    NULL,
    10
  )
ON CONFLICT DO NOTHING;

-- Добавляем фичи для бизнес-продуктов
INSERT INTO product_features (product_id, title, description, icon, sort_order)
VALUES
  ((SELECT id FROM products WHERE name = 'Бизнес-счёт' LIMIT 1), 'Открытие онлайн', 'Без визита в банк и бумажных документов', 'check', 10),
  ((SELECT id FROM products WHERE name = 'Бизнес-счёт' LIMIT 1), 'Бесплатные переводы', 'До 50 переводов в месяц без комиссии', 'swap_horiz', 20),
  ((SELECT id FROM products WHERE name = 'Бизнес-счёт' LIMIT 1), 'Мобильный банк', 'Управление счётом в приложении 24/7', 'phone_android', 30),
  ((SELECT id FROM products WHERE name = 'Эквайринг' LIMIT 1), 'Онлайн-оплата', 'Приём платежей на сайте', 'language', 10),
  ((SELECT id FROM products WHERE name = 'Эквайринг' LIMIT 1), 'POS-терминал', 'Оборудование для офлайн-продаж', 'storefront', 20),
  ((SELECT id FROM products WHERE name = 'Эквайринг' LIMIT 1), 'Вывод за 1 день', 'Быстрый зачисление на счёт', 'timer', 30),
  ((SELECT id FROM products WHERE name = 'Овердрафт для бизнеса' LIMIT 1), 'Решение за 1 час', 'Быстрое одобрение онлайн', 'check', 10),
  ((SELECT id FROM products WHERE name = 'Овердрафт для бизнеса' LIMIT 1), 'Без залога', 'Только по выписке из банка', 'shield', 20)
ON CONFLICT (product_id, title) DO NOTHING;
