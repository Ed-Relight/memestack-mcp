# Tools

This is a quick-reference catalog of the 21 tools exposed by the MemeStack MCP server. The authoritative source is the live `tools/list` response — see the curl command at the bottom of this page to fetch it.

Tiers: every tool is `tier: free` at the MCP protocol level — payment (where required) is enforced by the agent payment gate, not the tier system. 19 tools are free reads (some with a daily quota, above which they fall back to a metered price — see "Pricing & payments" in the [main README](../README.md)); `generate_meme` and `submit_image` are always paid, no free quota. Every tool is read-only and idempotent except the two paid tools, which are neither.

Safe by default: the nine list-returning tools — `search_images`, `search_charts`, `search_text_in_image`, `find_meme_for_text`, `reverse_image_search`, `find_similar`, `find_related`, `browse_images`, `browse_by_tag` — take an optional `include_controversial` (boolean, default `false`). Left off, results exclude images MemeStack classifies as controversial; set to `true`, they are included, marked `[controversial]` in the text view and carrying `controversial: true` in the structured payload. A non-boolean value is rejected before any request. By-id tools (`get_image`, `get_mutation_group`, `cite_image`) always answer and carry the flag. Over REST the same switch is `?content=all` on the browse endpoints.

---

## Discovery & search

### `search_images` *(free)*

Search the gallery. Runs semantic AI + keyword matching in parallel and merges results.

- **Required**: `query` (string). Alias `q` accepted — matches the REST `?q=` convention.
- **Optional**: `tag` (single tag slug), `tags` (comma-separated AND-filter, e.g. `"bitcoin,meme"`), `limit` (1–50, default 10), `offset`, `sort` (`newest` | `popular` | `oldest`; omit for relevance ranking).
- **Returns**: `{ images: [...], total, citations_combined }`. Each image has caption, simplified tag array, zap stats, `thumbnail_url`, `canonical_url`, `page_url`, and a per-image `citation` block.

### `search_charts` *(free)*

Search charts, maps and infographics that carry structured source metadata — the publishing dataset and its academic citation, the unit, the regions plotted, and the period the chart actually displays (never the dataset's wider history). Results say whether the source has published newer data since capture. `browse_by_tag`, `browse_by_category`, `get_leaderboard` and `get_mutation_group` return images without this metadata; the other search and image tools include it whenever a row exists. This tool covers only images that have stored metadata, so use `search_images` for the widest chart coverage. A chart whose displayed period could not be proven from the image itself is returned without one rather than with a guess.

- **Required**: `query` (string — what the chart should show, e.g. `"global cereal yields"`).
- **Optional**: `region` (entity exactly as the chart names it, e.g. `"World"`, `"Germany"`), `data_from`/`data_to` (years — matches charts whose DISPLAYED period overlaps the range; charts with no provable displayed period are excluded, and the underlying dataset's wider history is never used for this test), `chart_source` (upstream source key, e.g. `"owid"`), `limit` (1–50, default 10), `offset`.
- **Returns**: `{ images: [...], total, citations_combined }` — same shape as `search_images`; each image also carries a `chart` block when MemeStack holds one.

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

## Paid tools

### `generate_meme` *(paid — 60 sats standard / 150 sats quality, or USDC equivalent)*

Generate a new image from a text prompt via Grok Imagine. Paid per call over the agent payment rails — **x402** (USDC on Base; works out of the box with the Cloudflare Agents SDK `withX402Client` — raise `maxPaymentValue` above the $0.10 default for quality mode) or **L402** (Lightning sats). No account or API key; the payment is the auth. The call polls generation to completion (~10–90 s) and returns a hosted, auto-tagged, CDN-served image URL with caption and tags. If it times out or fails mid-run, retry with the **same** payment proof to resume — one payment delivers at most one image, never charged twice.

- **Required**: `prompt` (string, ≤2000 chars).
- **Optional**: `mode` (`standard` | `quality`, default `standard`), `aspect_ratio` (`1:1` | `3:4` | `16:9`, default `1:1`).

### `submit_image` *(paid — 100 sats/submission, or USDC equivalent)*

Submit an image by URL into the MemeStack moderation review queue. Paid per call over the agent payment rails — **x402** (USDC on Base; raise `maxPaymentValue` above the Cloudflare Agents SDK's $0.10 default, since 100 sats alone exceeds it whenever BTC trades above $100k) or **L402** (Lightning sats). No account or API key; the payment is the auth. **No refund if moderation rejects the submission** (duplicate, nsfw/gore/spam, low quality, or corrupt/invalid bytes) — the fee itself is the anti-spam mechanism, and a rejection consumes the review attempt just like an acceptance does. Accepted submissions land in the `needs_review` queue awaiting human approval; if approved, they join the public gallery credited to the `MCP Agents` account. A submission rejected as a duplicate of an existing **approved** image includes a `duplicate_of` pointer (image ID + page URL) to the existing hosted copy. The call polls the outcome to completion (~10–90 s); if it times out, or a failure occurs before any submission was created (bad URL, fetch error, oversize, non-image bytes), retry with the **same** payment proof — a corrected `image_url` is accepted on retry. Each payment allows up to **10 delivery attempts** before the claim closes and a new payment is required. Submission offers (this tool's 402 response) are capped at **50 per day per IP** — once reached, the tool returns a capacity error instead of a payment offer (an already-issued offer always remains payable).

- **Required**: `image_url` (string — HTTPS URL or `data:image/(jpeg|png|webp);base64,...` URL, max 8MB).
- **Optional**: `caption` (≤200 chars), `tags` (array, ≤10 items, ≤40 chars each), `attribution` (≤200 chars) — all three are hints shown to the AI tagger and to human moderators; **never published verbatim**.

Free-quota note for the read tools above: search/browse tools share 200 free calls/day/IP and `reverse_image_search` has 10/day/IP; above quota they return a dual-rail payment offer (5 and 21 sats per call respectively).

---

## Fetching the live, authoritative schema

```bash
curl -X POST https://mcp.memestack.ai/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | jq
```

Every tool ships an `inputSchema` (JSON Schema) and an `annotations` block (`title`, `readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`, `tier`). MCP-aware clients render these automatically.
