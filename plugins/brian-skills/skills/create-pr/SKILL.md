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

For a MarketDial repository, read `references/jira-tickets.md` and follow it to derive the ticket and the mandatory title format. For any other repository, skip this step and never infer a Jira ticket.

## 3. Write title and body

With an identified Jira ticket, use the title format from `references/jira-tickets.md`. Without one, create a concise title from the commits and diff. Do not invent a ticket or rely only on the branch description.

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
