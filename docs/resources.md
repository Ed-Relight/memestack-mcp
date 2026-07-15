# Resources

MCP resources are documents the server exposes for read access — typically reference material the client should load once per session rather than re-derive from tool calls.

Fetch the live, authoritative list:

```bash
curl -X POST https://mcp.memestack.ai/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"resources/list"}' | jq
```

Read one:

```bash
curl -X POST https://mcp.memestack.ai/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"resources/read","params":{"uri":"memestack://attribution-guide"}}'
```

---

## `memestack://attribution-guide`

**MIME**: `text/markdown`

How to cite MemeStack images: license model, recommended formats (markdown / HTML / plain), per-source attribution rules.

**Read this once at session start.** It explains the per-source license differences — OWID images carry CC-BY 4.0 attribution back to Our World in Data; Imgflip templates carry Imgflip attribution; 4chan archives carry archive-site attribution; Telegram bot submissions and direct uploads carry the uploader's display name — and Verified Creator uploads link the creator's name directly to their own website (mandatory attribution). The `citation` block on every tool response is pre-formatted against these rules — you can paste it verbatim and stay compliant.

## `memestack://taxonomy`

**MIME**: `application/json`

Full category → tag tree with image counts. Cached server-side for 1 hour. Useful for:

- Discovering what tags exist before filtering with `search_images` or `browse_by_tag`
- Building UI that surfaces the full category hierarchy
- Mapping LLM-generated free-tags onto the controlled tag vocabulary

## `memestack://recent`

**MIME**: `application/json`

The last 50 approved images on MemeStack, newest first, each with its citation block. Cached server-side for 60 seconds. Useful for:

- Real-time "what's new" feeds in agent UIs
- Periodic polling without paying the cost of running a full search
