# The Crafting Framework
A crafting framework for Morrowind, allowing other mods to register recipes, crafting materials and crafting stations.

Recipes are registered to a RecipeList, which is usually associated with a crafting station. 

## Crafting Manager

A crafting manager is an object that is used to manage a specific set of crafting stations and the recipes assigned to them.

| Methods | Description |
| ------- | ----------- |
| addRecipe(newRecipe) | Add a new recipe to the manager. |
| addOnEquipStation(newStationId) | Add a new equippable crafting station to the manager. | 
| addOnActivateStation(newStationId) | Add a new activatable crafting station to the manager. |
| addCustomTrigger(triggerId) | Add a new trigger event to the manager. |

### Registering a Crafting Manager

Register a new Crafting Manager with `crafting.registerCraftingManager()`:

| Parameter | Description |
| --------- | ----------- |
| id | Id of the crafting manager. Retrieve an existing crafting manager with `crafting.getManager(id)`. |
| name | Name that appears on the Crafting Menu when this manager is used. |
| recipes   | A list of recipes that will appear (if known) when the menu is activated. |
| onEquipStations | A list of keys of object ids. Equipping these items will trigger the crafting menu. Crafting stations activated from within your inventory should be registered here. |
| onActivateStations | A list of keys of object ids. Activating these items will trigger the crafting menu. Placed activator crafting stations should be registered here. |
| customTrigger | A string of an event id, allowing you to call the menu for this recipeList by calling `event.trigger("eventId")`. |

### Example:

```lua
local crafting = include("craftingFramework.interop")
if crafting then
  local manager = crafting.registerManager{
    id = "ManagerId",
    name = "Crafting Station",
    recipes = {
      --list of recipes goes here
    },
    onEquipStations = {
      equippableStationId = true,
    },
    onActivateStations = {
      activateableStationId = true
    },
    customTrigger = "UniqueEventId"
  }

manager:addRecipe(newRecipe)
manager:addOnEquipStation(newStationId)
manager:addOnActivateStation(newStationId)
manager:addCustomTrigger(triggerId)
end
```

## Recipes

A recipe represents an item that can be crafted, and describes what is needed to crafted. if the `id` matches a non-carryable object (static, activator etc), crafting the item will immediately place it in the world and allow you to position it. Otherwise, it will be added to your inventory. Items added to your inventory may still be placed as statics if a `placedObject` field is set to a non-carryable object.

| Parameter | Description |
| --------- | ----------- |
| id | The object ID of the crafted item. If the object is carryable, it will be added to your inventory. Otherwise, it will be placed directly into the world for positioning. |
| description | A description of the item being crafted. |
| materials | A list of materials required to craft this item. |
| timeTaken | Optional. Number of hours taken to craft. If set, the screen will fade out during crafting and this amount of game time will pass. |
| knownByDefault | Optional (default: false). If set to true, this recipe will be available immediately. Otherwise, it will check whether the recipe has been learned usng `crafting.learnRecipe(craftedObjectId)`. |
| placedObject | Optional. Only valid when `id` matches a carryable object. When set, placing the crafted object down in the world will automtaically convert it to the `placedObject` static. Activating this static will open a menu that will let you pick it back up. |
| menuOptions | A list of buttons that will be added to the placed static's menu in addition to the "Pick up" and "Cancel" buttons. |


### Example

```lua
local recipe = {
    id  = "alchemyTable_misc",
    description = "A rope spun from plant fibres that can be used in more advanced crafting recipes.",
    materials = {
        { material = crafting.materials.fibre, count = 2 }
    },
    timeTaken = 0.25, --hours. Optional,
    knownByDefault = true, --if false, checks `tes3.player.data.craftingFramework.recipes["alchemyTable_misc"].known`
    placedObject = "alchemyTable_static", --if set, dropping the misc item will automatically place it as a positionable static.
    menuOptions = {
      { text = "Open Alchemy Menu", callback = function() alchemy.openAlchemyMenu() end }
    }
},
```

## Materials
