-- Исправление кодировки для категорий платежей
UPDATE payment_categories SET name = 'Мобильная связь' WHERE code = 'mobile';
UPDATE payment_categories SET name = 'ЖКХ' WHERE code = 'utilities';
UPDATE payment_categories SET name = 'Интернет и ТВ' WHERE code = 'internet';
UPDATE payment_categories SET name = 'Штрафы и налоги' WHERE code = 'fines';
UPDATE payment_categories SET name = 'Госуслуги' WHERE code = 'government';
UPDATE payment_categories SET name = 'Транспорт' WHERE code = 'transport';
UPDATE payment_categories SET name = 'Образование' WHERE code = 'education';
UPDATE payment_categories SET name = 'Здоровье' WHERE code = 'health';
UPDATE payment_categories SET name = 'Страхование' WHERE code = 'insurance';
UPDATE payment_categories SET name = 'Финансы' WHERE code = 'finance';
UPDATE payment_categories SET name = 'Развлечения' WHERE code = 'entertainment';
UPDATE payment_categories SET name = 'Шопинг' WHERE code = 'shopping';
