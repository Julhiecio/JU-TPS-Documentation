AI Sensors
==========

Overview
--------

**AI Sensors** are responsible for **gathering information about the world** around the AI.

They do **not control movement or behavior**.
Instead, sensors observe the environment and provide data that can be used by the AI logic and actions to make decisions.

This separation keeps perception and behavior clearly decoupled.

What Sensors Do
***************

At a high level, sensors:

- Detect elements in the environment (targets, sounds, etc.)
- Trigger events when something relevant is detected

The AI controller decides **how to react** to sensor data.

Available Sensors
-----------------

Each sensor is documented in its own page.

.. toctree::
    :maxdepth: 1

    field_of_view/field_of_view_sensor
    hear/hear_sensor
