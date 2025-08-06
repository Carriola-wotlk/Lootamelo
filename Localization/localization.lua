local ns = _G[LOOTAMELO_NAME]
ns.L = ns.L or {}

LootameloDB = LootameloDB or {}
LootameloDB.settings = LootameloDB.settings or {}
LootameloDB.settings.language = LootameloDB.settings.language or GetLocale()

ns.translations = {
	enUS = {
		Create = "Create",
		NewRun = "New run",
		Cancel = "Cancel",
		Settings = "Settings",
		Save = "Save",
		PasteSoftRes = 'Paste SoftRes "WeakAura Data" here:',
		Language = "Language",
		Raid = "Raid",
		Loot = "Loot",

		--settings
		SettingsGeneral = "General",
		SettingsMasterLooterTitle = "Master Looter",
		Seconds = "seconds",
		RollCountdown = "Roll countdown",

		-- raid
		ReservedNotInRaid = "Players with SoftReserve not in raid",
		InRaid = "Players in raid",
		Items = "Items",
		Reserved = "reserved",
		NotReserved = "not reserved",
		None = "None",
		General = "General",

		--loot
		WonBy = "Won by",

		--roll
		On = "on",
		RollFor = "Roll for",
		RollForSoftReserve = "Roll for SoftReserve",
		ReservedBy = "Reserved by",
		RollingEndsIn = "Rolling ends in",
		RollingEndsNow = "Rolling ends now!",
		SelectWinner = "Select a winner",
		NoRollsYet = "No rolls yet",
		Announce = "Announce",
		UnknownItem = "Unknown Item",
		WinsTheRollFor = "wins the roll for",

		AddonBy = "by Carriola - La Fratellanza guild (ChromieCraft server)",
	},
	itIT = {
		Create = "Crea",
		NewRun = "Nuova run",
		Cancel = "Annulla",
		Settings = "Impostazioni",
		Save = "Salva",
		PasteSoftRes = 'Incolla qui i dati SoftRes di "WeakAura":',
		Language = "Lingua",
		Raid = "Raid",
		Loot = "Bottino",

		--settings
		SettingsGeneral = "Generale",
		SettingsMasterLooterTitle = "Master Looter",
		Seconds = "secondi",
		RollCountdown = "Conto alla rovescia del roll",

		-- raid
		ReservedNotInRaid = "Giocatori con SoftReserve non in raid",
		InRaid = "Giocatori in raid",
		Items = "Oggetti",
		Reserved = "riservato",
		NotReserved = "non riservato",
		None = "Nessuno",
		General = "Generale",

		--loot
		WonBy = "Vinto da",

		--roll
		On = "su",
		RollFor = "Roll per",
		RollForSoftReserve = "Roll per SoftReserve",
		ReservedBy = "Riservato da",
		RollingEndsIn = "Il roll termina tra",
		RollingEndsNow = "Il roll termina ora!",
		SelectWinner = "Seleziona un vincitore",
		NoRollsYet = "Nessun roll effettuato",
		Announce = "Annuncia",
		UnknownItem = "Oggetto sconosciuto",
		WinsTheRollFor = "vince il roll per",

		AddonBy = "by Carriola - Gilda La Fratellanza (server ChromieCraft)",
	},
}

ns.L = ns.translations[LootameloDB.settings.language] or ns.translations["enUS"]
