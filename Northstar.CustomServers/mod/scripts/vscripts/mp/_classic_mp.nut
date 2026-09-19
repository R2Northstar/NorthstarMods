global function ClassicMp_Init
global function ClassicMP_TryDefaultIntroSetup
global function OnDropshipStartSpawn
global function GetDropshipStartSpawnsForTeam
global function ClassicMP_IsLevelSetupForIntro
global function ClassicMP_CanUseIntroStartSpawn
global function ClassicMP_CallIntroPlayerSpawnFunc
global function ClassicMP_CallPrematchSpawnPlayersFunc
global function ClassicMP_CallIntroLevelSetupFunc
global function ClassicMP_SetIntroPlayerSpawnFunc
global function ClassicMP_SetPrematchSpawnPlayersFunc
global function ClassicMP_SetIntroLevelSetupFunc
global function AddPlayerToDropshipSpawnPlayerList
global function RemovePlayerFromDropshipSpawnPlayerList
global function ClearDropshipSpawnPlayerList
global function ClearClassicDropships
global function PlayJumpoutAnims
global function CanSpawnIntoIntroDropship
global function DisableDropshipSpawnForTeam
global function EnableDropshipSpawnForTeam
global function SpawnPlayerIntoSlotInDropship
global function DebugTestDropshipStartSpawns
global function DebugTestDropshipSpecificSpawn
global function SetCustomPlayerDropshipSpawn
global function DebugTestDropshipStartSpawnsForAll
global function DebugTestCustomDropshipSpawn
global function PlayerSpawnDropship_RunSpawnCallbacks
global function ClassicMP_TryPlayerIntroSpawn
global function AddCallback_OnWaveSpawnDropshipSpawned
global function GetDropshipIntroAnimation

global array<string> dropshipIdleAnimsList = [
	"Classic_MP_flyin_exit_playerA_idle",
	"Classic_MP_flyin_exit_playerB_idle",
	"Classic_MP_flyin_exit_playerC_idle",
	"Classic_MP_flyin_exit_playerD_idle"
]

global array<string> dropshipIdlePOVAnimsList = [
	"Classic_MP_flyin_exit_povA_idle",
	"Classic_MP_flyin_exit_povB_idle",
	"Classic_MP_flyin_exit_povC_idle",
	"Classic_MP_flyin_exit_povD_idle"
]

global array<string> dropshipJumpAnimsList = [
	"Classic_MP_flyin_exit_playerA_jump",
	"Classic_MP_flyin_exit_playerB_jump",
	"Classic_MP_flyin_exit_playerC_jump",
	"Classic_MP_flyin_exit_playerD_jump"
]

global array<string> dropshipJumpPOVAnimsList = [
	"Classic_MP_flyin_exit_povA_jump",
	"Classic_MP_flyin_exit_povB_jump",
	"Classic_MP_flyin_exit_povC_jump",
	"Classic_MP_flyin_exit_povD_jump"
]

const int DROPSHIP_SEAT = 0 // For paul to switch seats on dropship, set 0-7

struct
{
	table<int, bool> dropshipDisabledTeams = {}
	table<int, array<entity> > dropshipSpawnPlayerList = {}
	float dropshipSpawnTime = -1
	bool functionref( entity ) classicMP_introPlayerSpawnFunc = null
	bool functionref( array<entity> ) classicMP_prematchSpawnPlayersFunc = null
	bool functionref() classicMP_introLevelSetupFunc = null
	array<entity> dropship_start_spawns = []
	table<int, array> customDropshipSpawns = {}
	bool debugTestingSpawns = false
} file

void function ClassicMp_Init()
{
	if ( reloadingScripts )
		return

	level.canStillSpawnIntoIntro <- false
	level.classicMP_levelSetupForIntro <- false
	level.classicMPDropships <- { [TEAM_IMC] = [], [TEAM_MILITIA] = [] }

	// Players on this list will spawn on a dropship at start of classic MP or for wave respawn
	for ( int i = 0; i < TEAM_COUNT; ++i )
		file.dropshipSpawnPlayerList[ i ] <- []

	FlagInit( "ClassicMP_UsingCustomIntro", false )
	FlagInit( "GameModeAlwaysAllowsClassicIntro", true )
}

