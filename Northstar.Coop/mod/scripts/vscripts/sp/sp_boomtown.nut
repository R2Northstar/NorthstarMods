// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗  ██████╗  ██████╗ ███╗   ███╗████████╗ ██████╗ ██╗    ██╗███╗   ██╗
// ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║╚══██╔══╝██╔═══██╗██║    ██║████╗  ██║
// ██████╔╝██║   ██║██║   ██║██╔████╔██║   ██║   ██║   ██║██║ █╗ ██║██╔██╗ ██║
// ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║   ██║   ██║   ██║██║███╗██║██║╚██╗██║
// ██████╔╝╚██████╔╝╚██████╔╝██║ ╚═╝ ██║   ██║   ╚██████╔╝╚███╔███╔╝██║ ╚████║
// ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝   ╚═╝    ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝
//
// -------------------------------------------------------------------------------------------------------------------------
untyped

global function CodeCallback_MapInit
global function ReaperTown_SetPhysicsMotionOnMovers

//---------------------
// Tweakable Variables
//---------------------
const REAPER_HEALTH_THRESHOLD_PERCENT	= 50		// At REAPER_HEALTH_THRESHOLD_PERCENT % health, call a flag
const REAPER_PLAYER_LKP_PING			= 10		// Every so many seconds, tell the reaper where the player is.
const REAPERTOWN_DEATH_Z				= 6742.0	// If the player's Z is < this, kill them before Reapertown teleport.

//---------------------
// Asset Consts
//---------------------
const SFX_DOME_POWER_UP 				= "Boomtown_DomePowerOn"
const SFX_DOME_MOVING_FLICKER			= "Boomtown_DomePowerOn_ScreensFlickering"
const SFX_DOME_POWER_DOWN 				= "Boomtown_DomePowerOff"

struct
{
	int friendlyGrunts_GlobalArrayIdx = -1
	vector teleportStartRefPos
	vector teleportTargetRefPos
} file


