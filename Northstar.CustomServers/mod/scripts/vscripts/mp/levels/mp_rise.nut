global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	// imc droppod start spawnpoints don't have a team for some reason
	AddSpawnCallback( "info_spawnpoint_droppod_start", FixSpawnPointTeams )

	// Load Frontier Defense Data
	if ( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

void function FixSpawnPointTeams( entity spawn )
{
	if ( spawn.GetTeam() == TEAM_UNASSIGNED )
		SetTeam( spawn, TEAM_IMC )
}
