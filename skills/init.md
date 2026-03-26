# Initialize a New Symfony Project

Create a new Symfony project using the Symfony CLI. Always use the `symfony` binary — it's the recommended way to create new applications.

## Default Directory Structure

Follow the default Symfony directory structure. It's flat, self-explanatory, and not coupled to Symfony:

```
your_project/
├─ assets/
├─ bin/console
├─ config/
│  ├─ packages/
│  ├─ routes/
│  └─ services.yaml
├─ migrations/
├─ public/
│  └─ index.php
├─ src/
│  ├─ Kernel.php
│  ├─ Controller/
│  ├─ Entity/
│  └─ Repository/
├─ templates/
├─ tests/
├─ translations/
├─ var/
│  ├─ cache/
│  └─ log/
└─ vendor/
```

Do not create bundles to organize application logic (no `UserBundle`, `ProductBundle`, etc.). Use PHP namespaces instead.

## Arguments

Parse the user intent and map to the appropriate flags:

| User intent | Command |
|---|---|
| Default (full webapp) | `symfony new <name> --webapp` |
| API / API Platform | `symfony new <name> --api` |
| Microservice / minimal | `symfony new <name>` |
| With Docker support | add `--docker` flag |
| Specific PHP version | add `--php=<version>` flag |

## Steps

1. **Create the project:**

```bash
symfony new <project-name> [flags]
```

Key flags:
- `--webapp` — full web application (Twig, forms, security, ORM, mailer, etc.)
- `--api` — API project with API Platform pre-configured
- `--docker` — include Docker Compose configuration
- `--php=<version>` — specify PHP version (e.g. `8.3`)
- `--version=<version>` — specify Symfony version (e.g. `7.2`, `lts`)

2. **Post-creation checklist:**
   - `cd` into the project directory
   - Verify with `symfony check:requirements`
   - If Docker is used, run `docker compose up -d`
   - Start the dev server: `symfony server:start -d`
   - Show the user the local URL

3. **Report** the created project structure to the user with key directories and next steps.

## Common Additions

Suggest relevant packages based on the project type:

| Need | Package |
|---|---|
| Database ORM | `symfony composer require orm` (included with --webapp) |
| API Platform | `symfony composer require api` |
| Authentication | `symfony composer require security` |
| Admin panel | `symfony composer require admin` (EasyAdmin) |
| Mailer | `symfony composer require mailer` |
| Messenger (async) | `symfony composer require messenger` |
| Debugging | `symfony composer require --dev debug` |
| Testing | `symfony composer require --dev test` |
