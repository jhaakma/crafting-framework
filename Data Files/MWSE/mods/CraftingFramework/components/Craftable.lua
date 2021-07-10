local Util = require("CraftingFramework.util.Util")
local Positioner = require("CraftingFramework.controllers.Positioner")
local MenuButton = require("CraftingFramework.components.MenuButton")
local config = require("CraftingFramework.config")

local Craftable = {
    schema = {
        name = "Craftable",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = false },
            miscObject = { type = "string", required = false },
            placedObject = { type = "string", required = false },
            additionalMenuOptions = { type = "table", childType = MenuButton.schema, required = false },
            soundId = { type = "string", required = false },
            soundPath = { type = "string", required = false },
            materialRecovery = { type = "number", required = false},
        }
    }
}

Craftable.registeredCraftables = {}
function Craftable.getCraftable(id)
    return Craftable.registeredCraftables[id]
end

function Craftable.getPlacedCraftable(id)
    for _, craftable in pairs(Craftable.registeredCraftables) do
        if craftable.placedObject == id:lower() then return craftable end
    end
end

function Craftable:new(data)
    --Util.validate(data, Craftable.schema)
    data.id = data.id:lower()
    setmetatable(data, self)
    self.__index = self
    Craftable.registeredCraftables[data.id] = data
    data:registerEvents()
    return data
end

function Craftable:registerEvents()
    if self.placedObject then
        mwse.log("Registering events for %s", self.id)
        event.register("CraftingFramework:CraftableActivated", function(e)
            if Util.isShiftDown() and Util.canBeActivated(e.reference) then
                e.reference.data.allowActivate = true
                tes3.player:activate(e.reference)
                e.reference.data.allowActivate = nil
            else
                mwse.log("Activated %s", self.placedObject)
                self:activate(e.reference)
            end
        end, { filter = self.placedObject:lower() })

        event.register("itemDropped", function(e)
            if self.placedObject and e.reference.baseObject.id:lower() == self.id then
                self:swap(e.reference)
            end
        end)
    end
end

function Craftable:activate(reference)
    Util.messageBox{
        message = self:getName(),
        buttons = self:getMenuButtons(reference),
        doesCancel = true,
    }
end

function Craftable:swap(reference)
    local ref = tes3.createReference{
        object = self.placedObject,
        position = reference.position:copy(),
        orientation = reference.orientation:copy(),
        cell = reference.cell
    }
    ref.data.crafted = true
    Util.deleteRef(reference)
end

function Craftable:getMenuButtons(reference)
    local menuButtons = {}
    if self.additionalMenuOptions then
        for _, option in ipairs(self.additionalMenuOptions) do
            table.insert(menuButtons, option)
        end
    end
    local defaultButtons = {
        {
            text = "Pick Up",
            showRequirements = function()
                return self.miscItem ~= nil
            end,
            callback = function()
                self:pickUp(reference)
            end
        },
        {
            text = "Open",
            showRequirements = function()
                return reference.object.objectType == tes3.objectType.container
            end,
            callback = function()
                timer.delayOneFrame(function() 
                    reference.data.allowActivate = true
                    tes3.player:activate(reference)
                    reference.data.allowActivate = nil
                end)
            end
        },
        {
            text = "Position",
            callback = function()
                self:position(reference)
            end
        },
        {
            text = "Destroy",
            callback = function()
                Util.messageBox{
                    message = string.format("Destroy %s?", self:getName()),
                    buttons = {
                        { 
                            text = "Yes",
                            callback = function()
                                self:destroy(reference)
                            end
                        },

                    },
                    doesCancel = true
                }
               
            end
        }
    }

    for _, button in ipairs(defaultButtons) do
        table.insert(menuButtons, button)
    end
    return menuButtons
end

