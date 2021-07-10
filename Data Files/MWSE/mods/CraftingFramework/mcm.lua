local config = require("CraftingFramework.config")
local Util = require("CraftingFramework.util.Util")
local mcmConfig = mwse.loadConfig(config.configPath, config.mcmDefault)
local function registerMCM()
    local template = mwse.mcm.createTemplate{ name = config.static.modName }
    template.onClose = function()
        config.save(mcmConfig)
    end
    template:register()

    local page = template:createSideBarPage{ label = "Settings"}
    page:createDropdown{
        label = "Log Level",
        description = "Set the logging level for mwse.log. Keep on INFO unless you are debugging.",
        options = {
            { label = "TRACE", value = "TRACE"},
            { label = "DEBUG", value = "DEBUG"},
            { label = "INFO", value = "INFO"},
            { label = "ERROR", value = "ERROR"},
            { label = "NONE", value = "NONE"},
        },
        variable =  mwse.mcm.createTableVariable{ id = "logLevel", table = mcmConfig },
        callback = function(self)
            Util.log:setLogLevel(self.variable.value)
        end
    }
end
event.register("modConfigReady", registerMCM)