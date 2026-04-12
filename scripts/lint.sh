#!/bin/bash
set -euo pipefail

# Wiki health check: frontmatter, staleness, stubs, broken links, orphans, token budget

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
L1_DIR="$WIKI_ROOT/.wiki/l1-context"
L2_DIR="$WIKI_ROOT/.wiki/l2-reference"
LOG_DIR="$WIKI_ROOT/.wiki/log/daily"
COMPILED_DIR="$WIKI_ROOT/.wiki/log/compiled"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

issues=0
total_words=0

echo "Wiki Health Check"
echo "================="
echo ""

# 1. Check frontmatter in L1
echo "Checking L1 frontmatter..."
if [ -d "$L1_DIR" ]; then
  for file in "$L1_DIR"/*.md; do
    if [ -f "$file" ]; then
      first_line=$(head -1 "$file")
      if [ "$first_line" != "---" ]; then
        echo -e "${RED}✗ Missing frontmatter: $(basename "$file")${NC}"
        ((issues++))
      fi
    fi
  done
fi

# 2. Check staleness (> 30 days)
echo "Checking for stale pages (> 30 days old)..."
cutoff=$(date -v-30d +%s 2>/dev/null || date -d "30 days ago" +%s)

for dir in "$L1_DIR" "$L2_DIR"; do
  if [ -d "$dir" ]; then
    while IFS= read -r -d '' file; do
      mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
      if [ "$mtime" -lt "$cutoff" ]; then
        echo -e "${YELLOW}⚠ Stale ($(date -r "$mtime" +%Y-%m-%d)): $(basename "$file")${NC}"
        ((issues++))
      fi
    done < <(find "$dir" -maxdepth 1 -type f -name "*.md" -print0)
  fi
done

# 3. Check for stubs (< 50 words)
echo "Checking for stub pages (< 50 words)..."
for dir in "$L1_DIR" "$L2_DIR"; do
  if [ -d "$dir" ]; then
    while IFS= read -r -d '' file; do
      wordcount=$(wc -w < "$file" 2>/dev/null || echo 0)
      if [ "$wordcount" -lt 50 ]; then
        echo -e "${YELLOW}⚠ Stub (${wordcount}w): $(basename "$file")${NC}"
        ((issues++))
      fi
      ((total_words += wordcount))
    done < <(find "$dir" -maxdepth 1 -type f -name "*.md" -print0)
  fi
done

# 4. Check broken internal links using python3
echo "Checking for broken internal links..."
python3 << EOF
import os
import re
import sys

wiki_root = "$WIKI_ROOT"
l1_dir = os.path.join(wiki_root, '.wiki', 'l1-context')
l2_dir = os.path.join(wiki_root, '.wiki', 'l2-reference')

# Build map of available files
available_files = set()
for d in [l1_dir, l2_dir]:
  if os.path.isdir(d):
    for f in os.listdir(d):
      if f.endswith('.md'):
        available_files.add(f)
        # Also add without .md
        available_files.add(f[:-3])

# Find all markdown links
issue_count = 0
for d in [l1_dir, l2_dir]:
  if os.path.isdir(d):
    for filename in os.listdir(d):
      if filename.endswith('.md'):
        filepath = os.path.join(d, filename)
        try:
          with open(filepath, 'r') as f:
            content = f.read()
            # Match [text](relative/path.md)
            links = re.findall(r'\[([^\]]+)\]\(([^)]+\.md)\)', content)
            for text, link in links:
              # Normalize link
              link_file = os.path.basename(link)
              if link_file not in available_files:
                print(f'✗ Broken link in {filename}: {link}')
                issue_count += 1
        except:
          pass

sys.exit(0 if issue_count == 0 else 1)
EOF


# 5. Check uncompiled logs
echo "Checking for uncompiled daily logs..."
uncompiled=0
if [ -d "$LOG_DIR" ]; then
  for file in $(find "$LOG_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort -r); do
    basename=$(basename "$file" .md)
    if [ ! -f "$COMPILED_DIR/$basename.md.compiled" ]; then
      echo -e "${YELLOW}⚠ Uncompiled: $basename${NC}"
      ((uncompiled++))
      ((issues++))
    fi
  done
fi

# 6. Check for orphan L2 pages
echo "Checking for orphan L2 pages (not referenced)..."
if [ -d "$L2_DIR" ]; then
  # Read all wiki content into variable
  all_content=""
  find "$L1_DIR" "$L2_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | while read -r f; do
    if [ -f "$f" ]; then
      all_content+=$(cat "$f")$'\n'
    fi
  done 2>/dev/null || true

  # Re-read for orphan check (variable scope issue with while)
  all_content=$(find "$L1_DIR" "$L2_DIR" -maxdepth 1 -type f -name "*.md" -exec cat {} \; 2>/dev/null | cat)

  for l2_file in "$L2_DIR"/*.md; do
    if [ -f "$l2_file" ]; then
      filename=$(basename "$l2_file")
      # Check if referenced anywhere
      if ! echo "$all_content" | grep -q "$filename"; then
        echo -e "${YELLOW}⚠ Orphan: $filename${NC}"
        ((issues++))
      fi
    fi
  done
fi

# 7. L1 token budget (words * 1.3)
echo "Calculating L1 token budget..."
l1_words=0
l1_files=0
if [ -d "$L1_DIR" ]; then
  for file in "$L1_DIR"/*.md; do
    if [ -f "$file" ]; then
      w=$(wc -w < "$file" 2>/dev/null || echo 0)
      ((l1_words += w))
      ((l1_files++))
    fi
  done
fi

l1_tokens=$((l1_words * 13 / 10))
echo -e "${GREEN}L1: $l1_files files, $l1_words words, ~${l1_tokens} tokens${NC}"

# 8. Summary
echo ""
echo "Summary"
echo "======="
l1_count=$(find "$L1_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)
l2_count=$(find "$L2_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)
echo "Pages: L1=$l1_count, L2=$l2_count"
echo "Total words: $total_words"

if [ $issues -eq 0 ]; then
  echo -e "${GREEN}✓ Wiki is healthy${NC}"
  exit 0
else
  echo -e "${RED}✗ Found $issues issue(s)${NC}"
  exit 1
fi
