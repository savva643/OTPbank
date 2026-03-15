-- Миграция: Обновление stories - использование PNG вместо WebP
-- Дата: 2026-03-15
-- Описание: Заменяет WebP URL на PNG из /stories

-- Обновляем stories на PNG
UPDATE stories 
SET 
  mini_image_url = CASE 
    WHEN code = 'swarovski' THEN 'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif'
    WHEN code = 'otp-card' THEN '/stories/14-lama-main.png'
    WHEN code = 'internship' THEN '/stories/off-5.png'
    ELSE mini_image_url
  END,
  media_url = CASE 
    WHEN code = 'swarovski' THEN 'https://i.pinimg.com/originals/e8/6d/e1/e86de12a83c24422a90bbefacd922587.gif'
    WHEN code = 'otp-card' THEN '/stories/14-lama-main.png'
    WHEN code = 'internship' THEN '/stories/off-5.png'
    ELSE media_url
  END,
  media_type = CASE 
    WHEN code = 'swarovski' THEN 'gif'
    ELSE 'photo'
  END,
  title = CASE 
    WHEN code = 'swarovski' THEN 'Сваровски'
    ELSE title
  END,
  story_text = CASE 
    WHEN code = 'swarovski' THEN 'Приложение созданное командой Сваровски'
    ELSE story_text
  END,
  cta_label = CASE 
    WHEN code = 'swarovski' THEN 'Круто!'
    WHEN code = 'otp-card' THEN 'Оформить'
    ELSE cta_label
  END,
  cta_action = CASE 
    WHEN code = 'swarovski' THEN 'close'
    WHEN code = 'otp-card' THEN 'open_product'
    ELSE cta_action
  END,
  cta_payload = CASE 
    WHEN code = 'otp-card' THEN 'otp-debit-card'
    ELSE cta_payload
  END
WHERE code IN ('swarovski', 'otp-card', 'internship');
