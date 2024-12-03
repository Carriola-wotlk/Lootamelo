local Lootamelo = CreateFrame("Frame");
local addonName = ...;

local Lootamelo_MainButton = CreateFrame("Button", "LootameloInitialButton", UIParent, "UIPanelButtonTemplate");
Lootamelo_MainButton:SetPoint("LEFT", 0, 0);
Lootamelo_MainButton:SetSize(100, 30);
Lootamelo_MainButton:SetText("Lootamelo");
Lootamelo_MainButton:SetMovable(true);
Lootamelo_MainButton:RegisterForDrag("LeftButton");
Lootamelo_MainButton:SetScript("OnDragStart", Lootamelo_MainButton.StartMoving);
Lootamelo_MainButton:SetScript("OnDragStop", Lootamelo_MainButton.StopMovingOrSizing);

function Lootamelo_CloseMainFrame()
    if _G["Lootamelo_MainFrame"] then
        _G["Lootamelo_MainFrame"]:Hide();
    end
end

function Lootamelo_ShowMainFrame()
    _G["Lootamelo_MainFrame"]:Show();
    Lootamelo_NavigateToPage(Lootamelo_Current_Page);
end

function Lootamelo_MainFrameToggle()
    if _G["Lootamelo_MainFrame"] and _G["Lootamelo_MainFrame"]:IsShown() then
        Lootamelo_CloseMainFrame();
    else
        Lootamelo_ShowMainFrame();
    end
end

Lootamelo_MainButton:SetScript("OnClick", function()
    Lootamelo_MainFrameToggle();
end)


-- Funzione per gestire eventi
local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        Lootamelo_PagesVariableInit();
        if(LootameloDB) then
            Lootamelo_Current_Page = 'Raid';
            Lootamelo_CurrentRaid = LootameloDB.raid;
        else
            Lootamelo_Current_Page = 'Config';
        end
    end

    if event == "PLAYER_LOGIN" or event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LOOT_METHOD_CHANGED" then
        Lootamelo_LoadMainButton();
        Lootamelo_UpdatePlayerRoles();
        print("Lootamelo_IsRaidLeader" .. Lootamelo_IsRaidLeader);
    end

    if event == "LOOT_OPENED" then
        if Lootamelo_IsRaidLeader then
            if not _G["Lootamelo_MainFrame"]:IsShown() then
                _G["Lootamelo_MainFrame"]:Show();
            end
            Lootamelo_ShowLootPage(true);
        end
    end
end

-- Registra gli eventi
Lootamelo:RegisterEvent("ADDON_LOADED");
Lootamelo:RegisterEvent("PLAYER_LOGOUT");
Lootamelo:RegisterEvent("LOOT_OPENED");
Lootamelo:RegisterEvent("LOOT_CLOSED");
Lootamelo:RegisterEvent("PLAYER_LOGIN");
Lootamelo:RegisterEvent("GROUP_ROSTER_UPDATE");
Lootamelo:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
Lootamelo:SetScript("OnEvent", OnEvent);