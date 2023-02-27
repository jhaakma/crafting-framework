local orienter = include("CraftingFramework.controllers.Orienter")
local Util = require("CraftingFramework.util.Util")
local config = require("CraftingFramework.config")
local decals = require('CraftingFramework.controllers.Decals')
local m1 = tes3matrix33.new()
local logger = Util.createLogger("Positioner")
local CF = require("CraftingFramework")
CF.Positioner = {
    maxReach = 100,
    minReach = 100,
    currentReach = 500,
    holdKeyTime = 0.75,
    rotateMode = false,
    verticalMode = 0,
    wallAlignMode = true
}
local const_epsilon = 0.001
local function wrapRadians(x)
    return x % (2 * math.pi)
end

local settings = {
    free = 'free',
    ground = 'ground'
}
local endPlacement

local function isPlaceable(target)
    return target.data.crafted
end

local function getKeybindName(scancode)
    return tes3.findGMST(tes3.gmst.sKeyName_00 + scancode).value
end
-- Show keybind help overlay.
local function showGuide()
    local menu = tes3ui.findHelpLayerMenu(CF.Positioner.id_guide)

    if (menu) then
        menu.visible = true
        menu:updateLayout()
        return
    end

    menu = tes3ui.createHelpLayerMenu{ id = CF.Positioner.id_guide, fixedFrame = true }
    menu:destroyChildren()
    menu.disabled = true
    menu.absolutePosAlignX = 0.02
    menu.absolutePosAlignY = 0.04
    menu.color = {0, 0, 0}
    menu.alpha = 0.8
    menu.width = 330
    menu.autoWidth = false
    menu.autoHeight = true
    menu.paddingAllSides = 12
    menu.paddingLeft = 16
    menu.paddingRight = 16
    menu.flowDirection = "top_to_bottom"

    local function addLine(line, verb, scancode)
        local row = menu:createBlock{}
        row.widthProportional = 1.0
        row.autoHeight = true
        row.borderTop = 9
        row.borderBottom = 9
        row:createLabel{ text = line }
        local bind = row:createLabel{ text = verb .. getKeybindName(scancode) }
        bind.absolutePosAlignX = 1.0
    end

    addLine("Rotate", "Hold ", config.mcm.keybindRotate.keyCode)
    addLine("Cycle Drop Mode", "Press ", config.mcm.keybindModeCycle.keyCode)
    menu:updateLayout()

end

local function finalPlacement()
    logger:debug("finalPlacement()")
    CF.Positioner.shadow_model.appCulled = true
    CF.Positioner.lastItemOri = CF.Positioner.active.orientation:copy()

    if Util.isShiftDown() then
        CF.Positioner.active.position = CF.Positioner.itemInitialPos
        CF.Positioner.active.orientation = CF.Positioner.itemInitialOri
    end

    tes3.playSound{ sound = "Menu Click" }
    if CF.Positioner.active.baseObject.objectType == tes3.objectType.light then
        Util.removeLight(CF.Positioner.active.sceneNode)
        Util.onLight(CF.Positioner.active)
    end

    endPlacement()
end

local function doPinToWall()
    return config.persistent.placementSetting == settings.ground
        or CF.Positioner.pinToWall == true
end

