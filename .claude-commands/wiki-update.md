# /wiki-update

**Claude Code command for incremental wiki updates**

## Usage

```bash
/wiki-update [mode]
```

## Modes

- **default** (no args): Git diff incremental update — scan changed files, update relevant wiki pages
- **--bootstrap**: Full project scan — detect and initialize complete wiki structure
- **--full**: Recompile all — regenerate all wiki articles from scratch
- **--check**: Staleness check — identify pages not updated in 30+ days
- **--scope <area>**: Focused update — update wiki for specific area (e.g., `auth`, `api`, `database`)

## Implementation Steps

**Step 1: Determine Update Mode**
- Parse `$ARGUMENTS` for mode flag
- Default to incremental if no flag provided

**Step 2: Collect Changed Files**
For incremental mode:
- Run `git diff --name-only HEAD~1..HEAD` (or `git status --porcelain`)
- Group by feature area (auth, candidates, pipeline, etc.)
- Build file change manifest

**Step 3: Map Changes to Wiki**
Use this table to determine which wiki pages need updating:

| Source Files | Wiki Page | Content |
|---|---|---|
| `src/lib/rbac/**`, `src/server/middleware/rbac-*.ts` | `l2-reference/rbac.md` | RBAC architecture, permission matrix, audit trail |
| `schema/*.zmodel`, `scripts/tenant-schema/` | `l2-reference/db-schema.md` | Schema changes, migrations, DDL patterns |
| `src/lib/auth/**`, `src/server/routers/auth/**` | `l2-reference/auth.md` | Auth flow, JWT, session management, OAuth |
| `src/server/routers/tenant/**` | `l2-reference/api.md` | tRPC router updates, new procedures, breaking changes |
| `src/components/**`, `src/app/**`, `*.tsx` | `l2-reference/ui-patterns.md` | Component patterns, hooks, form validation |
| `__tests__/**`, `playwright/` | `l2-reference/testing.md` | New test patterns, test coverage updates |
| `microservices/`, `src/lib/integrations/` | `l2-reference/integrations.md` | External service integrations, microservice APIs |
| `docs/`, `*.md` in root | `l1-context/commands.md` | Commands, setup instructions, scripts |
| `src/` (any breaking change) | `l1-context/active-work.md` | Current focus, known issues, breaking changes |

**Step 4: Update L1 Active Work**
Append to `l1-context/active-work.md`:
```markdown
## Session [DATE] Update
- [Change 1]
- [Change 2]
- Related L2 pages: [links]
```

**Step 5: Update Relevant L2 Pages**
For each changed area:
1. Extract key changes from modified source files
2. Generate/update corresponding L2 page
3. Update timestamps in frontmatter
4. Link related pages

**Step 6: Save Incremental Update Log**
Create `l1-context/changelog.md` entry:
```markdown
### [DATE] - [Scope]
- Updated: [page list]
- Files changed: [N]
- Summary: [brief]
```

## Changelog Format

Each update appends to the session log in `active-work.md`:

```markdown
---
timestamp: 2026-04-12T14:30:00Z
files_changed: 5
scope: candidates
---

**Summary:** Updated candidate pipeline filtering and status transitions

**Changes:**
- Modified `candidateStatus` enum in schema
- Updated `l2-reference/db-schema.md` with new status values
- Updated `l2-reference/api.md` with breaking changes
- Added validation rule in `l2-reference/rbac.md`

**Files:**
- schema/tenant.zmodel
- src/server/routers/tenant/candidate.ts
- __tests__/candidate-status.test.ts
```

## Writing Guidelines

### L1 Context (always-loaded)
- **Concise**: Max 200 words per section
- **Actionable**: Include commands, links, quick references
- **Current**: Update timestamps when modified
- **Frontmatter**: Always include `---` YAML header with title + role
- **Format**: Markdown with strong headings

### L2 Reference (on-demand)
- **Comprehensive**: 500-2000 words, go deep
- **Structured**: Use tables, code examples, decision trees
- **Linked**: Cross-reference related L2 pages and L1
- **Versioned**: Track breaking changes and deprecations
- **Examples**: Include code snippets for patterns

### Daily Logs
- **Format**: `l1-context/changelog.md` for permanent records
- **Frontmatter**: Date, scope, files changed
- **Entries**: One section per session/update
- **Archive**: Old entries are read by `/wiki-query` for context

## Examples

### Incremental Update (default)
```bash
# Changes made to auth and RBAC
/wiki-update

# Updates:
# - l2-reference/auth.md (JWT expiry change)
# - l2-reference/rbac.md (permission matrix)
# - l1-context/active-work.md (session log)
```

### Bootstrap New Project
```bash
/wiki-update --bootstrap

# Creates: .wiki/{l1-context,l2-reference,log/daily,log/compiled}/
# Initializes template pages based on package.json/pyproject.toml/Cargo.toml
```

### Focused Update
```bash
/wiki-update --scope database

# Updates only pages related to:
# - schema/tenant.zmodel
# - scripts/tenant-schema/
# Result: l2-reference/db-schema.md updated
```

## Integration

This command is typically called:
1. **Automatically** by CI/CD before commit
2. **Manually** after major changes with `/wiki-update --full`
3. **In sessions** to keep context fresh (hourly cron possible)

The wiki is injected into system context via `session-start.sh` hook which reads all `l1-context/*.md` files at session start.
