-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license

local utils = require("miss-core.src.utils")

local _M = {}

-- @brief       xml to lua table
-- @param       xml {string}
--              <xml>
--                      <appid>123456</appid>
--                      <test>test</test>
--              </xml>
-- @return      tab {table[object]}
--              {
--                      appid = 123456,
--                      test = test
--              }
function _M.decode(xml)
        local tab = {}
        local content = xml:match("<xml>(.+)</xml>")
        if not content then return nil end

        local lines = utils.split(content, "\n")
        for i = 1, #lines do
                local line = lines[i]
                local key, value = line:match('<(.-)><!%[CDATA%[(.-)%]%]>')
                if key and value then
                        tab[key] = value
                else
                        key, value, _ = line:match('<([^>]*)>([^<]*)')
                        if key and value then
                                tab[key] = value
                        end
                end
        end

        return tab
end

-- @brief       lua table to xml
-- @param       tab     {table[object]}
-- @return      xml     {string}
function _M.encode(tab)
        local xml = "<xml>"

        for key, val in pairs(tab) do
                xml = xml .. "<" .. key .. "><![CDATA[" .. val .. "]]></" .. key .. ">"
        end

        return xml .. "</xml>"
end

return _M
