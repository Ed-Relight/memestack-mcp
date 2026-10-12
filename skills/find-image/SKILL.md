---
name: find-image
description: Find an existing meme, chart, infographic or screenshot on MemeStack by what it means, by the words printed inside it, or by a similar image, and cite it. Use when the user wants an image that already exists (to illustrate a point, back a claim with a chart, or trace where a picture came from), not a new one.
---

# Find an image on MemeStack

MemeStack is a search engine for memes, infographics, charts and screenshots. Every image is
AI-captioned and its printed text is indexed, so it can be found by meaning, by a quote, or by
looking like another picture. The tools come from the `memestack` MCP server this plugin installs.

## Pick the tool for the job

| The user wants… | Call |
|---|---|
| an image about an idea ("the meme where everyone panics about inflation") | `search_images` |
| a meme to make a point in a post or article | `find_meme_for_text` |
| an image with specific words written on it (a quote, a sign, a screenshot) | `search_text_in_image` |
| a chart with its source, unit, regions and the period it shows | `search_charts` |
| where an image they already have appears, or near-copies of it | `reverse_image_search` (an https URL or a `data:` URL) |
| more like a result they liked | `find_related` (same meaning) or `find_similar` (same look) |
| every version of a meme | `get_meme_variants` |
| the full record of one image (caption, OCR text, tags, chart data) | `get_image` |
| images under a topic | `browse_by_tag` (check the slug with `tag_autocomplete` first) |

Write queries the way a person describes the picture: what it shows or says, not file names. If
the first search comes back with only closest matches, rephrase once (shorter, or quote the text on
the image with `search_text_in_image`) before telling the user nothing fits.

## Show results honestly

- Lead with the strongest matches; say plainly when a result is only a close match.
- For a chart, report the period the chart actually shows and its source as the tool gives them.
  Never widen the period to the dataset's full history.
- Results exclude images classified controversial. Set `include_controversial` only when the user
  explicitly asks for unfiltered results.

## Always keep the citation

Every result carries a citation block (markdown, HTML and plain text). When you use, embed or
recommend an image, include its citation as given, or call `cite_image` for several at once.
Charts from Our World in Data, Eurostat, the EEA and USDA ERS carry licence terms that require the
credit line.

## Paid tools

The server also offers `generate_meme` (makes a new image) and `submit_image` (adds an image to
MemeStack's review queue). Both cost money per call, paid over Lightning or in USDC. Use them only
when the user asks for a brand-new image or asks to submit one, and tell them the price before you
call.
