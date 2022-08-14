
global function AssemblyMapInit
global function Assembly_EntitiesDidLoad
global function StartPoint_Start
global function StartPoint_Setup_Start
global function StartPoint_Skipped_Start
global function StartPoint_Assembly_Start
global function StartPoint_Setup_Assembly_Start
global function StartPoint_Skipped_Assembly_Start
global function StartPoint_Assembly_Dirt
global function StartPoint_Setup_Assembly_Dirt
global function StartPoint_Skipped_Assembly_Dirt
global function StartPoint_Assembly_Wallrun
global function StartPoint_Setup_Assembly_Wallrun
global function StartPoint_Skipped_Assembly_Wallrun
global function StartPoint_Assembly_Furniture
global function StartPoint_Setup_Assembly_Furniture
global function StartPoint_Skipped_Assembly_Furniture
global function StartPoint_Assembly_Walls
global function StartPoint_Setup_Assembly_Walls
global function StartPoint_Skipped_Assembly_Walls
global function StartPoint_Highway
global function StartPoint_Setup_Highway
global function StartPoint_Skipped_Highway
global function StartPoint_TownClimbEntry
global function StartPoint_Setup_TownClimbEntry
global function StartPoint_Skipped_TownClimbEntry

global function TunnelCrossTracks

const asset SKY_PANEL  = $"models/kodai_live_fire/fs_modular_single_01_opti.mdl"

const RAIL_MODEL_PROPS = $"models/boomtown/wf_platform_3_rail.mdl"
const RAIL_MODEL_WALLS_A = $"models/boomtown/wf_platform_4_rail_1.mdl"
const RAIL_MODEL_WALLS_B = $"models/boomtown/wf_platform_4_rail_2.mdl"
const RAIL_MODEL_WALLS_C = $"models/boomtown/wf_platform_4_rail_3.mdl"
const RAIL_MODEL_WALLS_D = $"models/boomtown/wf_platform_4_rail_4.mdl"

const PHYS_FALL_MODEL1 = $"models/containers/barrel.mdl"
const PHYS_FALL_MODEL2 = $"models/containers/pelican_case_large.mdl"
const PHYS_FALL_MODEL3 = $"models/IMC_base/cargo_container_imc_01_white.mdl"
const PHYS_FALL_MODEL4 = $"models/IMC_base/cargo_container_imc_01_blue.mdl"

const GRASS_GRINDER_EFFECT = $"P_assembly_tiller_dirt"
const DIRT_PRESS_EFFECT = $"P_assembly_stamp_dirt"
const PLATFORM_TRACK_SPEED = 200.0
const NUM_ARMS_FIRST_HANDOFF = 3

const LASER_SCANNER_EFFECT = $"P_assembly_uv_scanner"
const DUST_TRAIL_EFFECT = $"assembly_stamp_dust_trailing"
const SANITIZATION_EFFECT = $"assembly_sanitization_chamber"
const FLOOR_DOOR_OPEN_EFFECT = $"assembly_sanitization_chamber"

const HIGHWAY_ROLLER_SEPARATE_DIST = 48.0
const HIGHWAY_ROLLER_SEPARATE_TIME = 2.0
const HIGHWAY_ROLLERS_SHUFFLE_SPEED = 30.0

const DOME_BATTLE_SOUND_POS = < -9568, -2624, 6368 >

const TOWN_DISASSEMBLE_DIRT_EFFECT = $"P_assembly_rtown_dirt"

struct
{
	Point platform_track_slide_end
	Point platform_track_start
	Point platform_dirt_press_bottom
	Point platform_dirt_press_top
	Point platform_grass_plant_start
	Point platform_grass_plant_end
	Point platform_foundation_press_bottom
	Point platform_foundation_press_top
	Point platform_foundation_track_start
	Point platform_foundation_track_end
	Point platform_framing_insert_start
	Point platform_framing_insert_end
	Point platform_framing_insert_down
	Point platform_framing_lowered
	Point platform_framing_track_start
	Point platform_framing_stop1
	Point platform_framing_stop2
	Point platform_framing_track_end
	Point platform_framing_track_end_up
	Point platform_framing_track_end_outfeed

	vector platform_framing_door1_openedPos
	vector platform_framing_door1_closedPos
	vector platform_framing_door2_openedPos
	vector platform_framing_door2_closedPos

	entity dirtPressMover
	entity grassGrinder
	entity foundationPressMover
	entity laserScanner
	entity laserScannerMover
	entity laserScannerEffect
	entity framingPressMover
	entity platform_framing_door_1
	entity platform_framing_door_2

	PlatformArm &firstHandoffArm
	Platform &firstHandoffPlatform
	Platform &secondHandoffPlatform
	Platform &thirdHandoffPlatform
	Platform &fourthHandoffPlatform
	Platform &playerTownClimbPlatform

	PlatformArm &framingStop1Arm1
	PlatformArm &framingStop1Arm2
	PlatformArm &framingStop1Arm3
	entity framingStop1Rail
	PlatformArm &framingStop2Arm1
	PlatformArm &framingStop2Arm2
	PlatformArm &framingStop2Arm3
	entity framingStop2Rail
	PlatformArm &wallsStop1Arm1
	PlatformArm &wallsStop1Arm2
	PlatformArm &wallsStop1Arm3
	PlatformArm &wallsStop2Arm1
	PlatformArm &wallsStop2Arm2
	PlatformArm &wallsStop2Arm3
	PlatformArm &wallsStop3Arm1
	PlatformArm &wallsStop3Arm2
	PlatformArm &wallsStop3Arm3
	PlatformArm &wallsStop4Arm1
	PlatformArm &wallsStop4Arm2
	PlatformArm &wallsStop4Arm3
	entity wallsStop1Rail
	entity wallsStop2Rail
	entity wallsStop3Rail
	entity wallsStop4Rail

	entity node_enter
	entity node_elbow
	entity node_junction1A
	entity node_junction1B
	entity node_junction2A
	entity node_junction2B

	table<entity,int> switchTrackLastIndex
	bool townClimbEntryStarted
} file



void function AssemblyMapInit()
{
	AssemblyArmsInit()

	PrecacheModel( SKY_PANEL )
	PrecacheModel( ARM_MODEL )
	PrecacheModel( ARM_MODEL_SMALL )
	PrecacheModel( ARM_MODEL_SMALL_ANIMATED )
	PrecacheModel( ARM_MODEL_SKYBOX )
	PrecacheModel( ARM_MODEL_AMBIENT_1 )
	PrecacheModel( ARM_MODEL_AMBIENT_2 )
	PrecacheModel( PLATFORM_MODEL_AMBIENT_1 )
	PrecacheModel( PLATFORM_MODEL_AMBIENT_2 )
	PrecacheModel( PLATFORM_MODEL_FRAMING_SKYBOX )
	PrecacheModel( PLATFORM_MODEL_WALLS_SKYBOX )
	PrecacheModel( PLATFORM_MODEL_DIRT )
	PrecacheModel( PLATFORM_MODEL_DIRT_SKYBOX )
	PrecacheModel( PLATFORM_MODEL_FOUNDATION )
	PrecacheModel( PLATFORM_MODEL_FRAMING )
	PrecacheModel( PLATFORM_MODEL_WALLS )
	PrecacheModel( PLATFORM_MODEL_WALLS_RIGID )
	PrecacheModel( RAIL_MODEL_PROPS )
	PrecacheModel( RAIL_MODEL_WALLS_A )
	PrecacheModel( RAIL_MODEL_WALLS_B )
	PrecacheModel( RAIL_MODEL_WALLS_C )
	PrecacheModel( RAIL_MODEL_WALLS_D )
	PrecacheModel( PHYS_FALL_MODEL1 )
	PrecacheModel( PHYS_FALL_MODEL2 )
	PrecacheModel( PHYS_FALL_MODEL3 )
	PrecacheModel( PHYS_FALL_MODEL4 )

	PrecacheParticleSystem( GRASS_GRINDER_EFFECT )
	PrecacheParticleSystem( DIRT_PRESS_EFFECT )
	PrecacheParticleSystem( LASER_SCANNER_EFFECT )
	PrecacheParticleSystem( DUST_TRAIL_EFFECT )
	PrecacheParticleSystem( SANITIZATION_EFFECT )
	PrecacheParticleSystem( TOWN_DISASSEMBLE_DIRT_EFFECT )

	RegisterSignal( "FirstSectionPreHandoff" )
	RegisterSignal( "FirstSectionHandoff" )
	RegisterSignal( "FoundationPlatformReadyForPickup" )
	RegisterSignal( "HandoffComplete" )
	RegisterSignal( "FramedPlatformReadyForPickup" )
	RegisterSignal( "WallAssemblyHandoffReady" )
	RegisterSignal( "WallAssemblyHandoffComplete" )
	RegisterSignal( "StopUpdatingArmAndPlatformPushers" )
	RegisterSignal( "GhostRecorderFirstPlatformGo" )
	RegisterSignal( "GhostRecorderDirtPlatformGo" )
	RegisterSignal( "GhostRecorderReapertownJumpGo" )
	RegisterSignal( "ReapertownStarting" )
	RegisterSignal( "ArmInstallRumble" )

	FlagInit( "TownClimbArmStart" )
	FlagInit( "TownClimbRowsStartAssemble" )
	FlagInit( "TownClimbPlatformReadyToGrab" )
	FlagInit( "TownClimbPlatformTransfered" )
	FlagInit( "BoomtownDisassemble" )
	FlagInit( "TownClimbArm1PositionForClimb" )
	FlagInit( "ReaperTownRaisedUp" )
	FlagInit( "PlayerEnteringTownClimb" )
	FlagInit( "TownClimbBegin" )
	FlagInit( "AmbientPlatformsStartEnabled" )
	FlagInit( "AmbientPlatformsAboveGrassEnabled" )
	FlagInit( "AmbientPlatformsWallsStartEnabled" )
	FlagInit( "AmbientPlatformsTownClimbEntranceEnabled" )
	FlagInit( "TownClimbGeoMovingUp" )
	FlagInit( "TalkingGruntsFinished" )
	FlagInit( "ReapertownPlatforJumpMobilityGhostEnabled" )
	//FlagInit( "EnteringAssembly" )

	AddMobilityGhost( $"anim_recording/sp_boomtown_pipe_jump1.rpak" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_pipe_jump2.rpak" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_pipe_jump3.rpak" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_wallrun_to_assembly.rpak" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_assembly_platform_jump.rpak", "", "GhostRecorderFirstPlatformGo" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_grass_ride.rpak", "", "GhostRecorderDirtPlatformGo" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_town_climb_house1.rpak", "TownClimbBegin" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_town_climb_house2.rpak", "TownClimbBegin" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_town_climb_roof.rpak", "TownClimbBegin" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_town_climb_arms1.rpak", "TownClimbBegin" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_town_climb_arms2.rpak", "TownClimbBegin" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_town_climb_end1.rpak", "TownClimbBegin" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_town_climb_end2.rpak", "TownClimbBegin" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_reapertown_jump.rpak", "ReapertownPlatforJumpMobilityGhostEnabled", "GhostRecorderReapertownJumpGo" )
}

void function Assembly_EntitiesDidLoad()
{
	// Template pieces placed in leveled for reference
	entity marker = GetEntByScriptName( "platform_track_slide_end" )
	file.platform_track_slide_end.origin = marker.GetOrigin()
	file.platform_track_slide_end.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_track_start" )
	file.platform_track_start.origin = marker.GetOrigin()
	file.platform_track_start.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_dirt_press_bottom" )
	file.platform_dirt_press_bottom.origin = marker.GetOrigin()
	file.platform_dirt_press_bottom.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_dirt_press_top" )
	file.platform_dirt_press_top.origin = marker.GetOrigin()
	file.platform_dirt_press_top.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_grass_plant_start" )
	file.platform_grass_plant_start.origin = marker.GetOrigin()
	file.platform_grass_plant_start.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_grass_plant_end" )
	file.platform_grass_plant_end.origin = marker.GetOrigin()
	file.platform_grass_plant_end.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_foundation_press_bottom" )
	file.platform_foundation_press_bottom.origin = marker.GetOrigin()
	file.platform_foundation_press_bottom.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_foundation_press_top" )
	file.platform_foundation_press_top.origin = marker.GetOrigin()
	file.platform_foundation_press_top.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_foundation_track_start" )
	file.platform_foundation_track_start.origin = marker.GetOrigin()
	file.platform_foundation_track_start.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_foundation_track_end" )
	file.platform_foundation_track_end.origin = marker.GetOrigin()
	file.platform_foundation_track_end.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_insert_start" )
	file.platform_framing_insert_start.origin = marker.GetOrigin()
	file.platform_framing_insert_start.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_insert_end" )
	file.platform_framing_insert_end.origin = marker.GetOrigin()
	file.platform_framing_insert_end.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_insert_down" )
	file.platform_framing_insert_down.origin = marker.GetOrigin()
	file.platform_framing_insert_down.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_lowered" )
	file.platform_framing_lowered.origin = marker.GetOrigin()
	file.platform_framing_lowered.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_track_start" )
	file.platform_framing_track_start.origin = marker.GetOrigin()
	file.platform_framing_track_start.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_stop1" )
	file.platform_framing_stop1.origin = marker.GetOrigin()
	file.platform_framing_stop1.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_stop2" )
	file.platform_framing_stop2.origin = marker.GetOrigin()
	file.platform_framing_stop2.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_track_end" )
	file.platform_framing_track_end.origin = marker.GetOrigin()
	file.platform_framing_track_end.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_track_end_up" )
	file.platform_framing_track_end_up.origin = marker.GetOrigin()
	file.platform_framing_track_end_up.angles = marker.GetAngles()
	marker.Destroy()

	marker = GetEntByScriptName( "platform_framing_track_end_outfeed" )
	file.platform_framing_track_end_outfeed.origin = marker.GetOrigin()
	file.platform_framing_track_end_outfeed.angles = marker.GetAngles()
	marker.Destroy()

	// Piston movers
	file.dirtPressMover = CreateScriptMover( file.platform_dirt_press_bottom.origin )
	file.dirtPressMover.SetPusher( true )
	AddCleanupEnt( file.dirtPressMover )
	array<entity> pistons = GetEntArrayByScriptName( "dirt_press_piston" )
	foreach( entity piston in pistons )
		piston.SetParent( file.dirtPressMover, "", true )

	file.foundationPressMover = CreateScriptMover( file.platform_foundation_press_bottom.origin )
	file.foundationPressMover.SetPusher( true )
	AddCleanupEnt( file.foundationPressMover )
	entity piston = GetEntByScriptName( "foundation_press_piston" )
	piston.SetParent( file.foundationPressMover, "", true )

	file.framingPressMover = CreateScriptMover( file.platform_framing_track_end.origin )
	file.framingPressMover.SetPusher( true )
	AddCleanupEnt( file.framingPressMover )
	piston = GetEntByScriptName( "framing_press_piston" )
	piston.SetParent( file.framingPressMover, "", true )

	// Geass Grinder rotator
	file.grassGrinder = GetEntByScriptName( "grass_grinder" )
	AddCleanupEnt( file.grassGrinder )
	file.grassGrinder.NonPhysicsRotate( file.grassGrinder.GetRightVector() * -1, 500.0 )

	// Framing section doors
	entity door1 = GetEntByScriptName( "platform_framing_door_1" )
	file.platform_framing_door_1 = CreateOwnedScriptMover( door1 )
	AddCleanupEnt( file.platform_framing_door_1 )
	door1.SetParent( file.platform_framing_door_1, "", true )
	file.platform_framing_door_1.SetPusher( true )
	file.platform_framing_door1_openedPos = door1.GetOrigin() - <0,256,0>
	file.platform_framing_door1_closedPos = door1.GetOrigin()

	entity door2 = GetEntByScriptName( "platform_framing_door_2" )
	file.platform_framing_door_2 = CreateOwnedScriptMover( door2 )
	AddCleanupEnt( file.platform_framing_door_2 )
	door2.SetParent( file.platform_framing_door_2, "", true )
	file.platform_framing_door_2.SetPusher( true )
	file.platform_framing_door2_openedPos = door2.GetOrigin() + <0,256,0>
	file.platform_framing_door2_closedPos = door2.GetOrigin()

	file.framingStop1Arm1 = CreateArm( ARM_MODEL_SMALL_ANIMATED, file.platform_framing_stop1.origin, file.platform_framing_stop1.angles, true, false )
	file.framingStop1Arm2 = CreateArm( ARM_MODEL_SMALL_ANIMATED, file.platform_framing_stop1.origin, file.platform_framing_stop1.angles, true, false )
	file.framingStop1Arm3 = CreateArm( ARM_MODEL_SMALL_ANIMATED, file.platform_framing_stop1.origin, file.platform_framing_stop1.angles, true, false )
	file.framingStop1Rail = CreatePropDynamic( RAIL_MODEL_PROPS, file.platform_framing_stop1.origin, file.platform_framing_stop1.angles, SOLID_VPHYSICS )

	array<string> railParts = [
		"rail_1_prop_1",
		"rail_1_prop_5",
		"rail_2_prop_1",
		"rail_2_prop_5",
		"rail_3_prop_6",
		"rail_4_prop_6",
		"rail_3_prop_1",
		"rail_3_prop_5",
		"rail_4_prop_1",
		"rail_4_prop_5"
	]
	// off is on, and on is off for rails
	TurnOnParts( file.framingStop1Rail, railParts )

	railParts = [
		"rail_1_prop_2",
		"rail_1_prop_4",
		"rail_2_prop_2",
		"rail_2_prop_4",
		"rail_3_prop_3",
		"rail_4_prop_3",
		"rail_3_prop_2",
		"rail_3_prop_4",
		"rail_4_prop_2",
		"rail_4_prop_4",
	]
	// off is on, and on is off for rails
	TurnOffParts( file.framingStop1Rail, railParts )

	AddCleanupEnt( file.framingStop1Rail )

	file.framingStop2Arm1 = CreateArm( ARM_MODEL_SMALL_ANIMATED, file.platform_framing_stop2.origin, file.platform_framing_stop2.angles, true, false )
	file.framingStop2Arm2 = CreateArm( ARM_MODEL_SMALL_ANIMATED, file.platform_framing_stop2.origin, file.platform_framing_stop2.angles, true, false )
	file.framingStop2Arm3 = CreateArm( ARM_MODEL_SMALL_ANIMATED, file.platform_framing_stop2.origin, file.platform_framing_stop2.angles, true, false )
	file.framingStop2Rail = CreatePropDynamic( RAIL_MODEL_PROPS, file.platform_framing_stop2.origin, file.platform_framing_stop2.angles, SOLID_VPHYSICS )

	railParts = [
		"rail_1_prop_1",
		"rail_1_prop_5",
		"rail_2_prop_1",
		"rail_2_prop_5",
		"rail_3_prop_6",
		"rail_4_prop_6",
		"rail_3_prop_1",
		"rail_3_prop_5",
		"rail_4_prop_1",
		"rail_4_prop_5"
	]
	// off is on, and on is off for rails
	TurnOffParts( file.framingStop2Rail, railParts )

	railParts = [
		"rail_1_prop_2",
		"rail_1_prop_4",
		"rail_2_prop_2",
		"rail_2_prop_4",
		"rail_3_prop_3",
		"rail_4_prop_3",
		"rail_3_prop_2",
		"rail_3_prop_4",
		"rail_4_prop_2",
		"rail_4_prop_4",
	]
	// off is on, and on is off for rails
	TurnOnParts( file.framingStop2Rail, railParts )

	AddCleanupEnt( file.framingStop2Rail )

	entity node = GetEntByScriptName( "anim_node_walls1" )
	file.wallsStop1Arm1 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop1Arm2 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop1Arm3 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop1Rail = CreatePropDynamic( RAIL_MODEL_WALLS_A, node.GetOrigin(), node.GetAngles(), SOLID_VPHYSICS )
	AddCleanupEnt( file.wallsStop1Rail )

	node = GetEntByScriptName( "anim_node_walls2" )
	file.wallsStop2Arm1 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop2Arm2 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop2Arm3 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop2Rail = CreatePropDynamic( RAIL_MODEL_WALLS_B, node.GetOrigin(), node.GetAngles(), SOLID_VPHYSICS )
	AddCleanupEnt( file.wallsStop2Rail )

	node = GetEntByScriptName( "anim_node_walls3" )
	file.wallsStop3Arm1 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop3Arm2 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop3Arm3 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop3Rail = CreatePropDynamic( RAIL_MODEL_WALLS_C, node.GetOrigin(), node.GetAngles(), SOLID_VPHYSICS )
	AddCleanupEnt( file.wallsStop3Rail )

	node = GetEntByScriptName( "anim_node_walls4" )
	file.wallsStop4Arm1 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop4Arm2 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop4Arm3 = CreateArm( ARM_MODEL_SMALL_ANIMATED, node.GetOrigin(), node.GetAngles(), true, false )
	file.wallsStop4Rail = CreatePropDynamic( RAIL_MODEL_WALLS_D, node.GetOrigin(), node.GetAngles(), SOLID_VPHYSICS )
	AddCleanupEnt( file.wallsStop4Rail )

	GetEntByScriptName( "vista_wf_highway" ).DisableHibernation()
	GetEntByScriptName( "vista_start_wf_right" ).DisableHibernation()

	thread TownClimbCompletedWait()
}

void function StartPointPrint( entity player, string name )
{
	printt( "##################" )
	printt( "Start Point: " + name )
	//Dev_PrintMessage( player, "Start Point: " + name )
	printt( "##################" )
}

//	███████╗████████╗ █████╗ ██████╗ ████████╗
//	██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
//	███████╗   ██║   ███████║██████╔╝   ██║
//	╚════██║   ██║   ██╔══██║██╔══██╗   ██║
//	███████║   ██║   ██║  ██║██║  ██║   ██║
//	╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

void function StartPoint_Start( entity player )
{
	StartPointPrint( player, "Start" )

	Objective_Set( "#BOOMTOWN_OBJECTIVE_LOCATE_BT" )
	PlayMusic( "music_boomtown_09_middleintro" )

	thread BTCarriedAway( player )
	thread IntroDialogue( player )
	thread IntroElevator( player )
	thread TalkingGrunts( player )
	thread BTAssemblyLineDialogue( player )
	thread VentSounds( player )
	thread BTAlrightConversation( player )

	GetEntByScriptName( "vista_wf_highway" ).Hide()

	FlagWait( "EnteringAssembly" )
}

void function StartPoint_Setup_Start( entity player )
{
	FactoryStart( player )
}

void function StartPoint_Skipped_Start( entity player )
{
	Objective_Set( "#BOOMTOWN_OBJECTIVE_LOCATE_BT" )
}

void function IntroElevator( entity player )
{
	entity bottom = GetEntByScriptName( "ElevatorBottom" )
	entity mover = GetEntByScriptName( "ElevatorMover" )

	wait 1.0

	float rumbleAmplitude = 100.0
	float rumbleFrequency = 150
	float rumbleDuration = 12.0
	entity rumbleHandle = CreateShakeRumbleOnly( mover.GetOrigin(), rumbleAmplitude, rumbleFrequency, rumbleDuration )
	rumbleHandle.SetParent( mover, "", false )

	mover.NonPhysicsMoveTo( bottom.GetOrigin(), 10.0, 0.0, 2.0 )
	EmitSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorMove" )
	wait 8.0
	EmitSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorStop" )
	wait 2.0
	StopSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorMove" )

	rumbleAmplitude = 300.0
	rumbleFrequency = 60
	rumbleDuration = 1.0
	CreateShakeRumbleOnly( mover.GetOrigin(), rumbleAmplitude, rumbleFrequency, rumbleDuration )
}

void function VentSounds( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	FlagWait( "EnteredVent" )
	EmitSoundOnEntity( player, "Boomtown_Vent_Entrance" )
	thread VentRumbles( player )
	while( !player.IsOnGround() )
		WaitFrame()
	EmitSoundOnEntity( player, "Boomtown_Vent_Land" )
}

void function VentRumbles( entity player )
{
	EndSignal( player, "OnDeath" )

	float maxTime = 5.0
	float startTime = Time()
	float rumbleAmplitude
	float rumbleFrequency
	float rumbleDuration

	while( Time() <= startTime + maxTime )
	{
		if ( player.IsOnGround() )
			break

		rumbleAmplitude = RandomFloatRange( 500.0, 1000.0 )
		rumbleFrequency = RandomFloatRange( 140, 170 )
		rumbleDuration = RandomFloatRange( 0.5, 1.0 )
		CreateAirShakeRumbleOnly( player.GetOrigin(), rumbleAmplitude, rumbleFrequency, rumbleDuration )

		wait rumbleDuration * 0.5
	}

	// Landing shake
	rumbleAmplitude = 150.0
	rumbleFrequency = 60
	rumbleDuration = 1.0
	CreateShakeRumbleOnly( player.GetOrigin(), rumbleAmplitude, rumbleFrequency, rumbleDuration )
}

void function BTAlrightConversation( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagEnd( "EnteringAssembly" )
	FlagWait( "BTAreYouAlrightConversation" )
	PlayerConversation( "BTSubStation", player )
}

void function BTCarriedAway( entity player )
{
	entity mover = GetEntByScriptName( "BTMover1" )
	PlatformArm arm = CreateArm( ARM_MODEL_SMALL, mover.GetOrigin(), mover.GetAngles(), true, false )

	arm.mover.SetOrigin( mover.GetOrigin() )
	arm.mover.SetAngles( AnglesCompose( mover.GetAngles(), <0,180,0> ) )
	SetArmPose( arm, 0, 0, 0, 0, 0, 90, 0, 0.0 )
	arm.mover.SetParent( mover, "", true )
	arm.model.Anim_Play( "arm_boomtown_bt_grabbed" )

	entity bt = CreateBT( mover.GetOrigin() - <0,0,1000> )
	bt.SetParent( arm.model, "ref", false )
	bt.SetNoTarget( true )
	DisableTitanRodeo( bt )
	EmitSoundOnEntity( bt, "Boomtown_RobotArm_BTMoveLoop" )
	thread PlayAnimTeleport( bt, "bt_boomtown_body_grabbed", arm.model, "ref" )

	FlagSet( "BTMoveTrack1" )

	FlagWait( "BTMoveDone" )

	bt.Destroy()
	DestroyArm( arm )
	mover.Destroy()
}

void function IntroDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	wait 1.5

	// Pilot... Pilot... I need assistance...
	waitthread PlayDialogue( "BT_I_NEED_ASSISTANCE", player )

	// Looks like the automated security in this place has picked up a Titan.
	waitthread PlayDialogue( "GRUNT1_PICKED_UP_TITAN", player )

	// Heh. Less work for us.
	waitthread PlayDialogue( "GRUNT2_LESS_WORK_FOR_US", player )
}

