local Validator = {}

local FieldSchema = {
    {
        name = "FieldSchema",
        fields = {
            type = { type = "table|string", required = true },
            required = { type = "boolean", required = true},
        }
    }
}

local SchemaSchema = {
    name = "Schema",
    fields = {
        name = { type = "string", required = false },
        fields = { type = FieldSchema, required = true }
    }
}

--splits a string along | to return list of available types
local function getTypeStrings(str)
    local t = {}
    local function helper(line)
       table.insert(t, line)
       return ""
    end
    helper((str:gsub("(.|)\r?\n", helper)))
    return t
 end


Validator.validate = function(object, schema)
    Validator.validate(schema, SchemaSchema)
    assert(object, "Validation failed: No object provided.")
    assert(schema, "Validation failed: No schema provided.")

    local schemaName = schema.name or "[unknown]"
    for key, val in pairs(schema.fields) do
        local expectedType = val.type
        --check schema values
        assert(type(val) == "table", string.format("Validation failed: %s field data is not a table.", key))
        assert(expectedType, string.format("Validation failed: %s field data missing type.", key))

        --check field exists
        if val.required then
            assert(object[key],
                string.format("Validation failed for %s: Missing %s field.",
                    schemaName, key)
            )
        end
        --check field types
        if object[key] and not expectedType == "any" then
            if type(expectedType) == "string" then
                --standard lua types, might be separated by |
                local typeList = getTypeStrings(expectedType)
                local matchesType = false
                for _, expectedTypeString in ipairs(typeList) do
                    if type(object[key]) == expectedTypeString then
                        matchesType = true
                    end
                    if not matchesType then
                        --standard type checking
                        assert(type(object[key]) == expectedType,
                        string.format("Validation failed for %s: %s must be of type %s. Instead got %s.",
                            schemaName, key, expectedType, type(object[key]))
                        )
                    end
                end
            elseif type(expectedType) == "table" then
                --validate subschemas
                Validator.validate(object.key, expectedType)
            end
        end
    end
end

return Validator