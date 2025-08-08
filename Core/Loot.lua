local ns = _G[LOOTAMELO_NAME]
ns.Loot = ns.Loot or {}

local countdownTimer
local isFirstLootOpen = true
local MAX_UI_ROWS = 7
local itemPerPage = 2
local currentRaidNameForLoot
local currentPage = 1

local AceTimer = LibStub("AceTimer-3.0")
local AceComm = LibStub("AceComm-3.0")

function ns.Loot.HandleLootInfoMessage(data)
	local bossName, rest = strsplit(";", data, 2)

	print("HandleLootInfoMessage")
	print(bossName)
	print(rest)
	if not bossName or not rest then
		return
	end

	local newLoot = {}
	currentPage = 1

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
				currentPage = 1
				ns.Loot.LoadFrame(displayName, ns.State.currentRaid.name)
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
	for idx = 1, MAX_UI_ROWS do
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
		frame:SetSize(460, 360)
		frame:SetPoint("CENTER", _G["Lootamelo_LootFrame"], "CENTER", 0, -20)
		frame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
	end
	if not _G["Lootamelo_LootPrevPage"] then
		local prev = CreateFrame("Button", "Lootamelo_LootPrevPage", _G["Lootamelo_LootFrame"], "UIPanelButtonTemplate")
		prev:SetSize(60, 22)
		prev:SetPoint("BOTTOMLEFT", _G["Lootamelo_LootFrame"], "BOTTOMLEFT", 40, 18)
		prev:SetText("<")
		prev:SetScript("OnClick", function()
			currentPage = math.max(1, currentPage - 1)
			ns.Loot.LoadFrame(LootameloDB.raid.loot.lastBossLooted, currentRaidNameForLoot)
		end)

		local nextb =
			CreateFrame("Button", "Lootamelo_LootNextPage", _G["Lootamelo_LootFrame"], "UIPanelButtonTemplate")
		nextb:SetSize(60, 22)
		nextb:SetPoint("BOTTOMRIGHT", _G["Lootamelo_LootFrame"], "BOTTOMRIGHT", -40, 18)
		nextb:SetText(">")
		nextb:SetScript("OnClick", function()
			currentPage = currentPage + 1
			ns.Loot.LoadFrame(LootameloDB.raid.loot.lastBossLooted, currentRaidNameForLoot)
		end)

		local label = _G["Lootamelo_LootPageLabel"]
			or _G["Lootamelo_LootFrame"]:CreateFontString("Lootamelo_LootPageLabel", "ARTWORK", "GameFontNormal")
		label:SetPoint("BOTTOM", _G["Lootamelo_LootFrame"], "BOTTOM", 0, 20)
		label:SetText("")
	end

	for idx = 1, MAX_UI_ROWS do
		if not _G["Lootamelo_LootItem" .. idx] then
			local lootItem = CreateFrame(
				"Frame",
				"Lootamelo_LootItem" .. idx,
				_G["Lootamelo_LootFrame"],
				"Lootamelo_LootItemTemplate"
			)
			lootItem:SetPoint("TOPLEFT", _G["Lootamelo_LootFrame"], "TOPLEFT", 40, -55 - ((idx - 1) * 45))
		end
	end
end

