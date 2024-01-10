local lastPos = vec(0,0,0)
local pos = vec(0,0,0)
local mat = matrices.mat4()

function rotateBall(delta,katamariPos)
  lastPos = pos
  pos = katamariPos
  --print(delta)
  local truePos = math.lerp(lastPos,pos,delta)
  local vel = (lastPos-pos)*2
  mat:rotate(math.deg(-vel.z)*delta,0,math.deg(vel.x)*delta)
  mat.v14 = truePos.x*16
  mat.v24 = (truePos.y+1)*16
  mat.v34 = truePos.z*16
  return mat
end