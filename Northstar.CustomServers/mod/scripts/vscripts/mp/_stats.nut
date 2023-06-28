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
} file

void function Stats_Init()
{
	AddCallback_OnPlayerKilled(OnPlayerKilled)
	AddCallback_OnPlayerRespawned(OnPlayerRespawned)
	//AddCallback_OnClientConnected(OnClientConnected)
	AddCallback_OnClientDisconnected(OnClientDisconnected)

	thread TrackMoveState_Threaded()
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
		return


	string str = GetStatVar( statCategory, statAlias, statSubAlias )
	int type = GetStatVarType( statCategory, statAlias, statSubAlias )

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

void function OnClientDisconnected(entity player)
{
	// maybe we can save this stuff, but idk if we can access persistence in this callback
	if (player in file.cachedIntStatChanges)
		delete file.cachedIntStatChanges[player]

	if (player in file.cachedFloatStatChanges)
		delete file.cachedFloatStatChanges[player]
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	thread SetLastPosForDistanceStatValid_Threaded(victim, false)
}

void function OnPlayerRespawned( entity player )
{
	thread SetLastPosForDistanceStatValid_Threaded(player, true)
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
					Stats_IncrementStat( player, "distance_stats", "asTitan", GetTitanCharacterName( player ), distMiles )
					Stats_IncrementStat( player, "distance_stats", "asTitanTotal", "", distMiles )
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

		// track time stats
		foreach (entity player in GetPlayerArray())
		{
		}
		// not rly worth doing this every frame, just a couple of times per second should be fine
		wait 0.25
	}
}