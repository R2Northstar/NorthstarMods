global function Sh_GamemodePVB_Init

global const GAMEMODE_PVB = "pvb"

void function Sh_GamemodePVB_Init()
{
	// create custom gamemode
	AddCallback_OnCustomGamemodesInit( CreateGamemodePVB )
	AddCallback_OnRegisteringCustomNetworkVars( PvbRegisterNetworkVars )
}

void function CreateGamemodePVB()
{
    GameMode_Create( GAMEMODE_PVB )
    GameMode_SetName( GAMEMODE_PVB, "#GAMEMODE_PVB" )
    GameMode_SetDesc( GAMEMODE_PVB, "#PL_pvb_desc" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_PVB, "ffa_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_PVB, 3, 0.0 )
	GameMode_AddScoreboardColumnData( GAMEMODE_PVB, "#PVB_BOSS_DMG", PGS_ASSAULT_SCORE, 4 )
	GameMode_AddScoreboardColumnData( GAMEMODE_PVB, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2 )
	GameMode_SetColor( GAMEMODE_PVB, [147, 204, 57, 255] )

	AddPrivateMatchMode( GAMEMODE_PVB ) // add to private lobby modes

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_PVB, GamemodePVB_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_PVB, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_PVB, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_PVB, ClGamemodePVB_Init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_PVB, CompareAssaultScore )
	#endif
}

void function PvbRegisterNetworkVars()
{
	if ( GAMETYPE != GAMEMODE_PVB )
		return

	Remote_RegisterFunction( "ServerCallback_YouAreBoss" )
	Remote_RegisterFunction( "ServerCallback_AnnounceBoss" )
	Remote_RegisterFunction( "ServerCallback_YouAreAmped" )
	Remote_RegisterFunction( "ServerCallback_AnnounceAmped" )
	Remote_RegisterFunction( "ServerCallback_AnnounceAmpedToBoss" )
}