void function CodeCallback_MapInit()
{
	if ( reloadingScripts )
		return

	DropPod_Init()

	ShSpBoomtownMidCommonInit()

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	InitBoomtownDialogue()
	SPBoomtownUtilityInit()
	AssemblyMapInit()

	file.friendlyGrunts_GlobalArrayIdx = CreateScriptManagedEntArray()

	//------------------
	// Code Callbacks
	//------------------
	AddCallback_EntitiesDidLoad( Boomtown_EntitiesDidLoad )
	AddSpawnCallback( "prop_dynamic", OnSpawnedPropDynamic )
	AddSpawnCallback( "trigger_multiple", OnSpawnedTrigger)
	AddSpawnCallback( "trigger_once", OnSpawnedTrigger )

	//------------------
	// Flags
	//------------------
	FlagInit( "reapertown_teleport_done" )
	FlagInit( "reapertown_militia_spawn" )
	FlagInit( "reapertown_reaper_lift_raise" )
	FlagInit( "reapertown_first_reaper_low_health" )
	FlagInit( "reapertown_second_reaper_low_health" )
	FlagInit( "reapertown_reaper_killed_first" )
	FlagInit( "reapertown_reaper_killed_second" )
	FlagInit( "reapertown_ash_thanks_pilot" )
	FlagInit( "reapertown_cage_placed" )
	FlagInit( "reapertown_grunts_done_chatting_intro" )
	FlagInit( "reapertown_dome_close_reaper" )
	FlagInit( "reapertown_skydome_start_boot" )
	FlagInit( "reapertown_skydome_stop_boot" )
	FlagInit( "reapertown_dome_power_on" )
	FlagInit( "reapertown_skip_to_dome_breach" )
	FlagInit( "reapertown_reaper_lands" )

	RegisterSignal( "PlayerDoomedInReapertownLift" )

	//------------------
	// Start Points
	//------------------

	AddStartPoint( "Start",						StartPoint_Start, 				StartPoint_Setup_Start, 				StartPoint_Skipped_Start )
	AddStartPoint( "Assembly_Start",			StartPoint_Assembly_Start, 		StartPoint_Setup_Assembly_Start, 		StartPoint_Skipped_Assembly_Start )
	AddStartPoint( "Assembly_Dirt",				StartPoint_Assembly_Dirt, 		StartPoint_Setup_Assembly_Dirt, 		StartPoint_Skipped_Assembly_Dirt )
	AddStartPoint( "Assembly_Wallrun",			StartPoint_Assembly_Wallrun, 	StartPoint_Setup_Assembly_Wallrun, 		StartPoint_Skipped_Assembly_Wallrun )
	AddStartPoint( "Assembly_Furniture",		StartPoint_Assembly_Furniture, 	StartPoint_Setup_Assembly_Furniture, 	StartPoint_Skipped_Assembly_Furniture )
	AddStartPoint( "Assembly_Walls",			StartPoint_Assembly_Walls, 		StartPoint_Setup_Assembly_Walls, 		StartPoint_Skipped_Assembly_Walls )
	AddStartPoint( "Assembly_Highway",			StartPoint_Highway, 			StartPoint_Setup_Highway, 				StartPoint_Skipped_Highway )
	AddStartPoint( "Town_Climb_Entry",			StartPoint_TownClimbEntry, 		StartPoint_Setup_TownClimbEntry, 		StartPoint_Skipped_TownClimbEntry )

	AddStartPoint( "ReaperTown",          		StartPoint_ReaperTown,          StartPoint_Setup_ReaperTown,          	StartPoint_Skipped_ReaperTown )

	AddDeathCallback( "player", Boomtown_HandleSpecialDeathSounds )
	AddDeathCallback( "npc_titan", Boomtown_HandleSpecialDeathSounds )

	AddSpawnCallback_ScriptName( "disable_double_jump", TriggerDisableDoubleJump )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗ ████████╗ ██████╗ ██╗    ██╗███╗   ██╗
// ██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗██║    ██║████╗  ██║
// ██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝   ██║   ██║   ██║██║ █╗ ██║██╔██╗ ██║
// ██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗   ██║   ██║   ██║██║███╗██║██║╚██╗██║
// ██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║   ██║   ╚██████╔╝╚███╔███╔╝██║ ╚████║
// ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_ReaperTown( entity player )
{
	CleanupAssemblyEnts()

	//DEV_SkyPanelInfo()
	GenerateReapertownSkyDome()
	//DEV_SkyPanelInfo()

	thread ReaperTown_SkyDomeSetup()
	thread ReaperTown_TruckRotateSetup()
	thread ReaperTown_RaisedPlatformSetup()
	thread Reapertown_Lift_KillTriggerThink()

	ReaperTown_CombatScenario( player )
}


void function ReaperTown_CombatScenario( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "PlayerDoomedInReapertownLift" )

	entity floorRef = GetEntByScriptName( "reapertown_floor_ref" )
	vector floorRefPos = floorRef.GetOrigin()
	entity doorSpot = GetEntByScriptName( "reapertown_door_lookat_spot" )
	entity reaperSpot = GetEntByScriptName( "reapertown_militia_bullseye" )
	entity coverNavSeparator = GetEntByScriptName( "reapertown_stage_cover_npc_clip_brush" )
	coverNavSeparator.NotSolid()

	FlagSet( "FriendlyFireStrict" )

	entity cageDoorSeparator = GetEntByScriptName( "reapertown_cage_door_separator" )
	cageDoorSeparator.NotSolid()

	Objective_Clear()

	// -----------------------------------------------------------
	// Sky dome shut off, player teleport, sky dome reboot
	// -----------------------------------------------------------
	wait 2.0 // Give it time to breath before shutting off the dome

	waitthread PlayDialogue( "PA_LoadScenarioStart", player )

	// Teleport player from dark reapertown to lit one
	FlagWait ( "reapertown_begin_teleport" )
	ReaperTown_PlayerTeleportSequence( player )
	ReaperTown_SetPhysicsMotionOnMovers( true )

	// Wait for the sky dome to stop booting then speak to pilot & reset terrain
	FlagWait( "reapertown_skydome_stop_boot" )

	// -----------------------------------------------------------
	// Reset terrain
	// -----------------------------------------------------------
	StopMusicTrack( "music_boomtown_15_townclimb_activateconsole" )
	PlayMusic( "music_boomtown_16_reapertown_scenarioload" )

	FlagSet( "reapertown_start" )

	CreateShakeRumbleOnly( player.GetOrigin(), 16, 100, 21 )

	FlagWait( "reapertown_stop" )
	Boomtown_SetCSMTexelScale( player, 0.15, 0.5 )
	wait 1.0
	CheckPoint_ForcedSilent()


	// -----------------------------------------------------------
	// Deploy militia grunts
	// -----------------------------------------------------------
	WaitTillLookingAt( player, doorSpot, true, 30, 2000, 5.0 )
	waitthread PlayDialogue( "PA_DeployMilitia", player )
	thread ReaperTown_DeliveryAlarm( player, 6 )
	wait 1.0
	entity gruntCage = GetEntByScriptName( "reapertown_grunt_cage" )
	FlagSet( "reapertown_wall_open_bottom")
	CreateShakeRumbleOnly( player.GetOrigin(), 16, 100, 4.5 )

	thread ReaperTown_MilitiaSpawnGruntSquad()
	wait 1.0
	ReaperTown_GruntDeliverySequence( player )

	entity ammoCrate = GetEntByScriptName( "reapertown_stage_ammo_crate" )
	Objective_Set( "#BOOMTOWN_OBJECTIVE_ARM_UP", <0,0,0>, ammoCrate )

	// Raise cover
	ReaperTown_ToggleStageCover( true, 3.0 )
	CreateShakeRumbleOnly( player.GetOrigin(), 16, 100, 1 )

	CheckPoint_Silent()

	// -----------------------------------------------------------
	// First wave of spectres
	// -----------------------------------------------------------
	FlagWait( "reapertown_grunts_done_chatting_intro" )
	wait 1.0
	waitthread PlayDialogue( "PA_ScenarioLoadComplete", player )
	wait 0.5
	waitthread PlayDialogue( "ASH_DeploySpectresWarmUp", player )
	StopMusicTrack( "music_boomtown_16_reapertown_scenarioload" )
	PlayMusic( "music_boomtown_17_reapertown_deployspectres" )
	wait 2.0
	array<entity> pods1 = GetEntArrayByScriptName( "reapertown_droppod_spawner_wave1a" )
	foreach( pod in pods1 )
		thread DEV_ReaperTownDroppodSpawn( pod )

	pods1 = GetEntArrayByScriptName( "reapertown_droppod_spawner_wave1b" )
	foreach( pod in pods1 )
		thread DEV_ReaperTownDroppodSpawn( pod )

	wait 4.0

	thread ReaperTown_GruntChat_AttackSpectres( player )

	// Give this first encounter some breathing room
	wait 7.0
	PlayerConversation( "ReapertownHeartRate", player )
	wait 0.5

	// -----------------------------------------------------------
	// First Reaper
	// -----------------------------------------------------------
	waitthread WaitTillLookingAt( player, reaperSpot, true, 30, 2000, 5.0 )

	CheckPoint_Silent()

	PlayDialogue( "PA_ScenarioInfo", player )

	thread ReaperTown_AntiRoofCheese( player )

	entity firstReaper = ReaperTown_DeployReaperFromLift( player )
	thread ReaperTown_ReaperHealthMonitor( firstReaper, "reapertown_first_reaper_low_health" )

	thread ReaperTown_GruntChat_AttackReaper( player )

	Objective_Set( "#BOOMTOWN_OBJECTIVE_DEFEAT_REAPERS", Vector( 0, 0, 0 ) )
	wait 3.0

	if ( IsValid( firstReaper ) && IsAlive( firstReaper ) )
	{
		firstReaper.SetNoTarget( false )  // Let grunts start shooting at it

		// REAPER JUMPS AND SMASHES MILITIA GRUNTS
		thread ReaperTown_GruntChat_ReaperJumps( player )
		thread PlayAnim( firstReaper, "sspec_idle_to_run" )

		entity reaperJumpSpot = GetEntByScriptName( "reapertown_reaper_jump_spot" )
		firstReaper.Anim_ScriptedJump( reaperJumpSpot.GetOrigin() )
		firstReaper.DisableNPCFlag( NPC_IGNORE_ALL )  // Let the Reaper attack
		FlagSet( "reapertown_reaper_lands" )
		ClearInvincible( firstReaper )
	}

	thread ReaperTown_PeriodicallySetLKP( firstReaper, player )

	wait 6.0

	// -----------------------------------------------------------
	// Second Reaper
	// -----------------------------------------------------------
	// Wait until first reaper hits low health
	FlagWait( "reapertown_first_reaper_low_health" )
	CheckPoint_Silent()

	waitthread PlayDialogue( "BT_VideoEstablished", player )

	// DEPLOY ANOTHER REAPER
	waitthread PlayDialogue( "ASH_DeployMultipleReapers", player )
	thread ReaperTown_DeliveryAlarm( player, 7 )
	waitthread PlayDialogue( "PA_DeployAnotherReaper", player )
	FlagSet( "reapertown_dome_open_reaper" )
	wait 1.5
	entity secondReaper = ReaperTown_DeployReaper( "reapertown_reaper_spawner2" )
	thread ReaperTown_ReaperHealthMonitor( secondReaper, "reapertown_second_reaper_low_health" )
	thread ReaperTown_PeriodicallySetLKP( secondReaper, player )

	// Launch ticks as soon as possible
	secondReaper.SetEnemyLKP( player, player.GetOrigin() )
	thread ForceTickLaunch( secondReaper )

	thread ReaperTown_BothReapersDeadThink( player )

	wait 1.0

	CreateShakeRumbleOnly( player.GetOrigin(), 20, 150, 1 )

	wait 1.0

	FlagSet( "reapertown_dome_close_reaper" )

	wait 4.0

	// -----------------------------------------------------------
	// More spectres!
	// -----------------------------------------------------------
	array<entity> pods

	// Deploy a wave of spectres if there are less than X reapers to keep the action going
	if ( ReaperTown_GetLivingReaperCount() < 2 )
	{
		waitthread PlayDialogue( "ASH_DeployMoreIMC", player )

		pods = GetEntArrayByScriptName( "reapertown_droppod_spawner_wave2a" )
		foreach( pod in pods )
			thread DEV_ReaperTownDroppodSpawn( pod )

		pods = GetEntArrayByScriptName( "reapertown_droppod_spawner_wave2b" )
		foreach( pod in pods )
			thread DEV_ReaperTownDroppodSpawn( pod )
	}

	ReaperTown_AshThanksPilotThink( player )
	FlagWait( "reapertown_ash_thanks_pilot" )

	// Only wait if we have reapers around
	if ( ReaperTown_GetLivingReaperCount() > 0 )
		wait 5.0


	// -----------------------------------------------------------
	// Dome opening prep
	// -----------------------------------------------------------
	StopMusicTrack( "music_boomtown_18_reapertown_reaperarrive" )
	PlayMusic( "music_boomtown_19_reapertown_humanenemies" )
	waitthread PlayDialogue( "ASH_Should_Have_Died", player )
	wait 1.0
	waitthread PlayDialogue( "ASH_ToKappa_ReportToDome", player )
	waitthread PlayDialogue( "IMC_CAPTAIN_MovingToDome", player )

	wait 0.5

	// Have any remaining spectres move toward the dome opening
	entity stageAssaultPoint = GetEntByScriptName( "reapertown_stage_move_target" )
	array<entity> spectres = GetNPCArrayByClass( "npc_spectre" )
	foreach( spectre in spectres )
	{
		AssaultEntity( spectre, stageAssaultPoint )
	}


	// Drop another drop pod near the door to start redirecting attention toward it
	pods = GetEntArrayByScriptName( "reapertown_droppod_spawner_wave3" )
	foreach( pod in pods )
		thread DEV_ReaperTownDroppodSpawn( pod )

	// WAIT TILL THE 2ND REAPER IS WEAKENED
	FlagWait( "reapertown_second_reaper_low_health" )

	//wait 5.0  // Give the grunts some fake time to get into position
	waitthread PlayDialogue( "IMC_CAPTAIN_InPosition", player )

	// Only wait if we have reapers around
	if ( ReaperTown_GetLivingReaperCount() > 0 )
		wait 2.0


	// -----------------------------------------------------------
	// Breach the dome!
	// -----------------------------------------------------------
	WaitTillLookingAt( player, doorSpot, true, 30, 2000, 5.0 )
	CheckPoint_Silent()
	wait 0.5

	waitthread PlayDialogue( "ASH_TimeToEndThis", player )
	waitthread PlayDialogue( "ASH_EliminatePilot", player )
	waitthread PlayDialogue( "IMC_CAPTAIN_BreachPrep", player )

	ReaperTown_ToggleStageCover( false )

	wait 1.0

	FlagSet( "reapertown_wall_open_bottom" )
	FlagSet( "reapertown_open_dome" )
	CreateShakeRumbleOnly( player.GetOrigin(), 16, 100, 3.5 )

	thread ReaperTown_ExitDomeThink( player )
	entity wallMeshSeparator = GetEntByScriptName( "reapertown_wall_navmesh_separator" )
	wallMeshSeparator.NotSolid()

	// SQUAD SPAWNS AND ENTERS REAPERTOWN
	array<entity> cleanupSquadSpawners = GetEntArrayByScriptName( "reapertown_cleanup_crew" )
	array<entity> cleanupSquadGuys = SpawnFromSpawnerArray( cleanupSquadSpawners )

	thread ReaperTown_ExitNagThink( player )

	WaitForever()
}