// ---- CLASSIC MP DROPSHIP INTRO FUNCTIONS (DEFAULT) ----
// called from _mapspawn after level scripts have inited
void function ClassicMP_TryDefaultIntroSetup()
{
	Assert( IsMultiplayerPlaylist() )

	// If player spawn function hasn't been set yet, we know we have to use the default dropship intro setup
	if ( file.classicMP_introPlayerSpawnFunc != null )
	{
		FlagSet( "ClassicMP_UsingCustomIntro" )
		printt( "ClassicMP_TryDefaultIntroSetup: Not doing dropship intro for classic MP" )
		return
	}

	// ---- CALLBACKS AND CUSTOM POINTERS FOR THIS INTRO STYLE ----
	AddSpawnCallback( "info_spawnpoint_dropship_start", OnDropshipStartSpawn )
	AddCallback_GameStateEnter( eGameState.SwitchingSides, ClearClassicDropships )
	AddCallback_GameStateEnter( eGameState.Prematch, ClassicMP_Dropship_PrematchCallback )

	if ( IsRoundBased() && Flag( "GameModeAlwaysAllowsClassicIntro" ) )
		AddCallback_GameStateEnter( eGameState.WinnerDetermined, ClearClassicDropships )

	ClassicMP_SetIntroLevelSetupFunc( ClassicMP_Dropship_IntroLevelSetupFunc )
	ClassicMP_SetIntroPlayerSpawnFunc( ClassicMP_DropshipIntro_IntroPlayerSpawnFunc ) // all players (including late connectors) run this one
	ClassicMP_SetPrematchSpawnPlayersFunc( ClassicMP_DropshipIntro_PrematchSpawnPlayersFunc ) // run when prematch starts- only applies for players connected by then. (Prematch state happens more than once in round based games)

	AddCallback_OnClientConnected( ClassicMP_DropshipIntro_OnClientConnectedFunc )
	AddCallback_OnClientDisconnected( RemovePlayerFromDropshipSpawnPlayerList )
}

bool function ClassicMP_Dropship_IntroLevelSetupFunc()
{
	// move spawnpoint to custom locations if they have been changed
	CustomPlayerDropshipSpawn()

	// If riffs are set to be a Titan immediately, just drop in as a titan
	if ( ShouldIntroSpawnAsTitan() )
		return false

	// only support gamemodes with less than 3 teams
	if ( IsFFAGame() )
		return false

	// these are pruned by GameModeRemove()
	array<entity> imcSpawns = GetDropshipStartSpawnsForTeam( TEAM_IMC )
	array<entity> militiaSpawns = GetDropshipStartSpawnsForTeam( TEAM_MILITIA )

	// Assume 2 on each team. This restriction can be loosened later ( might want to randomize, etc )
	if ( imcSpawns.len() != 2 )
	{
		Warning( "IMC Dropship start spawnpoints not equal to 2! Not using DropshipStartSpawn" )
		return false
	}

	if ( militiaSpawns.len() != 2 )
	{
		Warning( "Militia Dropship start spawnpoints not equal to 2! Not using DropshipStartSpawn" )
		return false
	}

	return true
}

bool function ClassicMP_DropshipIntro_IntroPlayerSpawnFunc( entity player )
{
	if ( !CanSpawnIntoIntroDropship( player ) )
		return false

	Assert( GetGameState() != eGameState.Playing )

	if ( !PlayerWillSpawnOnDropship( player ) )
		return false

	SpawnPlayerIntoSlotInDropship( player )

	Assert( !PlayerWillSpawnOnDropship( player ) )

	return true
}

bool function ClassicMP_DropshipIntro_PrematchSpawnPlayersFunc( array<entity> players )
{
	if ( !ClassicMP_CanUseIntroStartSpawn() )
		return false

	TryStartSpawnPlayersIntoDropship( players )

	return true
}

void function ClassicMP_DropshipIntro_OnClientConnectedFunc( entity player )
{
	if ( !CanSpawnIntoIntroDropship( player ) )
		return

	if ( GetGameState() >= eGameState.Prematch )
		return

	AddPlayerToDropshipSpawnPlayerList( player )
}

void function OnDropshipStartSpawn( entity spawnPoint )
{
	if ( GameModeRemove( spawnPoint ) )
		return

	file.dropship_start_spawns.append( spawnPoint )
}

