untyped
global function gf 			// get file
global function ControlRoomBattle_End_ColeAnim
global function ControlRoomBattle_End_IkeAnim
global function ControlRoomBattle_End_Dudes
global function CodeCallback_MapInit

global function StaticSwarmStalkersDeath

const FX_SKYBOX_REDEYE_WARP_IN = $"veh_red_warp_in_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_IN = $"veh_birm_warp_in_FULL"
const SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM = $"models/vehicle/capital_ship_Birmingham/birmingham_space.mdl"
const SKYBOX_ARMADA_SHIP_MODEL_REDEYE = $"models/vehicle/redeye/redeye_background_01_LO.mdl"
const UPLINK_MODULE_MODEL = $"models/levels_terrain/sp_beacon/beacon_dish_module.mdl"
const asset ARC_TOOL_ANIMATED_MODEL = $"models/props/arc_tool_sp/arc_tool_sp_animated.mdl"
const MISSILE_MODEL = $"models/weapons/bullets/rocket_missile.mdl"
const MISSILE_TRAIL = $"Rocket_Smoke_Large"
const MISSILE_FLASH = $"wpn_muzzleflash_xo_rocket"
const MISSILE_EXPLOSION = $"P_exp_wall_concrete"
const WIDOW_MODEL = $"models/vehicle/widow/widow.mdl"
const DISH_ARMS_MODEL = $"models/levels_terrain/sp_beacon/beacon_dish_animated.mdl"
const CABLE_MODEL = $"models/levels_terrain/sp_beacon/beacon_cable_animated.mdl"

const EFFECT_CONTRAILS = $"veh_contrails_01"
const EFFECT_JETWASH = $"veh_jetwash_exit_eng_blast"

const SCREEN_MODEL_01_ON = $"models/beacon/beacon_small_screen_01.mdl"
const SCREEN_MODEL_01_OFF = $"models/beacon/beacon_small_screen_01_off.mdl"
const SCREEN_MODEL_02_ON = $"models/beacon/beacon_small_screen_02.mdl"
const SCREEN_MODEL_02_OFF = $"models/beacon/beacon_small_screen_02_off.mdl"

const HANGING_CRANE_MODEL = $"models/levels_terrain/sp_beacon/beacon_dish_new_construction.mdl"
const asset STRATON_MODEL = $"models/vehicle/straton/straton_imc_gunship_01.mdl"

const float DISH_SLIDE_DURATION = 2.4

struct Flyer
{
	entity model
	entity ref
	float health
	bool perched
}

struct NodeAnimPair
{
	entity node
	string anim
}

struct MyFile
{
	array<Flyer> flyers
	array<entity> controlRoomBattleEnemies
	array<entity> returnToHubEnemies

	array<string> stalkerClimbAnims = [ "st_beacon_swarm_climb_A", "st_beacon_swarm_climb_B", "st_beacon_swarm_climb_C", "st_beacon_swarm_climb_D", "st_beacon_swarm_climb_E" ]
	array<string> stalkerClimbIdles = [ "st_beacon_swarm_idle_A", "st_beacon_swarm_idle_B", "st_beacon_swarm_idle_C", "st_beacon_swarm_idle_D", "st_beacon_swarm_idle_E" ]
	array<entity> stalkerClimbSlots = [ null, null, null, null, null ]

	entity mike
	entity ike
	entity gren
	array<entity> controlRoomGrunts
	entity controlRoomCable
	entity satelliteDishHatch

	int controlRoomBattleEnemiesShot = 0
	int controlRoomBattleEnemiesStomped = 0

	entity highlightDishModel
	entity module1
	entity module2
}
MyFile file

void function CodeCallback_MapInit()
{
	// Force correct loadout choices in Trial
	if ( Script_IsRunningTrialVersion() )
		SetBTLoadoutsUnlockedBitfield( 31 )

	SPBeaconGlobals()
	BeaconEndingInit()

#if SERVER && DEV
	MarkNPCForAutoPrecache( "npc_soldier_hero_sarah" )
#endif // 	#if SERVER && DEV

	AddCallback_EntitiesDidLoad( Beacon_EntitiesDidLoad )

	ShSpBeaconHubCommonInit()
	PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_IN )
	PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_IN )
	PrecacheParticleSystem( CHARGE_BEAM_GHOST_EFFECT )
	PrecacheParticleSystem( MISSILE_TRAIL )
	PrecacheParticleSystem( MISSILE_FLASH )
	PrecacheParticleSystem( MISSILE_EXPLOSION )
	PrecacheParticleSystem( EFFECT_CONTRAILS )
	PrecacheParticleSystem( EFFECT_JETWASH )

	PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM )
	PrecacheModel( SKYBOX_ARMADA_SHIP_MODEL_REDEYE )
	PrecacheModel( DROPSHIP_MODEL )
	PrecacheModel( FLYER_MODEL )
	PrecacheModel( STRATON_MODEL )
	PrecacheModel( MISSILE_MODEL )
	PrecacheModel( WIDOW_MODEL )
	PrecacheModel( DISH_ARMS_MODEL )
	PrecacheModel( CABLE_MODEL )
	PrecacheModel( UPLINK_MODULE_MODEL )
	PrecacheModel( SCREEN_MODEL_01_ON )
	PrecacheModel( SCREEN_MODEL_01_OFF )
	PrecacheModel( SCREEN_MODEL_02_ON )
	PrecacheModel( SCREEN_MODEL_02_OFF )
	PrecacheModel( HANGING_CRANE_MODEL )
	PrecacheModel( ARC_TOOL_GHOST_WORLD_MODEL )
	PrecacheModel( ARC_TOOL_ANIMATED_MODEL )

	FlagInit( "passed_through_spoke_1" ) // to avoid script error due to map not being compiled yet, can remove this.
	FlagInit( "Spoke1_second_fight_left_tower_cleared" )
	FlagInit( "Spoke1_second_fight_UsedZipline" )
	FlagInit( "PlayerHelpingControlRoomBattle" )
	FlagInit( "BigCraneDone" )
	FlagInit( "ControlRoomBattleEnded" )
	FlagInit( "ShouldBeAssistingControlRoomFight" )
	FlagInit( "ControlRoomSkitGrunts" )
	FlagInit( "ControlRoomSkitGrunts2" )
	FlagInit( "PowerArrayActivated" )
	FlagInit( "ControlRoomElevatorUp" )
	FlagInit( "PilotAndTitanInsideControlRoom" )
	FlagInit( "ControlRoomASceneDone" )
	FlagInit( "PlayerEnteredBTAfterPoweringUpControlRoom" )
	FlagInit( "PlayerFastballToSpoke1" )
	FlagInit( "ReturnToHubBattleOver" )
	FlagInit( "MissileControlRoom" )
	FlagInit( "FinalBattle" )
	FlagInit( "SecureControlRoomDoorDialogueDone" )
	FlagInit( "PlayerSeesZipliner" )
	FlagInit( "ControlRoomWindowsOpen" )
	FlagInit( "MikeIkeActivatedElevator" )
	FlagInit( "ControlRoomCSequenceStart" )
	FlagInit( "ModuleAnimSequence1Done" )
	FlagInit( "ModuleAnimSequence2Done" )
	FlagInit( "PlayerHealthComesBack" )
	FlagInit( "AllDelayedHubEnemiesSpawned" )
	FlagInit( "ControlRoomASceneStarted" )
	FlagInit( "ThrownToDish" )
	FlagInit( "Module2CanBeReplaced" )
	FlagInit( "SecondBeaconBacktrackCheckpoint" )
	FlagInit( "BossFight" )

	FlagInit( "SavedOurAsses" )
	FlagInit( "ElevatorIsUp" )
	FlagInit( "ElevatorIsDown" )
	FlagInit( "DoFastball1Objective" )

	RegisterSignal( "doorknock" )
	RegisterSignal( "StopDropShipIdle" )
	RegisterSignal( "FlyerDisturbed" )
	RegisterSignal( "FlyerDeath" )
	RegisterSignal( "NinjaHides" )
	RegisterSignal( "DishSlide" )
	RegisterSignal( "DishSlideCancel" )
	RegisterSignal( "RunOverEnemiesEndThread" )
	RegisterSignal( "RanOverEnemiesEndThread" )
	RegisterSignal( "ControlRoomBattle_NagInactivePlayer" )
	RegisterSignal( "PlayerEquippedArcToolAtInnerHatch" )
	RegisterSignal( "HubEnemyKilledByPlayer" )
	RegisterSignal( "HubEnemyKilledByBT" )

	AddStartPoint( "Level Start", 			StartPoint_Start, 						StartPoint_Setup_Start, 					StartPoint_Skipped_Start )
	AddStartPoint( "Control Room", 			StartPoint_ControlRoom, 				StartPoint_Setup_ControlRoom,				StartPoint_Skipped_ControlRoom )
	AddStartPoint( "Spoke_0_Complete", 		StartPoint_GotChargeTool, 				StartPoint_Setup_GotChargeTool, 			StartPoint_Skipped_GotChargeTool )
	AddStartPoint( "Power Relays Online", 	StartPoint_PowerRelaysOnline, 			StartPoint_Setup_PowerRelaysOnline, 		StartPoint_Skipped_PowerRelaysOnline )
	AddStartPoint( "Fastball to Spoke 1", 	StartPoint_FastballToSpoke1, 			StartPoint_Setup_FastballToSpoke1,			StartPoint_Skipped_FastballToSpoke1 )
	AddStartPoint( "Spoke 1 Start", 		StartPoint_Spoke1_Start, 				StartPoint_Setup_Spoke1_Start,				StartPoint_Skipped_Spoke1_Start )
	AddStartPoint( "Spoke 1 First Combat", 	StartPoint_Spoke1_FirstFight, 			StartPoint_Setup_Spoke1_FirstFight, 		StartPoint_Skipped_Spoke1_FirstFight )
	AddStartPoint( "Spoke 1 Second Combat",	StartPoint_Spoke1_SecondFight, 			StartPoint_Setup_Spoke1_Secondfight, 		StartPoint_Skipped_Spoke1_SecondFight )
	AddStartPoint( "Spoke 1 Pillar Room",	StartPoint_Spoke1_PillarRoom, 			StartPoint_Setup_Spoke1_PillarRoom, 		StartPoint_Skipped_Spoke1_PillarRoom )
	AddStartPoint( "Double Crane Puzzle", 	StartPoint_Spoke1_Crane_Puzzle_Start, 	StartPoint_Setup_Spoke1_Crane_Puzzle, 		StartPoint_Skipped_Crane_Puzzle )
	AddStartPoint( "Second Beacon", 		StartPoint_Second_Beacon, 				StartPoint_Setup_Second_Beacon, 			StartPoint_Skipped_Second_Beacon )
	AddStartPoint( "Spoke 1 Arena", 		StartPoint_Spoke1_Arena, 				StartPoint_Setup_Spoke1_Arena, 				StartPoint_Skipped_Spoke1_Arena )
	AddStartPoint( "Wallrun Panels", 		StartPoint_Spoke1_Panels, 				StartPoint_Setup_Spoke1_Panels, 			StartPoint_Skipped_Spoke1_Panels )
	AddStartPoint( "Back at HUB", 			StartPoint_Return_To_Beacon, 			StartPoint_Setup_Return_To_Beacon, 			StartPoint_Skipped_Return_To_Beacon )
	AddStartPoint( "Climb Dish", 			StartPoint_Climb_Dish, 					StartPoint_Setup_Climb_Dish, 				StartPoint_Skipped_Climb_Dish )
	AddStartPoint( "Final Battle", 			StartPoint_Final_Battle, 				StartPoint_Setup_Final_Battle, 				StartPoint_Skipped_Final_Battle )
	AddStartPoint( "Send Signal", 			StartPoint_Send_Signal, 				StartPoint_Setup_Send_Signal, 				StartPoint_Skipped_Send_Signal )
	AddStartPoint( "Beacon Ending",			StartPoint_Beacon_Ending, 				StartPoint_Setup_Beacon_Ending )

	AddScriptNoteworthySpawnCallback( "HubFightEnemy", AddTrackedHubFightEnemy )
	AddScriptNoteworthySpawnCallback( "SecondBeaconReaper", SecondBeaconReaperSpawned )

	AddMobilityGhost( $"anim_recording/sp_beacon_round_run1.rpak" )
	AddMobilityGhost( $"anim_recording/sp_beacon_round_run2.rpak" )
	AddMobilityGhost( $"anim_recording/sp_beacon_dish_arm_walk.rpak", "BigCraneDone" )
	AddMobilityGhost( $"anim_recording/sp_beacon_dish_wallrun1.rpak" )
	AddMobilityGhost( $"anim_recording/sp_beacon_dish_wallrun2.rpak" )
	AddMobilityGhostWithCallback( $"anim_recording/sp_beacon_wallrun_panels1.rpak", GhostRecorderCallback_WallrunPanels )
	AddMobilityGhostWithCallback( $"anim_recording/sp_beacon_wallrun_panels2.rpak", GhostRecorderCallback_WallrunPanels )
	AddMobilityGhostWithCallback( $"anim_recording/sp_beacon_wallrun_panels2b.rpak", GhostRecorderCallback_WallrunPanels )
}

MyFile function gf()
{
	return file
}

//---------------------------------------------------------------------

//	███████╗████████╗ █████╗ ██████╗ ████████╗
//	██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
//	███████╗   ██║   ███████║██████╔╝   ██║
//	╚════██║   ██║   ██╔══██║██╔══██╗   ██║
//	███████║   ██║   ██║  ██║██║  ██║   ██║
//	╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

void function StartPoint_Start( entity player )
{
	ShowIntroScreen( player )
	FlagWait( "IntroScreenFading" )

	Remote_CallFunction_NonReplay( player, "ServerCallback_LevelIntroText" )

	entity arms = GetEntByScriptName( "dish_arms2" )
	arms.Anim_Play( "open" )

	ElevatorDown()

	SpawnControlRoomMikeAndIke()
	thread OpeningDialogue( player )
	thread SpawnControlRoomNPCs()
	thread ControlRoomBattle( player )
	thread ControlRoomBattleTimedEvents( player )

	SetDishAngle( 32 )
	CloseShutters( true )

	PlayMusic( "Music_Beacon_1_LevelStart" )

	FlagWait( "ControlRoomBattleEnded" )

	SetGlobalNetBool( "controlRoomBattleAmbient", false )
	Remote_CallFunction_Replay( player, "ServerCallback_ControlRoomBattleAmbient", false )

	CheckPoint()
}

void function StartPoint_Setup_Start( entity player )
{
	FlagSet( "CenterArcSwitchesEnabled" )
}

void function StartPoint_Skipped_Start( entity player )
{
	SetGlobalNetBool( "controlRoomBattleAmbient", false )
	Remote_CallFunction_Replay( player, "ServerCallback_ControlRoomBattleAmbient", false )
	FlagSet( "ControlRoomBattleEnded" )
}

//---------------------------------------------------------------------

// ██████╗ ██████╗ ███╗   ██╗████████╗██████╗  ██████╗ ██╗         ██████╗  ██████╗  ██████╗ ███╗   ███╗
//██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗██║         ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║
//██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║██║         ██████╔╝██║   ██║██║   ██║██╔████╔██║
//██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║██║         ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║
//╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║╚██████╔╝███████╗    ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║
// ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝

void function StartPoint_ControlRoom( entity player )
{
	Objective_Clear()

	printt( "START POINT - CONTROL ROOM" )

	// Mike & Ike will now open the control room door for the player
	FlagWait( "ControlRoomDoorOpen" )
	FlagSet( "FriendlyFireStrict" )

	FlagSet( "Door2ToSpok0Open" )

	Objective_Set( "#BEACON_OBJECTIVE_GO_TO_CONTROL_ROOM", GetEntByScriptName( "ControlRoomObjectiveLocation" ).GetOrigin() )

	SetGlobalForcedDialogueOnly( true )
	ControlRoomCableCollisionDisconnected()

	// Spawns and starts the skit grunts in the room
	FlagSet( "ControlRoomSkitGrunts" )
	FlagSetOnFlag( "ControlRoomSkitGrunts2", "EnteredControlRoom" )

	thread ControlRoomInteriorScene( player )
	thread DoorGuyOpensDoor( player )
	waitthread WaittillControlRoomElevatorReady( player )

	Embark_Disallow( player )

	Objective_Clear()

	FlagWait( "MikeIkeActivatedElevator" )

	// Move the elevator up
	ElevatorUp( 3.5 )
	FlagSet( "ControlRoomElevatorUp" )

	// Load Spoke 0
	FlagWait( "LoadSpoke0" )

	thread PlayBTDialogue( "BT_GoodLuckPilot" )

	PickStartPoint( "sp_beacon_spoke0", "Level Start" )
	WaitForever()
}

void function StartPoint_Setup_ControlRoom( entity player )
{
	TeleportPlayerAndBT( "control_room_titan_start", "control_room_titan_start" )
	ElevatorDown()
	SpawnControlRoomMikeAndIke()
	SetDishAngle( 32 )

	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	FlagSet( "ControlRoomDoorOpen" )
	FlagSet( "CenterArcSwitchesEnabled" )

	PlayMusic( "Music_Beacon_3_AllThreatsEliminated" )

	entity arms = GetEntByScriptName( "dish_arms2" )
	arms.Anim_Play( "open" )
}

void function StartPoint_Skipped_ControlRoom( entity player )
{
	FlagSet( "FriendlyFireStrict" )
}

void function WaittillControlRoomElevatorReady( entity player )
{
	// Wait until the player and titan are on the elevator before we raise it up
	EndSignal( player, "OnDeath" )

	while ( true )
	{
		entity bt = player.GetPetTitan()

//		printt( "PlayerOnElevator:", Flag( "PlayerOnElevator" ) )
//		printt( "TitanOnElevator:", Flag( "TitanOnElevator" ) )
//		printt( "BT:", bt )
//		printt( "PlayerIsTitan:", player.IsTitan() )

		if ( IsValid( bt ) )
			bt.AssaultSetArrivalTolerance( 100 )

		if ( ( !IsValid( bt ) || player.IsTitan() ) && Flag( "PlayerOnElevator" ) )
			break

		if ( Flag( "PlayerOnElevator" ) && Flag( "TitanOnElevator" ) )
			break

		WaitFrame()
	}

	FlagSet( "PilotAndTitanInsideControlRoom" )
	entity clip = GetEntByScriptName( "elevatorwallclip" )
	clip.Solid()
	ToggleNPCPathsForEntity( clip, false )
}

void function DoorGuyOpensDoor( entity player )
{
	// Spawn grunt
	entity node = GetEntByScriptName( "spoke0_door_guard_node" )
	entity grunt = file.gren//CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )

	// Idle
	thread PlayAnimTeleport( grunt, "pt_door_guard_A_start", node )

	// Wait for trigger
	FlagWait( "ControlRoomASceneDone" )

	// Do the sequence and idle again
	thread WaitForDoorGuySignal( grunt )
	waitthread PlayAnim( grunt, "pt_door_guard_A", node )
	thread PlayAnim( grunt, "pt_door_guard_A_start", node )
}

void function WaitForDoorGuySignal( entity grunt )
{
	EndSignal( grunt, "OnDestroy" )
	WaitSignal( grunt, "doorknock" )

	OnThreadEnd(
		function() : (  )
		{
			FlagSet( "Door1ToSpoke0Open" )
		}
	)

	// Good luck sir, hope you make it back. We've lost too many down there.
	thread PlayDialogue( "Grunt_GoodLuckSir", grunt )
}

//---------------------------------------------------------------------

//	 ██████╗  ██████╗ ████████╗     ██████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ███████╗    ████████╗ ██████╗  ██████╗ ██╗
//	██╔════╝ ██╔═══██╗╚══██╔══╝    ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝ ██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║
//	██║  ███╗██║   ██║   ██║       ██║     ███████║███████║██████╔╝██║  ███╗█████╗         ██║   ██║   ██║██║   ██║██║
//	██║   ██║██║   ██║   ██║       ██║     ██╔══██║██╔══██║██╔══██╗██║   ██║██╔══╝         ██║   ██║   ██║██║   ██║██║
//	╚██████╔╝╚██████╔╝   ██║       ╚██████╗██║  ██║██║  ██║██║  ██║╚██████╔╝███████╗       ██║   ╚██████╔╝╚██████╔╝███████╗
//	 ╚═════╝  ╚═════╝    ╚═╝        ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚════  ╚═╝    ╚═════╝  ╚═════╝ ╚════════╝     ╝

void function StartPoint_GotChargeTool( entity player )
{
	entity arms = GetEntByScriptName( "dish_arms2" )
	arms.Anim_Play( "open" )

	FlagSet( "Spoke0Completed" )

	ControlRoomCableCollisionConnected()

	thread BeaconBeamScreenEffects( player, "fx_Beacon_beam" )

	printt( "START POINT - GOT CHARGE TOOL")
	PlayerReturnedFromSpoke0( player )
	FlagSet( "ControlRoomSkitGrunts" )
	FlagSet( "ControlRoomSkitGrunts2" )
	ElevatorUp()

	PlayMusic( "Music_Beacon_9_BackToHubSuccessStinger" )

//	thread ClearFriendlyHighLightsInControlRoom()
	SpawnControlRoomMikeAndIke()
	thread PowerUpArcSwitchArray( player )
	waitthread ControlRoomBScene_BeforePower( player )
}

void function StartPoint_Setup_GotChargeTool( entity player )
{
	TeleportPlayerAndBT( "got_tool_player_start", "got_tool_titan_start" )
	SetDishAngle( 32 )
	CloseShutters( true )
}

void function StartPoint_Skipped_GotChargeTool( entity player )
{
	entity arms = GetEntByScriptName( "dish_arms2" )
	arms.Anim_Play( "open" )

	if ( !HasBatteryChargeTool( player ) )
		GiveBatteryChargeTool( player )

	SpawnControlRoomMikeAndIke()

	PlayerReturnedFromSpoke0( player )
	SetDishAngle( 0 )
	FlagSet( "PowerArrayActivated" )
	FlagClear( "PowerArrayDoorInner" )
	FlagSet( "Spoke0Completed" )

	entity controlRoomNode = GetEntByScriptName( "control_room_node" )
	thread PlayAnimTeleport( file.controlRoomCable, "cable_beacon_plugged", controlRoomNode )

	thread BeaconBeamScreenEffects( player, "fx_Beacon_beam" )
}

//---------------------------------------------------------------------

//	██████╗  ██████╗ ██╗    ██╗███████╗██████╗     ██████╗ ███████╗██╗      █████╗ ██╗   ██╗███████╗     ██████╗ ███╗   ██╗██╗     ██╗███╗   ██╗███████╗
//	██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗    ██╔══██╗██╔════╝██║     ██╔══██╗╚██╗ ██╔╝██╔════╝    ██╔═══██╗████╗  ██║██║     ██║████╗  ██║██╔════╝
//	██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝    ██████╔╝█████╗  ██║     ███████║ ╚████╔╝ ███████╗    ██║   ██║██╔██╗ ██║██║     ██║██╔██╗ ██║█████╗
//	██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗    ██╔══██╗██╔══╝  ██║     ██╔══██║  ╚██╔╝  ╚════██║    ██║   ██║██║╚██╗██║██║     ██║██║╚██╗██║██╔══╝
//	██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║    ██║  ██║███████╗███████╗██║  ██║   ██║   ███████║    ╚██████╔╝██║ ╚████║███████╗██║██║ ╚████║███████╗
//	╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝

void function StartPoint_PowerRelaysOnline( entity player )
{
	printt( "START POINT - POWER RELAYS ONLINE" )

	CheckPoint()

	wait 1.0 //wait for elevator to go up if starting at this start point

	waitthread ControlRoomBScene_AfterPower( player )
	thread BTMentionDeadTroops( player )

	FlagSet( "CenterArcSwitchesEnabled" )

	FlagWait( "CenterDoorsOpen" )
}

void function StartPoint_Setup_PowerRelaysOnline( entity player )
{
	TeleportPlayerAndBT( "powered_array_player_start", "got_tool_titan_start" )
	SetDishAngle( 32 )
	ElevatorUp()
	CloseShutters( true )
	FlagSet( "ControlRoomSkitGrunts" )
	FlagSet( "ControlRoomSkitGrunts2" )
}

void function StartPoint_Skipped_PowerRelaysOnline( entity player )
{
	// Shutters are open
	OpenShutters( true )

	// Door is open
	FlagSet( "ControlRoomDoorOpen" )

	FlagSet( "DishRingsActivate" )
	thread ControlRoomScreensPowerOn()

	// Make sure beacon effects are on if you skipped the bootup sequence
	FlagSet( "fx_Beacon_lights" )
	FlagSet( "fx_Beacon_beam" )
}

//---------------------------------------------------------------------

//	███████╗ █████╗ ███████╗████████╗██████╗  █████╗ ██╗     ██╗         ████████╗ ██████╗     ███████╗██████╗  ██████╗ ██╗  ██╗███████╗     ██╗
//	██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██║     ██║         ╚══██╔══╝██╔═══██╗    ██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝    ███║
//	█████╗  ███████║███████╗   ██║   ██████╔╝███████║██║     ██║            ██║   ██║   ██║    ███████╗██████╔╝██║   ██║█████╔╝ █████╗      ╚██║
//	██╔══╝  ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║██║     ██║            ██║   ██║   ██║    ╚════██║██╔═══╝ ██║   ██║██╔═██╗ ██╔══╝       ██║
//	██║     ██║  ██║███████║   ██║   ██████╔╝██║  ██║███████╗███████╗       ██║   ╚██████╔╝    ███████║██║     ╚██████╔╝██║  ██╗███████╗     ██║
//	╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝    ╚═════╝     ╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═╝

void function StartPoint_FastballToSpoke1( entity player )
{
	printt( "START POINT - FASTBALL TO SPOKE 1" )

	// BT should fastball the player to spoke 1 now

	FlagClear( "Door1ToSpoke0Open" )

	// Throw to spoke 1
	waitthread ThrowToSpoke1( player )

	FlagWait( "StartedSpoke1" )

	CheckPoint()

	thread PlayerConversation( "FastballComplete", player )
}

void function StartPoint_Setup_FastballToSpoke1( entity player )
{
	printt( "StartPoint_Setup_FastballToSpoke1" )

	TeleportPlayerAndBT( "fastball_player_start", "fastball_titan_start" )

	wait 1.0

	FlagSet( "EnteredBeaconFacility" )
}

void function StartPoint_Skipped_FastballToSpoke1( entity player )
{
	Objective_Set( "#BEACON_OBJECTIVE_GET_TO_SECOND_DISH", < -256, -592, 96 >, GetEntByScriptName( "dish_on_crane" ) )
	Objective_StaticModelHighlightOverrideEntity( file.highlightDishModel )
}

//---------------------------------------------------------------------

//	███████╗██████╗  ██████╗ ██╗  ██╗███████╗     ██╗    ███████╗████████╗ █████╗ ██████╗ ████████╗
//	██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝    ███║    ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
//	███████╗██████╔╝██║   ██║█████╔╝ █████╗      ╚██║    ███████╗   ██║   ███████║██████╔╝   ██║
//	╚════██║██╔═══╝ ██║   ██║██╔═██╗ ██╔══╝       ██║    ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
//	███████║██║     ╚██████╔╝██║  ██╗███████╗     ██║    ███████║   ██║   ██║  ██║██║  ██║   ██║
//	╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═╝    ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

void function StartPoint_Spoke1_Start( entity player )
{
	printt( "START POINT - SPOKE 1 START" )

	SetGlobalForcedDialogueOnly( false )

	// Shut the beacon center doors and disable the arc switches. We reenable them after the dish climb
	FlagClear( "CenterDoorsOpen" )
	FlagClear( "CenterArcSwitchesEnabled" )

	DestroySkitGrunts()

	thread FirstDropshipsDialogue( player )
	thread IMCRadioInterceptDialogue( player )

	FlagWait( "FirstCranePuzzleComplete" )
	CheckPoint()
}

void function StartPoint_Setup_Spoke1_Start( entity player )
{
	TeleportPlayerAndBT( "spoke1_player_start", "spoke1_titan_start" )
}

