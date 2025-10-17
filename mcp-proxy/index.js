require('dotenv').config();
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const morgan = require('morgan');

const target = process.env.GITHUB_MCP_URL || 'https://api.githubcopilot.com/mcp';
const port = process.env.PORT || 8080;
const token = process.env.GITHUB_PAT || process.env.GITHUB_TOKEN;

if (!token) {
  console.warn('Warning: GITHUB_PAT not set. The proxy will attempt unauthenticated requests.');
}

const app = express();
app.use(morgan('dev'));

app.get('/health', (req, res) => res.json({ ok: true, target }));

app.use('/mcp', createProxyMiddleware({
  target,
  changeOrigin: true,
  pathRewrite: { '^/mcp': '' },
  onProxyReq(proxyReq, req, res) {
    if (token) {
      proxyReq.setHeader('Authorization', `Bearer ${token}`);
    }
    // Optionally forward the user's GitHub username or other headers
  },
  onError(err, req, res) {
    console.error('Proxy error', err);
    res.status(502).json({ error: 'Bad gateway', details: err.message });
  }
}));

app.listen(port, () => console.log(`MCP proxy listening on http://localhost:${port}/mcp -> ${target}`));