array<entity> function GetDropshipStartSpawnsForTeam( int team )
{
	array<entity> teamDropshipSpawns = []

	ArrayRemoveDead( file.dropship_start_spawns )

	foreach ( entity spawnpoint in file.dropship_start_spawns )
	{
		if ( spawnpoint.GetTeam() != team )
			continue

		teamDropshipSpawns.append( spawnpoint )
	}

	return teamDropshipSpawns
}

bool function ClassicMP_IsLevelSetupForIntro()
{
	Assert( IsMultiplayerPlaylist() )

	// return level.classicMP_introSetupDone
	return expect bool( level.classicMP_levelSetupForIntro )
}

bool function ClassicMP_CanUseIntroStartSpawn()
{
	Assert( IsMultiplayerPlaylist() )

	if ( !ClassicMP_IsLevelSetupForIntro() )
		return false

	if ( GetGameState() > eGameState.Prematch )
		return false

	// gets set to true in _gamestate::EntitiesDidLoad() if intro setup is successful
	if ( !level.canStillSpawnIntoIntro )
		return false

	return true
}

// ========== CLASSIC MP INTRO CALLBACKS ==========
bool function ClassicMP_CallIntroPlayerSpawnFunc( entity player )
{
	Assert( IsMultiplayerPlaylist() )

	bool functionref( entity ) callbackFunc = file.classicMP_introPlayerSpawnFunc

	if ( callbackFunc != null )
		return callbackFunc( player )

	return false
}

bool function ClassicMP_CallPrematchSpawnPlayersFunc( array<entity> players )
{
	Assert( IsMultiplayerPlaylist() )

	bool functionref( array<entity> ) callbackFunc = file.classicMP_prematchSpawnPlayersFunc

	if ( callbackFunc != null )
		return callbackFunc( players )

	return false
}

bool function ClassicMP_CallIntroLevelSetupFunc()
{
	Assert( IsMultiplayerPlaylist() )

	bool functionref() callbackFunc = file.classicMP_introLevelSetupFunc

	if ( callbackFunc != null )
		return callbackFunc()

	return false
}

void function ClassicMP_SetIntroPlayerSpawnFunc( bool functionref( entity ) func )
{
	Assert( IsMultiplayerPlaylist() )

	file.classicMP_introPlayerSpawnFunc = func
}

void function ClassicMP_SetPrematchSpawnPlayersFunc( bool functionref( array<entity> ) func )
{
	Assert( IsMultiplayerPlaylist() )

	file.classicMP_prematchSpawnPlayersFunc = func
}

// setup your function to return false if a level isn't correctly set up to support the intro
void function ClassicMP_SetIntroLevelSetupFunc( bool functionref() func )
{
	Assert( IsMultiplayerPlaylist() )

	file.classicMP_introLevelSetupFunc = func
}

void function AddPlayerToDropshipSpawnPlayerList( entity player )
{
	int team = player.GetTeam()

	file.dropshipSpawnPlayerList[ team ].append( player )
}

void function RemovePlayerFromDropshipSpawnPlayerList( entity player )
{
	int team = player.GetTeam()

	if ( team == TEAM_SPECTATOR )
		return

	for ( int i = 0; i < TEAM_COUNT; ++i )
	{
		array<entity> dropshipPlayers = file.dropshipSpawnPlayerList[ i ]

		foreach ( entity dropshipPlayer in dropshipPlayers )
			if ( dropshipPlayer == player )
				file.dropshipSpawnPlayerList[ i ].removebyvalue( dropshipPlayer )
	}
}

void function UpdateDropshipSpawnPlayerList()
{
	for ( int i = 0; i < TEAM_COUNT; ++i )
	{
		array<entity> players = file.dropshipSpawnPlayerList[ i ]

		foreach ( entity player in players )
		{
			if ( player.GetTeam() != i )
			{
				file.dropshipSpawnPlayerList[ i ].removebyvalue( player )

				AddPlayerToDropshipSpawnPlayerList( player )
			}
		}
	}
}

void function ClearDropshipSpawnPlayerList( int ornull team = null )
{
	if ( team != null )
	{
		expect int( team )

		Assert( team == TEAM_IMC || team == TEAM_MILITIA, "team must be IMC or Militia" )

		file.dropshipSpawnPlayerList[ team ].clear()
	}
	else
	{
		level.canStillSpawnIntoIntro = false // Used as a defensive fix against 1 frame stuff.

		file.dropshipSpawnPlayerList[ TEAM_IMC ].clear()
		file.dropshipSpawnPlayerList[ TEAM_MILITIA ].clear()
	}
}

