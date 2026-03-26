# OpenCode Installation

## Prerequisites

- [OpenCode](https://github.com/opencode-ai/opencode) installed

## Install

```bash
./install.sh opencode
```

This:
1. Generates an OpenCode skill in `dist/opencode/` with a main `SKILL.md` + `references/` directory
2. Creates a symlink at `~/.agents/skills/symfony` → `dist/opencode/`

## How it works

OpenCode skills use a single `SKILL.md` as entry point with supporting reference files:

```
symfony/
├── SKILL.md                # Main skill — CLI conventions + reference table
└── references/
    ├── init.md
    ├── controller.md
    ├── entity.md
    └── ...
```

The CLI conventions are inlined in the main `SKILL.md` (background knowledge). All other skills are linked as references that OpenCode loads on demand.

## Usage

The symfony skill is automatically available in OpenCode. When working on a Symfony project, OpenCode will use the skill's knowledge to follow conventions and generate proper code.

## Updating

```bash
cd /path/to/symfony-skills
git pull
./install.sh opencode
```

## Uninstall

1. Remove the symlink: `rm ~/.agents/skills/symfony`
2. Remove generated files: `rm -rf dist/opencode/`
