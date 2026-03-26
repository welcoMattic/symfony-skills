#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# symfony-ai-skills installer
# Generates agent-specific formats from universal skill files
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
    cat <<EOF
${BOLD}symfony-ai-skills installer${NC}

Usage: ./install.sh <agent> [options]

Agents:
  claude-code     Install as Claude Code plugin (symlink to ~/.claude/skills/)
  opencode        Install as OpenCode skill (symlink to ~/.agents/skills/)
  codex           Generate AGENTS.md for OpenAI Codex
  cursor          Generate .cursorrules for Cursor
  windsurf        Generate .windsurfrules for Windsurf
  generic         Generate a single combined markdown file

Options:
  --project       Install into current project (default: global/user-level)
  --output <dir>  Custom output directory (for codex/cursor/windsurf/generic)
  --dry-run       Show what would be done without making changes
  -h, --help      Show this help

Examples:
  ./install.sh claude-code                  # Global install for Claude Code
  ./install.sh opencode                     # Global install for OpenCode
  ./install.sh codex --project              # Add AGENTS.md to current project
  ./install.sh cursor --output ~/my-app     # Generate .cursorrules in ~/my-app
  ./install.sh generic --output ./          # Generate combined file here
EOF
    exit 0
}

# ─────────────────────────────────────────────────────────────
# Parse YAML metadata (lightweight, no dependencies)
# ─────────────────────────────────────────────────────────────

# Read a skill's metadata field from _metadata.yaml
# Usage: read_meta <skill_name> <field>
read_meta() {
    local skill="$1" field="$2"
    local in_skill=false value=""

    while IFS= read -r line; do
        # Detect skill section
        if [[ "$line" =~ ^[[:space:]]{2}([a-z-]+):$ ]]; then
            if [[ "${BASH_REMATCH[1]}" == "$skill" ]]; then
                in_skill=true
            else
                in_skill=false
            fi
            continue
        fi

        if $in_skill; then
            # Single-line field: "    field: value"
            if [[ "$line" =~ ^[[:space:]]{4}${field}:[[:space:]]+(.*) ]]; then
                value="${BASH_REMATCH[1]}"
                # Handle YAML multiline ">" continuation
                if [[ "$value" == ">" || "$value" == ">-" ]]; then
                    value=""
                    while IFS= read -r cont; do
                        if [[ "$cont" =~ ^[[:space:]]{6} ]]; then
                            local trimmed="${cont#"${cont%%[![:space:]]*}"}"
                            value="${value:+$value }$trimmed"
                        else
                            break
                        fi
                    done
                fi
                # Strip surrounding quotes
                value="${value#\"}"
                value="${value%\"}"
                echo "$value"
                return
            fi
        fi
    done < "$SKILLS_DIR/_metadata.yaml"
}

# Get list of all skill names from metadata
list_skills() {
    grep -E '^  [a-z]' "$SKILLS_DIR/_metadata.yaml" | sed 's/://;s/^[[:space:]]*//'
}

# ─────────────────────────────────────────────────────────────
# Claude Code: generate plugin structure with SKILL.md files
# ─────────────────────────────────────────────────────────────

install_claude_code() {
    local target="${1:-$HOME/.claude/skills/symfony}"
    local dry_run="${2:-false}"

    echo -e "${BLUE}Installing for Claude Code...${NC}"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  Would create plugin at: ${BOLD}$target${NC}"
        echo "  Would create plugin.json + skills/<name>/SKILL.md for each skill"
        return
    fi

    # Create a build directory inside the repo
    local build_dir="$SCRIPT_DIR/dist/claude-code"
    rm -rf "$build_dir"
    mkdir -p "$build_dir/skills"

    # Generate plugin.json
    cat > "$build_dir/plugin.json" <<'PLUGIN'
{
  "name": "symfony",
  "description": "Skills for Symfony PHP framework development — project scaffolding, Doctrine entities, controllers, forms, services, tests, and more.",
  "version": "0.1.0"
}
PLUGIN

    # Generate SKILL.md for each skill
    for skill in $(list_skills); do
        local skill_dir="$build_dir/skills/$skill"
        mkdir -p "$skill_dir"

        local name description args auto
        name=$(read_meta "$skill" "name")
        description=$(read_meta "$skill" "description")
        args=$(read_meta "$skill" "args")
        auto=$(read_meta "$skill" "auto")

        {
            echo "---"
            echo "name: $name"
            echo "description: >"
            echo "  $description"
            if [[ -n "$args" ]]; then
                echo "argument-hint: \"$args\""
            fi
            if [[ "$auto" == "true" ]]; then
                echo "user-invocable: false"
            fi
            echo "allowed-tools: Bash, Read, Write, Edit, Glob, Grep"
            echo "---"
            echo ""
            cat "$SKILLS_DIR/$skill.md"
        } > "$skill_dir/SKILL.md"

        echo -e "  ${GREEN}+${NC} symfony:$skill"
    done

    # Create symlink
    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -d "$target" ]]; then
        echo -e "  ${YELLOW}Warning: $target already exists as a directory. Backing up to ${target}.bak${NC}"
        mv "$target" "${target}.bak"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$build_dir" "$target"

    echo ""
    echo -e "${GREEN}Done!${NC} Plugin installed at $target → $build_dir"
    echo ""
    echo -e "Add this to your ${BOLD}~/.claude/settings.json${NC} under \"enabledPlugins\":"
    echo -e "  ${BOLD}\"$target\": true${NC}"
    echo ""
    echo "Then restart Claude Code. Skills will be available as /symfony:<name>"
}

