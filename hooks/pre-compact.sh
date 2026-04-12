#!/bin/bash
set -euo pipefail

# Pre-Compact hook: Save 20 messages (not 30), inject overview + active-work after compaction
# Reads JSON from stdin with transcript_path field
# Outputs JSON with systemMessage for post-compaction re-injection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$WIKI_ROOT/.wiki/log/daily"
L1_DIR="$WIKI_ROOT/.wiki/l1-context"

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

# Extract last 20 messages using python3
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

  # Keep last 20 messages (not 30)
  relevant = messages[-20:] if len(messages) > 20 else messages

  # Format as markdown with frontmatter
  with open(output_file, 'w') as out:
    out.write('---\n')
    out.write(f'date: {datetime.now().isoformat()}\n')
    out.write('type: pre-compact-save\n')
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
  echo "## Pre-compact save ($(date +%H:%M:%S))" >> "$DAILY_FILE"
  echo "" >> "$DAILY_FILE"
  cat "$MESSAGES_TEMP" >> "$DAILY_FILE"
else
  cat "$MESSAGES_TEMP" > "$DAILY_FILE"
fi

# Read overview.md and active-work.md for re-injection
overview=""
active_work=""

if [ -f "$L1_DIR/overview.md" ] && [ -s "$L1_DIR/overview.md" ]; then
  overview=$(cat "$L1_DIR/overview.md")
fi

if [ -f "$L1_DIR/active-work.md" ] && [ -s "$L1_DIR/active-work.md" ]; then
  active_work=$(cat "$L1_DIR/active-work.md")
fi

# Build systemMessage for re-injection
system_msg=""
if [ -n "$overview" ]; then
  system_msg="$overview"$'\n\n'
fi
if [ -n "$active_work" ]; then
  system_msg+="$active_work"
fi

# Output JSON with systemMessage using python3
python3 << 'EOF'
import json
import sys

system_msg = sys.argv[1] if len(sys.argv) > 1 else ""

output = {
  "systemMessage": system_msg
}
print(json.dumps(output, ensure_ascii=False))
EOF
"$system_msg"
