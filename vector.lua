---@class Vector
---@field x number
---@field y number
---@operator add(Vector): Vector
---@operator sub(Vector): Vector
---@operator mul(Vector): Vector
---@operator mul(number): Vector
---@operator div(Vector): Vector
---@operator div(number): Vector
---@operator unm: Vector
Vector = {x=0,y=0}

---Create a new vector
---@param x number
---@param y number
---@return Vector
function Vector:new(x, y)
    local o = {}
    setmetatable(o, Vector.mt)
    o.x = x
    o.y = y
    return o
end

function Vector.add(a, b)
    return Vector(a.x + b.x, a.y + b.y);
end

function Vector.sub(a, b)
    return Vector(a.x - b.x, a.y - b.y);
end

function Vector.mul(a, b)
    if type(a) == "number" then return Vector(a * b.x, a * b.y) end
    if type(b) == "number" then return Vector(a.x * b, a.y * b) end
    return Vector(a.x * b.x, a.y * b.y);
end

function Vector.div(a, b)
    if type(a) == "number" then return Vector(a / b.x, a / b.y) end
    if type(b) == "number" then return Vector(a.x / b, a.y / b) end
    return Vector(a.x * b.x, a.y * b.y);
end

function Vector:negate()
    return Vector(-self.x, -self.y)
end

function Vector.eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector:tostring()
    return "("..tostring(self.x)..", "..tostring(self.y)..")";
end

---Apply current transforms to the vector
---@return Vector
function Vector:applyCurrentTransforms()
    return Vector:new(love.graphics.transformPoint(self.x, self.y))
end

---Inverse current transforms on vector (unapply transforms to return from screen space into the space of the current transforms)
---@return Vector
function Vector:inverseTransform()
    return Vector:new(love.graphics.inverseTransformPoint(self.x, self.y))
end

Vector.mt = {
    __index = Vector,
    __add = Vector.add,
    __sub = Vector.sub,
    __mul = Vector.mul,
    __div = Vector.div,
    __eq = Vector.eq,
    __unm = Vector.negate,
    __tostring = Vector.tostring,
    __call = Vector.new,
}
setmetatable(Vector, Vector.mt)