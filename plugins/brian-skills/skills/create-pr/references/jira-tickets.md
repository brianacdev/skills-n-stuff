# MarketDial Jira tickets

Only infer a Jira ticket for a MarketDial repository. Match the entire branch name, case-insensitively, against:

```regex
^ftr-(?:(fiat|green|smart|mdb)|([fgsm]))([0-9]+)(?:-.+)?$
```

Map the project token to its canonical Jira project:

| Token | Project |
|---|---|
| `fiat`, `f` | `FIAT` |
| `green`, `g` | `GREEN` |
| `smart`, `s` | `SMART` |
| `mdb`, `m` | `MDB` |

Combine the canonical project and captured number with a hyphen. Examples: `ftr-fiat123-cool-feature` becomes `FIAT-123`; `ftr-g789-foo2` becomes `GREEN-789`; `ftr-mdb42` becomes `MDB-42`.

If a ticket is identified, query that exact issue through the Jira MCP server. Use its summary and relevant issue context, but reconcile them with the actual branch diff. If Jira is unavailable or the issue cannot be read, say that the fallback was used and derive wording from the diff.

Do not infer Jira tickets from loosely matching branch text.

## Title format

For an identified Jira ticket, write:

```text
[<JIRA-TICKET>] <short description>
```

This format is mandatory: use square brackets around the canonical ticket, followed by one space. Never substitute a colon, hyphen, or bare ticket.

Make the short description 5–10 words, specific, and consistent with both Jira and the diff. Exclude the bracketed ticket from the word count. Prefer a concise action/result phrase, sentence case, with no trailing period. Before creating the PR, verify the final title matches `^\[(FIAT|GREEN|SMART|MDB)-[0-9]+\] .+` and recount the description words.
