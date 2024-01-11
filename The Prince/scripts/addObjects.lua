katamariRadius = 17
local objectDensityModifyer = 5 -- addjust how much the katamari will grow per each new object

function addObjects(katamariPos,matInverted)
  for k,item in pairs(models.models.itemCopies.World:getChildren()) do
    local itemID = item:getChildren()[1]:getName()
    local pos = item:getPos()/16 + item:getChildren()[1]:getPivot()/16
    local horosontalDistance = math.sqrt((katamariPos.x-pos.x)^2 + (katamariPos.z-pos.z)^2)
    local distance = math.sqrt((horosontalDistance^2 + (katamariPos.y-pos.y+1)^2))
    if distance < (katamariRadius/16) then
      sounds:playSound("minecraft:block.beehive.drip",player:getPos())
      local length = objectList[itemID].length
      local addedVolume = objectList[itemID].volume
      local katamariVolume = (4/3)*math.pi*katamariRadius^3
      katamariRadius = ((3/(4*math.pi))*(katamariVolume + addedVolume*objectDensityModifyer))^(1/3)
      local relativePos = (katamariPos/16)-pos
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