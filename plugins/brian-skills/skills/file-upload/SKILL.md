---
name: file-upload
description: Upload one local file to BAC7 and return its public URL. Use for upload, share, host, public-link, or BAC7 requests. For publishing rendered HTML plans or docs, use html-communication instead.
---

# BAC7

Upload one file as raw bytes to the authenticated API. Return the URL served by the public host.

## Authentication

Read `AUTH_TOKEN` from the environment. Every API request uses `X-BAC7-Auth-Token`; public-file requests need no auth. If the variable is unset, ask the user to export it. Keep the token out of output. Missing or wrong tokens return `401 {"error":"unauthorized"}`.

```sh
test -n "$AUTH_TOKEN"
```

## Upload

1. Choose an Upload Path of one to five segments. Percent-encode it for the request URL. BAC7 lowercases and slugifies every segment; the filename's final extension is preserved.
2. POST the file as raw bytes. Do not use multipart or base64.
3. Treat the plain-text response body as the Share Link.
4. Verify the Share Link with an unauthenticated GET, then return it to the user.

```sh
curl --fail-with-body -sS -X POST \
  'https://admin.bac7.dev/path-to/file.ext' \
  -H "X-BAC7-Auth-Token: $AUTH_TOKEN" \
  --data-binary @'/absolute/path/to/file.ext'
```

Success returns `201 Created` and a URL shaped like `https://bac7.dev/<eight-character-id>/path-to/file.ext`. Links stay live for at least 90 days; the service cleans up older files automatically. Each upload creates a new File and URL, including repeated Upload Paths.

Verify without printing file contents:

```sh
curl --fail -sS -o /dev/null 'https://bac7.dev/<id>/path-to/file.ext'
```

## Upload Path rules

- Use at most four slashes. Each segment must become nonempty after slugging.
- Expect accents to be removed and non-alphanumeric runs to become `-`.
- Preserve the filename extension so BAC7 serves the correct media type; request `Content-Type` is ignored.
- Expect `400 {"error":"invalid path"}` for empty, unsluggable, overlong (>128 chars per segment), or deeper paths.
- Retry the same upload after `409 {"error":"id collision; retry"}`; BAC7 never overwrites the existing File.
- The `/files/<filename>` route is reserved and returns `404`.

BAC7 has no list, update, per-file delete, fresh-link, folder-sharing, or expiration endpoint. Uploaded HTML runs under a restrictive CSP sandbox in an opaque origin. The upload API has no CORS.
