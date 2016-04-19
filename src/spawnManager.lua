
Block = require "src/block"

spawnManager = {
  states={curr,random={},sequence={}},
  extra={curr,attack}
}

local randomBlock

function spawnManager.load()
  spawnManager.sound = love.audio.newSource("sounds/attack.mp3", "static")
  spawnManager.attacks = {}
end

function spawnManager.start(game)
  spawnManager.states.curr = spawnManager.states.random
  spawnManager.capTime = 4
  spawnManager.timer = 3--spawnManager.capTime
  spawnManager.game = game
  spawnManager.blockQuant = 1
  spawnManager.round = 1
  spawnManager.attacks = {}
  spawnManager.limit = 4
end

function spawnManager.switch()

end

function spawnManager.toState(state)
  spawnManager.states.curr = state
  state.start()
end

function spawnManager.update(dt)
  spawnManager.states.curr.update(dt)
  spawnManager.timer = spawnManager.timer-dt
end

function spawnManager.states.random.start()
  spawnManager.blockQuant = 1
  spawnManager.capTime = 4
  spawnManager.timer = 3
end

function spawnManager.states.random.update(dt)
  if spawnManager.timer<0 then
    if spawnManager.blockQuant>4 then
      spawnManager.attacks = {}
      spawnManager.toState(spawnManager.states.sequence)
    else
    --love.audio.play(spawnManager.attacks.sound)
      table.cat(spawnManager.game.blocks,spawnManager.states.random.spawn(math.floor(spawnManager.blockQuant)))
      spawnManager.timer = spawnManager.capTime
      spawnManager.capTime = (spawnManager.capTime-1)*0.7+1
      spawnManager.blockQuant = spawnManager.blockQuant+0.19
      
      if spawnManager.round>1 then
        local s = spawnManager.game.width
        local rand = math.min(love.math.random(spawnManager.round+1)-1,8)
        love.audio.play(spawnManager.sound)
        for i=1,rand do
          local a = love.math.random()*math.pi*2
          table.insert(spawnManager.attacks,{
            x = math.cos(a)*s, y = math.sin(a)*s,
            timer = 1
          })
        end
      end
    end
  else
    spawnManager.updateAttacks(dt)
  end
end

function spawnManager.states.random.spawn(n)
  local q = n or 1
  local blocks = {}
  for i=1,q do
    local a = love.math.random()*math.pi*2
    table.insert(blocks,Block.new(love.graphics.getWidth()/2*math.cos(a),love.graphics.getHeight()/2*math.sin(a),spawnManager.game))
  end
  return blocks
end

function spawnManager.updateAttacks(dt)
  local g = spawnManager.game
  
  for i=#spawnManager.attacks,1,-1 do
    local v = spawnManager.attacks[i]
    v.timer = v.timer-dt
    if v.timer<0 then
      table.remove(spawnManager.attacks,i)
      local b = Block.new(v.x,v.y,g)
      b.speed.x = 5*b.speed.x
      b.speed.y = 5*b.speed.y
      table.insert(g.blocks,b)
    end
  end
end


--[[ Chain effect
sp = height space between following boxes
p.small = player smaller dimension
p.bigger = player bigger dimension
v = box velocity
w = box width
h = box.height
player will have to move >= (sp-p.small)/v
angular difference in box dimension = (2 * atan(w/2,r))
angular player difference = atan(p.w/2,r)
total angule difference = 2*atan(w/2,r)+atan(p.w/2,r)
time for the player to move <= (p.speed)/( 2*atan(w/2,r)+atan(p.w/2,r) )
(sp+h-p.small)/v < (p.speed)/( 2*atan(w/2,r)+atan(p.w/2,r) )
]]
function spawnManager.states.sequence.spawn(n)
  local g = spawnManager.game
  local p = g.players[1]:class()
  local w = Block.size.width
  local h = Block.size.height
  local r = g.radius
  r = 110
  local boxDist = 2*math.atan2(w/2,r)
  local t = (p.speed)/boxDist--(boxDist+math.atan2(p.size.big/2,r))
  --print(t)
  local dif = Block.speed*t+h-p.size.small
  --print(dif)
  local q = n or 15
  local a = love.math.random()*math.pi*2
  local blocks = {}
  local aw = love.graphics.getWidth()
  local ah = love.graphics.getWidth()
  dif = 80
  --boxDist = boxDist+0.1
  local all = math.floor(math.pi*2/boxDist-1)
  for i=1,q do
    --table.insert(g.blocks,Block.new(aw*math.cos(a),ah*math.sin(a),g))
    for j=1,all do table.insert(g.blocks, Block.new(aw*math.cos(a+boxDist*j),ah*math.sin(a+boxDist*j),g)) end
    aw = aw+dif
    ah = ah+dif
    --if i%2==0 then boxDist = -boxDist end
    a = a+boxDist
  end
end

function spawnManager.states.sequence.start()
  spawnManager.states.sequence.spawn()
end

function spawnManager.states.sequence.update(dt)
  --print(#spawnManager.game.blocks)
  if #spawnManager.game.blocks==0 then
    spawnManager.round = spawnManager.round+1
    spawnManager.game.newRound()
    spawnManager.toState(spawnManager.states.random)
  end
end

function spawnManager.draw()
  love.graphics.setLineWidth(10)
  for i,v in ipairs(spawnManager.attacks) do
    love.graphics.line(v.x,v.y,-v.x,-v.y)
  end
end

return spawnManager