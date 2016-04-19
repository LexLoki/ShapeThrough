local Player = class_new("Player")
local PlayerShape = require "src/playerShape"
Player.baseSpeed = 2.5--3
Player.speed = 2.5
Player.size={
  big = 70,
  small = 25
}

function Player.new(data,parent)
  local self = Player.newObject()
  -- SET PROPERTIES
  self.color = data.color
  self.input = data.input
  self.angle = math.pi/2
  self.parent = parent
  self.width = 70
  self.height = 25
  self:updatePos()
  self.shape = PlayerShape.new(self)
  return self
end

function Player:keypressed(key)
  if key==self.input.switch then
    self.shape:switch()
    return true
  end
  return false
end

function Player:update(dt)
  self.shape:update(dt)
  if love.keyboard.isDown(self.input.right) then
    self.speed = -Player.speed
  elseif love.keyboard.isDown(self.input.left) then
    self.speed = Player.speed
  else
    self.speed = 0
  end
  self.angle = self.angle + self.speed*dt
  self:updatePos()
end

function Player:updatePos()
  local p = self.parent
  self.x = math.cos(self.angle)*p.radius--+p.center.x
  self.y = math.sin(self.angle)*p.radius--+p.center.y
end

function Player:draw()
  love.graphics.push()
  love.graphics.setColor(self.color)
  love.graphics.translate(self.x,self.y); love.graphics.rotate(self.angle-math.pi/2)
  love.graphics.rectangle("fill",-self.width/2,0,self.width,self.height)
  love.graphics.pop()
end

return Player