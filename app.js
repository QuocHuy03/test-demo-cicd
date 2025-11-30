const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Metrics endpoint for Prometheus
app.get('/metrics', (req, res) => {
  const metrics = `
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200"} ${requestCount}

# HELP http_request_duration_seconds Duration of HTTP requests in seconds
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.1"} ${requestCount}
http_request_duration_seconds_bucket{le="0.5"} ${requestCount}
http_request_duration_seconds_bucket{le="1"} ${requestCount}
http_request_duration_seconds_bucket{le="+Inf"} ${requestCount}
http_request_duration_seconds_sum 0
http_request_duration_seconds_count ${requestCount}
`;
  res.set('Content-Type', 'text/plain');
  res.send(metrics);
});

let requestCount = 0;

// Main API endpoint
app.get('/', (req, res) => {
  requestCount++;
  res.json({
    message: 'Hello from Node.js App on Kubernetes!',
    version: '1.0.1', // Updated via CI/CD
    requests: requestCount,
    environment: process.env.NODE_ENV || 'development',
    deployedAt: new Date().toISOString()
  });
});

// API endpoint
app.get('/api/huydev', (req, res) => {
  requestCount++;
  res.json({
    message: 'Hello World!',
    timestamp: new Date().toISOString(),
    requests: requestCount
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});