function ns.Loot.LoadFrame(boss, raidName)
	if isFirstLootOpen then
		ItemsListInit()
		isFirstLootOpen = false
	end

	ClearItemsRows()

	local bossName = boss or LootameloDB.raid.loot.lastBossLooted
	currentRaidNameForLoot = raidName

	-- costruisci la mappa loot per il boss o gruppo
	local bossLoot = {}
	if ns.Utils.BossGroups[bossName] then
		for _, member in ipairs(ns.Utils.BossGroups[bossName]) do
			local list = LootameloDB.raid.loot.list[member]
			if list then
				for itemId, data in pairs(list) do
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
		local list = LootameloDB.raid.loot.list[bossName]
		if list then
			for itemId, data in pairs(list) do
				bossLoot[itemId] = {
					rolled = data.rolled and CopyTable(data.rolled) or {},
					won = data.won or "",
					count = data.count or 0,
				}
			end
		end
	end

	UpdateDropDownMenu(bossName)

	-- crea lista ordinata deterministica
	local itemIds = {}
	for itemId in pairs(bossLoot) do
		table.insert(itemIds, itemId)
	end
	table.sort(itemIds, function(a, b)
		local ia = ns.Utils.GetItemById(a, raidName)
		local ib = ns.Utils.GetItemById(b, raidName)
		local na = ia and ia.name or tostring(a)
		local nb = ib and ib.name or tostring(b)
		if na == nb then
			return a < b
		end
		return na < nb
	end)

	local totalItems = #itemIds
	local totalPages = math.max(1, math.ceil(totalItems / itemPerPage))

	-- clamp pagina corrente
	if currentPage > totalPages then
		currentPage = totalPages
	end
	if currentPage < 1 then
		currentPage = 1
	end

	-- UI paginazione
	local pageLabel = _G["Lootamelo_LootPageLabel"]
	if pageLabel then
		pageLabel:SetText(currentPage .. " / " .. totalPages)
	end
	local prevBtn = _G["Lootamelo_LootPrevPage"]
	local nextBtn = _G["Lootamelo_LootNextPage"]
	if prevBtn then
		if currentPage <= 1 then
			prevBtn:Disable()
		else
			prevBtn:Enable()
		end
	end
	if nextBtn then
		if currentPage >= totalPages then
			nextBtn:Disable()
		else
			nextBtn:Enable()
		end
	end

	-- range pagina
	local startIndex = (currentPage - 1) * itemPerPage + 1
	local endIndex = math.min(startIndex + itemPerPage - 1, totalItems)

	-- non mostro più righe di quante ne esistono fisicamente
	local rowsToShow = math.min(itemPerPage, MAX_UI_ROWS)

	-- popola righe visibili della pagina
	for row = 1, rowsToShow do
		local i = startIndex + (row - 1)
		local lootItem = _G["Lootamelo_LootItem" .. row]
		if not lootItem then
			break
		end

		if i <= endIndex then
			local itemId = itemIds[i]
			local itemData = bossLoot[itemId]

			lootItem:Show()

			local iconTex = _G[lootItem:GetName() .. "ItemIconTexture"]
			local text = _G[lootItem:GetName() .. "Text"]
			local count = _G[lootItem:GetName() .. "Count"]
			local iconReservedButton = _G[lootItem:GetName() .. "ReservedIcon"]
			local iconReservedTexture = _G[lootItem:GetName() .. "ReservedIconTexture"]
			local msButton = _G["Lootamelo_LootItem" .. row .. "MSButton"]
			local osButton = _G["Lootamelo_LootItem" .. row .. "OSButton"]
			local freeButton = _G["Lootamelo_LootItem" .. row .. "FreeButton"]
			local itemBtn = _G[lootItem:GetName() .. "ItemIcon"]
			local wonButton = _G["Lootamelo_LootItem" .. row .. "Won"]

			if itemBtn then
				itemBtn:Show()
			end

			local item = ns.Utils.GetItemById(itemId, raidName)

			if iconTex and item then
				iconTex:SetTexture(LOOTAMELO_WOW_ICONS_PATH .. item.icon)
				ns.Utils.ShowItemTooltip(itemBtn, ns.Utils.GetHyperlinkByItemId(itemId, item))
			end

			if text and count and item then
				text:SetText(LOOTAMELO_RARE_ITEM .. (item.name or "Unknown Item") .. "|r")
				if (itemData.count or 0) > 1 then
					count:SetText("x" .. itemData.count)
				else
					count:SetText(nil)
				end
			end

			-- reserved icon + tooltip
			local reservedAnnounce = ""
			local reservedData = LootameloDB.raid.reserve and LootameloDB.raid.reserve[itemId]
			if reservedData then
				reservedAnnounce = ns.Utils.SetReservedIcon(iconReservedButton, iconReservedTexture, reservedData)
			else
				if iconReservedButton then
					iconReservedButton:Hide()
					iconReservedButton:SetScript("OnEnter", nil)
					iconReservedButton:SetScript("OnLeave", nil)
				end
			end

			-- bottoni azione
			if ns.Utils.CanManage() then
				if msButton then
					msButton:Show()
					msButton:SetText(reservedData and "SR" or "MS")
					msButton:Enable()
					msButton:SetScript("OnClick", function()
						StartRollTimer("MS", itemId, reservedAnnounce, item)
					end)
				end
				if osButton then
					osButton:Show()
					osButton:Enable()
					osButton:SetScript("OnClick", function()
						StartRollTimer("OS", itemId, "", item)
					end)
				end
				if freeButton then
					freeButton:Show()
					freeButton:Enable()
					freeButton:SetScript("OnClick", function()
						StartRollTimer("Free", itemId, "", item)
					end)
				end
			end

			-- stato "won"
			if itemData.won ~= "" then
				if msButton then
					msButton:Disable()
				end
				if osButton then
					osButton:Disable()
				end
				if freeButton then
					freeButton:Disable()
				end
				if wonButton then
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
				end
			else
				if wonButton then
					wonButton:SetScript("OnEnter", nil)
					wonButton:SetScript("OnLeave", nil)
					wonButton:Hide()
				end
			end
		else
			lootItem:Hide()
		end
	end

	-- nascondo eventuali righe UI oltre rowsToShow (se esistono nel template)
	for row = rowsToShow + 1, MAX_UI_ROWS do
		local lootItem = _G["Lootamelo_LootItem" .. row]
		if lootItem then
			lootItem:Hide()
		end
	end
end
