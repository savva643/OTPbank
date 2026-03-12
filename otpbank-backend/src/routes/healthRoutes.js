const express = require('express');

const healthRoutes = express.Router();

healthRoutes.get('/', (req, res) => {
  res.json({ status: 'ok' });
});

module.exports = { healthRoutes };
