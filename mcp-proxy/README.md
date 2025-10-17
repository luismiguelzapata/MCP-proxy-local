# MCP Proxy

This is a simple local proxy to forward MCP requests to GitHub Copilot's MCP endpoint using your GITHUB_PAT.

Usage:

1. Copy `.env.example` to `.env` and set `GITHUB_PAT`.
2. Install dependencies: `npm install`.
3. Start the proxy: `npm start`.
4. Point VS Code MCP config to `http://localhost:8080/mcp/`.

Health endpoint: `http://localhost:8080/health` returns JSON `{ok: true}`.

Quick start
1. Copy `.env.example` to `.env` and set `GITHUB_PAT`.
2. Install dependencies:

```bash
npm install
```

3. Start the proxy (background):

```bash
nohup npm start > mcp-proxy.log 2>&1 & echo $! > mcp-proxy.pid
```

4. Stop the proxy:

```bash
kill $(cat mcp-proxy.pid) && rm mcp-proxy.pid
```

VS Code MCP config
Update your workspace `.vscode/mcp.json` to point to the local server or set the MCP server to `local`:

```jsonc
{
	"servers": {
		"local": { "type": "http", "url": "http://localhost:8080/mcp/" }
	}
}
```

Security notes
- Keep your PAT secret: never commit `.env` to git. Use the OS keyring or environment variables in CI.
- Limit PAT scopes to the minimal required for MCP.
