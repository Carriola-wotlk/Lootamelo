local ns = _G[LOOTAMELO_NAME]
ns.Loot = ns.Loot or {}

local countdownTimer
local isFirstLootOpen = true

local itemPerPage = 7
local AceTimer = LibStub("AceTimer-3.0")
local AceComm = LibStub("AceComm-3.0")

function ns.Loot.HandleLootInfoMessage(data)
	local bossName, rest = strsplit(";", data, 2)
	if not bossName or not rest then
		return
	end

	local newLoot = {}

	for itemChunk in string.gmatch(rest, "([^;]+)") do
		local itemIdStr, playersStr = strsplit(":", itemChunk)
		local itemId = tonumber(itemIdStr)
		if itemId then
			local players = {}
			if playersStr and playersStr ~= "" then
				for playerData in string.gmatch(playersStr, "([^,]+)") do
					local name, countStr = playerData:match("([^(]+)%((%d+)%)")
					if name then
						players[name] = { reserveCount = tonumber(countStr) or 1 }
					end
				end
			end

			newLoot[itemId] = {
				rolled = {},
				won = "",
				count = 1,
			}

			if not LootameloDB.raid.reserve[itemId] and next(players) then
				LootameloDB.raid.reserve[itemId] = players
			end
		end
	end

	if not LootameloDB.raid.loot.list[bossName] then
		LootameloDB.raid.loot.list[bossName] = {}
	end

	for itemId, data in pairs(newLoot) do
		if LootameloDB.raid.loot.list[bossName][itemId] then
			LootameloDB.raid.loot.list[bossName][itemId].count = LootameloDB.raid.loot.list[bossName][itemId].count + 1
		else
			LootameloDB.raid.loot.list[bossName][itemId] = data
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
	ns.Loot.LoadFrame(displayName, ns.State.currentRaid.name)
end

local function DisableButtons()
	for idx = 1, itemPerPage do
		if _G["Lootamelo_LootItem" .. idx .. "MSButton"] then
			_G["Lootamelo_LootItem" .. idx .. "MSButton"]:Disable()
		end
		if _G["Lootamelo_LootItem" .. idx .. "OSButton"] then
			_G["Lootamelo_LootItem" .. idx .. "OSButton"]:Disable()
		end
		if _G["Lootamelo_LootItem" .. idx .. "FreeButton"] then
			_G["Lootamelo_LootItem" .. idx .. "FreeButton"]:Disable()
		end
	end
end

local function EnableButtons()
	for idx = 1, itemPerPage do
		if _G["Lootamelo_LootItem" .. idx .. "MSButton"] then
			_G["Lootamelo_LootItem" .. idx .. "MSButton"]:Enable()
		end
		if _G["Lootamelo_LootItem" .. idx .. "OSButton"] then
			_G["Lootamelo_LootItem" .. idx .. "OSButton"]:Enable()
		end
		if _G["Lootamelo_LootItem" .. idx .. "FreeButton"] then
			_G["Lootamelo_LootItem" .. idx .. "FreeButton"]:Enable()
		end
	end
end

local function LootFrameInitDropDown(self, level)
	if not level then
		return
	end
	if not LootameloDB.raid.loot.list then
		return
	end

	local addedNames = {}

	for bossName, _ in pairs(LootameloDB.raid.loot.list) do
		-- Controllo se il boss appartiene ad un gruppo
		local groupName = nil
		for gName, members in pairs(ns.Utils.BossGroups) do
			for _, member in ipairs(members) do
				if member == bossName then
					groupName = gName
					break
				end
			end
			if groupName then
				break
			end
		end

		local displayName = groupName or bossName
		if not addedNames[displayName] then
			addedNames[displayName] = true
			local info = UIDropDownMenu_CreateInfo()
			info.text = displayName
			info.value = displayName
			info.func = function()
				LootameloDB.raid.loot.lastBossLooted = displayName
				UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], displayName)
				ns.Loot.LoadFrame(displayName, LootameloDB.raid.name)
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

