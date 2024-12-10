local ns = _G[LOOTAMELO_NAME];
ns.Roll = ns.Roll or {};

local rollFrame, rollList, itemText, rollListText, announceButton, winnerDropdown;
local rolls = {};
local selectedWinner = nil;
local itemLink = nil;

local function ResetRollManager()
    itemLink = nil;
    rolls = {};
    selectedWinner = nil;
end


local function UpdateWinnerDropdown()
    UIDropDownMenu_Initialize(winnerDropdown, function(self, level, menuList)
        for i, rollData in ipairs(rolls) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = rollData.player .. " (" .. rollData.roll .. ")"
            info.func = function()
                selectedWinner = rollData
                UIDropDownMenu_SetText(winnerDropdown, rollData.player .. " (" .. rollData.roll .. ")") -- Aggiorna il testo del dropdown
                print("Selected winner: " .. rollData.player)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    if #rolls > 0 then
        local firstRoll = rolls[1]
        print(firstRoll)
        UIDropDownMenu_SetText(winnerDropdown, "Select a winner") -- Testo iniziale predefinito
    else
        UIDropDownMenu_SetText(winnerDropdown, "No rolls yet") -- Testo se non ci sono giocatori
    end
end

function ns.Roll.UpdateRollList(playerName, rollValue)
    table.insert(rolls, { player = playerName, roll = tonumber(rollValue) })
    table.sort(rolls, function(a, b) return a.roll > b.roll end)
    local rollText = ""

    for _, rollData in ipairs(rolls) do
        rollText = rollText .. rollData.player .. ": " .. rollData.roll .. "\n"
    end

    rollListText:SetText(rollText)
    UpdateWinnerDropdown()
end

function ns.Roll.LoadFrame(link)
    ResetRollManager();
    itemLink = link;

    if(not _G["Lootamelo_RollFrame"]:IsShown()) then
        _G["Lootamelo_RollFrame"]:Show();
    end

    if(not rollFrame) then
        rollFrame = _G["Lootamelo_RollFrame"];
        rollFrame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                ResetRollManager()
            end
        end)

        itemText = rollFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        itemText:SetPoint("TOP", rollFrame, "TOP", 0, -10);
        itemText:SetText("Item: None");

        rollList = CreateFrame("Frame", "Lootamelo_RollList", rollFrame);
        rollList:SetSize(220, 120)
        rollList:SetPoint("CENTER", rollFrame, "CENTER", 0, -25)
        rollList:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
        })
        rollList:SetBackdropColor(0.1, 0.1, 0.1, 1)
        rollListText = rollList:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        rollListText:SetPoint("TOPLEFT", 10, -10)
        rollListText:SetPoint("BOTTOMRIGHT", -10, 10)
        rollListText:SetJustifyH("LEFT")
        rollListText:SetText("No rolls yet")

        winnerDropdown = CreateFrame("Frame", "WinnerDropdown", rollFrame, "UIDropDownMenuTemplate");
        winnerDropdown:SetPoint("TOPLEFT", rollList, "TOPLEFT", -15, 30);

        announceButton = CreateFrame("Button", nil, rollFrame, "UIPanelButtonTemplate")
        announceButton:SetSize(80, 25)
        announceButton:SetPoint("TOPRIGHT", rollList, "TOPRIGHT", 0, 29);
        announceButton:SetText("Announce")
        announceButton:Disable()
        announceButton:SetScript("OnClick", function()
            if not IsRaidLeader() then
                print("You must be the Raid Leader to announce a winner.")
                return
            end
            if selectedWinner then
                SendChatMessage(selectedWinner.player .. " wins the roll for " .. itemLink .. " with a roll of " .. selectedWinner.roll, "RAID_WARNING")
                ResetRollManager()
            else
                print("No winner selected. Please select a winner first.")
            end
        end)
    end

    itemText:SetText(itemLink);

    if(ns.Utils.CanManage()) then
        winnerDropdown:Show();
        announceButton:Show();
    else
        winnerDropdown:Hide();
        announceButton:Hide();
    end

end

