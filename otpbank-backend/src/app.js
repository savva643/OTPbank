const express = require('express');
const { router } = require('./routes');
const { errorHandler } = require('./middlewares/errorHandler');
const path = require('path');

const allowedOrigins = new Set([
  'http://otpbank.keep-pixel.ru',
  'https://otpbank.keep-pixel.ru'
]);

function createApp() {
  const app = express();

  app.use((req, res, next) => {
    const startedAt = Date.now();
    res.on('finish', () => {
      const ms = Date.now() - startedAt;
      console.log(`[http] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${ms}ms)`);
    });
    next();
  });

  app.use(express.json({ limit: '1mb' }));

  app.use((req, res, next) => {
    const origin = req.headers.origin;
    if (origin && allowedOrigins.has(origin)) {
      res.setHeader('Access-Control-Allow-Origin', origin);
      res.setHeader('Vary', 'Origin');
      res.setHeader('Access-Control-Allow-Credentials', 'true');
    }

    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'content-type, accept, authorization');

    if (req.method === 'OPTIONS') {
      res.status(204).end();
      return;
    }

    next();
  });

  app.use('/static', express.static(path.join(__dirname, '..', 'public')));
  app.use('/api/static', express.static(path.join(__dirname, '..', 'public')));

  app.use('/logos', express.static(path.join(__dirname, '..', 'public', 'logos')));
  app.use('/api/logos', express.static(path.join(__dirname, '..', 'public', 'logos')));

  app.use('/stories', express.static(path.join(__dirname, '..', 'public', 'stories')));
  app.use('/api/stories', express.static(path.join(__dirname, '..', 'public', 'stories')));

  app.use(router);

  app.use(errorHandler);

  return app;
}

module.exports = { createApp };
