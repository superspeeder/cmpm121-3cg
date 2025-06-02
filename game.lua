Game = {
    locations = {
        Location:new(1),
        Location:new(2),
        Location:new(3),
    },
    players = {
        Player:new(1),
        Player:new(2),
    },
    turnNumber = 1,
}


function Game:discard(card)
    card:discarded()

    if card.location ~= nil then
        card.location:remove(card)
    else
        card.owner:removeFromHand(card)
    end

    card.owner:addToDiscardPile(card)
    card.isDiscarded = true
end

function Game:moveAway(card)
    -- TODO
end

---Get the opponent of a player
---@param player Player
---@return Player
function Game:opponentOf(player)
    if player.index == 1 then
        return self.players[2]
    else
        return self.players[1]
    end
end

--- Run a turn
function Game:runTurn()
    for index, location in ipairs(self.locations) do
        location:resolve()
    end

    for index, location in ipairs(self.locations) do
        location:endOfTurn()
    end

    self.turnNumber = self.turnNumber + 1

    for index, player in ipairs(self.players) do
        player.manaBank = self.turnNumber
    end
end


