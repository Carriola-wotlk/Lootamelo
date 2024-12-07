local ns = _G[LOOTAMELO_NAME];
ns.Create = ns.Create or {};

local createButton, createTextArea, scrollFrame;
local createTitle;

local function UpdateCreateButtonState()
    local text = createTextArea:GetText();
    if text and text ~= "" and ns.State.currentRaid and ns.State.currentRaid ~= "" then
        createButton:Enable();
    else
        createButton:Disable();
    end
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

    LootameloDB = {
        id = {};
        date = today;
        raid = ns.State.currentRaid;
        reserve = data;
        loot = {
            lastBossLooted = "",
            list = {},
        };
    }


    ns.Navigation.ToPage("Raid");
end

function OnDropDownClick(self, arg1, arg2, checked)
        ns.State.currentRaid = self.value;
        local dropDownButton = _G["Lootamelo_CreateFrameDropDownButton"];
        UIDropDownMenu_SetText(dropDownButton, self.value);
end

function Lootamelo_CreateFrameInitDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    info.func = OnDropDownClick;

    if level == 1 then
        for _, raid in pairs(ns.Database.raids) do
            info.text = raid;
            info.value = raid;
            UIDropDownMenu_AddButton(info);
        end
    end
end



function ns.Create.LoadFrame()
    local createFrame =  _G["Lootamelo_CreateFrame"];

    if(not createTitle) then
        createTitle = _G["Lootamelo_CreateFrame"]:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        createTitle:SetPoint("TOPLEFT", _G["Lootamelo_CreateFrame"], "TOPLEFT", 55, -70);
        createTitle:SetText("Paste SoftRes \"WeakAura Data\" here:");
    end

    if(not scrollFrame) then
        scrollFrame = CreateFrame("ScrollFrame", "Lootamelo_CreateFrameTextAreaScollFrame", createFrame, "UIPanelScrollFrameTemplate");
        createTextArea = CreateFrame("EditBox", "Lootamelo_CreateFrameTextArea", scrollFrame);
        scrollFrame:SetSize(400, 230);
        scrollFrame:SetPoint("CENTER", createFrame, "CENTER", 0, -5);
        createTextArea:SetMultiLine(true);
        createTextArea:SetAutoFocus(true);
        createTextArea:SetSize(285, 230);
        createTextArea:SetFontObject(GameFontHighlight);
        scrollFrame:SetScrollChild(createTextArea);

        scrollFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            insets = { left = -8, right = 0, top = -8, bottom = -8 }
        });

        createButton = CreateFrame("Button", "Lootamelo_Create_Button", createFrame, "UIPanelButtonTemplate");
        createButton:SetPoint("BOTTOMRIGHT", createFrame, "BOTTOMRIGHT", -50, 30);
        createButton:SetSize(100, 30);
        createButton:SetText("Create");
        createButton:Disable();
    end

    createTextArea:SetScript("OnTextChanged", function(self)
        UpdateCreateButtonState();
        local scrollBar = scrollFrame.ScrollBar;
        local scrollMax = scrollBar:GetMinMaxValues();
        local currentScroll = scrollBar:GetValue();

        if currentScroll >= scrollMax then
            scrollFrame:SetVerticalScroll(scrollMax);
        end
    end)

    createTextArea:SetScript("OnEscapePressed", function(self)
        self:ClearFocus(); -- Rimuove il focus premendo Esc
    end)

    createButton:SetScript("OnClick", function()
        Lootamelo_Create_Run(createTextArea:GetText());
    end);
end