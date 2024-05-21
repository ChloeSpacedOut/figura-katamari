require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")
require("scripts.cullKatamari")

vanilla_model.ALL:setVisible(false)
renderer:setShadowRadius(1/8)
renderer:crosshairOffset(9999,0)
models.models.prince.World.Prince.Head:setPrimaryRenderType("TRANSLUCENT_CULL")
ballRotMat = nil
local katamariPos
local lastRunClock = 0
local runClock = 0
function events.tick()
  lastRunClock = runClock
  runClock = runClock + math.clamp(player:getVelocity():mul(1,0,1):length(),0,0.3)
  if host:isHost() and world.getTime() % 4 == 0 then
    local pos = (player:getPos()):floor()
    local rot = (player:getRot())
    local objects = #models.models.itemCopies.World:getChildren()
    pings.objectWorldSpawn(world.getTime(),pos,rot,objects)
  end
  models.models.prince.World.Prince.Head.Snorkel:setVisible(player:isUnderwater())
  if ballRotMat then
    addObjects(katamariPos,inverseRotMatrix(ballRotMat))
  end
  if player:getGamemode() == "SPECTATOR" then
    models.models.prince.World.Prince.Head:setOpacity(0.25)
    models.models.prince.World.Katamari:setVisible(false)
  else
    models.models.prince.World.Prince.Head:setOpacity(1)
    models.models.prince.World.Katamari:setVisible(true)
  end
end

local prince = models.models.prince.World.Prince
for _,part in pairs({"Head","Body","RightArm","LeftArm","LeftLeg","RightLeg"}) do
  prince[part]:setParentType(nil)
end

local cameraOffset = 0
local crouchOffset = 0
renderer:setForcePaperdoll(true)
function events.post_world_render(delta)
  if player:isLoaded() then
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
    prince.LeftArm:setRot(wave2*0.25+90,0,-15)
    prince.RightArm:setRot(wave1*0.25+90,0,15)
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
    katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-17)/16,0) + ((vectors.angleToDir(player:getRot(delta))*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1)))
    ballRotMat = rotateBall(delta,katamariPos)
    models.models.prince.World.Katamari:setMatrix(ballRotMat)
    models.models.prince.World.Prince:setPos(player:getPos(delta)*16+vec(0,crouchOffset,0)):setRot(0,-player:getBodyYaw(delta)-180)

    local camPos = player:getPos(delta) + vec(0,(katamariRadius-5)/15 + 0.35 + cameraOffset,0)
    local dir = player:getLookDir()
    local _, hitPos = raycast:block(camPos,camPos-dir*((katamariRadius-5)/8+1))
    local distance = (camPos - hitPos):length()
    renderer:setCameraPivot(camPos)
    renderer:setCameraPos(0,0,math.max(distance - 0.2,0))
  end
end
