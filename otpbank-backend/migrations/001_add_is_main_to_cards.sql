-- Добавляем поле is_main для определения основной карты счёта
ALTER TABLE cards ADD COLUMN IF NOT EXISTS is_main BOOLEAN NOT NULL DEFAULT false;

-- Устанавливаем первую карту каждого счёта как основную
UPDATE cards c1
SET is_main = true
WHERE c1.id = (
    SELECT c2.id FROM cards c2
    WHERE c2.account_id = c1.account_id
    ORDER BY c2.created_at ASC
    LIMIT 1
);

-- Создаём индекс для быстрого поиска основных карт
CREATE INDEX IF NOT EXISTS idx_cards_is_main ON cards(is_main);
