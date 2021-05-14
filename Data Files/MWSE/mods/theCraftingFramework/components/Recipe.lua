local Util = require("theCraftingFramework.util.Util")
local MenuButton = require("theCraftingFramework.components.MenuButton")
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
    data.menuOptions = self:createMenuOptions(data.menuOptions)
    data.craftable = Craftable:new(data.craftable)
    setmetatable(data, self)
    self.__index = self
    return data
end


function Recipe:createMenuOptions(options)
    options = options or {}
    local menuButtons = {}
    for _, option in ipairs(options) do
        Util.validate(option, MenuButton.schema)
        table.insert(menuButtons, option)
    end
    local pickUpButton = {
        text = "Pick Up",
        callback = self:pickUp()
    }
    table.insert(menuButtons, pickUpButton)
end

function Recipe:pickUp(reference)

    --if container, move to player inventory
    if reference.baseObject.objectType == tes3.objectType.container then
        local itemList = {}
        for stack in tes3.iterate(reference.object.inventory.iterator) do
            table.insert(itemList, stack)
        end
        for _, stack in ipairs(itemList) do
            tes3.transferItem{ from = reference, to = tes3.player, item = stack.object, count = stack.count, updateGUI  = false, playSound = false }
        end
        tes3ui.forcePlayerInventoryUpdate()
    end

    --If this item 
    if reference.baseObject.id == self.placedObject then

    end

    local miscId = containerToMiscMapping[reference.baseObject.id:lower()]
    tes3.addItem{ reference = tes3.player, item = miscId, }
    common.helper.yeet(reference)
    if #itemList > 0 then
        tes3.messageBox("Contents of %s added to inventory.", getName(reference))
    end
end

function Recipe:getCraftedObject()
    return tes3.getObject(self.id)
end

function Recipe:learn()
    self.known = true
end

function Recipe:unlearn()
    self.known = false
end

return Recipe