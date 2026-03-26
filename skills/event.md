# Create a Symfony Event

Generate an event class and its listener or subscriber.

## Arguments

- Event name (e.g. `OrderPlaced`, `UserRegistered`)
- `--listener` — generate an EventListener (default)
- `--subscriber` — generate an EventSubscriber

## Conventions

- **Events:** `src/Event/` — extend `Symfony\Contracts\EventDispatcher\Event`
- **Listeners:** `src/EventListener/` — use `#[AsEventListener]` attribute
- **Subscribers:** `src/EventSubscriber/` — implement `EventSubscriberInterface`
- **Naming:** Past tense for events (`OrderPlaced`, not `PlaceOrder`)
- **Listeners vs subscribers** — both are valid, the choice is a matter of personal taste. Listeners with `#[AsEventListener]` are simpler for single-event handling; subscribers are easier to reuse when listening to multiple events

## Template: Event

```php
<?php

namespace App\Event;

use Symfony\Contracts\EventDispatcher\Event;

class OrderPlacedEvent extends Event
{
    public function __construct(
        public readonly Order $order,
    ) {
    }
}
```

## Template: Event Listener (recommended)

```php
<?php

namespace App\EventListener;

use App\Event\OrderPlacedEvent;
use Symfony\Component\EventDispatcher\Attribute\AsEventListener;

#[AsEventListener]
class SendOrderConfirmationListener
{
    public function __invoke(OrderPlacedEvent $event): void
    {
        $order = $event->order;
        // Handle the event
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
        $order = $event->order;
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

Useful kernel events for listeners:

| Event | Use case |
|---|---|
| `kernel.request` | Authentication, locale detection |
| `kernel.controller` | Pre-action logic |
| `kernel.response` | Headers, caching |
| `kernel.exception` | Error handling |
| `kernel.terminate` | Post-response cleanup |
