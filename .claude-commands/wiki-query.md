# /wiki-query

**Claude Code command for querying wiki and synthesizing answers**

## Usage

```bash
/wiki-query <query>
/wiki-query [special-query]
```

## Query Types

- **Text search** (default): Search for topics, patterns, or questions
- **--index**: List all wiki pages with metadata
- **--status**: Overall wiki health and statistics
- **--recent**: Show recent changes and session logs
- **--stale**: Find pages not updated in 30+ days
- **--broken**: Find broken links and orphan pages

## Implementation Steps

**Step 1: Load L1 Context**
- Read all files from `.wiki/l1-context/*.md` in alphabetical order
- Concatenate into memory (typically 2-10K tokens)
- This is the "always-loaded" system context

**Step 2: Determine Relevant L2 Pages**
Based on query topic, identify which L2 reference pages apply:

| Query Pattern | Relevant L2 Pages |
|---|---|
| `auth`, `login`, `session`, `JWT` | `l2-reference/auth.md` |
| `RBAC`, `permission`, `role`, `access` | `l2-reference/rbac.md` |
| `schema`, `database`, `migration`, `table` | `l2-reference/db-schema.md` |
| `API`, `tRPC`, `router`, `procedure` | `l2-reference/api.md` |
| `component`, `hook`, `form`, `UI` | `l2-reference/ui-patterns.md` |
| `test`, `playwright`, `jest`, `unit` | `l2-reference/testing.md` |
| `integration`, `webhook`, `microservice` | `l2-reference/integrations.md` |
| `architecture`, `design`, `pattern` | `l2-reference/architecture.md` |

**Step 3: Grep Search in Wiki**
```bash
grep -r -i "<query>" .wiki/ --include="*.md"
```

- Search L1 first (always loaded anyway)
- Search L2 pages identified in Step 2
- Search daily logs for recent context
- Limit results to top 10 matching lines

**Step 4: Synthesize Answer**
Using L1 + matched L2 + search results:

1. **Collect**: Gather all matching content
2. **Rank**: Sort by relevance (L1 > L2 matching scope > logs)
3. **Synthesize**: Generate cohesive answer with:
   - Direct quote from wiki (if relevant)
   - Link to full page: `See .wiki/l2-reference/auth.md`
   - Example code or table if available
   - Related topics (cross-references)
4. **Fallback**: If no results, suggest `/wiki-update --check` to see what's missing

## Special Queries

### --index
List all pages:
```
L1 Context (Always-Loaded):
  - overview.md (500w)
  - conventions.md (300w)
  - commands.md (400w)
  - glossary.md (200w)
  - active-work.md (250w)

L2 Reference (On-Demand):
  - auth.md (1200w)
  - rbac.md (1500w)
  - db-schema.md (2000w)
  ...
```

### --status
Summary:
```
Total Pages: 12 (5 L1, 7 L2)
Token Budget: L1 = ~2K / 4K max
Total Wiki: ~8K words
Last Update: 2026-04-12
Uncompiled Logs: 3
Health: 2 issues (1 stale page, 1 orphan)
```

### --recent
Show last 3-5 session log entries with summaries:
```
2026-04-12 - Auth Refactor
  - Updated JWT expiry logic
  - Added session tracking in Redis
  - Files: src/lib/auth/*, src/server/routers/auth/*

2026-04-11 - Candidate Pipeline
  - Added bulk status update
  - Modified schema for new status values
  - Files: schema/tenant.zmodel, src/server/routers/tenant/candidate.ts
```

### --stale
Pages not updated in 30+ days:
```
⚠ Stale Pages (30+ days old):
  - l2-reference/architecture.md (last update: 2026-02-20)
  - l2-reference/integrations.md (last update: 2026-02-15)
```

### --broken
Find issues:
```
✗ Broken Links:
  - auth.md: references missing "oauth-flow.md"
  
✗ Orphan Pages:
  - l2-reference/deprecated-api.md (not referenced anywhere)
```

## Query Examples

### Simple Text Search
```bash
/wiki-query authentication
# Loads L1, searches for "authentication"
# Returns matches from auth.md + conventions.md
# Synthesizes: "Authentication uses JWT tokens. See l2-reference/auth.md for details."
```

### Architecture Question
```bash
/wiki-query how does multi-tenancy work
# Identifies: architecture.md, db-schema.md as relevant
# Searches for "tenant", "schema-per-tenant", "isolation"
# Returns: Multi-paragraph answer with code examples
```

### Permission-Related Question
```bash
/wiki-query what permission do I need to update candidates
# Identified L2: rbac.md
# Searches for "candidate.update", "permission"
# Returns: Permission matrix excerpt + related links
```

### Status Check
```bash
/wiki-query --status
# No search needed; runs health check
# Shows: page counts, L1 token budget, last update, issues
```

## Context Window Management

**L1 Auto-Loaded:**
- Always included in system message (via `session-start.sh`)
- ~2K tokens max (enforced by linter)
- User never needs to search for basic info

**L2 Loaded On-Demand:**
- Determined by query topic matching
- Only relevant pages included
- Typical query: L1 (2K) + matched L2 (1-2K) + search results

**Daily Logs:**
- Last 5-10 entries shown for recent context
- Automatically appended by `session-end.sh`
- Compiled/archived after 1-2 weeks

## Performance Targets

- **Search**: < 100ms (local grep)
- **Synthesis**: < 2 seconds (Claude processes matched content)
- **Index**: < 500ms
- **Status check**: < 1 second

## Integration Points

1. **Session Start**: `session-start.sh` injects L1 into system message
2. **Interactive Queries**: User types `/wiki-query <topic>` in Claude Code
3. **Scheduled Tasks**: Cron job runs `lint.sh` daily, results in status updates
4. **Compilation**: `compile.sh` turns daily logs into permanent L2 articles

## Fallback Behavior

If query yields no results:
- Suggest related searches
- Show list of available pages (`/wiki-query --index`)
- Recommend updating wiki: `/wiki-update --check`
- Example: "No results for 'GraphQL'. Try `/wiki-query --index` to see available pages."
