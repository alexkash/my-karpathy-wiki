# 📚 Karpathy Wiki for Claude Code

> Give Claude Code permanent memory. Based on [Andrej Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) methodology.

## The Problem

Every time you open Claude Code, it forgets everything. It re-scans files, asks the same questions, wastes 5-10 minutes and hundreds of tokens just to remember what it already knew yesterday.

## The Solution

A self-updating wiki that **compiles** your project knowledge into markdown files. Three hooks make it fully automatic:

- **Session Start** → Claude instantly knows your project (architecture, rules, current work)
- **Session End** → Session knowledge saved to daily log
- **Pre-Compact** → Context preserved when the window compresses mid-session

No vector databases. No embeddings. No RAG. Just markdown files and hooks.

## Install (One Command)

```bash
cd your-project

# Option A: curl (recommended)
curl -fsSL https://raw.githubusercontent.com/alexkash/my-karpathy-wiki/main/install.sh | bash

# Option B: clone + run
git clone https://github.com/alexkash/my-karpathy-wiki.git /tmp/kwiki
bash /tmp/kwiki/install.sh
rm -rf /tmp/kwiki
```

Then in Claude Code:
```
/wiki-update --bootstrap
```

That's it. Claude scans your codebase and fills the wiki. From now on, every session starts with full context.

## What Gets Installed

```
your-project/
├── .wiki/                          # Knowledge base
│   ├── WIKI.md                     # Schema (rules for Claude)
│   ├── l1-context/                 # Always loaded (~6K tokens)
│   │   ├── overview.md             # What is this project?
│   │   ├── architecture.md         # System design
│   │   ├── conventions.md          # Coding rules & gotchas
│   │   ├── commands.md             # CLI commands
│   │   ├── active-work.md          # Current sprint
│   │   ├── known-issues.md         # Bugs & workarounds
│   │   └── glossary.md             # Domain terms
│   ├── l2-reference/               # On-demand deep dives
│   │   ├── architecture/           # DB, auth, RBAC...
│   │   ├── features/               # Per-feature docs
│   │   ├── api/                    # Endpoint reference
│   │   ├── patterns/               # Code templates
│   │   ├── infrastructure/         # Docker, CI/CD
│   │   └── decisions/              # ADRs
│   └── log/
│       ├── changelog.md            # Update history
│       └── daily/                  # Auto-captured session logs
│
├── .claude/
│   ├── settings.json               # Hook wiring
│   └── commands/
│       ├── wiki-update.md          # /wiki-update command
│       └── wiki-query.md           # /wiki-query command
│
└── scripts/wiki/
    ├── hooks/
    │   ├── session-start.sh        # Load context on startup
    │   ├── session-end.sh          # Save knowledge on exit
    │   └── pre-compact.sh          # Protect from compression
    ├── bootstrap.sh                # Create wiki structure
    ├── compile.sh                  # Daily logs → wiki articles
    ├── lint.sh                     # Health check
    └── query.sh                    # Terminal query
```

## How It Works

### Two-Tier Cache (L1 / L2)

**L1 — Always loaded** (7 files, target <20K tokens): The essential context Claude needs every session. Would a mistake without this knowledge be **dangerous**? → L1.

**L2 — On demand** (unlimited pages, queried when needed): Deep dives loaded only when relevant. Would missing this be **merely inconvenient**? → L2.

### Automatic Lifecycle

```
Open Claude Code
    │
    ▼ SessionStart hook
    L1 context + last daily log → injected into Claude
    │
    You work normally...
    │
    ▼ Context fills up → compact hook
    Saves context → re-injects critical info
    │
    ▼ Close session → SessionEnd hook
    Last 30 messages → .wiki/log/daily/YYYY-MM-DD.md
    │
    ▼ Evening (manual or cron)
    npm run wiki:compile → daily logs become wiki articles
    │
    ▼ Next session → everything is remembered
```

## Commands

### In Claude Code

```
/wiki-update                  Smart incremental (git diff)
/wiki-update --bootstrap      Full initial generation
/wiki-update --full           Complete recompilation
/wiki-update --check          Staleness report
/wiki-update --scope schema   Update schema pages only
/wiki-update --scope recent   Update from recent git changes

/wiki-query authentication    Search for topic
/wiki-query index             List all pages
/wiki-query status            Wiki health
```

### Terminal (without Claude Code)

```bash
npm run wiki:lint              # Health check
npm run wiki:query "RBAC"      # Search wiki
npm run wiki:query -- --index  # List all pages
npm run wiki:compile           # Compile today's logs
npm run wiki:compile:all       # Compile all unprocessed
bash scripts/wiki/bootstrap.sh # Re-scaffold (non-destructive)
```

## Updating an Existing Installation

If you've already installed the wiki and want to pull in hook/script fixes without touching your wiki content:

### Option A: Re-run the installer (recommended)

```bash
cd your-project
curl -fsSL https://raw.githubusercontent.com/alexkash/my-karpathy-wiki/main/install.sh | bash
```

The installer detects that `.wiki/` already exists and **skips wiki content** — it only updates hooks, scripts, and Claude Code commands.

### Option B: Copy hooks manually

```bash
# From a local clone of this repo:
cp hooks/session-start.sh your-project/scripts/wiki/hooks/
cp hooks/session-end.sh   your-project/scripts/wiki/hooks/
cp hooks/pre-compact.sh   your-project/scripts/wiki/hooks/
```

### What gets updated vs. preserved

| Component | Updated | Preserved |
|-----------|---------|-----------|
| `scripts/wiki/hooks/*.sh` | ✅ | — |
| `scripts/wiki/*.sh` | ✅ | — |
| `.claude/commands/wiki-*.md` | ✅ | — |
| `.wiki/WIKI.md` (schema) | ✅ | — |
| `.wiki/l1-context/*.md` | — | ✅ |
| `.wiki/l2-reference/**` | — | ✅ |
| `.wiki/log/` | — | ✅ |

## Requirements

- bash 4.0+
- python3 3.6+
- Claude Code (for /wiki-update and /wiki-query commands)
- Optional: `claude` CLI (for compile.sh auto-synthesis)

## FAQ

**Does it work with any project?**
Yes. The installer detects your stack (Node.js, Python, Go, Rust) from config files. Wiki structure is language-agnostic.

**How much does it cost in tokens?**
L1 context is ~4-6K tokens per session start. That's 10-100x cheaper than Claude re-scanning your codebase every time.

**Can I use it from another project?**
Yes. In any other project's CLAUDE.md, add the path to your wiki:
```markdown
## Knowledge Base
Read .wiki/ at /path/to/main-project/.wiki/ for project context.
```

**Does it replace CLAUDE.md?**
No, it extends it. CLAUDE.md is a static note. The wiki is a living, growing knowledge base that updates itself.

**What if the wiki gets stale?**
Run `npm run wiki:lint` to detect stale pages. Run `/wiki-update` to refresh. Pages not updated in 30+ days auto-degrade to `confidence: low`.

## Credits

- [Andrej Karpathy](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — Original LLM Wiki concept
- [MehmetGoekce/llm-wiki](https://github.com/MehmetGoekce/llm-wiki) — L1/L2 cache architecture
- [toolboxmd/karpathy-wiki](https://github.com/toolboxmd/karpathy-wiki) — Skill-based implementation

## License

MIT
