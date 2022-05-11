local Util = require("CraftingFramework.util.Util")
local Craftable = require("CraftingFramework.components.Craftable")
local logger = Util.createLogger("CraftingEvents")
local function craftableActivated(e)
    logger:debug("craftableActivated!!")
    local craftable = Craftable.getPlacedCraftable(e.reference.object.id:lower())
    if craftable and craftable:getPlacedObjectId() then
        if Util.isShiftDown() and Util.canBeActivated(e.reference) then
            e.reference.data.allowActivate = true
            tes3.player:activate(e.reference)
            e.reference.data.allowActivate = nil
        else
            craftable:activate(e.reference)
        end
    end
end
event.register("CraftingFramework:CraftableActivated", craftableActivated)


local function itemDropped(e)
    logger:debug("ItemDROPPPPPED")
    local craftable = Craftable.getCraftable(e.reference.object.id)
    local placedObject = craftable and craftable:getPlacedObjectId()
    if placedObject then
        logger:debug("placedObject: " .. placedObject)
        if placedObject and e.reference.baseObject.id:lower() == craftable.id then
            logger:debug("itemDropped: " .. placedObject)
            craftable:swap(e.reference)
        end
    end
end
event.register("itemDropped", itemDropped)

