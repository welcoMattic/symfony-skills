# Symfony CLI Conventions

## Detection

A Symfony project is detected when any of the following exist in the working directory:

- `symfony.lock`
- `bin/console`
- `composer.json` containing `symfony/*` dependencies

## Command Prefixing Rules

When the Symfony CLI (`symfony`) is available on the system, **always** use it as a prefix instead of calling tools directly:

| Instead of | Use |
|---|---|
| `php bin/console <cmd>` | `symfony console <cmd>` |
| `composer <cmd>` | `symfony composer <cmd>` |
| `php -S localhost:8000` | `symfony server:start` |
| `php bin/phpunit` | `symfony php bin/phpunit` |

### Why?

The Symfony CLI automatically:
- Injects the correct PHP version configured for the project
- Sets up environment variables from `.env` files
- Provides TLS support for local development
- Handles Docker service integration (database, mailer, etc.) via exposed env vars

## Checking Symfony CLI Availability

Before using `symfony` as prefix, verify it is installed:

```bash
command -v symfony >/dev/null 2>&1
```

If not available, fall back to direct commands (`php bin/console`, `composer`, etc.) and suggest installing the Symfony CLI.

## Server Management

```bash
symfony server:start -d    # Start in background (daemon)
symfony server:stop         # Stop the server
symfony server:status       # Check status
symfony server:log          # Tail logs
```

## Useful Symfony CLI Commands

```bash
symfony check:requirements         # Check PHP & extension requirements
symfony local:php:list             # List available PHP versions
symfony proxy:start                # Start local proxy for multiple projects
symfony var:export --debug         # Show env vars injected by Symfony CLI
symfony check:security             # Check for known vulnerabilities
```
