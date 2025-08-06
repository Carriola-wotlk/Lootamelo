local ns = _G[LOOTAMELO_NAME]
ns.Events = ns.Events or {}
local AceComm = LibStub("AceComm-3.0")

-- ns.Events["UNIT_HEALTH"] = function(unit)
--     if ns.State.IsRaidLeader and not ns.State.masterLooterName then
--         if(LootameloDB.settings.autoMasterLoot) then
--             if not UnitExists(unit) then return end
--             if not UnitIsEnemy("player", unit) then return end

--             local healthPercentage = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
--             if healthPercentage <= 30 then
--                 SetLootMethod("master", "player");
--             end
--         end
--     end
-- end

ns.Events["PARTY_LEADER_CHANGED"] = function()
	if not UnitInRaid("player") then
		ns.State.isRaidLeader = false
		ns.State.isMasterLooter = false
		return
	end

	ns.State.isRaidLeader = (IsRaidLeader() == 1)

	local lootmethod, _, masterlooterRaidID = GetLootMethod()
	if lootmethod == "master" and masterlooterRaidID then
		local name = GetRaidRosterInfo(masterlooterRaidID)
		ns.State.masterLooterName = name
		ns.State.isMasterLooter = (name == ns.State.playerName)
	else
		ns.State.masterLooterName = nil
		ns.State.isMasterLooter = false
	end
end

ns.Events["PARTY_LOOT_METHOD_CHANGED"] = ns.Events["PARTY_LEADER_CHANGED"]
ns.Events["PLAYER_ENTERING_WORLD"] = ns.Events["PARTY_LEADER_CHANGED"]
ns.Events["PARTY_LOOT_METHOD_CHANGED"] = ns.Events["PARTY_LEADER_CHANGED"]
ns.Events["PLAYER_ENTERING_WORLD"] = ns.Events["PARTY_LEADER_CHANGED"]

ns.Events["UPDATE_INSTANCE_INFO"] = function()
	local inInstance = IsInInstance()
	local instanceName, type = GetInstanceInfo()
	if inInstance and type == "raid" then
		ns.State.currentRaid = ns.Utils.GetNormalizedRaidName(instanceName)
	end
end

ns.Events["ADDON_LOADED"] = function(addonName)
	if addonName ~= LOOTAMELO_NAME then
		return
	end

	ns.State.playerName = UnitName("player")
	ns.State.playerLevel = UnitLevel("player")

	LootameloDB = LootameloDB or {}

	if not LootameloDB.raid then
		ns.State.currentPage = "Create"
		LootameloDB.raid = {
			date = nil,
			name = nil,
			id = nil,
			reserve = {},
			loot = {
				lastBossLooted = nil,
				list = {},
			},
		}
	else
		ns.State.currentPage = "Raid"
		if LootameloDB.raid.name then
			ns.State.currentRaid = LootameloDB.raid.name
		end
	end

	LootameloDB.settings = LootameloDB.settings or {}
	LootameloDB.settings.alertMasterLoot = LootameloDB.settings.alertMasterLoot or false
	LootameloDB.settings.alertMasterLootHP = LootameloDB.settings.alertMasterLootHP or nil
	LootameloDB.settings.autoMasterLoot = LootameloDB.settings.autoMasterLoot or false
	LootameloDB.settings.autoMasterLootHP = LootameloDB.settings.autoMasterLootHP or nil
	LootameloDB.settings.rollCountdown = LootameloDB.settings.rollCountdown or 10
	LootameloDB.settings.showLootPanel = LootameloDB.settings.showLootPanel or false
	LootameloDB.settings.showRollPanel = LootameloDB.settings.showRollPanel or false
	LootameloDB.settings.language = LootameloDB.settings.language or GetLocale()

	ns.L = ns.translations[LootameloDB.settings.language] or ns.translations["enUS"]

	ns.ChangeLanguage(LootameloDB.settings.language)
end

