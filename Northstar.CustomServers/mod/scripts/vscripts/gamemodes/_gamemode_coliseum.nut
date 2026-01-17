untyped

global function GamemodeColiseum_Init
global function GamemodeColiseum_CustomIntro

// outro anims
// winner anims are for the winner, loser anims are for the loser
const array< array<string> > OUTROANIMS_WINNER = [
	[ "pt_coliseum_winner_gunkick", "pt_coliseum_winner_compassion", "pt_coliseum_winner_drinking" ], // winner lost 0 rounds
	[ "pt_coliseum_winner_respect", "pt_coliseum_winner_headlock", "pt_coliseum_winner_authority" ], // winner lost 1 round
	[ "pt_coliseum_winner_punch", "pt_coliseum_winner_kick", "pt_coliseum_winner_stomp" ] // winner lost 2 rounds
]

const array< array<string> > OUTROANIMS_LOSER = [
	[ "pt_coliseum_loser_gunkick", "pt_coliseum_loser_compassion", "pt_coliseum_loser_drinking" ], // winner lost 0 rounds
	[ "pt_coliseum_loser_respect", "pt_coliseum_loser_headlock", "pt_coliseum_loser_authority" ], // winner lost 1 round
	[ "pt_coliseum_loser_punch", "pt_coliseum_loser_kick", "pt_coliseum_loser_stomp" ], // winner lost 2 rounds
]

struct
{
	bool hasShownIntroScreen
} file

void function GamemodeColiseum_Init()
{
	// gamemode settings
	SetRoundBased( true )
	SetShouldUseRoundWinningKillReplay( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetSpectatorEnabled( false ) // stops players from spectating on death and in outro
	SetPrivateMatchSpectatorEnabled( false ) // private match spectator doesn't work well
	FlagClear( "WeaponDropsAllowed" ) // removes all dropped weapons

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, 8.5 )
	AddCallback_GameStateEnter( eGameState.Prematch, ShowColiseumIntroScreen )

	ClassicMP_SetEpilogue( SetupColiseumEpilogue )
}

// stub function referenced in sh_gamemodes_mp
void function GamemodeColiseum_CustomIntro( entity player )
{
}

void function ShowColiseumIntroScreen()
{
	if ( !file.hasShownIntroScreen )
		thread ShowColiseumIntroScreenThreaded()

	file.hasShownIntroScreen = true
}

void function ShowColiseumIntroScreenThreaded()
{
	wait 2.5

	foreach ( entity player in GetPlayerArray() )
	{
		array<entity> otherTeam = GetPlayerArrayOfTeam( GetOtherTeam( player.GetTeam() ) )

		foreach ( entity player in otherTeam )
			if ( IsPrivateMatchSpectator( player ) )
				otherTeam.removebyvalue( player )

		int winstreak = 0
		int wins = 0 
		int losses = 0

		if ( otherTeam.len() )
		{
			entity enemy = otherTeam.getrandom()

			winstreak = enemy.GetPersistentVarAsInt( "coliseumWinStreak" )
			wins = enemy.GetPersistentVarAsInt( "coliseumTotalWins" )
			losses = enemy.GetPersistentVarAsInt( "coliseumTotalLosses" )
		}

		Remote_CallFunction_NonReplay( player, "ServerCallback_ColiseumIntro", winstreak, wins, losses ) // stub numbers atm because lazy
	}
}

void function SetupColiseumEpilogue()
{
	AddCallback_GameStateEnter( eGameState.Epilogue, RunColiseumOutro )
}

