---
name: sync-repo-skills
description: Copy this project's shared skills into $HOME/.agents/skills and create matching aliases in $HOME/.claude/skills.
disable-model-invocation: true
compatibility: Requires Bash, git, and write access to the invoking user's home directory.
---

# Sync repo skills

Use this from the `skills-n-stuff` project when the user invokes `$sync-repo-skills`.

## Workflow

1. Preview the operation from anywhere inside the repository:

   ```bash
   bash .agents/skills/sync-repo-skills/scripts/sync.sh --dry-run
   ```

2. Stop and report every conflict if the preview fails. Preserve conflicting files, directories, and links.

3. If the preview passes, run the sync:

   ```bash
   bash .agents/skills/sync-repo-skills/scripts/sync.sh
   ```

   Request filesystem approval if the tool sandbox blocks writes to the user's home directory.

4. Report the skill count. Completion requires the script to print `Synced N skill(s).` with no conflict.

The script resolves targets from the invoking user's `$HOME`. It merges each directory under `plugins/brian-skills/skills` into `$HOME/.agents/skills/<name>`, then creates `$HOME/.claude/skills/<name>` as an absolute symlink to that installed copy.
