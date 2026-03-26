# Claude Code Installation

## Prerequisites

- [Claude Code](https://claude.ai/code) installed

## Install (global)

```bash
./install.sh claude-code
```

This:
1. Generates a Claude Code plugin in `dist/claude-code/` with `plugin.json` + individual `SKILL.md` files
2. Creates a symlink at `~/.claude/skills/symfony` → `dist/claude-code/`

Then add the plugin to your `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "/Users/<you>/.claude/skills/symfony": true
  }
}
```

## Install (project-level)

```bash
cd /path/to/your/symfony-project
/path/to/symfony-skills/install.sh claude-code --project
```

This creates `.claude/skills/symfony/` in your project. No settings.json change needed — project-level plugins are auto-discovered.

## Usage

After restarting Claude Code, skills are available as slash commands:

```
/symfony:init my-project --webapp --docker
/symfony:controller Product --crud
/symfony:entity Product title:string price:float
/symfony:form Product
/symfony:test ProductController --functional
/symfony:migration diff
/symfony:voter Product view edit delete
/symfony:event OrderPlaced --listener
/symfony:api Product --filters
/symfony:command app:import-users
/symfony:service InvoiceGenerator --interface
```

The `cli-conventions` skill is **not user-invocable** — it runs as background knowledge, automatically instructing Claude to use `symfony console` instead of `php bin/console`, etc.

## Updating

```bash
cd /path/to/symfony-skills
git pull
./install.sh claude-code
```

The symlink ensures Claude Code always reads the latest generated version.

## Uninstall

1. Remove from `settings.json`
2. Remove the symlink: `rm ~/.claude/skills/symfony`
3. Remove generated files: `rm -rf dist/claude-code/`
