vanilla_model.PLAYER:setVisible(false)

lastFrameTime = client.getSystemTime()
lastPos = vec(0,0,0)
pos = vec(0,0,0)
mat = matrices.mat4()

local function deepCopy(model)
  local copy = model:copy(model:getName())
  for _, child in pairs(copy:getChildren()) do
      copy:removeChild(child):addChild(deepCopy(child)):parentType()
  end
  return copy
end

local maxCeilingHeight = 5 
local function checkCeilng(clientPos)
  local likleyCeiling = 0
  for k = 1, maxCeilingHeight do
    if world.getBlockState(clientPos+vec(0,k,0)):hasCollision() then
      return k
    end
  end
  return maxCeilingHeight
end

local denyList = {"head","door"}

function objectSpawn()
  local clientPos = client.getViewer():getPos()
  local likleyCeiling = checkCeilng(clientPos)
  local randomPos = vec(math.floor(clientPos.x) + math.random(-20,20), math.floor(clientPos.y) + likleyCeiling, math.floor(clientPos.z) + math.random(-20,20))
  for k = 0, 5 + likleyCeiling do
    local pos = randomPos - vec(0,k,0)
    local blockstate = world.getBlockState(pos)
    local aboveBlockstate = world.getBlockState(pos+vec(0,1,0))
    local isDenyListed = false
    local isDenyListedAbove = false
    for i,j in pairs(denyList) do
      if string.find(blockstate.id,j) then
        isDenyListed = true
      end
      if string.find(aboveBlockstate.id,j) then
        isDenyListedAbove = true
      end
    end
    if (blockstate:hasCollision() and not (blockstate.id == "minecraft:light" or isDenyListed)) and (not aboveBlockstate:hasCollision() or aboveBlockstate.id == "minecraft:light" or isDenyListedAbove) then
      local finalPos = pos+vec(0.5,0,0.5)
      local blockHeight = 0
      if blockstate:getCollisionShape()[1] then
        blockHeight = blockstate:getCollisionShape()[1][2].y
      end
      local finalFinalPos = finalPos*16 + vec(0,blockHeight*16,0)
      local itemPool = models.items.World:getChildren()
      models.itemCopys.World:newPart(world.getTime()):addChild(deepCopy(itemPool[math.random(1,#itemPool)]))
      models.itemCopys.World[world.getTime()]:setPos(finalFinalPos)
      models.itemCopys.World[world.getTime()]:setRot(0,math.random(0,360),0)
    end
  end
end

function events.tick()
  if world.getTime() % 10 == 0 then
    objectSpawn()
  end
  models.prince.root.Head.Snorkel:setVisible(player:isUnderwater())
end

function events.render(delta)
  local katamariPos = models.prince.root.KatamariPos:partToWorldMatrix():apply()
  lastPos = pos
  pos = katamariPos

  local systmTime = client.getSystemTime()
   local fdelta = (systmTime-lastFrameTime)/50
   --print(delta)
    lastFrameTime = systmTime
    local truePos = math.lerp(lastPos,pos,delta)
    local vel = (lastPos-pos)*8
    mat:rotate(math.deg(-vel.z)*fdelta,0,math.deg(vel.x)*fdelta)
    mat.v14 = truePos.x*16
    mat.v24 = (truePos.y+1)*16
    mat.v34 = truePos.z*16
    models.prince.root.World:setMatrix(mat)

    for k,item in pairs(models.itemCopys.World:getChildren()) do
      local pos = item:getPos()/16
      local horosontalDistance = math.sqrt((katamariPos.x-pos.x)^2 + (katamariPos.z-pos.z)^2)
      local distance = math.sqrt((horosontalDistance^2 + (katamariPos.y-pos.y)^2))
      if distance < (15/16) then
        models.itemCopys.World:removeChild(item)
      end
    end
end