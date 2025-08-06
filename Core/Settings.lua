local ns = _G[LOOTAMELO_NAME]
ns.Settings = ns.Settings or {}

local settingsButton, cancelButton, settingsGeneralTitle, settingsMasterLootTitle
local langDropDown, langTitle
local timerDropDown, timerTitle, timerLabel

function ns.Settings.UpdateTexts()
	local elements = {
		{ settingsGeneralTitle, ns.L.SettingsGeneral },
		{ settingsMasterLootTitle, ns.L.SettingsMasterLooterTitle },
		{ settingsButton, ns.L.Save },
		{ cancelButton, ns.L.Cancel },
		{ langTitle, ns.L.Language },
		{ timerTitle, ns.L.RollCountdown },
		{ timerLabel, ns.L.Seconds },
	}

	for _, pair in ipairs(elements) do
		local element, text = pair[1], pair[2]
		if element and text then
			element:SetText(text)
		end
	end

	if langDropDown then
		local langText = LootameloDB.settings.language == "itIT" and "Italiano" or "English"
		UIDropDownMenu_SetText(langDropDown, langText)
	end

	if timerDropDown then
		UIDropDownMenu_SetText(timerDropDown, tostring(LootameloDB.settings.rollCountdown))
	end
end

function ns.ChangeLanguage(code)
	LootameloDB.settings = LootameloDB.settings or {}
	LootameloDB.settings.language = code
	ns.L = ns.translations[code] or ns.translations["enUS"]
	if ns.Navigation and ns.Navigation.UpdateTexts then
		ns.Navigation.UpdateTexts()
	end
	if ns.Settings and ns.Settings.UpdateTexts then
		ns.Settings.UpdateTexts()
	end
	if ns.Create and ns.Create.UpdateTexts then
		ns.Create.UpdateTexts()
	end

	if ns.Raid and ns.Raid.UpdateTexts then
		ns.Raid.UpdateTexts()
	end
end

local function InitLanguageDropDown(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	local availableLocales = {
		{ code = "enUS", label = "English" },
		{ code = "itIT", label = "Italiano" },
	}
	for _, localeData in ipairs(availableLocales) do
		info.text = localeData.label
		info.checked = (LootameloDB.settings.language == localeData.code)
		info.func = function()
			ns.ChangeLanguage(localeData.code)
			ns.Settings.UpdateTexts()
		end
		UIDropDownMenu_AddButton(info)
	end
end

local function InitTimerDropDown(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	local timerValues = { 10, 15, 20 }
	for _, val in ipairs(timerValues) do
		info.text = tostring(val)
		info.checked = (LootameloDB.settings.rollCountdown == val)
		info.func = function()
			LootameloDB.settings.rollCountdown = val
			ns.Settings.UpdateTexts()
		end
		UIDropDownMenu_AddButton(info)
	end
end

function ns.Settings.LoadFrame()
	local settingsFrame = _G["Lootamelo_SettingsFrame"]

	if not settingsGeneralTitle then
		settingsGeneralTitle = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		settingsGeneralTitle:SetPoint("TOPLEFT", 50, -30)
	end

	-- Titolo Lingua
	if not langTitle then
		langTitle = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		langTitle:SetPoint("TOPLEFT", settingsGeneralTitle, "BOTTOMLEFT", 20, -15)
	end

	-- Dropdown Lingua
	if not langDropDown then
		langDropDown =
			CreateFrame("Frame", "Lootamelo_SettingsLanguageDropDown", settingsFrame, "UIDropDownMenuTemplate")
		langDropDown:SetPoint("LEFT", langTitle, "RIGHT", -5, -3)
		UIDropDownMenu_SetWidth(langDropDown, 100)
		UIDropDownMenu_Initialize(langDropDown, InitLanguageDropDown)
	end
	if not settingsMasterLootTitle then
		settingsMasterLootTitle = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		settingsMasterLootTitle:SetPoint("TOPLEFT", settingsGeneralTitle, "BOTTOMLEFT", 0, -70)
	end

	-- Titolo Timer
	if not timerTitle then
		timerTitle = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		timerTitle:SetPoint("TOPLEFT", settingsMasterLootTitle, "BOTTOMLEFT", 20, -15)
	end

	-- Dropdown Timer
	if not timerDropDown then
		timerDropDown = CreateFrame("Frame", "Lootamelo_SettingsTimerDropDown", settingsFrame, "UIDropDownMenuTemplate")
		timerDropDown:SetPoint("LEFT", timerTitle, "RIGHT", -5, -3)
		UIDropDownMenu_SetWidth(timerDropDown, 60)
		UIDropDownMenu_Initialize(timerDropDown, InitTimerDropDown)
	end

	-- Label "secondi"
	if not timerLabel then
		timerLabel = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		timerLabel:SetPoint("LEFT", timerDropDown, "RIGHT", -5, 4)
	end

	ns.Settings.UpdateTexts()
end