void function ReaperTown_AntiRoofCheese( entity player )
{
	player.EndSignal( "OnDestroy" )

	float waitTime = 2.0
	int attempts = 5

	for( int i = 0; i < attempts; i++ )
	{
		if ( Flag( "reapertown_player_on_cheese_roof" ) )
			wait waitTime
		else
			return
	}

	array<entity> spectres = GetNPCArrayByClass( "npc_spectre" )
	if ( spectres.len() <= 0 )
		return

	entity spectre1 = GetClosest( spectres, player.GetOrigin() )
	if( spectre1 == null )
		return

	entity spectre2 = GetClosest( spectres, spectre1.GetOrigin() )
	entity target = GetEntByScriptName( "move_target_pilot_on_roof" )

	if( spectre1 != null )
		AssaultEntity( spectre1, target )
	if( spectre2 != null )
		AssaultEntity( spectre1, target )
}


int function ReaperTown_GetLivingReaperCount()
{
	array<entity> reapers = GetNPCArrayByClass( "npc_super_spectre" )
	return reapers.len()
}


void function ReaperTown_ExitNagThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	wait 20

	if ( Flag( "reapertown_pilot_exits_dome" ) )
		return

	while ( IsDialoguePlaying() )
		wait 0.1

	PlayerConversation( "ReapertownYouOK", player )

	entity exitSpot = GetEntByScriptName( "reapertown_door_exit_spot" )
	Objective_Set( "#BOOMTOWN_OBJECTIVE_ESCAPE_DOME", exitSpot.GetOrigin() )

	wait 30

	if ( Flag( "reapertown_pilot_exits_dome" ) )
		return

	PlayDialogue( "BT_ExitThruWall", player )
}


