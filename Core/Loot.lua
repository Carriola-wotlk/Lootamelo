local countdownDuration = 10;
local countdownTimer;
local isFirstLootOpen = true;

local itemPerPage = 7;
local AceTimer = LibStub("AceTimer-3.0");
local AceComm = LibStub("AceComm-3.0");


local function OnAddonMessageReceived(self, message)
    print(message);
end

AceComm:RegisterComm("Lootamelo", OnAddonMessageReceived);

local function LootFrameInitDropDown(self, level)
    if not level then
        return;
    end

    if not LootameloDB.loot.list then
        return;
    end

    for bossName, _ in pairs(LootameloDB.loot.list) do
        local info = UIDropDownMenu_CreateInfo();
        info.text = bossName;
        info.value = bossName;
        info.func = function(self)
            UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], bossName);
            Lootamelo_LoadLootFrame(bossName, false, "");
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

local function StartRollTimer(raidWarningMessage)
    if Lootamelo_IsRaidOfficer then
        SendChatMessage(raidWarningMessage, "RAID_WARNING");
        local countdownPos = countdownDuration;

        local function CountdownTick()
            countdownPos = countdownPos - 1;

            if countdownPos >= 10 then
                if countdownPos % 10 == 0 then
                    SendChatMessage(countdownPos .. " seconds left", "RAID_WARNING");
                end
            elseif countdownPos >= 5 then
                if countdownPos % 5 == 0 then
                    SendChatMessage(countdownPos .. " seconds left", "RAID_WARNING");
                end
            elseif countdownPos > 0 then
                SendChatMessage(countdownPos .. " seconds left", "RAID_WARNING");
            elseif countdownPos == 0 then
                SendChatMessage("Roll finished", "RAID_WARNING");
                AceTimer:CancelTimer(countdownTimer);
            end
        end

        countdownTimer = AceTimer:ScheduleRepeatingTimer(CountdownTick, 1);
    else
        print("You are not a raid officer");
    end
end

local function UpdateDropDownMenu(bossName)
    UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], bossName);
    UIDropDownMenu_Initialize(_G["Lootamelo_LootFrameDropDownButton"], LootFrameInitDropDown);
end

local function ClearItemsRows()
    for idx = 1, itemPerPage do
        if _G["Lootamelo_LootItem" .. idx .. "ItemIconTexture"] then
            _G["Lootamelo_LootItem" .. idx .. "ItemIconTexture"]:SetTexture(nil);
        end
        if _G["Lootamelo_LootItem" .. idx .. "Text"] then
            _G["Lootamelo_LootItem" .. idx .. "Text"]:SetText(nil);
        end
        if _G["Lootamelo_LootItem" .. idx .. "ReservedIconTexture"] then
            _G["Lootamelo_LootItem" .. idx .. "ReservedIconTexture"]:SetTexture(nil);
        end
        if _G["Lootamelo_LootItem" .. idx .. "ItemIcon"] then
            _G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:SetScript("OnEnter", nil);
            _G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:SetScript("OnLeave", nil);
            _G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:Hide();
        end
        if _G["Lootamelo_LootItem" .. idx .. "ReservedIcon"] then
            _G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:SetScript("OnEnter", nil);
            _G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:SetScript("OnLeave", nil);
            _G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:Hide();
        end
        if _G["Lootamelo_LootItem" .. idx .. "MSButton"] then
            _G["Lootamelo_LootItem" .. idx .. "MSButton"]:Hide();
        end
        if _G["Lootamelo_LootItem" .. idx .. "OSButton"] then
            _G["Lootamelo_LootItem" .. idx .. "OSButton"]:Hide();
        end
        if _G["Lootamelo_LootItem" .. idx .. "FreeButton"] then
            _G["Lootamelo_LootItem" .. idx .. "FreeButton"]:Hide();
        end
        if _G["Lootamelo_LootItem" .. idx .. "Roll"] then
            _G["Lootamelo_LootItem" .. idx .. "Roll"]:Hide();
        end
        if _G["Lootamelo_LootItem" .. idx .. "Won"] then
            _G["Lootamelo_LootItem" .. idx .. "Won"]:Hide();
        end
    end
end

local function ItemsListInit()
    if(not _G["Lootamelo_LootFrameBackground"]) then
        local frame = CreateFrame("Frame", "Lootamelo_LootFrameBackground", _G["Lootamelo_LootFrame"]);
        frame:SetSize(460, 330);
        frame:SetPoint("CENTER", _G["Lootamelo_LootFrame"], "CENTER", 0, -7);
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
    end

    for idx = 1, itemPerPage do
        local lootItem = CreateFrame("Frame", "Lootamelo_LootItem" .. idx, _G["Lootamelo_LootFrame"], "Lootamelo_LootItemTemplate")
        lootItem:SetPoint("TOPLEFT", _G["Lootamelo_LootFrame"], "TOPLEFT", 40, -55 - ((idx - 1) * 45));
    end
