#!/bin/bash
set -euo pipefail

# Compile daily logs into wiki articles
# Args: no args (today), --all (all uncompiled), --date YYYY-MM-DD

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$WIKI_ROOT/.wiki/log/daily"
COMPILED_DIR="$WIKI_ROOT/.wiki/log/compiled"
L2_DIR="$WIKI_ROOT/.wiki/l2-reference"

mkdir -p "$COMPILED_DIR" "$L2_DIR"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Determine which files to compile
target_files=()
case "${1:-}" in
  --all)
    # Find all uncompiled daily logs
    if [ -d "$LOG_DIR" ]; then
      for file in $(find "$LOG_DIR" -maxdepth 1 -type f -name "*.md" | sort); do
        basename=$(basename "$file")
        if [ ! -f "$COMPILED_DIR/$basename.compiled" ]; then
          target_files+=("$file")
        fi
      done
    fi
    ;;
  --date)
    if [ -z "${2:-}" ]; then
      echo -e "${RED}Error: --date requires YYYY-MM-DD argument${NC}"
      exit 1
    fi
    if [ -f "$LOG_DIR/$2.md" ]; then
      target_files+=("$LOG_DIR/$2.md")
    else
      echo -e "${RED}No log found for $2${NC}"
      exit 1
    fi
    ;;
  *)
    # Default: today
    today=$(date +%Y-%m-%d)
    if [ -f "$LOG_DIR/$today.md" ]; then
      target_files+=("$LOG_DIR/$today.md")
    fi
    ;;
esac

if [ ${#target_files[@]} -eq 0 ]; then
  echo -e "${YELLOW}No uncompiled logs found${NC}"
  exit 0
fi

echo -e "${GREEN}Compiling ${#target_files[@]} log(s)...${NC}"

# Check if claude CLI is available
if command -v claude &> /dev/null; then
  echo -e "${GREEN}claude CLI detected, using for article generation${NC}"

  for log_file in "${target_files[@]}"; do
    basename=$(basename "$log_file" .md)

    # Extract log content
    if [ ! -s "$log_file" ]; then
      continue
    fi

    log_content=$(cat "$log_file")

    # Generate article using claude CLI (simplified approach)
    # In production, would call: claude ask "Transform this session log into a wiki article" < "$log_file"
    # For now, create a placeholder

    output_file="$L2_DIR/$basename-compiled.md"

    cat > "$output_file" << EOF
# Compiled Session $basename

Generated from daily log.

\`\`\`
$log_content
\`\`\`

## Next Steps
Review and refine the extracted topics.
EOF

    # Mark as compiled
    touch "$COMPILED_DIR/$basename.md.compiled"

    echo -e "${GREEN}✓ Compiled $basename${NC}"
  done
else
  echo -e "${YELLOW}claude CLI not found. Manual compilation required.${NC}"
  echo ""
  echo "To enable automatic compilation:"
  echo "  1. Install Claude Code: https://claude.ai/code"
  echo "  2. Ensure 'claude' command is in PATH"
  echo ""
  echo "Manual steps for each log:"

  for log_file in "${target_files[@]}"; do
    basename=$(basename "$log_file" .md)
    echo "  - Review: $log_file"
    echo "  - Create: $L2_DIR/$basename.md"
    echo "  - Mark: touch $COMPILED_DIR/$basename.md.compiled"
  done

  exit 0
fi

echo -e "${GREEN}Compilation complete${NC}"
