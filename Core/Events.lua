local ns = _G[LOOTAMELO_NAME];
ns.Events = ns.Events or {};

-- ns.Events["UNIT_HEALTH"] = function(unit)
--     if ns.State.IsRaidLeader and not ns.State.masterLooterName then
--         if(LootameloDB.settings.autoMasterLoot) then
--             if not UnitExists(unit) then return end
--             if not UnitIsEnemy("player", unit) then return end
        
--             local healthPercentage = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
--             if healthPercentage <= 30 then
--                 SetLootMethod("master", "player");
--             end
--         end
--     end
-- end

ns.Events["PARTY_LEADER_CHANGED"] = function ()
    if(not UnitInRaid("player")) then
        return;
    end

    ns.State.IsRaidLeader = IsRaidLeader();

    local lootmethod, _, masterlooterRaidID = GetLootMethod();
    if(lootmethod ~= "master") then
        ns.State.masterLooterName = nil;
        ns.State.isMasterLooter = false;
        return;
    end

    if(not masterlooterRaidID) then
        return;
    end

    local name, _, _, _, _, _, _, _, _, _, isML = GetRaidRosterInfo(masterlooterRaidID);

    if(not isML) then
        return;
    end

    ns.State.masterLooterName = name;

    if(ns.State.playerName == name) then
        ns.State.isMasterLooter = true
    else
        ns.State.isMasterLooter = false
    end
end
ns.Events["PARTY_LOOT_METHOD_CHANGED"] =  ns.Events["PARTY_LEADER_CHANGED"];
ns.Events["PLAYER_ENTERING_WORLD"] =  ns.Events["PARTY_LEADER_CHANGED"];

ns.Events["UPDATE_INSTANCE_INFO"] = function ()
    local inInstance = IsInInstance()
    local instanceName, type = GetInstanceInfo()
    if (inInstance and type == "raid") then
        ns.State.currentRaid = ns.Utils.GetNormalizedRaidName(instanceName)
    end
end

ns.Events["ADDON_LOADED"] = function(addonName)
    if addonName == LOOTAMELO_NAME then
        ns.State.playerName = UnitName("player");
        ns.State.playerLevel = UnitLevel("player");
        if (not LootameloDB or not LootameloDB.raid) then
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
                    autoMasterLoot = false,
                    autoMasterLootHP = nil,
                    language = "enUS",
                    showLootPanel = false,
                    showRollPanel = false,
                }
            }
        else
            ns.State.currentPage = "Raid"
            if (LootameloDB.raid.name) then
                ns.State.currentRaid = LootameloDB.raid.name
            end
        end
    end
end

ns.Events["LOOT_OPENED"] = function()
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
        if(not LootameloDB.raid.loot.list[bossName]) then
            for slot = 1, GetNumLootItems() do
                local itemLink = GetLootSlotLink(slot);
                if(itemLink) then
                    local itemIcon, itemName, quantity, itemRarity = GetLootSlotInfo(slot);
                    local itemId;
                    itemId = ns.Utils.GetItemIdFromLink(itemLink);
                    if(itemId) then
                        if(ns.Database.items[ns.State.currentRaid][bossName][itemId]) then
                            
                            if (not LootameloDB.raid.loot.list[bossName]) then
                                LootameloDB.raid.loot.list[bossName] = {};
                                toSend = true;
                            end

                            if itemId then
                                local count = 0;
                                if(LootameloDB.raid.loot.list[bossName][itemId])then
                                    count = LootameloDB.raid.loot.list[bossName][itemId].count + 1;
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
                end
            end
        end

        LootameloDB.raid.loot.lastBossLooted = bossName;
        ns.Navigation.ToPage("Loot");
        ns.Loot.LoadFrame(bossName, toSend, messageToSend, ns.State.currentRaid)
end


ns.Events["CHAT_MSG_RAID_WARNING"] = function(message)
    local _, _, matchedItemLink = string.find(message, "Roll for .- on: (|c.-|r)")
    if matchedItemLink then
        ns.Roll.LoadFrame(matchedItemLink);
    end
end

ns.Events["CHAT_MSG_SYSTEM"] = function(message)
    if(_G["Lootamelo_RollFrame"] and _G["Lootamelo_RollFrame"]:IsShown()) then
        local _, _, playerName, rollValue, rollMin, rollMax = string.find(message, "(%a+)%srolls%s(%d+)%s%((%d+)%-(%d+)%)")
        if playerName and rollValue and rollMax and tonumber(rollMin) == 1 and tonumber(rollMax) == 100 then
            ns.Roll.UpdateRollList(playerName, rollValue)
        end
    end
end