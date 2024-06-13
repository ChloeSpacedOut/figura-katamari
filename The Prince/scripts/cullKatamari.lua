katamariObjects = {}
function cullKatamari()
  for ID,objectData in pairs(katamariObjects) do
    if (objectData.length + 2) < (katamariRadius/4) then
      models.models.prince.World.Katamari.parts[ID]:remove()
      katamariObjects[ID] = nil
    end
  end
end

