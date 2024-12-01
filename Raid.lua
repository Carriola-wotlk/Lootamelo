local raidPlayerFrame;
local playerReservedNotInRaidFrame;
local itemSelectedFrame;

function Lootamelo_ShowRaidFrame()
    _G["Lootamelo_CreateFrame"]:Hide();
    _G["Lootamelo_ReservedFrame"]:Show();

    if(Lootamelo_Item_Selected) then
        Lootamelo_RaidItemSelectedFrame();
    else
        Lootamelo_RaidGeneralFrame();
    end
    Lootamelo_Current_Page = 'raid';

end

function Lootamelo_RaidGeneralFrame()
    _G["Lootamelo_Raid_General_Frame"]:Show();
    _G["Lootamelo_Raid_Item_Selected_Frame"]:Hide();

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

function Lootamelo_RaidItemSelectedFrame()
    _G["Lootamelo_Raid_Item_Selected_Frame"]:Show();
    _G["Lootamelo_Raid_General_Frame"]:Hide();

    local itemSelectedScrollChild, itemSelectedScrollText;

    if(itemSelectedFrame) then
        Lootamelo_DestroyFrameChild(itemSelectedFrame);
    end

    itemSelectedFrame, itemSelectedScrollChild, itemSelectedScrollText =
    Lootamelo_CreateScrollableFrame(_G["Lootamelo_Raid_Item_Selected_Frame"], "Lootamelo_Raid_Item_Selected_Frame", 300, 250, "CENTER", -80, -10)

    local resultText = ""
    if(LootameloDB.reserve[Lootamelo_Item_Selected]) then
        for playerName, data in pairs(LootameloDB.reserve[Lootamelo_Item_Selected]) do
            print(playerName);
            resultText = resultText .. Lootamelo_GetClassColor(data["class"]) .. playerName .. "  x" .. data.reserveCount .. "|r\n";
        end
    else
        resultText = "Nessuno ha riservato questo item";
    end

    itemSelectedScrollText:SetText(resultText);
    itemSelectedScrollChild:SetSize(150, itemSelectedScrollText:GetStringHeight());
end

function Lootamelo_RaidGeneralFrame_RaidPlayers(mergedPlayers)
    local raidPlayersScrollChild, raidPlayersScrollText;
    if not raidPlayerFrame then
        raidPlayerFrame, raidPlayersScrollChild, raidPlayersScrollText =
        Lootamelo_CreateScrollableFrame(_G["Lootamelo_Raid_General_Frame"], "Lootamelo_Raid_Players_Frame", 150, 250, "LEFT", 20, 30)

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
    local playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText;
    if not playerReservedNotInRaidFrame then
        playerReservedNotInRaidFrame, playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText =
        Lootamelo_CreateScrollableFrame(_G["Lootamelo_Raid_General_Frame"], "Lootamelo_Player_Reserved_Not_In_Raid_Frame", 150, 250, "CENTER", 0, 30)

        local reservedTitle = playerReservedNotInRaidFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        reservedTitle:SetPoint("BOTTOM", playerReservedNotInRaidFrame, "TOP", 0, 5)
        reservedTitle:SetText("Reserved but Not in Raid")
    end

    local resultText = ""
    for playerName, condition in pairs(mergedPlayers) do
        if not condition.raid then
            resultText = resultText .. LOOTAMELO_OFFLINE_COLOR .. playerName .. "|r\n"
        end
    end

    playerReservedNotInRaidScrollText:SetText(resultText)
    playerReservedNotInRaidScrollChild:SetSize(150, playerReservedNotInRaidScrollText:GetStringHeight())
end

function Lootamelo_Raid_Item_DropDownOnClick(self)
    local dropDownButton = _G["Lootamelo_Raid_Items_DropDownButton"];

    if(self.value == "General") then
        Lootamelo_Item_Selected = nil;
        Lootamelo_RaidGeneralFrame();
        UIDropDownMenu_SetText(dropDownButton, "General");
    else
        local item = Lootamelo_GetItemByIdAndRaid(self.value);
        if(item) then
            print(item.name);
            Lootamelo_Item_Selected = self.value;
            Lootamelo_RaidItemSelectedFrame();
            UIDropDownMenu_SetText(dropDownButton, item.name);
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