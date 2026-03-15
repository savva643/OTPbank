const { storiesService } = require('../services/storiesService');

function svgForStory(code, type) {
  const t = String(type || 'mini').toLowerCase() === 'full' ? 'full' : 'mini';
  const w = t === 'full' ? 1080 : 168;
  const h = t === 'full' ? 1920 : 168;

  const presets = {
    'for-you': { bg1: '#C4FF2E', bg2: '#C8E1FC', text: 'Для вас' },
    cashback10: { bg1: '#FF7D32', bg2: '#9E6FC3', text: 'Кэшбэк 10%' },
    updates: { bg1: '#0F172A', bg2: '#4F46E5', text: 'Новое' },
  };

  const p = presets[String(code || '').trim()] || { bg1: '#C8E1FC', bg2: '#F1F5F9', text: 'Story' };
  const fontSize = t === 'full' ? 84 : 18;
  const subFont = t === 'full' ? 44 : 12;

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="${p.bg1}"/>
      <stop offset="100%" stop-color="${p.bg2}"/>
    </linearGradient>
    <radialGradient id="r" cx="85%" cy="15%" r="80%">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.45"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="100%" height="100%" rx="${t === 'full' ? 0 : 28}" fill="url(#g)"/>
  <rect width="100%" height="100%" fill="url(#r)"/>
  <g font-family="Arial, sans-serif" fill="#0F172A">
    <text x="${t === 'full' ? 80 : 18}" y="${t === 'full' ? 170 : 52}" font-size="${fontSize}" font-weight="800">${p.text}</text>
    ${t === 'full' ? `<text x="80" y="260" font-size="${subFont}" font-weight="600" fill="#1E293B">OTPbank • приложение</text>` : ''}
  </g>
</svg>`;
}

const storiesController = {
  list: async (req, res, next) => {
    try {
      const items = await storiesService.list();
      res.json({ items });
    } catch (e) {
      next(e);
    }
  },

  getById: async (req, res, next) => {
    try {
      const item = await storiesService.getById(req.params.id);
      res.json(item);
    } catch (e) {
      next(e);
    }
  },

  media: async (req, res) => {
    const svg = svgForStory(req.params.code, req.query.type);
    res.setHeader('content-type', 'image/svg+xml; charset=utf-8');
    res.send(svg);
  }
};

module.exports = { storiesController };
