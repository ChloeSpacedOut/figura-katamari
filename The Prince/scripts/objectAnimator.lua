hitObjectIndex = {}

-- animates objects. Run every frame
function objectAnimator(delta)
  -- for all objects in animation database
  for ID,hitTime in pairs(hitObjectIndex) do
    local clock = world.getTime(delta) - hitTime
    local part = models.models.itemCopies.World[ID]
    -- if the part's been deleted or reached the end of the animation
    if not part or clock > 30 then
      hitObjectIndex[ID] = nil
      return
    end
    local mat = matrices.mat4()
    local partPos = part:partToWorldMatrix():apply()
    local partModelPos = part:getPos()
    local partModelRot = part:getRot()
    -- find look direction to katamari and rotate animation to fit
    local angle =  math.deg(math.atan2(katamariPos.x - partPos.x,katamariPos.z - partPos.z)) - 180
    local rot = vectors.rotateAroundAxis(angle-partModelRot.y,math.sin(clock/2)*50/clock,0,0,vec(0,1,0))
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