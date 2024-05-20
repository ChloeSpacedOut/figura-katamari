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
function events.tick()
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

local cameraOffset = 0
local crouchOffset
function events.world_render(delta)
  if player:isLoaded() then
    if player:isCrouching() then
      crouchOffset = 2.5
      models.models.prince.World.Prince.RightLeg:setPos(0,-3,-3)
      models.models.prince.World.Prince.LeftLeg:setPos(0,-3,-3)
      cameraOffset = math.lerp(cameraOffset,-1/16,0.15)
    else
      cameraOffset = math.lerp(cameraOffset,0,0.15)
      crouchOffset = 0
      models.models.prince.World.Prince.RightLeg:setPos(0,0,0)
      models.models.prince.World.Prince.LeftLeg:setPos(0,0,0)
    end
    katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-17)/16,0) + ((vectors.angleToDir(player:getRot(delta))*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1)))
    ballRotMat = rotateBall(delta,katamariPos)
    models.models.prince.World.Katamari:setMatrix(ballRotMat)
    models.models.prince.World.Prince:setPos(player:getPos(delta)*16 + vec(0,crouchOffset,0)):setRot(0,-player:getBodyYaw(delta)-180)
    renderer:setCameraPivot(player:getPos(delta) + vec(0,(katamariRadius-5)/15 + 0.35 + cameraOffset,0))
    renderer:setCameraPos(0,0,(katamariRadius-5)/8+1)
  end
end