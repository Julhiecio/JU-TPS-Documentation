Save Load
=========

Description
-----------

This page provides an overview of the **gameplay state save/load system**
used by **JU TPS**.

The JU TPS save system is built on top of the :doc:`JU Save Load <../../../ju/features/saveload/saveload>` and
uses it to persist gameplay state in a structured and synchronized way.

Before reading this page, it is recommended to understand the base save
infrastructure:

| :ref:`JU Save Load Component`
| :ref:`JU Save Load Manager`

The JU TPS Save Load system is composed of **specialized save components**
that are responsible for storing and restoring the state of some gameplay
systems.

| Each save component:
| - Inherits from :ref:`JU Save Load Component`
| - Saves only **data**, never GameObjects or scene references

Gameplay Save Components
------------------------

Below is a list of available gameplay save components included with JU TPS.

.. contents::
   :local:
   :depth: 2


JU Save Load Armor
~~~~~~~~~~~~~~~~~~

Saves and loads the state of an ``Armor`` component.

| Saved data includes:
| - Armor health enable state
| - Armor protection enable state
| - Current armor health
| - Damage multiplier


JU Save Load Character
~~~~~~~~~~~~~~~~~~~~~

Saves and loads the state of the character controller.

| Saved data includes:
| - World position and rotation
| - Crouch and prone state
| - Equipped item
| - Equipped armors
| - Current vehicle (if driving)


JU Save Load General Item
~~~~~~~~~~~~~~~~~~~~~~~~

Generic save component for ``GeneralHoldableObject``.

| Saved data includes:
| - Unlock state
| - Quantity
| - Maximum quantity


JU Save Load Health
~~~~~~~~~~~~~~~~~~

Saves and loads the state of components implementing ``IHealth``.

| Saved data includes:
| - Current health
| - Maximum health
| - Protection value

JU Save Load Melee Weapon
~~~~~~~~~~~~~~~~~~~~~~~~~

Extends the generic item save logic to support melee weapons.

| Additional saved data:
| - Health usage enable state
| - Weapon health
| - Damage per use

JU Save Load Throwable Item
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Save component for throwable items.

JU Save Load Weapon
~~~~~~~~~~~~~~~~~~~

Save component for gun weapons.

| Additional saved data includes:
| - Magazine size
| - Total bullets
| - Current bullets
| - Shot count per fire
| - Infinite ammo usage
| - Precision and accuracy loss


JU Save Load Wheeled Vehicle
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Saves and loads the state of wheeled vehicles.

| Saved data includes:
| - Vehicle position
| - Vehicle rotation
| - Vehicle velocity (optional)