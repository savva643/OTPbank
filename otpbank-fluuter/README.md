# OTPbank — Flutter app

Мобильное приложение (Flutter) для проекта OTPbank.

## Запуск

```bash
flutter pub get
flutter run
```

## Конфигурация

`baseUrl` для backend задаётся в:
- `lib/core/config/app_config.dart`

## Авторизация (OTP)

Flow:
- Splash → Phone → Code → (Registration, если новый пользователь) → RootShell

## Аватары

Предустановленные аватары:
- `assets/avatars/avatar1.png`
- `assets/avatars/avatar2.png`
- `assets/avatars/avatar3.png`
- `assets/avatars/avatar4.png`

Можно выбрать и из галереи (локально на устройстве).
