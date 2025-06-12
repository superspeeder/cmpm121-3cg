---@class DeckbuildingUiState
---@field deckScroll number
---@field cardPoolScroll number

---@class DeckbuildingScreen
---@field cardsInDeck Card[]
---@field cardCounters { [string]: integer }
---@field owner Player?
---@field uiState DeckbuildingUiState
DeckbuildingScreen = {
    cardsInDeck = {},
    cardCounters = {},
    allowedCards = {},
    owner = nil,
    uiState = {
        deckScroll = 0.0,
        cardPoolScroll = 0.0
    },
}

---Begin the deckbuilder
---@param owner Player
function DeckbuildingScreen:begin(owner)
    Game.deckbuildingActive = true
    self.cardsInDeck = {}
    self.cardCounters = {}
    self.allowedCards = {}
    self.owner = owner
    self.uiState = {
        deckScroll = 0.0,
        cardPoolScroll = 0.0
    }
    for index, card in ipairs(Cards) do
        self.cardCounters[card.name] = 0
        table.insert(self.allowedCards, #self.allowedCards + 1, card.name)
    end
end

---Complete the deck by picking random cards
function DeckbuildingScreen:completeRandomly()
    local nCardsToPick = NUM_CARDS_IN_DECK - #self.cardsInDeck
    for i = 1, nCardsToPick do
        self:selectRandomCard()
    end
end

function DeckbuildingScreen:selectRandomCard()
    local card = selectRandomArrayElement(self.allowedCards)
    self:onCardChosen(card);
end

---Called to update the card lists when a card is chosen
---@param card Card | string
function DeckbuildingScreen:onCardChosen(card)
    if card == nil then return
    elseif type(card) == "string" then
        self:onCardChosen(CardsByName[card])
    else
        self:incrementCardUsage(card.name)
        local spawned = card:spawn(self.owner)
        table.insert(self.cardsInDeck, #self.cardsInDeck + 1, spawned)
    end
end

---Increment card usage
---@param card string name of the card
function DeckbuildingScreen:incrementCardUsage(card)
    self.cardCounters[card] = self.cardCounters[card] + 1
    if self.cardCounters[card] >= MAX_COPIES_PER_DECK then
        removeFromArray(self.allowedCards, card)
    end
end

---Check if a deck is complete
---@return boolean
function DeckbuildingScreen:isComplete()
    return #self.cardsInDeck == NUM_CARDS_IN_DECK
end

---Get the deck
---@return Card[]
function DeckbuildingScreen:getDeck()
    return self.cardsInDeck
end


---Draw the deckbuilding screen
function DeckbuildingScreen:draw()
    self:drawDeckPanel()
    self:drawCardBankPanel()
end

function DeckbuildingScreen:onScroll(dscroll)
    if rectContains(DECKBUILDING_DECK_CLIP_AREA, Vector:new(love.mouse.getPosition())) then
        self.uiState.deckScroll = self.uiState.deckScroll + dscroll * DECKBUILDING_SCROLL_SPEED
    elseif rectContains(DECKBUILDING_CARD_BANK_CLIP_AREA, Vector:new(love.mouse.getPosition())) then
        self.uiState.cardPoolScroll = self.uiState.cardPoolScroll + dscroll * DECKBUILDING_SCROLL_SPEED
    end
end

function DeckbuildingScreen:drawDeckPanel()
    self.uiState.deckScroll = self:drawCardList(self.cardsInDeck, DECKBUILDING_DECK_CLIP_AREA, self.uiState.deckScroll)

    love.graphics.setColor({0,0,0,1})
    love.graphics.rectangle("line", DECKBUILDING_DECK_CLIP_AREA.x, DECKBUILDING_DECK_CLIP_AREA.y, DECKBUILDING_DECK_CLIP_AREA.width, DECKBUILDING_DECK_CLIP_AREA.height);
end

function DeckbuildingScreen:drawCardBankPanel()
    self.uiState.cardPoolScroll = self:drawCardList(self.allowedCards, DECKBUILDING_CARD_BANK_CLIP_AREA, self.uiState.cardPoolScroll, self.cardCounters, function(i)
        return MAX_COPIES_PER_DECK - i
    end)
    love.graphics.setColor({0,0,0,1})
    love.graphics.rectangle("line", DECKBUILDING_CARD_BANK_CLIP_AREA.x, DECKBUILDING_CARD_BANK_CLIP_AREA.y, DECKBUILDING_CARD_BANK_CLIP_AREA.width, DECKBUILDING_CARD_BANK_CLIP_AREA.height);
end

---Card List
---@param cards (Card|string)[]
---@param clip Rectangle
---@param scroll number
---@param cardNumbers {[string]: integer}?
---@param cardNumberTransformer ?fun(integer): integer
---@return number
function DeckbuildingScreen:drawCardList(cards, clip, scroll, cardNumbers, cardNumberTransformer)
    local minCorner = Vector:new(clip.x, clip.y):applyCurrentTransforms()
    local maxCorner = Vector:new(clip.x + clip.width, clip.y + clip.height):applyCurrentTransforms()

    -- use the scissor to clip the scrollable area
    love.graphics.setScissor(minCorner.x, minCorner.y, maxCorner.x - minCorner.x, maxCorner.y - minCorner.y)

    -- Draw cards as a stack of rows
    local cardsPerRow = (clip.width - CARD_GAP) / (CARD_WIDTH + CARD_GAP)
    local areaHeight = math.ceil(#cards / cardsPerRow) * (CARD_HEIGHT + CARD_GAP) + CARD_GAP
    local travelDistance = areaHeight - clip.height;
    scroll = math.min(math.max(scroll, 0), travelDistance)


    love.graphics.push()
    love.graphics.translate(clip.x, clip.y - scroll);

    for index, card in ipairs(cards) do
        if type(card) == "string" then
            card = CardsByName[card]
        end

        local rowIndex = math.floor((index - 1) / cardsPerRow)
        local colIndex = (index - 1) % cardsPerRow
        local cardPos = Vector:new(CARD_GAP + colIndex * (CARD_GAP + CARD_WIDTH), CARD_GAP + rowIndex * (CARD_GAP + CARD_HEIGHT))

        local yoff = 0
        if card:draw(cardPos, true, false) then
            yoff = -4
        end
        if cardNumbers ~= nil then
            local cardNumber = cardNumbers[card.name]
            if cardNumberTransformer ~= nil then
                cardNumber = cardNumberTransformer(cardNumber)
            end

            local nTextWidth = Game.normalfont:getWidth(tostring(cardNumber))
            local nTextHeight = Game.normalfont:getHeight()
            love.graphics.setColor({0,0,0,0.5})
            love.graphics.rectangle("fill", cardPos.x + CARD_WIDTH - CARD_MARGIN * 3 - nTextWidth, yoff + cardPos.y + CARD_HEIGHT - CARD_MARGIN * 3 - nTextHeight, nTextWidth + CARD_MARGIN * 2, nTextHeight + CARD_MARGIN * 2, 6);
            love.graphics.setFont(Game.normalfont)
            love.graphics.setColor({1,1,1,1})
            love.graphics.print(tostring(cardNumber), cardPos.x + CARD_WIDTH - CARD_MARGIN * 2 - nTextWidth, yoff + cardPos.y + CARD_HEIGHT - CARD_MARGIN * 2 - nTextHeight)
        end
    end
    love.graphics.pop()

    -- only show the scrollbar if we actually have to display more than we can show
    if areaHeight > clip.height then
        love.graphics.setColor({0,0,0,0.2})
        love.graphics.rectangle("fill", clip.x + clip.width - 10, clip.y + 2, 8, clip.height - 4)
        local visibleFraction = clip.height / areaHeight
        if visibleFraction > 0.5 then -- we can do this because we only use visibleFraction to determine the size of the scrollbar
            visibleFraction = 0.5
        end

        local scrollbarHeight = visibleFraction * (clip.height - 8)
        local scrollPoint = scroll / travelDistance -- areaHeight - clip.height gets us the possible travel distance of the scrollbar so that we can't scroll past the bottom
        love.graphics.setColor({1,1,1,1})
        -- scrollPoint * (clip.height - 8 - scrollbarHeight) gets us the y position of the scrollbar so that max scroll doesn't look wrong.
        love.graphics.rectangle("fill", clip.x + clip.width - 8, clip.y + 4 + scrollPoint * (clip.height - 8 - scrollbarHeight), 4, scrollbarHeight)
    end

    love.graphics.setScissor()

    return scroll
end

---Called by the game manager when a card is clicked
---@param card Card
function DeckbuildingScreen:onClicked(card)
    if card.owner == nil then
        self:onCardChosen(card)
    else
        self:returnFromDeck(card)
    end
end

---Return a card from the deck to the bank
---@param card Card
function DeckbuildingScreen:returnFromDeck(card)
    removeFromArray(self.cardsInDeck, card)
    if self.cardCounters[card.name] == MAX_COPIES_PER_DECK then
        table.insert(self.allowedCards, #self.allowedCards + 1, card.name)
        sortByIndexMap(self.allowedCards, CardIndexMap)
    end
    self.cardCounters[card.name] = self.cardCounters[card.name] - 1
end