end

function Lootamelo_LoadLootFrame(boss, toSend, messageToSend)

    if(toSend) then
        if(messageToSend and messageToSend ~= "") then
            AceComm:SendCommMessage("Lootamelo",  messageToSend, "RAID", nil, "NORMAL")
        end
    end
    
    if(isFirstLootOpen) then
        ItemsListInit();
        isFirstLootOpen = false
    end

    ClearItemsRows();
    local bossName;

    if(boss) then
        bossName = boss;
    else
        bossName = LootameloDB.loot.lastBossLooted;
    end

    local bossLoot = LootameloDB.loot.list[bossName];
    if not bossLoot then
        return;
    end

    UpdateDropDownMenu(bossName);

    local index = 1
    for itemId, itemData in pairs(bossLoot) do
        local lootItem = _G["Lootamelo_LootItem" .. index];
        local itemIconTexture = _G[lootItem:GetName() .. "ItemIconTexture"];
        local text = _G[lootItem:GetName() .. "Text"]
        local iconReservedTexture = _G[lootItem:GetName() .. "ReservedIconTexture"];
        local msButton =  _G["Lootamelo_LootItem" .. index .. "MSButton"];
        local osButton =  _G["Lootamelo_LootItem" .. index .. "OSButton"];
        local freeButton =  _G["Lootamelo_LootItem" .. index .. "FreeButton"];
        _G["Lootamelo_LootItem" .. index .. "ItemIcon"]:Show();
        -- _G["Lootamelo_LootItem" .. index .. "Roll"]:Show();
        -- _G["Lootamelo_LootItem" .. index .. "Won"]:Show();

        if itemIconTexture then
            itemIconTexture:SetTexture(LOOTAMELO_WOW_ICONS_PATH .. itemData.icon);
            local itemButton = _G[lootItem:GetName() .. "ItemIcon"];
            Lootamelo_Utils.ShowItemTooltip(itemButton, Lootamelo_Utils.GetHyperlinkByItemId(itemId));
        end

        if text then
            local item = Lootamelo_Utils.GetItemById(itemId);
            if(item) then
                text:SetText(LOOTAMELO_RARE_ITEM .. item.name or "Unknown Item" .. "|r");
            end
        end

        local raidWarningMessage = "";
        if iconReservedTexture then
            local reservedData = LootameloDB.reserve[itemId];
            local iconReserved = _G[lootItem:GetName() .. "ReservedIcon"];
            if(reservedData) then
                if(Lootamelo_IsRaidOfficer) then
                    msButton:Show();
                    msButton:SetText("SR");
                end
                _G["Lootamelo_LootItem" .. index .. "ReservedIcon"]:Show();
                raidWarningMessage = "Roll SoftReserve for " .. Lootamelo_Utils.GetHyperlinkByItemId(itemId) .. ", reserved by ";
                for playerName, details in pairs(reservedData) do
                    raidWarningMessage = raidWarningMessage .. playerName .. ", ";
                    GameTooltip:AddLine(playerName .. " x" .. details.reserveCount);
                end
                iconReservedTexture:SetTexture([[Interface\AddOns\Lootamelo\Texture\icons\reserved]]);
                iconReserved:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:ClearLines();
                    GameTooltip:AddLine("Reserved by:");
                    for playerName, details in pairs(reservedData) do
                        GameTooltip:AddLine(playerName .. " x" .. details.reserveCount);
                    end
                    GameTooltip:Show();
                end);
                    iconReserved:SetScript("OnLeave", function()
                    GameTooltip:Hide();
                end);
            else
                raidWarningMessage = "Roll MS for " .. Lootamelo_Utils.GetHyperlinkByItemId(itemId);
                if(Lootamelo_IsRaidOfficer) then
                    msButton:Show();
                    msButton:SetText("MS");
                    --osButton:Show();
                    --freeButton:Show();
                end
                --iconReservedTexture:SetTexture([[Interface\AddOns\Lootamelo\Texture\icons\not_reserved]]);
                iconReserved:SetScript("OnEnter", nil);
                iconReserved:SetScript("OnLeave", nil);
            end
        end
        msButton:SetScript("OnClick", function()
            StartRollTimer(raidWarningMessage);
        end);

        index = index + 1
    end
end