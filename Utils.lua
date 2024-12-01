function Lootamelo_Trim(s)
    return s:match'^%s*(.*%S)' or '';
end

function Lootamelo_ToLowerCase(s)
    return s:lower();
end

function Lootamelo_ToUpperCase(s)
    return s:upper();
end

function Lootamelo_GetItemByIdAndRaid(itemId)
    local raidData = Lootamelo_Items_Data[Lootamelo_Current_Raid];
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