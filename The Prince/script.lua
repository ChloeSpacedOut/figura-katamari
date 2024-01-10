vanilla_model.PLAYER:setVisible(false)
--models.models.prince.root.World.Katamari.parts:setPos(0,-16,0)

local density = 300 -- number of items allowed to exist at once
local spawnRange = 50 -- the diameter from the player items spawn

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

local function isOnScreen(worldPos)
  screenPos = vectors.worldToScreenSpace(worldPos)
  return (-2 < screenPos.x and screenPos.x < 2) and (-2 < screenPos.y and screenPos.y < 2) and screenPos.z > 1
end

local denyList = {"head","door"}

function objectSpawn(spawnID)
  local clientPos = client.getViewer():getPos()
  local likleyCeiling = checkCeilng(clientPos)
  local randomPos = vec(math.floor(clientPos.x) + math.random(-spawnRange, spawnRange), math.floor(clientPos.y) + likleyCeiling, math.floor(clientPos.z) + math.random(-spawnRange, spawnRange))
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
      if isOnScreen(finalPos) then
        local blockHeight = 0
        if blockstate:getCollisionShape()[1] then
          blockHeight = blockstate:getCollisionShape()[1][2].y
        end
        local finalFinalPos = finalPos*16 + vec(0,blockHeight*16,0)
        local itemPool = models.models.items.World:getChildren()
        models.models.itemCopies.World:newPart(world.getTime()*10+spawnID):addChild(deepCopy(itemPool[math.random(1,#itemPool)]))
        models.models.itemCopies.World[world.getTime()*10+spawnID]:setPos(finalFinalPos + vec(math.random(1,8)+4,0,math.random(1,8)+4))
        models.models.itemCopies.World[world.getTime()*10+spawnID]:setRot(0,math.random(0,360),0)
      end
    end
  end
end

function events.tick()
  for spawnID = 1,10 do
    if #models.models.itemCopies.World:getChildren() < density then
      objectSpawn(spawnID)
    end
  end
  models.models.prince.root.Head.Snorkel:setVisible(player:isUnderwater())
end

lastFrameTime = client.getSystemTime()
lastPos = vec(0,0,0)
pos = vec(0,0,0)
mat = matrices.mat4()

function events.render(delta)
  local katamariPos = models.models.prince.root.KatamariPos:partToWorldMatrix():apply()
  lastPos = pos
  pos = katamariPos
  --print(delta)
  local truePos = math.lerp(lastPos,pos,delta)
  local vel = (lastPos-pos)*2
  mat:rotate(math.deg(-vel.z)*delta,0,math.deg(vel.x)*delta)
  mat.v14 = truePos.x*16
  mat.v24 = (truePos.y+1)*16
  mat.v34 = truePos.z*16

  local rotScaleComp = matrices.mat3(vec(mat.v11,mat.v21,mat.v31),vec(mat.v12,mat.v22,mat.v32),vec(mat.v13,mat.v23,mat.v33)):invert()
  local column1 = vec(rotScaleComp.v11,rotScaleComp.v21,rotScaleComp.v31,mat.v41 * -1)
  local column2 = vec(rotScaleComp.v12,rotScaleComp.v22,rotScaleComp.v32,mat.v42 * -1)
  local column3 = vec(rotScaleComp.v13,rotScaleComp.v23,rotScaleComp.v33,mat.v43 * -1)
  local column4 = vec(mat.v14,mat.v24,mat.v34,mat.v44)

  local matInverted = matrices.mat4(column1,column2,column3,column4)
  models.models.prince.root.World:setMatrix(mat)

  for k,item in pairs(models.models.itemCopies.World:getChildren()) do
    local pos = item:getPos()/16
    local horosontalDistance = math.sqrt((katamariPos.x-pos.x)^2 + (katamariPos.z-pos.z)^2)
    local distance = math.sqrt((horosontalDistance^2 + (katamariPos.y-pos.y+1)^2))
    if distance < (20/16) then
      sounds:playSound("minecraft:block.beehive.drip",player:getPos())
      local relativePos = katamariPos-pos
      relativePos = vec(relativePos.x,-relativePos.y,relativePos.z)
      local UUID = tostring(world.getTime()*#models.models.itemCopies.World:getChildren() + k)
      models.models.prince.root.World.Katamari.parts:newPart(UUID):addChild(deepCopy(item))
      local katamariPartParent = models.models.prince.root.World.Katamari.parts[UUID]
      local katamariPart = katamariPartParent:getChildren()[1]

      katamariPartParent:setMatrix(katamariPartParent:getPositionMatrix():translate(-katamariPos*16 - vec(0,16,0)):rotateY(180) * matInverted)
      katamariPart:setPos(katamariPart:getPos() -katamariPos*16 - vec(0,16,0))
      models.models.itemCopies.World:removeChild(item)
    end
    if distance > (spawnRange) then
      models.models.itemCopies.World:removeChild(item)
    end
  end
end