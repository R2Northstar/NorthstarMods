global function Stats_Init
global function AddStatCallback
global function Stats_SaveStatDelayed
global function PlayerStat_GetCurrentInt
global function PlayerStat_GetCurrentFloat
global function UpdatePlayerStat
global function IncrementPlayerDidPilotExecutionWhileCloaked
global function UpdateTitanDamageStat
global function UpdateTitanWeaponDamageStat
global function UpdateTitanCoreEarnedStat
global function PreScoreEventUpdateStats
global function PostScoreEventUpdateStats
global function Stats_OnPlayerDidDamage

struct {
	table<string, array<string> > refs
	table<string, array< void functionref(entity, float, string) > > callbacks

	table< entity, table< string, int > > cachedIntStatChanges
	table< table< string, float > > cachedFloatStatChanges

	bool isFirstStrike = true
} file

void function Stats_Init()
{
	AddCallback_OnPlayerKilled(OnPlayerOrNPCKilled)
	AddCallback_OnNPCKilled(OnPlayerOrNPCKilled)
	AddCallback_OnPlayerRespawned(OnPlayerRespawned)
	AddCallback_OnClientConnected(OnClientConnected)
	AddCallback_OnClientDisconnected(OnClientDisconnected)
	AddCallback_GameStateEnter( eGameState.Epilogue, OnEpilogueStarted )

	thread HandleDistanceAndTimeStats_Threaded()
	thread SaveStatsPeriodically_Threaded()
}

void function AddStatCallback(string statCategory, string statAlias, string statSubAlias, void functionref(entity, float, string) callback, string subRef)
{	
	if (!IsValidStat(statCategory, statAlias, statSubAlias))
		throw "INVALID STAT: " + statCategory + " : " + statAlias + " : " + statSubAlias
	
	
	string str = GetStatVar(statCategory, statAlias, statSubAlias)
	//printt(str)
	//printt(statCategory + " : " + statAlias + " : " + statSubAlias)
	if (str in file.refs)
	{
		file.refs[str].append(subRef)
		file.callbacks[str].append(callback)
	}
	else
	{
		file.refs[str] <- [subRef]
		file.callbacks[str] <- [callback]
	}
}

// a lot of this file seems to be doing caching of stats in some way
void function Stats_SaveStatDelayed(entity player, string statCategory, string statAlias, string statSubAlias)
{
	// idk how long the delay is meant to be but whatever
	WaitFrame()

	if (!IsValid(player))
		return

	Stats_SaveStat( player, statCategory, statAlias, statSubAlias )
}

void function Stats_SaveAllStats(entity player)
{
	if (player in file.cachedIntStatChanges)
	{
		foreach(string key, int val in file.cachedIntStatChanges[player])
		{
			player.SetPersistentVar( key, player.GetPersistentVarAsInt(key) + val )
		}
		
		delete file.cachedIntStatChanges[player]
	}
	// save cached float stat change
	if (player in file.cachedFloatStatChanges)
	{
		foreach(string key, float val in file.cachedFloatStatChanges[player])
		{
			player.SetPersistentVar( key, expect float(player.GetPersistentVar(key)) + val )
		}
		
		delete file.cachedFloatStatChanges[player]
	}
}

void function Stats_SaveStat(entity player, string statCategory, string statAlias, string statSubAlias)
{
	string str = GetStatVar(statCategory, statAlias, statSubAlias)
	// save cached int stat change
	if (player in file.cachedIntStatChanges && str in file.cachedIntStatChanges[player])
	{
		player.SetPersistentVar( str, player.GetPersistentVarAsInt(str) + file.cachedIntStatChanges[player][str] )
		delete file.cachedIntStatChanges[player][str]
		return
	}
	// save cached float stat change
	if (player in file.cachedFloatStatChanges && str in file.cachedFloatStatChanges[player])
	{
		player.SetPersistentVar( str, expect float(player.GetPersistentVar(str)) + file.cachedFloatStatChanges[player][str] )
		delete file.cachedFloatStatChanges[player][str]
		return
	}
}

// this gets the cached change, not the actual value
int function PlayerStat_GetCurrentInt(entity player, string statCategory, string statAlias, string statSubAlias)
{
	string str = GetStatVar(statCategory, statAlias, statSubAlias)

	if (player in file.cachedIntStatChanges && str in file.cachedIntStatChanges[player])
		return file.cachedIntStatChanges[player][str]
	return 0
}

