const jwt = require('jsonwebtoken');
const { WebSocketServer } = require('ws');
const { env } = require('../config/env');
const { addConnection, removeConnection, sendToUser } = require('./chatHub');
const { chatService } = require('../services/chatService');
const { marketSimService } = require('../services/marketSimService');

function parseToken(req) {
  try {
    const url = new URL(req.url, `http://${req.headers.host}`);
    return url.searchParams.get('token');
  } catch (_) {
    return null;
  }
}

function startWs(server) {
  const wss = new WebSocketServer({ server, path: '/ws' });

  wss.on('connection', async (ws, req) => {
    const token = parseToken(req);
    if (!token || !env.jwtSecret) {
      ws.close(1008, 'unauthorized');
      return;
    }

    let userId;
    try {
      const payload = jwt.verify(token, env.jwtSecret);
      userId = payload.sub;
      if (!userId) throw new Error('no sub');
    } catch (_) {
      ws.close(1008, 'unauthorized');
      return;
    }

    addConnection(userId, ws);

    const investSubs = new Set();
    const investInterval = setInterval(() => {
      try {
        if (ws.readyState !== ws.OPEN) return;
        if (investSubs.size === 0) return;

        const tickers = Array.from(investSubs);
        const quotes = marketSimService.getQuotes(tickers);
        const predictions = marketSimService.getPredictions(tickers);
        ws.send(JSON.stringify({ type: 'invest.update', data: { quotes, predictions } }));
      } catch (_) {
        // ignore
      }
    }, 2000);

    ws.on('message', async (raw) => {
      try {
        const text = raw.toString('utf8');
        const msg = JSON.parse(text);

        if (msg && msg.type === 'ping') {
          ws.send(JSON.stringify({ type: 'pong' }));
          return;
        }

        if (msg && msg.type === 'invest.subscribe') {
          const tickers = Array.isArray(msg.tickers) ? msg.tickers : [];
          const normalized = tickers.map((t) => String(t).trim()).filter(Boolean);
          marketSimService.assertTickersValid(normalized);
          for (const t of normalized) investSubs.add(t);

          const quotes = marketSimService.getQuotes(Array.from(investSubs));
          const predictions = marketSimService.getPredictions(Array.from(investSubs));
          ws.send(JSON.stringify({ type: 'invest.subscribed', data: { tickers: Array.from(investSubs) } }));
          ws.send(JSON.stringify({ type: 'invest.update', data: { quotes, predictions } }));
          return;
        }

        if (msg && msg.type === 'invest.unsubscribe') {
          const tickers = Array.isArray(msg.tickers) ? msg.tickers : [];
          for (const t of tickers.map((x) => String(x).trim()).filter(Boolean)) investSubs.delete(t);
          ws.send(JSON.stringify({ type: 'invest.subscribed', data: { tickers: Array.from(investSubs) } }));
          return;
        }

        if (msg && msg.type === 'invest.set') {
          const tickers = Array.isArray(msg.tickers) ? msg.tickers : [];
          const normalized = tickers.map((t) => String(t).trim()).filter(Boolean);
          marketSimService.assertTickersValid(normalized);

          investSubs.clear();
          for (const t of normalized) investSubs.add(t);

          const quotes = marketSimService.getQuotes(Array.from(investSubs));
          const predictions = marketSimService.getPredictions(Array.from(investSubs));
          ws.send(JSON.stringify({ type: 'invest.subscribed', data: { tickers: Array.from(investSubs) } }));
          ws.send(JSON.stringify({ type: 'invest.update', data: { quotes, predictions } }));
          return;
        }

        // Backward-compatible chat message handling
        if (!msg || typeof msg.message !== 'string') {
          ws.send(JSON.stringify({ type: 'error', error: { code: 'validation_error', message: 'message обязателен' } }));
          return;
        }

        const created = await chatService.sendMessage(userId, { message: msg.message });

        sendToUser(userId, { type: 'chat.message', data: created });
      } catch (e) {
        ws.send(JSON.stringify({ type: 'error', error: { code: 'bad_request', message: 'Некорректное сообщение' } }));
      }
    });

    ws.on('close', () => {
      try {
        clearInterval(investInterval);
      } catch (_) {
        // ignore
      }
      removeConnection(userId, ws);
    });
  });

  return wss;
}

module.exports = { startWs };
