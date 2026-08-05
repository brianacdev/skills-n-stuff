---
name: share-plan
description: Render a plan as HTML and publish it as a shareable public link. Use when the user asks to "share html plan", "publish html plan", or otherwise wants a public URL for a plan — from the conversation or a markdown plan file path. Not for rendering alone (that's plan-to-html). Composes plan-to-html (render) and bac7 (host).
---

# share-plan

Turn a plan into a styled HTML page and hand back a public URL. This skill is glue only —
the rendering and hosting details live in the child skills; invoke each via the Skill tool
and follow its instructions. Don't reimplement them here.

## Steps

1. **Render.** Invoke the `plan-to-html` skill on the plan (conversation context or the
   given file path). It produces `<root>/.plan-html/<slug>/index.html` and verifies
   fidelity. Note the slug.
2. **Publish.** Invoke the `bac7` skill to upload that file as `plans/<slug>/index.html`
   — the folder prefix is deliberate, so any future assets (images, extra pages) ride the
   same token via relative refs.
   - **First share** → upload, then take the returned link.
   - **Re-share after plan edits** → re-upload the same Name; the user's existing link
     serves the new bytes. Do **not** mint a fresh link — that would orphan the URL they
     already handed out. Only fresh-link when the old link has expired or the user asks
     for a new URL.
   - Expiry: use bac7's default (30d). Pass `?expires=` only if the user asks.
3. **Verify and report.** Per bac7's reporting rules, `curl -sI` the share URL → `200`.
   Then give the user: the share URL, its expiry, and the local path
   `.plan-html/<slug>/index.html`.

## Gotchas

- The slug from plan-to-html is already kebab-case, which satisfies bac7's Name charset —
  use it verbatim, don't re-slug.
- If plan-to-html extended the slug to avoid clobbering a different local plan, the upload
  Name extends the same way; local dir and remote prefix must stay in lockstep.
- `$BAC7_AUTH_TOKEN` unset → stop after rendering, report the local path, and ask the user
  to export the token; don't retry blind.
