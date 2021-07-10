local Material = require("CraftingFramework.components.Material")
local Util = require("CraftingFramework.util.Util")
local Tool = require("CraftingFramework.components.Tool")
local this = {}

local selectedRecipe

local menuConfig = {
    menuWidth = 500,
    menuHeight = 700,
    previewHeight = 270,
    previewWidth= 300,
    previewYOffset = -200
}

local uiids = {
    titleBlock = tes3ui.registerID("Crafting_Menu_TitleBlock"),
    craftingMenu = tes3ui.registerID("CustomMessageBox"),
    midBlock = tes3ui.registerID("Crafting_Menu_MidBlock"),
    previewBorder = tes3ui.registerID("Crafting_Menu_PreviewBorder"),
    previewBlock = tes3ui.registerID("Crafting_Menu_PreviewBlock"),
    nifPreviewBlock = tes3ui.registerID("Crafting_Menu_NifPreviewBlock"),
    imagePreviewBlock = tes3ui.registerID("Crafting_Menu_ImagePreviewBlock"),
    selectedItem = tes3ui.registerID("Crafting_Menu_SelectedResource"),
    nif = tes3ui.registerID("Crafting_Menu_NifPreview"),
    descriptionBlock = tes3ui.registerID("Crafting_Menu_DescriptionBlock"),
    buttonsBlock = tes3ui.registerID("Crafting_Menu_ButtonsBlock"),
    recipeListPane = tes3ui.registerID("Crafting_Menu_RecipeListBlock"),
    previewPane = tes3ui.registerID("Crafting_Menu_PreviewPane"),
    previewName = tes3ui.registerID("Crafting_Menu_PreviewName"),
    previewDescription = tes3ui.registerID("Crafting_Menu_PreviewDescription"),
    requirementsPane = tes3ui.registerID("Crafting_Menu_RequirementsPane"),
    toolsPane = tes3ui.registerID("Crafting_Menu_ToolsPane"),
    toolsContainer = tes3ui.registerID("Crafting_Menu_ToolsContainer"),
    createItemButton = tes3ui.registerID("Crafting_Menu_CreateItemButton"),
    unlockPackButton = tes3ui.registerID("Crafting_Menu_UnlockPackButton"),
}
local m1 = tes3matrix33.new()
local m2 = tes3matrix33.new()

local function closeMenu()
    local menu = tes3ui.findMenu(uiids.craftingMenu)
    if  menu then 
        menu:destroy()
        tes3ui.leaveMenuMode()
    end
end


local function craftItem()
    if not selectedRecipe then return end
    selectedRecipe:craft()
    closeMenu()
end

local menuButtons = {
    {
        id = tes3ui.registerID("Ashfall_Button_CraftItem"),
        name = "Craft",
        callback = craftItem,
        requirements = function() 
            return selectedRecipe:checkCanCraft()
        end
    },
    {
        id = tes3ui.registerID("CustomMessageBox_CancelButton"),
        name = "Cancel",
        callback = closeMenu
    }
}


local function removeCollision(sceneNode)
    for node in Util.traverseRoots{sceneNode} do
        if node:isInstanceOfType(tes3.niType.RootCollisionNode) then
            node.appCulled = true
        end
    end
end


local function toggleButtonDisabled(button, isVisible, isDisabled)
    button.visible = isVisible
    button.widget.state = isDisabled and 2 or 1
    button.disabled = isDisabled
    if isDisabled then
        button:register("help", function()
            local tooltip = tes3ui.createTooltipMenu()
            tooltip:createLabel{ text = "You do not have the necessary materials."}
        end)
    end
end

