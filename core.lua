-- SECTION: show FPS by default
ToggleFramerate()

-- SECTION: hide the bag bar and art
MicroButtonAndBagsBar:Hide()

-- SECTION: Classic style fade in/out
CHAT_TAB_SHOW_DELAY = 0
CHAT_FRAME_FADE_TIME = 1
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0

-- SECTION: hide expansion button
local hideExpansionButton = CreateFrame('frame')
hideExpansionButton:RegisterEvent('GARRISON_SHOW_LANDING_PAGE')
hideExpansionButton:SetScript('OnEvent', function(self, event)
    ExpansionLandingPageMinimapButton:Hide()
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
            local currentFrameScale = min(EditModeManagerFrame:GetRaidFrameHeight(frame) / 36,  EditModeManagerFrame:GetRaidFrameWidth(frame) / 72)
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
TalkingHeadFrame:Reset()
WORLD_QUEST_TRACKER_MODULE.ShowWorldQuests = false
hooksecurefunc('QuestUtils_IsQuestWorldQuest', function()
    ObjectiveTrackerBonusBannerFrame:Hide()
    TalkingHeadFrame:CloseImmediately()
end)

-- SECTION: auto repair and auto sell junk
local AutoRepairAndVendorFrame = CreateFrame('frame')
AutoRepairAndVendorFrame:RegisterEvent('MERCHANT_SHOW')
AutoRepairAndVendorFrame:SetScript('OnEvent', function(self, event)
    -- auto vendor
    for bag = Enum.BagIndex.Backpack, NUM_TOTAL_EQUIPPED_BAG_SLOTS, 1 do
	for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            local noValue = itemInfo and itemInfo.hasNoValue;
            local quality = itemInfo and itemInfo.quality;
            if (quality == Enum.ItemQuality.Poor) and not noValue then
                C_Container.UseContainerItem(bag, slot, nil, MerchantFrame:IsShown() and (MerchantFrame.selectedTab == 2))
            end
        end
    end

    -- auto repair
    if CanMerchantRepair() then
        if GetMoney() > (GetRepairAllCost() or 0) then
            RepairAllItems()
        end
    end
end)
