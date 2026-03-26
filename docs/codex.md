# Codex (OpenAI) Installation

## Prerequisites

- [Codex](https://github.com/openai/codex) installed

## Install

```bash
./install.sh codex --output /path/to/your/symfony-project
```

This generates an `AGENTS.md` file at the root of your project. Codex reads this file automatically when working in the project directory.

## How it works

All skills are concatenated into a single `AGENTS.md` file. Codex loads this as project-level instructions, giving it knowledge of Symfony conventions, CLI usage, and code generation patterns.

## Updating

Re-run the install command to regenerate:

```bash
./install.sh codex --output /path/to/your/symfony-project
```

## Uninstall

Delete the generated file:

```bash
rm /path/to/your/symfony-project/AGENTS.md
```
