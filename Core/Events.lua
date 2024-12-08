local ns = _G[LOOTAMELO_NAME];
ns.Events = ns.Events or {};

ns.Events["UNIT_HEALTH"] = function(unit)
    if(LootameloDB.settings.autoMasterLoot) then
        if not UnitExists(unit) then return end
        if not UnitIsEnemy("player", unit) then return end
    
        print(unit);

        local healthPercentage = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
        if healthPercentage <= 30 then
            if IsRaidLeader() then
                print("[Addon]: Il boss è sotto il 30% di vita. Imposto Master Loot!");
                SetLootMethod("master", "player");
            else
                print("[Addon]: Sei sotto il 30%, ma non sei il raid leader. Impossibile impostare il loot.");
            end
        end
    end
end

ns.Events["UPDATE_INSTANCE_INFO"] = function ()
    local inInstance = IsInInstance()
    local instanceName, type = GetInstanceInfo()
    if (inInstance and type == "raid") then
        ns.State.currentRaid = instanceName

        for index = 1, GetNumSavedInstances() do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid = GetSavedInstanceInfo(index)

            print(name)
            print(id)
            print(reset)
            print(difficulty)
            print(locked)
            print(extended)
            print(instanceIDMostSig)
            print(isRaid)
        end
    end
end

-- ns.Events["PLAYER_ENTERING_WORLD"] = function()
--     local inInstance = IsInInstance()
--     local instanceName, type = GetInstanceInfo()
--     if (inInstance and type == "raid") then
--         ns.State.currentRaid = instanceName

--         for index = 1, GetNumSavedInstances() do
--             local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid = GetSavedInstanceInfo(index)

--             print(name)
--             print(id)
--             print(reset)
--             print(difficulty)
--             print(locked)
--             print(extended)
--             print(instanceIDMostSig)
--             print(isRaid)
--         end
--     end
-- end

--ns.Events["PLAYER_LOGIN"] =  ns.Events["PLAYER_ENTERING_WORLD"];

-- ns.Events["PARTY_LEADER_CHANGED"] = ns.Events["PLAYER_LOGIN"]
-- ns.Events["PARTY_LOOT_METHOD_CHANGED"] = ns.Events["PLAYER_LOGIN"]


ns.Events["CHAT_MSG_SYSTEM"] = function(message)
    if message then
        if string.match(message, "(.+) is now the loot master") then
            local masterLooterName = string.match(arg1, "(.+) is now the loot master");
            print(masterLooterName);
            ns.State.masterLooterName = masterLooterName;
        end
    end
end

ns.Events["ADDON_LOADED"] = function(addonName)
    if addonName == LOOTAMELO_NAME then
        ns.State.playerName = UnitName("player");
        ns.State.playerLevel = UnitLevel("player");
        if (not LootameloDB or not LootameloDB.raid or not LootameloDB.raid.name) then
            print("eccomi, sono entrato")
            ns.State.currentPage = "Create"
            LootameloDB = {
                enabled = false,
                raid = {
                    date = nil,
                    name = nil,
                    id = nil,
                    reserve = {},
                    loot = {
                        lastBossLooted = nil,
                        list = {}
                    }
                },
                settings = {
                    alertMasterLoot = false,
                    alertMasterLootHP = nil,
                    autoMasterLoot = true,
                    autoMasterLootHP = nil,
                    language = "enUS",
                    showLootPanel = false,
                    showRollPanel = false,
                }
            }
        else
            print("else");
            print(LootameloDB.raid.name);
            ns.State.currentPage = "Raid"
            if (LootameloDB.raid.name) then
                ns.State.currentRaid = LootameloDB.raid.name
            end
        end
    end
end

ns.Events["LOOT_OPENED"] = function()
    if ns.State.isRaidOfficer then
        local targetName = GetUnitName("target");

        if(not targetName) then
            return;
        end
        local bossName = ns.Utils.GetBossName(targetName);
        
        if not bossName then
            return;
        end

        local messageToSend = "";
        local toSend = false;
        for slot = 1, GetNumLootItems() do
            local itemLink = GetLootSlotLink(slot);
            if(itemLink) then
                local itemIcon, itemName, _, itemRarity = GetLootSlotInfo(slot);
                local itemId;
                itemId = ns.Utils.GetItemIdFromLink(itemLink);

                if (not LootameloDB.raid.loot.list[bossName]) then
                    LootameloDB.raid.loot.list[bossName] = {};
                    toSend = true;
                end

                if itemId then
                    local count = 0;
                    if(LootameloDB.raid.loot.list[bossName][itemId])then
                        count = count + 1;
                    else
                        count = 1;
                    end
                    local icon = ns.Utils.GetIconFromPath(itemIcon);
                    
                    LootameloDB.raid.loot.list[bossName][itemId] = {
                        icon = icon,
                        name = itemName,
                        rolled = {},
                        won = "",
                        count = count
                    }
                    if(toSend) then
                        messageToSend = messageToSend .. ":" .. itemId;
                    end
                end
            end
        end

        LootameloDB.raid.loot.lastBossLooted = bossName;

        ns.Navigation.ToPage("Loot");
        ns.Loot.LoadFrame(bossName, toSend, messageToSend)
    end
end


