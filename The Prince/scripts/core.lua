-- require
require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")
require("scripts.cullKatamari")

-- define vars
prince = models.models.prince.Prince
isObjectsToggled = false
isKatamariToggled = false
local ballRotMat
local katamariPos

-- avatar setup
vanilla_model.PLAYER:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
renderer:setShadowRadius(1/8)
prince.Head:setPrimaryRenderType("TRANSLUCENT_CULL")
prince.RightArm.RightItemPivot:setScale(0.25)
prince.LeftArm.LeftItemPivot:setScale(0.25)
local skull = models.models.prince:newPart("Skull","SKULL")
skull:addChild(deepCopy(prince.Head))
  :setScale(1)
  :setPos(0,-4.8,0)
skull.Head.Snorkel:setVisible(false)
local portrait = models.models.prince:newPart("Portrait","PORTRAIT")
portrait:addChild(deepCopy(prince.Head))
portrait.Head:setScale(5)
  :setPos(0,-5.8,0)
portrait.Head.Snorkel:setVisible(false)

-- action wheel
local mainPage = action_wheel:newPage("mainPage")
action_wheel:setPage(mainPage)

function pings.toggleObjects(bool)
  isObjectsToggled = bool
  if not bool then
    for _,part in pairs(models.models.itemCopies.World:getChildren()) do
      part:remove()
    end
  end
end
mainPage:newAction()
  :title("Toggle Objects")
  :item('chest')
  :setOnToggle(pings.toggleObjects)

function pings.toggleKatamari(bool)
  isKatamariToggled = bool
  models.models.prince.World.Katamari:setVisible(false)
  if not bool then
    for _,part in pairs(models.models.prince.World.Katamari.parts:getChildren()) do
      models.models.prince.World.Katamari.parts:removeChild(part)
    end
    katamariObjects = {}
    katamariRadius = 5
  end
end
mainPage:newAction()
  :title("Toggle Katamari")
  :item('slime_ball')
  :setOnToggle(pings.toggleKatamari)

mainPage:setAction(3, require("scripts/abc_player/abc_player"))

-- tick functions
function events.tick()
  -- katamari Visiblity
  if player:getGamemode() == "SPECTATOR" then
    models.models.prince.World.Katamari:setVisible(false)
  else
    models.models.prince.World.Katamari:setVisible(isKatamariToggled)
  end
  -- snorkel visiblity
  prince.Head.Snorkel:setVisible(player:isUnderwater())
  -- katamri arm rot updates
  if isKatamariToggled then
    prince.LeftArm:setRot(90,0,-15)
    prince.RightArm:setRot(90,0,15)
  else
    prince.LeftArm:setRot(0,0,-15)
    prince.RightArm:setRot(0,0,15)
  end
  -- katamri object collision check and handler
  if ballRotMat and isObjectsToggled then
    addObjects(katamariPos,inverseRotMatrix(ballRotMat))
  end
end

-- render functions
function events.render()
  -- crouching updates
  if player:isCrouching() then
    prince.RightLeg:setPos(0,-3,-2.75)
    prince.LeftLeg:setPos(0,-3,-2.75)
    prince.Head:setPos(0,0.5,0)
  else
    prince.RightLeg:setPos(0,0,0)
    prince.LeftLeg:setPos(0,0,0)
    prince.Head:setPos(0,0,0)
  end
  -- not host crouch position update (since it doesn't use the custom player rendering)
  if not host:isHost() then
    if player:isCrouching() then
      prince:setPos(0,4,0)
    else
      prince:setPos(0,0,0)
    end
    return
  end
end

-- update katamari position and roll
function events.post_world_render(delta)
  if player:isLoaded() then
    if isKatamariToggled then
      local heightOffset = vec(0,(katamariRadius-17)/16,0)
      local yawOffset = ((vectors.angleToDir(player:getRot(delta))*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1))
      katamariPos = (player:getPos(delta) + heightOffset + yawOffset)
      ballRotMat = rotateBall(delta,katamariPos)
      models.models.prince.World.Katamari:setMatrix(ballRotMat)
    end
  end
end
