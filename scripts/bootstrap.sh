#!/bin/bash
set -euo pipefail

# Bootstrap: Lightweight scaffolding for new wiki
# Detects project info from package.json, pyproject.toml, Cargo.toml, go.mod
# Creates .wiki/ structure and template files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WIKI_ROOT="$PROJECT_ROOT/.wiki"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Karpathy Wiki Bootstrap${NC}"
echo "======================="
echo ""

# Detect project info
project_name="Project"
project_type="unknown"
project_lang="unknown"

if [ -f "$PROJECT_ROOT/package.json" ]; then
  project_type="JavaScript/Node"
  project_lang="JavaScript"
  # Extract name from package.json
  project_name=$(python3 -c "import json; print(json.load(open('$PROJECT_ROOT/package.json')).get('name', 'Project'))" 2>/dev/null || echo "Project")
elif [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
  project_type="Python"
  project_lang="Python"
  project_name=$(grep '^name' "$PROJECT_ROOT/pyproject.toml" | head -1 | cut -d'=' -f2 | tr -d ' "' | cut -d'-' -f1)
elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
  project_type="Rust"
  project_lang="Rust"
  project_name=$(grep '^name' "$PROJECT_ROOT/Cargo.toml" | head -1 | cut -d'=' -f2 | tr -d ' "')
elif [ -f "$PROJECT_ROOT/go.mod" ]; then
  project_type="Go"
  project_lang="Go"
  project_name=$(head -1 "$PROJECT_ROOT/go.mod" | cut -d' ' -f2 | xargs basename)
fi

echo -e "${GREEN}Detected:${NC}"
echo "  Project: $project_name"
echo "  Type: $project_type"
echo "  Language: $project_lang"
echo ""

# Create directory structure
echo "Creating wiki structure..."

mkdir -p "$WIKI_ROOT"/{l1-context,l2-reference,log/{daily,compiled}}

echo -e "${GREEN}✓ Created directories${NC}"
echo ""

# Create template files
echo "Creating template files..."

# overview.md template
cat > "$WIKI_ROOT/l1-context/overview.md" << 'EOF'
---
title: Project Overview
role: l1-context
---

# Project Overview

Brief description of the project.

## Key Facts

- **Project Name**: [Project Name]
- **Type**: [Type]
- **Language**: [Language]
- **Status**: [Active/Archived/In Planning]

## Problem Statement

What problem does this project solve?

## Architecture

High-level architecture overview.

## Getting Started

How to get up and running.
EOF

# conventions.md template
cat > "$WIKI_ROOT/l1-context/conventions.md" << 'EOF'
---
title: Conventions & Standards
role: l1-context
---

# Conventions & Standards

## Naming Conventions

- [Add naming rules for your project]

## Code Style

- [Add style guidelines]

## Project Structure

- [Add structure guidelines]

## Git Workflow

- [Add git conventions]
EOF

# glossary.md template
cat > "$WIKI_ROOT/l1-context/glossary.md" << 'EOF'
---
title: Glossary
role: l1-context
---

# Glossary

## Terms

- **Term**: Definition
EOF

# active-work.md template
cat > "$WIKI_ROOT/l1-context/active-work.md" << 'EOF'
---
title: Active Work
role: l1-context
updated: $(date +%Y-%m-%d)
---

# Active Work

## Current Focus

What are you working on right now?

## Recent Changes

- [List recent changes]

## Known Issues

- [List known issues]

## Next Steps

- [Planned work]
EOF

# commands.md template
cat > "$WIKI_ROOT/l1-context/commands.md" << 'EOF'
---
title: Essential Commands
role: l1-context
---

# Essential Commands

## Development

| Command | Description |
|---------|-------------|
| [command] | [description] |

## Testing

| Command | Description |
|---------|-------------|
| [command] | [description] |

## Build & Deploy

| Command | Description |
|---------|-------------|
| [command] | [description] |
EOF

echo -e "${GREEN}✓ Created template files${NC}"
echo ""

# Create .claude-commands directory if it doesn't exist in wiki structure
mkdir -p "$WIKI_ROOT/.claude-commands" 2>/dev/null || true

echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Edit wiki files:"
echo "   - $WIKI_ROOT/l1-context/overview.md"
echo "   - $WIKI_ROOT/l1-context/conventions.md"
echo "   - $WIKI_ROOT/l1-context/commands.md"
echo ""
echo "2. Create L2 reference pages as needed:"
echo "   - $WIKI_ROOT/l2-reference/architecture.md"
echo "   - $WIKI_ROOT/l2-reference/api-reference.md"
echo ""
echo "3. Test the wiki:"
echo "   - $SCRIPT_DIR/query.sh --index"
echo "   - $SCRIPT_DIR/query.sh --status"
echo "   - $SCRIPT_DIR/lint.sh"
echo ""
echo -e "${GREEN}✓ Bootstrap complete${NC}"
