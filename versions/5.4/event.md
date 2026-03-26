# Create a Symfony Event

Generate an event class and its subscriber.

## Arguments

- Event name (e.g. `OrderPlaced`, `UserRegistered`)

## Conventions

- **Events:** `src/Event/` — simple DTO classes
- **Subscribers:** `src/EventSubscriber/` — implement `EventSubscriberInterface`. This is the standard approach in Symfony 5.4 (the `#[AsEventListener]` attribute is not available)
- **Naming:** Past tense for events (`OrderPlaced`, not `PlaceOrder`)

## Template: Event

```php
<?php

namespace App\Event;

use Symfony\Contracts\EventDispatcher\Event;

class OrderPlacedEvent extends Event
{
    private Order $order;

    public function __construct(Order $order)
    {
        $this->order = $order;
    }

    public function getOrder(): Order
    {
        return $this->order;
    }
}
```

## Template: Event Subscriber

```php
<?php

namespace App\EventSubscriber;

use App\Event\OrderPlacedEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class OrderSubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        return [
            OrderPlacedEvent::class => 'onOrderPlaced',
        ];
    }

    public function onOrderPlaced(OrderPlacedEvent $event): void
    {
        $order = $event->getOrder();
        // Handle the event
    }
}
```

## Dispatching

```php
// In a controller or service
$this->eventDispatcher->dispatch(new OrderPlacedEvent($order));
```

## Built-in Symfony Events

Useful kernel events for subscribers:

| Event | Use case |
|---|---|
| `kernel.request` | Authentication, locale detection |
| `kernel.controller` | Pre-action logic |
| `kernel.response` | Headers, caching |
| `kernel.exception` | Error handling |
| `kernel.terminate` | Post-response cleanup |
