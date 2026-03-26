# Initialize a New Symfony Project

Create a new Symfony project using the Symfony CLI.

## Arguments

Parse the user intent and map to the appropriate flags:

| User intent | Command |
|---|---|
| Default (full webapp) | `symfony new <name> --webapp` |
| API / API Platform | `symfony new <name> --webapp` then add API Platform |
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
- `--docker` — include Docker Compose configuration
- `--php=<version>` — specify PHP version (e.g. `8.3`)
- `--version=<version>` — specify Symfony version (e.g. `7.2`, `lts`)

2. **If API project is requested**, after creation add API Platform:

```bash
cd <project-name>
symfony composer require api
```

3. **Post-creation checklist:**
   - `cd` into the project directory
   - Verify with `symfony check:requirements`
   - If Docker is used, run `docker compose up -d`
   - Start the dev server: `symfony server:start -d`
   - Show the user the local URL

4. **Report** the created project structure to the user with key directories and next steps.

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