entity function CreateBT( vector origin )
{
	TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()
	entity npcTitan = CreateNPCTitan( loadout.setFile, TEAM_MILITIA, origin, < 0, 0, 0 >, loadout.setFileMods )
	npcTitan.ai.titanSpawnLoadout = loadout
	npcTitan.EnableNPCFlag( NPC_IGNORE_FRIENDLY_SOUND )
	SetSpawnOption_AISettings( npcTitan, "npc_titan_buddy" )
	npcTitan.SetAISettings( "npc_titan_buddy" )
	DispatchSpawn( npcTitan )

	npcTitan.EnableNPCFlag( NPC_IGNORE_ALL )
	npcTitan.SetInvulnerable()
	npcTitan.SetNoTarget( true )

	HideCrit( npcTitan )
	Highlight_ClearFriendlyHighlight( npcTitan )

	return npcTitan
}

//	█████╗  ███████╗███████╗███████╗███╗   ███╗██████╗ ██╗  ██╗   ██╗    ███████╗████████╗ █████╗ ██████╗ ████████╗
//	██╔══██╗██╔════╝██╔════╝██╔════╝████╗ ████║██╔══██╗██║  ╚██╗ ██╔╝    ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
//	███████║███████╗███████╗█████╗  ██╔████╔██║██████╔╝██║   ╚████╔╝     ███████╗   ██║   ███████║██████╔╝   ██║
//	██╔══██║╚════██║╚════██║██╔══╝  ██║╚██╔╝██║██╔══██╗██║    ╚██╔╝      ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
//	██║  ██║███████║███████║███████╗██║ ╚═╝ ██║██████╔╝███████╗██║       ███████║   ██║   ██║  ██║██║  ██║   ██║
//	╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝       ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

void function StartPoint_Assembly_Start( entity player )
{
	StartPointPrint( player, "Assembly Start" )

	StopMusicTrack( "music_boomtown_09_middleintro" )
	PlayMusic( "music_boomtown_10_assembly_start" )

	thread StartPlatformMusic()
	thread AssemblyStartRadioDialogue( player )

	thread ContextLocationPastGrinder( player )
	thread ContextLocationPastScanner( player )
	thread ContextLocationFurniture( player )
	thread ContextLocationApproachingRoof1( player )
	thread ContextLocationRoof2( player )
	thread ContextLocationApproachingRoof3( player )

	FlagWait( "AssemblyDirtPlatform" )
}

void function StartPoint_Setup_Assembly_Start( entity player )
{
	FactoryStart( player )
	TeleportPlayerAndBT( "player_start_assembly" )
	thread TalkingGrunts( player )
	GetEntByScriptName( "vista_wf_highway" ).Hide()
	FlagSet( "EnteredVent" )
}

void function StartPoint_Skipped_Assembly_Start( entity player )
{
	thread ContextLocationPastGrinder( player )
	thread ContextLocationPastScanner( player )
	thread ContextLocationFurniture( player )
	thread ContextLocationApproachingRoof1( player )
	thread ContextLocationRoof2( player )
	thread ContextLocationApproachingRoof3( player )

	Objective_Set( "#BOOMTOWN_OBJECTIVE_ASSEMBLY" )
}

void function WhatAreTheyBuildingHereConversation( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "WhatAreTheyBuildingHereConversation" )

	thread PlayerConversation( "BTNotFarApart", player )
}

void function StartPlatformMusic()
{
	FlagEnd( "AssemblyDirtPlatform" )
	FlagWait( "PlatformMusic" )
	StopMusicTrack( "music_boomtown_10_assembly_start" )
	PlayMusic( "music_boomtown_11_assembly_jumpontomovingplatform" )
}

void function AssemblyStartRadioDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	//FlagWait( "TalkingGruntsFinished" )
	//wait 6.0
	FlagWait( "AshVanguardClassDialogue" )

	UnlockAchievement( player, achievements.ENTER_FOUNDRY )

	// Ash to Blisk: It appears a fugitive Militia Pilot and another Vanguard-class Titan have made their way into the Automated Testing Facility.
	waitthread PlayDialogue( "ASH_RADIO_ASSEMBLY_01", player )

	// Get rid of 'em Ash! What the hell do I pay you for?
	waitthread PlayDialogue( "BLISK_RADIO_ASSEMBLY_02", player )

	// Relax, Blisk - this Automated Testing Facility is uniquely equipped to deal with this...distraction.
	waitthread PlayDialogue( "ASH_RADIO_ASSEMBLY_03", player )

	// Oi! Enough with the bloody toys! You just kill that Pilot and you destroy that Titan, and you do it quick eh?
	waitthread PlayDialogue( "BLISK_RADIO_ASSEMBLY_04", player )

	wait 3.0

	// *Static* Pilot....I am being taken down an assembly line. <There> may be a common exit. <I> recommend <you> follow the flow of the platforms...*Static*
	waitthread PlayDialogue( "BT_ASSEMBLY_LINE", player )

	Objective_Set( "#BOOMTOWN_OBJECTIVE_ASSEMBLY" )

	wait 2.5

	waitthread PlayDialogue( "BT_ASSEMBLY_LINE_DANGEROUS", player )
}

void function BTAssemblyLineDialogue( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "BTAssemblyLineDialogue" )

	wait 1.0

	// I can see IMC infantry scattered throughout this facility. Be careful, Pilot.
	thread PlayDialogue( "BT_BE_CAREFUL_PILOT", player )
}

void function TalkingGrunts( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "EnteredVent" )

	array<entity> grunts
	array<entity> nodes
	for ( int i = 1 ; i <= 3 ; i++ )
	{
		entity spawner = GetEntByScriptName( "talking_grunt_spawner" + i )
		entity grunt = spawner.SpawnEntity()
		DispatchSpawn( grunt )
		grunts.append( grunt )

		entity node = GetEntByScriptName( "talking_grunt_node" + i )
		nodes.append( node )
	}

	waitthread GruntsDoTalkSequence( grunts, nodes, player )

	// Shout that they spotted you
	foreach( entity grunt in grunts )
	{
		if ( IsValid( grunt ) )
		{
			grunts.fastremovebyvalue( grunt )
			grunt.Anim_Stop()
			grunt.SetEnemy( player )

			// Watch yourself! We got a Militia intruder!
			EmitSoundOnEntity( grunt, "diag_sp_assembly_BM161_14_01_imc_grunt2" )
			break
		}
	}

	// Stop their anims
	foreach( entity grunt in grunts )
	{
		if ( IsValid( grunt ) )
		{
			grunt.Anim_Stop()
			grunt.SetEnemy( player )
		}
	}

	FlagSet( "TalkingGruntsFinished" )
}

void function GruntsDoTalkSequence( array<entity> grunts, array<entity> nodes, entity player )
{
	FlagEnd( "TalkingGruntsAlerted" )
	foreach( entity grunt in grunts )
	{
		EndSignal( grunt, "OnDeath" )
		EndSignal( grunt, "OnDamaged" )
		EndSignal( grunt, "OnFoundEnemy" )
		EndSignal( grunt, "OnSeeEnemy" )
		EndSignal( grunt, "OnHearCombat" )
	}

	string currentAlias = ""
	OnThreadEnd(
		function() : ( grunts, player, currentAlias )
		{
			foreach( entity grunt in grunts )
			{
				if ( IsAlive( grunt ) )
				{
					if ( currentAlias != "" )
						StopSoundOnEntity( grunt, currentAlias )
					grunt.ClearIdleAnim()
					grunt.DisableLookDistOverride()
				}
			}
		}
	)

	// Idle anims for now until a custom set is made
	// thread PlayAnim( grunts[0], "pt_spotter_A_start_idle", nodes[0] )
	// thread PlayAnim( grunts[1], "pt_spotter_A_start_idle", nodes[1] )
	// thread PlayAnim( grunts[2], "pt_spotter_B_start_idle", nodes[2] )

	IdleAtNode( grunts[0], nodes[0], "pt_spotter_A_start_idle" )
	IdleAtNode( grunts[1], nodes[1], "pt_spotter_A_start_idle" )
	IdleAtNode( grunts[2], nodes[2], "pt_spotter_B_start_idle" )

	// Bloody hell! This job is for MRVNs (pr. Marvins). Not trained infantry.
	currentAlias = "diag_sp_assembly_BM161_06a_01_imc_grunt4"
	EmitSoundOnEntity( grunts[0], currentAlias )
	wait 3.5

	// Too right, mate. We're overqualified for this pitiful assignment. I don't see why we need that bloody Simulacrum giving us orders.
	currentAlias = "diag_sp_assembly_BM161_07a_01_imc_grunt5"
	EmitSoundOnEntity( grunts[1], currentAlias )
	wait 7.2

	// She doesn't care about the IMC or the Frontier. Blisk's mercenaries only care about money.
	currentAlias = "diag_sp_assembly_BM161_08a_01_imc_grunt4"
	EmitSoundOnEntity( grunts[0], currentAlias )
	wait 5.0

	// And what do you care about?
	currentAlias = "diag_sp_assembly_BM161_09_01_imc_grunt3"
	EmitSoundOnEntity( grunts[2], currentAlias )
	wait 1.5

	// Killing.
	currentAlias = "diag_sp_assembly_BM161_10a_01_imc_grunt4"
	EmitSoundOnEntity( grunts[0], currentAlias )
	wait 0.8

	// (Laugh)
	currentAlias = "diag_sp_assembly_BM161_11_01_imc_grunt1"
	EmitSoundOnEntity( grunts[0], currentAlias )
	wait 0.1

	// (Laugh)
	currentAlias = "diag_sp_assembly_BM161_12_01_imc_grunt2"
	EmitSoundOnEntity( grunts[1], currentAlias )
	wait 0.1

	// (Laugh)
	currentAlias = "diag_sp_assembly_BM161_13_01_imc_grunt3"
	EmitSoundOnEntity( grunts[2], currentAlias )

	wait 3.0
}

void function IdleAtNode( entity npc, entity node, string anim )
{
	npc.SetLookDistOverride( 640 )
	npc.DisableNPCFlag( NPC_ALLOW_PATROL )
	npc.SetIdleAnim( anim )

	AnimRefPoint info = GetAnimStartInfo( npc, anim, node )

	npc.SetOrigin( info.origin )
	npc.SetAngles( info.angles )
}

//	█████╗  ███████╗███████╗███████╗███╗   ███╗██████╗ ██╗  ██╗   ██╗    ██████╗ ██╗██████╗ ████████╗
//	██╔══██╗██╔════╝██╔════╝██╔════╝████╗ ████║██╔══██╗██║  ╚██╗ ██╔╝    ██╔══██╗██║██╔══██╗╚══██╔══╝
//	███████║███████╗███████╗█████╗  ██╔████╔██║██████╔╝██║   ╚████╔╝     ██║  ██║██║██████╔╝   ██║
//	██╔══██║╚════██║╚════██║██╔══╝  ██║╚██╔╝██║██╔══██╗██║    ╚██╔╝      ██║  ██║██║██╔══██╗   ██║
//	██║  ██║███████║███████║███████╗██║ ╚═╝ ██║██████╔╝███████╗██║       ██████╔╝██║██║  ██║   ██║
//	╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝       ╚═════╝ ╚═╝╚═╝  ╚═╝   ╚═╝

void function StartPoint_Assembly_Dirt( entity player )
{
	StartPointPrint( player, "Assembly Dirt" )

	FlagWait( "AssemblyWallrunStart" )
}

void function StartPoint_Setup_Assembly_Dirt( entity player )
{
	FactoryStart( player )
	TeleportPlayerAndBT( "player_start_assembly_dirt" )

	// Spawn the enemies on the dirt platform
	table results = {}
	results.activator <- player
	GetEntByScriptName( "DirtPlatformSpawnTrigger" ).Signal( "OnTrigger", results )

	GetEntByScriptName( "vista_wf_highway" ).Hide()
}

void function StartPoint_Skipped_Assembly_Dirt( entity player )
{

}

//	█████╗  ███████╗███████╗███████╗███╗   ███╗██████╗ ██╗  ██╗   ██╗    ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗ ██╗   ██╗███╗   ██╗
//	██╔══██╗██╔════╝██╔════╝██╔════╝████╗ ████║██╔══██╗██║  ╚██╗ ██╔╝    ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██║   ██║████╗  ██║
//	███████║███████╗███████╗█████╗  ██╔████╔██║██████╔╝██║   ╚████╔╝     ██║ █╗ ██║███████║██║     ██║     ██████╔╝██║   ██║██╔██╗ ██║
//	██╔══██║╚════██║╚════██║██╔══╝  ██║╚██╔╝██║██╔══██╗██║    ╚██╔╝      ██║███╗██║██╔══██║██║     ██║     ██╔══██╗██║   ██║██║╚██╗██║
//	██║  ██║███████║███████║███████╗██║ ╚═╝ ██║██████╔╝███████╗██║       ╚███╔███╔╝██║  ██║███████╗███████╗██║  ██║╚██████╔╝██║ ╚████║
//	╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝        ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

void function StartPoint_Assembly_Wallrun( entity player )
{
	StartPointPrint( player, "Assembly Wallrun" )

	FlagWait( "AssemblyFurnitureArea" )
}

void function StartPoint_Setup_Assembly_Wallrun( entity player )
{
	FactoryStart( player )
	TeleportPlayerAndBT( "player_start_assembly_wallrun" )
	GetEntByScriptName( "vista_wf_highway" ).Hide()
}

void function StartPoint_Skipped_Assembly_Wallrun( entity player )
{
	FlagSet( "AssemblyFurnitureArea" )
}

