if not host:isHost() then return end
-- require
require("scripts.core")

-- define vars
local perspective = 0
local pivotOffset = {0,0}
local cameraOffset = 0
local crouchOffset = 0
local isThirdPerson = false
local importantGroup = models.models.prince.World.ImportantGroup

-- avatar setup
models.models.prince.World:addChild(deepCopy(models.models.prince.Prince))
local princeCopy = models.models.prince.World.Prince
for _,part in pairs({"Head","Body","RightArm","LeftArm","LeftLeg","RightLeg"}) do
  princeCopy[part]:setParentType("NONE")
end
princeCopy.RightArm.RightItemPivot:setParentType("NONE")
princeCopy.LeftArm.LeftItemPivot:setParentType("NONE")

-- keybinds
local togglePerspective = keybinds:fromVanilla("key.togglePerspective")
function togglePerspective.press()
  if not isThirdPerson then
    perspective = (perspective + 2) % 3 - 1
    return true
  else
    return false
  end
end

-- tick function
function events.tick()
  -- custom held items
  princeCopy.RightArm.RightItemPivot:newItem("RightHandItem")
    :setItem(player:getHeldItem())
    :setRot(-90,0,180)
    :setDisplayMode("THIRD_PERSON_RIGHT_HAND")
  princeCopy.LeftArm.LeftItemPivot:newItem("LeftHandItem")
    :setItem(player:getHeldItem(true))
    :setRot(-90,0,180)
    :setDisplayMode("THIRD_PERSON_LEFT_HAND")
  -- snorkel visiblity
  princeCopy.Head.Snorkel:setVisible(player:isUnderwater())
  -- custom spectator
  if player:getGamemode() == "SPECTATOR" then
    princeCopy.Head:setOpacity(0.25)
    princeCopy.Body:setVisible(false)
    princeCopy.LeftArm:setVisible(false)
    princeCopy.RightArm:setVisible(false)
    princeCopy.LeftLeg:setVisible(false)
    princeCopy.RightLeg:setVisible(false)
  else
    princeCopy.Head:setOpacity(1)
    princeCopy.Body:setVisible(true)
    princeCopy.LeftArm:setVisible(true)
    princeCopy.RightArm:setVisible(true)
    princeCopy.LeftLeg:setVisible(true)
    princeCopy.RightLeg:setVisible(true)
  end
  -- triggers object spawning, and sends data through pings
  if isObjectsToggled and world.getTime() % 4 == 0 then
    local pos = (player:getPos()):floor()
    local rot = (player:getRot())
    local objects = #models.models.itemCopies.World:getChildren()
    pings.objectWorldSpawn(world.getTime(),pos,rot,objects)
  end
end

-- render function
function events.render(delta,context)
  -- first person arm control
  if context == "FIRST_PERSON"then
    if perspective == 0  and not isHUDToggled then
      prince.RightArm["Right Arm"]:setVisible(true)
        :setScale(6)
        :setPos(2,16,2)
    else
      prince.RightArm["Right Arm"]:setVisible(false)
    end
  else
    prince.RightArm["Right Arm"]:setVisible(true)
      :setScale(1)
      :setPos(0,0,0)
  end
  -- show and scale up default player for GUI, otherwise hide it away lol
  if context == "MINECRAFT_GUI" or context == "FIGURA_GUI" then
    prince:setPos(0,crouchOffset,0)
    prince:setScale(4)
  else
    prince:setPos(0,-16000 + crouchOffset,0)
    prince:setScale(1)
  end
  -- detect real third person
  if context == "RENDER" then
    isThirdPerson = true
    host:actionbar([[{"text":"Please switch back to first person! Camera rotation will be broken!","bold":true,"color":"red"}]])
  else
    if isThirdPerson then
      host:actionbar([[{"text":"Thanks <3","bold":true,"color":"green"}]])
    end
    isThirdPerson = false
  end
  -- camera and crouch offsets for poses
  if player:getPose() == "SWIMMING" then
    pivotOffset = {5,-14}
    crouchOffset = 0
    cameraOffset = math.lerp(cameraOffset-(0.3/16),-2/16,0.1)
  elseif player:getPose() == "FALL_FLYING" then
    pivotOffset = {0,0}
    crouchOffset = 0
    cameraOffset = math.lerp(cameraOffset-(0.3/16),-2/16,0.1)
  elseif player:isCrouching() then
    pivotOffset = {0,0}
    crouchOffset = 4
    cameraOffset = math.lerp(cameraOffset,-2/16,0.1)
  else
    pivotOffset = {0,0}
    crouchOffset = 0
    cameraOffset = math.lerp(cameraOffset,0,0.1)
  end
end

-- world render function
function events.post_world_render(delta)
  if not player:isLoaded() then return end
  -- immatate vanilla part rot and position
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
  local princeMat = models:partToWorldMatrix():invert():translate(0,pivotOffset[2],pivotOffset[1]) * importantGroup:partToWorldMatrix()
  princeCopy:setMatrix(princeMat:invert())

  -- custom camera & perspective adjustments
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
