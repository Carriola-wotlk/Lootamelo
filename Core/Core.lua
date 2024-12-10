local ns = _G[LOOTAMELO_NAME];

-- Crea la frame principale e il bottone
ns.Lootamelo = CreateFrame("Frame");
ns.MainButton = CreateFrame("Button", "Lootamelo_MainButton", UIParent, "UIPanelButtonTemplate");


local pagesSwitch = {
    Settings = ns.Settings.LoadFrame,
    Raid = ns.Raid.LoadFrame,
    Loot = ns.Loot.LoadFrame,
    Create = ns.Create.LoadFrame,
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

local function OnEvent(self, event, ...)
    if ns.Events[event] then
        ns.Events[event](...);
    end
end

ns.Lootamelo:RegisterEvent("ADDON_LOADED");
ns.Lootamelo:RegisterEvent("PLAYER_LOGIN");

ns.Lootamelo:RegisterEvent("CHAT_MSG_RAID_WARNING")
ns.Lootamelo:RegisterEvent("CHAT_MSG_SYSTEM")

ns.Lootamelo:RegisterEvent("PARTY_LEADER_CHANGED");
ns.Lootamelo:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
ns.Lootamelo:RegisterEvent("PLAYER_ENTERING_WORLD");
ns.Lootamelo:RegisterEvent("UPDATE_INSTANCE_INFO");

ns.Lootamelo:RegisterEvent("LOOT_OPENED");
ns.Lootamelo:RegisterEvent("UNIT_HEALTH");
ns.Lootamelo:SetScript("OnEvent", OnEvent)