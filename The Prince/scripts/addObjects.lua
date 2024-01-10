function addObjects(katamariPos,matInverted)
  for k,item in pairs(models.models.itemCopies.World:getChildren()) do
    local pos = item:getPos()/16 + item:getChildren()[1]:getPivot()/16
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