ns.Events["LOOT_OPENED"] = function()
	local targetName = GetUnitName("target")

	if not targetName then
		return
	end

	local bossName = ns.Utils.GetBossName(targetName)

	if not bossName then
		return
	end

	local messageToSend = ""
	local toSend = false

	if not LootameloDB.raid.loot.list[bossName] then
		for slot = 1, GetNumLootItems() do
			local itemLink = GetLootSlotLink(slot)
			if itemLink then
				local itemId
				itemId = ns.Utils.GetItemIdFromLink(itemLink)
				if itemId then
					if ns.Database.items[ns.State.currentRaid][bossName][itemId] then
						if not LootameloDB.raid.loot.list[bossName] then
							LootameloDB.raid.loot.list[bossName] = {}
							toSend = true
						end

						local count = 0
						if LootameloDB.raid.loot.list[bossName][itemId] then
							count = LootameloDB.raid.loot.list[bossName][itemId].count + 1
						else
							count = 1
						end

						local item = ns.Utils.GetItemById(itemId, ns.State.currentRaid)

						if item then
							LootameloDB.raid.loot.list[bossName][itemId] = {
								rolled = {},
								won = "",
								count = count,
							}
						end
						if toSend then
							messageToSend = messageToSend .. ":" .. itemId
						end
					end
				end
			end
		end
	end

	local displayName = bossName
	for groupName, members in pairs(ns.Utils.BossGroups) do
		for _, member in ipairs(members) do
			if member == bossName then
				displayName = groupName
				break
			end
		end
	end

	LootameloDB.raid.loot.lastBossLooted = displayName
	ns.Navigation.ToPage("Loot")
	ns.Loot.LoadFrame(displayName, toSend, messageToSend, ns.State.currentRaid)
end

ns.Events["CHAT_MSG_SYSTEM"] = function(message)
	if _G["Lootamelo_RollFrame"] and _G["Lootamelo_RollFrame"]:IsShown() then
		local _, _, playerName, rollValue, rollMin, rollMax =
			string.find(message, "(%a+)%srolls%s(%d+)%s%((%d+)%-(%d+)%)")
		if playerName and rollValue and rollMax and tonumber(rollMin) == 1 and tonumber(rollMax) == 100 then
			ns.Roll.UpdateRollList(playerName, rollValue)
		end
	end
end

local function OnAddonMessageReceived(prefix, message, distribution, sender)
	if prefix ~= LOOTAMELO_CHANNEL_PREFIX then
		return
	end

	local cmd, data = strsplit(":", message)

	if cmd == "START_ROLL" then
		local itemId = tonumber(data)
		if itemId then
			local item = ns.Utils.GetItemById(itemId, ns.State.currentRaid)
			if item then
				ns.Roll.LoadFrame(ns.Utils.GetHyperlinkByItemId(itemId, item))
			end
		end
	elseif cmd == "RESERVE_DATA" then
		if not ns.Utils.CanManage() then
			local newReserve = {}

			for itemChunk in string.gmatch(data, "([^;]+)") do
				local itemIdStr, playersStr = strsplit(":", itemChunk)
				local itemId = tonumber(itemIdStr)
				if itemId then
					newReserve[itemId] = {}
					if playersStr and playersStr ~= "" then
						for player in string.gmatch(playersStr, "([^,]+)") do
							local name, countStr = player:match("([^(]+)%((%d+)%)")
							local count = tonumber(countStr) or 1
							newReserve[itemId][name] = {
								class = "",
								note = "",
								plus = 0,
								roll = 0,
								won = false,
								reserveCount = count,
							}
						end
					end
				end
			end

			if not LootameloDB.raid then
				LootameloDB.raid = { reserve = {} }
			end
			LootameloDB.raid.reserve = newReserve

			print(LOOTAMELO_RESERVED_COLOR .. "[Lootamelo]|r Reserve data received from Master Looter")
		end
	end
end

AceComm:RegisterComm(LOOTAMELO_CHANNEL_PREFIX, OnAddonMessageReceived)
