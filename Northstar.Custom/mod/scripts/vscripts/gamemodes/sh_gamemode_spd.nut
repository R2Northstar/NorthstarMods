global function SH_GamemodeSpd_init

global const string GAMEMODE_SPD = "spd"

void function SH_GamemodeSpd_init()
{
    // create custom gamemode
	AddCallback_OnCustomGamemodesInit( CreateGamemodeSpd )
	AddCallback_OnRegisteringCustomNetworkVars( SpdRegisterNetworkVars )
	if ( GAMETYPE != GAMEMODE_SPD )
		Sh_GGEarnMeter_Init()

}

void function CreateGamemodeSpd()
{
    GameMode_Create( GAMEMODE_SPD )
	GameMode_SetName( GAMEMODE_SPD, "#GAMEMODE_spd" )
	GameMode_SetDesc( GAMEMODE_SPD, "#PL_spd_desc" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_SPD, "ffa_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_SPD, 12, 0.0 )

    GameMode_AddScoreboardColumnData( GAMEMODE_SPD, "#SCOREBOARD_SCORE", PGS_ASSAULT_SCORE, 2 ) // score earned from being the fastest runner
    GameMode_AddScoreboardColumnData( GAMEMODE_SPD, "#TOP_SPEED", PGS_DEFENSE_SCORE, 2 ) // the players top speed throughout being the runner
    GameMode_AddScoreboardColumnData( GAMEMODE_SPD, "#RUNNER_KILLS", PGS_KILLS, 2 ) // amount of times the player has killed an enemy runner
	GameMode_AddScoreboardColumnData( GAMEMODE_SPD, "#SCOREBOARD_KILLS", PGS_PILOT_KILLS, 2 ) // general kills


	GameMode_SetColor( GAMEMODE_SPD, [147, 204, 57, 255] ) // not sure exactly where this is used but ill leave it be
	
	AddPrivateMatchMode( GAMEMODE_SPD ) // add to private lobby modes
	
	#if SERVER
		GameMode_AddServerInit( GAMEMODE_SPD, _GamemodeSpd_init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_SPD, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_SPD, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_SPD, CL_GamemodeSpd_init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_SPD, CompareScoreKillsAndTopSpeed )
	#endif
}

int function CompareScoreKillsAndTopSpeed( entity a, entity b ) // prioritises score, then pilot kills, then top speed, then entity a
{
	if (a.GetTeam() == b.GetTeam())
	{
		if ( GameRules_GetTeamScore(a.GetTeam() ) > GameRules_GetTeamScore(b.GetTeam() ) )
			return 1
		else 
			return -1
	}
	else
	{
    	int assaultScoreDiff = CompareAssault( a, b) // check if the score from being the runner is higher than entity b
    	if (assaultScoreDiff != 0)
    	    return assaultScoreDiff
	
    	int pilotKillsDiff = a.GetPlayerGameStat( PGS_PILOT_KILLS ) - b.GetPlayerGameStat( PGS_PILOT_KILLS ) // check if pilot kills is higher than entity b
    	if (pilotKillsDiff != 0) 
    	    return pilotKillsDiff / abs(pilotKillsDiff) 
	

    	int defenseScoreDiff = CompareDefense( a, b) // check if the top speed is higher than entity b
    	if (defenseScoreDiff != 0)
    	    return defenseScoreDiff
	
    	return 1 // ideally we never get to this point, but if it happens: fuck entity b, all my homies hate entity b
	}
	unreachable
}

void function SpdRegisterNetworkVars()
{
    // register all remote functions
	Remote_RegisterFunction( "ServerCallback_SpdSpeedometer_SetWeaponIcon" )
	Remote_RegisterFunction( "ServerCallback_Spd_Runner_You" )
	Remote_RegisterFunction( "ServerCallback_Spd_Runner_You_Next" )
	Remote_RegisterFunction( "ServerCallback_Spd_Runner_Teammate" )
	Remote_RegisterFunction( "ServerCallback_Spd_Runner_Teammate_Next" )
}