# OTPbank

## Быстрый старт (Docker)

Требования:

- Docker Desktop

Запуск:

```bash
docker compose up --build
```

Проверка:

- Backend healthcheck: `http://localhost:3000/health`

## Структура репозитория

- `otpbank-backend/` — Node.js/Express backend
- `otpbank-fluuter/` — Flutter мобильное приложение
- `otpbank-web/` — веб-версия (позже)

## Переменные окружения

В Docker Compose используется дефолтный набор переменных для разработки. Перед продом нужно заменить:

- `JWT_SECRET`
- креды к БД
