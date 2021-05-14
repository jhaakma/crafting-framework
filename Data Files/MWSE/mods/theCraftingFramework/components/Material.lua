local Util = require("theCraftingFramework.util.Util")

local Material = {
    schema = {
        name = "Material",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = true },
            ids = { type = "table", childType = "string", required = true }
        }
    }
}

function Material:new(data)
    Util.validate(data, Material.schema)
    setmetatable(data, self)
    self.__index = self
    return data
end

return Material