void function ClearClassicDropships()
{
	if ( expect array( expect table( level.classicMPDropships )[ TEAM_IMC ] ).clear() )
	{
	}

	if ( expect array( expect table( level.classicMPDropships )[ TEAM_MILITIA ] ).clear() )
	{
	}
}

void function ClassicMP_Dropship_PrematchCallback()
{
	if ( Flag( "GameModeAlwaysAllowsClassicIntro" ) )
		level.canStillSpawnIntoIntro = true // For later rounds, toggle this to see the dropship intro again

	// by default, classic MP clears the custom intro length after the first time it runs
	if ( ClassicMP_CanUseIntroStartSpawn() && !ShouldIntroSpawnAsTitan() && !IsFFAGame() ) // Spawning as titan and ffa uses default intro length and
		SetCustomIntroLength( 15.0 ) // affects gamestate switch to "playing"
}

bool function PlayerWillSpawnOnDropship( entity player )
{
	if ( !level.canStillSpawnIntoIntro )
		return false

	UpdateDropshipSpawnPlayerList()

	return !( file.dropshipSpawnPlayerList[ player.GetTeam() ].contains( player ) )
}

void function TryStartSpawnPlayersIntoDropship( array<entity> players )
{
	string dropshipAnimation = GetDropshipIntroAnimation()

	delaythread( GetAnimEventTime( DROPSHIP_MODEL, dropshipAnimation, "dropship_deploy" ) + 0.05 ) ClearDropshipSpawnPlayerList() // Clear out the players that are on this list after the window for spawning on the dropship has passed

	file.dropshipSpawnTime = Time()

	// these are pruned by GameModeRemove()
	array<entity> militiaSpawns = GetDropshipStartSpawnsForTeam( TEAM_MILITIA )
	array<entity> imcSpawns = GetDropshipStartSpawnsForTeam( TEAM_IMC )

	SpawnTeamPlayersIntoDropships( TEAM_MILITIA, militiaSpawns, -1, dropshipAnimation )
	SpawnTeamPlayersIntoDropships( TEAM_IMC, imcSpawns, -1, dropshipAnimation )

	foreach ( entity player in players )
		player.UnfreezeControlsOnServer()
}

