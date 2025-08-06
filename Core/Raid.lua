local ns = _G[LOOTAMELO_NAME]
ns.Raid = ns.Raid or {}

local raidPlayerFrame, raidPlayersScrollChild, raidPlayersScrollText
local playerReservedNotInRaidFrame, playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText
local itemSelectedFrame, itemSelectedScrollChild, itemSelectedScrollText
local dropDownTitle
local reservedItemTitle, reservedPanelTitle, reservedItemButton, inRaidTitle, inRaidSubtitle, notInRaidTitle
local reservedItemIcon, reservedItemIconTexture

function ns.Raid.UpdateTexts()
	if inRaidTitle then
		inRaidTitle:SetText(ns.L.InRaid)
	end

	if inRaidSubtitle then
		local textInRaid = " ( "
			.. LOOTAMELO_RESERVED_COLOR
			.. ns.L.Reserved
			.. "|r"
			.. " / "
			.. LOOTAMELO_WHITE_COLOR
			.. ns.L.NotReserved
			.. "|r )"
		inRaidSubtitle:SetText(textInRaid)
	end

	if notInRaidTitle then
		notInRaidTitle:SetText(ns.L.ReservedNotInRaid)
	end

	if dropDownTitle then
		local text = ns.L.Items
			.. " ( "
			.. LOOTAMELO_RESERVED_COLOR
			.. ns.L.Reserved
			.. "|r"
			.. " / "
			.. LOOTAMELO_WHITE_COLOR
			.. ns.L.NotReserved
			.. "|r )"
		dropDownTitle:SetText(text)
	end

	if reservedPanelTitle then
		reservedPanelTitle:SetText(ns.L.ReservedBy .. ":")
	end

	if ns.State.raidItemSelected == nil then
		local dropDownButton = _G["Lootamelo_RaidFrameDropDownButton"]
		if dropDownButton then
			UIDropDownMenu_SetText(dropDownButton, ns.L.General)
		end
	end
end

local function RaidPlayersList(mergedPlayers)
	if not raidPlayerFrame then
		raidPlayerFrame, raidPlayersScrollChild, raidPlayersScrollText = ns.Utils.CreateScrollableFrame(
			_G["Lootamelo_RaidFrameGeneral"],
			"Lootamelo_RaidFrameGeneralRaid",
			200,
			290,
			"BOTTOMLEFT",
			45,
			0
		)

		inRaidTitle = raidPlayerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		inRaidTitle:SetPoint("BOTTOM", raidPlayerFrame, "TOP", 0, 5)

		inRaidSubtitle = raidPlayerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		inRaidSubtitle:SetPoint("TOP", raidPlayerFrame, "BOTTOM", 0, -2)
	end

	local resultText = ""
	for playerName, condition in pairs(mergedPlayers) do
		if condition.raid then
			if condition.reserve then
				resultText = resultText .. LOOTAMELO_RESERVED_COLOR .. playerName .. "|r\n"
			else
				resultText = resultText .. LOOTAMELO_WHITE_COLOR .. playerName .. "|r\n"
			end
		end
	end

	raidPlayersScrollText:SetText(resultText)
	raidPlayersScrollChild:SetSize(150, raidPlayersScrollText:GetStringHeight())
end

local function PlayerReservedNotInRaidList(mergedPlayers)
	if not playerReservedNotInRaidFrame then
		playerReservedNotInRaidFrame, playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText =
			ns.Utils.CreateScrollableFrame(
				_G["Lootamelo_RaidFrameGeneral"],
				"Lootamelo_RaidFrameGeneralNotInRaid",
				200,
				290,
				"BOTTOMRIGHT",
				-45,
				0
			)

		notInRaidTitle = playerReservedNotInRaidFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		notInRaidTitle:SetPoint("BOTTOM", playerReservedNotInRaidFrame, "TOP", 0, 5)
	end

	local resultText = ""
	for playerName, condition in pairs(mergedPlayers) do
		if not condition.raid then
			resultText = resultText .. LOOTAMELO_OFFLINE_COLOR .. playerName .. "|r\n"
		end
	end

	playerReservedNotInRaidScrollText:SetText(nil)
	playerReservedNotInRaidScrollText:SetText(resultText)
	playerReservedNotInRaidScrollChild:SetSize(150, playerReservedNotInRaidScrollText:GetStringHeight())
