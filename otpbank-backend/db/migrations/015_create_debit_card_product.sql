-- Миграция: Создание продукта Дебетовая ОТП Карта
-- Дата: 2026-03-15
-- Описание: Создает продукт дебетовой карты с виджетами и возможностью оформления

-- Создаем категорию для карт если не существует
INSERT INTO product_categories (name)
VALUES ('Карты')
ON CONFLICT (name) DO NOTHING;

-- Создаем продукт Дебетовая ОТП Карта
INSERT INTO products (category_id, name, description, image_url)
VALUES (
  (SELECT id FROM product_categories WHERE name = 'Карты' LIMIT 1),
  'Дебетовая ОТП Карта',
  'Бесплатная дебетовая карта с кэшбэком до 3 000 ₽ каждый месяц и бесплатным обслуживанием',
  '/stories/14-lama-main.png'
)
ON CONFLICT (category_id, name) DO UPDATE SET
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url;

-- Добавляем оффер для продукта
INSERT INTO product_offers (product_id, kicker, title, description, image_url, bg_color, border_color, cta_label, cta_color, sort_order)
VALUES (
  (SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1),
  'КАРТЫ',
  'Дебетовая ОТП Карта',
  'Кэшбэк до 3 000 ₽ каждый месяц и бесплатное обслуживание',
  '/stories/14-lama-main.png',
  '#FFFFEDD5',
  '#66FFEDD5',
  'Оформить',
  '#FF7D32',
  10
)
ON CONFLICT (product_id, title) DO UPDATE SET
  kicker = EXCLUDED.kicker,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url,
  bg_color = EXCLUDED.bg_color,
  border_color = EXCLUDED.border_color,
  cta_label = EXCLUDED.cta_label,
  cta_color = EXCLUDED.cta_color,
  sort_order = EXCLUDED.sort_order;

-- Добавляем виджеты для продукта

-- Banner виджет
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
VALUES (
  (SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1),
  'banner',
  'Дебетовая ОТП Карта',
  'Бесплатная карта с кэшбэком до 3 000 ₽ каждый месяц',
  'credit_card',
  '#FFFFEDD5',
  '#66FFEDD5',
  'Оформить карту',
  'card_issue',
  'otp-debit',
  jsonb_build_object('gradient', jsonb_build_array('#FF7D32', '#C4FF2E')),
  10
)
ON CONFLICT DO NOTHING;

-- Карточка с информацией о кэшбэке
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
VALUES (
  (SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1),
  'card',
  'Кэшбэк до 3 000 ₽',
  'Каждый месяц возвращаем до 3 000 ₽ за покупки в любимых категориях',
  'percent',
  '#FFFFFF',
  '#F1F5F9',
  'Подробнее',
  'show_toast',
  'Кэшбэк начисляется за покупки в категориях: продукты, транспорт, развлечения',
  NULL,
  20
)
ON CONFLICT DO NOTHING;

-- Карточка с информацией о бесплатном обслуживании
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
VALUES (
  (SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1),
  'card',
  'Бесплатное обслуживание',
  'Никаких скрытых платежей и комиссий за обслуживание карты',
  'check_circle',
  '#FFFFFF',
  '#F1F5F9',
  'Условия',
  'show_toast',
  'Бесплатное обслуживание при условии любой операции в месяц',
  NULL,
  30
)
ON CONFLICT DO NOTHING;

-- FAQ виджет
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
VALUES (
  (SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1),
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
      jsonb_build_object('q', 'Сколько стоит оформление карты?', 'a', 'Оформление и доставка карты бесплатные.'),
      jsonb_build_object('q', 'Как получить кэшбэк?', 'a', 'Кэшбэк начисляется автоматически за покупки в выбранных категориях.'),
      jsonb_build_object('q', 'Можно ли снимать наличные?', 'a', 'Да, бесплатное снятие наличных в банкоматах ОТП и партнеров.')
    )
  ),
  40
)
ON CONFLICT DO NOTHING;

-- Stepper виджет - как оформить
INSERT INTO product_widgets (product_id, type, title, subtitle, icon, bg_color, border_color, cta_label, cta_action, cta_payload, payload, sort_order)
VALUES (
  (SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1),
  'stepper',
  'Как оформить карту',
  NULL,
  NULL,
  NULL,
  NULL,
  'Оформить',
  'card_issue',
  'otp-debit',
  jsonb_build_object(
    'steps', jsonb_build_array(
      'Заполните заявку онлайн',
      'Получите карту курьером или в отделении',
      'Активируйте карту в приложении'
    )
  ),
  50
)
ON CONFLICT DO NOTHING;

-- Добавляем фичи продукта
INSERT INTO product_features (product_id, title, description, icon, sort_order)
VALUES
  ((SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1), 'Кэшбэк до 3 000 ₽', 'Ежемесячный кэшбэк за покупки в популярных категориях', 'percent', 10),
  ((SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1), 'Бесплатное обслуживание', 'Никаких скрытых платежей', 'check', 20),
  ((SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1), 'Бесплатные переводы', 'Переводы между своими счетами без комиссии', 'sync_alt', 30),
  ((SELECT id FROM products WHERE name = 'Дебетовая ОТП Карта' LIMIT 1), 'Apple Pay / Google Pay', 'Оплата телефоном в магазинах и онлайн', 'smartphone', 40)
ON CONFLICT (product_id, title) DO NOTHING;
