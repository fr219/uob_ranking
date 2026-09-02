const crypto = require('crypto');
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { query } = require('../db');
const { authenticate } = require('../middleware/authMiddleware');

const router = express.Router();
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function publicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    department_id: user.department_id
  };
}

function createToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role, department_id: user.department_id },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '8h' }
  );
}

async function createSession(user, token) {
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  await query(
    `INSERT INTO user_sessions (user_id, session_token, expires_at)
     VALUES ($1, $2, NOW() + ($3 * INTERVAL '1 second'))`,
    [user.id, tokenHash, 8 * 60 * 60]
  );
}

router.post('/register', async (req, res, next) => {
  const { name, email, password, department_id } = req.body;

  if (typeof name !== 'string' || name.trim().length < 2 ||
      typeof email !== 'string' || !emailPattern.test(email) ||
      typeof password !== 'string' || password.length < 8) {
    return res.status(400).json({ error: 'Name, valid email, and an 8-character password are required' });
  }

  try {
    const passwordHash = await bcrypt.hash(password, 12);
    const result = await query(
      `INSERT INTO users (name, email, department_id, password_hash, role)
       VALUES ($1, $2, $3, $4, 'user')
       RETURNING id, name, email, department_id, role`,
      [name.trim(), email.trim().toLowerCase(), department_id || null, passwordHash]
    );
    const user = result.rows[0];
    const token = createToken(user);
    await createSession(user, token);
    return res.status(201).json({ user: publicUser(user), token });
  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({ error: 'An account with that email already exists' });
    }
    return next(error);
  }
});

router.post('/login', async (req, res, next) => {
  const { email, password } = req.body;

  if (typeof email !== 'string' || typeof password !== 'string') {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const result = await query(
      'SELECT id, name, email, department_id, role, password_hash FROM users WHERE email = $1',
      [email.trim().toLowerCase()]
    );
    const user = result.rows[0];
    const valid = user ? await bcrypt.compare(password, user.password_hash) : false;

    if (!valid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const token = createToken(user);
    await createSession(user, token);
    return res.json({ user: publicUser(user), token });
  } catch (error) {
    return next(error);
  }
});

router.get('/me', authenticate, async (req, res, next) => {
  try {
    const result = await query(
      `SELECT id, name, email, department_id, role
       FROM users WHERE id = $1`,
      [req.user.id]
    );
    if (!result.rows[0]) return res.status(404).json({ error: 'User not found' });
    return res.json({ user: publicUser(result.rows[0]) });
  } catch (error) {
    return next(error);
  }
});

router.post('/logout', authenticate, async (req, res, next) => {
  try {
    const token = req.get('authorization').slice(7);
    await query(
      'UPDATE user_sessions SET is_active = FALSE WHERE user_id = $1 AND session_token = $2',
      [req.user.id, crypto.createHash('sha256').update(token).digest('hex')]
    );
    return res.json({ message: 'Logged out successfully' });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