void function ReaperTown_ExitDomeThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	thread ReaperTown_CloseDoorBehindPlayer()

	FlagWait( "reapertown_pilot_exits_dome" )
	StopMusicTrack( "music_boomtown_19_reapertown_humanenemies" )
	PlayMusic( "music_boomtown_20_abovethedome" )

	while ( IsDialoguePlaying() )
		wait 0.1

	waitthread PlayDialogue( "ASH_Im_Coming_Down", player )
}


void function ReaperTown_CloseDoorBehindPlayer()
{
	// Close the door behind the player so they don't backtrack & get lost
	FlagWait( "reapertown_close_dome_behind_player" )

	FlagSet( "reapertown_wall_close_bottom" )
	FlagClear( "reapertown_open_dome" )
	entity wallMeshSeparator = GetEntByScriptName( "reapertown_wall_navmesh_separator" )
	wallMeshSeparator.Solid()

	CreateShakeRumbleOnly( wallMeshSeparator.GetOrigin(), 16, 100, 2.0 )

	entity exitSpot = GetEntByScriptName( "reapertown_exitSpot" )
	Objective_Set( "#BOOMTOWN_OBJECTIVE_ESCAPE_DOME", exitSpot.GetOrigin() )
}


void function ReaperTown_AshFinalTaunt( entity player )
{
	array<string> dialogKeys = [ "ASH_Taunt_TimeToEndThis", "ASH_Taunt_TimeToDispose" ]

	string dialogKey = dialogKeys.getrandom()
	waitthread PlayDialogue( "dialogKey", player )
}


void function ReaperTown_ToggleStageCover( bool raiseCover = true, float delay = 0.0 )
{
	wait delay

	float units = 0.0
	array<entity> covers = GetEntArrayByScriptName( "reapertown_stage_cover" )
	foreach( cover in covers )
	{
		if ( cover.HasKey( "script_noteworthy" ) )
			units = float( cover.kv.script_noteworthy )

		// If not raiseCover, then lower cover!
		if ( !raiseCover )
			units *= -1

		entity mover = cover.GetParent()
		vector newPos = mover.GetOrigin()
		newPos.z += units

		float dist = Distance( mover.GetOrigin(), newPos )
		if ( dist > 0.0 )
		{
			float pathSpeed = 100.0
			float moveTime = dist / pathSpeed
			float easeInTime = RandomFloatRange( 0.0, moveTime * 0.5 )
			float easeOutTime = RandomFloatRange( 0.0, moveTime * 0.5 )

			thread ReaperTown_MoveStageCover( mover, newPos, moveTime, easeInTime, easeOutTime )
		}
	}


	// If the cover is up, then block navmesh
	if ( raiseCover )
		FlagClear( "reapertown_stage_cover_clip_brush_off" )
	else
		FlagSet( "reapertown_stage_cover_clip_brush_off" )

}


void function ReaperTown_MoveStageCover( entity mover, vector newPos, float moveTime, float easeInTime, float easeOutTime )
{
	mover.EndSignal( "OnDestroy" )

	mover.NonPhysicsMoveTo( newPos, moveTime, easeInTime, easeOutTime )
	EmitSoundOnEntity( mover, "Boomtown_LargeConcreteWall_Raise" )
	wait moveTime
	StopSoundOnEntity( mover, "Boomtown_LargeConcreteWall_Raise" )
	EmitSoundOnEntity( mover, "Boomtown_LargeConcreteWall_Stop" )
}


void function ReaperTown_MilitiaSpawnGruntSquad()
{
	array<string> gruntNames = [ "#NPC_LEATHERMAN_NAME", "#NPC_JERRETT_NAME", "#NPC_MATCHETT_NAME", "#NPC_TOVAR_NAME", "#NPC_ROBERTS_NAME", "#NPC_BABB_NAME" ]
	array<entity> gruntSpawners = GetEntArrayByScriptName( "reapertown_caged_militia_grunt" )
	array<entity> grunts = SpawnFromSpawnerArray( gruntSpawners )
	entity bullseyeSpot = GetEntByScriptName( "reapertown_militia_bullseye" )

	for( int i = 0; i < grunts.len(); i++ )
	{
		entity grunt = grunts[ i ]
		string name = gruntNames[ i ]

		grunt.SetTitle( name )
		ShowName( grunt )
		grunt.DisableNPCFlag( NPC_ALLOW_PATROL )

		AddToScriptManagedEntArray( file.friendlyGrunts_GlobalArrayIdx, grunt )
	}


	FlagWait( "reapertown_connect_cage_mesh" )

	array<entity> moveTargets = GetEntArrayByScriptName( "move_target_enemy_staging" )
	for( int i = 0; i < grunts.len(); i++ )
	{
		entity target = moveTargets[i]
		AssaultEntity( grunts[i], target )
		grunts[i].SetPotentialThreatPos( bullseyeSpot.GetOrigin() )
		grunts[i].kv.alwaysalert = true

		wait 1
	}
}


void function ReaperTown_GruntConversation( entity player, array<string> gruntLines )
{
	player.EndSignal( "OnDestroy" )

	foreach( line in gruntLines )
	{
		if( GetScriptManagedEntArrayLen( file.friendlyGrunts_GlobalArrayIdx ) < 2 )   // Need at least two guys to talk to each other
			return

		entity guy = GetClosest( GetScriptManagedEntArray( file.friendlyGrunts_GlobalArrayIdx ), player.GetOrigin() )

		waitthread PlayDialogue( line, guy )
	}
}


