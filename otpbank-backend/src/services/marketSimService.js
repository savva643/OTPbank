const { ApiError } = require('../utils/apiError');

function clamp(n, min, max) {
  return Math.max(min, Math.min(max, n));
}

function roundTo(n, digits) {
  const p = Math.pow(10, digits);
  return Math.round(n * p) / p;
}

function randomBetween(min, max) {
  return min + Math.random() * (max - min);
}

function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function createInstrument({ ticker, name, kind, currency, price, volatility }) {
  return {
    ticker,
    name,
    kind,
    currency,
    price,
    prevClose: price,
    dayOpen: price,
    dayHigh: price,
    dayLow: price,
    volatility
  };
}

// In real banks, market data is streamed from providers. Here we simulate with a random walk.
const instrumentsByTicker = new Map(
  [
    createInstrument({ ticker: 'RUB', name: 'Российский рубль', kind: 'currency', currency: 'RUB', price: 1, volatility: 0 }),
    createInstrument({ ticker: 'USD/RUB', name: 'Доллар США', kind: 'fx', currency: 'RUB', price: 92.3, volatility: 0.003 }),
    createInstrument({ ticker: 'EUR/RUB', name: 'Евро', kind: 'fx', currency: 'RUB', price: 100.8, volatility: 0.0035 }),
    createInstrument({ ticker: 'CNY/RUB', name: 'Юань', kind: 'fx', currency: 'RUB', price: 12.8, volatility: 0.003 }),
    createInstrument({ ticker: 'SBER', name: 'Сбербанк', kind: 'stock', currency: 'RUB', price: 312.4, volatility: 0.01 }),
    createInstrument({ ticker: 'GAZP', name: 'Газпром', kind: 'stock', currency: 'RUB', price: 168.2, volatility: 0.012 }),
    createInstrument({ ticker: 'AAPL', name: 'Apple', kind: 'stock', currency: 'USD', price: 187.55, volatility: 0.008 }),
    createInstrument({ ticker: 'TSLA', name: 'Tesla', kind: 'stock', currency: 'USD', price: 212.4, volatility: 0.015 }),
    createInstrument({ ticker: 'BTC', name: 'Bitcoin', kind: 'crypto', currency: 'USD', price: 64250.0, volatility: 0.02 }),
    createInstrument({ ticker: 'ETH', name: 'Ethereum', kind: 'crypto', currency: 'USD', price: 3450.0, volatility: 0.022 })
  ].map((x) => [x.ticker, x])
);

function applyTick(inst) {
  if (inst.volatility <= 0) return;

  const shock = randomBetween(-1, 1) * inst.volatility;
  const next = inst.price * (1 + shock);
  inst.price = clamp(next, inst.price * 0.7, inst.price * 1.3);
  inst.dayHigh = Math.max(inst.dayHigh, inst.price);
  inst.dayLow = Math.min(inst.dayLow, inst.price);
}

function computeChange(inst) {
  const change = inst.price - inst.prevClose;
  const changePercent = inst.prevClose > 0 ? (change / inst.prevClose) * 100 : 0;
  return { change, changePercent };
}

function makePrediction(inst) {
  const { changePercent } = computeChange(inst);
  const bias = clamp(changePercent / 5, -0.3, 0.3);

  const direction = Math.random() < 0.5 + bias ? 'up' : 'down';
  const confidence = clamp(55 + Math.abs(changePercent) * 6 + randomBetween(-8, 8), 50, 92);
  const horizonMinutes = pick([15, 30, 60, 180, 360]);

  const magnitude = randomBetween(0.002, 0.02) * (inst.kind === 'crypto' ? 2.2 : 1);
  const signed = direction === 'up' ? magnitude : -magnitude;

  const targetPrice = inst.price * (1 + signed);

  return {
    ticker: inst.ticker,
    direction,
    confidence: Math.round(confidence),
    horizonMinutes,
    targetPrice: String(roundTo(targetPrice, inst.kind === 'crypto' ? 2 : 4)),
    note: direction === 'up' ? 'Потенциал роста (симуляция)' : 'Риск снижения (симуляция)'
  };
}

let started = false;
function start() {
  if (started) return;
  started = true;

  // Update prices ~ every 1s
  setInterval(() => {
    for (const inst of instrumentsByTicker.values()) applyTick(inst);
  }, 1000);

  // Rotate day close baseline every ~ 60s (demo)
  setInterval(() => {
    for (const inst of instrumentsByTicker.values()) {
      inst.prevClose = inst.price;
      inst.dayOpen = inst.price;
      inst.dayHigh = inst.price;
      inst.dayLow = inst.price;
    }
  }, 60_000);
}

start();

const marketSimService = {
  listInstruments: () => {
    return Array.from(instrumentsByTicker.values()).map((i) => ({
      ticker: i.ticker,
      name: i.name,
      kind: i.kind,
      currency: i.currency
    }));
  },

  getQuotes: (tickers) => {
    const list = Array.isArray(tickers) ? tickers : [];
    const now = new Date().toISOString();

    const quotes = list.map((t) => {
      const inst = instrumentsByTicker.get(String(t));
      if (!inst) return null;
      const { change, changePercent } = computeChange(inst);

      return {
        ticker: inst.ticker,
        price: String(roundTo(inst.price, inst.kind === 'crypto' ? 2 : 4)),
        currency: inst.currency,
        change: String(roundTo(change, inst.kind === 'crypto' ? 2 : 4)),
        changePercent: roundTo(changePercent, 2),
        ts: now
      };
    });

    return quotes.filter(Boolean);
  },

  getPredictions: (tickers) => {
    const list = Array.isArray(tickers) ? tickers : [];
    return list
      .map((t) => instrumentsByTicker.get(String(t)))
      .filter(Boolean)
      .map((inst) => makePrediction(inst));
  },

  assertTickersValid: (tickers) => {
    const list = Array.isArray(tickers) ? tickers : [];
    for (const t of list) {
      if (!instrumentsByTicker.has(String(t))) {
        throw new ApiError(400, 'validation_error', `Неизвестный тикер: ${t}`);
      }
    }
  }
};

module.exports = { marketSimService };
