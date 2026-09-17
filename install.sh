#!/usr/bin/env bash
# Install printer-doctor for any agent runtime that reads Agent Skills.
#
# Claude Code users can instead use the plugin:
#   /plugin marketplace add <owner>/printer-doctor
#   /plugin install printer-doctor@printer-doctor
#
# This script symlinks the skill so `git pull` updates every runtime at once.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/plugins/printer-doctor/skills/printer-doctor"
[ -d "$SRC" ] || { echo "error: skill not found at $SRC" >&2; exit 1; }

linked=0
for dir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  mkdir -p "$dir"
  target="$dir/printer-doctor"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "skip   $target (exists and is not a symlink - move it aside first)"
    continue
  fi
  ln -sfn "$SRC" "$target"
  echo "linked $target"
  linked=$((linked+1))
done

FLEET="$HOME/.printer-doctor/fleet.md"
if [ ! -f "$FLEET" ]; then
  mkdir -p "$(dirname "$FLEET")"
  cp "$SRC/references/fleet-template.md" "$FLEET"
  echo "created $FLEET from the template - describe your machines in it"
else
  echo "kept   $FLEET (your machines, left untouched)"
fi

echo
echo "Done. $linked runtime location(s) linked."
echo "~/.agents/skills is read by Codex, Copilot CLI and Gemini CLI."
