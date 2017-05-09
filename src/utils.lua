-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license

local _M = {}

-- @brief       wrap string
-- @param       str     {string}
-- @param       wrapper {string}
-- @return      str     {string}
function _M.wrap(str, wrapper)
        return wrapper .. str .. wrapper
end

-- @brief       remove whitespace from both ends of a string
-- @param       str     {string}
-- @return      str     {string}
function _M.trim(str)
        local from = str:match"^%s*()"
        return from > #str and "" or str:match(".*%S", from)
end

-- @brief       split string into an array of strings by separator
-- @param       str     {string}
-- @param       sep     {string}
-- @param       result  {array[string]}
function _M.split(str, sep)
        if type(sep) ~= "string" or sep == "" then
                sep = "%s+"
        end

        local result = {}
        local i = 1
        if type(str) == "string" then
                for value in string.gmatch(str, '([^' .. sep .. ']+)') do
                        result[i] = value
                        i = i + 1
                end
        end

        return result
end

-- @brief       gen random string
-- @param       hash    {function}
-- @return      str     {string}
function _M.randomString(hash)
        math.randomseed(os.time())
        return hash(os.time() .. math.random())
end

local uuid = require("miss-core.src.uuid")

-- @brief       gen uuid
-- @return      str     {string}
function _M.uuid()
        local str = uuid.generate_time_safe()
        return string.gsub(str, "-", "")
end

-- @refer       https://cloudwu.github.io/lua53doc/manual.html#6.4.1
--              magic characters        ^$()%.[]*+-?
local ENCODE_LUA_MAGIC_REGEXP = "([%^%$%(%)%%%.%[%]%*%+%-%?])"

-- @brief       replace lua magic characters to itself in regexp
-- @param       str     {string}        normale string ^$()%.[]*+-? 
-- @return      str     {string}        encoded string %^%$%(%)%%%.%[%]%*%+%-%?
function _M.encodeLuaMagic(str)
        if str then
                str = string.gsub(str, ENCODE_LUA_MAGIC_REGEXP, function(c)
                        return "%" .. c
                end)
        end
        return str
end

-- @brief       return keys of the table
-- @param       tab     {object}
-- @param       except  {object[boolean]}
-- @return      keys    {array[string]}
function _M.keys(tab, except)
        local keys = {}
        if except then
                for key, val in pairs(tab) do
                        if not except[key] then
                                table.insert(keys, key)
                        end
                end
        else
                for key, val in pairs(tab) do
                        table.insert(keys, key)
                end
        end

        return keys
end

-- @brief       merge src table to dest table
-- @param       dest    {object}
-- @param       src     {object}
-- @param       except  {object[boolean]}
function _M.merge(dest, src, except)
        if except then
                for key, val in pairs(src) do
                        if not except[key] then
                                dest[key] = val
                        end
                end
        else
                for key, val in pairs(src) do
                        dest[key] = val
                end
        end
end

return _M
