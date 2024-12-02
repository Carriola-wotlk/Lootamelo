local Lootamelo = CreateFrame("Frame");

local Lootamelo_main_button = CreateFrame("Button", "LootameloInitialButton", UIParent, "UIPanelButtonTemplate");
Lootamelo_main_button:SetPoint("LEFT", 0, 0);
Lootamelo_main_button:SetSize(100, 30);
Lootamelo_main_button:SetText("Lootamelo");
Lootamelo_main_button:SetMovable(true);
Lootamelo_main_button:RegisterForDrag("LeftButton");
Lootamelo_main_button:SetScript("OnDragStart", Lootamelo_main_button.StartMoving);
Lootamelo_main_button:SetScript("OnDragStop", Lootamelo_main_button.StopMovingOrSizing);

local addonName = ...;
local menuVoices = {"Config", "Raid", "Loot"};

function Lootamelo_CloseMainFrame()
    if _G["Lootamelo_MainFrame"] then
        _G["Lootamelo_MainFrame"]:Hide();
    end
end

function Lootamelo_ShowMainFrameNav()
    local navButton, buttonText;
    for index, voice in pairs(menuVoices) do
        navButton = CreateFrame("Button", "Lootamelo_NavButton" .. voice, _G["Lootamelo_MainFrame"], "Lootamelo_NavButtonTemplate");
        buttonText = _G[navButton:GetName() .. "Text"];
        if(buttonText) then
            buttonText:SetText(voice);
        end
        navButton:SetPoint("TOPLEFT", _G["Lootamelo_MainFrame"], "TOPLEFT", 60 + ((index-1) * 128), -40);
    end  
end

function Lootamelo_ShowMainFrame()
    _G["Lootamelo_MainFrame"]:Show();

    if(not _G["Lootamelo_NavButton1"]) then
        Lootamelo_ShowMainFrameNav();
    end
    
    Lootamelo_NavigateToPage(Lootamelo_Current_Page);
end

function Lootamelo_MainFrameToggle()
    if _G["Lootamelo_MainFrame"] and _G["Lootamelo_MainFrame"]:IsShown() then
        Lootamelo_CloseMainFrame();
    else
        Lootamelo_ShowMainFrame();
    end
end

Lootamelo_main_button:SetScript("OnClick", function()
    Lootamelo_MainFrameToggle();
end)


-- Funzione per gestire eventi
local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if(LootameloDB) then
            Lootamelo_Current_Page = 'Raid';
            Lootamelo_CurrentRaid = LootameloDB.raid;
        else
            Lootamelo_Current_Page = 'Create';
        end
    end
end

-- Registra gli eventi
Lootamelo:RegisterEvent("ADDON_LOADED");
Lootamelo:RegisterEvent("PLAYER_LOGOUT");
Lootamelo:SetScript("OnEvent", OnEvent);