//	█████╗  ███████╗███████╗███████╗███╗   ███╗██████╗ ██╗  ██╗   ██╗    ███████╗██╗   ██╗██████╗ ███╗   ██╗██╗████████╗██╗   ██╗██████╗ ███████╗
//	██╔══██╗██╔════╝██╔════╝██╔════╝████╗ ████║██╔══██╗██║  ╚██╗ ██╔╝    ██╔════╝██║   ██║██╔══██╗████╗  ██║██║╚══██╔══╝██║   ██║██╔══██╗██╔════╝
//	███████║███████╗███████╗█████╗  ██╔████╔██║██████╔╝██║   ╚████╔╝     █████╗  ██║   ██║██████╔╝██╔██╗ ██║██║   ██║   ██║   ██║██████╔╝█████╗
//	██╔══██║╚════██║╚════██║██╔══╝  ██║╚██╔╝██║██╔══██╗██║    ╚██╔╝      ██╔══╝  ██║   ██║██╔══██╗██║╚██╗██║██║   ██║   ██║   ██║██╔══██╗██╔══╝
//	██║  ██║███████║███████║███████╗██║ ╚═╝ ██║██████╔╝███████╗██║       ██║     ╚██████╔╝██║  ██║██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║███████╗
//	╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝       ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝

void function StartPoint_Assembly_Furniture( entity player )
{
	StartPointPrint( player, "Assembly Furniture" )

	thread WhatAreTheyBuildingHereConversation( player )

	// Stop the ambient platforms behind the player
	FlagClear( "AmbientPlatformsStartEnabled" )

	GetEntByScriptName( "vista_wf_highway" ).Show()

	FlagWait( "AssemblyWallsStart" )
}

void function StartPoint_Setup_Assembly_Furniture( entity player )
{
	FactoryStart( player )
	TeleportPlayerAndBT( "player_start_assembly_furniture" )
}

void function StartPoint_Skipped_Assembly_Furniture( entity player )
{
	GetEntByScriptName( "vista_wf_highway" ).Show()
}

//	█████╗  ███████╗███████╗███████╗███╗   ███╗██████╗ ██╗  ██╗   ██╗    ██╗    ██╗ █████╗ ██╗     ██╗     ███████╗
//	██╔══██╗██╔════╝██╔════╝██╔════╝████╗ ████║██╔══██╗██║  ╚██╗ ██╔╝    ██║    ██║██╔══██╗██║     ██║     ██╔════╝
//	███████║███████╗███████╗█████╗  ██╔████╔██║██████╔╝██║   ╚████╔╝     ██║ █╗ ██║███████║██║     ██║     ███████╗
//	██╔══██║╚════██║╚════██║██╔══╝  ██║╚██╔╝██║██╔══██╗██║    ╚██╔╝      ██║███╗██║██╔══██║██║     ██║     ╚════██║
//	██║  ██║███████║███████║███████╗██║ ╚═╝ ██║██████╔╝███████╗██║       ╚███╔███╔╝██║  ██║███████╗███████╗███████║
//	╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝        ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝

void function StartPoint_Assembly_Walls( entity player )
{
	StartPointPrint( player, "Assembly Walls" )

	FlagWait( "HighwayStart" )
}

void function StartPoint_Setup_Assembly_Walls( entity player )
{
	FactoryStart( player )
	TeleportPlayerAndBT( "player_start_assembly_walls" )
	thread MakeQuickWallsPlatform()
}

void function StartPoint_Skipped_Assembly_Walls( entity player )
{
	FlagSet( "HighwayStart" )
}

void function MakeQuickWallsPlatform()
{
	Platform platform = CreatePlatform( PLATFORM_MODEL_WALLS, file.platform_framing_track_end_outfeed.origin, file.platform_framing_track_end_outfeed.angles, true )
	PlatformAnim( platform, "wf_assemble_prewall_idle_platform" )
	thread TrackWallSectionRun()
	wait 12
	file.thirdHandoffPlatform = platform
	Signal( level, "FramedPlatformReadyForPickup" )
}

//	██╗  ██╗██╗ ██████╗ ██╗  ██╗██╗    ██╗ █████╗ ██╗   ██╗
//	██║  ██║██║██╔════╝ ██║  ██║██║    ██║██╔══██╗╚██╗ ██╔╝
//	███████║██║██║  ███╗███████║██║ █╗ ██║███████║ ╚████╔╝
//	██╔══██║██║██║   ██║██╔══██║██║███╗██║██╔══██║  ╚██╔╝
//	██║  ██║██║╚██████╔╝██║  ██║╚███╔███╔╝██║  ██║   ██║
//	╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝

void function StartPoint_Highway( entity player )
{
	//SOUPY HACK
	//This destroys the vista that is physically in the town climb section
	// NOTE: depending on how TU builds this vista and ties it into the highway, we also may need to hide/unhide "vista_wf_highway"
	GetEntByScriptName( "vista_start_wf_right" ).Destroy()

	StartPointPrint( player, "Highway" )

	// Start the ambient playforms in town climb entrance
	FlagSet( "AmbientPlatformsTownClimbEntranceEnabled" )
	FlagClear( "AmbientPlatformsStartEnabled" )
	FlagClear( "AmbientPlatformsAboveGrassEnabled" )
	FlagClear( "AmbientPlatformsWallsStartEnabled" )

	Boomtown_SetCSMTexelScale( player, 0.15, 9.0 )

	thread HighwayConversation( player )

	StopMusicTrack( "music_boomtown_11_assembly_jumpontomovingplatform" )
	PlayMusic( "music_boomtown_12_assembly_highway" )

	FlagWait( "PlayerEnteringTownClimb" )
}

void function StartPoint_Setup_Highway( entity player )
{
	TeleportPlayerAndBT( "player_start_assembly_walls" )
	thread MakeQuickHighwayPlatform( player )

	FlagSet( "AmbientPlatformsTownClimbEntranceEnabled" )
	FlagClear( "AmbientPlatformsStartEnabled" )
	FlagClear( "AmbientPlatformsAboveGrassEnabled" )
	FlagClear( "AmbientPlatformsWallsStartEnabled" )

	FactoryStart( player )
}

void function StartPoint_Skipped_Highway( entity player )
{
	FlagClear( "AmbientPlatformsStartEnabled" )
	FlagClear( "AmbientPlatformsAboveGrassEnabled" )
	FlagClear( "AmbientPlatformsWallsStartEnabled" )
	GetEntByScriptName( "vista_start_wf_right" ).Destroy()
}

void function MakeQuickHighwayPlatform( entity player )
{
	entity node = GetEntByScriptName( "platform_track_highway_start" )
	PlatformArm arm = CreateArm( ARM_MODEL, node.GetOrigin(), node.GetAngles(), true )
	arm.mover.SetPusher( true )

	vector originOffset = < 175, 0, -2020 >
	vector angleOffset = < 90, 90, 180 >
	Platform platform = CreatePlatform( PLATFORM_MODEL_WALLS, node.GetOrigin() + originOffset, node.GetAngles() + angleOffset, true )
	AttachPlatformToArm( platform, arm, true )
	thread SetArmPose( arm, 0, 0, 90, -52, -31, 90, 4.2, 0.0 )

	PlatformAnim( platform, "wf_assemble_walls_D_platform" )
	TurnOnParts( platform.model, [ "station_1_1", "station_1_2", "station_1_3" ] )
	TurnOnParts( platform.model, [ "station_2_1", "station_2_2" ] )
	TurnOnParts( platform.model, [ "station_3_1", "station_3_2", "station_3_3", "station_3_4" ] )
	TurnOnParts( platform.model, [ "station_4_1", "station_4_2", "station_4_3" ] )

	WaitFrame()

	int attachIndex = arm.model.LookupAttachment( "platform" )
	vector playerStart = arm.model.GetAttachmentOrigin( attachIndex )
	WaitFrame()
	player.SetOrigin( < 8658, -5887, 2560 > )

	UpdatePlatform4ModelToRigid( platform )

	thread TrackHighwaySection( arm, platform )
}

void function HighwayConversation( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "HighwayConversation" )

	thread PlayerConversation( "MeatGrinder", player )
}

//	████████╗ ██████╗ ██╗    ██╗███╗   ██╗     ██████╗██╗     ██╗███╗   ███╗██████╗     ███████╗███╗   ██╗████████╗██████╗ ██╗   ██╗
//	╚══██╔══╝██╔═══██╗██║    ██║████╗  ██║    ██╔════╝██║     ██║████╗ ████║██╔══██╗    ██╔════╝████╗  ██║╚══██╔══╝██╔══██╗╚██╗ ██╔╝
// 	   ██║   ██║   ██║██║ █╗ ██║██╔██╗ ██║    ██║     ██║     ██║██╔████╔██║██████╔╝    █████╗  ██╔██╗ ██║   ██║   ██████╔╝ ╚████╔╝
//	   ██║   ██║   ██║██║███╗██║██║╚██╗██║    ██║     ██║     ██║██║╚██╔╝██║██╔══██╗    ██╔══╝  ██║╚██╗██║   ██║   ██╔══██╗  ╚██╔╝
//	   ██║   ╚██████╔╝╚███╔███╔╝██║ ╚████║    ╚██████╗███████╗██║██║ ╚═╝ ██║██████╔╝    ███████╗██║ ╚████║   ██║   ██║  ██║   ██║
//	   ╚═╝    ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝     ╚═════╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝     ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝

void function StartPoint_TownClimbEntry( entity player )
{
	StartPointPrint( player, "Town Climb Entry" )

	thread TownClimbAshDialogue( player )

	FlagWait( "TownClimbBegin" )

	Boomtown_SetCSMTexelScale( player, 2.0, 4.5 )


	// Hack! The model at these spots has holes the player can slip through. Spawn invisible sky panels to block them.
	entity hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -11240, -800, 7376 >, < 0, -90, 180 >, 6 )
	hackSkyPanel.Hide()
	hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -11240, -800, 7152 >, < 0, -90, 180 >, 6 )
	hackSkyPanel.Hide()
	hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -10728, -4768, 7376 >, < 0, 0, 180 >, 6 )
	hackSkyPanel.Hide()
	hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -10728, -4768, 7152 >, < 0, 0, 180 >, 6 )
	hackSkyPanel.Hide()
	hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -7912, -4256, 7376 >, < 0, 90, 180 >, 6 )
	hackSkyPanel.Hide()
	hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -7912, -4256, 7152 >, < 0, 90, 180 >, 6 )
	hackSkyPanel.Hide()
	hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -8424, -288, 7376 >, < 0, 180, 180 >, 6 )
	hackSkyPanel.Hide()
	hackSkyPanel = CreatePropDynamicLightweight( SKY_PANEL, < -8424, -288, 7152 >, < 0, 180, 180 >, 6 )
	hackSkyPanel.Hide()


	//########################################
	// TOWN CLIMB ( USED TO BE IN START POINT)
	//########################################

	// This sets max look up so you can't look straight up.  Mess with the pilot_solo mod that's in there.  Thanks rayme! Change 178617
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "boomtown_climb" ] )

	FlagWait( "ReaperTownRaisedUp" ) // Set when all 6 pieces have finished moving up into reapertown

	// Chad: You might want to put a flag trigger at the control panel area to FlagWait() before ReaperTownRaisedUp?
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [] )

	FlagWait( "PlayerInRaisedReaperTown" ) // Trigger in raised area indicates the player has arrived

	Signal( player, "StopUpdatingArmAndPlatformPushers" )

	// Turn off ambient platforms behind the player. Some of these should already be disabled via triggers but we just make sure here
	FlagClear( "AmbientPlatformsStartEnabled" )
	FlagClear( "AmbientPlatformsAboveGrassEnabled" )
	FlagClear( "AmbientPlatformsWallsStartEnabled" )
	FlagClear( "AmbientPlatformsTownClimbEntranceEnabled" )

	// Player now goes to reapertown teleport
}

void function StartPoint_Setup_TownClimbEntry( entity player )
{
	FactoryStart( player )
	TeleportPlayerAndBT( "player_start_assembly_walls" )
	thread MakeQuickPlatformForTownClimbEntry( player )

	FlagSet( "AmbientPlatformsTownClimbEntranceEnabled" )
	FlagClear( "AmbientPlatformsStartEnabled" )
	FlagClear( "AmbientPlatformsAboveGrassEnabled" )
	FlagClear( "AmbientPlatformsWallsStartEnabled" )
}

void function StartPoint_Skipped_TownClimbEntry( entity player )
{

}

void function TownClimbAshDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagWait( "PlayerEnteringTownClimbDialogue" )

	// I see you, Pilot
	waitthread PlayDialogue( "ASH_TOWN_CLIMB_ENTRY_1",	player )

	wait 0.3

	// I admire your perseverance. If only the IMC infantry were as dedicated.
	waitthread PlayDialogue( "ASH_TOWN_CLIMB_ENTRY_2",	player )

	wait 0.3

	// Only one way out Pilot… up.
	thread PlayDialogue( "ASH_TOWN_CLIMB_ENTRY_3",	player )

	FlagWait( "HalfwayUpTownClimb" )

	// The dome is still waiting. Rest assured I will not execute you summarily. You have my word.
	thread PlayDialogue( "ASH_DOME_STILL_WAITING",	player )
}

void function MakeQuickPlatformForTownClimbEntry( entity player )
{
	array<entity> nodes = GetChainOfNodesByScriptName( "platform_track_highway_start" )
	PlatformArm arm = CreateArm( ARM_MODEL, nodes[3].GetOrigin(), nodes[0].GetAngles(), true )
	arm.mover.SetPusher( true )

	vector originOffset = < 175, 0, -2020 >
	vector angleOffset = < 90, 90, 180 >
	Platform platform = CreatePlatform( PLATFORM_MODEL_WALLS, nodes[3].GetOrigin() + originOffset, nodes[0].GetAngles() + angleOffset, true )
	AttachPlatformToArm( platform, arm, true )
	SetArmPose( arm, 90, 0, 90, -52, -31, 89, 4.2, 0.0 )
	WaitFrame()
	thread SetArmPose( arm, 180, 0, 90, -52, -31, 89, 4.2, 10.0 )

	PlatformAnim( platform, "wf_assemble_walls_D_platform" )
	TurnOnParts( platform.model, [ "station_1_1", "station_1_2", "station_1_3" ] )
	TurnOnParts( platform.model, [ "station_2_1", "station_2_2" ] )
	TurnOnParts( platform.model, [ "station_3_1", "station_3_2", "station_3_3", "station_3_4" ] )
	TurnOnParts( platform.model, [ "station_4_1", "station_4_2", "station_4_3" ] )

	UpdatePlatform4ModelToRigid( platform )

	int attachIndex = arm.model.LookupAttachment( "platform" )
	vector playerStart = arm.model.GetAttachmentOrigin( attachIndex )
	player.SetOrigin( playerStart + <100,100,280> )

	wait 1.0

	thread PlatformGoesToVerticalTown( arm, platform )
}

void function TownClimbComeTogether( entity player )
{
	thread TownClimbPieceGetsPlaced( player )
	thread TownClimbSectionsAssemble()
	thread BoomtownDisassemble()
}

//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------

void function FactoryStart( entity player )
{
	FlagSet( "AmbientPlatformsStartEnabled" )
	FlagSet( "AmbientPlatformsAboveGrassEnabled" )
	FlagSet( "AmbientPlatformsWallsStartEnabled" )

	thread UpdateArmAndPlatformPushersForPlayer( player )

	thread TrackFirstSection()
	thread TrackSecondSection()
	thread TrackFoundationTransferSection()
	thread TrackFrameSection()
	thread AmbientPlatforms()
	thread HighwayRollers()
	thread TownClimbComeTogether( player )
}

void function TrackFirstSection()
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	array<entity> nodes = GetChainOfNodesByScriptName( "track_sec1_start" )
	while( !Flag( "PlayerDoingWallAssembly" ) )
	{
		thread TrackFirstSection_Part1( nodes )
		wait 9.5 // need to deliver a platform to the handoff every 9.5 seconds
	}
	printt( "########################################" )
	printt( "STOPPING DIRT AND GRASS ASSMEBLY SECTION" )
	printt( "########################################" )
}

void function TrackFirstSection_Part1( array<entity> nodes )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	PlatformArm arm = CreateArm( ARM_MODEL, nodes[0].GetOrigin(), nodes[0].GetAngles(), true )
	Platform platform = CreatePlatform( PLATFORM_MODEL_DIRT, nodes[0].GetOrigin(), nodes[0].GetAngles(), true )
	AttachPlatformToArm( platform, arm, false, "platform_180" )
	thread SetArmPose( arm, -90, 0, 45, -32, -8, 89, 0.0, 0.0 )

	// Move out of the wall onto the main track
	float moveTime = Distance( arm.model.GetOrigin(), nodes[1].GetOrigin() ) / 680
	float easeIn = 0.0
	float easeOut = min( 0.5, moveTime * 0.5 )
	thread MoveArmForDuration( arm, nodes[1].GetOrigin(), moveTime, easeIn, easeOut )
	wait moveTime

	// Go to the slower section of track
	moveTime = Distance( arm.model.GetOrigin(), nodes[2].GetOrigin() ) / 680
	easeIn = min( 0.5, moveTime * 0.5 )
	easeOut = 0.0
	thread MoveArmForDuration( arm, nodes[2].GetOrigin(), moveTime, easeIn, easeOut )
	wait moveTime

	TrackFirstSection_Part2( arm, platform, nodes )
}

void function TrackFirstSection_Part2( PlatformArm arm, Platform platform, array<entity> nodes )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	// Move into handoff position on the track
	thread MoveArmForDuration( arm, nodes[3].GetOrigin(), 30.0, 0.0, 0.5 )
	wait 10.0
	Signal( level, "GhostRecorderFirstPlatformGo" )
	wait 20.0

	// Bend arm into handoff position
	Signal( level, "FirstSectionPreHandoff" )
	thread SetArmPose( arm, -90, 0, -68, 23, 37.5, 90, 0.0, 1.0 )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FirstExchange_PassExtend" )
	wait 1.0

	// Other arm will grab the platform now
	file.firstHandoffPlatform = platform
	file.firstHandoffArm = arm
	Signal( level, "FirstSectionHandoff" )
	WaitSignal( arm, "HandoffComplete" )

	// Move away without panel
	wait 1.5
	thread MoveArmForDuration( arm, nodes[4].GetOrigin(), 8.0, 0.5, 0.5 )
	thread SetArmPose( arm, -90, 90, 0, -20, 20, 0, 0.0, 1.0 )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FirstExchange_PassRetract" )
	wait 8.0

	// Move into the wall and delete
	thread MoveArmForDuration( arm, nodes[5].GetOrigin(), 2.0, 0.5, 0.5 )
	wait 2
	DestroyArm( arm )
}

void function TrackSecondSection()
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	array<entity> nodes = GetChainOfNodesByScriptName( "track_sec2_start" )
	for ( int i = 0 ; i < NUM_ARMS_FIRST_HANDOFF ; i++ )
	{
		PlatformArm arm = CreateArm( ARM_MODEL, nodes[0].GetOrigin(), nodes[0].GetAngles(), true )
		thread TrackSecondSectionArm( arm, nodes, i )
	}
}