// this gets the cached change, not the actual value
float function PlayerStat_GetCurrentFloat(entity player, string statCategory, string statAlias, string statSubAlias)
{
	string str = GetStatVar(statCategory, statAlias, statSubAlias)

	if (player in file.cachedFloatStatChanges && str in file.cachedFloatStatChanges[player])
		return file.cachedFloatStatChanges[player][str]
	return 0
}

void function UpdatePlayerStat(entity player, string statCategory, string subStat, int count = 1)
{
	if (!IsValid(player))
		return
		
	Stats_IncrementStat( player, statCategory, subStat, "", count.tofloat() )
}

void function IncrementPlayerDidPilotExecutionWhileCloaked(entity player)
{
	UpdatePlayerStat(player, "kills_stats", "pilotExecutePilotWhileCloaked")
}

void function UpdateTitanDamageStat(entity attacker, float savedDamage, var damageInfo)
{
	if (!IsValid(attacker))
		return
		
	Stats_IncrementStat( attacker, "titan_stats", "titanDamage", GetTitanCharacterName( attacker ), savedDamage )
}

void function UpdateTitanWeaponDamageStat(entity attacker, float savedDamage, var damageInfo)
{
	if (!IsValid(attacker))
		return

	string weaponName = GetPersistenceRefFromDamageInfo(damageInfo)
	if (weaponName == "")
		return

	Stats_IncrementStat( attacker, "weapon_stats", "titanDamage", weaponName, savedDamage )
}

void function UpdateTitanCoreEarnedStat( entity player, entity titan, int count = 1 )
{
	if (!IsValid(player))
		return

	if (!IsValid(titan))
		return

	Stats_IncrementStat( player, "titan_stats", "coresEarned", GetTitanCharacterName( titan ), count.tofloat() )
}

void function PreScoreEventUpdateStats(entity attacker, entity ent)
{
	// used to track kill streaks ending i think (that stuff gets reset during score event update)
}

void function PostScoreEventUpdateStats(entity attacker, entity ent)
{
	// used to track kill streaks starting maybe
}

void function Stats_OnPlayerDidDamage(entity victim, var damageInfo)
{
	// try and get the player
	entity attacker = DamageInfo_GetAttacker(damageInfo)
	// get the player from their titan
	if (attacker.IsTitan() && IsPetTitan(attacker))
		attacker = attacker.GetTitanSoul().GetBossPlayer()

	if (!attacker.IsPlayer())
		return

	string weaponName = GetPersistenceRefFromDamageInfo(damageInfo)
	if (weaponName == "")
		return

	Stats_IncrementStat( attacker, "weapon_stats", "shotsHit", weaponName, 1.0 )

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_CRITICAL )
		Stats_IncrementStat( attacker, "weapon_stats", "critHits", weaponName, 1.0 )
	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
		Stats_IncrementStat( attacker, "weapon_stats", "headshots", weaponName, 1.0 )
}

void function Stats_IncrementStat( entity player, string statCategory, string statAlias, string statSubAlias, float amount )
{
	if (!IsValidStat(statCategory, statAlias, statSubAlias))
	{
		printt("invalid stat: " + statCategory + " : " + statAlias + " : " + statSubAlias)
		return
	}

	string str = GetStatVar( statCategory, statAlias, statSubAlias )
	int type = GetStatVarType( statCategory, statAlias, statSubAlias )

	// stupid exception because respawn set this up as an int in script
	// but it is actually a float, so the game will crash if we don't fix it somewhere
	// i dont feel like committing all of sh_stats.gnut so im doing this instead
	if (str == "mapStats[%mapname%].hoursPlayed[%gamemode%]")
		type = ePlayerStatType.FLOAT

	// this is rather hacky
	string mode = GAMETYPE
	int difficulty = GetDifficultyLevel()
	if (difficulty >= 5)
		return

	string saveVar = Stats_GetFixedSaveVar( str, GetMapName(), mode, difficulty.tostring() )
	// check if the map and mode exist in persistence
	try
	{
		PersistenceGetEnumIndexForItemName( "gamemodes", mode )
		PersistenceGetEnumIndexForItemName( "maps", GetMapName() )
	}	
	catch( ex )
	{
		// if we have an invalid mode or map for persistence, and it is used in the
		// persistence string, we can't save the persistence so we have to just return
		if (str != saveVar)
		{
			printt(ex)
			return
		}
	}
	str = saveVar

	switch (type)
	{
	case ePlayerStatType.INT:
		// populate table if needed
		if (!(player in file.cachedIntStatChanges))
			file.cachedIntStatChanges[player] <- {}
		if (!(str in file.cachedIntStatChanges[player]))
			file.cachedIntStatChanges[player][str] <- 0
		
		file.cachedIntStatChanges[player][str] += amount.tointeger()
		break
	case ePlayerStatType.FLOAT:
		// populate table if needed
		if (!(player in file.cachedFloatStatChanges))
			file.cachedFloatStatChanges[player] <- {}
		if (!(str in file.cachedFloatStatChanges[player]))
			file.cachedFloatStatChanges[player][str] <- 0.0
		
		file.cachedFloatStatChanges[player][str] += amount
		break
	default:
		throw "UNIMPLEMENTED STAT TYPE: " + type
	}
	
	// amount here is never used
	Stats_RunCallbacks( str, player, amount )
}

