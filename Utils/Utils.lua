local ns = _G[LOOTAMELO_NAME];
ns.Utils = ns.Utils or {};

function ns.Utils.Trim(s)
    return s:match'^%s*(.*%S)' or '';
end

function ns.Utils.GetItemIdFromLink(itemLink)
    local itemId = itemLink:match("item:(%d+):");
    return tonumber(itemId);
end

function ns.Utils.GetItemById(itemId)
    local raidData = ns.Database.items[ns.State.currentRaid];
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

function ns.Utils.GetBossByItem(itemId)
    local raidData = ns.Database.items[ns.State.currentRaid];
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

function ns.Utils.GetHyperlinkByItemId(itemId)
    local qualityColor = "|cffa335ee";
    local item = ns.Utils.GetItemById(itemId);
    if(item) then
        return string.format("%s|Hitem:%d:0:0:0:0:0:0:0:%s|h[%s]|h|r", qualityColor, itemId, ns.State.playerLevel, item.name);
    else
        return "";
    end
end

function ns.Utils.GetIconFromPath(path)
    local lastSegment = path:match("([^\\]+)$");
    return lastSegment;
end

function ns.Utils.CreateScrollableFrame(parent, frameName, width, height, anchorPoint, offsetX, offsetY)
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


function ns.Utils.GetClassColor(className)
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


function ns.Utils.DestroyFrameChild(frame)
    if frame and frame:IsObjectType("Frame") then
        frame:Hide();
        for _, child in ipairs({frame:GetChildren()}) do
            ns.Utils.DestroyFrameChild(child);
        end
    end
end


function ns.Utils.ShowItemTooltip(hoverElement, content)
    hoverElement:SetScript("OnEnter", function()
        if content then
            GameTooltip:SetOwner(hoverElement, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(content);
            GameTooltip:Show();
        end
    end)
    hoverElement:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end)
end

function ns.Utils.GetBossName(targetName)
    if(targetName == "High Nethermancer Zerevor" or targetName == "Gathios the Shatterer" or targetName == "Veras Darkshadow" or targetName == "Lady Malande") then
        return "The Illidari Council";
    end

    if(targetName == "Essence of Suffering" or targetName == "Essence of Desire" or targetName == "Essence of Anger") then
        return "Reliquary of Souls";
    end

    if(ns.Database.items[ns.State.currentRaid][targetName]) then
        return targetName;
    end

    return nil;
end


function ns.Utils.CanManage()
    if(ns.State.isMasterLooter) then
        return true;
    elseif(ns.State.masterLooterName) then
        return false;
    elseif(ns.State.isRaidLeader) then
        return true
    end
    return false;
end

function ns.Utils.SetReservedIcon(iconReservedButton, iconReservedTexture, reservedData)
    local reservedAnnounce = "";
    iconReservedButton:Show();
    for playerName in pairs(reservedData) do
        reservedAnnounce =  reservedAnnounce .. playerName .. ", ";
    end
    reservedAnnounce = string.sub(reservedAnnounce, 1, -3); -- remove last comma
    iconReservedTexture:SetTexture([[Interface\AddOns\Lootamelo\Texture\icons\reserved]]);
    iconReservedButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:ClearLines();
        GameTooltip:AddLine("Reserved by:");
        for playerName, details in pairs(reservedData) do
            GameTooltip:AddLine(playerName .. " x" .. details.reserveCount);
        end
        GameTooltip:Show();
    end);
        iconReservedButton:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    return reservedAnnounce;
end