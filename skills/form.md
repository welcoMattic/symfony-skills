# Create a Symfony FormType

Generate a form type class following Symfony conventions.

## Arguments

- Name (e.g. `Product` → `ProductType`, or `ProductType` directly)
- If an entity with this name exists in `src/Entity/`, bind the form to it

## Conventions

- **Define forms as PHP classes** — always in `src/Form/`, never inline in controllers
- **Location:** `src/Form/`
- **Naming:** Always suffix with `Type` (e.g. `ProductType`)
- **Data class:** Set `data_class` in `configureOptions` when bound to an entity
- **Field types:** Use the most specific type class (e.g. `EmailType`, `MoneyType`, not just `TextType`)
- **Labels:** Do not hardcode labels — let Symfony's translation system handle them
- **Validation on the entity, not the form** — attach `#[Assert\...]` constraints to the entity properties. This way validation is reused wherever the entity is used, not just in this form
- **Buttons belong in templates, not in form classes** — never call `->add('submit', SubmitType::class)` in `buildForm()`. Button labels and CSS classes vary by context (e.g. "Create" vs "Save changes"). The only exception: forms with multiple submit buttons where the controller needs to detect which was clicked
- **Single action for render + process** — use one controller action to both display and handle the form submission. Two separate actions is unnecessary complexity

## Field Type Mapping

Map entity property types to form field types:

| Doctrine type | Form type |
|---|---|
| `string` | `TextType` |
| `text` | `TextareaType` |
| `integer` | `IntegerType` |
| `float` | `NumberType` |
| `boolean` | `CheckboxType` |
| `date_immutable` | `DateType` |
| `datetime_immutable` | `DateTimeType` |
| `json` | `TextareaType` (or custom) |
| `ManyToOne` | `EntityType` |
| `ManyToMany` | `EntityType` with `multiple => true` |

## Template

```php
<?php

namespace App\Form;

use App\Entity\Product;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class ProductType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('name')
            ->add('price')
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Product::class,
        ]);
    }
}
```

## Controller Pattern

Use a single action to render and process the form:

```php
#[Route('/product/new', name: 'product_new', methods: ['GET', 'POST'])]
public function new(Request $request, EntityManagerInterface $em): Response
{
    $product = new Product();
    $form = $this->createForm(ProductType::class, $product);
    $form->handleRequest($request);

    if ($form->isSubmitted() && $form->isValid()) {
        $em->persist($product);
        $em->flush();

        return $this->redirectToRoute('product_index');
    }

    return $this->render('product/new.html.twig', [
        'form' => $form,
    ]);
}
```

In the template, add the submit button:

```twig
{{ form_start(form) }}
    {{ form_widget(form) }}
    <button type="submit" class="btn btn-primary">Create</button>
{{ form_end(form) }}
```

## After Creation

- Add validation constraints on the entity if not already present (`#[Assert\NotBlank]`, `#[Assert\Length]`, etc.)
- Check that the controller handling this form exists
