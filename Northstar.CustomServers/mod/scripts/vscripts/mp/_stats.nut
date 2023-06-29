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
	AddCallback_OnPlayerKilled(OnPlayerKilled)
	AddCallback_OnPlayerRespawned(OnPlayerRespawned)
	AddCallback_OnClientConnected(OnClientConnected)
	AddCallback_OnClientDisconnected(OnClientDisconnected)
	AddCallback_GameStateEnter( eGameState.Epilogue, OnEpilogueStarted )

	thread TrackMoveState_Threaded()
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

	entity weapon = DamageInfo_GetWeapon(damageInfo)
	if (!IsValid(weapon))
		return

	Stats_IncrementStat( attacker, "weapon_stats", "titanDamage", weapon.GetWeaponClassName(), savedDamage )
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

}

void function PostScoreEventUpdateStats(entity attacker, entity ent)
{

}

void function Stats_OnPlayerDidDamage(entity player, var damageInfo)
{

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
	string difficulty = ""
	array<string> splitted = split(mode, "_")
	mode = splitted[0]
	if (splitted.len() > 1)
		difficulty = splitted[1]

	string saveVar = Stats_GetFixedSaveVar( str, GetMapName(), mode, difficulty )
	// check if the map and mode exist in persistence
	try
	{
		PersistenceGetEnumIndexForItemName( "gamemodes", mode )
		PersistenceGetEnumIndexForItemName( "maps", GetMapName() )
	}	
	catch( ex )
	{
		// if we have an invalid mode or map for persistence, and it is used in the 
		if (str != saveVar)
			return
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

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	thread SetLastPosForDistanceStatValid_Threaded(victim, false)

	// awards death stats
	// handle NPCs killing players
	// handle players killing players (death stats only)

	//bySpectres
	//byGrunts
	//total
	//totalPVP
	//asPilot
	//asTitan_<chassis>
	//byPilots
	//byNPCTitans_<chassis>
	//byTitan_<chassis>
	//suicides
	//whileEjecting

	if (victim.p.pilotEjecting)
		Stats_IncrementStat( victim, "deaths_stats", "whileEjecting", "", 1.0 )
}

void function OnNPCKilled( entity victim, entity attacker, var damageInfo )
{
	// handle NPCs killing NPCs
	// pass on players killing NPCs
	if (attacker.IsPlayer())
		PlayerKilledEntity( victim, attacker, damageInfo )
}

void function PlayerKilledEntity( entity victim, entity attacker, var damageInfo )
{
	// handle players killing NPCs
	// pass on players killing players
	if (victim.IsPlayer())
		PlayerKilledPlayer( victim, attacker, damageInfo )
}

void function PlayerKilledPlayer( entity victim, entity attacker, var damageInfo )
{
	// doesnt award death stats
	// handle players killing players (no death stats)


	// handle first strike stat
	if (file.isFirstStrike)
	{
		UpdatePlayerStat( attacker, "kills_stats", "firstStrikes" )
		file.isFirstStrike = false
	}

	// handle victim ejecting
	if (victim.p.pilotEjecting)
	{
		Stats_IncrementStat( attacker, "kills_stats", "ejectingPilots", "", 1.0 )

		entity weapon = DamageInfo_GetWeapon(damageInfo)
		if (IsValid(weapon))
			Stats_IncrementStat( attacker, "weapon_kill_stats", "ejecting_pilots", weapon.GetWeaponClassName(), 1.0 )
	}
	// handle attacker ejecting
	if (attacker.p.pilotEjecting)
	{
		Stats_IncrementStat( attacker, "kills_stats", "whileEjecting", "", 1.0 )
	}
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

void function TrackMoveState_Threaded()
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