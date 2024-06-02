require("scripts.core")
if not host:isHost() then return end

local princeCopy = models.models.prince.World.Prince

for _,part in pairs({"Head","Body","RightArm","LeftArm","LeftLeg","RightLeg"}) do
  princeCopy[part]:setParentType("NONE")
end
princeCopy.RightArm.RightItemPivot:setParentType("NONE")
princeCopy.LeftArm.LeftItemPivot:setParentType("NONE")

function events.tick()
  princeCopy.RightArm.RightItemPivot:newItem("RightHandItem"):setItem(player:getHeldItem()):setRot(-90,0,180):setDisplayMode("THIRD_PERSON_RIGHT_HAND")
  princeCopy.LeftArm.LeftItemPivot:newItem("LeftHandItem"):setItem(player:getHeldItem(true)):setRot(-90,0,180):setDisplayMode("THIRD_PERSON_LEFT_HAND")
  princeCopy.Head.Snorkel:setVisible(player:isUnderwater())
  if player:getGamemode() == "SPECTATOR" then
    princeCopy.Head:setOpacity(0.25)
    princeCopy.Body:setVisible(false)
    princeCopy.LeftArm:setVisible(false)
    princeCopy.RightArm:setVisible(false)
    princeCopy.LeftLeg:setVisible(false)
    princeCopy.RightLeg:setVisible(false)
    models.models.prince.World.Katamari:setVisible(false)
  else
    princeCopy.Head:setOpacity(1)
    princeCopy.Body:setVisible(true)
    princeCopy.LeftArm:setVisible(true)
    princeCopy.RightArm:setVisible(true)
    princeCopy.LeftLeg:setVisible(true)
    princeCopy.RightLeg:setVisible(true)
    models.models.prince.World.Katamari:setVisible(isKatamariToggled)
  end
  if world.getTime() % 4 == 0 and isObjectsToggled then
    local pos = (player:getPos()):floor()
    local rot = (player:getRot())
    local objects = #models.models.itemCopies.World:getChildren()
    pings.objectWorldSpawn(world.getTime(),pos,rot,objects)
  end
end

function events.post_world_render(delta)
  if not player:isLoaded() then return end
  local headMat = prince.Head:partToWorldMatrix():invert():translate(0,5,0) * models:partToWorldMatrix()
    princeCopy.Head:setMatrix(headMat:invert():translate(0,16000,0))
    local bodyMat = prince.Body:partToWorldMatrix():invert():translate(0,5,0) * models:partToWorldMatrix()
    princeCopy.Body:setMatrix(bodyMat:invert():translate(0,16000,0))
    local leftArmMat = prince.LeftArm:partToWorldMatrix():invert():translate(-1,4.5,0) * models:partToWorldMatrix()
    princeCopy.LeftArm:setMatrix(leftArmMat:invert():translate(0,16000,0))
    local rightArmMat = prince.RightArm:partToWorldMatrix():invert():translate(1,4.5,0) * models:partToWorldMatrix()
    princeCopy.RightArm:setMatrix(rightArmMat:invert():translate(0,16000,0))
    local leftLegMat = prince.LeftLeg:partToWorldMatrix():invert():translate(-0.35,2.4,0) * models:partToWorldMatrix()
    princeCopy.LeftLeg:setMatrix(leftLegMat:invert():translate(0,16000,0))
    local rightLegMat = prince.RightLeg:partToWorldMatrix():invert():translate(0.45,2.4,0) * models:partToWorldMatrix()
    princeCopy.RightLeg:setMatrix(rightLegMat:invert():translate(0,16000,0))
    
    princeCopy:setPos(player:getPos(delta)*16):setRot(0,-player:getBodyYaw(delta)-180)
    local pivotOffset = {0,0}
    if player:getPose() == "SWIMMING" then
      pivotOffset = {5,-14}
    end
    local princeMat = models:partToWorldMatrix():invert():translate(0,pivotOffset[2],pivotOffset[1]) * models.models.prince.World.ImportantCube:partToWorldMatrix()
    princeCopy:setMatrix(princeMat:invert())

    if perspective ~= 0 then
      vanilla_model.HELD_ITEMS:setVisible(false)
      renderer.renderCrosshair = false
      princeCopy:setVisible(true)
      local camPos = player:getPos(delta) + vec(0,(katamariRadius-5)/15 + 0.35 + cameraOffset,0)
      local dir = player:getLookDir()*perspective
      local _, hitPos = raycast:block(camPos,camPos-dir*((katamariRadius-5)/8+1))
      local distance = (camPos - hitPos):length()
      renderer:setCameraPivot(camPos)
      renderer:setCameraPos(0,0,distance - 0.2)
      if perspective == -1 then
        renderer:setOffsetCameraRot(180,0,180)
      else
        renderer:setOffsetCameraRot(0,0,0)
      end
    else
      vanilla_model.HELD_ITEMS:setVisible(true)
      renderer.renderCrosshair = true
      princeCopy:setVisible(false)
      renderer:setOffsetCameraRot(0,0,0)
      renderer:setCameraPos(nil)
      renderer:setCameraPivot(player:getPos(delta)+vec(0,6/16+cameraOffset,0))
      renderer:setEyeOffset(0,-1.245+cameraOffset*-4.6,0)
    end
end
