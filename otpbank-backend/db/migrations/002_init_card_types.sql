-- ============================================
-- Миграция: Инициализация типов карт
-- Описание: Создаёт таблицу типов карт и заполняет начальными данными
-- ============================================

-- Создаём таблицу типов карт, если не существует
CREATE TABLE IF NOT EXISTS card_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,           -- Код типа (для API)
    name VARCHAR(100) NOT NULL,                  -- Название типа (отображаемое)
    description TEXT,                            -- Описание
    card_design VARCHAR(50),                     -- Дизайн карты (цвет/тема)
    daily_limit NUMERIC(15, 2) DEFAULT 100000,   -- Дневной лимит
    monthly_limit NUMERIC(15, 2) DEFAULT 1000000,-- Месячный лимит
    has_cashback BOOLEAN DEFAULT false,          -- Есть ли кэшбэк
    has_bonuses BOOLEAN DEFAULT false,         -- Есть ли бонусы
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заполняем начальными данными (idempotent - не дублирует при повторном запуске)
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

-- Создаём индексы
CREATE INDEX IF NOT EXISTS idx_card_types_code ON card_types(code);

-- Добавляем поле card_type_id в таблицу cards (если ещё не добавлено)
ALTER TABLE cards ADD COLUMN IF NOT EXISTS card_type_id INTEGER REFERENCES card_types(id);

-- Обновляем существующие карты, устанавливая стандартный тип если не задан
UPDATE cards SET card_type_id = (SELECT id FROM card_types WHERE code = 'standard' LIMIT 1)
WHERE card_type_id IS NULL;

COMMENT ON TABLE card_types IS 'Типы карт для выпуска в приложении';
