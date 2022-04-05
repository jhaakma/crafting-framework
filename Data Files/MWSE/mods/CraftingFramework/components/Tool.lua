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
                    local itemData = tes3.addItemData{
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


function Tool.checkInventoryToolCount(obj, requirements)
    local countNeeded = requirements.count or 1
    local count = mwscript.getItemCount{ reference = tes3.player, item = obj }
    if count < countNeeded then
        Util.log:debug("Player has %d %s, needs %s", count, obj.id, countNeeded)
        return false
    end
    return true
end

function Tool.checkToolEquipped(obj, requirements)
    if requirements.equipped then
        local hasEquipped = tes3.getEquippedItem{
            actor = tes3.player,
            objectType = obj.objectType,
            slot = obj.slot,
            type = obj.type
        }
        if not hasEquipped then
            Util.log:debug("Tool %s needs to be equipped and isn't", obj.id)
            return false
        end
        Util.log:debug("Tool %s is totally equipped", obj.id)
    end
    Util.log:debug("Tool doesn't need equipping")
    return true
end

function Tool.checkToolCondition(obj)
    if obj.maxCondition then
        local stack = tes3.player.object.inventory:findItemStack(obj)
        if not( stack and stack.variables ) then return true end
        for _, data in pairs(stack.variables) do
            if data.condition and data.condition > 0 then
                return true
            end
        end
        Util.log:debug("Scanned inventory and found no %s with enough condition", obj.id)
        return false
    end
end

function Tool.checkToolRequirements(id, requirements)
    local obj = tes3.getObject(id)
    local isValid = obj
        and Tool.checkInventoryToolCount(obj, requirements)
        and Tool.checkToolEquipped(obj, requirements)
        and Tool.checkToolCondition(obj)
    if isValid then
        Util.log:debug("Has specific tool")
        return true
    end
    return false
end


---@param requirements craftingFrameworkToolRequirements
---@return boolean
function Tool:hasToolEquipped(requirements)
    for id, _ in pairs(self.ids) do
        local obj = tes3.getObject(id)
        return Tool.checkToolEquipped(obj, requirements)
    end
end

---@param requirements craftingFrameworkToolRequirements
---@return boolean
function Tool:hasToolCondition(requirements)
    for id, _ in pairs(self.ids) do
        local obj = tes3.getObject(id)
        return Tool.checkToolCondition(obj, requirements)
    end
end

---@param requirements craftingFrameworkToolRequirements
---@return boolean
function Tool:hasTool(requirements)
    requirements = requirements or {}
    for id, _ in pairs(self.ids) do
        if Tool.checkToolRequirements(id, requirements) then
            Util.log:debug("hasTool(): Has tool %s", id)
            return true
        end
    end
    return false
end

return Tool