void function StartPoint_Skipped_Spoke1_Start( entity player )
{
	// Shut the beacon center doors and disable the arc switches. We reenable them after the dish climb
	FlagClear( "CenterDoorsOpen" )
	FlagClear( "CenterArcSwitchesEnabled" )

	wait 1.0
	SetCraneYaw( GetEntByScriptName( "first_crane" ), 250 )
}

void function FirstDropshipsDialogue( entity player )
{
	entity trigger = GetEntByScriptName( "FirstCombatSpawnTrigger" )
	WaitSignal( trigger, "OnTrigger" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, <0,0,0>, "Beacon_Flying_3_ships" )

	// IMC dropships headed to your location.
	PlayBTDialogue( "BT_IMCDropships" )
}

void function IMCRadioInterceptDialogue( entity player )
{
	wait 5.0

	// Richter, this is Blisk.
	waitthread PlayDialogue( "Blisk_This_Is_Blisk", player )

	wait 0.3

	// Ja, dies ist Richter.
	waitthread PlayDialogue( "Richter_Dies_Ist_Richter", player )

	wait 0.3

	// That damn Pilot is trying to use the beacon. End this. I’m counting on you. Blisk out.
	waitthread PlayDialogue( "Blisk_Pilot_Trying_To_Use_Beacon", player )

	wait 2.0

	// All security units, this is Richter. Get to the beacon now. Find that Kleine Mann. Jetzt. Lass mich nicht hängen.
	waitthread PlayDialogue( "Richter_Get_To_Beacon_Now", player )

	wait 0.5

	// Copy that. Zulu One, Kilo One, move in! Alpha two, get soldiers on ground! Move it!
	waitthread PlayDialogue( "Comms_CopyThat", player )
}

//---------------------------------------------------------------------

//	███████╗██████╗  ██████╗ ██╗  ██╗███████╗     ██╗    ███████╗██╗██████╗ ███████╗████████╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
//	██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝    ███║    ██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
//	███████╗██████╔╝██║   ██║█████╔╝ █████╗      ╚██║    █████╗  ██║██████╔╝███████╗   ██║       █████╗  ██║██║  ███╗███████║   ██║
//	╚════██║██╔═══╝ ██║   ██║██╔═██╗ ██╔══╝       ██║    ██╔══╝  ██║██╔══██╗╚════██║   ██║       ██╔══╝  ██║██║   ██║██╔══██║   ██║
//	███████║██║     ╚██████╔╝██║  ██╗███████╗     ██║    ██║     ██║██║  ██║███████║   ██║       ██║     ██║╚██████╔╝██║  ██║   ██║
//	╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

void function StartPoint_Spoke1_FirstFight( entity player )
{
	printt( "START POINT - SPOKE 1 MIDFIGHT START" )

	StopMusicTrack( "Music_Beacon_14_BTThrowThruFirstCrane" )
	PlayMusic( "Music_Beacon_15A_FirstDropshipAttack_Ambient" )

	thread ReinforcementsDialogue1( player )
	thread DeployStalkersDialogue( player )

	FlagWait( "Spoke1_first_fight_complete" )

	CheckPoint()
}

void function StartPoint_Setup_Spoke1_FirstFight( entity player )
{
	TeleportPlayerAndBT( "spoke1_midfight_player_start", "spoke1_titan_start" )
}

void function StartPoint_Skipped_Spoke1_FirstFight( entity player )
{
}

void function ReaperFlyin()
{
	FlagWait( "reaper_flyin" )

	entity node = GetEntByScriptName( "reaper_arrival_node" )

	waitthread WarpinEffect( DROPSHIP_MODEL, "ds_sspec_dropship_deploy_flyin_01", node.GetOrigin(), node.GetAngles() )

	entity dropship = CreateDropship( TEAM_IMC, < 0, 0, 0 >, < 0, 0, 0 > )
	DispatchSpawn( dropship )

	entity reaperSpawner = GetEntByScriptName( "second_fight_super_spectre" )
	entity reaper = reaperSpawner.SpawnEntity()
	DispatchSpawn( reaper )

	WaitFrame()

	// Flyin
	thread ReaperFlyin_Ship( dropship, node )
	thread ReaperFlyin_Reaper( reaper, node )
}

void function ReaperFlyin_Ship( entity dropship, entity node )
{
	EndSignal( dropship, "OnDeath" )

	waitthread PlayAnimTeleport( dropship, "ds_sspec_dropship_deploy_flyin_01", node, 0 )
	WarpoutEffect( dropship )
	dropship.Destroy()
}

void function ReaperFlyin_Reaper( entity reaper, entity node )
{
	EndSignal( reaper, "OnDeath" )

	OnThreadEnd(
	function() : ()
		{
			StopMusicTrack( "Music_Beacon_15A_FirstDropshipAttack_Ambient" )
			StopMusicTrack( "Music_Beacon_15B_FirstDropshipAttack_Percussive" )
			PlayMusic( "music_beacon_16a_second_dropship_wave" )
			CheckPoint()
		}
	)

	PlayAnimTeleport( reaper, "sspec_dropship_deploy_flyin_01", node, 0 )
	PlayAnim( reaper, "sspec_dropship_deploy_release", node, 0 )

	entity mover = CreateOwnedScriptMover( reaper )
	reaper.SetParent( mover, "", false )

	// Animate while falling
	thread PlayAnim( reaper, "sspec_dropship_deploy_fall_idle", mover, 0 )

	PlayMusic( "Music_Beacon_15B_FirstDropshipAttack_Percussive" )

	vector landPos = OriginToGround( reaper.GetOrigin() + <0,0,1> )
	int index = reaper.LookupSequence( "sspec_dropship_deploy_landing" )
	vector delta = reaper.GetAnimDeltas( index, 0, 1 )
	landPos.z -= delta.z

	float dist = Distance( reaper.GetOrigin(), landPos )
	float fallTime = dist / 850

	// Fall
	mover.NonPhysicsMoveTo( landPos, fallTime, min( fallTime * 0.25, 1.4 ), 0.0 )
	wait fallTime
	PlayAnim( reaper, "sspec_dropship_deploy_landing", mover, 0 )
	reaper.ClearParent()
	mover.Destroy()

	WaitSignal( reaper, "OnDeath" )
}

void function ReinforcementsDialogue1( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagWait( "dialogue_send_reinforcements1" )

	// Zulu One-Six, we need reinforcements!
	PlayDialogue( "EnemyRadio_NeedReinforcements", player )

	wait 0.5

	// <static> Alpha One-Four, we are diverting forces to assist. ETA 3 minutes. <static>
	PlayDialogue( "EnemyRadio_ETA3Minutes", player )
}

void function DeployStalkersDialogue( entity player )
{
	FlagWait( "dialogue_deploy_stalkers" )

	entity location = GetEntByScriptName( "deploy_stalkers_dialogue_location" )

	// Deploy the Stalkers and send them in!
	PlayDialogue( "Grunt_DeployStalkersSendIn", location )
}

//---------------------------------------------------------------------

//	███████╗██████╗  ██████╗ ██╗  ██╗███████╗     ██╗    ███████╗███████╗ ██████╗ ██████╗ ███╗   ██╗██████╗     ███████╗██╗ ██████╗ ██╗  ██╗████████╗
//	██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝    ███║    ██╔════╝██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔══██╗    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
//	███████╗██████╔╝██║   ██║█████╔╝ █████╗      ╚██║    ███████╗█████╗  ██║     ██║   ██║██╔██╗ ██║██║  ██║    █████╗  ██║██║  ███╗███████║   ██║
//	╚════██║██╔═══╝ ██║   ██║██╔═██╗ ██╔══╝       ██║    ╚════██║██╔══╝  ██║     ██║   ██║██║╚██╗██║██║  ██║    ██╔══╝  ██║██║   ██║██╔══██║   ██║
//	███████║██║     ╚██████╔╝██║  ██╗███████╗     ██║    ███████║███████╗╚██████╗╚██████╔╝██║ ╚████║██████╔╝    ██║     ██║╚██████╔╝██║  ██║   ██║
//	╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═╝    ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

void function StartPoint_Spoke1_SecondFight( entity player )
{
	printt( "START POINT - SPOKE 1 MIDFIGHT START" )
}

void function StartPoint_Setup_Spoke1_Secondfight( entity player )
{
	TeleportPlayerAndBT( "midspoke1_start_org", "spoke1_titan_start" )

	// clear the area near start
	entity start = GetEntByScriptName( "midspoke1_start_org" )
	array<entity> enemies = GetNPCArrayEx( "any", TEAM_IMC, TEAM_ANY, start.GetOrigin(), float( start.kv.script_goal_radius ) )
	foreach ( npc in enemies )
	{
		npc.Die()
	}
}

void function StartPoint_Skipped_Spoke1_SecondFight( entity player )
{
	FlagSet( "Spoke1_second_fight_left_tower_cleared" )
}

//---------------------------------------------------------------------

//	███████╗██████╗  ██████╗ ██╗  ██╗███████╗     ██╗    ██████╗ ██╗██╗     ██╗      █████╗ ██████╗     ██████╗  ██████╗  ██████╗ ███╗   ███╗
//	██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝    ███║    ██╔══██╗██║██║     ██║     ██╔══██╗██╔══██╗    ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║
//	███████╗██████╔╝██║   ██║█████╔╝ █████╗      ╚██║    ██████╔╝██║██║     ██║     ███████║██████╔╝    ██████╔╝██║   ██║██║   ██║██╔████╔██║
//	╚════██║██╔═══╝ ██║   ██║██╔═██╗ ██╔══╝       ██║    ██╔═══╝ ██║██║     ██║     ██╔══██║██╔══██╗    ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║
//	███████║██║     ╚██████╔╝██║  ██╗███████╗     ██║    ██║     ██║███████╗███████╗██║  ██║██║  ██║    ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║
//	╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═╝    ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝

void function StartPoint_Spoke1_PillarRoom( entity player )
{
	printt( "START POINT - SPOKE 1 MIDFIGHT START" )
	FlagWait( "reached_second_crane" )
	CheckPoint()
}

void function StartPoint_Setup_Spoke1_PillarRoom( entity player )
{
	TeleportPlayerAndBT( "secondfight_left_tower_roof_towards_pillars_org", "spoke1_titan_start" )

	// clear the area near start
	entity clearEnemies = GetEntByScriptName( "secondfight_left_tower_roof_org" )
	array<entity> enemies = GetNPCArrayEx( "any", TEAM_IMC, TEAM_ANY, clearEnemies.GetOrigin(), float( clearEnemies.kv.script_goal_radius ) )
	foreach ( npc in enemies )
	{
		npc.Die()
	}
}

void function StartPoint_Skipped_Spoke1_PillarRoom( entity player )
{
	FlagSet( "passed_through_spoke_1" )
	FlagSet( "Spoke1_second_fight_left_tower_cleared" )
}

//---------------------------------------------------------------------

//	███████╗██████╗  ██████╗ ██╗  ██╗███████╗     ██╗     ██████╗██████╗  █████╗ ███╗   ██╗███████╗    ██████╗ ██╗   ██╗███████╗███████╗██╗     ███████╗
//	██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝    ███║    ██╔════╝██╔══██╗██╔══██╗████╗  ██║██╔════╝    ██╔══██╗██║   ██║╚══███╔╝╚══███╔╝██║     ██╔════╝
//	███████╗██████╔╝██║   ██║█████╔╝ █████╗      ╚██║    ██║     ██████╔╝███████║██╔██╗ ██║█████╗      ██████╔╝██║   ██║  ███╔╝   ███╔╝ ██║     █████╗
//	╚════██║██╔═══╝ ██║   ██║██╔═██╗ ██╔══╝       ██║    ██║     ██╔══██╗██╔══██║██║╚██╗██║██╔══╝      ██╔═══╝ ██║   ██║ ███╔╝   ███╔╝  ██║     ██╔══╝
//	███████║██║     ╚██████╔╝██║  ██╗███████╗     ██║    ╚██████╗██║  ██║██║  ██║██║ ╚████║███████╗    ██║     ╚██████╔╝███████╗███████╗███████╗███████╗
//	╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝

void function StartPoint_Spoke1_Crane_Puzzle_Start( entity player )
{
	printt( "START POINT - SPOKE 1 CRANE PUZZLE START" )

	thread ReinforcementsDialogue2( player )
	thread EnemiesInterceptDialogue( player )

	FlagWait( "PlayerEnteredSecondBeacon" )
}

void function StartPoint_Setup_Spoke1_Crane_Puzzle( entity player )
{
	TeleportPlayerAndBT( "crane_puzzle_player_start", "spoke1_titan_start" )
}

void function StartPoint_Skipped_Crane_Puzzle( entity player )
{

}

void function ReinforcementsDialogue2( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagWait( "dialogue_send_reinforcements2" )

	wait 1.0

	PlayMusic( "Music_Beacon_16_ReinforcementsToChokepoints" )
}

void function EnemiesInterceptDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagWait( "dialogue_enemy_intercept" )

	// Kilo One-Four, hostile Pilot sighted, headed your way. Acknowledge.
	PlayDialogue( "RadioGrunt1_PilotSpotted", player )

	wait 2.0

	// Kilo One-Four, do you copy? Come in Kilo One-Four!
	PlayDialogue( "RadioGrunt1_DoYouCopy", player )

	wait 2.0

	// All units, Kilo One-Four is not responding. Prepare to engage the target at Beacon Four.
	PlayDialogue( "RadioGrunt1_NotResponding", player )

	wait 0.5

	// Copy that. In position at Beacon Four gantry, standing by to intercept.
	PlayDialogue( "RadioGrunt2_StandingBy", player )
}

//---------------------------------------------------------------------

//	███████╗███████╗ ██████╗ ██████╗ ███╗   ██╗██████╗     ██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███╗   ██╗
//	██╔════╝██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗████╗  ██║
//	███████╗█████╗  ██║     ██║   ██║██╔██╗ ██║██║  ██║    ██████╔╝█████╗  ███████║██║     ██║   ██║██╔██╗ ██║
//	╚════██║██╔══╝  ██║     ██║   ██║██║╚██╗██║██║  ██║    ██╔══██╗██╔══╝  ██╔══██║██║     ██║   ██║██║╚██╗██║
//	███████║███████╗╚██████╗╚██████╔╝██║ ╚████║██████╔╝    ██████╔╝███████╗██║  ██║╚██████╗╚██████╔╝██║ ╚████║
//	╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝     ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝

void function StartPoint_Second_Beacon( entity player )
{
	printt( "START POINT - SECOND BEACON" )

	PlayMusic( "Music_Beacon_17_ReaperBattle" )

	DisableDoubleCranes()
	FlagClear( "ControlRoomDoorOpen" )
	FlagSet( "Spoke1CombatEntryDoorOpen" )
	FlagWait( "SecondBeaconArenaStart" )
	FlagSet( "Spoke1Backtrack" )

	CheckPoint()
}

void function StartPoint_Setup_Second_Beacon( entity player )
{
	TeleportPlayerAndBT( "second_beacon_player_start", "spoke1_titan_start" )
}

void function StartPoint_Skipped_Second_Beacon( entity player )
{
	DisableDoubleCranes()
	FlagSet( "Spoke1CombatEntryDoorOpen" )
	FlagSet( "Spoke1Backtrack" )
}

void function DisableDoubleCranes()
{
	entity crane1 = GetEntByScriptName( "double_crane_1" )
	entity crane2 = GetEntByScriptName( "double_crane_2" )

	SetCraneYaw( crane1, 80 )
	SetCraneYaw( crane2, 110 )

	SetCraneEnabled( crane1, false )
	SetCraneEnabled( crane2, false )
}

//---------------------------------------------------------------------

//	███████╗███████╗ ██████╗ ██████╗ ███╗   ██╗██████╗     ██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███╗   ██╗     █████╗ ██████╗ ███████╗███╗   ██╗ █████╗
//	██╔════╝██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗████╗  ██║    ██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗
//	███████╗█████╗  ██║     ██║   ██║██╔██╗ ██║██║  ██║    ██████╔╝█████╗  ███████║██║     ██║   ██║██╔██╗ ██║    ███████║██████╔╝█████╗  ██╔██╗ ██║███████║
//	╚════██║██╔══╝  ██║     ██║   ██║██║╚██╗██║██║  ██║    ██╔══██╗██╔══╝  ██╔══██║██║     ██║   ██║██║╚██╗██║    ██╔══██║██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║
//	███████║███████╗╚██████╗╚██████╔╝██║ ╚████║██████╔╝    ██████╔╝███████╗██║  ██║╚██████╗╚██████╔╝██║ ╚████║    ██║  ██║██║  ██║███████╗██║ ╚████║██║  ██║
//	╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝     ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝

void function StartPoint_Spoke1_Arena( entity player )
{
	printt( "START POINT - SECOND BEACON ARENA" )

	GetEntByScriptName( "beacon04_roofblock" ).NotSolid()

	Objective_Update( <0,0,0>, GetEntByScriptName( "satellite_platform_button" ) )

	GetEntByScriptName( "ModuleBlocker" ).Solid()

	thread SecondBeaconArrivalDialogue( player )
	thread TargetingModuleDialogue_CraneControls( player )
	thread TargetingModuleDialogue_OnDish( player )
	thread TargetingModuleDialogue_RemovedModule( player )
	thread CraneDishMarvins( player )

	thread DishCraneInPosition( player )

	FlagWait( "ModuleAnimSequence1Done" )
	CheckPoint()

	Objective_Set( "#BEACON_OBJECTIVE_RETURN_TO_BEACON", GetEntByScriptName( "platforms_objective_waypoint" ).GetOrigin() )

	FlagWait( "WallrunPanels" )
	CheckPoint()
}

void function StartPoint_Setup_Spoke1_Arena( entity player )
{
	TeleportPlayerAndBT( "second_beacon_arena_player_start", "spoke1_titan_start" )
	FlagSet( "SecondBeaconDrawbridge" )
}

void function StartPoint_Skipped_Spoke1_Arena( entity player )
{
	GetEntByScriptName( "beacon04_roofblock" ).NotSolid()
}

void function CraneDishMarvins( entity player )
{
	array<entity> nodes = GetEntArrayByScriptName( "CraneDishMarvinNode" )
	foreach( entity node in nodes )
	{
		entity marvin = CreateMarvin( TEAM_UNASSIGNED, node.GetOrigin(), node.GetAngles() )
		DispatchSpawn( marvin )
		thread CraneDishMarvinWelds( marvin, node )
	}
}

void function CraneDishMarvinWelds( entity marvin, entity node )
{
	EndSignal( marvin, "OnDeath" )

	//float animLength = marvin.GetSequenceDuration( "mv_idle_weld" )
	marvin.SetParent( node, "", false )
	while ( true )
	{
		marvin.Anim_ScriptedPlay( "mv_idle_weld" )
		WaittillAnimDone( marvin )
		//thread PlayAnim( marvin, "mv_idle_weld", node, null, 0.6 )
		//wait animLength
	}
}

//---------------------------------------------------------------------

//	███████╗██████╗  ██████╗ ██╗  ██╗███████╗     ██╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗     ███████╗
//	██╔════╝██╔══██╗██╔═══██╗██║ ██╔╝██╔════╝    ███║    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     ██╔════╝
//	███████╗██████╔╝██║   ██║█████╔╝ █████╗      ╚██║    ██████╔╝███████║██╔██╗ ██║█████╗  ██║     ███████╗
//	╚════██║██╔═══╝ ██║   ██║██╔═██╗ ██╔══╝       ██║    ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     ╚════██║
//	███████║██║     ╚██████╔╝██║  ██╗███████╗     ██║    ██║     ██║  ██║██║ ╚████║███████╗███████╗███████║
//	╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝

void function StartPoint_Spoke1_Panels( entity player )
{
	printt( "START POINT - SPOKE 1 PANELS" )

	Objective_Update( GetEntByScriptName( "bt_throw_objective_location" ).GetOrigin() )

	thread HubBattleEndlessBTEnemies( player )
	thread MidPanelsDialogue( player )
	thread PlayDialogue( "Richter_AlphaTwoComeIn", player )

	FlagWait( "Spoke1End" )

	CheckPoint()
}

void function StartPoint_Setup_Spoke1_Panels( entity player )
{
	TeleportPlayerAndBT( "platforms_player_start", "spoke1_titan_start" )
}

void function StartPoint_Skipped_Spoke1_Panels( entity player )
{

}

void function MidPanelsDialogue( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "midway_wallrun_panels" )

	PlayMusic( "Music_Beacon_21_BTAntiTitanSquads" )

	thread GunshipBackstrackStrafe()

	// Anti-Titan squads have arrived. Requesting assistance.
	PlayBTDialogue( "BT_AntiTitanSquadsArrived" )
}

//---------------------------------------------------------------------

//	██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗    ████████╗ ██████╗     ██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███╗   ██╗
//	██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║    ╚══██╔══╝██╔═══██╗    ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗████╗  ██║
//	██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║       ██║   ██║   ██║    ██████╔╝█████╗  ███████║██║     ██║   ██║██╔██╗ ██║
//	██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║       ██║   ██║   ██║    ██╔══██╗██╔══╝  ██╔══██║██║     ██║   ██║██║╚██╗██║
//	██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║       ██║   ╚██████╔╝    ██████╔╝███████╗██║  ██║╚██████╗╚██████╔╝██║ ╚████║
//	╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝       ╚═╝    ╚═════╝     ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝

void function StartPoint_Return_To_Beacon( entity player )
{
	printt( "START POINT - RETURN TO BEACON" )

	Objective_Set( "#BEACON_OBJECTIVE_ELIMINATE_BEACON_THREATS", GetEntByScriptName( "bt_throw_objective_location" ).GetOrigin() )

	thread ZiplineMusic( player )

	thread BTZiplineSequence( player )
	waitthread HubBattleBeforeFastballToDish( player )

	StopMusicTrack( "Music_Beacon_22_AreaBeforeZipline" )
	PlayMusic( "Music_Beacon_23_FinishZiplineBattle" )

	wait 1.5
	CheckPoint()
	wait 3.5

	// All threats eliminated. Area secure.
	waitthread PlayBTDialogue( "BT_AreaSecure" )

	wait 0.5

	waitthread PlayerConversation( "AreYouOkPilot", player )
}

void function ZiplineMusic( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagEnd( "ThrownToDish" )

	while( !player.IsZiplining() )
		WaitFrame()

	StopMusicTrack( "music_beacon_21_btantititansquads" )
	PlayMusic( "music_beacon_22_areabeforezipline" )

	DeleteSpoke1Marvins()
}

void function StartPoint_Setup_Return_To_Beacon( entity player )
{
	TeleportPlayerAndBT( "spoke1_end_player_start", "spoke1_end_titan_start" )
}

void function StartPoint_Skipped_Return_To_Beacon( entity player )
{

}

void function DeleteSpoke1Marvins()
{
	array<entity> marvins = GetNPCArrayByClass( "npc_marvin" )
	int count = 0
	foreach( entity marvin in marvins )
	{
		if ( IsValid( marvin ) )
		{
			marvin.Destroy()
			count++
		}
	}
	printt( "Deleted", count, "marvins" )
}

//---------------------------------------------------------------------

//	 ██████╗██╗     ██╗███╗   ███╗██████╗     ██████╗ ██╗███████╗██╗  ██╗
//	██╔════╝██║     ██║████╗ ████║██╔══██╗    ██╔══██╗██║██╔════╝██║  ██║
//	██║     ██║     ██║██╔████╔██║██████╔╝    ██║  ██║██║███████╗███████║
//	██║     ██║     ██║██║╚██╔╝██║██╔══██╗    ██║  ██║██║╚════██║██╔══██║
//	╚██████╗███████╗██║██║ ╚═╝ ██║██████╔╝    ██████╔╝██║███████║██║  ██║
//	 ╚═════╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝     ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝

void function StartPoint_Climb_Dish( entity player )
{
	printt( "START POINT - CLIMB DISH" )

	// Fastball to dish
	thread FastballPlayerToDishUntilSuccess( player )

	FlagClear( "ReachedTopOfDish" )
	FlagClear( "dialogue_radio_dishclimb" )
	FlagClear( "RotateDishUp" )

	// Set this here so players can start climbing the dish on their own if they want. You could get up there and break stuff
	FlagSet( "ThrownToDish" ) // turns on quick death triggers

	thread ArmsAnimateDownForModuleReplacement()

	thread ClimbDishDialogue( player )
	thread ClimbDishMusicEnteringHole( player )

	FlagWait( "TargetingModuleReplaced" )
	FlagWait( "ModuleAnimSequence2Done" )

	//FlagSet( "CenterArcSwitchesEnabled" )
	FlagSet( "CenterDoorsOpen" )
	FlagClear( "ControlRoomDoorOpen" )

	Objective_Clear()

	waitthread TargetingModuleReplaced( player )

	CheckPoint_ForcedSilent()
	wait 0.5
	FlagSet( "SaveRequires_PlayerIsTitan" )
}

void function ArmsAnimateDownForModuleReplacement()
{
	entity arms = GetEntByScriptName( "dish_arms2" )
	arms.Anim_Play( "close" )
	WaittillAnimDone( arms )
	FlagSet( "Module2CanBeReplaced" )
}

void function StartPoint_Setup_Climb_Dish( entity player )
{
	TeleportPlayerAndBT( "fastball_player_start", "climb_dish_titan_start" )
}

void function StartPoint_Skipped_Climb_Dish( entity player )
{
	FlagSet( "TargetingModuleReplaced" )
	SetDishAngle( -46 )
}

void function ClimbDishMusicEnteringHole( entity player )
{
	EndSignal( player, "OnDeath" )
	vector pos = < 3644, -2793, 4273 >
	while ( Distance( player.GetOrigin(), pos ) > 300 )
		WaitFrame()

	PlayMusic( "Music_Beacon_25_ClimbToTheDish" )
}

void function PeriodicUpdateEnemyLKP( entity npc, entity enemy )
{
	npc.EndSignal( "OnDeath" )
	enemy.EndSignal( "OnDeath" )

	while ( 1 )
	{
		npc.SetEnemyLKP( enemy, enemy.GetOrigin() )
		wait 10
	}
}

//---------------------------------------------------------------------

//	███████╗██╗███╗   ██╗ █████╗ ██╗         ██████╗  █████╗ ████████╗████████╗██╗     ███████╗
//	██╔════╝██║████╗  ██║██╔══██╗██║         ██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██║     ██╔════╝
//	█████╗  ██║██╔██╗ ██║███████║██║         ██████╔╝███████║   ██║      ██║   ██║     █████╗
//	██╔══╝  ██║██║╚██╗██║██╔══██║██║         ██╔══██╗██╔══██║   ██║      ██║   ██║     ██╔══╝
//	██║     ██║██║ ╚████║██║  ██║███████╗    ██████╔╝██║  ██║   ██║      ██║   ███████╗███████╗
//	╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝

