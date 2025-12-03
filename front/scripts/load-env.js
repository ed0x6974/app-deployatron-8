const dotenv = require("dotenv");
const mode = process.env.APP_ENV || "dev";

dotenv.config({
  path: `.env.${mode}`,
});

console.log(`Loaded env: .env.${mode}`);