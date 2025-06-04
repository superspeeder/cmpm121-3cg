io.stdout:setvbuf("no")

require("vector")
require("constants")
require("location")
require("player")
require("card")
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

function love.mousepressed(x, y)
    -- grabbing code

    if Game.hoveringSubmit then
        Game:runTurn()
    end
end