---
title: "Coding Conventions & Rules"
type: "conventions"
sources: ["CLAUDE.md", "src/", ".eslintrc.js"]
related: ["architecture.md", "known-issues.md"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# Coding Conventions & Rules

## Language & Framework Standards

> TODO: Document language-specific rules and framework conventions

### Example:
- **TypeScript:** No `any` types, use `unknown` + type narrowing
- **React:** Prefer server components; `'use client'` only for interactivity
- **Database:** Never raw SQL strings, use ORM query builders
- **Async:** Always handle Promise rejections, no unhandled rejections

## File Organization

> TODO: Document file naming, folder structure, and import conventions

### Example:
```
src/
  components/[Feature]/
    ComponentName.tsx (exported)
    ComponentName.test.tsx
    styles.module.css (optional)
  
  lib/
    [feature-name].ts (exported)
    __tests__/[feature-name].test.ts
```

## Gotchas & Anti-Patterns

> TODO: List 5–10 common mistakes and how to avoid them

### Example:
| ❌ Problem | ✅ Solution |
|---|---|
| Using `any` type | Use `unknown` + type guards |
| Raw SQL queries | Use ORM query builder |
| Importing `cookies` in client component | Fetch from API instead |
| Not handling null/undefined | Use optional chaining & nullish coalescing |

## Security & Privacy Rules

> TODO: Document authentication, authorization, and data handling standards

### Example:
- No API keys in client code
- Always validate user permissions before returning data
- Hash passwords with [algorithm]
- Don't log personally identifiable information (PII)

## Performance Guidelines

> TODO: Document optimization rules and budgets

### Example:
- Memoize expensive computations with `useMemo`
- Code-split routes with dynamic imports
- Keep main bundle < [size]
- API responses cached for [duration]

## Testing Standards

> TODO: Document testing expectations and patterns

### Example:
- Unit tests for all utils & services
- Integration tests for API routes
- E2E tests for critical user flows
- Target: [coverage %] coverage minimum

## Error Handling

> TODO: Document error handling patterns

### Example:
```
- User-facing errors: [Error type]
- Log errors to: [Service]
- Retry policy: [Details]
- Monitoring: [Service]
```

## Deployment & Environment Rules

> TODO: Document environment variables, config management, and CI/CD rules

### Example:
- Never commit `.env` files
- Feature flags controlled by: [System]
- Deployments triggered by: [Branch / Manual]
- Rollback procedure: [Steps]

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to fill with actual content.
