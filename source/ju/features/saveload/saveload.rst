Save Load
=========

Description
-----------

Generic save/load system for Unity.

- Uses **Newtonsoft.Json** for serialization.
- Encrypted save file.
- Supports **PC (Editor / Standalone)** and **Android**.
- **Does not support WebGL** due to file read/write limitations.
- Data is divided into **Global** and **Per-Scene** values.

Save File Location
------------------

PC (Editor / Standalone)
^^^^^^^^^^^^^^^^^^^^^^^

Save folder::

    <ProjectRoot>/Saves/

Files:

- ``Save.bin`` – main save file  
- ``Save.backup`` – backup save file

Android
^^^^^^^

Save folder::

    Application.persistentDataPath/Saves/

Files:

- ``Save.bin``  
- ``Save.backup``

How To
------

Set and Get Scene Values
-----------------------

Scene values are stored per scene.  
The **scene name should be obtained dynamically** using ``gameObject.scene.name``.

This avoids:
- Typos
- Broken saves after scene renames
- Hardcoded dependencies

Set a value
^^^^^^^^^^^

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
^^^^^^^^^^^

.. code-block:: csharp

    string sceneName = gameObject.scene.name;

    int life = JUSaveLoad.GetSceneValue(sceneName, "PlayerLife", 0);
    Vector3 position = JUSaveLoad.GetSceneValue(sceneName, "PlayerPosition", Vector3.zero);
    Quaternion rotation = JUSaveLoad.GetSceneValue(sceneName, "PlayerRotation", Quaternion.identity);

TryGet variant
^^^^^^^^^^^^^^

.. code-block:: csharp

    string sceneName = gameObject.scene.name;

    if (JUSaveLoad.TryGetSceneValue(sceneName, "PlayerLife", out int life))
    {
        Debug.Log(life);
    }

Set and Get Global Values
------------------------

Global values are shared between all scenes and do not require a scene name.

Set a global value
^^^^^^^^^^^^^^^^^^

.. code-block:: csharp

    JUSaveLoad.SetGlobalValue("Coins", 250);
    JUSaveLoad.Save();

Get a global value
^^^^^^^^^^^^^^^^^^

.. code-block:: csharp

    int coins = JUSaveLoad.GetGlobalValue("Coins", 0);

Saving and Loading
------------------

Save
^^^^

.. code-block:: csharp

    JUSaveLoad.Save();

Load
^^^^

Manual loading is usually **not required**.

The save file is automatically loaded when:
- Getting a value
- Setting a value
- Checking if a value exists

Force Load
^^^^^^^^^^

Use this to discard runtime changes and reload data from disk.

.. code-block:: csharp

    JUSaveLoad.Load(force: true);

Delete Save Data
----------------

Delete a scene value
^^^^^^^^^^^^^^^^^^^^

.. code-block:: csharp

    string sceneName = gameObject.scene.name;
    JUSaveLoad.DeleteSceneValue(sceneName, "PlayerLife");

Delete all data from a scene
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: csharp

    string sceneName = gameObject.scene.name;
    JUSaveLoad.DeleteSceneData(sceneName);

Delete a global value
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: csharp

    JUSaveLoad.DeleteGlobalValue("Coins");

Delete all saves
^^^^^^^^^^^^^^^^

.. code-block:: csharp

    JUSaveLoad.DeleteAllSaves();

Saving Component Data
---------------------

You should save **component variables**, not components or GameObjects.

Correct approach
^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
-------------------------

By default, the save system supports common Unity types such as:

- Vector2
- Vector3
- Vector4
- Quaternion
- Primitive types

These types work because they have **custom serialization bridges** registered internally.

Why Custom Types Are Needed
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Newtonsoft.Json cannot serialize some Unity or engine-specific types directly.

To support these types, the system uses:
- Plain data structs (bridge types)
- Custom ``JsonConverter`` implementations

Example: Vector3 Support
^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To support a new type:

1. Create a **data-only struct or class**
2. Create a **JsonConverter** for that type
3. Register the converter using ``AddTypeConverter``

Registering a converter
^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^

- Do not reference Unity objects
- Do not store scene or runtime state
- Use only serializable fields
- Treat custom types as pure data

This keeps the save file stable and engine-independent.

