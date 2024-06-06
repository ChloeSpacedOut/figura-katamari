
function events.render(delta)
  local playerPos = player:getPos(delta)
  for k,v in pairs(models.models.itemCopies.World:getChildren()) do
    local mat = matrices.mat4()
    local partPos = v:partToWorldMatrix():apply()
    local partModelPos = v:getPos()
    local partModelRot = v:getRot()
    local angle =  math.deg(math.atan2(playerPos.x - partPos.x,playerPos.z - partPos.z)) - 180
    local rot = vectors.rotateAroundAxis(angle-partModelRot.y,math.sin(world.getTime(delta))*10,0,0,vec(0,1,0))
    
    mat:rotate(rot):rotate(partModelRot)
    mat.v14 = partModelPos.x
    mat.v24 = (partModelPos.y)
    mat.v34 = partModelPos.z
    
    v:setMatrix(mat)
  end
end