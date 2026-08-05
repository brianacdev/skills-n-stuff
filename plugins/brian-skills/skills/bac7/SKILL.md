---
name: bac7
description: Share files from disk as public links via bac7 — upload, update, list, delete, or mint a fresh link. Use when the user wants to share, publish, or host a file (HTML, image, Markdown), asks for a public/shareable URL for something local, or mentions bac7.
---

# bac7

Single-user file store on Cloudflare R2. Everything is `curl` against two hosts with one bearer token.

- **API** `https://bac7.dev` — authed JSON. Every operation below. Never serves bytes.
- **Share** `https://bac7-share.brianarth7.workers.dev` — anonymous serving. Minted links point here; this is what you hand a human.

## Token

`$BAC7_AUTH_TOKEN` from the environment — reference it inline in each command, so nothing carries between calls. Wrong or empty → `401 {"error":"unauthorized"}`; if it's unset, ask the user to export it (the value lives in the gitignored `bac7/.env` and in `wrangler secret`).

## Names

A **Name** is the storage key, taken verbatim — invalid ones are rejected (`400 {"error":"invalid name"}`), never cleaned up for you. Per `/`-separated segment: `A-Za-z0-9._-` only, no leading dot, no `.`/`..`, ≤128 chars. So map the local filename into that charset yourself before uploading (`My Report.html` → `my-report.html`).

A **Folder** is just a Name prefix ending in `/` — `demo/index.html` creates no folder object.

## Operations

```sh
# upload (raw body; request Content-Type ignored, served type comes from the extension)
curl -X POST "https://bac7.dev/files/hello.html" -H "Authorization: Bearer $BAC7_AUTH_TOKEN" --data-binary @hello.html

# fresh link for something already stored — file Name, or a prefix ending in /
curl -X POST "https://bac7.dev/links?file=demo/" -H "Authorization: Bearer $BAC7_AUTH_TOKEN"

# list everything (complete, unpaginated)
curl "https://bac7.dev/files" -H "Authorization: Bearer $BAC7_AUTH_TOKEN"

# delete — 204, or 404 if absent. Also kills every outstanding link to that file.
curl -X DELETE "https://bac7.dev/files/hello.html" -H "Authorization: Bearer $BAC7_AUTH_TOKEN" -i
```

Upload and fresh-link both return `{url, expires_at, file, size}`.

`?expires=` on either: seconds (`604800`) or shorthand `4h`, `90d`, `3w`. Default 30d, clamped at 9 months. A fraction, uppercase unit, or `1mo` → `400`.

Ceiling is 100 MB; the edge rejects larger with `413` before the Worker runs.

## Choosing the operation

- **Update a live share** — re-upload the same Name. It overwrites, and unexpired links serve the new bytes. Reminting replaces the URL the user already has, so re-upload instead.
- **More than one file, or HTML with assets** — upload each under a shared Folder prefix, then one fresh-link on the prefix. The token rides in the path, so relative refs inside the HTML (`<img src="cat.png">`) resolve under the same token. An upload's own link covers only that one file.
- **Re-share an existing file** — fresh-link, not re-upload.

## Reporting

Verify before you hand it over: `curl -sI "<url>"` on the returned link returns `200`. Then give the user the share URL and its expiry.

A `410` page means the token expired or was tampered with; a `404` page means the token is good but nothing is stored at that Name (deleted, or you linked a Folder root — link a file inside it, or `index.html` under that prefix).

Deeper detail — token format, serving headers, deploy runbook: `/Users/brian/personal/projects/bac7/README.md` and `.scratch/file-share/spec.md`.
