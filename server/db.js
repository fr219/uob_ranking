const path = require('path');
const { Pool } = require('pg');
require('dotenv').config({ path: path.resolve(__dirname, '.env') });

const {
  DB_HOST,
  DB_PORT,
  DB_USER,
  DB_PASSWORD,
  DB_NAME,
  DATABASE_URL
} = process.env;

if (!DATABASE_URL && (!DB_HOST || !DB_PORT || !DB_USER || !DB_PASSWORD || !DB_NAME)) {
  throw new Error(
    'Missing PostgreSQL environment variables. Please set DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, or DATABASE_URL.'
  );
}

const pool = new Pool({
  connectionString: DATABASE_URL || undefined,
  host: DATABASE_URL ? undefined : DB_HOST,
  port: DATABASE_URL ? undefined : Number(DB_PORT || 5432),
  user: DATABASE_URL ? undefined : DB_USER,
  password: DATABASE_URL ? undefined : DB_PASSWORD,
  database: DATABASE_URL ? undefined : DB_NAME,
  ssl: {
    rejectUnauthorized: false
  }
});

pool.on('error', (err) => {
  console.error('Unexpected PostgreSQL client error:', err);
});

async function query(text, params) {
  const client = await pool.connect();

  try {
    return await client.query(text, params);
  } finally {
    client.release();
  }
}

module.exports = {
  pool,
  query
};