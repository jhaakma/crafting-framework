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
