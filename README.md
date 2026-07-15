# MemeStack MCP

[![smithery badge](https://smithery.ai/badge/memestack/mcp)](https://smithery.ai/servers/memestack/mcp)

Hosted [Model Context Protocol](https://modelcontextprotocol.io) server for [MemeStack](https://memestack.ai) — a searchable gallery of AI-tagged memes, infographics, charts, screenshots, and visual explainers, ranked by Lightning zaps. Free, public, no auth, no signup.

```
https://mcp.memestack.ai/mcp
```

Every list response returns citation blocks (markdown / HTML / plain) ready to paste with attribution. Image bytes are served from `https://api.memestack.ai/v1/images/{id}/{thumbnail|canonical|social-card}` — directly embeddable.

---

## Install

This is a hosted server. No clone, no build, no local environment. Point any MCP-aware client at the endpoint.

### Claude Code

```bash
claude mcp add --transport http memestack https://mcp.memestack.ai/mcp
```

### Claude Desktop

Edit `claude_desktop_config.json` (`%APPDATA%\Claude\` on Windows, `~/Library/Application Support/Claude/` on macOS):

```json
{
  "mcpServers": {
    "memestack": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.memestack.ai/mcp"]
    }
  }
}
```

Recent Claude Desktop versions support direct HTTP MCP servers — if yours does, you can drop the `mcp-remote` wrapper:

```json
{
  "mcpServers": {
    "memestack": { "url": "https://mcp.memestack.ai/mcp" }
  }
}
```

### Cursor

Edit `~/.cursor/mcp.json` (or per-project `.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "memestack": { "url": "https://mcp.memestack.ai/mcp" }
  }
}
```

### Continue.dev (VS Code / JetBrains)

In `~/.continue/config.json`, add under `mcpServers`:

```json
"memestack": { "url": "https://mcp.memestack.ai/mcp" }
```

### Raw JSON-RPC (any HTTP client)

```bash
curl -X POST https://mcp.memestack.ai/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

Same endpoint for `initialize`, `tools/call`, `prompts/list`, `prompts/get`, `resources/list`, `resources/read`. Protocol version: `2025-06-18`.

---

## What's exposed

- **20 tools** — 18 free read tools, 2 paid (`generate_meme`, `submit_image`) — full catalog: [docs/tools.md](docs/tools.md)
- **6 prompts** — pre-baked workflows (topic search, top zapped, cite a meme, find a meme for a vibe, research meme evolution, trending): [docs/prompts.md](docs/prompts.md)
- **3 resources** — attribution guide, tag taxonomy, recent uploads feed: [docs/resources.md](docs/resources.md)

### Tools at a glance

Discovery and search:

- `search_images` — semantic + keyword merged
- `search_text_in_image` — OCR-only search (find screenshots of specific quotes/text)
- `find_meme_for_text` — vibe-to-meme matcher for writing & social
- `reverse_image_search` — phash-based "find this image" (accepts HTTPS or `data:` URLs)
- `find_similar` / `find_related` — neighbors of a known image (visual phash / semantic embedding)
- `browse_images`, `browse_by_tag`, `browse_by_category`, `list_categories`
- `popular_tags`, `tag_autocomplete`, `get_tag_profile`
- `get_image`, `get_user_profile`, `get_leaderboard`, `get_mutation_group`

Attribution:

- `cite_image` — canonical markdown/HTML/plain attribution blocks for one or many image IDs

Paid (agent payment rails — pay per call, no account):

- `generate_meme` — AI image generation via Grok Imagine. 60 sats standard / 150 sats quality (or the USDC equivalent). Returns a hosted, auto-tagged, CDN-served image URL.
- `submit_image` — submit an image by URL into the moderation review queue. 100 sats/submission (or the USDC equivalent), always paid, no free quota. No refund on moderation rejection (duplicate/nsfw/spam/low-quality) — the fee is the anti-spam mechanism; accepted images await human review before publication.

---

## Citations are baked in

Every list response includes a `citations_combined` block in three formats (markdown / HTML / plain) for the full set, plus a per-image `citation` on every individual image. Per-source rules differ — OWID images carry CC-BY 4.0 attribution to Our World in Data; Imgflip templates carry Imgflip attribution; direct uploads carry the uploader's display name and the MemeStack page URL — and Verified Creator uploads link the creator's name directly to their own website (mandatory attribution).

**Read `memestack://attribution-guide` once per session** for the license model and per-source rules. See [docs/resources.md](docs/resources.md).

---

## Pricing & payments

Reads are free with generous daily quotas; generation is paid per call. **No account, no API key** — payment itself is the auth, over two rails:

- **x402** (USDC on Base) — standard `x402/error` + `x402/payment` `_meta` flow; works out of the box with the Cloudflare Agents SDK's `withX402Client`. Heads-up: the SDK's default `maxPaymentValue` is $0.10 — raise it to use `generate_meme` quality mode (~$0.15) or `submit_image` (100 sats, which alone exceeds $0.10 whenever BTC trades above $100k).
- **L402** (Lightning sats) — on REST, standard `WWW-Authenticate: L402 macaroon="…", invoice="…"` challenge; retry with `Authorization: L402 <macaroon>:<preimage>`. Over MCP, an experimental `l402/payment` `_meta` extension carries the same proof.

| Tool group | Free quota | Over quota / price |
|---|---|---|
| Search & browse tools (`search_images`, `browse_*`, `find_meme_for_text`, `search_text_in_image`) | 200 calls/day/IP | 5 sats/call |
| `reverse_image_search` | 10 calls/day/IP | 21 sats/call |
| `generate_meme` | always paid | 60 sats standard / 150 sats quality |
| `submit_image` | always paid | 100 sats/submission |
| Everything else (`get_image`, `cite_image`, tags, categories, leaderboard, resources, prompts) | unmetered, free | — |

Paid REST twins (same prices, standard dual-header 402): `POST api.memestack.ai/v1/agent/generate`, `POST api.memestack.ai/v1/agent/reverse-search`, and `POST api.memestack.ai/v1/agent/submit` — see the [OpenAPI spec](https://api.memestack.ai/openapi.json).

One payment delivers at most one result — if a call fails or times out mid-generation, retry with the **same** payment proof to resume; you are never charged twice for one payment.

`submit_image` submissions land in the moderation review queue, not directly in the public gallery — there is **no refund if moderation rejects** the submission (duplicate/nsfw/spam/low-quality), since the review attempt itself is what the fee buys.

---

## Discovery surface

How MemeStack exposes itself to AI agents, beyond MCP:

| Surface | URL | Purpose |
|---|---|---|
| `llms.txt` | [memestack.ai/llms.txt](https://memestack.ai/llms.txt) | Concise human-readable summary + endpoint links |
| `ai-plugin.json` | [memestack.ai/.well-known/ai-plugin.json](https://memestack.ai/.well-known/ai-plugin.json) | ChatGPT plugin manifest |
| OpenAPI 3.1 | [api.memestack.ai/openapi.json](https://api.memestack.ai/openapi.json) | REST API the MCP wraps |
| Apex MCP mirror | [memestack.ai/mcp](https://memestack.ai/mcp) | Same MCP endpoint at apex (for naive scanners) |
| oEmbed | [api.memestack.ai/v1/oembed](https://api.memestack.ai/v1/oembed) | Photo-type oEmbed for gallery URLs |
| Sitemap | [memestack.ai/sitemap.xml](https://memestack.ai/sitemap.xml) | Sitemap index with image, page, and user sub-sitemaps |

---

## Source

The MCP server runs on Cloudflare Workers and proxies the public MemeStack REST API ([api.memestack.ai](https://api.memestack.ai)). The server's source is part of the larger MemeStack codebase, which is not publicly mirrored at this time. This repository hosts the public-facing docs, install snippets, and tool catalog so directory submissions and integrators can link to a stable, browsable surface.

If you want to fork the *protocol behavior* and self-host a similar gallery, the [REST API](https://api.memestack.ai/openapi.json) is documented and a sufficient backend for any MCP-style wrapper.

The `Dockerfile` in this repo is a thin proxy — it uses `mcp-remote` to bridge stdio MCP to the hosted HTTP endpoint, and exists only so MCP directories that require Dockerfile-based introspection (Glama, etc.) can validate the live tools/prompts/resources. End users should connect directly to `mcp.memestack.ai/mcp` per the [Install](#install) section above; the Docker image holds no source.

---

## License

MIT — covers the snippets and docs in this repo. The hosted MemeStack service is governed separately by [memestack.ai/terms](https://memestack.ai/terms). Image content carries per-source licenses, surfaced in each image's `citation` block.
