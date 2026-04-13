#!/bin/bash
# ============================================================
# sync-claude-md.sh — Keep CLAUDE.md wiki section in sync
# ============================================================
#
# Scans .wiki/ directory structure and regenerates the wiki
# reference section in CLAUDE.md with actual file links.
#
# Called by:
#   - bootstrap-wiki.ts (after scaffolding)
#   - /wiki-update (after any update)
#   - install.sh (after installation)
#
# Usage:
#   bash scripts/wiki/sync-claude-md.sh [--project-root /path]
# ============================================================

set -euo pipefail

# ---------- Locate project root ----------
PROJECT_ROOT=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --project-root) PROJECT_ROOT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [ -z "$PROJECT_ROOT" ]; then
  # Auto-detect: walk up from script location
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

WIKI_DIR="$PROJECT_ROOT/.wiki"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

# ---------- Validate ----------
if [ ! -d "$WIKI_DIR" ]; then
  echo "⚠ No .wiki/ directory found at $WIKI_DIR — skipping CLAUDE.md sync"
  exit 0
fi

# ---------- Build wiki section from actual files ----------

generate_wiki_section() {
  local wiki="$1"

  # --- Collect L1 files ---
  local l1_files=()
  if [ -d "$wiki/l1-context" ]; then
    while IFS= read -r f; do
      l1_files+=("$f")
    done < <(find "$wiki/l1-context" -name '*.md' -type f | sort)
  fi

  # --- Collect L2 categories and their files ---
  local l2_categories=()
  local l2_files_by_cat=()
  if [ -d "$wiki/l2-reference" ]; then
    while IFS= read -r catdir; do
      local catname
      catname="$(basename "$catdir")"
      local files_in_cat=()
      while IFS= read -r f; do
        local base
        base="$(basename "$f" .md)"
        # Skip _index, _template, _about
        [[ "$base" == _* ]] && continue
        files_in_cat+=("$base")
      done < <(find "$catdir" -name '*.md' -type f | sort)
      if [ ${#files_in_cat[@]} -gt 0 ]; then
        l2_categories+=("$catname")
        l2_files_by_cat+=("$(IFS=,; echo "${files_in_cat[*]}")")
      fi
    done < <(find "$wiki/l2-reference" -mindepth 1 -maxdepth 1 -type d | sort)
  fi

  # --- Generate markdown ---
  echo '## 📚 Project Wiki (Self-Updating Knowledge Base)'
  echo ''
  echo '**Location:** `.wiki/` — Karpathy-method compiled wiki. Use `/wiki-query <topic>` to search, `/wiki-update` to refresh.'
  echo ''

  # L1
  if [ ${#l1_files[@]} -gt 0 ]; then
    local l1_names=()
    for f in "${l1_files[@]}"; do
      l1_names+=("$(basename "$f" .md)")
    done
    local l1_list
    l1_list="$(printf '%s, ' "${l1_names[@]}")"
    l1_list="${l1_list%, }"  # trim trailing comma+space
    echo "- **L1 context** (\`.wiki/l1-context/\`) — Always-loaded: $l1_list"
  fi

  # L2
  if [ ${#l2_categories[@]} -gt 0 ]; then
    echo "- **L2 reference** (\`.wiki/l2-reference/\`) — On-demand deep dives:"
    for i in "${!l2_categories[@]}"; do
      local cat="${l2_categories[$i]}"
      local files="${l2_files_by_cat[$i]}"
      local formatted_files
      formatted_files="$(echo "$files" | sed 's/,/, /g')"
      echo "  - \`$cat/\` — $formatted_files"
    done
  fi
}

# ---------- Markers for the section ----------
MARKER_START="<!-- wiki-section-start -->"
MARKER_END="<!-- wiki-section-end -->"

new_section="$MARKER_START
$(generate_wiki_section "$WIKI_DIR")
$MARKER_END"

# ---------- Update CLAUDE.md ----------

if [ ! -f "$CLAUDE_MD" ]; then
  # No CLAUDE.md — create minimal one with wiki section
  cat > "$CLAUDE_MD" << EOF
# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

$new_section
EOF
  echo "✓ Created CLAUDE.md with wiki section"
  exit 0
fi

# Check if markers already exist
if grep -q "$MARKER_START" "$CLAUDE_MD" 2>/dev/null; then
  # Replace existing section between markers
  python3 -c "
import sys

marker_start = '$MARKER_START'
marker_end = '$MARKER_END'

with open('$CLAUDE_MD', 'r') as f:
    content = f.read()

new_section = '''$new_section'''

start_idx = content.find(marker_start)
end_idx = content.find(marker_end)

if start_idx >= 0 and end_idx >= 0:
    end_idx += len(marker_end)
    content = content[:start_idx] + new_section + content[end_idx:]
    with open('$CLAUDE_MD', 'w') as f:
        f.write(content)
"
  echo "✓ Updated wiki section in CLAUDE.md (replaced between markers)"
else
  # No markers yet — find existing wiki section or insert after first heading
  python3 -c "
import re

with open('$CLAUDE_MD', 'r') as f:
    content = f.read()

new_section = '''$new_section'''

# Try to find existing wiki section (## ... Wiki ...) and replace it
wiki_pattern = r'## 📚 Project Wiki.*?(?=\n## |\Z)'
match = re.search(wiki_pattern, content, re.DOTALL)

if match:
    # Replace old wiki section with new marked one
    content = content[:match.start()] + new_section + '\n\n' + content[match.end():].lstrip()
else:
    # Insert after first '# ' heading line
    lines = content.split('\n')
    inserted = False
    for i, line in enumerate(lines):
        if line.startswith('# ') and not line.startswith('## '):
            # Find end of this heading block (next empty line or next heading)
            insert_at = i + 1
            # Skip any immediate blank lines after the heading
            while insert_at < len(lines) and lines[insert_at].strip() == '':
                insert_at += 1
            # Skip non-heading description lines right after the heading
            if insert_at < len(lines) and not lines[insert_at].startswith('#'):
                # There's a description line — insert after it + blank line
                while insert_at < len(lines) and lines[insert_at].strip() != '' and not lines[insert_at].startswith('#'):
                    insert_at += 1
            lines.insert(insert_at, '\n' + new_section + '\n')
            inserted = True
            break
    if not inserted:
        lines.insert(0, new_section + '\n')
    content = '\n'.join(lines)

with open('$CLAUDE_MD', 'w') as f:
    f.write(content)
"
  echo "✓ Added wiki section with markers to CLAUDE.md"
fi
