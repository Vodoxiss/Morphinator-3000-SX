--[[
    Morphinator 3000-SX - UI.lua
    Searchable list of morphs (name + ID) with direct application.
    No 3D preview: not reliably possible on this client for an arbitrary ID
    (SetCreature requires a local cache, SetDisplayInfo does not exist,
    SetUnit only works on a unit that is actually present).
--]]

local ROW_HEIGHT   = 20
local NUM_ROWS     = 18
local PLACEHOLDER_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local sortedMorphs = {}      -- MorphinatorData sorted alphabetically
local displayList  = {}      -- filtered (search) subset currently shown
local selectedEntry = nil    -- currently selected {id, name} entry
local sortDescending = false

local mainFrame, listRows
local nameText, idText, totalText, searchBox

-- ============================================================
-- Sort / filter
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
        totalText:SetText("Total Morphs  " .. #MorphinatorData .. "   (" .. #displayList .. " shown)")
    end
end

-- Applies the morph to the player (DisplayID).
local function ApplyMorph(entry)
    if not entry then return end
    SendChatMessage(".morph " .. entry.id, "SAY")
    Morphinator_DebugPrint("Morph applied: " .. entry.name .. " (Entry " .. (entry.entry or "?") .. ", DisplayID " .. entry.id .. ")")
end

-- ============================================================
-- Selection (list click)
-- ============================================================
local function SelectMorph(entry)
    selectedEntry = entry
    if not entry then
        nameText:SetText("")
        idText:SetText("")
        return
    end

    nameText:SetText(entry.name)
    idText:SetText("Entry : " .. (entry.entry or "?") .. "   |   DisplayID : " .. entry.id)
end

-- ============================================================
-- List (FauxScrollFrame)
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

    -- SELECTION highlight: only visible on the selected row
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
            GameTooltip:AddLine("Entry : " .. (self.entry.entry or "?") .. "   DisplayID : " .. self.entry.id, 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return row
end

-- ============================================================
-- Window construction
-- ============================================================
local function CreateMainFrame()
    local f = CreateFrame("Frame", "MorphinatorMainFrame", UIParent)
    f:SetSize(460, 620)
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

    -- Title bar
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

    -- Search bar
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
    searchLabel:SetText("Search")

    -- Sort A-Z / Z-A button
    local sortButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    sortButton:SetSize(90, 22)
    sortButton:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    sortButton:SetText("Sort A-Z")
    sortButton:SetScript("OnClick", function(self)
        sortDescending = not sortDescending
        self:SetText(sortDescending and "Sort Z-A" or "Sort A-Z")
        BuildSortedList()
        RefreshDisplayList()
        UpdateListRows()
    end)

    -- Action panel (name, ID and buttons together in ONE frame), right under the search bar
    local actionPanel = CreateFrame("Frame", nil, f)
    actionPanel:SetSize(400, 104)
    actionPanel:SetPoint("TOPLEFT", 24, -96)
    actionPanel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    actionPanel:SetBackdropColor(0.15, 0.05, 0.05, 0.9)

    nameText = actionPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOP", 0, -10)
    nameText:SetWidth(380)

    idText = actionPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    idText:SetPoint("TOP", nameText, "BOTTOM", 0, -4)
    idText:SetTextColor(1, 0.82, 0)

    local morphButton = CreateFrame("Button", nil, actionPanel, "UIPanelButtonTemplate")
    morphButton:SetSize(180, 26)
    morphButton:SetPoint("BOTTOMLEFT", 10, 10)
    morphButton:SetText("Morph now!")
    morphButton:SetScript("OnClick", function()
        if selectedEntry then
            ApplyMorph(selectedEntry)
        end
    end)

    local demorphButton = CreateFrame("Button", nil, actionPanel, "UIPanelButtonTemplate")
    demorphButton:SetSize(180, 26)
    demorphButton:SetPoint("BOTTOMRIGHT", -10, 10)
    demorphButton:SetText("Un-morph")
    demorphButton:SetScript("OnClick", function()
        SendChatMessage(".demorph", "SAY")
        Morphinator_DebugPrint("Un-morph sent")
    end)

    -- List panel, below the action panel. Sized to fully contain NUM_ROWS
    -- rows (18 * 20px = 360) plus the scroll frame's 6px top/bottom padding,
    -- so rows never overflow past the panel's own background.
    local listPanel = CreateFrame("Frame", nil, f)
    listPanel:SetSize(400, NUM_ROWS * ROW_HEIGHT + 12)
    listPanel:SetPoint("TOPLEFT", actionPanel, "BOTTOMLEFT", 0, -12)
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

    return f
end

-- ============================================================
-- API publique
-- ============================================================
function Morphinator_InitUI()
    if mainFrame then return end
    local ok, err = pcall(function()
        mainFrame = CreateMainFrame()
        BuildSortedList()
        RefreshDisplayList()
        UpdateListRows()
    end)
    if not ok then
        print("|cffff0000[Morphinator] InitUI error:|r", err)
    end
end

function Morphinator_ToggleUI()
    if not mainFrame then
        Morphinator_InitUI()
    end
    if not mainFrame then
        print("|cffff0000[Morphinator] mainFrame not found after InitUI, aborting.|r")
        return
    end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        local ok, err = pcall(function()
            BuildSortedList()
            RefreshDisplayList()
            UpdateListRows()
        end)
        if not ok then
            print("|cffff0000[Morphinator] Error before Show:|r", err)
        end
        mainFrame:Show()
    end
end
