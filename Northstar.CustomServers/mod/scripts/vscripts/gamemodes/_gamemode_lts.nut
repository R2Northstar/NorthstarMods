global function GamemodeLts_Init

struct
{
	entity lastDamageInfoVictim
	entity lastDamageInfoAttacker
	int lastDamageInfoMethodOfDeath
	float lastDamageInfoTime

	bool shouldDoHighlights

	table<entity, int> pilotstreak
} file

void function GamemodeLts_Init()
{
	// gamemode settings
	SetSwitchSidesBased( true )
	SetGamemodeAllowsTeamSwitch( false )
	SetRoundBased( true )
	Riff_ForceSetEliminationMode( eEliminationMode.PilotsTitans )
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundWinningKillReplayKillClasses( true, true ) // both titan and pilot kills are tracked
	ScoreEvent_SetupEarnMeterValuesForTitanModes()
	SetLoadoutGracePeriodEnabled( false )
	FlagSet( "ForceStartSpawn" )

	AddCallback_OnPilotBecomesTitan( RefreshThirtySecondWallhackHighlight )
	AddCallback_OnTitanBecomesPilot( RefreshThirtySecondWallhackHighlight )

	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, 0 )

	GM_AddThirtySecondsLeftFunc( ThirtySecondsLeft )

	AddCallback_OnClientConnected( SetupPlayerLTSChallenges ) // Just to make up the Match Goals tracking
	AddCallback_OnClientDisconnected( RemovePlayerLTSChallenges ) // Safety removal of data to prevent crashes
	AddCallback_OnPlayerKilled( LTSChallengeForPlayerKilled )
}

void function SetupPlayerLTSChallenges( entity player )
{
	file.pilotstreak[ player ] <- 0
}

void function RemovePlayerLTSChallenges( entity player )
{
	if ( player in file.pilotstreak )
		delete file.pilotstreak[ player ]
}

void function LTSChallengeForPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim == attacker || !attacker.IsPlayer() || GetGameState() != eGameState.Playing )
		return

	if ( victim.IsPlayer() && attacker in file.pilotstreak )
	{
		file.pilotstreak[ attacker ]++

		if ( file.pilotstreak[ attacker ] >= 2 && !HasPlayerCompletedMeritScore( attacker ) )
		{
			AddPlayerScore( attacker, "ChallengeLTS" )
			SetPlayerChallengeMeritScore( attacker )
		}

		if ( GetPlayerArrayOfTeam_Alive( victim.GetTeam() ).len() == 1 ) // last titan on team
			PlayFactionDialogueToPlayer( "lts_playerLastTitanOnTeam", GetPlayerArrayOfTeam_Alive( victim.GetTeam() )[ 0 ] )
	}
}

void function ThirtySecondsLeft()
{
	foreach ( entity player in GetPlayerArray() )
	{
		// warn there's 30 seconds left
		Remote_CallFunction_NonReplay( player, "ServerCallback_LTSThirtySecondWarning" )

		// do inital highlight
		RefreshThirtySecondWallhackHighlight( player, player.GetPetTitan() )
	}
}

void function RefreshThirtySecondWallhackHighlight( entity player, entity titan )
{
	if ( GameTime_TimeLeftSeconds() > 30 )
		return

	if ( !Hightlight_HasEnemyHighlight( player, "enemy_sonar" ) )
		Highlight_SetEnemyHighlight( player, "enemy_sonar" ) // i think this needs a different effect, this works for now tho

	if ( IsValid( titan ) && !Hightlight_HasEnemyHighlight( titan, "enemy_sonar" ) )
		Highlight_SetEnemyHighlight( titan, "enemy_sonar" )
}
