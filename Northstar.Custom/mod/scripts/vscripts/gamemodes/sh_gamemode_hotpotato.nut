global function Sh_GamemodeHotPotato_Init

global const string GAMEMODE_HOTPOTATO = "hotpotato"

void function Sh_GamemodeHotPotato_Init()
{
	// create custom gamemode
	AddCallback_OnCustomGamemodesInit( CreateGamemodeHotPotato )
	AddCallback_OnRegisteringCustomNetworkVars( HotPotatoRegisterNetworkVars )
}

void function CreateGamemodeHotPotato()
{
	GameMode_Create( GAMEMODE_HOTPOTATO )
	GameMode_SetName( GAMEMODE_HOTPOTATO, "#GAMEMODE_HOTPOTATO" )
	GameMode_SetDesc( GAMEMODE_HOTPOTATO, "#PL_hotpotato_desc" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_HOTPOTATO, "ffa_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_HOTPOTATO, 30, 0.0 )
	GameMode_AddScoreboardColumnData( GAMEMODE_HOTPOTATO, "#SCOREBOARD_HOTPOTATOPASS", PGS_ASSAULT_SCORE, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_HOTPOTATO, "#SCOREBOARD_HOTPOTATOSURVIVED", PGS_PILOT_KILLS, 2 )
	GameMode_SetColor( GAMEMODE_HOTPOTATO, [147, 204, 57, 255] )

	GameMode_SetDefaultScoreLimits( GAMEMODE_HOTPOTATO, 12, 0 ) // set this to default max 12 player count
	AddPrivateMatchMode( GAMEMODE_HOTPOTATO ) // add to private lobby modes
	AddPrivateMatchModeSettingArbitrary( "#GAMEMODE_HOTPOTATO", "hotpotato_timer", "30.0" )

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_HOTPOTATO, GamemodeHotPotato_Init )
		GameMode_AddServerInit( GAMEMODE_HOTPOTATO, GamemodeFFAShared_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_HOTPOTATO, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_HOTPOTATO, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_HOTPOTATO, ClGamemodeHotPotato_Init )
		GameMode_AddClientInit( GAMEMODE_HOTPOTATO, GamemodeFFAShared_Init )
		GameMode_AddClientInit( GAMEMODE_HOTPOTATO, ClGamemodeFFA_Init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_HOTPOTATO, CompareAssaultScore )
		GameMode_AddSharedInit( GAMEMODE_HOTPOTATO, GamemodeFFA_Dialogue_Init )
	#endif
}

void function HotPotatoRegisterNetworkVars()
{
	if ( GAMETYPE != GAMEMODE_HOTPOTATO )
		return

	Remote_RegisterFunction( "ServerCallback_AnnounceNewMark" )
	Remote_RegisterFunction( "ServerCallback_ShowHotPotatoCountdown" )
	Remote_RegisterFunction( "ServerCallback_PassedHotPotato" )
	Remote_RegisterFunction( "ServerCallback_HotPotatoSpectator" )
	Remote_RegisterFunction( "ServerCallback_MarkedChanged" )
}
