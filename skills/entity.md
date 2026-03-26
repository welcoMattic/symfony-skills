# Create a Doctrine Entity

Generate an entity class with its repository following Symfony & Doctrine conventions.

## Arguments

- Entity name (e.g. `Product`)
- Field definitions as `name:type` pairs (e.g. `title:string price:float description:text`)
- `--api` — add API Platform `#[ApiResource]` attribute

## Supported Field Types

| Shorthand | Doctrine type | PHP type |
|---|---|---|
| `string` | `string(255)` | `string` |
| `text` | `text` | `string` |
| `int` / `integer` | `integer` | `int` |
| `float` / `decimal` | `float` | `float` |
| `bool` / `boolean` | `boolean` | `bool` |
| `date` | `date_immutable` | `\DateTimeImmutable` |
| `datetime` | `datetime_immutable` | `\DateTimeImmutable` |
| `json` | `json` | `array` |
| `uuid` | `uuid` (doctrine/uid) | `Uuid` |

## Relationships

If a field type matches an existing entity name, create a relationship:
- `category:Category` → `ManyToOne` (default)
- `tags:Tag[]` → `ManyToMany`
- `comments:Comment[]` → `OneToMany`

Always set the `inversedBy` / `mappedBy` sides properly.

## Conventions

- **Location:** `src/Entity/`
- **Repository:** `src/Repository/<Name>Repository.php` — always generate the matching repository
- **Attributes only** — use PHP 8 attributes (`#[ORM\Entity]`, `#[ORM\Column]`) for all Doctrine mapping. Never annotations, never YAML, never XML. Attributes are the most convenient and agile way to set up mapping
- **ID:** Use auto-increment `id` as primary key by default. Use UUID if the user specifies or for API projects
- **Constants for domain values** — define options that rarely change as class constants. They can be used everywhere (Twig, controllers, other entities), unlike container parameters
- **Timestamps:** If the user mentions timestamps or dates, add `createdAt` and `updatedAt` with `#[ORM\HasLifecycleCallbacks]` and `#[ORM\PrePersist]` / `#[ORM\PreUpdate]`
- **Nullable:** Fields are NOT nullable by default. Only set nullable if explicitly requested
- **Immutable dates:** Always prefer `\DateTimeImmutable` over `\DateTime`
- **Getters/setters:** Generate fluent setters (return `$this`)
- **Validation constraints on the entity** — always add `#[Assert\...]` attributes directly on properties. This way constraints are enforced everywhere the entity is used (forms, API, manual validation)

## Template: Entity

```php
<?php

namespace App\Entity;

use App\Repository\ProductRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: ProductRepository::class)]
class Product
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    // Constants for domain values that rarely change
    public const STATUS_DRAFT = 'draft';
    public const STATUS_PUBLISHED = 'published';
    public const NUM_ITEMS_PER_PAGE = 10;

    #[ORM\Column(length: 255)]
    #[Assert\NotBlank]
    private ?string $name = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }
}
```

## After Creation

1. Generate the repository class
2. Create a migration: `symfony console make:migration`
3. Suggest running: `symfony console doctrine:migrations:migrate`
4. If `--api`, add the `#[ApiResource]` attribute and ensure API Platform is installed
