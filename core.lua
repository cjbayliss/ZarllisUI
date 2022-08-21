-- SECTION: hide the bag bar and art
MicroButtonAndBagsBar:Hide()

-- SECTION: Classic style fade in/out
CHAT_TAB_SHOW_DELAY = 0
CHAT_FRAME_FADE_TIME = 1
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0

-- SECTION: autohide minimap buttons
function HideMiniMapIcons()
    MinimapBorderTop:Hide()
    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    MiniMapWorldMapButton:Hide()
    GameTimeFrame:Hide()
    MiniMapTracking:Hide()
    MinimapZoneTextButton:Hide()
    GarrisonLandingPageMinimapButton:Hide()
end

function ShowMiniMapIcons()
    MinimapBorderTop:Show()
    MinimapZoomIn:Show()
    MinimapZoomOut:Show()
    MiniMapWorldMapButton:Show()
    GameTimeFrame:Show()
    MiniMapTracking:Show()
    MinimapZoneTextButton:Show()
    GarrisonLandingPageMinimapButton:Show()
end

function OnMouseLeaveMinimap()
    if not MouseIsOver(MinimapBackdrop) then
        HideMiniMapIcons()
    else
        C_Timer.After(0.5, OnMouseLeaveMinimap)
    end
end

HideMiniMapIcons()

local hideGarrisonIcon = CreateFrame('Frame')
hideGarrisonIcon:RegisterEvent('GARRISON_SHOW_LANDING_PAGE')
hideGarrisonIcon:SetScript('OnEvent', function(self, event)
    GarrisonLandingPageMinimapButton:Hide()
end)

MinimapBackdrop:HookScript('OnEnter', function()
    ShowMiniMapIcons()
end)

MinimapBackdrop:HookScript('OnLeave', function()
    OnMouseLeaveMinimap()
end)

-- SECTION: actionbars
MainMenuBarArtFrameBackground:Hide()
MainMenuBarArtFrame.LeftEndCap:Hide()
MainMenuBarArtFrame.RightEndCap:Hide()
MainMenuBarArtFrameBackground:Hide()
MainMenuBarArtFrame.PageNumber:Hide()
ActionBarUpButton:Hide()
ActionBarDownButton:Hide()

local margin = 8
ActionButton1:ClearAllPoints()
ActionButton1:SetPoint('CENTER', StatusTrackingBarManager, 'TOP', -(ActionButton1:GetWidth() * 5 + margin * 5 + margin / 2), 57)
MultiBarBottomLeftButton1:ClearAllPoints()
MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 0, margin)
MultiBarBottomRightButton1:ClearAllPoints()
MultiBarBottomRightButton1:SetPoint('TOPRIGHT', ActionButton1, 'BOTTOMRIGHT', 0, -margin)

hooksecurefunc('PetActionBar_UpdatePositionValues', function()
    if not InCombatLockdown() then
        PetActionBarFrame:SetMovable(true)
        PetActionBarFrame:ClearAllPoints()
        PetActionBarFrame:SetPoint('CENTER', MultiBarBottomLeftButton1, 'CENTER', 0, margin)
        PetActionBarFrame:SetUserPlaced(true)
        PetActionBarFrame:SetMovable(flase)
        -- this is *REALLY* confusing, the PetActionBarFrame is hard to relocate.
        for i = 1, 12 do
            local petButton = _G['PetActionButton' .. i]
            local x = -114 + ((i - 1) * 38)
            if petButton ~= nil then
                petButton:ClearAllPoints()
                petButton:SetPoint('BOTTOMLEFT', PetActionBarFrame, 'CENTER', x, 10 + margin)
            end
        end
    end
end)

StanceBarFrame:SetMovable(true)
StanceBarFrame:ClearAllPoints()
StanceBarFrame:SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton1, 'TOPLEFT', 0, margin - 1)
StanceBarFrame:SetUserPlaced(true)
StanceBarFrame:SetMovable(flase)

-- move action bars
for _, v in ipairs({ 'MultiBarBottomRightButton', 'MultiBarBottomLeftButton', 'ActionButton' }) do
    for i = 2, 12 do
        local prevButton = _G[v .. (i - 1)]
        local button = _G[v .. i]
        button:ClearAllPoints()
        button:SetPoint('LEFT', prevButton, 'RIGHT', margin, 0)
    end
end

-- crop icons
hooksecurefunc(ActionButton1, 'OnEvent', function()
    if not InCombatLockdown() then
        for _, v in ipairs({ 'ActionButton', 'MultiBarBottomRightButton', 'MultiBarBottomLeftButton', 'MultiBarRightButton', 'MultiBarLeftButton' }) do
            if v then
                for i = 1, 12 do
                    _G[v .. i]:SetSize(33, 33)
                    _G[v .. i .. 'Icon']:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end
            end
        end
    end
end)

-- SECTION: better partyframe buffs
-- more than 3 partyframe buffs, also cooldown text on partyframe buffs
local function createBuffFrames(frame)
    if not InCombatLockdown() and frame:GetName() then
        -- set the buffs location
        frame.buffFrames[1]:ClearAllPoints()
        frame.buffFrames[1]:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -1)

        -- set number of buffs shown to 7, and place them from TOPLEFT to TOPRIGHT
        local frameName = frame:GetName() .. 'Buff'
        for i = 1, 7 do
            -- place or create buff frames
            if i > 1 then
                local child = _G[frameName .. i] or CreateFrame('Button', frameName .. i, frame, 'CompactBuffTemplate')
                child:ClearAllPoints()
                child:SetPoint('TOPLEFT', _G[frameName .. i - 1], 'TOPRIGHT')
            end

            -- show cooldown numbers, set a resonable size for buffs and font
            local currentFrameScale = min(DefaultCompactUnitFrameSetupOptions.height / 36, DefaultCompactUnitFrameSetupOptions.width / 72)
            local buffSize = 14 * currentFrameScale
            local fontSize = 8 * currentFrameScale
            _G[frameName .. i].cooldown:SetHideCountdownNumbers(false)
            _G[frameName .. i].cooldown:GetRegions():SetFont('Fonts\\FRIZQT__.TTF', fontSize, 'OUTLINE')
            _G[frameName .. i]:SetSize(buffSize, buffSize)
        end

        frame.maxBuffs = 7
    end
end

hooksecurefunc('CompactUnitFrame_UpdateAll', createBuffFrames)

-- SECTION: disable world quest UI (still shows on map/minimap)
WORLD_QUEST_TRACKER_MODULE.ShowWorldQuests = false
hooksecurefunc('QuestUtils_IsQuestWorldQuest', function()
    ObjectiveTrackerBonusBannerFrame:Hide()
end)

-- SECTION: disable talking head
-- FIXME: this disables questline talking heads too, although those are quite rare
TalkingHead_LoadUI()
hooksecurefunc('TalkingHeadFrame_PlayCurrent', function()
    TalkingHeadFrame_CloseImmediately()
end)
