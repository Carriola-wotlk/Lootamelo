local ns = _G[LOOTAMELO_NAME]
ns.Navigation = ns.Navigation or {}

local navButtonSettings, navButtonRaid, navButtonLoot, navButtonCreate
local navButtonSettingsTexture, navButtonRaidTexture, navButtonLootTexture
local pressTexture, normalTexture
local isFirstOpen = true

function ns.Navigation.UpdateTexts()
	if navButtonSettings then
		_G[navButtonSettings:GetName() .. "Text"]:SetText(ns.L.Settings or "Settings")
	end
	if navButtonRaid then
		_G[navButtonRaid:GetName() .. "Text"]:SetText(ns.L.Raid or "Raid")
	end
	if navButtonLoot then
		_G[navButtonLoot:GetName() .. "Text"]:SetText(ns.L.Loot or "Loot")
	end
	if navButtonCreate then
		_G[navButtonCreate:GetName() .. "Text"]:SetText(ns.L.NewRun or "New run")
	end

	local versionLabel = _G["Lootamelo_Addon_Version"]
	if versionLabel then
		versionLabel:SetText(ns.L.AddonBy or "by Carriola - La Fratellanza guild (ChromieCraft server)")
	end
end

local function NavButtonManaged(isCreatePage)
	if isCreatePage then
		if navButtonRaid and navButtonRaid:IsShown() then
			navButtonRaid:Hide()
		end

		if navButtonLoot and navButtonLoot:IsShown() then
			navButtonLoot:Hide()
		end

		if navButtonSettings and navButtonSettings:IsShown() then
			navButtonSettings:Hide()
		end

		if navButtonCreate and navButtonCreate:IsShown() then
			navButtonCreate:Hide()
		end
	else
		if navButtonRaid and not navButtonRaid:IsShown() then
			navButtonRaid:Show()
		end

		if navButtonLoot and not navButtonLoot:IsShown() then
			navButtonLoot:Show()
		end

		if navButtonSettings and not navButtonSettings:IsShown() then
			navButtonSettings:Show()
		end

		if navButtonCreate and not navButtonCreate:IsShown() then
			navButtonCreate:Show()
		end
	end
end

local function ShowRaidPage()
	ns.State.currentPage = "Raid"
	if navButtonRaidTexture and navButtonLootTexture and navButtonSettingsTexture then
		navButtonRaidTexture:SetTexture(pressTexture)
		navButtonSettingsTexture:SetTexture(normalTexture)
		navButtonLootTexture:SetTexture(normalTexture)

		NavButtonManaged(false)

		if _G["Lootamelo_SettingsFrame"] then
			_G["Lootamelo_SettingsFrame"]:Hide()
		end

		if _G["Lootamelo_LootFrame"] then
			_G["Lootamelo_LootFrame"]:Hide()
		end

		if _G["Lootamelo_CreateFrame"] then
			_G["Lootamelo_CreateFrame"]:Hide()
		end

		_G["Lootamelo_RaidFrame"]:Show()

		if ns.State.raidItemSelected then
			if _G["Lootamelo_RaidFrameGeneral"] then
				_G["Lootamelo_RaidFrameGeneral"]:Hide()
			end
			_G["Lootamelo_RaidFrameItemSelected"]:Show()
		else
			if _G["Lootamelo_RaidFrameItemSelected"] then
				_G["Lootamelo_RaidFrameItemSelected"]:Hide()
			end
			_G["Lootamelo_RaidFrameGeneral"]:Show()
		end
	end
end

local function ShowSettingsPage()
	ns.State.currentPage = "Settings"
	if navButtonRaidTexture and navButtonLootTexture and navButtonSettingsTexture then
		navButtonRaidTexture:SetTexture(normalTexture)
		navButtonSettingsTexture:SetTexture(pressTexture)
		navButtonLootTexture:SetTexture(normalTexture)

		NavButtonManaged(false)

		if _G["Lootamelo_RaidFrame"] then
			_G["Lootamelo_RaidFrame"]:Hide()
		end

		if _G["Lootamelo_CreateFrame"] then
			_G["Lootamelo_CreateFrame"]:Hide()
		end

		if _G["Lootamelo_LootFrame"] then
			_G["Lootamelo_LootFrame"]:Hide()
		end

		_G["Lootamelo_SettingsFrame"]:Show()
	end
