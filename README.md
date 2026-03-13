# OTPbank

Проект для **Challenge Cup IT 2026** (кейс от **OTP Bank**).

`OTPbank` — прототип мобильного банковского приложения:
- авторизация по номеру телефона и SMS-коду (OTP)
- онбординг/регистрация профиля
- главная с виджетами
- продукты и сценарии
- переводы/платежи
- история операций
- копилка (goals)
- инвестиции + стрим котировок (WebSocket)
- чат

Backend является **mock/демо-сервером** (Node.js + Postgres), который поддерживает экраны Flutter-приложения.

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
- `flutter_bloc` (состояние)
- `dio` (HTTP)
- `shared_preferences` (JWT в storage)
- `image_picker` (выбор аватара из галереи)

### Backend
- Node.js + Express
- PostgreSQL
- JWT
- SMSAero (отправка SMS для OTP, опционально)

## Архитектура (кратко)

- **Backend**: `routes -> controllers -> services -> db(pool)`
- **Flutter**:
  - `core/` — конфиг, сеть, storage, общие виджеты
  - `features/*` — экраны по доменам (auth, splash, shell, goals, products, ...)
  - `AuthBloc` управляет полным auth-flow (phone → code → registration → authorized)

## Быстрый старт (Docker)

Требования:
- Docker Desktop

Запуск:
```bash
docker compose up --build
```

Проверка:
- Backend healthcheck: `http://localhost:3000/health`

## Запуск Flutter

Требования:
- Flutter SDK
- Android Studio/SDK или устройство

Команды:
```bash
flutter pub get
flutter run
```

`baseUrl` на клиенте задаётся в `otpbank-fluuter/lib/core/config/app_config.dart`.

## Аватары (ассеты)

В приложении есть выбор аватара:
- из набора `assets/avatars/avatar1.png..avatar4.png`
- из галереи (локально на устройстве)

Положи картинки сюда:
- `otpbank-fluuter/assets/avatars/`

## Документация API

Смотри `API.md`.

## Переменные окружения

В Docker Compose используется дефолтный набор переменных для разработки. Перед продом нужно заменить:

- `JWT_SECRET`
- креды к БД

Для OTP по SMSAero (необязательно):
- `SMSAERO_EMAIL`
- `SMSAERO_API_KEY`
- `SMSAERO_SIGN` (опционально)
- `SMSAERO_TEST_MODE` (опционально)
