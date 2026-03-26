# AI Coding Agent Skills for Symfony

A foundational set of Symfony best practices for AI coding agents.

## Philosophy

This project provides a **minimal, opinionated base** that teaches AI coding agents how to write Symfony code the way the official documentation recommends it. No magic, no shortcuts — just the practices that every Symfony project should follow.

The goal is not to cover every edge case or every bundle. It's to establish a **common foundation** so that when an AI agent generates Symfony code, it produces code that any Symfony developer would recognize as idiomatic:

- PHP 8 attributes everywhere (`#[Route]`, `#[ORM\Column]`, `#[AsCommand]`, etc.) — never annotations, never YAML for things that belong in code
- Symfony CLI as the default entry point when available (`symfony console`, `symfony composer`)
- Constructor injection, autowiring, `final readonly` services
- Doctrine best practices (immutable dates, fluent setters, always a repository)
- Proper test hierarchy (unit / functional / integration with the right base class)

## Skills

### Background knowledge (applied automatically)

| Skill               | What it teaches                                                                         |
|---------------------|-----------------------------------------------------------------------------------------|
| **cli-conventions** | Always prefer `symfony console` over `php bin/console`, detect Symfony CLI availability |
| **configuration**   | When to use env vars vs parameters vs constants vs secrets, `app.` prefix convention    |
| **templates**       | Snake_case naming, underscore-prefixed fragments, AssetMapper over Webpack              |

### Code generation (invocable)

| Skill          | What it teaches                                                                                        |
|----------------|--------------------------------------------------------------------------------------------------------|
| **init**       | Scaffold projects with `symfony new`, default directory structure, no bundles for app logic            |
| **controller** | Extend `AbstractController`, attributes for routing/security/caching, Entity Value Resolver            |
| **entity**     | Attributes for Doctrine mapping, class constants for domain values, validation constraints on entities |
| **form**       | FormType as PHP classes, buttons in templates not form classes, single action for render + process     |
| **command**    | `#[AsCommand]`, SymfonyStyle, proper return codes                                                      |
| **service**    | `final readonly`, autowiring, private services, no bundles, constructor injection                      |
| **test**       | Smoke testing all URLs, hard-coded URLs, right base class per test type                                |
| **migration**  | `diff` over `generate`, review before migrate, never edit executed migrations                          |
| **voter**      | Single firewall, `auto` password hasher, Voters over complex `#[IsGranted]` expressions                |
| **event**      | `#[AsEventListener]` over subscribers, past-tense naming                                               |
| **api**        | API Platform attributes, serialization groups, filters                                                 |

## Install

The skill content is **pure markdown** — agent-agnostic. An installer generates the native format for your agent of choice.

```bash
git clone https://github.com/welcoMattic/symfony-skills.git
cd symfony-skills
```

Two installers are provided — pick whichever fits your setup:

**Bash** (no dependencies):
```bash
./install.sh <agent>
```

**[Castor](https://castor.jolicode.com/)** (PHP 8.2+):
```bash
castor install <agent>
```

### Supported agents

| Agent                                               | Command                            | Result                          |
|-----------------------------------------------------|------------------------------------|---------------------------------|
| [Claude Code](https://claude.ai/code)               | `./install.sh claude-code`         | Plugin with `/symfony:*` skills |
| [OpenCode](https://github.com/opencode-ai/opencode) | `./install.sh opencode`            | Skill with references           |
| [Vibe](https://github.com/mistralai/mistral-vibe)   | `./install.sh vibe`                | Skill with references           |
| [Codex](https://github.com/openai/codex)            | `./install.sh codex --output .`    | `AGENTS.md`                     |
| [Cursor](https://cursor.sh)                         | `./install.sh cursor --output .`   | `.cursorrules`                  |
| [Windsurf](https://windsurf.com)                    | `./install.sh windsurf --output .` | `.windsurfrules`                |
| Any other                                           | `./install.sh generic --output .`  | `symfony-skills.md`             |

### Symfony version support

Skills adapt to your Symfony version. By default, the latest stable (8.0) is used.

```bash
./install.sh claude-code --version 6.4          # Bash
castor install claude-code --symfony=6.4        # Castor
```

| Version | Status                  | Key differences                                 |
|---------|-------------------------|-------------------------------------------------|
| **8.0** | Latest stable (default) | PHP 8.4, attributes, AssetMapper, `readonly class` |
| **7.4** | LTS                     | PHP 8.2, same practices as 8.0                  |
| **6.4** | LTS                     | PHP 8.1, `readonly` properties only (not class) |

See [docs/](docs/) for detailed per-agent instructions.

### Options

| Bash              | Castor              | Description                                                             |
|-------------------|----------------------|-------------------------------------------------------------------------|
| `--version <X.Y>` | `--symfony=<X.Y>`   | Symfony version: `6.4`, `7.4`, `8.0` (default: latest)                 |
| `--project`       | `--project`          | Install into the current project instead of globally                    |
| `--output <dir>`  | `--output=<dir>`     | Output directory for generated files (Codex, Cursor, Windsurf, generic) |
| `--dry-run`       | `--dry-run`          | Preview what would be done without making changes                       |

## Project structure

```
skills/                     # Source of truth for latest version — pure markdown
  _metadata.yaml            # Metadata per skill (name, description, args hint)
  cli-conventions.md
  init.md
  controller.md
  ...
versions/                   # Version-specific overrides (only files that differ)
  6.4/
    service.md              # readonly properties, not class
  7.4/                      # Empty — same as 8.0
install.sh                  # Bash installer (no dependencies)
castor.php                  # Castor installer (PHP 8.2+)
dist/                       # Generated output (gitignored)
docs/                       # Per-agent installation guides
```

The install script resolves each skill by checking `versions/<X.Y>/<skill>.md` first, then falling back to `skills/<skill>.md`.

## Contributing

1. Edit files in `skills/` — that's the single source of truth
2. Update `_metadata.yaml` if adding or removing a skill
3. Run `./install.sh <agent>` to regenerate and test
4. Open a PR

All conventions should be traceable to the [official Symfony documentation](https://symfony.com/doc/current/index.html). If a practice isn't in the docs, it probably shouldn't be here.

