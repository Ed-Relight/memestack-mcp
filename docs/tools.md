# Tools

This is a quick-reference catalog of the 19 tools exposed by the MemeStack MCP server. The authoritative source is the live `tools/list` response — see the curl command at the bottom of this page to fetch it.

Tiers: `free` (no auth, no cost) or `enterprise` (reserved for a future agent-tier monetization flow). Every tool is read-only and idempotent unless noted otherwise.

---

## Discovery & search

### `search_images` *(free)*

Search the gallery. Runs semantic AI + keyword matching in parallel and merges results.

- **Required**: `query` (string). Alias `q` accepted — matches the REST `?q=` convention.
- **Optional**: `tag` (single tag slug), `tags` (comma-separated AND-filter, e.g. `"bitcoin,meme"`), `limit` (1–50, default 10), `offset`, `sort` (`newest` | `popular` | `oldest`; omit for relevance ranking).
- **Returns**: `{ images: [...], total, citations_combined }`. Each image has caption, simplified tag array, zap stats, `thumbnail_url`, `canonical_url`, `page_url`, and a per-image `citation` block.

### `search_text_in_image` *(free)*

OCR-only search — matches only the `text_in_image` field, not captions or tags. Use this to find screenshots of specific quotes, signs, watermarks, or memes with specific embedded text.

- **Required**: `query` (string).
- **Optional**: `limit`, `offset`.

### `find_meme_for_text` *(free)*

Vibe-to-meme matcher. Find a meme that captures an idea or concept — ready to embed with citation blocks. Use this when writing posts, articles, or social content.

- **Required**: `vibe` (string).
- **Optional**: `limit` (default 5).

### `reverse_image_search` *(free, rate-limited 10/min/IP)*

Find MemeStack images visually similar to a given image. Accepts an HTTPS URL or a `data:image/...;base64,...` URL (handy for pasting bytes from agent context). Returns visually-similar matches via perceptual-hash (dHash) Hamming distance, plus citation blocks.

- **Required**: `url` (string — HTTPS or `data:` URL).
- **Optional**: `limit`.

### `find_similar` *(free)*

Visually-similar neighbors of a known image (phash-only — no semantic).

- **Required**: `id` (image UUID).
- **Optional**: `limit` (1–20, default 10).

### `find_related` *(free)*

Semantically-related neighbors of a known image (AI embedding similarity — similar topic/meaning, may not look alike).

- **Required**: `id` (image UUID).
- **Optional**: `limit` (1–20, default 10).

### `get_image` *(free)*

Full metadata for one image — caption, alt text, tags, OCR text, dimensions, MIME, zap stats, URLs, citation.

- **Required**: `id` (image UUID).

### `get_mutation_group` *(free)*

Get all variants of a meme template tracked on MemeStack. Returns the dominant image plus every variant in the same mutation group, with citation blocks for each. Use this to research how a meme has evolved or to find variants of a known image.

- **Required**: `image_id` (UUID).

---

## Browse

### `browse_images` *(free)*

Browse and filter the gallery without a search query. Useful for discovering content by tag, trending, or recent uploads.

- **Optional**: `tag`, `sort` (`newest` | `popular` | `oldest` | `trending`; default `newest`), `limit`, `offset`.

### `browse_by_tag` *(free)*

Browse images for a specific tag. Returns the tag profile (description, stats) and optionally a paginated list of images.

- **Required**: `tag` (slug).
- **Optional**: `limit`, `offset`.

### `browse_by_category` *(free)*

Get a category and its featured images. Categories group related tags — e.g. "charts", "memes", "lightning-network".

- **Required**: `category` (slug).

### `list_categories` *(free)*

List all 16 image categories. Call this first to discover what `category` values `browse_by_category` accepts.

- **No parameters.**

### `get_tag_profile` *(free)*

Tag profile (description, image count, total zaps, related tags) without fetching any images. Use `browse_by_tag` instead if you also want images.

- **Required**: `tag` (slug).

---

## Tag discovery

### `popular_tags` *(free)*

Most-used tags on MemeStack by all-time usage count.

- **Optional**: `limit` (default 20).
- Note: time-period filtering is not yet supported — counts are lifetime totals.

### `tag_autocomplete` *(free)*

Suggest tag slugs matching a prefix. Use this to verify a tag exists before filtering by it.

- **Required**: `prefix` (≥ 2 characters).
- **Optional**: `limit`.

---

## Profiles & rankings

### `get_user_profile` *(free)*

Public profile — display name, stats, avatar info. Strips pubkey and role.

- **Required**: `identifier` (pubkey or UUID).

### `get_leaderboard` *(free)*

Top-ranked images by zaps received, or top zappers by amount zapped.

- **Required**: `type` (`images` | `zappers`).
- **Optional**: `period` (`day` | `week` | `month` | `all`; default `week`).

---

## Attribution

### `cite_image` *(free)*

Generate canonical attribution blocks for one or more MemeStack images. Returns markdown, HTML, and plain-text citation strings ready to paste, plus a combined block for citing multiple images at once.

- **Required**: `image_ids` (array of UUIDs).
- **Returns**: `{ citations: [...], combined: { markdown, html, plain }, missing_ids: [...] }`.

---

## Write (stub)

### `submit_image` *(enterprise — currently a stub)*

Reserved for a future agent-tier monetization flow. Calling it returns a polite redirect to [memestack.ai/mcp/agent-tier](https://memestack.ai/mcp/agent-tier).

- **Required**: `image_url`.
- **Optional**: `caption`, `tags`.

---

## Fetching the live, authoritative schema

```bash
curl -X POST https://mcp.memestack.ai/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | jq
```

Every tool ships an `inputSchema` (JSON Schema) and an `annotations` block (`title`, `readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`, `tier`). MCP-aware clients render these automatically.
