local Recipe = require("CraftingFramework.components.Recipe")
local Material = require("CraftingFramework.components.Material")

local doUnitTests = true
local UnitWind = include("unitwind.unitwind")
if not UnitWind then return end
UnitWind = UnitWind.new{
    enabled = doUnitTests,
    highlight = true,
    exitAfter = false
}

UnitWind:start("Crafting Framework: On Initialised Tests")
UnitWind:test("Canary", function()
    UnitWind:expect(true).toBe(true)
end)

Material:new{
    id = "testMaterial",
    name = "Test Material",
    ids = {
        "misc_clothbolt_01"
    },
}

local validRecipe = {
    id = "testRecipe",
    craftable = {
        id = "testCraftable",
    },
    materials = {
        {material = "testMaterial"}
    },
    skillRequirement = {
        skill = "speechcraft",
        requirement = 50
    }
}

UnitWind:test("A valid recipe gets created successfully", function()
    local recipe = Recipe:new(validRecipe)
    UnitWind:expect(recipe).NOT.toBe(nil)
    UnitWind:log(json.encode(recipe, { indent = true}))
end)

UnitWind:finish()
