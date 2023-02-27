local CF = require("CraftingFramework")
local MenuActivator = require("CraftingFramework.components.MenuActivator")
local Recipe = require("CraftingFramework.components.Recipe")
local Material = require("CraftingFramework.components.Material")
local Tool = require("CraftingFramework.components.Tool")
local Positioner = require("CraftingFramework.controllers.Positioner")
local StaticActivator = require("CraftingFramework.controllers.StaticActivator")
local Indicator = require("CraftingFramework.controllers.Indicator")
---@class craftingFrameworkInterop
CF.interop = {}

--MenuActivator APIs

---@param menuActivator CraftingFramework.MenuActivator.data
---@return CraftingFramework.MenuActivator
function CF.interop.registerMenuActivator(menuActivator)
    local catalogue = MenuActivator:new(menuActivator)
    return catalogue
end
---@param id string
---@return CraftingFramework.MenuActivator menuActivator
function CF.interop.getMenuActivator(id)
    return MenuActivator.registeredMenuActivators[id]
end

--Recipe APIs

---@param data CraftingFramework.Recipe.data[]
function CF.interop.registerRecipes(data)
    for _, recipe in ipairs(data) do
        CF.interop.registerRecipe(recipe)
    end
end
---@param recipe CraftingFramework.Recipe.data
function CF.interop.registerRecipe(recipe)
    Recipe:new(recipe)
end
---@param id string
---@return CraftingFramework.Recipe recipe
function CF.interop.getRecipe(id)
    return Recipe.registeredRecipes[id]
end
---@param id string
function CF.interop.learnRecipe(id)
    local recipe = CF.interop.getRecipe(id)
    recipe:learn()
end
---@param id string
function CF.interop.unlearnRecipe(id)
    local recipe = CF.interop.getRecipe(id)
    recipe:unlearn()
end

--Material APIs

---@param data craftingFrameworkMaterialData[]
function CF.interop.registerMaterials(data)
    for _, material in ipairs(data) do
        CF.interop.registerMaterial(material)
    end
end
---@param data craftingFrameworkMaterialData
function CF.interop.registerMaterial(data)
    Material:new(data)
end
---@param id string
---@return craftingFrameworkMaterial material
function CF.interop.getMaterials(id)
    return Material.registeredMaterials[id]
end

--Tool APIs

---@param data CraftingFramework.Tool.data[]
function CF.interop.registerTools(data)
    for _, tool in ipairs(data) do
        CF.interop.registerTool(tool)
    end
end
---@param data CraftingFramework.Tool.data
function CF.interop.registerTool(data)
    Tool:new(data)
end

-- Activator APIs
function CF.interop.registerStaticActivator(data)
    StaticActivator:new(data)
end

-- Indicator APIs
function CF.interop.registerIndicator(data)
    Indicator:new(data)
end

---@param id string
---@return CraftingFramework.Tool tool
function CF.interop.getTools(id)
    return Tool.registeredTools[id]
end

--[[
    Activates the Positioner mechanic for the given reference
]]
---@class CraftingFramework.interop.activatePositionerParams
---@field reference tes3reference
---@field pinToWall boolean
---@field placementSetting string
---@field blockToggle boolean

---@param e CraftingFramework.interop.activatePositionerParams
function CF.interop.activatePositioner(e)
    Positioner.startPositioning{
        target = e.reference,
        nonCrafted = true,
        pinToWall = e.pinToWall,
        placementSetting = e.placementSetting,
        blockToggle = e.blockToggle,
    }
end


return CF.interop