-- Миграция: Добавление поля card_type_name в таблицу cards
-- Дата: 2026-03-15
-- Описание: Добавляет поле для хранения типа карты (только МИР с прикольными названиями)

ALTER TABLE cards ADD COLUMN IF NOT EXISTS card_type_name text;

-- Заполняем тестовые данные для существующих карт на основе product_type
UPDATE cards 
SET card_type_name = CASE 
    WHEN product_type = 'debit' THEN 'МИР Дебют'
    WHEN product_type = 'credit' THEN 'МИР Кредитка+'
    WHEN product_type = 'credit_card' THEN 'МИР Кредитка+'
    WHEN product_type = 'travel' THEN 'МИР Вокруг Света'
    WHEN product_type = 'kids' THEN 'МИР Малой'
    ELSE 'МИР Классик'
END
WHERE card_type_name IS NULL OR card_type_name = '';
