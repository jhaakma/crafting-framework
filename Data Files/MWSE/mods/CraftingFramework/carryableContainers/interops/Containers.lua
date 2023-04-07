local CarryableMisc = require("CraftingFramework.carryableContainers.components.CarryableMisc")

---@type CarryableMisc.containerConfig[] a map of container ids to their config
local containers = {
}

for _, containerConfig in ipairs(containers) do
    CarryableMisc.register(containerConfig)
end