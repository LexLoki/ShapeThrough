require "utils/class"
local game = require "src/game"

--io.stdout:setvbuf("no")

function love.load()
  game.load()
  game.start()
end

function love.update(dt)
  game.update(dt)
end

function love.keypressed(key)
  game.keypressed(key)
end

function love.draw()
  game.draw()
end