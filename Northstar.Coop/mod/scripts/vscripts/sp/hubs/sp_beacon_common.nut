untyped

global function SPBeaconGlobals
global function SkitGruntsSpeakLinesNearPlayer
global function GetClosestGrunt
global function GetClosestGrunts
global function DestroySkitGrunts
global function GruntSkitsInit
global function GhostFireArcToolAtEntity
global function AssignRandomMilitiaGruntModel
global function BeaconBeamScreenEffects

const STALKER_MODEL = $"models/robots/stalker/robot_stalker.mdl"
const DEFAULT_SKIT_ACTIVATE_DISTANCE = 575 * 575
global const CHARGE_BEAM_GHOST_EFFECT = $"P_wpn_charge_tool_beam_HOLO"
global const ARC_TOOL_GHOST_WORLD_MODEL = $"models/weapons/arc_tool_sp/w_arc_tool_sp.mdl"
const asset GRAVITY_MINE_PROP = $"models/weapons/gravity_mine/w_gravity_mine_prop.mdl"

struct SkitAnims
{
	entity guy
	string startIdle = ""
	string skitAnim = ""
	string endIdle = ""
	bool destroyAfterSkit = false
	bool idleForever = false
	array<entity> propModels
	array<string> propStartIdles
	array<string> propSkitAnims
	array<string> propEndIdles
}

struct
{
	array<entity> skitGrunts
	array<asset> militiaGruntModels = [ TEAM_MIL_GRUNT_MODEL_LMG, TEAM_MIL_GRUNT_MODEL_RIFLE, TEAM_MIL_GRUNT_MODEL_SHOTGUN, TEAM_MIL_GRUNT_MODEL_SMG ]
	int nextGruntModelToUse = 0
} file

function SPBeaconGlobals()
{
	ShBeaconCommonInit()

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddArcSwitchActivateCallback( ArcSwitchActivated_Beacon )

	PrecacheModel( TEAM_MIL_GRUNT_MODEL_LMG	)
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_RIFLE	)
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_SHOTGUN )
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_SMG	)
	PrecacheModel( ROCKET_TURRET_MODEL )
	PrecacheModel( GRAVITY_MINE_PROP )

	RegisterSignal( "ActivateChargePlatform" )
	RegisterSignal( "ActivateChargePlatformForever" )
	RegisterSignal( "StopGruntSkit" )
	RegisterSignal( "GruntSkitsInit" )

	FlagInit( "DishPowerPhase1" )
	FlagInit( "DishPowerPhase2" )
	FlagInit( "HasChargeTool" )
}

void function EntitiesDidLoad()
{
	thread GruntSkitsInit()
}

void function ArcSwitchActivated_Beacon( entity ent )
{
	//Assert( 0, "Deprecated" )

	// See if the switch links to anything and do behavior based on what it links to
	array<entity> linkedEnts = ent.GetLinkEntArray()
	foreach ( entity linkedEnt in linkedEnts )
	{
		if ( !IsValid( linkedEnt ) )
			continue

		if ( linkedEnt.GetClassName() == "func_brush" )
		{
			if ( linkedEnt.HasKey("move_time") && linkedEnt.HasKey("movedirection") )
			{
				EmitSoundOnEntity( ent, "Metal_Window_Open" )
				thread BrushMoves( linkedEnt )
			}
		}
		if ( linkedEnt.GetClassName() == "info_target" && linkedEnt.GetScriptName() == "charge_panel_platform" )
		{
			if ( ent.HasKey( "resetTime" ) && ent.kv.resetTime == "-1" )
				Signal( linkedEnt, "ActivateChargePlatformForever" )
			else
				Signal( linkedEnt, "ActivateChargePlatform" )
		}
	}
}

