# Create a Symfony Controller

Generate a controller following Symfony conventions and best practices.

## Arguments

- Controller name (e.g. `Product`, `ProductController` — normalize to `ProductController`)
- `--crud` — generate full CRUD actions (index, show, new, edit, delete)
- `--api` — generate API-style controller (JSON responses, no templates)

## Conventions

- **Location:** `src/Controller/`
- **Namespace:** `App\Controller`
- **Routing:** Use PHP 8 attributes (`#[Route]`), never annotations or YAML
- **Class attribute:** Always set a route prefix on the class with `#[Route('/prefix', name: 'prefix_')]`
- **Method naming:** `index`, `show`, `new`, `edit`, `delete` for CRUD
- **Route naming:** snake_case, prefixed by entity name (e.g. `product_index`, `product_show`)
- **Type hints:** Always type-hint `Request`, entities, and return types (`Response`)
- **Entity resolution:** Use `MapEntity` attribute or route parameter auto-mapping

## Template: Standard Controller

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/prefix', name: 'prefix_')]
class PrefixController extends AbstractController
{
    #[Route('', name: 'index', methods: ['GET'])]
    public function index(): Response
    {
        return $this->render('prefix/index.html.twig');
    }
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