void function StartPoint_Final_Battle( entity player )
{
	printt( "START POINT - FINAL BATTLE" )

	FlagSet( "FinalBattle" )

	ElevatorDown()

	thread SpawnControlRoomNPCs()

	// Player triggered the final battle
	FlagWait( "StartFinalBattle" )

	// Temp: make Militia ignored so Reapers and Boss don't attack them instead of the player
	array<entity> friendlies = GetNPCArrayEx( "npc_soldier", TEAM_MILITIA, TEAM_ANY, < 0, 0, 0 >, -1 )
	foreach( entity npc in friendlies )
	{
		npc.kv.AccuracyMultiplier = 0.1
		npc.kv.WeaponProficiency = eWeaponProficiency.POOR
		npc.SetNoTarget( true )
	}

	// Make the turrets not very effective against the final enemies
	array<entity> turrets = GetEntArrayByScriptName( "control_room_battle_turret" )
	foreach( entity turret in turrets )
	{
		turret.SetNoTarget( false )
		turret.SetHealth( 1 )
		turret.kv.AccuracyMultiplier = 0.1
		turret.kv.WeaponProficiency = eWeaponProficiency.POOR
	}

	// This is Richter. Intercept and destroy that Pilot. Then execute the remaining Militia troops.
	waitthread PlayDialogue( "Richter_DestroyThatPilot", player )

	CheckPoint()

	// Reapers inbound.
	waitthread PlayBTDialogue( "BT_ReapersInbound" )

	PlayMusic( "Music_Beacon_27_FinalBattleReapersArrive" )

	//###############################
	// Spawn the reapers (initial 2)
	//###############################

	array<entity> reaperSpawnersWave1 = GetEntArrayByScriptName( "FinalFightReaperSpawner_Initial" )
	array<entity> reapers
	foreach( entity spawner in reaperSpawnersWave1 )
	{
		entity reaper = spawner.SpawnEntity()
		DispatchSpawn( reaper )
		reaper.AssaultSetGoalRadius( 10000 )
		reapers.append( reaper )
		thread PeriodicUpdateEnemyLKP( reaper, player )
		wait RandomFloatRange( 0.1, 0.2 )
	}

	wait 2.0

	Objective_Set( "#BEACON_OBJECTIVE_ELIMINATE_IMC_THREATS", <0,0,0> )

	//#############################################
	// BT tells Militia to secure the control room
	//#############################################

	thread SecureControlRoomDoor()

	// Militia forces, lockdown the control room. Threat detected.
	waitthread PlayBTDialogue( "BT_LockdownControlRoom" )

	FlagSet( "SecureControlRoomDoorDialogueDone" )

	// Copy that. Locking down. We will assist from here.
	waitthread PlayDialogue( "Mike_GoingIntoLockdown", player )

	//#############################
	// Wait for reapers to be dead
	//#############################

	WaitUntilAllDead( reapers )

	CheckPoint()

	wait 2.0

	CheckPoint()

	//##############################
	// Second wave of Reapers spawn
	//##############################

	array<entity> reaperSpawnersWave2 = GetWave2ReaperSpawners( player )
	foreach( entity spawner in reaperSpawnersWave2 )
	{
		entity reaper = spawner.SpawnEntity()
		DispatchSpawn( reaper )
		reaper.AssaultSetGoalRadius( 20000 )
		reapers.append( reaper )
		thread PeriodicUpdateEnemyLKP( reaper, player )
		wait RandomFloatRange( 0.1, 0.2 )
	}

	WaitUntilAllDead( reapers )

	CheckPoint()

	wait 2.0

	CheckPoint()

	//######################
	// Stryder Titan spawns
	//######################

	// Caution: Anomaly detected. Possible hostile Titan.
	waitthread PlayBTDialogue( "BT_HostileTitanfall" )

	entity stryderTitanSpawner1 = GetStryderTitanSpawner( player, "FinalFightTitanSpawner1" )
	entity titan1 = stryderTitanSpawner1.SpawnEntity()
	DispatchSpawn( titan1 )
	titan1.AssaultSetGoalRadius( 20000 )
	titan1.SetEnemy( player )

	wait 0.5

	entity stryderTitanSpawner2 = GetStryderTitanSpawner( player, "FinalFightTitanSpawner2" )
	entity titan2 = stryderTitanSpawner2.SpawnEntity()
	DispatchSpawn( titan2 )
	titan2.AssaultSetGoalRadius( 20000 )
	titan2.SetEnemy( player )

	// Listen, IMC. I am looking for someone to promote. I am also looking for someone to kill. You get to choose which one you wish to be. Now ihn zu vernichten!
	thread PlayDialogue( "Richter_LookingToPromote", player )

	array<entity> titans = [ titan1, titan2 ]
	thread RichterFinalBattleDialogue( player, titans )
	while ( titans.len() > 0 )
	{
		wait 1.0
		ArrayRemoveDead( titans )
	}

	CheckPoint()

	wait 4.0

	//######################
	// Do boss fight
	//######################

	StopMusicTrack( "Music_Beacon_27_FinalBattleReapersArrive" )
	PlayMusic( "Music_Beacon_28_BossArrivesAndBattle" )

	// set efficient mode on friendly soldiers so they don't run away from Boss nuke so they can play scripted animation at end
	array<entity> friendlySoldiers = GetNPCArrayEx( "npc_soldier", TEAM_MILITIA, TEAM_ANY, Vector( 0, 0, 0 ), -1 )
	foreach ( guy in friendlySoldiers )
		guy.SetEfficientMode( true )

	TitanBossFight( player )

	thread GruntSkitsInit() // We deleted all grunt skits earlier as an optimization and the nodes wont be waiting for the flag anymore, so we need to reinitialize
	FlagSet( "ControlRoomSkitGrunts" )
	FlagSet( "ControlRoomSkitGrunts2" )

	StopMusicTrack( "Music_Beacon_28_BossArrivesAndBattle" )
	PlayMusic( "Music_Beacon_29_FinalBattleEnds" )

	wait 1.0

	FlagClear( "SaveRequires_PlayerIsTitan" )
	CheckPoint()
	UnlockAchievement( player, achievements.BEAT_RICHTER )

	wait 6.0

	//###############################################
	// Open the control room door and shutters again
	//###############################################

	FlagSet( "ControlRoomDoorOpen" )
	Objective_Set( "#BEACON_OBJECTIVE_RETURN_TO_CONTROL_ROOM", GetEntByScriptName( "ControlRoomObjectiveLocation" ).GetOrigin() )
	OpenShutters()
}

void function RichterFinalBattleDialogue( entity player, array<entity> titans )
{
	EndSignal( player, "OnDeath" )
	FlagEnd( "BossFight" )

	wait 15.0

	// Do not let him leave here alive.
	thread PlayDialogue( "Richter_DontLeaveHimAlive", player )

	while ( titans.len() >= 2 )
		wait 0.2

	wait 1.0

	// Ugh.. You all deserve to die.
	thread PlayDialogue( "Richter_YouDeserveToDie", player )
}

array<entity> function GetWave2ReaperSpawners( entity player )
{
	vector p = player.GetOrigin()
	array<entity> groupNodes = ArrayClosest( GetEntArrayByScriptName( "FinalFightReaperSpawnerGroup" ), p )
	array<entity> validGroupNodes
	foreach( entity node in groupNodes )
	{
		if ( Distance( node.GetOrigin(), p ) < 1200 )
			continue
		validGroupNodes.append( node )
	}

	// validGroupNodes now contains sorted list of nodes by distance we could use that wouldn't telefrag the player
	entity bestNode
	foreach( entity node in validGroupNodes )
	{
		if ( !PlayerCanSee( player, node, false, 40 ) )
			continue
		bestNode = node
		break
	}

	// If we didn't find a node the player can see just select a random one
	if ( !IsValid( bestNode ) )
		bestNode = validGroupNodes.getrandom()
	Assert( IsValid( bestNode ) )

	array<entity> spawners = bestNode.GetLinkEntArray()
	Assert( spawners.len() == 3 )
	return spawners
}

entity function GetStryderTitanSpawner( entity player, string scriptName )
{
	vector p = player.GetOrigin()
	array<entity> spawners = ArrayClosest( GetEntArrayByScriptName( scriptName ), p )
	array<entity> validSpawners
	foreach( entity spawner in spawners )
	{
		if ( Distance( StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) ), p ) < 1300 )
			continue
		validSpawners.append( spawner )
	}

	entity bestSpawner
	foreach( entity spawner in validSpawners )
	{
		if ( !PlayerCanSeePos( player, StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) ), false, 40 ) )
			continue
		bestSpawner = spawner
		break
	}

	// If we didn't find a spawner the player can see just select a random one
	if ( !IsValid( bestSpawner ) )
		bestSpawner = validSpawners.getrandom()
	Assert( IsValid( bestSpawner ) )

	return bestSpawner
}

void function StartPoint_Setup_Final_Battle( entity player )
{
	TeleportPlayerAndBT( "final_battle_player_start", "final_battle_titan_start" )

	// Go back to the control room
	Objective_Set( "#BEACON_OBJECTIVE_RETURN_TO_CONTROL_ROOM", GetEntByScriptName( "ControlRoomObjectiveLocation" ).GetOrigin() )

	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
}

void function StartPoint_Skipped_Final_Battle( entity player )
{
	FlagSet( "FinalBattle" )
}

void function SecureControlRoomDoor()
{
	// Wait until the dialogue is over, but if player rushes the door we close it prematurely
	FlagWaitAny( "SecureControlRoomDoorDialogueDone", "PlayerNearControlRoomDoor" )

	// Close the door and shutters
	FlagClear( "ControlRoomDoorOpen" )
	CloseShutters()
}

void function TitanBossFight( entity player )
{
	FlagSet( "BossFight" )

	// Don't allow embark or disembark during titan intro because it causes issues if you're doing a sequence at the time
	Embark_Disallow( player )
	Disembark_Disallow( player )

	// Spawn the boss
	entity titanSpawner = GetEntByScriptName( "TitanBossSpawner" )
	table spawnerKeyValues = titanSpawner.GetSpawnEntityKeyValues()
	vector spawnerVector = StringToVector( string( spawnerKeyValues.origin ) )
	if ( PlayerOrBTWithinOrigin( player, spawnerVector, 300 ) )
	{
		titanSpawner = GetEntByScriptName( "TitanBossSpawnerAlt" )
		spawnerKeyValues = titanSpawner.GetSpawnEntityKeyValues()
		spawnerVector = StringToVector( string( spawnerKeyValues.origin ) )
	}

	entity titan = titanSpawner.SpawnEntity()
	SetSpawnOption_Ordnance( titan, "mp_titanweapon_homing_rockets" )
	SetSpawnOption_Special( titan, "mp_titanweapon_vortex_shield" )

	waitthread NPCPrespawnWarpfallSequence( GetDefaultAISetting( titan ), spawnerVector, <0,0,0>  )

	DispatchSpawn( titan )

	titan.DisableBehavior( "Assault" )
	titan.SetEnemyLKP( player, player.GetOrigin() )
	AddEntityCallback_OnDamaged( titan, Richter_NuclearPayload_DamageCallback )
	AddEntityCallback_OnDamaged( player, PreventNukeDeath )

	// Make sure he doesn't get shot at during his intro by other NPCs
	WaitSignal( titan, "BossTitanIntroEnded" )

	// Free SP trial ends here, folks!
	if( Script_IsRunningTrialVersion() )
	{
		Remote_CallFunction_UI( player, "ScriptCallback_Beacon_FreeTrialOverMessage" )
		WaitForever()
	}

	// He can now be shot at by other NPCs and player can embark or disembark again
	Embark_Allow( player )
	Disembark_Allow( player )

	if ( IsValid( titan ) )
		WaitSignal( titan, "OnDeath" )

	CheckPoint()
}

void function PreventNukeDeath( entity titan, var damageInfo )
{
	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.damagedef_nuclear_core )
		return

	if ( GetSpDifficulty() == DIFFICULTY_MASTER )
		return

	float damage = DamageInfo_GetDamage( damageInfo )

	if ( damage < titan.GetHealth() )
		return

	DamageInfo_SetDamage( damageInfo, titan.GetHealth() - 1 )
}

// intercept damage to nuke titans in damage callback so we can nuke them before death 100% of the time
void function Richter_NuclearPayload_DamageCallback( entity titan, var damageInfo )
{
	if ( !IsAlive( titan ) )
		return

	if ( !GetDoomedState( titan ) )
		return

	float damage = DamageInfo_GetDamage( damageInfo )

	if ( damage < titan.GetHealth() )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !attacker.IsPlayer() )
		return

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.titan_execution )
		return

	entity soul = titan.GetTitanSoul()
	if ( soul.IsEjecting() )
		return

	if ( NPC_GetNuclearPayload( titan ) == 0 )
	{
		NPC_SetNuclearPayload( titan )
		Remote_CallFunction_NonReplay( attacker, "ServerCallback_BossTitanDeath", titan.GetEncodedEHandle(), GetBossTitanID( titan.ai.bossCharacterName ) )
		thread TitanEjectPlayer( titan )
	}
}

void function SetBossTitanSettings( entity titan )
{

}

bool function PlayerOrBTWithinOrigin( entity player, vector position, float dist )
{
	if ( Distance( player.GetOrigin(), position ) <= dist )
		return true
	entity bt = player.GetPetTitan()
	if ( IsValid( bt ) && Distance( bt.GetOrigin(), position ) <= dist )
		return true
	return false
}

//---------------------------------------------------------------------

//	███████╗███████╗███╗   ██╗██████╗     ███████╗██╗ ██████╗ ███╗   ██╗ █████╗ ██╗
//	██╔════╝██╔════╝████╗  ██║██╔══██╗    ██╔════╝██║██╔════╝ ████╗  ██║██╔══██╗██║
//	███████╗█████╗  ██╔██╗ ██║██║  ██║    ███████╗██║██║  ███╗██╔██╗ ██║███████║██║
//	╚════██║██╔══╝  ██║╚██╗██║██║  ██║    ╚════██║██║██║   ██║██║╚██╗██║██╔══██║██║
//	███████║███████╗██║ ╚████║██████╔╝    ███████║██║╚██████╔╝██║ ╚████║██║  ██║███████╗
//	╚══════╝╚══════╝╚═╝  ╚═══╝╚═════╝     ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

void function StartPoint_Send_Signal( entity player )
{
	Assert( IsAlive( file.mike ) && IsAlive( file.ike ), "IKE OR MIKE was dead when they shouldn't be" )
	// ike and mike should never die so we shouldn't have these endsignals.
	// EndSignal( file.mike, "OnDeath" )
	// EndSignal( file.ike, "OnDeath" )

	printt( "START POINT - SEND SIGNAL" )

	SetGlobalForcedDialogueOnly( true )

	// Mike and Ike do idle for scene C
	entity controlRoomNode = GetEntByScriptName( "control_room_node_rotated" )
	Assert( IsValid( controlRoomNode ) )

	entity node = CreateScriptMover( controlRoomNode.GetOrigin() + < 105,-310,0 >, AnglesCompose( controlRoomNode.GetAngles(), <0,90,0> ) )
	file.mike.SetParent( node )
	file.ike.SetParent( node )
	file.mike.Anim_ScriptedPlay( "pt_control_roomC_gruntA_idle" )
	file.ike.Anim_ScriptedPlay( "pt_control_roomC_gruntB_idle" )
	thread PlayAnimTeleport( file.gren, "pt_control_roomB_gruntA_idle", GetEntByScriptName( "grenNode" ) )

	thread AllControlRoomGruntsPrepareForSceneC()

	//####################################
	// Wait for player and BT on elevator
	//####################################

	FlagClear( "PilotAndTitanInsideControlRoom" )
	//thread NagPlayerToSendSignal( player )
	waitthread WaittillControlRoomElevatorReady( player )
	FlagSet( "PilotAndTitanInsideControlRoom" )

	Embark_Disallow( player )
	Objective_Clear()

	// Move the elevator up
	ElevatorUp( 3.5 )

	ControlRoomSceneC( player )

	ScreenFadeToBlackForever( player )
	wait 3.0
}

void function StartPoint_Setup_Send_Signal( entity player )
{
	TeleportPlayerAndBT( "control_room_titan_start", "control_room_titan_start" )

	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	FlagSet( "ControlRoomSkitGrunts" )
	FlagSet( "ControlRoomSkitGrunts2" )

	OpenShutters( true )

	ElevatorDown()
	FlagSet( "ControlRoomDoorOpen" )
	PlayMusic( "Music_Beacon_29_FinalBattleEnds" )
}

void function StartPoint_Skipped_Send_Signal( entity player )
{

}

void function AllControlRoomGruntsPrepareForSceneC()
{
	WaitFrame()
	entity testNode = GetEntByScriptName( "control_room_player_start" )
	array<entity> grunts = GetNPCArrayEx( "npc_soldier", TEAM_MILITIA, TEAM_IMC, testNode.GetOrigin(), 2000 )
	grunts.fastremovebyvalue( file.mike )
	grunts.fastremovebyvalue( file.ike )
	grunts.fastremovebyvalue( file.gren )

	array<entity> nodes = GetEntArrayByScriptName( "ControlRoomCNode" )
	Assert( nodes.len() >= grunts.len() )

	array<entity> nodesA
	array<entity> nodesB
	array<entity> nodesC
	array<entity> nodesD
	foreach( entity node in nodes )
	{
		switch( node.kv.script_noteworthy )
		{
			case "a":
				nodesA.append( node )
				break
			case "b":
				nodesB.append( node )
				break
			case "c":
				nodesC.append( node )
				break
			case "d":
				nodesD.append( node )
				break
		}
	}
	Assert( nodesA.len() == nodesB.len() )

	array<entity> priorityNodes
	priorityNodes.extend( nodesA )
	priorityNodes.extend( nodesB )

	array<entity> secondaryNodes
	secondaryNodes.extend( nodesC )
	secondaryNodes.extend( nodesD )

	foreach( entity node in priorityNodes )
	{
		entity closestGrunt = GetClosest( grunts, node.GetOrigin() )
		Assert( IsValid( closestGrunt ) )
		grunts.fastremovebyvalue( closestGrunt )
		thread GruntToControlRoomSceneC( closestGrunt, node )
	}

	foreach( entity grunt in grunts )
	{
		// Get the closest node to use
		entity node = GetClosest( secondaryNodes, grunt.GetOrigin() )
		Assert( IsValid( node ) )
		secondaryNodes.fastremovebyvalue( node )
		thread GruntToControlRoomSceneC( grunt, node )
	}
}

void function GruntToControlRoomSceneC( entity grunt, entity node )
{
	//DebugDrawLine( grunt.GetOrigin(), node.GetOrigin(), 255, 0, 0, true, 30.0 )
	EndSignal( grunt, "OnDeath" )

	float delay = RandomFloatRange( 0.0, 0.6 )
	array<string> anims
	switch( node.kv.script_noteworthy )
	{
		case "a":
			delay = 0.1
			anims = [ "pt_control_roomC_gruntA_idle", "pt_control_roomC_gruntA_scene", "pt_control_roomC_gruntA_end" ]
			break
		case "b":
			delay = 0.1
			anims = [ "pt_control_roomC_gruntB_idle", "pt_control_roomC_gruntB_scene", "pt_control_roomC_gruntB_end" ]
			break
		case "c":
			anims = [ "pt_control_roomC_gruntC_idle", "pt_control_roomC_gruntC_scene", "pt_control_roomC_gruntC_end" ]
			break
		case "d":
			anims = [ "pt_control_roomC_gruntD_idle", "pt_control_roomC_gruntD_scene", "pt_control_roomC_gruntD_end" ]
			break
	}

	Signal( grunt, "StopGruntSkit" )

	thread RunToAndPlayAnimAndWait( grunt, anims[0], node )

	FlagWait( "ControlRoomCSequenceStart" )
	wait 6.0 + delay
	waitthread PlayAnim( grunt, anims[1], node )
	thread PlayAnim( grunt, anims[2], node )
}
/*
void function NagPlayerToSendSignal( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( level, "PilotAndTitanInsideControlRoom" )

	while ( true )
	{
		wait 20

		if ( Flag( "PilotAndTitanInsideControlRoom" ) )
			return

		// Let's get to the control room, Pilot.  I can send the signal from there.
		PlayBTDialogue( "BT_Nag_ICanSendSignal" )

		wait 20

		if ( Flag( "PilotAndTitanInsideControlRoom" ) )
			return

		// Pilot, I recommend we go into the control room.
		PlayBTDialogue( "BT_Nag_GoIntoControlRoom" )
	}
}
*/

void function ControlRoomSceneC( entity player )
{
	EndSignal( player, "OnDeath" )

	entity controlRoomNodeBT = GetEntByScriptName( "control_room_node" )

	// If the player is in BT we force him out
	entity bt = player.GetPetTitan()

	if ( player.IsTitan() )
	{
		thread SendSignalDisembarkHint( player )
		player.ForceStand()

		// Wait for BT to exist since we are disembarking
		bt = player.GetPetTitan()
		while ( !IsValid( bt ) )
		{
			bt = player.GetPetTitan()
			//printt( "1" )
			WaitFrame()
		}

		Embark_Disallow( player )
		player.UnforceStand()
		ClearOnscreenHint( player )
		wait 3.0
	}
	else
	{
		bt = player.GetPetTitan()
		Assert( IsValid( bt ) )
	}

	FlagSet( "ControlRoomCSequenceStart" )

	ClearOnscreenHint( player )
	StopMusic()
	PlayMusic( "music_beacon_29a_elevator" )
	entity screen = GetEntArrayByScriptName( "ControlRoomScreenLeftUpper" )[0]
	EmitSoundAtPosition( TEAM_UNASSIGNED, screen.GetOrigin(), "bt_beacon_controlroom_left_screens_flicker_on_02" )

	if ( EntityInSolid( bt, player ) )
	{
		thread PlayAnimTeleport( bt, "bt_beacon_controlroom_c_skit_closedhatch", controlRoomNodeBT )
	}
	else
	{
		thread RunToAndPlayAnim( bt, "bt_beacon_controlroom_c_skit_closedhatch", controlRoomNodeBT )
		table result = WaitSignal( bt, "OnFinishedAssault", "OnFailedToPath" )
		if ( result.signal == "OnFailedToPath" )
			thread PlayAnimTeleport( bt, "bt_beacon_controlroom_c_skit_closedhatch", controlRoomNodeBT )
	}

	thread ControlRoomSceneC_BTAnim( bt )

	// Ok, all systems are functional!
	waitthread PlayGabbyDialogue( "Ike_AllSystemsFunctional", file.ike, "face_generic_talker_emotion" )
	wait 0.3

	// Grenier! Fire it up!
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE152_02_01_mcor_grunt1", true )
	waitthread PlayDialogue( "Mike_FireItUp", file.mike )

	// Yes sir! Transmission sequence activated!
	waitthread PlayGabbyDialogue( "Ike_YesSir", file.gren, "face_generic_talker_emotion" )
	thread SendSignalMikeIkeReact()

	wait 0.5

	// It's working! Transmission power at 25 percent and climbing!
	waitthread PlayGabbyDialogue( "Ike_ItsWorking", file.gren, "face_generic_talker_emotion" )

	wait 1.0

	// 60 percent! Looking good!
	waitthread PlayGabbyDialogue( "Ike_60Percent", file.gren )

	wait 0.2

	// Almost there! 80 percent!
	waitthread PlayGabbyDialogue( "Ike_80Percent", file.gren )
	wait 0.2

	// Signal strength at maximum power! We are a go for transmission!
	EmitSoundOnEntity( player, "beacon_scr_dish_sent_signal" )
	waitthread PlayGabbyDialogue( "Ike_WeAreGoForTransmission", file.gren, "face_generic_talker_emotion" )

	wait 0.2

	// Broadcasting data stream. Awaiting response.
	waitthread PlayDialogue( "BT_BroadcastingDataStream", bt )

	// Here's hoping someone's still up there....
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE411_02_01_mcor_gcaptain", true )
	wait 0.3
	waitthread PlayDialogue( "Mike_HopingSomeoneStillUpThere", file.mike )
	thread PlayAnim( file.gren, "pt_control_roomB_gruntA_react", GetEntByScriptName( "grenNode" ) )

	wait 1.0

	// Got it.
	waitthread PlayGabbyDialogue( "Grunt_GotIt", file.gren )

	// This is Commander Sarah Briggs of Marauder Corps, Militia SRS. Authenticate.
	waitthread PlayDialogue( "Sarah_Authenticate", player )

	// Commander Briggs, this is BT-7274.
	waitthread PlayDialogue( "BT_ThisIsBT", bt )

	// Protocol 2: Uphold the mission. Report intel to the fleet attached to the SRS unit.
	waitthread PlayDialogue( "BT_UpholdTheMission", bt )

	// Solid copy - Good to hear you guys are still down there. We're receiving your data now.
	waitthread PlayDialogue( "Sarah_SolidCopy", player )
}

void function SendSignalDisembarkHint( entity player )
{
	FlagEnd( "ControlRoomCSequenceStart" )
	FlagWait( "ElevatorIsUp" )

	wait 2.0

	thread PlayBTDialogue( "BT_DisembarkNag" )
	DisplayOnscreenHint( player, "DisembarkHint" )
}

void function SendSignalMikeIkeReact()
{
	file.mike.Anim_ScriptedPlay( "pt_control_roomC_gruntA_scene" )
	file.ike.Anim_ScriptedPlay( "pt_control_roomC_gruntB_scene" )

	WaittillAnimDone( file.mike )

	file.mike.Anim_ScriptedPlay( "pt_control_roomC_gruntA_end" )
	file.ike.Anim_ScriptedPlay( "pt_control_roomC_gruntB_end" )
}

void function ControlRoomSceneC_BTAnim( entity bt )
{
	entity controlRoomNodeBT = GetEntByScriptName( "control_room_node" )
	WaittillAnimDone( bt )
	thread PlayAnim( bt, "bt_beacon_controlroom_c_loop", controlRoomNodeBT )
}


//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------

//	      ██╗     ███████╗██╗   ██╗███████╗██╗         ██╗      ██████╗  ██████╗ ██╗ ██████╗
//	      ██║     ██╔════╝██║   ██║██╔════╝██║         ██║     ██╔═══██╗██╔════╝ ██║██╔════╝
//	█████╗██║     █████╗  ██║   ██║█████╗  ██║         ██║     ██║   ██║██║  ███╗██║██║      █████╗
//	╚════╝██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║         ██║     ██║   ██║██║   ██║██║██║      ╚════╝
//	      ███████╗███████╗ ╚████╔╝ ███████╗███████╗    ███████╗╚██████╔╝╚██████╔╝██║╚██████╗
//	      ╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝

void function Beacon_EntitiesDidLoad()
{
	// Setup button on beacon
	entity button = GetEntByScriptName( "dish_objective_button" )
	entity arms = GetEntByScriptName( "dish_arms2" )
	arms.SetPusher( true )
	button.SetParent( arms, "ATTACH_MODULE", false )
	button.Hide()
	button.SetUsePrompts( "#BEACON_INSTALL_MODULE_HOLD_TO_USE" , "#BEACON_INSTALL_MODULE_PRESS_TO_USE" )
	thread StopButtonStatusLight( button )

	entity controlRoomNode = GetEntByScriptName( "control_room_node" )
	file.controlRoomCable = CreatePropDynamic( CABLE_MODEL, controlRoomNode.GetOrigin(), controlRoomNode.GetAngles(), 6 )
	file.controlRoomCable.SetInvulnerable()
	thread PlayAnimTeleport( file.controlRoomCable, "cable_beacon_unplugged", controlRoomNode )

	file.satelliteDishHatch = GetEntByScriptName( "SatDishHatch" )
	file.satelliteDishHatch.DisableHibernation()
	file.satelliteDishHatch.Hide()
	file.satelliteDishHatch.NotSolid()

	// Fake objective highlight dish
	entity dish = GetEntByScriptName( "dish_on_crane" )
	file.highlightDishModel = CreatePropScript( HANGING_CRANE_MODEL, dish.GetOrigin(), dish.GetAngles(), 0, 99999 )
	file.highlightDishModel.SetParent( dish, "", true )
	file.highlightDishModel.Hide()
	Objective_InitEntity( file.highlightDishModel )

	GetEntByScriptName( "ModuleBlocker" ).NotSolid()

	thread FlyerInit()
	thread DrawBridge1()
	thread DrawBridge2()
	thread DrawBridge3()
	thread SecondBeaconFirstFight()
	thread DoubleCraneAlignmentCheckpoint()
	thread ModuleAnimSequence1()
	thread ModuleAnimSequence2()
	thread ZiplineBacktrack()
	thread ReaperFlyin()
}

void function ControlRoomCableCollisionConnected()
{
	GetEntByScriptName( "PipeCollisionDisconnected" ).NotSolid()
	GetEntByScriptName( "PipeCollisionConnected" ).Solid()
}

void function ControlRoomCableCollisionDisconnected()
{
	GetEntByScriptName( "PipeCollisionDisconnected" ).Solid()
	GetEntByScriptName( "PipeCollisionConnected" ).NotSolid()
}

void function StopButtonStatusLight( entity button )
{
	wait 1.0
	Entity_StopFXArray( button )
}

void function SetDishAngle( float angle, float duration = 0 )
{
	entity dish = GetEntByScriptName( "dish_rotator" )
	if ( duration <= 0 )
		dish.SetAngles( <0,90,angle> )
	else
		dish.NonPhysicsRotateTo( <0,90,angle>, duration, duration / 2.0, duration / 2.0 )

	//thread DrawAnglesForMovingEnt( GetEntByScriptName( "satellite2_platform_mover" ), 100.0 )
	//thread DrawAnglesForMovingEnt( GetEntByScriptName( "satellite2_move_target" ), 100.0 )

	//array<entity> rotators = GetEntArrayByScriptName( "satellite2_platform_rotator" )
	//foreach( entity rotator in rotators )
	//	thread DrawAnglesForMovingEnt( rotator, 100.0 )
}

