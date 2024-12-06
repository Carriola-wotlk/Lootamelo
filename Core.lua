local Lootamelo = CreateFrame("Frame");
local addonName = ...;
local itemPerPage = 7;
local AceTimer = LibStub("AceTimer-3.0");
local AceComm = LibStub("AceComm-3.0");
local countdownDuration = 10;
local countdownTimer;
local isFirstLootOpen = true;

local Lootamelo_MainButton = CreateFrame("Button", "LootameloInitialButton", UIParent, "UIPanelButtonTemplate");
Lootamelo_MainButton:SetPoint("LEFT", 0, 0);
Lootamelo_MainButton:SetSize(100, 30);
Lootamelo_MainButton:SetText("Lootamelo");
Lootamelo_MainButton:SetMovable(true);
Lootamelo_MainButton:RegisterForDrag("LeftButton");
Lootamelo_MainButton:SetScript("OnDragStart", Lootamelo_MainButton.StartMoving);
Lootamelo_MainButton:SetScript("OnDragStop", Lootamelo_MainButton.StopMovingOrSizing);
local lootInfoRetry = 10;

local function OnAddonMessageReceived(self, message)
    print(message);
end

AceComm:RegisterComm("Lootamelo", OnAddonMessageReceived);


------------------------------------------------------------------
-- LOOTING -------------------------------------------------------

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

local function UpdateLootFrame(bossName)

    if not _G["Lootamelo_LootFrame"] then
        return;
    end
    ClearItemsRows();
    
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

local function OnLoot()
    if Lootamelo_IsRaidOfficer then
        local targetName = GetUnitName("target");

        if(not targetName) then
            return;
        end
        local bossName = Lootamelo_GetBossName(targetName);
        
        if not bossName then
            return;
        end

        local messageToSend = "";
        for slot = 1, GetNumLootItems() do
            print(GetNumLootItems())
            print("1");
            local itemLink = GetLootSlotLink(slot);
            if(itemLink) then
                print("2");
                local itemIcon, itemName, _, itemRarity = GetLootSlotInfo(slot);
                local itemId;
                itemId = Lootamelo_GetItemIdFromLink(itemLink);

                if (not LootameloDB.loot[bossName]) then
                    LootameloDB.loot[bossName] = {};
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
        end

        if(messageToSend and messageToSend ~= "") then
                AceComm:SendCommMessage("Lootamelo",  messageToSend, "RAID", nil, "NORMAL")
        end

        UpdateDropDownMenu(bossName);

        if not _G["Lootamelo_MainFrame"]:IsShown() then
            _G["Lootamelo_MainFrame"]:Show();
        end
        if(_G["Lootamelo_RaidFrame"]) then
            _G["Lootamelo_RaidFrame"]:Hide();
        end
        if(_G["Lootamelo_ConfigFrame"]) then
            _G["Lootamelo_ConfigFrame"]:Hide();
        end
        _G["Lootamelo_LootFrame"]:Show();

        if(isFirstLootOpen) then
            ItemsListInit();
            isFirstLootOpen = false
        end

        UpdateLootFrame(bossName);
    end
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
            UpdateLootFrame(bossName);
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

------------------------------------------------------------------
------------------------------------------------------------------


------------------------------------------------------------------
-- NAVIGATION ----------------------------------------------------

function Lootamelo_CloseMainFrame()
    if _G["Lootamelo_MainFrame"] then
        _G["Lootamelo_MainFrame"]:Hide();
    end
end


function Lootamelo_NavButtonOnClick(self)
    local buttonName = self:GetName();
    local page = string.match(buttonName, "Lootamelo_NavButton(%w+)");
    Lootamelo_NavigateToPage(page);
end

function Lootamelo_ShowMainFrame()
    _G["Lootamelo_MainFrame"]:Show();
    Lootamelo_NavigateToPage(Lootamelo_Current_Page);
end

function Lootamelo_MainFrameToggle()
    if _G["Lootamelo_MainFrame"] and _G["Lootamelo_MainFrame"]:IsShown() then
        Lootamelo_CloseMainFrame();
    else
        Lootamelo_ShowMainFrame();
    end
end

Lootamelo_MainButton:SetScript("OnClick", function()
    Lootamelo_MainFrameToggle();
end)

function Lootamelo_RaidEventListener(event, arg1, message)
    local inInstance, instanceType = IsInInstance();

    if(instanceType and instanceType == "pvp") then
        return;
    end

    if event == "PLAYER_LOGIN" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_LOOT_METHOD_CHANGED" then
        Lootamelo_IsRaidOfficer = IsRaidOfficer();
    end

    if event == "CHAT_MSG_SYSTEM" then
        if(arg1) then
            if string.match(arg1, "(.+) is now the loot master") then
                local masterLooterName = string.match(arg1, "(.+) is now the loot master")
                Lootamelo_MasterLooterName = masterLooterName;
            end
        end
    end
    -- if event == "PLAYER_ENTERING_WORLD" then
    --     if inInstance and instanceType == "raid" then
    --         local instanceID = select(8, GetInstanceInfo());
    --         print("instanceID", instanceID);

    --         StaticPopupDialogs["LOOTAMELO_CONFIRM_RAID_START"] = {
    --             text = "Sei sicuro di voler iniziare il raid?",
    --             button1 = "Sì",
    --             button2 = "No",
    --             OnAccept = function()
    --                 -- Azioni da eseguire quando l'utente preme "Sì"
    --                 print("Il raid è stato avviato!")
    --             end,
    --             OnCancel = function()
    --                 -- Azioni da eseguire quando l'utente preme "No"
    --                 print("Il raid non è stato avviato.")
    --             end,
    --             timeout = 0,
    --             whileDead = true,
    --             hideOnEscape = true,
    --         };

    --         StaticPopup_Show("LOOTAMELO_CONFIRM_RAID_START");

    --     end
    -- end

    -- if event == "CHAT_MSG_ADDON" and arg1 == Lootamelo_ChannelPrefix then
    --     if(message) then
    --         print("eccomi>>>>" .. message);
    --     end
    -- end
end

local function OnEvent(self, event, arg1, message)
    if event == "LOOT_OPENED" then
        OnLoot();
     end


    if event == "ADDON_LOADED" and arg1 == addonName then
        Lootamelo_PagesVariableInit();
        if(LootameloDB) then
            Lootamelo_Current_Page = "Raid";
            Lootamelo_PlayerLevel = UnitLevel("player");
            if(LootameloDB.raid) then
             Lootamelo_CurrentRaid = LootameloDB.raid;
            end
        else
            Lootamelo_Current_Page = "Config";
            LootameloDB = {
                date = "";
                raid = "";
                reserve = {};
                loot = {};
            };
        end
    end

    if UnitInRaid("player") then
        Lootamelo_RaidEventListener(event, arg1, message);
    end
end

-- Registra gli eventi
Lootamelo:RegisterEvent("ADDON_LOADED");
Lootamelo:RegisterEvent("PLAYER_LOGIN");
Lootamelo:RegisterEvent("CHAT_MSG_SYSTEM");
Lootamelo:RegisterEvent("PARTY_LEADER_CHANGED");
Lootamelo:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
Lootamelo:RegisterEvent("PLAYER_ENTERING_WORLD");
Lootamelo:RegisterEvent("LOOT_OPENED");
Lootamelo:SetScript("OnEvent", OnEvent);