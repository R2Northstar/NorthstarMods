global function GamemodeTTDM_Init

struct
{
	table<entity, int> challengeCount
} file

void function GamemodeTTDM_Init()
{
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never )
	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetLoadoutGracePeriodEnabled( false )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( SetupPlayerTTDMChallenges ) // Just to make up the Match Goals tracking
	AddCallback_OnClientDisconnected( RemovePlayerTTDMChallenges ) // Safety removal of data to prevent crashes
	AddCallback_OnPlayerKilled( AddTeamScoreForPlayerKilled ) // dont have to track autotitan kills since you cant leave your titan in this mode
	// probably needs scoreevent earnmeter values
}

void function SetupPlayerTTDMChallenges( entity player )
{
	file.challengeCount[ player ] <- 0
}

void function RemovePlayerTTDMChallenges( entity player )
{
	if ( player in file.challengeCount )
		delete file.challengeCount[ player ]
}

void function AddTeamScoreForPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim == attacker || !victim.IsPlayer() || !attacker.IsPlayer() && GetGameState() == eGameState.Playing )
		return

	if ( victim in file.challengeCount )
		file.challengeCount[ victim ] = 0

	if ( attacker in file.challengeCount )
	{
		file.challengeCount[ attacker ]++
		if ( file.challengeCount[ attacker ] >= 2 && !HasPlayerCompletedMeritScore( attacker ) )
		{
			AddPlayerScore( attacker, "ChallengeTTDM" )
			SetPlayerChallengeMeritScore( attacker )
		}
	}

	AddTeamScore( GetOtherTeam( victim.GetTeam() ), 1 )
}
