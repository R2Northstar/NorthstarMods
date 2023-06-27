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

void function Stats_Init()
{

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

}

void function IncrementPlayerDidPilotExecutionWhileCloaked(entity player)
{
	player.SetPersistentVar("killStats.pilotExecutePilotWhileCloaked", player.GetPersistentVarAsInt("killStats.pilotExecutePilotWhileCloaked") + 1)
}

void function UpdateTitanDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanWeaponDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanCoreEarnedStat( entity player, entity titan, int count = 1 )
{
	string ref = "titanStats[" + GetTitanCharacterName(titan) + "].coresEarned"
	player.SetPersistentVar(ref, player.GetPersistentVarAsInt(ref) + count)
	// todo, callbacks
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
	default:
		throw "Unimplemented statCategory: " + statCategory
	}

	if (isArray)
		ret += "[" + statSubAlias + "]"

	ret += "." + statAlias

	return ret
}