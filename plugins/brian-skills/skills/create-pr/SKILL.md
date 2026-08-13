---
name: create-pr
description: Create a pull request with the GitHub CLI from the current Git branch. Use when asked to file, make, submit, or create a PR
---

# Create PR

Create one non-draft PR from the current branch. Inspect the repository and diff, generate an accurate title and body, push the branch when needed, then use `gh pr create`.

## 1. Inspect

Run read-only checks first:

- Confirm the working directory is inside a Git repository.
- Read the current branch with `git branch --show-current`; stop on a detached HEAD.
- Read `origin` with `git remote get-url origin`; stop if it is missing or is not GitHub.
- Check authentication with `gh auth status`.
- Get the repository's default branch from `gh repo view --json defaultBranchRef` and use it as the PR base unless the user named another base.
- Fetch the base branch from `origin`, then inspect `git log`, `git diff --stat`, and `git diff` for `origin/<base>...HEAD`.
- Inspect any repository PR template and contribution instructions.
- Check for an existing open PR from the current branch. If one exists, return its URL instead of creating a duplicate.

Stop if there are no commits to propose. Do not commit user changes. If the worktree is dirty, explain that uncommitted changes will not be included and stop so the user can decide what to commit.

## 2. Determine Jira context

Treat the repository as MarketDial when the normalized GitHub owner from `origin` is `marketdial`, case-insensitively. Support SSH and HTTPS remote forms.

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

Do not infer Jira tickets from non-MarketDial repositories or loosely matching branch text.

## 3. Write title and body

For an identified Jira ticket, write:

```text
[<JIRA-TICKET>] <short description>
```

This format is mandatory: use square brackets around the canonical ticket, followed by one space. Never substitute a colon, hyphen, or bare ticket.

Make the short description 5–10 words, specific, and consistent with both Jira and the diff. Exclude the bracketed ticket from the word count. Prefer a concise action/result phrase, sentence case, with no trailing period. Before creating the PR, verify the final Jira title matches `^\[(FIAT|GREEN|SMART|MDB)-[0-9]+\] .+` and recount the description words.

Without a Jira ticket, create a concise title from the commits and diff. Do not invent a ticket or rely only on the branch description.

Build the PR body from the actual changes:

- Preserve applicable repository template sections and instructions.
- Summarize the purpose and material changes in 1–3 concise bullets.
- Report tests actually run and their results. If none ran, say `Not run` and why; never invent test evidence.
- Mention material risks, migrations, rollout steps, or manual verification when relevant.

## 4. Push and create

Push the current branch to `origin` with upstream tracking if it is not already available remotely. Never force-push.

Write the body to a temporary file and pass it with `--body-file` to avoid shell-escaping errors. Create the PR with explicit head, base, title, and body:

```bash
gh pr create --head <current-branch> --base <base-branch> --title <title> --body-file <body-file>
```

Do not use `--draft` unless the user asks. Remove the temporary file after the command. Return the PR URL, title, and base branch.

If push or creation fails, report the exact failing command and concise cause. Do not retry with destructive flags.
