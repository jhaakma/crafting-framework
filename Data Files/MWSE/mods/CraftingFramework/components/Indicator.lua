local Util = require("CraftingFramework.util.Util")
local logger = Util.createLogger("Indicator")

---@class CraftingFramework.Indicator.data
---@field objectId string The object id to register the indicator for
---@field name string The name to display in the tooltip.
---@field craftedOnly boolean If true, the indicator will only show if the object is crafted.
---@field additionalUI fun(self: CraftingFramework.Indicator, parent: tes3uiElement) A function that adds additional UI elements to the tooltip.

---@class CraftingFramework.Indicator : CraftingFramework.Indicator.data
---@field reference tes3reference
Indicator = {}
---@type table<string, CraftingFramework.Indicator.data> List of registered indicator objects, indexed by object id
Indicator.registeredObjects = {}

---@param data CraftingFramework.Indicator.data
function Indicator.register(data)
    logger:assert(type(data.objectId) == "string" , "data.objectId is required")
    if Indicator.registeredObjects[data.objectId:lower()] then
        logger:warn("Indicator.register: %s is already registered", data.objectId)
    end
    Indicator.registeredObjects[data.objectId:lower()] = data
    logger:debug("Registered %s as Indicator", data.objectId)
end

---@return CraftingFramework.Indicator|nil
function Indicator:new(reference)
    if not reference then return end
    local data = Indicator.registeredObjects[reference.object.id:lower()]
    if not data then return end
    if not (data.name or data.additionalUI) then return end
    local indicator = table.copy(data)
    indicator.reference = reference
    setmetatable(indicator, self)
    self.__index = self
    return indicator
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

function Indicator:createOrUpdateTooltipMenu()
    local indicator = Indicator.registeredObjects[self.reference.object.id:lower()]
    local headerText = indicator.name
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

    if headerText then
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
    end
    if indicator.additionalUI then
        local additionalUIBlock = labelBorder:createBlock()
        additionalUIBlock.autoHeight = true
        additionalUIBlock.autoWidth = true
        indicator:additionalUI(additionalUIBlock)
    end

    return labelBorder
end

--- Update the indicator with the given reference
function Indicator:update()
    --get registered object
    --If craftedOnly, check the crafted flag
    local blockNonCrafted = self.craftedOnly
        and self.reference.data
        and not self.reference.data.crafted

    --get menu
    local menu = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    --If its an activator with a name, it'll already have a tooltip
    local hasObjectName = self.reference and self.reference.object.name and self.reference.object.name ~= ""
    local hasRegisteredName = self.name and self.name ~= ""

    local showIndicator = menu
        and self
        and ( hasRegisteredName or self.additionalUI )
        and (not hasObjectName)
        and (not blockNonCrafted)
    if showIndicator then
        self:createOrUpdateTooltipMenu()
    else
        Indicator.disable()
    end
end

---Hide the indicator if it's visible
function Indicator.disable()
    local tooltipMenu = getTooltip()
    if tooltipMenu then
        tooltipMenu.visible = false
    end
end

return Indicator