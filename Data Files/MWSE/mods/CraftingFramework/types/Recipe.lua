---@meta

---@class craftingFrameworkMaterialRequirement
---@field material string **Required.** The Crafting Framework id of the required material.
---@field count number *Default*: `1`. The required amount of the material.

---@class craftingFrameworkRecipeData
---@field id string
---@field description string
---@field craftable craftingFrameworkCraftableData
---@field materials table<number, craftingFrameworkMaterialRequirement>
---@field timeTaken string
---@field knownByDefault boolean
---@field customRequirements table<number, craftingFrameworkCustomRequirementData>
---@field skillRequirements table<number, craftingFrameworkSkillRequirementData>
---@field tools table<number, craftingFrameworkToolRequirementData>
---@field category string
---@field mesh string

---@class craftingFrameworkRecipe
---@field id string This is the unique identifier used internally by Crafting Framework to identify this `recipe`.
---@field description string The description of the recipe. Used in various UIs.
---@field craftable craftingFrameworkCraftable The object that can be crafted with this recipe.
---@field materials table<number, craftingFrameworkMaterialRequirement> **Required.** A table with the materials required by this recipe.
---@field timeTaken string The time taken to craft the associated object. Currently, doesn't serve a purpose within Crafting Framework, but it can be used to implement custom mechanics.
---@field knownByDefault boolean *Default*: `true`. Controls whether the player knows this recipe from the game start.
---@field customRequirements table<number, craftingFrameworkCustomRequirement> A table with the custom requirements that need to be met in order to craft the associated item.
---@field skillRequirements table<number, craftingFrameworkSkillRequirement> A table with the skill requirements needed to craft the associated item.
---@field tools table<number, craftingFrameworkToolRequirement> A table with the tool requirements needed to craft the associated item.
---@field category string *Default*: `"Other"`. This is the category in which the recipe will appear in the crafting menu.
---@field mesh string This is the mesh override for the preview pane in the crafting menu. If no mesh is present, the 3D model of the associated item will be used.
craftingFrameworkRecipe = {}

---This method will make the recipe available to the player.
function craftingFrameworkRecipe:learn() end

---This method will make the recipe unavailable for the player. If the recipe has knownByDefault set to `true`, calling this method will change it to `false`.
function craftingFrameworkRecipe:unlearn() end

---This method will return `true` if the player knows the recipe.
---@return boolean
function craftingFrameworkRecipe:isKnown() end

---This method will perform crafting of the related craftable object. It will perform the following:
---
--- - The required amount of materials will be removed from the player's inventory.
---
--- - The condition of the used tool(s) will be reduced, by amount specified in the toolRequirement.
---
--- - A new craftable object is created by invoking its `craft` method.
---
--- - The appropriate skills will be awarded experience.
function craftingFrameworkRecipe:craft() end

---This method returns the item that can be crafted with this recipe.
---@return tes3object object
function craftingFrameworkRecipe:getItem() end

---This method returns the average of the skill levels required to craft the item associated with this recipe.
---@return number
function craftingFrameworkRecipe:getAverageSkillLevel() end

---This method will return `true` if the player has the materials required to craft the item. Otherwise, `false` and reason (string) why the item can't be crafted is returned.
---@return boolean
---@return string reason
function craftingFrameworkRecipe:hasMaterials() end

---This method will return `true` if the player has the tools required to craft the item. Otherwise, `false` and reason (string) why the item can't be crafted is returned.
---@return boolean
---@return string reason
function craftingFrameworkRecipe:meetsToolRequirements() end

---This method will return `true` if the player's skills meet the requirements to craft the item. Otherwise, `false` and reason (string) why the item can't be crafted is returned.
---@return boolean
---@return string reason
function craftingFrameworkRecipe:meetsSkillRequirements() end

---This method will return `true` if the player meets custom requirements needed to craft the item. Otherwise, `false` and reason (string) why the item can't be crafted is returned.
---@return boolean
---@return string reason
function craftingFrameworkRecipe:meetsCustomRequirements() end

---This method will return `true` if the player meets all the requirements needed to craft the item. Otherwise, `false` and reason (string) why the item can't be crafted is returned.
---@return boolean
---@return string reason
function craftingFrameworkRecipe:meetsAllRequirements() end


---@class Recipe
---@field registeredRecipes table<string, craftingFrameworkRecipe>
Recipe = {}

---@param id string The recipe's unique identifier.
---@return craftingFrameworkRecipe recipe The recipe requested.
function Recipe.getRecipe(id) end

---This method creates a new recipe.
---@param data craftingFrameworkRecipeData This table accepts following values:
---
--- `id`: string —  This is the unique identifier used internally by Crafting Framework to identify this `recipe`. If none is provided, the id of the associated craftable object will be used.
---
--- `description`: string —  The description of the recipe. Used in various UIs.
---
--- `craftable`: craftingFrameworkCraftableData — The object that can be crafted with this recipe.
---
--- `materials`: table<number, craftingFrameworkMaterialRequirement> — **Required.**  A table with the materials required by this recipe.
---
--- `timeTaken`: string — The time taken to craft the associated object. Currently, doesn't serve a purpose within Crafting Framework, but it can be used to implement custom mechanics.
---
--- `knownByDefault`: boolean — *Default*: `true`. Controls whether the player knows this recipe from the game start.
---
--- `customRequirements`: table<number, craftingFrameworkCustomRequirementData> — A table with the custom requirements that need to be met in order to craft the associated item.
---
--- `skillRequirements`: table<number, craftingFrameworkSkillRequirementData> — A table with the skill requirements needed to craft the associated item.
---
--- `tools`: table<number, craftingFrameworkToolRequirementData> — A table with the tool requirements needed to craft the associated item.
---
--- `category`: string — *Default*: `"Other"`. This is the category in which the recipe will appear in the crafting menu.
---
--- `mesh`: string — This is the mesh override for the preview pane in the crafting menu. If no mesh is present, the 3D model of the associated item will be used.
---@return craftingFrameworkRecipe recipe The newly constructed recipe.
function Recipe:new(data) end
