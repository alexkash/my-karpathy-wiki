---
title: "API Reference Index"
type: "api"
sources: ["src/server/routers/", "src/lib/trpc.ts"]
related: ["l1-context/architecture.md", "l2-reference/features/_index.md"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# API Reference Index

This section documents all public API endpoints, request/response formats, authentication, and error handling.

## Available Endpoints

> TODO: Add pages as APIs are documented

### Public Endpoints
- `authentication.md` — Login, logout, token refresh
- `users.md` — User profile, settings, preferences
- `resources.md` — Core resource operations (CRUD)

### Internal APIs (Microservices)
- `internal-service-1.md` — [Service description]
- `internal-service-2.md` — [Service description]

## API Documentation Format

Each API page includes:

```yaml
---
title: "API: [Endpoint Group Name]"
type: "api"
sources: ["src/server/routers/[module]"]
related: ["Related API docs", "Features using this API"]
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: high|medium|low
---

# API: [Endpoint Group Name]

## Base URL
[http://localhost:4000/api/v1 or similar]

## Authentication
[Required headers, token format, session management]

## Endpoints

### GET /endpoint
[Description]
- **Parameters:** [Query/path params]
- **Response:** [Success response example]
- **Errors:** [Possible error codes]
- **Rate Limit:** [If applicable]

### POST /endpoint
[Description]
[Similar structure]

## Common Response Formats
[Standard envelope, metadata, error handling]

## Authentication & Authorization
[How to authenticate, permission requirements]

## Rate Limiting
[If applicable, limits and reset windows]

## Examples
[Code examples for common workflows]
```

## Quick Reference

### Common Status Codes
| Code | Meaning | Typical Cause |
|------|---------|---|
| 200 | OK | Request succeeded |
| 400 | Bad Request | Invalid parameters |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Unexpected error |

## Navigation

**Looking for feature details?** See `l2-reference/features/`.

**Need code patterns?** See `l2-reference/patterns/`.

**Want to understand the architecture?** See `l2-reference/architecture/`.

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to auto-generate API docs from source.
