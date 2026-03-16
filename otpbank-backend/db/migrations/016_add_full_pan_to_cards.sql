-- Добавляем поле pan (полный номер карты) для тестового стенда
ALTER TABLE cards ADD COLUMN IF NOT EXISTS pan TEXT;

-- Для существующих карт: если pan пустой, генерируем случайный 16-значный номер
UPDATE cards
SET pan = LPAD((FLOOR(RANDOM() * 10000000000000000))::bigint::text, 16, '0')
WHERE pan IS NULL OR TRIM(pan) = '';
