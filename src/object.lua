-- @overview: from luvit deps/core.lua

local Object = {}
Object.meta = {
        __index = Object
}

-- @overview: create a new instance of this object
function Object:create()
        local meta = rawget(self, 'meta')
        if not meta then 
                error('cannot inherit form instance object')
        end
        return setmetatable({}, meta)
end

-- @overview: creates a new instance and calls obj:constructor(...) if it exists.
-- @example:
--    local Rectangle = Object:extend()
--    function Rectangle:constructor(w, h)
--      self.w = w
--      self.h = h
--    end
--
--    function Rectangle:getArea()
--      return self.w * self.h
--    end
--
--    local rect = Rectangle:new(3, 4)
--    print(rect:getArea())
function Object:new(...)
        local object = self:create()
        if type(object.constructor) == "function" then
                local ret = object:constructor(...)
                -- zero means no error
                if ret and ret ~= 0 then return nil, ret end
        end

        return object, 0
end

-- @overview: creates a new sub-class.
-- @example:
--    local Square = Rectangle:extend()
--    function Square:constructor(w)
--      self.w = w
--      self.h = h
--    end
function Object:extend()
        local object = self:create()
        local meta = {}
        -- move the meta methods defined in our ancestors meta into our own
        -- to preserve expected behavior in children (like __tostring, __add, etc)
        for k, v in pairs(self.meta) do
                meta[k] = v
        end
        meta.__index = object
        object.meta = meta
        return object
end

return Object
