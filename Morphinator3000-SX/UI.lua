--[[
    Morphinator 3000-SX - UI.lua
    Interface inspiree du Mount Journal : liste a gauche + apercu du modele a droite.
--]]

local ROW_HEIGHT   = 20
local NUM_ROWS     = 18
local PLACEHOLDER_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local sortedMorphs = {}      -- MorphinatorData trie alphabetiquement
local displayList  = {}      -- sous-ensemble filtre (recherche) affiche actuellement
local selectedEntry = nil    -- entree {id, name} actuellement selectionnee
local sortDescending = false

local mainFrame, listRows, modelFrame
local nameText, idText, totalText, searchBox

-- ============================================================
-- Tri / filtre
-- ============================================================
local function BuildSortedList()
    sortedMorphs = {}
    for _, entry in ipairs(MorphinatorData) do
        table.insert(sortedMorphs, entry)
    end
    table.sort(sortedMorphs, function(a, b)
        local an, bn = a.name:lower(), b.name:lower()
        if an == bn then
            return a.id < b.id
        end
        if sortDescending then
            return an > bn
        end
        return an < bn
    end)
end

local function RefreshDisplayList()
    local search = searchBox and searchBox:GetText() or ""
    search = search:lower()
    wipe(displayList)
    for _, entry in ipairs(sortedMorphs) do
        if search == "" or entry.name:lower():find(search, 1, true) then
            table.insert(displayList, entry)
        end
    end
    if totalText then
        totalText:SetText("Total Morphs  " .. #MorphinatorData .. "   (" .. #displayList .. " displayed)")
    end
end

-- ============================================================
-- Selection / apercu
-- ============================================================
local function SelectMorph(entry)
    selectedEntry = entry
    if not entry then
        nameText:SetText("")
        idText:SetText("")
        modelFrame:ClearModel()
        return
    end
    
    nameText:SetText(entry.name)
    idText:SetText("DisplayID : " .. entry.id)

    -- Effacer l'ancien modèle et appliquer le nouveau DisplayID
    modelFrame:ClearModel()
    modelFrame:SetDisplayInfo(entry.id)
    
    -- Ajuster la position, la rotation et l'échelle de la caméra
    modelFrame:SetPosition(0, 0, 0)
    modelFrame:SetFacing(0)
    modelFrame:SetModelScale(1)
    modelFrame:SetCamDistanceScale(1)
end

-- ============================================================
-- Liste (FauxScrollFrame)
-- ============================================================
local function UpdateListRows()
    local offset = FauxScrollFrame_GetOffset(mainFrame.scrollFrame)
    for i = 1, NUM_ROWS do
        local row = listRows[i]
        local dataIndex = i + offset
        local entry = displayList[dataIndex]
        if entry then
            row.entry = entry
            row.text:SetText(entry.name)
            row:Show()
            if selectedEntry and selectedEntry == entry then
                row.selectedTexture:Show()
            else
                row.selectedTexture:Hide()
            end
        else
            row.entry = nil
            row:Hide()
        end
    end
    FauxScrollFrame_Update(mainFrame.scrollFrame, #displayList, NUM_ROWS, ROW_HEIGHT)
end

local function CreateListRow(parent, index)
    local row = CreateFrame("Button", "MorphinatorRow" .. index, parent)
    row:SetSize(340, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -((index - 1) * ROW_HEIGHT) - 4)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if index % 2 == 0 then
        bg:SetTexture(0, 0, 0, 0.15)
    else
        bg:SetTexture(0, 0, 0, 0)
    end

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", 4, 0)
    icon:SetTexture(PLACEHOLDER_ICON)
    row.icon = icon

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    text:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    text:SetJustifyH("LEFT")
    row.text = text

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture(1, 1, 1, 0.08)
    highlight:SetBlendMode("ADD")

    -- Surbrillance de SELECTION : uniquement visible sur la ligne selectionnee
    -- (geree explicitement dans UpdateListRows/SelectMorph, jamais au survol)
    local selectedTexture = row:CreateTexture(nil, "BORDER")
    selectedTexture:SetAllPoints()
    selectedTexture:SetTexture(1, 0.82, 0, 0.35)
    selectedTexture:Hide()
    row.selectedTexture = selectedTexture

    row:SetScript("OnClick", function(self)
        if self.entry then
            SelectMorph(self.entry)
            UpdateListRows()
        end
    end)

    row:SetScript("OnEnter", function(self)
        if self.entry then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.entry.name, 1, 0.82, 0)
            GameTooltip:AddLine("DisplayID : " .. self.entry.id, 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return row
end

-- ============================================================
-- Construction de la fenetre
-- ============================================================
local function CreateMainFrame()
    local f = CreateFrame("Frame", "MorphinatorMainFrame", UIParent)
    f:SetSize(700, 520)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    f:Hide()

    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 },
    })

    -- Barre de titre
    local titleBg = f:CreateTexture(nil, "ARTWORK")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetSize(300, 64)
    titleBg:SetPoint("TOP", 0, 12)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", titleBg, "TOP", 0, -14)
    title:SetText("|cffffd200Morphinator 3000-SX|r")

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() f:Hide() end)

    -- Total morphs
    totalText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    totalText:SetPoint("TOPLEFT", 24, -22)
    totalText:SetTextColor(1, 0.82, 0)

    -- Barre de recherche
    searchBox = CreateFrame("EditBox", "MorphinatorSearchBox", f, "InputBoxTemplate")
    searchBox:SetSize(220, 20)
    searchBox:SetPoint("TOPLEFT", 34, -66)
    searchBox:SetAutoFocus(false)
    searchBox:SetScript("OnTextChanged", function()
        RefreshDisplayList()
        UpdateListRows()
    end)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local searchLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    searchLabel:SetPoint("BOTTOMLEFT", searchBox, "TOPLEFT", -2, 2)
    searchLabel:SetText("Recherche")

    -- Bouton tri A-Z / Z-A
    local sortButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    sortButton:SetSize(90, 22)
    sortButton:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    sortButton:SetText("Tri A-Z")
    sortButton:SetScript("OnClick", function(self)
        sortDescending = not sortDescending
        self:SetText(sortDescending and "Tri Z-A" or "Tri A-Z")
        BuildSortedList()
        RefreshDisplayList()
        UpdateListRows()
    end)

    -- Panneau liste (gauche)
    local listPanel = CreateFrame("Frame", nil, f)
    listPanel:SetSize(360, 400)
    listPanel:SetPoint("TOPLEFT", 24, -86)
    listPanel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    listPanel:SetBackdropColor(0, 0, 0, 0.6)

    local scrollFrame = CreateFrame("ScrollFrame", "MorphinatorScrollFrame", listPanel, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 6, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", -26, 6)
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, UpdateListRows)
    end)
    f.scrollFrame = scrollFrame

    listRows = {}
    for i = 1, NUM_ROWS do
        listRows[i] = CreateListRow(listPanel, i)
    end

    -- Panneau apercu (droite)
    local previewPanel = CreateFrame("Frame", nil, f)
    previewPanel:SetSize(260, 400)
    previewPanel:SetPoint("TOPRIGHT", -24, -86)
    previewPanel:SetBackdrop({
        bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    previewPanel:SetBackdropColor(0.15, 0.05, 0.05, 0.9)

    nameText = previewPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nameText:SetPoint("TOP", 0, -14)
    nameText:SetWidth(240)

    idText = previewPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    idText:SetPoint("TOP", nameText, "BOTTOM", 0, -4)
    idText:SetTextColor(1, 0.82, 0)

modelFrame = CreateFrame("PlayerModel", "MorphinatorModelFrame", previewPanel)
    modelFrame:SetSize(220, 230)
    modelFrame:SetPoint("TOP", idText, "BOTTOM", 0, -10)
    modelFrame:EnableMouse(true)
    modelFrame:EnableMouseWheel(true)

    -- Rotation du modèle avec la souris
    modelFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.rotating = true
            self.lastX = GetCursorPosition()
        end
    end)
    modelFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self.rotating = false
        end
    end)
    modelFrame:SetScript("OnUpdate", function(self)
        if self.rotating then
            local x = GetCursorPosition()
            local delta = (x - (self.lastX or x)) * 0.01
            self:SetFacing((self:GetFacing() or 0) + delta)
            self.lastX = x
        end
    end)

    -- Zoom avec la molette de la souris
    modelFrame:SetScript("OnMouseWheel", function(self, delta)
        local zoom = (self.zoomLevel or 1) - (delta * 0.1)
        if zoom < 0.3 then zoom = 0.3 end
        if zoom > 3.0 then zoom = 3.0 end
        self.zoomLevel = zoom
        self:SetCamDistanceScale(zoom)
    end)

    local morphButton = CreateFrame("Button", nil, previewPanel, "UIPanelButtonTemplate")
    morphButton:SetSize(160, 26)
    morphButton:SetPoint("BOTTOM", 0, 26)
    morphButton:SetText("Morph now!")
    morphButton:SetScript("OnClick", function()
        if selectedEntry then
            SendChatMessage(".morph " .. selectedEntry.id, "SAY")
        end
    end)

    local demorphButton = CreateFrame("Button", nil, previewPanel, "UIPanelButtonTemplate")
    demorphButton:SetSize(160, 22)
    demorphButton:SetPoint("BOTTOM", morphButton, "TOP", 0, 4)
    demorphButton:SetText("Un-morph")
    demorphButton:SetScript("OnClick", function()
        SendChatMessage(".demorph", "SAY")
    end)

    return f
end

-- ============================================================
-- API publique
-- ============================================================
function Morphinator_InitUI()
    if mainFrame then return end
    mainFrame = CreateMainFrame()
    BuildSortedList()
    RefreshDisplayList()
    UpdateListRows()
end

function Morphinator_ToggleUI()
    if not mainFrame then
        Morphinator_InitUI()
    end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        BuildSortedList()
        RefreshDisplayList()
        UpdateListRows()
        mainFrame:Show()
    end
end
