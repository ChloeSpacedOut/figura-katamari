-- gets a deep copy of a model. Made by 4p5
function deepCopy(model)
  local copy = model:copy(model:getName())
  for _, child in pairs(copy:getChildren()) do
      copy:removeChild(child):addChild(deepCopy(child)):parentType()
  end
  return copy
end

-- generates a random float. Made by 4p5
rng = {}
function rng.float(min, max)
  return math.random() * (max - min) + min
end

-- gets the inverse rotation matrix
function inverseRotMatrix(mat)
  local rotScaleComp = matrices.mat3(vec(mat.v11,mat.v21,mat.v31),vec(mat.v12,mat.v22,mat.v32),vec(mat.v13,mat.v23,mat.v33)):invert()
  local column1 = vec(rotScaleComp.v11,rotScaleComp.v21,rotScaleComp.v31,mat.v41 * -1)
  local column2 = vec(rotScaleComp.v12,rotScaleComp.v22,rotScaleComp.v32,mat.v42 * -1)
  local column3 = vec(rotScaleComp.v13,rotScaleComp.v23,rotScaleComp.v33,mat.v43 * -1)
  local column4 = vec(mat.v14,mat.v24,mat.v34,mat.v44)
  return matrices.mat4(column1,column2,column3,column4)
end