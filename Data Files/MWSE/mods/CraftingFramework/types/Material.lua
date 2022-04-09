---@meta

---@class craftingFrameworkMaterialData
---@field id string **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `material`.
---@field name string The name of the material. Used in various UIs.
---@field ids table<number, string> **Required.**  This is the list of item ids that are considered as identical material.

---@class craftingFrameworkMaterialRequirement
---@field material string **Required.** The Crafting Framework id to indentify the material.
---@field count number *Default*: `0`. The required amount of the material.

---@class craftingFrameworkMaterial
---@field id string The material's id. This is the id used as the material's unique identifer within Crafting Framework.
---@field name string The material's name. Used in various UIs.
---@field ids table<string, boolean> This is the list of item ids that are considered as identical material.
craftingFrameworkMaterial = {}

---This method returns `true` if the `itemId` is registered as a this material.
---@param itemId string The id of the item to check.
---@return boolean isMaterial True if the item of provided `id` is in this material's list of ids.
function craftingFrameworkMaterial:itemIsMaterial(itemId) end

---This method returns the name of the material.
---@return string name
function craftingFrameworkMaterial:getName() end

---This method returns `true` if the player has at least `numRequired` instances of this material in their inventory.
---@param numRequired number
---@return boolean hasEnough
function craftingFrameworkMaterial:checkHasIngredient(numRequired) end


---@class Material
---@field registeredMaterials table<string, craftingFrameworkMaterial>
Material = {}

--- If the material of provided `id` hasn't been registered before, but `id` is a valid item id (e.g. defined in the Construction Set), a new material will be created.
---@param id string The material's unique identifier.
---@return craftingFrameworkMaterial material The material requested.
function Material.getMaterial(id) end

---This method creates a new material.
---@param data craftingFrameworkMaterialData This table accepts following values:
---
--- `id`: string — **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `material`.
---
--- `name`: string — The name of the material. Used in various UIs.
---
--- `ids`: table<number, string> — **Required.**  This is the list of item ids that are considered as identical material.
---@return craftingFrameworkMaterial material The newly constructed material.
function Material:new(data) end
