local ns = _G[LOOTAMELO_NAME]
ns.Create = ns.Create or {}

local createButton, cancelButton, createTextArea, scrollFrame
local createTitle
local raidInfo

function ns.Create.UpdateTexts()
	if createTitle then
		createTitle:SetText(ns.L.PasteSoftRes or 'Paste SoftRes "WeakAura Data" here:')
	end
	if createButton then
		createButton:SetText(ns.L.Create or "Create")
	end
	if cancelButton then
		cancelButton:SetText(ns.L.Cancel or "Cancel")
	end
end

local function UpdateCreateButtonState()
	local text = createTextArea:GetText()
	if text and text ~= "" then
		createButton:Enable()
	else
		createButton:Disable()
	end
end

local function CreateRun(inputText)
	local data = {}
	local isFirstLine = true
	for line in inputText:gmatch("[^\r\n]+") do
		if isFirstLine and line:match("^ItemId,Name,Class,Note,Plus$") then
			isFirstLine = false
		else
			local itemId, playerName, class, note, plus = line:match("([^,]+),([^,]+),([^,]*),([^,]*),([^,]*)")
			if itemId and playerName then
				itemId = tonumber(itemId)
				if not data[itemId] then
					data[itemId] = {}
				end

				local playerData = data[itemId][playerName]

				if playerData then
					playerData.reserveCount = (playerData.reserveCount or 0) + 1
				else
					data[itemId][playerName] = {
						reserveCount = 1,
					}
				end
			end
		end
		isFirstLine = false
	end

	if not LootameloDB then
		LootameloDB = {}
	end

	LootameloDB.raid = LootameloDB.raid or {}

	LootameloDB.raid.reserve = data or {}
	LootameloDB.raid.loot = { lastBossLooted = nil, list = {} }

	local cr = ns.State.currentRaid or {}
	LootameloDB.raid.info = {
		id = cr.id,
		name = cr.name,
		maxPlayers = cr.maxPlayers,
		difficultyIndex = cr.difficultyIndex,
		difficultyName = cr.difficultyName,
	}

	ns.Navigation.ToPage("Raid")
	ns.State.currentPage = "Raid"
	ns.Raid.LoadFrame()
end

function ns.Create.LoadFrame()
	local createFrame = _G["Lootamelo_CreateFrame"]

	if not raidInfo then
		raidInfo = _G["Lootamelo_CreateFrame"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		raidInfo:SetPoint("TOPLEFT", _G["Lootamelo_CreateFrame"], "TOPLEFT", 55, -20)
		local cr = ns.State.currentRaid or {}
		local name = cr.name or ""
		local maxp = cr.maxPlayers or ""
		local diff = cr.difficultyName or ""
		raidInfo:SetText(string.format("%s %s players - %s", name, maxp, diff))
	end

	if not createTitle then
		createTitle = _G["Lootamelo_CreateFrame"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		createTitle:SetPoint("TOPLEFT", _G["Lootamelo_CreateFrame"], "TOPLEFT", 55, -70)
		createTitle:SetText(ns.L.PasteSoftRes)
	end

	if not scrollFrame then
		scrollFrame = CreateFrame(
			"ScrollFrame",
			"Lootamelo_CreateFrameTextAreaScollFrame",
			createFrame,
			"UIPanelScrollFrameTemplate"
		)
		createTextArea = CreateFrame("EditBox", "Lootamelo_CreateFrameTextArea", scrollFrame)
		scrollFrame:SetSize(400, 230)
		scrollFrame:SetPoint("CENTER", createFrame, "CENTER", 0, -5)
		createTextArea:SetMultiLine(true)
		createTextArea:SetAutoFocus(true)
		createTextArea:SetSize(285, 230)
		createTextArea:SetFontObject(GameFontHighlight)
		scrollFrame:SetScrollChild(createTextArea)

		scrollFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			insets = { left = -8, right = 0, top = -8, bottom = -8 },
		})

		createButton = CreateFrame("Button", "Lootamelo_CreateFrameCreateButton", createFrame, "UIPanelButtonTemplate")
		createButton:SetPoint("BOTTOMRIGHT", createFrame, "BOTTOMRIGHT", -50, 30)
		createButton:SetSize(100, 30)
		createButton:Disable()

		cancelButton = CreateFrame("Button", "Lootamelo_CreateFrameCancelButton", createFrame, "UIPanelButtonTemplate")
		cancelButton:SetPoint("BOTTOMRIGHT", createFrame, "BOTTOMRIGHT", -150, 30)
		cancelButton:SetSize(100, 30)
	end

	ns.Create.UpdateTexts()

	createTextArea:SetScript("OnTextChanged", function(self)
		UpdateCreateButtonState()

		local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
		if scrollBar then
			local scrollMax = scrollBar:GetMinMaxValues()
			local currentScroll = scrollBar:GetValue()

			if currentScroll >= scrollMax then
				scrollFrame:SetVerticalScroll(scrollMax)
			end
		end
	end)

	createTextArea:SetScript("OnEscapePressed", function(self)
		self:ClearFocus() -- Rimuove il focus premendo Esc
	end)

	createButton:SetScript("OnClick", function()
		CreateRun(createTextArea:GetText())
	end)

	cancelButton:SetScript("OnClick", function()
		ns.Navigation.ToPage("Raid")
	end)
end
