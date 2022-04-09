local Util = require("CraftingFramework.util.Util")
local config = require("CraftingFramework.config")

---@class CustomRequirement
local CustomRequirement = {
    schema = {
        name = "CustomRequirement",
        fields = {
            getLabel = { type = "function",  required = true},
            check = { type = "function",  required = true},
            showInMenu = { type = "boolean", default = true, required = false},
        }
    }
}


---Constructor
---@param data craftingFrameworkCustomRequirementData
---@return craftingFrameworkCustomRequirement
function CustomRequirement:new(data)
    Util.validate(data, CustomRequirement.schema)
    setmetatable(data, self)
    self.__index = self
    return data
end

function CustomRequirement:getName()
    return self.name
end



return CustomRequirement