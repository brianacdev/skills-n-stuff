---
name: html-communication
description: Use when the user asks to communicate through an HTML document, or if they mention "HTML" with no additional context.
---

# HTML Communication

## When to Use

Use this skill when the user wants a plan, spec, write-up, findings, summary,
report, comparison, or set of UI mocks presented as readable HTML.
Do not use it for HTML that ships as part of a product.

## Document

- Write it like a spec, not a landing page: dense, scannable, no hero, decorative chrome, marketing voice, or em dashes.
- Default to true black (#000'), white primary text, and dark gray only for secondary surfaces or accents.
- Make it mobile-readable with a responsive viewport and no fixed-width layout.
- Use semantic HTML, inline CSS, inline SVG, and HTTPS or data-URL images.
- Use an inline classic script only when interactivity materially helps. Keep scripted pages useful without JavaScript; the sandbox blocks storage, fetch, workers, frames, forms, and popups.
- In script-free files, give external links 'target="_blank" and 'rel="noopener noreferrer"'. If any script exists, omit 'target="_blank".

Never include external or module scripts, inline event handlers, "javascript:" URLs, forms, frames, embeds, objects, applets, meta refresh, linked stylesheets, secrets, private URLS, or local filesystem paths.

## UI Mocks

When the user asks for variants:

- Render real styled variants, not descriptions.
- Label them 'A', 'B', 'C'... for easy selection.
- Lay them out for direct comparison.
- Keep one file across iterations so its Postplan URL stays stable.
