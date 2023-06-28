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
} file

void function Stats_Init()
{
	//AddCallback_OnPlayerKilled(OnEntityKilled)
	//AddCallback_OnClientConnected(OnClientConnected)
}

void function AddStatCallback(string statCategory, string statAlias, string statSubAlias, void functionref(entity, float, string) callback, string subRef)
{
	// callback signature is ( entity player, float changeInValue, string itemRef )
	// example args:
	// category,       statAlias,     statSubAlias
	// "weapon_stats", "titanDamage", "mp_titanweapon_predator_cannon"
	//printt(statCategory + " " + statAlias + " " + statSubAlias)
	
	if (!IsValidStat(statCategory, statAlias, statSubAlias))
		throw "INVALID STAT: " + statCategory + " " + statAlias + " " + statSubAlias
	
	
	string str = GetStatVar(statCategory, statAlias, statSubAlias)
	printt(str)
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

}

int function PlayerStat_GetCurrentInt(entity player, string statCategory, string statAlias, string statSubAlias)
{
	return GetPlayerStatInt(player, statCategory, statAlias, statSubAlias)
}

float function PlayerStat_GetCurrentFloat(entity player, string statCategory, string statAlias, string statSubAlias)
{
	return GetPlayerStatFloat(player, statCategory, statAlias, statSubAlias)
}

void function UpdatePlayerStat(entity player, string statCategory, string subStat, int count = 1)
{

}

void function IncrementPlayerDidPilotExecutionWhileCloaked(entity player)
{

}

void function UpdateTitanDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanWeaponDamageStat(entity attacker, float savedDamage, var damageInfo)
{

}

void function UpdateTitanCoreEarnedStat( entity player, entity titan, int count = 1 )
{

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