contact = {}

local checkContact,projectR,project,hasOverlap

function contact.check(player,blocks,game)
  local angle = player.angle - math.pi/2
  local si = math.sin(angle)
  local co = math.cos(angle)
  local p11 = {x=player.x-co*player.width/2, y=player.y-si*player.width/2}
  local hy = co*player.height
  local hx = -si*player.height
  local p12 = {x=2*player.x-p11.x,y=2*player.y-p11.y}
  local p13 = {x=p11.x+hx,y=p11.y+hy}
  local p14 = {x=p12.x+hx,y=p12.y+hy}
  local r1 = {p11,p12,p13,p14}
  local a1 = {}
  putAxis(a1,r1)
  game.tests = {r1}
  for i,v in ipairs(blocks) do
    si = math.sin(v.angle); co = math.cos(v.angle)
    local w = {x=co*v.width,y=si*v.width}
    local h = {x=-si*v.height,y=co*v.height}--{x=co*v.height,y=si*v.height}
    local r2 = {
      {x=v.x,y=v.y},
      {x=v.x+w.x,y=v.y+w.y},
      {x=v.x+h.x,y=v.y+h.y},
      {x=v.x+w.x+h.x,y=v.y+h.y+w.y}
    }
    table.insert(game.tests,r2)
    if checkContact(r1,a1,r2) then
      game.contacted = v
      return true
    end
  end
  return false
end

function checkContact(r1,a1,r2)
  local axis={}
  for i,v in pairs(a1) do
    table.insert(axis,v)
  end
  putAxis(axis,r2)
  for i,v in pairs(axis) do
    local min1,max1=projectR(r1,v)
    local min2,max2=projectR(r2,v)
    if not hasOverlap(min1,max1,min2,max2) then return false end
  end
  return true
end

function putAxis(t,r)
  table.insert(t,{x=r[4].x-r[3].x,y=r[4].y-r[3].y})
  table.insert(t,{x=r[4].x-r[2].x,y=r[4].y-r[2].y})
end

function projectR(r,axis)
  local pos={},max,min
  for i,v in pairs(r) do
    local p = project(v,axis)
    table.insert(pos,p.x*axis.x+p.y*axis.y)
  end
  max = pos[1]; min = pos[1]
  for i=2,#pos do
    if pos[i]>max then
      max = pos[i]
    elseif pos[i]<min then
      min = pos[i]
    end
  end
  return min,max
end

function project(v1,v2)
  local v = (v1.x*v2.x+v1.y*v2.y)/(v2.x*v2.x+v2.y*v2.y)
  return {x=v*v2.x, y=v*v2.y}
end

function hasOverlap(min1,max1,min2,max2)
  return min1<max2 and min2<max1
end

return contact