void function TrackSecondSectionArm( PlatformArm arm, array<entity> nodes, int startIndex )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	thread SetArmPose( arm, -90, 0, -11, -75, 15, -5, 0.0, 0.0 )

	while( true )
	{
		// Wait for platform to almost be in position
		WaitSignal( level, "FirstSectionPreHandoff" )
		if ( startIndex > 0 )
		{
			startIndex--
			continue
		}

		thread SetArmPose( arm, -90, 0, -11, -75, 15, -5, 0.0, 1.0 )

		// Wait for it to hear the platform is in position
		table signalData = WaitSignal( level, "FirstSectionHandoff" )
		Assert( IsValid( file.firstHandoffPlatform ) )
		Assert( IsValid( file.firstHandoffArm ) )

		// Slide into the platform to grab it
		EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FirstExchange_ReceiveExtend" )
		thread MoveArmForDuration( arm, nodes[1].GetOrigin(), 1.0, 0.5, 0.5 )
		wait 1.0

		// Attach the platform to this arm now
		PlatformArm otherArm = file.firstHandoffArm
		Platform platform = file.firstHandoffPlatform

		int attachIndex = arm.model.LookupAttachment( "platform" )
		vector startPos = otherArm.model.GetAttachmentOrigin( attachIndex )
		vector endPos = arm.model.GetAttachmentOrigin( attachIndex )
		float d = Distance( startPos, endPos )
		float transferTime = d / 100.0
		DetachPlatform( platform )
		if ( transferTime > 0.0 )
		{
			//thread MovePlatformForDuration( platform, endPos, transferTime, transferTime * 0.33, transferTime * 0.33 )
			platform.mover.NonPhysicsMoveTo( endPos, transferTime, transferTime * 0.33, transferTime * 0.33 )
			wait transferTime
		}
		AttachPlatformToArm( platform, arm, false )

		// Tell the other arm it's not carrying the panel anymore
		Signal( otherArm, "HandoffComplete" )

		// Move the panel and get it rotated to fit into the building ( player will fall off )
		thread MoveArmForDuration( arm, nodes[2].GetOrigin(), 2.0, 1.0, 1.0 )
		wait 1.0
		EmitSoundOnEntityNoSave( arm.mover, "BoomTown_RobotArm_FoldWithPlate" )
		thread SetArmPose( arm, 0, 0, 90, -90, -90, -12, 0.0, 2.0 )	// rotate and fold up, can still stand on platform
		wait 2.0
		thread SetArmPose( arm, 0, 0, 90, -90, -90, -90, 0.0, 1.0 ) // platform goes vertical
		wait 1.0

		// Move through the slot into next position
		thread MoveArmForDuration( arm, nodes[3].GetOrigin(), 3.0, 1.0, 1.0 )
		wait 3.0

		// Lay the platform down on the track slider
		EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FirstExchange_MoveOntoConveyor" )
		thread MoveArmForDuration( arm, nodes[4].GetOrigin(), 1.0, 0.5, 0.5 )
		thread SetArmPose( arm, 0, 0, 90, -90, -90, -16, 0, 1.0 )
		wait 1.0
		thread SetArmPose( arm, 0, 1, 90, -49, -90, 47, 0.0, 1.0 )
		wait 1.0
		thread SetArmPose( arm, 0, 0, 36, -42, -42, 37, 0.0, 1.0 ) // lays platform on the track slider
		thread MoveArmForDuration( arm, nodes[5].GetOrigin(), 1.0, 0.5, 0.5 )
		wait 1.0

		// Release the platform
		thread PlatformGetsDirtAndGrass( platform )
		wait 1.0
		thread SetArmPose( arm, 0, 0, 77, -57, -30, 56, 0.0, 1.0 ) // pulls forks out of the platform
		wait 1.0
		thread SetArmPose( arm, 0, 0, 90, -90, -90, -90, 0.0, 1.0 ) // platform goes vertical

		// Move around the track back to starting position
		thread MoveArmForDuration( arm, nodes[6].GetOrigin(), 3.0, 1.0, 1.0 )
		wait 3.0
		thread MoveArmForDuration( arm, nodes[7].GetOrigin(), 5.0, 0.5, 0.5 )
		wait 5.0
		wait 3.0 // sit and wait at the corner
		EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FirstExchange_ReceiveApproach" )
		thread MoveArmForDuration( arm, nodes[0].GetOrigin(), 3.0, 1.0, 1.0 )
		wait 1.0
		thread SetArmPose( arm, -90, 0, -11, -75, 15, -5, 0.0, 2.0 )
		wait 2.0
	}
}

void function PlatformGetsDirtAndGrass( Platform platform )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	DetachPlatform( platform )

	// Slide down the rails
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_Plate_SlideIntoConveyor" )
	vector origin = file.platform_track_slide_end.origin
	vector angles = file.platform_track_slide_end.angles
	float moveTime = Distance( platform.mover.GetOrigin(), origin ) / PLATFORM_TRACK_SPEED
	waitthread MovePlatformForDuration( platform, origin, moveTime, moveTime * 0.33, 0.0, false )

	// Fall onto the track
	origin = file.platform_track_start.origin
	angles = file.platform_track_start.angles
	moveTime = Distance( platform.mover.GetOrigin(), origin ) / PLATFORM_TRACK_SPEED
	thread MovePlatformForDuration( platform, origin, moveTime, moveTime * 0.33, 0.0 )
	thread RotatePlatform( platform, angles, moveTime, moveTime * 0.33, 0.0 )
	wait moveTime

	// Move to the press
	origin = file.platform_dirt_press_bottom.origin
	moveTime = Distance( platform.mover.GetOrigin(), origin ) / PLATFORM_TRACK_SPEED
	thread MovePlatformForDuration( platform, origin, moveTime, moveTime * 0.05, moveTime * 0.1 )
	wait moveTime * 0.5
	FlagSet( "warning_lights_dirt" )
	wait moveTime * 0.5

	// Press goes up
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateLift_RockLayerRaise" )
	AttachPlatformToEnt( platform, file.dirtPressMover, "", true )
	file.dirtPressMover.NonPhysicsMoveTo( file.platform_dirt_press_top.origin, 1.0, 0.5, 0.2 )
	wait 1.0
	AssemblyScreenShake( file.platform_dirt_press_top.origin )

	// Activate the dirt
	int bodyGroupIndex = platform.model.FindBodyGroup( "dirt" )
	platform.model.SetBodygroup( bodyGroupIndex, 1 )
	thread DirtPressEffect()
	wait 0.3

	FlagClear( "warning_lights_dirt" )

	// Press goes down
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateLift_RockLayerLower" )
	file.dirtPressMover.NonPhysicsMoveTo( file.platform_dirt_press_bottom.origin, 1.4, 0.4, 0.4 )
	wait 1.4
	DetachPlatform( platform )

	// Dirt trail effect
	entity dirtTrailEffect = StartParticleEffectOnEntity_ReturnEntity( platform.model, GetParticleSystemIndex( DUST_TRAIL_EFFECT ), FX_PATTACH_ROOTBONE_FOLLOW, 0 )

	// Move down the track to the grass planter
	origin = file.platform_grass_plant_start.origin
	moveTime = Distance( platform.mover.GetOrigin(), origin ) / PLATFORM_TRACK_SPEED
	thread MovePlatformForDuration( platform, origin, moveTime, moveTime * 0.1, 0.0 )
	wait 5.0
	Signal( level, "GhostRecorderDirtPlatformGo" )
	wait moveTime - 5.0

	// Move platform through the grass planter
	if ( PlayerCanHearEnt( file.grassGrinder ) )
		EmitSoundOnEntity( file.grassGrinder, "Boomtown_PlateGrinder_AddingGrass" )
	origin = file.platform_grass_plant_end.origin
	moveTime = Distance( platform.mover.GetOrigin(), origin ) / PLATFORM_TRACK_SPEED
	moveTime += 3.0
	thread MovePlatformForDuration( platform, origin, moveTime, 0.0, 0.0 )
	thread GrassGrinderEffects()
	wait moveTime * 0.05
	for ( int i = 1 ; i < 9 ; i++ )
	{
		wait moveTime * 0.1
		int bodyGroupIndex = platform.model.FindBodyGroup( "grass_" + i )
		platform.model.SetBodygroup( bodyGroupIndex, 1 )

		if ( i == 7 )
			StopSoundOnEntity( file.grassGrinder, "Boomtown_PlateGrinder_AddingGrass" )
	}

	if ( IsValid( dirtTrailEffect ) )
	{
		EffectStop( dirtTrailEffect )
		dirtTrailEffect.Destroy()
	}

	// Move platform down to the next station
	origin = file.platform_foundation_press_bottom.origin
	moveTime = Distance( platform.mover.GetOrigin(), origin ) / PLATFORM_TRACK_SPEED
	thread MovePlatformForDuration( platform, origin, moveTime, 0.0, 0.0 )
	wait moveTime - 2.0
	FlagSet( "warning_lights_foundation" )
	wait 2.0

	// Move the platform into the foundation press
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateLift_MetalLayerRaise" )
	AttachPlatformToEnt( platform, file.foundationPressMover, "", true )
	file.foundationPressMover.NonPhysicsMoveTo( file.platform_foundation_press_top.origin, 1.0, 0.8, 0.0 )
	wait 1.0
	AssemblyScreenShake( file.platform_foundation_press_top.origin )

	StartParticleEffectInWorld( GetParticleSystemIndex( DIRT_PRESS_EFFECT ), platform.model.GetOrigin(), platform.model.GetAngles() )

	// Swap to foundation platform
	platform.activeAnim = ""
	ChangePlatformModel( platform, PLATFORM_MODEL_FOUNDATION )
	wait 0.5

	// Bring the platform back down and rotated
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateLift_MetalLayerLower" )
	file.foundationPressMover.NonPhysicsMoveTo( file.platform_foundation_track_start.origin, 3.0, 0.5, 0.5 )
	wait 0.5
	FlagClear( "warning_lights_foundation" )
	file.foundationPressMover.NonPhysicsRotateTo( file.platform_foundation_track_start.angles, 2.0, 1.0, 1.0 )
	wait 2.5

	// Move the platform down to the end of the tracks
	DetachPlatform( platform )
	file.foundationPressMover.NonPhysicsRotateTo( file.platform_foundation_press_bottom.angles, 0.4, 0.2, 0.2 )
	origin = file.platform_foundation_track_end.origin
	thread MovePlatformForDuration( platform, origin, 6.0, 0.5, 0.5 )

	// Wait for platform to clear the piston before it goes back up
	wait 3.5

	// Move the piston back into position for next platform
	EmitSoundOnEntityNoSave( file.foundationPressMover, "Boomtown_PlateLift_MetalLayerStart" )
	file.foundationPressMover.NonPhysicsMoveTo( file.platform_foundation_press_bottom.origin, 1.0, 0.5, 0.5 )
	file.foundationPressMover.NonPhysicsRotateTo( file.platform_foundation_press_bottom.angles, 1.0, 0.5, 0.5 )

	// Wait for platform to reach the end of the track
	wait 2.1 // wait 0.4 seconds less than actual move time so the next arm looks better anticipating the arrival

	file.secondHandoffPlatform = platform
	Signal( level, "FoundationPlatformReadyForPickup" )
}

void function TrackFoundationTransferSection()
{
	// Platforms come out at 9.5 seconds spacing

	array<entity> nodesA = GetChainOfNodesByScriptName( "foundation_transfer_track1" )
	array<entity> nodesB = GetChainOfNodesByScriptName( "foundation_transfer_track2" )

	array<PlatformArm> armsA
	armsA.append( CreateArm( ARM_MODEL, nodesA[0].GetOrigin(), nodesA[0].GetAngles(), true ) )
	armsA.append( CreateArm( ARM_MODEL, nodesA[0].GetOrigin(), nodesA[0].GetAngles(), true ) )

	array<PlatformArm> armsB
	armsB.append( CreateArm( ARM_MODEL, nodesB[0].GetOrigin(), nodesB[0].GetAngles(), true ) )
	armsB.append( CreateArm( ARM_MODEL, nodesB[0].GetOrigin(), nodesB[0].GetAngles(), true ) )

	array<entity> scannerNodes = GetChainOfNodesByScriptName( "foundation_transfer_scan_track" )
	file.laserScannerMover = GetEntByScriptName( "scanner_equipment_mover" )
	file.laserScanner = GetEntByScriptName( "scanner_equipment" )

	thread TrackFoundationTransferSectionRun( armsA[0], nodesA, scannerNodes, 0, 0 )
	thread TrackFoundationTransferSectionRun( armsB[0], nodesB, scannerNodes, 1, 1 )
	thread TrackFoundationTransferSectionRun( armsA[1], nodesA, scannerNodes, 0, 2 )
	thread TrackFoundationTransferSectionRun( armsB[1], nodesB, scannerNodes, 1, 3 )
}

void function TrackFoundationTransferSectionRun( PlatformArm arm, array<entity> nodes, array<entity> scannerNodes, int side, int startIndex )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	thread SetArmPose( arm, 0, 0, 0, 19, -23, 90, 0, 0.0 )

	while( true )
	{
		// Sit and wait for a platform to pick up
		WaitSignal( level, "FoundationPlatformReadyForPickup" )
		Assert( IsValid( file.secondHandoffPlatform ) )
		Platform platform = file.secondHandoffPlatform

		if ( startIndex > 0 )
		{
			startIndex--
			continue
		}

		// Grab the platform
		if ( side == 0 )
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_RightGrabExtend" )
		else
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_LeftGrabExtend" )
		thread SetArmPose( arm, 0, 0, 2, -38, 37, 90, 0, 1.0 )
		wait 1.0

		// Connect the platform to the new arm
		AttachPlatformToArm( platform, arm, true )

		// Move down the path to the tilt spot
		thread MoveArmForDuration( arm, nodes[1].GetOrigin(), 2.5, 0.5, 0.5 )
		wait 2.5

		// Give player a chance to jump off before tilting vertical
		wait 0.5

		// Tilt it vertically
		if ( side == 0 )
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_RightGrabRetract" )
		else
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_LeftGrabRetract" )
		thread SetArmPose( arm, 0, 0, 0, 19, -23, 90, 0, 0.5 )
		wait 0.5
		thread SetArmPose( arm, 0, 0, 90, -90, -90, -90, 0, 1.5 )
		wait 1.5
		thread MoveArmForDuration( arm, nodes[2].GetOrigin(), 1.0, 0.5, 0.5 )

		// Wait for next platform to get closer so player can jump onto this one
		wait 5.0

		// Get the scanner into position
		if ( side == 0 )
			file.laserScannerMover.NonPhysicsRotateTo( < 0, -90.0, 0 >, 3.0, 1.5, 1.5 )
		else
			file.laserScannerMover.NonPhysicsRotateTo( < 0, 90.0, 0 >, 3.0, 1.5, 1.5 )
		EmitSoundOnEntityNoSave( file.laserScanner, "Boomtown_RobotArm_SecondExchange_MiddleRotate" )
		file.laserScannerMover.NonPhysicsMoveTo( scannerNodes[1].GetOrigin(), 1.5, 0.5, 0.5 )
		wait 1.5
		file.laserScannerMover.NonPhysicsMoveTo( scannerNodes[0].GetOrigin(), 1.5, 0.5, 0.5 )
		wait 1.5

		ScannerOn()

		// Move down the track vertically
		thread MoveArmForDuration( arm, nodes[3].GetOrigin(), 4.0, 0.5, 0.5 )
		wait 4.0

		ScannerOff()

		// Put the panel back horizontal
		if ( side == 0 )
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_RightPlaceExtend" )
		else
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_LeftPlaceExtend" )
		thread SetArmPose( arm, 0, 0, 2, -38, 37, 90, 0, 1.5 )
		wait 1.5

		// Move platform into slot
		thread MoveArmForDuration( arm, nodes[4].GetOrigin(), 1.0, 0.5, 0.5 )

		// Stay put so player can land on it
		wait 5.5

		// Release the platform
		DetachPlatform( platform )
		if ( side == 0 )
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_RightPlaceRetract" )
		else
			EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SecondExchange_LeftPlaceRetract" )
		thread SetArmPose( arm, 0, 0, 0, 19, -23, 90, 0, 1.0 )
		wait 1.0
		thread SetArmPose( arm, 0, 0, 0, 19, -23, 0, 0, 1.0 )

		// Move platform into the slot
		thread TrackFoundationEnterSlotAndDestroy( platform )

		// Pull arm away and go back around the track
		thread MoveArmForDuration( arm, nodes[5].GetOrigin(), 1.5, 0.5, 0.5 )
		wait 1.5
		thread MoveArmForDuration( arm, nodes[6].GetOrigin(), 8.0, 0.5, 0.5 )
		wait 7.0
		thread SetArmPose( arm, 0, 0, 0, 19, -23, 90, 0, 1.0 )
		wait 1.0
		thread MoveArmForDuration( arm, nodes[0].GetOrigin(), 1.5, 0.5, 0.5 )
		wait 1.5
	}
}

void function ScannerOn()
{
	if ( IsValid( file.laserScannerEffect ) )
		return
	int attachIndex = file.laserScanner.LookupAttachment( "laser" )
	EmitSoundOnEntity( file.laserScanner, "BoomTown_RobotArm_Scanner" )
	file.laserScannerEffect = StartParticleEffectOnEntity_ReturnEntity( file.laserScanner, GetParticleSystemIndex( LASER_SCANNER_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
}

void function ScannerOff()
{
	if ( IsValid( file.laserScannerEffect ) )
	{
		EffectStop( file.laserScannerEffect )
		file.laserScannerEffect.Destroy()
	}
}

void function TrackFoundationEnterSlotAndDestroy( Platform platform )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )
	MovePlatformAtSpeed( platform, file.platform_framing_insert_end.origin, PLATFORM_TRACK_SPEED * 2.5, 0.0, 0.5 )
	waitthread MovePlatformForDuration( platform, file.platform_framing_insert_down.origin, 0.5, 0.25, 0.25 )
	DestroyPlatform( platform )
}

void function TrackFrameSection()
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	file.framingStop1Arm1.model.Anim_Play( "wf_assemble_furniture_A_arm1_idle" )
	file.framingStop1Arm2.model.Anim_Play( "wf_assemble_furniture_A_arm2_idle" )
	file.framingStop1Arm3.model.Anim_Play( "wf_assemble_furniture_A_arm3_idle" )

	file.framingStop2Arm1.model.Anim_Play( "wf_assemble_furniture_B_arm1_idle" )
	file.framingStop2Arm2.model.Anim_Play( "wf_assemble_furniture_B_arm2_idle" )
	file.framingStop2Arm3.model.Anim_Play( "wf_assemble_furniture_B_arm3_idle" )

	file.wallsStop1Arm1.model.Anim_Play( "wf_assemble_walls_A_arm1_idle" )
	file.wallsStop1Arm2.model.Anim_Play( "wf_assemble_walls_A_arm2_idle" )
	file.wallsStop1Arm3.model.Anim_Play( "wf_assemble_walls_A_arm3_idle" )

	file.wallsStop2Arm1.model.Anim_Play( "wf_assemble_walls_B_arm1_idle" )
	file.wallsStop2Arm2.model.Anim_Play( "wf_assemble_walls_B_arm2_idle" )
	file.wallsStop2Arm3.model.Anim_Play( "wf_assemble_walls_B_arm3_idle" )

	file.wallsStop3Arm1.model.Anim_Play( "wf_assemble_walls_C_arm1_idle" )
	file.wallsStop3Arm2.model.Anim_Play( "wf_assemble_walls_C_arm2_idle" )
	file.wallsStop3Arm3.model.Anim_Play( "wf_assemble_walls_C_arm3_idle" )

	file.wallsStop4Arm1.model.Anim_Play( "wf_assemble_walls_D_arm1_idle" )
	file.wallsStop4Arm2.model.Anim_Play( "wf_assemble_walls_D_arm2_idle" )
	file.wallsStop4Arm3.model.Anim_Play( "wf_assemble_walls_D_arm3_idle" )

	thread DoInstallArmRumbles( file.framingStop1Arm1.model, false )
	thread DoInstallArmRumbles( file.framingStop1Arm2.model, false )
	thread DoInstallArmRumbles( file.framingStop1Arm3.model, false )
	thread DoInstallArmRumbles( file.framingStop2Arm1.model, false )
	thread DoInstallArmRumbles( file.framingStop2Arm2.model, false )
	thread DoInstallArmRumbles( file.framingStop2Arm3.model, false )

	thread DoInstallArmRumbles( file.wallsStop1Arm1.model, true )
	thread DoInstallArmRumbles( file.wallsStop1Arm2.model, true )
	thread DoInstallArmRumbles( file.wallsStop1Arm3.model, true )
	thread DoInstallArmRumbles( file.wallsStop2Arm1.model, true )
	thread DoInstallArmRumbles( file.wallsStop2Arm2.model, true )
	thread DoInstallArmRumbles( file.wallsStop2Arm3.model, true )
	thread DoInstallArmRumbles( file.wallsStop3Arm1.model, true )
	thread DoInstallArmRumbles( file.wallsStop3Arm2.model, true )
	thread DoInstallArmRumbles( file.wallsStop3Arm3.model, true )
	thread DoInstallArmRumbles( file.wallsStop4Arm1.model, true )
	thread DoInstallArmRumbles( file.wallsStop4Arm2.model, true )
	thread DoInstallArmRumbles( file.wallsStop4Arm3.model, true )

	while( !Flag( "HighwayStart" ) )
	{
		thread TrackFrameSectionRun()
		wait 20
	}
}

