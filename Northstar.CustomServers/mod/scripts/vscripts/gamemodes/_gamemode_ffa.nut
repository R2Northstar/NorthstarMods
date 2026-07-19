global function FFA_Init

void function FFA_Init()
{
	SetupGenericFFAChallenge()

	if ( GAMETYPE == FREE_AGENCY )
	{
		// need a way to disable passive earnmeter gain
		ScoreEvent_SetEarnMeterValues( "PilotBatteryPickup", 0.0, 0.34 )
		EarnMeterMP_SetPassiveMeterGainEnabled( false )
		PilotBattery_SetMaxCount( 3 )

		AddCallback_OnPlayerKilled(
			void function( entity victim, entity attacker, var damageInfo ) : ()
			{
				PlayerEarnMeter_Reset( victim )
			}
		)
		return
	}

	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_OnPlayerKilled( OnPlayerKilled )

	// modified for northstar
	AddCallback_OnClientConnected( OnClientConnected )
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

// modified for northstar
void function OnClientConnected( entity player )
{
	thread FFAPlayerScoreThink( player ) // good to have this! instead of DisconnectCallback this could handle a null player
}

void function FFAPlayerScoreThink( entity player )
{
	int team = player.GetTeam()

	player.WaitSignal( "OnDestroy" ) // this can handle disconnecting
	AddTeamScore( team, -GameRules_GetTeamScore( team ) )
}
