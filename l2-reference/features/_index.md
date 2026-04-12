---
title: "Features Reference Index"
type: "feature"
sources: ["src/components/", "src/server/routers/"]
related: ["l1-context/overview.md", "l2-reference/api/_index.md"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# Features Reference Index

This section contains detailed specifications and implementation guides for major features.

## Available Features

> TODO: Add pages as features are documented

### Core Features
- `feature-1.md` — [Feature description]
- `feature-2.md` — [Feature description]
- `feature-3.md` — [Feature description]

### Advanced Features
- `advanced-feature-1.md` — [Feature description]
- `advanced-feature-2.md` — [Feature description]

## Feature Documentation Format

Each feature page includes:

```yaml
---
title: "Feature: [Name]"
type: "feature"
sources: ["src/components/Feature", "src/server/routers/feature"]
related: ["Related features", "API docs"]
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: high|medium|low
---

# Feature: [Name]

## Overview
[One-paragraph description of what the feature does]

## Use Cases
- Use case 1
- Use case 2

## Architecture
[How it's implemented, key components, data flow]

## API
[Relevant API endpoints, request/response formats]

## User Interface
[UI components, screenshots, user workflows]

## Testing
[How to test this feature, test coverage]

## Limitations
[Known limitations, future improvements]
```

## Navigation

**Looking for API docs?** See `l2-reference/api/`.

**Need code patterns?** See `l2-reference/patterns/`.

**Want architectural details?** See `l2-reference/architecture/`.

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to auto-generate feature docs from source.
