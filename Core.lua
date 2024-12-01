-- Creazione del frame principale per gestire eventi
local Lootamelo = CreateFrame("Frame");

-- Creazione del bottone principale
local Lootamelo_main_button = CreateFrame("Button", "LootameloInitialButton", UIParent, "UIPanelButtonTemplate");
Lootamelo_main_button:SetPoint("LEFT", 0, 0);
Lootamelo_main_button:SetSize(100, 30);
Lootamelo_main_button:SetText("Lootamelo");
Lootamelo_main_button:SetMovable(true);
Lootamelo_main_button:RegisterForDrag("LeftButton");
Lootamelo_main_button:SetScript("OnDragStart", Lootamelo_main_button.StartMoving);
Lootamelo_main_button:SetScript("OnDragStop", Lootamelo_main_button.StopMovingOrSizing);

local addonName = ...;

-- Funzioni per gestire il frame principale
function Lootamelo_CloseMainFrame()
    if _G["Lootamelo_MainFrame"] then
        _G["Lootamelo_MainFrame"]:Hide();
    end
end

function Lootamelo_ShowMainFrame()
    _G["Lootamelo_MainFrame"]:Show();

    print(Lootamelo_Current_Page);

    if(Lootamelo_Current_Page == 'create') then
        Lootamelo_ShowCreateFrame();
    else
        Lootamelo_ShowRaidFrame();
    end
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
            Lootamelo_Current_Page = 'raid';
            Lootamelo_Current_Raid = LootameloDB.raid;
        else
            Lootamelo_Current_Page = 'create';
        end
    end
end

-- Registra gli eventi
Lootamelo:RegisterEvent("ADDON_LOADED");
Lootamelo:RegisterEvent("PLAYER_LOGOUT");
Lootamelo:SetScript("OnEvent", OnEvent);