# Чеклист разработки OTPbank (хакатон)

## Этап 1 — Backend foundation

- [x] Docker Compose: backend + PostgreSQL
- [x] Healthcheck endpoint
- [x] Единый формат ошибок + глобальный error handler
- [x] JWT auth: регистрация/логин/refresh (минимум логин)
- [x] Структура модулей: routes/controllers/services/models
- [x] Подключение к PostgreSQL (pool)
- [x] SQL схема и первичная миграция/seed

## Этап 2 — API под экраны

### Home
- [x] `GET /user/profile`
- [x] `GET /accounts`
- [x] `GET /cards`
- [x] `GET /widgets/cashback`
- [x] `GET /widgets/bonuses`
- [x] `GET /products/recommended`

### Products / Scenarios
- [x] `GET /products`
- [x] `GET /products/category/:id`
- [x] `GET /scenarios`
- [x] `GET /scenarios/:id`

### Card/Account management
- [x] `GET /cards/:id`
- [x] `POST /cards/:id/freeze`
- [x] `POST /cards/:id/unfreeze`
- [x] `POST /cards/:id/limits`

### Goals
- [x] `GET /goals`
- [x] `POST /goals`
- [x] `PUT /goals/:id`
- [x] `DELETE /goals/:id`

### Investments
- [x] `GET /investments/portfolio`
- [x] `GET /investments/assets`

### Payments
- [x] `POST /payments/card-transfer`
- [x] `POST /payments/phone-transfer`
- [x] `POST /payments/sbp`
- [x] `POST /payments/bills`
- [x] `POST /payments/mobile`
- [x] `POST /payments/nfc/start`
- [x] `POST /payments/nfc/confirm`
- [x] `POST /payments/qr/scan`
- [x] `POST /payments/qr/pay`

### History
- [x] `GET /transactions` (фильтры/поиск)
- [x] `GET /transactions/:id`

### Profile
- [x] `PUT /user/profile`
- [x] `PUT /user/avatar`

### Chat
- [x] `GET /chat/messages`
- [x] `POST /chat/messages`
- [x] WebSocket (опционально)

## Этап 3 — Стабилизация

- [ ] Валидация запросов (zod/joi)
- [ ] Роли/права (минимально)
- [ ] Логи
- [ ] Swagger/OpenAPI
- [ ] Тесты (smoke)

## Этап 4 — Web

- [ ] Подключить `otpbank-web/`
- [ ] Docker сервис для web
