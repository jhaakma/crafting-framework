local config = require("CraftingFramework.carryableContainers.config")
local common = require("CraftingFramework.carryableContainers.common")
local logger = common.createLogger("Container")

local Container = {}

function Container.getMiscIdfromReference(reference)
    if not reference then
        logger:debug("No container ref")
        return nil
    end
    local miscId = config.persistent.containerToMiscCopyMapping[reference.baseObject.id:lower()]
    if not miscId then
        logger:trace("No misc id")
        return nil
    end
    logger:debug("Found misc id: %s", miscId)
    return miscId
end

---@return string? # Flase if not open, otherwise returns the associated misc item id
function Container.getOpenContainerMiscId(contentsMenu)
    logger:debug("Checking if we are in a carryable container inventory")
    local contentsMenu = contentsMenu or tes3ui.findMenu(tes3ui.registerID("MenuContents"))
    local menuInvalid = contentsMenu == nil
        or contentsMenu.name ~= "MenuContents"
        or contentsMenu.visible == false
    if menuInvalid then
        logger:debug("Menu is invalid")
        return nil
    end
    local containerRef = contentsMenu:getPropertyObject("MenuContents_ObjectRefr")
    return Container.getMiscIdfromReference(containerRef)
end

local function replaceTakeAllButton(menu, carryable)
    local takeAllButton = menu:findChild("MenuContents_takeallbutton")
    takeAllButton.visible = false
    local takeAllButtonParent = takeAllButton.parent

    local newTakeAllButton = takeAllButtonParent:createButton{
        id = "merCarryableContainers_takeAllButton",
        text = "Take All"
    }
    newTakeAllButton:register("mouseClick", function()
        logger:debug("Clicked take all button")
        carryable:takeAll()
        menu:updateLayout()
    end)
    newTakeAllButton.borderAllSides = 4
    newTakeAllButton.paddingLeft = 8
    newTakeAllButton.paddingRight = 8
    newTakeAllButton.paddingBottom = 3
    takeAllButton.parent:reorderChildren(takeAllButton, newTakeAllButton, 1)
end

local function createFilterLabel(filterButtonParent, filter)
    logger:debug("Creating filter label")
    local label = filterButtonParent:createLabel{
        id = "merCarryableContainers_filterLabel",
        text = string.format(" [ Filter: %s ] ", filter.name)
    }
    label.borderRight = 10
    label.borderBottom = 3
    label.color = tes3ui.getPalette("header_color")
    return label
end

local function createFilterButton(transferButtonParent, menu, carryable)
    local filter = carryable:getFilter()
    local tranferText = string.format("Transfer %s", filter.name)
    local transferButton = transferButtonParent:createButton{
        id = "merCarryableContainers_transferButton",
        text = tranferText
    }
    transferButton:register("mouseClick", function()
        logger:debug("Clicked transfer button")
        carryable:transferFiltered()
        menu:updateLayout()
    end)
    transferButton.borderAllSides = 4
    transferButton.paddingLeft = 8
    transferButton.paddingRight = 8
    transferButton.paddingBottom = 3
    return transferButton
end

---@param parent tes3uiElement
---@param carryable CarryableMisc
local function addRenameButton(parent, carryable)
    local renameButton = parent:createButton{
        id = "merCarryableContainers_renameButton",
        text = "Rename"
    }
    renameButton:register("mouseClick", function()
        logger:debug("Clicked rename button")
        carryable:openRenameMenu{
            callback = function()
                logger:debug("Reopening container after rename")
                timer.delayOneFrame(function()
                    tes3.player:activate(carryable:getCreateContainerRef())
                end)
            end
        }
    end)
    return renameButton
end

---@param parent tes3uiElement
---@param carryable CarryableMisc
local function addPickupButton(parent, carryable, menu)
    if carryable.reference == nil then return end
    local pickupButton = parent:createButton{
        id = "merCarryableContainers_pickupButton",
        text = "Pick Up"
    }
    pickupButton:register("mouseClick", function()
        logger:debug("Clicked pickup button")
        menu:destroy()
        tes3ui.leaveMenuMode()
        carryable:setSafeInstance()
        timer.delayOneFrame(function()
            logger:debug("Picking up after frame")
            carryable:getSafeInstance()
            carryable:pickup{ doPlaySound = true}
        end)
    end)
    return pickupButton
end

---@param menu tes3uiElement
---@param carryable CarryableMisc
function Container.addButtons(menu, carryable)
    menu = menu:getContentElement()

    -- disable UI Expansions filter block
    local uiExp = menu:findChild("UIEXP:ContentsMenu:FilterBlock")
    if uiExp then
        tes3ui.acquireTextInput(nil)
        uiExp.visible = false
    end

    local doFilterLabel = false
    local filter = carryable:getFilter()
    if filter and doFilterLabel then
        local headerBlock = menu:getTopLevelMenu():findChild("PartDragMenu_title_tint")
        local title = headerBlock:findChild("PartDragMenu_title")
        title.borderRight = 0
        local filterLabel = createFilterLabel(headerBlock, filter)
        headerBlock:reorderChildren(-2, filterLabel, 1)
    end

    local takeAllButton = menu:findChild("MenuContents_takeallbutton")
    local buttonBlock = takeAllButton.parent
    --addTopRow(menu, carryable)
    replaceTakeAllButton(menu, carryable)

    local pickupButton = addPickupButton(buttonBlock, carryable, menu)
    if pickupButton then
        local closeButton = menu:findChild("MenuContents_closebutton")
        pickupButton.parent:reorderChildren(closeButton, pickupButton, 1)
    end

    --Filter button on bottom row
    if carryable:getFilter() then
        local transferButton = createFilterButton(buttonBlock, menu, carryable)
        buttonBlock:reorderChildren(takeAllButton, transferButton, 1)
    end

    local renameButton = addRenameButton(buttonBlock, carryable)
    buttonBlock:reorderChildren(-2, renameButton, 1)

    menu:updateLayout()
end

return Container