global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
    if(GameRules_GetGameMode()=="fd")
        initFrontierDefenseData()
}