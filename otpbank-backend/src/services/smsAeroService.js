const https = require('https');
const { env } = require('../config/env');
const { ApiError } = require('../utils/apiError');

function basicAuthHeader(login, apiKey) {
  const raw = `${login}:${apiKey}`;
  return `Basic ${Buffer.from(raw, 'utf8').toString('base64')}`;
}

function requestJson({ method, hostname, path, headers, body }) {
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        method,
        hostname,
        path,
        headers: {
          accept: 'application/json',
          ...headers
        }
      },
      (res) => {
        let data = '';
        res.setEncoding('utf8');
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          try {
            const parsed = data ? JSON.parse(data) : null;
            resolve({ statusCode: res.statusCode || 0, body: parsed });
          } catch (e) {
            resolve({ statusCode: res.statusCode || 0, body: { raw: data } });
          }
        });
      }
    );

    req.on('error', reject);

    if (body !== undefined) {
      req.write(JSON.stringify(body));
    }

    req.end();
  });
}

const smsAeroService = {
  /**
   * Sends OTP SMS using SMSAero v2 API.
   * Falls back to console log if SMSAERO credentials are missing.
   */
  sendOtp: async ({ phone, code }) => {
    const safePhone = String(phone || '').replace(/\D/g, '');
    if (!safePhone) throw new ApiError(400, 'validation_error', 'phone обязателен');

    const text = `OTPбанк: код ${code}. Никому не сообщайте.`;

    if (!env.smsAeroEmail || !env.smsAeroApiKey) {
      console.warn('[smsAeroService] SMSAERO_EMAIL/SMSAERO_API_KEY not set. OTP:', safePhone, code);
      return { provider: 'disabled', ok: true };
    }

    const path = `/v2/sms/send`;

    const { statusCode, body } = await requestJson({
      method: 'POST',
      hostname: 'gate.smsaero.ru',
      path,
      headers: {
        'content-type': 'application/json',
        authorization: basicAuthHeader(env.smsAeroEmail, env.smsAeroApiKey)
      },
      body: {
        number: safePhone,
        text,
        sign: env.smsAeroSign,
        shortLink: 1
      }
    });

    const ok = statusCode >= 200 && statusCode < 300;
    if (!ok) {
      throw new ApiError(502, 'sms_provider_error', 'Не удалось отправить SMS');
    }

    if (body && body.success === false) {
      throw new ApiError(502, 'sms_provider_error', body.message || 'Не удалось отправить SMS');
    }

    return { provider: 'smsaero', ok: true, result: body };
  }
};

module.exports = { smsAeroService };
