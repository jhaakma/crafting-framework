local Util = require("CraftingFramework.util.Util")
local log = Util.createLogger("Tool")
local CF = require("CraftingFramework")

---@class CraftingFramework.Tool.data
---@field id string **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `tool`.
---@field name string The name of the tool. Used in various UIs.
---@field ids table<number, string> **Required.**  This is the list of item ids that are considered identical tool.
---@field requirement fun(stack : tes3itemStack): boolean Optionally, you can provide a function that will be used to evaluate if a certain item in the player's inventory can be used as a tool. It will be called with a `tes3itemStack` parameter, that it needs to evaluate if it should be recognized as a tool. When that is the case the function needs to return `true`, `false` otherwise. Used when no `ids` are provided.


---@class CraftingFramework.Tool : CraftingFramework.Tool.data
---@field ids table<string, boolean>
CF.Tool = {
    schema = {
        name = "Tool",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = false },
            ids = { type = "table", childType = "string", required = false },
            requirement = { type = "function", required = false},
        }
    }
}


CF.Tool.registeredTools = {}
---@param id string
---@return CraftingFramework.Tool tool
function CF.Tool.getTool(id)
    return CF.Tool.registeredTools[id]
end

---@param data CraftingFramework.Tool.data
---@return CraftingFramework.Tool Tool
function CF.Tool:new(data)
    Util.validate(data, CF.Tool.schema)
    if not CF.Tool.registeredTools[data.id] then
        CF.Tool.registeredTools[data.id] = {
            id = data.id,
            name = data.name,
            ids = {},
            requirement = data.requirement
        }
    end
    local tool = CF.Tool.registeredTools[data.id]
    --add tool ids
    if data.ids then
        for _, id in ipairs(data.ids) do
            tool.ids[id:lower()] = true
        end
    end
    setmetatable(tool, self)
    self.__index = self
    return tool
end

---@return string name
function CF.Tool:getName()
    return self.name
end

---@param amount number
function CF.Tool:use(amount)
    amount = amount or 1
    log:debug("Using tool, degrading by %s", amount)
    for id, _ in pairs(self:getToolIds()) do
        local obj = tes3.getObject(id)
        if obj then
            local itemStack = tes3.player.object.inventory:findItemStack(obj)
            if itemStack then
                log:debug("Found in inventory: %s", itemStack.object.id)
                if not itemStack.variables then
                    tes3.addItemData{
                        to = tes3.player,
                        item = itemStack.object,
                        updateGUI = true
                    }
                end
                for _, itemData in ipairs(itemStack.variables) do
                    if itemData.condition > 0 then
                        log:debug("Degrading condition of tool: %s", self:getName())
                        itemData.condition = math.max(0, itemData.condition - amount)
                        return
                    end
                end
                log:debug("Couldn't find an itemData with condition to degrade")
                return
            end
        end
    end
    log:debug("Couldn't find any item to degrade")
end

---@return table<string, true>
function CF.Tool:getToolIds()
    if self.ids and #self.ids > 0 then return self.ids end
    if self.requirement then
        local ids = {}
        for _, stack in pairs(tes3.player.object.inventory) do
            if self.requirement(stack) then
                ids[stack.object.id:lower()] = true
            end
        end
        return ids
    end
    log:debug("getToolIds(): No tool ids found")
    return {}
end

return CF.Tool