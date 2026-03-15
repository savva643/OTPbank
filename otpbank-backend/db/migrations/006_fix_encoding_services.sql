-- Исправление кодировки для услуг
UPDATE payment_services SET name = 'МТС' WHERE code = 'mts';
UPDATE payment_services SET name = 'Билайн' WHERE code = 'beeline';
UPDATE payment_services SET name = 'МегаФон' WHERE code = 'megafon';
UPDATE payment_services SET name = 'Tele2' WHERE code = 'tele2';
UPDATE payment_services SET name = 'Yota' WHERE code = 'yota';
UPDATE payment_services SET name = 'Ростелеком' WHERE code = 'rostelecom_mobile';
UPDATE payment_services SET name = 'Мосэнергосбыт' WHERE code = 'mosenergosbyt';
UPDATE payment_services SET name = 'Газпром Межрегионгаз' WHERE code = 'gazprom_mezhregiongaz';
UPDATE payment_services SET name = 'Мосводоканал' WHERE code = 'mosvodokanal';
UPDATE payment_services SET name = 'МособлЕИРЦ' WHERE code = 'mosobleirc';
UPDATE payment_services SET name = 'Ростелеком' WHERE code = 'rostelecom';
UPDATE payment_services SET name = 'Дом.ru' WHERE code = 'domru';
UPDATE payment_services SET name = 'МТС Интернет' WHERE code = 'mts_internet';
UPDATE payment_services SET name = 'Штрафы ГИБДД' WHERE code = 'gibdd';
UPDATE payment_services SET name = 'Штрафы парковки' WHERE code = 'parking';
UPDATE payment_services SET name = 'Налоги ФНС' WHERE code = 'fns';
UPDATE payment_services SET name = 'Госуслуги' WHERE code = 'gosuslugi';
UPDATE payment_services SET name = 'Судебные задолженности' WHERE code = 'fssp';
UPDATE payment_services SET name = 'Тройка' WHERE code = 'troika';
UPDATE payment_services SET name = 'Паркон' WHERE code = 'parkon';
UPDATE payment_services SET name = 'Сбербанк' WHERE code = 'sber';
UPDATE payment_services SET name = 'Тинькофф' WHERE code = 'tinkoff';
UPDATE payment_services SET name = 'ВТБ' WHERE code = 'vtb';
UPDATE payment_services SET name = 'Альфа-Банк' WHERE code = 'alfa';

-- Исправление описаний
UPDATE payment_services SET description = 'Мобильная связь' WHERE code IN ('mts', 'beeline', 'megafon', 'tele2', 'yota', 'rostelecom_mobile');
UPDATE payment_services SET description = 'Электроэнергия' WHERE code = 'mosenergosbyt';
UPDATE payment_services SET description = 'Газоснабжение' WHERE code = 'gazprom_mezhregiongaz';
UPDATE payment_services SET description = 'Водоснабжение' WHERE code = 'mosvodokanal';
UPDATE payment_services SET description = 'Единый расчетный центр' WHERE code = 'mosobleirc';
UPDATE payment_services SET description = 'Интернет и ТВ' WHERE code IN ('rostelecom', 'domru');
UPDATE payment_services SET description = 'Домашний интернет' WHERE code = 'mts_internet';
UPDATE payment_services SET description = 'Административные штрафы' WHERE code = 'gibdd';
UPDATE payment_services SET description = 'Московский паркинг' WHERE code = 'parking';
UPDATE payment_services SET description = 'Налоговые платежи' WHERE code = 'fns';
UPDATE payment_services SET description = 'Портал госуслуг' WHERE code = 'gosuslugi';
UPDATE payment_services SET description = 'ФССП России' WHERE code = 'fssp';
UPDATE payment_services SET description = 'Пополнение карты' WHERE code = 'troika';
UPDATE payment_services SET description = 'Оплата парковки' WHERE code = 'parkon';
UPDATE payment_services SET description = 'Пополнение счета' WHERE code IN ('sber', 'tinkoff', 'vtb', 'alfa');

-- Исправление типов карт
UPDATE card_types SET name = 'Стандарт' WHERE code = 'standard';
UPDATE card_types SET name = 'Премиум' WHERE code = 'premium';
UPDATE card_types SET name = 'Для путешествий' WHERE code = 'travel';
UPDATE card_types SET name = 'Для покупок' WHERE code = 'online';
UPDATE card_types SET name = 'Детская' WHERE code = 'kids';
UPDATE card_types SET name = 'Кредитная Стандарт' WHERE code = 'credit_standard';
UPDATE card_types SET name = 'Кредитная Премиум' WHERE code = 'credit_premium';
UPDATE card_types SET name = 'Виртуальная' WHERE code = 'virtual';

UPDATE card_types SET description = 'Обычная дебетовая карта для повседневных покупок' WHERE code = 'standard';
UPDATE card_types SET description = 'Премиальная карта с повышенным кэшбэком и привилегиями' WHERE code = 'premium';
UPDATE card_types SET description = 'Карта с выгодным курсом для путешествий и страховкой' WHERE code = 'travel';
UPDATE card_types SET description = 'Карта для безопасных онлайн-покупок' WHERE code = 'online';
UPDATE card_types SET description = 'Карта для детей с контролем родителей' WHERE code = 'kids';
UPDATE card_types SET description = 'Кредитная карта с льготным периодом 50 дней' WHERE code = 'credit_standard';
UPDATE card_types SET description = 'Премиальная кредитная карта с повышенным лимитом' WHERE code = 'credit_premium';
UPDATE card_types SET description = 'Виртуальная карта для онлайн-покупок' WHERE code = 'virtual';
