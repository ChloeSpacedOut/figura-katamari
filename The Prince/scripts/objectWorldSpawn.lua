require("scripts.objectList")
require("scripts.utils")
local maxCeilingHeight = 5 
density = 300 -- number of items allowed to exist at once
spawnRange = 50 -- the diameter from the player items spawn

local rarityCount = 0
local rarityIndex = {}  
for _,item in pairs(models.models.items.World:getChildren()) do
  local item = item:getName()
  rarityCount = rarityCount + objectList[item].rarity
  table.insert(rarityIndex,{ID = item, rarityVal = rarityCount})
end

local function getRandomObject()
  local randVal = rng.float(0,rarityCount)
  for k,v in ipairs(rarityIndex) do
    if v.rarityVal > randVal then
      return v.ID
    end
  end
end


local denyList = {"head","door"}

local function checkCeiling(clientPos)
  local likelyCeiling = 0
  for k = 1, maxCeilingHeight do
    if world.getBlockState(clientPos+vec(0,k,0)):hasCollision() then
      return k
    end
  end
  return maxCeilingHeight
end

function objectWorldSpawn(spawnID)
  local clientPos = client.getViewer():getPos()
  local likelyCeiling = checkCeiling(clientPos)
  local randomPos = vec(math.floor(clientPos.x) + math.random(-spawnRange, spawnRange), math.floor(clientPos.y) + likelyCeiling, math.floor(clientPos.z) + math.random(-spawnRange, spawnRange))
  for k = 0, 5 + likelyCeiling do
    local pos = randomPos - vec(0,k,0)
    local blockstate = world.getBlockState(pos)
    local aboveBlockstate = world.getBlockState(pos+vec(0,1,0))
    local isDenyListed = false
    local isDenyListedAbove = false
    for i,j in pairs(denyList) do
      if string.find(blockstate.id,j) then
        isDenyListed = true
      end
      if string.find(aboveBlockstate.id,j) then
        isDenyListedAbove = true
      end
    end
    if (blockstate:hasCollision() and not (blockstate.id == "minecraft:light" or isDenyListed)) and (not aboveBlockstate:hasCollision() or aboveBlockstate.id == "minecraft:light" or isDenyListedAbove) then
      local finalPos = pos+vec(0.5,0,0.5)
      if isOnScreen(finalPos) then
        local blockHeight = 0
        if blockstate:getCollisionShape()[1] then
          blockHeight = blockstate:getCollisionShape()[1][2].y
        end
        local finalFinalPos = finalPos*16 + vec(0,blockHeight*16,0)
        models.models.itemCopies.World:newPart(world.getTime()*10+spawnID):addChild(deepCopy(models.models.items.World[getRandomObject()]))
        models.models.itemCopies.World[world.getTime()*10+spawnID]:setPos(finalFinalPos + vec(math.random(1,8)+4,0,math.random(1,8)+4))
        models.models.itemCopies.World[world.getTime()*10+spawnID]:setRot(0,math.random(0,360),0)
      end
    end
  end
end