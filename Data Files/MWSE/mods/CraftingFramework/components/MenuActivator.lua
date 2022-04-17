local craftingMenu = require("CraftingFramework.controllers.CraftingMenu")
local Recipe = require("CraftingFramework.components.Recipe")
local Util = require("CraftingFramework.util.Util")
local logger = Util.createLogger("MenuActivator")

---@class MenuActivator : craftingFrameworkMenuActivator
local MenuActivator = {
    schema = {
        name = "MenuActivator",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = false },
            type = { type = "string", values = {"activate", "equip", "event" }, required = true },
            recipes = { type = "table", childType = Recipe.schema, required = false },
            defaultFilter = { type = "string", values = {"all", "canCraft", "materials", "skill"}, default = "all", required = false },
            defaultSort = { type = "string", values = {"name", "skill", "canCraft"}, default = "name", required = false },
            defaultShowCategories = { type = "boolean", default = true, required = false },
        }
    }
}

MenuActivator.registeredMenuActivators = {}

---@param data craftingFrameworkMenuActivatorData
---@return craftingFrameworkMenuActivator menuActivator
function MenuActivator:new(data)
    Util.validate(data, MenuActivator.schema)
    data.equipStationIds = data.equipStationIds or {}
    data.activateStationIds = data.activateStationIds or {}
    data.triggers = data.triggers or {}
    setmetatable(data, self)
    self.__index = self

    -- For activators, set name to object name if not already set
    if (data.type ~= "event") and (not data.name) then
        local obj = tes3.getObject(data.id)
        if obj then
            data.name = obj.name
        end
    end
    if not data.name then
        logger:error("MenuActivator:new - no name specified for menu activator %s", data.id)
    end
    --Convert to objects
    data.recipes = Util.convertListTypes(data.recipes, Recipe)
    data:registerEvents()

    --Merge with existing or register new Menu Activator
    local menuActivator = MenuActivator.registeredMenuActivators[data.id]
    if not menuActivator then
        MenuActivator.registeredMenuActivators[data.id] = data
        menuActivator = data
    else
        for _, recipe in pairs(self.recipes) do
            table.insert(menuActivator.recipes, recipe)
        end
    end
    return menuActivator
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

-- Adds a list of recipes to the menu activator from recipe schemas
function MenuActivator:registerRecipes(recipes)
    recipes = Util.convertListTypes(recipes, Recipe)
    recipes = recipes or {}
    for _, recipe in ipairs(recipes) do
        table.insert(self.recipes, recipe)
    end
end

--Adds a recipe to the menu activator from recipe schema
function MenuActivator:registerRecipe(data)
    self:registerRecipes({data})
end

--Adds a list of recipes to the menu activator
function MenuActivator:addRecipes(recipes)
    for _, recipe in ipairs(recipes) do
        table.insert(self.recipes, recipe)
    end
end

--Adds an already registered recipe to the menu activator
function MenuActivator:addRecipe(recipe)
    table.insert(self.recipes, recipe)
end



return MenuActivator