-- Called every simulation frame to reposition the item.
local function simulatePlacement()
    CF.Positioner.maxReach = tes3.getPlayerActivationDistance()
    CF.Positioner.currentReach = math.min(CF.Positioner.currentReach, CF.Positioner.maxReach)
    if not CF.Positioner.active then
        return
    end
    -- Stop if player takes the object.
    if (CF.Positioner.active.deleted) then
        logger:debug("simulatePlacement: CF.Positioner.active is deleted, ending placement")
        endPlacement()
        return
    -- Check for glitches.
    elseif (CF.Positioner.active.sceneNode == nil) then
        logger:debug("simulatePlacement: sceneNode missing, ending placement")
        tes3.messageBox{ message = "Item location was lost. Placement reset."}
        CF.Positioner.active.position = CF.Positioner.itemInitialPos
        CF.Positioner.active.orientation = CF.Positioner.itemInitialOri
        endPlacement()
        return
    -- Drop item if player readies combat or casts a spell.
    elseif (tes3.mobilePlayer.weaponReady) then
        logger:debug("simulatePlacement: weapon ready, drop active")
        finalPlacement()
        return
    --Drop item if no longer able to manipulate
    elseif not config.persistent.positioningActive then
        logger:debug("simulatePlacement: not positioningActive, drop active")
        finalPlacement()
        return
    end

    local d_theta = tes3.player.orientation.z - CF.Positioner.playerLastOri.z
    -- Cast ray along initial pickup direction rotated by the 1st person camera.
    CF.Positioner.shadow_model.appCulled = true
    CF.Positioner.active.sceneNode.appCulled = true

    local eyePos = tes3.getPlayerEyePosition()
    local eyeVec = tes3.getPlayerEyeVector()
    ---The position from the player's view to the max distance
    local lookPos = eyePos + eyeVec * CF.Positioner.currentReach
    logger:trace("eyePos: %s, eyeVec: %s, lookPos: %s", eyePos, eyeVec, lookPos)

    if CF.Positioner.offset == nil then
        logger:trace("CF.Positioner.offset is nil, setting to lookPos - active.position")
        CF.Positioner.offset = lookPos - CF.Positioner.active.position
    else
        m1:toRotationZ(d_theta)
    end
    logger:trace("CF.Positioner.offset: %s", CF.Positioner.offset)

    ---The position to place the object
    ---@type any
    local targetPos = eyePos + eyeVec * CF.Positioner.currentReach - CF.Positioner.offset
    logger:trace("targetPos: %s", targetPos)

    if doPinToWall() then
        logger:trace("Pin to wall")
        local rayVec = (targetPos - eyePos):normalized()
        logger:trace("rayVec: %s", rayVec)
        local ray = tes3.rayTest{
            position = eyePos,
            direction = rayVec,
            ignore = { CF.Positioner.active, tes3.player },
            maxDistance = CF.Positioner.currentReach,
        }
        if ray then
            local width = math.min(CF.Positioner.boundMax.x - CF.Positioner.boundMin.x, CF.Positioner.boundMax.y - CF.Positioner.boundMin.y, CF.Positioner.boundMax.z - CF.Positioner.boundMin.z)
            logger:trace("width: %s", width)
            local distance = math.min(ray.distance, CF.Positioner.currentReach) - width
            logger:trace("distance: %s", distance)
            local diff = targetPos:distance(eyePos) - distance
            logger:trace("diff: %s", diff)
            targetPos = targetPos - rayVec * diff
            ---@cast targetPos tes3vector3
            logger:trace("new targetPos: %s", targetPos)
        end

        local dropPos = targetPos:copy()
        local rayhit = tes3.rayTest{
            position = CF.Positioner.active.position - tes3vector3.new(0, 0, CF.Positioner.offset.z),
            direction = tes3vector3.new(0, 0, -1),
            ignore = { CF.Positioner.active, tes3.player }
        }
        if (rayhit ) then
            dropPos = rayhit.intersection:copy()
            targetPos.z = math.max(targetPos.z, dropPos.z + (CF.Positioner.height or 0) )
        end

    end

    --targetPos.z = targetPos.z + const_epsilon


    -- Incrementally rotate the same amount as the player, to keep relative alignment with player.

    CF.Positioner.playerLastOri = tes3.player.orientation:copy()
    if (CF.Positioner.rotateMode) then
        -- Use inputController, as the player orientation is locked.
        logger:trace("rotate mode is active")
        local mouseX = tes3.worldController.inputController.mouseState.x
        logger:trace("mouse x: %s", tes3.worldController.inputController.mouseState.x)
        d_theta = 0.001 * 15 * mouseX
    end

    --logger:debug("simulatePlacement: position: %s", pos)
    -- Update item and shadow spot.
    CF.Positioner.active.sceneNode.appCulled = false
    CF.Positioner.active.position = targetPos
    CF.Positioner.active.orientation.z = wrapRadians(CF.Positioner.active.orientation.z + d_theta)

    local doOrient = config.persistent.placementSetting == settings.ground

    if doOrient then
        orienter.orientRefToGround{ ref = CF.Positioner.active, mode = config.persistent.placementSetting }
        --logger:debug("simulatePlacement: orienting %s", CF.Positioner.active.orientation)
    else
        CF.Positioner.active.orientation = tes3vector3.new(0, 0, CF.Positioner.active.orientation.z)
    end
end

-- cellChanged event handler.
local function cellChanged(e)
    -- To avoid problems, reset item if moving in or out of an interior cell.
    if (CF.Positioner.active.cell.isInterior or e.cell.isInterior) then
        tes3.messageBox{ message = "You cannot move items between cells. Placement reset."}
        CF.Positioner.active.position = CF.Positioner.itemInitialPos
        CF.Positioner.active.orientation = CF.Positioner.itemInitialOri
        endPlacement()
    end
end