// Taken from Angel City pretty much
void function SpawnTeamPlayersIntoDropships( int team, array<entity> dropshipSpawns, int seatOverride = -1, string dropshipAnimation = "dropship_classic_mp_flyin" )
{
	array<FirstPersonSequenceStruct> idleAnims = []

	// third person, first person, yaw offset

	FirstPersonSequenceStruct sequence

	sequence.firstPersonAnim = dropshipIdlePOVAnimsList[ 0 ]
	sequence.thirdPersonAnim = dropshipIdleAnimsList[ 0 ]
	sequence.attachment = "ORIGIN"
	sequence.blendTime = 0.0
	sequence.hideProxy = true
	sequence.viewConeFunction = ViewConeRampFree

	idleAnims.append( clone sequence )

	sequence.firstPersonAnim = dropshipIdlePOVAnimsList[ 1 ]
	sequence.thirdPersonAnim = dropshipIdleAnimsList[ 1 ]

	idleAnims.append( clone sequence )

	sequence.firstPersonAnim = dropshipIdlePOVAnimsList[ 2 ]
	sequence.thirdPersonAnim = dropshipIdleAnimsList[ 2 ]

	idleAnims.append( clone sequence )

	sequence.firstPersonAnim = dropshipIdlePOVAnimsList[ 3 ]
	sequence.thirdPersonAnim = dropshipIdleAnimsList[ 3 ]

	idleAnims.append( clone sequence )

	array<FirstPersonSequenceStruct> jumpAnims = []

	sequence.firstPersonAnim = dropshipJumpPOVAnimsList[ 0 ]
	sequence.thirdPersonAnim = dropshipJumpAnimsList[ 0 ]

	jumpAnims.append( clone sequence )

	sequence.firstPersonAnim = dropshipJumpPOVAnimsList[ 1 ]
	sequence.thirdPersonAnim = dropshipJumpAnimsList[ 1 ]

	jumpAnims.append( clone sequence )

	sequence.firstPersonAnim = dropshipJumpPOVAnimsList[ 2 ]
	sequence.thirdPersonAnim = dropshipJumpAnimsList[ 2 ]

	jumpAnims.append( clone sequence )

	sequence.firstPersonAnim = dropshipJumpPOVAnimsList[ 3 ]
	sequence.thirdPersonAnim = dropshipJumpAnimsList[ 3 ]

	jumpAnims.append( clone sequence )

	UpdateDropshipSpawnPlayerList()

	array<entity> players = file.dropshipSpawnPlayerList[ team ]
	array<entity> ship1Players = []
	array<entity> ship2Players = []

	if ( seatOverride == -1 )
		seatOverride = DROPSHIP_SEAT

	if ( seatOverride > 0 && players.len() == 1 )
	{
		// debugging dropship seats
		Assert( seatOverride >= 0 && seatOverride < 8, "Illegal seatOverride value " + seatOverride )

		if ( seatOverride < 4 )
			ship1Players.append( players[ 0 ] )
		else
			ship2Players.append( players[ 0 ] )
	}
	else
	{
		for ( int i = 0; i < 4; i++ )
		{
			if ( i >= players.len() )
				break

			ship1Players.append( players[ i ] )
		}

		for ( int i = 4; i < 8; i++ ) // Assuming we never have more than 8 players...
		{
			if ( i >= players.len() )
				break

			ship2Players.append( players[ i ] )
		}
	}

	thread SpawnDropshipAndPlayers(
		team,
		0.0,
		dropshipSpawns[ 0 ].GetOrigin(),
		dropshipSpawns[ 0 ].GetAngles(),
		idleAnims,
		jumpAnims,
		ship1Players,
		dropshipAnimation,
		seatOverride
	)
	thread SpawnDropshipAndPlayers(
		team,
		0.0,
		dropshipSpawns[ 1 ].GetOrigin(),
		dropshipSpawns[ 1 ].GetAngles(),
		idleAnims,
		jumpAnims,
		ship2Players,
		dropshipAnimation,
		seatOverride
	)
}

void function SpawnDropshipAndPlayers( int team, float initialTime, vector origin, vector angles, array<FirstPersonSequenceStruct> idleAnims, array<FirstPersonSequenceStruct> jumpAnims, array<entity> players, string anim, int seatOverride )
{
	asset model = $""

	if ( team == TEAM_IMC )
		model = $"models/vehicle/goblin_dropship/goblin_dropship_hero.mdl"
	else if ( team == TEAM_MILITIA )
		model = $"models/vehicle/crow_dropship/crow_dropship_hero.mdl"

	entity ship = CreateDropship( team, origin, angles )

	ship.SetValueForModelKey( model )

	DispatchSpawn( ship )

	ship.SetModel( model )

	if ( expect array( expect table( level.classicMPDropships )[ team ] ).append( ship ) )
	{
	}

	for ( int i = 0; i < players.len(); i++ )
	{
		entity player = players[ i ]

		FirstPersonSequenceStruct idleAnim
		FirstPersonSequenceStruct jumpAnim

		if ( seatOverride > 0 )
		{
			idleAnim = idleAnims[ seatOverride % 4 ]
			jumpAnim = jumpAnims[ seatOverride % 4 ]
		}
		else
		{
			idleAnim = idleAnims[ i ]
			jumpAnim = jumpAnims[ i ]
		}

		thread SpawnPlayerIntoDropship( ship, player, idleAnim, jumpAnim )
	}

	PlayerSpawnDropship_RunSpawnCallbacks( ship, anim )

	thread PlayAnim( ship, anim, origin, angles )

	ship.Anim_SetInitialTime( initialTime )

	WaittillAnimDone( ship )

	ClearClassicDropships()
}