end

local function ShowLootPage()
	ns.State.currentPage = "Loot"
	if navButtonRaidTexture and navButtonLootTexture and navButtonSettingsTexture then
		navButtonRaidTexture:SetTexture(normalTexture)
		navButtonSettingsTexture:SetTexture(normalTexture)
		navButtonLootTexture:SetTexture(pressTexture)

		NavButtonManaged(false)

		if _G["Lootamelo_RaidFrame"] then
			_G["Lootamelo_RaidFrame"]:Hide()
		end

		if _G["Lootamelo_CreateFrame"] then
			_G["Lootamelo_CreateFrame"]:Hide()
		end

		if _G["Lootamelo_SettingsFrame"] then
			_G["Lootamelo_SettingsFrame"]:Hide()
		end

		_G["Lootamelo_LootFrame"]:Show()
	end
end

local function ShowCreatePage()
	ns.State.currentPage = "Create"

	NavButtonManaged(true)

	if _G["Lootamelo_RaidFrame"] then
		_G["Lootamelo_RaidFrame"]:Hide()
	end

	if _G["Lootamelo_LootFrame"] then
		_G["Lootamelo_LootFrame"]:Hide()
	end

	if _G["Lootamelo_SettingsFrame"] then
		_G["Lootamelo_SettingsFrame"]:Hide()
	end

	_G["Lootamelo_CreateFrame"]:Show()
end

local function NavButtonsInit()
	local pages = { "Settings", "Raid", "Loot" }
	local navButton, buttonText
	for index, pageKey in ipairs(pages) do
		navButton = CreateFrame(
			"Button",
			"Lootamelo_NavButton" .. pageKey,
			_G["Lootamelo_MainFrame"],
			"Lootamelo_NavButtonTemplate"
		)
		buttonText = _G[navButton:GetName() .. "Text"]
		if buttonText then
			buttonText:SetText(ns.L[pageKey] or pageKey)
		end
		navButton:SetPoint("TOPLEFT", _G["Lootamelo_MainFrame"], "TOPLEFT", 90 + ((index - 1) * 128), -40)
	end

	navButtonCreate = _G["Lootamelo_MainFrameNewRunButton"]
	navButtonSettings = _G["Lootamelo_NavButtonSettings"]
	navButtonRaid = _G["Lootamelo_NavButtonRaid"]
	navButtonLoot = _G["Lootamelo_NavButtonLoot"]

	pressTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-press]]
	normalTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-normal]]

	if navButtonSettings then
		navButtonSettingsTexture = _G[navButtonSettings:GetName() .. "NormalTexture"]
	end
	if navButtonRaid then
		navButtonRaidTexture = _G[navButtonRaid:GetName() .. "NormalTexture"]
	end
	if navButtonLoot then
		navButtonLootTexture = _G[navButtonLoot:GetName() .. "NormalTexture"]
	end
end

local pagesSwitch = {
	Settings = ShowSettingsPage,
	Raid = ShowRaidPage,
	Loot = ShowLootPage,
	Create = ShowCreatePage,
}

function ns.Navigation.CloseMainFrame()
	if _G["Lootamelo_MainFrame"] then
		_G["Lootamelo_MainFrame"]:Hide()
	end
end

function ns.Navigation.MainFrameToggle(page)
	if _G["Lootamelo_MainFrame"] and _G["Lootamelo_MainFrame"]:IsShown() then
		ns.Navigation.CloseMainFrame()
	else
		ns.Navigation.ToPage(page)
	end
end

function ns.Navigation.ToPage(page)
	ns.State.currentPage = page
	if not _G["Lootamelo_MainFrame"]:IsShown() then
		_G["Lootamelo_MainFrame"]:Show()
	end
	if isFirstOpen then
		NavButtonsInit()
		ns.Navigation.UpdateTexts()
		isFirstOpen = false
	end

	if pagesSwitch[page] then
		pagesSwitch[page]()
	else
		print("Page not found")
	end
end

-- globals wrapper for xml files --
function Lootamelo_CloseMainFrame()
	ns.Navigation.CloseMainFrame()
end