void function Stats_RunCallbacks( string statVar, entity player, float change )
{
	if (!(statVar in file.refs))
		return
	
	for(int i = 0; i < file.refs[statVar].len(); i++)
	{
		string ref = file.refs[statVar][i]
		void functionref(entity, float, string) callback = file.callbacks[statVar][i]

		callback( player, change, ref )
	}
}

void function OnClientConnected(entity player)
{
	Stats_IncrementStat( player, "game_stats", "game_joined", "", 1.0 )
}

void function OnClientDisconnected(entity player)
{
	Stats_SaveAllStats(player)
	// maybe we can save this stuff, but idk if we can access persistence in this callback
	if (player in file.cachedIntStatChanges)
		delete file.cachedIntStatChanges[player]

	if (player in file.cachedFloatStatChanges)
		delete file.cachedFloatStatChanges[player]
}

void function OnPlayerOrNPCKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim.IsPlayer() )
		thread SetLastPosForDistanceStatValid_Threaded( victim, false ) 
	
	HandleDeathStats( victim, attacker, damageInfo )
	HandleKillStats( victim, attacker, damageInfo )
	HandleWeaponKillStats( victim, attacker, damageInfo )
}

void function HandleDeathStats( entity player, entity attacker, var damageInfo )
{
	if (!IsValid(player) || !player.IsPlayer())
		return
	
	// total
	// totalPVP
	// asPilot
	// asTitan_<chassis>
	// byPilots
	// byTitan_<chassis>
	// bySpectres
	// byGrunts
	// byNPCTitans_<chassis>
	// suicides
	// whileEjecting
	
	// total
	Stats_IncrementStat( player, "deaths_stats", "total", "", 1.0 )

	// these all rely on the attacker being valid
	if ( IsValid(attacker) )
	{
		// totalPVP
		// note: I'm not sure if owned entities count towards totalPVP
		// such as auto-titans, turrets, etc.
		if ( attacker.IsPlayer() || attacker.GetBossPlayer() )
			Stats_IncrementStat( player, "deaths_stats", "totalPVP", "", 1.0 )

		// byPilots
		if ( IsPilot(attacker) )
			Stats_IncrementStat( player, "deaths_stats", "byPilots", "", 1.0 )

		// byTitan_<chassis>
		if ( attacker.IsTitan() && attacker.IsPlayer() )
			Stats_IncrementStat( player, "deaths_stats", "byTitan_" + GetTitanCharacterName(attacker), "", 1.0 )

		// bySpectres
		if ( IsSpectre(attacker) )
			Stats_IncrementStat( player, "deaths_stats", "bySpectres", "", 1.0 )

		// byGrunts
		if ( IsGrunt(attacker) )
			Stats_IncrementStat( player, "deaths_stats", "byGrunts", "", 1.0 )

		// byNPCTitans_<chassis>
		if ( attacker.IsTitan() && attacker.IsNPC() )
			Stats_IncrementStat( player, "deaths_stats", "byNPCTitans_" + GetTitanCharacterName(attacker), "", 1.0 )
	}
	
	// asPilot
	if ( IsPilot(player) )
		Stats_IncrementStat( player, "deaths_stats", "asPilot", "", 1.0 )

	// asTitan_<chassis>
	if ( player.IsTitan() )
		Stats_IncrementStat( player, "deaths_stats", "asTitan_" + GetTitanCharacterName(player), "", 1.0 )

	// suicides
	if ( IsSuicide( attacker, player, DamageInfo_GetDamageSourceIdentifier(damageInfo) ) )
		Stats_IncrementStat( player, "deaths_stats", "suicides", "", 1.0 )

	// whileEjecting
	if ( player.p.pilotEjecting )
		Stats_IncrementStat( player, "deaths_stats", "whileEjecting", "", 1.0 )
}

