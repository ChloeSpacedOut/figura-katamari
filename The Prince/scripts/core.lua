require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")
require("scripts.cullKatamari")

vanilla_model.ALL:setVisible(false)
renderer:setShadowRadius(1/8)
--renderer:crosshairOffset(9999,0)
models.models.prince.World.Prince.Head:setPrimaryRenderType("TRANSLUCENT_CULL")
ballRotMat = nil
isObjectsToggled = false
isKatamariToggled = false
local katamariPos
local lastRunClock = 0
local runClock = 0
local perspective = 0

local princeCopy = models.models.prince:addChild(deepCopy(models.models.prince.World.Prince))
princeCopy:setScale(4)

local prince = models.models.prince.World.Prince
for _,part in pairs({"Head","Body","RightArm","LeftArm","LeftLeg","RightLeg"}) do
  princeCopy.Prince[part]:setParentType(part)
  prince[part]:setParentType(nil)
end
princeCopy.Prince.LeftArm:setParentType("LeftArm")


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
  models.models.prince.World.Prince.Head.Snorkel:setVisible(player:isUnderwater())
  if ballRotMat and isObjectsToggled then
    addObjects(katamariPos,inverseRotMatrix(ballRotMat))
  end
  if player:getGamemode() == "SPECTATOR" then
    models.models.prince.World.Prince.Head:setOpacity(0.25)
    models.models.prince.World.Prince.Body:setVisible(false)
    models.models.prince.World.Prince.LeftArm:setVisible(false)
    models.models.prince.World.Prince.RightArm:setVisible(false)
    models.models.prince.World.Prince.LeftLeg:setVisible(false)
    models.models.prince.World.Prince.RightLeg:setVisible(false)
    models.models.prince.World.Katamari:setVisible(false)
  else
    models.models.prince.World.Prince.Head:setOpacity(1)
    models.models.prince.World.Prince.Body:setVisible(true)
    models.models.prince.World.Prince.LeftArm:setVisible(true)
    models.models.prince.World.Prince.RightArm:setVisible(true)
    models.models.prince.World.Prince.LeftLeg:setVisible(true)
    models.models.prince.World.Prince.RightLeg:setVisible(true)
    models.models.prince.World.Katamari:setVisible(isKatamariToggled)
  end
end

local cameraOffset = 0
local crouchOffset = 0
renderer:setForcePaperdoll(true)

local togglePerspective = keybinds:fromVanilla("key.togglePerspective")
function togglePerspective.press()
  perspective = (perspective + 2) % 3 - 1
  return true
end

function events.render(delta,context)
  if not host:isHost() then return end
  if context == "RENDER" then
    log("Please switch to first person and reload avatar.")
    error("womp womp, killing avatar")
  end
  if context == "FIRST_PERSON" then
    if perspective == 0 then
      princeCopy.Prince.RightArm["Right Arm"]:setVisible(true):setScale(6):setPos(2,16,2)
    else
      princeCopy.Prince.RightArm["Right Arm"]:setVisible(false)
    end
  else
    princeCopy.Prince.RightArm["Right Arm"]:setVisible(true):setScale(1):setPos(0,0,0)
  end
end

function events.post_world_render(delta)
  if player:isLoaded() then
    local armOffset
    if isKatamariToggled then
      armOffset = 90
    else
      armOffset = 0
    end
    local lerpedRunClock = math.lerp(lastRunClock,runClock,delta)
    local rot = player:getRot()
		local yaw = player:getBodyYaw()
    local vel = player:getVelocity():mul(1,0,1):length()
    vel = math.clamp(vel,0,0.3)
    local wave1 = (math.sin(lerpedRunClock*2)*753.6-32.6)*vel
    local wave2 = (math.sin((lerpedRunClock+math.pi/2)*2)*753.6-32.6)*vel
    prince.Head:setRot(-player:getRot(delta).x,math.clamp(-((rot.y-yaw + 180) % 360 - 180),-50,50),0)
    prince.LeftLeg:setRot(wave1*0.25)
    prince.RightLeg:setRot(wave2*0.25)
    prince.LeftArm:setRot(wave2*0.25+armOffset,0,-15)
    prince.RightArm:setRot(wave1*0.25+armOffset,0,15)
    if player:isCrouching() then
      crouchOffset = -1
      prince.Body:setRot(-20)
      prince.RightLeg:setPos(0,0,0.8)
      prince.LeftLeg:setPos(0,0,0.8)
      cameraOffset = math.lerp(cameraOffset,-1/16,0.15)
    else
      crouchOffset = 0
      cameraOffset = math.lerp(cameraOffset,0,0.15)
      prince.Body:setRot(0)
      prince.RightLeg:setPos(0,0,0)
      prince.LeftLeg:setPos(0,0,0)
    end
    if isKatamariToggled then
      katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-17)/16,0) + ((vectors.angleToDir(player:getRot(delta))*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1)))
      ballRotMat = rotateBall(delta,katamariPos)
      models.models.prince.World.Katamari:setMatrix(ballRotMat)
    end
    models.models.prince.World.Prince:setPos(player:getPos(delta)*16+vec(0,crouchOffset,0)):setRot(0,-player:getBodyYaw(delta)-180)
    if perspective ~= 0 then
      renderer.renderCrosshair = false
      prince:setVisible(true)
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
      renderer.renderCrosshair = true
      prince:setVisible(false)
      renderer:setOffsetCameraRot(0,0,0)
      renderer:setCameraPos(nil)
      renderer:setCameraPivot(player:getPos(delta)+vec(0,6/16+cameraOffset,0))
      renderer:setEyeOffset(0,-1.245+cameraOffset*-4.6,0)
    end
  end
end
