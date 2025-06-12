---Find the index of an item in an array
---@generic T
---@param array T[]
---@param element T
---@return integer?
function indexArray(array, element)
    for index, value in ipairs(array) do
        if value == element then
            return index
        end
    end

    return nil
end

---Remove an item from an array
---@generic T
---@param array T[]
---@param element T
function removeFromArray(array, element)
    local i = indexArray(array, element)
    if i == nil then return end
    table.remove(array, i)
end

---Select a random element from an array
---@generic T
---@param array T[]
---@return T
function selectRandomArrayElement(array)
    return array[love.math.random(#array)]
end

---@class Rectangle
---@field x number
---@field y number
---@field width number
---@field height number


---@param rect Rectangle
---@param pos Vector
function rectContains(rect, pos)
    return pos.x >= rect.x and pos.y >= rect.y and pos.x <= rect.x + rect.width and pos.y <= rect.y + rect.height
end

---@generic T
---@param array T[]
---@param indexMap { [T]: integer }
function sortByIndexMap(array, indexMap)
    table.sort(array, function(a, b) return indexMap[a] < indexMap[b] end)
end

function isInScissor(x, y)
    local sx,sy,sw,sh = love.graphics.getScissor()
    return x >= sx and y >= sy and x <= sx + sw and y <= sy + sh
end
