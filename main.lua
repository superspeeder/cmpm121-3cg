io.stdout:setvbuf("no")

require("vector")
require("utils")
require("constants")
require("location")
require("player")
require("card")
require("deckbuilding")
require("game")

function love.load()
    Game:setup()
end

function love.draw(dt)
    Game:draw()
end

function love.update(dt)
    Game:update()
end

function love.mousepressed(x, y, button, istouch, presses)
    if Game.gameOver then Game:setup() end
    -- grabbing code
    if Game.hoveringSubmit then
        Game:runTurn()
    elseif Game.hoveredCard ~= nil then
        Game:grab()
    end
end

function love.wheelmoved(x, y)
    if Game.deckbuildingActive then
        DeckbuildingScreen:onScroll(y)
    end
end
