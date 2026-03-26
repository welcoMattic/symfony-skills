# Twig Templates

Conventions for Twig templates in a Symfony project.

## Naming Conventions

- **Use snake_case** for all template names, directories, and variables — lowercase with underscores
- **Template paths:** `templates/<section>/<action>.html.twig`
- **Examples:**
  - `templates/product/index.html.twig` (not `Product/Index.html.twig`)
  - `templates/user_profile/edit_form.html.twig` (not `UserProfile/EditForm.html.twig`)

## Template Fragments

- **Prefix partial templates with an underscore** — reusable fragments that are included/embedded
- **Examples:**
  - `templates/product/_card.html.twig`
  - `templates/layout/_navigation.html.twig`
  - `templates/form/_caution_message.html.twig`
- **Purpose:** Visually distinguish fragments from full page templates at a glance

## Variables

Use snake_case for all variables passed to templates:

```php
// In controller
return $this->render('product/show.html.twig', [
    'product_list' => $products,      // good
    'is_published' => true,           // good
    // 'productList' => $products,    // bad — camelCase
]);
```

## Template Structure

Follow the standard Twig inheritance pattern:

```twig
{# templates/base.html.twig #}
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Welcome{% endblock %}</title>
    {% block stylesheets %}{% endblock %}
</head>
<body>
    {% block body %}{% endblock %}
    {% block javascripts %}{% endblock %}
</body>
</html>

{# templates/product/index.html.twig #}
{% extends 'base.html.twig' %}

{% block title %}Products{% endblock %}

{% block body %}
    <h1>Products</h1>
    {# ... #}
{% endblock %}
```

## Web Assets

Use **Webpack Encore** to manage CSS, JavaScript, and images. Encore simplifies Webpack configuration and was designed specifically for Symfony applications.

```bash
symfony composer require encore
```

Note: AssetMapper is not available in Symfony 5.4. Webpack Encore is the standard approach for asset management.
