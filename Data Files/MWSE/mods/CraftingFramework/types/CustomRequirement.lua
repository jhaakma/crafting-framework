---@meta

---@class craftingFrameworkCustomRequirementData
---@field getLabel function **Required.** This method should return the text that needs to be displayed for this `customRequirement` in the Crafting Menu.
---@field check function **Required.** This method will be called on this `customRequirement` object when performing checks whether an item can be crafted. The function should return `false` the conditions aren't met, and also a reason (string), why the item crafting failed.
---@field showInMenu boolean *Default*: `true`. This property controls if this `customRequirement` will be shown in the Crafting Menu.

---@class craftingFrameworkCustomRequirement
---@field getLabel function **Required.** This method should return the text that needs to be displayed for this `customRequirement` in the Crafting Menu.
---@field check function **Required.** This method will be called on this `customRequirement` object when performing checks whether an item can be crafted. The function should return `false` the conditions aren't met, and also a reason (string), why the item crafting failed.
---@field showInMenu boolean *Default*: `true`. This property controls if this `customRequirement` will be shown in the Crafting Menu.
craftingFrameworkCustomRequirement = {}

---This method returns the name of this customRequirement.
---@return string name
function craftingFrameworkCustomRequirement:getName() end

---@class CustomRequirement
CustomRequirement = {}

---@param data craftingFrameworkCustomRequirementData This table accepts following values:
---
--- `getLabel`: function — **Required.** This method should return the text that needs to be displayed for this `customRequirement` in the Crafting Menu.
---
--- `check`: function — **Required.** This method will be called on this `customRequirement` object when performing checks whether an item can be crafted. The function should return `false` the conditions aren't met, and also a reason (string), why the item crafting failed.
---
--- `showInMenu`: boolean —  *Default*: `true`. This property controls if this `customRequirement` will be shown in the Crafting Menu.
---@return craftingFrameworkCustomRequirement customRequirement
function CustomRequirement:new(data) end
