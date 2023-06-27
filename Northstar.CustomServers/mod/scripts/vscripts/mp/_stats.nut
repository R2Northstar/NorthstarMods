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
	// the key being the persistence string
	table<string, void functionref(entity, float, string)> statCallbacks
	table<string, string> statCallbackRefs
} file

void function Stats_Init()
{
	AddCallback_OnPlayerKilled(OnEntityKilled)
	AddCallback_OnClientConnected(OnClientConnected)
}

void function AddStatCallback(string statCategory, string statAlias, string statSubAlias, void functionref(entity, float, string) callback, string subRef)
{
	// callback signature is ( entity player, float changeInValue, string itemRef )
	// example args:
	// category,       statAlias,     statSubAlias
	// "weapon_stats", "titanDamage", "mp_titanweapon_predator_cannon"
	//printt(statCategory + " " + statAlias + " " + statSubAlias)
	string str = GetPersistenceString(statCategory, statAlias, statSubAlias)
	printt(str)

	file.statCallbacks[str] <- callback
	file.statCallbackRefs[str] <- subRef
}

void function Stats_SaveStatDelayed(entity player, string statCategory, string statAlias, string statSubAlias)
{

}

int function PlayerStat_GetCurrentInt(entity player, string statCategory, string statAlias, string statSubAlias)
{
	return 0
}

float function PlayerStat_GetCurrentFloat(entity player, string statCategory, string statAlias, string statSubAlias)
{
	return 0
}

void function UpdatePlayerStat(entity player, string statCategory, string subStat, int count = 1)
{
	string str = GetPersistenceString(statCategory, subStat)
	player.SetPersistentVar(str, player.GetPersistentVarAsInt(str) + count)

	if (str in file.statCallbacks)
		file.statCallbacks[str]( player, count.tofloat(), file.statCallbackRefs[str] )
}

void function IncrementPlayerDidPilotExecutionWhileCloaked(entity player)
{
	string str = "killStats.pilotExecutePilotWhileCloaked"
	IncrementStat( player, str )
}

void function UpdateTitanDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanWeaponDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanCoreEarnedStat( entity player, entity titan, int count = 1 )
{
	string str = GetPersistenceString("titan_stats", "coresEarned", GetTitanCharacterName(titan))
	player.SetPersistentVar(str, player.GetPersistentVarAsInt(str) + count)

	if (str in file.statCallbacks)
		file.statCallbacks[str]( player, count.tofloat(), file.statCallbackRefs[str] )
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

string function GetPersistenceString(string statCategory, string statAlias, string statSubAlias = "")
{
	string ret = ""

	bool isArray = false

	switch (statCategory)
	{
	case "titan_stats":
		ret += "titanStats"
		isArray = true
		break
	case "distance_stats":
		ret += "distanceStats"
		break
	case "kills_stats":
		ret += "killStats"
		break
	case "weapon_kill_stats":
		ret += "weaponKillStats"
		isArray = true
		break
	case "weapon_stats":
		ret += "weaponStats"
		isArray = true
		break
	case "game_stats":
		ret += "gameStats"
		break
	case "fd_stats":
		ret += "fdStats"
		break
	case "misc_stats":
		ret += "miscStats"
		break
	case "death_stats":
		ret += "deathStats"
		break
	case "map_stats":
		ret += "mapStats"
	default:
		throw "Unimplemented statCategory: " + statCategory
	}

	if (isArray)
		ret += "[" + statSubAlias + "]"

	ret += "." + statAlias

	return ret
}

void function IncrementStat( entity player, string persistenceRef )
{
	player.SetPersistentVar( persistenceRef, player.GetPersistentVarAsInt(persistenceRef) + 1 )

	if (persistenceRef in file.statCallbacks)
		file.statCallbacks[persistenceRef]( player, 1.0, file.statCallbackRefs[persistenceRef] )
}

void function OnEntityKilled( entity victim, entity attacker, var damageInfo )
{
	// handle victim stats
	if (victim.IsPlayer())
	{
		IncrementStat( victim, GetPersistenceString("death_stats", "total") )

		if (attacker.IsPlayer())
			IncrementStat( victim, GetPersistenceString("death_stats", "totalPVP") )

		if (!victim.IsTitan())
		{
			IncrementStat( victim, GetPersistenceString("death_stats", "asPilot") )
		}
		else
		{
			// todo
		}

		if (attacker == victim)
			IncrementStat( victim, GetPersistenceString("death_stats", "suicides") )

		if (victim.p.pilotEjecting)
			IncrementStat( victim, GetPersistenceString("death_stats", "whileEjecting") )
	}

	// handle attacker stats
	if (attacker.IsPlayer())
	{
		IncrementStat( attacker, GetPersistenceString("kills_stats", "total") )

		if (victim.IsPlayer())
			IncrementStat( attacker, GetPersistenceString("kills_stats", "totalPVP") )
		
		if (!attacker.IsTitan())
		{
			IncrementStat( attacker, GetPersistenceString("kills_stats", "asPilot") )
		}
		else
		{
			// todo
		}

		if (victim.p.pilotEjecting)
			IncrementStat( attacker, GetPersistenceString("kills_stats", "ejectingPilots") )
	}
}

void function OnClientConnected( entity player )
{
	try
	{
		int enumModeIndex = PersistenceGetEnumIndexForItemName( "gamemodes", GAMETYPE )
		int enumMapIndex = PersistenceGetEnumIndexForItemName( "maps", GetMapName() )
		IncrementStat( player, "mapStats[" + enumMapIndex + "].gamesJoined[" + enumModeIndex + "]" )
	}	
	catch( ex ) {}
}