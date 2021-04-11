--[[
This module gives us some class-like functionality
]]

local Class = {}
Class.__index = Class

--default implementation
function Class:new() end

--create a new Class type from our base class
function Class:derive(class_type)
    assert(class_type ~= nil, "parameter class_type must not be nil!")
    assert(type(class_type) == "string", "parameter class_type class must be string!")
    local cls = {}
    cls["__call"] = Class.__call
    cls.type = class_type
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

-- -- Check if the instance is a sub-class of the given type
-- function Class:isClass(class)
--     assert(class ~= nil, "parameter class must not be nil!")
--     assert(type(class) == "table", "parameter class must be of Type Class!")
--     local mt = getmetatable(self)
--     while mt do
--         if mt == class then return true end
--         mt = getmetatable(mt)
--     end
--     return false
-- end


-- this was is_type, I'll change the other (above) to isClass if I end up needing it
-- this is more useful to me as the is() function
function Class:is(class_type)
    assert(class_type ~= nil, "parameter class_type must not be nil!")
    assert(type(class_type) == "string", "parameter class_type class must be string!")
    local base = self
    while base do
        if base.type == class_type then return true end
        base = base.super
    end
    return false
end

function Class:__call(...)
    local inst = setmetatable({}, self)
    inst:new(...)
    return inst
end

function Class:get_type()
    return self.type
end

function Class:can(state) -- string
    -- should take a table also
    if state then
        if type(state) == "string" then
            if not self.form[state] then  -- if there's nothing at that state,
                return false -- bail and return false
            else
                -- it should probably check for an enter function as well
                return type(self.form[state]) == "function" -- if it's indeed a function, return true
            end
        elseif type(state) == "table" then
            -- table implentation here. recursive!
            -- expects a table of strings that represent states
            for i = 1, #state do
                if self:can(state[i]) then
                    return state[i] -- if it finds a state it can do, return that string
                end
            end
            return false -- return false if none of them matched
        end
    else
        --how could this return available states when given 0 parameters? perhaps by scanning for enter or exit functions!
    end
end

if not Class.UF then Class.UF = {} end -- update functions as strings
function Class:C_update(dt)
    local UF = self.UF
    for _,v in ipairs(UF) do
        -- print(type(self.HP_update))
        -- print('val func name is ', v)
        if type(self[v]) == 'function' then
            self[v](self, dt)
        else
            -- print(self.form.ent_name)
            -- for _, v in ipairs(UF) do
            --     print("UF: ", v)
            -- end
            -- print(type(self[v]))
            -- print(v)
            -- assert(false, 'UF doesnt exist!')
        end
    end
end




return Class