-- Match vertical mode from an orientation.
local function matchVerticalMode(orient)
    if (math.abs(orient.x) > 0.1) then
        local k = math.floor(0.5 + orient.z / (0.5 * math.pi))
        if (k == 0) then
            CF.Positioner.verticalMode = 1
            CF.Positioner.height = -CF.Positioner.boundMin.y
        elseif (k == -1) then
            CF.Positioner.verticalMode = 2
            CF.Positioner.height = -CF.Positioner.boundMin.x
        elseif (k == 2) then
            CF.Positioner.verticalMode = 3
            CF.Positioner.height = CF.Positioner.boundMax.y
        elseif (k == 1) then
            CF.Positioner.verticalMode = 4
            CF.Positioner.height = CF.Positioner.boundMax.x
        end
    else
        CF.Positioner.verticalMode = 0
        CF.Positioner.height = -CF.Positioner.boundMin.z
    end
end


local function toggleBlockActivate()
    event.trigger("BlockScriptedActivate", { doBlock = true })
    timer.delayOneFrame(function()
        event.trigger("BlockScriptedActivate", { doBlock = false })
    end)
end


-- On grabbing / dropping an item.
CF.Positioner.togglePlacement = function(e)
    CF.Positioner.maxReach = tes3.getPlayerActivationDistance()
    e = e or { target = nil }
    --init settings
    CF.Positioner.pinToWall = e.pinToWall or false
    CF.Positioner.blockToggle = e.blockToggle or false

    config.persistent.placementSetting = config.persistent.placementSetting or "ground"
    logger:debug("togglePlacement")
    toggleBlockActivate()
    if CF.Positioner.active then
        logger:debug("togglePlacement: isActive, calling finalPlacement()")
        finalPlacement()
        return
    end

    local target
    if not e.target then
        logger:debug("togglePlacement: no target")
        if tes3.menuMode() then
            logger:debug("togglePlacement: menuMode, return")
            return
        end
        local ray = tes3.rayTest({
            position = tes3.getPlayerEyePosition(),
            direction = tes3.getPlayerEyeVector(),
            ignore = { tes3.player },
            maxDistance = CF.Positioner.maxReach,
            root = config.persistent.placementSetting == "ground"
                and tes3.game.worldLandscapeRoot or nil
        })

        target = ray and ray.reference
        if target and ray then
            logger:debug("togglePlacement: ray found target, doing reach stuff")
            CF.Positioner.offset = target.position - ray.intersection
            CF.Positioner.currentReach = ray and math.min(ray.distance, CF.Positioner.maxReach)
        end
    else
        logger:debug("togglePlacement: e.target, doing reach stuff")
        target = e.target
        local dist = target.position:distance(tes3.getPlayerEyePosition())
        CF.Positioner.currentReach = math.min(dist, CF.Positioner.maxReach)
        CF.Positioner.offset = nil
    end

    if not target then
        logger:debug("togglePlacement: no e.target or ray target, return")
        return
    end

    -- Filter by allowed object type.
    if not (isPlaceable(target) or e.nonCrafted ) then
        logger:debug("togglePlacement: not placeable")
        return
    end

    -- if target.position:distance(tes3.player.position) > CF.Positioner.maxReach  then
    --     logger:debug("togglePlacement: out of reach, return")
    --     return
    -- end

    -- Workaround to avoid dupe-on-load bug when moving non-persistent refs into another cell.
    if (target.sourceMod and not target.cell.isInterior) then
        tes3.messageBox{ message = "You must pick up and drop Positioner item first." }
        return
    end

    logger:debug("togglePlacement: passed checks, setting position variables")

    -- Calculate effective bounds including scale.
    CF.Positioner.boundMin = target.object.boundingBox.min * target.scale
    CF.Positioner.boundMax = target.object.boundingBox.max * target.scale
    matchVerticalMode(target.orientation)

    -- Get exact ray to selection point, relative to 1st person camera.
    local eye = tes3.getPlayerEyePosition()
    local basePos = target.position - tes3vector3.new(0, 0, CF.Positioner.height or 0)
    CF.Positioner.ray = tes3.worldController.armCamera.cameraRoot.worldTransform.rotation:transpose() * (basePos - eye)
    CF.Positioner.playerLastOri = tes3.player.orientation:copy()
    CF.Positioner.itemInitialPos = target.position:copy()
    CF.Positioner.itemInitialOri = target.orientation:copy()
    CF.Positioner.orientation = target.orientation:copy()


    CF.Positioner.active = target
    CF.Positioner.active.hasNoCollision = true
    decals.applyDecals(CF.Positioner.active, config.persistent.placementSetting)
    tes3.playSound{ sound = "Menu Click" }

    event.register("cellChanged", cellChanged)
    tes3ui.suppressTooltip(true)

    logger:debug("togglePlacement: showing guide")
    showGuide()

    config.persistent.positioningActive = true
    event.register("simulate", simulatePlacement)
end

---@param from tes3reference
---@param to tes3reference
local function copyRefData(from, to)
    if from.data then
        for k, v in pairs(from.data) do
            to.data[k] = v
        end
    end
