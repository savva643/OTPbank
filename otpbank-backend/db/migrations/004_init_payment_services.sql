-- ============================================
-- Миграция: Инициализация услуг/организаций для платежей
-- Описание: Создаёт таблицу услуг и заполняет начальными данными
-- ============================================

-- Создаём таблицу услуг
CREATE TABLE IF NOT EXISTS payment_services (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,        -- Код услуги (mts, sber и т.д.)
    name VARCHAR(100) NOT NULL,              -- Название услуги/организации
    description TEXT,                        -- Описание
    category_id INTEGER REFERENCES payment_categories(id) ON DELETE CASCADE,
    icon_color VARCHAR(9) DEFAULT '#FF0000',  -- Цвет иконки с прозрачностью (AARRGGBB)
    bg_color VARCHAR(9) DEFAULT '#33FF0000',  -- Цвет фона с прозрачностью (AARRGGBB)
    image_url TEXT,                          -- URL логотипа (если есть)
    is_popular BOOLEAN DEFAULT false,        -- Популярная услуга
    display_order INTEGER DEFAULT 0,         -- Порядок отображения
    is_active BOOLEAN DEFAULT true,          -- Активна ли услуга
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заполняем услуги по категориям (idempotent)

-- Мобильная связь
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular, display_order)
SELECT 'mts', 'МТС', 'Мобильная связь', pc.id, '#FFFF0033', '#33FF0033', true, 1
FROM payment_categories pc WHERE pc.code = 'mobile'
UNION ALL
SELECT 'beeline', 'Билайн', 'Мобильная связь', pc.id, '#FFFECC00', '#33FECC00', true, 2
FROM payment_categories pc WHERE pc.code = 'mobile'
UNION ALL
SELECT 'megafon', 'МегаФон', 'Мобильная связь', pc.id, '#FF00B2E5', '#3300B2E5', true, 3
FROM payment_categories pc WHERE pc.code = 'mobile'
UNION ALL
SELECT 'tele2', 'Tele2', 'Мобильная связь', pc.id, '#FFFF9900', '#33FF9900', true, 4
FROM payment_categories pc WHERE pc.code = 'mobile'
UNION ALL
SELECT 'yota', 'Yota', 'Мобильная связь', pc.id, '#FF00B2E5', '#3300B2E5', false, 5
FROM payment_categories pc WHERE pc.code = 'mobile'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category_id = EXCLUDED.category_id,
    icon_color = EXCLUDED.icon_color,
    bg_color = EXCLUDED.bg_color;

-- ЖКХ
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'mosenergosbyt', 'Мосэнергосбыт', 'Электроэнергия', pc.id, '#FFF59E0B', '#33F59E0B', true
FROM payment_categories pc WHERE pc.code = 'utilities'
UNION ALL
SELECT 'gazprom_mezhregiongaz', 'Газпром Межрегионгаз', 'Газоснабжение', pc.id, '#FFEF4444', '#33EF4444', true
FROM payment_categories pc WHERE pc.code = 'utilities'
UNION ALL
SELECT 'mosvodokanal', 'Мосводоканал', 'Водоснабжение', pc.id, '#FF3B82F6', '#333B82F6', true
FROM payment_categories pc WHERE pc.code = 'utilities'
UNION ALL
SELECT 'mosobleirc', 'МособлЕИРЦ', 'Единый расчетный центр', pc.id, '#FF8B5CF6', '#338B5CF6', false
FROM payment_categories pc WHERE pc.code = 'utilities'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category_id = EXCLUDED.category_id,
    icon_color = EXCLUDED.icon_color,
    bg_color = EXCLUDED.bg_color;

