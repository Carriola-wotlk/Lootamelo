function Lootamelo_Trim(s)
    return s:match'^%s*(.*%S)' or '';
end

function Lootamelo_ToLowerCase(s)
    return s:lower();
end

function Lootamelo_ToUpperCase(s)
    return s:upper();
end

function Lootamelo_GetItemIdFromLink(itemLink)
    local itemId = itemLink:match("item:(%d+):");
    return tonumber(itemId);
end

function Lootamelo_GetItemById(itemId)
    local raidData = Lootamelo_Items_Data[Lootamelo_CurrentRaid];
    if not raidData then
        return nil;
    end

    for bossName, items in pairs(raidData) do
        for _, item in ipairs(items) do
            if item.id == itemId then
                return item;
            end
        end
    end

    return nil;
end

function Lootamelo_GetBossByItem(itemId)
    local raidData = Lootamelo_Items_Data[Lootamelo_CurrentRaid];
    if not raidData then
        return nil;
    end

    for bossName, items in pairs(raidData) do
        for _, item in ipairs(items) do
            if item.id == itemId then
                return bossName;
            end
        end
    end

    return nil;
end

function Lootamelo_CreateScrollableFrame(parent, frameName, width, height, anchorPoint, offsetX, offsetY)
    local frame = CreateFrame("Frame", frameName, parent)
    frame:SetSize(width, height)
    frame:SetPoint(anchorPoint, offsetX, offsetY)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    local scrollChild = CreateFrame("Frame", frameName .. "_ScrollChild", frame)
    scrollChild:SetPoint("TOPLEFT", 0, 0)

    local scrollText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    scrollText:SetPoint("TOPLEFT", 0, 0)
    scrollText:SetJustifyH("LEFT")
    scrollText:SetJustifyV("TOP")
    scrollText:SetText("")

    local scrollFrame = CreateFrame("ScrollFrame", frameName .. "_ScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    scrollFrame:SetScrollChild(scrollChild)
    scrollFrame:SetVerticalScroll(0)

    return frame, scrollChild, scrollText
end


function Lootamelo_GetClassColor(className)
    local classColors = {
        Paladin = LOOTAMELO_PALADIN_COLOR,
        Warrior = LOOTAMELO_WARRIOR_COLOR,
        Mage = LOOTAMELO_MAGE_COLOR,
        Hunter = LOOTAMELO_HUNTER_COLOR,
        Druid = LOOTAMELO_DRUID_COLOR,
        Rogue = LOOTAMELO_ROGUE_COLOR,
        Priest = LOOTAMELO_PRIEST_COLOR,
        DeathKnight = LOOTAMELO_DEATHKNIGHT_COLOR,
        Warlock = LOOTAMELO_WARLOCK_COLOR,
        Shaman = LOOTAMELO_SHAMAN_COLOR,
    }

    return classColors[className] or LOOTAMELO_OFFLINE_COLOR
end


function Lootamelo_DestroyFrameChild(frame)
    if frame and frame:IsObjectType("Frame") then
        frame:Hide();
        for _, child in ipairs({frame:GetChildren()}) do
            Lootamelo_DestroyFrameChild(child); -- Ricorsivamente distruggi i figli
        end
    end
end


function Lootamelo_ShowItemTooltip(hoverElement, itemLink)
    hoverElement:SetScript("OnEnter", function()
        if itemLink then
            GameTooltip:SetOwner(hoverElement, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(itemLink);
            GameTooltip:Show();
        end
    end)
    hoverElement:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end)
end

function Lootamelo_NavigateToPage(page)
    Lootamelo_Current_Page = page;
    local navButtonConfig, navButtonRaid, navButtonLoot;
    local navButtonConfigTexture, navButtonRaidTexture, navButtonLootTexture;
    local pressTexture, normalTexture;

    navButtonConfig = _G["Lootamelo_NavButtonConfig"];
    navButtonRaid = _G["Lootamelo_NavButtonRaid"];
    navButtonLoot = _G["Lootamelo_NavButtonLoot"];

    pressTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-press]];
    normalTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-normal]]

    if(navButtonConfig and navButtonLoot and navButtonRaid) then
        navButtonConfigTexture = _G[navButtonConfig:GetName() .. "NormalTexture"];
        navButtonRaidTexture = _G[navButtonRaid:GetName() .. "NormalTexture"];
        navButtonLootTexture = _G[navButtonLoot:GetName() .. "NormalTexture"];

        if(navButtonConfigTexture and navButtonRaidTexture and navButtonLootTexture) then
            if(Lootamelo_Current_Page == "Raid") then
                navButtonRaidTexture:SetTexture(pressTexture);
                navButtonConfigTexture:SetTexture(normalTexture);
                navButtonLootTexture:SetTexture(normalTexture);
                if(_G["Lootamelo_ConfigFrame"]) then
                    _G["Lootamelo_ConfigFrame"]:Hide();
                end
                _G["Lootamelo_RaidFrame"]:Show();
                if(_G["Lootamelo_LootFrame"]) then
                    _G["Lootamelo_LootFrame"]:Hide();
                end
                Lootamelo_LoadRaidFrame();
            
            end
            if(Lootamelo_Current_Page == "Config") then
                navButtonRaidTexture:SetTexture(normalTexture);
                navButtonConfigTexture:SetTexture(pressTexture);
                navButtonLootTexture:SetTexture(normalTexture);
            end
            if(Lootamelo_Current_Page == "Loot") then
                navButtonRaidTexture:SetTexture(normalTexture);
                navButtonConfigTexture:SetTexture(normalTexture);
                navButtonLootTexture:SetTexture(pressTexture);
            end
        end
    end
end

function Lootamelo_NavButtonOnClick(self)
    local buttonName = self:GetName();
    local page = string.match(buttonName, "Lootamelo_NavButton(%w+)");
    Lootamelo_NavigateToPage(page);
end