global function Sh_GamemodeTbag_Init

global const string GAMEMODE_TBAG = "tbag"

void function Sh_GamemodeTbag_Init()
{
	// create custom gamemode
	AddCallback_OnCustomGamemodesInit( CreateGamemodeTbag )
	AddCallback_OnRegisteringCustomNetworkVars( TbagRegisterNetworkVars )
}

void function CreateGamemodeTbag()
{
	GameMode_Create( GAMEMODE_TBAG )
	GameMode_SetName( GAMEMODE_TBAG, "#GAMEMODE_TBAG" )
	GameMode_SetDesc( GAMEMODE_TBAG, "#PL_tbag_desc" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_TBAG, "grnc_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_TBAG, 10, 0.0 )
	GameMode_AddScoreboardColumnData( GAMEMODE_TBAG, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_TBAG, "#SCOREBOARD_DEATHS", PGS_ASSAULT_SCORE, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_TBAG, "#SCOREBOARD_GAVETEABAG", PGS_TITAN_KILLS, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_TBAG, "#SCOREBOARD_DENYTEABAG", PGS_DEFENSE_SCORE, 2 )
	GameMode_SetColor( GAMEMODE_TBAG, [147, 204, 57, 255] )

	AddPrivateMatchMode( GAMEMODE_TBAG ) // add to private lobby modes

	AddPrivateMatchModeSettingArbitrary( "#PL_tbag", "floatingduration", "30" )
	AddPrivateMatchModeSettingArbitrary( "#PL_tbag", "teabagcounter", "4" )

	// set this to 25 score limit default
	GameMode_SetDefaultScoreLimits( GAMEMODE_TBAG, 25, 0 )

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_TBAG, GamemodeTbag_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_TBAG, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_TBAG, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_TBAG, ClGamemodeTbag_Init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_TBAG, CompareAssaultScore )
	#endif
}

void function TbagRegisterNetworkVars()
{
	if ( GAMETYPE != GAMEMODE_TBAG )
		return

	Remote_RegisterFunction( "ServerCallback_TeabagConfirmed" )
	Remote_RegisterFunction( "ServerCallback_TeabagDenied" )
}
