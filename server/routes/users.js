const express = require('express');
const { query } = require('../db');
const { authenticate, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();
router.use(authenticate, requireRole('admin'));

router.get('/', async (req, res, next) => {
  try {
    const result = await query(
      `SELECT u.id, u.name, u.email, u.role, u.department_id, d.name AS department_name, u.created_at
       FROM users u LEFT JOIN departments d ON d.id = u.department_id
       ORDER BY u.created_at DESC`
    );
    return res.json({ users: result.rows });
  } catch (error) {
    return next(error);
  }
});

router.patch('/:id', async (req, res, next) => {
  const { name, role, department_id } = req.body;
  if (!/^\d+$/.test(req.params.id) ||
      (name !== undefined && (typeof name !== 'string' || name.trim().length < 2)) ||
      (role !== undefined && !['admin', 'user', 'manager'].includes(role))) {
    return res.status(400).json({ error: 'Invalid user update' });
  }

  try {
    const result = await query(
      `UPDATE users
       SET name = COALESCE($1, name), role = COALESCE($2, role), department_id = $3
       WHERE id = $4
       RETURNING id, name, email, role, department_id, created_at`,
      [name === undefined ? null : name.trim(), role || null, department_id || null, Number(req.params.id)]
    );
    if (!result.rows[0]) return res.status(404).json({ error: 'User not found' });
    return res.json({ user: result.rows[0] });
  } catch (error) {
    return next(error);
  }
});

router.delete('/:id', async (req, res, next) => {
  if (!/^\d+$/.test(req.params.id)) return res.status(400).json({ error: 'Invalid user id' });
  if (Number(req.params.id) === req.user.id) return res.status(400).json({ error: 'You cannot delete your own account' });
  try {
    const result = await query('DELETE FROM users WHERE id = $1 RETURNING id', [Number(req.params.id)]);
    if (!result.rows[0]) return res.status(404).json({ error: 'User not found' });
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
