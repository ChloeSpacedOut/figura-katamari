require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")

vanilla_model.PLAYER:setVisible(false)
renderer:setShadowRadius(1/8)
local mat
local katamariPos
function events.tick()
  for spawnID = 1,5 do
    if #models.models.itemCopies.World:getChildren() < density then
      objectWorldSpawn(spawnID)
    end
  end
  models.models.prince.root.Head.Snorkel:setVisible(player:isUnderwater())
  if player:getPose() == "CROUCHING" then
    models.models.prince:setPos(0,5,0)
    models.models.prince.root.RightLeg:setPos(0,-3,-3)
    models.models.prince.root.LeftLeg:setPos(0,-3,-3)
  else
    models.models.prince:setPos(0,0,0)
    models.models.prince.root.RightLeg:setPos(0,0,0)
    models.models.prince.root.LeftLeg:setPos(0,0,0)
  end
  if mat then
    addObjects(katamariPos,inverseRotMatrix(mat))
  end
end

local cameraOffset = 0
function events.render(delta,context)
  if not (context == "RENDER" or context == "FIRST_PERSON") then return end
  if player:isCrouching() then
    cameraOffset = math.lerp(cameraOffset,-1/16,0.15)
  else
    cameraOffset = math.lerp(cameraOffset,0,0.15)
  end
  katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-17)/16,0) + ((player:getLookDir()*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1)))
  mat = rotateBall(delta,katamariPos)
  models.models.prince.root.World:setMatrix(mat)
  if context == "RENDER" then
    models.models.prince.root.LeftArm:setScale(1)
    models.models.prince.root.RightArm:setScale(1)
    renderer:setCameraPivot(player:getPos(delta) + vec(0,(katamariRadius-5)/15 + 0.35 + cameraOffset,0))
    renderer:setCameraPos(0,0,(katamariRadius-5)/8-3)
  else
    renderer:setCameraPivot(player:getPos(delta) + vec(0,0.35 + cameraOffset,0))
    renderer:setCameraPos(0,0,0)
  end
end

function events.render(delta, context)
  local isFirstPerson = context == "FIRST_PERSON"
  if isFirstPerson then
    models.models.prince.root.RightArm["Right Arm"]:setScale(5)
    models.models.prince.root.LeftArm["Left Arm"]:setScale(5)
  else
    models.models.prince.root.RightArm["Right Arm"]:setScale(1)
    models.models.prince.root.LeftArm["Left Arm"]:setScale(1)
  end
end