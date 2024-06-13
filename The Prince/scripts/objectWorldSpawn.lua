-- require 
require("scripts.objectList")
require("scripts.utils")

-- define var
density = 200 -- number of items allowed to exist at once
spawnRange = 30 -- the diameter from the player items spawn
local maxCeilingHeight = 10
local rarityCount = 0
local rarityIndex = {}

-- generates rarity index table (table to choose objects from)
for _,item in pairs(models.models.items.World:getChildren()) do
  local item = item:getName()
  rarityCount = rarityCount + objectList[item].rarity
  table.insert(rarityIndex,{ID = item, rarityVal = rarityCount})
end

-- gets object from rarity index table
local function getRandomObject()
  local randVal = rng.float(0,rarityCount)
  for k,v in ipairs(rarityIndex) do
    if v.rarityVal > randVal then
      return v.ID
    end
  end
end

-- checks if the a point is infront of the player
local function isInLookDir(worldPos,rot)
  local lookDir = vectors.angleToDir(rot)
  local vecToPart = worldPos - player:getPos():floor()
  local dot = vecToPart:dot(lookDir)
  return dot > 0
end

-- spawns objects in the world
function pings.objectWorldSpawn(worldTime,pos,rot,objects)
  -- gets the height of the ceiling above the player
  local playerPos = player:getPos()
  _,ceilingPos = raycast:block(playerPos,playerPos+vec(0,maxCeilingHeight,0))
  local likelyCeiling = ceilingPos.y - player:getPos().y
  for spawnID = 1,20 do
    -- if object cound isn't greater than the max
    if objects < density then
      local objectPos = pos
      -- sets the seed so random values are synced between clients
      math.randomseed(worldTime*spawnID)
      -- choose a random point around the player
      local randomPos = vec(math.floor(objectPos.x) + math.random(-spawnRange, spawnRange), math.floor(objectPos.y) + likelyCeiling, math.floor(objectPos.z) + math.random(-spawnRange, spawnRange))
      local rayCastPoint = randomPos+vec(0.5,0,0.5)
      -- cast a ray from the ceiling height to find the ground
      block,objectPos = raycast:block(rayCastPoint,rayCastPoint - vec(0,30,0))
      -- if the object is infront of the player
      if block:getID() ~= "minecraft:air" and block:getID() ~= "minecraft:light" and block:getID() ~= "minecraft:cave_air" and isInLookDir(objectPos,rot) then
        -- generates a new part and places it in the world
        local partID = worldTime*spawnID
        models.models.itemCopies.World:newPart(partID):addChild(deepCopy(models.models.items.World[getRandomObject()]))
        models.models.itemCopies.World[partID]:setPos(objectPos*16 + vec(math.random(1,8)+4,0,math.random(1,8)+4))
        models.models.itemCopies.World[partID]:setRot(0,math.random(0,360),0)
      end
    end
  end

  -- remove objects too far aay in the world
  for _,item in pairs(models.models.itemCopies.World:getChildren()) do
    local objectPos = item:getPos()/16 + item:getChildren()[1]:getPivot()/16
    local distance = (pos-objectPos):length()
    if distance > (spawnRange) then
      models.models.itemCopies.World:removeChild(item)
    end
  end
end