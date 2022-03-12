local MenuActivator = require("CraftingFramework.components.MenuActivator")
local Recipe = require("CraftingFramework.components.Recipe")
local Material = require("CraftingFramework.components.Material")
local Tool = require("CraftingFramework.components.Tool")
local interop = {}

--MenuActivator APIs
function interop.registerMenuActivator(menuActivator)
    local catalogue = MenuActivator:new(menuActivator)
    return catalogue
end
function interop.getMenuActivator(id)
    return MenuActivator.registeredMenuActivators[id]
end

--Recipe APIs
function interop.registerRecipes(data)
    for _, recipe in ipairs(data) do
        interop.registerRecipe(recipe)
    end
end
function interop.registerRecipe(recipe)
    Recipe:new(recipe)
end
function interop.getRecipe(id)
    return Recipe.registeredRecipes[id]
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
function interop.registerMaterials(data)
    for _, material in ipairs(data) do
        interop.registerMaterial(material)
    end
end
function interop.registerMaterial(data)
    Material:new(data)
end
function interop.getMaterials(id)
    return Material.registeredMaterials[id]
end

--Tool APIs
function interop.registerTools(data)
    for _, tool in ipairs(data) do
        interop.registerTool(tool)
    end
end

function interop.registerTool(data)
    Tool:new(data)
end

---@param id string the id of the tool
function interop.getTools(id)
    return Tool.registeredTools[id]
end

return interop