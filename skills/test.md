# Generate Symfony Tests

Create PHPUnit tests following Symfony testing conventions.

## Arguments

- Class name to test (e.g. `ProductController`, `InvoiceGenerator`)
- `--unit` — unit test (isolated, mocked dependencies)
- `--functional` — functional/HTTP test (`WebTestCase`)
- `--integration` — integration test (`KernelTestCase`)

If no type flag is given, auto-detect:
- Controller → functional test
- Entity → unit test
- Service → unit test (with `--integration` if it has many dependencies)
- Command → functional test
- Repository → integration test

## Conventions

- **Location:** `tests/` mirroring `src/` structure (e.g. `tests/Controller/ProductControllerTest.php`)
- **Naming:** `<ClassName>Test` suffix
- **Base classes:**
  - Unit: `PHPUnit\Framework\TestCase`
  - Functional: `Symfony\Bundle\FrameworkBundle\Test\WebTestCase`
  - Integration: `Symfony\Bundle\FrameworkBundle\Test\KernelTestCase`
- **Methods:** Prefix with `test` (e.g. `testIndex`, `testCreateProduct`) — no `@test` annotation
- **Assertions:** Use specific assertions (`assertResponseIsSuccessful`, `assertSelectorTextContains`) over generic ones
- **Data providers:** Use `#[DataProvider('providerName')]` attribute for parameterized tests

## Template: Functional Test (Controller)

```php
<?php

namespace App\Tests\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class ProductControllerTest extends WebTestCase
{
    public function testIndex(): void
    {
        $client = static::createClient();
        $client->request('GET', '/product');

        $this->assertResponseIsSuccessful();
    }

    public function testShow(): void
    {
        $client = static::createClient();
        $client->request('GET', '/product/1');

        $this->assertResponseIsSuccessful();
    }
}
```

## Template: Unit Test (Service)

```php
<?php

namespace App\Tests\Service;

use App\Service\InvoiceGenerator;
use PHPUnit\Framework\TestCase;

class InvoiceGeneratorTest extends TestCase
{
    public function testGenerate(): void
    {
        $service = new InvoiceGenerator(/* mocked deps */);

        $result = $service->generate($order);

        $this->assertInstanceOf(Invoice::class, $result);
    }
}
```

## Template: Integration Test

```php
<?php

namespace App\Tests\Service;

use App\Service\InvoiceGenerator;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

class InvoiceGeneratorTest extends KernelTestCase
{
    public function testGenerate(): void
    {
        self::bootKernel();
        $service = static::getContainer()->get(InvoiceGenerator::class);

        $result = $service->generate($order);

        $this->assertInstanceOf(Invoice::class, $result);
    }
}
```

## Running Tests

```bash
symfony php bin/phpunit                          # All tests
symfony php bin/phpunit tests/Controller/         # Directory
symfony php bin/phpunit --filter testIndex        # Single test
symfony php bin/phpunit --testdox                 # Human-readable output
```
