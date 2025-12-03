const dotenv = require("dotenv");
const mode = process.env.APP_ENV || "dev";

dotenv.config({
  path: `.env.${mode}`,
  override: false,
});

console.log(`Loaded env: .env.${mode}`);