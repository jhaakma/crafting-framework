local Util = {}

Util.messageBox = require("theCraftingFramework.util.messageBox").messageBox
Util.validate = require("theCraftingFramework.util.validator").validate

function Util.deleteRef(ref, no)
    if no then
        mwse.error("You called deleteRef() with a colon, didn't you?")
    end
    ref:disable()
    mwscript.setDelete{ reference = ref}
end

return Util