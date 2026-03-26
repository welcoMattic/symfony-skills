# Create a Symfony Controller

Generate a controller following Symfony conventions and best practices.

## Arguments

- Controller name (e.g. `Product`, `ProductController` — normalize to `ProductController`)
- `--crud` — generate full CRUD actions (index, show, new, edit, delete)
- `--api` — generate API-style controller (JSON responses, no templates)

## Conventions

- **Extend `AbstractController`** — always. It provides shortcuts for rendering, redirects, security checks, and form handling. Controllers should be thin (no business logic), so this coupling is acceptable
- **Location:** `src/Controller/`
- **Namespace:** `App\Controller`
- **Use attributes for everything** — routing (`#[Route]`), caching (`#[Cache]`), security (`#[IsGranted]`). Never YAML, never annotations. Configuration belongs where it's used
- **Class attribute:** Always set a route prefix on the class with `#[Route('/prefix', name: 'prefix_')]`
- **Method naming:** `index`, `show`, `new`, `edit`, `delete` for CRUD
- **Route naming:** snake_case, prefixed by entity name (e.g. `product_index`, `product_show`)
- **Dependency injection:** Type-hint services in action method parameters or constructor. Never use `$this->container->get()` — only use the shortcuts provided by `AbstractController` (`$this->render()`, `$this->redirectToRoute()`, etc.)
- **Entity Value Resolver:** Use route parameter auto-mapping to let Symfony fetch the entity and return 404 automatically. Only query manually via repository when the retrieval logic is complex

## Template: Standard Controller

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/prefix', name: 'prefix_')]
class PrefixController extends AbstractController
{
    #[Route('', name: 'index', methods: ['GET'])]
    public function index(): Response
    {
        return $this->render('prefix/index.html.twig');
    }
}

// Entity Value Resolver example — Symfony fetches the entity automatically:
#[Route('/{id}', name: 'show', methods: ['GET'])]
public function show(Product $product): Response
{
    // No need to query the repository — $product is resolved from {id}
    // Returns 404 automatically if not found
    return $this->render('product/show.html.twig', ['product' => $product]);
}
```

## Template: CRUD Controller

For `--crud`, generate all 5 actions:
- `index` — `GET /` — list all
- `show` — `GET /{id}` — show one (use entity type-hint for param converter)
- `new` — `GET|POST /new` — create form
- `edit` — `GET|POST /{id}/edit` — edit form
- `delete` — `POST /{id}/delete` — delete with CSRF token check

Inject the repository via constructor or method parameter. Use `FormType` for new/edit.

## Template: API Controller

For `--api`, return `JsonResponse` instead of rendering templates. Use `#[Route]` with explicit `methods` and use proper HTTP status codes.

## After Creation

- Create matching Twig templates in `templates/<prefix>/` (unless `--api`)
- If CRUD, ensure the related entity and FormType exist — suggest creating them if not
