# symfony-ai-skills

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

| Skill | What it teaches |
|---|---|
| **cli-conventions** | Always prefer `symfony console` over `php bin/console`, detect Symfony CLI availability |
| **configuration** | When to use env vars vs parameters vs constants vs secrets, `app.` prefix convention |
| **templates** | Snake_case naming, underscore-prefixed fragments, AssetMapper over Webpack |

### Code generation (invocable)

| Skill | What it teaches |
|---|---|
| **init** | Scaffold projects with `symfony new`, default directory structure, no bundles for app logic |
| **controller** | Extend `AbstractController`, attributes for routing/security/caching, Entity Value Resolver |
| **entity** | Attributes for Doctrine mapping, class constants for domain values, validation constraints on entities |
| **form** | FormType as PHP classes, buttons in templates not form classes, single action for render + process |
| **command** | `#[AsCommand]`, SymfonyStyle, proper return codes |
| **service** | `final readonly`, autowiring, private services, no bundles, constructor injection |
| **test** | Smoke testing all URLs, hard-coded URLs, right base class per test type |
| **migration** | `diff` over `generate`, review before migrate, never edit executed migrations |
| **voter** | Single firewall, `auto` password hasher, Voters over complex `#[IsGranted]` expressions |
| **event** | `#[AsEventListener]` over subscribers, past-tense naming |
| **api** | API Platform attributes, serialization groups, filters |

## Install

The skill content is **pure markdown** — agent-agnostic. An install script generates the native format for your agent of choice.

```bash
git clone https://github.com/your-username/symfony-ai-skills.git
cd symfony-ai-skills
./install.sh <agent>
```

### Supported agents

| Agent | Command | Result |
|---|---|---|
| [Claude Code](https://claude.ai/code) | `./install.sh claude-code` | Plugin with `/symfony:*` skills |
| [OpenCode](https://github.com/opencode-ai/opencode) | `./install.sh opencode` | Skill with references |
| [Codex](https://github.com/openai/codex) | `./install.sh codex --output .` | `AGENTS.md` |
| [Cursor](https://cursor.sh) | `./install.sh cursor --output .` | `.cursorrules` |
| [Windsurf](https://windsurf.com) | `./install.sh windsurf --output .` | `.windsurfrules` |
| Any other | `./install.sh generic --output .` | `symfony-skills.md` |

See [docs/](docs/) for detailed per-agent instructions.

### Options

| Flag | Description |
|---|---|
| `--project` | Install into the current project instead of globally (Claude Code, OpenCode) |
| `--output <dir>` | Output directory for generated files (Codex, Cursor, Windsurf, generic) |
| `--dry-run` | Preview what would be done without making changes |

## Project structure

```
skills/                     # Source of truth — pure markdown, no agent-specific markup
  _metadata.yaml            # Metadata per skill (name, description, args hint)
  cli-conventions.md
  init.md
  controller.md
  ...
install.sh                  # Reads skills/ + _metadata.yaml, generates native format
dist/                       # Generated output (gitignored)
docs/                       # Per-agent installation guides
```

## Contributing

1. Edit files in `skills/` — that's the single source of truth
2. Update `_metadata.yaml` if adding or removing a skill
3. Run `./install.sh <agent>` to regenerate and test
4. Open a PR

All conventions should be traceable to the [official Symfony documentation](https://symfony.com/doc/current/index.html). If a practice isn't in the docs, it probably shouldn't be here.

## License

MIT
