local Block = class_new("Block")

Block.speed = 100
Block.baseSpeed = 100
Block.size={width=66,height=24}

function Block.load()
  
end

function Block.new(x,y,parent,w,h)
  local self = Block.newObject()
  if love.math.random()>0.5 then
    self.width=w or Block.size.width
    self.height=h or Block.size.height
  else
    self.width=h or Block.size.height
    self.height=w or Block.size.width
  end
  self:setOriginFromCenter({x=x,y=y})
  self.parent = parent
  self.distance = self:getDistance()
  self.alive = true
  self:attractOrigin()
  return self
end

function Block:attractOrigin()
  local c = self:getCenter()
  local f = Block.speed/math.sqrt(c.x*c.x+c.y*c.y)
  self.speed = {x=-c.x*f,y=-c.y*f}
end

function Block:getDistance()
  local c = self:getCenter()
  return math.sqrt(c.x*c.x+c.y*c.y)
end

--[[ Centro =
(x + w/2*cos - h/2*sin, y + w/2*sin + h/2*cos)
]]
function Block:getCenter()
  local si = math.sin(self.angle)
  local co = math.cos(self.angle)
  return {x=self.x+(self.width*co-self.height*si)/2,y=self.y+(self.width*si+self.height*co)/2}
end

function Block:setOriginFromCenter(center)
  self.angle = math.atan2(center.y,center.x)-math.pi/2
  local si = math.sin(self.angle)
  local co = math.cos(self.angle)
  self.x = center.x - (self.width*co-self.height*si)/2
  self.y = center.y - (self.width*si+self.height*co)/2
end

function Block:update(dt)
  self.x = self.x+self.speed.x*dt
  self.y = self.y+self.speed.y*dt
  local dist = self:getDistance()
  if dist>self.distance then
    self.alive = false
  end
  self.distance = dist
end

function Block:draw()
  --love.graphics.setColor(0,0,255)
  love.graphics.push()
  love.graphics.translate(self.x,self.y)
  local dist = self:getDistance()/self.parent.radius
  dist = dist-(dist-1)/2
  dist = 1
  local w = dist*self.width
  local h = dist*self.height
  love.graphics.rotate(self.angle)
  love.graphics.rectangle("fill",(self.width-w)/2,(self.height-h)/2,w,h)
  love.graphics.pop()
  --[[
  love.graphics.push()
  love.graphics.translate(-self.x-self.width,self.y)
  love.graphics.rectangle("fill",0,0,self.width,self.height)
  love.graphics.pop()
  ]]
end

return Block