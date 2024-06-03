if not host:isHost() then return end
-- require
require("scripts.core")
require("scripts.hostPlayerRenderer")

-- define vars

-- avatar setup
models.models.prince:newPart("princePreview","HUD")
models.models.prince.princePreview:addChild(deepCopy(models.models.prince.Prince))
  :setPivot(0,4,0)
  :setScale(16)
  :setRot(0,-30,0)
  :setVisible(false)
local princePreview = models.models.prince.princePreview.Prince

for _,part in pairs({"Head","Body","RightArm","LeftArm","LeftLeg","RightLeg"}) do
  princePreview[part]:setParentType("NONE")
end
princePreview.RightArm.RightItemPivot:setParentType("NONE")
princePreview.LeftArm.LeftItemPivot:setParentType("NONE")


  function events.tick()
    -- custom held items
    princePreview.RightArm.RightItemPivot:newItem("RightHandItem")
      :setItem(player:getHeldItem())
      :setRot(-90,0,180)
      :setDisplayMode("THIRD_PERSON_RIGHT_HAND")
    princePreview.LeftArm.LeftItemPivot:newItem("LeftHandItem")
      :setItem(player:getHeldItem(true))
      :setRot(-90,0,180)
      :setDisplayMode("THIRD_PERSON_LEFT_HAND")
    -- snorkel visiblity
    princePreview.Head.Snorkel:setVisible(player:isUnderwater())
  end
--
function events.post_world_render(delta)
  if not player:isLoaded() then return end
  local windowSize = -client.getScaledWindowSize()
  models.models.prince.princePreview:setPos(windowSize.x+60,windowSize.y+75,0)
  -- immatate vanilla part rot and position
  local headMat = prince.Head:partToWorldMatrix():invert():translate(0,5,0) * models:partToWorldMatrix()
  princePreview.Head:setMatrix(headMat:invert():translate(0,16000,0))
  local bodyMat = prince.Body:partToWorldMatrix():invert():translate(0,5,0) * models:partToWorldMatrix()
  princePreview.Body:setMatrix(bodyMat:invert():translate(0,16000,0))
  local leftArmMat = prince.LeftArm:partToWorldMatrix():invert():translate(-1,4.5,0) * models:partToWorldMatrix()
  princePreview.LeftArm:setMatrix(leftArmMat:invert():translate(0,16000,0))
  local rightArmMat = prince.RightArm:partToWorldMatrix():invert():translate(1,4.5,0) * models:partToWorldMatrix()
  princePreview.RightArm:setMatrix(rightArmMat:invert():translate(0,16000,0))
  local leftLegMat = prince.LeftLeg:partToWorldMatrix():invert():translate(-0.35,2.4,0) * models:partToWorldMatrix()
  princePreview.LeftLeg:setMatrix(leftLegMat:invert():translate(0,16000,0))
  local rightLegMat = prince.RightLeg:partToWorldMatrix():invert():translate(0.45,2.4,0) * models:partToWorldMatrix()
  princePreview.RightLeg:setMatrix(rightLegMat:invert():translate(0,16000,0))
end