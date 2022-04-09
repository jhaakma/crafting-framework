---@meta

---@class craftingFrameworkCraftableData
---@field id string **Required.**
---@field name string
---@field description string
---@field placedObject string
---@field uncarryable boolean
---@field additionalMenuOptions table
---@field soundId string
---@field soundPath string
---@field soundType string
---@field materialsRecovery number
---@field maxSteepness number
---@field resultAmount number
---@field recoverEquipmentMaterials boolean
---@field destroyCallback function
---@field placeCallback function
---@field craftCallback function

---@class craftingFrameworkCraftable
---@field id string **Required.**
---@field name string
---@field description string
---@field placedObject string
---@field uncarryable boolean
---@field additionalMenuOptions table
---@field soundId string
---@field soundPath string
---@field soundType string
---@field materialsRecovery number
---@field maxSteepness number
---@field resultAmount number
---@field recoverEquipmentMaterials boolean
---@field destroyCallback function
---@field placeCallback function
---@field craftCallback function
craftingFrameworkCraftable = {}

---comment
---@param reference tes3reference
function craftingFrameworkCraftable:activate(reference) end

---comment
---@param reference tes3reference
function craftingFrameworkCraftable:swap(reference) end

---comment
---@param reference tes3reference
---@return unknow menuButtons
function craftingFrameworkCraftable:getMenuButtons(reference) end

---comment
---@param reference tes3reference
function craftingFrameworkCraftable:position(reference) end

---Transfers all the items from crafted container to the player's inventory. Shows a message if some items were transfered.
---@param reference tes3reference
function craftingFrameworkCraftable:recoverItemsFromContainer(reference) end

---This will add the item to player's inventory. If the item is a container, its contents will be added to the player's inventory.
---@param reference tes3reference
function craftingFrameworkCraftable:pickUp(reference) end

---comment
---@param materialsUsed table<string, number>
---@param materialRecovery number
---@return string|nil recoverMessage A message that tells the player what materials were recovered. If no materials were recovered, returns nil.
function craftingFrameworkCraftable:recoverMaterials(materialsUsed, materialRecovery) end

---This will completely remove the provided `reference` from the game world. It will clean up after itself:
---
--- - The reference will be disabled and deleted after a frame.
---
--- - The reference's contents will be added to the player if applicable.
---
--- - A deconstruction sound will be played.
---
--- - Some materials may be recovered, depending on the settings.
---
--- - The player will be notified by a message.
---
--- - If this craftable object has `:destroyCallback()`, it will be executed.
---@param reference tes3reference
function craftingFrameworkCraftable:destroy(reference) end

---comment
---@return string name
function craftingFrameworkCraftable:getName() end

---comment
---@return string name In the format: "`itemName x resultAmount`".
function craftingFrameworkCraftable:getNameWithCount() end

---comment
function craftingFrameworkCraftable:playCraftingSound() end

---comment
function craftingFrameworkCraftable:playDeconstructionSound() end

---comment
---@param materialsUsed table<string, number>
function craftingFrameworkCraftable:craft(materialsUsed) end

---comment
---@param materialsUsed table<string, number>
function craftingFrameworkCraftable:place(materialsUsed) end


---@class Craftable
---@field registeredCraftables table<string, craftingFrameworkCraftable>
Craftable = {}

---comment
---@param id string
---@return craftingFrameworkCraftable craftable
function Craftable.getCraftable(id) end

---comment
---@param id string
---@return craftingFrameworkCraftable craftable
function Craftable.getPlacedCraftable(id) end

---This method registers a new craftable object.
---@param data craftingFrameworkCraftableData
---@return craftingFrameworkCraftable
function Craftable:new(data) end

---comment
function Craftable:registerEvents() end
