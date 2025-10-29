void function CodeCallback_MapInit()
{
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == "fd" )
		initFrontierDefenseData()
}