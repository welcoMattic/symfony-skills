# symfony-ai-skills

Symfony development skills for AI coding agents. One source of truth, multiple agents supported.

## What's inside

12 skills covering the full Symfony development workflow:

| Skill | Description |
|---|---|
| **cli-conventions** | Auto-prefix commands with Symfony CLI (`symfony console`, `symfony composer`, etc.) |
| **init** | Scaffold a new project (`--webapp`, `--api`, `--docker`) |
| **controller** | Create controllers with routes, CRUD, or API style |
| **entity** | Create Doctrine entities with relationships and repositories |
| **form** | Create FormType classes bound to entities |
| **command** | Create console commands with `#[AsCommand]` |
| **service** | Create services with DI, optionally with interface |
| **test** | Generate unit, functional, or integration tests |
| **migration** | Manage Doctrine migrations (diff, migrate, rollback) |
| **voter** | Create security voters for fine-grained authorization |
| **event** | Create events with listeners or subscribers |
| **api** | Configure API Platform resources with filters and serialization groups |

## Supported agents

| Agent | Install method | Skill format |
|---|---|---|
| [Claude Code](https://claude.ai/code) | Plugin with namespaced skills (`/symfony:controller`) | Individual SKILL.md per skill |
| [OpenCode](https://github.com/opencode-ai/opencode) | Skill with references | SKILL.md + references/ |
| [Codex](https://github.com/openai/codex) | AGENTS.md | Single concatenated file |
| [Cursor](https://cursor.sh) | .cursorrules | Single concatenated file |
| [Windsurf](https://windsurf.com) | .windsurfrules | Single concatenated file |
| Any other | Generic markdown | Single concatenated file |

## Quick install

```bash
git clone https://github.com/your-username/symfony-ai-skills.git
cd symfony-ai-skills
./install.sh <agent>
```

See detailed instructions per agent below, or in the [docs/](docs/) folder.

### Claude Code

```bash
./install.sh claude-code
```

This creates a plugin at `~/.claude/skills/symfony/` (symlinked to `dist/claude-code/`).

Then add to your `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "/Users/<you>/.claude/skills/symfony": true
  }
}
```

Restart Claude Code. Skills are available as `/symfony:init`, `/symfony:controller`, etc.

For project-level install:

```bash
./install.sh claude-code --project
```

### OpenCode

```bash
./install.sh opencode
```

This creates a skill at `~/.agents/skills/symfony/` (symlinked to `dist/opencode/`).

Restart OpenCode. The `symfony` skill will be available automatically.

### Codex (OpenAI)

```bash
./install.sh codex --output /path/to/your/project
```

This generates an `AGENTS.md` file in your project root.

### Cursor

```bash
./install.sh cursor --output /path/to/your/project
```

This generates a `.cursorrules` file in your project root.

### Windsurf

```bash
./install.sh windsurf --output /path/to/your/project
```

This generates a `.windsurfrules` file in your project root.

### Generic / Other agents

```bash
./install.sh generic --output /path/to/your/project
```

This generates a `symfony-skills.md` file you can include in any agent's context.

## Options

| Flag | Description |
|---|---|
| `--project` | Install into current project instead of global (Claude Code, OpenCode) |
| `--output <dir>` | Output directory for generated files (Codex, Cursor, Windsurf, generic) |
| `--dry-run` | Preview what would happen without making changes |

## Architecture

```
symfony-ai-skills/
├── skills/                     # Universal source of truth
│   ├── _metadata.yaml          # Skill metadata (name, description, args)
│   ├── cli-conventions.md      # Pure markdown — no agent-specific markup
│   ├── init.md
│   ├── controller.md
│   └── ...
├── install.sh                  # Multi-agent installer
├── dist/                       # Generated (gitignored)
│   ├── claude-code/            # Claude Code plugin
│   └── opencode/               # OpenCode skill
└── docs/                       # Per-agent detailed docs
```

The `skills/` directory contains **pure markdown** — the knowledge itself, with no agent-specific frontmatter or markup. The `install.sh` script reads `_metadata.yaml` for skill metadata and generates the appropriate format for each agent.

## Contributing

1. Edit files in `skills/` (the source of truth)
2. Update `_metadata.yaml` if adding/removing skills
3. Run `./install.sh <agent>` to regenerate
4. Test with your agent

## License

MIT