void function HandleWeaponKillStats( entity attacker, entity victim, var damageInfo )
{
	// total
	// pilots
	// ejecting_pilots
	// titansTotal
	// assistsTotal
	// killingSprees
	// spectres
	// marvins
	// grunts
	// ai
	// titans_<chassis>
	// npcTitans_<chassis>
}

void function HandleKillStats( entity player, entity victim, var damageInfo )
{
	// total
	// totalWhileUsingBurnCard
	// titansWhileTitanBCActive
	// totalPVP
	// pilots
	// spectres
	// marvins
	// grunts
	// totalTitans
	// totalPilots
	// totalNPC
	// totalTitansWhileDoomed
	// asPilot
	// totalAssists
	// asTitan_<chassis>
	// killingSpressAs_<chassis>
	// firstStrikes
	// ejectingPilots
	// whileEjecting
	// cloakedPilots
	// whileCloaked
	// wallrunningPilots
	// whileWallrunning
	// wallhangingPilots
	// whileWallhanging
	// pilotExecution
	// pilotExecutePilot
	// pilotExecutePilotWhileCloaked
	// pilotKillsWithHoloPilotActive
	// pilotKillsWithAmpedWallActive
	// pilotExecutePilotUsing_<execution>
	// pilotKickMelee
	// pilotKickMeleePilot
	// titanMelee
	// titanMeleePilot
	// titanStepCrush
	// titanStepCrushPilot
	// titanExocution<capitalisedChassis>
	// titanFallKill
	// petTitanKillsFollowMode
	// petTitanKillsGuardMode
	// rodeo_total
	// pilot_headshots_total
	// evacShips
	// flyers
	// nuclearCore
	// evacuatingEnemies
	// coopChallenge_NukeTitan_Kills
	// coopChallenge_MortarTitan_Kills
	// coopChallenge_EmpTitan_Kills
	// coopChallenge_SuicideSpectre_Kills
	// coopChallenge_Turret_Kills
	// coopChallenge_CloakDrone_Kills
	// coopChallenge_BubbleShieldGrunt_Kills
	// coopChallenge_Dropship_Kills
	// coopChallenge_Sniper_Kills
	// ampedVortexKills
	// meleeWhileCloaked
	// pilotKillsWhileUsingActiveRadarPulse
	// titanKillsAsPilot
	// pilotKillsWhileStimActive
	// pilotKillsAsTitan
	// pilotKillsAsPilot
	// titanKillsAsTitan
}

void function OnPlayerRespawned( entity player )
{
	thread SetLastPosForDistanceStatValid_Threaded(player, true)
}

void function OnEpilogueStarted()
{
	// award players for match completed, wins, and losses
	foreach (entity player in GetPlayerArray())
	{
		Stats_IncrementStat( player, "game_stats", "game_completed", "", 1.0 )

		if (player.GetTeam() == GetWinningTeam())
			Stats_IncrementStat( player, "game_stats", "game_won", "", 1.0 )
		else
			Stats_IncrementStat( player, "game_stats", "game_lost", "", 1.0 )
	}
	// award mvp and top 3 in each team
	if (!IsFFAGame())
	{
		string gamemode = GameRules_GetGameMode()
		int functionref( entity, entity ) compareFunc = GameMode_GetScoreCompareFunc( gamemode )

		for(int team = 0; team < MAX_TEAMS; team++)
		{
			array<entity> players = GetPlayerArrayOfTeam(team)
			if ( compareFunc == null )
			{
				printt( "gamemode doesn't have a compare func to get the top 3")
				return
			}
			players.sort( compareFunc )
			int max = min( players.len(), 3 ).tointeger()
			for (int i = 0; i < max; i++)
			{
				if (i == 0)
					Stats_IncrementStat( players[i], "game_stats", "mvp", "", 1.0 )
				Stats_IncrementStat( players[i], "game_stats", "top3OnTeam", "", 1.0 )
			}
		}
		
	}
}

