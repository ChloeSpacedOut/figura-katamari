require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")
require("scripts.cullKatamari")

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
local prince = models.models.prince.Prince
renderer:setShadowRadius(1/8)
prince.Head:setPrimaryRenderType("TRANSLUCENT_CULL")
ballRotMat = nil
isObjectsToggled = false
isKatamariToggled = false
local katamariPos
local lastRunClock = 0
local runClock = 0
local perspective = 0
prince.RightArm.RightItemPivot:setScale(0.25)
prince.LeftArm.LeftItemPivot:setScale(0.25)
models.models.prince.World:addChild(deepCopy(models.models.prince.Prince))
local princeCopy = models.models.prince.World.Prince

for _,part in pairs({"Head","Body","RightArm","LeftArm","LeftLeg","RightLeg"}) do
  princeCopy[part]:setParentType("NONE")
end
princeCopy.RightArm.RightItemPivot:setParentType("NONE")
princeCopy.LeftArm.LeftItemPivot:setParentType("NONE")


local mainPage = action_wheel:newPage("mainPage")
action_wheel:setPage(mainPage)

function pings.toggleObjects(bool)
  isObjectsToggled = bool
  if not bool then
    for _,part in pairs(models.models.itemCopies.World:getChildren()) do
      part:remove()
    end
  end
end

local toggleObjects = mainPage:newAction()
  :title("Toggle Objects")
  :item('chest')
  :setOnToggle(pings.toggleObjects)

function pings.toggleKatamari(bool)
  isKatamariToggled = bool
  models.models.prince.World.Katamari:setVisible(false)
end

local toggleKatamari = mainPage:newAction()
  :title("Toggle Katamari")
  :item('slime_ball')
  :setOnToggle(pings.toggleKatamari)

function events.tick()
  lastRunClock = runClock
  runClock = runClock + math.clamp(player:getVelocity():mul(1,0,1):length(),0,0.3)
  if host:isHost() and world.getTime() % 4 == 0 and isObjectsToggled then
    local pos = (player:getPos()):floor()
    local rot = (player:getRot())
    local objects = #models.models.itemCopies.World:getChildren()
    pings.objectWorldSpawn(world.getTime(),pos,rot,objects)
  end
  prince.Head.Snorkel:setVisible(player:isUnderwater())
  princeCopy.Head.Snorkel:setVisible(player:isUnderwater())
  if ballRotMat and isObjectsToggled then
    addObjects(katamariPos,inverseRotMatrix(ballRotMat))
  end
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
end

local cameraOffset = 0
local crouchOffset = 0

local togglePerspective = keybinds:fromVanilla("key.togglePerspective")
function togglePerspective.press()
  perspective = (perspective + 2) % 3 - 1
  return true
end

function events.render(delta,context)
  local crouchOffset = 0
  if player:isCrouching() then
    crouchOffset = 3
    prince.RightLeg:setPos(0,-3,-2.75)
    prince.LeftLeg:setPos(0,-3,-2.75)
    prince.Head:setPos(0,0.5,0)
    cameraOffset = math.lerp(cameraOffset,-2/16,0.1)
  else
    crouchOffset = 0
    cameraOffset = math.lerp(cameraOffset,0,0.1)
    prince.RightLeg:setPos(0,0,0)
    prince.LeftLeg:setPos(0,0,0)
    prince.Head:setPos(0,0,0)
  end

  if context == "MINECRAFT_GUI" or context == "FIGURA_GUI" then
    prince:setPos(0,crouchOffset,0)
    prince:setScale(4)
  else
    prince:setPos(0,-16000 + crouchOffset,0)
    prince:setScale(1)
  end
  if not host:isHost() then return end
  if context == "RENDER" then
    log("Please switch to first person and reload avatar.")
    error("womp womp, killing avatar")
  end
  if isKatamariToggled then
    prince.LeftArm:setRot(90,0,-15)
    prince.RightArm:setRot(90,0,15)
  else
    prince.LeftArm:setRot(0,0,-15)
    prince.RightArm:setRot(0,0,15)
  end
  if context == "FIRST_PERSON" then
    if perspective == 0 then
      prince.RightArm["Right Arm"]:setVisible(true):setScale(6):setPos(2,16,2)
    else
      prince.RightArm["Right Arm"]:setVisible(false)
    end
  else
    prince.RightArm["Right Arm"]:setVisible(true):setScale(1):setPos(0,0,0)
  end
end

function events.post_world_render(delta)
  if player:isLoaded() then
    if isKatamariToggled then
      katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-17)/16,0) + ((vectors.angleToDir(player:getRot(delta))*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1)))
      ballRotMat = rotateBall(delta,katamariPos)
      models.models.prince.World.Katamari:setMatrix(ballRotMat)
    end
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
    models.models.prince.World.ImportantCube:setPos(player:getPos(delta)*16 + vec(0,16000,0))
--[[     local pivotOffset = {0,0}
    if player:getPose() == "SWIMMING" then
      pivotOffset = {5,-14}
    end
    local princeMat = models:partToWorldMatrix():invert():translate(0,pivotOffset[2],pivotOffset[1]) * models.models.prince.World.ImportantCube:partToWorldMatrix()
    princeCopy:setMatrix(princeMat:invert():translate(0,16000,0):translate(player:getPos(delta)*16)) ]]

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
end
