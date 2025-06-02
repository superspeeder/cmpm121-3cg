---@class Player
---@field index integer
---@field manaBank integer
---@field points integer
---@field hand Card[]
---@field deck Card[]
---@field discardPile Card[]
Player = {}
Player.mt = {__index=Player}

---Create a new Player
---@param index integer
---@return Player
function Player:new(index)
    local player = {}
    setmetatable(player, {__index=self})
    player.index = index
    player.manaBank = 1
    player.points = 0
    player.hand = {}
    player.deck = {}
    player.discardPile = {}
    return player
end

function Player:addPoints(points)
    self.points = self.points + points
end

function Player:addToDiscardPile(card)
    table.insert(self.discardPile, #self.discardPile, card)
end

function Player:removeFromDiscardPile(card)
    for index, value in ipairs(self.hand) do
        if value == card then
            table.remove(self.discardPile, index)
            break
        end
    end
end

function Player:addToHand(card)
    table.insert(self.hand, #self.hand, card)
end

function Player:removeFromHand(card)
    for index, value in ipairs(self.hand) do
        if value == card then
            table.remove(self.hand, index)
            break
        end
    end
end

function Player:drawCard()
    local topCard = self.deck[1]
    if topCard ~= nil then
        table.remove(topCard, 1)
        self:addToHand(topCard)
    end
end

function Player:shuffleDeck()
    -- TODO
end

