-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license

local MIME = require("miss-core.src.mime")

local _M = {}

-- @brief   wrap string
-- @param   str     {string}
-- @param   wrapper {string}
-- @return  str     {string}
local function wrap(str, wrapper)
    return wrapper .. str .. wrapper
end

_M.wrap = wrap

-- @brief   remove regexp from both ends of a string
-- @param   str     {string}
-- @param   regexp  {string}
-- @return  str     {string}
local function trim(str, regexp)
    if type(str) == "string" then
        regexp = regexp or "%s"
        local from = str:match("^" .. regexp .. "*()")
        return from > #str and "" or str:match(".*[^" .. regexp .. "]", from)
    end
end

_M.trim = trim

-- @brief   split string into an array of strings by separator
-- @param   str     {string}
-- @param   sep     {string}
-- @return  result  {array[string]}
local function split(str, sep)
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

_M.split = split

-- @brief   gen random string
-- @param   hash    {function}
-- @return  str     {string}
function _M.randomString(hash)
    math.randomseed(os.time())
    return hash(os.time() .. math.random())
end

local uuid = require("miss-core.src.uuid")

-- @brief   gen uuid
-- @return  str     {string}
function _M.uuid()
    local str = uuid.generate_time_safe()
    return string.gsub(str, "-", "")
end

-- @refer   https://cloudwu.github.io/lua53doc/manual.html#6.4.1
--          magic characters        ^$()%.[]*+-?
local ENCODE_LUA_MAGIC_REGEXP = "([%^%$%(%)%%%.%[%]%*%+%-%?])"

-- @brief   replace lua magic characters to itself in regexp
-- @param   str     {string}        normale string ^$()%.[]*+-? 
-- @return  str     {string}        encoded string %^%$%(%)%%%.%[%]%*%+%-%?
function _M.encodeLuaMagic(str)
    if str then
        str = string.gsub(str, ENCODE_LUA_MAGIC_REGEXP, function(c)
            return "%" .. c
        end)
    end
    return str
end

-- @brief   returns keys of the table
-- @param   tab     {object}
-- @param   except  {object[boolean]}
-- @return  keys    {array[string]}
local function keys(tab, except)
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

_M.keys = keys

-- @brief   merge src table to dest table
-- @param   dest    {object}
-- @param   src     {object}
-- @param   except  {object[boolean]}
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

-- @brief   parser Content-Type
-- @param   str     {string}
-- @return  ctype   {string}
-- @return  charset {string} 
function _M.parseContentType(str)
    if not str then return end
    local ret = split(str, ";")
    
    local ctype = ret[1]
    if not ctype then return end

    ctype = string.lower(trim(ctype))

    local charset = ret[2]
    if not charset then return ctype end 

    if ctype == MIME.MULTIPART then
        charset = trim(charset)
    else
        charset = string.lower(trim(charset))
    end

    return ctype, charset
end

local function isArray(tab)
    if type(tab) ~= "table" then
        return false
    end

    local i = 1
    for k, v in pairs(tab) do
        if k ~= i then
            return false
        end 
        i = i + 1
    end

    return true
end

_M.isArray = isArray

local function indent(level)
    return string.rep("    ", level)
end

local function quote(str)
    return '"' .. string.gsub(str, '"', '\\"') .. '"'
end

local function wrapKey(key)
    if type(key) == "string" then
        return "[" .. quote(key) .. "]"
    else
        return "[" .. tostring(key) .. "]"
    end
end

local function dump(input, level)
    local t = type(input)
    if t == "string" then
        return quote(input)
    elseif t == "table" then
        local i     = 1
        local lines = {}
        if isArray(input) then
            for k, v in ipairs(input) do
                local s = dump(v, level + 1)
                lines[i] = s
                i = i + 1
            end
        else
            local max = 0
            for k, v in pairs(input) do
                local key = wrapKey(k)
                local l = #key + 1
                if l > max then
                    max = l
                end
            end

            local len = math.ceil(max / 4) * 4
            for k, v in pairs(input) do
                local key = wrapKey(k) 
                local s = key .. string.rep(" ", len - #key) .. "= "
                s = s .. dump(v, level + 1)
                lines[i] = s
                i = i + 1
            end
        end

        local content = table.concat(lines, ",\n" .. indent(level))
        return "{\n" .. indent(level) .. content .. "\n" .. indent(level -1) .. "}"
    else
        return tostring(input)
    end
end

-- @brief   dump table
-- @param   input   {any}
-- @return  str     {string}
-- @refer   https://github.com/luvit/luv/blob/master/lib/utils.lua
function _M.dump(input)
    return dump(input, 1)
end

local function deepEqual(a, b, path)
    if a == b then
        return true
    end

    local atype = type(a)
    local btype = type(b)
    if atype ~= btype then
        local prefix = path or "."
        return false, prefix .. " not equal (" .. tostring(a) .. ", " .. tostring(b) .. ")."
    end

    if atype ~= "table" then
        local prefix = path or "."
        return false, prefix .. " not equal (" .. tostring(a) .. ", " .. tostring(b) .. ")."
    end

    for key in pairs(a) do
        print(key)
        local newPath   = path and (path .. "." .. key) or ("." .. key)
        local same, msg = deepEqual(a[key], b[key], newPath)
        if not same then
            return same, msg
        end
    end

    for key in pairs(b) do
        if a[key] == nil then
            local newPath   = path and (path .. "." .. key) or ("." .. key)
            return false, newPath .. " not equal (" .. tostring(a[key]) .. ", " .. tostring(b[key]) .. ")."
        end
    end

    return true
end

-- @brief   deep equal
-- @param   a       {any}
-- @param   b       {any}
-- @return  same    {boolean}
-- @return  msg     {string}
-- @refer   https://github.com/luvit/luvit/blob/master/tests/libs/deep-equal.lua
function _M.deepEqual(a, b)
    return deepEqual(a, b)
end

-- @brief   returns whether table contains value
-- @param   a   {any|not nil}
-- @param   t   {object|array}
-- @return  res {boolean}
function _M.in(a, t)
    if type(t) ~= "table" then
        return false
    end

    for k, v in pairs(t) do
        if v == a then
            return true
        end
    end

    return false
end

return _M
