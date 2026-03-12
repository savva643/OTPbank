const express = require('express');
const { authRequired } = require('../middlewares/auth');
const { paymentsController } = require('../controllers/paymentsController');

const paymentsRoutes = express.Router();

paymentsRoutes.post('/card-transfer', authRequired, paymentsController.cardTransfer);
paymentsRoutes.post('/phone-transfer', authRequired, paymentsController.phoneTransfer);
paymentsRoutes.post('/sbp', authRequired, paymentsController.sbpTransfer);
paymentsRoutes.post('/bills', authRequired, paymentsController.payBills);
paymentsRoutes.post('/mobile', authRequired, paymentsController.mobileTopUp);

paymentsRoutes.post('/nfc/start', authRequired, paymentsController.nfcStart);
paymentsRoutes.post('/nfc/confirm', authRequired, paymentsController.nfcConfirm);

paymentsRoutes.post('/qr/scan', authRequired, paymentsController.qrScan);
paymentsRoutes.post('/qr/pay', authRequired, paymentsController.qrPay);

module.exports = { paymentsRoutes };