void function PlayerReturnedFromSpoke0( entity player )
{
	array<entity> disbaleTriggers = GetEntArrayByScriptName( "DoorToSpoke0CloseTriggers" )
	foreach ( entity trigger in disbaleTriggers )
	{
		trigger.SetOrigin( trigger.GetOrigin() - Vector( 0, 0, 2000 ) )
	}

	FlagClear( "Door2ToSpok0Open" )

	// Give charge tool
	FlagSet( "HasChargeTool" )
	if ( !HasBatteryChargeTool( player ) )
		GiveBatteryChargeTool( player )
}

void function HubBattleEndlessBTEnemies( entity player )
{
	// Spawn guys to keep BT busy while player makes his way back to BT
	// They stop when player reached end of spoke1 and time has passed, or if player returns to BT

	entity bt = player.GetPetTitan()
	while ( !IsValid( bt ) )
	{
		bt = player.GetPetTitan()
		WaitFrame()
	}

	entity node = GetEntByScriptName( "ZiplineMomentNode" )
	bt.AssaultPoint( OriginToGround( node.GetOrigin() + <0,0,1> ) )
	bt.AssaultSetGoalRadius( 800 )

	array<entity> endlessSpawners = GetEntArrayByScriptName( "HubFightEndlessSpawner" )
	array<entity> endlessGuys
	float spawnersStopTime = 0.0

	while ( true )
	{
		wait 0.2

		if ( spawnersStopTime == 0.0 )
		{
			if ( Flag( "Spoke1End" ) )
			{
				spawnersStopTime = Time() + 60.0
				printt( "#########################################" )
				printt( "STOPPING ENDLESS BT ENEMIES IN 60 SECONDS" )
				printt( "#########################################" )
			}
			if ( Flag( "ReturnedToBeacon" ) )
			{
				spawnersStopTime = Time()
				printt( "###############################" )
				printt( "STOPPING ENDLESS BT ENEMIES NOW")
				printt( "###############################" )
			}
		}

		if ( spawnersStopTime > 0.0 && Time() >= spawnersStopTime )
		{
			printt( "#####################" )
			printt( "ENDLESS ENEMIES ENDED")
			printt( "#####################" )
			break
		}

		// Max 2 enemies at a time to keep a light battle going with BT
		ArrayRemoveDead( endlessGuys )
		ArrayRemoveDead( file.returnToHubEnemies )
		if ( endlessGuys.len() >= 2 )
			continue

		// Spawn a new guy to keep BT busy
		endlessSpawners.randomize()
		entity guy = endlessSpawners[0].SpawnEntity()
		DispatchSpawn( guy )
		endlessGuys.append( guy )
		AddTrackedHubFightEnemy( guy )
	}
}

void function AddTrackedHubFightEnemy( entity guy )
{
	file.returnToHubEnemies.append( guy )
}

void function HubBattleBeforeFastballToDish( entity player )
{
	// Check the flag again because we may have timed out above without the flag being set
	FlagWait( "ReturnedToBeacon" )

	// Spawn the HUB enemies and wait until they are all dead
	array<entity> spawners = GetEntArrayByScriptName( "HubFightSpawner" )
	foreach ( entity spawner in spawners )
	{
		entity npc = spawner.SpawnEntity()
		DispatchSpawn( npc )
		AddTrackedHubFightEnemy( npc )
	}

	thread HubBattleDropships()
	thread HubBattleContextDialogue( player )

	FlagWait( "AllDelayedHubEnemiesSpawned" )

	// Wait until all hub enemies are dead
	thread KillOffEnemiesOverTime( player, file.returnToHubEnemies, 45.0 )
	while ( file.returnToHubEnemies.len() > 0 )
	{
		wait 1.0
		ArrayRemoveDead( file.returnToHubEnemies )
	}

	// Make sure no ticks in the area
	array<entity> fragDrones = GetNPCArrayByClass( "npc_frag_drone" )
	vector testPos = GetEntByScriptName( "BeaconObjectiveLocation" ).GetOrigin()
	float maxDist = 4000 * 4000
	while( true )
	{
		ArrayRemoveDead( fragDrones )
		ArrayRemoveInvalid( fragDrones )

		for ( int i = fragDrones.len() - 1 ; i >= 0 ; i-- )
		{
			if ( DistanceSqr( testPos, fragDrones[i].GetOrigin() ) > maxDist )
				fragDrones.remove( i )
		}

		if ( fragDrones.len() == 0 )
			break

		wait 0.1
	}

	FlagSet( "ReturnToHubBattleOver" )

	Objective_Clear()
}

void function HubBattleDropships()
{
	entity dropshipSpawner1 = GetEntByScriptName( "HubFightDropshipSpawner1" )
	Assert( IsValid( dropshipSpawner1 ) )

	entity dropshipSpawner2 = GetEntByScriptName( "HubFightDropshipSpawner2" )
	Assert( IsValid( dropshipSpawner2 ) )

	thread SpawnFromDropship( dropshipSpawner2 )

	wait 10.0

	thread SpawnFromDropship( dropshipSpawner1 )

	wait 3.0

	FlagSet( "AllDelayedHubEnemiesSpawned" )
}

void function HubBattleContextDialogue( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( level, "ReturnToHubBattleOver" )

	AddDeathCallback( "npc_soldier", HubBattleDeathCallback )
	AddDeathCallback( "npc_spectre", HubBattleDeathCallback )
	AddDeathCallback( "npc_stalker", HubBattleDeathCallback )
	AddDeathCallback( "npc_super_spectre", HubBattleDeathCallback )

	OnThreadEnd(
		function() : (  )
		{
			RemoveDeathCallback( "npc_soldier", HubBattleDeathCallback )
			RemoveDeathCallback( "npc_spectre", HubBattleDeathCallback )
			RemoveDeathCallback( "npc_stalker", HubBattleDeathCallback )
			RemoveDeathCallback( "npc_super_spectre", HubBattleDeathCallback )
		}
	)

	array<string> playerKillLines = [
									"BT_GoodShot"		// Good shot.
									]
	array<string> btKillLines = [
								"BT_TargetEliminated"	// Target eliminated.
								]

	bool stalkerDown = false
	bool reaperDown = false

	while ( true )
	{
		table results = WaitSignal( level, "HubEnemyKilledByPlayer", "HubEnemyKilledByBT" )

		if ( results.classname == "npc_stalker" && !stalkerDown && CoinFlip() )
		{
			wait 2.0
			// Stalker down.
			PlayBTDialogue( "BT_StalkerDown" )
			stalkerDown = true
		}
		else if ( results.classname == "npc_super_spectre" && !reaperDown )
		{
			wait 2.0
			// Reaper down.
			PlayBTDialogue( "BT_ReaperDown" )
			reaperDown = true
		}
		else if ( results.signal == "HubEnemyKilledByPlayer" && playerKillLines.len() > 0 && CoinFlip() )
		{
			wait 2.0
			PlayBTDialogue( playerKillLines[0] )
			playerKillLines.remove(0)
		}
		else if ( results.signal == "HubEnemyKilledByBT" && btKillLines.len() > 0 && CoinFlip() )
		{
			wait 2.0
			PlayBTDialogue( btKillLines[0] )
			btKillLines.remove(0)
		}
	}
}

void function HubBattleDeathCallback( entity npc, var damageInfo )
{
	if ( !IsValid( npc ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) )
		return

	table signalData
	signalData.classname <- npc.GetClassName()

	if ( attacker.IsPlayer() )
		Signal( level, "HubEnemyKilledByPlayer", signalData )
	else if ( attacker.IsTitan() )
		Signal( level, "HubEnemyKilledByBT", signalData )
}

void function BTIntroWalkAndTalkDialogue( entity player, entity bt )
{
	FlagWait( "dialogue_beacon_taken_some_damage" )

	// Scans detect minimal power functionality. It may need repairs.
	thread PlayBTDialogue( "BT_ItMayNeedRepairs" )

	FlagWait( "dialogue_multiple_contacts" )

	PlayMusic( "Music_Beacon_2_HearTheDistantBattle" )

	// Careful. I am picking up multiple contacts, range 300 meters.
	PlayBTDialogue( "BT_MultipleContacts" )
}

void function OpeningConversation( entity player )
{
	wait 5.0
	thread PlayerConversation( "ApproachingTransmitter", player )
}

void function OpeningDialogue( entity player )
{
	entity bt = player.GetPetTitan()

	Embark_Disallow( player )

	bt.EnableNPCFlag( NPC_IGNORE_ALL )

	//#####################
	// Intro
	//#####################

	// Make sure trial mode doesn't reveal any spoilers!
	if ( !Script_IsRunningTrialVersion() )
		thread OpeningConversation( player )

	waitthread PlayerClimbIntro( player, bt )

	CheckPoint()

	//#####################################
	// Hike up the hill and see the beacon
	//#####################################

	thread IntroGetMovingNag( player, bt )
	waitthread BTPointsToBeacon( bt )

	// Objective: Use the beacon to send SOS signal
	//entity beaconObjectiveLocation = GetEntByScriptName( "BeaconObjectiveLocation" )
	Objective_Set( "#BEACON_OBJECTIVE_GO_TO_BEACON", < 0, 0, 0 > )

	entity rockAnimNode = GetEntByScriptName( "bt_intro_cover2" )

	//###################################
	// Walk down to the first cover spot
	//###################################

	thread BTIntroWalkAndTalkDialogue( player, bt )

	waitthread RunToAndPlayAnimAndWait( bt, "bt_beacon_approach_a_start", rockAnimNode )
	// Get behind rock 1 and idle
	thread PlayAnim( bt, "bt_beacon_approach_a_loop", rockAnimNode )

	// Wait for player to be near BT
	WaittillAnyFlag( [ "PlayerReachedBottomOfHill", "EnteredFogArea" ] )

	// BT moves to second rock
	waitthread PlayAnim( bt, "bt_beacon_approach_b_start", rockAnimNode )
	thread PlayAnim( bt, "bt_beacon_approach_b_loop", rockAnimNode )

	bt.DisableNPCFlag( NPC_IGNORE_ALL )

	thread OpeningEmbarkNag( player )

	//#####################################
	// Give player access into BT and wait
	//#####################################

	Embark_Allow( player )

	waitthread WaitForPlayerToEmbarkOrFlag( player, "EnteredFogArea" )
	CheckPoint()

	bt = player.GetPetTitan()
	if ( IsValid( bt ) )
		bt.Anim_Stop()

	wait 5.0

	//#####################################
	// Militia asks for assistance
	//#####################################

	// Pilot, I am detecting Militia forces inside that beacon control room. They are signalling distress. Patching in.
	PlayBTDialogue( "BT_DetectingMilitiaForces" )

	// <...crackle crackle unintelligible...>
	PlayDialogue( "BT_CrackleCrackle", player )

	// Hey, you out there! Pilot! Are you reading us? We could use some help over here!
	PlayDialogue( "Mike_WeCanUseSomeHelp", player )

	// We're from the 3rd Militia Grenadiers! We're getting overrun by Stalkers! Please assist!
	PlayDialogue( "Mike_PleaseAssist", player )

	// I suggest we help eliminate these Stalkers, and then make direct contact with the Militia Riflemen.
	PlayBTDialogue( "BT_WeShouldHelp" )

	Objective_Set( "#BEACON_OBJECTIVE_HELP_CONTROL_ROOM_MILITIA", GetEntByScriptName( "control_room_battle_objective_pos" ).GetOrigin() )

	// Allows nag dialogue logic to happen
	FlagSet( "ShouldBeAssistingControlRoomFight" )

	thread ControlRoomBattleDialogue( player )
}

void function WaittillAnyFlag( array<string> flags )
{
	while (true)
	{
		foreach( string flag in flags )
		{
			if ( Flag( flag ) )
				return
		}
		WaitFrame()
	}
}

void function WaitForPlayerToEmbarkOrFlag( entity player, string flag )
{
//	EndSignal( player, "OnDeath" )
//	EndSignal( level, flag )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
				bool ha = true
		}
	)

	while ( IsValid( player ) )
	{
		if ( player.IsTitan() )
			return
		if ( Flag( flag ) )
			return
		wait 0.1
	}
}

void function OpeningEmbarkNag( entity player )
{
	wait 20
	if ( !player.IsTitan() )
	{
		// Pilot, I recommend you get in the cockpit - that fog is deadly to organic life.
		waitthread PlayBTDialogue( "BT_FogIsDeadlyToOrganics" )
	}
}

void function IntroGetMovingNag( entity player, entity bt )
{
	EndSignal( level, "PlayerMovingUpHill" )
	EndSignal( player, "OnDestroy" )
	EndSignal( bt, "OnDestroy" )

	while( IsConversationPlaying() || IsDialoguePlaying() )
		wait 1

	wait 3

	if ( Flag( "PlayerMovingUpHill" ) )
		return

	PlayBTDialogue( "BT_WeShouldGetMoving" )
}

void function PlayerClimbIntro( entity player, entity bt )
{
	player.DisableWeapon()

	entity node = GetEntByScriptName( "bt_intro_node" )
	entity mover = CreateOwnedScriptMover( node )

	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.0
	sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_beacon_intro_camp"
	sequence.thirdPersonAnim = "pt_beacon_intro_camp"
	sequence.viewConeFunction = ViewConeTight

	player.ContextAction_SetBusy()
	entity weaponModel

	OnThreadEnd(
		function() : ( player, weaponModel )
		{
			if ( IsValid( player ) )
			{
				player.Anim_Stop()
				player.ClearParent()
				ClearPlayerAnimViewEntity( player )
				if ( player.ContextAction_IsBusy() )
					player.ContextAction_ClearBusy()
				player.EnableWeapon()

				if ( IsValid( weaponModel ) )
					weaponModel.Destroy()
			}
		}
	)

	entity playerWeapon = player.GetActiveWeapon()
	if ( IsValid( playerWeapon ) )
	{
		asset weaponModelAsset = playerWeapon.GetWeaponInfoFileKeyFieldAsset( "playermodel" )
		entity fpProxy = player.GetFirstPersonProxy()
		int attachID = fpProxy.LookupAttachment( "PROPGUN" )
		weaponModel = CreatePropDynamic( weaponModelAsset, fpProxy.GetAttachmentOrigin( attachID ), fpProxy.GetAttachmentAngles( attachID ) )
		weaponModel.SetParent( player.GetFirstPersonProxy(), "PROPGUN", false, 0.0 )
	}

	bt.Anim_EnablePlanting()
	thread PlayAnimTeleport( bt, "bt_beacon_intro_camp", mover, "ref" )
	bt.Anim_AdvanceCycleEveryFrame( true )
	waitthread FirstPersonSequence( sequence, player, mover )
}

void function BTPointsToBeacon( entity bt )
{
	entity node = GetEntByScriptName( "bt_beacon_sighting_node" )

	// Get into position and idle while the player catches up
	waitthread RunToAndPlayAnimGravityForced( bt, "bt_beacon_intro_point_start", node )
	thread PlayAnim( bt, "bt_beacon_intro_point_idle", node )

	// Wait for player to get close
	FlagWait( "dialogue_theres_the_beacon" )
	while( IsDialoguePlaying() || IsConversationPlaying() )
		WaitFrame()

	waitthread PlayAnim( bt, "bt_beacon_intro_point_end", node )
}

void function ControlRoomBattleDialogue( entity player )
{
	if ( Flag( "ControlRoomBattleEnded" ) )
		return
	EndSignal( level, "ControlRoomBattleEnded" )

	//#######################################
	// Wait for the player to join the fight
	//#######################################

	thread ControlRoomBattle_NagInactivePlayer( player )

	while ( true )
	{
		if ( Flag( "PlayerHelpingControlRoomBattle" ) )
			break
		if ( file.controlRoomBattleEnemiesShot > 0 )
			break
		if ( file.controlRoomBattleEnemiesStomped > 0 )
			break
		WaitFrame()
	}

	while ( IsDialoguePlaying() )
		WaitFrame()

	thread ControlRoomBattle_PlayerRanOverEnemies( player )
	thread ControlRoomBattle_PlayerDidntRunOverEnemies( player )
}

void function ControlRoomBattle_PlayerRanOverEnemies( entity player )
{
	EndSignal( level, "ControlRoomBattleEnded" )
	EndSignal( level, "RanOverEnemiesEndThread" )

	// Wait for player to run over an enemy
	while ( file.controlRoomBattleEnemiesStomped == 0 )
		WaitFrame()

	Signal( level, "RunOverEnemiesEndThread" )

	wait 1.0

	// Good thinking, Pilot. Running them over *is* a valid tactical option.
	PlayBTDialogue( "BT_GoodThinkingRunThemOver" )
}

void function ControlRoomBattle_PlayerDidntRunOverEnemies( entity player )
{
	EndSignal( level, "ControlRoomBattleEnded" )
	EndSignal( level, "RunOverEnemiesEndThread" )

	// If player kills some enemies but doesn't run any over
	while ( file.controlRoomBattleEnemiesShot < 5 )
		WaitFrame()

	if ( file.controlRoomBattleEnemiesStomped > 0 )
		return

	Signal( level, "RanOverEnemiesEndThread" )

	wait 1.0

	// Pilot, you can also run them over. That *is* a valid tactical option...
	if ( player.IsTitan() )
	PlayBTDialogue( "BT_YouCanRunThemOver" )
}

void function ControlRoomBattle_NagInactivePlayer( entity player )
{
	if ( !Flag( "ShouldBeAssistingControlRoomFight" ) )
		return

	Signal( player, "ControlRoomBattle_NagInactivePlayer" )
	EndSignal( level, "ControlRoomBattleEnded" )
	EndSignal( player, "ControlRoomBattle_NagInactivePlayer" )
	EndSignal( player, "OnDestroy" )

	array<string> lines
	lines.append( "Mike_Nag_NeedYourAssistance" )	// (NAG) We can't hold them off for much longer. We need your assistance! Over.
	lines.append( "Mike_Nag_BadShape" )				// We're in bad shape! Please assist! Over.

	while ( true )
	{
		foreach( string line in lines )
		{
			wait 15
			if ( file.controlRoomBattleEnemies.len() < 5 )
				return
			PlayDialogue( line, player )
		}
	}
}

void function ControlRoomInteriorScene( entity player )
{
	EndSignal( player, "OnDeath" )

	Assert( IsAlive( file.mike ) && IsAlive( file.ike ), "IKE OR MIKE was dead when they shouldn't be" )
	// ike and mike should never die so we shouldn't have these endsignals.
	// EndSignal( file.mike, "OnDeath" )
	// EndSignal( file.ike, "OnDeath" )

	entity controlRoomNode = GetEntByScriptName( "control_room_node" )
	Assert( IsValid( controlRoomNode ) )

	entity arcTool = CreatePropDynamic( ARC_TOOL_ANIMATED_MODEL, controlRoomNode.GetOrigin(), controlRoomNode.GetAngles() )
	file.mike.TakeActiveWeapon()

	// Mike & Ike idle and wait for player and BT to come up elevator
	thread PlayAnimTeleport( file.mike, "pt_beacon_controlroom_a_01_start_loop", controlRoomNode )
	thread PlayAnimTeleport( file.ike, "pt_beacon_controlroom_a_02_start_loop", controlRoomNode )
	thread PlayAnimTeleport( arcTool, "tool_beacon_controlroom_a_01_start_loop", controlRoomNode )

//	FlagWait( "EnteredControlRoom" )
//	thread ClearFriendlyHighLightsInControlRoom()

	FlagWait( "PilotAndTitanInsideControlRoom" )

	// Close the door to prevent leaving
	FlagClear( "ControlRoomDoorOpen" )

	// Activate the elevator anims
	thread PlayAnim( file.mike, "pt_beacon_controlroom_a_01_signal", controlRoomNode )
	thread PlayAnim( arcTool, "tool_beacon_controlroom_a_01_signal", controlRoomNode )
	waitthread PlayAnim( file.ike, "pt_beacon_controlroom_a_02_signal", controlRoomNode )

	FlagSet( "MikeIkeActivatedElevator" )

	// Back to idle
	thread PlayAnim( file.mike, "pt_beacon_controlroom_a_01_wait_loop", controlRoomNode )
	thread PlayAnim( file.ike, "pt_beacon_controlroom_a_02_wait_loop", controlRoomNode )
	thread PlayAnim( arcTool, "tool_beacon_controlroom_a_01_wait_loop", controlRoomNode )

	// Wait for elevator to be up
	FlagWait( "ControlRoomElevatorUp" )

	// Wait for player to disembark BT
	thread DisembarkBTNag( player )
	while( player.IsTitan() || player.GetPetTitan() == null )
		WaitFrame()

	FlagSet( "ControlRoomASceneStarted" )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	if ( bt.Anim_IsActive() )
		WaittillAnimDone( bt )


	if ( EntityInSolid( bt, player ) )
	{
		thread PlayAnimTeleport( bt, "bt_beacon_controlroom_a_skit", controlRoomNode )
	}
	else
	{
		thread RunToAndPlayAnim( bt, "bt_beacon_controlroom_a_skit", controlRoomNode, true )
		table result = WaitSignal( bt, "OnFinishedAssault", "OnFailedToPath" )
		if ( result.signal == "OnFailedToPath" )
			thread PlayAnimTeleport( bt, "bt_beacon_controlroom_a_skit", controlRoomNode )
	}

	// Start the sequence
	thread PlaySceneAnimThenIdle( file.mike, controlRoomNode, "pt_beacon_controlroom_a_01_skit", "pt_beacon_controlroom_a_01_end_loop" )
	thread PlaySceneAnimThenIdle( file.ike, controlRoomNode, "pt_beacon_controlroom_a_02_skit", "pt_beacon_controlroom_a_02_end_loop" )
	thread PlaySceneAnimThenIdle( arcTool, controlRoomNode, "tool_beacon_controlroom_a_01_skit", "tool_beacon_controlroom_a_01_end_loop" )

	wait 36.5

	thread RandomGruntChatterAfterSceneA( player )

	// Sequence is done, open door to spoke 0 and idle
	FlagSet( "ControlRoomASceneDone" )

	Objective_Set( "#BEACON_OBJECTIVE_GET_ARC_TOOL", GetEntByScriptName( "spoke0_objective_location" ).GetOrigin() )

	WaittillAnimDone( bt )
	waitthread PlaySceneAnimThenIdle( bt, controlRoomNode, "", "bt_beacon_controlroom_a_end_loop", true )

	// Nag player to go get the arc tool
	wait 30.0

	if ( Flag( "LoadSpoke0" ) )
		return

	// Pilot, the beacon power substation is through that giant door marked "Power Grid"
	waitthread PlayDialogue( "BT_Nag_ThatDoorOverThere", bt )
	Objective_Remind()
}

/*
void function ClearFriendlyHighLightsInControlRoom()
{
	wait 0.5 // wait a bit so all npc's spawned
	entity node = GetEntByScriptName( "control_room_node" )
	array<entity> gruntArray = GetNPCArrayEx( "npc_soldier", TEAM_MILITIA, TEAM_ANY, node.GetOrigin(), 5000 )
	foreach( grunt in gruntArray )
	{
		printt( "grunt", grunt, Distance( grunt.GetOrigin(), node.GetOrigin() ) )
		if ( IsAlive( grunt) )
			Highlight_ClearFriendlyHighlight( grunt )
	}
}
*/

void function DisembarkBTNag( entity player )
{
	FlagEnd( "ControlRoomASceneStarted" )
	EndSignal( player, "OnDeath" )

	OnThreadEnd(
	function() : ( player )
	{
		if ( IsValid( player ) )
			ClearOnscreenHint( player )
	}
)
	wait 3.0

	if ( !player.IsTitan() )
		return

	// Pilot, I advise you disembark to engage the Militia Riflemen directly.
	PlayBTDialogue( "BT_DisembarkNag" )

	DisplayOnscreenHint( player, "DisembarkHint" )
	wait 3.0
}

void function RandomGruntChatterAfterSceneA( entity player )
{
	array<string> skitNames
	skitNames.append( "skit_turret_repair" )
	skitNames.append( "skit_window_a" )
	skitNames.append( "skit_window_b" )
	skitNames.append( "skit_arc_mine_activate" )
	skitNames.append( "skit_ammo_box" )
	skitNames.append( "skit_gearup" )

	array< array<string> > chatAliases
	chatAliases.append( ["Grunt_4_StalkersKeptComing"] )	// Those Stalkers just kept coming. It's a good thing that Pilot and that Titan showed up...
	chatAliases.append( ["Grunt_5_PickingThemOff"] )		// Blisk and his Mercs are cold blooded killers. It's a good thing someone's been picking them off one by one.
	chatAliases.append( ["Grunt_6_KillBecauseWeHaveTo"] )	// We kill because we have to. The IMC hired Blisk to kill for money. That's not noble.
	chatAliases.append( ["Grunt_11_TasteOfOwnMedicine"] )	// I heard someone's been killing off Blisk's team. Giving the mercenaries a taste of their own medicine.
	chatAliases.append( ["Grunt_12_NothingButWatch"] )		// We were just forced to watch the massacre over at the beacon. Nothing I could do but watch...
	chatAliases.append( ["Grunt_13_HeMadeItThisFar"] )		// That Pilot's gotta know some interesting tactics. He made it this far.
	chatAliases.append( ["Grunt_14_ProgrammedDrones"] )		// They didn't build this place expecting humans to hit the buttons. Nothing but programmed drones in charge down here.

	chatAliases.append( [ 	"Grunt_7_Conv1",				// I thought with Demeter shut down the IMC wouldn't have reinforcements.
							"Grunt_8_Conv2",				// They have pleny of mindless Stalkers, that's for damn sure.
							"Grunt_7_Conv3" ] )				// I don't know if that's a good thing or a bad thing.
	chatAliases.append( [ 	"Grunt_9_Conv4",				// Taking out Demeter was a huge victory for us, why doesn't it feel that way?
							"Grunt_10_Conv5",				// Well, the Demeter fleet was only about a third of the IMC presence on the Frontier. Still, every little victory counts.
							"Grunt_9_Conv6" ] )				// You have the fullest half-glass I've ever seen...

	thread SkitGruntsSpeakLinesNearPlayer( player, skitNames, chatAliases )
}

void function PlaySceneAnimThenIdle( entity guy, entity node, string sceneAnim, string idleAnim, bool teleport = false )
{
	EndSignal( guy, "OnDeath" )

	if ( sceneAnim != "" )
	{
		if ( teleport )
			waitthread PlayAnim( guy, sceneAnim, node )
		else
			waitthread PlayAnimTeleport( guy, sceneAnim, node )
	}

	thread PlayAnim( guy, idleAnim, node )
}

