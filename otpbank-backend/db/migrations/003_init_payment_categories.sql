-- ============================================
-- Миграция: Инициализация категорий платежей
-- Описание: Создаёт таблицу категорий платежей и заполняет начальными данными
-- ============================================

-- Создаём таблицу категорий платежей
CREATE TABLE IF NOT EXISTS payment_categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,        -- Код категории (mobile, utilities и т.д.)
    name VARCHAR(100) NOT NULL,              -- Название категории
    icon_name VARCHAR(50),                   -- Название иконки (Material Icons)
    background_color VARCHAR(7) DEFAULT '#F1F5F9', -- Цвет фона (hex)
    display_order INTEGER DEFAULT 0,         -- Порядок отображения
    is_active BOOLEAN DEFAULT true,          -- Активна ли категория
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заполняем категории (idempotent)
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

-- Создаём индексы
CREATE INDEX IF NOT EXISTS idx_payment_categories_code ON payment_categories(code);
CREATE INDEX IF NOT EXISTS idx_payment_categories_order ON payment_categories(display_order);
CREATE INDEX IF NOT EXISTS idx_payment_categories_active ON payment_categories(is_active);

COMMENT ON TABLE payment_categories IS 'Категории платежей (ЖКХ, мобильная связь и т.д.)';