-- Интернет
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'rostelecom', 'Ростелеком', 'Интернет и ТВ', pc.id, '#FF910A60', '#33910A60', true
FROM payment_categories pc WHERE pc.code = 'internet'
UNION ALL
SELECT 'domru', 'Дом.ru', 'Интернет и ТВ', pc.id, '#FFEF4444', '#33EF4444', true
FROM payment_categories pc WHERE pc.code = 'internet'
UNION ALL
SELECT 'mts_internet', 'МТС Интернет', 'Домашний интернет', pc.id, '#FFFF0033', '#33FF0033', true
FROM payment_categories pc WHERE pc.code = 'internet'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category_id = EXCLUDED.category_id,
    icon_color = EXCLUDED.icon_color,
    bg_color = EXCLUDED.bg_color;

-- Штрафы
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'gibdd', 'Штрафы ГИБДД', 'Административные штрафы', pc.id, '#FFF59E0B', '#33F59E0B', true
FROM payment_categories pc WHERE pc.code = 'fines'
UNION ALL
SELECT 'parking', 'Штрафы парковки', 'Московский паркинг', pc.id, '#FFEF4444', '#33EF4444', true
FROM payment_categories pc WHERE pc.code = 'fines'
UNION ALL
SELECT 'fns', 'Налоги ФНС', 'Налоговые платежи', pc.id, '#FF0EA5E9', '#330EA5E9', true
FROM payment_categories pc WHERE pc.code = 'fines'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category_id = EXCLUDED.category_id,
    icon_color = EXCLUDED.icon_color,
    bg_color = EXCLUDED.bg_color;

-- Госуслуги
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'gosuslugi', 'Госуслуги', 'Портал госуслуг', pc.id, '#FF0EA5E9', '#330EA5E9', true
FROM payment_categories pc WHERE pc.code = 'government'
UNION ALL
SELECT 'fssp', 'Судебные задолженности', 'ФССП России', pc.id, '#FFDC2626', '#33DC2626', false
FROM payment_categories pc WHERE pc.code = 'government'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category_id = EXCLUDED.category_id,
    icon_color = EXCLUDED.icon_color,
    bg_color = EXCLUDED.bg_color;

-- Транспорт
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'troika', 'Тройка', 'Пополнение карты', pc.id, '#FFC4FF2E', '#33C4FF2E', true
FROM payment_categories pc WHERE pc.code = 'transport'
UNION ALL
SELECT 'parkon', 'Паркон', 'Оплата парковки', pc.id, '#FF84CC16', '#3384CC16', true
FROM payment_categories pc WHERE pc.code = 'transport'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category_id = EXCLUDED.category_id,
    icon_color = EXCLUDED.icon_color,
    bg_color = EXCLUDED.bg_color;

-- Финансы (переводы между банками)
INSERT INTO payment_services (code, name, description, category_id, icon_color, bg_color, is_popular)
SELECT 'sber', 'Сбербанк', 'Пополнение счета', pc.id, '#FF1AB248', '#331AB248', true
FROM payment_categories pc WHERE pc.code = 'finance'
UNION ALL
SELECT 'tinkoff', 'Тинькофф', 'Пополнение счета', pc.id, '#FFFFDD2D', '#33FFDD2D', true
FROM payment_categories pc WHERE pc.code = 'finance'
UNION ALL
SELECT 'vtb', 'ВТБ', 'Пополнение счета', pc.id, '#FF032973', '#33032973', true
FROM payment_categories pc WHERE pc.code = 'finance'
UNION ALL
SELECT 'alfa', 'Альфа-Банк', 'Пополнение счета', pc.id, '#FFED1C24', '#33ED1C24', true
FROM payment_categories pc WHERE pc.code = 'finance'
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category_id = EXCLUDED.category_id,
    icon_color = EXCLUDED.icon_color,
    bg_color = EXCLUDED.bg_color;

-- Создаём индексы
CREATE INDEX IF NOT EXISTS idx_payment_services_code ON payment_services(code);
CREATE INDEX IF NOT EXISTS idx_payment_services_category ON payment_services(category_id);
CREATE INDEX IF NOT EXISTS idx_payment_services_popular ON payment_services(is_popular);
CREATE INDEX IF NOT EXISTS idx_payment_services_active ON payment_services(is_active);

COMMENT ON TABLE payment_services IS 'Услуги и организации для оплаты';
