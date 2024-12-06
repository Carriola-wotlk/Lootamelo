local raidPlayerFrame, raidPlayersScrollChild, raidPlayersScrollText;
local playerReservedNotInRaidFrame, playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText;
local itemSelectedFrame, itemSelectedScrollChild, itemSelectedScrollText;
local dropDownTitle;
local reservedItemTitle, reservedPanelTitle, reservedItemButton;
local itemSelected;

function Lootamelo_LoadRaidFrame()
    if(itemSelected) then
        Lootamelo_RaidItemSelectedFrame();
    else
        Lootamelo_RaidGeneralFrame();
    end
end

function Lootamelo_RaidGeneralFrame()
    _G["Lootamelo_RaidFrameGeneral"]:Show();

    if(_G["Lootamelo_RaidFrameItemSelected"]) then
        _G["Lootamelo_RaidFrameItemSelected"]:Hide();
    end

    local raidPlayers = {};
    for i = 1, MAX_RAID_MEMBERS do
        local name = GetRaidRosterInfo(i);
        if name then
            raidPlayers[name] = true;
        end
    end

    if(not dropDownTitle) then
        dropDownTitle = _G["Lootamelo_RaidFrame"]:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        dropDownTitle:SetPoint("TOPRIGHT", _G["Lootamelo_RaidFrame"], "TOPRIGHT", -45, -15);
        local text = "Items ( " ..  LOOTAMELO_RESERVED_COLOR .. "reserved|r" .. " / " .. LOOTAMELO_WHITE_COLOR .. "not reserved" .. "|r )"
        dropDownTitle:SetText(text);
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

function Lootamelo_RaidItemSelectedFrame()
    _G["Lootamelo_RaidFrameItemSelected"]:Show();
    _G["Lootamelo_RaidFrameGeneral"]:Hide();

    if(not itemSelectedFrame) then
        itemSelectedFrame, itemSelectedScrollChild, itemSelectedScrollText =
        Lootamelo_CreateScrollableFrame(_G["Lootamelo_RaidFrameItemSelected"], "Lootamelo_RaidFrameItemSelected", 420, 270, "BOTTOM", 0, 0)
    end

    local resultText = ""

    if(not reservedItemTitle) then
        reservedItemTitle = itemSelectedFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        reservedItemTitle:SetPoint("BOTTOM", itemSelectedFrame, "TOP", 0, 25);
        reservedPanelTitle = itemSelectedFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        reservedPanelTitle:SetPoint("TOPLEFT", itemSelectedFrame, "TOPLEFT", 8, 15);
        reservedPanelTitle:SetText("Reserved by:");

        reservedItemButton = CreateFrame("Button", "ReservedItemTooltipButton", itemSelectedFrame);
        reservedItemButton:SetPoint("CENTER", reservedItemTitle, "CENTER");
    end

    local itemLink = Lootamelo_GetHyperlinkByItemId(itemSelected);
    reservedItemTitle:SetText(itemLink);
    reservedItemButton:SetSize(reservedItemTitle:GetStringWidth(), 25);

    Lootamelo_ShowItemTooltip(reservedItemButton, itemLink);

    if(LootameloDB.reserve[itemSelected]) then
        for playerName, data in pairs(LootameloDB.reserve[itemSelected]) do            
            resultText = resultText .. Lootamelo_GetClassColor(data["class"]) .. playerName .. "  x" .. data.reserveCount .. "|r\n";
        end
    else
        resultText = "None";
    end

    itemSelectedScrollText:SetText(resultText);
    itemSelectedScrollChild:SetSize(150, itemSelectedScrollText:GetStringHeight());
end

function Lootamelo_RaidGeneralFrame_RaidPlayers(mergedPlayers)
    if not raidPlayerFrame then
        raidPlayerFrame, raidPlayersScrollChild, raidPlayersScrollText =
        Lootamelo_CreateScrollableFrame(_G["Lootamelo_RaidFrameGeneral"], "Lootamelo_RaidFrameGeneralRaid", 200, 290, "BOTTOMLEFT", 45, 0)

        local raidTitle = raidPlayerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        raidTitle:SetPoint("BOTTOM", raidPlayerFrame, "TOP", 0, 5);
        raidTitle:SetText("Raid");
    end

    local resultText = ""
    for playerName, condition in pairs(mergedPlayers) do
        if condition.raid then
            if condition.reserve then
                resultText = resultText .. LOOTAMELO_RESERVED_COLOR .. playerName .. "|r\n"
            else
                resultText = resultText .. LOOTAMELO_WHITE_COLOR .. playerName .. "|r\n"
            end
        end
    end

    raidPlayersScrollText:SetText(resultText)
    raidPlayersScrollChild:SetSize(150, raidPlayersScrollText:GetStringHeight())
end

function Lootamelo_RaidGeneralFrame_PlayerReservedNotInRaid(mergedPlayers)

    if not playerReservedNotInRaidFrame then
        playerReservedNotInRaidFrame, playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText =
        Lootamelo_CreateScrollableFrame(_G["Lootamelo_RaidFrameGeneral"], "Lootamelo_RaidFrameGeneralNotInRaid", 200, 290, "BOTTOMRIGHT", -45, 0);

        local panelTitle = playerReservedNotInRaidFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        panelTitle:SetPoint("BOTTOM", playerReservedNotInRaidFrame, "TOP", 0, 5);
        panelTitle:SetText("Reserved but Not in Raid");
    end

    local resultText = ""
    for playerName, condition in pairs(mergedPlayers) do
        if not condition.raid then
            resultText = resultText .. LOOTAMELO_OFFLINE_COLOR .. playerName .. "|r\n";
        end
    end

    playerReservedNotInRaidScrollText:SetText(nil);
    playerReservedNotInRaidScrollText:SetText(resultText);
    playerReservedNotInRaidScrollChild:SetSize(150, playerReservedNotInRaidScrollText:GetStringHeight());
end

function Lootamelo_RaidFrameDropDown_OnClick(self)
    local dropDownButton = _G["Lootamelo_RaidFrameDropDownButton"];

    if(self.value == "General") then
        itemSelected = nil;
        Lootamelo_RaidGeneralFrame();
        UIDropDownMenu_SetText(dropDownButton, "General");
    else
        local item = Lootamelo_GetItemById(self.value);
        if(item) then
            itemSelected = self.value;
            Lootamelo_RaidItemSelectedFrame();
            local isReserved = LootameloDB["reserve"][self.value];
            local itemName = item.name;
            if isReserved then
                itemName = LOOTAMELO_RESERVED_COLOR .. item.name .. "|r";
            end
            UIDropDownMenu_SetText(dropDownButton, itemName);
        end
    end
end

function Lootamelo_RaidFrameInitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()

    info.func = Lootamelo_RaidFrameDropDown_OnClick;

    if level == 1 then
        info.text = "General"
        info.value = "General"
        info.hasArrow = false
        UIDropDownMenu_AddButton(info, level)

        for bossName, _ in pairs(Lootamelo_ItemsDatabase[Lootamelo_CurrentRaid]) do
            info.text = bossName
            info.value = bossName
            info.hasArrow = true
            info.menuList = bossName
            info.func = nil
            UIDropDownMenu_AddButton(info, level)
        end
        elseif level == 2 and menuList then
            local items = Lootamelo_ItemsDatabase[Lootamelo_CurrentRaid][menuList]
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