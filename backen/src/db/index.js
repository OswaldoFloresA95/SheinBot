const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // if you need ssl in production, configure here
  // ssl: { rejectUnauthorized: false }
});

async function query(text, params) {
  return pool.query(text, params);
}

module.exports = {
  query,
  pool
};
