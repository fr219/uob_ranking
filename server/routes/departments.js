const express = require('express');
const { query } = require('../db');
const { authenticate, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();
router.use(authenticate, requireRole('admin'));

router.get('/', async (req, res, next) => {
  try {
    const result = await query('SELECT id, name, created_at FROM departments ORDER BY name');
    return res.json({ departments: result.rows });
  } catch (error) {
    return next(error);
  }
});

router.post('/', async (req, res, next) => {
  const name = typeof req.body.name === 'string' ? req.body.name.trim() : '';
  if (name.length < 2 || name.length > 120) return res.status(400).json({ error: 'A valid department name is required' });

  try {
    const result = await query(
      'INSERT INTO departments (name) VALUES ($1) RETURNING id, name, created_at',
      [name]
    );
    return res.status(201).json({ department: result.rows[0] });
  } catch (error) {
    return next(error);
  }
});

router.patch('/:id', async (req, res, next) => {
  const name = typeof req.body.name === 'string' ? req.body.name.trim() : '';
  if (!/^\d+$/.test(req.params.id) || name.length < 2 || name.length > 120) {
    return res.status(400).json({ error: 'A valid id and department name are required' });
  }

  try {
    const result = await query(
      'UPDATE departments SET name = $1 WHERE id = $2 RETURNING id, name, created_at',
      [name, Number(req.params.id)]
    );
    if (!result.rows[0]) return res.status(404).json({ error: 'Department not found' });
    return res.json({ department: result.rows[0] });
  } catch (error) {
    return next(error);
  }
});

router.delete('/:id', async (req, res, next) => {
  if (!/^\d+$/.test(req.params.id)) return res.status(400).json({ error: 'Invalid department id' });
  try {
    const result = await query('DELETE FROM departments WHERE id = $1 RETURNING id', [Number(req.params.id)]);
    if (!result.rows[0]) return res.status(404).json({ error: 'Department not found' });
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
