-- require
require("scripts.objectAnimator")
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
      local isNotTooBig = objectList[itemID].length < katamariRadius * pickupTheshold
      local isTouchingObject = distance < (katamariRadius/16)
      local isCollidingObject  = distance < (katamariRadius/16 + 0.4)
      if isTouchingObject and isNotTooBig then
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
        -- apply pickup indicator animation
        if host:isHost() then
          local pickupPreview = models.models.HUD.HUD.PickupPreview
          for _,part in pairs(pickupPreview.Object.RotateObject:getChildren()) do
            part:remove()
          end
          pickupPreview.Object.RotateObject:newPart(UUID):addChild(deepCopy(item))
          local objectPart = pickupPreview.Object.RotateObject[UUID]:getChildren()[1]
          pickupPreview.Object.RotateObject[UUID]:setPos(0,-25,0)
          local previewData = objectList[itemID].previewData
          objectPart:setPos(0,0,0)
            :setRot(0,0,0)
            :setScale(previewData[2])
          pickupPreview.Object:setRot(-35,0,0)
            :setPos(0,previewData[1],0)
          pickupPreviewName:setText(objectList[itemID].name)
          animations["models.HUD"].pickupObject:stop()
          animations["models.HUD"].pickupObject:play()
        end
        -- remove origional objects and cull objects in the katamari
        models.models.itemCopies.World:removeChild(item)
        katamariObjects[UUID] = {distance = distance*16, length = objectList[itemID].length}
        cullKatamari()
      -- checks if colliding with too big object
      elseif isCollidingObject and not isNotTooBig then
        local partID = item:getName()
        -- adds object to animation database
        if not hitObjectIndex[partID] then
          local partPos = item:partToWorldMatrix():apply()
          local angle =  math.deg(math.atan2(katamariPos.x - partPos.x,katamariPos.z - partPos.z)) - 180
          hitObjectIndex[partID] = {collisionTime = world.getTime(), collisionAngle = angle}
          sounds:playSound("minecraft:block.anvil.hit",player:getPos())
        end
      end
    end
  end
end