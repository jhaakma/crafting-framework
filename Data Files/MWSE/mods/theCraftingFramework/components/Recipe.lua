local Util = require("theCraftingFramework.util.Util")
local Craftable = require("theCraftingFramework.components.Craftable")

local Recipe = {
    schema = {
        name = "Recipe",
        fields = {
            id = { type = "string", required = true },
            craftable = { type = Craftable.schema, required = true },
            description = { type = "string", required = true },
            materials = { type = "table", required = true },
            timeTaken = { type = "string", required = false },
            known = { type = "string", required = false },
        }
    }
}

function Recipe:new(data)
    Util.validate(data, Recipe.schema)
    data.known = data.known or false
    data.craftable = Craftable:new(data.craftable)
    setmetatable(data, self)
    self.__index = self
    return data
end

function Recipe:learn()
    self.known = true
end

function Recipe:unlearn()
    self.known = false
end

return Recipe