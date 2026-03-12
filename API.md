# OTPbank API (Mock Backend)

Base URL:
- `http://<host>:3000`

Auth:
- Bearer JWT: `Authorization: Bearer <accessToken>`
- WebSocket token: `ws://<host>:3000/ws?token=<accessToken>`

## REST

### Health

#### GET `/health`
Response:
```json
{ "status": "ok" }
```

### Auth

#### POST `/auth/register`
Body:
```json
{ "name": "User", "phone": "+79990000000", "email": "u@mail.com", "password": "1234" }
```
Response:
```json
{ "accessToken": "...", "user": { "id": "...", "name": "...", "phone": "...", "email": "...", "avatarUrl": null } }
```

#### POST `/auth/login`
Body:
```json
{ "login": "+79990000000", "password": "1234" }
```
Response: same as `/auth/register`

#### POST `/auth/otp/request`
Body:
```json
{ "phone": "+79990000000" }
```
Response:
```json
{ "ok": true, "expiresInSec": 300 }
```

#### POST `/auth/otp/verify`
Body:
```json
{ "phone": "+79990000000", "code": "123456" }
```
Response (existing user):
```json
{ "isNew": false, "accessToken": "...", "user": { "id": "...", "name": "...", "phone": "...", "email": "...", "avatarUrl": null } }
```
Response (new user):
```json
{ "isNew": true, "registrationToken": "..." }
```

#### POST `/auth/complete-registration`
Body:
```json
{ "registrationToken": "...", "fullName": "Иванов Иван", "email": "u@mail.com", "gender": "male", "birthDate": "2000-01-01", "avatarUrl": "http://<host>:3000/static/avatars/a1.png" }
```
Response:
```json
{ "accessToken": "...", "user": { "id": "...", "name": "...", "phone": "...", "email": "...", "avatarUrl": "..." } }
```

### User

#### GET `/user/profile`
Auth: required
Response:
```json
{ "id": "...", "name": "...", "phone": "...", "email": "...", "avatarUrl": null }
```

#### PUT `/user/profile`
Auth: required
Body (example):
```json
{ "name": "New Name", "email": "new@mail.com" }
```

#### PUT `/user/avatar`
Auth: required
Body (example):
```json
{ "avatarUrl": "https://..." }
```

### Accounts

#### GET `/accounts`
Auth: required
Response:
```json
{ "items": [ { "id": "...", "type": "debit", "title": "Основной счёт", "balance": "0", "currency": "RUB" } ] }
```

### Cards

#### GET `/cards`
Auth: required

#### GET `/cards/:id`
Auth: required

#### POST `/cards/:id/freeze`
Auth: required

#### POST `/cards/:id/unfreeze`
Auth: required

#### POST `/cards/:id/limits`
Auth: required
Body:
```json
{ "limitPerTx": 50000, "limitPerDay": 200000 }
```

### Transactions

#### GET `/transactions`
Auth: required

#### GET `/transactions/:id`
Auth: required

### Widgets

#### GET `/widgets/cashback`
Auth: required

#### GET `/widgets/bonuses`
Auth: required

### Stories

#### GET `/stories`
Auth: required

### Products

#### GET `/products/categories`
Auth: required

#### GET `/products/offers`
Auth: required

#### GET `/products/:id`
Auth: required

### Scenarios

#### GET `/scenarios`
Auth: required

### Chat

#### GET `/chat/messages`
Auth: required
Response:
```json
{ "items": [ { "id": "...", "sender": "user|bot", "message": "...", "createdAt": "..." } ] }
```

#### POST `/chat/messages`
Auth: required
Body:
```json
{ "message": "Hello" }
```
Response:
```json
{ "id": "...", "sender": "user", "message": "Hello", "createdAt": "..." }
```

### Goals (Piggy Bank / Копилка)

#### GET `/goals`
Auth: required
Response:
```json
{ "items": [ { "id": "...", "name": "На отпуск", "icon": "beach", "targetAmount": "100000", "savedAmount": "25000", "currency": "RUB", "deadline": null, "progressPercent": 25 } ] }
```

#### POST `/goals`
Auth: required
Body:
```json
{ "name": "На отпуск", "icon": "beach", "targetAmount": 100000, "savedAmount": 0, "currency": "RUB", "deadline": "2026-09-01" }
```
Response: goal item

#### PUT `/goals/:id`
Auth: required
Body (any subset):
```json
{ "name": "На отпуск 2", "icon": "plane", "targetAmount": 120000, "savedAmount": 10000, "currency": "RUB", "deadline": null }
```

#### DELETE `/goals/:id`
Auth: required

### Investments

#### GET `/investments/portfolio`
Auth: required
Response:
```json
{ "value": "0", "currency": "RUB", "dailyChange": "0", "dailyChangePercent": 0 }
```

#### GET `/investments/assets`
Auth: required
Response:
```json
{ "items": [ { "id": "...", "type": "stock", "ticker": "SBER", "name": "Сбербанк", "quantity": "1", "avgPrice": "300", "currency": "RUB" } ] }
```

#### GET `/investments/instruments`
Auth: required
Response:
```json
{ "items": [ { "ticker": "SBER", "name": "Сбербанк", "kind": "stock", "currency": "RUB" } ] }
```

#### GET `/investments/quotes?tickers=SBER,BTC,USD/RUB`
Auth: required
Response:
```json
{ "items": [ { "ticker": "SBER", "price": "312.4000", "currency": "RUB", "change": "1.2300", "changePercent": 0.39, "ts": "2026-01-01T00:00:00.000Z" } ] }
```

#### GET `/investments/predictions?tickers=SBER,BTC`
Auth: required
Response:
```json
{ "items": [ { "ticker": "SBER", "direction": "up", "confidence": 73, "horizonMinutes": 60, "targetPrice": "318.1000", "note": "Потенциал роста (симуляция)" } ] }
```

## WebSocket

Connect:
- `ws://<host>:3000/ws?token=<accessToken>`

### Ping
Client:
```json
{ "type": "ping" }
```
Server:
```json
{ "type": "pong" }
```

### Investments subscribe

Client:
```json
{ "type": "invest.subscribe", "tickers": ["SBER", "BTC", "USD/RUB"] }
```

Server ack:
```json
{ "type": "invest.subscribed", "data": { "tickers": ["SBER", "BTC", "USD/RUB"] } }
```

Server updates (about every 2 seconds while subscribed):
```json
{ "type": "invest.update", "data": { "quotes": [ ... ], "predictions": [ ... ] } }
```

Unsubscribe:
```json
{ "type": "invest.unsubscribe", "tickers": ["BTC"] }
```

Replace subscription set:
```json
{ "type": "invest.set", "tickers": ["SBER"] }
```

### Chat message (legacy)
Client:
```json
{ "message": "Hello" }
```
Server push:
```json
{ "type": "chat.message", "data": { "id": "...", "sender": "user", "message": "Hello", "createdAt": "..." } }
```

## Errors

Error payload format:
```json
{ "type": "error", "error": { "code": "validation_error", "message": "..." } }
```

HTTP errors come from `errorHandler` and include `code` + `message`.
