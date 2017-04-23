-- @author: qianye@droi.com

local cjson     = require("cjson.safe")

local _M = {}

local function log(level, msg)
        if msg == nil then
                msg = "nil"
        elseif msg == false then
                msg = "false"
        elseif msg == true then
                msg = "true"
        end

        local msg_type = type(msg)
        if msg_type == "string" or msg_type == "number" then
                ngx.log(level, msg) 
        elseif msg_type == "table" then
                local str, err = cjson.encode(msg)
                if str then
                        ngx.log(level, str)
                else
                        error("json encode error: " .. err)
                end
        else
                error("unsupport msg type")
        end
end

function _M.ERROR(msg)
        log(ngx.ERR, msg)
end

function _M.WARN(msg)
        log(ngx.WARN, msg)
end

function _M.INFO(msg)
        log(ngx.INFO, msg)
end

function _M.DEBUG(msg)
        log(ngx.DEBUG, msg)
end

return _M