void function GruntSkitsInit()
{
	// kill any grunt skits that are already waiting to happen
	svGlobal.levelEnt.Signal( "GruntSkitsInit" )

	table<string,void functionref(entity,entity)> skitFuncs
	skitFuncs[ "skit_dumpbody_over_railing" ] 	<- GruntSkit_DumpBody
	skitFuncs[ "skit_arc_mine_activate" ] 		<- GruntSkit_ArcMine
	skitFuncs[ "skit_turret_repair" ] 			<- GruntSkit_TurretRepair
	skitFuncs[ "skit_ammo_box" ] 				<- GruntSkit_AmmoBox
	skitFuncs[ "skit_hanging_stalker" ] 		<- GruntSkit_HangingStalker
	skitFuncs[ "skit_window_a" ] 				<- GruntSkit_WindowA
	skitFuncs[ "skit_window_b" ] 				<- GruntSkit_WindowB
	skitFuncs[ "skit_door_guard" ] 				<- GruntSkit_DoorGuard
	skitFuncs[ "skit_gearup" ] 					<- GruntSkit_GearUp
	skitFuncs[ "skit_spotters" ]				<- GruntSkit_Spotters

	skitFuncs[ "skit_kickbody_over_edge" ]		<- GruntSkit_KickBodyOverEdge


	while( GetPlayerArray().len() == 0 )
		WaitFrame()

	entity player = GetPlayerArray()[0]

	array<entity> nodes
	foreach ( string scriptName, void functionref(entity,entity) func in skitFuncs )
	{
		nodes = GetEntArrayByScriptName( scriptName )
		foreach ( entity node in nodes )
		{
			if ( !node.HasKey( "hover" ) || node.kv.hover != "1" )
				DropToGround( node )
			//DebugDrawAngles( node.GetOrigin(), node.GetAngles() )
			thread GruntSkitsInitFunc( func, player, node )
		}
	}
}

void function GruntSkitsInitFunc( void functionref( entity, entity ) gruntSkitFunc, entity player, entity node )
{
	// kill any grunt skits that are already waiting to happen
	svGlobal.levelEnt.EndSignal( "GruntSkitsInit" )
	gruntSkitFunc( player, node )
}

void function GruntSkitFlagWait( entity node )
{
	if ( node.HasKey( "script_flag" ) )
	{
		FlagInit( string( node.kv.script_flag ) )
		FlagWait( string( node.kv.script_flag ) )
	}
}

