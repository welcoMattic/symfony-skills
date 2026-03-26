# Mistral Vibe CLI Installation

## Prerequisites

- [Mistral Vibe CLI](https://github.com/mistralai/mistral-vibe) installed

## Install (global)

```bash
./install.sh vibe
```

This:
1. Generates a Vibe skill in `dist/vibe/` with a main `SKILL.md` + `references/` directory
2. Creates a symlink at `~/.vibe/skills/symfony` → `dist/vibe/`

## Install (project-level)

```bash
cd /path/to/your/symfony-project
/path/to/symfony-skills/install.sh vibe --project
```

This creates `.vibe/skills/symfony/` in your project. Make sure the project folder is trusted in `~/.vibe/trusted_folders.toml`.

## How it works

Vibe skills follow the [Agent Skills specification](https://agentskills.io/specification) — a `SKILL.md` with YAML frontmatter as entry point, plus supporting reference files:

```
symfony/
├── SKILL.md                # Main skill — background knowledge + reference table
└── references/
    ├── init.md
    ├── controller.md
    ├── entity.md
    └── ...
```

Background knowledge (CLI conventions, configuration, templates) is inlined in the main `SKILL.md`. All other skills are linked as references that Vibe loads on demand.

## Updating

```bash
cd /path/to/symfony-skills
git pull
./install.sh vibe
```

## Uninstall

1. Remove the symlink: `rm ~/.vibe/skills/symfony`
2. Remove generated files: `rm -rf dist/vibe/`
