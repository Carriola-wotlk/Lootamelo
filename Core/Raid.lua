local ns = _G[LOOTAMELO_NAME]
ns.Raid = ns.Raid or {}

local raidPlayerFrame, raidPlayersScrollChild, raidPlayersScrollText
local playerReservedNotInRaidFrame, playerReservedNotInRaidScrollChild, playerReservedNotInRaidScrollText
local itemSelectedFrame, itemSelectedScrollChild, itemSelectedScrollText
local dropDownTitle
local reservedItemTitle, reservedPanelTitle, reservedItemButton

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

		local raidTitle = raidPlayerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		raidTitle:SetPoint("BOTTOM", raidPlayerFrame, "TOP", 0, 5)
		raidTitle:SetText("Raid")
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

		local panelTitle = playerReservedNotInRaidFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		panelTitle:SetPoint("BOTTOM", playerReservedNotInRaidFrame, "TOP", 0, 5)
		panelTitle:SetText("Reserved but Not in Raid")
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
		local text = "Items ( "
			.. LOOTAMELO_RESERVED_COLOR
			.. "reserved|r"
			.. " / "
			.. LOOTAMELO_WHITE_COLOR
			.. "not reserved"
			.. "|r )"
		dropDownTitle:SetText(text)
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
			270,
			"BOTTOM",
			0,
			0
		)
	end

	local resultText = ""

	if not reservedItemTitle then
		reservedItemTitle = itemSelectedFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		reservedItemTitle:SetPoint("BOTTOM", itemSelectedFrame, "TOP", 0, 25)
		reservedPanelTitle = itemSelectedFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		reservedPanelTitle:SetPoint("TOPLEFT", itemSelectedFrame, "TOPLEFT", 8, 15)
		reservedPanelTitle:SetText("Reserved by:")

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
		resultText = "None"
	end

	itemSelectedScrollText:SetText(resultText)
	itemSelectedScrollChild:SetSize(150, itemSelectedScrollText:GetStringHeight())
end

local function OnDropDownClick(self)
	local dropDownButton = _G["Lootamelo_RaidFrameDropDownButton"]

	if self.value == "General" then
		ns.State.raidItemSelected = nil
		ns.Navigation.ToPage("Raid")
		UIDropDownMenu_SetText(dropDownButton, "General")
	else
		local item = ns.Utils.GetItemById(self.value, LootameloDB.raid.name)
		if item then
			ns.State.raidItemSelected = self.value
			ItemSelectedFrame()
			local isReserved = LootameloDB.raid.reserve[self.value]
			local itemName = item.name
			if isReserved then
				itemName = LOOTAMELO_RESERVED_COLOR .. item.name .. "|r"
			end
			UIDropDownMenu_SetText(dropDownButton, itemName)
		end
	end
end

function Lootamelo_RaidFrameInitDropDown(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()

	info.func = OnDropDownClick

	if level == 1 then
		info.text = "General"
		info.value = "General"
		info.hasArrow = false
		UIDropDownMenu_AddButton(info, level)
		for bossName, _ in pairs(ns.Database.items[LootameloDB.raid.name]) do
			info.text = bossName
			info.value = bossName
			info.hasArrow = true
			info.menuList = bossName
			info.func = nil
			UIDropDownMenu_AddButton(info, level)
		end
	elseif level == 2 and menuList then
		local items = ns.Database.items[LootameloDB.raid.name][menuList]
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
end
