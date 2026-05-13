# Prompts

MCP prompts are pre-baked workflows — short instructions the client expands into a tool-using session. Use them when you want a one-line user message to drive a multi-step interaction without writing the orchestration yourself.

Fetch the live, authoritative list:

```bash
curl -X POST https://mcp.memestack.ai/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"prompts/list"}' | jq
```

Invoke one:

```bash
curl -X POST https://mcp.memestack.ai/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"prompts/get","params":{"name":"search_memes","arguments":{"topic":"bitcoin inflation"}}}'
```

---

## `search_memes`

Search MemeStack for memes, infographics, or visual content on any topic.

- **Required**: `topic` — what to search for (e.g. `"Bitcoin inflation"`, `"Pepe frog"`).

## `trending_images`

See what's trending on MemeStack right now. Wraps `browse_images` with `sort: "trending"`.

- **No arguments.**

## `top_zapped`

Find the most zapped (tipped with Lightning sats) images over a time period.

- **Optional**: `period` — `day` | `week` | `month` | `all` (default `week`).

## `cite_this_meme`

Generate canonical attribution markdown for a single MemeStack image. Wraps `cite_image` for the most common single-image case.

- **Required**: `image_id` (UUID).

## `find_a_meme_for_vibe`

Find memes that capture a vibe / idea / concept, ready to embed with attribution.

- **Required**: `vibe` — the vibe, idea, or concept.
- **Optional**: `count` (default 3).

## `research_meme_evolution`

Research how a meme has evolved on MemeStack via mutation groups. Accepts either a UUID (calls `get_mutation_group`) or a template slug (calls `browse_images` filtered to that template).

- **Required**: `meme_or_template` — image UUID or meme template slug.
