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

**Read this once at session start.** It explains the per-source differences — OWID, Eurostat and EEA charts are CC-BY 4.0 and USDA ERS charts are US public domain, each credited to its publisher; Verified Creator uploads are all rights reserved and link the creator's name directly to their own website (mandatory attribution); every other image (direct uploads, Telegram submissions, Imgflip templates, 4chan archives, X saves, AI-generated and agent-submitted images) carries no license from MemeStack — its rights stay with their owners, and its citation records where it was found. The `citation` block on every tool response is pre-formatted against these rules: paste it verbatim, but it is attribution, not permission to reuse.

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

## `memestack://top/{period}` (template)

**MIME**: `application/json` · listed by `resources/templates/list`

The top 50 zapped images for `period` ∈ {`day`, `week`, `month`, `all`}, each with its citation block, plus a combined citation block. Cached server-side for 5 minutes. Example: `memestack://top/week`.

---

On the directory endpoint (`https://mcp.memestack.ai/mcp/directory`, for Claude.ai and ChatGPT) the same resources are served, and none of them ever includes an image classified controversial.
