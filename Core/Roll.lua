local RollManager = CreateFrame("Frame", "RollManagerFrame", UIParent)
local rolls = {}
local itemLink = nil
local selectedWinner = nil  -- Variabile per tenere traccia del vincitore selezionato
local selectedRow = nil     -- Per tracciare la riga selezionata


-- Funzione per resettare i dati
local function ResetRollManager()
    rolls = {}
    itemLink = nil
    RollManager:Hide()
end

-- Creazione del frame principale
RollManager:SetSize(256, 256)
RollManager:SetPoint("CENTER")
RollManager:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
RollManager:SetBackdropColor(0, 0, 0, 1)
RollManager:Hide()

-- Item link display
local itemText = RollManager:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
itemText:SetPoint("TOP", 0, -20)
itemText:SetText("Item: None")

-- Roll list display
local rollList = CreateFrame("Frame", nil, RollManager)
rollList:SetSize(220, 120)
rollList:SetPoint("CENTER")
rollList:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
})
rollList:SetBackdropColor(0.1, 0.1, 0.1, 1)

local rollListText = rollList:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
rollListText:SetPoint("TOPLEFT", 10, -10)
rollListText:SetPoint("BOTTOMRIGHT", -10, 10)
rollListText:SetJustifyH("LEFT")
rollListText:SetText("No rolls yet")

-- Button per selezionare il vincitore
local announceButton = CreateFrame("Button", nil, RollManager, "UIPanelButtonTemplate")
announceButton:SetSize(120, 30)
announceButton:SetPoint("BOTTOM", 0, 20)
announceButton:SetText("Announce Winner")
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

local selectedWinnerText = RollManager:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
selectedWinnerText:SetPoint("TOP", rollList, "TOP", 0, 20)
selectedWinnerText:SetText("Selected Winner: None")

-- Dropdown per selezionare il vincitore
local winnerDropdown = CreateFrame("Frame", "WinnerDropdown", RollManager, "UIDropDownMenuTemplate")
winnerDropdown:SetPoint("TOP", rollList, "BOTTOM", 0, -10)

-- Funzione per aggiornare il dropdown
local function UpdateWinnerDropdown()
    UIDropDownMenu_Initialize(winnerDropdown, function(self, level, menuList)
        for i, rollData in ipairs(rolls) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = rollData.player .. " (" .. rollData.roll .. ")"
            info.func = function()
                selectedWinner = rollData
                selectedWinnerText:SetText("Selected Winner: " .. rollData.player)
                UIDropDownMenu_SetText(winnerDropdown, rollData.player .. " (" .. rollData.roll .. ")") -- Aggiorna il testo del dropdown
                print("Selected winner: " .. rollData.player)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Imposta il testo iniziale del dropdown
    if #rolls > 0 then
        local firstRoll = rolls[1]
        print(firstRoll)
        UIDropDownMenu_SetText(winnerDropdown, "Select a winner") -- Testo iniziale predefinito
    else
        UIDropDownMenu_SetText(winnerDropdown, "No rolls yet") -- Testo se non ci sono giocatori
    end
end

-- Funzione per aggiornare la lista dei roll
local function UpdateRollList()
    table.sort(rolls, function(a, b) return a.roll > b.roll end)
    local rollText = ""

    for _, rollData in ipairs(rolls) do
        rollText = rollText .. rollData.player .. ": " .. rollData.roll .. "\n"
    end

    rollListText:SetText(rollText)
    UpdateWinnerDropdown() -- Aggiorna il dropdown con l'elenco dei giocatori
end

-- Funzione per analizzare la chat
RollManager:RegisterEvent("CHAT_MSG_RAID_WARNING")
RollManager:RegisterEvent("CHAT_MSG_SYSTEM")
RollManager:SetScript("OnEvent", function(self, event, message, sender)
    if event == "CHAT_MSG_RAID_WARNING" then
        -- Modifica il pattern per essere più generico
        local _, _, matchedItemLink = string.find(message, "Roll for .- on: (|c.-|r)")
        if matchedItemLink then
            itemLink = matchedItemLink
            itemText:SetText("Item: " .. itemLink)
            RollManager:Show()
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        if itemLink then
            -- Modifica il pattern per gestire il formato (1-100)
            local _, _, playerName, rollValue, rollMin, rollMax = string.find(message, "(%a+)%srolls%s(%d+)%s%((%d+)%-(%d+)%)")
            print(playerName, rollValue, rollMin, rollMax) -- Debug: Verifica i valori estratti
            if playerName and rollValue and rollMax and tonumber(rollMin) == 1 and tonumber(rollMax) == 100 then
                table.insert(rolls, { player = playerName, roll = tonumber(rollValue) })
                UpdateRollList()
                if IsRaidLeader() then
                    announceButton:Enable()
                end
            end
        end
    end
end)


-- Esc per chiudere il frame
RollManager:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        ResetRollManager()
    end
end)
