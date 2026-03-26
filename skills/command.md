# Create a Symfony Console Command

Generate a console command following Symfony conventions.

## Arguments

- Command name in colon-separated format (e.g. `app:import-users`)
- Optional description

## Conventions

- **Location:** `src/Command/`
- **Naming:** Convert command name to PascalCase + `Command` suffix (e.g. `app:import-users` → `ImportUsersCommand`)
- **Attribute:** Use `#[AsCommand]` attribute (not `configure()` for name/description)
- **Invokable commands:** Use `__invoke()` as the entry point — this is the modern pattern. The class does not need to extend `Command`. `SymfonyStyle` and other services can be injected directly as parameters
- **Return codes:** Always use `Command::SUCCESS`, `Command::FAILURE`, `Command::INVALID`
- **Services:** Inject dependencies via `__invoke()` parameters or constructor (auto-wired)

## Template

```php
<?php

namespace App\Command;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Attribute\Argument;
use Symfony\Component\Console\Attribute\Option;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

#[AsCommand(
    name: 'app:command-name',
    description: 'Short description of the command',
)]
class CommandNameCommand
{
    public function __invoke(
        #[Argument('Argument description')] string $arg1,
        InputInterface $input,
        OutputInterface $output,
    ): int {
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
