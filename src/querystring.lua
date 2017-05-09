-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license

local uri       = require("miss-core.src.uri")
local utils     = require("miss-core.src.utils")

local _M = {}

-- @breif       query string to lua table
-- @param       query   {string}
-- @return      tab     {object}
function _M.decode(str, limit)
        local fields = utils.split(str, "&")
        local tab = {}
        if fields then
                local len = #fields
                if limit and len > limit then
                        len = limit
                end

                for i = 1, len do
                        local field = fields[i]
                        local key, val = string.match(field, "([^=]*)=(.*)")
                        if key then
                                key = uri.decodeComponent(key)
                                val = uri.decodeComponent(val)
                                local fieldType = type(tab[key])
                                if fieldType == "nil" then
                                        tab[key] = val
                                elseif fieldType == "table" then
                                        table.insert(tab[key], val)
                                else
                                        tab[key] = {tab[key], val} 
                                end
                        end
                end
        end

        return tab
end

local function insertField(fields, key, val)
        if type(val) == "table" then
                for j = 1, #val do
                        local field = key .. "=" .. val[j]
                        table.insert(fields, field)
                end
        else
                local field = key .. "=" .. val
                table.insert(fields, field)
        end
end

-- @brief       build query string
-- @param       tab     {object}
-- @param       keys    {array[string]}
-- @return      query   {string}
function _M.build(tab, keys)
        local fields = {}
        if keys then
                for i = 1, #keys do
                        local key = keys[i]
                        local val = tab[key]
                        insertField(fields, key, val)
                end
        else
                for key, val in pairs(tab) do
                        insertField(fields, key, val)
                end
        end

        return table.concat(fields, "&")
end

local function insertEncodedField(fields, key, val)
        if type(val) == "table" then
                for j = 1, #val do
                        local field = utils.encodeComponent(key) .. 
                                      "=" .. 
                                      utils.encodeComponent(val[j])
                        table.insert(fields, field)
                end
        else
                local field = utils.encodeComponent(key) ..
                              "=" ..
                              utils.encodeComponent(val)
                table.insert(fields, field)
        end
end

-- @brief       build query string, key and value encoded
-- @param       tab     {object}
-- @param       keys    {array[string]}
-- @return      query   {string}
function _M.encode(tab, keys)
        local fields = {}
        if keys then
                for i = 1, #keys do
                        local key = keys[i]
                        local val = tab[key]
                        insertEncodedField(fields, key, val)
                end
        else
                for key, val in pairs(tab) do
                        insertEncodedField(fields, key, val)
                end
        end

        return table.concat(fields, "&")
end

return _M
