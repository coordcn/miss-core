-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license

local utils = require("miss-core.src.utils")

local _M = {}

-- @refer   http://www.ecma-international.org/ecma-262/6.0/#sec-uri-syntax-and-semantics
local URI_RESERVED  = ";/?:@&=+$,"
local URI_MARK      = "-_.!~*'()"

-- @refer   https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/encodeURI
--          Reserved characters 	; , / ? : @ & = + $
--          Unescaped characters    alphabetic, decimal digits, - _ . ! ~ * ' ( )
--          Number sign 	        #
local ENCODE_URI_EXCEPT_REGEXP  = "([^%w" .. 
                                  utils.encodeLuaMagic(URI_RESERVED) .. 
                                  utils.encodeLuaMagic(URI_MARK) ..
                                  "#" ..
                                  "])"

-- @brief   encode complete uri
-- @param   uri     {string}    complete uri
-- @return  uri     {string}    encoded uri
function _M.encode(uri)
    if uri then
        uri = string.gsub(uri, ENCODE_URI_EXCEPT_REGEXP, function(c)
            return string.format("%%%02X", string.byte(c))
        end)
    end
    return uri
end

local URI_RESERVED_HEX = {}
local function FILL_URI_RESERVED_HEX(str)
    local len = #str
    for i = 1, len do
        local hex = string.format("%02X", string.byte(str, i))
        URI_RESERVED_HEX[hex] = true
    end
end

FILL_URI_RESERVED_HEX(URI_RESERVED)

-- @brief   decode complete uri
-- @param   uri     {string}    encoded uri
-- @return  uri     {string}    decoded uri
function _M.decode(uri)
    if uri then
        uri = string.gsub(uri, "%%(%x%x)", function(hex)
            if URI_RESERVED_HEX[hex] then
                return "%" .. hex
            else
                return string.char(tonumber(hex, 16))
            end
        end)
    end
    return uri
end

-- @refer   https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
--          Reserved characters
--          Unescaped characters    alphabetic, decimal digits, - _ . ! ~ * ' ( )
--          Number sign
local ENCODE_URI_COMPONENT_EXCEPT_REGEXP  = "([^%w" .. 
                                            utils.encodeLuaMagic(URI_MARK) .. 
                                            "])"

-- @brief       encode uri component
-- @param       str     {string}        uri component
-- @return      str     {string}        encoded uri component
function _M.encodeComponent(str)
    if str then
        str = string.gsub(str, ENCODE_URI_COMPONENT_EXCEPT_REGEXP, function(c)
            return string.format('%%%02X', string.byte(c))
        end)
    end
    return str
end

-- @brief   decode uri component
-- @param   str     {string}    encoded uri component
-- @return  str     {string}    decoded uri component
function _M.decodeComponent(str)
    if str then
        str = string.gsub(str, "%%(%x%x)", function(hex)
            return string.char(tonumber(hex, 16))
        end)
    end
    return str
end

return _M