local function StartRollTimer(type, itemId, reservedPlayersAnnounce, item)
	if ns.Utils.CanManage() then
		local raidWarningMessage
		if reservedPlayersAnnounce ~= "" then
			raidWarningMessage = ns.L.RollForSoftReserve
				.. ": "
				.. ns.Utils.GetHyperlinkByItemId(itemId, item)
				.. ", "
				.. ns.L.ReservedBy
				.. " "
				.. reservedPlayersAnnounce
		else
			raidWarningMessage = ns.L.RollFor
				.. " "
				.. type
				.. " "
				.. ns.L.On
				.. ": "
				.. ns.Utils.GetHyperlinkByItemId(itemId, item)
		end

		SendChatMessage(raidWarningMessage, "RAID_WARNING")

		local bossName = LootameloDB.raid.loot.lastBossLooted or ""
		local reservedPlayers = reservedPlayersAnnounce or ""
		local commMsg = "START_ROLL:" .. itemId .. "|" .. reservedPlayers .. "|" .. bossName
		AceComm:SendCommMessage(LOOTAMELO_CHANNEL_PREFIX, commMsg, "RAID")

		local countdownPos = LootameloDB.settings.rollCountdown or 10

		SendChatMessage(ns.L.RollingEndsIn .. " " .. countdownPos .. " " .. ns.L.Seconds, "RAID_WARNING")

		local function CountdownTick()
			countdownPos = countdownPos - 1

			if countdownPos <= 5 and countdownPos > 0 then
				-- ultimi 5 secondi
				SendChatMessage(ns.L.RollingEndsIn .. " " .. countdownPos .. " " .. ns.L.Seconds, "RAID_WARNING")
			elseif countdownPos == 0 then
				SendChatMessage(ns.L.RollingEndsNow, "RAID_WARNING")
				EnableButtons()
				AceTimer:CancelTimer(countdownTimer)
			end
		end

		DisableButtons()
		countdownTimer = AceTimer:ScheduleRepeatingTimer(CountdownTick, 1)
	end
end

local function UpdateDropDownMenu(bossName)
	UIDropDownMenu_SetText(_G["Lootamelo_LootFrameDropDownButton"], bossName)
	UIDropDownMenu_Initialize(_G["Lootamelo_LootFrameDropDownButton"], LootFrameInitDropDown)
end

local function ClearItemsRows()
	for idx = 1, itemPerPage do
		if _G["Lootamelo_LootItem" .. idx .. "ItemIconTexture"] then
			_G["Lootamelo_LootItem" .. idx .. "ItemIconTexture"]:SetTexture(nil)
		end
		if _G["Lootamelo_LootItem" .. idx .. "Count"] then
			_G["Lootamelo_LootItem" .. idx .. "Count"]:SetText(nil)
		end
		if _G["Lootamelo_LootItem" .. idx .. "Text"] then
			_G["Lootamelo_LootItem" .. idx .. "Text"]:SetText(nil)
		end
		if _G["Lootamelo_LootItem" .. idx .. "ReservedIconTexture"] then
			_G["Lootamelo_LootItem" .. idx .. "ReservedIconTexture"]:SetTexture(nil)
		end
		if _G["Lootamelo_LootItem" .. idx .. "ItemIcon"] then
			_G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:SetScript("OnEnter", nil)
			_G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:SetScript("OnLeave", nil)
			_G["Lootamelo_LootItem" .. idx .. "ItemIcon"]:Hide()
		end
		if _G["Lootamelo_LootItem" .. idx .. "ReservedIcon"] then
			_G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:SetScript("OnEnter", nil)
			_G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:SetScript("OnLeave", nil)
			_G["Lootamelo_LootItem" .. idx .. "ReservedIcon"]:Hide()
		end
		if _G["Lootamelo_LootItem" .. idx .. "MSButton"] then
			_G["Lootamelo_LootItem" .. idx .. "MSButton"]:Hide()
		end
		if _G["Lootamelo_LootItem" .. idx .. "OSButton"] then
			_G["Lootamelo_LootItem" .. idx .. "OSButton"]:Hide()
		end
		if _G["Lootamelo_LootItem" .. idx .. "FreeButton"] then
			_G["Lootamelo_LootItem" .. idx .. "FreeButton"]:Hide()
		end
		if _G["Lootamelo_LootItem" .. idx .. "Roll"] then
			_G["Lootamelo_LootItem" .. idx .. "Roll"]:Hide()
		end
		if _G["Lootamelo_LootItem" .. idx .. "Won"] then
			_G["Lootamelo_LootItem" .. idx .. "Won"]:Hide()
		end
	end
end

local function ItemsListInit()
	if not _G["Lootamelo_LootFrameBackground"] then
		local frame = CreateFrame("Frame", "Lootamelo_LootFrameBackground", _G["Lootamelo_LootFrame"])
		frame:SetSize(460, 330)
		frame:SetPoint("CENTER", _G["Lootamelo_LootFrame"], "CENTER", 0, -7)
		frame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
	end

	for idx = 1, itemPerPage do
		local lootItem =
			CreateFrame("Frame", "Lootamelo_LootItem" .. idx, _G["Lootamelo_LootFrame"], "Lootamelo_LootItemTemplate")
		lootItem:SetPoint("TOPLEFT", _G["Lootamelo_LootFrame"], "TOPLEFT", 40, -55 - ((idx - 1) * 45))
	end
