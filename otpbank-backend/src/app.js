const express = require('express');
const { router } = require('./routes');
const { errorHandler } = require('./middlewares/errorHandler');
const path = require('path');

function createApp() {
  const app = express();

  app.use(express.json({ limit: '1mb' }));

  app.use('/static', express.static(path.join(__dirname, '..', 'public')));

  app.use(router);

  app.use(errorHandler);

  return app;
}

module.exports = { createApp };
