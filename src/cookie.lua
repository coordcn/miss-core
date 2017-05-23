-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license

local utils = require("miss-core.src.utils")

local _M = {}

function _M.decode(str)
        local cookies = utils.split(str, ";")

        local result = {}
        for i = 1, #cookies do
                local cookie = cookies[i]
                local tmp = utils.split(cookie, "=")
                local key = tmp[1]
                local value = tmp[2]
                if key then
                        key = utils.trim(key)
                        if #key > 0 then
                                value = utils.trim(value)
                                result[key] = value or ""
                        end
                end
        end

        return result
end

-- @brief       cookie object to string
-- @param       cookie          {object}
--      cookie = {
--              key             = {string|required}
--              name            = {string|required}
--              expires         = {string}
--              maxage          = {number|string}
--              path            = {string}
--              secure          = {boolean}
--              httponly        = {boolean}
--              samesite        = {string|["Strict", "Lax"]}
--              extension       
--      }
function _M.encode(cookie)
        if not cookie.key or 
           not cookie.value then
                error("cookie.key and cookie.value required")
        end

        local str = cookie.key .. "=" .. cookie.value

        if cookie.expires then
                str = str .. "; Expires=" .. cookie.expires
        end

        if cookie.maxage then
                str = str .. "; Max-Age=" .. cookie.max_age
        end

        if cookie.domain then
                str = str .. "; Domain=" .. cookie.domain
        end

        if cookie.path then
                str = str .. "; Path=" .. cookie.path
        end

        if cookie.secure then
                str = str .. "; Secure"
        end

        if cookie.httponly then
                str = str .. "; HttpOnly"
        end

        if cookie.samesite then
                local samesite = cookie.samesite
                if samesite ~= "Strict" and 
                   Samesite ~= "Lax" then
                        str = str .. "; SameSite=" .. samesite
                end
        end

        return str
end

function _M.set(cookies)
        local set = {}
        local i = 1
        for key, value in pairs(cookies) do
                set[i] = _M.encode(value)
                i = i + 1
        end

        ngx.header["Set-Cookie"] = set
end

return _M
