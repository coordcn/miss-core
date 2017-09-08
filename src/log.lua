-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license

local cjson     = require("cjson.safe")

local _M = {}

function _M.log(input)
    if input == nil then
        return "nil"
    elseif input == false then
        return "false"
    elseif input == true then
        return "true"
    end

    local input_type = type(input)
    if input_type == "string" or input_type == "number" then
        return input
    elseif input_type == "table" then
        local output, err = cjson.encode(input)
        if output then
            return output
        else
            error("json encode error: " .. err)
        end
    else
        error("unsupport input type")
    end
end

return _M
