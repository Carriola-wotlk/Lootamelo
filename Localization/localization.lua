local ns = _G[LOOTAMELO_NAME];
ns.L = ns.L or {};

LootameloDB = LootameloDB or {}
LootameloDB.language = LootameloDB.language or GetLocale()

local translations = {
    enUS = {
        Create = "Create",
        Settings = "Settings"
    },
    itIT = {
        Create = "Crea",
        Settings = "Impostazioni"
    },
}

ns.L = translations[LootameloDB.language] or translations["enUS"]