<?php

use Castor\Attribute\AsArgument;
use Castor\Attribute\AsOption;
use Castor\Attribute\AsTask;

use function Castor\io;
use function Castor\fs;
use function Castor\yaml_parse;

// ─────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────

const SUPPORTED_VERSIONS = ['6.4', '7.4', '8.0'];
const SUPPORTED_AGENTS = ['claude-code', 'opencode', 'vibe', 'codex', 'cursor', 'windsurf', 'generic'];

function skillsDir(): string
{
    return __DIR__ . '/skills';
}

function versionsDir(): string
{
    return __DIR__ . '/versions';
}

function distDir(): string
{
    return __DIR__ . '/dist';
}

// ─────────────────────────────────────────────────────────────
// Metadata helpers
// ─────────────────────────────────────────────────────────────

function loadMetadata(): array
{
    return yaml_parse(file_get_contents(skillsDir() . '/_metadata.yaml'));
}

function listSkills(): array
{
    $meta = loadMetadata();

    return array_keys($meta['skills']);
}

function getSkillMeta(string $skill): array
{
    $meta = loadMetadata();

    return $meta['skills'][$skill] ?? throw new \InvalidArgumentException("Unknown skill: {$skill}");
}

function resolveSkillPath(string $skill, ?string $version): string
{
    if ($version && file_exists(versionsDir() . "/{$version}/{$skill}.md")) {
        return versionsDir() . "/{$version}/{$skill}.md";
    }

    return skillsDir() . "/{$skill}.md";
}

function readSkill(string $skill, ?string $version): string
{
    return file_get_contents(resolveSkillPath($skill, $version));
}

function validateVersion(?string $version): void
{
    if ($version !== null && !in_array($version, SUPPORTED_VERSIONS, true)) {
        throw new \InvalidArgumentException(
            "Unsupported Symfony version '{$version}'. Supported: " . implode(', ', SUPPORTED_VERSIONS)
        );
    }
}

function versionLabel(?string $version): string
{
    return $version ? " (Symfony {$version})" : '';
}

// ─────────────────────────────────────────────────────────────
// Symlink helper
// ─────────────────────────────────────────────────────────────

function createSymlink(string $buildDir, string $target): void
{
    if (is_link($target)) {
        unlink($target);
    } elseif (is_dir($target)) {
        io()->warning("{$target} already exists as a directory. Backing up to {$target}.bak");
        rename($target, "{$target}.bak");
    }

    fs()->mkdir(dirname($target));
    symlink($buildDir, $target);
}

// ─────────────────────────────────────────────────────────────
// Build: SKILL.md with references/ (used by OpenCode and Vibe)
// ─────────────────────────────────────────────────────────────

function buildSkillWithReferences(string $buildDir, ?string $version, bool $inlineAllAuto = false): void
{
    fs()->remove($buildDir);
    fs()->mkdir("{$buildDir}/references");

    // Build main SKILL.md
    $main = "---\nname: symfony\n";
    $main .= "description: Skills for Symfony PHP framework development — project scaffolding, Doctrine entities, controllers, forms, services, tests, and more.\n";
    $main .= "---\n\n";
    $main .= "# Symfony Development Skills\n\n";
    $main .= "Comprehensive knowledge base for Symfony PHP framework development.\n\n";

    // Inline background knowledge
    foreach (listSkills() as $skill) {
        $meta = getSkillMeta($skill);
        $isAuto = ($meta['auto'] ?? false) === true;

        if ($inlineAllAuto && $isAuto) {
            $content = readSkill($skill, $version);
            // Strip the H1 title line
            $lines = explode("\n", $content);
            array_shift($lines);
            $main .= "\n" . implode("\n", $lines) . "\n";
        } elseif (!$inlineAllAuto && $skill === 'cli-conventions') {
            $content = readSkill($skill, $version);
            $lines = explode("\n", $content);
            array_shift($lines);
            $main .= "## CLI Conventions\n" . implode("\n", $lines) . "\n";
        }
    }

    // Reference table for non-auto skills
    $main .= "\n## Skill References\n\n";
    $main .= "| Skill | Description | Reference |\n";
    $main .= "|-------|-------------|----------|\n";

    foreach (listSkills() as $skill) {
        $meta = getSkillMeta($skill);
        $isAuto = ($meta['auto'] ?? false) === true;
        if ($isAuto) {
            continue;
        }
        $desc = trim($meta['description']);
        $main .= "| {$skill} | {$desc} | [{$skill}](references/{$skill}.md) |\n";
    }

    fs()->dumpFile("{$buildDir}/SKILL.md", $main);
    io()->text("  <info>+</info> SKILL.md (main)");

    // Copy each non-auto skill as a reference
    foreach (listSkills() as $skill) {
        $meta = getSkillMeta($skill);
        $isAuto = ($meta['auto'] ?? false) === true;
        if ($isAuto) {
            continue;
        }
        $content = readSkill($skill, $version);
        fs()->dumpFile("{$buildDir}/references/{$skill}.md", $content);
        io()->text("  <info>+</info> references/{$skill}.md");
    }
}