local function updateToolsPane(recipe)
    local craftingMenu = tes3ui.findMenu(uiids.craftingMenu)
    if not craftingMenu then return end
    local toolsContainer = craftingMenu:findChild(uiids.toolsContainer)
    local list = craftingMenu:findChild(uiids.toolsPane)
    list:getContentElement():destroyChildren()
    if #recipe.tools < 1 then 
        toolsContainer.visible = false
    else
        toolsContainer.visible = true
        for _, toolReq in ipairs(recipe.tools) do
            local tool = Tool.getTool(toolReq.tool)
            if tool then
                local text = string.format("%s x %G", tool.name, (toolReq.count or 1) )
                if toolReq.equipped then
                    if tool:checkToolEquipped(toolReq) then
                        text = string.format("%s (Equipped)", tool.name)
                    else
                        text = string.format("%s (Not Equipped)", tool.name)
                    end
                end
                if not tool:hasToolCondition(toolReq) then
                    text = string.format("%s (Broken)", tool.name)
                end

                local requirement = list:createLabel()
                requirement.borderAllSides = 2
                requirement.text = text

                requirement:register("help", function()
                    local tooltip = tes3ui.createTooltipMenu()
                    local outerBlock = tooltip:createBlock()
                    outerBlock.flowDirection = "top_to_bottom"
                    outerBlock.paddingTop = 6
                    outerBlock.paddingBottom = 12
                    outerBlock.paddingLeft = 6
                    outerBlock.paddingRight = 6
                    outerBlock.maxWidth = 300
                    outerBlock.autoWidth = true
                    outerBlock.autoHeight = true   
                    outerBlock.childAlignX = 0.5
        
                    local header =  outerBlock:createLabel{ text = tool.name}
                    header.color = tes3ui.getPalette("header_color")
        
                    for _, id in ipairs(tool.ids) do
                        local item = tes3.getObject(id)
                        if item then
                            local itemCount = mwscript.getItemCount{ reference = tes3.player, item = item }
                            local block = outerBlock:createBlock{}
                            block.flowDirection = "left_to_right"
                            block.autoHeight = true
                            block.autoWidth = true
                            block.childAlignX = 0.5
        
                            local image = block:createImage{path=("icons\\" .. item.icon)}
                            local text = string.format("%s (%G)", item.name, itemCount)
                            
                            if toolReq.equipped then
                                if Tool.checkToolEquipped(item, toolReq) then
                                    text = string.format("%s (Equipped)", item.name)
                                else
                                    text = string.format("%s (Not Equipped)", item.name)
                                end
                            end
                            if not Tool.checkToolCondition(item, toolReq) then
                                text = string.format("%s (Broken)", item.name)
                            end
                            local text = block:createLabel{ text = text}
                            text.borderAllSides = 4
        
                            if not Tool.checkToolRequirements(id, toolReq) then
                                text.color = tes3ui.getPalette("disabled_color")
                            end
                        end
                    end
                end)
                    
                if tool:hasTool(toolReq) then
                    requirement.color = tes3ui.getPalette("normal_color")  
                else
                    requirement.color = tes3ui.getPalette("disabled_color")
                end
            end
        end
    end
end

local function updateRequirementsPane(recipe)
    local craftingMenu = tes3ui.findMenu(uiids.craftingMenu)
    if not craftingMenu then return end

    local list = craftingMenu:findChild(uiids.requirementsPane)
    list:getContentElement():destroyChildren()
    for _, materialReq in ipairs(recipe.materials) do
        local material = Material.getMaterial(materialReq.material)

        local name = material:getName()
        local text = string.format("%s x %G", name, materialReq.count )
        local requirement = list:createLabel()
        requirement.borderAllSides = 2
        requirement.text = text

        requirement:register("help", function()
            local tooltip = tes3ui.createTooltipMenu()
            local outerBlock = tooltip:createBlock()
            outerBlock.flowDirection = "top_to_bottom"
            outerBlock.paddingTop = 6
            outerBlock.paddingBottom = 12
            outerBlock.paddingLeft = 6
            outerBlock.paddingRight = 6
            outerBlock.maxWidth = 300
            outerBlock.autoWidth = true
            outerBlock.autoHeight = true   
            outerBlock.childAlignX = 0.5

            local header =  outerBlock:createLabel{ text = name}
            header.color = tes3ui.getPalette("header_color")


            for _, id in ipairs(material.ids) do
                local item = tes3.getObject(id)
                if item then
                    local itemCount = mwscript.getItemCount{ reference = tes3.player, item = item }
                    local block = outerBlock:createBlock{}
                    block.flowDirection = "left_to_right"
                    block.autoHeight = true
                    block.autoWidth = true
                    block.childAlignX = 0.5

                    local image = block:createImage{path=("icons\\" .. item.icon)}
                    local text = string.format("%s (%G)", item.name, itemCount)
                    local text = block:createLabel{ text = text}
                    text.borderAllSides = 4

                    if itemCount <= 0 then
                        text.color = tes3ui.getPalette("disabled_color")
                    end
                end
            end
        end)
            
        
        if material:checkHasIngredient(materialReq.count) then
            requirement.color = tes3ui.getPalette("normal_color")  
        else
            requirement.color = tes3ui.getPalette("disabled_color")
        end
    end
