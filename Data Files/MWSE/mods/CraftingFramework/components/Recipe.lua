local Util = require("CraftingFramework.util.Util")
local Material = require("CraftingFramework.components.Material")
local Craftable = require("CraftingFramework.components.Craftable")
local Tool = require("CraftingFramework.components.Tool")
local config = require("CraftingFramework.config")

local MaterialRequirementSchema = {
    name = "MaterialRequirement",
    fields = {
        material = { type = "string", required = true },
        count = { type = "number", required = false, default = 1 }
    }
}

local SkillRequirementSchema = {
    name = "SkillRequirement",
    fields = {
        skill = { type = "string", required = true },
        requirement = { type = "number", required = true },
    }
}

local ToolRequirementsSchema = {
    name = "ToolRequirements",
    fields = {
        tool = { type = "string", required = true },
        equipped = { type = "boolean", required = false },
        count = { type = "number", required = false },
        conditionPerUse = { type = "number", required = false }
    }
}

local Recipe = {
    schema = {
        name = "Recipe",
        fields = {
            id = { type = "string", required = false },
            craftable = { type = Craftable.schema, required = false },
            description = { type = "string", required = false },
            materials = { type = "table", childType = MaterialRequirementSchema, required = true },
            timeTaken = { type = "string", required = false },
            knownByDefault = { type = "boolean", required = false },
            skillRequirement = { type = SkillRequirementSchema, required = false },
            tools = { type = "table", childType = ToolRequirementsSchema, required = false }
        }
    }
}

Recipe.registeredRecipes = {}
function Recipe.getRecipe(id)
    return Recipe.registeredRecipes[id]
end

function Recipe:new(data)
    Util.validate(data, Recipe.schema)
    data.knownByDefault = data.knownByDefault or false
    data.craftable = data.craftable or { id = data.id }
    data.id = data.id or data.craftable.id
    data.skillRequired = data.skillRequired or 0
    data.tools = data.tools or {}
    assert(data.id, "Validation Error: No id or craftable provided for Recipe")
    data.craftable = Craftable:new(data.craftable)
    setmetatable(data, self)
    self.__index = self
    Recipe.registeredRecipes[data.id] = data
    return data
end


function Recipe:learn()
    config.persistent.knownRecipes[self.id] = true
end

function Recipe:unlearn()
    self.knownByDefault = false
    config.persistent.knownRecipes[self.id] = nil
end

function Recipe:isKnown()
    if self.knownByDefault then return true end
    return config.persistent.knownRecipes[self.id]
end

function Recipe:craft()
    local materialsUsed = {}
    for _, materialReq in ipairs(self.materials) do
        local material = Material.getMaterial(materialReq.material)
        local remaining = materialReq.count
        for _, id in ipairs(material.ids) do
            materialsUsed[id] = materialsUsed[id] or 0

            local inInventory = mwscript.getItemCount{ reference = tes3.player, item = id}
            local numToRemove = math.min(inInventory, remaining)
            materialsUsed[id] = materialsUsed[id] + numToRemove
            tes3.removeItem{ reference = tes3.player, item = id, playSound = false, count = numToRemove}
            remaining = remaining - numToRemove
            if remaining == 0 then break end
        end
    end
    for _, toolReq in ipairs(self.tools) do
        local tool = Tool.getTool(toolReq.tool)
        if tool then
            tool:use(toolReq.conditionPerUse)
        end
    end

    self.craftable:craft(materialsUsed)
end

function Recipe:getItem()
    local id = self.craftable.placedObject or self.miscItem
    if id then
        return tes3.getObject(id)
    end
end

function Recipe:checkCanCraft()
    for _, materialReq in ipairs(self.materials) do
        local material = Material.getMaterial(materialReq.material)
        if not material then
            Util.log:error("Can not craft %s, required material '%s' has not been registered", self.id, materialReq.material)
            return false
        end
        local numRequired = materialReq.count
        if not material:checkHasIngredient(numRequired) then 
            return false 
        end
    end
    for _, toolRequirement in ipairs(self.tools) do
        local tool = Tool.getTool(toolRequirement.tool)
        if not tool then
            Util.log:error("Can not craft %s, required tool '%s' has not been registered", self.id, toolId)
            return false
        end
        if not tool:hasTool(toolRequirement) then
            return false
        end
    end
    
    return true
end

return Recipe