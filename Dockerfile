# Thin-proxy Dockerfile for MCP-directory introspection (Glama, etc.).
#
# The actual MemeStack MCP server runs on Cloudflare Workers at
# https://mcp.memestack.ai/mcp and is not packaged as a Docker image —
# this container exists only so directory crawlers that require a
# Dockerfile can start a process that speaks the MCP stdio protocol.
#
# `mcp-remote` (npm) is the canonical stdio<->HTTP bridge. The container's
# stdio is the MCP transport; mcp-remote forwards every JSON-RPC frame
# to the hosted endpoint and pipes the response back. Tool/prompt/resource
# introspection therefore reflects the real, live server.
#
# Connect directly without Docker — point any MCP-aware client at:
#   https://mcp.memestack.ai/mcp
# See the README for client config snippets.

FROM node:20-alpine

# Trust certs for HTTPS to mcp.memestack.ai
RUN apk add --no-cache ca-certificates && update-ca-certificates

ENTRYPOINT ["npx", "-y", "mcp-remote", "https://mcp.memestack.ai/mcp"]
