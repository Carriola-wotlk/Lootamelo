local createButton, createTextArea, scrollFrame;

local function UpdateCreateButtonState()
    local text = createTextArea:GetText();
    if text ~= "" and Lootamelo_Current_Raid and Lootamelo_Current_Raid ~= "" then
        createButton:Enable();
    else
        createButton:Disable();
    end
end

function  Lootamelo_ShowCreateFrame()
    _G["Lootamelo_Create_Frame"]:Show();
    _G["Lootamelo_Raid_Frame"]:Hide();
    Lootamelo_Current_Page = 'create';

    local createFrame =  _G["Lootamelo_Create_Frame"];

    if(not scrollFrame) then
        scrollFrame = CreateFrame("ScrollFrame", "Lootamelo_TextArea_ScrollFrame", createFrame, "UIPanelScrollFrameTemplate");
        createTextArea = CreateFrame("EditBox", "Lootamelo_TextArea", scrollFrame);
        scrollFrame:SetSize(290, 230); -- Larghezza e altezza visibile
        scrollFrame:SetPoint("TOP", createFrame, "TOP", -80, -150); -- Posizionamento relativo al frame principale
        createTextArea:SetMultiLine(true);
        createTextArea:SetAutoFocus(false);
        createTextArea:SetSize(285, 230);
        createTextArea:SetFontObject(GameFontHighlight);
        scrollFrame:SetScrollChild(createTextArea);

        scrollFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            insets = { left = -8, right = 0, top = -8, bottom = -8 }
        });

        -- create button
        createButton = CreateFrame("Button", "Lootamelo_Create_Button", createFrame, "UIPanelButtonTemplate");
        createButton:SetPoint("BOTTOM", createFrame, "BOTTOM", 17, 80);
        createButton:SetSize(100, 30);
        createButton:SetText("Create");
        createButton:Disable();
    end

    -- Aggiungi il comportamento per aggiornare lo scroll dinamicamente
    createTextArea:SetScript("OnTextChanged", function(self)
        UpdateCreateButtonState();
        local scrollBar = scrollFrame.ScrollBar;
        local scrollMax = scrollBar:GetMinMaxValues();
        local currentScroll = scrollBar:GetValue();

        -- Aggiorna automaticamente lo scroll alla fine se il testo aumenta
        if currentScroll >= scrollMax then
            scrollFrame:SetVerticalScroll(scrollMax);
        end
    end)

    -- Aggiungi interazione per fare click nella textarea e abilitarla
    createTextArea:SetScript("OnEscapePressed", function(self)
        self:ClearFocus(); -- Rimuove il focus premendo Esc
    end)

    createButton:SetScript("OnClick", function()
        Lootamelo_Create_Run(createTextArea:GetText());
    end);

end

function Lootamelo_Create_Run(inputText)
    local data = {};
    local today = date("%d-%m-%Y");
    local isFirstLine = true;
    for line in inputText:gmatch("[^\r\n]+") do
        if isFirstLine and line:match("^ItemId,Name,Class,Note,Plus$") then
            isFirstLine = false;
        else
            local itemId, playerName, class, note, plus = line:match("([^,]+),([^,]+),([^,]*),([^,]*),([^,]*)");
            if itemId and playerName then
                itemId = tonumber(itemId);
                if not data[itemId] then
                    data[itemId] = {};
                end
                -- Verifica se il giocatore ha già riservato questo item utilizzando il nome come chiave
                local playerData = data[itemId][playerName];

                
               -- Se il giocatore ha già riservato, aggiorna la sua proprietà 'reserveCount'
               if playerData then
                    playerData.reserveCount = (playerData.reserveCount or 0) + 1;
                else
                    data[itemId][playerName] = {
                        class = class,
                        note = note,
                        plus = tonumber(plus) or 0,
                        roll = 0,
                        won = false,
                        reserveCount = 1
                    };
                end
                print(data);
            end
        end
        isFirstLine = false;
    end

    if not LootameloDB then LootameloDB = {}; end

    LootameloDB.date = today;
    LootameloDB.raid = Lootamelo_Current_Raid;
    LootameloDB.reserve = data;

    Lootamelo_ShowRaidFrame();
end

function Lootamelo_Create_Raids_DropDownOnClick(self, arg1, arg2, checked)
        Lootamelo_Current_Raid = self.value;
        local dropDownButton = _G["Lootamelo_Create_Raids_DropDownButton"];
        UIDropDownMenu_SetText(dropDownButton, self.value);
end

function Lootamelo_Create_Raids_InitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = Lootamelo_Create_Raids_DropDownOnClick;

    if level == 1 then
        for _, raid in pairs(Lootamelo_Raids_Data) do
            info.text = raid;
            info.value = raid;
            UIDropDownMenu_AddButton(info);
        end
    end

end