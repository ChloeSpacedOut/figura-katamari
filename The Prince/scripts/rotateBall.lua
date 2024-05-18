local lastPos = vec(0,0,0)
local pos = vec(0,0,0)
local mat = matrices.mat4()

function rotateBall(delta,katamariPos)
  lastPos = pos
  pos = katamariPos
  local vel = (lastPos-pos)*(1/(katamariRadius/32))
  mat:rotate(math.deg(-vel.z)*delta,0,math.deg(vel.x)*delta)
  mat.v14 = pos.x*16
  mat.v24 = (pos.y+1)*16
  mat.v34 = pos.z*16
  return mat
end