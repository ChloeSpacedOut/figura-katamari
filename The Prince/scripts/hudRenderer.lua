if not host:isHost() then return end
-- require
require("scripts.core")
require("scripts.hostPlayerRenderer")

-- define vars
local earth = models.models.HUD.HUD.Earth
local radiusDisplayPart = models.models.HUD.HUD.RadiusDisplay
local shape = models.models.HUD.HUD.Shape
local arrows = models.models.HUD.HUD.KatamriArrows
local pickupPreview = models.models.HUD.HUD.PickupPreview
local pickupPreviewNamePart = models.models.HUD.HUD.PickupPreview.Name
-- avatar setup
models.models.HUD.HUD:setVisible(false)
models.models.HUD.HUD:newPart("princePreview")
models.models.HUD.HUD.princePreview:addChild(deepCopy(models.models.prince.Prince))
  :setPivot(0,4,0)
  :setScale(16)
  :setRot(0,-30,0)
local princePreview = models.models.HUD.HUD.princePreview.Prince
local radiusDisplay = radiusDisplayPart:newText("radiusDisplay")
pickupPreviewName = pickupPreviewNamePart:newText("pickupPreviewName")
pickupPreviewName:setAlignment("CENTER")
  :setScale(1.5)
  :setBackground(true)
radiusDisplay:setScale(2)
shape:setOpacity(0.9)
arrows:setScale(0.65)
pickupPreview:setVisible(false)

for _,part in pairs({"Head","Body","RightArm","LeftArm","LeftLeg","RightLeg"}) do
  princePreview[part]:setParentType("NONE")
end
princePreview.RightArm.RightItemPivot:setParentType("NONE")
princePreview.LeftArm.LeftItemPivot:setParentType("NONE")


  function events.tick()
    local m = math.floor(katamariRadius/10)
    local cm = math.floor(katamariRadius*10) - m*100
    local mm = math.floor(katamariRadius*1000) - cm*100 - m*10000
    radiusDisplay:setText(m.."m "..cm.."cm "..mm.."mm")
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
  models.models.HUD.HUD.princePreview:setPos(windowSize.x+60,windowSize.y+65,0)
  earth:setPos(windowSize.x+64,windowSize.y+34,30)
  shape:setPos(-34,-26,0)
    :setScale(math.sin(world.getTime(delta)/2)/40+1.02)
  radiusDisplayPart:setPos(-70,-60,0)
  pickupPreviewNamePart:setPos(0,0,0)
  pickupPreview:setPos(-80,windowSize.y+65,0)
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