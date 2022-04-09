---@meta

---@class craftingFrameworkCustomRequirementData
---@field getLabel function **Required.**
---@field check function **Required.**
---@field showInMenu boolean

---@class craftingFrameworkCustomRequirement
---@field getLabel function **Required.**
---@field check function **Required.**
---@field showInMenu boolean
craftingFrameworkCustomRequirement = {}

---This method returns the name of this customRequirement.
---@return string name
function craftingFrameworkCustomRequirement:getName() end

---@class CustomRequirement
CustomRequirement = {}

---@param data craftingFrameworkCustomRequirementData This table accepts following values:
---
--- `getLabel`: function — **Required.**
---
--- `check`: function — **Required.**
---
--- `showInMenu`: boolean — *Default*: `true`.
---@return craftingFrameworkCustomRequirement
function CustomRequirement:new(data) end
