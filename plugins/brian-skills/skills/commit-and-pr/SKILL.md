---
name: commit-and-pr
description: Brian's commit message and pull request conventions. Use whenever writing a git commit message, amending one, or drafting a PR title/body — including when asked to "commit this", "commit and push", "open a PR", "write a PR description", or when running `git commit` / `gh pr create` for any reason.
---

Apply these to every commit and PR in Brian's repos. Concision beats grammar — drop
articles and filler before you drop information.

## Commit subject

- **Imperative mood**, sentence case, no trailing period. `Add admin email sending`, not
  `Added...` / `add...` / `Add admin email sending.`
- **No conventional-commit prefixes.** Never `feat:`, `fix:`, `chore:`, `refactor:`.
- **Optional scope prefix** when the change belongs to a named feature area, using the
  feature's real name followed by a colon: `Collections: cover generate/preview/apply flow`,
  `Build mode: send wizard picks as structured context to Enhance`.
- Aim for ≤ 72 chars. Use `;` to join two tightly-related halves rather than writing two
  vague clauses: `Init repo; ticket 01 two-host skeleton`.
- Say what the change *does*, not what you did to the files. Not `Update handler.ts`.

## Commit body

Optional — omit for changes the subject fully explains.

Include one when there's non-obvious *why*, a behavior change a reader would want flagged,
or several distinct changes. Two shapes, both used:

- **Terse bullets** for a list of independent changes:
  ```
  - Reuse cached PDFs and backfill older pages on demand
  - Invalidate cached PDFs after image rotation
  ```
- **Dense prose** for one intricate change — packed clauses, semicolons, no hedging:
  ```
  Optional buildContext {theme, subjects, twists} on suggestColoringPrompts;
  server filters picks not substring-present in seed (edits win), appends
  labeled picks to user msg + BUILD CONTEXT rules to system.
  ```

Note what did *not* change when it prevents a wrong assumption (`originalPrompt storage
unchanged`). Wrap at ~72 chars.

## Trailer

End every commit Claude authored with the co-author trailer, blank line before it:

```
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

Use the actual model name of the session writing the commit.

## Pull requests

- **Title**: same rules as a commit subject.
- **Body**: short prose, not a template. Lead with the problem or motivation in one or two
  sentences, then what the change does. Call out anything deliberate that looks wrong at a
  glance — a retained workaround, a narrowly-scoped lint exception, a skipped test.
- No "Summary / Test plan / Checklist" headings unless the repo's own PR template has them.
- Skip screenshots-and-emoji ceremony. Do include a screenshot for a visual change.
- End with:
  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  ```

## Rules of engagement

- Commit or push **only when asked**. Never auto-commit after finishing an edit.
- If on the default branch (`main`) and the change is more than trivial, branch first.
- Never `git add -A` blindly — stage the files the change actually touched.
- If the diff spans unrelated concerns, propose splitting it into separate commits rather
  than writing a subject that has to say "and".