void function ControlRoomBScene_BeforePower( entity player )
{
	//###################################
	// Player returned with the Arc Tool
	//###################################

	Objective_Set( "#BEACON_OBJECTIVE_RETURN_WITH_ARC_TOOL" )

	SetGlobalForcedDialogueOnly( true )
	Embark_Disallow( player )

	entity bt = player.GetPetTitan()
	while ( !IsValid( bt ) )
	{
		WaitFrame()
		bt = player.GetPetTitan()
	}
	Assert( IsValid( bt ) )
	entity btSpawnPos = GetEntByScriptName( "got_tool_titan_start" )
	Assert( IsValid( btSpawnPos ) )
	bt.SetOrigin( btSpawnPos.GetOrigin() )

	thread PlayerReturnsFromSpoke0Hallway( player )
	thread ControlRoomB_BeforePower_Grunts( player )
	thread ControlRoomB_BeforePower_Scene( player, bt )

	// Wait for player to enter the door and lock the player in
	FlagWait( "PowerRelayHallway" )
	FlagClear( "PowerArrayDoorOpen" )

	wait 1.0

	//###################################
	// Player is between the hatches
	//###################################

	// Caution: high radiation levels detected. Your suit will only protect you for a limited time. I suggest you move quickly.
	waitthread PlayDialogue( "BT_RadiationVeryHigh", bt )

	// I wouldn't stay in there too long unless you want to be burnt to a crisp.
	waitthread PlayDialogue( "Mike_WouldntStayTooLong", file.mike )

	// Nag and wait for player to have arc tool equipped
	thread NagPlayerToEquipArcToolAtInnerHatch( player )
	WaitTillPlayerHasArcToolEquipped( player )

	PlayMusic( "Music_Beacon_10_RelayChamber" )

	wait 1.0

	//#######################################
	// Door opening countdown and door opens
	//#######################################

	// Ok, opening the hatch in 3...
	PlayDialogue( "Mike_OkOpeningHatch", player )

	// 2...
	PlayDialogue( "Mike_2", player )

	// 1...
	PlayDialogue( "Mike_1", player )

	// Go!
	thread PlayDialogue( "Mike_Go", player )

	// Open the door and lock the player in
	FlagSet( "PowerArrayDoorInner" )
	FlagWait( "EnteredPowerArray" )
	FlagClear( "PowerArrayDoorInner" )
	FlagClear( "OpenShutters" )
	Objective_Update( <0,0,0> )

	EmitSoundOnEntityOnlyToPlayerWithFadeIn( player, player, "Pilot_GeigerCounter_Warning_LV1", 1.5 )

	//###############################
	// Wait until room is powered up
	//###############################

	// Wait till we are done in the room
	FlagWait( "PowerArrayActivated" )
	Objective_Clear()
	CheckPoint()
}

void function ControlRoomBScene_AfterPower( entity player )
{
	SetGlobalForcedDialogueOnly( true )
	Embark_Disallow( player )

	entity bt = player.GetPetTitan()
	entity controlRoomNode = GetEntByScriptName( "control_room_node" )
	thread PlayAnimTeleport( bt, "bt_beacon_controlroom_b_wait", controlRoomNode)

	thread ControlRoomB_AfterPower_Grunts( player )

	// Open the door to let the player out
	FlagSet( "PowerArrayDoorInner" )
	thread PlayerStopsTakingRadiationDamage( player )

	//################################
	// Player is back at control room
	//################################

	FlagWait( "OpenShutters" )
	FlagSet( "PowerArrayDoorOpen" )

	delaythread( 1 ) ControlRoomB_AfterPower_BT( bt )
	wait 0.5
	waitthread ControlRoomB_BootupDialogue( player, bt )

	//##############################
	// Wait for player to embark BT
	//##############################

	// Wait until player is in the Titan
	thread BT_Nag_Player_Leave_Control_Room( bt )
	Embark_Allow( player )
	while ( !player.IsTitan() )
		WaitFrame()
	FlagSet( "PlayerEnteredBTAfterPoweringUpControlRoom" )

	wait 1.0

	// Elevator Goes Down
	ElevatorDown( 3.5 )

	// Open the exit door
	FlagSet( "ControlRoomDoorOpen" )

	EndSignal( player, "OnDeath" )
	// ike and mike should never die so we shouldn't have these endsignals.
	// EndSignal( file.mike, "OnDeath" )
	// EndSignal( file.mike, "OnDestroy" )

	while( Distance( player.GetOrigin(), file.mike.GetOrigin() ) < 2700 )
		WaitFrame()

	// Be careful. We've already lost a lot of good soldiers over there.
	thread PlayDialogue( "Mike_BeCareful", player )
}

void function ControlRoomB_BootupDialogue( entity player, entity bt )
{
	entity loudspeaker = GetEntByScriptName( "control_room_loudspeaker" )

	array<entity> grunts = GetClosestGrunts( bt.GetOrigin(), 3, [file.mike, file.ike ] )
	Assert( grunts.len() == 3 )

	entity grunt1 = file.ike
	entity grunt2 = grunts[0]
	entity grunt3 = grunts[1]
	entity grunt4 = grunts[2]

	float looktime = 0.9
	file.mike.Anim_ScriptedPlay( "pt_control_roomB_gruntA_salute" )
	file.mike.Anim_SetInitialTime( looktime )
	file.ike.Anim_ScriptedPlay( "pt_control_roomB_gruntB_salute" )
	file.ike.Anim_SetInitialTime( looktime )

	wait 0.5

	thread ControlRoomScreensPowerOn()

	// Alright, we got power. Open those shutters. Let's get that beacon up and running.
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE351_16_01_mcor_gcaptain", true )
	PlayDialogue( "Mike_OpenThoseShutters", file.mike )

	// Opening shutters!
	thread PlayDialogue( "Grunt2_OpeningShutters", grunt2 )

	wait 1.0

	OpenShutters()

	wait 1.0

	// Diagnostic complete. Power 100%.
	PlayDialogue( "Facility_DiagnosticsComplete", 	loudspeaker )

	UnlockAchievement( player, achievements.POWER_BEACON )

	// Initiate dish targeting reset.
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE351_19_01_mcor_gcaptain", true )
	wait 0.1
	PlayDialogue( "Mike_InitiateDishTargeting", 	file.mike )

	// Yes, sir! Initiating reset.
	//thread PlayDialogue( "Grunt1_InitiatingReset", 		grunt1 )

	// Uplink Targeting Module reset intiated.
	thread PlayDialogue( "Facility_TargetingInitiated", 	loudspeaker )

	PlayMusic( "Music_Beacon_11_DishStartAndFail" )
	thread ControlRoomBScene_AfterPower_FX()
	SetDishAngle( 0, 10.0 )
	FlagSet( "DishRingsActivate" )

	wait 1.0

	// 60%
	PlayDialogue( "Grunt1_60Percent", 				grunt1 )

	wait 0.8

	// 70%
	PlayDialogue( "Grunt1_70Percent", 				grunt1 )

	wait 0.8

	// 80% ... 90%
	PlayDialogue( "Grunt1_8090Percent", 				grunt1 )


	// WARNING. Fault detected. Emergency shut down.
	PlayDialogue( "Facility_FaultDetected", 	loudspeaker )

	// Ahh Great. What's going on? Talk to me!
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE351_26_01_mcor_gcaptain", true )
	wait 0.2
	PlayDialogue( "Mikes_WhatsGoingOn", 		file.mike )

	// Not sure. Some sort of fail safe!
	PlayDialogue( "Grunt3_NotSure", 				grunt3 )

	// Scans indicate the Uplink Targeting Module is offline.
	PlayDialogue( "BT_TargetingModuleOffline", 		bt )

	// Not good. I bet the IMC are on their way.
	looktime = 5.5
	file.mike.Anim_ScriptedPlay( "pt_control_roomB_gruntA_idle" )
	file.mike.Anim_SetInitialTime( looktime )
	file.ike.Anim_ScriptedPlay( "pt_control_roomB_gruntB_idle" )
	file.ike.Anim_SetInitialTime( looktime )
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE351_29_01_mcor_gcaptain", true )
	wait 0.3
	PlayDialogue( "Mike_IMCOnTheirWay", 			file.mike )

	// That is a reasonable bet.
	PlayDialogue( "BT_ReasonableBet", 				bt )

	// McCord, can we bypass the module?
	int yawID 		= file.mike.LookupPoseParameterIndex( "head_yaw" )
	file.mike.SetPoseParameterOverTime( yawID, 46.5, 0.5 )
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE351_31_01_mcor_gcaptain", true )
	PlayDialogue( "Mike_CanWeBypassModule", 		file.mike )

	// No, sir. Not unless we want to send a message to the entire IMC fleet.
	looktime = 2.1
	file.mike.Anim_ScriptedPlay( "pt_control_roomB_gruntA_idle" )
	file.mike.Anim_SetInitialTime( looktime )
	file.ike.Anim_ScriptedPlay( "pt_control_roomB_gruntB_idle" )
	file.ike.Anim_SetInitialTime( looktime )
	file.ike.Anim_ScriptedAddGestureSequence( "face_BE351_32_01_mcor_grunt2", true )
	int yawID2 		= file.ike.LookupPoseParameterIndex( "head_yaw" )
	file.ike.SetPoseParameterOverTime( yawID2, -46.5, 0.5 )
	PlayDialogue( "Grunt2_NoSir", 					file.ike )
	file.ike.SetPoseParameterOverTime( yawID2, 0, 0.5 )

	// Then the module is gonna have to be repaired manually.
	file.mike.SetPoseParameterOverTime( yawID, -46.5, 0.5 )
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE351_31_01_mcor_gcaptain", true )
	PlayDialogue( "Mike_RepairedManually", 			file.mike )
	file.mike.SetPoseParameterOverTime( yawID, 0, 0.5 )

	// Pilot, this situation could use your skills.
	PlayDialogue( "BT_SituationForPilot", 			bt )

	// I hope you're up for another trip to hell, Pilot. You'll need to repair beacon on-site and get back here as fast as possible.
	looktime = 5.4
	file.mike.Anim_ScriptedPlay( "pt_control_roomB_gruntA_idle" )
	file.mike.Anim_SetInitialTime( looktime )
	file.ike.Anim_ScriptedPlay( "pt_control_roomB_gruntB_idle" )
	file.ike.Anim_SetInitialTime( looktime )
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE351_35_01_mcor_gcaptain", true )
	wait 0.4
	PlayDialogue( "Mike_RepairBeaconInSite", 		file.mike )

	Objective_Set( "#BEACON_OBJECTIVE_FIND_REPLACEMENT_MODULE", GetEntByScriptName( "bt_throw_objective_location" ).GetOrigin() )
}

void function ControlRoomBScene_AfterPower_FX()
{
	vector soundPos = < 11658, -2432, 480 >

	FlagSet( "fx_Beacon_lights" )

	wait 3
	FlagSet( "fx_Beacon_beam" )

	wait 8

	FlagSet( "fx_beacon_explode" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, soundPos, "bt_beacon_controlroom_dish_explosion" )
}
/*
void function BeaconBeamStutter()
{
	//Flicker the beam
	while ( true )
	{

		FlagClear( "fx_Beacon_beam" )
		wait RandomFloatRange( 1.0, 3.0 )

		FlagSet( "fx_Beacon_beam" )
		wait RandomFloatRange( 1.0, 3.0 )
	}
}
*/

void function PlayerReturnsFromSpoke0Hallway( entity player )
{
	entity door_node = GetEntByScriptName( "spoke0_door_guard_node_return" )
	entity door_grunt = CreateSoldier( TEAM_MILITIA, door_node.GetOrigin(), door_node.GetAngles() )
	DispatchSpawn( door_grunt )
	thread PlayAnimTeleport( door_grunt, "pt_door_guard_A_start", door_node )

	entity grunt1 = GetClosestGrunt( player.GetOrigin() )

	wait 1.0

	thread PlayGabbyDialogue( "Grunt1_LooksLikeArcTool", door_grunt )
	thread PlayAnim( door_grunt, "pt_door_guard_A", door_node )

	WaitSignal( door_grunt, "doorknock" )
	FlagSet( "Door1ToSpoke0Open" )

	WaittillAnimDone(door_grunt )
	thread PlayAnim( door_grunt, "pt_door_guard_A_start", door_node )
}

void function ControlRoomB_BeforePower_Grunts( entity player )
{
	Assert( IsAlive( file.mike ) && IsAlive( file.ike ), "IKE OR MIKE was dead when they shouldn't be" )
	// ike and mike should never die so we shouldn't have these endsignals.
	// EndSignal( file.mike, "OnDeath" )
	// EndSignal( file.ike, "OnDeath" )

	entity controlRoomNode = GetEntByScriptName( "control_room_node_rotated" )
	Assert( IsValid( controlRoomNode ) )

	// Mike & Ike idle at control console
	thread PlayAnimTeleport( file.mike, "pt_control_roomB_gruntA_idle", controlRoomNode )
	thread PlayAnimTeleport( file.ike, "pt_control_roomB_gruntB_idle", controlRoomNode )

	// When player walks by they do a salute
	//commented this out because it looks bad here
/*	FlagWait( "grunts_salute" )

	thread PlayAnim( file.mike, "pt_control_roomB_gruntA_salute", controlRoomNode )
	waitthread PlayAnim( file.ike, "pt_control_roomB_gruntB_salute", controlRoomNode )

	// Back to idle
	thread PlayAnim( file.mike, "pt_control_roomB_gruntA_idle", controlRoomNode )
	thread PlayAnim( file.ike, "pt_control_roomB_gruntB_idle", controlRoomNode )*/
}

void function ControlRoomB_BeforePower_Scene( entity player, entity bt )
{
	// Guard stands at the relay chamber door
	entity chamber_door_node = GetEntByScriptName( "chamber_door_guard_node" )
	entity chamber_door_grunt = file.gren
	thread PlayAnimTeleport( chamber_door_grunt, "pt_door_guard_A_start", chamber_door_node )

	// BT and pipe wait to be visible
	entity controlRoomNode = GetEntByScriptName( "control_room_node" )
	Assert( IsValid( controlRoomNode ) )
	thread PlayAnimTeleport( file.controlRoomCable, "cable_beacon_controlroom_b_idle", controlRoomNode )
	thread PlayAnimTeleport( bt, "bt_beacon_controlroom_b_pipe_idle", controlRoomNode )

	// Wait for the door to the control room to open up from another thread
	FlagWait( "Door1ToSpoke0Open" )

	// The cable is secure, Captain.
	thread CableSecureVO()

	// Good work, Pilot Cooper. Now we can jump-start the power to get the beacon functional.
	thread PlayDialogue( "BT_GoodWorkCooper", bt )

	// BT pushes the pipe into position then idles
	thread PlayAnimTeleport( file.controlRoomCable, "cable_beacon_controlroom_b", controlRoomNode )
	thread PlayAnim( bt, "bt_beacon_controlroom_b_pipeA", controlRoomNode )
	thread PlayAnimOnAnimDone( bt, "bt_beacon_controlroom_b_pipeA_idle", controlRoomNode )

	wait 9

	// Wait for player to have entered the control room if they were still in the cooridor
	FlagWait( "PlayerEnteredControlRoomWithArcTool" )

	Objective_Clear()

	float looktime = 5.4
	float lookdelay = 0.4
	// Glad you made it back, Cooper. Just in time too, the system's rewired - now all we need is some power.
	file.mike.Anim_ScriptedPlay( "pt_control_roomB_gruntA_idle" )
	file.mike.Anim_SetInitialTime( looktime )
	file.ike.Anim_ScriptedPlay( "pt_control_roomB_gruntB_idle" )
	file.ike.Anim_SetInitialTime( looktime )
	wait lookdelay
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE341_02_01_mcor_gcaptain", true )
	waitthread PlayDialogue( "Mike_WeNeedSomePower", file.mike )

	wait 0.5

	// Pilot, the power chamber relays are offline. The Arc Tool should be able to jump start them manually.
	thread PlayDialogue( "BT_RelaysAreOffline", bt )
	thread PlayAnim( bt, "bt_beacon_controlroom_b_pipeB", controlRoomNode )
	thread PlayAnimOnAnimDone( bt, "bt_beacon_controlroom_b_wait", controlRoomNode )

	wait 5.5

	Objective_Set( "#BEACON_OBJECTIVE_ACTIVATE_POWER_RELAYS", GetEntByScriptName( "objective_relays_location" ).GetOrigin() )

	wait 1.0

	// Cooper, let's hope that Arc Tool was worth all the trouble.
	file.mike.Anim_ScriptedPlay( "pt_control_roomB_gruntA_idle" )
	file.mike.Anim_SetInitialTime( looktime )
	file.ike.Anim_ScriptedPlay( "pt_control_roomB_gruntB_idle" )
	file.ike.Anim_SetInitialTime( looktime )
	wait lookdelay
	file.mike.Anim_ScriptedAddGestureSequence( "face_BE341_04_01_mcor_gcaptain", true )
	thread PlayDialogue( "Mike_WorthTheTrouble", file.mike )

	thread BT_Nag_Player_Enter_Power_Chamber( bt )
	thread GruntBanterPlayerReturnedWithArcTool( player )

	// Wait for player to get close to the chamber door
	while( Distance( player.GetOrigin(), chamber_door_node.GetOrigin() ) > 300 )
		WaitFrame()

	// Open the chamber door
	thread PlayAnim( chamber_door_grunt, "pt_door_guard_A", chamber_door_node )

	WaitSignal( chamber_door_grunt, "doorknock" )
	FlagSet( "PowerArrayDoorOpen" )

	WaittillAnimDone(chamber_door_grunt )
	thread PlayAnim( chamber_door_grunt, "pt_door_guard_A_start", chamber_door_node )
}

void function CableSecureVO()
{
	wait 7.0
	// The cable is secure, Captain.
	thread PlayGabbyDialogue( "Grunt_CableSecure", file.ike )
}

void function PlayAnimOnAnimDone( entity guy, string animation_name, entity ornull reference = null, string ornull optionalTag = null, float blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
{
	wait 0.1
	WaittillAnimDone( guy )
	PlayAnim( guy, animation_name, reference, optionalTag, blendTime )
}

void function GruntBanterPlayerReturnedWithArcTool( entity player )
{
	// Do a few grunt banter lines after player returns with the arc tool but stop doing them once he enteres the power array

	array<string> skitNames
	skitNames.append( "skit_ammo_box" )
	skitNames.append( "skit_gearup" )

	array< array<string> > chatAliases
	chatAliases.append( [ 	"Grunt_Banter_Wait_Power_Array1",		// That Pilot better be careful in there...After those relays blew, they leaked radiation all over that chamber. Scorched my damn hair when I got too close.
							"Grunt_Banter_Wait_Power_Array2",		// What hair? You're bald, Barry.
							"Grunt_Banter_Wait_Power_Array3" ] )	// Not yet, still got a few survivors. Just like us.

	wait 2.0 // give mike some time to finish his line
	if ( !Flag( "PowerRelayHallway" ) )
		thread SkitGruntsSpeakLinesNearPlayer( player, skitNames, chatAliases, "PowerRelayHallway" )
}

void function ControlRoomB_AfterPower_Grunts( entity player )
{
	Assert( IsAlive( file.mike ) && IsAlive( file.ike ), "IKE OR MIKE was dead when they shouldn't be" )
	// ike and mike should never die so we shouldn't have these endsignals.
	// EndSignal( file.mike, "OnDeath" )
	// EndSignal( file.ike, "OnDeath" )

	entity controlRoomNode = GetEntByScriptName( "control_room_node_rotated" )
	Assert( IsValid( controlRoomNode ) )

	// Idle
	thread PlayAnim( file.mike, "pt_control_roomB_gruntA_idle", controlRoomNode )
	thread PlayAnim( file.ike, "pt_control_roomB_gruntB_idle", controlRoomNode )

	FlagWait( "ControlRoomWindowsOpen" )

	// React to shutters opening
	thread PlayAnim( file.mike, "pt_control_roomB_gruntA_react", controlRoomNode )
	waitthread PlayAnim( file.ike, "pt_control_roomB_gruntB_react", controlRoomNode )

	// Back to idle
	thread PlayAnim( file.mike, "pt_control_roomB_gruntA_idle", controlRoomNode )
	thread PlayAnim( file.ike, "pt_control_roomB_gruntB_idle", controlRoomNode )
}

void function ControlRoomB_AfterPower_BT( entity bt )
{
	entity controlRoomNodeBT = GetEntByScriptName( "control_room_node" )
	Assert( IsValid( controlRoomNodeBT ) )
	waitthread PlayAnim( bt, "bt_beacon_controlroom_b_listening", controlRoomNodeBT )
	thread PlayAnim( bt, "bt_beacon_controlroom_b_embark", controlRoomNodeBT )
}

void function BT_Nag_Player_Enter_Power_Chamber( entity bt )
{
	EndSignal( level, "PowerRelayHallway" )

	wait 25.0

	if ( Flag( "PowerRelayHallway" ) )
		return

	// The Captain will open the chamber door for you when you are ready.
	PlayDialogue( "BT_Nag_GoIntoChamber", bt )
	Objective_Remind()
}

void function BT_Nag_Player_Leave_Control_Room( entity bt )
{
	EndSignal( level, "PlayerEnteredBTAfterPoweringUpControlRoom" )

	while ( true )
	{
		wait 15
		if ( Flag( "PlayerEnteredBTAfterPoweringUpControlRoom" ) )
			return

		// Embark and we will move out Pilot.
		PlayDialogue( "BT_Nag_ReadyToMoveOut", bt )

		wait 20
	}
}

void function WaitTillPlayerHasArcToolEquipped( entity player )
{
	EndSignal( player, "OnDeath" )
	while (true)
	{
		entity weapon = player.GetActiveWeapon()
		if ( IsValid( weapon ) && weapon.GetWeaponClassName() == "sp_weapon_arc_tool" )
			break
		WaitFrame()
	}
	Signal( player, "PlayerEquippedArcToolAtInnerHatch" )
}

void function NagPlayerToEquipArcToolAtInnerHatch( entity player )
{
	EndSignal( player, "PlayerEquippedArcToolAtInnerHatch" )
	EndSignal( player, "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
				ClearOnscreenHint( player )
		}
	)

	wait 0.2

	while ( true )
	{
		// Get that Arc Tool ready. When I open the hatch, every second will count.
		DisplayOnscreenHint( player, "ArcToolHint" )
		waitthread PlayDialogue( "Mike_HaveArcToolReady", player )
		wait 5.0
		ClearOnscreenHint( player )
		wait 5.0

		// You need to switch to the Arc Tool, Pilot. When I open that inner hatch, every second will count.
		DisplayOnscreenHint( player, "ArcToolHint" )
		waitthread PlayDialogue( "Mike_SwitchToArcTool", player )
		wait 5.0
		ClearOnscreenHint( player )
		wait 5.0
	}
}

void function WaitForElevatorSafeToMove()
{
	entity player = GetPlayerArray()[0]
	player.EndSignal( "OnDestroy" )
	while( player.ContextAction_IsBusy() || player.IsPhaseShifted() )
	{
		WaitFrame()
	}
}

void function ElevatorUp( float moveTime = 0 )
{
	waitthread WaitForElevatorSafeToMove()

	entity mover = GetEntByScriptName( "elevator_mover" )
	Assert( IsValid( mover ) )
	mover.ChangeNPCPathsOnMove( true )

	entity moveToEnt = GetEntByScriptName( "elevator_top" )
	Assert( IsValid( moveToEnt ) )

	entity clip = GetEntByScriptName( "elevatorwallclip" )
	clip.Solid()
	ToggleNPCPathsForEntity( clip, false )
	FlagSet( "ElevatorRailingUp" )
	FlagClear( "ElevatorIsDown" )

	if ( moveTime > 0 )
	{
		EmitSoundOnEntity( mover, "Beacon_ControlRoom_Lift_Up" )
		mover.NonPhysicsMoveTo( moveToEnt.GetOrigin(), moveTime, moveTime * 0.25, moveTime * 0.25 )

		float rumbleAmplitude = 300.0
		float rumbleFrequency = 100
		entity rumbleHandle = CreateShakeRumbleOnly( mover.GetOrigin(), rumbleAmplitude, rumbleFrequency, moveTime + 2.0, 500 )
		rumbleHandle.SetParent( mover, "", false )

		wait moveTime
		EmitSoundOnEntity( mover, "Platform_Stop" )

		rumbleAmplitude = 500.0
		rumbleFrequency = 30
		CreateShakeRumbleOnly( mover.GetOrigin(), rumbleAmplitude, rumbleFrequency, 1.5, 500 )
	}
	else
	{
		mover.SetOrigin( moveToEnt.GetOrigin() )
	}
	FlagSet( "ElevatorIsUp" )
}

void function ElevatorDown( float moveTime = 0 )
{
	waitthread WaitForElevatorSafeToMove()

	entity mover = GetEntByScriptName( "elevator_mover" )
	Assert( IsValid( mover ) )
	mover.ChangeNPCPathsOnMove( true )

	entity moveToEnt = GetEntByScriptName( "elevator_bottom" )
	Assert( IsValid( moveToEnt ) )

	entity clip = GetEntByScriptName( "elevatorwallclip" )
	clip.NotSolid()
	ToggleNPCPathsForEntity( clip, true )
	FlagClear( "ElevatorIsUp")

	if ( moveTime > 0 )
	{
		EmitSoundOnEntity( mover, "Beacon_ControlRoom_Lift_Down" )
		mover.NonPhysicsMoveTo( moveToEnt.GetOrigin(), moveTime, moveTime * 0.25, moveTime * 0.25 )

		float rumbleAmplitude = 300.0
		float rumbleFrequency = 100
		entity rumbleHandle = CreateShakeRumbleOnly( mover.GetOrigin(), rumbleAmplitude, rumbleFrequency, moveTime + 2.0, 500 )
		rumbleHandle.SetParent( mover, "", false )

		wait moveTime
		EmitSoundOnEntity( mover, "Platform_Stop" )

		rumbleAmplitude = 500.0
		rumbleFrequency = 30
		CreateShakeRumbleOnly( mover.GetOrigin(), rumbleAmplitude, rumbleFrequency, 1.5, 500 )
	}
	else
	{
		mover.SetOrigin( moveToEnt.GetOrigin() )
	}

	FlagClear( "ElevatorRailingUp" )
	FlagSet( "ElevatorIsDown" )
}

void function PowerUpArcSwitchArray( entity player )
{
	//############################################
	// Wait for all arc switches to be powered up
	//############################################

	EndSignal( player, "OnDeath" )

	array<entity> arcSwitches = GetEntArrayByScriptName( "radial_arc_switch" )
	printt( "Arc switches to power up:", arcSwitches.len() )

	array<int> pointerVar = [ 0 ]
	table<string,array<entity> > arcSwitchGroups = {}
	foreach( entity arcSwitch in arcSwitches )
	{
		Assert( arcSwitch.HasKey( "script_noteworthy" ) )
		string group = string( arcSwitch.kv.script_noteworthy )
		if ( !( group in arcSwitchGroups ) )
			arcSwitchGroups[ group ] <- []
		arcSwitchGroups[ group ].append( arcSwitch )

		thread ArcSwitchJankFix( arcSwitch, arcSwitches )
		thread IncrementVarWhenArcSwitchActivated( arcSwitch, pointerVar )

		arcSwitch.Anim_Play( "close_with_effects" )
		wait 0.1
	}

	foreach( string group, array<entity> arcSwitches in arcSwitchGroups )
		thread ArcSwitchGroupActivation( arcSwitches, group )

	int lastVal = pointerVar[0]

	bool played25Percent = false
	bool played50Percent = false
	bool played75Percent = false
	int startPlayerHealth = player.GetMaxHealth()
	float endPlayerHealth = startPlayerHealth * 0.6

	float health

	while ( pointerVar[0] < arcSwitches.len() )
	{
		health = GraphCapped( pointerVar[0], 0, arcSwitches.len(), startPlayerHealth, endPlayerHealth )
		player.SetHealth( int( health ) )

		if ( lastVal != pointerVar[0] )
		{
			if ( !played25Percent && pointerVar[0] >= ( arcSwitches.len() * 0.25 ) )
			{
				// Good, we're at 25% power. Keep going.
				//thread PlayBTDialogue( "BT_25PercentPower" )
				played25Percent = true
			}
			if ( !played50Percent && pointerVar[0] >= ( arcSwitches.len() * 0.5 ) )
			{
				// Power level at 50%. Don't stop.
				//thread PlayBTDialogue( "BT_50PercentPower" )
				played50Percent = true
				EmitSoundOnEntityOnlyToPlayerWithFadeIn( player, player, "Pilot_GeigerCounter_Warning_LV2", 1.5 )
				FadeOutSoundOnEntity( player, "Pilot_GeigerCounter_Warning_LV1", 1.5 )
			}
			if ( !played75Percent && pointerVar[0] >= ( arcSwitches.len() * 0.75 ) )
			{
				// We're at 75%. You're almost there.
				//thread PlayBTDialogue( "BT_75PercentPower" )
				played75Percent = true
				EmitSoundOnEntityOnlyToPlayerWithFadeIn( player, player, "Pilot_GeigerCounter_Warning_LV3", 1.5 )
				FadeOutSoundOnEntity( player, "Pilot_GeigerCounter_Warning_LV1", 1.5 )
				FadeOutSoundOnEntity( player, "Pilot_GeigerCounter_Warning_LV2", 1.5 )
			}
		}

		lastVal = pointerVar[0]
		WaitFrame()
	}

	thread KeepPlayerAtLowHealthUntilFlag( player, int( health ), "PlayerHealthComesBack" )

	// Power flow at 100%. Well done.
	thread PlayBTDialogue( "BT_100PercentPower" )
	wait 1.0
	FlagSet( "PowerArrayActivated" )
}

