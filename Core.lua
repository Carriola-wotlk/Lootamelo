local Lootamelo = CreateFrame("Frame");
local addonName = ...;
local isFirstLootOpen = true;

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


function Lootamelo_NavButtonOnClick(self)
    local buttonName = self:GetName();
    local page = string.match(buttonName, "Lootamelo_NavButton(%w+)");
    Lootamelo_NavigateToPage(page, isFirstLootOpen);
    if(page == "Loot") then
        isFirstLootOpen = false;
    end
end

function Lootamelo_ShowMainFrame()
    _G["Lootamelo_MainFrame"]:Show();
    Lootamelo_NavigateToPage(Lootamelo_Current_Page, isFirstLootOpen);
    if(Lootamelo_Current_Page == "Loot") then
        isFirstLootOpen = false;
    end
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

function Lootamelo_RaidEventListener(event, arg1, message)
    local inInstance, instanceType = IsInInstance();

    if(instanceType and instanceType == "pvp") then
        return;
    end

    if event == "PLAYER_LOGIN" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_LOOT_METHOD_CHANGED" then
        Lootamelo_IsRaidOfficer = IsRaidOfficer();
    end

    if event == "CHAT_MSG_SYSTEM" then
        if(arg1) then
            if string.match(arg1, "(.+) is now the loot master") then
                local masterLooterName = string.match(arg1, "(.+) is now the loot master")
                Lootamelo_MasterLooterName = masterLooterName;
            end
        end
    end

    if(LootameloDB.reserve) then
        if event == "LOOT_OPENED" then
            local targetName = GetUnitName("target", true);
            local bossName = Lootamelo_GetBossName(targetName);
        
            if not bossName then
                print("Nessun boss trovato.");
                return
            end

            if Lootamelo_IsRaidOfficer then
                if not _G["Lootamelo_MainFrame"]:IsShown() then
                    _G["Lootamelo_MainFrame"]:Show();
                end
                Lootamelo_ShowLootPage(true, bossName, isFirstLootOpen);
                isFirstLootOpen = false;
            end
        end
    end

    -- if event == "PLAYER_ENTERING_WORLD" then
    --     if inInstance and instanceType == "raid" then
    --         local instanceID = select(8, GetInstanceInfo());
    --         print("instanceID", instanceID);

    --         StaticPopupDialogs["LOOTAMELO_CONFIRM_RAID_START"] = {
    --             text = "Sei sicuro di voler iniziare il raid?",
    --             button1 = "Sì",
    --             button2 = "No",
    --             OnAccept = function()
    --                 -- Azioni da eseguire quando l'utente preme "Sì"
    --                 print("Il raid è stato avviato!")
    --             end,
    --             OnCancel = function()
    --                 -- Azioni da eseguire quando l'utente preme "No"
    --                 print("Il raid non è stato avviato.")
    --             end,
    --             timeout = 0,
    --             whileDead = true,
    --             hideOnEscape = true,
    --         };

    --         StaticPopup_Show("LOOTAMELO_CONFIRM_RAID_START");

    --     end
    -- end

    -- if event == "CHAT_MSG_ADDON" and arg1 == Lootamelo_ChannelPrefix then
    --     if(message) then
    --         print("eccomi>>>>" .. message);
    --     end
    -- end
end

local function OnEvent(self, event, arg1, message)
    if event == "ADDON_LOADED" and arg1 == addonName then
        Lootamelo_PagesVariableInit();
        if(LootameloDB) then
            Lootamelo_Current_Page = "Raid";
            Lootamelo_PlayerLevel = UnitLevel("player");
            Lootamelo_CurrentRaid = LootameloDB.raid;
        else
            Lootamelo_Current_Page = "Config";
            LootameloDB = {
                date = "";
                raid = "";
                reserve = {};
                loot = {};
            };
        end
    end

    if UnitInRaid("player") then
        Lootamelo_RaidEventListener(event, arg1, message);
    end
end

-- Registra gli eventi
Lootamelo:RegisterEvent("ADDON_LOADED");
Lootamelo:RegisterEvent("LOOT_OPENED");
Lootamelo:RegisterEvent("PLAYER_LOGIN");
Lootamelo:RegisterEvent("CHAT_MSG_SYSTEM");
Lootamelo:RegisterEvent("PARTY_LEADER_CHANGED");
Lootamelo:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
Lootamelo:RegisterEvent("PLAYER_ENTERING_WORLD");
Lootamelo:RegisterEvent("CHAT_MSG_ADDON");

Lootamelo:SetScript("OnEvent", OnEvent);