function Craftable:position(reference)

    timer.delayOneFrame(function()
        -- Put those hands away.
        if (tes3.mobilePlayer.weaponReady) then
            tes3.mobilePlayer.weaponReady = false
        elseif (tes3.mobilePlayer.castReady) then
            tes3.mobilePlayer.castReady = false
        end
        Positioner.togglePlacement{ target = reference }
    end)
end

function Craftable:transferItems(reference)
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
        if #itemList > 0 then
            tes3.messageBox("Contents of %s added to inventory.", self:getName(reference))
        end
    end
end

function Craftable:pickUp(reference)
    self:transferItems(reference)
    tes3.addItem{ reference = tes3.player, item = self.id }
    Util.deleteRef(reference)
end

function Craftable:destroy(reference)
    self:transferItems(reference)
    -- play a destroy sound
    tes3.playSound{ sound = "repair fail", pitch = 0.2 }
    local destroyMessage = string.format("%s has been destroyed.", self:getName())

    --check if materials are recovered
    if reference.data.materialsUsed  then
        
        local recoverMessage = "You recover the following materials:"
        local didRecover = false
        for id, count in pairs(reference.data.materialsUsed) do
            local item = tes3.getObject(id)
            local recoveryRatio = self.materialRecovery or config.mcm.defaultMaterialRecovery
            local recoveredCount = math.floor(count * math.clamp(recoveryRatio, 0, 1) )
            if item and recoveredCount > 0 then
                didRecover = true
                recoverMessage = recoverMessage .. string.format("\n- %s x%d", item.name, recoveredCount )
                tes3.addItem{
                    reference = tes3.player,
                    item = item,
                    count = recoveredCount
                }
            end
        end
        if didRecover then
            destroyMessage = recoverMessage
        end
    end
    tes3.messageBox(destroyMessage)

    reference.sceneNode.appCulled = true
    tes3.positionCell{
        reference = reference, 
        position = { 0, 0, 0, },
    }
    reference:disable()
    timer.delayOneFrame(function()
        mwscript.setDelete{ reference = reference}
    end)
end

function Craftable:getName()
    return self.name or tes3.getObject(self.id) and tes3.getObject(self.id).name or "[unknown]"
end

function Craftable:playCraftingSound()

    if self.soundId then
        tes3.playSound{ sound = self.soundId }
    elseif self.soundPath then
        tes3.playSound{ soundPath = self.soundPath }
    else
        tes3.playSound{ soundPath = "furncraft\\craft.wav" }
    end
end

function Craftable:craft(materialsUsed)
    if self.miscObject then
        local item = tes3.getObject(self.miscObject)
        if item then
            tes3.playSound{ soundPath = "ashfall\\craft.wav"}
            tes3.addItem{ reference = tes3.player, item = item, playSound = false }
            tes3.messageBox("You successfully crafted %s.", item.name)
        end
    else
        self:position(self:place(materialsUsed))
    end
    self:playCraftingSound()
    
end

function Craftable:place(materialsUsed)
    local eyeOri = tes3.getPlayerEyeVector()
    local eyePos = tes3.getPlayerEyePosition()
    local ray = tes3.rayTest{ 
        position = tes3.getPlayerEyePosition(), 
        direction = tes3.getPlayerEyeVector(),
        ignore = { tes3.player}
    }
    local rayDist = ray and ray.intersection and math.min(ray.distance -5, 200) or 0

    if not ray then
        mwse.log("WTF why no ray?")
        end
    if not ray.intersection then
        mwse.log("WTF why no intersection?")
    end

    local position = eyePos + eyeOri * rayDist
    
    local ref = tes3.createReference{
        object = self.placedObject,
        cell = tes3.player.cell,
        orientation = tes3.player.orientation:copy() + tes3vector3.new(0, 0, math.pi),
        position = position
    }
    ref.data.crafted = true
    ref.data.materialsUsed = materialsUsed
    ref:updateSceneGraph()
    ref.sceneNode:updateNodeEffects()
    return ref
end

return Craftable