void function DoInstallArmRumbles( entity model, bool largeRumble )
{
	EndSignal( model, "OnDestroy" )

	int attachID = model.LookupAttachment( "SOUNDPOS" )
	Assert( attachID >= 0 )

	while( true )
	{
		WaitSignal( model, "ArmInstallRumble" )

		vector pos = model.GetAttachmentOrigin( attachID )
		float rumbleAmplitude
		float rumbleFrequency
		float rumbleDuration

		if ( largeRumble )
		{
			rumbleAmplitude = 100.0
			rumbleFrequency = 130
			rumbleDuration = 1.5
		}
		else
		{
			rumbleAmplitude = 50.0
			rumbleFrequency = 170
			rumbleDuration = 1.5
		}

		CreateShakeRumbleOnly( pos, rumbleAmplitude, rumbleFrequency, rumbleDuration )
	}
}

void function TrackFrameSectionRun()
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	// Frame gets build via audio!
	entity soundSource = CreateScriptMover( file.platform_framing_lowered.origin, file.platform_framing_lowered.angles )
	wait 6
	EmitSoundOnEntityNoSave( soundSource, "Boomtown_PlateLift_UnderGroundConstruction" )
	wait 14
	StopSoundOnEntity( soundSource, "Boomtown_PlateLift_UnderGroundConstruction" )
	soundSource.Destroy()

	Platform platform = CreatePlatform( PLATFORM_MODEL_FRAMING, file.platform_framing_lowered.origin, file.platform_framing_lowered.angles, true )
	platform.model.Show()
	platform.model.Solid()
	platform.isHidden = false

	wait 0.1
	thread NotSolidBoneFollowersForTime( platform.model, 0.2, GetBoneFollowersListForModel( PLATFORM_MODEL_FRAMING ) )
	wait 0.1

	PlatformAnim( platform, "wf_assemble_prefurniture_idle_platform" )
	platform.mover.SetKillNPCOnPush( true )

	StartParticleEffectInWorld( GetParticleSystemIndex( FLOOR_DOOR_OPEN_EFFECT ), file.platform_framing_track_start.origin, file.platform_framing_track_start.angles )

	// Open the doors
	file.platform_framing_door_1.NonPhysicsMoveTo( file.platform_framing_door1_openedPos, 1.5, 0.5, 0.5 )
	file.platform_framing_door_2.NonPhysicsMoveTo( file.platform_framing_door2_openedPos, 1.5, 0.5, 0.5 )
	EmitSoundAtPosition( TEAM_UNASSIGNED, file.platform_framing_track_start.origin, "Boomtown_PlateConveyor_FloorOpen" )
	wait 1.5

	// Move platform up
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateLift_HouseFrame" )
	thread MovePlatformForDuration( platform, file.platform_framing_track_start.origin, 2.5, 0.0, 1.0 )
	wait 2.0

	// Platform is up almost, close the doors
	file.platform_framing_door_1.NonPhysicsMoveTo( file.platform_framing_door1_closedPos, 1.5, 0.5, 0.5 )
	file.platform_framing_door_2.NonPhysicsMoveTo( file.platform_framing_door2_closedPos, 1.5, 0.5, 0.5 )
	EmitSoundAtPosition( TEAM_UNASSIGNED, file.platform_framing_track_start.origin, "Boomtown_PlateConveyor_FloorClose" )

	// Wait for platform to be fully in up position
	wait 0.5

	// Move platform to stop 1
	MovePlatformAtSpeed( platform, file.platform_framing_stop1.origin, PLATFORM_TRACK_SPEED, 0.5, 0.5 )

	// Do anim sequence for stop 1
	FlagSet( "warning_lights_furniture1" )
	float animDuration = platform.model.GetSequenceDuration( "wf_assemble_furniture_A_platform" )
	file.framingStop1Arm1.model.Anim_Play( "wf_assemble_furniture_A_arm1" )
	file.framingStop1Arm2.model.Anim_Play( "wf_assemble_furniture_A_arm2" )
	file.framingStop1Arm3.model.Anim_Play( "wf_assemble_furniture_A_arm3" )
	file.framingStop1Rail.Anim_Play( "wf_assemble_furniture_A_rail" )

	array<string> railPartsA = [
		"rail_1_prop_2",
		"rail_1_prop_4",
		"rail_3_prop_3",
	]
	TurnOnParts( file.framingStop1Rail, railPartsA )

	array<string> railPartsB = [
		"rail_2_prop_2",
		"rail_2_prop_4",
		"rail_4_prop_3"
	]
	TurnOffParts( file.framingStop1Rail, railPartsB )

	// delaythread(9.1) TurnOnParts( file.framingStop1Rail, railPartsA )
	// delaythread(9.1) TurnOffParts( file.framingStop1Rail, railPartsB )

	PlayGrabberSoundOnArm( file.framingStop1Arm1, "Boomtown_SmallRobotArm_FurniturePlaceA_Arm1" )
	PlayGrabberSoundOnArm( file.framingStop1Arm2, "Boomtown_SmallRobotArm_FurniturePlaceA_Arm2" )
	PlayGrabberSoundOnArm( file.framingStop1Arm3, "Boomtown_SmallRobotArm_FurniturePlaceA_Arm3" )
	PlatformAnim( platform, "wf_assemble_furniture_A_platform" )
	TurnOnParts( platform.model, [ "prop_2", "prop_4", "prop_5" ] )
	thread PlaySoundOnRail( file.framingStop1Rail, "Boomtown_RailDelivery_FurniturePlaceA", "RAIL2", animDuration )
	wait animDuration
	FlagClear( "warning_lights_furniture1" )
	//platform.activeAnim = ""

	// Move to stop 2
	MovePlatformAtSpeed( platform, file.platform_framing_stop2.origin, PLATFORM_TRACK_SPEED, 0.5, 0.5 )

	// Do anim sequence for stop 2
	FlagSet( "warning_lights_furniture2" )
	animDuration = platform.model.GetSequenceDuration( "wf_assemble_furniture_B_platform" )
	file.framingStop2Arm1.model.Anim_Play( "wf_assemble_furniture_B_arm1" )
	file.framingStop2Arm2.model.Anim_Play( "wf_assemble_furniture_B_arm2" )
	file.framingStop2Arm3.model.Anim_Play( "wf_assemble_furniture_B_arm3" )
	file.framingStop2Rail.Anim_Play( "wf_assemble_furniture_B_rail" )

	railPartsA = [
		"rail_1_prop_1",
		"rail_1_prop_5",
		"rail_3_prop_6"
	]
	TurnOnParts( file.framingStop2Rail, railPartsA )

	railPartsB = [
		"rail_2_prop_1",
		"rail_2_prop_5",
		"rail_4_prop_6"
	]
	TurnOffParts( file.framingStop2Rail, railPartsB )

	PlayGrabberSoundOnArm( file.framingStop2Arm1, "Boomtown_SmallRobotArm_FurniturePlaceB_Arm1" )
	PlayGrabberSoundOnArm( file.framingStop2Arm2, "Boomtown_SmallRobotArm_FurniturePlaceB_Arm2" )
	PlayGrabberSoundOnArm( file.framingStop2Arm3, "Boomtown_SmallRobotArm_FurniturePlaceB_Arm3" )
	PlatformAnim( platform, "wf_assemble_furniture_B_platform" )
	TurnOnParts( platform.model, [ "prop_1", "prop_6", "prop_7" ] )
	thread PlaySoundOnRail( file.framingStop2Rail, "Boomtown_RailDelivery_FurniturePlaceB", "RAIL2", animDuration )
	wait animDuration
	FlagClear( "warning_lights_furniture2" )
	//platform.activeAnim = ""

	// Move to the stomper at the 90 degree bend
	MovePlatformAtSpeed( platform, file.platform_framing_track_end.origin, PLATFORM_TRACK_SPEED, 0.5, 0.5 )

	// Stomp the press
	FlagSet( "warning_lights_steam" )
	AttachPlatformToEnt( platform, file.framingPressMover, "", true )
	file.framingPressMover.NonPhysicsMoveTo( file.platform_framing_track_end_up.origin, 2.0, 1.0, 0.0 )
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateLift_AddPropsRaise" )
	wait 2.0
	AssemblyScreenShake( file.platform_framing_track_end_up.origin )

	StartParticleEffectInWorld( GetParticleSystemIndex( SANITIZATION_EFFECT ), platform.model.GetOrigin(), platform.model.GetAngles() )

	// Swap the model
	platform.model.Code_Anim_Stop()
	ChangePlatformModel( platform, PLATFORM_MODEL_WALLS )
	WaitFrame()
	PlatformAnim( platform, "wf_assemble_prewall_idle_platform" )

	wait 0.5
	FlagClear( "warning_lights_steam" )

	// Press comes down and rotates
	EmitSoundOnEntityNoSave( platform.mover, "Boomtown_PlateLift_AddPropsLower" )
	file.framingPressMover.NonPhysicsMoveTo( file.platform_framing_track_end.origin, 2.0, 0.5, 0.5 )
	wait 0.3
	file.framingPressMover.NonPhysicsRotateTo( file.platform_framing_track_end_outfeed.angles, 1.2, 0.5, 0.5 )
	wait 1.7

	// Create the next arm that will pick it up down the line
	thread TrackWallSectionRun()

	// Move platform to the end of the outfeed for this section
	DetachPlatform( platform )
	file.framingPressMover.NonPhysicsRotateTo( file.platform_framing_track_end.angles, 1.0, 0.5, 0.5 )
	MovePlatformAtSpeed( platform, file.platform_framing_track_end_outfeed.origin, PLATFORM_TRACK_SPEED, 0.5, 0.5 )

	// Tell the next arm to pick it up now
	file.thirdHandoffPlatform = platform
	Signal( level, "FramedPlatformReadyForPickup" )
}

void function TrackWallSectionRun()
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	array<entity> nodes = GetChainOfNodesByScriptName( "platform_track_walls_start" )
	PlatformArm arm = CreateArm( ARM_MODEL, nodes[0].GetOrigin(), nodes[0].GetAngles(), true )

	// Pose arm for transport to the panel
	thread SetArmPose( arm, 90, 0, 89, -90, -63, -61, 0, 0.0 )

	// Move to the panel
	thread MoveArmForDuration( arm, nodes[1].GetOrigin(), 4.5, 0.5, 0.5 )
	wait 4.5
	thread MoveArmForDuration( arm, nodes[2].GetOrigin(), 4.5, 0.5, 0.5 )
	wait 4.5

	// Get into position to grab the panel
	thread SetArmPose( arm, 90, 0, 47, -28, -49, 40, 0, 1.0 )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_ThirdExchange_GrabPrep" )

	// Wait for there to be a platform to pick up
	WaitSignal( level, "FramedPlatformReadyForPickup" )
	Assert( IsValid( file.thirdHandoffPlatform ) )
	Platform platform = file.thirdHandoffPlatform

	// Get into gripping position and attach platform to new arm
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_ThirdExchange_GrabPlate" )
	thread SetArmPose( arm, 90, 0, 26, -49, 10, 59, 4.2, 1.0 )
	wait 1.0
	AttachPlatformToArm( platform, arm, true )

	// Lift platform off the track
	thread SetArmPose( arm, 90, 0, 52, -63, -44, 27, 4.2, 1.0 )
	wait 1.0

	// Rotate and go to first stop
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_ThirdExchange_Arm180Turn" )
	thread SetArmPose( arm, -90, 0, 52, -63, -44, 27, 4.2, 5.0 )
	thread MoveArmForDuration( arm, nodes[3].GetOrigin(), 5.0, 1.0, 1.0 )
	wait 5.0

	// Walls 1 get installed
	FlagSet( "warning_lights_walls1" )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SmallTiltUp" )
	thread SetArmPose( arm, -90, -15, 52, -63, -44, 27, 4.2, 2.0 )
	wait 2.0

	// Do anim sequence for stop 1
	float animDuration = platform.model.GetSequenceDuration( "wf_assemble_walls_A_platform" )
	file.wallsStop1Arm1.model.Anim_Play( "wf_assemble_walls_A_arm1" )
	file.wallsStop1Arm2.model.Anim_Play( "wf_assemble_walls_A_arm2" )
	file.wallsStop1Arm3.model.Anim_Play( "wf_assemble_walls_A_arm3" )
	file.wallsStop1Rail.Anim_Play( "wf_assemble_walls_A_rail" )

	array<string> railPartsA = [
		"rail_1_station_1_2",
		"rail_2_station_1_1",
		"rail_2_station_1_3",
	]
	TurnOffParts( file.wallsStop1Rail, railPartsA )

	array<string> railPartsB = [
		"rail_3_station_1_2",
		"rail_4_station_1_1",
		"rail_4_station_1_3",
	]
	TurnOnParts( file.wallsStop1Rail, railPartsB )

	PlayGrabberSoundOnArm( file.wallsStop1Arm1, "Boomtown_SmallRobotArm_WallPlaceA_Arm1" )
	PlayGrabberSoundOnArm( file.wallsStop1Arm2, "Boomtown_SmallRobotArm_WallPlaceA_Arm2" )
	PlayGrabberSoundOnArm( file.wallsStop1Arm3, "Boomtown_SmallRobotArm_WallPlaceA_Arm3" )
	PlatformAnim( platform, "wf_assemble_walls_A_platform" )
	TurnOnParts( platform.model, [ "station_1_1", "station_1_2", "station_1_3" ] )
	thread PlaySoundOnRail( file.wallsStop1Rail, "Boomtown_RailDelivery_WallPlaceA", "RAIL2", animDuration )
	wait animDuration
	FlagClear( "warning_lights_walls1" )

	// Tild platform back down to flat
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SmallTiltDown" )
	thread SetArmPose( arm, -90, 0, 52, -63, -44, 27, 4.2, 2.0 )
	wait 2.0

	// Go to second stop
	thread MoveArmForDuration( arm, nodes[4].GetOrigin(), 5.0, 1.0, 1.0 )
	wait 1.0
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_90Turn" )
	thread SetArmPose( arm, -180, 0, 52, -63, -44, 27, 4.2, 4.0 )
	wait 4.0

	// Arm tilts upward
	FlagSet( "warning_lights_walls2" )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_StairStation_MoveIn" )
	thread SetArmPose( arm, -180, 0, 22, -43, -54, 32, 4.2 , 2.0 )
	wait 2.0

	// Walls 2 get installed
	animDuration = platform.model.GetSequenceDuration( "wf_assemble_walls_B_platform" )
	file.wallsStop2Arm1.model.Anim_Play( "wf_assemble_walls_B_arm1" )
	file.wallsStop2Arm2.model.Anim_Play( "wf_assemble_walls_B_arm2" )
	file.wallsStop2Arm3.model.Anim_Play( "wf_assemble_walls_B_arm3" )
	file.wallsStop2Rail.Anim_Play( "wf_assemble_walls_B_rail" )

	railPartsA = [
		"rail_4_station_2_2",
		"rail_3_station_2_1",
	]
	TurnOnParts( file.wallsStop2Rail, railPartsA )

	railPartsB = [
		"rail_1_station_2_1",
		"rail_2_station_2_2",
	]
	TurnOffParts( file.wallsStop2Rail, railPartsB )

	PlayGrabberSoundOnArm( file.wallsStop2Arm1, "Boomtown_SmallRobotArm_WallPlaceB_Arm1" )
	PlayGrabberSoundOnArm( file.wallsStop2Arm2, "Boomtown_SmallRobotArm_WallPlaceB_Arm2" )
	PlayGrabberSoundOnArm( file.wallsStop2Arm3, "Boomtown_SmallRobotArm_WallPlaceB_Arm3" )
	thread NotSolidBoneFollowersForTime( file.wallsStop2Rail, 0.5, [ "def_c_rail_3", "def_c_rail_4" ] )
	delaythread(6) NotSolidBoneFollowersForTime( file.wallsStop2Rail, 0.5, [ "def_c_rail_1", "def_c_rail_2" ] )
	PlatformAnim( platform, "wf_assemble_walls_B_platform" )
	TurnOnParts( platform.model, [ "station_2_1", "station_2_2" ] )
	thread PlaySoundOnRail( file.wallsStop2Rail, "Boomtown_RailDelivery_WallPlaceB", "RAIL2", animDuration )
	wait animDuration - 2.0
	thread TrackWallSectionRun2()
	wait 2.0
	FlagClear( "warning_lights_walls2" )

	// Flatten the panel and rotate forward
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_StairStation_MoveOut" )
	thread SetArmPose( arm, -180, 0, 90, -49, -36, 90, 4.2, 2.0 )
	wait 2.0
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_90Turn" )
	thread SetArmPose( arm, -180, 0, 90, -49, -36, 90, 4.2, 2.0 )

	// Go to handoff
	thread MoveArmForDuration( arm, nodes[5].GetOrigin(), 7.0, 1.0, 1.0 )
	wait 4.0
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FourthHandOff_PassExtend" )
	thread SetArmPose( arm, -180, 0, 52, -63, -44, 27, 4.2, 2.0 )
	wait 3.0

	// Tell the other arm it can take this platform
	file.fourthHandoffPlatform = platform
	Signal( level, "WallAssemblyHandoffReady" )

	// Wait for platform to be offloaded
	WaitSignal( level, "WallAssemblyHandoffComplete" )

	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FourthHandOff_PassRetract" )
	thread SetArmPose( arm, -90, 0, 90, -90, -90, 90, 0, 2.5 )
	wait 1.0

	// Move empty arm away and delete
	thread MoveArmForDuration( arm, nodes[6].GetOrigin(), 5.0, 1.0, 1.0 )
	wait 5.0
	thread MoveArmForDuration( arm, nodes[7].GetOrigin(), 5.0, 1.0, 1.0 )
	wait 5.0

	DestroyArm( arm )
}

