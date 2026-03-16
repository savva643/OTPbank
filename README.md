# OTPbank

![Flutter](https://img.shields.io/badge/Flutter-Dart-1FBCFD?logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=nodedotjs&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white)
![BLoC](https://img.shields.io/badge/flutter__bloc-state%20management-4E7BFF)

Проект для **Challenge Cup IT 2026** (кейс от **OTP Bank**).

`OTPbank` — прототип мобильного банковского приложения:
- авторизация по номеру телефона и SMS-коду (OTP)
- онбординг/регистрация профиля
- главная (счета/карты/виджеты)
- продукты и сценарии
- переводы/платежи
- история операций
- копилка (goals)
- инвестиции + стрим котировок (WebSocket)
- чат

Backend является **mock/демо-сервером** (Node.js + Postgres), который поддерживает экраны Flutter-приложения.

## Репозитории / папки

- **Flutter**: `otpbank-fluuter/`
- **Backend**: `otpbank-backend/`

## Демо-сценарий (что показать на защите)

- 1) Splash → ввод телефона → получение OTP → ввод кода
- 2) Если пользователь новый: регистрация (ФИО + опциональные поля + аватар)
- 3) Главная: счета/карты/виджеты
- 4) Продукты/сценарии: просмотр карточек
- 5) Платежи: несколько типов переводов
- 6) История: список и детали операции
- 7) Копилка: создание/редактирование цели
- 8) Инвестиции: портфель + обновления через WebSocket
- 9) Чат

## Стек

### Mobile

- Flutter (Dart)
- `flutter_bloc`
- `dio`
- `shared_preferences`
- `image_picker`

### Backend

- Node.js + Express
- PostgreSQL
- JWT
- SMSAero (отправка SMS для OTP, опционально)

## Порты

- **Backend API**: `3000`
- **Postgres**: `5432`

## Переменные окружения

В репозитории есть шаблоны:

- **root**: `.env.example`
- **backend**: `otpbank-backend/.env.example`

Для локальной разработки:

- скопируй `otpbank-backend/.env.example` → `otpbank-backend/.env`
- измени значения при необходимости

Ключевые переменные:

- `PORT` (по умолчанию `3000`)
- `DATABASE_URL` (строка подключения к Postgres)
- `JWT_SECRET` (**обязательно поменять в проде**)

Для OTP по SMSAero (необязательно):

- `SMSAERO_EMAIL`
- `SMSAERO_API_KEY`
- `SMSAERO_SIGN`
- `SMSAERO_TEST_MODE`

## Быстрый старт (Docker)

Требования:

- Docker Desktop

Запуск:

```bash
docker compose up --build
```

Проверка:

- Backend healthcheck: `http://localhost:3000/health`

## Запуск backend без Docker (локально)

Требования:

- Node.js 20+
- PostgreSQL 16+

Шаги:

```bash
# 1) backend env
cp otpbank-backend/.env.example otpbank-backend/.env

# 2) install
cd otpbank-backend
npm i

# 3) run
npm run dev
```

## Запуск Flutter

Требования:

- Flutter SDK
- Android Studio/SDK или устройство

Команды:

```bash
cd otpbank-fluuter
flutter pub get
flutter run
```

`baseUrl` на клиенте задаётся в `otpbank-fluuter/lib/core/config/app_config.dart`.

## Аватары (ассеты)

В приложении есть выбор аватара:

- из набора `assets/avatars/avatar1.png..avatar4.png`
- из галереи (локально на устройстве)

Папка:

- `otpbank-fluuter/assets/avatars/`

## Документация

- API: `API.md`
- Деплой/сервер: `deploy_server.md`