void function ReaperTown_GruntChat_ArmUp( entity player )
{
	OnThreadEnd(
	function() : (  )
		{
			FlagSet( "reapertown_grunts_done_chatting_intro" )
		}
	)

	ReaperTown_GruntConversation( player, [ "GRUNT1_ArmUp", "GRUNT2_BarelySurvivedBefore", "GRUNT3_ShutUpGrabGun" ] )
	wait 1.0
	ReaperTown_GruntConversation( player, [ "GRUNT2_APilot", "GRUNT1_AimSharp" ] )
}


void function ReaperTown_GruntChat_AttackSpectres( entity player )
{
	ReaperTown_GruntConversation( player, [ "GRUNT1_EyesForward", "GRUNT2_SpectresOpenFire" ] )
}


void function ReaperTown_GruntChat_AttackReaper( entity player )
{
	ReaperTown_GruntConversation( player, [ "GRUNT3_WhatIsThat", "GRUNT2_ItsAReaper" ] )
}


void function ReaperTown_GruntChat_ReaperJumps( entity player )
{
	wait 1.0
	ReaperTown_GruntConversation( player, [ "GRUNT2_LookOut", "GRUNT3_Aaaaah" ] )
}


void function ReaperTown_GruntDeliverySequence( entity player )
{
	entity wallMeshSeparator = GetEntByScriptName( "reapertown_wall_navmesh_separator" )
	wallMeshSeparator.NotSolid()

	FlagSet( "reapertown_cage_deploy")

	FlagWait( "reapertown_cage_placed" )

	thread ReaperTown_GruntChat_ArmUp( player )

	entity cageFloor = GetEntByScriptName( "reapertown_cage_floor_clip" )
	cageFloor.Destroy()

	entity gruntCage = GetEntByScriptName( "reapertown_grunt_cage" )
	entity cageParent = gruntCage.GetParent()
	gruntCage.ClearParent()

	// Open cage doors
	thread PlayAnim( gruntCage, "front_doors_open")
	FlagSet( "reapertown_connect_cage_mesh" )

	wait 5.0
	PlayAnim( gruntCage, "front_doors_close" )
	wait 1.0
	gruntCage.SetParent( cageParent )

	FlagSet( "reapertown_cage_retract" )
	CreateShakeRumbleOnly( player.GetOrigin(), 16, 100, 4.5 )

	FlagWait( "reapertown_wall_close_bottom" )

	wallMeshSeparator.Solid()
}


void function ReaperTown_DeliveryAlarm( entity player, int alarmCount )
{
	player.EndSignal( "OnDestroy" )

	for( int i = 0; i < alarmCount; i++ )
	{
		EmitSoundOnEntity( player, "Boomtown_ReaperTubeAlarm" )
		wait 2.0
	}
}


entity function ReaperTown_DeployReaper( string spawnerName )
{
	array<entity> reaperSpawners = GetEntArrayByScriptName( spawnerName )
	array<entity> reapers = SpawnFromSpawnerArray( reaperSpawners )

	foreach ( reaper in reapers )
	{
		reaper.ai.shouldDropBattery = false
	}

	return reapers[0]
}


void function ReaperTown_SkyDome_PowerOn( entity player )
{
	thread CreateShakeRumbleOnly( player.GetOrigin(), 3, 150, 25, 4048 )
	EmitSoundOnEntity( player, SFX_DOME_POWER_UP )
	wait 1.0
	thread SkyDome_ChangeSkinSequence( "reapertown_room_center", eSkindex.mountain )
	FlagSet( "reapertown_skydome_start_boot" )
}


vector function GetPosInOtherBoomtown( vector startPos )
{
	vector offsetFromRef = startPos - file.teleportStartRefPos
	vector newPos = file.teleportTargetRefPos + offsetFromRef
	return newPos
}


void function ReaperTown_PlayerTeleportSequence( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	if ( !IsAlive( player ) )
		return

	thread Reapertown_PreTeleportKillThink( player )

	MakeInvincible( player )

	EmitSoundOnEntity( player, SFX_DOME_POWER_DOWN )
	wait 0.5
	thread SkyDome_TurnOffDome()

	Boomtown_SetCSMTexelScale( player, 0.15, 2.25 )
	Remote_CallFunction_NonReplay( player, "ServerCallback_ReaperTownTeleport" )

	wait 2.0

	thread PlayDialogue( "ASH_WelcomePilot", player )

	player.ClearTraverse()

	// Teleport player to the real ReaperTown
	vector newPos = GetPosInOtherBoomtown( player.GetOrigin() )

	// HACK: This line shouldn't be needed with PutEntityInSafeSpot() but the sky panel textures are not rendering properly unless we do this.
	player.SetOrigin( newPos )

	if( !PutEntityInSafeSpot( player, null, null, newPos, newPos ) )
	{
		// 100% safe spot just in case for failsafe.  This has never happened in testing, but just in case...
		player.SetOrigin( < 9637.23, -2876.61, 11866.2 > )
		player.SetAngles( < -1.0, -94.3, 0.0 > )
	}

	wait 4.0
	thread ReaperTown_SkyDome_PowerOn( player )

	ClearInvincible( player )

	FlagSet( "reapertown_teleport_done" )
}


// Edge case: If the player jumps back down under the dome space, kill them. Otherwise they will be trapped down there.
void function Reapertown_PreTeleportKillThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	while( 1 )
	{
		if ( Flag( "reapertown_teleport_done" ) )
			return

		if ( player.GetOrigin().z <= REAPERTOWN_DEATH_Z )
		{
			printt( "ERROR! - Player exited reapertown during teleport!" )
			if ( IsAlive( player ) )
			{
				ClearInvincible( player )
				KillPlayer( player, eDamageSourceId.damagedef_suicide )
			}
			return
		}

		WaitFrame()
	}
}


void function ReaperTown_AshThanksPilotThink( entity player )
{
	FlagWait( "reapertown_reaper_killed_first" )
	wait 4.0
	waitthread PlayDialogue( "ASH_ThanksPilot", player )

	FlagSet( "reapertown_ash_thanks_pilot" )
}


