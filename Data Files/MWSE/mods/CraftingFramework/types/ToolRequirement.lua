---@meta

---@class craftingFrameworkToolRequirementData
---@field tool string **Required.** The tool's id. This is the id used as the tool's unique identifer within Crafting Framework. It shouldn't be confused with item ids defined in the Construction Set.
---@field equipped boolean When `true`, the player needs to have the tool equipped to be considered valid.
---@field count number How many of the items need to be in the player's inventory.
---@field conditionPerUse number Tool's condition will be reduced by this value per use.


---@class craftingFrameworkToolRequirement
---A tool is an item that is required for crafting an item, but not consumed during crafting like a material. It may need to be equipped, and can be confugured to lose durability each time it is used for crafting.
---@field tool craftingFrameworkTool **Required.** The tool's id. This is the id used as the tool's unique identifer within Crafting Framework. It shouldn't be confused with item ids defined in the Construction Set.
---@field equipped boolean When `true`, the player needs to have the tool equipped to be considered valid.
---@field count number How many of the items need to be in the player's inventory.
---@field conditionPerUse number Tool's condition will be reduced by this value per use.
craftingFrameworkToolRequirement = {}

---@param id string The tool's unique identifier.
---@return craftingFrameworkTool Tool The tool requested.
function craftingFrameworkToolRequirement.getTool(id) end

---This method creates a new tool.
---@param data craftingFrameworkToolRequirementData This table accepts following values:
---
--- `id`: string — **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `tool`.
---
--- `name`: string — The name of the tool. Used in various UIs.
---
--- `ids`: table<number, string> — **Required.**  This is the list of item ids that are considered identical tool.
---@return craftingFrameworkToolRequirement Tool The newly constructed tool.
function craftingFrameworkToolRequirement:new(data) end

---This method returns the name of the tool.
---@return string name
function craftingFrameworkToolRequirement:getName() end

---Find a valid tool of this type and apply condition damage if appropriate.
---@param amount number How much condition damage is done.
function  craftingFrameworkToolRequirement:use(amount) end

---The method returns `true` if the player has the tool equipped.
---@param requirements craftingFrameworkToolRequirement This table accepts following values:
--- `tool`: string — **Required.** The tool's id.
---
--- `equipped`: boolean — When `true`, the player needs to have the tool equipped to be considered valid.
---
--- `count`: number — How many of the items need to be in the player's inventory.
---
--- `conditionPerUse`: number — Tool's condition will be reduced by this value per use.
---@return boolean
function craftingFrameworkToolRequirement:hasToolEquipped(requirements) end

---The method returns `true` if the tool's condition is above zero.
---@param requirements craftingFrameworkToolRequirement This table accepts following values:
--- `tool`: string — **Required.** The tool's id.
---
--- `equipped`: boolean — When `true`, the player needs to have the tool equipped to be considered valid.
---
--- `count`: number — How many of the items need to be in the player's inventory.
---
--- `conditionPerUse`: number — Tool's condition will be reduced by this value per use.
---@return boolean
function craftingFrameworkToolRequirement:hasToolCondition(requirements) end

---The method returns `true` if the player has the tool that meets provided requirements.
---@param requirements craftingFrameworkToolRequirement This table accepts following values:
--- `tool`: string — **Required.** The tool's id.
---
--- `equipped`: boolean — When `true`, the player needs to have the tool equipped to be considered valid.
---
--- `count`: number — How many of the items need to be in the player's inventory.
---
--- `conditionPerUse`: number — Tool's condition will be reduced by this value per use.
---@return boolean
function craftingFrameworkToolRequirement:hasTool(requirements) end