void function SpawnPlayerIntoDropship( entity ship, entity player, FirstPersonSequenceStruct idleAnim, FirstPersonSequenceStruct jumpAnim, bool waveSpawn = false )
{
	if ( file.debugTestingSpawns && player.IsBot() )
		return

	// spawns player into a ride, and plays a sequence
	// dont show hud during intro
	if ( waveSpawn )
		AddCinematicFlag( player, CE_FLAG_WAVE_SPAWNING )
	else
		AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	if ( !file.debugTestingSpawns ) // Check to see if we are testing spawns, if we are, don't respawn them.
		DoRespawnPlayer( player, null )

	if ( waveSpawn )
		SetWaveSpawnProtection( player )

	thread void function() : ( player, waveSpawn )
	{
		player.EndSignal( "OnDestroy" )

		WaitEndFrame()

		HolsterViewModelAndDisableWeapons( player )

		if ( waveSpawn )
			ScreenFadeFromBlack( player )
		else
			ScreenFadeFromBlack( player, 1.0, 1.0 )
	}()

	player.SetIsValidChaseObserverTarget( false )
	player.LerpSkyScale( 0.9, 0.1 )

	if ( !waveSpawn )
		Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnFactionCommanderInDropship", ship.GetEncodedEHandle(), file.dropshipSpawnTime )

	Remote_CallFunction_Replay( player, "ServerCallback_SetClassicSkyScale", ship.GetEncodedEHandle(), 0.7 )

	AddAnimEvent(
		player,
		"SkyScaleDefault",
		void function( entity player ) : ( ship )
		{
			SkyScaleDefault( player )

			if ( !IsValid( ship ) )
				return

			Remote_CallFunction_Replay( player, "ServerCallback_ResetClassicSkyScale", ship.GetEncodedEHandle() )
		}
	)

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.SetIsValidChaseObserverTarget( true )

				DeleteAnimEvent( player, "SkyScaleDefault" )

				thread ClearWaveSpawnProtectionOnPrimaryAttackOrDelay( player, WAVESPAWN_PROTECTION_TIME )

				DeployViewModelAndEnableWeapons( player )
			}
		}
	)

	// we're about to start our animation logic - bring out the gun on a delayed beat
	if ( waveSpawn )
		thread DelayedWeaponDeploy( player )

	thread FirstPersonSequence( idleAnim, player, ship )

	if ( idleAnim.viewConeFunction != ViewConeRampFree && idleAnim.viewConeFunction != ViewConeFree )
	{
		ViewConeZeroInstant( player )

		WaitFrame()

		idleAnim.viewConeFunction( player )
	}
	else
		player.PlayerCone_SetLerpTime( 0 )

	ship.WaitSignal( "deploy" )

	#if BATTLECHATTER_ENABLED
		array<entity> otherPlayers
		int team = player.GetTeam()

		foreach ( entity dropshipPlayer in file.dropshipSpawnPlayerList[ team ] )
			if ( dropshipPlayer != player && dropshipPlayer.GetParent() == player.GetParent() )
				otherPlayers.append( dropshipPlayer )

		if ( otherPlayers.len() )
			PlayBattleChatterLineOnlyToPlayer( otherPlayers.getrandom(), player, "bc_pIntroChat" )
	#endif

	waitthread PlayJumpoutAnims( player, ship, jumpAnim )
}

void function DelayedWeaponDeploy( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	wait 1.0

	player.EnableWeaponViewModel()
}

// Inherits end signals from calling function SpawnPlayerIntoDropship
void function PlayJumpoutAnims( entity player, entity ship, FirstPersonSequenceStruct jumpAnim )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				// printt( "Removing cinematic flags from classic mp" )

				RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
				RemoveCinematicFlag( player, CE_FLAG_WAVE_SPAWNING )
			}
		}
	)

	// printt( "Playing Jump Anim " + jumpAnim.thirdPersonAnim + " for player: " + player )
	waitthread FirstPersonSequence( jumpAnim, player, ship )

	player.ClearParent()

	ClearPlayerAnimViewEntity( player )

	wait 0.3

	Loadouts_TryGivePilotLoadout( player )

	for ( ; ; )
	{
		if ( player.IsOnGround() || player.IsWallRunning() || player.IsWallHanging() )
			break

		wait 0
	}
}