end


local function updateDescriptionPane(recipe)
    local craftingMenu = tes3ui.findMenu(uiids.craftingMenu)
    if not craftingMenu then return end

    local label = craftingMenu:findChild(uiids.selectedItem)
    if label then
        label.text = recipe.craftable.name
    end

    local description = craftingMenu:findChild(uiids.previewDescription)
    if description then
        description.text = recipe.description or ""
    end
end

local function updatePreviewPane(recipe)
    local craftingMenu = tes3ui.findMenu(uiids.craftingMenu)
    if not craftingMenu then return end

    local item = recipe:getItem()
    if item then 
        --nifPreviewBLock
        local nifPreviewBlock = craftingMenu:findChild(uiids.nifPreviewBlock)
        if nifPreviewBlock then 
            nifPreviewBlock:destroyChildren()
            local mesh = recipe.mesh or item.mesh
            local nif = nifPreviewBlock:createNif{ id = uiids.nif, path = mesh}
            if not nif then return end 
            --nif.scaleMode = true
            craftingMenu:updateLayout()
            


            local node = nif.sceneNode
            Util.removeLight(node)
            removeCollision(node)
            node:update()

            local maxDimension
            local bb = node:createBoundingBox(node.scale)

            --get size from bounding box

            local height = bb.max.z - bb.min.z
            local width = bb.max.y - bb.min.y
            local depth = bb.max.x - bb.min.x

            maxDimension = math.max(width, depth, height)
            --local maxDimension = node.worldBoundRadius

            local targetHeight = 150
            node.scale = targetHeight / maxDimension

            local lowestPoint = bb.min.z
            node.translation.z = node.translation.z - lowestPoint*node.scale 

            do --add properties
                local vertexColorProperty = niVertexColorProperty.new()
                vertexColorProperty.name = "vcol yo"
                vertexColorProperty.source = 2
                node:attachProperty(vertexColorProperty)

                local zBufferProperty = niZBufferProperty.new()
                zBufferProperty.name = "zbuf yo"
                zBufferProperty:setFlag(true, 0)
                zBufferProperty:setFlag(true, 1)
                node:attachProperty(zBufferProperty)
            end

            m1:toRotationX(math.rad(-15))
            m2:toRotationZ(math.rad(180))
            node.rotation = node.rotation * m1:copy() * m2:copy()
            
            
            node.appCulled = false
            node:updateProperties()
            node:update()
            nifPreviewBlock:updateLayout()
        end
    end
    --updateBuyButtons()
end
local function updateButtons()
    local craftingMenu = tes3ui.findMenu(uiids.craftingMenu)
    if not craftingMenu then return end
    for _, buttonConf in ipairs(menuButtons) do
        local button = craftingMenu:findChild(buttonConf.id)
        if buttonConf.requirements and buttonConf.requirements() ~= true then
            toggleButtonDisabled(button, true, true)
        else
            toggleButtonDisabled(button, true, false)
            button:register("mouseClick", buttonConf.callback)
        end
    end
end

local function updateMenu(recipe)
    selectedRecipe = recipe
    updatePreviewPane(recipe)
    updateDescriptionPane(recipe)
    updateRequirementsPane(recipe)
    updateToolsPane(recipe)
    updateButtons()
end