void function TrackWallSectionRun2()
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	array<entity> nodes = GetChainOfNodesByScriptName( "platform_track_walls_start2" )
	PlatformArm arm = CreateArm( ARM_MODEL, nodes[0].GetOrigin(), nodes[0].GetAngles(), true )

	// Pose arm for transport to the panel
	thread SetArmPose( arm, 90, 0, 89, -90, -63, -61, 0, 0.0 )

	// Move to the handoff position
	thread MoveArmForDuration( arm, nodes[1].GetOrigin(), 4.5, 0.5, 0.5 )
	wait 4.5
	thread MoveArmForDuration( arm, nodes[2].GetOrigin(), 4.5, 0.5, 0.5 )
	thread SetArmPose( arm, 0, 0, 89, -90, -63, -61, 0, 4.0 )
	wait 4.5

	// Wait for there to be a platform to pick up
	WaitSignal( level, "WallAssemblyHandoffReady" )
	Assert( IsValid( file.fourthHandoffPlatform ) )
	Platform platform = file.fourthHandoffPlatform

	// Get into gripping position and attach platform to new arm
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FourthHandOff_RecieveExtend" )
	thread SetArmPose( arm, 0, 0, 48, -54, -62, 24, 0, 1.5 )
	wait 1.5
	thread SetArmPose( arm, 0, 0, 48, -54, -62, 24, 4.2, 0.5 )
	wait 0.5
	DetachPlatform( platform )
	AttachPlatformToArm( platform, arm, true )

	// Tell the other arm the platform has been transfered
	Signal( level, "WallAssemblyHandoffComplete" )

	// Go to the first station
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FourthHandOff_Receive180Turn" )
	//thread SetArmPose( arm, 0,  0, 68, -54, -23, 69, 4.2, 3.0 )
	thread MoveArmForDuration( arm, nodes[3].GetOrigin(), 6.0, 0.5, 0.5 )
	wait 6.0
	thread SetArmPose( arm, -90, 0, 68, -70, 2, 64, 4.2, 3.0 )
	wait 2.0
	thread MoveArmForDuration( arm, nodes[4].GetOrigin(), 4.0, 0.5, 0.5 )
	wait 4.0

	// Position at first station and tilt
	FlagSet( "warning_lights_walls3" )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_LargeTiltUp" )
	thread SetArmPose( arm, -90, -62, 68, -70, 2, 64, 4.2, 1.5 )
	wait 1.5

	// Ceiling gets installed
	float animDuration = platform.model.GetSequenceDuration( "wf_assemble_walls_C_platform" )
	file.wallsStop3Arm1.model.Anim_Play( "wf_assemble_walls_C_arm1" )
	file.wallsStop3Arm2.model.Anim_Play( "wf_assemble_walls_C_arm2" )
	file.wallsStop3Arm3.model.Anim_Play( "wf_assemble_walls_C_arm3" )
	file.wallsStop3Rail.Anim_Play( "wf_assemble_walls_C_rail" )

	array<string> railPartsA = [
		"rail_1_station_3_3",
		"rail_1_station_3_4",
		"rail_2_station_3_1",
		"rail_2_station_3_2",
	]
	TurnOffParts( file.wallsStop3Rail, railPartsA )

	array<string> railPartsB = [
		"rail_3_station_3_3",
		"rail_3_station_3_4",
		"rail_4_station_3_1",
		"rail_4_station_3_2",
	]
	TurnOnParts( file.wallsStop3Rail, railPartsB )

	PlayGrabberSoundOnArm( file.wallsStop3Arm1, "Boomtown_SmallRobotArm_WallPlaceC_Arm1" )
	PlayGrabberSoundOnArm( file.wallsStop3Arm2, "Boomtown_SmallRobotArm_WallPlaceC_Arm2" )
	PlayGrabberSoundOnArm( file.wallsStop3Arm3, "Boomtown_SmallRobotArm_WallPlaceC_Arm3" )
	PlatformAnim( platform, "wf_assemble_walls_C_platform" )
	TurnOnParts( platform.model, [ "station_3_1", "station_3_2", "station_3_3", "station_3_4" ] )
	thread PlaySoundOnRail( file.wallsStop3Rail, "Boomtown_RailDelivery_WallPlaceC", "RAIL2", animDuration )
	wait animDuration
	FlagClear( "warning_lights_walls3" )

	// Get into normal pose to leave the station
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_LargeTiltDown" )
	thread SetArmPose( arm, -90, 0, 68, -70, 2, 64, 4.2, 1.3 )
	wait 2.0

	// Go to the second station
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_SlightForward" )
	thread SetArmPose( arm, -90, 0, 26, -39, -29, 44, 4.2, 2.0 )
	thread MoveArmForDuration( arm, nodes[5].GetOrigin(), 4.0, 0.5, 0.5 )
	wait 1.0
	thread SetArmPose( arm, 0, 0, 26, -39, -29, 44, 4.2, 3.0 )
	wait 3.0

	// Pose for second station
	FlagSet( "warning_lights_walls4" )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FinalStationLower" )
	thread SetArmPose( arm, 0 ,0 , 1, -22, 10, 73, 4.2 , 2.0 )
	wait 2.0

	// Roof and walls get installed
	animDuration = platform.model.GetSequenceDuration( "wf_assemble_walls_D_platform" )
	file.wallsStop4Arm1.model.Anim_Play( "wf_assemble_walls_D_arm1" )
	file.wallsStop4Arm2.model.Anim_Play( "wf_assemble_walls_D_arm2" )
	file.wallsStop4Arm3.model.Anim_Play( "wf_assemble_walls_D_arm3" )
	file.wallsStop4Rail.Anim_Play( "wf_assemble_walls_D_rail" )

	railPartsA = [
		"rail_1_station_4_2",
		"rail_1_station_4_3",
		"rail_2_station_4_1",
	]
	TurnOffParts( file.wallsStop4Rail, railPartsA )

	railPartsB = [
		"rail_3_station_4_2",
		"rail_3_station_4_3",
		"rail_4_station_4_1",
	]
	TurnOnParts( file.wallsStop4Rail, railPartsB )

	PlayGrabberSoundOnArm( file.wallsStop4Arm1, "Boomtown_SmallRobotArm_WallPlaceD_Arm1" )
	PlayGrabberSoundOnArm( file.wallsStop4Arm2, "Boomtown_SmallRobotArm_WallPlaceD_Arm2" )
	PlayGrabberSoundOnArm( file.wallsStop4Arm3, "Boomtown_SmallRobotArm_WallPlaceD_Arm3" )
	PlatformAnim( platform, "wf_assemble_walls_D_platform" )
	TurnOnParts( platform.model, [ "station_4_1", "station_4_2", "station_4_3" ] )
	thread PlaySoundOnRail( file.wallsStop4Rail, "Boomtown_RailDelivery_WallPlaceD", "RAIL3", animDuration )
	wait animDuration
	FlagClear( "warning_lights_walls4" )

	UpdatePlatform4ModelToRigid( platform )
	printt( "UpdatePlatform4ModelToRigid" )

	// Pull out of the station
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_FinalStationRaise" )
	thread SetArmPose( arm, 0, 0, 59, -41, -10, 90, 4.2, 1.5 )
	wait 1.5
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_90Turn" )
	thread SetArmPose( arm, -90, 0, 90, -52, -31, 90, 4.2, 2.0 )
	wait 2.0

	thread TrackHighwaySection( arm, platform )
}

void function TrackHighwaySection( PlatformArm arm, Platform platform )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	array<entity> nodes = GetChainOfNodesByScriptName( "platform_track_highway_start" )

	// Move to the highway start node
	thread MoveArmForDuration( arm, nodes[0].GetOrigin(), 5.0, 0.5, 0.5 )
	wait 3.0
	thread SetArmPose( arm, 0, 0, 90, -52, -31, 89, 4.2, 2.0 )
	wait 2.0

	// Move to first waypoint
	thread MoveArmForDuration( arm, nodes[1].GetOrigin(), 8.0, 0.5, 0.5 )
	wait 8.0

	thread TunnelCrossTracks()

	// Move down hexagon roller tunnel
	thread MoveArmForDuration( arm, nodes[2].GetOrigin(), 16.0, 3.0, 0.5 )
	wait 10.0
	thread SetArmPose( arm, 90, 0, 90, -52, -31, 89, 4.2, 6.0 )
	thread AmbientPlatformsRun_Count( "highway_merging_track", 600, 6.0, 2, ARM_MODEL, [ PLATFORM_MODEL_FRAMING, PLATFORM_MODEL_WALLS ], 0.0, 0, true )
	wait 6.0

	// Go down the long tunnel
	EmitSoundOnEntity( platform.mover, "Boomtown_RobotArmTrack_PassBy" )
	thread MoveArmForDuration( arm, nodes[3].GetOrigin(), 8.0, 2.5, 2.5 )
	wait 8.0
	thread SetArmPose( arm, 180, 0, 90, -52, -31, 89, 4.2, 10.0 )

	// If the player is on this panel we move it into the town climb, all others go to the junker
	if ( Flag( "NextPlatformEnterTownClimb" ) && !file.townClimbEntryStarted )
	{
		thread PlatformGoesToVerticalTown( arm, platform )
		file.townClimbEntryStarted = true
		return
	}

	// Player wasn't on this platform or it's behind the player, so go to the junker and delete
	entity node = GetEntByScriptName( "HighwayEndTerminatePath" )
	array<entity> linkedNodes
	bool firstMove = true
	while( true )
	{
		if ( !IsValid( node ) )
			break
		float moveTime = Distance( arm.model.GetOrigin(), node.GetOrigin() ) / 500
		float ease = firstMove ? 0.0 : min( 1.0, moveTime * 0.5 )
		firstMove = false
		thread MoveArmForDuration( arm, node.GetOrigin(), moveTime, ease, ease )
		wait moveTime
		linkedNodes = node.GetLinkEntArray()
		if ( linkedNodes.len() == 0 )
			break
		node = linkedNodes.getrandom()
	}

	// Delete the panel since this isn't the one that went into town climb
	DestroyPlatform( platform )
	DestroyArm( arm )
}

void function PlatformGoesToVerticalTown( PlatformArm arm, Platform platform )
{
	// Player is on this platform so don't ever make the arm and platform ever remove collision
	RemovePlatformFromArray( platform )
	RemovePlatformArmFromArray( arm )

	// Don't delete this entity when reaper town starts
	RemoveCleanupEnt( platform.mover )
	RemoveCleanupEnt( platform.model )

	array<entity> nodes = GetChainOfNodesByScriptName( "TownClimbEntryPath" )
	float speed = 500.0

	FlagSet( "TownClimbRowsStartAssemble" )
	FlagSet( "PlayerEnteringTownClimb" )

	// Move to track start
	float moveTime = Distance( arm.model.GetOrigin(), nodes[0].GetOrigin() ) / speed
	float ease = min( 1.0, moveTime * 0.5 )
	thread MoveArmForDuration( arm, nodes[0].GetOrigin(), moveTime, ease, ease )
	wait moveTime

	// Move into vertical town climb area
	FlagSet( "TownClimbArmStart" )
	thread MoveArmForDuration( arm, nodes[1].GetOrigin(), 23.0, 1.0, 1.0 )
	wait 19.0
	arm.mover.NonPhysicsRotateTo( <0,-180,0>, 4.0, 1.5, 1.5 )
	wait 4.0

	file.playerTownClimbPlatform = platform
	FlagSet( "TownClimbPlatformReadyToGrab" )

	FlagWait( "TownClimbPlatformTransfered" )
	UpdatePlatform4ModelToAnimated( platform )

	// Release the platform, move away and delete
	thread SetArmPose( arm, -180, 0, 90, -52, -31, 89, 0.0, 1.0 )
	thread MoveArmForDuration( arm, nodes[2].GetOrigin(), 12.0, 1.0, 0.0 )
	wait 2.0
	thread SetArmPose( arm, -180, 0, 90, -90, -90, -90, 0.0, 1.0 )
	wait 1.0
	thread SetArmPose( arm, -180, 90, 90, -90, -90, -90, 0.0, 1.0 )
	wait 9.0
	DestroyArm( arm )
}

void function TunnelCrossTracks()
{
	wait 5.0
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_1", 1.0, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_DIRT_SKYBOX ], 	 0.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_2", 1.4, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_FRAMING_SKYBOX ], 0.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_3", 1.2, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_DIRT_SKYBOX ], 	 0.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_3", 1.2, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_WALLS_SKYBOX ], 	 4.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_4", 1.5, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_FRAMING_SKYBOX ], 6.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_8", 1.4, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_DIRT_SKYBOX ], 	 9.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_7", 1.0, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_FRAMING_SKYBOX ], 10.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
	thread AmbientPlatformsRun_Count( "highway_cross_track_vista_4", 1.5, 0, 1, ARM_MODEL_SKYBOX, [ PLATFORM_MODEL_WALLS_SKYBOX ], 	 11.0, 0, 	false, "Boomtown_RobotArmTrack_PassBy" )
}

void function AmbientPlatforms()
{
	thread AmbientPlatformsRun_Flag( "ambient_track_1", 400, 6.0, "AmbientPlatformsStartEnabled", ARM_MODEL_AMBIENT_1, [ PLATFORM_MODEL_AMBIENT_1 ], 0.0, -1, false )
	thread AmbientPlatformsRun_Flag( "ambient_track_2", 450, 4.5, "AmbientPlatformsAboveGrassEnabled", ARM_MODEL_AMBIENT_1, [ PLATFORM_MODEL_AMBIENT_1 ], 0.0, -1, false )
	thread AmbientPlatformsRun_Flag( "ambient_track_3", 300, 8.0, "AmbientPlatformsAboveGrassEnabled", ARM_MODEL_AMBIENT_1, [ PLATFORM_MODEL_AMBIENT_1 ], 0.0, -1, false )

	thread AmbientPlatformsRun_Flag( "ambient_track_4", 400, 10.0, "AmbientPlatformsWallsStartEnabled", ARM_MODEL_AMBIENT_2, [ PLATFORM_MODEL_AMBIENT_2 ], 1.0, -1, false )
	thread AmbientPlatformsRun_Flag( "ambient_track_5", 400, 10.0, "AmbientPlatformsWallsStartEnabled", ARM_MODEL_AMBIENT_2, [ PLATFORM_MODEL_AMBIENT_2 ], 0.0, -1, false )
	thread AmbientPlatformsRun_Flag( "ambient_track_6", 400, 4.0, "AmbientPlatformsTownClimbEntranceEnabled", ARM_MODEL_AMBIENT_2, [ PLATFORM_MODEL_AMBIENT_2, PLATFORM_MODEL_AMBIENT_1 ], 0.0, -1, false )
}

void function AmbientPlatformsRun_Flag( string startNodeScriptName, float speed, float rate, string flag, asset armModel, array<asset> platformModels, float startDelay, int poseIndex, bool collisionEnabled, string loopSound = "" )
{
	// Runs continuous ambient platforms while the flag is set
	Assert( rate > 0.0 )
	Assert( speed > 0.0 )
	Assert( flag != "" )
	Assert( FlagExists( flag ) )
	Assert( platformModels.len() > 0 )
	Assert( startDelay >= 0.0 )

	wait startDelay

	while( true )
	{
		if ( !Flag( flag ) )
			FlagWait( flag )
		thread CreateAmbientPlatformAndMove( startNodeScriptName, speed, armModel, platformModels, poseIndex, collisionEnabled, loopSound )
		wait rate
	}
}

void function AmbientPlatformsRun_Count( string startNodeScriptName, float speed, float rate, int count, asset armModel, array<asset> platformModels, float startDelay, int poseIndex, bool collisionEnabled, string loopSound = "" )
{
	// Runs continuous ambient platforms until the count is reached
	Assert( speed > 0.0 )
	Assert( platformModels.len() > 0 )
	Assert( startDelay >= 0.0 )

	wait startDelay

	for ( int i = 0 ; i < count ; i++ )
	{
		thread CreateAmbientPlatformAndMove( startNodeScriptName, speed, armModel, platformModels, poseIndex, collisionEnabled, loopSound )

		if ( rate > 0 )
			wait rate
		else
			WaitFrame()
	}
}

void function CreateAmbientPlatformAndMove( string startNodeScriptName, float speed, asset armModel, array<asset> platformModels, int poseIndex, bool collisionEnabled, string loopSound = "" )
{
	entity startNode = GetEntByScriptName( startNodeScriptName )
	asset modelName = platformModels.getrandom()

	PlatformArm arm = CreateArm( armModel, startNode.GetOrigin(), startNode.GetAngles(), false )
	int platformCollision = collisionEnabled ? SOLID_HITBOXES : 0
	if ( armModel == ARM_MODEL_SKYBOX )
		arm.model.DisableHibernation()
	entity platform = CreatePropDynamic( modelName, startNode.GetOrigin(), startNode.GetAngles(), platformCollision )
	platform.SetParent( arm.model, "platform", false )
	AddCleanupEnt( platform )

	platform.PhysicsDummyEnableMotion( collisionEnabled )
	arm.model.PhysicsDummyEnableMotion( collisionEnabled )
	// Hide the models while attaching and doing poses. Gets shown below after a wait frame
	arm.model.Hide()
	platform.Hide()

	EndSignal( arm.mover, "OnDestroy" )
	EndSignal( arm.model, "OnDestroy" )
	EndSignal( platform, "OnDestroy" )

	switch( modelName )
	{
		case PLATFORM_MODEL_DIRT_SKYBOX:
			platform.DisableHibernation()
		case PLATFORM_MODEL_DIRT:
			TurnOnParts( platform, [ "dirt", "grass_1", "grass_2", "grass_3", "grass_4", "grass_5", "grass_6", "grass_7", "grass_8" ] )
			break
		case PLATFORM_MODEL_WALLS_SKYBOX:
			platform.DisableHibernation()
		case PLATFORM_MODEL_WALLS:
			TurnOnParts( platform, [ "station_1_1", "station_1_2", "station_1_3" ] )
			TurnOnParts( platform, [ "station_2_1", "station_2_2" ] )
			TurnOnParts( platform, [ "station_3_1", "station_3_2", "station_3_3", "station_3_4" ] )
			TurnOnParts( platform, [ "station_4_1", "station_4_2", "station_4_3" ] )
			break
		case PLATFORM_MODEL_FRAMING_SKYBOX:
			platform.DisableHibernation()
			break
	}

	switch( poseIndex )
	{
		case 0:
			SetArmPose( arm, 90, 90, -90, 71, 90, 90, 0, 0.0 )
			break
		case 1:
			SetArmPose( arm, 90, 90, -90, 76, 21, -90, 0, 0.0 )
			break
	}

	WaitFrame()

	arm.model.Show()
	platform.Show()

	thread PlatformAndArmMoveNodesAndDestroy( arm, platform, startNodeScriptName, speed, loopSound )
}

void function PlatformAndArmMoveNodesAndDestroy( PlatformArm arm, entity platform, string startNodeScriptName, float speed, string loopSound )
{
	// Move down the track and delete
	float moveTime
	vector pos
	float ease

	array<entity> nodes
	entity node = GetEntByScriptName( startNodeScriptName )
	array<entity> linkedNodes
	entity nextNode
	while( true )
	{
		linkedNodes = node.GetLinkEntArray()

		if ( linkedNodes.len() == 0 )
		{
			break
		}
		else if ( linkedNodes.len() == 1 )
		{
			nextNode = linkedNodes[0]
		}
		else
		{
			if ( !( node in file.switchTrackLastIndex ) )
				file.switchTrackLastIndex[ node ] <- -1
			file.switchTrackLastIndex[ node ]++
			if ( file.switchTrackLastIndex[ node ] >= linkedNodes.len() )
				file.switchTrackLastIndex[ node ] = 0
			nextNode = linkedNodes[ file.switchTrackLastIndex[ node ] ]
		}
		nodes.append( nextNode )
		node = nextNode
	}

	if ( loopSound != "" && PlayerCanHearEnt( arm.mover ) )
		EmitSoundOnEntityNoSave( arm.mover, loopSound )

	foreach( int i, entity node in nodes )
	{
		if ( !IsValid( arm.model ) || !IsValid( arm.mover ) )
			return
		pos = node.GetOrigin()
		moveTime = Distance( arm.model.GetOrigin(), pos ) / speed
		ease = min( 0.5, moveTime * 0.5 )
		thread MoveArmForDuration( arm, pos, moveTime, ease, ease )
		wait moveTime
	}

	if ( loopSound != "" && IsValid( arm.model ) )
		StopSoundOnEntity( arm.model, loopSound )

	if ( IsValid( platform ) )
		platform.Destroy()
	DestroyArm( arm )
}

void function HighwayRollers()
{
	array<entity> highway_rollers = GetEntArrayByScriptName( "highway_rollers" )
	foreach( entity node in highway_rollers )
		thread HighwayRollerThink( node )
}

void function HighwayRollerThink( entity node )
{
	EndSignal( node, "OnDestroy" )

	array<entity> rollers = node.GetLinkEntArray()
	Assert( rollers.len() >= 2 )

	array<entity> movers
	array<entity> platforms
	vector centerPoint
	int numRollers = rollers.len()
	float rotateDegrees = 360 / float( numRollers )

	foreach( entity roller in rollers )
	{
		entity mover = CreateScriptMover( roller.GetOrigin(), <0,0,0>, 0 )

		EndSignal( mover, "OnDestroy" )

		AddCleanupEnt( mover )
		mover.NonPhysicsSetRotateModeLocal( true )
		centerPoint += roller.GetOrigin()
		entity geo = roller.GetLinkEnt()
		platforms.append( geo )
		geo.SetParent( mover, "", true )
		movers.append( mover )
		roller.Destroy()
	}

	centerPoint /= numRollers
	entity centerMover = CreateScriptMover( centerPoint, <0,0,0>, 0 )
	AddCleanupEnt( centerMover )

	while( true )
	{
		// Wait random amount of time before doing anything
		wait RandomFloatRange( 5.0, 10.0 )

		EmitSoundOnEntityNoSave( centerMover, "Boomtown_AssemblyPillarRoll_Start" )

		// Move away from center
		foreach( entity mover in movers )
		{
			vector outDir = Normalize( mover.GetOrigin() - centerMover.GetOrigin() )
			vector outPos = mover.GetOrigin() + ( outDir * HIGHWAY_ROLLER_SEPARATE_DIST )
			mover.NonPhysicsMoveTo( outPos, HIGHWAY_ROLLER_SEPARATE_TIME, HIGHWAY_ROLLER_SEPARATE_TIME * 0.5, HIGHWAY_ROLLER_SEPARATE_TIME * 0.5 )
		}
		wait HIGHWAY_ROLLER_SEPARATE_TIME

		// Attach all movers to the center spinner
		centerMover.SetAngles( <0,0,0> )
		foreach( entity mover in movers )
			mover.SetParent( centerMover, "", true )

		int maxRotations = numRollers - 1
		int rotations = maxRotations > 1 ? RandomIntRange( 1, maxRotations ) : 1

		// Rotate the rollers around the center point
		for ( int i = 1 ; i <= rotations ; i++ )
		{
			vector ang = < rotateDegrees * i, 0, 0 >
			float rotateTime = rotateDegrees / HIGHWAY_ROLLERS_SHUFFLE_SPEED
			float easeIn = i == 1 ? rotateTime * 0.5 : 0.0
			float easeOut = i == rotations ? rotateTime * 0.5 : 0.0
			centerMover.NonPhysicsRotateTo( ang, rotateTime, easeIn, easeOut )
			wait rotateTime
		}

		// Unlink movers from center spinner
		foreach( entity mover in movers )
			mover.ClearParent()

		// Get the panels back to nearest angle divisible by 60
		foreach( entity mover in movers )
			mover.NonPhysicsRotateTo( < -60 * rotations, 0, 0 >, 3.0, 0.5, 0.5 )
		wait 2.0

		// Move platforms back into each other
		foreach( entity mover in movers )
		{
			vector outDir = Normalize( mover.GetOrigin() - centerMover.GetOrigin() )
			vector outPos = mover.GetOrigin() + ( outDir * -HIGHWAY_ROLLER_SEPARATE_DIST )
			mover.NonPhysicsMoveTo( outPos, HIGHWAY_ROLLER_SEPARATE_TIME, HIGHWAY_ROLLER_SEPARATE_TIME * 0.5, HIGHWAY_ROLLER_SEPARATE_TIME * 0.5 )
		}
		wait HIGHWAY_ROLLER_SEPARATE_TIME

		StopSoundOnEntity( centerMover, "Boomtown_AssemblyPillarRoll_Start" )
		EmitSoundOnEntityNoSave( centerMover, "Boomtown_AssemblyPillarRoll_Stop" )
	}
}