# ─────────────────────────────────────────────────────────────
# OpenCode: generate skill with SKILL.md + references/
# ─────────────────────────────────────────────────────────────

install_opencode() {
    local target="${1:-$HOME/.agents/skills/symfony}"
    local dry_run="${2:-false}"

    echo -e "${BLUE}Installing for OpenCode...${NC}"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  Would create skill at: ${BOLD}$target${NC}"
        echo "  Would create SKILL.md + references/*.md"
        return
    fi

    local build_dir="$SCRIPT_DIR/dist/opencode"
    rm -rf "$build_dir"
    mkdir -p "$build_dir/references"

    # Build the main SKILL.md — aggregated overview + reference table
    {
        echo "---"
        echo "name: symfony"
        echo "description: Skills for Symfony PHP framework development — project scaffolding, Doctrine entities, controllers, forms, services, tests, and more."
        echo "---"
        echo ""
        echo "# Symfony Development Skills"
        echo ""
        echo "Comprehensive knowledge base for Symfony PHP framework development."
        echo ""

        # Include cli-conventions inline (background knowledge)
        echo "## CLI Conventions"
        echo ""
        cat "$SKILLS_DIR/cli-conventions.md" | tail -n +3
        echo ""

        # Reference table for other skills
        echo "## Skill References"
        echo ""
        echo "| Skill | Description | Reference |"
        echo "|-------|-------------|-----------|"
        for skill in $(list_skills); do
            if [[ "$skill" == "cli-conventions" ]]; then continue; fi
            local description
            description=$(read_meta "$skill" "description")
            echo "| $skill | $description | [${skill}](references/${skill}.md) |"
        done
    } > "$build_dir/SKILL.md"

    echo -e "  ${GREEN}+${NC} SKILL.md (main)"

    # Copy each skill as a reference file
    for skill in $(list_skills); do
        if [[ "$skill" == "cli-conventions" ]]; then continue; fi
        cp "$SKILLS_DIR/$skill.md" "$build_dir/references/$skill.md"
        echo -e "  ${GREEN}+${NC} references/$skill.md"
    done

    # Create symlink
    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -d "$target" ]]; then
        echo -e "  ${YELLOW}Warning: $target already exists. Backing up to ${target}.bak${NC}"
        mv "$target" "${target}.bak"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$build_dir" "$target"

    echo ""
    echo -e "${GREEN}Done!${NC} Skill installed at $target → $build_dir"
    echo "Restart OpenCode to use the symfony skill."
}

# ─────────────────────────────────────────────────────────────
# Codex: generate AGENTS.md
# ─────────────────────────────────────────────────────────────

install_codex() {
    local output_dir="${1:-.}"
    local dry_run="${2:-false}"
    local output_file="$output_dir/AGENTS.md"

    echo -e "${BLUE}Generating AGENTS.md for Codex...${NC}"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  Would create: ${BOLD}$output_file${NC}"
        return
    fi

    mkdir -p "$output_dir"

    {
        echo "# Symfony Development Guidelines"
        echo ""
        echo "> Auto-generated by [symfony-ai-skills](https://github.com/your-username/symfony-ai-skills)"
        echo ""
        for skill in $(list_skills); do
            cat "$SKILLS_DIR/$skill.md"
            echo ""
            echo "---"
            echo ""
        done
    } > "$output_file"

    echo -e "${GREEN}Done!${NC} Created $output_file"
}