void function GruntSkit_DumpBody( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt
	skitAnimGrunt.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt.guy )
	skitAnimGrunt.startIdle = "pt_dumpbody_over_railing_idle"
	skitAnimGrunt.skitAnim = "pt_dumpbody_over_railing"
	skitAnimGrunt.endIdle = "pt_dumpbody_over_railing_idle"

	SkitAnims skitAnimSpectre
	skitAnimSpectre.guy = CreatePropDynamic( STALKER_MODEL, node.GetOrigin(), node.GetAngles(), 6 )
	skitAnimSpectre.startIdle = "st_dumpbody_over_railing_idle"
	skitAnimSpectre.skitAnim = "st_dumpbody_over_railing"
	skitAnimSpectre.endIdle = ""
	skitAnimSpectre.destroyAfterSkit = true

	array<SkitAnims> skitData = [ skitAnimGrunt, skitAnimSpectre ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_KickBodyOverEdge( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt
	skitAnimGrunt.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt.guy )
	skitAnimGrunt.startIdle = "pt_kickbody_over_edge_startidle"
	skitAnimGrunt.skitAnim = "pt_kickbody_over_edge"
	skitAnimGrunt.endIdle = "pt_kickbody_over_edge_endidle"

	SkitAnims skitAnimSpectre
	skitAnimSpectre.guy = CreatePropDynamic( STALKER_MODEL, node.GetOrigin(), node.GetAngles(), 6 )
	skitAnimSpectre.startIdle = "st_kickbody_over_edge_startidle"
	skitAnimSpectre.skitAnim = "st_kickbody_over_edge"
	//skitAnimSpectre.endIdle = "st_kickbody_over_edge_endidle"
	skitAnimSpectre.destroyAfterSkit = true

	array<SkitAnims> skitData = [ skitAnimGrunt, skitAnimSpectre ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_ArcMine( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt
	skitAnimGrunt.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt.guy )

	entity mine1 = CreatePropDynamic( GRAVITY_MINE_PROP, node.GetOrigin(), node.GetAngles() )
	entity mine2 = CreatePropDynamic( GRAVITY_MINE_PROP, node.GetOrigin(), node.GetAngles() )

	skitAnimGrunt.startIdle = "pt_arc_mine_activate_idle"
	skitAnimGrunt.skitAnim = "pt_arc_mine_activate"
	skitAnimGrunt.endIdle = "pt_arc_mine_activate_idle"
	skitAnimGrunt.propModels = [ mine1, mine2 ]
	skitAnimGrunt.propStartIdles = [ "w_gravity_mineA_activate_idle", "" ]
	skitAnimGrunt.propSkitAnims = [ "w_gravity_mineA_activate", "w_gravity_mineB_activate" ]
	skitAnimGrunt.propEndIdles = [ "w_gravity_mineA_activate_idle", "w_gravity_mineB_activate_idle" ]

	array<SkitAnims> skitData = [ skitAnimGrunt ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_TurretRepair( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt
	skitAnimGrunt.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	skitAnimGrunt.guy.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( skitAnimGrunt.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt.guy )
	skitAnimGrunt.startIdle = "pt_turret_repair_idle"
	skitAnimGrunt.idleForever = true

	SkitAnims skitAnimTurret
	skitAnimTurret.guy = CreatePropDynamic( ROCKET_TURRET_MODEL, node.GetOrigin(), node.GetAngles(), 6 )
	skitAnimTurret.guy.SetAIObstacle( true )
	skitAnimTurret.startIdle = "turret_repair_idle"
	skitAnimTurret.idleForever = true

	array<SkitAnims> skitData = [ skitAnimGrunt, skitAnimTurret ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_AmmoBox( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt1
	skitAnimGrunt1.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	skitAnimGrunt1.guy.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( skitAnimGrunt1.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt1.guy )
	skitAnimGrunt1.startIdle = "pt_grab_ammo_start_A"
	skitAnimGrunt1.skitAnim = "pt_grab_ammo_start_scene_A"
	skitAnimGrunt1.endIdle = "pt_grab_ammo_end_A"

	SkitAnims skitAnimGrunt2
	skitAnimGrunt2.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	skitAnimGrunt2.guy.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( skitAnimGrunt2.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt2.guy )
	skitAnimGrunt2.startIdle = "pt_grab_ammo_start_B"
	skitAnimGrunt2.skitAnim = "pt_grab_ammo_start_scene_B"
	skitAnimGrunt2.endIdle = "pt_grab_ammo_end_B"

	array<SkitAnims> skitData = [ skitAnimGrunt1, skitAnimGrunt2 ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_HangingStalker( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt
	skitAnimGrunt.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt.guy )
	skitAnimGrunt.startIdle = "pt_smash_hanging_stalker_idle"
	skitAnimGrunt.skitAnim = "pt_smash_hanging_stalker"

	SkitAnims skitAnimSpectre
	skitAnimSpectre.guy = CreatePropDynamic( STALKER_MODEL, node.GetOrigin(), node.GetAngles(), 6 )
	skitAnimSpectre.startIdle = "st_smash_hanging_stalker_idle"
	skitAnimSpectre.skitAnim = "st_smash_hanging_stalker"
	//skitAnimSpectre.endIdle = "st_smash_hanging_stalker_idle"

	array<SkitAnims> skitData = [ skitAnimGrunt, skitAnimSpectre ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_WindowA( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt
	skitAnimGrunt.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt.guy )
	skitAnimGrunt.startIdle = "pt_cover_window_idle_A"
	skitAnimGrunt.skitAnim = "pt_cover_window_scene_A"
	skitAnimGrunt.endIdle = "pt_cover_window_idle_A"

	array<SkitAnims> skitData = [ skitAnimGrunt ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_WindowB( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt
	skitAnimGrunt.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt.guy )
	skitAnimGrunt.startIdle = "pt_cover_window_idle_B"
	skitAnimGrunt.skitAnim = "pt_cover_window_scene_B"
	skitAnimGrunt.endIdle = "pt_cover_window_idle_B"

	array<SkitAnims> skitData = [ skitAnimGrunt ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_DoorGuard( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt1
	skitAnimGrunt1.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt1.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt1.guy )
	skitAnimGrunt1.startIdle = "pt_door_guard_start"
	skitAnimGrunt1.skitAnim = "pt_door_guard"
	skitAnimGrunt1.endIdle = "pt_door_guard_end"

	SkitAnims skitAnimGrunt2
	skitAnimGrunt2.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt2.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt2.guy )
	skitAnimGrunt2.startIdle = "pt_door_guard_A_start"
	skitAnimGrunt2.skitAnim = "pt_door_guard_A"

	SkitAnims skitAnimGrunt3
	skitAnimGrunt3.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt3.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt3.guy )
	skitAnimGrunt3.startIdle = "pt_door_guard_B_start"
	skitAnimGrunt3.skitAnim = "pt_door_guard_B"

	array<SkitAnims> skitData = [ skitAnimGrunt1, skitAnimGrunt2, skitAnimGrunt3 ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_GearUp( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt1
	skitAnimGrunt1.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt1.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt1.guy )
	skitAnimGrunt1.startIdle = "pt_gearup_window_idle_A"
	skitAnimGrunt1.idleForever = true

	SkitAnims skitAnimGrunt2
	skitAnimGrunt2.guy = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt2.guy )
	AssignRandomMilitiaGruntModel( skitAnimGrunt2.guy )
	skitAnimGrunt2.startIdle = "pt_gearup_window_idle_B"
	skitAnimGrunt2.idleForever = true

	array<SkitAnims> skitData = [ skitAnimGrunt1, skitAnimGrunt2 ]

	DoGruntSkit( player, node, skitData )
}

void function GruntSkit_Spotters( entity player, entity node )
{
	GruntSkitFlagWait( node )

	SkitAnims skitAnimGrunt1
	skitAnimGrunt1.guy = CreateSoldier( TEAM_IMC, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt1.guy )
	skitAnimGrunt1.guy.kv.alwaysalert = 1
	skitAnimGrunt1.startIdle = "pt_spotter_A_start_idle"
	skitAnimGrunt1.skitAnim = "pt_spotter_A_react"

	SkitAnims skitAnimGrunt2
	skitAnimGrunt2.guy = CreateSoldier( TEAM_IMC, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( skitAnimGrunt2.guy )
	skitAnimGrunt2.guy.kv.alwaysalert = 1
	skitAnimGrunt2.startIdle = "pt_spotter_B_start_idle"
	skitAnimGrunt2.skitAnim = "pt_spotter_B_react"

	array<SkitAnims> skitData = [ skitAnimGrunt1, skitAnimGrunt2 ]

	DoGruntSkit( player, node, skitData )
}

void function DoGruntSkit( entity player, entity node, array<SkitAnims> skitData )
{
	foreach ( data in skitData )
	{
		data.guy.EndSignal( "OnDeath" )
		data.guy.EndSignal( "StopGruntSkit" )

		ArrayRemoveInvalid( file.skitGrunts )
		file.skitGrunts.append( data.guy )
	}

	//DebugDrawAngles( node.GetOrigin(), node.GetAngles() )

	// Start idle
	foreach ( SkitAnims data in skitData )
	{
		thread PlayAnimTeleport( data.guy, data.startIdle, node )
		for ( int i = 0 ; i < data.propModels.len() ; i++ )
		{
			if ( data.propStartIdles[i] != "" )
				thread PlayAnimTeleport( data.propModels[i], data.propStartIdles[i], node )
			else
				data.propModels[i].Hide()
		}
	}

	// If the node targets a info_move_target we make the guys assault it so when animation is done they will go there
	entity moveTarget = node.GetLinkEnt()
	if ( IsValid( moveTarget ) && GetEditorClass( moveTarget ) == "info_move_target" )
	{
		foreach ( SkitAnims data in skitData )
			AssaultEntityForced( data.guy, moveTarget )
	}

	foreach ( SkitAnims data in skitData )
	{
		if ( data.idleForever )
			return
	}

	// Wait for player to get close, or it to be seen
	waitthread WaitForSkitStart( player, node, skitData )

	//DebugDrawAngles( node.GetOrigin(), node.GetAngles() )

	bool everyoneValid = true
	foreach ( SkitAnims data in skitData )
	{
		if ( IsValid( data.guy ) )
			continue
		everyoneValid = false
		break
	}

	// If someone became invalid abort the skit
	if ( !everyoneValid )
	{
		foreach ( SkitAnims data in skitData )
		{
			if ( IsValid( data.guy ) )
				data.guy.Stop_Anim()
		}
		return
	}

	// Skit anim
	foreach ( SkitAnims data in skitData )
	{
		thread PlayAnimTeleport( data.guy, data.skitAnim, node )
		for ( int i = 0 ; i < data.propModels.len() ; i++ )
		{
			data.propModels[i].Show()
			thread PlayAnimTeleport( data.propModels[i], data.propSkitAnims[i], node )
		}
	}

	// Wait until skit is over
	WaittillAnimDone( skitData[0].guy )

	// Delete guys that are supposed to be deleted
	foreach ( SkitAnims data in skitData )
	{
		if ( data.destroyAfterSkit )
			data.guy.Destroy()
	}

	// Play end idle on remaining guys
	foreach ( SkitAnims data in skitData )
	{
		if ( IsValid( data.guy ) && data.endIdle != "" )
		{
			thread PlayAnimTeleport( data.guy, data.endIdle, node )
			for ( int i = 0 ; i < data.propModels.len() ; i++ )
				thread PlayAnimTeleport( data.propModels[i], data.propEndIdles[i], node )
		}
	}
}

void function WaitForSkitStart( entity player, entity node, array<SkitAnims> skitData )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( node, "OnDestroy" )

	bool waitForRadius = node.HasKey( "script_goal_radius" ) && node.kv.script_goal_radius != ""
	bool waitForVisible = node.HasKey( "starts_when_visible" ) && node.kv.starts_when_visible == "1"
	Assert( waitForRadius || waitForVisible, "Skit node at " + node.GetOrigin() + " doesn't have a script_goal_radius set, or have starts_when_visible 1. It needs to have one or the other." )

	while( true )
	{
		if ( waitForRadius )
		{
			float activateRadiusSqr = float( node.kv.script_goal_radius ) * float( node.kv.script_goal_radius )
			if ( DistanceSqr( node.GetOrigin(), player.GetOrigin() ) <= activateRadiusSqr )
				return
		}

		if ( waitForVisible )
		{
			if ( PlayerCanSee( player, node, true, 45 ) )
				return
			foreach ( SkitAnims data in skitData )
			{
				if ( PlayerCanSee( player, data.guy, true, 45 ) )
					return
			}
		}

		WaitFrame()
	}
}

void function DestroySkitGrunts()
{
	foreach( entity grunt in file.skitGrunts )
	{
		if ( IsValid( grunt ) )
			grunt.Destroy()
	}
}

void function AssaultEntity( entity guy, entity target )
{
	vector origin = target.GetOrigin()
	vector angles = target.GetAngles()
	float radius = 750
	if ( target.HasKey( "script_goal_radius" ) )
		radius = float( target.kv.script_goal_radius )

	guy.AssaultPoint( origin )
	guy.AssaultSetGoalRadius( radius )

	if ( target.HasKey( "face_angles" ) && target.kv.face_angles == "1" )
		guy.AssaultSetAngles( angles, true )
}

void function AssaultEntityForced( entity guy, entity target )
{
	guy.DisableNPCFlag( NPC_ALLOW_FLEE | NPC_ALLOW_HAND_SIGNALS )
	guy.AssaultSetFightRadius( 4 )
	AssaultEntity( guy, target )
}

void function SkitGruntsSpeakLinesNearPlayer( entity player, array<string> skitNames, array< array<string> > chatAliases, string cancelFlag = "" )
{
	if ( cancelFlag != "" )
		FlagEnd( cancelFlag )
	EndSignal( player, "OnDeath" )

	array<string> singleLines
	array< array<string> > multiLines
	foreach( array<string> aliases in chatAliases )
	{
		if ( aliases.len() == 1 )
			singleLines.append( aliases[0] )
		else
			multiLines.append( aliases )
	}

	array<entity> nodes
	foreach( string name in skitNames )
		nodes.extend( GetEntArrayByScriptName( name ) )

	const float TRIGGER_DIST = 200.0

	array<string> singleSkits = [ "skit_turret_repair", "skit_window_a", "skit_window_b", "skit_arc_mine_activate", "skit_dumpbody_over_railing", "skit_kickbody_over_edge" ]
	array<string> multiSkits = [ "skit_ammo_box", "skit_gearup" ]

	// Keep checking which node the player is by, and if close enough we trigger the event
	vector pos
	entity closestNode
	float d
	while( true )
	{
		if ( singleLines.len() == 0 && multiLines.len() == 0 )
			break
		if ( nodes.len() == 0 )
			break

		wait 0.1

		pos = player.GetOrigin()
		closestNode = GetClosest( nodes, pos )
		d = Distance( pos, closestNode.GetOrigin() )

		//DebugDrawLine( pos, closestNode.GetOrigin(), 0, 255, 0, true, 0.2 )
		//DebugDrawText( closestNode.GetOrigin(), closestNode.GetScriptName(), true, 0.2 )
		//printt( "d:", d )

		if ( d > TRIGGER_DIST )
			continue

		string nodeSkitType = closestNode.GetScriptName()
		if ( singleSkits.contains( nodeSkitType ) )
		{
			// Single line
			string alias = singleLines.getrandom()
			singleLines.fastremovebyvalue( alias )
			if ( singleLines.len() == 0 )
			{
				// Remove all single line nodes since we are out of single line aliases
				for ( int i = nodes.len() - 1 ; i >= 0 ; i-- )
				{
					string scriptName = nodes[i].GetScriptName()
					if ( singleSkits.contains( scriptName ) )
						nodes.fastremove( i )
				}
			}
			entity grunt = GetClosestGrunt( closestNode.GetOrigin() )
			//DebugDrawSphere( grunt.GetWorldSpaceCenter(), 16, 255, 255, 255, true, 2.0 )
			waitthread PlayGabbyDialogue( alias, grunt )
		}
		else if ( multiSkits.contains( nodeSkitType ) )
		{
			// Multi-line conversation
			array<string> aliases = multiLines.getrandom()
			multiLines.fastremovebyvalue( aliases )
			if ( multiLines.len() == 0 )
			{
				// Remove all multi-line nodes since we are out of multi-line aliases
				for ( int i = nodes.len() - 1 ; i >= 0 ; i-- )
				{
					string scriptName = nodes[i].GetScriptName()
					if ( multiSkits.contains( scriptName ) )
						nodes.fastremove( i )
				}
			}
			array<entity> grunts = GetClosestGrunts( closestNode.GetOrigin(), 2 )
			Assert( grunts.len() == 2 )
			int nextGuy = 0
			foreach( string alias in aliases )
			{
				if ( !IsValid( grunts[nextGuy] ) )
					break
				//DebugDrawSphere( grunts[nextGuy].GetWorldSpaceCenter(), 16, 255, 255, 255, true, 2.0 )
				waitthread PlayGabbyDialogue( alias, grunts[nextGuy] )
				nextGuy = nextGuy == 0 ? 1 : 0
			}
		}
		else
		{
			Assert( 0, "Unhandled node type in SkitGruntsSpeakLinesNearPlayer" )
		}

		nodes.fastremovebyvalue( closestNode )

		wait 0.5 // debounce time before doing another line
	}

	//printt( "Ran out of grunt chatter aliases" )
}

entity function GetClosestGrunt( vector position, array<entity> exclude = [] )
{
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
		if ( exclude.contains( npc ) )
			continue
		grunts.append( npc )
	}
	Assert( grunts.len() > 0 )

	entity closestGrunt = GetClosest( grunts, position )
	Assert( IsValid( closestGrunt ) )

	return closestGrunt
}

array<entity> function GetClosestGrunts( vector position, int count, array<entity> exclude = [] )
{
	array<entity> grunts
	for ( int i = 0 ; i < count ; i++ )
	{
		entity grunt = GetClosestGrunt( position, exclude )
		grunts.append( grunt )
		exclude.append( grunt )
	}
	Assert( grunts.len() == count )
	return grunts
}

void function GhostFireArcToolAtEntity( entity ghost, entity weapon, entity target )
{
	// Shoot the arc tool at the switch
	int attachIndex = weapon.LookupAttachment( "muzzle_flash" )
	entity effect = StartParticleEffectOnEntity_ReturnEntity( weapon, GetParticleSystemIndex( CHARGE_BEAM_GHOST_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	EffectSetControlPointVector( effect, 1, target.GetWorldSpaceCenter() )

	EmitSoundOnEntity( ghost, "Weapon_BatteryGun_FireStart_3P" )
	EmitSoundOnEntity( ghost, "Weapon_BatteryGun_FireLoop_3P" )

	wait 0.5

	if ( IsValid( ghost ) )
	{
		StopSoundOnEntity( ghost, "Weapon_BatteryGun_FireLoop_3P" )
		EmitSoundOnEntity( ghost, "Weapon_BatteryGun_FireStop_1P" )
	}

	EffectStop( effect )
}

void function AssignRandomMilitiaGruntModel( entity grunt )
{
	Assert( IsValid( grunt ) )
	grunt.SetModel( file.militiaGruntModels[ file.nextGruntModelToUse ] )
	file.nextGruntModelToUse++
	if ( file.nextGruntModelToUse >= file.militiaGruntModels.len() )
		file.nextGruntModelToUse = 0
}

void function BeaconBeamScreenEffects( entity player, string enabledFlag = "" )
{
	EndSignal( player, "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid ( player ) )
				StopSoundOnEntity( player, EMP_IMPARED_SOUND )
		}
	)

	if ( enabledFlag != "" )
	{
		if ( !Flag( enabledFlag ) )
			FlagWait( enabledFlag )
	}

	array<entity> ents = GetEntArrayByScriptName( "BeaconScreenEffect" )
	array<vector> start
	array<vector> end
	array<float> radius
	foreach( entity ent in ents )
	{
		start.append( ent.GetOrigin() )
		end.append( ent.GetLinkEnt().GetOrigin() )
		radius.append( float( ent.kv.radius ) )
	}

	bool soundPlaying
	float maxAmount
	vector p
	while( true )
	{
		maxAmount = 0
		p = player.GetOrigin()
		for ( int i = 0 ; i < ents.len() ; i++ )
		{
			float d = GetDistanceFromLineSegment( start[i], end[i], p )
			float amount = GraphCapped( d, 0.0, radius[i], 1.0, 0.0 )
			maxAmount = max( amount, maxAmount )
		}

		if ( maxAmount > 0 )
		{
			StatusEffect_AddTimed( player, eStatusEffect.emp, maxAmount, 0.25, 0.05 )
			if ( !soundPlaying )
			{
				EmitSoundOnEntity( player, EMP_IMPARED_SOUND )
				soundPlaying = true
			}
		}
		else if ( soundPlaying )
		{
			StopSoundOnEntity( player, EMP_IMPARED_SOUND )
			soundPlaying = false
		}

		wait 0.1
	}
}







