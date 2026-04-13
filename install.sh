#!/bin/bash
# ============================================================
# Karpathy Wiki — One-Command Installer
# ============================================================
#
# Usage (from your project root):
#
#   curl -fsSL https://raw.githubusercontent.com/alexkash/my-karpathy-wiki/main/install.sh | bash
#
# Or if already cloned:
#
#   bash /path/to/my-karpathy-wiki/install.sh
#
# What it does:
#   1. Copies .wiki/ template into your project
#   2. Copies Claude Code commands (/wiki-update, /wiki-query)
#   3. Installs 3 hooks (session-start, session-end, pre-compact)
#   4. Installs utility scripts (bootstrap, compile, lint, query)
#   5. Adds npm scripts if package.json exists
#
# Requirements: bash, python3, git
# ============================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}📚 Karpathy Wiki Installer${NC}"
echo -e "   Self-updating knowledge base for Claude Code"
echo "   ─────────────────────────────────────────────"
echo ""

# ---------- Detect project root ----------

PROJECT_ROOT="$(pwd)"
if [ ! -d "$PROJECT_ROOT/.git" ]; then
  echo -e "${YELLOW}⚠ Not a git repository. Using current directory: $PROJECT_ROOT${NC}"
fi

# ---------- Detect source (cloned repo or curl) ----------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR=""

# Check if running from cloned repo
if [ -f "$SCRIPT_DIR/WIKI.md" ] && [ -d "$SCRIPT_DIR/hooks" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
  echo -e "${GREEN}✓ Installing from local clone: $SOURCE_DIR${NC}"
else
  # Download from GitHub
  echo -e "${BLUE}↓ Downloading from GitHub...${NC}"
  TEMP_DIR=$(mktemp -d)
  trap "rm -rf $TEMP_DIR" EXIT
  git clone --depth 1 https://github.com/alexkash/my-karpathy-wiki.git "$TEMP_DIR/wiki" 2>/dev/null || {
    echo -e "${RED}✗ Failed to clone. Check internet connection.${NC}"
    exit 1
  }
  SOURCE_DIR="$TEMP_DIR/wiki"
  echo -e "${GREEN}✓ Downloaded${NC}"
fi

# ---------- Check if wiki already exists ----------

if [ -d "$PROJECT_ROOT/.wiki/l1-context" ]; then
  echo -e "${YELLOW}⚠ .wiki/ already exists. Updating hooks and scripts only (wiki content preserved).${NC}"
  WIKI_EXISTS=true
else
  WIKI_EXISTS=false
fi

# ---------- 1. Copy .wiki/ template ----------

echo ""
echo -e "${BOLD}Step 1: Wiki structure${NC}"

