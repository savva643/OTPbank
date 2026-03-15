# Логотипы для услуг и магазинов кэшбэка

## Структура папок
```
otpbank-backend/public/
├── logos/
│   ├── services/          # Логотипы услуг (МТС, Сбер, etc.)
│   │   ├── mts.png
│   │   ├── beeline.png
│   │   └── ...
│   └── cashback/          # Логотипы магазинов кэшбэка
│       ├── pyaterochka.png
│       ├── wildberries.png
│       └── ...
```

## Логотипы услуг (services/)

### Мобильная связь (mobile)
| Файл | Организация |
|------|-------------|
| mts.png | МТС |
| beeline.png | Билайн |
| megafon.png | МегаФон |
| tele2.png | Tele2 |
| yota.png | Yota |

### ЖКХ (utilities)
| Файл | Организация |
|------|-------------|
| mosenergosbyt.png | Мосэнергосбыт |
| gazprom_mezhregiongaz.png | Газпром Межрегионгаз |
| mosvodokanal.png | Мосводоканал |
| mosobleirc.png | МособлЕИРЦ |

### Интернет и ТВ (internet)
| Файл | Организация |
|------|-------------|
| rostelecom.png | Ростелеком |
| domru.png | Дом.ru |
| mts_internet.png | МТС Интернет |

### Штрафы и налоги (fines)
| Файл | Организация |
|------|-------------|
| gibdd.png | Штрафы ГИБДД |
| parking.png | Московский паркинг |
| fns.png | Налоги ФНС |

### Госуслуги (government)
| Файл | Организация |
|------|-------------|
| gosuslugi.png | Госуслуги |
| fssp.png | ФССП |

### Транспорт (transport)
| Файл | Организация |
|------|-------------|
| troika.png | Тройка |
| parkon.png | Паркон |

### Финансы (finance - банки для пополнения)
| Файл | Организация |
|------|-------------|
| sber.png | Сбербанк |
| tinkoff.png | Тинькофф |
| vtb.png | ВТБ |
| alfa.png | Альфа-Банк |

---

## Логотипы магазинов кэшбэка (cashback/)

### Еда и продукты
| Файл | Магазин | Категория |
|------|---------|-----------|
| pyaterochka.png | Пятёрочка | food |
| magnit.png | Магнит | food |
| lenta.png | Лента | food |
| auchan.png | Ашан | food |
| perekrestok.png | Перекрёсток | food |
| samokat.png | Самокат | food_delivery |
| yandex_eda.png | Яндекс Еда | food_delivery |
| delivery.png | Delivery Club | food_delivery |

### Кафе и рестораны
| Файл | Магазин | Категория |
|------|---------|-----------|
| dodo.png | Додо Пицца | cafe |
| burger_king.png | Burger King | cafe |
| kfc.png | KFC | cafe |
| mcdonalds.png | McDonald's | cafe |
| starbucks.png | Starbucks | cafe |
| shokoladnitsa.png | Шоколадница | cafe |

### Одежда и обувь
| Файл | Магазин | Категория |
|------|---------|-----------|
| wildberries.png | Wildberries | clothes |
| ozon.png | Ozon | clothes |
| lamoda.png | Lamoda | clothes |
| sportmaster.png | Спортмастер | clothes |

### Электроника
| Файл | Магазин | Категория |
|------|---------|-----------|
| mvideo.png | М.Видео | electronics |
| eldorado.png | Эльдорадо | electronics |
| dns.png | DNS | electronics |
| citilink.png | Ситилинк | electronics |

### Авто (АЗС)
| Файл | Магазин | Категория |
|------|---------|-----------|
| shell.png | Shell | fuel |
| bp.png | BP | fuel |
| rosneft.png | Роснефть | fuel |
| lukoil.png | Лукойл | fuel |
| gazpromneft.png | Газпромнефть | fuel |

### Красота и здоровье
| Файл | Магазин | Категория |
|------|---------|-----------|
| riv_gosh.png | Рив Гош | beauty |
| letual.png | Л'Этуаль | beauty |
| apteka_ru.png | Аптека.ру | health |
| eapteka.png | Еаптека | health |

### Развлечения
| Файл | Магазин | Категория |
|------|---------|-----------|
| kinopoisk.png | Кинопоиск | entertainment |
| ivi.png | Иви | entertainment |
| okko.png | Okko | entertainment |
| yandex_plus.png | Яндекс Плюс | entertainment |

### Транспорт и путешествия
| Файл | Магазин | Категория |
|------|---------|-----------|
| yandex_go.png | Яндекс Go | transport |
| citydrive.png | CityDrive | transport |
| delimobil.png | Делимобиль | transport |
| tutu.png | Туту.ру | travel |
| ozon_travel.png | Ozon Travel | travel |

---

## Рекомендации по формату
- **Формат**: PNG с прозрачностью (preferred) или JPG
- **Размер**: 128x128px или 256x256px
- **Цвет фона**: прозрачный (для PNG) или белый
- **Именование**: строчные буквы, без пробелов, подчеркивания для разделения слов

## Обновление БД с путями к картинкам

После загрузки логотипов, обнови URL в БД:

```sql
-- Пример: обновить логотипы услуг
UPDATE payment_services SET image_url = '/logos/services/mts.png' WHERE code = 'mts';
UPDATE payment_services SET image_url = '/logos/services/beeline.png' WHERE code = 'beeline';
-- ... и т.д.

-- Обновить логотипы кэшбэка
UPDATE cashback_partners SET logo_url = '/logos/cashback/pyaterochka.png' WHERE code = 'pyaterochka';
UPDATE cashback_partners SET logo_url = '/logos/cashback/wildberries.png' WHERE code = 'wildberries';
-- ... и т.д.
```

Или можешь изменить `01_init.sql` сразу указать полные URL:
```sql
INSERT INTO payment_services (code, name, ..., image_url) VALUES
('mts', 'МТС', ..., '/logos/services/mts.png');
```