end

---@param ref tes3reference
local function recreateRef(ref)
    ref:disable()
    ref:enable()
end

--pre-declared above
endPlacement = function()
    logger:debug("endPlacement()")
    if (CF.Positioner.matchTimer) then
        CF.Positioner.matchTimer:cancel()
    end
    recreateRef(CF.Positioner.active)
    decals.applyDecals(CF.Positioner.active)
    event.unregister("simulate", simulatePlacement)
    event.unregister("cellChanged", cellChanged)
    tes3ui.suppressTooltip(false)
    local ref = CF.Positioner.active
    CF.Positioner.active.hasNoCollision = false
    CF.Positioner.active = nil
    CF.Positioner.rotateMode = nil
    tes3.mobilePlayer.mouseLookDisabled = false

    local menu = tes3ui.findHelpLayerMenu(CF.Positioner.id_guide)
    if (menu) then
        menu:destroy()
    end
    timer.delayOneFrame(function()timer.delayOneFrame(function()
        config.persistent.positioningActive = nil
    end)end)
    event.trigger("CraftingFramework:EndPlacement", { reference = ref })
end


-- End placement on load game. CF.Positioner.active would be invalid after load.
local function onLoad()
    if (CF.Positioner.active) then
        endPlacement()
    end
end

local function rotateKeyDown(e)
    if (CF.Positioner.active) then
        if (e.keyCode == config.mcm.keybindRotate.keyCode) then
            logger:debug("rotateKeyDown")
            CF.Positioner.rotateMode = true
            tes3.mobilePlayer.mouseLookDisabled = true
            return false
        end
    end
end

local function rotateKeyUp(e)
    if (CF.Positioner.active) then
        if (e.keyCode == config.mcm.keybindRotate.keyCode) then
            logger:debug("rotateKeyUp")
            CF.Positioner.rotateMode = false
            tes3.mobilePlayer.mouseLookDisabled = false
        end
    end
end

local function toggleMode(e)
    if not config.persistent then return end
    if CF.Positioner.blockToggle then return end
    CF.Positioner.shadow_model = tes3.loadMesh("craftingFramework/shadow.nif")
    if (config.persistent.positioningActive) then
        if (e.keyCode == config.mcm.keybindModeCycle.keyCode) then

            local cycle = {
                [settings.free] = settings.ground,
                [settings.ground] = settings.free
            }

            config.persistent.placementSetting = cycle[config.persistent.placementSetting]
            if CF.Positioner.active then
                decals.applyDecals(CF.Positioner.active, config.persistent.placementSetting)
            end
            tes3.playSound{ sound = "Menu Click" }

        end
    end
end

local function onInitialized()
    CF.Positioner.shadow_model = tes3.loadMesh("craftingFramework/shadow.nif")

    CF.Positioner.id_guide = tes3ui.registerID("ObjectPlacement:GuideMenu")
    event.register("load", onLoad)
    event.register("keyDown", rotateKeyDown, { priority = -100})
    event.register("keyUp", rotateKeyUp)
    event.register("keyDown", toggleMode)

end
event.register("initialized", onInitialized)


local function onMouseScroll(e)
    if CF.Positioner.active then
        local multi = Util.isShiftDown() and 0.02 or 0.1
        local change = multi * e.delta
        local newMaxReach = math.clamp(CF.Positioner.currentReach + change, CF.Positioner.minReach, CF.Positioner.maxReach)
        CF.Positioner.currentReach = newMaxReach
    end
end
event.register("mouseWheel", onMouseScroll)


local function blockActivation(e)
    logger:debug("blockActivation")
    if config.persistent.positioningActive then
        logger:debug("Positioning Active")
        return (e.activator ~= tes3.player)
    end
end
event.register("activate", blockActivation, { priority = 500 })


local function onActiveKey(e)
    local inputController = tes3.worldController.inputController
    local keyTest = inputController:keybindTest(tes3.keybind.activate)
    if keyTest then
        if config.persistent.positioningActive then
            CF.Positioner.togglePlacement()
        end
    end
end
event.register("keyDown", onActiveKey, { priority = 100 })


CF.Positioner.startPositioning = function(e)
    -- Put those hands away.
    if (tes3.mobilePlayer.weaponReady) then
        tes3.mobilePlayer.weaponReady = false
    elseif (tes3.mobilePlayer.castReady) then
        tes3.mobilePlayer.castReady = false
    end
    if e.placementSetting then
        config.persistent.placementSetting = e.placementSetting
    end
    CF.Positioner.togglePlacement(e)
end

event.register("CraftingFramework:startPositioning", function(e)
    CF.Positioner.startPositioning(e)
end)

return CF.Positioner
