local Util = require("CraftingFramework.util.Util")
local logger = Util.createLogger("RecoverMaterials")
local Craftable = require("CraftingFramework.components.Craftable")
--[[
    When the player equips a crafted tool which has no durability,
    give the option to deconstruct it for materials
]]
---@param e equipEventData
local function recoverBrokenToolMaterials(e)
    logger:debug("Recovering broken tool materials")
    local materialsUsed = e.itemData.data.materialsUsed
    local recoverMessage = Craftable:recoverMaterials(materialsUsed)
    if recoverMessage then
        tes3.messageBox(recoverMessage)
    else
        tes3.messageBox("No materials recovered.")
    end
    logger:debug("removing %s from inventory", e.item.name)
    tes3.removeItem{
        reference = tes3.player,
        item = e.item,
        itemData = e.itemData,
        count = 1,
        playSound = false,
    }
    Craftable:playDeconstructionSound()
end

local function showRecoverMaterialsMessage(e)
    if not e.itemData then
        return
    end
    local isBroken = e.itemData.condition and e.itemData.condition <= 0
    local materialsUsed = e.itemData.data.materialsUsed
    if isBroken and materialsUsed then
        logger:debug("Item is broken, showing recover materials message")
        Util.messageBox{
            message = string.format("%s is broken.", e.item.name),
            buttons = {
                {
                    text = "Recover Materials",
                    callback = function()
                        recoverBrokenToolMaterials(e)
                    end
                }
            },
            doesCancel = true,
        }
        return false
    end
end

event.register("equip", showRecoverMaterialsMessage)