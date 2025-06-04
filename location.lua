---@class Location
---@field index integer
---@field cards Card[]
---@field winner ?Player
Location = {}
Location.mt = {__index=Location}

---Create a new Location
---@param index integer
---@return Location
function Location:new(index)
    local location = {}
    setmetatable(location, {__index=self})
    location.index = index
    location.cards = {}
    location.winner = nil
    return location
end

---Add a card
---@param card Card
function Location:add(card)
    table.insert(self.cards, #self.cards + 1, card)
    card.location = self
    card.grabbable = false
end

function Location:remove(card)
    for index, value in ipairs(self.cards) do
        if card == value then
            table.remove(self.cards, index)
            return
        end
    end
end

function Location:isWinning(player)
    return self.winner == player
end

---Resolve a location (reveals cards and selects a winner)
function Location:resolve()
    ---@type Card[]
    local cards1 = {}

    ---@type Card[]
    local cards2 = {}

    for index, card in ipairs(self.cards) do
        if card.owner.index == 1 then
            table.insert(cards1, #cards1 + 1, card)
        else
            table.insert(cards2, #cards2 + 1, card)
        end
    end

    if self.winner ~= nil then
        if self.winner.index == 1 then
            for index, card in ipairs(cards1) do
                if not card.revealed then
                    card:reveal()
                end
            end
            for index, card in ipairs(cards2) do
                if not card.revealed then
                    card:reveal()
                end
            end
        else
            for index, card in ipairs(cards2) do
                if not card.revealed then
                    card:reveal()
                end
            end
            for index, card in ipairs(cards1) do
                if not card.revealed then
                    card:reveal()
                end
            end
        end
    else
        self.winner = Game.players[love.math.random(2)] -- flip a coin for winner
    end

    local power1 = 0
    local power2 = 0
    for index, card in ipairs(cards1) do
        power1 = power1 + card.power
    end
    for index, card in ipairs(cards2) do
        power2 = power2 + card.power
    end

    if power1 > power2 then
        self.winner = Game.players[1]
        self.winner:addPoints(power1 - power2)
    elseif power2 > power1 then
        self.winner = Game.players[2]
        self.winner:addPoints(power2 - power1)
    else
        self.winner = Game.players[love.math.random(2)] -- flip a coin for winner
    end
end

function Location:endOfTurn()
    for index, card in ipairs(self.cards) do
        card:endOfTurn()
    end
end

function Location:reset()
    self.winner = nil
    self.cards = {}
end

---Check if a card can be placed
---@param card Card
---@return boolean
function Location:canPlaceCard(card)
    if #self.cards >= 8 then
        return false
    end

    local sameOwnerCount = 0
    for index, c in ipairs(self.cards) do
        if c.owner == card.owner then
            sameOwnerCount = sameOwnerCount + 1
        end
    end

    return sameOwnerCount < 4
end

---Draw a location
---@param position Vector
function Location:draw(position)
    love.graphics.push()
    love.graphics.translate(position.x, position.y)

    love.graphics.setColor(LOCATION_COLOR)
    love.graphics.rectangle("fill", 0, 0, LOCATION_WIDTH, LOCATION_HEIGHT, 2)

    local p1c = 0
    local p2c = 0
    for index, card in ipairs(self.cards) do
        local x, y
        if card.owner.index == 2 then
            x = (CARD_WIDTH + CARD_GAP) * p1c + CARD_GAP
            y = CARD_GAP;
            p1c = p1c + 1
        else
            x = (CARD_WIDTH + CARD_GAP) * p2c + CARD_GAP
            y = CARD_GAP * 4 + CARD_HEIGHT;
            p2c = p2c + 1
        end

        card:draw(Vector:new(x, y))
    end

    love.graphics.pop()
end