void function ArcSwitchGroupActivation( array<entity> arcSwitches, string group )
{
	vector averageOrigin = < 0, 0, 0 >
	vector roomCenter
	if ( group == "group0" || group == "group1" || group == "group2" || group == "group3" )
		roomCenter = GetEntByScriptName( "relay_room_center_lower" ).GetOrigin()
	else
		roomCenter = GetEntByScriptName( "relay_room_center" ).GetOrigin()

	// Monitor switch activation and calculate center origin
	array<int> pointerVar = [ 0 ]
	foreach( entity arcSwitch in arcSwitches )
	{
		thread IncrementVarWhenArcSwitchActivated( arcSwitch, pointerVar )
		averageOrigin += arcSwitch.GetOrigin()
	}
	averageOrigin /= arcSwitches.len()
	vector moveToPos = averageOrigin + ( Normalize( averageOrigin - roomCenter ) * 55 )

	// Wait for all switches to be activated
	while ( pointerVar[0] < arcSwitches.len() )
		WaitFrame()

	wait 0.2

	// Parent them to a mover that will move them into the wall
	entity mover = CreateScriptMover( averageOrigin, <0,0,0> )
	foreach( entity arcSwitch in arcSwitches )
		arcSwitch.SetParent( mover, "", true )

	// Move them into the wall
	EmitSoundAtPosition( TEAM_ANY, averageOrigin, "beacon_power_array_retract" )
	mover.NonPhysicsMoveTo( moveToPos, 4.0, 1.5, 1.5 )
	wait 3.0

	// Close the bay door
	if ( FlagExists( group + "close" ) )
		FlagSet( group + "close" )

	// Wait for retract to finish and stop the sound
	wait 1.0
	StopSoundAtPosition( averageOrigin, "beacon_power_array_retract" )

	wait 2.0

	for ( int i = arcSwitches.len() - 1 ; i >= 0 ; i-- )
	{
		if ( IsValid( arcSwitches[i] ) )
			arcSwitches[i].Destroy()
	}
}

void function ArcSwitchJankFix( entity arcSwitch, array<entity> arcSwitches )
{
	// Get nearby arc switches
	array<entity> nearbySwitches = ArrayClosestWithinDistance( arcSwitches, arcSwitch.GetOrigin(), 100 )
	nearbySwitches.fastremovebyvalue( arcSwitch )

	if ( nearbySwitches.len() != 2 )
		return

	EndSignal( arcSwitch, "arc_switch_activated" )

	float[2] pointerVar = [ -1.0, -1.0 ]
	foreach( int i, entity nearbySwitch in nearbySwitches )
		thread ArcSwitchJankFix_UpdateVarWhenActivated( arcSwitch, nearbySwitch, pointerVar, i )

	while ( true )
	{
		if ( !IsValid( arcSwitch ) )
			return

		if ( pointerVar[0] > -1 && pointerVar[1] > -1 )
			break

		WaitFrame()
	}

	if ( fabs( pointerVar[0] - pointerVar[1] ) <= 1.0 )
	{
		Signal( arcSwitch, "ArcEntityDamaged", { attacker = GetPlayerArray()[0] } )
	}
}

void function ArcSwitchJankFix_UpdateVarWhenActivated( entity arcSwitchToFix, entity nearbyArcSwitch, float[2] pointerVar, int index )
{
	EndSignal( arcSwitchToFix, "arc_switch_activated" )
	WaitSignal( nearbyArcSwitch, "arc_switch_activated" )
	pointerVar[ index ] = Time()
}

void function KeepPlayerAtLowHealthUntilFlag( entity player, int health, string flag )
{
	EndSignal( player, "OnDeath" )
	EndSignal( level, flag )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				FadeOutSoundOnEntity( player, "Pilot_GeigerCounter_Warning_LV1", 4.0 )
				FadeOutSoundOnEntity( player, "Pilot_GeigerCounter_Warning_LV2", 4.0 )
				FadeOutSoundOnEntity( player, "Pilot_GeigerCounter_Warning_LV3", 4.0 )
			}
		}
	)

	while ( !Flag( flag ) )
	{
		player.SetHealth( health )
		WaitFrame()
	}
}

void function PlayerStopsTakingRadiationDamage( entity player )
{
	FlagWaitClear( "PowerArrayDoorInner" )
	FlagSet( "PlayerHealthComesBack" )

	wait 1.0

	thread PlayDialogue( "Mike_PowerIsBack", file.mike )
}

void function BTMentionDeadTroops( entity player )
{
	EndSignal( level, "CenterDoorsOpen" )

	FlagClear( "dialogue_dead_troops" )
	FlagWait( "dialogue_dead_troops" )

	PlayMusic( "Music_Beacon_12_Spoke1FallenSoldiers" )

	thread PlayerConversation( "FallenTitan", player )
}

void function IncrementVarWhenArcSwitchActivated( entity arcSwitch, array<int> pointerVar )
{
	WaitSignal( arcSwitch, "arc_switch_activated" )
	pointerVar[0]++
}

void function ThrowToSpoke1( entity player )
{
	CheckPoint()

	printt( "ThrowToSpoke1" )

	SetGlobalForcedDialogueOnly( true )
	Embark_Disallow( player )

	entity titanNode = GetEntByScriptName( "FastballNodeSpoke1" )
	Assert( IsValid( titanNode ) )
	entity throwTarget = titanNode.GetLinkEnt()
	Assert( IsValid( throwTarget ) )

	// Make sure player isn't in BT
	if ( player.IsTitan() )
		thread ForcedTitanDisembark( player )

	// Wait for BT to exist since we may be disembarking
	entity bt = player.GetPetTitan()
	while ( !IsValid( bt ) )
	{
		bt = player.GetPetTitan()
		WaitFrame()
	}
	Assert( IsValid( bt ) )

	// after done, don't go back to start point, facing away from player
	bt.AssaultSetGoalRadius( 1024 )

	waitthread RunToAndPlayAnim( bt, "bt_beacon_fastball_throw_start", titanNode, false )

	thread UpdateObjectiveDuringFastballSequence( player, bt )
	thread FastballConversation( player, bt )
	PlayMusic( "Music_Beacon_13_BTGivesThePlan" )
	WaittillAnimDone( bt )

	thread BTNagToGetIntoHand( player, bt )

	// BT Gets ready to throw the player
	FlagSet( "DoFastball1Objective" )
	SetFastballAnims( "", "bt_beacon_fastball_throw_idle", "bt_beacon_fastball_throw_end", "ptpov_beacon_fastball_throw_end", "pt_beacon_fastball_throw_end" )
	thread ScriptedTitanFastball( player, bt, titanNode, throwTarget, "PlayerFastballToSpoke1" )

	WaitSignal( bt, "fastball_release" )
	Embark_Allow( player )

	thread ThrowImpactSound( player )
}

void function ThrowImpactSound( entity player )
{
	EndSignal( player, "OnDeath" )

	wait 0.5
	while( true )
	{
		if ( player.IsOnGround() )
			break
		if ( player.IsWallHanging() )
			break
		if ( player.IsWallRunning() )
			break
		WaitFrame()
	}

	EmitSoundOnEntity( player, "Beacon_FastballThrow_Impact" )
}

void function FastballConversation( entity player, entity bt )
{
	wait 15.0
	thread PlayerConversation( "FirstFastball", player, bt )
}

void function UpdateObjectiveDuringFastballSequence( entity player, entity bt )
{
	player.EndSignal( "OnDeath" )
	bt.EndSignal( "OnDeath" )

	wait 8.0
	Objective_Set( "#BEACON_OBJECTIVE_GET_TO_SECOND_DISH", < -256, -592, 96 >, GetEntByScriptName( "dish_on_crane" ) )
	Objective_StaticModelHighlightOverrideEntity( file.highlightDishModel )

	FlagWait( "DoFastball1Objective" )
	Objective_Hide( player )
	WaitFrame()
	if ( !Flag( "PlayerFastballToSpoke1" ) )
	{
		Objective_Set( "#BEACON_OBJECTIVE_FASTBALL1", < 0,0,1 > )
		Objective_SetFastball( bt )

		WaitSignal( bt, "FastballStarting" )

		entity marker = Objective_GetMarkerEntity()
		marker.ClearParent()
	}
	Objective_Hide( player )
	WaitFrame()
	Objective_SetSilent( "#BEACON_OBJECTIVE_GET_TO_SECOND_DISH", < -256, -592, 96 >, GetEntByScriptName( "dish_on_crane" ) )
	Objective_StaticModelHighlightOverrideEntity( file.highlightDishModel )
}

void function BTNagToGetIntoHand( entity player, entity bt )
{
	EndSignal( bt, "FastballStarting" )
	EndSignal( player, "OnDestroy" )
	EndSignal( level, "PlayerFastballToSpoke1" )

	OnThreadEnd(
	function() : ( player )
		{
			PlayMusic( "Music_Beacon_14_BTThrowThruFirstCrane" )
			StopConversationNow( player )
		}
	)

	if ( Flag( "PlayerFastballToSpoke1" ) )
		return

	wait 60.0

	if ( Flag( "PlayerFastballToSpoke1" ) )
		return

	// Pilot, I have an idea of how to get you over there. Climb onto my hand when you're ready.
	PlayBTDialogue( "BT_Nag_ClimbIntoMyHand" )

	wait 60.0

	if ( Flag( "PlayerFastballToSpoke1" ) )
		return

	// Standing by, Pilot. Climb onto my hand.
	PlayBTDialogue( "BT_Nag_ClimbIntoMyHand" )
}

void function SecondBeaconArrivalDialogue( entity player )
{
	// Uplink Targeting Module detected. Check your HUD.
	Objective_Update( <0,0,0>, file.module1 )

	wait 1.5
	StopMusic()
	PlayMusic( "Music_Beacon_18_SeeTheDish" )
	PlayBTDialogue( "BT_UplinkTargetingModuleDetected" )
	Objective_Remind()

	wait 2.0

	// Zulu One-Six, Beacon Four gantry team is KIA. Pilot may be attempting to transmit from there.
	PlayDialogue( "EnemyRadio_TeamIsKIA", player )

	wait 0.4

	// Zulu One- Six to Richter, the Pilot’s intentions are unknown. He may be attempting to draw us away from the Titan.
	PlayDialogue( "EnemyRadio_DrawUsAway", player )

	wait 0.5

	// Nein. Focus on the Pilot. I have other plans for the Titan.
	PlayDialogue( "EnemyRadio_FocusOnPilot", player )
}

void function TargetingModuleDialogue_CraneControls( entity player )
{
	EndSignal( player, "OnDestroy" )

	entity dishCrane = GetEntByScriptName( "dish_crane" )
	WaitTillCraneUsed( dishCrane )

	PlayMusic( "Music_Beacon_19A_DishMoveStingerToDishBattle_Ambient" )

	wait 1.5

	// Good, you're at the controls. Move the dish to the far right, to bring it within your reach.
	PlayBTDialogue( "BT_MoveDishCloser" )
}

void function TargetingModuleDialogue_OnDish( entity player )
{
	EndSignal( player, "OnDestroy" )

	// Wait for player to be on the crane
	FlagWait( "PlayerOnSecondDish" )

	// Sensors detect the module in the projector of that dish.
	PlayBTDialogue( "BT_ModuleInProjector" )
	Objective_Remind()

	// Wait for player to be at module
	FlagWait( "PlayerAtSecondartBeaconSwitch" )

	// StopMusicTrack( "Music_Beacon_19A_DishMoveStingerToDishBattle_Ambient" )
}

void function TargetingModuleDialogue_RemovedModule( entity player )
{
	EndSignal( player, "OnDestroy" )

	// Wait for module removal
	FlagWait( "satellite_panelboard1" )

	wait 6.0

	// Uplink targeting module...disconnected.
	PlayDialogue( "Beacon_ModuleRemoved", player )

	UnlockAchievement( player, achievements.GET_MODULE )

	// *Chime 1 In* Protocol 2 Mission Update: Uplink module acquired. *Chime 1 Out* Standing by for your return Cooper.
	PlayBTDialogue( "BT_GoodYouGotIt" )

	// Caution...entering maintenance mode.
	PlayDialogue( "Beacon_MaintananceMode", player )
}

void function ClimbDishDialogue( entity player )
{
	FlagWait( "dialogue_radio_dishclimb" )

	PlayMusic( "music_beacon_24a_blisktease" )

	// Make sure trial mode doesn't reveal any spoilers!
	if ( !Script_IsRunningTrialVersion() )
	{
		// Blisk, this is Slone.
		PlayDialogue( "Radio_DishClimb_01", player )

		// Go ahead.
		PlayDialogue( "Radio_DishClimb_02", player )

		// Kane and Ash are dead. Someone's been killing your mercs. And it looks like one of our radios has been nicked. I knew you shouldn't have hired those tossers...
		PlayDialogue( "Radio_DishClimb_03", player )

		// (impressed rough chuckle, dangerous laugh)
		PlayDialogue( "Radio_DishClimb_04", player )

		// Oi Pilot...this is Kuben Blisk. You been listening to us eh? You want to be a hero, yeah? Ok.
		PlayDialogue( "Radio_DishClimb_05", player )

		// Keep coming at me, keep coming! But if I were you, I'd stop trying so hard to be a hero eh?. You'll live longer.
		PlayDialogue( "Radio_DishClimb_06", player )
	}

	FlagWait( "ReachedTopOfDish" )

	// Hypothesis: the dish will automatically reorient intself once the new module is installed.
	PlayBTDialogue( "BT_DishWillReorientItself" )
	Objective_Remind()
}

void function SecondBeaconReaperSpawned( entity reaper )
{
	thread SecondBeaconReaperMusic( reaper )
}

void function SecondBeaconReaperMusic( entity reaper )
{
	PlayMusic( "Music_Beacon_19B_DishBattle_Percussive" )
	WaitSignal( reaper, "OnDeath" )
	//StopMusicTrack( "Music_Beacon_19B_DishBattle_Percussive" )
}

void function FlyerInit()
{
	array<entity> refs = GetEntArrayByScriptName( "flyer_perch" )
	foreach ( entity ref in refs )
		thread FlyerThink( ref )
}

void function FlyerThink( entity ref )
{
	entity trigger = ref.GetLinkEnt()
	Assert( IsValid( trigger ) )

	entity player

	while ( true )
	{
		table results = WaitSignal( trigger, "OnTrigger" )
		player = expect entity( results.activator )
		if ( !IsValid( player ) )
			continue
		if ( !player.IsPlayer() )
			continue
		break
	}

	// Spawn a flyer here
	Flyer flyer
	flyer.model = CreatePropDynamic( FLYER_MODEL, ref.GetOrigin(), ref.GetAngles(), 2 )
	flyer.ref = ref
	flyer.health = 300
	flyer.perched = true
	file.flyers.append( flyer )

	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( flyer, "FlyerDeath" )
	EndSignal( flyer.model, "OnDestroy" )

	AddEntityCallback_OnDamaged( flyer.model, OnFlyerDamaged )

	thread FlyerPerchIdle( flyer )

	// Wait for player to be near flyer with line of sight
	if ( ref.HasKey( "script_noteworthy" ) && ref.kv.script_noteworthy == "instant" )
	{
		// Doesn't wait for player to look at it or anything, just flies away after being spawned
		wait 0.4
	}
	else
	{
		waitthread WaitTillFlyerLookatToDamaged( player, flyer.model )
		if ( CoinFlip() )
			waitthread PlayAnim( flyer.model, "fl_perched_scream", ref )
	}

	Signal( flyer, "FlyerDisturbed" )

	waitthread PlayAnim( flyer.model, "fl_perched_takeoff", ref )

	flyer.model.Destroy()
	file.flyers.fastremovebyvalue( flyer )
}

void function WaitTillFlyerLookatToDamaged( entity player, entity flyer )
{
	EndSignal( flyer, "OnDamaged" )
	waitthread WaitTillLookingAt( player, flyer, true, 45, 1200 )
}

void function OnFlyerDamaged( entity model, var damageInfo )
{
	// Get the struct this flyer is part of
	Flyer flyer
	foreach ( Flyer _flyer in file.flyers )
	{
		if ( _flyer.model == model )
		{
			flyer = _flyer
			break
		}
	}
	if ( !IsValid( flyer.model ) )
		return

	// Remove health
	if ( flyer.health <= 0 )
		return

	float damageAmount = DamageInfo_GetDamage( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( damageAmount >= 500 )
		damageAmount = flyer.health
	else if ( attacker && attacker.IsTitan() )
		damageAmount *= 2.5

	if ( IsValid( attacker ) && attacker.IsPlayer() && IsAlive( attacker ) )
		attacker.NotifyDidDamage( flyer.model, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), damageAmount, DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )

	flyer.health -= damageAmount

	// return if flyer is still alive
	if ( flyer.health > 0 )
		return

	thread FlyerDeath( flyer, damageAmount, attacker )
}

void function FlyerDeath( Flyer flyer, float damageAmount, entity attacker )
{
	// Stop anims that were playing
	flyer.model.Anim_Stop()
	Signal( flyer, "FlyerDeath" )

	// Make flyer do something on death
	if ( attacker && attacker.IsTitan() && damageAmount > 150 )
	{
		// Gib
		vector forceVec = attacker.GetOrigin() - flyer.model.GetOrigin()
		forceVec.Norm()
		forceVec *= 50.0 // seems like a good number
		flyer.model.Gib( forceVec )
	}
	else
	{
		if ( flyer.perched )
		{
			float duration = flyer.model.GetSequenceDuration( "fl_perched_death" )
			thread PlayAnim( flyer.model, "fl_perched_death" )
			wait duration - 0.2
		}
		if ( IsValid( flyer.model ) )
			flyer.model.BecomeRagdoll( flyer.model.GetVelocity(), true )
	}

	//flyer.model.Destroy()
	file.flyers.fastremovebyvalue( flyer )
}

void function FlyerPerchIdle( Flyer flyer )
{
	EndSignal( flyer.model, "OnDestroy" )
	EndSignal( flyer, "FlyerDisturbed" )
	EndSignal( flyer, "FlyerDeath" )

	array<string> anims
	anims.append( "fl_perched_idle" )
	anims.append( "fl_perched_idle" )
	anims.append( "fl_perched_idle_look" )

	while ( IsValid( flyer.model ) )
		waitthread PlayAnim( flyer.model, anims.getrandom(), flyer.ref )
}

void function DrawBridge1()
{
	entity bridge = GetEntByScriptName( "drawbridge1" )
	Assert( IsValid( bridge ) )
	FlagWait( "drawbridge1" )
	bridge.Anim_Play( "open" )
}

void function DrawBridge2()
{
	entity bridge = GetEntByScriptName( "drawbridge2" )
	Assert( IsValid( bridge ) )
	FlagWait( "drawbridge2" )
	bridge.Anim_Play( "open" )
}

void function DrawBridge3()
{
	entity bridge = GetEntByScriptName( "drawbridge3" )
	Assert( IsValid( bridge ) )
	FlagWait( "SecondBeaconDrawbridge" )
	bridge.Anim_Play( "open" )
	FlagWaitClear( "SecondBeaconDrawbridge" )
	bridge.Anim_Play( "close" )
	FlagSet( "SecondBeaconBacktrackCheckpoint" )
}

void function DishCraneInPosition( entity player )
{
	entity crane = GetEntByScriptName( "dish_crane" )
	CraneAllowRotationLeft( crane, false )

	float yaw
	while ( true )
	{
		yaw = GetCraneYaw( crane )
		if ( yaw < 70 )
			break
		WaitFrame()
	}

	FlagSet( "BigCraneDone" )
	SetCraneEnabled( crane, false )

	// Alpha Two-One, is he dead yet? Give me a sitrep, over.
	waitthread PlayDialogue( "Richter_IsHeDeadYet", player )

	// Richter, we need backup. The enemy Pilot is still active around Beacon 4, over.
	waitthread PlayDialogue( "EnemyRadio_WeNeedBackup", player )

	// Backup?...typical IMC Schwächling. Sending backup.
	waitthread PlayDialogue( "Richter_SendingBackup", player )
}

void function ControlRoomBattleTimedEvents( entity player )
{
	FlagEnd( "ControlRoomBattleEnded" )

	thread WidowStalkerDropoff_Near( player )

	FlagWait( "StopFloodSpawnersLeft" )
	WaitTillLookingAt( player, GetEntByScriptName( "flyby_lookat" ), false, 45, 0, 20.0 )

	//thread WidowStalkerDropoff_Far()

	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_close", "Beacon_Stratton_Strafe_Close" )
	wait 5.0
	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_far", "Beacon_Stratton_Strafe_Far" )
	wait 5.0
	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_close_alt", "Beacon_Stratton_Strafe_Close_Alt" )
	wait 5.0
	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_far_alt", "Beacon_Stratton_Strafe_Far_Alt" )
	wait 5.0
	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_close", "Beacon_Stratton_Strafe_Close" )
	wait 5.0
	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_far", "Beacon_Stratton_Strafe_Far" )
	wait 5.0
	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_close_alt", "Beacon_Stratton_Strafe_Close_Alt" )
	wait 5.0
	waitthreadsolo GunshipAttacksControlRoom( "st_beacon_strafe_far_alt", "Beacon_Stratton_Strafe_Far_Alt" )
}

void function WidowStalkerDropoff_Near( entity player )
{
	entity node = GetEntByScriptName( "widow_deploy_node_near" )
	entity ship = CreatePropDynamic( WIDOW_MODEL, node.GetOrigin(), node.GetAngles(), 6, 99999 )

	// Idle in place
	thread PlayAnimTeleport( ship, "wd_beacon_widow_spawner_near_idle", node.GetOrigin(), node.GetAngles() )

	WaitTillLookingAt( player, ship, true, 90, 9000, 30, null, "StopFloodSpawnersLeft" )

	// Fly away
	waitthread PlayAnimTeleport( ship, "wd_beacon_widow_spawner_near", node.GetOrigin(), node.GetAngles() )

	if ( IsValid( ship ) )
		ship.Destroy()
}
/*
void function WidowStalkerDropoff_Far()
{
	entity node = GetEntByScriptName( "widow_deploy_node_far" )
	entity ship = CreatePropDynamic( WIDOW_MODEL, node.GetOrigin(), node.GetAngles(), 6, 99999 )
	entity stalker = CreateStalker( TEAM_IMC, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( stalker )

	thread PlayAnimTeleport( stalker, "st_beacon_widow_spawner", node.GetOrigin(), node.GetAngles() )
	waitthread PlayAnimTeleport( ship, "wd_beacon_widow_spawner", node.GetOrigin(), node.GetAngles() )

	if ( IsValid( ship ) )
		ship.Destroy()
	if ( IsValid( stalker ) )
		stalker.Destroy()
}
*/
void function SpawnControlRoomMikeAndIke()
{
	// Spawn Mike -> Cpt Cole
	if ( !IsValid( file.mike ) || !IsAlive( file.mike) )
	{
		entity mikeSpawner = GetEntByScriptName( "mike" )
		file.mike = mikeSpawner.SpawnEntity()
		DispatchSpawn( file.mike )
		file.mike.SetModel( TEAM_MIL_GRUNT_MODEL_RIFLE )
		file.mike.SetInvulnerable()
		file.mike.SetTitle( "#CPT_COLE" )
		ShowName( file.mike )
	}

	// Spawn Ike -> SGT McCord
	if ( !IsValid( file.ike ) || !IsAlive( file.ike) )
	{
		entity ikeSpawner = GetEntByScriptName( "ike" )
		file.ike = ikeSpawner.SpawnEntity()
		DispatchSpawn( file.ike )
		file.ike.SetModel( TEAM_MIL_GRUNT_MODEL_SMG )
		file.ike.SetInvulnerable()
		file.ike.SetTitle( "#SGT_MCCORD" )
		ShowName( file.ike )
	}

		// Spawn gren -> RC3 Grenier
	if ( !IsValid( file.gren ) || !IsAlive( file.gren) )
	{
		entity grenSpawner = GetEntByScriptName( "grenier" )
		file.gren = grenSpawner.SpawnEntity()
		DispatchSpawn( file.gren )
		file.gren.SetModel( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
		file.gren.SetInvulnerable()
		file.gren.SetTitle( "#RC3_GRENIER" )
		ShowName( file.gren )
	}

	printt( "Mike, Ike, and Gren spawned", file.mike, file.ike, file.gren )
}

void function SpawnControlRoomNPCs()
{
	// Spawn friendly grunts
	array<entity> control_room_militia_spawners = GetEntArrayByScriptName( "control_room_militia_spawners" )
	foreach ( entity spawner in control_room_militia_spawners )
	{
		entity guy = spawner.SpawnEntity()
		DispatchSpawn( guy )
		guy.SetModel( TEAM_MIL_GRUNT_MODEL_LMG )
		//AssignRandomMilitiaGruntModel( guy )
		guy.SetInvulnerable()
		guy.ai.invulnerableToNPC = true
		file.controlRoomGrunts.append( guy )
	}

	// Delete friendly grunts when we spawn the skit grunts
	FlagWait( "EnteredControlRoom" )
	foreach( entity guy in file.controlRoomGrunts )
	{
		if ( IsValid( guy ) )
			guy.Destroy()
	}
	file.controlRoomGrunts.clear()
}

void function ControlRoomBattleDeathCallback( entity guy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) || !attacker.IsPlayer() )
		return

	thread ControlRoomBattle_NagInactivePlayer( attacker )

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( damageSourceID == damagedef_titan_step )
		file.controlRoomBattleEnemiesStomped++
	else
		file.controlRoomBattleEnemiesShot++
}

void function ControlRoomBattle( entity player )
{
	AddDeathCallback( "npc_soldier", ControlRoomBattleDeathCallback )
	AddDeathCallback( "npc_stalker", ControlRoomBattleDeathCallback )

	thread StaticSwarmStalkers()

	thread FloodSpawners( "StalkerFloodSpawnerLeft", "StopFloodSpawnersLeft" )
	thread FloodSpawners( "StalkerFloodSpawnerRight", "StopFloodSpawnersRight" )

	// Turret
	array<entity> turrets = GetEntArrayByScriptName( "control_room_battle_turret" )
	foreach( entity turret in turrets )
	{
		turret.SetInvulnerable()
		turret.SetNoTarget( true )
		thread TurretShootsFloodStalkers( turret )
	}

	// When the player gets close these unimportant npcs are vulnerable again to other NPCs
	thread ControlRoomBattleNPCsVulnerableWait( player )

	// Wait until all enemies are dead
	while ( file.controlRoomBattleEnemies.len() > 0 )
	{
		wait 1.0
		ArrayRemoveDead( file.controlRoomBattleEnemies )
	}

	RemoveDeathCallback( "npc_soldier", ControlRoomBattleDeathCallback )
	RemoveDeathCallback( "npc_stalker", ControlRoomBattleDeathCallback )

	FlagSet( "ControlRoomBattleEnded" )

	while ( IsDialoguePlaying() )
		wait 0.5

	wait 2.0

	thread ControlRoomBattle_End_ColeAnim()
	thread ControlRoomBattle_End_IkeAnim()
	thread ControlRoomBattle_End_GrenAnim()
	thread ControlRoomBattle_End_Dudes()

	StopMusic()
	PlayMusic( "Music_Beacon_3_AllThreatsEliminated" )

	// Threat neutralized. Well done.This victory has raised our combat efficiency rating.
	PlayBTDialogue( "BT_ThreatNeutralized" )

	wait 1.5

	// Guardian One to Militia forces - all threats have been eliminated.
	PlayBTDialogue( "BT_AllThreatsEliminated" )

	delaythread( 0.5 ) FlagSet( "SavedOurAsses" )
	wait 1.0

	// You saved our asses. Those Stalkers just kept on coming -- we may not have lasted much longer.
	PlayDialogue( "Mike_YouSavedOurAsses", player )

	wait 1.0

	// We're opening the blast doors. Come on in.
	PlayDialogue( "Mike_ComeOnIn", player )

	// Open the doors
	FlagSet( "ControlRoomDoorOpen" )

	wait 2.0
	if ( !Flag( "PilotAndTitanInsideControlRoom" ) && PlayerIsFarFromElevator( player ) )
		PlayDialogue( "Mike_BlastDoorsAreOpen", player )

	thread NagPlayerToEnterControlRoom( player )
}

