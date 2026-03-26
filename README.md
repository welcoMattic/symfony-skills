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

| Skill | What it teaches |
|---|---|
| **cli-conventions** | Always prefer `symfony console` over `php bin/console`, detect Symfony CLI availability |
| **init** | Scaffold projects with `symfony new` and the right flags |
| **controller** | Routes as attributes, CRUD structure, proper type hints |
| **entity** | Doctrine mappings, relationships, lifecycle callbacks |
| **form** | FormType bound to entities, field type mapping, validation on entities |
| **command** | `#[AsCommand]`, SymfonyStyle, proper return codes |
| **service** | `final readonly`, constructor injection, interface binding |
| **test** | WebTestCase vs KernelTestCase vs TestCase, `#[DataProvider]` |
| **migration** | `diff` over `generate`, review before migrate, never edit executed migrations |
| **voter** | Permission constants, `supports()` + `voteOnAttribute()` pattern |
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
