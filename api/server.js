const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs'); 
const { Pool } = require('pg');
const app = express();
const https = require('https');

const sslOptions = {
  key: fs.readFileSync('/home/deployatron/.acme.sh/api.3deploy.shop_ecc/api.3deploy.shop.key'),
  cert: fs.readFileSync('/home/deployatron/.acme.sh/api.3deploy.shop_ecc/api.3deploy.shop.cer'),
  ca: fs.readFileSync('/home/deployatron/.acme.sh/api.3deploy.shop_ecc/ca.cer'),
};

app.use(cors());

app.use(express.static(path.join(__dirname, 'static')));

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// let users = [
//   { id: 1, name: 'John Doe', age: 30 },
//   { id: 2, name: 'Jane Doe', age: 26 }
// ];

app.get('/api/users', async (req, res) => {
  try {
    res.status(500).json({ error: 'test staging error' });
    const result = await pool.query('SELECT * FROM users');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database query failed' });
  }
});

https.createServer(sslOptions, app).listen(3000, () => {
  console.log('HTTPS works on 3000');
});
