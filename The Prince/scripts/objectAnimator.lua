hitObjectIndex = {}

-- animates objects. Run every frame
function objectAnimator(delta)
  -- for all objects in animation database
  for ID,hitData in pairs(hitObjectIndex) do
    local clock = world.getTime(delta) - hitData.collisionTime
    local part = models.models.itemCopies.World[ID]
    -- if the part's been deleted or reached the end of the animation
    if not part or clock > 30 then
      hitObjectIndex[ID] = nil
      return
    end
    local mat = matrices.mat4()
    local partModelPos = part:getPos()
    local partModelRot = part:getRot()
    -- rotation wobble animation around collision angle
    local rot = vectors.rotateAroundAxis(hitData.collisionAngle-partModelRot.y,math.sin(clock/2)*50/clock,0,0,vec(0,1,0))
    -- rotate part by rotation and origional rotations
    mat:rotate(rot):rotate(partModelRot)
    -- reposition part
    mat.v14 = partModelPos.x
    if clock < math.pi*2 then
      mat.v24 = (partModelPos.y + math.sin(clock-math.pi/2)*2+2)
    else
      mat.v24 = partModelPos.y
    end
    mat.v34 = partModelPos.z
    --set matrix
    part:setMatrix(mat)
  end
end