// ─────────────────────────────────────────────────────────────
// Build: concatenated single file (used by Codex, Cursor, Windsurf, generic)
// ─────────────────────────────────────────────────────────────

function buildConcatenatedFile(string $outputFile, string $header, ?string $version): void
{
    $content = $header;

    foreach (listSkills() as $skill) {
        $content .= readSkill($skill, $version);
        $content .= "\n\n---\n\n";
    }

    fs()->mkdir(dirname($outputFile));
    fs()->dumpFile($outputFile, $content);
}

// ─────────────────────────────────────────────────────────────
// Tasks
// ─────────────────────────────────────────────────────────────

#[AsTask(name: 'install', description: 'Install skills for a specific AI coding agent')]
function install(
    #[AsArgument(name: 'agent', description: 'Target agent: claude-code, opencode, vibe, codex, cursor, windsurf, generic')]
    string $agent,
    #[AsOption(name: 'symfony', description: 'Symfony version (6.4, 7.4, 8.0). Default: latest')]
    ?string $symfony = null,
    #[AsOption(name: 'project', description: 'Install into current project instead of globally')]
    bool $project = false,
    #[AsOption(name: 'output', description: 'Output directory (for codex, cursor, windsurf, generic)')]
    ?string $output = null,
    #[AsOption(name: 'dry-run', description: 'Show what would be done without making changes')]
    bool $dryRun = false,
): void {
    if (!in_array($agent, SUPPORTED_AGENTS, true)) {
        io()->error("Unknown agent: {$agent}. Supported: " . implode(', ', SUPPORTED_AGENTS));

        return;
    }

    validateVersion($symfony);

    match ($agent) {
        'claude-code' => installClaudeCode($symfony, $project, $dryRun),
        'opencode' => installOpenCode($symfony, $project, $dryRun),
        'vibe' => installVibe($symfony, $project, $dryRun),
        'codex' => installCodex($symfony, $output ?? '.', $dryRun),
        'cursor' => installCursor($symfony, $output ?? '.', $dryRun),
        'windsurf' => installWindsurf($symfony, $output ?? '.', $dryRun),
        'generic' => installGeneric($symfony, $output ?? '.', $dryRun),
    };
}

// ─────────────────────────────────────────────────────────────
// Agent installers
// ─────────────────────────────────────────────────────────────

