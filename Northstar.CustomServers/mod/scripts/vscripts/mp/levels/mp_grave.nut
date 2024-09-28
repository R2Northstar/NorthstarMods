global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	// there are some really busted titan startspawns that are on the fucking other side of the map from where they should be, so we remove them
	// AddSpawnCallback( "info_spawnpoint_titan_start", TrimBadTitanStartSpawns )
	
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()

	FlagSet( "LevelHasRoof" ) // So it forces Warpfall on all Titans like vanilla
}

void function TrimBadTitanStartSpawns( entity spawn )
{
	vector comparisonOrigin
	if ( spawn.GetTeam() == TEAM_IMC )
		comparisonOrigin = < -2144, -4944, 1999.7 >
	else
		comparisonOrigin = < 11026.8, -5163.18, 1885.64 >

	if ( Distance2D( spawn.GetOrigin(), comparisonOrigin ) >= 2000.0 )
		spawn.Destroy()
}