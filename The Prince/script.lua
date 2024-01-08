vanilla_model.PLAYER:setVisible(false)

lastFrameTime = client.getSystemTime()
lastPos = vec(0,0,0)
pos = vec(0,0,0)
mat = matrices.mat4()

function events.tick()
  models.prince.root.Head.Snorkel:setVisible(player:isUnderwater())
end

function events.render(delta)
  local katamariPos = models.prince.root.KatamariPos:partToWorldMatrix():apply()
  lastPos = pos
  pos = katamariPos

  local systmTime = client.getSystemTime()
   local fdelta = (systmTime-lastFrameTime)/50
   --print(delta)
    lastFrameTime = systmTime
    local truePos = math.lerp(lastPos,pos,delta)
    local vel = (lastPos-pos)*8
    mat:rotate(math.deg(-vel.z)*fdelta,0,math.deg(vel.x)*fdelta)
    mat.v14 = truePos.x*16
    mat.v24 = (truePos.y+1)*16
    mat.v34 = truePos.z*16
    models.prince.root.World:setMatrix(mat)
end