function installClaudeCode(?string $version, bool $project, bool $dryRun): void
{
    $target = $project
        ? getcwd() . '/.claude/skills/symfony'
        : $_SERVER['HOME'] . '/.claude/skills/symfony';

    io()->section("Installing for Claude Code" . versionLabel($version));

    if ($dryRun) {
        io()->text("Would create plugin at: <comment>{$target}</comment>");
        io()->text("Would create plugin.json + skills/<name>/SKILL.md for each skill");

        return;
    }

    $buildDir = distDir() . '/claude-code';
    fs()->remove($buildDir);
    fs()->mkdir("{$buildDir}/skills");

    // plugin.json
    $pluginJson = json_encode([
        'name' => 'symfony',
        'description' => 'Skills for Symfony PHP framework development — project scaffolding, Doctrine entities, controllers, forms, services, tests, and more.',
        'version' => '0.1.0',
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n";
    fs()->dumpFile("{$buildDir}/plugin.json", $pluginJson);

    // Generate SKILL.md for each skill
    foreach (listSkills() as $skill) {
        $meta = getSkillMeta($skill);
        $skillDir = "{$buildDir}/skills/{$skill}";
        fs()->mkdir($skillDir);

        $frontmatter = "---\n";
        $frontmatter .= "name: {$meta['name']}\n";
        $frontmatter .= "description: >\n  " . trim($meta['description']) . "\n";
        if (!empty($meta['args'])) {
            $frontmatter .= "argument-hint: \"{$meta['args']}\"\n";
        }
        if (($meta['auto'] ?? false) === true) {
            $frontmatter .= "user-invocable: false\n";
        }
        $frontmatter .= "allowed-tools: Bash, Read, Write, Edit, Glob, Grep\n";
        $frontmatter .= "---\n\n";

        $content = $frontmatter . readSkill($skill, $version);
        fs()->dumpFile("{$skillDir}/SKILL.md", $content);

        io()->text("  <info>+</info> symfony:{$skill}");
    }

    createSymlink($buildDir, $target);

    io()->newLine();
    io()->success("Plugin installed at {$target} → {$buildDir}");
    io()->text("Add this to your <comment>~/.claude/settings.json</comment> under \"enabledPlugins\":");
    io()->text("  <comment>\"{$target}\": true</comment>");
    io()->newLine();
    io()->text("Then restart Claude Code. Skills will be available as /symfony:<name>");
}

function installOpenCode(?string $version, bool $project, bool $dryRun): void
{
    $target = $project
        ? getcwd() . '/.opencode/skills/symfony'
        : $_SERVER['HOME'] . '/.agents/skills/symfony';

    io()->section("Installing for OpenCode" . versionLabel($version));

    if ($dryRun) {
        io()->text("Would create skill at: <comment>{$target}</comment>");
        io()->text("Would create SKILL.md + references/*.md");

        return;
    }

    $buildDir = distDir() . '/opencode';
    buildSkillWithReferences($buildDir, $version, inlineAllAuto: false);
    createSymlink($buildDir, $target);

    io()->newLine();
    io()->success("Skill installed at {$target} → {$buildDir}");
    io()->text("Restart OpenCode to use the symfony skill.");
}

function installVibe(?string $version, bool $project, bool $dryRun): void
{
    $target = $project
        ? getcwd() . '/.vibe/skills/symfony'
        : $_SERVER['HOME'] . '/.vibe/skills/symfony';

    io()->section("Installing for Mistral Vibe" . versionLabel($version));

    if ($dryRun) {
        io()->text("Would create skill at: <comment>{$target}</comment>");
        io()->text("Would create SKILL.md + references/*.md");

        return;
    }

    $buildDir = distDir() . '/vibe';
    buildSkillWithReferences($buildDir, $version, inlineAllAuto: true);
    createSymlink($buildDir, $target);

    io()->newLine();
    io()->success("Skill installed at {$target} → {$buildDir}");
    io()->text("Restart Vibe to use the symfony skill.");
}

function installCodex(?string $version, string $outputDir, bool $dryRun): void
{
    $outputFile = "{$outputDir}/AGENTS.md";

    io()->section("Generating AGENTS.md for Codex" . versionLabel($version));

    if ($dryRun) {
        io()->text("Would create: <comment>{$outputFile}</comment>");

        return;
    }

    $header = "# Symfony Development Guidelines\n\n";
    $header .= "> Auto-generated by [symfony-skills](https://github.com/welcoMattic/symfony-skills)\n\n";

    buildConcatenatedFile($outputFile, $header, $version);
    io()->success("Created {$outputFile}");
}

function installCursor(?string $version, string $outputDir, bool $dryRun): void
{
    $outputFile = "{$outputDir}/.cursorrules";

    io()->section("Generating .cursorrules for Cursor" . versionLabel($version));

    if ($dryRun) {
        io()->text("Would create: <comment>{$outputFile}</comment>");

        return;
    }

    $header = "# Symfony Development Rules\n\n";
    $header .= "You are an expert Symfony PHP developer. Follow these conventions and patterns.\n\n";

    buildConcatenatedFile($outputFile, $header, $version);
    io()->success("Created {$outputFile}");
}

function installWindsurf(?string $version, string $outputDir, bool $dryRun): void
{
    $outputFile = "{$outputDir}/.windsurfrules";

    io()->section("Generating .windsurfrules for Windsurf" . versionLabel($version));

    if ($dryRun) {
        io()->text("Would create: <comment>{$outputFile}</comment>");

        return;
    }

    $header = "# Symfony Development Rules\n\n";
    $header .= "You are an expert Symfony PHP developer. Follow these conventions and patterns.\n\n";

    buildConcatenatedFile($outputFile, $header, $version);
    io()->success("Created {$outputFile}");
}

function installGeneric(?string $version, string $outputDir, bool $dryRun): void
{
    $outputFile = "{$outputDir}/symfony-skills.md";

    io()->section("Generating combined symfony-skills.md" . versionLabel($version));

    if ($dryRun) {
        io()->text("Would create: <comment>{$outputFile}</comment>");

        return;
    }

    $header = "# Symfony Development Skills\n\n";
    $header .= "Comprehensive reference for Symfony PHP framework development.\n";
    $header .= "Generated by [symfony-skills](https://github.com/welcoMattic/symfony-skills)\n\n---\n\n";

    buildConcatenatedFile($outputFile, $header, $version);
    io()->success("Created {$outputFile}");
}
