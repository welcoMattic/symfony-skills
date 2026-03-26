# Create a Symfony Voter

Generate a security voter for fine-grained access control.

## Arguments

- Entity name to protect (e.g. `Product`)
- Permission names (e.g. `view`, `edit`, `delete`) — defaults to `view`, `edit`, `delete` if not specified

## Conventions

- **Location:** `src/Security/Voter/`
- **Naming:** `<Entity>Voter` (e.g. `ProductVoter`)
- **Constants:** Define permissions as class constants
- **Type safety:** Use `supports()` to narrow down the subject type
- **Return early:** Deny by default — only grant explicitly

## Template

```php
<?php

namespace App\Security\Voter;

use App\Entity\Product;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;
use Symfony\Component\Security\Core\User\UserInterface;

class ProductVoter extends Voter
{
    public const VIEW = 'PRODUCT_VIEW';
    public const EDIT = 'PRODUCT_EDIT';
    public const DELETE = 'PRODUCT_DELETE';

    public function __construct(
        private Security $security,
    ) {
    }

    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::VIEW, self::EDIT, self::DELETE])
            && $subject instanceof Product;
    }

    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();

        if (!$user instanceof UserInterface) {
            return false;
        }

        if ($this->security->isGranted('ROLE_ADMIN')) {
            return true;
        }

        /** @var Product $product */
        $product = $subject;

        return match ($attribute) {
            self::VIEW => $this->canView($product, $user),
            self::EDIT => $this->canEdit($product, $user),
            self::DELETE => $this->canDelete($product, $user),
            default => false,
        };
    }

    private function canView(Product $product, UserInterface $user): bool
    {
        return true;
    }

    private function canEdit(Product $product, UserInterface $user): bool
    {
        return $product->getOwner() === $user;
    }

    private function canDelete(Product $product, UserInterface $user): bool
    {
        return $product->getOwner() === $user;
    }
}
```

## Usage in Controller

```php
// Check authorization
$this->denyAccessUnlessGranted(ProductVoter::EDIT, $product);

// Or in Twig
// {% if is_granted('PRODUCT_EDIT', product) %}
```
