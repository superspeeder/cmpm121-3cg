---@class Card
---@field name string
---@field cost integer
---@field power integer
---@field text string
---@field owner Player
---@field hasUniquePower boolean
---@field location ?Location
---@field isDiscarded boolean
---@field prototype ?Card
---@field revealed boolean
---@field grabbable boolean
Card = {hasUniquePower=false,grabbable=false}
Card.mt = {__index=Card}

---Called when a card is revealed
function Card:whenRevealed()
end

---Called on end of turn
function Card:endOfTurn()
end

---Called on discarded
function Card:discarded()
end

---Called when another card is played
---@param card Card
function Card:cardPlayed(card)
end

-- Sandbox Functions

function Card:discard()
    Game:discard(self)
end

function Card:changePower(n)
    self.power = self.power + n
end

function Card:setPower(n)
    self.power = n
end

function Card:changeCost(n)
    self.cost = self.cost + n
end

function Card:setCost(n)
    self.cost = n
end

---Spawn a copy of this card (based on prototype)
---
---The card will have the prototype field set (prototypes should NOT have this set)
---@param owner ?Player
---@return Card
function Card:spawn(owner)
    if self.prototype ~= nil then
        return self.prototype:spawn(owner)
    else
        local card = {}
        setmetatable(card, {__index=self})
        card.prototype = self
        card.owner = owner
        return card
    end
end

---Create a card prototype
---@param name string
---@param cost integer
---@param power integer
---@param text string
---@return Card
function Card:makePrototype(name, cost, power, text)
    local card = {}
    setmetatable(card, {__index=self})
    card.name = name
    card.cost = cost
    card.power = power
    card.text = text
    card.revealed = false
    return card
end

---Draw a card at a position
---@param position Vector
---@param revealOverride ?boolean
---@param unrevealedShow ?boolean
---@return boolean
function Card:draw(position, revealOverride, unrevealedShow)
    local revealed = revealOverride or self.revealed
    local rv = false

    love.graphics.push()
    love.graphics.translate(position.x, position.y)

    local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

    -- terrible if statement *but* it does reduce the chances I break something because of code duplication.
    if ((self.grabbable and Game.grabbedCard == nil and self.owner.index == 1) or (Game.deckbuildingActive and isInScissor(love.mouse.getPosition()))) and mx > 0 and my > 0 and mx < CARD_WIDTH and my < CARD_HEIGHT then
        love.graphics.setColor({0.0,0.0,0.0,0.3})
        love.graphics.rectangle("fill", 0, 0, CARD_WIDTH, CARD_HEIGHT, CARD_ROUNDING)
        love.graphics.translate(0, -4)

        Game.hoveredCard = self
        Game.hoverSpot = Vector:new(mx, my)
        rv = true
    end

    if revealed then
        if unrevealedShow then
            love.graphics.setColor({1.0,0.8,0.8})
        else
            love.graphics.setColor(WHITE)
        end
        love.graphics.rectangle("fill", 0, 0, CARD_WIDTH, CARD_HEIGHT, CARD_ROUNDING)

        love.graphics.setColor(BLACK)
        love.graphics.printf(self.name, CARD_MARGIN, CARD_MARGIN, CARD_WIDTH - CARD_MARGIN * 2 - 16)

        love.graphics.setColor(MANA_COLOR)
        love.graphics.printf(self.cost, CARD_MARGIN, CARD_MARGIN, CARD_WIDTH - CARD_MARGIN * 2, "right")

        love.graphics.setColor({0.7,0,0})
        love.graphics.printf(self.power, CARD_MARGIN, CARD_MARGIN + 14, CARD_WIDTH - CARD_MARGIN * 2, "right")

        love.graphics.setColor({0.2,0.2,0.2})
        love.graphics.printf(self.text, CARD_MARGIN, CARD_MARGIN + 32, CARD_WIDTH - CARD_MARGIN * 2)
    else
        love.graphics.setColor(CARD_UNREVEALED_COLOR)
        love.graphics.rectangle("fill", 0, 0, CARD_WIDTH, CARD_HEIGHT, CARD_ROUNDING)
    end

    love.graphics.setColor(BLACK)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0, CARD_WIDTH, CARD_HEIGHT, CARD_ROUNDING)

    love.graphics.pop()

    return rv
end

function Card:reveal()
    self.revealed = true
    self:whenRevealed()
end

--------------------------------------------
---------------- Card Types ----------------
--------------------------------------------

---@class Zeus: Card
Zeus = Card:makePrototype("Zeus", 5, 7, "When Revealed: Lower the power of each card in your opponent's hand by 1.")
function Zeus:whenRevealed()
    local opponent = Game:opponentOf(self.owner)
    for index, card in ipairs(opponent.hand) do
        card:changePower(-1)
    end
end