local function populateRecipeList(recipeList)
    local craftingMenu = tes3ui.findMenu(uiids.craftingMenu)
    if not craftingMenu then return end

    local list = craftingMenu:findChild(uiids.recipeListPane)
    list:getContentElement():destroyChildren()
    

    table.sort(recipeList, function(a,b) return a.craftable.name < b.craftable.name end)

    for _, recipe in ipairs(recipeList) do
        if recipe:isKnown() then
            local button = list:createTextSelect()
            button.borderAllSides = 2
            button.text = recipe.craftable.name
            if not recipe:checkCanCraft() then
                button.color = tes3ui.getPalette("disabled_color")
                button.widget.idle = tes3ui.getPalette("disabled_color")
            end
            button:register("mouseClick", function()
                updateMenu(recipe)
            end)
        end
    end
end

local function rotateNif(e)
    local menu = tes3ui.findMenu(uiids.craftingMenu)
    if not menu then 
        event.unregister("enterFrame", rotateNif)
        return 
    end
    local nif = menu:findChild(uiids.nif)
    
    if nif and nif.sceneNode then
        local node = nif.sceneNode
        

        m2:toRotationZ(math.rad(15) * e.delta)
        node.rotation = node.rotation * m2

        node:update()
    end
end

local function resourceSorter(a, b)
	return a.name:lower() < b.name:lower()
end



local function createPreviewPane(parent)
    local previewBorder = parent:createThinBorder{ id = uiids.previewBorder }
    --previewBorder.width = menuConfig.previewWidth
    previewBorder.flowDirection = "top_to_bottom"
    previewBorder.widthProportional= 1
    previewBorder.autoHeight = true
    previewBorder.childAlignX = 0.5
    --previewBorder.absolutePosAlignX = 0


    local nifPreviewBlock = previewBorder:createBlock{ id = uiids.nifPreviewBlock }
    --nifPreviewBlock.width = menuConfig.previewWidth
    nifPreviewBlock.width = menuConfig.previewWidth
    nifPreviewBlock.height = menuConfig.previewHeight

    nifPreviewBlock.childOffsetX = menuConfig.previewWidth/2
    nifPreviewBlock.childOffsetY = menuConfig.previewYOffset
    nifPreviewBlock.paddingAllSides = 2
end

local function createLeftToRightBlock(parent)
    local block = parent:createBlock()
    block.widthProportional = 1.0
    block.heightProportional = 1.0
    block.flowDirection = "left_to_right"
    return block
end

local function createTopToBottomBlock(parent)
    local block = parent:createBlock()
    block.widthProportional = 1.0
    block.heightProportional = 1.0
    block.flowDirection = "top_to_bottom"
    return block
end

local function createTitle(block, titleName)
    local title = block:createLabel{ }
    title.text = titleName
    title.color = tes3ui.getPalette("header_color")
    return title
end

local function createTitleBlock(parent, title)
    local titleBlock = parent:createBlock{ id = uiids.titleBlock }
    titleBlock.flowDirection = "top_to_bottom"
    titleBlock.childAlignX = 0.5
    titleBlock.autoHeight = true
    titleBlock.widthProportional = 1.0
    titleBlock.borderBottom = 10
    createTitle(titleBlock, title)
    return titleBlock
end



local function createRecipeListPane(parent)
    local block = parent:createThinBorder{}
    block.flowDirection = "top_to_bottom"
    block.paddingAllSides = 10
    block.widthProportional = 1.0
    block.heightProportional = 1.0
    
    local title = block:createLabel()
    title.color = tes3ui.getPalette("header_color")
    title.text = "Recipes:"

    local recipeListPane = block:createVerticalScrollPane({ id = uiids.recipeListPane})
    recipeListPane.borderTop = 4
    recipeListPane.widthProportional = 1.0
    recipeListPane.heightProportional = 1.0
    return block
end