bool function PlayerIsFarFromElevator( entity player )
{
	return Distance( <11594, -2450, -204>, player.GetOrigin() ) >= 800
}

void function ControlRoomBattle_End_ColeAnim()
{
	FlagEnd( "ControlRoomDoorOpen" )

	vector origin = < 11770, -2449, 84.0313 >
	vector angles = < 0,180,0 >
	string anim = "react_salute_raisefist"
	vector hack = HackGetDeltaToRef( origin, angles, file.mike, anim )
	bool doArrival = false
	file.mike.AssaultPointToAnim( hack, angles, anim, doArrival, 16.0 )
	file.mike.WaitSignal( "OnFinishedAssault" )
	wait 2.1
	file.mike.Anim_ScriptedPlay( "CQB_Idle_Casual" )

	FlagWait( "SavedOurAsses" )

	file.mike.Anim_ScriptedPlay( "React_salute_high_thumbsup" )
	wait 2.1
	file.mike.Anim_ScriptedPlay( "CQB_Idle_Casual" )
	wait 1.0
	file.mike.Anim_ScriptedPlay( "stand_2_walk_180R" )
	WaittillAnimDone( file.mike )

	entity controlRoomNode = GetEntByScriptName( "control_room_node" )
	anim = "pt_beacon_controlroom_a_01_start_loop"
	origin = controlRoomNode.GetOrigin()
	waitthread RunToAnimStartForced_Deprecated( file.mike, anim, origin + < 16,0,1>, controlRoomNode.GetAngles() )
	thread PlayAnim( file.mike, anim, origin, controlRoomNode.GetAngles() )
}

void function ControlRoomBattle_End_GrenAnim()
{
	FlagEnd( "ControlRoomDoorOpen" )

	wait 1.0

	file.gren.SetEfficientMode( true )

	vector origin = < 11770, -2000, 84.0313 >
	vector angles = < 0,230,0 >
	string anim = "React_salute_high_thumbsup"
	vector hack = HackGetDeltaToRef( origin, angles, file.gren, anim )
	bool doArrival = false
	file.gren.AssaultPointToAnim( hack, angles, anim, doArrival, 16.0 )
	file.gren.WaitSignal( "OnFinishedAssault" )
	wait 2.1
	file.gren.Anim_ScriptedPlay( "CQB_Idle_Casual" )

	FlagWaitWithTimeout( "SavedOurAsses", 2.0 )

	file.gren.Anim_Stop()

	// Idle
	entity node = GetEntByScriptName( "spoke0_door_guard_node" )
	anim = "pt_door_guard_A_start"
	origin = node.GetOrigin()
	waitthread RunToAnimStartForced_Deprecated( file.gren, anim, origin, node.GetAngles() )
	thread PlayAnim( file.gren, anim, origin, node.GetAngles() )
}

void function ControlRoomBattle_End_IkeAnim()
{
	FlagEnd( "ControlRoomDoorOpen" )

	wait 1.0

	file.ike.Anim_Stop()
	file.ike.SetEfficientMode( true )

	vector origin = < 11773, -2948, 84.0313 >
	vector angles = < 0, 140 ,0 >
	string anim = "React_salute"
	vector hack = HackGetDeltaToRef( origin, angles, file.mike, anim )
	bool doArrival = false
	file.ike.AssaultPointToAnim( hack, angles, anim, doArrival, 16.0 )
	file.ike.WaitSignal( "OnFinishedAssault" )
	wait file.ike.GetSequenceDuration( anim ) - 0.3
	file.ike.Anim_ScriptedPlay( "CQB_Idle_Casual" )

	FlagWaitWithTimeout( "SavedOurAsses", 3.0 )

	file.ike.Anim_Stop()

	entity controlRoomNode = GetEntByScriptName( "control_room_node" )
	anim = "pt_beacon_controlroom_a_02_start_loop"
	origin = controlRoomNode.GetOrigin()
	waitthread RunToAnimStartForced_Deprecated( file.ike, anim, origin + < 16,0,1>, controlRoomNode.GetAngles() )
	thread PlayAnim( file.ike, anim, origin, controlRoomNode.GetAngles() )
}

void function ControlRoomBattle_End_Dudes()
{
	array<string> anims = [ "React_salute_tapheart", 	"React_salute_headnod", 	"React_salute" ]
	array<vector> origin = [ < 11772, -2635, 84.0313 >, < 11757, -2281, 84.0313 > ]
	array<vector> angles = [ < 0, 166 ,0 >, < 0, 210, 0 > ]
	foreach( index, guy in file.controlRoomGrunts )
		thread ControlRoomBattle_End_DudeThink( guy, anims[ index ], origin[ index ], angles[ index ] )
}

void function ControlRoomBattle_End_DudeThink( entity guy, string anim, vector origin, vector angles )
{
	if ( !IsValid( guy ) )
		return
	guy.EndSignal( "OnDeath" )

	wait RandomFloatRange( 0.5, 1.5 )

	guy.Anim_Stop()
	guy.SetEfficientMode( true )

	vector hack = HackGetDeltaToRef( origin, angles, file.mike, anim )
	bool doArrival = false

	guy.AssaultPointToAnim( hack, angles, anim, doArrival, 16.0 )
	guy.WaitSignal( "OnFinishedAssault" )
	wait guy.GetSequenceDuration( anim ) - 0.3

	guy.Anim_ScriptedPlay( "CQB_Idle_Casual" )

	wait RandomFloatRange( 2, 4 )
	array<string> turn = [ "stand_2_walk_180L", "stand_2_walk_180R" ]

	guy.Anim_ScriptedPlay( turn.getrandom() )
	WaittillAnimDone( guy )
	guy.Anim_ScriptedPlay( "patrol_walk_lowport" )
	wait 3.5
	guy.Anim_ScriptedPlay( "walk_2_stand" )
	WaittillAnimDone( guy )
	guy.Anim_ScriptedPlay( "CQB_Idle_Casual" )
}

void function NagPlayerToEnterControlRoom( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( level, "PlayerOnElevator" )

	wait 15
	if ( Flag( "PlayerOnElevator" ) )
		return

	// Pilot, I recommend we go into the control room.
	PlayBTDialogue( "BT_Nag_GoIntoControlRoom" )
}

void function ControlRoomBattleNPCsVulnerableWait( entity player )
{
	EndSignal( player, "OnDeath" )

	vector controlRoomPos = GetEntByScriptName( "control_room_radius_ent" ).GetOrigin()
	while ( Distance( controlRoomPos, player.GetOrigin() ) > 1800 )
		WaitFrame()

	FlagSet( "PlayerHelpingControlRoomBattle" )

	thread KillOffEnemiesOverTime( player, file.controlRoomBattleEnemies )
}

void function KillOffEnemiesOverTime( entity player, array<entity> enemies, float startDelay = 0.0 )
{
	// Kills off enemies in the array over time. It tries to start with enemies that are behind the player and far away
	EndSignal( player, "OnDeath" )

	if ( startDelay > 0 )
		wait startDelay

	float startTime = Time()
	while ( true )
	{
		float delay = GraphCapped( Time(), startTime, startTime + 30.0, 3.0, 1.0 )
		wait delay

		ArrayRemoveDead( enemies )

		if ( enemies.len() == 0 )
			return

		array<entity> sortedEnemies = ArrayFarthest( enemies, player.GetOrigin() )

		entity enemyToKill
		foreach( entity enemy in sortedEnemies )
		{
			if ( IsSuperSpectre( enemy ) )
				continue
			float d = Distance( player.GetOrigin(), enemy.GetOrigin() )
			if ( d <= 500 )
				continue
			if ( PlayerCanSee( player, enemy, false, 65 ) && d < 2000 && sortedEnemies.len() <= 5 )
				continue
			enemyToKill = enemy
			break
		}

		if ( !IsValid( enemyToKill ) )
			continue

		//printt( "Auto-killing enemy" )
		//DebugDrawLine( enemyToKill.GetOrigin(), enemyToKill.GetOrigin() + <0,0,500>, 255, 0, 0, true, 500.0 )

		enemyToKill.TakeDamage( enemyToKill.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.deadly_fog } )
	}
}

void function GunshipBackstrackStrafe()
{
	wait 2.0
	entity node = GetEntByScriptName( "control_room_stalker_climb_node" )
	entity ship = CreatePropDynamic( STRATON_MODEL )
	waitthread PlayAnimTeleport( ship, "st_beacon_strafe_spoke1", node )
	EmitSoundOnEntity( ship, "Beacon_Stratton_Strafe_Spoke1" )
	ship.Destroy()
}

void function GunshipAttacksControlRoom( string anim, string soundAlias )
{
	entity node = GetEntByScriptName( "control_room_stalker_climb_node" )
	entity ship = CreatePropDynamic( STRATON_MODEL )

	thread PlayAnimTeleport( ship, anim, node )
	EmitSoundOnEntity( ship, soundAlias )

	// Wait for missile barrage
	WaitSignal( ship, "MissileControlRoom" )

	array<entity> targets = GetEntArrayByScriptName( "control_room_missile_target" )
	int numMissilesPerSide = RandomIntRangeInclusive( 3, 5 )
	for ( int i = 0 ; i < numMissilesPerSide ; i++ )
	{
		float delay = i * 0.2
		thread FireMissileFromShip( ship, "Light_Red1", targets.getrandom().GetOrigin(), delay )
		thread FireMissileFromShip( ship, "Light_Green1", targets.getrandom().GetOrigin(), delay )
	}

	WaittillAnimDone( ship )
	ship.Destroy()
}

void function FireMissileFromShip( entity ship, string tag, vector destination, float delay )
{
	wait delay

	if ( !IsValid( ship ) )
		return

	int index = ship.LookupAttachment( tag )
	vector startPos = ship.GetAttachmentOrigin( index )
	vector startAng = VectorToAngles( destination - startPos )

	PlayFX( MISSILE_FLASH, startPos )

	entity missile = CreateScriptMover( startPos, startAng )
	missile.SetModel( MISSILE_MODEL )

	PlayFXOnEntity( MISSILE_TRAIL, missile, "exhaust" )

	float d = Distance( missile.GetOrigin(), destination )
	float time = d / 4500

	float accel = min( time * 0.25, 1.0 )
	missile.NonPhysicsMoveTo( destination, time, accel, 0.0 )
	EmitSoundOnEntity( missile, "Beacon_Straton_MissileFire_RocketTrail" )
	wait time

	PlayFX( MISSILE_EXPLOSION, destination )
	EmitSoundAtPosition( TEAM_UNASSIGNED, destination, "Beacon_Straton_MissileFire_RocketExplo" )
	missile.Destroy()
}

void function TurretShootsFloodStalkers( entity turret )
{
	EndSignal( turret, "OnDeath" )

	entity target
	while ( true )
	{
		if ( Flag( "PlayerHelpingControlRoomBattle" ) )
			return

		target = GetClosestFloodEnemy()
		if ( IsValid( target ) && IsAlive( target ) )
		{
			turret.SetEnemy( target )
			wait 2.0
		}

		wait 1.0
	}
}

void function FloodSpawners( string spawnersScriptName, string stopFlag )
{
	array<entity> floodSpawners = GetEntArrayByScriptName( spawnersScriptName )
	Assert( floodSpawners.len() > 0 )

	// 1 in every 3 will not be efficient
	int efficiencyCounter = 3

	while ( true )
	{
		floodSpawners.randomize()
		foreach( entity spawner in floodSpawners )
		{
			if ( Flag( stopFlag ) )
				return

			wait RandomFloatRange( 4.0, 7.0 )

			ArrayRemoveDead( file.controlRoomBattleEnemies )
			if ( file.controlRoomBattleEnemies.len() >= 50 )
				continue

			// spawn a guy
			entity stalker = spawner.SpawnEntity()
			DispatchSpawn( stalker )
			//stalker.EnableNPCFlag( NPC_IGNORE_ALL )
			//stalker.SetHealth( 1 )
			stalker.GetActiveWeapon().AddMod( "less_npc_burst" )
			stalker.DisableHibernation()

			efficiencyCounter--
			if ( efficiencyCounter <= 0 )
			{
				efficiencyCounter = 2
				stalker.SetEfficientMode( false )
			}
			else
			{
				stalker.SetEfficientMode( true )
			}

			file.controlRoomBattleEnemies.append( stalker )

			thread FloodEnemyClimbControlRoomOrDie( stalker )
		}
	}
}

entity function GetClosestFloodEnemy()
{
	array<entity> targets
	entity bestTarget
	foreach( entity target in file.controlRoomBattleEnemies )
	{
		if ( IsValid( target ) && IsStalker( target ) )
			targets.append( target )
	}

	if ( targets.len() == 0 )
		return bestTarget

	return GetClosest( targets, GetEntByScriptName( "control_room_radius_ent" ).GetOrigin(), 3000 )
}

void function FloodEnemyClimbControlRoomOrDie( entity guy )
{
	EndSignal( guy, "OnDeath" )
	EndSignal( guy, "OnDestroy" )

	//guy.SetNoTarget( true )

	vector point = GetEntByScriptName( "control_room_radius_ent" ).GetOrigin()
	float deathRadius = RandomFloatRange( 1500, 2200 )
	float deathRadiusSqr = deathRadius * deathRadius

	while ( DistanceSqr( point, guy.GetOrigin() ) > deathRadiusSqr )
		wait 1.0

	//guy.SetNoTarget( false )

	// Guy is near the control room. Die after X seconds, but while waiting see if you can climb the control room
	float deathTime = Time() + RandomFloatRange( 1.0, 6.0 )
	if ( Flag( "PlayerHelpingControlRoomBattle" ) )
		deathTime = Time() + RandomFloatRange( 15.0, 20.0 )

	while ( Time() <= deathTime )
	{
		// Climb the control room if there is a slot free
		if ( GetAvailableControlRoomClimbSlot() >= 0 && guy.IsInterruptable() )
		{
			thread StalkerClimbControlRoom( guy )
			return
		}
		wait 0.1
	}

	// Timer ran out and stalker wasn't able to climb the control room. Kill him now so they don't pile up in the area
	guy.TakeDamage( guy.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.mp_weapon_rspn101 } )
}

int function GetAvailableControlRoomClimbSlot()
{
	array<int> availableSlots
	foreach( int i, entity guy in file.stalkerClimbSlots )
	{
		if ( !IsValid( guy ) )
			availableSlots.append( i )
	}

	if ( availableSlots.len() > 0 )
		return availableSlots.getrandom()
	return -1
}

void function StalkerClimbControlRoom( entity stalker )
{
	int slotIndex = GetAvailableControlRoomClimbSlot()
	Assert( slotIndex >= 0 )
	Assert( !IsValid( file.stalkerClimbSlots[ slotIndex ] ) )

	// Get assets used for the anim in this slot
	entity node = GetEntByScriptName( "control_room_stalker_climb_node" )
	string climbAnim = file.stalkerClimbAnims[ slotIndex ]
	string idleAnim = file.stalkerClimbIdles[ slotIndex ]

	// Stop doing assault path
	StopAssaultMoveTarget( stalker )

	// Don't die so easily so he can get to the node. Normally these guys only have 1 health so they die
	//stalker.SetHealth( 100 )
	//stalker.SetNoTarget( true )
	//stalker.ai.invulnerableToNPC = true

	// Reserve the slot
	file.stalkerClimbSlots[ slotIndex ] = stalker

	EndSignal( stalker, "OnDeath" )
	EndSignal( stalker, "OnDestroy" )

	// Free the slot on death
	OnThreadEnd(
	function() : ( slotIndex )
		{
			file.stalkerClimbSlots[ slotIndex ] = null
		}
	)

	// Get the stalker to the anim start point
	//table animStart = stalker.Anim_GetStartForRefPoint_Old( climbAnim, node.GetOrigin(), node.GetAngles() )
	//DebugDrawLine( stalker.GetOrigin(), animStart.origin, 255, 0, 0, true, 20.0 )
	waitthread RunToAndPlayAnim( stalker, climbAnim, node, false )

	float timeout = Time() + 2.0
	while ( !stalker.IsInterruptable() && Time() < timeout )
	{
		WaitFrame()
	}

	if ( !stalker.IsInterruptable() )
		return

	// Now that we are animating we can be killed by AI again
	//stalker.SetHealth( 1 )
	//stalker.SetNoTarget( false )
	//stalker.ai.invulnerableToNPC = false
	stalker.SetNPCFlag( NPC_NO_WEAPON_DROP, true )
	stalker.e.forceGibDeath = true
	stalker.SetEfficientMode( true )

	// Climb the control room then idle
	stalker.DisableNPCFlag( NPC_PAIN_IN_SCRIPTED_ANIM )

	// waitthread PlayAnim( stalker, climbAnim, node )
	WaittillAnimDone( stalker )

	SetDeathFuncName( stalker, "StaticSwarmStalkersDeath" )
	thread PlayAnim( stalker, idleAnim, node )
	thread StalkerDieOnAnimDone( stalker )

	thread KillControlRoomClimbStalkerDelayed( stalker, RandomFloatRange( 6.0, 10.0 ) )

	WaitSignal( stalker, "OnDeath" )
}

void function StaticSwarmStalkers()
{
	entity middleNode = GetEntByScriptName( "control_room_stalker_climb_node" )
	entity leftNode = GetEntByScriptName( "control_room_stalker_node_left" )
	entity rightNode = GetEntByScriptName( "control_room_stalker_node_right" )

	array<NodeAnimPair> animData

	animData.append( CreateStaticSwarmAnim( middleNode, "st_beacon_swarm_smash_B" ) )
	animData.append( CreateStaticSwarmAnim( middleNode, "st_beacon_swarm_shoot_C" ) )
	animData.append( CreateStaticSwarmAnim( middleNode, "st_beacon_swarm_claw_A" ) )
	animData.append( CreateStaticSwarmAnim( middleNode, "st_beacon_swarm_punch_B" ) )
	animData.append( CreateStaticSwarmAnim( middleNode, "st_beacon_swarm_smash_C" ) )
	animData.append( CreateStaticSwarmAnim( leftNode, "st_beacon_swarm_shoot_window_A" ) )
	animData.append( CreateStaticSwarmAnim( leftNode, "st_beacon_swarm_shoot_window_B" ) )
	animData.append( CreateStaticSwarmAnim( rightNode, "st_beacon_swarm_shoot_window_A" ) )
	animData.append( CreateStaticSwarmAnim( rightNode, "st_beacon_swarm_shoot_window_B" ) )

	//###############################
	// Spawn Stalkers and play anims
	//###############################

	array<entity> stalkers
	foreach( NodeAnimPair data in animData )
	{
		entity stalker = CreateStalker( TEAM_IMC, data.node.GetOrigin(), data.node.GetAngles() )
		DispatchSpawn( stalker )
		SetDeathFuncName( stalker, "StaticSwarmStalkersDeath" )

		// Don't drop a weapon on death becuase it gets stuck in the geo
		stalker.SetNPCFlag( NPC_NO_WEAPON_DROP, true )
		stalker.e.forceGibDeath = true

		file.controlRoomBattleEnemies.append( stalker )
		stalkers.append( stalker )

		//stalker.SetNoTarget( true )
		//stalker.ai.invulnerableToNPC = true
		stalker.SetEfficientMode( true )
		stalker.SetNoTarget( true )
		//stalker.SetHealth( 1 )

		thread PlayAnim( stalker, data.anim, data.node )
		thread StalkerDieOnAnimDone( stalker )
	}

	FlagWait( "PlayerHelpingControlRoomBattle" )

	foreach ( entity stalker in stalkers )
	{
		if ( !IsValid( stalker ) || !IsAlive( stalker ) )
			continue
		//stalker.SetNoTarget( false )
		stalker.ai.invulnerableToNPC = false
	}
}

void function StalkerDieOnAnimDone( entity guy )
{
	guy.EndSignal( "OnDeath" )
	WaittillAnimDone( guy )

	guy.Die()
}

void function StaticSwarmStalkersDeath( entity guy )
{
	if ( !IsValid( guy ) )
		return
	guy.EndSignal( "OnDestroy" )

	guy.Anim_Stop()
	guy.NotSolid()
	guy.ClearParent()
	guy.Anim_ScriptedPlay( "st_dieforward_fallback" )
	guy.Anim_SetInitialTime( 0.7 )
	wait 0.8
	guy.BecomeRagdoll( < 0,0,-500 >, true )
}

NodeAnimPair function CreateStaticSwarmAnim( entity node, string anim )
{
	NodeAnimPair data
	data.node = node
	data.anim = anim
	return data
}

void function KillControlRoomClimbStalkerDelayed( entity stalker, float delay )
{
	EndSignal( stalker, "OnDeath" )
	wait delay
	stalker.TakeDamage( stalker.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.mp_weapon_rspn101 } )
}

void function FastballPlayerToDishUntilSuccess( entity player )
{
	EndSignal( player, "OnDeath" )

	// Kick the player out of BT if you're inside him
	Embark_Disallow( player )

	if ( player.IsTitan() || IsPlayerEmbarking( player ) )
		DisplayOnscreenHint( player, "DisembarkHint" )

	while ( player.IsTitan() || IsPlayerEmbarking( player ) )
		WaitFrame()

	ClearOnscreenHint( player )

	wait 2.0

	entity titanNode = GetEntByScriptName( "FastballNodeDish" )
	entity throwTarget = titanNode.GetLinkEnt()
	entity bt = player.GetPetTitan()
	while ( !IsValid( bt ) )
	{
		WaitFrame()
		bt = player.GetPetTitan()
	}
	Assert( IsValid( bt ) )

	EndSignal( level, "TargetingModuleReplaced" )
	OnThreadEnd(
	function() : ( player )
		{
			Embark_Allow( player )
		}
	)

	bool didInitialThrow = false
	while ( true )
	{
		// Fastball the player to the dish
		string startAnim = didInitialThrow ? "bt_beacon_fastball_lob_start_short" : "bt_beacon_fastball_lob_start"
		waitthread RunToAndPlayAnim( bt, startAnim, titanNode, false )

		printt( "player:", player )
		if ( IsValid( player ) )
			printt( "playerIsTitan?:", player.IsTitan() )

		bt = player.GetPetTitan()
		while ( !IsValid( bt ) )
		{
			WaitFrame()
			bt = player.GetPetTitan()
		}
		Assert( IsValid( bt ) )

		if ( !didInitialThrow )
		{
			thread SetObjectiveForInstallingModule()
			thread MusicOnFirstThrowToDish( player )
		}
		WaittillAnimDone( bt )

		thread ModuleBreadCrumbObjective( player, bt )

		SetFastballAnims( "", "bt_beacon_fastball_lob_idle", "bt_beacon_fastball_lob_end", "ptpov_beacon_fastball_lob_end", "pt_beacon_fastball_lob_end" )
		thread FastballToDishNagLines( player, bt )
		waitthread ScriptedTitanFastball( player, bt, titanNode, throwTarget )
		didInitialThrow = true

		// Wait for player to fall off, then rethrow
		while ( player.GetOrigin().z > 2700 )
			wait 0.25

		if ( Flag( "TargetingModuleReplaced" ) )
			break
	}

	Embark_Allow( player )
}



void function MusicOnFirstThrowToDish( entity player )
{
	WaitSignal( player.GetPetTitan(), "FastballStarting" )
	StopConversationNow( player )
	PlayMusic( "Music_Beacon_24_BTLob" )
}

void function SetObjectiveForInstallingModule()
{
	wait 4.0
	Objective_Set( "#BEACON_OBJECTIVE_INSTALL_TARGETING_MODULE", <0,0,0>, file.module2 )
}

void function ModuleBreadCrumbObjective( entity player, entity bt )
{
	Objective_Hide( player )
	WaitFrame()
	Objective_Set( "#BEACON_OBJECTIVE_FASTBALL1", < 0,0,1 > )
	Objective_SetFastball( bt )

	waitthread WaitForBTThrowOrDishClimb( bt )

	entity marker = Objective_GetMarkerEntity()
	marker.ClearParent()

	Objective_Hide( player )
	WaitFrame()
	Objective_SetSilent( "#BEACON_OBJECTIVE_INSTALL_TARGETING_MODULE", <0,0,0>, file.module2 )
}

void function WaitForBTThrowOrDishClimb( bt )
{
	if ( Flag( "DishClimbActive" ) )
		return

	FlagEnd( "DishClimbActive" )
	WaitSignal( bt, "FastballStarting" )
}

void function FastballToDishNagLines( entity player, entity bt )
{
	EndSignal( bt, "FastballStarting" )
	EndSignal( player, "OnDeath" )
	EndSignal( bt, "OnDeath" )
	EndSignal( level, "ReachedTopOfDish" )

	if ( Flag( "DishClimbActive" ) )
		return
	FlagEnd( "DishClimbActive" )

	while ( true )
	{
		wait 30

		if ( Flag( "ReachedTopOfDish" ) )
			break

		// Pilot, we must install the module. When you are ready, climb onto my hand.
		PlayDialogue( "BT_Nag_WhenReadyClimbIntoHand", bt )

		wait 30

		if ( Flag( "ReachedTopOfDish" ) )
			break

		// Standing by, Pilot. Climb onto my hand.
		PlayDialogue( "BT_Nag_StadingByClimbIntoHand", bt )
	}
}

void function PlayerFellOffDish( entity player )
{
	EndSignal( player, "DishSlide" )
	while ( player.GetOrigin().z > 2700 )
		WaitFrame()
	Signal( player, "DishSlideCancel" )
}

void function TargetingModuleReplaced( entity player )
{
	entity arms = GetEntByScriptName( "dish_arms2" )
	arms.Anim_Play( "open" )

	SetDishAngle( -20, 2.0 )
	wait 2.0
	SetDishAngle( -46, 1.0 )
	wait 0.8

	waitthread PlayerSlidesOffDish( player )

	wait 2.0

	PlayDialogue( "Mike_OutstandingWorkSir", player )

	// Go back to the control room
	Objective_Set( "#BEACON_OBJECTIVE_RETURN_TO_CONTROL_ROOM", GetEntByScriptName( "ControlRoomObjectiveLocation" ).GetOrigin() )

	wait 4.0

	PlayDialogue( "Richter_This_Is_Blisk", player )

	waitthread PlayDialogue( "Richter_On_My_Way", player )
}

void function PlayerSlidesOffDish( entity player)
{
	entity titan = player.GetPetTitan()
	Assert( IsValid( titan ) )

	entity titanNode = GetEntByScriptName( "DishFallBTNode" )
	Assert( IsValid( titanNode ) )

	entity ref = CreateOwnedScriptMover( titanNode )

	player.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDeath" )

	player.ContextAction_SetBusy()
	player.ForceStand()
	player.DisableWeapon()

	// Create a mover to play the slide animation on
	entity mover = CreateOwnedScriptMover( player )
	player.SetParent( mover, "ref", false, 0.0 )

	// Max slide time
	float maxSlideDuration = player.GetFirstPersonProxy().GetSequenceDuration( "ptpov_beacon_satellite_slide" )

	// Prop weapon
	entity weaponModel
	entity playerWeapon = player.GetActiveWeapon()
	if ( IsValid( playerWeapon ) )
	{
		asset weaponModelAsset = playerWeapon.GetWeaponInfoFileKeyFieldAsset( "playermodel" )
		entity fpProxy = player.GetFirstPersonProxy()
		int attachID = fpProxy.LookupAttachment( "PROPGUN" )
		weaponModel = CreatePropDynamic( weaponModelAsset, fpProxy.GetAttachmentOrigin( attachID ), fpProxy.GetAttachmentAngles( attachID ) )
		weaponModel.SetParent( player.GetFirstPersonProxy(), "PROPGUN", false, 0.0 )
	}

	table fallAnimStart = player.GetFirstPersonProxy().Anim_GetStartForRefEntity_Old( "ptpov_beacon_satellite_freefall", ref, "ref" )
	float slideDist = Distance( fallAnimStart.origin, mover.GetOrigin() )
	float slideDuration = DISH_SLIDE_DURATION//clamp( ( slideDist / 2600 ) * maxSlideDuration, 0.1, maxSlideDuration )
	//printt( "slideDuration:", slideDuration )
	float slideAccel = min( slideDuration * 0.5, 1.0 )
	float lerpIntoSlideAngleDuration = max( slideDuration * 0.25, 0.3 )
	vector slideAngle = < 45, 180, 0 >

	WaitFrame()

	// Play the slide anim
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.2//lerpIntoSlideAngleDuration
	sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_beacon_satellite_slide"
	sequence.thirdPersonAnim = "pt_beacon_satellite_slide"
	sequence.viewConeFunction = ViewConeTight

	thread FirstPersonSequence( sequence, player, mover )

	// Slide the player into place
	mover.NonPhysicsMoveTo( fallAnimStart.origin, slideDuration, slideAccel, 0.0 )

	// Rotate the player into slide angle first, then rotate them into fall anim angle
	mover.NonPhysicsRotateTo( slideAngle, lerpIntoSlideAngleDuration, 0.0, 0.0 )

	// Wait until the slide is over
	wait slideDuration

	BTCatchPlayerSequence( player, titan, ref, weaponModel )
}

