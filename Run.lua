local lootPanelFrame;
local isRaidLeader = false;
local isAssistant = false;
local isMasterLooter = false;

function Lootamelo_ShowLootPanel()
    _G["Lootamelo_CreateFrame"]:Hide();
    _G["Lootamelo_ReservedFrame"]:Hide();
    _G["Lootamelo_MainFrame"]:Show();

    -- Cancella eventuali oggetti già presenti nel frame
    if _G["Lootamelo_MainFrame"].itemList then
        for _, item in ipairs(_G["Lootamelo_MainFrame"].itemList) do
            item:Hide()
        end
    else
        _G["Lootamelo_MainFrame"].itemList = {}
    end

    local numLootSlots = GetNumLootItems()

    for slot = 1, numLootSlots do
        -- Recupera informazioni sull'oggetto
        local itemLink = GetLootSlotLink(slot)
        local itemIcon, itemName, _, _, _, _ = GetLootSlotInfo(slot)

        if itemLink then
            -- Crea un'istanza del template
            local lootItem = CreateFrame("Frame", "Lootamelo_LootItem" .. slot, _G["Lootamelo_MainFrame"], "Lootamelo_LootItemTemplate")

            -- Posiziona dinamicamente
            lootItem:SetPoint("TOPLEFT", _G["Lootamelo_MainFrame"], "TOPLEFT", 20, -80 - ((slot - 1) * 40))

            -- Item icon
            local iconLeft = _G[lootItem:GetName() .. "IconLeft"];
            local iconLeftTexture = _G[iconLeft:GetName() .. "Texture"];

            print(iconLeft);
            if iconLeft then
                iconLeftTexture:SetTexture(nil);
                iconLeftTexture:SetTexture(itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark");
             
                -- Tooltip
                Lootamelo_ShowItemTooltip(iconLeft, itemLink);
            end
      
            -- item text
            local text = _G[lootItem:GetName() .. "Text"];
            if text then
                text:SetText(itemName or "Unknown Item");
            end
        
            -- reserved icon
            local iconRight = _G[lootItem:GetName() .. "IconRight"];
            local iconRightTexture = _G[iconRight:GetName() .. "Texture"];
            if iconRight then
                iconRightTexture:SetTexture(nil);
                iconRightTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
            end

            table.insert(_G["Lootamelo_MainFrame"].itemList, lootItem);
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