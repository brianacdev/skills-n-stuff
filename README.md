# skills-n-stuff

Personal Claude Code skills, distributed as a plugin marketplace so the same set is
available in every project — work and personal.

## Install

Local (this checkout is the source of truth):

```sh
/plugin marketplace add /Users/brian/personal/projects/skills-n-stuff
/plugin install brian-skills@brian-skills
```

From GitHub, once pushed:

```sh
/plugin marketplace add <user>/skills-n-stuff
/plugin install brian-skills@brian-skills
```

Install at **user scope** to get the skills in every project.

## Layout

```sh
.claude-plugin/marketplace.json   # the marketplace: lists plugins in this repo
plugins/brian-skills/
  .claude-plugin/plugin.json      # plugin manifest (bump version on release)
  skills/<name>/SKILL.md          # one directory per skill
  commands/                       # optional: slash commands
  agents/                         # optional: subagent definitions
```

Add a second plugin (e.g. work-only skills) by creating `plugins/<name>/` and adding
an entry to `marketplace.json`.

## Editing skills

Installed plugins are **cached** under `~/.claude/plugins/cache/`, so edits here do not
take effect until you refresh:

```sh
/plugin marketplace update brian-skills
```

Bump `version` in `plugin.json` when you want the change to land as a new release.

## Skill anatomy

`SKILL.md` needs YAML frontmatter with `name` and `description`. The description is the
only thing Claude sees when deciding whether to load the skill — write it as \*what it does

- when to use it\*, including the phrases you'd actually type.

```markdown
---
name: my-skill
description: Does X. Use when the user asks to "do x", mentions Y, or ...
---

Instructions for Claude go here.
```

Keep `SKILL.md` short; put long reference material in sibling files and link to them so
they load on demand.
