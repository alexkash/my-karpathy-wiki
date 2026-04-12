#!/bin/bash
set -euo pipefail

# Session Start hook: Read L1 context + last daily log, output JSON systemMessage
# Resolves paths relative to script location (../../ from hooks/)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
L1_DIR="$WIKI_ROOT/.wiki/l1-context"
LOG_DIR="$WIKI_ROOT/.wiki/log/daily"

# If L1 context doesn't exist, exit cleanly
if [ ! -d "$L1_DIR" ]; then
  echo "{}"
  exit 0
fi

# Collect all .md files from l1-context sorted by name
declare -a l1_files
while IFS= read -r -d '' file; do
  l1_files+=("$file")
done < <(find "$L1_DIR" -maxdepth 1 -type f -name "*.md" -print0 | sort -z)

# If no files, exit cleanly
if [ ${#l1_files[@]} -eq 0 ]; then
  echo "{}"
  exit 0
fi

# Concatenate L1 content into temp file
L1_TEMP=$(mktemp)
trap "rm -f $L1_TEMP" EXIT

for file in "${l1_files[@]}"; do
  if [ -s "$file" ]; then
    cat "$file" >> "$L1_TEMP"
    echo "" >> "$L1_TEMP"
    echo "" >> "$L1_TEMP"
  fi
done

# Find last daily log (most recent YYYY-MM-DD.md)
last_log=""
if [ -d "$LOG_DIR" ]; then
  last_log=$(find "$LOG_DIR" -maxdepth 1 -type f -name "*.md" | sort -r | head -1 || true)
fi

# Build combined content temp file
COMBINED_TEMP=$(mktemp)
trap "rm -f $L1_TEMP $COMBINED_TEMP" EXIT

if [ -s "$L1_TEMP" ]; then
  cat "$L1_TEMP" >> "$COMBINED_TEMP"
fi

if [ -n "$last_log" ] && [ -s "$last_log" ]; then
  echo "" >> "$COMBINED_TEMP"
  echo "---" >> "$COMBINED_TEMP"
  echo "## Last Session Log" >> "$COMBINED_TEMP"
  echo "" >> "$COMBINED_TEMP"
  cat "$last_log" >> "$COMBINED_TEMP"
fi

# Output JSON using python3
python3 << 'EOF'
import json
import sys

# Read combined content
try:
  with open(sys.argv[1], 'r') as f:
    combined = f.read()
except:
  combined = ""

output = {
  "systemMessage": combined
}
print(json.dumps(output, ensure_ascii=False))
EOF
"$COMBINED_TEMP"
