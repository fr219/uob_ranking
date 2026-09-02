const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { query } = require('../db');

function getToken(req) {
  const header = req.get('authorization');
  return header && header.startsWith('Bearer ') ? header.slice(7) : null;
}

async function authenticate(req, res, next) {
  const token = getToken(req);

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const session = await query(
      `SELECT id FROM user_sessions
       WHERE session_token = $1 AND user_id = $2 AND is_active = TRUE AND expires_at > NOW()`,
      [tokenHash, req.user.id]
    );
    if (!session.rows[0]) {
      return res.status(401).json({ error: 'Session is no longer active' });
    }
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    return next();
  };
}

module.exports = { authenticate, requireRole };
