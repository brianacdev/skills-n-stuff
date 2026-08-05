---
name: plan-to-html
description: Render a markdown plan as a styled HTML page under `.plan-html/`. Use when the user wants a plan turned into HTML, rendered as a web page, or previewed in a browser — either a plan just written in the conversation or a path to a markdown plan file.
---

Turn a plan into a self-contained HTML page styled with Pico CSS. The bar is **fidelity**:
the page carries every heading, step, list item, code block, and table the plan had — a
prettier plan, never a shorter one.

## Steps

1. **Resolve the source.** A path was given → read that file. Otherwise render the plan
   already in the conversation. Neither exists → ask which plan before going further.
2. **Name the page.** From the plan's subject, derive a 1–3 word kebab-case slug
   (`auth-refactor`, `stripe-webhooks`, `db-migration`) and a title-case page title
   (`Auth Refactor`). If `.plan-html/<slug>/` already holds a *different* plan, extend the
   slug to distinguish it rather than clobbering.
3. **Create the directory.** Project root is the git root, else the cwd.
   `mkdir -p <root>/.plan-html/<slug>`.
4. **Render.** Copy `assets/plan-template.html` to `<root>/.plan-html/<slug>/index.html`,
   replacing `{{PLACEHOLDER_PAGE_TITLE}}` with the page title and
   `{{PLACEHOLDER_PAGE_CONTENT}}` with the converted body.
5. **Verify, then report.** Re-read the written file: no `{{PLACEHOLDER_` survives, and
   every heading, step, list item, code block, and table of the source has a counterpart.
   Report the absolute path.

## Page structure

- Open the body with `<hgroup>`: `<h1>` the plan title, `<p>` a one-line summary of what
  the plan achieves.
- One `<article>` per top-level section of the plan, its heading as `<h2>` inside.
- Long supporting detail — rationale, alternatives considered, dumps of schema or config —
  goes in `<details><summary>…</summary>` inside its article, so the steps stay scannable.
- `<footer>` inside an article for that section's outcome or acceptance criteria.

## Gotchas

- Pico styles semantic HTML directly. Write plain `<article>`, `<h2>`, `<ul>`, `<table>` —
  adding classes or a `<style>` block fights the framework and dulls the purple theme.
- The template's `<main class="container">` is already the page wrapper. Emit only its
  children; no `<html>`, `<head>`, `<body>`, or second container.
- Markdown task items (`- [ ]`) become
  `<li><input type="checkbox" disabled> text</li>` — checked items add `checked`. Keep the
  `disabled`; these record plan state, they are not a working form.
- Escape `&`, `<`, `>` inside `<pre><code>`, and drop the fence's language tag. Code that
  ships unescaped silently eats the rest of the page.
- Inline markdown inside list items and table cells still needs converting — a stray
  `**bold**` or `` `code` `` in the output means the pass was shallow.
- Mermaid or other diagram fences stay as escaped `<pre><code>`; the page loads Pico only.
