# Create a Symfony Service

Generate a service class following Symfony conventions with autowiring.

## Arguments

- Service name (e.g. `InvoiceGenerator`)
- `--interface` — also generate an interface and bind it

## Conventions

- **Location:** `src/Service/` (or a domain-specific subdirectory if the project uses DDD-style structure)
- **Injection:** Constructor injection only — never setter injection
- **Typing:** Always type-hint constructor parameters with interfaces when available (e.g. `LoggerInterface`, `EntityManagerInterface`)
- **Autowiring:** Symfony autowires by default — no need to configure `services.yaml` unless binding an interface
- **Final:** Declare classes `final` unless there's a clear need for inheritance
- **Readonly:** Use `readonly` on the class or constructor-promoted properties when applicable (PHP 8.2+)

## Template: Service

```php
<?php

namespace App\Service;

final readonly class InvoiceGenerator
{
    public function __construct(
        private EntityManagerInterface $entityManager,
    ) {
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
final readonly class InvoiceGenerator implements InvoiceGeneratorInterface
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
