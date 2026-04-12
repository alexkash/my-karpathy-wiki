---
title: "Code Patterns Reference Index"
type: "pattern"
sources: ["src/lib/", "src/components/", "src/server/"]
related: ["l1-context/conventions.md", "l1-context/architecture.md"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# Code Patterns Reference Index

This section documents reusable code patterns, architectural patterns, and best practices.

## Available Patterns

> TODO: Add pages as patterns are documented and extracted

### UI Patterns
- `component-composition.md` — Building composable React components
- `form-handling.md` — Forms, validation, submission
- `data-fetching.md` — Loading data, error states, caching
- `state-management.md` — Using hooks, context, global state

### Server Patterns
- `middleware.md` — Request/response middleware, error handling
- `database-queries.md` — Building efficient queries, N+1 avoidance
- `error-handling.md` — Exception handling, logging, user-facing errors
- `validation.md` — Input validation, schema validation

### Architectural Patterns
- `service-layer.md` — Separating business logic from routing
- `repository-pattern.md` — Data access abstraction
- `dependency-injection.md` — Inversion of control
- `event-driven.md` — Event publishing, listening, processing

### Testing Patterns
- `unit-testing.md` — Testing utilities, mocking
- `integration-testing.md` — Testing with databases, external services
- `e2e-testing.md` — Testing user workflows

### Performance Patterns
- `memoization.md` — Caching expensive computations
- `lazy-loading.md` — Code splitting, dynamic imports
- `pagination.md` — Fetching large datasets
- `batching.md` — Combining requests

## Pattern Documentation Format

Each pattern page includes:

```yaml
---
title: "Pattern: [Pattern Name]"
type: "pattern"
sources: ["src/[location]/", "example.ts"]
related: ["Related patterns", "Features using this pattern"]
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: high|medium|low
---

# Pattern: [Pattern Name]

## Problem Statement
[What problem does this pattern solve?]

## Solution Overview
[How does this pattern work?]

## Code Example
[Minimal working example]

## When to Use
[Scenarios where this pattern applies]

## When NOT to Use
[Anti-patterns or scenarios to avoid]

## Pros & Cons
[Advantages and tradeoffs]

## Related Patterns
[Similar or complementary patterns]

## Files Implementing This
[Files/components that use this pattern]
```

## Navigation

**Looking for architectural details?** See `l2-reference/architecture/`.

**Need feature specifications?** See `l2-reference/features/`.

**Want API documentation?** See `l2-reference/api/`.

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to auto-generate pattern docs from source.
