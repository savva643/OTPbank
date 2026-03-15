-- Миграция: Создание таблиц для Дома и Авто с автоплатежами
-- Дата: 2026-03-15

-- Таблица объектов недвижимости (Дом/Квартира)
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

-- Таблица автомобилей
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

-- Таблица автоплатежей (универсальная для дома и авто)
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

-- Индексы
CREATE INDEX IF NOT EXISTS idx_user_properties_user_id ON user_properties(user_id);
CREATE INDEX IF NOT EXISTS idx_user_vehicles_user_id ON user_vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_autopayments_user_id ON autopayments(user_id);
CREATE INDEX IF NOT EXISTS idx_autopayments_property_id ON autopayments(property_id);
CREATE INDEX IF NOT EXISTS idx_autopayments_vehicle_id ON autopayments(vehicle_id);

-- Комментарии
COMMENT ON TABLE user_properties IS 'Недвижимость пользователей (дома, квартиры)';
COMMENT ON TABLE user_vehicles IS 'Транспорт пользователей';
COMMENT ON TABLE autopayments IS 'Автоплатежи для дома и авто';
