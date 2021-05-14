local Recipe = require("theCraftingFramework.components.Recipe")
local Util = require("theCraftingFramework.util.Util")

local CraftingManager = {
    schema = {
        name = "CraftingManager",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = true },
            recipes = { type = "table", required = false },
            equipStationIds = { type = "table", required = false },
            activateStationIds = { type = "table", required = false },
            triggers = { type = "table", required = false },
        }
    }
}



function CraftingManager:new(data)
    Util.validate(data, CraftingManager.schema)
    data.equipStationIds = data.equipStationIds or {}
    data.activateStationIds = data.activateStationIds or {}
    data.triggers = data.triggers or {}
    setmetatable(data, self)
    self.__index = self

    --turn recipes into Recipe objects
    if data.recipes then
        local recipes = table.copy(data.recipes)
        data.recipes = {}
        data:registerRecipes(recipes)
    else
        data.recipes = {}
    end
    return data
end

function CraftingManager:registerRecipes(recipes)
    recipes = recipes or {}
    for _, recipe in ipairs(recipes) do
        local registeredRecipe = Recipe:new(recipe)
        table.insert(self.recipes, registeredRecipe)
    end
end

function CraftingManager:registerRecipe(data)
    self:registerRecipes({data})
end

return CraftingManager