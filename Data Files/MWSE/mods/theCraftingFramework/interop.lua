local CraftingManager = require("theCraftingFramework.components.CraftingManager")
local Recipe = require("theCraftingFramework.components.Recipe")

local interop = {}

--Crafting Manager APIs
local managers = {}
function interop.registerManager(data)
    local manager = CraftingManager:new(data)
    managers[manager.id] = manager
    return manager
end
function interop.getManager(id)
    return managers[id]
end

--Recipe APIs
local recipes = {}
function interop.registerRecipe(data)
    local recipe = Recipe:new(data)
    recipes[recipe.id] = recipe
end
function interop.getRecipe(id)
    return recipes[id]
end
function interop.learnRecipe(id)
    local recipe = interop.getRecipe(id)
    recipe:learn()
end
function interop.unlearnRecipe(id)
    local recipe = interop.getRecipe(id)
    recipe:unlearn()
end

--Material APIs

return interop