require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")

vanilla_model.PLAYER:setVisible(false)
renderer:setCameraPos(0,0,0)

function events.tick()
  for spawnID = 1,10 do
    if #models.models.itemCopies.World:getChildren() < density then
      objectWorldSpawn(spawnID)
    end
  end
  models.models.prince.root.Head.Snorkel:setVisible(player:isUnderwater())
end

function events.render(delta,context)
  if not (context == "RENDER" or context == "FIRST_PERSON") then return end
  local katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-18)/16,0) + ((player:getLookDir()*vec(1,0,1)):normalize()*(((katamariRadius+4)/16))))
  local mat = rotateBall(delta,katamariPos)
  models.models.prince.root.World:setMatrix(mat)
  addObjects(katamariPos,inverseRotMatrix(mat))
  if context == "RENDER" then
    renderer:setOffsetCameraPivot(0,(katamariRadius-18)/64,0)
    renderer:setCameraPos(0,0,(katamariRadius-18)/64)
  else
    renderer:setOffsetCameraPivot(0,0,0)
    renderer:setCameraPos(0,0,0)
  end
end