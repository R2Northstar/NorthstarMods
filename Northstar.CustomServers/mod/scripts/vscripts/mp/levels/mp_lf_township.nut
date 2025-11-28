global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	SetupLiveFireMaps()
	
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}