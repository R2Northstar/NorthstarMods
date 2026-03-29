global function CodeCallback_MapInit
void function CodeCallback_MapInit()
{
	// the spawnpoints are on the wrong side of the map or team for some reason
	AddSpawnCallback( "info_spawnpoint_titan_start", InvertTitanStartSpawnsTeams )

	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

void function InvertTitanStartSpawnsTeams( entity spawn )
{
	if ( IsIMCOrMilitiaTeam( spawn.GetTeam() ) )
		SetTeam( spawn, GetOtherTeam( spawn.GetTeam() ) )
}