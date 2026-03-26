# Windsurf Installation

## Prerequisites

- [Windsurf](https://windsurf.com) installed

## Install

```bash
./install.sh windsurf --output /path/to/your/symfony-project
```

This generates a `.windsurfrules` file at the root of your project. Windsurf reads this file automatically when working in the project directory.

## How it works

All skills are concatenated into a single `.windsurfrules` file with a system preamble. Windsurf loads this as project-level rules, giving it knowledge of Symfony conventions, CLI usage, and code generation patterns.

## Updating

Re-run the install command to regenerate:

```bash
./install.sh windsurf --output /path/to/your/symfony-project
```

## Uninstall

Delete the generated file:

```bash
rm /path/to/your/symfony-project/.windsurfrules
```
