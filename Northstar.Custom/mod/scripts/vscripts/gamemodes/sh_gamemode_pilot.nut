global function Sh_GamemodePilot_Init

global const string GAMEMODE_PILOT = "pilot"

void function Sh_GamemodePilot_Init()
{
	// create custom gamemode
	AddCallback_OnCustomGamemodesInit( CreateGamemodePilot )
	AddCallback_OnRegisteringCustomNetworkVars( PilotRegisterNetworkVars )
}

void function CreateGamemodePilot()
{
	GameMode_Create( GAMEMODE_PILOT )
	GameMode_SetName( GAMEMODE_PILOT, "The Pilot" )
	GameMode_SetDesc( GAMEMODE_PILOT, "There is one Pilot, and many grunts. Together, grunts can take down a pilot. Alone? The Pilot will destroy you." )
	GameMode_SetGameModeAnnouncement( GAMEMODE_PILOT, "ffa_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_PILOT, 5, 0.0 )
	GameMode_AddScoreboardColumnData( GAMEMODE_PILOT, "#SCOREBOARD_SCORE", PGS_ASSAULT_SCORE, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_PILOT, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2 )
	GameMode_SetColor( GAMEMODE_PILOT, [147, 204, 57, 255] )

	AddPrivateMatchMode( GAMEMODE_PILOT ) // add to private lobby modes

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_PILOT, GamemodePilot_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_PILOT, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_PILOT, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_PILOT, ClGamemodePilot_Init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_PILOT, CompareAssaultScore )
	#endif
}

void function PilotRegisterNetworkVars()
{
	if ( GAMETYPE != GAMEMODE_PILOT )
		return

	Remote_RegisterFunction( "ServerCallback_YouArePilot" )
	Remote_RegisterFunction( "ServerCallback_AnnouncePilot" )
}
