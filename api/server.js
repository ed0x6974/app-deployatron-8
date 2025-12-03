const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs'); 
const { Pool } = require('pg');
const app = express();
const https = require('https');

const MODE = process.env.MODE || 'staging';

app.use(cors());

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database query failed' });
  }
});

if (MODE === 'prod') {
  const sslOptions = {
    key: fs.readFileSync('/home/deployatron/.acme.sh/api.3deploy.shop_ecc/api.3deploy.shop.key'),
    cert: fs.readFileSync('/home/deployatron/.acme.sh/api.3deploy.shop_ecc/api.3deploy.shop.cer'),
    ca: fs.readFileSync('/home/deployatron/.acme.sh/api.3deploy.shop_ecc/ca.cer'),
  };

  https.createServer(sslOptions, app).listen(3000, () => {
    console.log('Production HTTPS works on port 3000');
  });
} else {
  const SOCKET_PATH = path.join(__dirname, '../deployatron.sock');

  if (fs.existsSync(SOCKET_PATH)) fs.unlinkSync(SOCKET_PATH);

  app.listen(SOCKET_PATH, () => {
    fs.chmodSync(SOCKET_PATH, 0o660);
    console.log(`Staging server running on socket ${SOCKET_PATH}`);
  });
}