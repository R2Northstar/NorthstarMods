global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	// Load Frontier Defense Data

	print(GameRules_GetGameMode())
	if(GameRules_GetGameMode()=="fd")
        initFrontierDefenseData()
}