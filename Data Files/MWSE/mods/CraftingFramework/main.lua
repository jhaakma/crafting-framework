require("CraftingFramework.mcm")
require("CraftingFramework.controllers.StaticActivator")
require("CraftingFramework.controllers.Positioner")
require("CraftingFramework.controllers.RecoverMaterials")
require("CraftingFramework.controllers.CraftingEvents")
mwse.log("[CraftingFramework INFO] initialised.")
require("CraftingFramework.test")


--Register crafting menu with RightClickMenuExit
event.register(tes3.event.initialized, function()
    local RightClickMenuExit = include("mer.RightClickMenuExit")
    if RightClickMenuExit and RightClickMenuExit.registerMenu then
        RightClickMenuExit.registerMenu{
            menuId = "CF_Menu",
            buttonId = "Crafting_Menu_CancelButton"
        }
    end
end)