bool function CanSpawnIntoIntroDropship( entity player )
{
	if ( !ClassicMP_CanUseIntroStartSpawn() )
		return false

	if ( ShouldIntroSpawnAsTitan() )
		return false

	if ( player.GetTeam() in file.dropshipDisabledTeams )
		return false

	// If more than 8 players have tried to connect to this server at this time,
	// just say you can't spawn in the dropship. Easier than having to keep track of
	// what is the next available slot, due to people connecting and then disconnecting during the idle anim time.

	/*
	mo: this is an overly complicated system -> this function for example gets run when a player connects. He sees that he has room in the list and then is added to the list.
	then DecidePlayerRespawn() runs and checks this function again... which checks to see the number of people on the list
	keep in mind that the value here used to be 7, not 8.  Keeping that in mind...
	Players 15 and 16 are the last to be added to this list, so they think there is no room on the dropship, even though they've been added. so they respawn on the ground
	then the thread for spawning players into the dropship runs and sees them on the list and tries to respawn them, causing a bug. the change from 7 to 8 is really just a work around

	this system could be re-written to be much simpler.  if your ent index is less than 16 you spawn in the dropship, ( assuming 4 ships of 4 ), otherwise you spawn on the ground. simple as that
	the ent index will decide the seat position since even if a player disconnects, the player that replaces him will have the same ent index.  For R2 - we should re-write it to do that.
*/

	int team = player.GetTeam()

	if ( file.dropshipSpawnPlayerList[ team ].len() > 8 )
		return false

	return true
}

void function DisableDropshipSpawnForTeam( int team )
{
	file.dropshipDisabledTeams[ team ] <- true
}

void function EnableDropshipSpawnForTeam( int team )
{
	if ( team in file.dropshipDisabledTeams )
		delete file.dropshipDisabledTeams[ team ]
}

void function SpawnPlayerIntoSlotInDropship( entity player, bool waveSpawn = false )
{
	int team = player.GetTeam()

	Assert( expect array( expect table( level.classicMPDropships )[ team ] ).len(), "Tried to spawn player into dropship in progress but no dropship is active!" )

	int numOfDropshipSpawningTeammates = file.dropshipSpawnPlayerList[ team ].len()
	// printt( "numOfDropshipSpawningTeammates " + numOfDropshipSpawningTeammates )

	AddPlayerToDropshipSpawnPlayerList( player )

	entity shipToSpawnIn

	// Assume we never have more than 8 players...
	if ( numOfDropshipSpawningTeammates < SQUAD_SIZE && expect array( expect table( level.classicMPDropships )[ team ] ).len() > 1 )
	{
		// printt( "First ship" )
		int index = expect array( expect table( level.classicMPDropships )[ team ] ).len() - 2

		shipToSpawnIn = expect entity( expect array( expect table( level.classicMPDropships )[ team ] )[ index ] ) // 1st ship
	}

	if ( !IsValid( shipToSpawnIn ) )
	{
		// printt( "Second ship" )
		int index = expect array( expect table( level.classicMPDropships )[ team ] ).len() - 1

		shipToSpawnIn = expect entity( expect array( expect table( level.classicMPDropships )[ team ] )[ index ] ) // 2nd ship
	}

	int seatNumber = numOfDropshipSpawningTeammates % 4

	// printt( "SeatNumber: " + seatNumber )

	FirstPersonSequenceStruct sequence

	sequence.firstPersonAnim = dropshipIdlePOVAnimsList[ seatNumber ]
	sequence.thirdPersonAnim = dropshipIdleAnimsList[ seatNumber ]
	sequence.attachment = "ORIGIN"
	sequence.blendTime = 0.0
	sequence.hideProxy = true
	sequence.viewConeFunction = ViewConeRampFree
	sequence.setInitialTime = Time() - file.dropshipSpawnTime

	FirstPersonSequenceStruct idleAnim = clone sequence

	sequence.firstPersonAnim = dropshipJumpPOVAnimsList[ seatNumber ]
	sequence.thirdPersonAnim = dropshipJumpAnimsList[ seatNumber ]
	sequence.setInitialTime = 0.0

	FirstPersonSequenceStruct jumpAnim = clone sequence

	if ( waveSpawn )
		idleAnim = clone GetWaveSpawnCustomPlayerRideAnimIdle( seatNumber, idleAnim )

	if ( waveSpawn )
		jumpAnim = clone GetWaveSpawnCustomPlayerRideAnimJump( seatNumber, jumpAnim )

	thread SpawnPlayerIntoDropship( shipToSpawnIn, player, idleAnim, jumpAnim, waveSpawn )
}

void function DebugTestDropshipStartSpawns()
{
	bool result

	for ( int i = 0; i < 8; ++i )
	{
		result = DebugTestDropshipSpecificSpawn( i )

		if ( !result )
			break

		file.debugTestingSpawns = true // Set it true and false later to fix problem with testin dropship spawns in levels with out of bounds triggers

		wait 25.0
	}

	file.debugTestingSpawns = false
}

