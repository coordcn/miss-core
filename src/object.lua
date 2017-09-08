-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license
-- @refer       luvit deps/core.lua

local setmetatable = setmetatable

-- @refer   https://github.com/katlogic/__gc
if _VERSION == "Lua 5.1" then
	local _rawget           = assert(rawget)
	local _proxy_key        = "__gc_proxy__"
	local _rawset           = assert(rawset)
	local _getmetatable     = assert(debug.getmetatable)
	local _setmetatable     = assert(setmetatable)
	local _newproxy         = assert(newproxy)

	setmetatable = function(t, mt)
		if mt ~= nil and _rawget(mt, "__gc") and not _rawget(t, _proxy_key) then
			local _proxy = _newproxy(true)
			_rawset(t, _proxy_key, _proxy)

			_getmetatable(_proxy).__gc = function()
				_rawset(t, _proxy_key, nil)

				local _mt = _getmetatable(t)
				if not _mt then return end

				local _gc = _rawget(_mt, "__gc")
				if _gc and type(_gc) == "function" then 
                    return _gc(t) 
                end
			end
		end

		return _setmetatable(t,mt)
	end
end

local Object = {}
Object.__meta__ = {
    __index = Object
}

-- @brief   create a new instance of this object
function Object:__create__()
    local meta = rawget(self, '__meta__')
    if not meta then 
            error('cannot inherit form instance object')
    end
    return setmetatable({}, meta)
end

-- @brief   creates a new instance and calls obj:constructor(...) if it exists.
-- @example
--  local Rectangle = Object:extend()
--  function Rectangle:constructor(w, h)
--      self.w = w
--      self.h = h
--  end
--
--  function Rectangle:getArea()
--      return self.w * self.h
--  end
--
--  local rect = Rectangle:new(3, 4)
--  print(rect:getArea())
function Object:new(...)
    local object = self:__create__()

    local ret
    if type(object.constructor) == "function" then
        ret = object:constructor(...)
        -- ret == nil means no error
        if ret and ret ~= 0 then 
            return nil, ret
        end
    end

    return object, ret
end

-- @brief   creates a new sub-class.
-- @example
--  local Square = Rectangle:extend()
--  function Square:constructor(w)
--      self.w = w
--      self.h = h
--  end
function Object:extend(flag)
    local object = self:__create__()

    -- move the meta methods defined in our ancestors meta into our own
    -- to preserve expected behavior in children (like __tostring, __add, etc)
    local __meta__ = {}
    for k, v in pairs(self.__meta__) do
        if k ~= "__gc" then
            __meta__[k] = v
        end
    end

    if flag then
        __meta__[k] = function(obj)
            if type(obj.destructor) == "function" then
                obj:destructor()
                if type(object.constructor) == "function" then
                    object.constructor(obj)
                end
            end
        end
    end

    __meta__.__index = object
    object.__meta__ = __meta__

    return object
end

function Object:setmetamethod(meta)
    local self_meta = self.__meta__
    if type(meta) == "table" then
        for k, v in pairs(meta) do
            if k ~= "__gc" then
                self_meta[k] = v
            end
        end
    end
end

return Object
