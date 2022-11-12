untyped
global function GamemodeLts_Init

struct {
	entity lastDamageInfoVictim
	entity lastDamageInfoAttacker
	int lastDamageInfoMethodOfDeath
	float lastDamageInfoTime
	
	bool shouldDoHighlights
} file

void function GamemodeLts_Init()
{
	// gamemode settings
	SetShouldUsePickLoadoutScreen( true )
	SetSwitchSidesBased( true )
	SetRoundBased( true )
	SetRespawnsEnabled( false )
	SetShouldPlayMusic( false )
	Riff_ForceSetEliminationMode( eEliminationMode.PilotsTitans )
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundWinningKillReplayKillClasses( true, true ) // both titan and pilot kills are tracked
	ScoreEvent_SetupEarnMeterValuesForTitanModes()
	SetLoadoutGracePeriodEnabled( false )
	FlagSet( "ForceStartSpawn" )

	AddCallback_OnPilotBecomesTitan( RefreshThirtySecondWallhackHighlight )
	AddCallback_OnTitanBecomesPilot( RefreshThirtySecondWallhackHighlight )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	
	SetTimeoutWinnerDecisionFunc( CheckTitanHealthForDraw )
	SetTimeoutWinnerDecisionReason( "#GAMEMODE_TITAN_DAMAGE_ADVANTAGE", "#GAMEMODE_TITAN_DAMAGE_DISADVANTAGE" )
	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )
	
	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
	AddCallback_GameStateEnter( eGameState.Playing, WaitForThirtySecondsLeft )
}

void function WaitForThirtySecondsLeft()
{
	thread WaitForThirtySecondsLeftThreaded()
}

void function WaitForThirtySecondsLeftThreaded()
{
	svGlobal.levelEnt.EndSignal( "RoundEnd" ) // end this on round end
	
	float endTime = expect float ( GetServerVar( "roundEndTime" ) )
	
	// wait until 30sec left 
	wait ( endTime - 30 ) - Time()
	//PlayMusicToAll( eMusicPieceID.LEVEL_LAST_MINUTE )
	//try using this?
	CreateTeamMusicEvent( TEAM_IMC, eMusicPieceID.LEVEL_LAST_MINUTE, Time() )
	CreateTeamMusicEvent( TEAM_MILITIA, eMusicPieceID.LEVEL_LAST_MINUTE, Time() )
	foreach( entity player in GetPlayerArray() )
		PlayCurrentTeamMusicEventsOnPlayer( player )
	
	foreach ( entity player in GetPlayerArray() )
	{	
		// warn there's 30 seconds left
		Remote_CallFunction_NonReplay( player, "ServerCallback_LTSThirtySecondWarning" )

		// do initial highlight
		//RefreshThirtySecondWallhackHighlight( player, null )
		if( IsAlive( player ) )
			thread ThirtySecondWallhackHighlightThink( player )
	}
}

void function ThirtySecondWallhackHighlightThink( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	while( true )
	{
		if( player.IsTitan() )
			Highlight_SetEnemyHighlight( player, "enemy_sonar" )
		else if( IsValid( player.GetPetTitan() ) )
			Highlight_SetEnemyHighlight( player.GetPetTitan(), "enemy_sonar" )
		WaitFrame()
	}
}

void function RefreshThirtySecondWallhackHighlight( entity player, entity titan )
{
	if ( TimeSpentInCurrentState() < expect float ( GetServerVar( "roundEndTime" ) ) - 30.0 )
		return
		
	Highlight_SetEnemyHighlight( player, "enemy_sonar" ) // i think this needs a different effect, this works for now tho
		
	if ( player.GetPetTitan() != null )
		Highlight_SetEnemyHighlight( player.GetPetTitan(), "enemy_sonar" )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	array<entity> allies = GetPlayerArrayOfTeam_Alive( victim.GetTeam() )
	int teamTitanCount
	entity latestCheckedPlayer
	foreach( entity player in allies )
	{
		if( PlayerHasTitan( player ) )
		{
			teamTitanCount += 1
			latestCheckedPlayer = player
		}
	}
	if( teamTitanCount == 1 )
	{
		if( IsValid( latestCheckedPlayer ) )
			PlayFactionDialogueToPlayer( "lts_playerLastTitanOnTeam", latestCheckedPlayer )
	}
}

int function CheckTitanHealthForDraw()
{
	int militiaTitans
	int imcTitans
	
	float militiaHealth
	float imcHealth
	
	foreach ( entity titan in GetTitanArray() )
	{
		if ( titan.GetTeam() == TEAM_MILITIA )
		{
			// doomed is counted as 0 health
			militiaHealth += titan.GetTitanSoul().IsDoomed() ? 0.0 : GetHealthFrac( titan )
			militiaTitans++
		}
		else
		{
			// doomed is counted as 0 health in this
			imcHealth += titan.GetTitanSoul().IsDoomed() ? 0.0 : GetHealthFrac( titan )
			imcTitans++
		}
	}
	
	// note: due to how stuff is set up rn, there's actually no way to do win/loss reasons outside of a SetWinner call, i.e. not in timeout winner decision
	// as soon as there is, strings in question are "#GAMEMODE_TITAN_TITAN_ADVANTAGE" and "#GAMEMODE_TITAN_TITAN_DISADVANTAGE"
	
	if ( militiaTitans != imcTitans )
		return militiaTitans > imcTitans ? TEAM_MILITIA : TEAM_IMC
	else if ( militiaHealth != imcHealth )
		return militiaHealth > imcHealth ? TEAM_MILITIA : TEAM_IMC
		
	return TEAM_UNASSIGNED
}