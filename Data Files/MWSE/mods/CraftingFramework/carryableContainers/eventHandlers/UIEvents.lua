local common = require("CraftingFramework.carryableContainers.common")
local logger = common.createLogger("UIEvents")
local CarryableMisc = require("CraftingFramework.carryableContainers.components.CarryableMisc")
local Container = require("CraftingFramework.carryableContainers.components.Container")

---@param e uiActivatedEventData
local function onUiActivated(e)
    logger:debug("uiActivated")
    local miscId = Container.getOpenContainerMiscId(e.element)
    if not miscId then return end
    local miscObject = tes3.getObject(miscId) --[[@as tes3misc]]
    if not miscObject then return end
    local menu = e.element
    local carryable = CarryableMisc:new{
        item = miscObject
    }
    if not carryable then return end
    logger:debug("We are in a carryable container inventory, miscRef ID: %s", miscId)
    Container.addButtons(menu, carryable)
end
event.register(tes3.event.uiActivated, onUiActivated)


---@param e uiObjectTooltipEventData
local function onTooltip(e)
    logger:trace("onTooltip()")

    local carryable = CarryableMisc:new{
        containerRef = e.reference,
    }
    if not carryable then
        carryable = CarryableMisc:new{
            item = e.object,
            itemData = e.itemData,
            reference = e.reference,
        }
    end
    if not carryable then return end
    local filterText = "Container"
    local filter = carryable:getFilter()
    if filter then
        filterText = filter.name .. " Container"
    end
    local filterLabel = e.tooltip:createLabel{
        text = filterText
    }
    filterLabel.borderLeft = 10
    filterLabel.borderRight = 10
    filterLabel.borderBottom = 10
    --Display current/max weight
    local containerRef = carryable:getContainerRef()
    local currentWeight
    local maxWeight
    if containerRef then
        currentWeight = containerRef.object.inventory:calculateWeight()
        maxWeight = containerRef.object.capacity
    else
        currentWeight = 0
        maxWeight = carryable:calculateCapacity()
    end
    if maxWeight < 9998 then
        local fillbar = e.tooltip:createFillBar{
            current = currentWeight,
            max = maxWeight
        }
        fillbar.borderBottom = 10
        fillbar.borderLeft = 10
        fillbar.borderRight = 10
    end
end
event.register(tes3.event.uiObjectTooltip, onTooltip)