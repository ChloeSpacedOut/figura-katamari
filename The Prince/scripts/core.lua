require("scripts.objectList")
require("scripts.utils")
require("scripts.objectWorldSpawn")
require("scripts.rotateBall")
require("scripts.addObjects")
require("scripts.cullKatamari")

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
prince = models.models.prince.Prince
renderer:setShadowRadius(1/8)
prince.Head:setPrimaryRenderType("TRANSLUCENT_CULL")
ballRotMat = nil
isObjectsToggled = false
isKatamariToggled = false
local katamariPos
perspective = 0
prince.RightArm.RightItemPivot:setScale(0.25)
prince.LeftArm.LeftItemPivot:setScale(0.25)
models.models.prince.World:addChild(deepCopy(models.models.prince.Prince))
local princeCopy
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

local toggleObjects = mainPage:newAction()
  :title("Toggle Objects")
  :item('chest')
  :setOnToggle(pings.toggleObjects)

function pings.toggleKatamari(bool)
  isKatamariToggled = bool
  models.models.prince.World.Katamari:setVisible(false)
end

local toggleKatamari = mainPage:newAction()
  :title("Toggle Katamari")
  :item('slime_ball')
  :setOnToggle(pings.toggleKatamari)

  mainPage:setAction(3, require("scripts/abc_player/abc_player"))

function events.tick()
  if not host:isHost() then
    models.models.prince.World.Katamari:setVisible(isKatamariToggled)
  end
  prince.Head.Snorkel:setVisible(player:isUnderwater())
  if ballRotMat and isObjectsToggled then
    addObjects(katamariPos,inverseRotMatrix(ballRotMat))
  end
end

cameraOffset = 0
crouchOffset = 0

local togglePerspective = keybinds:fromVanilla("key.togglePerspective")
function togglePerspective.press()
  perspective = (perspective + 2) % 3 - 1
  return true
end

function events.render(delta,context)
  if player:getPose() == "SWIMMING" or player:getPose() == "FALL_FLYING" then
    crouchOffset = 0
    cameraOffset = math.lerp(cameraOffset-(0.3/16),-2/16,0.1)
  elseif player:isCrouching() then
    crouchOffset = 4
    prince.RightLeg:setPos(0,-3,-2.75)
    prince.LeftLeg:setPos(0,-3,-2.75)
    prince.Head:setPos(0,0.5,0)
    cameraOffset = math.lerp(cameraOffset,-2/16,0.1)
  else
    crouchOffset = 0
    cameraOffset = math.lerp(cameraOffset,0,0.1)
    prince.RightLeg:setPos(0,0,0)
    prince.LeftLeg:setPos(0,0,0)
    prince.Head:setPos(0,0,0)
  end
  if isKatamariToggled then
    prince.LeftArm:setRot(90,0,-15)
    prince.RightArm:setRot(90,0,15)
  else
    prince.LeftArm:setRot(0,0,-15)
    prince.RightArm:setRot(0,0,15)
  end
  if not host:isHost() then
    if player:isCrouching() then
      prince:setPos(0,4,0)
    else
      prince:setPos(0,0,0)
    end
    return
  end
  if context == "MINECRAFT_GUI" or context == "FIGURA_GUI" then
    prince:setPos(0,crouchOffset,0)
    prince:setScale(4)
  else
    prince:setPos(0,-16000 + crouchOffset,0)
    prince:setScale(1)
  end
  if context == "RENDER" then
    log("Please switch back to first person and reload avatar.")
    error("womp womp, killing avatar")
  end
  
  if context == "FIRST_PERSON" then
    if perspective == 0 then
      prince.RightArm["Right Arm"]:setVisible(true):setScale(6):setPos(2,16,2)
    else
      prince.RightArm["Right Arm"]:setVisible(false)
    end
  else
    prince.RightArm["Right Arm"]:setVisible(true):setScale(1):setPos(0,0,0)
  end
end

function events.post_world_render(delta)
  if player:isLoaded() then
    if isKatamariToggled then
      katamariPos = (player:getPos(delta) + vec(0,(katamariRadius-17)/16,0) + ((vectors.angleToDir(player:getRot(delta))*vec(1,0,1)):normalize()*(((katamariRadius)/20) + 0.1)))
      ballRotMat = rotateBall(delta,katamariPos)
      models.models.prince.World.Katamari:setMatrix(ballRotMat)
    end
    if not host:isHost() then return end
    
  end
end
