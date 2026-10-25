# Prompts

MCP prompts are pre-baked workflows — short instructions the client expands into a tool-using session. Use them when you want a one-line user message to drive a multi-step interaction without writing the orchestration yourself.

The server has six prompts. `prompts/list` shows a prompt only while every tool it uses is listed in `tools/list` — a client can call only the tools it was shown — so on `/mcp` it shows three by default: `search_memes`, `cite_this_meme` and `find_a_meme_for_vibe`. The other three (`trending_images`, `top_zapped`, `research_meme_evolution`) are marked *not listed by default* below; each still answers `prompts/get` by name. On `/mcp/directory`, `prompts/list` shows every prompt but `top_zapped`.

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

*Not listed by default* (`browse_images` is not a core tool); `prompts/get` by name.

See what's trending on MemeStack right now. Wraps `browse_images` with `sort: "trending"`.

- **No arguments.**

## `top_zapped`

*Not listed by default* (`get_leaderboard` is not a core tool; not listed on `/mcp/directory` either); `prompts/get` by name.

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

*Not listed by default* (`get_meme_variants` and `browse_images` are not core tools); `prompts/get` by name.

Research how a meme has evolved on MemeStack through its tracked variants. Accepts either a UUID (calls `get_meme_variants`) or a template slug (calls `browse_images` filtered to that template).

- **Required**: `meme_or_template` — image UUID or meme template slug.
