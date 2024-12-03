local isAssistant = false
local isMasterLooter = false
local targetName;
local lastBossName;
local currentOffset = 0;
local isFirstOpen = true;
local itemPerPage = 7;


-- 5 --
function Lootamelo_UpdateLootFrame()
    if not _G["Lootamelo_LootFrame"] then
        return;
    end

    local bossLoot = LootameloDB.loot[lastBossName]
    if bossLoot then
        local index = 1
        local itemIndex = 0
        for itemId, itemData in pairs(bossLoot) do
            itemIndex = itemIndex + 1
            if itemIndex > currentOffset and itemIndex <= currentOffset + itemPerPage then
                local lootItem = _G["Lootamelo_LootItem" .. index];
                local itemIconTexture = _G[lootItem:GetName() .. "ItemIconTexture"];
                local text = _G[lootItem:GetName() .. "Text"]
                local iconReservedTexture = _G[lootItem:GetName() .. "ReservedIconTexture"];

                if itemIconTexture then
                    itemIconTexture:SetTexture(itemData.icon);
                    local itemButton = _G[lootItem:GetName() .. "ItemIcon"];
                    Lootamelo_ShowItemTooltip(itemButton, itemData.link);
                end

                if text then
                    text:SetText(LOOTAMELO_RARE_ITEM .. itemData.name or "Unknown Item" .. "|r");
                end

                if iconReservedTexture then
                    local reservedData = LootameloDB.reserve[itemId];
                    local iconReserved = _G[lootItem:GetName() .. "ReservedIcon"];
                    if(reservedData) then
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
                        --iconReservedTexture:SetTexture([[Interface\AddOns\Lootamelo\Texture\icons\not_reserved]]);
                        iconReserved:SetScript("OnEnter", nil);
                        iconReserved:SetScript("OnLeave", nil);
                    end
                end
                index = index + 1
            end
        end
        Lootamelo_UpdateDropDownMenu();
    end
end

-- 4 --
function Lootamelo_OnLoot()
    targetName = GetUnitName("target", true);

    local numLootSlots = GetNumLootItems();
    lastBossName = Lootamelo_GetBossName(targetName);

    if not lastBossName then
        print("Nessun boss trovato.");
        return
    end

    if not LootameloDB.loot then
        LootameloDB.loot = {};
    end

    if not LootameloDB.loot[lastBossName] then
        LootameloDB.loot[lastBossName] = {};
    end

    for slot = 1, numLootSlots do
        local itemLink = GetLootSlotLink(slot);
        local itemIcon, itemName, _, itemRarity = GetLootSlotInfo(slot);

        if not itemLink or itemRarity < 4 then
            return;
        end

        local itemId = Lootamelo_GetItemIdFromLink(itemLink);

        if itemId then
            LootameloDB.loot[lastBossName][itemId] = {
                icon = itemIcon,
                name = itemName,
                link = itemLink,
                rolled = {},
                won = "",
            }
        end
    end
end

-- 3 --
function Lootamelo_ClearItemsRows()
    for idx = 1, itemPerPage do
        _G["Lootamelo_LootItem" .. idx .. "ItemIconTexture"]:SetTexture(nil);
        _G["Lootamelo_LootItem" .. idx .. "Text"]:SetText(nil);
        _G["Lootamelo_LootItem" .. idx .. "ReservedIconTexture"]:SetTexture(nil);
        _G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:SetScript("OnEnter", nil);
        _G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:SetScript("OnLeave", nil);
        _G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:SetScript("OnEnter", nil);
        _G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:SetScript("OnLeave", nil);
    end
end

-- 2 --
function Lootamelo_ItemsListInit()
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
    isFirstOpen = false;
end

-- 1 --
function Lootamelo_LoadLootPanel(isLooting)
    if(isFirstOpen) then
        Lootamelo_ItemsListInit();
    end
    Lootamelo_ClearItemsRows();

    if(isLooting) then
        Lootamelo_OnLoot();
    else
        if(LootameloDB.loot) then
            lastBossName = next(LootameloDB.loot);
        end
    end

    Lootamelo_UpdateLootFrame();
end

function Lootamelo_NextPage()
    if not LootameloDB.loot[lastBossName] then return end
    local totalItems = 0
    for _ in pairs(LootameloDB.loot[lastBossName]) do
        totalItems = totalItems + 1
    end

    if currentOffset + itemPerPage < totalItems then
        currentOffset = currentOffset + itemPerPage
        Lootamelo_UpdateLootFrame()
    end
end

function Lootamelo_PreviousPage()
    if currentOffset > 0 then
        currentOffset = currentOffset - itemPerPage
        Lootamelo_UpdateLootFrame()
    end
end

function Lootamelo_LootFrameInitDropDown(self, level)
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
            currentOffset = 0;
            Lootamelo_UpdateLootFrame();
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

-- function Lootamelo_SetDefaultDropDown()
--     if not LootameloDB.loot then return end

--     for bossName, _ in pairs(LootameloDB.loot) do
--         UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], bossName)
--         lastBossName = bossName
--         currentOffset = 0
--         Lootamelo_UpdateLootFrame()
--         break
--     end
-- end

function Lootamelo_UpdateDropDownMenu()
    UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], lastBossName);
    UIDropDownMenu_Initialize(_G["Lootamelo_LootFrameDropDownButton"], Lootamelo_LootFrameInitDropDown);
end



function Lootamelo_UpdatePlayerRoles()
    local lootMethod, masterLooterPartyID, masterLooterRaidID = GetLootMethod();

    print("masterLooterPartyID", masterLooterPartyID);

    Lootamelo_IsRaidLeader = IsRaidOfficer();

    if lootMethod == "master" then
        print("lootMethod", lootMethod);
    end

    print("Raid Leader:", Lootamelo_IsRaidLeader, "Assistant:", isAssistant, "Master Looter:", isMasterLooter);
end