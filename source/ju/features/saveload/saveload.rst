Save Load
=========

.. contents::
   :local:
   :depth: 2

JU Save Load
------------

Generic save/load system for Unity.

- Uses **Newtonsoft.Json** for serialization.
- Encrypted save file.
- Supports **PC (Editor / Standalone)** and **Android**.
- **Does not support WebGL** due to file read/write limitations.
- Data is divided into **Global** and **Per-Scene** values.

Save File Location
~~~~~~~~~~~~~~~~~~

PC (Editor / Standalone)
........................

Save folder::

    <ProjectRoot>/Saves/

Files:

- ``Save.bin`` – main save file  
- ``Save.backup`` – backup save file

Android
.......

Save folder::

    Application.persistentDataPath/Saves/

Files:

- ``Save.bin``  
- ``Save.backup``

How To
~~~~~~

Set and Get Scene Values
........................

Scene values are stored per scene.  
The **scene name should be obtained dynamically** using ``gameObject.scene.name``.

This avoids:
- Typos
- Broken saves after scene renames
- Hardcoded dependencies

Set a value
...........

.. code-block:: csharp

    using JU.SaveLoad;
    using UnityEngine;

    public class PlayerSaveExample : MonoBehaviour
    {
        void SaveData()
        {
            string sceneName = gameObject.scene.name;

            JUSaveLoad.SetSceneValue(sceneName, "PlayerLife", 100);
            JUSaveLoad.SetSceneValue(sceneName, "PlayerPosition", transform.position);
            JUSaveLoad.SetSceneValue(sceneName, "PlayerRotation", transform.rotation);

            JUSaveLoad.Save();
        }
    }

Get a value
...........

.. code-block:: csharp

    string sceneName = gameObject.scene.name;

    int life = JUSaveLoad.GetSceneValue(sceneName, "PlayerLife", 0);
    Vector3 position = JUSaveLoad.GetSceneValue(sceneName, "PlayerPosition", Vector3.zero);
    Quaternion rotation = JUSaveLoad.GetSceneValue(sceneName, "PlayerRotation", Quaternion.identity);

Try get a value
...............

.. code-block:: csharp

    string sceneName = gameObject.scene.name;

    if (JUSaveLoad.TryGetSceneValue(sceneName, "PlayerLife", out int life))
    {
        Debug.Log(life);
    }

Set and Get Global Values
.........................

Global values are shared between all scenes and do not require a scene name.

.. code-block:: csharp

    JUSaveLoad.SetGlobalValue("Coins", 250);
    JUSaveLoad.Save();

.. code-block:: csharp

    int coins = JUSaveLoad.GetGlobalValue("Coins", 0);

Saving and Loading
~~~~~~~~~~~~~~~~~~

Save
....

.. code-block:: csharp

    JUSaveLoad.Save();

Load
....

Manual loading is usually **not required**.

The save file is automatically loaded when:
- Getting a value
- Setting a value
- Checking if a value exists

Force Load
~~~~~~~~~~

Use this to discard runtime changes and reload data from disk.

.. code-block:: csharp

    JUSaveLoad.Load(force: true);

Delete Save Data
~~~~~~~~~~~~~~~~

Delete a scene value
~~~~~~~~~~~~~~~~~~~~

.. code-block:: csharp

    string sceneName = gameObject.scene.name;
    JUSaveLoad.DeleteSceneValue(sceneName, "PlayerLife");

Delete all data from a scene
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: csharp

    string sceneName = gameObject.scene.name;
    JUSaveLoad.DeleteSceneData(sceneName);

Delete a global value
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: csharp

    JUSaveLoad.DeleteGlobalValue("Coins");

Delete all saves
~~~~~~~~~~~~~~~~

.. code-block:: csharp

    JUSaveLoad.DeleteAllSaves();

Saving Component Data
~~~~~~~~~~~~~~~~~~~~~

You should save **component variables**, not components or GameObjects.

Correct approach
................

.. code-block:: csharp

    using JU.SaveLoad;
    using UnityEngine;

    public class PlayerStats : MonoBehaviour
    {
        public int life;
        public float speed;

        public void Save()
        {
            string sceneName = gameObject.scene.name;

            JUSaveLoad.SetSceneValue(sceneName, "PlayerLife", life);
            JUSaveLoad.SetSceneValue(sceneName, "PlayerSpeed", speed);
            JUSaveLoad.Save();
        }

        public void Load()
        {
            string sceneName = gameObject.scene.name;

            life = JUSaveLoad.GetSceneValue(sceneName, "PlayerLife", 100);
            speed = JUSaveLoad.GetSceneValue(sceneName, "PlayerSpeed", 5f);
        }
    }

Why You Should NOT Save Components or GameObjects
.................................................

- Unity components are not pure data.
- They depend on scene hierarchy and engine state.
- References break during serialization.
- Scenes already recreate GameObjects on load.

Always save **data only**:

- numbers
- strings
- vectors
- enums
- simple structs
- data-only serializable classes

Custom Data Types Support
~~~~~~~~~~~~~~~~~~~~~~~~~

By default, the save system supports common Unity types such as:

- Vector2
- Vector3
- Vector4
- Quaternion
- Primitive types

These types work because they have **custom serialization bridges** registered internally.

Why Custom Types Are Needed
...........................

Newtonsoft.Json cannot serialize some Unity or engine-specific types directly.