void function RunColiseumOutro()
{
	entity outroAnimPoint = GetEnt( "intermission" )

	if ( !GetPlayerArray().len() || !IsValid( outroAnimPoint ) || !IsIMCOrMilitiaTeam( GetWinningTeam() ) )
	{
		SetGameState( eGameState.Postmatch )
		return
	}

	// also since this runs on game end, do winstreak stuff
	foreach ( entity player in GetPlayerArray() )
	{
		if ( GetWinningTeam() == player.GetTeam() )
		{
			player.SetPersistentVar( "coliseumTotalWins", player.GetPersistentVarAsInt( "coliseumTotalWins" ) + 1 )
			player.SetPersistentVar( "coliseumWinStreak", player.GetPersistentVarAsInt( "coliseumWinStreak" ) + 1 )
		}
		else
		{
			player.SetPersistentVar( "coliseumTotalLosses", player.GetPersistentVarAsInt( "coliseumTotalLosses" ) + 1 )
			player.SetPersistentVar( "coliseumWinStreak", 0 )
		}
	}

	WaitFrame()

	array<entity> winningPlayers = GetPlayerArrayOfTeam( GetWinningTeam() )
	array<entity> losingPlayers = GetPlayerArrayOfTeam( GetOtherTeam( GetWinningTeam() ) )

	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsPrivateMatchSpectator( player ) )
			continue

		if ( winningPlayers.contains( player ) )
			winningPlayers.removebyvalue( player )

		if ( losingPlayers.contains( player ) )
			losingPlayers.removebyvalue( player )
	}

	entity winningPlayer = null
	entity losingPlayer = null

	if ( winningPlayers.len() )
		winningPlayer = winningPlayers.getrandom()

	if ( losingPlayers.len() )
		losingPlayer = losingPlayers.getrandom()

	if ( IsValid( winningPlayer ) && IsValid( losingPlayer ) ) // this will fail if we don't have players
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( IsPrivateMatchSpectator( player ) )
				continue

			if ( !IsAlive( player ) )
			{
				DoRespawnPlayer( player, null )
				delaythread ( 0.0001 ) EnableDemigod( player )
			}
			else
				EnableDemigod( player )

			HolsterViewModelAndDisableWeapons( player )

			player.SetOrigin( OriginToGround( outroAnimPoint.GetOrigin() ) )
			player.SetNameVisibleToEnemy( false )
			player.SetNameVisibleToFriendly( false )

			if ( player != winningPlayer && player != losingPlayer )
				player.kv.VisibilityFlags = ~ENTITY_VISIBLE_TO_EVERYONE
		}

		thread RunColiseumOutroThreaded( winningPlayer, losingPlayer )
	}
	else
		SetGameState( eGameState.Postmatch )
}

void function RunColiseumOutroThreaded( entity winningPlayer, entity losingPlayer )
{
	OnThreadEnd
	(
		function() : ( losingPlayer )
		{
			if ( IsValid( losingPlayer ) )
				losingPlayer.ClearParent()

			SetGameState( eGameState.Postmatch )
		}
	)

	winningPlayer.EndSignal( "OnDestroy" )

	losingPlayer.EndSignal( "OnDestroy" )

	// pick winner and loser anims
	int numLost = min( 2, GameRules_GetTeamScore( GetOtherTeam( GetWinningTeam() ) ) ).tointeger()
	int animIndex = RandomInt( OUTROANIMS_WINNER[ numLost ].len() )

	if ( !( animIndex in OUTROANIMS_LOSER[ numLost ] ) )
		return

	string winnerAnim = OUTROANIMS_WINNER[ numLost ][ animIndex ]
	string loserAnim = OUTROANIMS_LOSER[ numLost ][ animIndex ]

	FirstPersonSequenceStruct winnerSequence

	winnerSequence.thirdPersonAnim = winnerAnim

	entity winningPlayerWeapon = winningPlayer.GetActiveWeapon()

	if ( IsValid( winningPlayerWeapon ) )
		winningPlayerWeapon.Destroy()

	thread FirstPersonSequence( winnerSequence, winningPlayer )

	FirstPersonSequenceStruct loserSequence

	loserSequence.thirdPersonAnim = loserAnim
	loserSequence.attachment = "REF"
	loserSequence.useAnimatedRefAttachment = true

	entity losingPlayerWeapon = losingPlayer.GetActiveWeapon()

	if ( IsValid( losingPlayerWeapon ) && loserAnim != "pt_coliseum_loser_gunkick" )
		losingPlayerWeapon.Destroy()

	thread FirstPersonSequence( loserSequence, losingPlayer, winningPlayer )

	foreach ( entity player in GetPlayerArray() )
	{
		AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
		ScreenFadeFromBlack( player, 0.5 )

		// for some reason this just doesn't use the mp music system, so have to manually play this
		// odd game

		EmitSoundOnEntityOnlyToPlayer( player, player, "music_mp_speedball_game_win" )

		SetPlayerAnimViewEntity( player, winningPlayer )

		player.AnimViewEntity_SetThirdPersonCameraAttachments( [ "VDU" ] )
	}

	// all outro anims should be the same length ideally
	wait winningPlayer.GetSequenceDuration( winnerAnim ) - 0.75

	foreach ( entity player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, 0.3 )

	wait 0.5
}