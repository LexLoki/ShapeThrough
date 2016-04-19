function sign(n)
  if n<0 then return 1 else return -1 end
end

function safeIter (a, i)
  i = i - 1
  local v = a[i]
  if v then
    return i, v
  end
end
    
function safePairs (a)
  return safeIter, a, #a+1
end

function table.cat(t1,t2)
  for i,v in pairs(t2) do table.insert(t1,v) end
end

function floorN(num,n)
  local div = math.pow(10,n)
  return math.floor(num*div)/div
end