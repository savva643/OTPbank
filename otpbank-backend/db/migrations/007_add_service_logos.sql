-- Миграция: Привязка логотипов к услугам
-- Дата: 2026-03-15
-- Описание: Обновляет image_url для услуг с добавленными логотипами

-- Мобильная связь
UPDATE payment_services SET image_url = '/logos/services/mts.png' WHERE code = 'mts';
UPDATE payment_services SET image_url = '/logos/services/mts.png' WHERE code = 'mts_internet';
UPDATE payment_services SET image_url = '/logos/services/beeline.png' WHERE code = 'beeline';
UPDATE payment_services SET image_url = '/logos/services/megafon.png' WHERE code = 'megafon';
UPDATE payment_services SET image_url = '/logos/services/tele2.png' WHERE code = 'tele2';
UPDATE payment_services SET image_url = '/logos/services/yota.png' WHERE code = 'yota';

-- ЖКХ
UPDATE payment_services SET image_url = '/logos/services/mosenergysbit.png' WHERE code = 'mosenergosbyt';
UPDATE payment_services SET image_url = '/logos/services/regiongaz.png' WHERE code = 'gazprom_mezhregiongaz';
UPDATE payment_services SET image_url = '/logos/services/mosvodochanel.png' WHERE code = 'mosvodokanal';
UPDATE payment_services SET image_url = '/logos/services/mosobleric.png' WHERE code = 'mosobleirc';

-- Интернет
UPDATE payment_services SET image_url = '/logos/services/rostelecom.png' WHERE code = 'rostelecom';
UPDATE payment_services SET image_url = '/logos/services/domru.png' WHERE code = 'domru';

-- Банки (финансы)
UPDATE payment_services SET image_url = '/logos/services/sber.png' WHERE code = 'sber';
UPDATE payment_services SET image_url = '/logos/services/tbank.png' WHERE code = 'tinkoff';
UPDATE payment_services SET image_url = '/logos/services/vtb.png' WHERE code = 'vtb';
UPDATE payment_services SET image_url = '/logos/services/alfa.png' WHERE code = 'alfa';

-- Штрафы и госуслуги
UPDATE payment_services SET image_url = '/logos/services/gibdd.png' WHERE code = 'gibdd';
UPDATE payment_services SET image_url = '/logos/services/gosuslugi.png' WHERE code = 'gosuslugi';

-- Транспорт
UPDATE payment_services SET image_url = '/logos/services/troika.png' WHERE code = 'troika';
