local Util = require("CraftingFramework.util.Util")

local Material = {
    schema = {
        name = "Material",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = false },
            ids = { type = "table", childType = "string", required = true }
        }
    }
}

Material.registeredMaterials = {}
function Material.getMaterial(id)
    return Material.registeredMaterials[id]
end


function Material:new(data)
    Util.validate(data, Material.schema)
    setmetatable(data, self)
    self.__index = self
    Material.registeredMaterials[data.id] = data
    return data
end

function Material:getName()
    return self.name
end

function Material:checkHasIngredient(numRequired)
    local count = 0
    for _, id in ipairs(self.ids) do
        count = count + mwscript.getItemCount{ reference = tes3.player, item = id }
    end
    return count >= numRequired
end

return Material