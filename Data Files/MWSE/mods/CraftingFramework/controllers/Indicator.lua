local Util = require("CraftingFramework.util.Util")
local logger = Util.createLogger("Indicator")
local CF = require("CraftingFramework")
CF.Indicator = {}
CF.Indicator.registeredObjects = {}
---@class CraftingFramework.Indicator.data
---@field objectId string The object id to register the indicator for
---@field name string The name to display in the tooltip.
---@field craftedOnly boolean If true, the indicator will only show if the object is crafted.
---@field additionalUI fun(parentElement: tes3uiElement, reference: tes3reference) Add more UI to the tooltip

---@param data CraftingFramework.Indicator.data
function CF.Indicator.register(data)
    logger:assert(type(data.objectId) == "string" , "data.objectId is required")
    if CF.Indicator.registeredObjects[data.objectId:lower()] then
        logger:warn("Indicator.register: %s is already registered", data.objectId)
    end
    CF.Indicator.registeredObjects[data.objectId:lower()] = data
    logger:debug("Registered %s as Indicator", data.objectId)
end

local id_indicator = tes3ui.registerID("CraftingFramework:activatorTooltip")
local id_contents = tes3ui.registerID("CraftingFramework:activatorTooltipContents")
local id_label = tes3ui.registerID("CraftingFramework:activatorTooltipLabel")
local icon_block = tes3ui.registerID("CraftingFramework:activatorTooltipIconBlock")
local function getTooltip()
    local MenuMulti = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    if not MenuMulti then return end
    return MenuMulti:findChild(id_indicator)
end

local function createOrUpdateTooltipMenu(headerText)
    local MenuMulti = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    if not MenuMulti then return end
    local tooltipMenu = MenuMulti:findChild(id_indicator)
        or MenuMulti:createBlock{ id = id_indicator }
    tooltipMenu.visible = true
    tooltipMenu:destroyChildren()
    tooltipMenu.absolutePosAlignX = 0.5
    tooltipMenu.absolutePosAlignY = 0.03
    tooltipMenu.autoHeight = true
    tooltipMenu.autoWidth = true
    local labelBackground = tooltipMenu:createRect({color = {0, 0, 0}})
    labelBackground.autoHeight = true
    labelBackground.autoWidth = true
    local labelBorder = labelBackground:createThinBorder({id = id_contents })
    labelBorder.autoHeight = true
    labelBorder.autoWidth = true
    labelBorder.childAlignX = 0.5
    labelBorder.paddingAllSides = 10
    labelBorder.flowDirection = "top_to_bottom"
    local headerBlock = labelBorder:createBlock()
    headerBlock.autoHeight = true
    headerBlock.autoWidth = true
    headerBlock.flowDirection = "left_to_right"
    headerBlock.childAlignY = 0.5
    local iconBlock = headerBlock:createBlock{ id = icon_block }
    iconBlock.autoHeight = true
    iconBlock.autoWidth = true
    local header = headerBlock:createLabel{ id = id_label, text = headerText or "" }
    header.autoHeight = true
    header.autoWidth = true
    header.color = tes3ui.getPalette("header_color")
    return labelBorder
end

--- Update the indicator with the given reference
function CF.Indicator.update(reference)
    --get registered object
    local registeredObject = CF.Indicator.registeredObjects[reference.object.id:lower()]
    --If craftedOnly, check the crafted flag
    local blockNonCrafted = registeredObject
        and registeredObject.craftedOnly
        and reference.data
        and not reference.data.crafted

    --get menu
    local menu = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    --If its an activator with a name, it'll already have a tooltip
    local hasName = reference and reference.object.name and reference.object.name ~= ""

    logger:trace("Indicator.update: %s, %s, %s, %s",
        (registeredObject and registeredObject.name),
        menu,
        hasName,
        blockNonCrafted)
    local showIndicator = menu
        and registeredObject
        and (not hasName)
        and (not blockNonCrafted)
    if showIndicator then
        createOrUpdateTooltipMenu(registeredObject.name)
    else
        CF.Indicator.disable()
    end
end

---Hide the indicator if it's visible
function CF.Indicator.disable()
    local tooltipMenu = getTooltip()
    if tooltipMenu then
        tooltipMenu.visible = false
    end
end

return CF.Indicator