To support these types, the system uses:
- Plain data structs (bridge types)
- Custom ``JsonConverter`` implementations

Example: Vector3 Support
........................

Vector3 is not serialized directly.  
Instead, it is converted into a plain data struct.

.. code-block:: csharp

    using UnityEngine;

    namespace JU.SaveLoad.Serialization
    {
        public struct JUVector3
        {
            public float x;
            public float y;
            public float z;

            public JUVector3(Vector3 vector)
            {
                x = vector.x;
                y = vector.y;
                z = vector.z;
            }

            public JUVector3(float x, float y, float z)
            {
                this.x = x;
                this.y = y;
                this.z = z;
            }
        }
    }

A corresponding ``JsonConverter`` handles the conversion between:
- ``Vector3`` → ``JUVector3`` (save)
- ``JUVector3`` → ``Vector3`` (load)

Adding Support for New Types
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To support a new type:

1. Create a **data-only struct or class**
2. Create a **JsonConverter** for that type
3. Register the converter using ``AddTypeConverter``

Registering a converter
.......................

.. code-block:: csharp

    using JU.SaveLoad;
    using Newtonsoft.Json;

    public class SaveSetup
    {
        public static void Setup()
        {
            JUSaveLoad.AddTypeConverter(new MyCustomTypeConverter());
        }
    }

Rules for Custom Types
......................

- Do not reference Unity objects
- Do not store scene or runtime state
- Use only serializable fields

.. _JU Save Load Component:

JU Save Load Component
----------------------

Overview
~~~~~~~~

``JUSaveLoadComponent`` is a **reusable base class** designed to be inherited by
any ``Monobehavior`` that handle save load.

It already contains all the base required to **set and load values**
using the **JU Save Load**, like load data on start, save on destroy and ensure
syncronization during save/load.

You can write your own save/load system for ``Monobehavior`` too, but you need to handle syncronization, keys generation and
save load manually on this case.

``JUSaveLoadComponent`` does **not** contain gameplay logic.
Its responsibility is only to handle *how data is saved and restored*.

Basic Usage
~~~~~~~~~~~

To create a save component:

.. warning::
    Ensure you **DO NOT** have different objects with same components and **SAME NAME** because
    this can result in data loss.

    All objects **MUST HAVE** different names.

.. code-block:: csharp

    using JU.SaveLoad;
    using UnityEngine;

    public class MySaveComponent : JUSaveLoadComponent
    {
        private const string VALUE_KEY = "MyValue";

        public override void Save()
        {
            base.Save();
            SetValue(VALUE_KEY, 42);
        }

        public override void Load()
        {
            base.Load();
            int value = GetValue(VALUE_KEY, 0);
            Debug.Log(value);
        }
    }

Synchronizing data during save load
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All components that inherit from ``JUSaveLoadComponent`` are designed to work
together.
When the save is triggered by ``JUSaveLoadManager.SaveOnFile()``:

- All components execute ``Save()``
- Each component writes its data to ``JUSaveLoad``
- The save file is written only after all components are synchronized

This guarantees that save and load operations remain **synchronized**, even when multiple components are involved.

.. _JU Save Load Manager:

JU Save Load Manager
--------------------

Description
^^^^^^^^^^^

``JUSaveLoadManager`` is a **centralized save coordinator** for the **JU Save Load**.

Its responsibility is to:

- Trigger ``Save()`` on all components that inherit from ``JUSaveLoadComponent``.
- Ensure all data is synchronized before writing the save file
- Write the save file **only once** instead of call ``JUSaveLoad.Save()`` on each component.

When to Use
^^^^^^^^^^^

Use ``JUSaveLoadManager.SaveOnFile()`` when:

- Saving from menus
- Saving on checkpoints
- Saving on application quit
- Saving before scene transitions

JU Save Load Mode Component
---------------------------

By default, all ``JUSaveLoadComponent`` saves on Scene. But it's possible to
save all data globally if necessary adding the ``JUSaveLoadModeComponent`` to some gameObject
(for example: *GameManager*, *SaveManager*, or *LevelManager*) and setting ``Mode`` property to `Scene`.


Save Load Components
--------------------

They are optional utilities designed to simplify common save mechanics.
All components listed below integrate with :ref:`JU Save Load Manager`.

.. contents::
   :local:
   :depth: 1

JU Auto Save
~~~~~~~~~~~

Automatically writes the save file at a fixed time interval.

Usage
.....

1. Add **JU Auto Save** to any active GameObject in the scene  
   (for example: *GameManager*, *SaveManager*, or *LevelManager*)
2. Set the time interval to save.

.. warning::
    Multiple instances are not recommended.

JU Save Point Trigger
~~~~~~~~~~~~~~~~~~~~

Saves the game when the player enters a trigger collider.

This component acts as a **checkpoint system**, writing the save file when
a specific object (usually the player) enters a trigger collider.

Usage
.....

1. Add a **Collider** to a gameObject and enable **Is Trigger**
2. Add **JU Save Point Trigger** to this GameObject
3. Set the **Player Tag** (default: ``Player``) and ensure the player GameObject uses the same tag.

JU Save Load Destroyed Object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This component ensures that once an object is destroyed,
it will **remain destroyed** when the scene is loaded again.

Usage
.....

1. Add **JU Save Load Destroyed Object** to the GameObject
2. Ensure the GameObject has a **unique name** in the scene
