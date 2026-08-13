---
name: html-communication
description: Use when the user asks to communicate through an HTML document, wants a plan rendered, shared, or published as HTML, or if they mention "HTML" with no additional context.
---

# HTML Communication

## When to Use

Use this skill when the user wants a plan, spec, write-up, findings, summary,
report, comparison, or set of UI mocks presented as readable HTML.
Do not use it for HTML that ships as part of a product.

Plans follow the Plans section; everything else follows Document. Both end at Publish.

## Document

- Write it like a spec, not a landing page: dense, scannable, no hero, decorative chrome, marketing voice, or em dashes.
- Default to true black (#000), white primary text, and dark gray only for secondary surfaces or accents.
- Make it mobile-readable with a responsive viewport and no fixed-width layout.
- Use semantic HTML, inline CSS, inline SVG, and HTTPS or data-URL images.
- Use an inline classic script only when interactivity materially helps. Keep scripted pages useful without JavaScript; the sandbox blocks storage, fetch, workers, frames, forms, and popups.
- In script-free files, give external links `target="_blank"` and `rel="noopener noreferrer"`. If any script exists, omit `target="_blank"`.

Never include external or module scripts, inline event handlers, "javascript:" URLs, forms, frames, embeds, objects, applets, meta refresh, linked stylesheets, secrets, private URLs, or local filesystem paths.

## Plans

Render with `assets/plan-template.html` (Pico CSS inlined — Postplan blocks `<link>` tags, so never swap the inline block for a CDN link). The bar is **fidelity**: the page carries every heading, step, list item, code block, and table the plan had — a prettier plan, never a shorter one.

1. **Resolve the source.** A path was given → read that file. Otherwise render the plan
   already in the conversation. Neither exists → ask which plan before going further.
2. **Name the page.** From the plan's subject, derive a 1–3 word kebab-case slug
   (`auth-refactor`, `stripe-webhooks`) and a title-case page title (`Auth Refactor`).
   If `.plan-html/<slug>/` already holds a *different* plan, extend the slug to
   distinguish it rather than clobbering.
3. **Create the directory.** Project root is the git root, else the cwd.
   `mkdir -p <root>/.plan-html/<slug>`. In a git repo, make sure `.gitignore` covers
   `.plan-html/` — append the entry if it's missing; rendered plans are throwaway
   output, not source.
4. **Render.** Copy the template to `<root>/.plan-html/<slug>/index.html`,
   replacing `{{PLACEHOLDER_PAGE_TITLE}}` with the page title and
   `{{PLACEHOLDER_PAGE_CONTENT}}` with the converted body.
5. **Verify.** Re-read the written file: no `{{PLACEHOLDER_` survives, and every
   heading, step, list item, code block, and table of the source has a counterpart.
6. **Publish** per the Publish section. Keeping the slug directory stable keeps the
   Postplan URL stable across re-renders.

### Page structure

- Open the body with `<hgroup>`: `<h1>` the plan title, `<p>` a one-line summary of what
  the plan achieves.
- One `<article>` per top-level section of the plan, its heading as `<h2>` inside.
- Long supporting detail — rationale, alternatives considered, dumps of schema or config —
  goes in `<details><summary>…</summary>` inside its article, so the steps stay scannable.
- `<footer>` inside an article for that section's outcome or acceptance criteria.

### Gotchas

- Pico styles semantic HTML directly. Write plain `<article>`, `<h2>`, `<ul>`, `<table>` —
  adding classes or a second `<style>` block fights the framework and dulls the purple theme.
- The template's `<main class="container">` is already the page wrapper. Emit only its
  children; no `<html>`, `<head>`, `<body>`, or second container.
- Markdown task items (`- [ ]`) become
  `<li><input type="checkbox" disabled> text</li>` — checked items add `checked`. Keep the
  `disabled`; these record plan state, they are not a working form.
- Escape `&`, `<`, `>` inside `<pre><code>`, and drop the fence's language tag. Code that
  ships unescaped silently eats the rest of the page.
- Inline markdown inside list items and table cells still needs converting — a stray
  `**bold**` or `` `code` `` in the output means the pass was shallow.
- Mermaid or other diagram fences stay as escaped `<pre><code>`; the template's inlined
  Pico is the only styling on the page.

## UI Mocks

When the user asks for variants:

- Render real styled variants, not descriptions.
- Label them 'A', 'B', 'C'... for easy selection.
- Lay them out for direct comparison.
- Keep one file across iterations so its Postplan URL stays stable.

## Publish

Brian has given standing permission to upload every artifact created or updated with this skill. Upload is required, including in Auto mode. Do not ask for separate permission or stop at the local file.

1. Write the HTML file locally.
2. Run `npx postplan upload <file path>`.
3. Report the local path and returned Postplan URL.

Re-upload the same absolute path to update the existing URL. Use `npx postplan upload <file path> --new` only when a new draft is wanted.

If validation fails, fix the markup and retry. If a scripted upload needs authentication, ask the user to run `postplan auth login`, then retry without removing the requested interactivity.

Never open a browser or claim the document is hosted before upload succeeds.
Do not verify in a browser unless the user asks.
