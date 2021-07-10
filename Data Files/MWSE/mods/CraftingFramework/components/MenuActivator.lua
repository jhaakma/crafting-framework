local craftingMenu = require("CraftingFramework.controllers.CraftingMenu")
local Recipe = require("CraftingFramework.components.Recipe")
local Util = require("CraftingFramework.util.Util")

local MenuActivator = {
    schema = {
        name = "MenuActivator",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = true },
            type = { type = "string", values = {"activate", "equip", "event" }, required = true },
            recipes = { type = "table", childType = Recipe.schema, required = false },
        }
    }
}

MenuActivator.registeredMenuActivators = {}

function MenuActivator:new(data)
    Util.validate(data, MenuActivator.schema)
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
    data:registerEvents()
    MenuActivator.registeredMenuActivators[data.id] = data
    return data
end

function MenuActivator:registerEvents()
    if self.type == "activate" then
        event.register("activate", function(e) 
            if e.target.baseObject.id:lower() == self.id:lower() then
                self:openMenu()
            end
        end)
    elseif self.type == "equip" then
        event.register("equip", function(e)
            if e.item.id:lower() == self.id:lower() then
                self:openMenu()
                return false
            end
        end)
    elseif self.type == "event" then
        event.register(self.id, function()
            self:openMenu()
        end)
    end
end

function MenuActivator:openMenu()
    local knowsRecipe = false
    for _, recipe in pairs(self.recipes) do
        if recipe:isKnown() then
            knowsRecipe = true
            break
        end
    end
    if knowsRecipe then
        craftingMenu.openMenu(self)
    else
        tes3.messageBox("You don't know any recipes")
    end
end

function MenuActivator:registerRecipes(recipes)
    recipes = recipes or {}
    for _, recipe in ipairs(recipes) do
        local registeredRecipe = Recipe:new(recipe)
        table.insert(self.recipes, registeredRecipe)
    end
end

function MenuActivator:registerRecipe(data)
    self:registerRecipes({data})
end



return MenuActivator