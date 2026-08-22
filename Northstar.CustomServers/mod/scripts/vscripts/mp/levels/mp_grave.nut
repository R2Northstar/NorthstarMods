global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	// Load Frontier Defense Data
	if ( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()

	FlagSet( "LevelHasRoof" ) // So it forces Warpfall on all Titans like vanilla
}
