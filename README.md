# 3CG - Casual Card Cacophony

## Patterns Used
- Prototype (used to make the cards themselves and overall improves the experience of adding new cards, since I make a prototype card based on a base prototype card, and then can spawn cards based on that prototype however I want to, which is useful for cards like hydra)
- Flyweight (used for things like fonts or the library of card types, prevents me from doing the same thing several times when it's not necessary)
- Singleton (the game state is a singleton object, since I only run one game at a time. This helped a lot with making things work well together since I could provide functions that modify game state safely instead of just having tons of places where I randomly change variables for no reason)
- Subclass Sandbox (the base card class is a subclass sandbox, providing a few callback functions and several utilities that allow you to easily customize card functionality. This lets me have very short card definitions, only a dozen or so lines of code instead of the many many more I would need for some other methods)
- Game Loop and Update Function (these are pretty core to both how things work and how LOVE2D works, since LOVE2D manages the game loop and then calls the draw and update functions, which I just pass to other objects)

## Feedback
I got feedback from Hunter Kingsly somewhat early on in the development of this project. He helped me to think through some of my problems at the time (namely trying to figure out how to get cards interacting with eachother correctly). I don't have any written feedback from him, though, and this was more of a problem solving/small bits of feedback than it was code review.
I also got feedback (written) from Joshua Acosta about my code much further along in the process. He made some suggestions (namely suggesting making a turn managing system) which I plan to implement for the final version, but don't have time to implement for this one. A pdf of his feedback can be found in the `/feedback` folder of this repository.

## Postmortem
I think this project has gone fairly well. I wish I had finished it sooner so that I didn't get so stressed over it, but code wise I think it's fairly good. I think the biggest pain point in the project was making cards work properly together. I also need to do some rebalancing for the version for the final. I also want to make things look better (adding delays since I definitely do the whole turn in one frame right now since I didn't have time to make it pause and resume). If I did this over again, I would make resolving command based instead of a normal function (which I may do for the final version, it wouldn't be that hard to make the cards feed into a command queue thing, then I could animate more).

## Assets
All Me!



## Some really cool stuff I did in the code that I want to highlight
One thing that was awesome to work with was the way I setup the subclass sandbox and prototypes for cards. For example, creating the card "Ship of Theseus" is only this code.
```lua
---@class ShipOfTheseus: Card
ShipOfTheseus = Card:makePrototype("Ship of Theseus", 2, 2, "When Revealed: Add a copy with +1 power to your hand.")
function ShipOfTheseus:whenRevealed()
    local card = self:spawn()
    card:setPower(self.power + 1)
    self.owner:addToHand(card)
end
```

The `Card:makePrototype` function is a card factory function which gives me an object that the system recognizes as a card prototype and lets me set common values there.
This is all possible because all non-prototype cards have their `prototype` field set, while all card prototypes leave it `nil`. This let me right my `Card:spawn` function like this:
```lua
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
```

This spawn function proved incredibly useful because I could use it to create a copy of a card, or just create a card from a prototype without worrying about carrying over non-prototype based information (for example, cards track a lot of information about placement, so if I tried to implement "Ship of Theseus" by just using the spawning card as the metatable, I'd be able to get the right stats but I'd also run into issues with values getting indexed on an existing card that shouldn't be).
