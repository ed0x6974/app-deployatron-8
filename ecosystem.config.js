module.exports = {
  apps: [
    {
      name: "backend",
      script: "./api/server.js",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "500M",
      env: {
        DB_USER: "",
        DB_HOST: "",
        DB_NAME: "",
        DB_PASSWORD: "",
        DB_PORT: 5432,
        PORT: 3000,
      },
      log_file: "./logs/combined.log",
      out_file: "./logs/out.log",
      error_file: "./logs/error.log",
      time: true
    },
  ],
};