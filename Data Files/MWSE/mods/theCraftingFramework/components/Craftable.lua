local Util = require("theCraftingFramework.util.Util")
local MenuButton = require("theCraftingFramework.components.MenuButton")

local Craftable = {
    schema = {
        id = { type = "string", required = true },
        placedObject = { type = "string", required = false },
        menuOptions = { type = "table", required = false },
    }
}

function Craftable:new(data)
    Util.validate(data, Craftable.schema)
    data.menuOptions = self:createMenuOptions(data.menuOptions)
    setmetatable(data, self)
    self.__index = self
    return data
end

function Craftable:createMenuOptions(options)
    options = options or {}
    local menuButtons = {}
    for _, option in ipairs(options) do
        Util.validate(option, MenuButton.schema)
        table.insert(menuButtons, option)
    end
    local pickUpButton = {
        text = "Pick Up",
        callback = self.craftable:pickUp()
    }
    table.insert(menuButtons, pickUpButton)
end

function Craftable:pickUp(reference)
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

return Craftable