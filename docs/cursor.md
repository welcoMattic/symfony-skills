# Cursor Installation

## Prerequisites

- [Cursor](https://cursor.sh) installed

## Install

```bash
./install.sh cursor --output /path/to/your/symfony-project
```

This generates a `.cursorrules` file at the root of your project. Cursor reads this file automatically when working in the project directory.

## How it works

All skills are concatenated into a single `.cursorrules` file with a system preamble. Cursor loads this as project-level rules, giving it knowledge of Symfony conventions, CLI usage, and code generation patterns.

## Updating

Re-run the install command to regenerate:

```bash
./install.sh cursor --output /path/to/your/symfony-project
```

## Uninstall

Delete the generated file:

```bash
rm /path/to/your/symfony-project/.cursorrules
```

## Note

If you already have a `.cursorrules` file, the install will overwrite it. Back up your existing file first, or manually merge the generated content.
