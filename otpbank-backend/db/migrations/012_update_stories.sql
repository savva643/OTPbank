-- Миграция: Обновление stories - удаление старых, добавление новых
-- Дата: 2026-03-15
-- Описание: Заменяет старые stories на новые (Swarovski, Дебетовая ОТП Карта, Стажировка)

-- Удаляем старые stories
DELETE FROM stories WHERE title IN ('Для вас', 'Кэшбэк 10%', 'Новое в приложении');

-- Добавляем новые stories
INSERT INTO stories (code, title, mini_image_url, media_type, media_url, story_text, is_active)
VALUES
  (
    'swarovski',
    'Swarovski',
    'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif',
    'gif',
    'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif',
    'Приложение созданное командой Сваровски',
    true
  ),
  (
    'otp-card',
    'Дебетовая ОТП Карта',
    'https://www.otpbank.ru/img/main-page/video/14-lama-main.webp',
    'photo',
    'https://www.otpbank.ru/img/main-page/video/14-lama-main.webp',
    'Приятный кэшбэк до 3 000 ₽ каждый месяц!',
    true
  ),
  (
    'internship',
    'Стажировка',
    'https://www.otpbank.ru/about/press-centr/logos/img/off-5.webp',
    'photo',
    'https://www.otpbank.ru/about/press-centr/logos/img/off-5.webp',
    'Приходи в наши офисы и устраивайся на стажировку',
    true
  )
ON CONFLICT (title) DO UPDATE SET
  code = EXCLUDED.code,
  mini_image_url = EXCLUDED.mini_image_url,
  media_type = EXCLUDED.media_type,
  media_url = EXCLUDED.media_url,
  story_text = EXCLUDED.story_text,
  is_active = true;
