const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs'); 
const app = express();
const https = require('https');

const sslOptions = {
  key: fs.readFileSync('/root/.acme.sh/api.3deploy.shop_ecc/api.3deploy.shop.key'),
  cert: fs.readFileSync('/root/.acme.sh/api.3deploy.shop_ecc/api.3deploy.shop.cer'),
  ca: fs.readFileSync('/root/.acme.sh/api.3deploy.shop_ecc/ca.cer'),
};

app.use(cors());

app.use(express.static(path.join(__dirname, 'static')));

let users = [
  { id: 1, name: 'John Doe', age: 30 },
  { id: 2, name: 'Jane Doe', age: 26 }
];

app.get('/api/users', (req, res) => {
  res.json(users);
});

https.createServer(sslOptions, app).listen(3000, () => {
  console.log('HTTPS works on 3000');
});
