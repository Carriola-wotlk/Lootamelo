local raidPlayerFrame, raidPlayersScrollFrame, raidPlayersScrollChild, raidPlayersScrollText;
local playerReservedNotInRaidFrame, playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText, playerReservedNotInRaidcrollFrame;
local itemSelectedFrame, itemSelectedScrollFrame, itemSelectedScrollChild, itemSelectedScrollText;

function Lootamelo_ShowRaidFrame()
    _G["Lootamelo_Create_Frame"]:Hide();
    _G["Lootamelo_Raid_Frame"]:Show();

    if(Lootamelo_Item_Selected) then
        Lootamelo_RaidGeneralFrame();
    else
        Lootamelo_RaidGeneralFrame();
    end
    Lootamelo_Current_Page = 'raid';

    
end

function Lootamelo_RaidGeneralFrame()
    _G["Lootamelo_Raid_Item_Frame"]:Show();

    -- Creazione del frame solo se non esiste
    if not itemSelectedFrame then
        itemSelectedFrame = CreateFrame("Frame", "Lootamelo_Raid_Players_Frame", _G["Lootamelo_Raid_General_Frame"]);
        itemSelectedFrame:SetSize(150, 250);
        itemSelectedFrame:SetPoint("LEFT", 20, 30);
        itemSelectedFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        });

        -- ScrollFrame
        itemSelectedScrollFrame = CreateFrame("ScrollFrame", "Lootamelo_Raid_Players_ScrollFrame", itemSelectedFrame, "UIPanelScrollFrameTemplate");
        itemSelectedScrollFrame:SetPoint("TOPLEFT", 10, -10);
        itemSelectedScrollFrame:SetPoint("BOTTOMRIGHT", -30, 10);

        -- ScrollChild (contenuto scrollabile)
        itemSelectedScrollChild = CreateFrame("Frame", "Lootamelo_Raid_Players_ScrollChild", itemSelectedScrollFrame);
        itemSelectedScrollChild:SetSize(150, 1); -- Altezza iniziale
        itemSelectedScrollFrame:SetScrollChild(itemSelectedScrollChild);

        -- Testo scrollabile
        itemSelectedScrollText = itemSelectedScrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        itemSelectedScrollText:SetPoint("TOPLEFT");
        itemSelectedScrollText:SetJustifyH("LEFT");
        itemSelectedScrollText:SetJustifyV("TOP");
        itemSelectedScrollText:SetText("");
    end

    -- Generazione del contenuto
    local resultText = "";
    for playerName, condition in pairs(mergedPlayers) do
        if condition.raid then
            resultText = resultText .. (condition.reserve and LOOTAMELO_RESERVED_COLOR or LOOTAMELO_WHITE_COLOR) .. playerName .. "|r\n";
        end
    end

    -- Aggiornamento del testo e della dimensione del contenitore
    itemSelectedScrollText:SetText(resultText);
    itemSelectedScrollChild:SetHeight(itemSelectedScrollText:GetStringHeight());
end


function Lootamelo_RaidGeneralFrame()
    _G["Lootamelo_Raid_General_Frame"]:Show();
    local raidPlayers = {};
    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i);
        if name then
            raidPlayers[name] = true;
        end
    end

    local reservedPlayers = {};
    for _, itemData in pairs(LootameloDB["reserve"]) do
        for playerName in pairs(itemData) do
            reservedPlayers[playerName] = true;
        end
    end

    local mergedPlayers = {};
    for playerName in pairs(reservedPlayers) do
        if raidPlayers[playerName] then
            mergedPlayers[playerName] = { raid = true, reserve = true };
        else
            mergedPlayers[playerName] = { raid = false, reserve = true };
        end
    end

    for playerName in pairs(raidPlayers) do
        if not mergedPlayers[playerName] then
            mergedPlayers[playerName] = { raid = true, reserve = false };
        end
    end

    Lootamelo_RaidGeneralFrame_PlayerReservedNotInRaid(mergedPlayers);
    Lootamelo_RaidGeneralFrame_RaidPlayers(mergedPlayers);
end

function Lootamelo_RaidGeneralFrame_RaidPlayers(mergedPlayers)
    if(not raidPlayerFrame) then
        raidPlayerFrame = CreateFrame("Frame", "Lootamelo_Raid_Players_Frame", _G["Lootamelo_Raid_General_Frame"]);
        raidPlayerFrame:SetSize(150, 250);
        raidPlayerFrame:SetPoint("LEFT", 20, 30);
        raidPlayerFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        });

        raidPlayersScrollChild = CreateFrame("Frame", "Lootamelo_Raid_Players_ScrollChild", raidPlayerFrame);
        raidPlayersScrollChild:SetPoint("TOPLEFT", 0, 0);

        raidPlayersScrollText = raidPlayersScrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        raidPlayersScrollText:SetPoint("TOPLEFT", 0, 0);
        raidPlayersScrollText:SetJustifyH("LEFT");
        raidPlayersScrollText:SetJustifyV("TOP");
        raidPlayersScrollText:SetText("");

        raidPlayersScrollFrame = CreateFrame("ScrollFrame", "Lootamelo_Raid_Players_ScrollFrame", raidPlayerFrame, "UIPanelScrollFrameTemplate");
        raidPlayersScrollFrame:SetPoint("TOPLEFT", raidPlayerFrame, "TOPLEFT", 10, -10);
        raidPlayersScrollFrame:SetPoint("BOTTOMRIGHT", raidPlayerFrame, "BOTTOMRIGHT", -30, 10);
        raidPlayersScrollFrame:SetScrollChild(raidPlayersScrollChild);
        raidPlayersScrollFrame:SetVerticalScroll(0);
    end

    local resultText = "";
    for playerName, condition in pairs(mergedPlayers) do
        if condition.raid then
            if condition.reserve then
                resultText = resultText .. LOOTAMELO_RESERVED_COLOR .. playerName .. "|r\n";
            else
                resultText = resultText .. LOOTAMELO_WHITE_COLOR .. playerName .. "|r\n";
            end
        end
    end

    raidPlayersScrollText:SetText(resultText);
    raidPlayersScrollChild:SetSize(150, raidPlayersScrollText:GetStringHeight());
