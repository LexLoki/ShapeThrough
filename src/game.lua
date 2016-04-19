local game = {
  states = {idle={}, action={}, paused={}},
  tests={},
  growSpeed = 8,
  colorTime = 0,
  color = {0,0,0}
}
game.state = game.states.idle
local Player = require "src/player"
local contact = require "src/contact"
local spawnManager = require "src/spawnManager"
require "utils/utils"

function game.load()
  game.music = love.audio.newSource("sounds/PerceptionSong.mp3")
  game.music:setLooping(true)
  game.font = love.graphics.newFont(20)
  spawnManager.load()
end

function game.start()
  game.contacted = nil
  game.timer = 0
  game.blocks = {}
  game.growStack = 0
  game.width,game.height = love.graphics.getDimensions()
  game.smallRadius = 0.08*game.width
  game.bigRadius = 0.27*game.width
  game.radius = game.smallRadius
  game.growDir = 1
  game.center = {x=game.width/2,y=game.height/2}
  local player1Data = {
    input={left="left",right="right",switch="space"},
    color = {255,0,0},
    center = game.center
  }
  game.players = {Player.new(player1Data,game)}
  spawnManager.start(game)
end

function game.newRound()
  Player.speed = Player.speed*1.35
  Block.speed = Block.speed*1.35
end

function game.keypressed(key)
  game.state.keypressed(key)
end

function game.states.idle.keypressed(key)
  if key=="return" then game.state = game.states.action
  love.audio.play(game.music) game.start() end
end

function game.states.action.keypressed(key)
  if key=="return" then love.audio.pause(game.music) game.state = game.states.paused end
  for i,v in pairs(game.players) do
    if v:keypressed(key) then do return end end
  end
end

function game.states.paused.keypressed(key)
  if key=="return" then love.audio.resume(game.music) game.state = game.states.action end
end

function game.update(dt)
  game.state.update(dt)
end

function game.states.idle.update(dt)
  
end

function game.states.action.update(dt)
  game.colorTime = game.colorTime-dt
  if game.colorTime<0 then
    game.colorTime = 2
    game.colorV = {}
    for i=1,3 do
      table.insert(game.colorV,(30+195*love.math.random()-game.color[i])/2)
    end
  else
    for i,v in ipairs(game.colorV) do game.color[i]= game.color[i]+v*dt end
  end
  game.timer = game.timer+dt
  for i,v in safePairs(game.blocks) do
    v:update(dt)
    if not v.alive then
      table.remove(game.blocks,i)
      game.growStack = game.growStack+3
    end
  end
  if game.growStack>0 then
    local q = game.growSpeed*dt
    game.radius = game.radius+q*game.growDir
    if game.growDir==1 then if game.radius>game.bigRadius then game.growDir=-1 spawnManager.switch() end else if game.radius<game.smallRadius then game.growDir = 1 spawnManager.switch() end end
    game.growStack = game.growStack-q
  end
  
  for i,v in pairs(game.players) do
    v:update(dt)
    
    if contact.check(v,game.blocks,game) then
      love.audio.stop(game.music)
      Player.speed = Player.baseSpeed
      Block.speed = Block.baseSpeed
      game.state = game.states.idle
      do return end
    end
  end
  spawnManager.update(dt)
end

function game.states.paused.update(dt) end

function game.draw()
  love.graphics.setColor(game.color)
  love.graphics.rectangle("fill",0,0,game.width,game.height)
  love.graphics.setColor(255,255,255)
  love.graphics.setFont(game.font)
  love.graphics.printf(math.floor(game.timer),game.width/2,game.height*0.1,500)
  love.graphics.translate(game.center.x,game.center.y)
  love.graphics.push()
  local c = {255-game.color[1],255-game.color[2],255-game.color[3]}
  love.graphics.setColor(c)
  love.graphics.scale(1,-1)
  love.graphics.circle("fill",0,0,game.radius,100)
  for i,v in pairs(game.players) do v:draw() end
  love.graphics.setColor(c)
  for i,v in pairs(game.blocks) do v:draw() end
  spawnManager.draw()
  if game.contacted ~= nil then
    love.graphics.setColor(0,255,0)
    game.contacted:draw()
  end
  love.graphics.pop()
  love.graphics.setColor(255,255,255)
  game.state.draw()
end

function game.states.idle.draw()
  love.graphics.print("Press enter to play")
end

function game.states.action.draw() end

function game.states.paused.draw()
  love.graphics.print("Press enter to resume")
end


return game