Health System
=============

JU provides a shared health system composed of two main elements: ``IHealth`` and ``JUHealth``.

``IHealth`` defines how any system should interact with health. It represents a common and safe way
to read, modify, and react to health values, without depending on a specific health implementation.

``JUHealth`` is the default health system provided by JU. It is a implementation of
``IHealth`` and exists to cover common health management needs.

.. warning::

    Custom health systems should **not** be based on ``JUHealth``.
    Instead, they should implement ``IHealth`` directly.

    This ensures that different health systems can coexist and remain compatible
    with all systems that rely on JU.

.. note::
    Any system that needs to interact with health should always communicate through ``IHealth``.
    Direct dependency on ``JUHealth`` should be avoided to keep systems decoupled and interchangeable.

JUHealth Basics
---------------

.. image:: images/juhealth.png

``JUHealth`` is the default health component provided by JU. It represents a traditional health system,
commonly used by characters, enemies, and any object that can receive damage.

It is responsible for controlling the current health value, the maximum health, and determining
whether the object is alive or dead.

Health and Max Health
~~~~~~~~~~~~~~~~~~~~~

JUHealth works with two core values:

- **Health**: the current life amount of the object
- **Max Health**: the maximum life the object can have

Health values are always kept within valid limits, never going below zero or above the maximum.
JUHealth also exposes a normalized health value (from 0 to 1), which is useful for health bars and UI elements, try ``IHealth.NormalizedHealth``.

Invincibility
~~~~~~~~~~~~~

JUHealth supports an **invincibility** state.

When invincibility is enabled, the object still receives damage requests, but no real damage is applied
to its health. This is commonly used for temporary immunity, cutscenes, special abilities, or
grace periods after being hit.

Health Regeneration
~~~~~~~~~~~~~~~~~~~

JUHealth includes an optional **health regeneration** system.

Health regeneration works automatically based on two values:

- A **delay**, which defines how long after the last hit regeneration starts
- A **speed**, which defines how fast health is restored over time

Regeneration only occurs when the object is alive and stops when health reaches the maximum value
or when new damage is received.

Death and Health Reset
~~~~~~~~~~~~~~~~~~~~~~

When health reaches zero, the object is considered dead.

In this state:
- Health regeneration stops
- Death-related events are triggered

JUHealth also allows health to be fully reset, restoring the object to its maximum health and
bringing it back to a living state. This is typically used for respawning or restarting gameplay scenarios.
For this, try call ``IHealth.ResetHealth()``.

Events
~~~~~~

JUHealth exposes several events that allow other systems to react to health changes without directly
controlling the health system.

- **On Damaged**  
  Triggered whenever damage is applied. Useful for hit reactions, visual effects, sounds, and UI feedback.

- **On Death**  
  Triggered when health reaches zero. Commonly used for death logic, animations, or game state changes.

- **On Health Added**  
  Triggered when health is restored. Useful for healing effects and feedback.

- **On Reset Health**  
  Triggered when health is fully reset. Useful for respawn logic and state cleanup.

Using these events allows systems to stay decoupled, reacting to health changes without relying on
a specific health implementation.
