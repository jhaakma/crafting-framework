require("CraftingFramework.mcm")
local function onInit()
    require("CraftingFramework.controllers.StaticActivator")
    require("CraftingFramework.controllers.Positioner")
    
    mwse.log("[CraftingFramework INFO] StaticActivator Controller initialised.")
end
event.register("initialized", onInit)