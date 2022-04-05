---@meta

---@class craftingFrameworkToolData
---@field id string **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `tool`.
---@field name string The name of the tool. Used in various UIs.
---@field ids table<number, string> **Required.**  This is the list of item ids that are considered identical tool.


---@class craftingFrameworkToolRequirements
---@field tool string **Required.** The tool's id. This is the id used as the tool's unique identifer within Crafting Framework. It shouldn't be confused with item ids defined in the Construction Set.
---@field equipped boolean When `true`, the player needs to have the tool equipped to be considered valid.
---@field count number How many of the items need to be in the player's inventory.
---@field conditionPerUse number Tool's condition will be reduced by this value per use.


---@class craftingFrameworkTool
---@field id string The tool's id. This is the id used as the tool's unique identifer within Crafting Framework. It shouldn't be confused with item ids defined in the Construction Set.
---@field name string The tool's name.
---@field ids table<number, string> A table with the in-game ids of the items that are registered as this tool.
craftingFrameworkTool = {}

---This method returns the name of the tool.
---@return string name
function craftingFrameworkTool:getName() end

---Find a valid tool of this type and apply condition damage if appropriate.
---@param amount number How much condition damage is done.
function  craftingFrameworkTool:use(amount) end

---The method returns `true` if the player has the tool equipped.
---@param requirements craftingFrameworkToolRequirements This table accepts following values:
--- `tool`: string — **Required.** The tool's id.
---
--- `equipped`: boolean — When `true`, the player needs to have the tool equipped to be considered valid.
---
--- `count`: number — How many of the items need to be in the player's inventory.
---
--- `conditionPerUse`: number — Tool's condition will be reduced by this value per use.
---@return boolean
function craftingFrameworkTool:hasToolEquipped(requirements) end

---The method returns `true` if the tool's condition is above zero.
---@param requirements craftingFrameworkToolRequirements This table accepts following values:
--- `tool`: string — **Required.** The tool's id.
---
--- `equipped`: boolean — When `true`, the player needs to have the tool equipped to be considered valid.
---
--- `count`: number — How many of the items need to be in the player's inventory.
---
--- `conditionPerUse`: number — Tool's condition will be reduced by this value per use.
---@return boolean
function craftingFrameworkTool:hasToolCondition(requirements) end

---The method returns `true` if the player has the tool that meets provided requirements.
---@param requirements craftingFrameworkToolRequirements This table accepts following values:
--- `tool`: string — **Required.** The tool's id.
---
--- `equipped`: boolean — When `true`, the player needs to have the tool equipped to be considered valid.
---
--- `count`: number — How many of the items need to be in the player's inventory.
---
--- `conditionPerUse`: number — Tool's condition will be reduced by this value per use.
---@return boolean
function craftingFrameworkTool:hasTool(requirements) end


---@class Tool
---@field registeredTools table<string, craftingFrameworkTool>
Tool = {}

---@param id string The tool's unique identifier.
---@return craftingFrameworkTool Tool The tool requested.
function Tool.getTool(id) end

---This method creates a new tool.
---@param data craftingFrameworkToolData This table accepts following values:
---
--- `id`: string — **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `tool`.
---
--- `name`: string — The name of the tool. Used in various UIs.
---
--- `ids`: table<number, string> — **Required.**  This is the list of item ids that are considered identical tool.
---@return craftingFrameworkTool Tool The newly constructed tool.
function Tool:new(data) end

---Performs a check whether the player has needed amount of the tool in inventory.
---@param obj tes3object
---@param requirements craftingFrameworkToolRequirements
---@return boolean
function Tool.checkInventoryToolCount(obj, requirements) end

---Performs a check whether the player has the tool equipped.
---@param obj tes3object
---@param requirements craftingFrameworkToolRequirements
---@return boolean
function Tool.checkToolEquipped(obj, requirements) end

---Performs a check whether the tool's condition is above zero.
---@param obj tes3object
---@return boolean
function Tool.checkToolCondition(obj) end

---@param id string The id of the tool to check.
---@param requirements craftingFrameworkToolRequirements
---@return boolean
function Tool.checkToolRequirements(id, requirements) end
