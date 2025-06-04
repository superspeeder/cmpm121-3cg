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
    hoveredCard = nil,
    hoverSpot = nil,
    grabbedCard = nil,
    grabSpot = nil
}

---Discard a card
---@param card Card
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
        if #player.hand < 7 and #player.deck > 0 then
            player:addToHand(player:drawCard())
        end
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

    if self.grabbedCard ~= nil then
        self.grabbedCard:draw(Vector:new(love.mouse.getX(), love.mouse.getY()) - self.grabSpot, true)
    end
end

function Game:update()
    if self.grabbedCard ~= nil and not love.mouse.isDown(1) then
        self:grabRelease()
    end
end

function Game:grab()
    if self.hoveredCard == nil then
        return
    end

    if self.hoveredCard.cost > self.players[1].manaBank then
        return
    end

    self.grabbedCard = self.hoveredCard
    self.grabSpot = self.hoverSpot
    self.hoveredCard = nil
    self.hoverSpot = nil
    self.grabbedCard.owner:removeFromHand(self.grabbedCard)
end

function Game:grabRelease()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()
    if my > LOCATION_Y and my < LOCATION_Y + LOCATION_HEIGHT then
        if mx > LOCATION_1_POSITION.x and mx < LOCATION_1_POSITION.x + LOCATION_WIDTH then
            if self.locations[1]:canPlaceCard(self.grabbedCard) then
                self.locations[1]:add(self.grabbedCard)
                self.players[1].manaBank = self.players[1].manaBank - self.grabbedCard.cost
                self.grabbedCard = nil
                return
            end
        elseif mx > LOCATION_2_POSITION.x and mx < LOCATION_2_POSITION.x + LOCATION_WIDTH then
            if self.locations[2]:canPlaceCard(self.grabbedCard) then
                self.locations[2]:add(self.grabbedCard)
                self.players[1].manaBank = self.players[1].manaBank - self.grabbedCard.cost
                self.grabbedCard = nil
                return
            end

        elseif mx > LOCATION_3_POSITION.x and mx < LOCATION_3_POSITION.x + LOCATION_WIDTH then
            if self.locations[3]:canPlaceCard(self.grabbedCard) then
                self.locations[3]:add(self.grabbedCard)
                self.players[1].manaBank = self.players[1].manaBank - self.grabbedCard.cost
                self.grabbedCard = nil
                return
            end
        end
    end

    self.grabbedCard.owner:addToHand(self.grabbedCard)
    self.grabbedCard = nil
end