void function SetLastPosForDistanceStatValid_Threaded(entity player, bool val)
{
	WaitFrame()
	if (!IsValid(player))
		return
	player.p.lastPosForDistanceStatValid = val
}

void function HandleDistanceAndTimeStats_Threaded()
{
	// just to be safe
	if (IsLobby())
		return

	while (GetGameState() < eGameState.Playing)
		WaitFrame()

	float lastTickTime = Time()
	
	while(true)
	{
		// track distance stats
		foreach (entity player in GetPlayerArray())
		{
			if (player.p.lastPosForDistanceStatValid)
			{
				// not 100% sure on using Distance2D over Distance tbh
				float distInches = Distance2D(player.p.lastPosForDistanceStat, player.GetOrigin())
				float distMiles = distInches / 63360.0

				// more generic distance stats
				Stats_IncrementStat( player, "distance_stats", "total", "", distMiles )
				if ( player.IsTitan() )
				{
					Stats_IncrementStat( player, "distance_stats", "asTitan_" + GetTitanCharacterName( player ), "", distMiles )
					Stats_IncrementStat( player, "distance_stats", "asTitan", "", distMiles )
				}
				else
					Stats_IncrementStat( player, "distance_stats", "asPilot", "", distMiles )


				string state = ""
				// specific distance stats
				if (player.IsWallRunning())
					state = "wallrunning"
				else if (PlayerIsRodeoingTitan(player))
				{
					if (player.GetTitanSoulBeingRodeoed().GetTeam() == player.GetTeam())
						state = "onFriendlyTitan"
					else
						state = "onEnemyTitan"
				}
				else if (player.IsZiplining())
					state = "ziplining"
				else if (!player.IsOnGround())
					state = "inAir"

				if (state != "")
					Stats_IncrementStat( player, "distance_stats", state, "", distMiles )
			}

			player.p.lastPosForDistanceStat = player.GetOrigin()
		}

		float timeSeconds = Time() - lastTickTime
		float timeHours = timeSeconds / 3600.0

		// track time stats
		foreach (entity player in GetPlayerArray())
		{
			// first tick i dont count
			if (timeSeconds == 0)
				break
			
			// more generic time stats
			Stats_IncrementStat( player, "time_stats", "hours_total", "", timeHours )
			if ( player.IsTitan() )
			{
				Stats_IncrementStat( player, "time_stats", "hours_as_titan_" + GetTitanCharacterName( player ), "", timeHours )
				Stats_IncrementStat( player, "time_stats", "hours_as_titan", "", timeHours )
			}
			else
				Stats_IncrementStat( player, "time_stats", "hours_as_pilot", "", timeHours )

			string state = ""
			// specific time stats
			if (!IsAlive(player))
				state = "hours_dead"
			else if (player.IsWallHanging())
				state = "hours_wallhanging"
			else if (player.IsWallRunning())
				state = "hours_wallrunning"
			else if (!player.IsOnGround())
				state = "hours_inAir"
			
			if (state != "")
				Stats_IncrementStat( player, "time_stats", state, "", timeHours )

			// weapon time stats
			entity activeWeapon = player.GetActiveWeapon()
			if (IsValid(activeWeapon))
			{
				Stats_IncrementStat( player, "weapon_stats", "hoursUsed", activeWeapon.GetWeaponClassName(), timeHours )
				foreach(entity weapon in player.GetMainWeapons())
				{
					Stats_IncrementStat( player, "weapon_stats", "hoursEquipped", weapon.GetWeaponClassName(), timeHours )
				}
			}

			// map time stats
			Stats_IncrementStat( player, "game_stats", "hoursPlayed", "", timeHours )
		}

		lastTickTime = Time()
		// not rly worth doing this every frame, just a couple of times per second should be fine
		wait 0.25
	}
}

// this is kinda shit
void function SaveStatsPeriodically_Threaded()
{
	while(true)
	{
		foreach(entity player in GetPlayerArray())
			Stats_SaveAllStats(player)
		wait 5
	}
}

string function GetPersistenceRefFromDamageInfo(var damageInfo)
{
	string damageSourceString = DamageSourceIDToString( DamageInfo_GetDamageSourceIdentifier( damageInfo ) )

	foreach(str in shGlobalMP.statsItemsList)
	{
		if (str == damageSourceString)
			return damageSourceString
	}

	return ""
}