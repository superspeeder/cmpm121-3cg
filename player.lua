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
    table.insert(self.discardPile, #self.discardPile + 1, card)
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
    card.owner = self
    card.grabbable = true
    table.insert(self.hand, #self.hand + 1, card)
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
        table.remove(self.deck, 1)
    end

    return topCard
end

function Player:shuffleDeck()
    for i = 1,#self.deck do
        local j = love.math.random(i,#self.deck)
        local card2 = self.deck[i]
        self.deck[i] = self.deck[j]
        self.deck[j] = card2
    end
end

function Player:autobuildDeck()
    local counters = {}
    self.deck = {}

    while #self.deck < 20 do
        local cardN = love.math.random(#Cards)
        if counters[cardN] ~= nil and counters[cardN] < 2 then
            table.insert(self.deck, #self.deck + 1, Cards[cardN]:spawn(self))
            counters[cardN] = counters[cardN] + 1
        elseif counters[cardN] == nil then
            counters[cardN] = 1
            table.insert(self.deck, #self.deck + 1, Cards[cardN]:spawn(self))
        end
    end
end

---Draw the player's hand
---@param visible boolean
---@param top boolean
function Player:drawHand(visible, top)
    local y
    if top then
        y = CARD_GAP
    else
        y = HEIGHT - PLAYER_HAND_HEIGHT - CARD_GAP
    end

    love.graphics.push()
    love.graphics.translate(WIDTH / 2, y)
    love.graphics.setColor(PLAYER_HAND_COLOR)
    love.graphics.rectangle("fill", -PLAYER_HAND_WIDTH / 2, 0, PLAYER_HAND_WIDTH, PLAYER_HAND_HEIGHT)
    
    local cardTotalWidth = #self.hand * (CARD_WIDTH + CARD_GAP) - CARD_GAP
    love.graphics.push()
    love.graphics.translate(-cardTotalWidth / 2, CARD_GAP)
    for index, card in ipairs(self.hand) do
        card:draw(Vector:new((index - 1) * (CARD_WIDTH + CARD_GAP), 0), visible)
    end
    love.graphics.pop()

    love.graphics.pop()
end

function Player:drawManaBar()
    local fillHeight = (self.manaBank / Game.turnNumber) * MANA_BAR_HEIGHT

    love.graphics.push()
    love.graphics.translate(LOCATION_GAP * 4 + LOCATION_WIDTH * 3, CARD_GAP + MANA_BAR_WIDTH)
    love.graphics.setColor(WHITE)

    love.graphics.rectangle("fill", -CARD_GAP, -CARD_GAP, MANA_BAR_WIDTH + CARD_GAP * 2, MANA_BAR_HEIGHT + CARD_GAP * 2)
    love.graphics.setColor(BLACK)
    love.graphics.rectangle("fill", 0, 0, MANA_BAR_WIDTH, MANA_BAR_HEIGHT)
    love.graphics.setColor(MANA_COLOR)
    love.graphics.rectangle("fill", 0, MANA_BAR_HEIGHT - fillHeight, MANA_BAR_WIDTH, fillHeight)

    love.graphics.setColor(WHITE)
    love.graphics.printf(tostring(self.manaBank), 0, CARD_MARGIN + (MANA_BAR_HEIGHT - fillHeight), MANA_BAR_WIDTH, "center")

    love.graphics.setColor({1,1,1})
    love.graphics.printf("Turn "..tostring(Game.turnNumber), 0, -2 * CARD_GAP - 12, MANA_BAR_WIDTH, "center")
    
    love.graphics.pop()
end

function Player:setupHand()
    self.hand = {self:drawCard(),self:drawCard(),self:drawCard(),self:drawCard()}
    self.hand[1].grabbable = true
    self.hand[2].grabbable = true
    self.hand[3].grabbable = true
    self.hand[4].grabbable = true
end

function Player:drawDeck(top)
    local y, m
    if top then
        y = CARD_GAP
        m = #self.deck
    else
        y = HEIGHT - CARD_GAP - CARD_HEIGHT
        m = 0
    end
    
    love.graphics.push()
    for index, card in ipairs(self.deck) do
        card:draw(Vector:new(DECK_X, y - index + 1 + m), false)
    end
    love.graphics.pop()
end

function Player:drawDiscard(top)
    local y, m
    if top then
        y = CARD_GAP
        m = #self.deck
    else
        y = HEIGHT - CARD_GAP - CARD_HEIGHT
        m = 0
    end
    
    love.graphics.push()
    for index, card in ipairs(self.discardPile) do
        card:draw(Vector:new(DECK_X + CARD_GAP + CARD_WIDTH, y - index + 1 + m), true)
    end
    love.graphics.pop()
end

function Player:drawSubmitButton()
    local width = love.graphics.getFont():getWidth("Submit")

    -- ugly to look at but honestly I don't want to deal with changing this, it's rectangle point intersection and the rectangle isn't constant so I have to do something weird any way I do this.
    if love.mouse.getX() > SUBMIT_BUTTON_X and love.mouse.getY() > SUBMIT_BUTTON_Y and love.mouse.getX() < SUBMIT_BUTTON_X + width + CARD_MARGIN * 4 and love.mouse.getY() < SUBMIT_BUTTON_Y + 14 + CARD_MARGIN * 4 then
        Game.hoveringSubmit = true
        love.graphics.setColor(SUBMIT_BUTTON_COLOR_HOVER)
    else
        Game.hoveringSubmit = false
        love.graphics.setColor(SUBMIT_BUTTON_COLOR)
    end


    love.graphics.push()
    love.graphics.translate(SUBMIT_BUTTON_X, SUBMIT_BUTTON_Y)
    love.graphics.rectangle("fill", 0, 0, width + CARD_MARGIN * 4, 14 + CARD_MARGIN * 4, 4.0)

    love.graphics.setColor(WHITE)
    love.graphics.print("Submit", CARD_MARGIN * 2, CARD_MARGIN * 2)

    love.graphics.pop()
end