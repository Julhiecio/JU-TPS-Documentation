Humanoid AI
===========

Overview
--------

The Humanoid AI system is designed exclusively for **humanoid characters** in JUTPS.

This AI framework relies on features that only make sense for human-like characters, such as:

* Character-based movement control
* Directional navigation
* Aiming and look direction
* Melee and ranged attacks
* Jumping logic
* Weapon handling and combat stances

Because of this, the system is **not intended for creatures, vehicles, animals, or non-humanoid entities**.

The AI system is **modular**, where each AI is composed of a set of actions and sensors, allowing the creation of different AI types, such as patrols, soldiers, and NPCs.
It includes **built-in AI models** for common humanoid behaviors and can be extended by creating new variations.

Guide
-----

.. toctree::
    :maxdepth: 1

    models/builtin_models
    how_to/how_to


