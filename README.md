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
| equipStationIds | A list of keys of object ids. Equipping these items will trigger the crafting menu. Crafting stations activated from within your inventory should be registered here. |
| activateStationIds | A list of keys of object ids. Activating these items will trigger the crafting menu. Placed activator crafting stations should be registered here. |
| triggers | A ilst of event ids, allowing you to call the menu for this recipeList by calling `event.trigger("eventId")`. |

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
    equipStationIds = {
      stationId = true,
    },
    activateStationIds = {
      stationId = true
    },
    triggers = {
      "UniqueEventId"
    }
  }
end

manager:addRecipe(newRecipe)
manager:addOnEquipStation(newStationId)
manager:addOnActivateStation(newStationId)
manager:addCustomTrigger(triggerId)
end
```

## Recipes

A recipe represents an item that can be crafted, and describes what is needed to crafted. if the `id` matches a non-carryable object (static, activator etc), crafting the item will immediately place it in the world and allow you to position it. Otherwise, it will be added to your inventory. Items added to your inventory may still be placed as statics if a `placedObject` field is set to a non-carryable object.

### Registering a recipe

You can either include a recipe in your Crafting Manager definition, or add it via `manager:addRecipe`. 

| Parameter | Description |
| --------- | ----------- |
| id | The object ID of the crafted item. If the object is carryable, it will be added to your inventory. Otherwise, it will be placed directly into the world for positioning. |
| description | A description of the item being crafted. |
| materials | A list of materials required to craft this item. |
| timeTaken | Optional. Number of hours taken to craft. If set, the screen will fade out during crafting and this amount of game time will pass. |
| known | Optional (default: false). If set to true, this recipe will be available immediately. Otherwise, it can be learned using `crafting.learnRecipe(craftedObjectId)`. |
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
```

### Learning a Recipe

A recipe can be known by default by passing `known=true` when registering the recipe. Otherwise, you can trigger when the player learns the recipe by calling `crafting.learnRecipe(craftedObjectId)`. Similarly, you can unlearn the recipe by called `crafting.unlearnRecipe(crafedObjectId)`. Recipes are learned and unlearned globally, not tied to specific crafting stations. 

## Crafting Materials

A crafting material represents a list of objects which can be used to fulfill the material requirement of a recipe. So for example, if a recipe requires animal hide, you can register `Animal Hide` as a material, and assign guar, alit, kagouti hide etc as that material. Then, any of those items can be used to craft it.

```lua
crafting.registerMaterial{
  id = "resin",
  name = "Resin",
  ids = {
    "ingred_resin_01", 
  },
}
--Once registered, material is stored on materials table:
local resinMaterial = crafting.materials.resin
--You can add new items to the id list
resinMaterial:addItem("ingred_shalk_resin_01")
```


