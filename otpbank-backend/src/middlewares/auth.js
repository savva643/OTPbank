const jwt = require('jsonwebtoken');
const { env } = require('../config/env');
const { ApiError } = require('../utils/apiError');

function authRequired(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return next(new ApiError(401, 'unauthorized', 'Необходим токен авторизации'));

  const [type, token] = header.split(' ');
  if (type !== 'Bearer' || !token) return next(new ApiError(401, 'unauthorized', 'Некорректный токен'));
  if (!env.jwtSecret) return next(new ApiError(500, 'misconfigured', 'JWT_SECRET не задан'));

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.user = { id: payload.sub };
    return next();
  } catch (e) {
    return next(new ApiError(401, 'unauthorized', 'Токен недействителен'));
  }
}

module.exports = { authRequired };
