local Util = require("CraftingFramework.util.Util")
local Indicator = require("CraftingFramework.controllers.Indicator")
local logger = Util.createLogger("StaticActivator")
local config = require("CraftingFramework.config")
---@class CraftingFramework
---@field StaticActivator CraftingFramework.StaticActivator
local CF = require("CraftingFramework")

---@class CraftingFramework.StaticActivator
CF.StaticActivator = {
    registeredObjects = {}
}

---@class CraftingFramework.StaticActivator.data : CraftingFramework.Indicator.data
---@field onActivate fun(reference: tes3reference) @Called when the object is activated

---@param data CraftingFramework.StaticActivator.data
function CF.StaticActivator.register(data)
    logger:assert(type(data.objectId) == "string", "objectId must be a string")
    logger:assert(type(data.onActivate) == "function", "onActivate must be a function. If you want a tooltip without an activator, register an Indciator instead")
    if CF.StaticActivator.registeredObjects[data.objectId:lower()] then
        logger:warn("Object %s is already registered", data.objectId)
    end
    CF.StaticActivator.registeredObjects[data.objectId:lower()] = data
    Indicator.register(data)
    logger:debug("Registered %s as StaticActivator", data.objectId)
end

local isBlocked
local function blockScriptedActivate(e)
    logger:debug("BlockScriptedActivate doBlock: %s", e.doBlock)
    isBlocked = e.doBlock
end
event.register("BlockScriptedActivate", blockScriptedActivate)

local function doActivate(reference)
    logger:debug("Activating %s", reference.id)
    local data = CF.StaticActivator.registeredObjects[reference.baseObject.id:lower()]
    if data then
        event.trigger("BlockScriptedActivate", { doBlock = true })
        timer.delayOneFrame(function()
            event.trigger("BlockScriptedActivate", { doBlock = false })
        end)
        data.onActivate(reference)
    end
end

function CF.StaticActivator.doTriggerActivate()
    local activationBlocked =
        config.persistent.positioningActive
        or isBlocked
        or tes3ui.menuMode()
        or tes3.mobilePlayer.controlsDisabled
    if not activationBlocked then
        logger:debug("Triggered Activate")
        local ref = CF.StaticActivator.callRayTest{
            eventName = "CraftingFramework:StaticActivation"
        }
        if ref then
            doActivate(ref)
        end
    end
end

function CF.StaticActivator.callRayTest(e)
    local eyePos = tes3.getPlayerEyePosition()
    local eyeDirection = tes3.getPlayerEyeVector()
    --If in menu, use cursor position
    if tes3ui.menuMode() then
        local inventory = tes3ui.findMenu("MenuInventory")
        local inventoryVisible = inventory and inventory.visible == true
        if inventoryVisible then
            local cursor = tes3.getCursorPosition()
            ---@diagnostic disable-next-line: undefined-field
            local camera = tes3.worldController.worldCamera.camera
            eyePos, eyeDirection = camera:windowPointToRay{cursor.x, cursor.y}
        end
    end

    if not (eyeDirection or eyeDirection) then return end
    local activationDistance = tes3.getPlayerActivationDistance()
    local result = tes3.rayTest{
        position = eyePos,
        direction = eyeDirection,
        ignore = { tes3.player },
        maxDistance = activationDistance,
    }
    if e.eventName then
        local eventData = {
            rayResult = result,
            reference = result and result.reference
        }
        event.trigger(e.eventName, eventData)
    end
    if result and result.reference then
        logger:trace("Updating indicator for: %s", result.reference.id)
        Indicator.update(result.reference)
        return result.reference
    end
    logger:trace("No reference found, disabling tooltip")
    Indicator.disable()
end

return CF.StaticActivator