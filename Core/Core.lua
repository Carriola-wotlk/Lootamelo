local ns = _G[LOOTAMELO_NAME]

-- Crea la frame principale e il bottone
ns.Lootamelo = CreateFrame("Frame")
ns.MainButton = CreateFrame("Button", "Lootamelo_MainButton", UIParent, "UIPanelButtonTemplate")

ns.MainButton:SetPoint("LEFT", 0, 0)
ns.MainButton:SetSize(100, 30)
ns.MainButton:SetText("Lootamelo")
ns.MainButton:SetMovable(true)
ns.MainButton:RegisterForDrag("LeftButton")
ns.MainButton:SetScript("OnDragStart", ns.MainButton.StartMoving)
ns.MainButton:SetScript("OnDragStop", ns.MainButton.StopMovingOrSizing)

local function Loading_PagesData(page)
	if page == "Settings" then
		ns.Settings.LoadFrame()
	elseif page == "Raid" then
		ns.Raid.LoadFrame()
	elseif page == "Loot" then
		if LootameloDB.raid.name and LootameloDB.raid.loot and LootameloDB.raid.loot.lastBossLooted then
			ns.Loot.LoadFrame(LootameloDB.raid.loot.lastBossLooted, false, "", LootameloDB.raid.name)
		end
	elseif page == "Create" then
		ns.Create.LoadFrame()
	end
end

ns.MainButton:SetScript("OnClick", function()
	ns.Navigation.MainFrameToggle(ns.State.currentPage)
	Loading_PagesData(ns.State.currentPage)
end)

function Lootamelo_CreateNewRun()
	ns.Navigation.ToPage("Create")
	ns.Create.LoadFrame()
end

function Lootamelo_NavButtonOnClick(self)
	local buttonName = self:GetName()
	local page = string.match(buttonName, "Lootamelo_NavButton(%w+)")
	ns.Navigation.ToPage(page)
	Loading_PagesData(page)
end

local function OnEvent(self, event, ...)
	if ns.Events[event] then
		ns.Events[event](...)
	end
end

ns.Lootamelo:RegisterEvent("ADDON_LOADED")
--ns.Lootamelo:RegisterEvent("PLAYER_LOGIN");

ns.Lootamelo:RegisterEvent("CHAT_MSG_RAID_WARNING")
ns.Lootamelo:RegisterEvent("CHAT_MSG_SYSTEM")

ns.Lootamelo:RegisterEvent("PARTY_LEADER_CHANGED")
ns.Lootamelo:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
ns.Lootamelo:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.Lootamelo:RegisterEvent("UPDATE_INSTANCE_INFO")

ns.Lootamelo:RegisterEvent("LOOT_OPENED")
-- ns.Lootamelo:RegisterEvent("UNIT_HEALTH");
ns.Lootamelo:SetScript("OnEvent", OnEvent)
