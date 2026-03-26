# Doctrine Migrations Management

Manage database schema migrations in a Symfony project.

## Arguments

- `generate` or `diff` — create a new migration from entity changes
- `migrate` — run pending migrations
- `rollback` — revert the last migration
- `status` — show migration status

## Commands

| Action | Command |
|---|---|
| Generate migration from diff | `symfony console doctrine:migrations:diff` |
| Create empty migration | `symfony console doctrine:migrations:generate` |
| Run all pending | `symfony console doctrine:migrations:migrate` |
| Run up to specific version | `symfony console doctrine:migrations:migrate <version>` |
| Rollback last | `symfony console doctrine:migrations:migrate prev` |
| Show status | `symfony console doctrine:migrations:status` |
| List all migrations | `symfony console doctrine:migrations:list` |
| Validate schema | `symfony console doctrine:schema:validate` |

## Best Practices

1. **Always use `diff`** over `generate` — it computes the exact SQL from your entity changes
2. **Review the generated migration** before running it — check the `up()` and `down()` methods
3. **Never edit a migration** that has already been executed in production
4. **Add data migrations** manually when needed (e.g. seeding default values after adding a column)
5. **Test rollback** — make sure `down()` works correctly
6. **In production**, always run with `--no-interaction` and review first:
   ```bash
   symfony console doctrine:migrations:migrate --dry-run
   symfony console doctrine:migrations:migrate --no-interaction
   ```

## Workflow

1. Modify your entity (`src/Entity/`)
2. Generate the migration: `symfony console doctrine:migrations:diff`
3. Review the generated file in `migrations/`
4. Run it: `symfony console doctrine:migrations:migrate`
5. Validate: `symfony console doctrine:schema:validate`

## Troubleshooting

- **"The schema is not in sync"** — run `doctrine:migrations:diff` to generate the missing migration
- **Migration fails** — check the SQL, fix, and if needed create a new corrective migration (never delete an executed migration)
- **Conflict with team** — if two developers created migrations in parallel, re-generate from the current state
