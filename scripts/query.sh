#!/bin/bash
set -euo pipefail

# Query wiki from terminal
# Args: search query, --index (list pages), --status (health), --recent (changelog)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
L1_DIR="$WIKI_ROOT/.wiki/l1-context"
L2_DIR="$WIKI_ROOT/.wiki/l2-reference"
LOG_DIR="$WIKI_ROOT/.wiki/log/daily"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper: Get relative path using python3
get_relative_path() {
  python3 << 'EOF'
import os
import sys

file_path = sys.argv[1]
base_path = sys.argv[2]

try:
  rel = os.path.relpath(file_path, base_path)
  print(rel)
except:
  print(file_path)
EOF
"$1" "$2"
}

# Default action
action="${1:-search}"

case "$action" in
  --index)
    echo "Wiki Pages"
    echo "=========="
    echo ""
    echo -e "${BLUE}L1 Context:${NC}"
    if [ -d "$L1_DIR" ]; then
      find "$L1_DIR" -maxdepth 1 -type f -name "*.md" | sort | while read -r f; do
        size=$(wc -w < "$f" 2>/dev/null || echo 0)
        echo "  $(basename "$f") ($size words)"
      done
    fi
    echo ""
    echo -e "${BLUE}L2 Reference:${NC}"
    if [ -d "$L2_DIR" ]; then
      find "$L2_DIR" -maxdepth 1 -type f -name "*.md" | sort | while read -r f; do
        size=$(wc -w < "$f" 2>/dev/null || echo 0)
        echo "  $(basename "$f") ($size words)"
      done
    fi
    ;;

  --status)
    echo "Wiki Status"
    echo "==========="
    echo ""
    # Count pages
    l1_count=$(find "$L1_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)
    l2_count=$(find "$L2_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)
    total=$((l1_count + l2_count))

    echo "Pages:"
    echo "  L1 Context: $l1_count"
    echo "  L2 Reference: $l2_count"
    echo "  Total: $total"
    echo ""

    # Recent activity
    echo "Recent logs:"
    if [ -d "$LOG_DIR" ]; then
      find "$LOG_DIR" -maxdepth 1 -type f -name "*.md" | sort -r | head -5 | while read -r f; do
        echo "  $(basename "$f")"
      done
    fi
    echo ""

    # Run lint if available
    if [ -x "$SCRIPT_DIR/lint.sh" ]; then
      echo "Running health check..."
      "$SCRIPT_DIR/lint.sh" 2>&1 | tail -10
    fi
    ;;

  --recent)
    echo "Recent Changelog"
    echo "================"
    echo ""
    if [ -d "$LOG_DIR" ]; then
      # Show last 3 daily logs with summaries
      find "$LOG_DIR" -maxdepth 1 -type f -name "*.md" | sort -r | head -3 | while read -r f; do
        basename=$(basename "$f")
        echo -e "${BLUE}$basename${NC}"
        # Show first 5 lines of content
        tail -n +4 "$f" | head -10
        echo ""
      done
    fi
    ;;

  *)
    # Search mode
    query="$action"
    echo "Searching wiki for: $query"
    echo "=========================="
    echo ""

    found=0

    # Search in L1
    if [ -d "$L1_DIR" ]; then
      results=$(grep -r -i "$query" "$L1_DIR" 2>/dev/null || true)
      if [ -n "$results" ]; then
        echo -e "${BLUE}L1 Results:${NC}"
        echo "$results" | head -10
        ((found++))
        echo ""
      fi
    fi

    # Search in L2
    if [ -d "$L2_DIR" ]; then
      results=$(grep -r -i "$query" "$L2_DIR" 2>/dev/null || true)
      if [ -n "$results" ]; then
        echo -e "${BLUE}L2 Results:${NC}"
        echo "$results" | head -10
        ((found++))
        echo ""
      fi
    fi

    # Search in logs
    if [ -d "$LOG_DIR" ]; then
      results=$(grep -r -i "$query" "$LOG_DIR" 2>/dev/null || true)
      if [ -n "$results" ]; then
        echo -e "${BLUE}Log Results:${NC}"
        echo "$results" | head -10
        ((found++))
        echo ""
      fi
    fi

    if [ $found -eq 0 ]; then
      echo -e "${YELLOW}No results found${NC}"
      exit 1
    fi

    # Try to synthesize using claude if available
    if command -v claude &> /dev/null; then
      echo -e "${GREEN}Synthesizing answer with Claude...${NC}"
      echo ""
      # Build context from results
      context=""
      for dir in "$L1_DIR" "$L2_DIR"; do
        if [ -d "$dir" ]; then
          context+=$(grep -r -i "$query" "$dir" 2>/dev/null || true)
          context+=$'\n'
        fi
      done

      # Limit context length
      context="${context:0:2000}"

      # Query claude (simplified)
      # In production, would pipe context: echo "$context" | claude ask "Based on this wiki content, answer: $query"
      echo "Claude synthesis would appear here"
    fi
    ;;
esac
