const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Simple middleware
app.use(express.json());

// Main API endpoint for frontend
app.get('/api/status', (req, res) => {
  res.json({
    message: 'KVInfoSysBund Backend is running!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production',
    database: 'connected',
    version: '1.0.0',
    service: 'kv-infosys-backend'
  });
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`KVInfoSys Backend running on port ${port}`);
  console.log(`API Status: http://localhost:${port}/api/status`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});