# ─────────────────────────────────────────────────────────────
# Cursor: generate .cursorrules
# ─────────────────────────────────────────────────────────────

install_cursor() {
    local output_dir="${1:-.}"
    local dry_run="${2:-false}"
    local output_file="$output_dir/.cursorrules"

    echo -e "${BLUE}Generating .cursorrules for Cursor...${NC}"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  Would create: ${BOLD}$output_file${NC}"
        return
    fi

    mkdir -p "$output_dir"

    {
        echo "# Symfony Development Rules"
        echo ""
        echo "You are an expert Symfony PHP developer. Follow these conventions and patterns."
        echo ""
        for skill in $(list_skills); do
            cat "$SKILLS_DIR/$skill.md"
            echo ""
            echo "---"
            echo ""
        done
    } > "$output_file"

    echo -e "${GREEN}Done!${NC} Created $output_file"
}

# ─────────────────────────────────────────────────────────────
# Windsurf: generate .windsurfrules
# ─────────────────────────────────────────────────────────────

install_windsurf() {
    local output_dir="${1:-.}"
    local dry_run="${2:-false}"
    local output_file="$output_dir/.windsurfrules"

    echo -e "${BLUE}Generating .windsurfrules for Windsurf...${NC}"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  Would create: ${BOLD}$output_file${NC}"
        return
    fi

    mkdir -p "$output_dir"

    {
        echo "# Symfony Development Rules"
        echo ""
        echo "You are an expert Symfony PHP developer. Follow these conventions and patterns."
        echo ""
        for skill in $(list_skills); do
            cat "$SKILLS_DIR/$skill.md"
            echo ""
            echo "---"
            echo ""
        done
    } > "$output_file"

    echo -e "${GREEN}Done!${NC} Created $output_file"
}

# ─────────────────────────────────────────────────────────────
# Generic: single combined markdown
# ─────────────────────────────────────────────────────────────

install_generic() {
    local output_dir="${1:-.}"
    local dry_run="${2:-false}"
    local output_file="$output_dir/symfony-skills.md"

    echo -e "${BLUE}Generating combined symfony-skills.md...${NC}"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  Would create: ${BOLD}$output_file${NC}"
        return
    fi

    mkdir -p "$output_dir"

    {
        echo "# Symfony Development Skills"
        echo ""
        echo "Comprehensive reference for Symfony PHP framework development."
        echo "Generated by [symfony-ai-skills](https://github.com/your-username/symfony-ai-skills)"
        echo ""
        echo "---"
        echo ""
        for skill in $(list_skills); do
            cat "$SKILLS_DIR/$skill.md"
            echo ""
            echo "---"
            echo ""
        done
    } > "$output_file"

    echo -e "${GREEN}Done!${NC} Created $output_file"
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

AGENT=""
PROJECT=false
OUTPUT=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        claude-code|opencode|codex|cursor|windsurf|generic)
            AGENT="$1"; shift ;;
        --project)
            PROJECT=true; shift ;;
        --output)
            OUTPUT="$2"; shift 2 ;;
        --dry-run)
            DRY_RUN=true; shift ;;
        -h|--help)
            usage ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}" >&2
            usage ;;
    esac
done

if [[ -z "$AGENT" ]]; then
    echo -e "${RED}Error: no agent specified${NC}"
    echo ""
    usage
fi

case "$AGENT" in
    claude-code)
        if $PROJECT; then
            install_claude_code "./.claude/skills/symfony" "$DRY_RUN"
        else
            install_claude_code "$HOME/.claude/skills/symfony" "$DRY_RUN"
        fi
        ;;
    opencode)
        if $PROJECT; then
            install_opencode "./.opencode/skills/symfony" "$DRY_RUN"
        else
            install_opencode "$HOME/.agents/skills/symfony" "$DRY_RUN"
        fi
        ;;
    codex)
        install_codex "${OUTPUT:-.}" "$DRY_RUN"
        ;;
    cursor)
        install_cursor "${OUTPUT:-.}" "$DRY_RUN"
        ;;
    windsurf)
        install_windsurf "${OUTPUT:-.}" "$DRY_RUN"
        ;;
    generic)
        install_generic "${OUTPUT:-.}" "$DRY_RUN"
        ;;
esac
