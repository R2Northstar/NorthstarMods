global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	//Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
	else
		ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
}