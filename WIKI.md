# Karpathy Wiki: Compilation-Based Context Architecture

## Purpose

This is a **Karpathy-method compiled wiki**—a two-tier knowledge base optimized for Claude's context window constraints. Rather than RAG (retrieval-augmented generation) or full file dumps, this wiki uses:

- **Compilation:** Human-curated summaries + structured data instead of raw documentation
- **Stratification:** Frequently-accessed facts (L1) always loaded; deep dives (L2) on-demand
- **Freshness:** Automated staleness detection and confidence scoring
- **Portability:** Template-based structure that works across projects

## Two-Tier Architecture

### Layer 1: Always-Loaded Context (L1)
**Budget:** 20K tokens target / 30K max  
**Access:** Automatically loaded at session start  
**Refresh:** Updated during session if changes detected  
**Files:**

| File | Purpose | Update Frequency |
|------|---------|------------------|
| `l1-context/overview.md` | Project description, stack, key directories | Per-sprint |
| `l1-context/architecture.md` | System architecture, data flow, topology | Per-major-feature |
| `l1-context/conventions.md` | Coding rules, anti-patterns, gotchas | Per-quarter |
| `l1-context/commands.md` | Essential CLI commands, dev workflows | Per-sprint |
| `l1-context/active-work.md` | Current focus, recent changes, blockers | Daily |
| `l1-context/known-issues.md` | Bugs, tech debt, workarounds | Weekly |
| `l1-context/glossary.md` | Domain terminology, acronyms | Per-sprint |

### Layer 2: On-Demand Reference (L2)
**Budget:** 2K tokens per page, 5K max  
**Access:** Loaded when `/wiki-query <topic>` is invoked  
**Structure:** Organized by domain
```
l2-reference/
├── architecture/          # Deep-dive system docs
├── features/              # Feature specs & implementations
├── api/                   # API endpoints, payloads, auth
├── patterns/              # Reusable code patterns
├── infrastructure/        # Deployment, ops, monitoring
└── decisions/             # Architecture Decision Records (ADRs)
```

## Page Format: YAML Frontmatter

Every wiki file (L1 and L2) uses this frontmatter:

```yaml
---
title: "Page Title"
type: "overview|architecture|feature|decision|pattern|api|glossary|troubleshooting"
sources: ["file1.ts", "file2.md", "CLAUDE.md"]
related: ["path/to/related-page.md", "another/page.md"]
created: 2024-01-15
updated: 2024-02-20
confidence: high  # high|medium|low
---

# Page Title

Content here...
```

**Frontmatter fields:**
- `title` — Human-readable name
- `type` — Semantic category (helps with `/wiki-query` filtering)
- `sources` — Which files this was sourced from (aids updates)
- `related` — Cross-references to related pages
- `created` — ISO date of creation
- `updated` — ISO date of last update
- `confidence` — How reliable this info is (staleness: 30+ days → low)

## Update Rules

### When to Update
- **After schema changes:** Update `architecture.md` within 24 hours
- **New commands/scripts:** Update `commands.md` immediately
- **Bug fixes / workarounds:** Update `known-issues.md` same day
- **Active work status:** Update `active-work.md` end of day
- **Quarterly:** Re-validate all L1 pages and update timestamps

### How to Update
1. Run `/wiki-update` to scan source files for changes
2. Tool identifies drift between source files and wiki pages
3. Pages with `updated < 30 days ago` stay as-is
4. Pages with `updated > 30 days ago` get `confidence: low` and are flagged
5. Contradict handler checks L1 against source files
6. Merge recommendations into markdown

### File Mapping (for `/wiki-update`)
The update script maps source files → wiki pages:
- `.prisma` / `.zmodel` files → `architecture.md`
- `src/lib/rbac/*.ts` → `conventions.md` (RBAC section)
- `src/server/middleware/*.ts` → `conventions.md` (middleware rules)
- `scripts/` → `commands.md`
- `package.json` → `commands.md` (npm scripts)
- `CLAUDE.md` → All L1 pages (source of truth)
- `.github/workflows/` → `infrastructure/` or `active-work.md`
- `src/components/` → `l2-reference/patterns/`

## Contradiction Handling

When `/wiki-update` detects conflicts:

1. **Source of truth ranking:**
   - CLAUDE.md (if present) > actual code > wiki
   - Recent changes (< 7 days) > older wiki entries
   - Comments in source code > implicit assumptions

2. **Resolution:**
   - Flag with `[CONFLICT]` comment in frontmatter
   - Show both versions to user for manual reconciliation
   - Preserve "confidence: low" until resolved

3. **Example:**
   ```yaml
   ---
   # ... frontmatter
   [CONFLICT]: "conventions.md says 'never use any types', but source shows '@ts-ignore' patterns"
   ---
   ```

## Staleness Detection

Pages are automatically scored for freshness:

| Last Updated | Confidence | Action |
|--------------|-----------|--------|
| < 7 days | `high` | Use as-is |
| 7–30 days | `medium` | Use with caution, consider re-validating |
| > 30 days | `low` | Flag prominently, run `/wiki-update` to refresh |
| > 90 days | `critical` | Exclude from context unless explicitly requested |