void function DirtPressEffect()
{
	array<entity> ents = GetEntArrayByScriptName( "dirt_press_effect" )
	int particleSystemIndex = GetParticleSystemIndex( DIRT_PRESS_EFFECT )
	array<entity> fxHandles
	foreach( entity ent in ents )
		fxHandles.append( StartParticleEffectInWorld_ReturnEntity( particleSystemIndex, ent.GetOrigin(), ent.GetAngles() ) )
	wait 3.0
	fxHandles.randomize()
	foreach( entity fxHandle in fxHandles )
	{
		EffectStop( fxHandle )
		wait 0.05
	}
}

void function GrassGrinderEffects()
{
	array<entity> ents = GetEntArrayByScriptName( "grass_grinder_effect" )
	ents.reverse()
	int particleSystemIndex = GetParticleSystemIndex( GRASS_GRINDER_EFFECT )
	float endTime = Time() + 9.5
	int i = 0
	while( Time() <= endTime )
	{
		StartParticleEffectInWorld( particleSystemIndex, ents[i].GetOrigin(), <0,0,0> )
		i++
		if ( i >= ents.len() )
			i = 0
		wait 0.2
	}
}

void function TownClimbPieceGetsPlaced( entity player )
{
	svGlobal.levelEnt.EndSignal( "ReapertownStarting" )

	entity railModel = GetEntByScriptName( "town_climb_lower_rail" )
	entity railOriginEnt = GetEntByScriptName( "town_climb_lower_rail_origin" )
	entity railArmOriginEnt = GetEntByScriptName( "town_climb_lower_rail_arm_attach" )
	entity railEndLeft = GetEntByScriptName( "town_climb_lower_rail_left" )
	entity railEndRight = GetEntByScriptName( "town_climb_lower_rail_right" )
	entity finalPositionOriginEnt = GetEntByScriptName( "final_platform_position_for_town_climb" )
	Point finalPositionOrigin
	finalPositionOrigin.origin = finalPositionOriginEnt.GetOrigin()
	finalPositionOrigin.angles = finalPositionOriginEnt.GetAngles()
	finalPositionOriginEnt.Destroy()
	entity playerArmStopNode = GetEntByScriptName( "town_climb_player_platform_track_stop" )
	entity armPickupPosEnt = GetEntByScriptName( "town_climb_lower_rail_arm_pickup_pos" )
	entity neighborPlatform = GetEntByScriptName( "neighbor_town_climb_platform" )
	entity neighborPlatformOriginEnt = GetEntByScriptName( "neighbor_town_climb_platform_final_position" )
	entity neighborPlatformMover = CreateScriptMover( neighborPlatformOriginEnt.GetOrigin(), neighborPlatformOriginEnt.GetAngles() )
	neighborPlatform.SetParent( neighborPlatformMover, "", true )
	neighborPlatformMover.SetOrigin( < -10079, -4363, 2550> )
	entity rowMover = GetEntByScriptName( "townclimb_mover1" )

	// Create arm and rail mover
	PlatformArm arm = CreateArm( ARM_MODEL, railArmOriginEnt.GetOrigin(), railArmOriginEnt.GetAngles(), true )
	entity railMover = CreateScriptMover( railOriginEnt.GetOrigin(), railOriginEnt.GetAngles() )
	AddCleanupEnt( railMover )

	// Link arm to the rail and the rail to the mover
	arm.mover.SetParent( railModel, "", true )
	railModel.SetParent( railMover, "", true )

	//##############################################
	// SEQUENCE READY
	//##############################################

	// Arm starts as if it just inserted the second neighboring platform
	railMover.SetOrigin( railEndRight.GetOrigin() )
	SetArmPose( arm, 0, 0, -72, 90, 12, 19, 0, 0.0 )

	FlagWait( "TownClimbArmStart" )

	//##############################################
	// SEQUENCE BEGIN
	//##############################################

	// Pull out from the second neighboring platform
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_LowHouseArm_RetractFirst" )
	thread SetArmPose( arm, 0, 0, -90, 45, 87, 64, 0, 1.0 )
	wait 1.0

	// Go pick up the neighbor platform from out of sight location
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Backward" )
	railMover.NonPhysicsMoveTo( railEndLeft.GetOrigin(), 6.0, 1.5, 1.5 )
	arm.mover.NonPhysicsMoveTo( armPickupPosEnt.GetOrigin(), 6.0, 1.5, 1.5 )
	wait 1.0
	thread SetArmPose( arm, 178, -180, -33, 90, 78, 58, 0, 4.0 )
	wait 5.0
	StopSoundOnEntity( railMover, "Boomtown_Sideways_LowerArmTrack_Backward" )
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Stop" )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_LowHouseArm_FirstHouseGrab" )

	// Show the neighbor platform and attach it to the arm
	neighborPlatformMover.SetParent( arm.model, "platform", false )

	// Wait a bit to seem like it picked something up not instantly
	wait 1.5

	// Rail slides closer to the town
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Forward" )
	railMover.NonPhysicsMoveTo( railEndRight.GetOrigin(), 9.0, 1.5, 1.5 )

	// Arm moves along the rail to the neighbor platform insert position
	arm.mover.NonPhysicsMoveTo( <railEndRight.GetOrigin().x, neighborPlatformOriginEnt.GetOrigin().y, arm.model.GetOrigin().z>, 9.0, 1.5, 1.5 )

	// Arm moves neightbor platform to right position to insert
	thread SetArmPose( arm, 0, 0, -90, 76, 50, 43, 0, 5.0 )
	wait 7.0

	// Arm puts platform into place and platform moves into exact right spot
	thread SetArmPose( arm, 0, 0, -72, 90, 12, 19, 0, 2.0 )
	wait 1.0
	neighborPlatformMover.ClearParent()
	neighborPlatformMover.NonPhysicsMoveTo( neighborPlatformOriginEnt.GetOrigin(), 1.0, 0.0, 0.5 )
	neighborPlatformMover.NonPhysicsRotateTo( neighborPlatformOriginEnt.GetAngles(), 1.0, 0.0, 0.5 )
	wait 1.0
	StopSoundOnEntity( railMover, "Boomtown_Sideways_LowerArmTrack_Forward" )
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Stop" )

	// Attach it to the row
	neighborPlatformMover.SetParent( rowMover, "", true )

	// Pull out from the platform
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_LowHouseArm_RetractSecond" )
	thread SetArmPose( arm, 0, 0, -90, 45, 87, 64, 0, 1.0 )
	wait 1.0

	// Rail and arm move back away from town so it can reach the players platform
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Backward" )
	railMover.NonPhysicsMoveTo( railEndLeft.GetOrigin(), 3.0, 1.5, 1.5 )
	arm.mover.NonPhysicsMoveTo( <railEndLeft.GetOrigin().x, neighborPlatformOriginEnt.GetOrigin().y, arm.model.GetOrigin().z>, 3.0, 1.5, 1.5 )
	wait 1.0
	// Arm gets into position to grab the players platform
	thread SetArmPose( arm, 0, 0, -87, 23, 69, -62, 0, 2.0 )
	wait 2.0
	StopSoundOnEntity( railMover, "Boomtown_Sideways_LowerArmTrack_Backward" )
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Stop" )

	// Arm slides down the rail into position to grab players platform
	arm.mover.NonPhysicsMoveTo( <railEndLeft.GetOrigin().x, finalPositionOrigin.origin.y, arm.model.GetOrigin().z>, 1.5, 0.5, 0.5 )
	wait 1.5

	// Wait for the player's platform to be ready and in position
	FlagWait( "TownClimbPlatformReadyToGrab" )

	// Slide in and grab platform
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_LowHouseArm_SecondHouseGrab" )
	thread SetArmPose( arm, 0, 0, -70, 49, 59, -41, 0, 1.5 )
	wait 1.5
	AttachPlatformToArm( file.playerTownClimbPlatform, arm, true )

	FlagSet( "TownClimbPlatformTransfered" )
	StopMusicTrack( "music_boomtown_12_assembly_highway" )
	PlayMusic( "music_boomtown_13_townclimb_buildingtipsup" )

	// Arm and rail position platform to underneith the correct spot
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_LowHouseArm_SecondHousePlace" )
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Forward" )
	thread SetArmPose( arm, 0, 0, -90, 76, 50, 43, 0, 5.0 )
	arm.mover.NonPhysicsMoveTo( <railEndRight.GetOrigin().x, finalPositionOrigin.origin.y, arm.model.GetOrigin().z>, 5.0, 1.5, 1.5 )
	railMover.NonPhysicsMoveTo( railEndRight.GetOrigin(), 5.0, 1.5, 1.5 )
	wait 5.0
	StopSoundOnEntity( railMover, "Boomtown_Sideways_LowerArmTrack_Forward" )
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Stop" )

	// Arm puts platform into place and platform moves into exact right spot
	thread SetArmPose( arm, 0, 0, -72, 90, 12, 19, 0, 2.0 )
	wait 1.0
	DetachPlatform( file.playerTownClimbPlatform )
	thread MovePlatformForDuration( file.playerTownClimbPlatform, finalPositionOrigin.origin, 1.0, 0.0, 0.5, false )
	thread RotatePlatform( file.playerTownClimbPlatform, finalPositionOrigin.angles, 1.0, 0.0, 0.5 )
	wait 1.0

	// Attach player house to main row
	AttachPlatformToEnt( file.playerTownClimbPlatform, rowMover, "", true )

	FlagSet( "TownClimbBegin" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, DOME_BATTLE_SOUND_POS, "Boomtown_Emit_DomeBattle" )

	thread TownClimbMusic()

	// Pull out from the platform and retract the arm away from the town climb
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_LowHouseArm_RetractThird" )
	thread SetArmPose( arm, 0, 0, -90, 45, 87, 64, 0, 1.0 )
	wait 1.0
	thread SetArmPose( arm, 0, 0, -87, 23, 69, -62, 0, 2.0 )
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Backward" )
	railMover.NonPhysicsMoveTo( railEndLeft.GetOrigin(), 5.0, 1.5, 1.5 )
	wait 5.0
	StopSoundOnEntity( railMover, "Boomtown_Sideways_LowerArmTrack_Backward" )
	EmitSoundOnEntityNoSave( railMover, "Boomtown_Sideways_LowerArmTrack_Stop" )

	// Pilot, scans indicate the dome above is your best course of action to find an exit. I recommend getting there by any means neccessary.
	waitthread PlayDialogue( "BT_ANY_MEANS_NECCESSARY", player )

	Objective_Set( "#BOOMTOWN_OBJECTIVE_TOWN_CLIMB", GetEntByScriptName("town_climb_objective").GetOrigin() )
}

void function TownClimbMusic()
{
	FlagEnd( "TownClimbComplete" )
	FlagWait( "PlayerExitedTownClimbHouse" )
	StopMusicTrack( "music_boomtown_13_townclimb_buildingtipsup" )
	PlayMusic( "music_boomtown_14_townclimb_outoftheroof" )
}

void function TownClimbSectionsAssemble()
{
	// Nodes
	file.node_enter = GetEntByScriptName( "boomtown_track_enter" )
	file.node_elbow = GetEntByScriptName( "boomtown_track_elbow" )
	file.node_junction1A = GetEntByScriptName( "boomtown_track_junction1A" )
	file.node_junction1B = GetEntByScriptName( "boomtown_track_junction1B" )
	file.node_junction2A = GetEntByScriptName( "boomtown_track_junction2A" )
	file.node_junction2B = GetEntByScriptName( "boomtown_track_junction2B" )

	// Movers
	entity mover2 = GetEntByScriptName( "townclimb_mover2" )
	entity mover3 = GetEntByScriptName( "townclimb_mover3" )
	entity mover4 = GetEntByScriptName( "townclimb_mover4" )
	entity mover5 = GetEntByScriptName( "townclimb_mover5" )
	entity mover6 = GetEntByScriptName( "townclimb_mover6" )

	vector finalPosRow2 = mover2.GetOrigin()
	vector finalPosRow3 = mover3.GetOrigin()
	vector finalPosRow4 = mover4.GetOrigin()
	vector finalPosRow5 = mover5.GetOrigin()
	vector finalPosRow6 = mover6.GetOrigin()

	mover2.SetOrigin( file.node_enter.GetOrigin() )
	mover2.SetAngles( <0,90,180> )
	mover3.SetOrigin( file.node_enter.GetOrigin() )
	mover3.SetAngles( <0,90,180> )
	mover4.SetOrigin( file.node_enter.GetOrigin() )
	mover4.SetAngles( <0,90,180> )
	mover5.SetOrigin( file.node_enter.GetOrigin() )
	mover5.SetAngles( <0,90,180> )
	mover6.SetOrigin( file.node_enter.GetOrigin() )
	mover6.SetAngles( <0,90,180> )

	//##############################################
	// SEQUENCE READY
	//##############################################

	FlagWait( "TownClimbRowsStartAssemble" )

	thread TownClimbAssemble_Row2( mover2, finalPosRow2 )
	thread TownClimbAssemble_Row3( mover3, finalPosRow3 )
	thread TownClimbAssemble_Row4( mover4, finalPosRow4 )
	thread TownClimbAssemble_Row5( mover5, finalPosRow5 )
	thread TownClimbAssemble_Row6( mover6, finalPosRow6 )
}

void function TownClimbAssemble_Row2( entity mover, vector finalPos )
{
	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_FastTrack_1" )
	mover.NonPhysicsMoveTo( file.node_elbow.GetOrigin(), 8.0, 0.0, 0.5 )
	wait 8.0
	mover.NonPhysicsMoveTo( file.node_junction1B.GetOrigin(), 4.0, 1.0, 1.0 )
	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_RotateAndPlace_1" )
	mover.NonPhysicsRotateTo( <0,90,90>, 4.0, 1.0, 0.0 )
	wait 4.0
	mover.NonPhysicsMoveTo( file.node_junction2B.GetOrigin(), 4.0, 1.0, 1.0 )
	mover.NonPhysicsRotateTo( <0,90,0>, 4.0, 0.0, 1.0 )
	wait 4.0
	mover.NonPhysicsMoveTo( finalPos, 3.0, 1.0, 1.0 )
	wait 3.0
}

void function TownClimbAssemble_Row3( entity mover, vector finalPos )
{
	// Create arm
	PlatformArm arm = CreateArm( ARM_MODEL, GetEntByScriptName("boomtown_climb_arm_2_right").GetOrigin(), <0,90,0>, true )

	// Get the platform
	entity platformMover = GetEntByScriptName( "row_3_platform" )

	// Remember where the platform needs to end up final position
	Point platformFinalPos
	platformFinalPos.origin = platformMover.GetOrigin()
	platformFinalPos.angles = platformMover.GetAngles()
	vector placePiecePos = < arm.model.GetOrigin().x, platformFinalPos.origin.y, arm.model.GetOrigin().z >

	platformMover.SetParent( arm.model, "platform", false )
	WaitFrame()

	// Starting pose with platform
	SetArmPose( arm, -120, -180, -90, 80, 86, -12, 0, 0.0 )

	// Wait for time to do this sequence
	wait 5.0

	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_FastTrack_2" )

	// Move platform to the junctions
	mover.NonPhysicsMoveTo( file.node_elbow.GetOrigin(), 8.0, 0.0, 0.5 )
	wait 8.0

	// Move platform row into position
	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_RotateAndPlace_2" )
	mover.NonPhysicsMoveTo( file.node_junction1B.GetOrigin(), 4.0, 1.0, 1.0 )
	mover.NonPhysicsRotateTo( <0,90,90>, 4.0, 1.0, 0.0 )
	wait 4.0

	// Move arm into partial position
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_UpperHouseArm_HouseGrab" )
	thread MoveArmForDuration( arm, placePiecePos, 4.0, 1.0, 1.0 )
	thread SetArmPose( arm, 0 , 0 , -23 , 2 , 35 , -20 , 0 , 4.0 )

	// Continue moving platform row into position
	mover.NonPhysicsMoveTo( file.node_junction2B.GetOrigin(), 4.0, 1.0, 1.0 )
	mover.NonPhysicsRotateTo( <0,90,0>, 4.0, 0.0, 1.0 )
	wait 4.0

	// Make sure row piece gets into exact position
	mover.NonPhysicsMoveTo( finalPos, 0.5, 0.25, 0.25 )

	// Put the piece in place
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_UpperHouseArm_HousePlace" )
	thread SetArmPose( arm, 0, 0, -28, -4, 23, -2, 0, 2.0 )
	wait 2.0

	// Put the platform into perfect position
	platformMover.ClearParent()
	platformMover.NonPhysicsMoveTo( platformFinalPos.origin, 1.5, 0.5, 0.5 )
	platformMover.NonPhysicsRotateTo( platformFinalPos.angles, 1.5, 0.5, 0.5 )
	wait 1.5

	// Attach platform to the big row so it moves with it into the boomtown
	platformMover.SetParent( mover, "", true )

	// Arm poses out of the way for next pieces to move in
	wait 2.0
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_UpperHouseArm_RetractFold" )
	thread SetArmPose( arm, 0, 0, -90, 90, 90, -37, 0, 1.5 )
	wait 4.0
	thread SetArmPose( arm, 0, 0, 90, 68, -90, -21, 0, 1.5 )

	// Final resting position for player to walk on it
	FlagWait( "TownClimbArm1PositionForClimb" )
	thread MoveArmForDuration( arm, GetEntByScriptName( "boomtown_climb_arm_2" ).GetOrigin(), 3.0, 1.0, 1.0 )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_UpperHouseArm_MoveToRest" )
	thread SetArmPose( arm, 6, 76, 23, 4, 36, 62, 0, 3.0 )

	FlagWait( "TownClimbGeoMovingUp" )
	thread SetArmPose( arm, 0, 0, 90, 72, -90, -24, 0, 3.0 )
}

void function TownClimbAssemble_Row4( entity mover, vector finalPos )
{
	wait 18

	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_FastTrack_3" )

	mover.NonPhysicsMoveTo( file.node_elbow.GetOrigin(), 8.0, 0.0, 0.5 )
	wait 8.0
	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_RotateAndPlace_3" )
	mover.NonPhysicsMoveTo( file.node_junction1A.GetOrigin(), 1.5, 0.5, 0.5 )
	mover.NonPhysicsRotateTo( <0,90,90>, 1.5, 1.0, 0.0 )
	wait 1.5
	mover.NonPhysicsMoveTo( file.node_junction2A.GetOrigin(), 4.0, 1.0, 1.0 )
	mover.NonPhysicsRotateTo( <0,90,0>, 4.0, 0.0, 1.0 )
	wait 4.0
	mover.NonPhysicsMoveTo( finalPos, 3.0, 1.0, 1.0 )
	wait 3.0
}