void function Reapertown_Lift_KillTriggerThink()
{
	entity trigger = GetEntByScriptName( "reapertown_cage_kill_trigger" )
	trigger.WaitSignal( "OnTrigger" )

	entity player = GetPlayerArray()[0]
	player.EndSignal( "OnDestroy" )

	player.Signal( "PlayerDoomedInReapertownLift" )

	if ( IsAlive( player ) )
	{
		KillPlayer( player, eDamageSourceId.damagedef_suicide )
	}
}


void function StartPoint_Setup_ReaperTown( entity player )
{
	TeleportPlayerAndBT( "start_player_ReaperTown", "start_bt_ReaperTown" )
}


void function StartPoint_Skipped_ReaperTown( entity player )
{
}


void function ReaperTown_SkyDomeSetup()
{
	SkyDome_TurnOnDome( eSkindex.white )
}


void function ReaperTown_TruckRotateSetup()
{
	array<entity> rotators = GetEntArrayByScriptName( "reapertown_car_rotator" )
	foreach( rotator in rotators )
	{
		array<entity> trucks = rotator.GetLinkEntArray()
		foreach( truck in trucks )
		{
			// Rotate to a starting position
			vector baseAngles = rotator.GetAngles() //< 90, 0, 0>
			float startDegrees = float( rotator.kv.rotate_to_degrees ) * -1   // We want the opposite to start with

			vector rotateAngles = AnglesCompose( baseAngles, Vector( 0.0, 0.0, startDegrees ) )
			entity mover = CreateScriptMover( truck.GetOrigin(), baseAngles )

			truck.SetParent( mover, "ref", true )
			mover.NonPhysicsRotateTo( rotateAngles, 1.0, 0.0, 0.0 )

			thread ReaperTown_TruckRotateThink( mover, rotator, baseAngles )  // Don't use the rotator to rotate in this scenario as it is buggy.  Use it for it's data.
		}
	}
}


void function ReaperTown_TruckRotateThink( entity mover, entity rotator, vector baseAngles )
{
	float startDelay = 0.0
	float rotateDegrees = 0.0
	float rotateTime  = 0.0
	float rotateEase = 0.0
	string moveSound = ""

	if ( rotator.HasKey( "start_delay" ) )
		startDelay = float( rotator.kv.start_delay )

	if ( rotator.HasKey( "script_sound" ) )
		moveSound = string( rotator.kv.script_sound )

	if ( rotator.HasKey( "rotate_to_time" ) )
		rotateTime = float( rotator.kv.rotate_to_time )

	if ( rotator.HasKey( "rotate_to_ease" ) )
		rotateEase = float( rotator.kv.rotate_to_ease )

	FlagWait( "reapertown_start" )

	wait startDelay

	if ( moveSound != "" )
		EmitSoundAtPosition( TEAM_UNASSIGNED, mover.GetOrigin(), moveSound )

	mover.NonPhysicsRotateTo( baseAngles, 2.0, 0.0, 0.0 )
}


void function ReaperTown_RaisedPlatformSetup()
{
	FlagSet( "reapertown_lower_reaper_platform" )

	entity floorRef = GetEntByScriptName( "reapertown_floor_ref" )
	vector floorRefPos = floorRef.GetOrigin()

	array<entity> movers = GetEntArrayByScriptName( "reapertown_raised_platform_mover" )
	foreach( mover in movers )
	{
		// Lower the platforms down into the ground so we can raise them up when triggered
		vector moverPos = mover.GetOrigin()
		vector targetPos = moverPos
		targetPos.z = floorRefPos.z

		if ( !( "startPos" in mover.s ) )
			mover.s.startPos <- moverPos  // Store the starting position to use later when raising up

		mover.NonPhysicsMoveTo( targetPos, 0.1, 0.0, 0.0 )

		delaythread(1) ReaperTown_RaisedPlatformThink( mover )
	}
}


void function ReaperTown_RaisedPlatformThink( entity mover )
{
	string flag = ""
	float startDelay = 0.0
	float pathSpeed  = 0.0
	string moveSound = ""
	string stopSound = ""

	if ( mover.HasKey( "script_flag" ) )
		flag = string( mover.kv.script_flag )

	if ( mover.HasKey( "start_delay" ) )
		startDelay = float( mover.kv.start_delay )

	if ( mover.HasKey( "path_speed" ) )
		pathSpeed = float( mover.kv.path_speed )

	if ( mover.HasKey( "sound_move" ) )
		moveSound = string( mover.kv.sound_move )

	if ( mover.HasKey( "sound_stop_move" ) )
		stopSound = string( mover.kv.sound_stop_move )


	float dist = Distance( mover.s.startPos, mover.GetOrigin() )
	if ( dist > 0.0 )
	{
		float moveTime = dist / pathSpeed
		float easeInTime = RandomFloatRange( 0.0, moveTime * 0.5 )
		float easeOutTime = RandomFloatRange( 0.0, moveTime * 0.5 )

		//printt("moveTime:",moveTime,"easeInTime",easeInTime,"easeOutTime",easeOutTime )

		//entity mover = CreateScriptMover( brush.GetOrigin(), Vector( 0, 0, 0 ) )
		//ent.SetParent( mover, "ref", true )

		if ( flag != "" )
			FlagWait( flag )

		wait startDelay

		if ( moveSound != "" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, mover.GetOrigin(), moveSound )

		mover.NonPhysicsMoveTo( mover.s.startPos, moveTime, easeInTime, easeOutTime )

		wait moveTime

		if ( stopSound != "" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, mover.GetOrigin(), stopSound )

		wait 0.1

		mover.SetPusher ( true )

		array<entity> linkedEnts = mover.GetLinkEntArray()
		foreach( ent in linkedEnts )
		{
			SetPhysicsMotionOnEnt( ent, false )
		}
	}
}


void function ReaperTown_SetPhysicsMotionOnMovers( bool enabled )
{
	array<entity> movers = GetEntArrayByScriptName( "reapertown_raised_platform_mover" )
	foreach( mover in movers )
	{
		array<entity> linkedEnts = mover.GetLinkEntArray()
		foreach( ent in linkedEnts )
		{
			SetPhysicsMotionOnEnt( ent, enabled )
		}
	}
}