end

local function GeneralFrame()
	local raidPlayers = {}
	for i = 1, MAX_RAID_MEMBERS do
		local name = GetRaidRosterInfo(i)
		if name then
			raidPlayers[name] = true
		end
	end

	if not dropDownTitle then
		dropDownTitle = _G["Lootamelo_RaidFrame"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		dropDownTitle:SetPoint("TOPRIGHT", _G["Lootamelo_RaidFrame"], "TOPRIGHT", -45, -15)
	end

	local reservedPlayers = {}
	for _, itemData in pairs(LootameloDB.raid.reserve) do
		for playerName in pairs(itemData) do
			reservedPlayers[playerName] = true
		end
	end

	local mergedPlayers = {}
	for playerName in pairs(reservedPlayers) do
		if raidPlayers[playerName] then
			mergedPlayers[playerName] = { raid = true, reserve = true }
		else
			mergedPlayers[playerName] = { raid = false, reserve = true }
		end
	end

	for playerName in pairs(raidPlayers) do
		if not mergedPlayers[playerName] then
			mergedPlayers[playerName] = { raid = true, reserve = false }
		end
	end

	PlayerReservedNotInRaidList(mergedPlayers)
	RaidPlayersList(mergedPlayers)
end

local function ItemSelectedFrame()
	_G["Lootamelo_RaidFrameItemSelected"]:Show()
	_G["Lootamelo_RaidFrameGeneral"]:Hide()

	if not itemSelectedFrame then
		itemSelectedFrame, itemSelectedScrollChild, itemSelectedScrollText = ns.Utils.CreateScrollableFrame(
			_G["Lootamelo_RaidFrameItemSelected"],
			"Lootamelo_RaidFrameItemSelected",
			420,
			250,
			"BOTTOM",
			0,
			0
		)
	end

	local resultText = ""

	if not reservedItemTitle then
		reservedItemTitle = itemSelectedFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		reservedItemTitle:SetPoint("TOPLEFT", itemSelectedFrame, "TOPLEFT", 45, 48)

		-- Icona oggetto
		reservedItemIcon = CreateFrame("Button", "ReservedItemIcon", itemSelectedFrame)
		reservedItemIcon:SetSize(32, 32)
		reservedItemIcon:SetPoint("RIGHT", reservedItemTitle, "LEFT", -8, 0)
		reservedItemIconTexture = reservedItemIcon:CreateTexture(nil, "BACKGROUND")
		reservedItemIconTexture:SetAllPoints(reservedItemIcon)

		reservedPanelTitle = itemSelectedFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		reservedPanelTitle:SetPoint("TOPLEFT", itemSelectedFrame, "TOPLEFT", 8, 15)
		reservedPanelTitle:SetText(ns.L.ReservedBy .. ":")

		reservedItemButton = CreateFrame("Button", "ReservedItemTooltipButton", itemSelectedFrame)
		reservedItemButton:SetPoint("CENTER", reservedItemTitle, "CENTER")
	end

	local item = ns.Utils.GetItemById(ns.State.raidItemSelected, LootameloDB.raid.name)
	local itemLink = ns.Utils.GetHyperlinkByItemId(ns.State.raidItemSelected, item)
	reservedItemTitle:SetText(itemLink)
	reservedItemButton:SetSize(reservedItemTitle:GetStringWidth(), 25)

	ns.Utils.ShowItemTooltip(reservedItemButton, itemLink)

	if LootameloDB.raid.reserve[ns.State.raidItemSelected] then
		for playerName, data in pairs(LootameloDB.raid.reserve[ns.State.raidItemSelected]) do
			resultText = resultText
				.. ns.Utils.GetClassColor(data["class"])
				.. playerName
				.. "  x"
				.. data.reserveCount
				.. "|r\n"
		end
	else
		resultText = ns.L.None
	end

	itemSelectedScrollText:SetText(resultText)
	itemSelectedScrollChild:SetSize(150, itemSelectedScrollText:GetStringHeight())
end

local function OnDropDownClick(self)
	local dropDownButton = _G["Lootamelo_RaidFrameDropDownButton"]

	if self.value == "General" then
		ns.State.raidItemSelected = nil
		ns.Navigation.ToPage("Raid")
		UIDropDownMenu_SetText(dropDownButton, ns.L.General)
	elseif type(self.value) == "number" then
		local item = ns.Utils.GetItemById(self.value, LootameloDB.raid.name)

		if item then
			ns.State.raidItemSelected = self.value
			local itemLink = ns.Utils.GetHyperlinkByItemId(ns.State.raidItemSelected, item)
			ItemSelectedFrame()
			local isReserved = LootameloDB.raid.reserve[self.value]
			local itemName = item.name
			if isReserved then
				itemName = LOOTAMELO_RESERVED_COLOR .. item.name .. "|r"
			end
			UIDropDownMenu_SetText(dropDownButton, itemName)

			if item.icon then
				reservedItemIconTexture:SetTexture(LOOTAMELO_WOW_ICONS_PATH .. item.icon)
				ns.Utils.ShowItemTooltip(reservedItemIcon, itemLink)
			else
				reservedItemIconTexture:SetTexture(nil)
				reservedItemIcon:SetScript("OnEnter", nil)
				reservedItemIcon:SetScript("OnLeave", nil)
			end
		end
	else
		local displayName = self.value
		local items = {}

		if ns.Utils.BossGroups[displayName] then
			for _, member in ipairs(ns.Utils.BossGroups[displayName]) do
				if ns.Database.items[LootameloDB.raid.name][member] then
					for itemId, itemData in pairs(ns.Database.items[LootameloDB.raid.name][member]) do
						items[itemId] = itemData
					end
				end
			end
		else
			items = ns.Database.items[LootameloDB.raid.name][displayName] or {}
		end

		UIDropDownMenu_SetText(dropDownButton, displayName)

		local level = 2
		local info = UIDropDownMenu_CreateInfo()
		info.func = OnDropDownClick
		for itemId, item in pairs(items) do
			local isReserved = LootameloDB.raid.reserve[itemId]
			local itemName = item.name
			if isReserved then
				itemName = LOOTAMELO_RESERVED_COLOR .. item.name .. "|r"
			end
			info.text = itemName
			info.value = itemId
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

function Lootamelo_RaidFrameInitDropDown(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.func = OnDropDownClick

	if level == 1 then
		info.text = ns.L.General
		info.value = "General"
		info.hasArrow = false
		UIDropDownMenu_AddButton(info, level)

		local addedNames = {}

		for bossName, _ in pairs(ns.Database.items[LootameloDB.raid.name]) do
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
				info.text = displayName
				info.value = displayName
				info.hasArrow = true
				info.menuList = displayName
				info.func = nil
				UIDropDownMenu_AddButton(info, level)
			end
		end
	elseif level == 2 and menuList then
		local items = {}
		if ns.Utils.BossGroups[menuList] then
			for _, member in ipairs(ns.Utils.BossGroups[menuList]) do
				if ns.Database.items[LootameloDB.raid.name][member] then
					for itemId, itemData in pairs(ns.Database.items[LootameloDB.raid.name][member]) do
						items[itemId] = itemData
					end
				end
			end
		else
			items = ns.Database.items[LootameloDB.raid.name][menuList] or {}
		end

		for itemId, item in pairs(items) do
			local isReserved = LootameloDB.raid.reserve[itemId]
			local itemName = item.name
			if isReserved then
				itemName = LOOTAMELO_RESERVED_COLOR .. item.name .. "|r"
			end
			info.text = itemName
			info.value = itemId
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

function ns.Raid.LoadFrame()
	if ns.State.raidItemSelected then
		ItemSelectedFrame()
	else
		GeneralFrame()
	end

	ns.Raid.UpdateTexts()
end
