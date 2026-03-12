const { ApiError } = require('../utils/apiError');

function errorHandler(err, req, res, next) {
  const apiErr = err instanceof ApiError ? err : new ApiError(500, 'internal_error', 'Внутренняя ошибка сервера');

  if (!(err instanceof ApiError)) {
    console.error(err);
  }

  res.status(apiErr.statusCode).json({
    error: {
      code: apiErr.code,
      message: apiErr.message
    }
  });
}

module.exports = { errorHandler };
