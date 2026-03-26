# Symfony Configuration

How to organize configuration in a Symfony project.

## Three Levels of Configuration

Symfony distinguishes three types of configuration. Use the right one:

### 1. Environment Variables — for infrastructure

Values that change from one machine to another: database credentials, API keys, server host, ports.

- Defined in `.env` (committed, with safe defaults) and `.env.local` (not committed, real values)
- Override per environment with `.env.prod.local`, `.env.test`, etc.
- Access with `%env(DATABASE_URL)%` in YAML config

**Never put application behavior in env vars.**

### 2. Parameters — for application behavior

Values that modify how the application works: email sender address, number of items per page, feature flags.

- Defined in `config/services.yaml` under `parameters:`
- **Always prefix with `app.`** to avoid collisions with Symfony or bundle parameters
- Override per environment in `config/services_dev.yaml`, `config/services_prod.yaml`

```yaml
# config/services.yaml
parameters:
    # Good: short, prefixed, clear
    app.notifications_email: 'noreply@example.com'
    app.items_per_page: 10

    # Bad: too generic, no prefix
    dir: '...'
    email: '...'
```

### 3. Constants — for domain values that rarely change

Values that are intrinsic to the domain and almost never change.

- Defined as PHP class constants on the relevant entity or class
- Can be used everywhere: Twig, Doctrine queries, controllers, services
- Unlike parameters, they don't require the service container

```php
class Post
{
    public const NUM_ITEMS_PER_PAGE = 10;
    public const STATUS_DRAFT = 'draft';
    public const STATUS_PUBLISHED = 'published';
}
```

## Secrets

Use Symfony's secrets management for sensitive values that should never appear in version control:

```bash
symfony console secrets:set DATABASE_PASSWORD
```

Secrets are encrypted and safe to commit. Each environment has its own vault.

## Summary

| What changes | Where to put it | Example |
|---|---|---|
| Per machine | Environment variable (`.env`) | `DATABASE_URL`, `MAILER_DSN` |
| Per environment | Parameter (`services.yaml`) | `app.notifications_email` |
| Almost never | Class constant | `Post::NUM_ITEMS_PER_PAGE` |
| Sensitive | Secret (`secrets:set`) | API keys, passwords |
