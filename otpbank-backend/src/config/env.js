require('dotenv').config();

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT || 3000),
  databaseUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET,
  smsAeroEmail: process.env.SMSAERO_EMAIL,
  smsAeroApiKey: process.env.SMSAERO_API_KEY,
  smsAeroSign: process.env.SMSAERO_SIGN || 'OTPbank',
  smsAeroTestMode: String(process.env.SMSAERO_TEST_MODE || '').toLowerCase() === 'true'
};

module.exports = { env };
