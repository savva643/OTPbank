const express = require('express');
const { router } = require('./routes');
const { errorHandler } = require('./middlewares/errorHandler');
const path = require('path');

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

  app.use('/static', express.static(path.join(__dirname, '..', 'public')));

  app.use('/logos', express.static(path.join(__dirname, '..', 'public', 'logos')));

  app.use('/stories', express.static(path.join(__dirname, '..', 'public', 'stories')));

  app.use(router);

  app.use(errorHandler);

  return app;
}

module.exports = { createApp };
