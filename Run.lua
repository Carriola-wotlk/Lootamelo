local lootPanelFrame;
local isRaidLeader = false;
local isAssistant = false;
local isMasterLooter = false;

function Lootamelo_CreateLootPanel()
    lootPanelFrame = CreateFrame("Frame", "Lootamelo_LootPanel", UIParent);
    lootPanelFrame:SetSize(300, 400);
    lootPanelFrame:SetPoint("CENTER");

    lootPanelFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });

    local title = lootPanelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOP", 0, -10);
    title:SetText("Lootamelo - Looted Items");

    lootPanelFrame.itemList = {};

    return lootPanelFrame;
end

function Lootamelo_ShowLootPanel()
    if not lootPanelFrame then
       lootPanelFrame = Lootamelo_CreateLootPanel();
    end

    -- Clear previous items
    for _, item in ipairs(lootPanelFrame.itemList) do
        item:Hide();
    end
    lootPanelFrame.itemList = {};

    -- Populate with new items
    local numLootSlots = GetNumLootItems();
    for slot = 1, numLootSlots do
        local itemLink = GetLootSlotLink(slot);
        local itemName, a, b, c, d, itemType = GetLootSlotInfo(slot);

        if itemLink then
            local itemText = lootPanelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("TOPLEFT", 10, -30 - (20 * (#lootPanelFrame.itemList + 1)));
            itemText:SetText(itemLink);
            table.insert(lootPanelFrame.itemList, itemText);

             -- Create an invisible button to handle tooltip
             local itemButton = CreateFrame("Button", nil, lootPanelFrame);
             itemButton:SetPoint("TOPLEFT", itemText, "TOPLEFT");
             itemButton:SetSize(itemText:GetStringWidth(), itemText:GetStringHeight());
 
             -- Show the tooltip when hovering over the item
             itemButton:SetScript("OnEnter", function()
                 GameTooltip:SetOwner(itemButton, "ANCHOR_CURSOR");
                 GameTooltip:SetHyperlink(itemLink);
                 GameTooltip:Show();
             end);
 
             -- Hide the tooltip when the cursor leaves the item
             itemButton:SetScript("OnLeave", function()
                 GameTooltip:Hide();
             end);
 
             -- Store itemText and itemButton
             table.insert(lootPanelFrame.itemList, itemText);
        end
    end
end



function Lootamelo_UpdatePlayerRoles()
    local lootMethod, masterLooterPartyID, masterLooterRaidID = GetLootMethod();

    print("masterLooterPartyID", masterLooterPartyID);

    isRaidLeader = IsRaidOfficer();

    if lootMethod == "master" then
        print("lootMethod", lootMethod);
    end

    print("Raid Leader:", isRaidLeader, "Assistant:", isAssistant, "Master Looter:", isMasterLooter);
end


function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LOOT_METHOD_CHANGED" then
        Lootamelo_UpdatePlayerRoles();
    end

    if event == "LOOT_OPENED" then
        if isRaidLeader then
            Lootamelo_ShowLootPanel();
        end
    end
end

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent("LOOT_OPENED");
eventFrame:RegisterEvent("LOOT_CLOSED");
eventFrame:RegisterEvent("PLAYER_LOGIN");
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
eventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
eventFrame:SetScript("OnEvent", OnEvent);