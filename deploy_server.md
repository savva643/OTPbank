# Deploy / Server guide

Этот документ описывает, как развернуть backend и web-версию (Flutter Web bundle) на сервере.

Целевой сервер:

- IP: `144.31.86.235`
- Домен: `otpbank.keep-pixel.ru`

Ниже инструкция для Ubuntu/Debian.

## Подготовка сервера (Ubuntu/Debian)

### 1) Обновление пакетов и базовые утилиты

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
```

### 2) Установка Git

```bash
sudo apt-get install -y git
```

### 3) Установка Docker Engine + docker compose plugin

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Проверка:

```bash
docker --version
docker compose version
```

Опционально (чтобы не писать sudo):

```bash
sudo usermod -aG docker $USER
```

### 4) Firewall / порты (UFW)

Если UFW выключен — можно пропустить.

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

## Порты / firewall

- **HTTP**: `80/tcp` (для Cloudflare Flexible — Cloudflare подключается к origin по HTTP)
- **HTTPS**: `443/tcp` (если не Flexible, а Full/Strict или если хочешь TLS на origin)
- **Backend API** (если открываешь наружу напрямую): `3000/tcp`
- **PostgreSQL**: `5432/tcp` (обычно **НЕ** открывают наружу, только внутри сервера/сети)

Рекомендуемая схема:

- Nginx на `80`/`443`
- Nginx проксирует `/api/*` -> backend (внутренний `3000`)
- Nginx раздаёт статический Flutter Web bundle (папка `otpbank-web/`)

## Cloudflare Flexible (важно)

Flexible означает:

- Клиент -> Cloudflare: **HTTPS**
- Cloudflare -> origin: **HTTP** (обычно порт 80)

То есть на origin достаточно открыть **80**, а TLS-сертификат на origin **не обязателен**.

Если хочешь более безопасно (end-to-end TLS) — используй Cloudflare **Full (Strict)** и подними `443` на origin (например через Let’s Encrypt).

## Web: подготовка Flutter bundle

На локальной машине:

```bash
cd otpbank-fluuter
flutter build web --release
```

Для локальной разработки с бэкендом на localhost переопредели baseUrl:

```bash
flutter run --dart-define=BASE_URL=http://localhost:3000
```

> Важно: baseUrl теперь зависит от платформы:
> - Web: относительный '/api'
> - Desktop/Mobile: 'http://144.31.86.235/api'
> Чтобы переопределить (например для локального запуска), используй --dart-define=BASE_URL.

Затем содержимое `otpbank-fluuter/build/web/` нужно скопировать на сервер в папку репозитория:

- `otpbank-web/` (эта папка используется nginx-конфигом)

Пример:

```bash
# копируем содержимое build/web в otpbank-web
# (команда примерная — путь и способ зависят от твоего деплоя)
rsync -av otpbank-fluuter/build/web/ user@server:/opt/otpbank/otpbank-web/
```

Важно:

- На сервере папка должна быть именно `otpbank-web/` (её монтирует Nginx-контейнер).
- После копирования достаточно перезапустить web-контейнер:

```bash
docker compose -f docker-compose.web.yml restart
```

## Docker + Nginx (web + reverse proxy)

В репозитории предусмотрена docker-заготовка под Nginx.

### 1) Клонирование репозитория на сервер

Пример целевого пути:

```bash
sudo mkdir -p /opt/otpbank
sudo chown -R $USER:$USER /opt/otpbank
cd /opt/otpbank

git clone <REPO_URL> otpbank
cd otpbank
```

### 2) Подготовка backend окружения

Скопируй env-шаблон и отредактируй значения:

```bash
cp .env.example .env
cp otpbank-backend/.env.example otpbank-backend/.env
```

Запуск (после того как положил web bundle в `otpbank-web/`):

```bash
docker compose -f docker-compose.web.yml up -d --build
```

Запуск backend + db (из корня репозитория):

```bash
docker compose up -d --build
```

Проверка:

- Главная:
  - `http://144.31.86.235/`
  - `http://otpbank.keep-pixel.ru/`
- Backend health:
  - `http://144.31.86.235/api/health`
  - `http://otpbank.keep-pixel.ru/api/health`

## Backend

### Вариант A: Docker (рекомендуется)

Используй существующий `docker-compose.yml` (db + backend) или объедини с web-Compose.

```bash
docker compose up -d --build
```

Healthcheck:

- `http://localhost:3000/health`

### Вариант B: systemd (без Docker)

1) Установи Node.js 20
2) Настрой `.env` в `otpbank-backend/.env`
3) Подними Postgres
4) Запусти backend (`npm run start` или `npm run dev`)

## Nginx конфиг (как работает)

- `/` -> статические файлы Flutter Web
- `/api/` -> прокси на backend
- Для Flutter Web используется `try_files $uri $uri/ /index.html;`, чтобы работала навигация.

## Примечание про домен и Cloudflare

- Если домен проксируется Cloudflare и включён Flexible, то на origin достаточно порта `80`.
- Если хочешь TLS на origin (Full/Strict) — добавь сертификаты и `listen 443 ssl;` в Nginx (отдельным шагом).