if [ "$WIKI_EXISTS" = false ]; then
  mkdir -p "$PROJECT_ROOT/.wiki"/{l1-context,l2-reference/{architecture,features,api,patterns,infrastructure,decisions},sources,log/daily,log/compiled}

  # Copy template files
  cp "$SOURCE_DIR/WIKI.md" "$PROJECT_ROOT/.wiki/WIKI.md"
  echo -e "  ${GREEN}✓ .wiki/WIKI.md (schema)${NC}"

  for file in overview.md architecture.md conventions.md commands.md active-work.md known-issues.md glossary.md; do
    if [ -f "$SOURCE_DIR/l1-context/$file" ]; then
      cp "$SOURCE_DIR/l1-context/$file" "$PROJECT_ROOT/.wiki/l1-context/$file"
    fi
  done
  echo -e "  ${GREEN}✓ .wiki/l1-context/ (7 scaffold files)${NC}"

  # L2 reference
  for dir in architecture features api patterns decisions; do
    for file in "$SOURCE_DIR/l2-reference/$dir"/*.md; do
      [ -f "$file" ] || continue
      cp "$file" "$PROJECT_ROOT/.wiki/l2-reference/$dir/$(basename "$file")"
    done
  done
  echo -e "  ${GREEN}✓ .wiki/l2-reference/ (index files + ADR template)${NC}"

  # Log & sources
  cp "$SOURCE_DIR/log/changelog.md" "$PROJECT_ROOT/.wiki/log/changelog.md" 2>/dev/null || true
  cp "$SOURCE_DIR/sources/_about.md" "$PROJECT_ROOT/.wiki/sources/_about.md" 2>/dev/null || true

  # .gitignore for wiki
  echo -e "*.tmp\n*.bak" > "$PROJECT_ROOT/.wiki/.gitignore"
  echo -e "  ${GREEN}✓ .wiki/log/ + .wiki/sources/ + .gitignore${NC}"
else
  # Only update WIKI.md schema
  cp "$SOURCE_DIR/WIKI.md" "$PROJECT_ROOT/.wiki/WIKI.md"
  echo -e "  ${GREEN}✓ .wiki/WIKI.md updated (content preserved)${NC}"
fi

# ---------- 2. Claude Code commands ----------

echo ""
echo -e "${BOLD}Step 2: Claude Code commands${NC}"

mkdir -p "$PROJECT_ROOT/.claude/commands"
cp "$SOURCE_DIR/.claude-commands/wiki-update.md" "$PROJECT_ROOT/.claude/commands/wiki-update.md"
cp "$SOURCE_DIR/.claude-commands/wiki-query.md" "$PROJECT_ROOT/.claude/commands/wiki-query.md"
echo -e "  ${GREEN}✓ /wiki-update command${NC}"
echo -e "  ${GREEN}✓ /wiki-query command${NC}"

# ---------- 3. Hooks ----------

echo ""
echo -e "${BOLD}Step 3: Hooks (auto-memory)${NC}"

mkdir -p "$PROJECT_ROOT/scripts/wiki/hooks"
cp "$SOURCE_DIR/hooks/session-start.sh" "$PROJECT_ROOT/scripts/wiki/hooks/session-start.sh"
cp "$SOURCE_DIR/hooks/session-end.sh" "$PROJECT_ROOT/scripts/wiki/hooks/session-end.sh"
cp "$SOURCE_DIR/hooks/pre-compact.sh" "$PROJECT_ROOT/scripts/wiki/hooks/pre-compact.sh"
chmod +x "$PROJECT_ROOT/scripts/wiki/hooks/"*.sh
echo -e "  ${GREEN}✓ session-start.sh (auto-load context)${NC}"
echo -e "  ${GREEN}✓ session-end.sh (save session knowledge)${NC}"
echo -e "  ${GREEN}✓ pre-compact.sh (protect from context compression)${NC}"

# Wire hooks into .claude/settings.json
# Format: each event is an ARRAY of { matcher, hooks[] } objects
# command is a single string (not command + args)
SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.json"

WIKI_HOOKS='{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/wiki/hooks/session-start.sh"
          }
        ]
      },
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/wiki/hooks/pre-compact.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "clear",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/wiki/hooks/session-end.sh"
          }
        ]
      },
      {
        "matcher": "prompt_input_exit",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/wiki/hooks/session-end.sh"
          }
        ]
      }
    ]
  }
}'

if [ -f "$SETTINGS_FILE" ]; then
  # Merge hooks into existing settings
  python3 -c "
import json, sys

with open('$SETTINGS_FILE') as f:
    settings = json.load(f)

wiki_hooks = json.loads('''$WIKI_HOOKS''')
settings['hooks'] = wiki_hooks['hooks']

# Preserve any other existing settings
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
" 2>/dev/null && echo -e "  ${GREEN}✓ Hooks merged into .claude/settings.json${NC}" || {
    echo -e "  ${YELLOW}⚠ Could not merge. Creating new settings.json${NC}"
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    echo "$WIKI_HOOKS" > "$SETTINGS_FILE"
    echo -e "  ${GREEN}✓ Created .claude/settings.json with hooks${NC}"
  }
else
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  echo "$WIKI_HOOKS" > "$SETTINGS_FILE"
  echo -e "  ${GREEN}✓ Created .claude/settings.json${NC}"
fi

# ---------- 4. Utility scripts ----------

echo ""
echo -e "${BOLD}Step 4: Utility scripts${NC}"

for script in compile.sh lint.sh query.sh bootstrap.sh; do
  if [ -f "$SOURCE_DIR/scripts/$script" ]; then
    cp "$SOURCE_DIR/scripts/$script" "$PROJECT_ROOT/scripts/wiki/$script"
    chmod +x "$PROJECT_ROOT/scripts/wiki/$script"
    echo -e "  ${GREEN}✓ scripts/wiki/$script${NC}"
  fi
done

# ---------- 5. npm scripts (if package.json exists) ----------

echo ""
echo -e "${BOLD}Step 5: npm scripts${NC}"

if [ -f "$PROJECT_ROOT/package.json" ]; then
  # Add wiki scripts using python
  python3 -c "
import json

with open('$PROJECT_ROOT/package.json') as f:
    pkg = json.load(f)

scripts = pkg.get('scripts', {})
added = []

wiki_scripts = {
    'wiki:bootstrap': 'bash scripts/wiki/bootstrap.sh',
    'wiki:lint': 'bash scripts/wiki/lint.sh',
    'wiki:query': 'bash scripts/wiki/query.sh',
    'wiki:compile': 'bash scripts/wiki/compile.sh',
    'wiki:compile:all': 'bash scripts/wiki/compile.sh --all'
}

for name, cmd in wiki_scripts.items():
    if name not in scripts:
        scripts[name] = cmd
        added.append(name)

pkg['scripts'] = scripts

with open('$PROJECT_ROOT/package.json', 'w') as f:
    json.dump(pkg, f, indent=2)
    f.write('\n')

for name in added:
    print(f'  Added: {name}')
" 2>/dev/null && echo -e "  ${GREEN}✓ npm scripts added to package.json${NC}" || {
    echo -e "  ${YELLOW}⚠ Could not update package.json. Add manually:${NC}"
    echo '    "wiki:bootstrap": "bash scripts/wiki/bootstrap.sh"'
    echo '    "wiki:lint": "bash scripts/wiki/lint.sh"'
    echo '    "wiki:query": "bash scripts/wiki/query.sh"'
    echo '    "wiki:compile": "bash scripts/wiki/compile.sh"'
  }
else
  echo -e "  ${YELLOW}· No package.json found. Skipping npm scripts.${NC}"
  echo "    Run scripts directly: bash scripts/wiki/lint.sh"
fi

# ---------- 6. Update CLAUDE.md ----------

echo ""
echo -e "${BOLD}Step 6: CLAUDE.md reference${NC}"

CLAUDEMD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDEMD" ]; then
  if grep -q "wiki" "$CLAUDEMD" 2>/dev/null; then
    echo -e "  ${GREEN}✓ CLAUDE.md already references wiki${NC}"
  else
    # Prepend wiki reference after the first heading
    python3 -c "
with open('$CLAUDEMD') as f:
    content = f.read()

wiki_ref = '''
## 📚 Project Wiki (Self-Updating Knowledge Base)

**Location:** \`.wiki/\` — Karpathy-method compiled wiki. Use \`/wiki-query <topic>\` to search, \`/wiki-update\` to refresh.
- **L1 context** (\`.wiki/l1-context/\`) — Always-loaded: overview, architecture, conventions, commands, active work, issues, glossary
- **L2 reference** (\`.wiki/l2-reference/\`) — On-demand deep dives: architecture, features, API, patterns, infrastructure, decisions
'''

# Insert after first line (# heading)
lines = content.split('\n')
for i, line in enumerate(lines):
    if line.startswith('# ') and i == 0:
        lines.insert(i + 1, wiki_ref)
        break
else:
    lines.insert(0, wiki_ref)

with open('$CLAUDEMD', 'w') as f:
    f.write('\n'.join(lines))

print('  Added wiki reference to CLAUDE.md')
" 2>/dev/null && echo -e "  ${GREEN}✓ Wiki reference added to CLAUDE.md${NC}" || {
      echo -e "  ${YELLOW}⚠ Could not update CLAUDE.md. Add manually.${NC}"
    }
  fi
else
  echo -e "  ${YELLOW}· No CLAUDE.md found. Create one with /wiki-update --bootstrap${NC}"
fi

# ---------- Done ----------

echo ""
echo "  ─────────────────────────────────────────────"
echo -e "${BOLD}${GREEN}✅ Karpathy Wiki installed!${NC}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo ""
echo "  1. Open Claude Code in this project"
echo "  2. Run:  /wiki-update --bootstrap"
echo "     (Claude will scan the codebase and fill the wiki)"
echo ""
echo -e "  ${BOLD}After that:${NC}"
echo "  • Wiki loads automatically at session start (hook)"
echo "  • Session knowledge saved automatically on exit (hook)"
echo "  • Context preserved during compaction (hook)"
echo ""
echo -e "  ${BOLD}Commands:${NC}"
echo "  /wiki-update              Smart incremental update"
echo "  /wiki-update --bootstrap  Full initial generation"
echo "  /wiki-query <topic>       Search the wiki"
echo "  npm run wiki:lint         Health check"
echo "  npm run wiki:query        Query from terminal"
echo ""
