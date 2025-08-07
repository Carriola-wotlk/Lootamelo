local ns = _G[LOOTAMELO_NAME]
ns.Events = ns.Events or {}
local AceComm = LibStub("AceComm-3.0")
local AceTimer = LibStub("AceTimer-3.0")

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

function ns.Events.UpdateMasterLooterState()
	if not UnitInRaid("player") then
		ns.State.isRaidLeader = false
		ns.State.isMasterLooter = false
		return
	end

	ns.State.isRaidLeader = IsRaidLeader() == 1

	local lootmethod, _, masterlooterRaidID = GetLootMethod()
	if lootmethod == "master" and masterlooterRaidID then
		local name = GetRaidRosterInfo(masterlooterRaidID)
		ns.State.masterLooterName = name
		ns.State.isMasterLooter = (name == ns.State.playerName)
	else
		ns.State.masterLooterName = nil
		ns.State.isMasterLooter = false
	end

	print("ns.State.isMasterLooter")
	print(ns.State.isMasterLooter)
end

ns.Events["PARTY_LEADER_CHANGED"] = ns.Events.UpdateMasterLooterState
ns.Events["PARTY_LOOT_METHOD_CHANGED"] = ns.Events.UpdateMasterLooterState
ns.Events["RAID_ROSTER_UPDATE"] = ns.Events.UpdateMasterLooterState

ns.Events["PLAYER_ENTERING_WORLD"] = function()
	AceTimer:ScheduleTimer(function()
		ns.Events.UpdateMasterLooterState()
	end, 1)
end

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
	if ns.Utils.CanManage() then
		local targetName = GetUnitName("target")
		if not targetName then
			return
		end

		local bossName = ns.Utils.GetBossName(targetName)
		if not bossName then
			return
		end

		local messageParts = {}

		for slot = 1, GetNumLootItems() do
			local itemLink = GetLootSlotLink(slot)
			if itemLink then
				local itemId = ns.Utils.GetItemIdFromLink(itemLink)
				if itemId then
					if
						ns.Database.items[ns.State.currentRaid][bossName]
						and ns.Database.items[ns.State.currentRaid][bossName][itemId]
					then
						local reserveData = LootameloDB.raid.reserve[itemId]
						local players = {}

						if reserveData then
							for player, data in pairs(reserveData) do
								table.insert(players, player .. "(" .. (data.reserveCount or 1) .. ")")
							end
						end

						if #players > 0 then
							table.insert(messageParts, itemId .. ":" .. table.concat(players, ","))
						else
							table.insert(messageParts, itemId)
						end
					end
				end
			end
		end

		if #messageParts > 0 then
			local messageToSend = "LOOT_INFO:" .. bossName .. ";" .. table.concat(messageParts, ";")
			AceComm:SendCommMessage(LOOTAMELO_CHANNEL_PREFIX, messageToSend, "RAID")
		end
	end
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

	local cmd, data = message:match("([^:]+):(.+)")

	if cmd == "LOOT_INFO" then
		ns.Loot.HandleLootInfoMessage(data)
	elseif cmd == "START_ROLL" then
		local itemIdStr, reservedStr, bossName = strsplit("|", data)
		local itemId = tonumber(itemIdStr)

		if itemId then
			local item = ns.Utils.GetItemById(itemId, ns.State.currentRaid)
			if item then
				local reservedPlayers = reservedStr ~= "" and reservedStr or nil
				ns.Roll.LoadFrame(ns.Utils.GetHyperlinkByItemId(itemId, item), bossName, reservedPlayers)
			end
		end
	elseif cmd == "RESERVE_DATA" then
		if not ns.Utils.CanManage() then
			local raidName, reserveDataStr = data:match("([^|]+)|(.+)")
			if raidName and reserveDataStr then
				LootameloDB.raid = LootameloDB.raid or {}
				LootameloDB.raid.name = raidName
				LootameloDB.raid.reserve = {}

				local newReserve = {}

				for itemChunk in string.gmatch(reserveDataStr, "([^;]+)") do
					local itemIdStr, playersStr = itemChunk:match("([^:]+):(.+)")
					local itemId = tonumber(itemIdStr)
					if itemId then
						newReserve[itemId] = {}
						if playersStr and playersStr ~= "" then
							for player in string.gmatch(playersStr, "([^,]+)") do
								local name, countStr = player:match("([^(]+)%((%d+)%)")
								local count = tonumber(countStr) or 1
								newReserve[itemId][name] = {
									reserveCount = count,
								}
							end
						end
					end
				end

				LootameloDB.raid.reserve = newReserve

				print(LOOTAMELO_RESERVED_COLOR .. "[Lootamelo]|r Reserve data received from Master Looter")
				print(LOOTAMELO_RESERVED_COLOR .. "[Lootamelo]|r Raid: " .. raidName)
			end
		end
	end
end

AceComm:RegisterComm(LOOTAMELO_CHANNEL_PREFIX, OnAddonMessageReceived)