---@class Ares: Card
Ares = Card:makePrototype("Ares", 3, 3, "When Revealed: Gain +2 power for each enemy card here.")
function Ares:whenRevealed()
    local opponent = Game:opponentOf(self.owner)
    for index, card in ipairs(self.location.cards) do
        if card.owner == opponent then
            self:changePower(2)
        end
    end
end

---@class Medusa: Card
Medusa = Card:makePrototype("Medusa", 6, 9, "When ANY other card is played here, lower that card's power by 1.")
function Medusa:cardPlayed(card)
    if card.location == self.location then
        card:changePower(-1)
    end
end

---@class Cyclops: Card
Cyclops = Card:makePrototype("Cyclops", 5, 2, "When Revealed: Discard your other cards here, gain +2 power for each discarded.")
function Cyclops:whenRevealed()
    local cardsToDiscard = {}
    for index, card in ipairs(self.location.cards) do
        if card.owner == self.owner and card ~= self then
            self:changePower(2)
            table.insert(cardsToDiscard, card)
        end
    end
    for index, card in ipairs(cardsToDiscard) do
        card:discard()
    end
end

---@class Artemis: Card
Artemis = Card:makePrototype("Artemis", 4, 6, "When Revealed: Gain +5 power if there is exactly one enemy card here.")
function Artemis:whenRevealed()
    local enemy_card_count = 0
    local opponent = Game:opponentOf(self.owner)
    for index, card in ipairs(self.location.cards) do
        if card.owner == opponent then
            enemy_card_count = enemy_card_count + 1
        end
    end

    if enemy_card_count == 1 then
        self:changePower(5)
    end
end

---@class Hera: Card
Hera = Card:makePrototype("Hera", 6, 8, "When Revealed: Give cards in your hand +1 power.")
function Hera:whenRevealed()
    for index, card in ipairs(self.owner.hand) do
        card:changePower(1)
    end
end


---@class Demeter: Card
Demeter = Card:makePrototype("Demeter", 4, 6, "When Revealed: Both players draw a card.")
function Demeter:whenRevealed()
    if #Game.players[1].hand < 7 then
        Game.players[1]:addToHand(Game.players[1]:drawCard())
    end
    if #Game.players[2].hand < 7 then
        Game.players[2]:addToHand(Game.players[2]:drawCard())
    end
end

---@class Hades: Card
Hades = Card:makePrototype("Hades", 3, 1, "When Revealed: Gain +2 power for each card in your discard pile.")
function Hades:whenRevealed()
    self:changePower(2 * #self.owner.discardPile)
end

---@class Hercules: Card
Hercules = Card:makePrototype("Hercules", 5, 7, "When Revealed: Doubles its power if its the strongest card here.")
function Hercules:whenRevealed()
    for index, card in ipairs(self.location.cards) do
        if card.power > self.power then
            return -- exit from function if there is a stronger card here
        end
    end

    self:changePower(self.power)
end

---@class Dionysus: Card
Dionysus = Card:makePrototype("Dionysus", 4, 2, "When Revealed: Gain +2 power for each of your other cards here.")
function Dionysus:whenRevealed()
    local yourCards = 0
    for index, card in ipairs(self.location.cards) do
        if card ~= self and card.owner == self.owner then
            yourCards = yourCards + 1
        end
    end

    self:changePower(2 * yourCards)
end

---@class Hydra: Card
Hydra = Card:makePrototype("Hydra", 7, 11, "Add two copies to your hand when this card is discarded.")
function Hydra:discarded()
    self.owner:addToHand(self:spawn())
    self.owner:addToHand(self:spawn())
end

---@class ShipOfTheseus: Card
ShipOfTheseus = Card:makePrototype("Ship of Theseus", 2, 2, "When Revealed: Add a copy with +1 power to your hand.")
function ShipOfTheseus:whenRevealed()
    local card = self:spawn()
    card:setPower(self.power + 1)
    self.owner:addToHand(card)
end

---@class SwordOfDamocles: Card
SwordOfDamocles = Card:makePrototype("Sword of Damocles", 4, 6, "End of Turn: Loses 1 power if not winning this location.")
function SwordOfDamocles:endOfTurn()
    if not self.location:isWinning(self.owner) then
        self:changePower(-1)
    end
end

Cards = {
    Card:makePrototype("Wooden Cow", 1, 1, "Vanilla"),
    Card:makePrototype("Pegasus", 3, 5, "Vanilla"),
    Card:makePrototype("Minotaur", 5, 9, "Vanilla"),
    Card:makePrototype("Titan", 6, 12, "Vanilla"),
    Zeus,
    Ares,
    Medusa,
    Cyclops,
    Artemis,
    Hera,
    Demeter,
    Hades,
    Hercules,
    Dionysus,
    Hydra,
    ShipOfTheseus,
    SwordOfDamocles
}

CardsByName = {}
CardIndexMap = {}
for index, card in ipairs(Cards) do
    CardsByName[card.name] = card
    CardIndexMap[card.name] = index
end
