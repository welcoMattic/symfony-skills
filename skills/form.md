# Create a Symfony FormType

Generate a form type class following Symfony conventions.

## Arguments

- Name (e.g. `Product` → `ProductType`, or `ProductType` directly)
- If an entity with this name exists in `src/Entity/`, bind the form to it

## Conventions

- **Location:** `src/Form/`
- **Naming:** Always suffix with `Type` (e.g. `ProductType`)
- **Data class:** Set `data_class` in `configureOptions` when bound to an entity
- **Field types:** Use the most specific type class (e.g. `EmailType`, `MoneyType`, not just `TextType`)
- **Labels:** Do not hardcode labels — let Symfony's translation system handle them
- **Validation:** Prefer constraints on the entity (`#[Assert\...]`) over form-level validation

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

## After Creation

- Add validation constraints on the entity if not already present
- Check that the controller handling this form exists
