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
    hoveringSubmit = false,
    hoveredCard = nil
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
    print("whee")
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


function Game:setup()
    self.turnNumber = 1
    self.players[1]:autobuildDeck()
    self.players[1]:shuffleDeck()
    self.players[1].manaBank = 1
    self.players[2]:autobuildDeck()
    self.players[2]:shuffleDeck()
    self.players[2].manaBank = 1

    self.locations[1]:reset()
    self.locations[2]:reset()
    self.locations[3]:reset()

    self.players[1]:setupHand()
    self.players[2]:setupHand()

    love.window.setMode(WIDTH, HEIGHT)
end

function Game:draw()
    self.hoveredCard = nil
    
    love.graphics.clear(BACKGROUND)
    self.locations[1]:draw(LOCATION_1_POSITION)
    self.locations[2]:draw(LOCATION_2_POSITION)
    self.locations[3]:draw(LOCATION_3_POSITION)

    self.players[1]:drawHand(true, false)
    self.players[1]:drawDeck(false)
    self.players[1]:drawDiscard(false)
    self.players[1]:drawSubmitButton()

    self.players[2]:drawHand(false, true)
    self.players[2]:drawDeck(true)
    self.players[2]:drawDiscard(true)

    self.players[1]:drawManaBar()
end

function Game:update()
end

