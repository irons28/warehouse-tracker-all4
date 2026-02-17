module.exports = {
  apps: [
    {
      name: 'warehouse-tracker',
      script: 'server.js',
      cwd: __dirname,
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HTTPS_PORT: 3443,
        TRUST_PROXY: 1,
      },
      instances: 1,
      exec_mode: 'fork',
      max_memory_restart: '600M',
      autorestart: true,
      watch: false,
      time: true,
      out_file: './logs/app.out.log',
      error_file: './logs/app.err.log',
      merge_logs: true,
    },
  ],
};
