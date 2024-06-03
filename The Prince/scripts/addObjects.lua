-- define vars
katamariRadius = 5
local objectDensityModifier = 3 -- adjusts how much the katamari will grow per each new object
local pickupTheshold = 1.2 -- adjusts how long the object must be before it can be picked up, where 1 is the radius of the katamari
local ticksToIterate = 3 -- how many ticks it takes to check all the objects

function addObjects(katamariPos,matInverted)
  local min = (world.getTime() % ticksToIterate)*(density/ticksToIterate)
  local max = (world.getTime() % ticksToIterate + 1)*(density/ticksToIterate) % (density+1)
  -- iterate for all spawned objects
  for k,item in pairs(models.models.itemCopies.World:getChildren()) do
    local distance
    -- only do check if within the iteration range
    if k > min and k < max then
      local itemID = item:getChildren()[1]:getName()
      local pos = item:getPos()/16 + item:getChildren()[1]:getPivot()/16
      distance = (katamariPos-(pos - vec(0,1,0))):length()
      -- if object is within the pickup range & small enough to be picked up
      if distance < (katamariRadius/16) and objectList[itemID].length < katamariRadius * pickupTheshold then
        -- execute pickup logic
        sounds:playSound("minecraft:block.beehive.drip",player:getPos())
        local addedVolume = objectList[itemID].volume
        local katamariVolume = (4/3)*math.pi*katamariRadius^3
        katamariRadius = ((3/(4*math.pi))*(katamariVolume + addedVolume*objectDensityModifier))^(1/3)
        -- generate clone of part
        local UUID = tostring(world.getTime()*#models.models.itemCopies.World:getChildren() + k)
        models.models.prince.World.Katamari.parts:newPart(UUID):addChild(deepCopy(item))
        -- reposition part to match world position
        local katamariPartParent = models.models.prince.World.Katamari.parts[UUID]
        local katamariPart = katamariPartParent:getChildren()[1]
        katamariPartParent:setMatrix(katamariPartParent:getPositionMatrix():translate(-katamariPos*16 - vec(0,16,0)):rotateY(180) * matInverted)
        katamariPart:setPos(katamariPart:getPos() -katamariPos*16 - vec(0,16,0))
        -- remove origional objects and cull objects in the katamari
        models.models.itemCopies.World:removeChild(item)
        katamariObjects[UUID] = {distance = distance*16, length = objectList[itemID].length}
        cullKatamari()
      end
    end
  end
end