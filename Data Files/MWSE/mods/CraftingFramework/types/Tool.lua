---@meta

---@class craftingFrameworkToolData
---@field id string **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `tool`.
---@field name string The name of the tool. Used in various UIs.
---@field ids table<number, string> **Required.**  This is the list of game item ids that will be used as the tool.

---@class craftingFrameworkToolRequirements
---@field equipped boolean Perform a check whether the tool is equipped?

---@class craftingFrameworkTool
---@field id string The tool's id.
---@field name string The tool's name.
---@field ids table<number, string> A table with the ids of the items that are considered equal as this tool.
