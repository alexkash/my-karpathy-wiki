#!/bin/bash
set -euo pipefail

# Session End hook: Extract last 30 messages from JSONL transcript, save to daily log
# Reads JSON from stdin with transcript_path field
# Outputs {} on stdout

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Search upward for .wiki/ directory (works both in repo and after install)
WIKI_ROOT=""
dir="$SCRIPT_DIR"
while [ "$dir" != "/" ]; do
  if [ -d "$dir/.wiki" ]; then
    WIKI_ROOT="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done

if [ -z "$WIKI_ROOT" ]; then
  echo "{}"
  exit 0
fi

LOG_DIR="$WIKI_ROOT/.wiki/log/daily"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Read JSON from stdin
input=$(cat)
if [ -z "$input" ]; then
  echo "{}"
  exit 0
fi

# Extract transcript_path — pipe input via stdin, not sys.argv
transcript_path=$(echo "$input" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('transcript_path', ''))
except Exception:
    print('')
")

# If no transcript path, exit cleanly
if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
  echo "{}"
  exit 0
fi

# Extract last 30 messages using python3
MESSAGES_TEMP=$(mktemp)
trap "rm -f $MESSAGES_TEMP" EXIT

# Pass file paths via argv (python3 - arg1 arg2 << 'EOF' syntax)
python3 - "$transcript_path" "$MESSAGES_TEMP" << 'EOF'
import json
import sys
from datetime import datetime

transcript_path = sys.argv[1]
output_file = sys.argv[2]

try:
  with open(transcript_path, 'r') as f:
    lines = f.readlines()

  messages = []
  for line in lines:
    if line.strip():
      try:
        msg = json.loads(line)
        messages.append(msg)
      except Exception:
        pass

  # Keep last 30 messages (user + assistant pairs)
  relevant = messages[-30:] if len(messages) > 30 else messages

  # Format as markdown with frontmatter
  with open(output_file, 'w') as out:
    out.write('---\n')
    out.write(f'date: {datetime.now().isoformat()}\n')
    out.write('type: session-end\n')
    out.write('---\n\n')

    for msg in relevant:
      role = msg.get('role', 'unknown').upper()
      content = msg.get('content', '')
      if content:
        out.write(f'**{role}:**\n{content}\n\n')
except Exception as e:
  with open(output_file, 'w') as out:
    out.write(f'Error: {str(e)}\n')
EOF

# Get today's date
TODAY=$(date +%Y-%m-%d)
DAILY_FILE="$LOG_DIR/$TODAY.md"

# Append to existing daily file or create new one
if [ -f "$DAILY_FILE" ]; then
  echo "" >> "$DAILY_FILE"
  echo "---" >> "$DAILY_FILE"
  echo "## Session End ($(date +%H:%M:%S))" >> "$DAILY_FILE"
  echo "" >> "$DAILY_FILE"
  cat "$MESSAGES_TEMP" >> "$DAILY_FILE"
else
  cat "$MESSAGES_TEMP" > "$DAILY_FILE"
fi

# Output empty JSON
echo "{}"