local function createDescriptionPane(parent)
    local descriptionBlock = parent:createThinBorder{ ids = uiids.descriptionBlock}
    descriptionBlock.flowDirection = "top_to_bottom"
    descriptionBlock.paddingAllSides = 10
    descriptionBlock.widthProportional = 1.0
    descriptionBlock.autoHeight = true

    local selectedItemLabel = descriptionBlock:createLabel{ id = uiids.selectedItem }
    selectedItemLabel.autoWidth = true
    selectedItemLabel.autoHeight = true
    selectedItemLabel.text = ""
    selectedItemLabel.color = tes3ui.getPalette("header_color")

    local previewDescription = descriptionBlock:createLabel{ id = uiids.previewDescription }
    previewDescription.wrapText = true
    previewDescription.text = ""
    return descriptionBlock
end


local function createRequirementsPane(parent)
    local block = parent:createThinBorder{}
    block.flowDirection = "top_to_bottom"
    block.paddingAllSides = 10
    block.widthProportional = 1.0
    block.heightProportional = 1.0
    
    local title = block:createLabel()
    title.color = tes3ui.getPalette("header_color")
    title.text = "Materials:"

    local requirementsPane = block:createVerticalScrollPane({ id = uiids.requirementsPane})
    requirementsPane.borderTop = 4
    requirementsPane.widthProportional = 1.0
    requirementsPane.heightProportional = 1.0
end

local function createToolsPane(parent)
    local block = parent:createThinBorder{ id = uiids.toolsContainer}
    block.flowDirection = "top_to_bottom"
    block.paddingAllSides = 10
    block.widthProportional = 1.0
    block.height = 120
    
    local title = block:createLabel()
    title.color = tes3ui.getPalette("header_color")
    title.text = "Tools:"

    local toolsPane = block:createVerticalScrollPane({ id = uiids.toolsPane})
    toolsPane.borderTop = 4
    toolsPane.widthProportional = 1.0
    toolsPane.heightProportional = 1.0
end



local function createMenuButtonBlock(parent)
    local buttonsBlock = parent:createBlock{ id = uiids.buttonsBlock}
    buttonsBlock.autoHeight = true
    buttonsBlock.widthProportional = 1.0
    buttonsBlock.childAlignX = 1.0
    --buttonsBlock.absolutePosAlignX = 1
    --buttonsBlock.absolutePosAlignY = 1.0
    return buttonsBlock
end

local function addMenuButtons(parent)
    for _, buttonConf in ipairs(menuButtons) do
        local button = parent:createButton({ id = buttonConf.id})
        button.text = buttonConf.name
        button.borderLeft = 0
    end
end

function this.openMenu(menuActivator)
    local title = menuActivator.name
    local recipeList = menuActivator.recipes

    tes3.playSound{sound="Menu Click", reference=tes3.player}
    local craftingMenu = tes3ui.findMenu(uiids.craftingMenu)
    if craftingMenu then craftingMenu:destroy() end
    craftingMenu = tes3ui.createMenu{ id = uiids.craftingMenu, fixedFrame = true }
    craftingMenu.minWidth = menuConfig.menuWidth
    craftingMenu.minHeight = menuConfig.menuHeight

    --"Bushcrafting"
    createTitleBlock(craftingMenu, title)

    --Left to Right block. Recipe list on the left, results on the right
    local outerBlock = createLeftToRightBlock(craftingMenu)

    --recipes on the left
    local recipeBlock = createRecipeListPane(outerBlock)
    recipeBlock.widthProportional = 0.9
    
    --Results on the right, consisting of a preview pane, description, and requirements list
    local resultsBlock = createTopToBottomBlock(outerBlock)
    resultsBlock.widthProportional = 1.1
    createPreviewPane(resultsBlock)
    --createDescriptionPane(resultsBlock) 
    createToolsPane(resultsBlock)
    createRequirementsPane(resultsBlock)

    --Craft and Cancel buttons on the bottom
    local menuButtonBlock = createMenuButtonBlock(craftingMenu)
    addMenuButtons(menuButtonBlock)

    --Update all the windows
    populateRecipeList(recipeList)

    local initialRecipe = recipeList[1]
    updateMenu(initialRecipe)

    craftingMenu:updateLayout()
    tes3ui.enterMenuMode(uiids.craftingMenu)
    event.register("enterFrame", rotateNif)
end
return this