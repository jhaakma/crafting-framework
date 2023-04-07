---@class CarrableContainers.common
local common = {}
local config = require("CraftingFramework.carryableContainers.config")
local mwseLogger = require("logging.logger")
---@type table<string, mwseLogger>
common.loggers = {}

function common.createLogger(serviceName)
    local logger = mwseLogger.new{
        name = string.format("CarryableContainers - %s", serviceName),
        logLevel = config.mcm.logLevel,
        includeTimestamp = true,
    }
    common.loggers[serviceName] = logger
    return logger
end
local logger = common.createLogger("common")

function common.getVersion()
    return config.metadata.package.version
end

return common