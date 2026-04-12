---
title: "Glossary & Terminology"
type: "glossary"
sources: ["docs/", "CLAUDE.md", "README.md"]
related: ["overview.md", "architecture.md"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# Glossary & Terminology

## Domain-Specific Terms

> TODO: Document key domain terminology used in the project

| Term | Abbreviation | Definition | Related |
|------|---|---|---|
| [Term] | [Abbr] | [Definition] | [Related terms] |
| [Term] | [Abbr] | [Definition] | [Related terms] |

### Example (to delete):
| Term | Abbreviation | Definition | Related |
|------|---|---|---|
| Entity | - | A database record representing a real-world object | Entity Relationship |
| Schema | - | Database structure defining tables, columns, and constraints | Migration, DDL |
| API | Application Programming Interface | Interface for applications to communicate | REST, gRPC |

## Acronyms & Abbreviations

> TODO: Document acronyms used in codebase and documentation

| Acronym | Full Form | Context | Notes |
|---|---|---|---|
| [Acronym] | [Full form] | [Where used] | [Notes] |

### Example (to delete):
| Acronym | Full Form | Context | Notes |
|---|---|---|---|
| ORM | Object-Relational Mapping | Database layer | Prisma, SQLAlchemy |
| CI/CD | Continuous Integration/Continuous Deployment | DevOps | GitHub Actions, GitLab |
| JWT | JSON Web Token | Authentication | Stateless token-based auth |

## Architecture Patterns

> TODO: Document design patterns used in the project

- **[Pattern Name]:** [Description, where used, file locations]
- **[Pattern Name]:** [Description, where used, file locations]

### Example (to delete):
- **Service Layer:** Encapsulates business logic (see `src/lib/services/`)
- **Middleware Pattern:** Request/response processing in `src/middleware/`
- **Dependency Injection:** Service instantiation via constructor (see `src/lib/di/`)

## Database Concepts

> TODO: Document data model terminology specific to your project

| Concept | Type | Description |
|---|---|---|
| [Entity/Table] | [Type: Core/Reference/Join] | [Purpose] |
| [Entity/Table] | [Type: Core/Reference/Join] | [Purpose] |

### Example (to delete):
| Concept | Type | Description |
|---|---|---|
| User | Core | Represents a person using the system |
| Session | Reference | Tracks active user sessions (auth state) |
| Audit Log | Core | Records all data mutations for compliance |

## API & Integration Terms

> TODO: Document external API and integration terminology

| Term | Service | Endpoint/Purpose | Auth Type |
|---|---|---|---|
| [Term] | [Service name] | [Endpoint or purpose] | [Auth: API key/OAuth/JWT] |

## Feature Flags & Configuration

> TODO: Document feature flag names and configuration options

| Flag/Config | Type | Purpose | Values |
|---|---|---|---|
| [Flag name] | [Feature flag/ENV var/Config] | [What it controls] | [Possible values] |

## Testing Terminology

> TODO: Document testing-specific terms used in test suites

- **[Type of test]:** [Definition, examples]
- **[Test approach]:** [Definition, where used]

### Example (to delete):
- **Unit test:** Tests a single function or class in isolation (use Mocks)
- **Integration test:** Tests multiple components working together (use test database)
- **E2E test:** Tests full user workflows through UI (use Playwright)

## Common Project-Specific Terms

> TODO: Add any other domain-specific language unique to your project

- **[Term]:** [Definition]
- **[Term]:** [Definition]

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to fill with actual content.
