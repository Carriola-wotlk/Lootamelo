local ns = _G[LOOTAMELO_NAME];
ns.State = ns.State or {};

ns.State.raidItemSelected = nil;
ns.State.playerLevel = 0;
ns.State.playerName = nil;
ns.State.isRaidLeader = 0;
ns.State.isMasterLooter = 0;
ns.State.masterLooterName = nil;
ns.State.currentRaid = nil;
ns.State.currentPage = nil;