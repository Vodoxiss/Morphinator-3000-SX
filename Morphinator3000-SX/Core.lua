--[[
    Morphinator 3000-SX - Core.lua
    Minimap button, commande /morph, initialisation des SavedVariables.
--]]

local ADDON_NAME = "Morphinator3000-SX"

MorphinatorDB = MorphinatorDB or {}

-- ============================================================
-- Minimap Button
-- ============================================================
local minimapButton = CreateFrame("Button", "MorphinatorMinimapButton", Minimap)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:SetSize(31, 31)
minimapButton:RegisterForClicks("LeftButtonUp")
minimapButton:RegisterForDrag("LeftButton")

local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
overlay:SetSize(53, 53)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT", 0, 0)

local background = minimapButton:CreateTexture(nil, "BACKGROUND")
background:SetSize(20, 20)
background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
background:SetPoint("CENTER", 0, 0)

local icon = minimapButton:CreateTexture(nil, "ARTWORK")
icon:SetSize(19, 19)
icon:SetTexture("Interface\\Icons\\Spell_Nature_Polymorph")
icon:SetPoint("CENTER", 0, 1)
icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local function UpdateMinimapButtonPosition()
    local angle = math.rad(MorphinatorDB.minimapAngle or 215)
    local radius = 80
    local x, y = math.cos(angle) * radius, math.sin(angle) * radius
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

minimapButton:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function(self)
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        local angle = math.deg(math.atan2(py - my, px - mx))
        MorphinatorDB.minimapAngle = angle
        UpdateMinimapButtonPosition()
    end)
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

minimapButton:SetScript("OnClick", function()
    Morphinator_ToggleUI()
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Morphinator 3000-SX", 1, 0.82, 0)
    GameTooltip:AddLine("Clic gauche : ouvrir / fermer", 1, 1, 1)
    GameTooltip:AddLine("Glisser-deposer : deplacer le bouton", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- ============================================================
-- Slash command : /morph
-- ============================================================
SLASH_MORPHINATOR1 = "/morph"
SlashCmdList["MORPHINATOR"] = function(msg)
    Morphinator_ToggleUI()
end

-- ============================================================
-- Initialisation
-- ============================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, name)
    if name == ADDON_NAME then
        MorphinatorDB.minimapAngle = MorphinatorDB.minimapAngle or 215
        UpdateMinimapButtonPosition()

        if Morphinator_InitUI then
            Morphinator_InitUI()
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end)
