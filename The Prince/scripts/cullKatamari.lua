katamariObjects = {}
function cullKatamari()
  for ID,objectData in pairs(katamariObjects) do
    local temp = (objectData.length)*6 + 9
    if katamariRadius-objectData.distance > 10 or temp < katamariRadius then
      models.models.prince.World.Katamari.parts[ID]:remove()
      katamariObjects[ID] = nil
    end
  end
end

