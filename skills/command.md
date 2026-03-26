# Create a Symfony Console Command

Generate a console command following Symfony conventions.

## Arguments

- Command name in colon-separated format (e.g. `app:import-users`)
- Optional description

## Conventions

- **Location:** `src/Command/`
- **Naming:** Convert command name to PascalCase + `Command` suffix (e.g. `app:import-users` → `ImportUsersCommand`)
- **Attribute:** Use `#[AsCommand]` attribute (not `configure()` for name/description)
- **Return codes:** Always use `Command::SUCCESS`, `Command::FAILURE`, `Command::INVALID`
- **I/O:** Use `SymfonyStyle` for consistent output formatting
- **Services:** Inject dependencies via constructor (auto-wired)

## Template

```php
<?php

namespace App\Command;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

#[AsCommand(
    name: 'app:command-name',
    description: 'Short description of the command',
)]
class CommandNameCommand extends Command
{
    public function __construct()
    {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addArgument('arg1', InputArgument::REQUIRED, 'Argument description')
            ->addOption('option1', null, InputOption::VALUE_NONE, 'Option description')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        // Command logic here

        $io->success('Done.');

        return Command::SUCCESS;
    }
}
```

## After Creation

- Test the command: `symfony console app:command-name`
- List commands: `symfony console list app`
