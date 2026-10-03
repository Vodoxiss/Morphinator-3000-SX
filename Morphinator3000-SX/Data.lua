--[[
    Morphinator 3000-SX - Data.lua

    Base table + add function. The actual data lives in
    Data_NPC1.lua / Data_NPC2.lua / Data_NPC3.lua (generated from
    full_cleaned.xlsx).

    Format of each entry:
        { entry = <NPC entry ID>, id = <DisplayID>, name = "Name" }

    - "id" (DisplayID) is what gets sent to the .morph command.
    - "entry" (NPC entry ID) is kept for reference/debugging; it is not
      currently used by the UI (no 3D preview on this client, see UI.lua).
--]]

MorphinatorData = {}

function Morphinator_AddMorphs(list)
    if type(list) ~= "table" then return end
    for _, e in ipairs(list) do
        if e.id and e.name then
            table.insert(MorphinatorData, { entry = e.entry, id = e.id, name = e.name })
        end
    end
end
