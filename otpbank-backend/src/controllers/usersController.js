const usersService = require('../services/usersService');

const searchByPhone = async (req, res) => {
  try {
    const { phone } = req.query;
    if (!phone) {
      return res.status(400).json({ error: 'Phone query param required' });
    }

    const digitsOnly = phone.replace(/[^0-9]/g, '');
    if (digitsOnly.length < 10) {
      return res.status(400).json({ error: 'Invalid phone number' });
    }

    const normalized = digitsOnly.length === 10 ? '7' + digitsOnly : digitsOnly;
    const user = await usersService.findByPhone(normalized);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      id: user.id,
      firstName: user.first_name,
      lastName: user.last_name,
      middleName: user.middle_name,
      phone: user.phone,
    });
  } catch (err) {
    console.error('searchByPhone error', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  usersController: {
    searchByPhone,
  },
};
