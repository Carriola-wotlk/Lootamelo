
local itemPerPage = 7;
local AceTimer = LibStub("AceTimer-3.0");
local AceComm = LibStub("AceComm-3.0");
local countdownDuration = 10;
local countdownTimer;
local lastBossName;



local function OnAddonMessageReceived(self, message)
    print(message);
end

AceComm:RegisterComm("Lootamelo", OnAddonMessageReceived);

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

local function UpdateDropDownMenu()
    UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], lastBossName);
    UIDropDownMenu_Initialize(_G["Lootamelo_LootFrameDropDownButton"], LootFrameInitDropDown);
end

-- 5 --
local function UpdateLootFrame(bossName, isLooting)

    if not _G["Lootamelo_LootFrame"] then
        return;
    end

    if(isLooting) then
        if not LootameloDB.loot then
            LootameloDB.loot = {}
        end

        if not LootameloDB.loot[bossName] then
            LootameloDB.loot[bossName] = {};
            local messageToSend = "";
            for slot = 1, GetNumLootItems() do
                local itemLink = GetLootSlotLink(slot);
                local itemIcon, itemName, _, itemRarity = GetLootSlotInfo(slot);

                if itemRarity < 4 then
                    return;
                end

                local itemId;
                if(itemLink) then
                    itemId = Lootamelo_GetItemIdFromLink(itemLink);
                else
                    return;
                end

                if itemId then
                    local count = 0;
                    if(LootameloDB.loot[bossName][itemId])then
                        count = count + 1;
                    else
                        count = 1;
                    end
                    local icon = Lootamelo_GetIconFromPath(itemIcon);
                    LootameloDB.loot[bossName][itemId] = {
                        icon = icon,
                        name = itemName,
                        rolled = {},
                        won = "",
                        count = count
                    }
                    messageToSend = messageToSend .. ":" .. itemId;
                end
            end
            if(Lootamelo_IsRaidOfficer) then
                print(messageToSend);
                if(messageToSend and messageToSend ~= "") then
                        AceComm:SendCommMessage("Lootamelo",  messageToSend, "RAID", nil, "NORMAL")
                end
            end
        end
    end

    local bossLoot = LootameloDB.loot[bossName]
    if not bossLoot then
        return;
    end

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
            Lootamelo_ShowItemTooltip(itemButton, Lootamelo_GetHyperlinkByItemId(itemId));
        end

        if text then
            local item = Lootamelo_GetItemById(itemId);
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
                raidWarningMessage = "Roll SoftReserve for " .. Lootamelo_GetHyperlinkByItemId(itemId) .. ", reserved by ";
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
                raidWarningMessage = "Roll MS for " .. Lootamelo_GetHyperlinkByItemId(itemId);
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
    UpdateDropDownMenu();
end


local function ClearItemsRows()
    for idx = 1, itemPerPage do
        -- Verifica esistenza di ogni elemento prima di accedervi
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

-- 2 --
local function ItemsListInit()
    print("ItemsListInit");
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

-- 1 --
function Lootamelo_LoadLootPanel(isLooting, bossName, isFirstLootOpen)
    if(isFirstLootOpen) then
        ItemsListInit();
    end

    ClearItemsRows();
    
    if(isLooting) then
        lastBossName = bossName;
    else
        if(LootameloDB.loot) then
            lastBossName = next(LootameloDB.loot);
        end
    end

    UpdateLootFrame(lastBossName, isLooting);
end

function LootFrameInitDropDown(self, level)
    if not level then
        return;
    end

    if not LootameloDB.loot then
        return;
    end

    for bossName, _ in pairs(LootameloDB.loot) do
        local info = UIDropDownMenu_CreateInfo();
        info.text = bossName;
        info.value = bossName;
        info.func = function(self)
            UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], bossName);
            lastBossName = bossName;
            UpdateLootFrame();
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

