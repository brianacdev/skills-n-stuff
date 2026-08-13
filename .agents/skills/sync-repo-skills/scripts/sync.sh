#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync.sh [--dry-run] [--repo-root DIR] [--target-root DIR]

Copy repo skills into TARGET_ROOT/.agents/skills and create matching
TARGET_ROOT/.claude/skills symlinks.

Options:
  --dry-run          Check inputs and print planned work without writing
  --repo-root DIR    Repository root, defaults to the current Git repository
  --target-root DIR  Parent of .agents and .claude, defaults to $HOME
  -h, --help         Show this help
EOF
}

dry_run=false
repo_root=""
target_root="${HOME:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      shift
      ;;
    --repo-root)
      [[ $# -ge 2 ]] || { echo "Error: --repo-root requires a directory." >&2; exit 2; }
      repo_root="$2"
      shift 2
      ;;
    --target-root)
      [[ $# -ge 2 ]] || { echo "Error: --target-root requires a directory." >&2; exit 2; }
      target_root="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$target_root" ]]; then
  echo "Error: HOME is not set. Set HOME or pass --target-root." >&2
  exit 2
fi

if [[ -z "$repo_root" ]]; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Error: run inside the skills-n-stuff Git repository." >&2
    exit 2
  }
fi

case "$repo_root" in
  /*) ;;
  *) repo_root="$(cd "$repo_root" && pwd -P)" ;;
esac

case "$target_root" in
  /)
    echo "Error: --target-root cannot be /." >&2
    exit 2
    ;;
  /*) ;;
  *) target_root="$(cd "$target_root" && pwd -P)" ;;
esac

source_root="$repo_root/plugins/brian-skills/skills"
agents_root="$target_root/.agents/skills"
claude_root="$target_root/.claude/skills"

if [[ ! -d "$source_root" ]]; then
  echo "Error: skill source not found: $source_root" >&2
  exit 2
fi

skill_dirs=()
while IFS= read -r skill_dir; do
  skill_dirs+=("$skill_dir")
done < <(find "$source_root" -mindepth 1 -maxdepth 1 -type d -print | LC_ALL=C sort)

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "Error: no skill directories found in $source_root" >&2
  exit 2
fi

conflicts=0
for skill_dir in "${skill_dirs[@]}"; do
  skill_name="${skill_dir##*/}"
  agent_dir="$agents_root/$skill_name"
  claude_link="$claude_root/$skill_name"

  if [[ ! "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "Conflict: invalid skill directory name: $skill_name" >&2
    conflicts=$((conflicts + 1))
  fi

  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    echo "Conflict: missing SKILL.md: $skill_dir" >&2
    conflicts=$((conflicts + 1))
  fi

  if [[ -L "$agent_dir" || ( -e "$agent_dir" && ! -d "$agent_dir" ) ]]; then
    echo "Conflict: Agents target is not a regular directory: $agent_dir" >&2
    conflicts=$((conflicts + 1))
  fi

  if [[ -L "$claude_link" ]]; then
    current_target="$(readlink "$claude_link")"
    if [[ "$current_target" != "$agent_dir" ]]; then
      echo "Conflict: Claude alias points to $current_target: $claude_link" >&2
      conflicts=$((conflicts + 1))
    fi
  elif [[ -e "$claude_link" ]]; then
    echo "Conflict: Claude alias path already exists: $claude_link" >&2
    conflicts=$((conflicts + 1))
  fi
done

if [[ $conflicts -gt 0 ]]; then
  echo "Stopped: $conflicts conflict(s). No files changed." >&2
  exit 1
fi

if [[ "$dry_run" == true ]]; then
  for skill_dir in "${skill_dirs[@]}"; do
    skill_name="${skill_dir##*/}"
    echo "Would sync $skill_name -> $agents_root/$skill_name"
    if [[ -L "$claude_root/$skill_name" ]]; then
      echo "Would keep alias $claude_root/$skill_name"
    else
      echo "Would create alias $claude_root/$skill_name"
    fi
  done
  echo "Ready: ${#skill_dirs[@]} skill(s)."
  exit 0
fi

mkdir -p "$agents_root" "$claude_root"

for skill_dir in "${skill_dirs[@]}"; do
  skill_name="${skill_dir##*/}"
  agent_dir="$agents_root/$skill_name"
  claude_link="$claude_root/$skill_name"

  mkdir -p "$agent_dir"
  cp -R "$skill_dir/." "$agent_dir/"

  if [[ ! -L "$claude_link" ]]; then
    ln -s "$agent_dir" "$claude_link"
  fi

  echo "Synced $skill_name"
done

echo "Synced ${#skill_dirs[@]} skill(s)."
