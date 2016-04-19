local playerShape = class_new("Shape")

playerShape.cooldown = 0.2

function playerShape.new(player)
  local self = playerShape.newObject()
  self.player = player
  self.timer = 0
  return self
end

function playerShape:update(dt)
  if self.timer > 0 then
    self.timer = self.timer - dt
  end
end

function playerShape:switch()
  if self.timer <=0 then
    self.timer = self.cooldown
    local aux = self.player.width
    self.player.width = self.player.height
    self.player.height = aux
  end
end

return playerShape