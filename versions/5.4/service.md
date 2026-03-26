# Create a Symfony Service

Generate a service class following Symfony conventions with autowiring.

## Arguments

- Service name (e.g. `InvoiceGenerator`)
- `--interface` — also generate an interface and bind it

## Conventions

- **Never create bundles for application logic** — don't make `UserBundle`, `ProductBundle`, etc. Bundles are for reusable standalone software. Use PHP namespaces to organize code
- **Autowiring + autoconfiguration** — rely on them by default. Symfony reads type-hints and injects the right services. Manual `services.yaml` configuration is only needed for edge cases (interface binding, non-standard constructor arguments)
- **Services are private by default** — never fetch a service via `$container->get()`. Always inject via constructor or method arguments. This is enforced by Symfony's default configuration
- **Location:** `src/Service/` (or a domain-specific subdirectory if the project uses DDD-style structure)
- **Injection:** Constructor injection only — never setter injection
- **Typing:** Always type-hint constructor parameters with interfaces when available (e.g. `LoggerInterface`, `EntityManagerInterface`)
- **Final:** Declare classes `final` unless there's a clear need for inheritance
- **No `readonly`** — `readonly` properties require PHP 8.1, `readonly` classes require PHP 8.2. Symfony 5.4 supports PHP 7.2.5+, so do not use these features
- **Configuration format:** When manual service configuration is needed, use YAML (`config/services.yaml`)

## Template: Service

```php
<?php

namespace App\Service;

final class InvoiceGenerator
{
    private EntityManagerInterface $entityManager;

    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }

    public function generate(Order $order): Invoice
    {
        // Service logic here
    }
}
```

## Template: With Interface

If `--interface` is specified, also create:

```php
<?php

namespace App\Service;

interface InvoiceGeneratorInterface
{
    public function generate(Order $order): Invoice;
}
```

And the service implements it:

```php
final class InvoiceGenerator implements InvoiceGeneratorInterface
```

Then add the binding in `config/services.yaml`:

```yaml
services:
    App\Service\InvoiceGeneratorInterface:
        alias: App\Service\InvoiceGenerator
```

## Common Injected Services

| Need | Type-hint |
|---|---|
| Database | `Doctrine\ORM\EntityManagerInterface` |
| Logging | `Psr\Log\LoggerInterface` |
| HTTP client | `Symfony\Contracts\HttpClient\HttpClientInterface` |
| Cache | `Symfony\Contracts\Cache\CacheInterface` |
| Mailer | `Symfony\Component\Mailer\MailerInterface` |
| Router | `Symfony\Component\Routing\RouterInterface` |
| Event dispatcher | `Symfony\Contracts\EventDispatcher\EventDispatcherInterface` |
| Messenger | `Symfony\Component\Messenger\MessageBusInterface` |