void function SetPhysicsMotionOnEnt( entity ent, bool enabled )
{
	string className = ent.GetClassName()
	switch ( className )
	{
		case "prop_dynamic":
		case "prop_dynamic_lightweight":
		case "func_brush":
		case "func_brush_lightweight":
			ent.PhysicsDummyEnableMotion( enabled )
			break
		default:
			break
	}
}


void function ReaperTown_MilitiaTargetsReaperThink()
{
	entity bullseyeSpot = GetEntByScriptName( "reapertown_militia_bullseye" )
	entity bullseye = SpawnBullseye( TEAM_IMC )
	bullseye.SetOrigin( bullseyeSpot.GetOrigin() + <0,0,50> )

	// Shoot at the glass before it jumps out of the container
	foreach ( guy in GetScriptManagedEntArray( file.friendlyGrunts_GlobalArrayIdx ) )
	{
		if ( IsAlive( guy ) )
			guy.SetEnemyLKP( bullseye, bullseye.GetOrigin() )
	}


	FlagWait( "reapertown_reaper_lands" )

	bullseye.Destroy()

	foreach ( guy in GetScriptManagedEntArray( file.friendlyGrunts_GlobalArrayIdx ) )
	{
		if ( IsAlive( guy ) )
		{
			guy.ClearEnemy()
			guy.ClearPotentialThreatPos()
		}
	}
}


entity function ReaperTown_DeployReaperFromLift( entity player )
{
	entity clipBrush = GetEntByScriptName( "reapertown_lift_clip_brush" )
	clipBrush.Destroy()

	array<entity> reaperSpawners = GetEntArrayByScriptName( "reapertown_reaper_spawner" )
	array<entity> reapers = SpawnFromSpawnerArray( reaperSpawners )
	entity reaper = reapers[0]

	MakeInvincible( reaper )

	reaper.ai.shouldDropBattery = false
	reaper.SetNoTarget( true )
	reaper.EnableNPCFlag( NPC_IGNORE_ALL )

	wait 0.25

	thread PlayAnim( reaper, "sspec_powerup_idle" )
	reaper.Anim_EnablePlanting()

	FlagSet("reapertown_reaper_lift_open")
	wait 2.0
	FlagSet("reapertown_raise_reaper_platform")

	CreateShakeRumbleOnly( player.GetOrigin(), 20, 150, 5 )

	thread ReaperTown_DeliveryAlarm( player, 7 )

	wait 4.0

	FlagSet("reapertown_reaper_lift_plunger_up")

	thread ReaperTown_MilitiaTargetsReaperThink()

	CreateShakeRumbleOnly( player.GetOrigin(), 20, 150, 6 )

	StopMusicTrack( "music_boomtown_17_reapertown_deployspectres" )
	PlayMusic( "music_boomtown_18_reapertown_reaperarrive" )

	wait 4.0
	thread PlayAnim( reaper, "sspec_powerup" )
	reaper.Anim_EnablePlanting()

	FlagWait( "reapertown_lift_plunger_stop" )

	//entity plunger = GetEntByScriptName( "reapertown_reaper_lift_plunger" )
	//TransitionNPCPathsForEntity( plunger, plunger.GetOrigin(), true )

	thread PlayAnim( reaper, "sspec_idle_to_startup_to_attack_f" )
	reaper.Anim_EnablePlanting()

	return reaper
}


void function ReaperTown_BothReapersDeadThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "reapertown_reaper_killed_first" )
	FlagWait( "reapertown_reaper_killed_second" )

	Objective_Clear()

	// Achievement!
	UnlockAchievement( player, achievements.BEAT_REAPERS )
}


void function ReaperTown_PeriodicallySetLKP( entity npc, entity enemy )
{
	npc.EndSignal( "OnDestroy" )
	enemy.EndSignal( "OnDestroy" )

	while( 1 )
	{
		wait REAPER_PLAYER_LKP_PING

		if ( !IsCloaked( enemy ) )
			npc.SetEnemyLKP( enemy, enemy.GetOrigin() )
	}
}


void function ReaperTown_ReaperHealthMonitor( entity reaper, string flag )
{
	reaper.EndSignal( "OnDestroy" )

	int startHealth 	= reaper.GetHealth()
	int healthThreshold = ( startHealth * REAPER_HEALTH_THRESHOLD_PERCENT ) / 100

	OnThreadEnd(
	function() : ( flag )
		{
			printt("ReaperHealthMonitor setting flag:", flag)
			FlagSet( flag )
		}
	)

	while ( 1 )
	{
		if ( reaper.GetHealth() <= healthThreshold )
			return

		wait 0.25
	}
}


void function DEV_ReaperTownDroppodSpawn( entity spawner  )
{
	float dropDuration = 1.25
	entity moveToNode = null
	entity sfxNode = null
	array<entity> spawners = []

	string spawnerName = spawner.GetScriptName()
	var openFlag = spawner.kv.script_noteworthy

	entity pod = CreateDropPod( spawner.GetOrigin() )
	pod.NotSolid()

	array<entity> linkedEnts = spawner.GetLinkEntArray()
	foreach ( entity ent in linkedEnts )
	{
		if ( ent.GetScriptName() == "reapertown_droppod_target" )
			moveToNode = ent
		else if ( ent.GetScriptName() == "reapertown_droppod_door_sfx_spot" )
			sfxNode = ent
		else
			spawners.append( ent )
	}

	FlagSet( string( openFlag ) )

	if ( sfxNode != null )
		EmitSoundAtPosition( TEAM_UNASSIGNED, sfxNode.GetOrigin(), "Boomtown_DomeCeilingOpen" )

	wait 1.0

	wait RandomFloatRange( 0.0, 0.5 )

	entity mover = CreateScriptMover( pod.GetOrigin(), pod.GetAngles() )
	pod.SetParent( mover )
	mover.NonPhysicsMoveTo( moveToNode.GetOrigin(), dropDuration, dropDuration*0.4, dropDuration*0.4 )
	EmitSoundOnEntity( mover, "Boomtown_SpectrePod_Dropped" )

	wait dropDuration

	// Impact FX, SFX, shake, and rumble
	//EmitSoundAtPosition( TEAM_UNASSIGNED, GetPlayerArray()[0].GetOrigin(), "SuperSpectre.Land.Default_3P" )
	PlayFX( $"droppod_impact", mover.GetOrigin() )
	CreateShake( pod.GetOrigin(), 7, 0.15, 1.75, 768 )

	thread PushPlayerAndCreateCollision( pod, spawnerName )

	// Spawn the spectres
	wait 0.5
	SpawnFromSpawnerArray( spawners )

	// Close the skydome door
	wait 3.0
	var closeFlag = moveToNode.kv.script_noteworthy
	FlagSet( string( closeFlag ) )

	if ( sfxNode != null )
		EmitSoundAtPosition( TEAM_UNASSIGNED, sfxNode.GetOrigin(), "Boomtown_DomeCeilingClose" )
}


