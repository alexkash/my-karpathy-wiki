---
title: "System Architecture"
type: "architecture"
sources: ["src/", "schema/", "docs/architecture.md"]
related: ["overview.md", "l2-reference/architecture/"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# System Architecture

## High-Level System Diagram

> TODO: ASCII diagram or reference to architecture docs

### Example:
```
┌─────────────────────────────────────┐
│       Frontend (React)              │
└──────────────┬──────────────────────┘
               │
        ┌──────▼───────┐
        │   API Layer  │
        │    (tRPC)    │
        └──────┬───────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───▼───┐ ┌───▼───┐ ┌───▼───┐
│ Auth  │ │ Data  │ │ Queue │
│       │ │   DB  │ │       │
└───────┘ └───────┘ └───────┘
```

## Core Services / Layers

> TODO: Document main services and their responsibilities

### Example:
**Service Layer**
- [Service 1]: [What it does]
- [Service 2]: [What it does]

**Data Layer**
- [Datastore 1]: [Schema or purpose]
- [Datastore 2]: [Schema or purpose]

**External Integrations**
- [Integration 1]: [What it connects to, purpose]

## Data Flow

> TODO: Walk through a typical request lifecycle

### Example:
1. User clicks button in UI
2. Client sends tRPC mutation to `/api/trpc`
3. Server validates auth + permissions
4. Database transaction created
5. Changes synced to cache / message queue
6. Response returns to client, UI updates

## Deployment Architecture

> TODO: Document environments and deployment targets

| Environment | Infrastructure | Scale |
|---|---|---|
| Development | Local / Docker | Single machine |
| Staging | [Cloud platform] | [Approximate size] |
| Production | [Cloud platform] | [Approximate scale] |

## Key Decisions & Trade-offs

> TODO: Document why architecture was chosen this way

- **[Decision]**: [Rationale] (see `l2-reference/decisions/` for details)
- **[Decision]**: [Rationale]

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to fill with actual content.