end

function Lootamelo_RaidGeneralFrame_PlayerReservedNotInRaid(mergedPlayers)
    if(not playerReservedNotInRaidFrame) then
        playerReservedNotInRaidFrame = CreateFrame("Frame", "Lootamelo_Player_Reserved_Not_In_Raid_Frame", _G["Lootamelo_Raid_General_Frame"]);
        playerReservedNotInRaidFrame:SetSize(150, 250);
        playerReservedNotInRaidFrame:SetPoint("CENTER", 0, 30);
        playerReservedNotInRaidFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        });

        playerReservedNotInRaidScrollChild = CreateFrame("Frame", "Lootamelo_Player_Reserved_Not_In_Raid_ScrollChild", playerReservedNotInRaidFrame);
        playerReservedNotInRaidScrollChild:SetPoint("TOPLEFT", 0, 0);

        playerReservedNotInRaidScrollText = playerReservedNotInRaidScrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        playerReservedNotInRaidScrollText:SetPoint("TOPLEFT", 0, 0);
        playerReservedNotInRaidScrollText:SetJustifyH("LEFT");
        playerReservedNotInRaidScrollText:SetJustifyV("TOP");
        playerReservedNotInRaidScrollText:SetText("");
        playerReservedNotInRaidcrollFrame = CreateFrame("ScrollFrame", "Lootamelo_Player_Reserved_Not_In_Raid_ScrollFrame", playerReservedNotInRaidFrame, "UIPanelScrollFrameTemplate");
        playerReservedNotInRaidcrollFrame:SetPoint("TOPLEFT", playerReservedNotInRaidFrame, "TOPLEFT", 10, -10);
        playerReservedNotInRaidcrollFrame:SetPoint("BOTTOMRIGHT", playerReservedNotInRaidFrame, "BOTTOMRIGHT", -30, 10);
        playerReservedNotInRaidcrollFrame:SetScrollChild(playerReservedNotInRaidScrollChild);
        playerReservedNotInRaidcrollFrame:SetVerticalScroll(0);
    end

    local resultText = "";
    for playerName, condition in pairs(mergedPlayers) do
        if not condition.raid then
            resultText = resultText .. LOOTAMELO_OFFLINE_COLOR .. playerName .. "|r\n";
        end
    end

    playerReservedNotInRaidScrollText:SetText(resultText);
    playerReservedNotInRaidScrollChild:SetSize(150, playerReservedNotInRaidScrollText:GetStringHeight());
end

function Lootamelo_Raid_Item_DropDownOnClick(self)
    local dropDownButton = _G["Lootamelo_Raid_Items_DropDownButton"];

    if(self.value == "General") then
        Lootamelo_Item_Selected = nil;
        UIDropDownMenu_SetText(dropDownButton, self.value);
    else
        Lootamelo_Item_Selected = Lootamelo_GetItemByIdAndRaid(self.value);
        if(Lootamelo_Item_Selected) then
            UIDropDownMenu_SetText(dropDownButton, Lootamelo_Item_Selected.name);
        end
    end
end

function Lootamelo_Raid_Items_InitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()

    info.func = Lootamelo_Raid_Item_DropDownOnClick;

    if level == 1 then
        info.text = 'General'
        info.value = 'General'
        info.hasArrow = false
        UIDropDownMenu_AddButton(info, level)

        for bossName, _ in pairs(Lootamelo_Items_Data[Lootamelo_Current_Raid]) do
            info.text = bossName
            info.value = bossName
            info.hasArrow = true
            info.menuList = bossName
            info.func = nil
            UIDropDownMenu_AddButton(info, level)
        end
        elseif level == 2 and menuList then
            local items = Lootamelo_Items_Data[Lootamelo_Current_Raid][menuList]
            for _, item in ipairs(items) do
                local isReserved = LootameloDB["reserve"][item.id];
                local itemName = item.name;
    
                if isReserved then
                    itemName = LOOTAMELO_RESERVED_COLOR .. item.name .. "|r";
                end
                
                info.text = itemName;
                info.value = item.id;
                UIDropDownMenu_AddButton(info, level);
            end
    end
end