function PushPlayerAndCreateCollision( entity pod, string spawnerName )
{
	entity point_push = CreateEntity( "point_push" )
	point_push.kv.spawnflags = 8
	point_push.kv.enabled = 1
	point_push.kv.magnitude = 140.0 * 0.75 //Compensate for reduced player gravity to match R1
	point_push.kv.radius = 192.0
	point_push.SetOrigin( pod.GetOrigin() + Vector( 0.0, 0.0, 32.0 ) )
	DispatchSpawn( point_push )

	OnThreadEnd(
		function() : ( point_push )
		{
			point_push.Fire( "Kill", "", 0.0 )
		}
	)

	while ( CheckPlayersIntersectingPod( pod, pod.GetOrigin() ) )
		wait( 0.1 )

	pod.Solid()

	// Move the collision to the pod's location
	entity collisionBrush = GetEntByScriptName( spawnerName + "_col" )
	collisionBrush.SetOrigin( pod.GetOrigin() + < 0, 0, -50 > )
	collisionBrush.SetAngles( pod.GetAngles() )
}


function CheckPlayersIntersectingPod( entity pod, vector targetOrigin )
{
	array<entity> playerList = GetPlayerArray()

	// Multiplying the bounds by 1.42 to ensure this encloses the droppod when it's rotated 45 degrees
	local mins = pod.GetBoundingMins() * 1.42 + targetOrigin
	local maxs = pod.GetBoundingMaxs() * 1.42 + targetOrigin
	local safeRadiusSqr = 250 * 250

	foreach ( player in playerList )
	{
		local playerOrigin = player.GetOrigin()

		if ( DistanceSqr( targetOrigin, playerOrigin ) > safeRadiusSqr )
			continue

		local playerMins = player.GetBoundingMins() + playerOrigin
		local playerMaxs = player.GetBoundingMaxs() + playerOrigin

		if ( BoxIntersectsBox( mins, maxs, playerMins, playerMaxs ) )
			return true
	}

	return false
}


// -------------------------------------------------------------------------------------------------------------------------
//
//  ██████╗ █████╗ ██╗     ██╗     ██████╗  █████╗  ██████╗██╗  ██╗███████╗
// ██╔════╝██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝
// ██║     ███████║██║     ██║     ██████╔╝███████║██║     █████╔╝ ███████╗
// ██║     ██╔══██║██║     ██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ╚════██║
// ╚██████╗██║  ██║███████╗███████╗██████╔╝██║  ██║╚██████╗██║  ██╗███████║
//  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function Boomtown_EntitiesDidLoad()
{
	Assembly_EntitiesDidLoad()

	ReaperTown_SetPhysicsMotionOnMovers( false )

	// Optimization: store these for later so we don't call GetEntByScriptName() twice per frame later
	file.teleportStartRefPos  = GetEntByScriptName( "reaper_town_teleport_start_ref" ).GetOrigin()
	file.teleportTargetRefPos = GetEntByScriptName( "reaper_town_teleport_target_ref" ).GetOrigin()
}


void function OnSpawnedPropDynamic( entity propDynamic )
{
	local scriptName = propDynamic.GetScriptName()

	if ( propDynamic.HasKey( "script_noteworthy" ) && propDynamic.kv.script_noteworthy == "fakeDropPod" )
		thread DoFakeDropPodSpawn( propDynamic )
}


void function OnSpawnedTrigger( entity trigger )
{
	local entName = trigger.GetTargetName()
	string scriptName = trigger.GetScriptName()
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
// ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
// ██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
// ██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
// ╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
//  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function AssaultEntity( entity guy, entity target, float radius = 1024 )
{
	vector origin = target.GetOrigin()
	vector angles = target.GetAngles()
	if ( target.HasKey( "script_goal_radius" ) )
		radius = float( target.kv.script_goal_radius )

	guy.AssaultPoint( origin )
	guy.AssaultSetGoalRadius( radius )

	if ( target.HasKey( "face_angles" ) && target.kv.face_angles == "1" )
		guy.AssaultSetAngles( angles, true )
}

void function DoFakeDropPodSpawn( entity pod )
{
	float dropDuration = 0.75
	entity moveToNode = null
	array<entity> spawners = []

	array<entity> linkedEnts = pod.GetLinkEntArray()
	foreach ( entity ent in linkedEnts )
	{
		if ( ent.GetScriptName() == "moveToNode" )
			moveToNode = ent
		else
			spawners.append( ent )
	}

	wait RandomFloatRange( 0.0, 0.5 )

	entity mover = CreateScriptMover( pod.GetOrigin(), pod.GetAngles() )
	pod.SetParent( mover )
	mover.NonPhysicsMoveTo( moveToNode.GetOrigin(), dropDuration, dropDuration*0.4, dropDuration*0.4 )

	wait dropDuration

	PlayFX( $"droppod_impact", mover.GetOrigin() )

	wait 1.0

	SpawnFromSpawnerArray( spawners )

	wait 3.0

	pod.Destroy()
}

void function TriggerDisableDoubleJump( entity trigger )
{
	trigger.SetEnterCallback( TriggerDisableDoubleJumpEnter )
	trigger.SetLeaveCallback( TriggerDisableDoubleJumpLeave )
}

void function TriggerDisableDoubleJumpEnter( entity trigger, entity player )
{
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "disable_doublejump" ] )
}

void function TriggerDisableDoubleJumpLeave( entity trigger, entity player )
{
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [] )
}