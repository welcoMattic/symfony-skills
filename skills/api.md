# Create an API Platform Resource

Expose a Doctrine entity as an API Platform resource.

## Arguments

- Entity name (e.g. `Product`)
- `--graphql` — enable GraphQL support
- `--filters` — add common filters (search, date, order, boolean)

## Prerequisites

Ensure API Platform is installed:

```bash
symfony composer require api
```

## Conventions

- **Attributes:** Use PHP 8 attributes (`#[ApiResource]`), never XML/YAML config
- **Operations:** Be explicit about which operations are exposed
- **Serialization groups:** Always use groups to control input/output fields
- **DTOs:** For complex APIs, prefer Input/Output DTOs over directly exposing entities
- **Pagination:** Enabled by default (30 items) — customize per resource if needed

## Template: Basic API Resource

Add the `#[ApiResource]` attribute to an existing entity:

```php
<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\Put;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Delete;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Attribute\Groups;

#[ApiResource(
    operations: [
        new GetCollection(),
        new Get(),
        new Post(),
        new Put(),
        new Patch(),
        new Delete(),
    ],
    normalizationContext: ['groups' => ['product:read']],
    denormalizationContext: ['groups' => ['product:write']],
    paginationItemsPerPage: 30,
)]
#[ORM\Entity]
class Product
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['product:read'])]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    #[Groups(['product:read', 'product:write'])]
    private ?string $name = null;

    #[ORM\Column]
    #[Groups(['product:read', 'product:write'])]
    private ?float $price = null;
}
```

## Adding Filters

```php
use ApiPlatform\Doctrine\Orm\Filter\SearchFilter;
use ApiPlatform\Doctrine\Orm\Filter\OrderFilter;
use ApiPlatform\Doctrine\Orm\Filter\RangeFilter;
use ApiPlatform\Doctrine\Orm\Filter\BooleanFilter;
use ApiPlatform\Doctrine\Orm\Filter\DateFilter;
use ApiPlatform\Metadata\ApiFilter;

#[ApiFilter(SearchFilter::class, properties: ['name' => 'partial'])]
#[ApiFilter(RangeFilter::class, properties: ['price'])]
#[ApiFilter(OrderFilter::class, properties: ['name', 'price'])]
```

## Validation

Add Symfony validation constraints — API Platform enforces them automatically:

```php
use Symfony\Component\Validator\Constraints as Assert;

#[Assert\NotBlank]
#[Assert\Length(min: 2, max: 255)]
#[Groups(['product:read', 'product:write'])]
private ?string $name = null;
```

## After Creation

1. Check the API docs: `https://localhost:8000/api`
2. Verify operations in the Swagger UI
3. Test with: `curl https://localhost:8000/api/products`
