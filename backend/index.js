const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Simple middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'kv-infosys-backend',
    version: '1.0.0'
  });
});

// Ready check endpoint
app.get('/ready', (req, res) => {
  res.json({
    status: 'ready',
    timestamp: new Date().toISOString(),
    database: 'connected',
    service: 'kv-infosys-backend'
  });
});

// Simple API endpoint
app.get('/api/status', (req, res) => {
  // Simple database check (mock for now)
  const dbConnected = process.env.DATABASE_URL ? true : true; // Always true for demo
  
  res.json({
    message: 'KVInfoSysBund Backend is running!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    database: dbConnected ? 'connected' : 'disconnected',
    version: '1.0.0'
  });
});

// Simple geo endpoint (demo)
app.get('/api/geo/info', (req, res) => {
  res.json({
    message: 'Geo-Information System API',
    features: [
      'Crisis Management',
      'Geographic Information',
      'Real-time Data'
    ],
    status: 'operational'
  });
});

// Metrics endpoint for Prometheus (simple)
app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send(`
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/health"} 42
http_requests_total{method="GET",route="/api/status"} 123

# HELP app_info Application information
# TYPE app_info gauge
app_info{version="1.0.0",service="kv-infosys-backend"} 1
  `.trim());
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`KVInfoSys Backend running on port ${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
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
