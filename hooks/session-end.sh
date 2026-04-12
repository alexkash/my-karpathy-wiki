#!/bin/bash
set -euo pipefail

# Session End hook: Extract last 30 messages from JSONL transcript, save to daily log
# Reads JSON from stdin with transcript_path field
# Outputs {} on stdout

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$WIKI_ROOT/.wiki/log/daily"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Read JSON from stdin
input=$(cat)
if [ -z "$input" ]; then
  echo "{}"
  exit 0
fi

# Extract transcript_path using python3
transcript_path=$(python3 << 'EOF'
import json
import sys

try:
  data = json.loads(sys.argv[1])
  print(data.get('transcript_path', ''))
except:
  print('')
EOF
"$input")

# If no transcript path, exit cleanly
if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
  echo "{}"
  exit 0
fi

# Extract last 30 messages using python3
MESSAGES_TEMP=$(mktemp)
trap "rm -f $MESSAGES_TEMP" EXIT

python3 << 'EOF'
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
      except:
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
"$transcript_path" "$MESSAGES_TEMP"

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
