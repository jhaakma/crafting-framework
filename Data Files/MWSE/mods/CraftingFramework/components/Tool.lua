local Util = require("CraftingFramework.util.Util")

---@class craftingFrameworkTool
local Tool = {
    schema = {
        name = "Tool",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = false },
            ids = { type = "table", childType = "string", required = true }
        }
    }
}


Tool.registeredTools = {}
---@param id string
---@return craftingFrameworkTool Tool
function Tool.getTool(id)
    return Tool.registeredTools[id]
end

---@param data craftingFrameworkToolData
---@return craftingFrameworkTool Tool
function Tool:new(data)
    Util.validate(data, Tool.schema)
    if not Tool.registeredTools[data.id] then
        Tool.registeredTools[data.id] = {
            id = data.id,
            name = data.name,
            ids = {}
        }
    end
    local tool = Tool.registeredTools[data.id]
    --add tool ids
    for _, id in ipairs(data.ids) do
        tool.ids[id:lower()] = true
    end
    setmetatable(tool, self)
    self.__index = self
    return tool
end

---@return string name
function Tool:getName()
    return self.name
end

---@param amount number
function Tool:use(amount)
    amount = amount or 1
    for id, _ in pairs(self.ids) do
        local obj = tes3.getObject(id)
        if obj then
            local itemStack = tes3.player.object.inventory:findItemStack(obj)
            if itemStack then
                if not itemStack.variables then
                    tes3.addItemData{
                        to = tes3.player,
                        item = itemStack.object,
                        updateGUI = true
                    }
                end
                for _, itemData in ipairs(itemStack.variables) do
                    if itemData.condition > 0 then
                        Util.log:debug("Degrading condition of tool: %s", self:getName())
                        itemData.condition = math.max(0, itemData.condition - amount)
                    end
                end
            end
        end
    end
end

return Tool