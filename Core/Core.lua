local ns = _G[LOOTAMELO_NAME];

-- Crea la frame principale e il bottone
ns.Lootamelo = CreateFrame("Frame");
ns.MainButton = CreateFrame("Button", "Lootamelo_MainButton", UIParent, "UIPanelButtonTemplate");


local pagesSwitch = {
    Settings = ns.Settings.LoadFrame,
    Raid = ns.Raid.LoadFrame,
    Loot = ns.Loot.LoadFrame,
}

ns.MainButton:SetPoint("LEFT", 0, 0);
ns.MainButton:SetSize(100, 30);
ns.MainButton:SetText("Lootamelo");
ns.MainButton:SetMovable(true);
ns.MainButton:RegisterForDrag("LeftButton");
ns.MainButton:SetScript("OnDragStart", ns.MainButton.StartMoving);
ns.MainButton:SetScript("OnDragStop", ns.MainButton.StopMovingOrSizing);

local function Loading_PagesData(page)
    if pagesSwitch[page] then
        pagesSwitch[page]();
    else
        print("Page not found");
    end
end

ns.MainButton:SetScript("OnClick", function()
    ns.Navigation.MainFrameToggle(ns.State.currentPage);
    Loading_PagesData(ns.State.currentPage);
end)

function Lootamelo_CreateNewRun()
    ns.Navigation.ToPage("Create");
    ns.Create.LoadFrame();
end

function Lootamelo_NavButtonOnClick(self)
    local buttonName = self:GetName();
    local page = string.match(buttonName, "Lootamelo_NavButton(%w+)");
    ns.Navigation.ToPage(page);
    Loading_PagesData(page);
end

function ns.ChangeLanguage(newLanguage)
    LootameloDB.language = newLanguage;
    ReloadUI();
end

local function OnLoot()
    if ns.State.isRaidOfficer then
        local targetName = GetUnitName("target");

        if(not targetName) then
            return;
        end
        local bossName = ns.Utils.GetBossName(targetName);
        
        if not bossName then
            return;
        end

        local messageToSend = "";
        local toSend = false;
        for slot = 1, GetNumLootItems() do
            local itemLink = GetLootSlotLink(slot);
            if(itemLink) then
                local itemIcon, itemName, _, itemRarity = GetLootSlotInfo(slot);
                local itemId;
                itemId = ns.Utils.GetItemIdFromLink(itemLink);

                if (not LootameloDB.loot.list[bossName]) then
                    LootameloDB.loot.list[bossName] = {};
                    toSend = true;
                end

                if itemId then
                    local count = 0;
                    if(LootameloDB.loot.list[bossName][itemId])then
                        count = count + 1;
                    else
                        count = 1;
                    end
                    local icon = ns.Utils.GetIconFromPath(itemIcon);
                    
                    LootameloDB.loot.list[bossName][itemId] = {
                        icon = icon,
                        name = itemName,
                        rolled = {},
                        won = "",
                        count = count
                    }
                    if(toSend) then
                        messageToSend = messageToSend .. ":" .. itemId;
                    end
                end
            end
        end

        LootameloDB.loot.lastBossLooted = bossName;

        ns.Navigation.ToPage("Loot");
        ns.Loot.LoadFrame(bossName, toSend, messageToSend)
    end
end

------------------------------------------------------------------
-- EVENTS --------------------------------------------------------
function ns.RaidEventListener(event, arg1, message)
    local inInstance, instanceType = IsInInstance();

    if(instanceType and instanceType == "pvp") then
        return;
    end

    if event == "PLAYER_LOGIN" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_LOOT_METHOD_CHANGED" then
        ns.State.isRaidOfficer = IsRaidOfficer();
    end

    if event == "CHAT_MSG_SYSTEM" then
        if(arg1) then
            if string.match(arg1, "(.+) is now the loot master") then
                local masterLooterName = string.match(arg1, "(.+) is now the loot master")
                ns.State.isMasterLooter = masterLooterName;
            end
        end
    end
end

local function OnEvent(self, event, arg1, message)
    if event == "LOOT_OPENED" then
        OnLoot();
     end

    if event == "ADDON_LOADED" and arg1 == addonName then
        ns.State.playerLevel = UnitLevel("player");
        if(not LootameloDB or LootameloDB.raid == "") then
            ns.State.currentPage = "Create";
            LootameloDB = {
                date = "";
                raid = "";
                reserve = {};
                loot = {};
            };
        else
            ns.State.currentPage = "Raid";
            if(LootameloDB.raid) then
                ns.State.currentRaid = LootameloDB.raid;
            end
        end
    end

    if UnitInRaid("player") then
        ns.RaidEventListener(event, arg1, message);
    end
end

ns.Lootamelo:RegisterEvent("ADDON_LOADED");
ns.Lootamelo:RegisterEvent("PLAYER_LOGIN");
ns.Lootamelo:RegisterEvent("CHAT_MSG_SYSTEM");
ns.Lootamelo:RegisterEvent("PARTY_LEADER_CHANGED");
ns.Lootamelo:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
ns.Lootamelo:RegisterEvent("PLAYER_ENTERING_WORLD");
ns.Lootamelo:RegisterEvent("LOOT_OPENED");
ns.Lootamelo:SetScript("OnEvent", OnEvent);
