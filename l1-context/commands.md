---
title: "Essential Commands"
type: "commands"
sources: ["package.json", "Makefile", "scripts/"]
related: ["active-work.md", "conventions.md"]
created: 2025-02-15
updated: 2025-02-15
confidence: low
---

# Essential Commands

## Development

> TODO: Document how to start dev environment and common dev workflows

### Example:
| Command | Purpose | Notes |
|---------|---------|-------|
| `npm run dev` | Start dev server | Port 4000, HMR enabled |
| `npm run dev:debug` | Debug mode | Slower, better logging |
| `npm run dev:restart` | Kill + restart | Use if HMR breaks |

## Database & Schema

> TODO: Document database setup, migrations, and schema management

### Example:
| Command | Purpose | Destructive? |
|---------|---------|---|
| `npm run db:setup` | Initialize local DB | Yes |
| `npm run db:migrate` | Run pending migrations | No |
| `npm run db:seed` | Populate seed data | Yes |
| `npm run db:reset` | Wipe + reinit (nuclear) | Yes |

## Testing

> TODO: Document how to run tests and debug test failures

### Example:
| Command | Purpose |
|---------|---------|
| `npm test` | All unit tests |
| `npm run test:watch` | Watch mode (dev) |
| `npm run test:coverage` | Coverage report |
| `npx playwright test` | E2E tests |
| `npx playwright test --ui` | E2E with visual debug |

## Building & Deployment

> TODO: Document build process and deployment commands

### Example:
| Command | Purpose |
|---------|---------|
| `npm run build` | Production build |
| `npm run build:analyze` | Bundle size analysis |
| `npm run deploy:staging` | Deploy to staging |
| `npm run deploy:prod` | Deploy to production |

## Code Quality

> TODO: Document linting, formatting, and type checking

### Example:
| Command | Purpose | Auto-fix? |
|---------|---------|---|
| `npm run lint` | ESLint check | No |
| `npm run lint:fix` | ESLint + auto-fix | Yes |
| `npm run format` | Prettier format | Yes |
| `npm run type-check` | TypeScript check | No |

## Documentation & Wiki

> TODO: Document wiki maintenance and documentation commands

### Example:
| Command | Purpose |
|---------|---------|
| `npm run wiki:update` | Sync wiki from source |
| `npm run wiki:health-check` | Check for stale pages |
| `npm run wiki:bootstrap` | Initialize wiki in new project |

## Troubleshooting Quick Fixes

> TODO: Document common issues and quick recovery commands

### Example:
| Problem | Command |
|---------|---------|
| Port 4000 in use | `npm run dev:restart` |
| Node modules corrupted | `rm -rf node_modules && npm install` |
| Build failures | `npm run build:clean && npm run build` |
| DB connection issues | `npm run db:reset` (if safe) |

---

> ⚠️ SCAFFOLD — Run `/wiki-update --bootstrap` to fill with actual content.
