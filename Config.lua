local createButton, configTextArea, scrollFrame;
local configTitle;

local function UpdateCreateButtonState()
    local text = configTextArea:GetText();
    if text and text ~= "" and Lootamelo_CurrentRaid and Lootamelo_CurrentRaid ~= "" then
        createButton:Enable();
    else
        createButton:Disable();
    end
end

function  Lootamelo_LoadConfigFrame()
    local configFrame =  _G["Lootamelo_ConfigFrame"];

    if(not configTitle) then
        configTitle = _G["Lootamelo_ConfigFrame"]:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        configTitle:SetPoint("TOPLEFT", _G["Lootamelo_ConfigFrame"], "TOPLEFT", 55, -70);
        configTitle:SetText("Paste SoftRes \"WeakAura Data\" here:");
    end

    if(not scrollFrame) then
        scrollFrame = CreateFrame("ScrollFrame", "Lootamelo_ConfigFrameTextAreaScollFrame", configFrame, "UIPanelScrollFrameTemplate");
        configTextArea = CreateFrame("EditBox", "Lootamelo_ConfigFrameTextArea", scrollFrame);
        scrollFrame:SetSize(400, 230);
        scrollFrame:SetPoint("CENTER", configFrame, "CENTER", 0, -5);
        configTextArea:SetMultiLine(true);
        configTextArea:SetAutoFocus(true);
        configTextArea:SetSize(285, 230);
        configTextArea:SetFontObject(GameFontHighlight);
        scrollFrame:SetScrollChild(configTextArea);

        scrollFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            insets = { left = -8, right = 0, top = -8, bottom = -8 }
        });

        createButton = CreateFrame("Button", "Lootamelo_Create_Button", configFrame, "UIPanelButtonTemplate");
        createButton:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -50, 30);
        createButton:SetSize(100, 30);
        createButton:SetText("Create");
        createButton:Disable();
    end

    configTextArea:SetScript("OnTextChanged", function(self)
        UpdateCreateButtonState();
        local scrollBar = scrollFrame.ScrollBar;
        local scrollMax = scrollBar:GetMinMaxValues();
        local currentScroll = scrollBar:GetValue();

        if currentScroll >= scrollMax then
            scrollFrame:SetVerticalScroll(scrollMax);
        end
    end)

    configTextArea:SetScript("OnEscapePressed", function(self)
        self:ClearFocus(); -- Rimuove il focus premendo Esc
    end)

    createButton:SetScript("OnClick", function()
        Lootamelo_Create_Run(configTextArea:GetText());
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

                local playerData = data[itemId][playerName];

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
            end
        end
        isFirstLine = false;
    end

    if(not LootameloDB) then
        LootameloDB = {};
    end

    LootameloDB.date = today;
    LootameloDB.raid = Lootamelo_CurrentRaid;
    LootameloDB.reserve = data;
    LootameloDB.loot = {};

    Lootamelo_NavigateToPage("Raid");
end

function Lootamelo_ConfigFrameDropDown_OnClick(self, arg1, arg2, checked)
        Lootamelo_CurrentRaid = self.value;
        local dropDownButton = _G["Lootamelo_ConfigFrameDropDownButton"];
        UIDropDownMenu_SetText(dropDownButton, self.value);
end

function Lootamelo_ConfigFrameInitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = Lootamelo_ConfigFrameDropDown_OnClick;

    if level == 1 then
        for _, raid in pairs(Lootamelo_Raids_Data) do
            info.text = raid;
            info.value = raid;
            UIDropDownMenu_AddButton(info);
        end
    end
end