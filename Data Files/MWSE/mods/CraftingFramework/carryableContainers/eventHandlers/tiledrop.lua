local TileDropper = require("CraftingFramework.components.TileDropper")
local CarryableContainer = require("CraftingFramework.carryableContainers.components.CarryableContainer")
TileDropper.register{
    name = "CarryableContainers",
    highlightColor = { 1, 1, 1 },
    isValidTarget = function(e)
        return CarryableContainer.getContainerConfig(e.item) ~= nil
    end,
    canDrop = function(e)
        --Check if passes the container filter
        local container = CarryableContainer:new{
            item = e.target.item,
            itemData = e.target.itemData,
        }
        if not container then return false end
        local filter = container:getFilter()
        if not filter then return true end
        return filter:isValid(e.held.item, e.held.itemData)
    end,
    --transfer
    onDrop = function(e)
        local container = CarryableContainer:new{
            item = e.target.item,
            itemData = e.target.itemData,
        }
        if not container then return end
        container:transferPlayerToContainer{
            itemIds = { e.held.item.id },
        }
    end
}