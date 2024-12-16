local ns = _G[LOOTAMELO_NAME];
ns.Roll = ns.Roll or {};

local rollFrame, rollList, itemText, rollListText, announceButton, winnerDropdown, iconReservedButton, iconReservedTexture, itemIcon, itemIconTexture;
local rolls = {};
local selectedWinner = nil;
local itemLink = nil;

local function ResetRollManager()
    itemLink = nil;
    rolls = {};
    selectedWinner = nil;
end


local function UpdateWinnerDropdown()
    UIDropDownMenu_Initialize(winnerDropdown, function(self, level, menuList)
        if rolls and #rolls > 0 then
            for i, rollData in ipairs(rolls) do
                local info = UIDropDownMenu_CreateInfo();
                info.text = rollData.player .. " (" .. rollData.roll .. ")";
                info.func = function()
                    announceButton:Enable();
                    selectedWinner = rollData;
                    UIDropDownMenu_SetText(winnerDropdown, rollData.player .. " (" .. rollData.roll .. ")");
                    print("Selected winner: " .. rollData.player);
                end
                UIDropDownMenu_AddButton(info);
            end
        else
            UIDropDownMenu_SetText(winnerDropdown, "");
        end
    end)

    if rolls and #rolls > 0 then
        UIDropDownMenu_SetText(winnerDropdown, "Select a winner");
    end
end


function ns.Roll.UpdateRollList(playerName, rollValue)
    table.insert(rolls, { player = playerName, roll = tonumber(rollValue) })
    table.sort(rolls, function(a, b) return a.roll > b.roll end)
    local rollText = ""

    for _, rollData in ipairs(rolls) do
        rollText = rollText .. rollData.player .. ": " .. rollData.roll .. "\n"
    end

    rollListText:SetText(rollText)
    UpdateWinnerDropdown()
end


function ns.Roll.LoadFrame(link)
    ResetRollManager();
    itemLink = link;

    if(not _G["Lootamelo_RollFrame"]:IsShown()) then
        _G["Lootamelo_RollFrame"]:Show();
    end

    if(not rollFrame) then
        rollFrame = _G["Lootamelo_RollFrame"];
        rollFrame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                ResetRollManager()
            end
        end)

        itemText = _G[rollFrame:GetName() .. "ItemText"];
        iconReservedButton = _G[rollFrame:GetName() .. "ReservedIcon"];
        iconReservedTexture = _G[rollFrame:GetName() .. "ReservedIconTexture"];

        itemIcon = _G[rollFrame:GetName() .. "ItemIcon"];
        itemIconTexture = _G[rollFrame:GetName() .. "ItemIconTexture"];

        rollList = CreateFrame("Frame", "Lootamelo_RollList", rollFrame);
        rollList:SetSize(220, 120);
        rollList:SetPoint("CENTER", rollFrame, "CENTER", 0, -25);
        rollList:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
        });
        rollList:SetBackdropColor(0.1, 0.1, 0.1, 1);
        rollListText = rollList:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
        rollListText:SetPoint("TOPLEFT", 10, -10);
        rollListText:SetPoint("BOTTOMRIGHT", -10, 10);
        rollListText:SetJustifyH("LEFT");

        winnerDropdown = CreateFrame("Frame", "WinnerDropdown", rollFrame, "UIDropDownMenuTemplate");
        winnerDropdown:SetPoint("TOPLEFT", rollList, "TOPLEFT", -15, 30);

        announceButton = CreateFrame("Button", nil, rollFrame, "UIPanelButtonTemplate");
        announceButton:SetSize(80, 25);
        announceButton:SetPoint("TOPRIGHT", rollList, "TOPRIGHT", 0, 29);
        announceButton:SetText("Announce");
    end
    UpdateWinnerDropdown();
    itemText:SetText(nil);
    rollListText:SetText("No rolls yet");
    announceButton:Disable();

   
    local itemId = ns.Utils.GetItemIdFromLink(itemLink);
    local item = ns.Utils.GetItemById(itemId, ns.State.currentRaid);
    local reservedData = LootameloDB.raid.reserve[itemId];
    local bossName = ns.Utils.GetBossByItem(itemId);

    if(bossName and LootameloDB.raid.loot.list[bossName][itemId].icon) then
        ns.Utils.ShowItemTooltip(itemIcon, ns.Utils.GetHyperlinkByItemId(itemId, item));
        itemIconTexture:SetTexture(LOOTAMELO_WOW_ICONS_PATH .. LootameloDB.raid.loot.list[bossName][itemId].icon);
    else
        itemIconTexture:SetTexture(nil);
    end

    if itemText then
        if(item) then
            itemText:SetText(LOOTAMELO_RARE_ITEM .. item.name or "Unknown Item" .. "|r");
        end
    end

    if(reservedData) then
       ns.Utils.SetReservedIcon(iconReservedButton, iconReservedTexture, reservedData);
       if(reservedData[ns.State.playerName]) then
            _G["Lootamelo_RollFrameRollButton"]:Enable()
       else
            _G["Lootamelo_RollFrameRollButton"]:Disable()
       end
    else
        _G["Lootamelo_RollFrameRollButton"]:Enable()
        iconReservedButton:Hide();
        iconReservedButton:SetScript("OnEnter", nil);
        iconReservedButton:SetScript("OnLeave", nil);
    end

    if(ns.Utils.CanManage()) then
        winnerDropdown:Show();
        announceButton:Show();
        announceButton:SetScript("OnClick", function()
            if selectedWinner then
                local bossName = ns.Utils.GetBossByItem(itemId);
                LootameloDB.raid.loot.list[bossName][itemId].won = selectedWinner.player;
                SendChatMessage(selectedWinner.player .. " wins the roll for " .. itemLink, "RAID_WARNING");
                ResetRollManager();
                ns.Loot.LoadFrame(bossName, false, "", ns.State.currentRaid);
            end
        end)
    else
        winnerDropdown:Hide();
        announceButton:Hide();
    end

end

function Lootamelo_RandomRoll()
   RandomRoll(1, 100);
end


function Lootamelo_CloseRollFrame()
    ResetRollManager();
    _G["Lootamelo_RollFrame"]:Hide();
end