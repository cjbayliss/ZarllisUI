---@diagnostic disable: undefined-global

-- SECTION: edit mode has a bug that get's blamed on addons
EditModeManagerFrame:HookScript('OnHide', function()
    ReloadUI()
end)

-- SECTION: show FPS by default
ToggleFramerate()

-- SECTION: Classic style fade in/out
CHAT_TAB_SHOW_DELAY = 0
CHAT_FRAME_FADE_TIME = 1
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0

-- SECTION: better partyframe buffs
-- more than 3 partyframe buffs, also cooldown text on partyframe buffs
local function createBuffFrames()
    local compactPartyFrameChildren = { CompactPartyFrame:GetChildren() }
    for _, frame in ipairs(compactPartyFrameChildren) do
        local _, match = string.find(frame:GetName(), 'CompactPartyFrameMember')
        if match then
            if frame:GetName() then
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
                    local raidFrameHeight = EditModeManagerFrame:GetRaidFrameHeight(frame) or 38
                    local raidFrameWidth = EditModeManagerFrame:GetRaidFrameWidth(frame) or 74
                    local currentFrameScale = min(raidFrameHeight / 36, raidFrameWidth / 72)
                    local buffSize = 14 * currentFrameScale
                    local fontSize = 8 * currentFrameScale
                    _G[frameName .. i].cooldown:SetHideCountdownNumbers(false)
                    _G[frameName .. i].cooldown:GetRegions():SetFont('Fonts\\FRIZQT__.TTF', fontSize, 'OUTLINE')
                    _G[frameName .. i]:SetSize(buffSize, buffSize)
                end

                frame.maxBuffs = 7
            end
        end
    end
end

local ZarlliBuffFrame = CreateFrame('frame')
ZarlliBuffFrame:RegisterEvent('GROUP_JOINED')
ZarlliBuffFrame:RegisterEvent('GROUP_LEFT')
ZarlliBuffFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
ZarlliBuffFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
ZarlliBuffFrame:RegisterEvent('PLAYER_ROLES_ASSIGNED')
ZarlliBuffFrame:RegisterEvent('UNIT_AURA')
ZarlliBuffFrame:SetScript('OnEvent', function(self, event)
    if not InCombatLockdown() then
        createBuffFrames()
    end
end)

-- SECTION: don't announce world quests
local HideWorldQuestsFrame = CreateFrame('frame')
HideWorldQuestsFrame:RegisterEvent('QUEST_ACCEPTED')
HideWorldQuestsFrame:SetScript('OnEvent', function(self, event, ...)
    if not InCombatLockdown() then
        local questID = ...
        if QuestUtils_IsQuestWorldQuest(questID) then
            RunNextFrame(function()
                ObjectiveTrackerBonusBannerFrame:Hide()
                TalkingHeadFrame:CloseImmediately()
            end)
        end
    end
end)

-- SECTION: auto repair and auto sell junk
local AutoRepairAndVendorFrame = CreateFrame('frame')
AutoRepairAndVendorFrame:RegisterEvent('MERCHANT_SHOW')
AutoRepairAndVendorFrame:SetScript('OnEvent', function(self, event)
    if not InCombatLockdown() then
        -- auto vendor
        for bag = Enum.BagIndex.Backpack, NUM_TOTAL_EQUIPPED_BAG_SLOTS, 1 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                local noValue = itemInfo and itemInfo.hasNoValue
                local quality = itemInfo and itemInfo.quality
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
    end
end)