end

function ns.Loot.LoadFrame(boss, raidName)
	if isFirstLootOpen then
		ItemsListInit()
		isFirstLootOpen = false
	end

	ClearItemsRows()
	local bossName

	if boss then
		bossName = boss
	else
		bossName = LootameloDB.raid.loot.lastBossLooted
	end

	local bossLoot = {}
	if ns.Utils.BossGroups[boss] then
		for _, member in ipairs(ns.Utils.BossGroups[boss]) do
			if LootameloDB.raid.loot.list[member] then
				for itemId, data in pairs(LootameloDB.raid.loot.list[member]) do
					if not bossLoot[itemId] then
						bossLoot[itemId] = {
							rolled = data.rolled and CopyTable(data.rolled) or {},
							won = data.won or "",
							count = data.count or 0,
						}
					else
						bossLoot[itemId].count = bossLoot[itemId].count + (data.count or 0)
					end
				end
			end
		end
	else
		if LootameloDB.raid.loot.list[boss] then
			for itemId, data in pairs(LootameloDB.raid.loot.list[boss]) do
				bossLoot[itemId] = {
					rolled = data.rolled and CopyTable(data.rolled) or {},
					won = data.won or "",
					count = data.count or 0,
				}
			end
		end
	end

	UpdateDropDownMenu(bossName)

	local index = 1
	for itemId, itemData in pairs(bossLoot) do
		local lootItem = _G["Lootamelo_LootItem" .. index]
		local itemIconTexture = _G[lootItem:GetName() .. "ItemIconTexture"]
		local text = _G[lootItem:GetName() .. "Text"]
		local count = _G[lootItem:GetName() .. "Count"]
		local iconReservedButton = _G[lootItem:GetName() .. "ReservedIcon"]
		local iconReservedTexture = _G[lootItem:GetName() .. "ReservedIconTexture"]
		local msButton = _G["Lootamelo_LootItem" .. index .. "MSButton"]
		local osButton = _G["Lootamelo_LootItem" .. index .. "OSButton"]
		local freeButton = _G["Lootamelo_LootItem" .. index .. "FreeButton"]
		_G["Lootamelo_LootItem" .. index .. "ItemIcon"]:Show()
		local wonButton = _G["Lootamelo_LootItem" .. index .. "Won"]
		-- _G["Lootamelo_LootItem" .. index .. "Roll"]:Show();

		local item = ns.Utils.GetItemById(itemId, raidName)

		if itemIconTexture and item then
			itemIconTexture:SetTexture(LOOTAMELO_WOW_ICONS_PATH .. item.icon)
			local itemButton = _G[lootItem:GetName() .. "ItemIcon"]
			ns.Utils.ShowItemTooltip(itemButton, ns.Utils.GetHyperlinkByItemId(itemId, item))
		end

		if text and count then
			if item then
				text:SetText(LOOTAMELO_RARE_ITEM .. item.name or "Unknown Item" .. "|r")
				if itemData.count > 1 then
					count:SetText("x" .. itemData.count)
				end
			end
		end

		local reservedAnnounce = ""

		local reservedData = LootameloDB.raid.reserve[itemId]
		if reservedData then
			reservedAnnounce = ns.Utils.SetReservedIcon(iconReservedButton, iconReservedTexture, reservedData)
		else
			iconReservedButton:Hide()
			iconReservedButton:SetScript("OnEnter", nil)
			iconReservedButton:SetScript("OnLeave", nil)
		end
		if ns.Utils.CanManage() then
			msButton:Show()
			if reservedData then
				msButton:SetText("SR")
			else
				msButton:SetText("MS")
			end
			osButton:Show()
			freeButton:Show()
			msButton:Enable()
			osButton:Enable()
			freeButton:Enable()
			osButton:SetScript("OnClick", function()
				StartRollTimer("OS", itemId, "", item)
			end)
			freeButton:SetScript("OnClick", function()
				StartRollTimer("Free", itemId, "", item)
			end)
			msButton:SetScript("OnClick", function()
				StartRollTimer("MS", itemId, reservedAnnounce, item)
			end)
		end

		if itemData.won ~= "" then
			msButton:Disable()
			osButton:Disable()
			freeButton:Disable()
			wonButton:Show()
			wonButton:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:ClearLines()
				GameTooltip:AddLine(ns.L.WonBy or "Won by:")
				GameTooltip:AddLine(itemData.won)
				GameTooltip:Show()
			end)

			wonButton:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		else
			wonButton:SetScript("OnEnter", nil)
			wonButton:SetScript("OnLeave", nil)
			wonButton:Hide()
		end

		index = index + 1
	end
end
