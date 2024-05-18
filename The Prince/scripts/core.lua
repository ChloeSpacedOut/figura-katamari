require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")
require("scripts.cullKatamari")

vanilla_model.ALL:setVisible(false)
renderer:setShadowRadius(1/8)
renderer:crosshairOffset(9999,0)
local mat
local katamariPos
function events.tick()
  for spawnID = 1,5 do
    if #models.models.itemCopies.World:getChildren() < density then
      objectWorldSpawn(spawnID)
    end
  end
  models.models.prince.World.Prince.Head.Snorkel:setVisible(player:isUnderwater())
  if mat then
    addObjects(katamariPos,inverseRotMatrix(mat))
  end
end

local cameraOffset = 0
function events.render(delta,context)
  --if context == "PAPERDOLL" then models.models.prince.World.Prince:setScale(5) end
  if not (context == "RENDER" or context == "FIRST_PERSON") then return end
  --models.models.prince.World.Prince:setScale(1)
  if player:isCrouching() then
    models.models.prince:setPos(0,5,0)
    models.models.prince.World.Prince.RightLeg:setPos(0,-3,-3)
    models.models.prince.World.Prince.LeftLeg:setPos(0,-3,-3)
    cameraOffset = math.lerp(cameraOffset,-1/16,0.15)
  else
    cameraOffset = math.lerp(cameraOffset,0,0.15)
    models.models.prince:setPos(0,0,0)
    models.models.prince.World.Prince.RightLeg:setPos(0,0,0)
    models.models.prince.World.Prince.LeftLeg:setPos(0,0,0)
  end
  katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-17)/16,0) + ((player:getLookDir()*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1)))
  mat = rotateBall(delta,katamariPos)
  models.models.prince.World.Katamari:setMatrix(mat)
  models.models.prince.World.Prince:setPos(player:getPos(delta)*16):setRot(0,-player:getBodyYaw(delta)-180)
  renderer:setCameraPivot(player:getPos(delta) + vec(0,(katamariRadius-5)/15 + 0.35 + cameraOffset,0))
  renderer:setCameraPos(0,0,(katamariRadius-5)/8+1)
end