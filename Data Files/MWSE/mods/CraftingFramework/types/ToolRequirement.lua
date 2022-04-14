---@meta

---@class craftingFrameworkToolRequirementData
---@field tool string **Required.** The tool's id. This is the id used as the tool's unique identifer within Crafting Framework. It shouldn't be confused with item ids defined in the Construction Set.
---@field equipped boolean When `true`, the player needs to have the tool equipped to be considered valid.
---@field count number *Default*: `1`. How many of the items need to be in the player's inventory.
---@field conditionPerUse number Tool's condition will be reduced by this value per use.


---@class craftingFrameworkToolRequirement
---A tool is an item that is required for crafting an item, but not consumed during crafting like a material. It may need to be equipped, and can be confugured to lose durability each time it is used for crafting.
---@field tool craftingFrameworkTool The tool associated with this toolRequirement.
---@field equipped boolean When `true`, the player needs to have the tool equipped to be considered valid.
---@field count number *Default*: `1`. How many of the items need to be in the player's inventory.
---@field conditionPerUse number Tool's condition will be reduced by this value per use.
craftingFrameworkToolRequirement = {}

---This method creates a new toolRequirement object.
---@param data craftingFrameworkToolRequirementData This table accepts following values:
---
--- `tool`: string — **Required.** The tool's id. This is the id used as the tool's unique identifer within Crafting Framework. It shouldn't be confused with item ids defined in the Construction Set.
---
--- `equipped`: boolean — When `true`, the player needs to have the tool equipped to be considered valid.
---
--- `count`: number — *Default*: `1`. How many of the items need to be in the player's inventory.
---
--- `conditionPerUse`: number —  Tool's condition will be reduced by this value per use.
---@return craftingFrameworkToolRequirement toolRequirement The newly constructed tool.
function craftingFrameworkToolRequirement:new(data) end

---@return nil
function craftingFrameworkToolRequirement:getLabel() end

---The method returns `true` if the player has the required tool equipped.
---@return boolean
function craftingFrameworkToolRequirement:hasToolEquipped() end

---The method returns `true` if the player has the required tool with condition above zero.
---@return boolean
function craftingFrameworkToolRequirement:hasToolCondition() end

---The method returns `true` if the player has a tool that meets this toolRequirement's conditions.
---@return boolean
function craftingFrameworkToolRequirement:hasTool() end
