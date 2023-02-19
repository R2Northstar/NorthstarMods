global function FFA_Init

void function FFA_Init()
{
	ClassicMP_ForceDisableEpilogue( true )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_OnPlayerKilled( OnPlayerKilled )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() && GetGameState() == eGameState.Playing )
	{
		AddTeamScore( attacker.GetTeam(), 1 )
		// why isn't this PGS_SCORE? odd game
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
	}
}

void function FFAPlayerScoreThink( entity player )
{
	int team = player.GetTeam()

	player.WaitSignal( "OnDestroy" ) // this can handle disconnecting
	AddTeamScore( team, -GameRules_GetTeamScore( team ) )
}