void function TownClimbAssemble_Row5( entity mover, vector finalPos )
{
	// This arm comes in just after the platform and player needs to climb on it to progress
	PlatformArm arm = CreateArm( ARM_MODEL, file.node_enter.GetOrigin(), <0,0,-90>, true )
	thread SetArmPose( arm, 0, 0, 90, -90, -90, -90, 0.0, 0.0 )

	wait 29.0

	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_FastTrack_4" )

	mover.NonPhysicsMoveTo( file.node_elbow.GetOrigin(), 8.0, 0.0, 0.5 )
	wait 3.0
	thread MoveArmForDuration( arm, file.node_elbow.GetOrigin(), 9.0, 0.0, 0.5 )
	wait 5.0
	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_RotateAndPlace_4" )
	mover.NonPhysicsMoveTo( file.node_junction1A.GetOrigin(), 1.5, 0.5, 0.5 )
	mover.NonPhysicsRotateTo( <0,90,90>, 1.5, 1.0, 0.0 )
	wait 1.5
	mover.NonPhysicsMoveTo( file.node_junction2A.GetOrigin(), 4.0, 1.0, 1.0 )
	mover.NonPhysicsRotateTo( <0,90,0>, 2.5, 0.0, 1.0 )
	wait 4.0
	thread MoveArmForDuration( arm, GetEntByScriptName( "boomtown_climb_arm_1" ).GetOrigin(), 4.0, 1.0, 1.0 )
	EmitSoundOnEntityNoSave( arm.mover, "Boomtown_RobotArm_Sideways_MiddleHouseArm_MoveToRest" )
	thread SetArmPose( arm, -11, 24, 7, -36, 1, -90, 0, 3.0 )
	FlagSet( "TownClimbArm1PositionForClimb" )
	mover.NonPhysicsMoveTo( finalPos, 0.5, 0.25, 0.25 )
	wait 0.5

	FlagWait( "TownClimbGeoMovingUp" )
	thread MoveArmForDuration( arm, GetEntByScriptName( "boomtown_track_junction1B" ).GetOrigin(), 3.0, 1.0, 1.0 )
	thread SetArmPose( arm, 0, 0, 90, -90, -90, -90, 0, 3.0 )
}

void function TownClimbAssemble_Row6( entity mover, vector finalPos )
{
	wait 23.0
	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_FastTrack_5" )

	mover.NonPhysicsMoveTo( file.node_elbow.GetOrigin(), 8.0, 0.0, 0.5 )
	wait 8.0
	EmitSoundOnEntityNoSave( mover, "Boomtown_Sideways_FloorPiece_Entrance_RotateAndPlace_5" )
	mover.NonPhysicsMoveTo( file.node_junction1A.GetOrigin(), 1.5, 0.5, 0.5 )
	mover.NonPhysicsRotateTo( <0,90,90>, 1.5, 1.0, 0.0 )
	wait 1.5
	mover.NonPhysicsMoveTo( file.node_junction2A.GetOrigin(), 4.0, 1.0, 1.0 )
	mover.NonPhysicsRotateTo( <0,90,0>, 4.0, 0.0, 1.0 )
	wait 4.0
	mover.NonPhysicsMoveTo( finalPos, 3.0, 1.0, 1.0 )
	wait 3.0
}

void function BoomtownDisassemble()
{
	array<entity> movers
	array<entity> effectEnts
	for ( int i = 1 ; i <= 6 ; i++ )
	{
		entity mover = GetEntByScriptName( "boomtown_above_mover_" + i )
		Assert( IsValid( mover ) )
		movers.append( mover )

		entity effectEnt = GetEntByScriptName( "boomtown_above_geo_effect_ent_" + i )
		Assert( IsValid( effectEnt ) )
		effectEnts.append( effectEnt )

		effectEnt.SetParent( mover, "", true )
	}

	FlagWait( "BoomtownDisassemble" )

	GetEntByScriptName( "townclimb_arm1_collision" ).NotSolid()

	StopSoundAtPosition( DOME_BATTLE_SOUND_POS, "Boomtown_Emit_DomeBattle" )

	//for ( int i = 0 ; i <= 5 ; i++ )
	int index = 1
	for ( int i = 5 ; i >= 0 ; i-- )
	{
		float delay = ( 5 - i ) * 5.0
		thread BoomtownDisassembleRow( movers[i], delay, index, effectEnts[i] )
		index++
	}
}

void function BoomtownDisassembleRow( entity mover, float delay, int index, entity effectEnt )
{
	array<entity> nodes = GetChainOfNodesLinked( mover )
	wait delay

	// Move down and rotate
	entity soundEmitter = CreateScriptMover( mover.GetOrigin() - <0,4300,0>, mover.GetAngles(), 0  )
	soundEmitter.SetParent( mover, "", true )
	AddCleanupEnt( soundEmitter )

	if ( index < 3 )
	{
		float rumbleAmplitude = 300.0
		float rumbleFrequency = 30
		float rumbleDuration = 30.0
		entity rumbleHandle = CreateShakeRumbleOnly( soundEmitter.GetOrigin(), rumbleAmplitude, rumbleFrequency, rumbleDuration, 8000 )
		rumbleHandle.SetParent( soundEmitter, "", false )
	}

	EmitSoundOnEntityNoSave( soundEmitter, "Boomtown_Sideways_FloorPiece_Exit_LowerRotate_" + index )
	if ( index < 6 )
		thread SetFlagForDuration( "BoomtownDisassembleEffects" + index, 1.0 )

	thread DisassemblyObjectsFall( index, mover )

	mover.NonPhysicsMoveTo( nodes[0].GetOrigin(), 5.5, 2.0, 2.0 )
	float rotateDelay
	if ( delay == 0.0 )
		rotateDelay = 2.0 // first piece needs to wait longer so antennas don't clip through the world
	else
		rotateDelay = 1.0
	wait rotateDelay

	mover.NonPhysicsRotateTo( <0,90,90>, 5.5 - rotateDelay, 0.5, 0.0 )

	wait 4.5 - rotateDelay
	StartParticleEffectInWorld( GetParticleSystemIndex( TOWN_DISASSEMBLE_DIRT_EFFECT ), effectEnt.GetOrigin(), effectEnt.GetAngles() )
	wait 1.0

	// Move down the track
	EmitSoundOnEntityNoSave( soundEmitter, "Boomtown_Sideways_FloorPiece_Exit_FastTrack_" + index )
	mover.NonPhysicsMoveTo( nodes[1].GetOrigin(), 9.0, 2.0, 2.0 )
	wait 9.0

	// Delete the mover and geo, and sound emitter
	soundEmitter.Destroy()
	// Can't destroy ents with static props attached??? Dumb
	/*
	array<entity> linkedEnts = mover.GetLinkEntArray()
	foreach( entity ent in linkedEnts )
		ent.Destroy()
	mover.Destroy()
	*/
}

void function SetFlagForDuration( string flag, float duration )
{
	FlagSet( flag )
	wait duration
	FlagClear( flag )
}

void function DisassemblyObjectsFall( int index, entity mover )
{
	array<asset> physModels = [ PHYS_FALL_MODEL1, PHYS_FALL_MODEL2, PHYS_FALL_MODEL3, PHYS_FALL_MODEL4 ]

	// Physics objects fall
	array<entity> locations = GetEntArrayByScriptName( "BoomtownDisassemblePhysLocation" + index )
	foreach( entity location in locations )
	{
		entity prop_physics = CreateEntity( "prop_physics" )
		prop_physics.SetValueForModelKey( physModels.getrandom() )
		prop_physics.kv.spawnflags = 0
		prop_physics.kv.fadedist = -1
		prop_physics.kv.physdamagescale = 0.1
		prop_physics.kv.inertiaScale = 1.0
		prop_physics.kv.renderamt = 255
		prop_physics.kv.rendercolor = "255 255 255"
		prop_physics.kv.physicsmode = 1
		SetTeam( prop_physics, TEAM_BOTH )	// need to have a team other then 0 or it won't take impact damage
		prop_physics.SetPhysics( MOVETYPE_VPHYSICS )

		prop_physics.SetOrigin( location.GetOrigin() )
		prop_physics.SetAngles( <0,0,0> )
		DispatchSpawn( prop_physics )
	}
}

void function DisassemblyDialogue()
{
	wait 1.0

	// PA: Simulation override initiated.  Resetting terrain.
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "panel_hack_PA_dialogue_location" ).GetOrigin(), "diag_sp_townClimb_BM171_12_01_imc_facilityPA" )

	wait 5.0

	entity player = GetPlayerArray()[0]
	if ( !IsValid( player ) )
		return
	EndSignal( player, "OnDeath" )

	thread PlayerRidingTownClimbDialogue( player )

	// Impressive, Pilot. You made it all this way alive. Unfortunately for you, there is only one way out. Step onto a moving platform.
	waitthread PlayDialogue( "ASH_DOME_AWAITS_YOU", player )

	Objective_Set( "#BOOMTOWN_OBJECTIVE_RIDE_PLATFORM" )

	// Nag player to jump onto the platforms and ride into the dome
	array<string> nagLines = ["ASH_NAG_ENTER_DOME_1", "ASH_NAG_ENTER_DOME_2", "ASH_NAG_ENTER_DOME_3" ]
	foreach( string nagLine in nagLines )
	{
		wait 10.0
		if ( Flag( "PlayerRidingTownClimb" ) )
			break

		waitthread PlayDialogue( nagLine, player )
	}
}

void function PlayerRidingTownClimbDialogue( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "PlayerRidingTownClimb" )

	// I admire your perseverance. If only the IMC infantry were as dedicated. I will take it from here.
	PlayDialogue( "ASH_TAKE_IT_FROM_HERE", player )
}

void function TownClimbCompletedWait()
{
	FlagWait( "TownClimbComplete" )

	Objective_Clear()

	entity player = GetPlayerArray()[0]
	UnlockAchievement( player, achievements.SIDEWAYS_TOWN )

	CheckPoint()

	StopMusicTrack( "music_boomtown_14_townclimb_outoftheroof" )
	PlayMusic( "music_boomtown_15_townclimb_activateconsole" )

	FlagClear( "PlayerRidingTownClimb" ) // clear this flag since it probably got set during town climb
	thread DisassemblyDialogue()

	// Disassemble the boomtown
	FlagSet( "BoomtownDisassemble" )

	// Move the wall climb parts into the boomtown
	entity mover1 = GetEntByScriptName( "townclimb_mover1" )
	entity mover2 = GetEntByScriptName( "townclimb_mover2" )
	entity mover3 = GetEntByScriptName( "townclimb_mover3" )
	entity mover4 = GetEntByScriptName( "townclimb_mover4" )
	entity mover5 = GetEntByScriptName( "townclimb_mover5" )
	entity mover6 = GetEntByScriptName( "townclimb_mover6" )

	wait 17.0 // give time to allow old boomtown to clear out of the way

	FlagSet( "TownClimbGeoMovingUp" )
	FlagSet( "ReapertownPlatforJumpMobilityGhostEnabled" )

	thread MoveWallClimbRowIntoBoomtown( mover5, "", 1 )
	wait 5.0
	thread MoveWallClimbRowIntoBoomtown( mover6, "", 2 )
	wait 5.0
	thread MoveWallClimbRowIntoBoomtown( mover4, "", 3 )
	wait 4.0
	thread MoveWallClimbRowIntoBoomtown( mover3, "", 4 )
	wait 4.0
	thread MoveWallClimbRowIntoBoomtown( mover2, "", 5 )
	wait 4.0
	waitthread MoveWallClimbRowIntoBoomtown( mover1, "ReaperTownRaisedUp", 6 )

	if ( !Flag( "PlayerInRaisedReaperTown" ) ) // Trigger in raised area indicates the player has arrived
	{
		foreach ( player in GetPlayerArray() )
		{
			thread PlayDialogue( "ASH_DISAPPOINTING", player )
			ScreenFadeToBlackForever( player )
		}
		ReloadForMissionFailure()
	}
}

void function MoveWallClimbRowIntoBoomtown( entity mover, string flagToSet = "", int platformIndex = 0 )
{
	array<entity> nodes = GetChainOfNodesLinked( mover )
	float dist
	float moveTime
	float ease

	entity soundEmitter = CreateScriptMover( mover.GetOrigin() - <0,4300,0>, mover.GetAngles() )
	soundEmitter.SetParent( mover, "", true )
	AddCleanupEnt( soundEmitter )

	// Platform moves along the wall to the junction
	string moveSound = ""
	if ( platformIndex == 2 )
		moveSound = "Boomtown_Sideways_FloorPiece_Assemble_VerticalLower_" + platformIndex
	if ( platformIndex >= 3 )
		moveSound = "Boomtown_Sideways_FloorPiece_Assemble_VerticalRaise_" + platformIndex
	if ( moveSound != "" )
		EmitSoundOnEntityNoSave( soundEmitter, moveSound )
	dist = Distance( mover.GetOrigin(), nodes[0].GetOrigin() )
	moveTime = dist / 150.0
	ease = min( 0.5, moveTime * 0.33 )
	if ( moveTime > 0.0 )
	{
		mover.NonPhysicsMoveTo( nodes[0].GetOrigin(), moveTime, ease, ease )
		wait moveTime
	}

	// Move away from the wall and rotate to flat
	mover.NonPhysicsRotateTo( <0,90,90>, 5.0, 2.0, 2.0 )

	// Move down horizontal track to the point where it goes up

	float rumbleAmplitude
	float rumbleFrequency

	// Playforms 1-5 just go straight there, platform 6 may stop to wait for the player
	if ( platformIndex > 0 )
		EmitSoundOnEntityNoSave( soundEmitter, "Boomtown_Sideways_FloorPiece_Assemble_HorizontalRotate_" + platformIndex )
	if ( platformIndex == 6 )
	{
		dist = Distance( mover.GetOrigin(), nodes[2].GetOrigin() )
		moveTime = dist / 300.0
		ease = min( 0.5, moveTime * 0.33 )
		FlagClear( "ReapertownPlatforJumpMobilityGhostEnabled" )
		mover.NonPhysicsMoveTo( nodes[2].GetOrigin(), moveTime, ease, 0.0 )

		rumbleAmplitude = 4000.0
		rumbleFrequency = 100
		entity rumbleHandle = CreateShakeRumbleOnly( soundEmitter.GetOrigin(), rumbleAmplitude, rumbleFrequency, moveTime * 1.2, 5000 )
		rumbleHandle.SetParent( soundEmitter, "", false )

		wait 2.5
		Signal( level, "GhostRecorderReapertownJumpGo" )
		wait moveTime - 2.5

		if ( !Flag( "PlayerRidingTownClimb" ) )
		{
			// Platform stops so stop that sound and play a stop sound and new move sound when it resumes
			if ( moveSound != "" )
				StopSoundOnEntity( soundEmitter, moveSound )
			StopSoundOnEntity( soundEmitter, "Boomtown_Sideways_FloorPiece_Assemble_HorizontalRotate_" + platformIndex )
			EmitSoundOnEntityNoSave( soundEmitter, "Boomtown_Sideways_FloorPiece_Assemble_StopForPlayer" )

			FlagWait( "PlayerRidingTownClimb" )
			wait 1.0

			EmitSoundOnEntityNoSave( soundEmitter, "Boomtown_Sideways_FloorPiece_Entrance_FastTrack_1" )
		}

		dist = Distance( mover.GetOrigin(), nodes[3].GetOrigin() )
		moveTime = dist / 300.0
		ease = min( 0.5, moveTime * 0.33 )
		mover.NonPhysicsMoveTo( nodes[3].GetOrigin(), moveTime, 0.0, ease )

		rumbleHandle = CreateShakeRumbleOnly( soundEmitter.GetOrigin(), rumbleAmplitude, rumbleFrequency, moveTime * 1.2, 5000 )
		rumbleHandle.SetParent( soundEmitter, "", false )

		wait moveTime
	}
	else
	{
		// Go right to node 3
		dist = Distance( mover.GetOrigin(), nodes[3].GetOrigin() )
		moveTime = dist / 300.0
		ease = min( 0.5, moveTime * 0.33 )
		mover.NonPhysicsMoveTo( nodes[3].GetOrigin(), moveTime, ease, 0.0 )

		rumbleAmplitude = 4000.0
		rumbleFrequency = 100
		entity rumbleHandle = CreateShakeRumbleOnly( soundEmitter.GetOrigin(), rumbleAmplitude, rumbleFrequency, moveTime * 1.2, 5000 )
		rumbleHandle.SetParent( soundEmitter, "", false )

		wait 2.5
		Signal( level, "GhostRecorderReapertownJumpGo" )
		wait moveTime - 2.5
	}

	// Move up and into the boom town
	if ( platformIndex > 0 )
		EmitSoundOnEntityNoSave( soundEmitter, "Boomtown_Sideways_FloorPiece_Assemble_LiftIntoDome_" + platformIndex )
	dist = Distance( mover.GetOrigin(), nodes[4].GetOrigin() )
	moveTime = dist / 300.0
	ease = min( 0.5, moveTime * 0.33 )
	mover.NonPhysicsMoveTo( nodes[4].GetOrigin(), moveTime, ease, ease )

	rumbleAmplitude = 4000.0
	rumbleFrequency = 100
	entity rumbleHandle = CreateShakeRumbleOnly( soundEmitter.GetOrigin(), rumbleAmplitude, rumbleFrequency, moveTime * 1.2, 5000 )
	rumbleHandle.SetParent( soundEmitter, "", false )

	wait moveTime

	rumbleAmplitude = 10000.0
	rumbleFrequency = 50
	CreateShakeRumbleOnly( soundEmitter.GetOrigin(), rumbleAmplitude, rumbleFrequency, 1.5, 5000 )

	if ( flagToSet != "" )
		FlagSet( flagToSet )
	soundEmitter.Destroy()
}

void function AssemblyScreenShake( vector pos )
{
	array<entity> players = GetPlayerArray()
	if ( players.len() == 0 )
		return
	entity player = players[0]
	if ( !IsValid( player ) )
		return
	if ( Distance( player.GetOrigin(), pos ) >= 2000 )
		return
	Remote_CallFunction_NonReplay( player, "ServerCallback_BoomtownScreenShake", 2, 10, 2 )    //float amplitude, float frequency, float duration
}

void function ContextLocationPastGrinder( entity player )
{
	FlagWait( "ContextLocationPastGrinder" )

	// He's on the platform!
	thread PlayContextLocationGruntDialogue( player, "GRUNT_HES_ON_PLATFORM" )
}

void function ContextLocationPastScanner( entity player )
{
	FlagWait( "ContextLocationPastScanner" )

	// Pilot spotted on moving platform! Get him before he escapes!
	thread PlayContextLocationGruntDialogue( player, "GRUNT_BEFORE_HE_ESCAPES" )
}

void function ContextLocationFurniture( entity player )
{
	FlagWait( "ContextLocationFurniture" )

	// Watch out! He's movin' quick on the converyor!
	thread PlayContextLocationGruntDialogue( player, "GRUNT_ON_CONVEYOR" )
}

void function ContextLocationApproachingRoof1( entity player )
{
	FlagWait( "ContextLocationApproachingRoof1" )

	// There's no way he's going to survive out there, but kill him anyway!
	thread PlayContextLocationGruntDialogue( player, "GRUNT_KILL_HIM_ANYWAY" )
}

void function ContextLocationRoof2( entity player )
{
	FlagWait( "ContextLocationRoof2" )

	// That platform's moving outa reach! Gamma two - Take him out!
	thread PlayContextLocationGruntDialogue( player, "GRUNT_MOVING_OUTA_REACH" )
}

void function ContextLocationApproachingRoof3( entity player )
{
	FlagWait( "ContextLocationApproachingRoof3" )

	// Get him before he gets further down the assembly!
	thread PlayContextLocationGruntDialogue( player, "GRUNT_GET_HIM" )
}

void function PlayContextLocationGruntDialogue( entity player, string dialogue )
{
	// Get the nearest grunt to the player
	array <entity> npcs = GetNPCArray()
	array <entity> grunts
	foreach( npc in npcs )
	{
		if ( !IsValid( npc ) )
			continue
		if ( !IsAlive( npc ) )
			continue
		if ( !IsGrunt( npc ) )
			continue
		grunts.append( npc )
	}

	if ( grunts.len() == 0 )
		return

	entity closestGrunt = GetClosest( grunts, player.GetOrigin() )
	Assert( IsValid( closestGrunt ) )

	thread PlayDialogue( dialogue, closestGrunt )
}


