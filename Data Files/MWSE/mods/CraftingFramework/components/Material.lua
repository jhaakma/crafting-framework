local Util = require("CraftingFramework.util.Util")
local logger = Util.createLogger("Material")
---@class CraftingFramework
---@field Material CraftingFramework.Material
local CF = require("CraftingFramework")

---@class CraftingFramework.Material.data
---@field id string **Required.**  This will be the unique identifier used internally by Crafting Framework to identify this `material`.
---@field name string The name of the material. Used in various UIs.
---@field ids table<number, string> **Required.**  This is the list of item ids that are considered as identical material.


---@class CraftingFramework.Material : CraftingFramework.Material.data
---@field ids table<string, boolean>
CF.Material = {
    schema = {
        name = "Material",
        fields = {
            id = { type = "string", required = true },
            name = { type = "string", required = false },
            ids = { type = "table", childType = "string", required = true },
        }
    }
}

CF.Material.registeredMaterials = {}
---@param id string
---@return CraftingFramework.Material material
function CF.Material.getMaterial(id)
    local material = CF.Material.registeredMaterials[id:lower()]
    if not material then
        logger:debug("no material found, checking object for %s", id)
        --if the material id is an actual in-game object
        -- create a new material for this object
        -- the object is the only item in the list
        local matObj = tes3.getObject(id)
        if matObj then
            logger:debug("Found object, creating new material")
            material = CF.Material:new{
                id = id,
                name = matObj.name,
                ids = { id }
            }
        else
            logger:debug("No object found")
        end
    end
    return material
end

---@param data CraftingFramework.Material.data
---@return CraftingFramework.Material material
function CF.Material:new(data)
    Util.validate(data, CF.Material.schema)
    if not CF.Material.registeredMaterials[data.id] then
        CF.Material.registeredMaterials[data.id] = {
            id = data.id,
            name = data.name,
            ids = {}
        }
    end
    local material = CF.Material.registeredMaterials[data.id]
    --add material ids
    for _, id in ipairs(data.ids) do
        material.ids[id:lower()] = true
    end
    setmetatable(material, self)
    self.__index = self
    return material
end

---@param materialList CraftingFramework.Material.data[]
function CF.Material:registerMaterials(materialList)
    if materialList.id then ---@diagnostic disable-line: undefined-field
        logger:error("You passed a single material to registerMaterials, use registerMaterial instead or pass a list of materials")
    end
    for _, data in ipairs(materialList) do
        CF.Material:new(data)
    end
end

---@param itemId string
---@return boolean isMaterial
function CF.Material:itemIsMaterial(itemId)
    return self.ids[itemId:lower()]
end

---@return string name
function CF.Material:getName()
    return self.name
end

---@param numRequired number
---@return boolean hasEnough
function CF.Material:checkHasIngredient(numRequired)
    local count = 0
    for id, _ in pairs(self.ids) do
        local item = tes3.getObject(id)
        if item then
            ---@diagnostic disable-next-line: assign-type-mismatch
            count = count + tes3.getItemCount{ reference = tes3.player, item = item }
        end
    end
    return count >= numRequired
end

--Checks if at least one ingredient in the list is valid
function CF.Material:hasValidIngredient()
    for id, _ in pairs(self.ids) do
        local item = tes3.getObject(id)
        if item then
            return true
        end
    end
    return false
end

return CF.Material