bool function DebugTestDropshipSpecificSpawn( int seat )
{
	CustomPlayerDropshipSpawn()

	file.dropshipSpawnTime = Time()
	file.debugTestingSpawns = true

	array<entity> players = GetPlayerArray()
	entity player = players[ 0 ]
	int team = player.GetTeam()

	AddPlayerToDropshipSpawnPlayerList( player )

	int dropshipNum = 1

	if ( seat > 3 )
		dropshipNum = 2

	string teamStr

	if ( team == TEAM_IMC )
		teamStr = "imc"
	else if ( team == TEAM_MILITIA )
		teamStr = "militia"

	printt( "Dropship Start spawn: dropshipNum: " + dropshipNum + ", team: " + teamStr + ", seatNumber: " + seat )

	array<entity> spawns = GetDropshipStartSpawnsForTeam( team )

	if ( spawns.len() != 2 )
	{
		printt( "Need exactly 2 dropship spawns for team: " + teamStr + " . " + spawns.len() + " detected. Returning" )
		return false
	}

	SpawnTeamPlayersIntoDropships( team, spawns, seat, GetDropshipIntroAnimation() )

	file.debugTestingSpawns = false

	RemovePlayerFromDropshipSpawnPlayerList( player )

	return true
}

void function SetCustomPlayerDropshipSpawn( int team = -1, vector ornull origin_1 = null, vector ornull angles_1 = null, vector ornull origin_2 = null, vector ornull angles_2 = null )
{
	array data = []

	if ( team == -1 )
	{
		array<entity> players = GetPlayerArray()
		entity player = players[ 0 ]

		team = player.GetTeam()
		origin_1 = player.GetOrigin()
		angles_1 = player.GetAngles()
	}

	data.append( { origin = origin_1, angles = angles_1 } )
	data.append( { origin = origin_2, angles = angles_2 } )

	file.customDropshipSpawns[ team ] <- data
}

void function CustomPlayerDropshipSpawn()
{
	foreach ( team, data in file.customDropshipSpawns )
	{
		int index = 0

		foreach ( entity spawnpoint in file.dropship_start_spawns )
		{
			if ( spawnpoint.GetTeam() == team && expect table( data[ index ] ).origin != null )
			{
				spawnpoint.SetOrigin( expect vector( expect table( data[ index ] ).origin ) )
				spawnpoint.SetAngles( expect vector( expect table( data[ index ] ).angles ) )

				index++
			}
		}
	}
}

void function DebugTestDropshipStartSpawnsForAll()
{
	// no bots
}

void function DebugTestCustomDropshipSpawn()
{
	DebugTestDropshipSpecificSpawn( DROPSHIP_SEAT )
}

void function PlayerSpawnDropship_RunSpawnCallbacks( entity dropship, string anim )
{
	// Added via AddCallback_OnWaveSpawnDropshipSpawned
	foreach ( callbackFunc in svGlobal.onWaveSpawnDropshipSpawned )
		callbackFunc( dropship, anim )
}

bool function ClassicMP_TryPlayerIntroSpawn( entity player )
{
	Assert( IsMultiplayerPlaylist() )

	if ( !ClassicMP_CanUseIntroStartSpawn() )
		return false

	Assert( file.classicMP_introPlayerSpawnFunc != null, "No Classic MP intro player spawn function set! We at least expect the default dropship intro." )

	return ClassicMP_CallIntroPlayerSpawnFunc( player )
}

void function AddCallback_OnWaveSpawnDropshipSpawned( void functionref( entity, string ) callbackFunc )
{
	Assert( !svGlobal.onWaveSpawnDropshipSpawned.contains( callbackFunc ), "Already added " + name + " with AddCallback_OnWaveSpawnDropshipSpawned" )

	svGlobal.onWaveSpawnDropshipSpawned.append( callbackFunc )
}

string function GetDropshipIntroAnimation()
{
	switch ( GetMapName() )
	{
		case "mp_complex3":
			return "dropship_classic_mp_flyin_timeshift"

		case "mp_grave":
			return "dropship_classic_mp_flyin_grave"
	}

	return "dropship_classic_mp_flyin"
}
