local Craftable = {
    schema = {
        id = { type = "string", required = true },
        placedObject = { type = "string", required = false },
        menuOptions = { type = "table", required = false },
    }
}



return Craftable