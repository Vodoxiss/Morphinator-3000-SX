--[[
    Morphinator 3000-SX - Options.lua
    Standard Blizzard options panel (Interface > AddOns).
    For now: a single setting, DEBUG mode (disabled by default).
--]]

local panel = CreateFrame("Frame", "MorphinatorOptionsPanel", UIParent)
panel.name = "Morphinator 3000-SX"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Morphinator 3000-SX")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
subtitle:SetJustifyH("LEFT")
subtitle:SetText("Options for the Game Master morphing addon.")

local debugCheck = CreateFrame("CheckButton", "MorphinatorDebugCheckButton", panel, "InterfaceOptionsCheckButtonTemplate")
debugCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -16)
_G[debugCheck:GetName() .. "Text"]:SetText("Enable debug mode")

local debugDesc = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
debugDesc:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 4, -2)
debugDesc:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
debugDesc:SetJustifyH("LEFT")
debugDesc:SetText("Shows diagnostic messages in chat (.morph/.demorph sent, internal errors). Disabled by default.")

debugCheck:SetScript("OnClick", function(self)
    MorphinatorDB.debug = self:GetChecked() and true or false
    Morphinator_DebugPrint("Debug mode enabled.")
end)

-- Syncs the checkbox state with the actual stored value every time the panel
-- is opened (useful if it was changed elsewhere, or on first display).
panel.refresh = function()
    debugCheck:SetChecked(MorphinatorDB and MorphinatorDB.debug or false)
end

if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end
