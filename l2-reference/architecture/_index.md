---
title: "Architecture Reference Index"
type: "architecture"
sources: ["l1-context/architecture.md"]
related: ["l1-context/overview.md"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# Architecture Reference Index

This section contains deep-dive documentation on system architecture, design patterns, and infrastructure.

## Available Pages

> TODO: Add pages as they're created

### Core Systems
- `data-models.md` — Database schema, relationships, normalization
- `api-layer.md` — REST/gRPC/tRPC routing, request/response flow
- `authentication.md` — Auth mechanisms, session management, JWT
- `authorization.md` — Permission system, RBAC implementation
- `caching-strategy.md` — Cache layers, invalidation, TTL policies

### Infrastructure
- `deployment-architecture.md` — Staging, production, scaling
- `monitoring-observability.md` — Logging, metrics, alerting
- `database-architecture.md` — Sharding, replication, backup strategy
- `message-queue.md` — Event distribution, task queues

### Performance & Optimization
- `performance-targets.md` — Latency budgets, throughput requirements
- `cdn-strategy.md` — Content delivery, edge caching
- `database-optimization.md` — Indexing, query optimization

### Data & Integration
- `data-flow.md` — How data moves through the system
- `external-integrations.md` — Third-party service connections
- `event-streaming.md` — Real-time data pipelines

## Quick Links

**Need to understand how [feature] works?** See the feature docs in `l2-reference/features/`.

**Looking for code patterns?** See `l2-reference/patterns/`.

**Want to know why we made a decision?** See `l2-reference/decisions/`.

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to auto-generate architecture docs from source.