Tool: Run `npm run wiki:health-check` to audit all pages.

## Token Budget

### L1 Budget Allocation (20K target)
| Section | Target | Typical |
|---------|--------|---------|
| overview.md | 4K | 3.5K |
| architecture.md | 5K | 4.8K |
| conventions.md | 6K | 5.2K |
| commands.md | 2K | 1.9K |
| active-work.md | 2K | 1.8K |
| known-issues.md | 2K | 1.9K |
| glossary.md | 1K | 0.8K |
| **TOTAL** | **22K** | **~19.9K** |

If L1 exceeds 30K, compress lower-confidence sections into L2.

### L2 Budget Per Page (2K target, 5K max)
- Feature specs: 2–3K
- API docs: 1.5–2.5K
- Patterns: 1–2K
- ADRs: 1–1.5K
- Troubleshooting: 0.5–1.5K

Use `/wiki-query --budget` to monitor.

## Automation Hooks

Three hook points for keeping wiki fresh:

### 1. Session Start (`pre-load.sh`)
```bash
# Runs when user opens Claude Code session
if [ -f .wiki/log/session-lock ]; then
  # Another session is writing — wait
  sleep 2
fi

# Check for stale pages
npm run wiki:health-check --quiet

# If any page is > 30 days old, log warning but don't block
```

### 2. Session End (`post-save.sh`)
```bash
# After Claude finishes major edits
git status --porcelain | grep -E '\.(ts|zmodel|prisma)$' && {
  # Files changed — trigger wiki update
  npm run wiki:update --auto
}
```

### 3. Pre-Compact (`compact.sh`)
```bash
# Before compiling L1 context for Claude
# Remove L2 pages not referenced in recent sessions
rm -f .wiki/l2-reference/**/*.tmp
npm run wiki:compact
```

## Portability Instructions

This wiki is designed to bootstrap in any project:

### For New Projects

1. **Copy this template:**
   ```bash
   cp -r wiki-template .wiki
   ```

2. **Bootstrap with project details:**
   ```bash
   npm run wiki:bootstrap
   # Interactively prompts for project name, stack, key paths
   # Fills L1 overview.md, architecture.md scaffolds
   ```

3. **Add source-file mappings** (optional, for auto-updates):
   - Edit `.wiki/config.yml` with your project's file structure
   - Set frequency (daily, per-sprint, manual)

4. **First `/wiki-update`:**
   ```bash
   npm run wiki:update --full
   # Scans all source files, populates L2 pages
   ```

### Migrating from Old Wikis

1. Export old knowledge base as markdown files → `.wiki/l2-reference/imported/`
2. Run: `npm run wiki:migrate`
3. Tool attempts to extract frontmatter and reclassify
4. Manual review + confidence scoring

### Disabling Auto-Updates

If your project doesn't have `npm run wiki:*` scripts:

1. Delete `.wiki/scripts/`
2. Use `/wiki-update` manually when needed
3. Claude will still respect frontmatter & staleness scores

## Integration with Claude Code Workflow

### /wiki-query Command
```bash
/wiki-query "how do I authenticate API calls?"
# Returns: active-work.md snippet + conventions.md (auth section)
# If not found in L1, searches L2 and loads matching pages
```

### /wiki-update Command
```bash
/wiki-update --full
# Scans all source files, compares with wiki
# Shows diffs, prompts for merges

/wiki-update --dry-run
# Show what would change without writing
```

### /wiki-check Command
```bash
/wiki-check
# Quick validation: frontmatter, cross-refs, staleness
```

## Contradiction Scenarios

### Scenario 1: Code Comment vs. Wiki
```
Code comment:  "// Cache TTL is 5 minutes"
Wiki says:    "Cache TTL is 10 minutes"
Action:       Show both to user, ask which to trust, update confidence
```

### Scenario 2: Multiple L2 Pages Same Topic
```
l2-reference/patterns/caching.md         (1 year old, confidence: low)
l2-reference/architecture/performance.md (2 weeks old, confidence: medium)
Action:       Merge into one, mark old page as "deprecated, see [new-page]"
```

### Scenario 3: Breaking Change in Source
```
CLAUDE.md updated: "Never use @ts-ignore" (3 days ago)
conventions.md:    "@ts-ignore OK with explanation" (200 days old)
Action:           Flag [CONFLICT], show both, update conventions.md, set confidence: high
```

## Example: Start a New Session

1. Claude loads `.wiki/l1-context/*.md` (~19K tokens)
2. User asks: "How do I add a new API endpoint?"
3. Claude:
   - Checks `conventions.md` for rules ✓
   - Checks `architecture.md` for structure ✓
   - If more detail needed, triggers `/wiki-query "API endpoints"` → loads `l2-reference/api/structure.md`
4. Claude helps user implement
5. User makes changes to source files
6. At session end, `/post-save.sh` runs, detects changes
7. Next session, user sees `/wiki-update` notice: "3 files changed since last session. Run `/wiki-update` to sync?"

This keeps knowledge fresh without manual maintenance burden.

---

**Last Updated:** 2025-02-15  
**Confidence:** high  
**Maintainer:** Karpathy wiki template v1.0
