require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")

vanilla_model.PLAYER:setVisible(false)

function events.tick()
  for spawnID = 1,10 do
    if #models.models.itemCopies.World:getChildren() < density then
      objectWorldSpawn(spawnID)
    end
  end
  models.models.prince.root.Head.Snorkel:setVisible(player:isUnderwater())
end

function events.render(delta)
  local katamariPos = models.models.prince.root.KatamariPos:partToWorldMatrix():apply()
  local mat = rotateBall(delta,katamariPos)
  models.models.prince.root.World:setMatrix(mat)
  addObjects(katamariPos,inverseRotMatrix(mat))
end