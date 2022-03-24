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
            description = { type = "string", required = false },
            placedObject = { type = "string", required = false },
            uncarryable = { type = "boolean", required = false },
            additionalMenuOptions = { type = "table", required = false },
            soundId = { type = "string", required = false },
            soundPath = { type = "string", required = false },
            soundType = { type = "string", required = false },
            materialRecovery = { type = "number", required = false},
            maxSteepness = { type = "number", required = false},
            resultAmount = { type = "number", required = false}
        }
    },
    constructionSounds = {
        fabric = {
            "craftingFramework\\craft\\Fabric1.wav",
            "craftingFramework\\craft\\Fabric2.wav",
            "craftingFramework\\craft\\Fabric3.wav",
            "craftingFramework\\craft\\Fabric4.wav",
        },
        wood = {
            "craftingFramework\\craft\\Wood1.wav",
            "craftingFramework\\craft\\Wood2.wav",
            "craftingFramework\\craft\\Wood3.wav",
        },
        leather = {
            "craftingFramework\\craft\\Leather1.wav",
            "craftingFramework\\craft\\Leather2.wav",
            "craftingFramework\\craft\\Leather3.wav",
        },
        rope = {
            "craftingFramework\\craft\\Rope1.wav",
            "craftingFramework\\craft\\Rope2.wav",
            "craftingFramework\\craft\\Rope3.wav",
        },
        straw = {
            "craftingFramework\\craft\\Straw1.wav",
            "craftingFramework\\craft\\Straw2.wav",
        },
        metal = {
            "craftingFramework\\craft\\Metal1.wav",
            "craftingFramework\\craft\\Metal2.wav",
            "craftingFramework\\craft\\Metal3.wav",
        },
        default = {
            "craftingFramework\\craft\\Fabric1.wav",
            "craftingFramework\\craft\\Fabric2.wav",
            "craftingFramework\\craft\\Fabric3.wav",
            "craftingFramework\\craft\\Fabric4.wav",
        }
    },
    deconstructionSounds = {
        "craftingFramework\\craft\\Deconstruct1.wav",
        "craftingFramework\\craft\\Deconstruct2.wav",
        "craftingFramework\\craft\\Deconstruct3.wav",
    },

}


Craftable.registeredCraftables = {}
--Static functions

function Craftable.getCraftable(id)
    return Craftable.registeredCraftables[id]
end

function Craftable.getPlacedCraftable(id)
    for _, craftable in pairs(Craftable.registeredCraftables) do
        if craftable.placedObject == id:lower() then return craftable end
    end
end

local function isCarryable(id)
    local unCarryableTypes = {
        [tes3.objectType.light] = true,
        [tes3.objectType.container] = true,
        [tes3.objectType.static] = true,
        [tes3.objectType.door] = true,
        [tes3.objectType.activator] = true,
        [tes3.objectType.npc] = true,
        [tes3.objectType.creature] = true,
    }
    local placedObject = tes3.getObject(id)
    if placedObject then
        if placedObject.canCarry then
            return true
        end
        local objType = placedObject.objectType

        if unCarryableTypes[objType] then
            return false
        end
        return true
    end
end
--Methods

function Craftable:new(data)
    Util.validate(data, Craftable.schema)
    data.id = data.id:lower()
    if data.uncarryable == nil then
        data.uncarryable = not isCarryable(data.id)
    end
    if data.uncarryable and not data.placedObject then
        data.placedObject = data.id
    end
    setmetatable(data, self)
    self.__index = self
    Craftable.registeredCraftables[data.id] = data
    data:registerEvents()
    return data
end

function Craftable:registerEvents()
    if self.placedObject then
        event.register("CraftingFramework:CraftableActivated", function(e)
            if Util.isShiftDown() and Util.canBeActivated(e.reference) then
                e.reference.data.allowActivate = true
                tes3.player:activate(e.reference)
                e.reference.data.allowActivate = nil
            else
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
        callbackParams = { reference = reference }
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
    ref.data.positionerMaxSteepness = self.maxSteepness

    Util.deleteRef(reference)
end

function Craftable:getDescription()
    return self.description
end

function Craftable:getMenuButtons(reference)
    local menuButtons = {}
    if self.additionalMenuOptions then
        for _, option in ipairs(self.additionalMenuOptions) do
            table.insert(menuButtons, {
                text = option.text,
                callback = function()
                    option.callback({
                        reference = reference
                    })
                end
            })
        end
    end
    local defaultButtons = {
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
            text = "Pick Up",
            showRequirements = function()
                return not self.uncarryable
            end,
            callback = function()
                self:pickUp(reference)
            end
        },
        {
            text = "Destroy",
            showRequirements = function()
                return self.uncarryable
            end,
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
    self:playDeconstructingSound()
    local destroyMessage = string.format("%s has been destroyed.", self:getName())

    --check if materials are recovered
    if reference.data.materialsUsed  then

        local recoverMessage = "You recover the following materials:"
        local didRecover = false
        for id, count in pairs(reference.data.materialsUsed) do
            local item = tes3.getObject(id)
            local recoveryRatio = (self.materialRecovery or config.mcm.defaultMaterialRecovery) / 100
            local recoveredCount = math.floor(count * math.clamp(recoveryRatio, 0, 1) )
            if item and recoveredCount > 0 then
                didRecover = true
                recoverMessage = recoverMessage .. string.format("\n- %s x%d", item.name, recoveredCount )
                tes3.addItem{
                    reference = tes3.player,
                    item = item,
                    count = recoveredCount,
                    playSound = false,
                    updateGUI = false
                }
            end
        end
        tes3ui.updateInventoryTiles()
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

function Craftable:getNameWithCount()
    return string.format("%s%s", self:getName(),
        self.resultAmount and string.format(" x%d", self.resultAmount) or ""
    )
end

function Craftable:playCraftingSound()
    if self.soundType then
        local soundPick = table.choice(self.constructionSounds[self.soundType])
        if soundPick then
            tes3.playSound{ soundPath = soundPick}
            return
        end
    end
    if self.soundId then
        tes3.playSound{ sound = self.soundId }
    elseif self.soundPath then
        tes3.playSound{ soundPath = self.soundPath }
    else
        local soundPick = table.choice(self.constructionSounds.default)
        tes3.playSound{ soundPath = soundPick }
    end
end

function Craftable:playDeconstructingSound()
    local soundPick = table.choice(self.deconstructionSounds)
    tes3.playSound{soundPath = soundPick }
end

function Craftable:craft(materialsUsed)
    if self.uncarryable then
        self:position(self:place(materialsUsed))
    else
        local item = tes3.getObject(self.id)
        if item then
            tes3.addItem{
                reference = tes3.player,
                item = item, playSound = false,
                count = self.resultAmount or 1,
            }
            tes3.messageBox("You successfully crafted %s%s.",
                item.name,
                self.resultAmount and string.format(" x%d", self.resultAmount) or ""
            )
        end
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
    local position = eyePos + eyeOri * rayDist

    local ref = tes3.createReference{
        object = self.placedObject,
        cell = tes3.player.cell,
        orientation = tes3.player.orientation:copy() + tes3vector3.new(0, 0, math.pi),
        position = position
    }
    ref.data.crafted = true
    ref.data.positionerMaxSteepness = self.maxSteepness
    ref.data.materialsUsed = materialsUsed
    ref:updateSceneGraph()
    ref.sceneNode:updateNodeEffects()
    return ref
end

return Craftable