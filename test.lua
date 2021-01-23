local stringUtils = require("lib/stringutils")
local arg = {...}

print(stringUtils.TableToString(arg,1, #arg-1))