void function BTCatchPlayerSequence( entity player, entity titan, entity ref, entity weaponModel )
{
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.0
	sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_beacon_satellite_freefall"
	sequence.thirdPersonAnim = "pt_beacon_satellite_freefall"
	sequence.viewConeFunction = ViewConeTight

	titan.ClearParent()
	thread PlayAnimTeleport( titan, "bt_beacon_satellite_catch", ref, "ref" )
	titan.Anim_AdvanceCycleEveryFrame( true )
	thread BeeeTeee( player )
	waitthread FirstPersonSequence( sequence, player, ref )

	player.EnableWeapon()
	player.UnforceStand()

	if ( IsValid( weaponModel ) )
		weaponModel.Destroy()

	ForceScriptedEmbark( player, titan )
	titan.Destroy()
}

void function BeeeTeee( entity player )
{
	EndSignal( player, "OnDeath" )
	wait 1.0
	PlayDialogue( "BEEEE_TEEEE", player )
}

void function SecondBeaconFirstFight()
{
	FlagWait( "SecondBeaconFirstAreaSpawn" )
	printt( "Start Second Beacon First Battle" )

	// Spawn the first group of grunts
	array<entity> spawners = GetEntArrayByScriptName( "SecondBeaconFirstAreaSoldierSpawner" )
	array<entity> grunts = SpawnFromSpawnerArray( spawners )

	// Wait for player to get inside the room or look at the door
	waitthread SecondBeaconFirstFightRetreat()

	thread SecondBeaconFirstFightDialogue( grunts )

	// Grunts close the door
	wait 1.0
	FlagClear( "SecondBeaconFirstAreaDoorOpen" )
	wait 1.0

	// Stalker racks activate
	array<entity> stalkerRackSpawners = GetEntArrayByScriptName( "SecondBeaconFirstAreaStalkerRack" )
	foreach ( spawner in stalkerRackSpawners )
	{
		thread SpawnFromStalkerRack( spawner )
	}

	wait 1.0

	array<entity> retreatNodes = GetEntArrayByScriptName( "SecondBeaconFirstAreaSoldierRetreatNode" )
	foreach( entity guy in grunts )
	{
		if ( !IsValid( guy ) || !IsAlive( guy ) )
			continue
		entity node = retreatNodes.getrandom()
		float radius = float( node.kv.script_goal_radius )
		guy.AssaultPoint( node.GetOrigin() )
		guy.AssaultSetGoalRadius( radius )
	}
}

void function SecondBeaconFirstFightDialogue( array<entity> grunts )
{
	SetGlobalForcedDialogueOnly( true )
	OnThreadEnd(
		function() : (  )
		{
			SetGlobalForcedDialogueOnly( false )
		}
	)
	wait 2.0

	ArrayRemoveDead( grunts )
	if ( grunts.len() > 0 )
	{
		entity speaker = grunts.getrandom()

		// Enemy Pilot! Fall back!
		PlayDialogue( "Grunt_FallBack", speaker )

		if ( IsAlive( speaker ) )
		{
			// Deploy the Stalkers!
			PlayDialogue( "Grunt_DeployStalkers", speaker )
		}
	}

	wait 5.0
}

void function SecondBeaconFirstFightRetreat()
{
	EndSignal( level, "SecondBeaconFirstAreaRetreat" )
	entity lookatEnt = GetEntByScriptName( "SecondBeaconFirstAreaRetreatLookat" )
	WaitTillLookingAt( GetPlayerArray()[0], lookatEnt, true, 30, 900, 30.0 )
}


void function DoubleCraneAlignmentCheckpoint()
{
	entity crane1 = GetEntByScriptName( "double_crane_1" )
	entity crane2 = GetEntByScriptName( "double_crane_2" )
	while ( true )
	{
		float yaw1 = crane1.GetAngles().y
		if ( yaw1 >= 105 && yaw1 <= 115 )
		{
			float yaw2 = crane2.GetAngles().y
			if ( yaw2 >= 10 && yaw2 <= 25 )
			{
				CheckPoint()
				return
			}
		}
		wait 1.0
	}
}

void function ZiplineBacktrack()
{
	//########################
	// Hide the zipline bases
	//########################

	array<entity> ziplineBase1 = GetEntArrayByScriptName( "zipline_base1" )
	array<entity> ziplineBase2 = GetEntArrayByScriptName( "zipline_base2" )
	foreach( entity ent in ziplineBase1 )
	{
		ent.Hide()
		ent.NotSolid()
	}
	foreach( entity ent in ziplineBase2 )
	{
		ent.Hide()
		ent.NotSolid()
	}

	FlagWait( "Spoke1End" )

	//########################
	// Show the zipline bases
	//########################

	foreach( entity ent in ziplineBase1 )
	{
		ent.Show()
		ent.Solid()
	}
	foreach( entity ent in ziplineBase2 )
	{
		ent.Show()
		ent.Solid()
	}

	//#####################
	// Create the ziplines
	//#####################

	entity ziplineStart1 = GetEntByScriptName( "zipline_start1" )
	entity ziplineEnd1 = ziplineStart1.GetLinkEnt()
	entity ziplineDetachNode1 = ziplineEnd1.GetLinkEnt()

	entity ziplineStart2 = GetEntByScriptName( "zipline_start2" )
	entity ziplineEnd2 = ziplineStart2.GetLinkEnt()
	entity ziplineDetachNode2 = ziplineEnd2.GetLinkEnt()

	float ziplineMoveSpeedScale = 0.75
	ZipLine zipline1 = CreateZipLine( ziplineStart1.GetOrigin(), ziplineEnd1.GetOrigin(), 1200, ziplineMoveSpeedScale )
	ZipLine zipline2 = CreateZipLine( ziplineStart2.GetOrigin(), ziplineEnd2.GetOrigin(), 250, ziplineMoveSpeedScale )

	array<entity> gruntSpawners = GetEntArrayByScriptName( "zipline_spawner" )

	//############################
	// Create some guys that will continually zipline down so the player sees them from below
	//############################

	thread CreateZipLineGuys( zipline1, ziplineDetachNode1, gruntSpawners[0], 4 )
	thread CreateZipLineGuys( zipline2, ziplineDetachNode2, gruntSpawners[1], 5 )

	//############################
	// Create some guys that will be left behind to fight the player
	//############################

	foreach( int i, entity spawner in gruntSpawners )
	{
		if ( i == 0 )
			continue
		entity guy = spawner.SpawnEntity()
		guy.kv.alwaysAlert = 1
		DispatchSpawn( guy )

		guy.AssaultPoint( guy.GetOrigin() )
		guy.AssaultSetGoalRadius( 1200 )

		AddTrackedHubFightEnemy( guy )
	}

	thread ZiplineGuyWaitsForPlayerToSeeHim( zipline1, ziplineDetachNode1, GetPlayerArray()[0], gruntSpawners[2] )
	thread ZiplineGuyWaitsForPlayerToSeeHim( zipline2, ziplineDetachNode2, GetPlayerArray()[0], gruntSpawners[1] )
	thread ZiplineWavingGuyWaitsForPlayerToSeeHim( GetPlayerArray()[0], gruntSpawners[0] )

	//############################
	// Play dialogue
	//############################

	entity dialogueLocation = GetEntByScriptName( "zipline_dialogue_location" )

	// Ziplines out! Go after the Titan!
	thread PlayDialogue( "Grunt_ZiplinesOut", dialogueLocation, 2.0 )

	// Hit the zipline, move move!
	thread PlayDialogue( "Grunt_MoveMove", dialogueLocation, 5.0 )
}

void function ZiplineWavingGuyWaitsForPlayerToSeeHim( entity player, entity spawner )
{
	// Spawn the guy
	entity guy = spawner.SpawnEntity()
	DispatchSpawn( guy )
	if ( !IsValid( guy ) )
		return
	EndSignal( guy, "OnDeath" )

	AddTrackedHubFightEnemy( guy )

	entity node = GetEntByScriptName( "zipline_waver_node" )

	// Idle
	if ( guy.IsInterruptable() )
		thread PlayAnimTeleport( guy, "pt_generic_commander_wave_short_C_idle", node )

	// Wait until the player can see the zipliner or hits the trigger because they are in the room
	waitthread WaitTillLookingAt( player, guy, true, 50, 0, 0, null, "PlayerNearZipliners" )
	FlagSet( "PlayerSeesZipliner" )

	// Do wave
	if ( guy.IsInterruptable() )
		thread PlayAnim( guy, "pt_generic_commander_wave_short_C", node )
}

void function ZiplineGuyWaitsForPlayerToSeeHim( ZipLine zipline, entity landingNode, entity player, entity spawner )
{
	// Spawn the guy
	entity guy = spawner.SpawnEntity()
	DispatchSpawn( guy )
	if ( !IsValid( guy ) )
		return
	AddTrackedHubFightEnemy( guy )

	// Get on zipline but wait to move down the line
	thread GuyDoZipline( zipline, landingNode, guy, true, "PlayerSeesZipliner" )

	// Wait until the player can see the zipliner or hits the trigger because they are in the room
	waitthread WaitTillLookingAt( player, guy, true, 50, 0, 0, null, "PlayerNearZipliners" )

	// Trigger the zipliner to move down the line
	FlagSet( "PlayerSeesZipliner" )
}

void function CreateZipLineGuys( ZipLine zipline, entity landingNode, entity spawner, int count )
{
	EndSignal( level, "PlayerNearZipliners" )

	for ( int i = 0 ; i < count ; i++ )
	{
		if ( Flag( "PlayerNearZipliners" ) )
			return
		if ( Flag( "PlayerNearZipliners" ) )
			return

		entity guy = spawner.SpawnEntity()
		DispatchSpawn( guy )
		if ( !IsValid( guy ) )
			continue

		AddTrackedHubFightEnemy( guy )

		thread GuyDoZipline( zipline, landingNode, guy, true )

		wait RandomFloatRange( 2.0, 3.5 )
	}
}

void function GuyDoZipline( ZipLine zipline, entity landingNode, entity guy, bool instantStart, string waitFlag = "" )
{
	string anim_attach = "pt_zipline_start"
	string anim_dismount = "pt_zipline_dismount_standF"
	string anim_sliding = "pt_zipline_slide_idle"

	// Calculate where to detach from the zipline for smooth transition to landing animation on the node
	vector landPos = landingNode.GetOrigin()
	vector landAng = FlattenAngles( VectorToAngles( zipline.end.GetOrigin() - zipline.start.GetOrigin() ) )
	//DebugDrawAngles( landPos, landAng )

	Attachment attachment = guy.Anim_GetAttachmentAtTime( anim_dismount, "L_HAND", 0.0 )
	vector originOffset = attachment.position - guy.GetOrigin()
	float angDiff = AngleDiff( guy.GetAngles().y, landAng.y )
	vector ziplineAnimEndPos = landPos + VectorRotate( originOffset, < 0, angDiff, 0 > )
	vector ziplineDetachPos = GetClosestPointOnLineSegment( zipline.start.GetOrigin(), zipline.end.GetOrigin(), ziplineAnimEndPos )
	//DebugDrawAngles( ziplineAnimEndPos, landAng, 30.0 )

	// Calculate where the guy attaches and starts the zipline
	vector ziplineStart = zipline.start.GetOrigin() + ( Normalize( zipline.end.GetOrigin() - zipline.start.GetOrigin() ) * 100 )
	//DebugDrawAngles( ziplineStart, landAng, 30.0 )

	// Create a mover to move the AI and midpoint down the path
	entity mover = CreateScriptMover( ziplineStart, < 0, 0, 0 > )
	Assert( IsValid( mover ) )

	EndSignal( guy, "OnDeath" )
	EndSignal( guy, "OnDestroy" )

	OnThreadEnd(
	function() : ( zipline, mover, guy, landPos, landAng, anim_dismount )
		{
			// Take the slack out of the zipline and destroy the mover
			thread ZiplineMoverDestroy( zipline, mover )

			// Guy does dismount animation
			if ( IsValid( guy ) )
			{
				guy.ClearParent()
				guy.SetNoTarget( false )
				guy.e.forceRagdollDeath = false
				guy.Anim_ScriptedPlayWithRefPoint( anim_dismount, landPos, landAng, 0.4 )
				if ( IsAlive( guy ) )
				{
					guy.SetHealth( guy.GetMaxHealth() )
					guy.AssaultPoint( landPos )
					guy.AssaultSetGoalRadius( 4000 )
				}
			}
		}
	)

	if ( !guy.IsInterruptable() )
		return

	// Get the AI to the attach point
	if ( !instantStart )
	{
		entity node = CreateScriptRef( ziplineStart, landAng )
		waitthread RunToAndPlayAnimAndWait( guy, anim_attach, node )
		node.Destroy()
	}

	//thread DrawLineFromEntToEntForTime( zipline.start, zipline.mid, 90.0 )
	//thread DrawLineFromEntToEntForTime( zipline.mid, zipline.end, 90.0 )
	zipline.mid.SetParent( mover, "", false )
	guy.SetParent( mover, "", false )
	guy.e.forceRagdollDeath = true
	guy.SetHealth( 1 )

	// AI shouldn't get shot by BT during zipline. This lets the player have the glory of doing it
	guy.SetNoTarget( true )

	// Figure out movement time based on zipline length
	float moveDuration = Distance( ziplineStart, ziplineDetachPos ) / 450
	float moveAccel = min( 3.0, moveDuration )

	// Guy does zipline idle and moves to position
	guy.Anim_ScriptedPlay( anim_sliding )

	if ( waitFlag != "" )
		FlagWait( waitFlag )

	mover.NonPhysicsMoveTo( ziplineDetachPos, moveDuration, moveAccel, 0.0 )

	// Wait until dismount time
	wait moveDuration
}

void function ZiplineMoverDestroy( ZipLine zipline, entity mover )
{
	if ( !IsValid( mover ) )
		return
	EndSignal( mover, "OnDestroy" )

	vector closestPoint = GetClosestPointOnLineSegment( zipline.start.GetOrigin(), zipline.end.GetOrigin(), mover.GetOrigin() )
	mover.NonPhysicsMoveTo( closestPoint, 0.4, 0.0, 0.0 )
	wait 0.4
	mover.SetOrigin( closestPoint )
	WaitFrame()
	zipline.mid.ClearParent()
	WaitFrame()
	mover.Destroy()
}

void function BTZiplineSequence( entity player )
{
	EndSignal( player, "OnDeath" )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	entity node = GetEntByScriptName( "ZiplineMomentNode" )
	Assert( IsValid( node ) )

	// Get BT to starting pos for zipline sequence
	thread RunToAnimStartForced_Deprecated( bt, "bt_beacon_zipline_fight", node )

	// Wait for player to be ziplining and within 6000 units of BT to make sure it's the right ziplines
	while ( true )
	{
		if ( player.IsZiplining() )// && Distance( player.GetOrigin(), node.GetOrigin() ) <= 6000 )
			break
		WaitFrame()
	}

	// Start the sequence
	entity stalker1 = CreateStalker( TEAM_IMC, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( stalker1 )
	entity stalker2 = CreateStalker( TEAM_IMC, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( stalker2 )
	thread PlayAnimTeleport( stalker1, "st_beacon_zipline_fight_01", node )
	thread PlayAnimTeleport( stalker2, "st_beacon_zipline_fight_02", node )
	thread PlayAnimTeleport( bt, "bt_beacon_zipline_fight", node )

	// Wait till player is back at the HUB
	FlagWait( "ReturnedToBeacon" )

	// Welcome back Cooper. Recommend we secure this area before proceeding with the repairs.
	thread PlayBTDialogue( "BT_WelcomeBackPilot" )
}

FirstPersonSequenceStruct function PlayerCustomDisembarkSequence( entity player, entity titan )
{
	FirstPersonSequenceStruct playerSequence
	playerSequence.blendTime = 0
	playerSequence.teleport = true
	playerSequence.attachment = "hijack"
	playerSequence.thirdPersonAnim = "pt_beacon_controlroom_a_disembark"
	playerSequence.firstPersonAnim = "ptpov_beacon_controlroom_a_disembark"
	playerSequence.useAnimatedRefAttachment = true

	return playerSequence
}

FirstPersonSequenceStruct function TitanCustomDisembarkSequence( entity player, entity titan )
{
	string animation = "bt_beacon_controlroom_a_disembark"
	entity controlRoomNode = GetEntByScriptName( "control_room_node" )

	FirstPersonSequenceStruct titanSequence
	titanSequence.blendTime = 1.0
	titanSequence.thirdPersonAnim = animation
	titanSequence.gravity = true
	titanSequence.origin = controlRoomNode.GetOrigin()
	titanSequence.angles = controlRoomNode.GetAngles()

	return titanSequence
}

void function OpenShutters( bool instant = false )
{
	entity shutters = GetEntByScriptName( "BeaconBunkerShutters" )
	if ( instant )
		shutters.Anim_Play( "open_pose" )
	else
		shutters.Anim_Play( "open" )
	FlagSet( "ControlRoomWindowsOpen" )
}

void function CloseShutters( bool instant = false )
{
	entity shutters = GetEntByScriptName( "BeaconBunkerShutters" )
	if ( instant )
		shutters.Anim_Play( "closed_pose" )
	else
		shutters.Anim_Play( "close" )
}

void function ControlRoomScreensPowerOn()
{
	array<entity> screens = GetEntArrayByScriptName( "ControlRoomScreen" )
	screens.extend( GetEntArrayByScriptName( "ControlRoomScreenLeftUpper" ) )
	screens.extend( GetEntArrayByScriptName( "ControlRoomScreenLeft" ) )
	screens.extend( GetEntArrayByScriptName( "ControlRoomScreenRightUpper" ) )
	screens.extend( GetEntArrayByScriptName( "ControlRoomScreenRight" ) )

	foreach( entity screen in screens )
	{
		wait RandomFloatRange( 0.4, 0.8 )
		thread ControlRoomScreenFlickerOn( screen )
	}
}

void function ControlRoomScreenFlickerOn( entity screen )
{
	asset modelOff = screen.GetModelName()
	asset modelOn
	switch( modelOff )
	{
		case SCREEN_MODEL_01_OFF:
			modelOn = SCREEN_MODEL_01_ON
			break
		case SCREEN_MODEL_02_OFF:
			modelOn = SCREEN_MODEL_02_ON
			break
	}

	if ( screen.GetScriptName() == "ControlRoomScreenLeftUpper" )
	{
		FlagSet( "fx_beacon_consoleLight_left" )
		if ( GetCurrentStartPoint() != "Send Signal" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, screen.GetOrigin(), "bt_beacon_controlroom_left_screens_flicker_on" )
		EmitSoundAtPosition( TEAM_UNASSIGNED, screen.GetOrigin(), "amb_emit_Beacon_Computer_Screen" )
	}
	else if ( screen.GetScriptName() == "ControlRoomScreenRightUpper" )
	{
		FlagSet( "fx_beacon_consoleLight_right" )
		EmitSoundAtPosition( TEAM_UNASSIGNED, screen.GetOrigin(), "bt_beacon_controlroom_right_screens_flicker_on" )
		EmitSoundAtPosition( TEAM_UNASSIGNED, screen.GetOrigin(), "amb_emit_Beacon_Computer_Screen" )
	}

	int flickers = RandomIntRangeInclusive( 2, 4 )
	for ( int i = 0 ; i < flickers ; i++ )
	{
		// On
		screen.SetModel( modelOn )

		wait RandomFloatRange( 0.05, 0.1 )

		// Off
		screen.SetModel( modelOff )

		wait RandomFloatRange( 0.05, 0.2 )
	}

	// On
	screen.SetModel( modelOn )
}

void function ModuleAnimSequence2()
{
	// Put a modeule in the slot
	entity arms = GetEntByScriptName( "dish_arms2" )
	file.module2 = CreatePropDynamic( UPLINK_MODULE_MODEL )
	file.module2.SetParent( arms, "ATTACH_MODULE", false )
	Objective_InitEntity( file.module2 )

	// Wait until we are at the right point of the level, otherwise a player may find their way up there at the start and activate it before completing the rest of the level
	FlagWait( "Module2CanBeReplaced" )

	// Fix button prompt
	wait 0.5
	entity button = GetEntByScriptName( "dish_objective_button" )
	button.SetUsePrompts( "#BEACON_INSTALL_MODULE_HOLD_TO_USE" , "#BEACON_INSTALL_MODULE_PRESS_TO_USE" )

	// Wait for button press
	FlagWait( "TargetingModuleReplaced" )

	// Turns off the quick death triggers around the dish
	FlagClear( "DishClimbActive" )
	FlagClear( "ThrownToDish" )

	file.satelliteDishHatch.Show()
	file.satelliteDishHatch.Solid()
	//GetEntByScriptName( "dishclimb_quickdeath_trigger" ).Destroy()
	//GetEntByScriptName( "climb_dish_active_flag_trigger" ).Destroy()

	// Get the player
	entity player = GetPlayerArray()[0]
	Assert( IsValid ( player ) )
	EndSignal( player, "OnDeath" )

	// Spawn a mover to do anim on
	entity mover = CreateOwnedScriptMover( arms )
	WaitFrame()
	mover.SetParent( arms, "ref", false )

	// Create sequence
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.2
	sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_beacon_dish_module_02"
	sequence.thirdPersonAnim = "pt_beacon_dish_module_02"
	sequence.viewConeFunction = ViewConeTight

	// Do the anim
	player.DisableWeapon()
	player.ContextAction_SetBusy()
	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.Anim_Stop()
				player.ClearParent()
				ClearPlayerAnimViewEntity( player )
				if ( player.ContextAction_IsBusy() )
					player.ContextAction_ClearBusy()
				player.EnableWeapon()
			}
		}
	)
	arms.Anim_Play( "beacon_dish_module_02" )

	StopMusicTrack( "Music_Beacon_25_ClimbToTheDish" )
	PlayMusic( "Music_Beacon_26_ActivateDishStingerToFallCatch" )

	waitthread FirstPersonSequence( sequence, player, arms )

	FlagSet( "ModuleAnimSequence2Done" )
}

void function ModuleAnimSequence1()
{
	// Spawn the arms model and link everything to move together
	entity dishModel = GetEntByScriptName( "hanging_dish_static_model" )
	entity dish = GetEntByScriptName( "dish_on_crane" )
	entity arms = CreatePropDynamic( DISH_ARMS_MODEL, null, null, 6, 99999 )
	arms.SetParent( dish, "", false )

	// Mark as pusher since this crane doesn't do it automatically
	dishModel.SetPusher( true )
	arms.SetPusher( true )

	// One of the arms is missing on this dish
	int bodyGroupIndex = arms.FindBodyGroup( "leg3" )
	arms.SetBodygroup( bodyGroupIndex, 1 )

	// Arms start out
	arms.Anim_Play( "open_v2" )

	// Put a modeule in the slot
	file.module1 = CreatePropDynamic( UPLINK_MODULE_MODEL )
	file.module1.SetParent( arms, "ATTACH_MODULE", false )
	Objective_InitEntity( file.module1 )

	// Setup button
	int attachmentID = arms.LookupAttachment( "ATTACH_MODULE" )
	vector origin = arms.GetAttachmentOrigin( attachmentID ) + <0,0,16>
	vector angles = arms.GetAttachmentAngles( attachmentID )

	entity button = GetEntByScriptName( "satellite_platform_button" )
	button.SetOrigin( origin )
	button.SetAngles( angles )
	button.SetParent( arms, "ATTACH_MODULE", true ) // keep offset
	button.Hide()
	button.SetUsePrompts( "#BEACON_REMOVE_MODULE_HOLD_TO_USE" , "#BEACON_REMOVE_MODULE_PRESS_TO_USE" )
	button.SetUsableRadius( 32 )
	Entity_StopFXArray( button )

	// Wait for button press
	FlagWait( "satellite_panelboard1" )

	// Get the player
	entity player = GetPlayerArray()[0]
	Assert( IsValid ( player ) )
	EndSignal( player, "OnDeath" )

	// Spawn a mover to do anim on
	entity mover = CreateOwnedScriptMover( arms )
	mover.SetParent( arms, "ref", false )

	// Create sequence
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.2
	sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_beacon_dish_module_01"
	sequence.thirdPersonAnim = "pt_beacon_dish_module_01"
	sequence.viewConeFunction = ViewConeTight

	thread RemoveModuleMusicStinger()

	// Do the anim
	player.DisableWeapon()
	player.ContextAction_SetBusy()
	arms.Anim_Play( "beacon_dish_module_01" )
	waitthread FirstPersonSequence( sequence, player, arms )

	if ( IsValid( file.module1 ) )
		file.module1.Destroy()

	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.EnableWeapon()

	FlagSet( "ModuleAnimSequence1Done" )

	GetEntByScriptName( "ModuleBlocker" ).NotSolid()

	wait 0.5

	// Arms move in
	arms.Anim_Play( "close_v2" )
}

void function RemoveModuleMusicStinger()
{
	wait 5.0
	PlayMusic( "Music_Beacon_20_RemoveModuleStinger" )
}

void function GhostRecorderCallback_WallrunPanels( entity ghost, entity weapon )
{
	EndSignal( ghost, "OnDestroy" )

	weapon.Destroy()

	entity arcTool = CreatePropScript( ARC_TOOL_GHOST_WORLD_MODEL )
	arcTool.kv.skin = 1
	arcTool.kv.rendercolor = "94 174 255" //Blue
	arcTool.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	arcTool.SetOwner( ghost )
	arcTool.SetParent( ghost, "PROPGUN", false )

	entity target
	string flag

	while( IsValid( ghost ) )
	{
		table results = WaitSignal( ghost, "animRecordingSignal" )

		if ( results.value == "shoot_arc_switch1" )
		{
			flag = "panel1"
			target = GetEntByScriptName( "arc_switch_panel1" )
		}
		else if ( results.value == "shoot_arc_switch2" )
		{
			flag = "panel2"
			target = GetEntByScriptName( "arc_switch_panel2" )
		}
		else if ( results.value == "shoot_arc_switch3" )
		{
			flag = "panel3"
			target = GetEntByScriptName( "arc_switch_panel3" )
		}
		else if ( results.value == "shoot_arc_switch4" )
		{
			flag = "panel4"
			target = GetEntByScriptName( "arc_switch_panel4" )
		}
		else if ( results.value == "shoot_arc_switch5" )
		{
			flag = "panel5"
			target = GetEntByScriptName( "arc_switch_panel5" )
		}
		else if ( results.value == "shoot_arc_switch6" )
		{
			flag = "panel6"
			target = GetEntByScriptName( "arc_switch_panel6" )
		}
		else if ( results.value == "shoot_arc_switch7" )
		{
			flag = "panel7"
			target = GetEntByScriptName( "arc_switch_panel7" )
		}
		else
		{
			continue
		}

		if ( !Flag( flag ) )
			thread GhostFireArcToolAtEntity( ghost, arcTool, target )
	}
}