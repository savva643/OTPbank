const { categoriesService } = require('../services/categoriesService');

async function getCategories(req, res) {
  try {
    const categories = await categoriesService.getCategories();
    res.json({ items: categories });
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
}

async function getServicesByCategory(req, res) {
  try {
    const { categoryId } = req.params;
    const services = await categoriesService.getServicesByCategory(categoryId);
    res.json({ items: services });
  } catch (error) {
    console.error('Error fetching services:', error);
    res.status(500).json({ error: 'Failed to fetch services' });
  }
}

async function searchServices(req, res) {
  try {
    const { q } = req.query;
    if (!q || q.trim().length === 0) {
      return res.status(400).json({ error: 'Search query is required' });
    }
    const services = await categoriesService.searchServices(q.trim());
    res.json({ items: services });
  } catch (error) {
    console.error('Error searching services:', error);
    res.status(500).json({ error: 'Failed to search services' });
  }
}

module.exports = {
  categoriesController: {
    getCategories,
    getServicesByCategory,
    searchServices,
  },
};
