global function CodeCallback_MapInit

const ARC_TOOL_VIEW_MODEL = $"models/weapons/arc_tool_sp/v_arc_tool_sp.mdl"

struct
{
	entity player
	entity arcToolMarvin
	array<entity> logRollRoomEnemies
	int fanWallrunDeathCount
} file

void function CodeCallback_MapInit()
{
	ShSpBeaconSpoke0CommonInit()
	SPBeaconGlobals()
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	//DronePlatform_Init()

	AddDeathCallback( "npc_marvin", MarvinOnDeath )

	FlagInit( "Fan1Enabled", true )
	FlagInit( "DisableSkitGruntBanter" )

	PrecacheModel( ARC_TOOL_VIEW_MODEL )
	PrecacheModel( ARC_TOOL_GHOST_WORLD_MODEL )
	PrecacheParticleSystem( CHARGE_BEAM_GHOST_EFFECT )

	RegisterSignal( "AssemblyAdvance" )
	RegisterSignal( "StopAssemblyLineThink" )
	RegisterSignal( "MarvinStopWorkingArcTool" )
	RegisterSignal( "wallrun_start" )
	RegisterSignal( "wallrun_end" )
	RegisterSignal( "wind_tunnel_blend_out" )
	RegisterSignal( "marvin_shot_switch" )
	RegisterSignal( "doorknock" )
	RegisterSignal( "marvin_lose_arc_tool" )
	RegisterSignal( "attach_arc_tool" )
	RegisterSignal( "RestorePlayerFriction" )

	AddStartPoint( "Level Start", 				StartPoint_Start, 					StartPoint_Setup_Start, 				StartPoint_Skipped_Start )
	AddStartPoint( "First Fight", 				StartPoint_FirstFight, 				StartPoint_Setup_FirstFight, 			StartPoint_Skipped_FirstFight )
	AddStartPoint( "Get Arc Tool", 				StartPoint_GetArcTool,				StartPoint_Setup_GetArcTool, 			StartPoint_Skipped_GetArcTool )
	AddStartPoint( "Got Arc Tool", 				StartPoint_GotArcTool,				StartPoint_Setup_GotArcTool, 			StartPoint_Skipped_GotArcTool )
	AddStartPoint( "Horizontal Fan", 			StartPoint_HorizontalFan, 			StartPoint_Setup_HorizontalFan, 		StartPoint_Skipped_HorizontalFan )
	AddStartPoint( "Horizontal Fan Complete", 	StartPoint_HorizontalFanDone, 		StartPoint_Setup_HorizontalFanDone, 	StartPoint_Skipped_HorizontalFanDone )
	AddStartPoint( "Fan Wallrun", 				StartPoint_FanWallrun, 				StartPoint_Setup_FanWallrun, 			StartPoint_Skipped_FanWallrun )

	FlagSet( "FriendlyFireStrict" )

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	AddScriptNoteworthySpawnCallback( "LogRollRoomStalker", LogRollRoomStalkerSpawnCallback )

	AddMobilityGhost( $"anim_recording/spoke0_electric1.rpak" )
	AddMobilityGhost( $"anim_recording/spoke0_electric2.rpak" )
	AddMobilityGhost( $"anim_recording/spoke0_electric3.rpak" )
	AddMobilityGhost( $"anim_recording/spoke0_electric4.rpak" )
	AddMobilityGhost( $"anim_recording/spoke0_electric5.rpak" )
	AddMobilityGhost( $"anim_recording/spoke0_vertical_fan1.rpak", "Fan1Enabled" )
	AddMobilityGhostWithCallback( $"anim_recording/spoke0_first_arc_fan.rpak", GhostRecorderCallback_FirstArcFan )
	AddMobilityGhost( $"anim_recording/spoke0_fly_through_vent.rpak", "vent_open" )
	AddMobilityGhostWithCallback( $"anim_recording/spoke0_three_fans.rpak", GhostRecorderCallback_TripleArcFans )
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
	thread BeaconBeamScreenEffects( player )
	thread WaitFan1Disable( player )
	thread PlayerEnteredFan1ControlRoom( player )
	thread BTHintAboutFan1( player )
	thread VerticalFansDialogue( player )
	thread SonicRunStart()
	thread BeginningGruntBanter( player )
	thread DoorGuyOpensDoor_Spoke0( player )
	thread Conversation1( player )
	thread Conversation2( player )
	thread BTPatchesIntoHelmet( player )

	Objective_Set( "#BEACON_OBJECTIVE_LOCATE_ARC_TOOL" )

	PlayMusic( "Music_Beacon_4_DescendIntoSubstation" )

	FlagWait( "FirstFight" )
}

void function StartPoint_Setup_Start( entity player )
{

}

void function StartPoint_Skipped_Start( entity player )
{
	thread BeaconBeamScreenEffects( player )
	thread WaitFan1Disable( player )
	thread PlayerEnteredFan1ControlRoom( player )
	thread BTHintAboutFan1( player )
	thread VerticalFansDialogue( player )
	thread SonicRunStart()
	thread Conversation1( player )
	thread Conversation2( player )
	thread BTPatchesIntoHelmet( player )

	FlagSet( "DisableSkitGruntBanter" )

	Objective_Set( "#BEACON_OBJECTIVE_LOCATE_ARC_TOOL" )
}

void function BeginningGruntBanter( entity player )
{
	array<string> skitNames
	skitNames.append( "skit_turret_repair" )
	skitNames.append( "skit_window_a" )
	skitNames.append( "skit_window_b" )
	skitNames.append( "skit_arc_mine_activate" )
	skitNames.append( "skit_dumpbody_over_railing" )
	skitNames.append( "skit_kickbody_over_edge" )
	skitNames.append( "skit_ammo_box" )
	skitNames.append( "skit_gearup" )

	array< array<string> > chatAliases
	chatAliases.append( ["RandomGrunt_Banter_2"] )			// Pilot, more Stalkers are expected... We'll hold them off but don't be gone too long.
	chatAliases.append( ["RandomGrunt_Banter_3"] )			// We're getting low on ammo... and soldiers.
	chatAliases.append( ["RandomGrunt_Banter_4"] )			// We're doing our best down here.
	chatAliases.append( ["RandomGrunt_Banter_5"] )			// It's great to have a Pilot with us again. Looks like we'll have a chance of getting out alive after all.
	chatAliases.append( ["RandomGrunt_Banter_6"] )			// I wonder how deep this facility goes.
	chatAliases.append( ["RandomGrunt_Banter_7"] )			// Careful people. These Stalkers can come out of the walls...Stay alert.
	chatAliases.append( ["RandomGrunt_Banter_9"] )			// This place is run by machines. It's not like there's an elevator around here. How's he gonna get through this place?
	chatAliases.append( ["RandomGrunt_Banter_10"] )			// It looks like they can turtle up to protect their heads. That's why they were so hard to kill...
	chatAliases.append( ["RandomGrunt_Banter_11"] )			// Wish I could tell you what's down there, but whatever it is, we're hoping you can handle it, Pilot.

	chatAliases.append( [ 	"RandomGrunt_Banter_1a",		// Who is this loudspeaker talking to? It's not like these tin-cans speak english.
							"RandomGrunt_Banter_1b" ] )		// Maybe they can...
	chatAliases.append( [ 	"RandomGrunt_Banter_8a",		// We should just seal this place off and be done with it...
							"RandomGrunt_Banter_8b" ] )		// That's your answer to everything, Barry.

	FlagWait( "FacilityVO1" )
	wait 4.0 // wait for opening loud speaker to finish

	thread SkitGruntsSpeakLinesNearPlayer( player, skitNames, chatAliases, "DisableSkitGruntBanter" )
}

void function DoorGuyOpensDoor_Spoke0( entity player )
{
	// Spawn grunt and spectre model
	entity node = GetEntByScriptName( "door_guy_ref" )
	entity grunt = CreateSoldier( TEAM_MILITIA, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( grunt )
	grunt.EndSignal( "OnDeath" )
	EndSignal( player, "OnDeath" )

	// Idle
	thread PlayAnimTeleport( grunt, "pt_spotter_A_start_idle", node )

	// Speak line when player gets close
	for(;;)
	{
		if ( !IsValid( player ) || Distance( player.GetOrigin(), grunt.GetOrigin() ) > 450 )
			break
		WaitFrame()
	}

	// The last Pilot in our unit went that way a few hours ago, but he never came back. Be careful.
	thread PlayDialogue( "RandomGrunt_LastPilotWentThatWay", grunt )
}

//---------------------------------------------------------------------

//	███████╗██╗██████╗ ███████╗████████╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
//	██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
//	█████╗  ██║██████╔╝███████╗   ██║       █████╗  ██║██║  ███╗███████║   ██║
//	██╔══╝  ██║██╔══██╗╚════██║   ██║       ██╔══╝  ██║██║   ██║██╔══██║   ██║
//	██║     ██║██║  ██║███████║   ██║       ██║     ██║╚██████╔╝██║  ██║   ██║
//	╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

void function StartPoint_FirstFight( entity player )
{
	thread LogRollRoomFight( player )
	FlagSet( "DisableSkitGruntBanter" )
	FlagWait( "ArcToolRoom" )
}

void function StartPoint_Setup_FirstFight( entity player )
{
	TeleportPlayerAndBT( "first_fight_player_start" )
}

void function StartPoint_Skipped_FirstFight( entity player )
{
	FlagSet( "Fan1Disable" )
}

void function LogRollRoomFight( entity player )
{
	FlagWait( "PlayerEnteredRestrictedArea" )

	TriggerManualCheckPoint( null, <704, 4668, 498>, true )

	PlayMusic( "Music_Beacon_5_FirstCombat" )
	thread LogRollRoomFightDialogue( player )

	array<entity> spawners

	//#####################
	// WAVE 1
	//#####################

	printt( "####################" )
	printt( "       WAVE 1       " )
	printt( "####################" )

	// Spawn drones
	spawners = GetEntArrayByScriptName( "LogRollDroneSpawner" )
	foreach( entity spawner in spawners )
	{
		entity enemy = spawner.SpawnEntity()
		DispatchSpawn( enemy )
		file.logRollRoomEnemies.append( enemy )
	}

	// Spawn stalkers
	spawners = GetEntArrayByScriptName( "LogRollStalkerSpawner_Wave1" )
	foreach( entity spawner in spawners )
	{
		entity enemy = spawner.SpawnEntity()
		DispatchSpawn( enemy )
	}

	// Spawn stalkers from racks
	spawners = GetEntArrayByScriptName( "LogRollStalkerRack_Wave1" )
	foreach( entity spawner in spawners )
		thread SpawnFromStalkerRack( spawner )

	// Wait for Wave 1 to be thinned out
	wait 6.0
	while( file.logRollRoomEnemies.len() > 3 )
	{
		wait 1.0
		ArrayRemoveDead( file.logRollRoomEnemies )
		printt( "WAVE 1 ENEMIES:", file.logRollRoomEnemies.len() )
	}

	//#####################
	// WAVE 2
	//#####################

	printt( "####################" )
	printt( "       WAVE 2       " )
	printt( "####################" )

	// Stalker racks
	spawners = GetEntArrayByScriptName( "LogRollStalkerRack_Wave2" )
	foreach( entity spawner in spawners )
		thread SpawnFromStalkerRack( spawner )

	// Wait for Wave 2 to be thinned out
	wait 3.0
	while( file.logRollRoomEnemies.len() > 3 )
	{
		wait 1.0
		ArrayRemoveDead( file.logRollRoomEnemies )
		printt( "WAVE 2 ENEMIES:", file.logRollRoomEnemies.len() )
	}

	//#####################
	// WAVE 3 - gate opens
	//#####################

	spawners = GetEntArrayByScriptName( "LogRollStalkerSpawner_Door" )
	foreach( entity spawner in spawners )
	{
		entity enemy = spawner.SpawnEntity()
		DispatchSpawn( enemy )
	}

	FlagSet( "LogRollRoomDoorOpen" )
}

void function LogRollRoomFightDialogue( entity player )
{
	entity loudSpeaker = GetEntByScriptName( "loudspeaker_restricted_area" )

	// Unauthorized human personnel detected. Deploying automated security forces.
	PlayDialogue( "Facility_UnauthorizedHuman", loudSpeaker )
}

//---------------------------------------------------------------------

//	 ██████╗ ███████╗████████╗     █████╗ ██████╗  ██████╗    ████████╗ ██████╗  ██████╗ ██╗
//	██╔════╝ ██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║
//	██║  ███╗█████╗     ██║       ███████║██████╔╝██║            ██║   ██║   ██║██║   ██║██║
//	██║   ██║██╔══╝     ██║       ██╔══██║██╔══██╗██║            ██║   ██║   ██║██║   ██║██║
//	╚██████╔╝███████╗   ██║       ██║  ██║██║  ██║╚██████╗       ██║   ╚██████╔╝╚██████╔╝███████╗
//	 ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝

void function StartPoint_GetArcTool( entity player )
{
	printt( "Start Point - Get Charge Tool" )

	thread MarvinOperatesArcTool( player )
	thread FacilityTurbineTestDialogue()
	
	for(;;)
	{
		if ( !IsValid( player ) || !HasBatteryChargeTool( player ) )
			break
		WaitFrame()
	}

	FlagSet( "HasChargeTool" )
}

void function StartPoint_Setup_GetArcTool( entity player )
{
	TeleportPlayerAndBT( "get_charge_tool_player_start" )
}

void function StartPoint_Skipped_GetArcTool( entity player )
{
	FlagSet( "HasChargeTool" )
	if ( !HasBatteryChargeTool( player ) )
		GiveBatteryChargeTool( player )
}

//---------------------------------------------------------------------

//	 ██████╗  ██████╗ ████████╗     █████╗ ██████╗  ██████╗    ████████╗ ██████╗  ██████╗ ██╗
//	██╔════╝ ██╔═══██╗╚══██╔══╝    ██╔══██╗██╔══██╗██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║
//	██║  ███╗██║   ██║   ██║       ███████║██████╔╝██║            ██║   ██║   ██║██║   ██║██║
//	██║   ██║██║   ██║   ██║       ██╔══██║██╔══██╗██║            ██║   ██║   ██║██║   ██║██║
//	╚██████╔╝╚██████╔╝   ██║       ██║  ██║██║  ██║╚██████╗       ██║   ╚██████╔╝╚██████╔╝███████╗
//	 ╚═════╝  ╚═════╝    ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝

void function StartPoint_GotArcTool( entity player )
{
	printt( "Start Point - Got Charge Tool" )

	Objective_Clear()
	UnlockAchievement( player, achievements.GET_ARC_TOOL )

	thread ArcToolLeaveRoomHints( player )
	thread FirstArcSwitchFacilityDialogue( player )

	// Well done, Pilot. You have acquired the Arc Tool. Return to the control room. We are ready to jumpstart the system.
	waitthread PlayDialogue( "BT_YouHaveTheArcTool", player )

	Objective_Set( "#BEACON_OBJECTIVE_RETURN_WITH_ARC_TOOL" )
	CheckPoint()
	FlagWait( "HorizontalFanStartPoint" )
}

void function StartPoint_Setup_GotArcTool( entity player )
{
	TeleportPlayerAndBT( "got_charge_tool_player_start" )
	if ( !HasBatteryChargeTool( player ) )
		GiveBatteryChargeTool( player )
}

void function StartPoint_Skipped_GotArcTool( entity player )
{
	Objective_Set( "#BEACON_OBJECTIVE_RETURN_WITH_ARC_TOOL" )
}

void function ArcToolLeaveRoomHints( entity player )
{
	FlagClear( "ReturnedToPlatformWithArcTool" )

	// When player lands on the platform and sets this flag the thread will end and stop giving the hints
	EndSignal( level, "ReturnedToPlatformWithArcTool" )

	wait 15.0

	if ( Flag( "ReturnedToPlatformWithArcTool" ) )
		return

	// Pilot, there appears to be an override switch on the central turbine.
	waitthread PlayDialogue( "BT_OverrideSwitchOnTurbine", player )

	wait 10.0

	if ( Flag( "ReturnedToPlatformWithArcTool" ) )
		return

	// Try using the Arc Tool on that switch. That should enable you to run across the face of the turbine.
	waitthread PlayDialogue( "BT_TryUsingArcToolOnSwitch", player )
	thread ArcToolLeaveRoomHintObjective( player )
}

void function ArcToolLeaveRoomHintObjective( entity player )
{
	if ( Flag( "ReturnedToPlatformWithArcTool" ) && !Flag( "ArcToolFan1" ) )
		return

	thread SwitchToArcToolNag( player, "ReturnedToPlatformWithArcTool" )

	entity ent = GetEntByScriptName( "arc_tool_marvin_target" )

	entity highlightEnt = CreatePropDynamic( ent.GetModelName(), ent.GetOrigin(), ent.GetAngles() )
	Highlight_ClearFriendlyHighlight( highlightEnt )
	Objective_InitEntity( highlightEnt )

	Objective_Set( "#BEACON_OBJECTIVE_USE_ARC_TOOL_ON_TURBINE", <0,0,0>, ent )
	Objective_StaticModelHighlightOverrideEntity( highlightEnt )

	FlagWaitClear( "ArcToolFan1" )

	Objective_Set( "#BEACON_OBJECTIVE_RETURN_WITH_ARC_TOOL" )
	highlightEnt.Destroy()
}

void function SwitchToArcToolNag( entity player, string endFlag )
{
	if ( Flag( endFlag ) )
		return
	FlagEnd( endFlag )
	EndSignal( player, "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
		}
	)
	wait 5


	while( true )
	{
		entity weapon = player.GetActiveWeapon()
		if ( IsValid( weapon ) && weapon.GetWeaponClassName() != "sp_weapon_arc_tool" )
		{
			DisplayOnscreenHint( player, "ArcToolHint" )
			waitthread WaitTillPlayerHasArcToolEquippedOrTimeout( player, 4.0 )
			ClearOnscreenHint( player )
		}
		wait 10
	}
}

void function WaitTillPlayerHasArcToolEquippedOrTimeout( entity player, float timeout = 8.0 )
{
	EndSignal( player, "OnDeath" )
	float endTime = Time() + timeout
	while ( Time() < endTime )
	{
		entity weapon = player.GetActiveWeapon()
		if ( IsValid( weapon ) && weapon.GetWeaponClassName() == "sp_weapon_arc_tool" )
			break
		WaitFrame()
	}
}

void function FirstArcSwitchFacilityDialogue( entity player )
{
	FlagClear( "PlayerNearFirstArcSwitch" )
	FlagWait( "PlayerNearFirstArcSwitch" )

	// Status - Beacon Three Power Substation - hostile force lockout protocols in effect for all critical access points - manual activation by Arc Tool required.
	thread PlayDialogue( "Facility_LockoutProtocols", GetEntByScriptName( "facility_speaker_fan1" ) )
}

//---------------------------------------------------------------------

//	██╗  ██╗ ██████╗ ██████╗ ██╗███████╗ ██████╗ ███╗   ██╗████████╗ █████╗ ██╗         ███████╗ █████╗ ███╗   ██╗███████╗
//	██║  ██║██╔═══██╗██╔══██╗██║╚══███╔╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║         ██╔════╝██╔══██╗████╗  ██║██╔════╝
//	███████║██║   ██║██████╔╝██║  ███╔╝ ██║   ██║██╔██╗ ██║   ██║   ███████║██║         █████╗  ███████║██╔██╗ ██║███████╗
//	██╔══██║██║   ██║██╔══██╗██║ ███╔╝  ██║   ██║██║╚██╗██║   ██║   ██╔══██║██║         ██╔══╝  ██╔══██║██║╚██╗██║╚════██║
//	██║  ██║╚██████╔╝██║  ██║██║███████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║███████╗    ██║     ██║  ██║██║ ╚████║███████║
//	╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝

void function StartPoint_HorizontalFan( entity player )
{
	printt( "Horizontal Fan" )
	thread FanRoomEnemiesEvents( player )
	thread FacilityCoolingDialogue( player )
	thread HorizontalFanRoomArcToolHint( player )

	FlagWait( "HorizontalFanComplete" )
}

void function StartPoint_Setup_HorizontalFan( entity player )
{
	TeleportPlayerAndBT( "horizontal_fan_player_start" )
}

void function StartPoint_Skipped_HorizontalFan( entity player )
{

}

void function HorizontalFanRoomArcToolHint( entity player )
{
	EndSignal( player, "OnDeath" )

	// Wait for player to be in the fan room
	FlagWait( "InsideFirstHorizontalFanRoom" )

	// Wait a while before we help them out
	wait 25.0

	// Don't do hint if they already activated the cooling panels
	if ( Flag( "WindPanels_HFan1" ) || Flag( "CompletedFirstHorizontalFanRoom" ) )
		return

	DisplayOnscreenHint( player, "ArcToolActivateSwitchesHint" )
	FlagWaitAny( "WindPanels_HFan1", "CompletedFirstHorizontalFanRoom" )
	ClearOnscreenHint( player )
}

void function FanRoomEnemiesEvents( entity player )
{
	FlagWait( "DeployingFanRoomEnemies" )

	PlayMusic( "Music_Beacon_7_SecondCombat" )

	// Deploying security reinforcements.
	PlayDialogue( "Facility_DeployingReinforcements", GetEntByScriptName( "fan_room_enemies_speaker" ) )
}

void function FacilityCoolingDialogue( entity player )
{
	FlagWait( "WindPanels_HFan1" )
	wait 1.5

	// Automated cooling process - activated.
	thread PlayDialogue( "Facility_CoolingProcessActivated", GetEntByScriptName( "loudspeaker_coolingroom_1" ) )

	FlagWait( "WindPanels" )
	wait 1.5

	// Heatsink cooldown in progress
	thread PlayDialogue( "Facility_CooldownInProgress", GetEntByScriptName( "loudspeaker_coolingroom_3" ) )
	wait 8.0

	// Heatsink temperature at 75 percent
	thread PlayDialogue( "Facility_Temp75Percent", GetEntByScriptName( "loudspeaker_coolingroom_3" ) )
	wait 25

	// Heatsink temperature at 50 percent
	thread PlayDialogue( "Facility_Temp50Percent", GetEntByScriptName( "loudspeaker_coolingroom_3" ) )
	wait 25

	// Heatsink temperature at 25 percent
	thread PlayDialogue( "Facility_Temp25Percent", GetEntByScriptName( "loudspeaker_coolingroom_3" ) )
}

//---------------------------------------------------------------------

//	██╗  ██╗ ██████╗ ██████╗ ██╗███████╗ ██████╗ ███╗   ██╗████████╗ █████╗ ██╗         ███████╗ █████╗ ███╗   ██╗███████╗    ██████╗  ██████╗ ███╗   ██╗███████╗
//	██║  ██║██╔═══██╗██╔══██╗██║╚══███╔╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║         ██╔════╝██╔══██╗████╗  ██║██╔════╝    ██╔══██╗██╔═══██╗████╗  ██║██╔════╝
//	███████║██║   ██║██████╔╝██║  ███╔╝ ██║   ██║██╔██╗ ██║   ██║   ███████║██║         █████╗  ███████║██╔██╗ ██║███████╗    ██║  ██║██║   ██║██╔██╗ ██║█████╗
//	██╔══██║██║   ██║██╔══██╗██║ ███╔╝  ██║   ██║██║╚██╗██║   ██║   ██╔══██║██║         ██╔══╝  ██╔══██║██║╚██╗██║╚════██║    ██║  ██║██║   ██║██║╚██╗██║██╔══╝
//	██║  ██║╚██████╔╝██║  ██║██║███████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║███████╗    ██║     ██║  ██║██║ ╚████║███████║    ██████╔╝╚██████╔╝██║ ╚████║███████╗
//	╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝

void function StartPoint_HorizontalFanDone( entity player )
{
	printt( "Horizontal Fan Complete" )
	PlayMusic( "Music_Beacon_8_ThirdCombat" )

	FlagWait( "FanRunStartPoint" )
}

void function StartPoint_Setup_HorizontalFanDone( entity player )
{
	TeleportPlayerAndBT( "horizontal_fan_complete_player_start" )
	FlagSet( "vent_open" )
}

void function StartPoint_Skipped_HorizontalFanDone( entity player )
{

}

void function FanVentsAnim()
{
	entity vents = GetEntByScriptName( "FanVents" )
	Assert( IsValid( vents ) )

	FlagWait( "vent_open" )

	vents.Anim_Play( "beacon_vents_animated" )
	wait 3.0
	vents.Hide()
}

//---------------------------------------------------------------------

//	███████╗ █████╗ ███╗   ██╗    ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗ ██╗   ██╗███╗   ██╗
//	██╔════╝██╔══██╗████╗  ██║    ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██║   ██║████╗  ██║
//	█████╗  ███████║██╔██╗ ██║    ██║ █╗ ██║███████║██║     ██║     ██████╔╝██║   ██║██╔██╗ ██║
//	██╔══╝  ██╔══██║██║╚██╗██║    ██║███╗██║██╔══██║██║     ██║     ██╔══██╗██║   ██║██║╚██╗██║
//	██║     ██║  ██║██║ ╚████║    ╚███╔███╔╝██║  ██║███████╗███████╗██║  ██║╚██████╔╝██║ ╚████║
//	╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

void function StartPoint_FanWallrun( entity player )
{
	printt( "Fan Wallrun" )

	FlagClear( "SpokeEntrance" )

	GetEntByScriptName( "FanBacktrackerBlocker" ).NotSolid()

	// Safe fix for rare bug keeping wallrun low friction after completing the long wallrun fan section
	Signal( player, "RestorePlayerFriction" )

	thread WallrunFansDialogueAndNPC( player )
	thread WallrunFansGruntBanter( player )
	thread WallrunFansDeathThread( player )

	AddModToArcTool( player, "ShorterSmartAmmoSearchDist" )

	FlagWait( "ExitSpoke0" )
	RemoveModToArcTool( player, "ShorterSmartAmmoSearchDist" )
	Coop_LoadMapFromStartPoint( "sp_beacon", "Spoke_0_Complete" )
}

void function StartPoint_Setup_FanWallrun( entity player )
{
	TeleportPlayerAndBT( "fan_wallrun_player_start" )
}

void function StartPoint_Skipped_FanWallrun( entity player )
{

}

void function AddModToArcTool( entity player, string mod )
{
	array<entity> weapons = player.GetMainWeapons()
	foreach( weapon in weapons )
	{
		if ( weapon.GetWeaponClassName() == "sp_weapon_arc_tool" )
		{
			if ( !weapon.HasMod( mod ) )
				weapon.AddMod( mod )
			break
		}
	}
}

void function RemoveModToArcTool( entity player, string mod )
{
	array<entity> weapons = player.GetMainWeapons()
	foreach( weapon in weapons )
	{
		if ( weapon.GetWeaponClassName() == "sp_weapon_arc_tool" )
		{
			if ( weapon.HasMod( mod ) )
				weapon.RemoveMod( mod )
			break
		}
	}
}
//---------------------------------------------------------------------

//	      ██╗     ███████╗██╗   ██╗███████╗██╗         ██╗      ██████╗  ██████╗ ██╗ ██████╗
//	      ██║     ██╔════╝██║   ██║██╔════╝██║         ██║     ██╔═══██╗██╔════╝ ██║██╔════╝
//	█████╗██║     █████╗  ██║   ██║█████╗  ██║         ██║     ██║   ██║██║  ███╗██║██║      █████╗
//	╚════╝██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║         ██║     ██║   ██║██║   ██║██║██║      ╚════╝
//	      ███████╗███████╗ ╚████╔╝ ███████╗███████╗    ███████╗╚██████╔╝╚██████╔╝██║╚██████╗
//	      ╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝

void function EntitiesDidLoad()
{
	Objective_InitEntity( GetEntByScriptName( "Fan1HackPanel" ) )

	SetGlobalForcedDialogueOnly( true )

	AddDeathCallback( "player", PlayerDeathCallback )

	thread HeatSinkActivationThink()
	thread DronePlatformsGroup1()
	thread DronePlatformsGroup2()
	thread FanVentsAnim()

	// Marvin Delta-Seven-Three-Zulu please report to sector Bravo-Seven.
	thread FacilityDialogueOnFlag( "FacilityVO1", GetEntByScriptName( "entrance_loudspeaker" ), "Facility_MarvinReportToSector" )

	// Status - Beacon Three Power Substation - power filtering - nominal.
	thread FacilityDialogueOnFlag( "FacilityVO2", GetEntByScriptName( "loudspeaker2" ), "Facility_PowerFilteringNominal" )

	// Status - Beacon Three Power Substation - shock resistant bombardment survival envelope is within acceptable operating limits.
	thread FacilityDialogueOnFlag( "FacilityVO3", GetEntByScriptName( "FacilityVO3Speaker" ), "Facility_AcceptableOperatingLimits" )

	// Marvin Delta-Seven-Four-Alpha - airflow regulation request - authorized.
	thread FacilityDialogueOnFlag( "FacilityVO4", GetEntByScriptName( "facility_speaker_fan1" ), "Facility_RequestAuthorized" )

	FlagSet( "WallFanPusher1Active" )
	FlagSet( "WallFanPusher2Active" )
	FlagSet( "WallFanPusher3Active" )
}

void function PlayerDeathCallback( entity player, var damageInfo )
{
	if ( !IsValid( player ) )
		return

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( damageSourceID == eDamageSourceId.electric_conduit )
	{
		printt( "Pilot_ElectricalZapDeath_1P" )
		EmitSoundOnEntity( player, "Pilot_ElectricalZapDeath_1P" )
	}
	else if ( damageSourceID == eDamageSourceId.turbine )
	{
		printt( "Pilot_ShredderFanDeath_1P" )
		EmitSoundOnEntity( player, "Pilot_ShredderFanDeath_1P" )
	}

}

void function BTPatchesIntoHelmet( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "BTPatchesIntoHelmet" )
	PlayDialogue( "BT_PatchedIntoHelmet", player )
}

void function Conversation1( entity player )
{
	FlagWait( "Conversation1" )
	thread PlayerConversation( "WhereAmIGoing", player )
}

void function Conversation2( entity player )
{
	FlagWait( "Conversation2" )
	thread PlayerConversation( "WhatIsThisPlace", player )
}

void function BTHintAboutFan1( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagEnd( "Fan1Disable" )
	FlagEnd( "EnteredFan1" )

	FlagWait( "Fan1Room" )

	wait 30

	PlayDialogue( "BT_HintFan1", player )
}

void function WaitFan1Disable( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagWait( "Fan1Disable" )
	FlagClear( "Fan1Enabled" )
	FlagClear( "DoveIntoFan1" )

	entity controlRoomSpeaker = GetEntByScriptName( "facility_speaker_fan1_controlroom" )
	entity speaker = GetEntByScriptName( "facility_speaker_fan1" )

	// Unscheduled turbine deactivation detected. Running diagnostics.
	thread PlayDialogue( "Facility_TurbineDeactivation", speaker )

	PlayMusic( "Music_Beacon_6_TurbineDeactivationStinger" )

	wait 2.0

	// Bypass successful. Fan exhaust is offline.
	thread PlayDialogue( "BT_FanOffline", player )

	wait 2.0

	// Intruder detected. Deploying security forces for further investigation.
	thread PlayDialogue( "Facility_IntruderDetected", controlRoomSpeaker )

	FlagWait( "DoveIntoFan1" )

	// Foreign object detected in turbine thermal exhaust shaft. Analysis inconclusive - excessive magnetic interference.
	thread PlayDialogue( "Facility_ForeignObject", speaker )
}

void function PlayerEnteredFan1ControlRoom( entity player )
{
	entity speaker = GetEntByScriptName( "facility_speaker_fan1_controlroom" )

	FlagWait( "PlayerInFan1ControlRoom" )

	// Anomaly detected. Organic. Code yellow. Unauthorized personnel. Unauthorized personnel.
	thread PlayDialogue( "Facility_AnomalyDetected", speaker )
}

void function SonicRunStart()
{
	entity trigger = GetEntByScriptName( "fan_push_start" )

	// Wait for the player to jump off the platform to get sucked in
	entity player
	while(true)
	{
		table results = WaitSignal( trigger, "OnTrigger" )
		entity activator = expect entity( results.activator )
		if ( !IsValid( activator ) )
			continue
		if ( !activator.IsPlayer() )
			continue
		player = activator
		break
	}

	//if ( GetBugReproNum() == 81765 )
	//SonicRun_FullyAnimated( player )
	thread SonicRun_PlayerControlled_Friction( player )
	SonicRun_PlayerControlled( player )
}

void function SonicRun_PlayerControlled( entity player )
{
	entity path = GetEntByScriptName( "fan_push_path" )
	array<entity> sonicPathNodes = GetEntityLinkChain( path )
	//thread DebugDrawPath( sonicPathNodes )

	float startTime = Time()
	float fullPushTime = startTime + 3.0

	//DebugDrawLine( player.GetOrigin(), player.GetOrigin() + < 0, -1000, 0 >, 255, 0, 0, true, 30.0 )
	player.SetVelocity( < 0, -1000, 100 > )

	while( IsValid( player ) )
	{
		vector p = player.GetOrigin()
		float fractionOnPath = GetFractionAlongPath( sonicPathNodes, p )
		vector pointOnPath = GetPointOnPathForFraction( sonicPathNodes, fractionOnPath )

		float distFromPath = Distance( p, pointOnPath )
		if ( distFromPath > 512 )
		{
			WaitFrame()
			continue
		}

		if ( fractionOnPath >= 1.0 )
		{
			Signal( player, "RestorePlayerFriction" )
			WaitFrame()
			continue
		}

		vector pointOnPathForward = GetPointOnPathForFraction( sonicPathNodes, fractionOnPath + 0.03 )
		float windStrength = 3500
		float frameTime = 0.01666667
		vector windPush

		if ( fractionOnPath <= 0.25 )
		{
			// At the start of the path we do some course correction to make sure the player goes into the hole
			float correctionFrac = GraphCapped( fractionOnPath, 0.0, 0.25, 0.0, 1.0 )

			vector vecToPath = Normalize( pointOnPath - p ) * 200
			vector windVec = Normalize( pointOnPathForward - pointOnPath ) * 1000

			vector blendedVec = Normalize( ( vecToPath + windVec ) * 0.5 ) * 2000

			//DebugDrawLine( p, p + ( vecToPath ), 255, 255, 255, true, 0.1 )
			//DebugDrawLine( p, p + ( windVec ), 255, 255, 0, true, 0.1 )
			//DebugDrawLine( p, p + ( blendedVec ), 255, 0, 0, true, 0.1 )

			windPush = blendedVec//Normalize( pointOnPathForward - pointOnPath ) * windStrength * frameTime
		}
		else
		{
			// Just simple wind push once in the tunnel
			windPush = Normalize( pointOnPathForward - pointOnPath ) * windStrength * frameTime
		}



		vector playerVelocity = player.GetVelocity()
		//printt( "playerVelocity:", playerVelocity )

		// Apply push to the velocity
		playerVelocity += windPush

		// Limit player speed
		float speedCap = GraphCapped( Time(), startTime, fullPushTime, 3000, 1200 )
		if ( Length( playerVelocity ) > speedCap )
			playerVelocity = Normalize( playerVelocity ) * speedCap

		//DebugDrawSphere( pointOnPath, 25.0, 255, 255, 0, true, 0.1 )
		//DebugDrawLine( p, p + playerVelocity, 255, 0, 0, true, 0.1 )
		//printt( "wind push:", Length( playerVelocity ) )

		// Apply new force to ent
		if ( !player.IsNoclipping() )
			player.SetVelocity( playerVelocity )

		WaitFrame()
	}
}

void function SonicRun_PlayerControlled_Friction( entity player )
{
	float defaultGroundFriction = player.GetGroundFrictionScale()
	float defaultWallrunFriction = player.GetWallrunFrictionScale()

	player.SetGroundFrictionScale( 0.0 )
	player.SetWallrunFrictionScale( 0.0 )
	player.e.windPushEnabled = false

	EndSignal( player, "OnDeath" )

	WaitSignal( player, "RestorePlayerFriction" )

	float startTime = Time()
	float endTime = startTime + 2.0
	while( Time() <= endTime )
	{
		float groundFrac = GraphCapped( Time(), startTime, endTime, 0.0, defaultGroundFriction )
		float wallrunFrac = GraphCapped( Time(), startTime, endTime, 0.0, defaultWallrunFriction )
		player.SetGroundFrictionScale( groundFrac )
		player.SetWallrunFrictionScale( wallrunFrac )
		WaitFrame()
	}
	player.e.windPushEnabled = true

	//printt( "########################" )
	//printt( "PLAYER FRICTION RESTORED" )
	//printt( "########################" )
}

void function SonicRun_FullyAnimated( entity player )
{
	SonicRun_DoAnim( player, "ptpov_beacon_wind_tunnel", "pt_beacon_wind_tunnel" )

	vector velocity = AnglesToForward( < -7, -7, 0 > ) * 1100 // Aims a little up and to the right to put the player into a good wallrun
	player.SetVelocity( velocity )
	thread WindTunnelFriction( player )
}

void function SonicRun_DoAnim( entity player, string firstPersonAnim, string thirdPersonAnim )
{
	// Blend the player into the first person sequence and fly through the tunnel
	entity ref = GetEntByScriptName( "wind_tunnel_anim_ref" )
	entity animRef = CreateOwnedScriptMover( ref )

	player.ContextAction_SetBusy()
	player.ForceStand()

	FirstPersonSequenceStruct sequence
	sequence.blendTime = 1.0
	sequence.attachment = "ref"
	sequence.hideProxy = true
	sequence.firstPersonAnim = firstPersonAnim
	sequence.thirdPersonAnim = thirdPersonAnim
	sequence.viewConeFunction = ViewConeNarrow

	thread HandleWindTunnelAnimSignals( player )
	waitthread FirstPersonSequence( sequence, player, animRef )

	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	player.SetOneHandedWeaponUsageOff()
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.UnforceStand()
}

void function DebugDrawPath( array<entity> nodes )
{
	foreach( entity node in nodes )
	{
		entity nextNode = node.GetLinkEnt()
		if ( !IsValid( nextNode ) )
			return
		DebugDrawLine( node.GetOrigin(), nextNode.GetOrigin(), 100, 100, 0, true, 9999 )
	}
}

void function MarvinOnDeath( entity npc, var damageInfo )
{
	if ( npc == file.arcToolMarvin && !Flag( "HasChargeTool" ) )
	{
		entity droppedWeapon = CreateWeaponEntityByName( "sp_weapon_arc_tool", npc.GetOrigin() + <0,0,4>, <0,10,90> )
		droppedWeapon.kv.fadedist = -1
		HighlightWeapon( droppedWeapon )
	}
}

void function VerticalFansDialogue( entity player )
{
	FlagWait( "Fan1Room" )

	wait 3.5

	Objective_Set( "#BEACON_OBJECTIVE_DISABLE_TURBINE", < 0, 0, 48 >, GetEntByScriptName( "Fan1HackPanel" ) )

	// Marvin Delta- Two-One-Bravo - retune blade angle on turbine four to - one point eight-seven degrees.
	thread PlayDialogue( "Facility_RetuneBladeAngle", GetEntByScriptName( "facility_speaker_fan1" ) )

	FlagWait( "Fan1Disable" )

	Objective_Set( "#BEACON_OBJECTIVE_LOCATE_ARC_TOOL" )

	WaitTillLookingAt( player, GetEntByScriptName( "dive_in_lookat" ), true, 45, 0, 10.0 )

	if ( !Flag( "DoveIntoFan1" ) )
	{
		// Go ahead and dive in - your jumpkit can take that fall.
		thread PlayDialogue( "BT_GoAheadJumpIn", player )
	}
}

void function WallrunFansDialogueAndNPC( entity player )
{
	entity gruntNode = GetEntByScriptName( "welcome_back_node" )
	entity gruntSpawner = GetEntByScriptName( "return_grunt_spawner" )
	entity secondGruntSoundEnt = GetEntByScriptName( "return_grunt_second_grunt_vo_node" )

	// Spawn the grunt and have him idle
	entity grunt = gruntSpawner.SpawnEntity()
	DispatchSpawn( grunt )
	Assert( IsValid( grunt ) )
	grunt.kv.alwaysalert = true
	grunt.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )

	// Wait for the player to start the fan wallruns
	//thread PlayAnimTeleport( grunt, "pt_welcomeback_start_idle", gruntNode )

	//FlagWait( "StartedTripleFanRun" )

	// Player is wallrunning on the fans
	waitthread PlayAnim( grunt, "pt_welcomeback_start_2_watch", gruntNode )
	thread PlayAnim( grunt, "pt_welcomeback_watch_idle", gruntNode )

	// Player made it back
	FlagWait( "SpokeEntrance" )

	StopMusicTrack( "Music_Beacon_8_ThirdCombat" )
	PlayMusic( "music_beacon_8a_jumpingsuccess" )

	waitthread PlayAnim( grunt, "pt_welcomeback_end", gruntNode )
	entity exitnode = GetEntByScriptName( "welcomebackguyexitnode" )
	grunt.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
	grunt.AssaultPoint( exitnode.GetOrigin() )
	grunt.AssaultSetAngles( exitnode.GetAngles(), true )
	grunt.AssaultSetGoalRadius( 256 )

	// Grunts say random things to pilot again
	array<string> skitNames
	skitNames.append( "skit_turret_repair" )
	skitNames.append( "skit_window_a" )
	skitNames.append( "skit_window_b" )
	skitNames.append( "skit_arc_mine_activate" )
	skitNames.append( "skit_dumpbody_over_railing" )
	skitNames.append( "skit_kickbody_over_edge" )

	array< array<string> > chatAliases
	if ( file.fanWallrunDeathCount < 3 )
	{
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter1"] )	// That was some amazing moves.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter2"] )	// That's not in the Pilot handbook.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter3"] )	// He's got the Arc Tool. Now that's impressive.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter4"] )	// Welcome back, sir. Those moves were something else.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter5"] )	// You, sir, are one hell of a Pilot.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter6"] )	// Good to see you back here safely, Pilot. That Arc Tool is just what we need to signal the Militia fleet.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter7"] )	// They must be stepping up their Pilot training...I gotta work out more if I'm gonna keep up.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Few_Banter8"] )	// There's no giving up today, guys. That Pilot went down there and got us an Arc Tool. We're still in business.
	}
	else
	{
		chatAliases.append( ["Grunt_FanWallrunSuccess_Multi_Banter1"] )	// Looks like you've been to hell and back... We're glad you made it, Pilot.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Multi_Banter2"] )	// I can't imagine what you just went through down there. Great work, Pilot.
		chatAliases.append( ["Grunt_FanWallrunSuccess_Multi_Banter3"] )	// You made it all the way around and found an Arc Tool. If I had a medal I'd give it to you. Well done, sir.
	}

	thread SkitGruntsSpeakLinesNearPlayer( player, skitNames, chatAliases )
}

void function WallrunFansGruntBanter( entity player )
{
	entity soundEnt = GetEntByScriptName( "fan_wallrun_grunt_talk_pos" )

	// Is that the Pilot? He must be crazy making those jumps!
	waitthread PlayDialogue( "Grunt_FanWallrun_Banter1", soundEnt )

	// That's him! That's the Pilot. He gonna make it. I thought he was lost for sure.
	thread PlayDialogue( "Grunt_FanWallrun_Banter2", soundEnt )

	FlagWait( "ClearedFan1" )

	// Those fans are pouring out deadly exhaust! Be careful Sir!
	thread PlayDialogue( "Grunt_FanWallrun_Banter3", soundEnt )

	FlagWait( "ClearedFan2" )

	// One more, Pilot, and we're heading home. We got your back.
	thread PlayDialogue( "Grunt_FanWallrun_Banter4", soundEnt )
}

void function WallrunFansDeathThread( entity player )
{
	FlagEnd( "SpokeEntrance" )

	entity soundEnt = GetEntByScriptName( "fan_wallrun_grunt_talk_pos" )

	while( true )
	{
		WaitSignal( player, "QuickDeath" )

		file.fanWallrunDeathCount++

		if ( file.fanWallrunDeathCount == 1 )
		{
			// Sir! No!
			thread PlayDialogue( "Grunt_FanWallrun_Death1", soundEnt )
		}
		else if ( file.fanWallrunDeathCount == 2 )
		{
			// Watch out! No!
			thread PlayDialogue( "Grunt_FanWallrun_Death2", soundEnt )
		}
		else if ( file.fanWallrunDeathCount == 3 )
		{
			// Pilot down!
			thread PlayDialogue( "Grunt_FanWallrun_Death3", soundEnt )
		}
	}
}

void function MarvinOperatesArcTool( entity player )
{
	entity spawner = GetSpawnerByScriptName( "arc_marvin_spawner" )
	entity marvin = spawner.SpawnEntity()
	DispatchSpawn( marvin )
	marvin.SetNPCFlag( NPC_NO_WEAPON_DROP, true )

	Signal( marvin, "StopDoingJobs" )
	marvin.AssaultSetArrivalTolerance( 4 )
	marvin.AssaultPoint( marvin.GetOrigin() )

	marvin.GiveWeapon( "sp_weapon_arc_tool" )
	file.arcToolMarvin = marvin
	Assert( IsValid( marvin ) )

	EndSignal( marvin, "OnDeath" )
	EndSignal( marvin, "OnDestroy" )
	EndSignal( marvin, "MarvinStopWorkingArcTool" )

	entity arc_switch = GetEntByScriptName( "arc_tool_marvin_target" )
	entity marvin_node = GetEntByScriptName( "arc_marvin_node" )

	thread MarvinGivesArcToolToPlayerPeacefully( marvin )
	thread GetArcToolFromMarvinDialogue( marvin, player )
	thread MarvinShotActivatesSwitch( marvin, arc_switch )

	while( IsAlive( marvin ) )
	{
		// Shoot
		marvin.Anim_ScriptedPlayWithRefPoint( "mv_arctool_fire", marvin_node.GetOrigin(), marvin_node.GetAngles(), 0.1 )
		WaittillAnimDone( marvin )

		// Idle
		marvin.Anim_ScriptedPlayWithRefPoint( "mv_arctool_idle", marvin_node.GetOrigin(), marvin_node.GetAngles(), 0.1 )

		wait 1.0
	}
}

void function MarvinShotActivatesSwitch( entity marvin, entity arc_switch )
{
	EndSignal( marvin, "OnDeath" )
	EndSignal( marvin, "OnDestroy" )
	EndSignal( marvin, "MarvinStopWorkingArcTool" )
	EndSignal( arc_switch, "OnDestroy" )

	while( IsValid( marvin ) )
	{
		// Wait until marvin shoots
		marvin.WaitSignal( "marvin_shot_switch" )

		// Activate the arc switch
		Signal( arc_switch, "ArcEntityDamaged", { attacker = marvin } )
	}
}

void function FacilityTurbineTestDialogue()
{
	entity arc_switch = GetEntByScriptName( "arc_tool_marvin_target" )
	entity speaker = GetEntByScriptName( "loudspeaker_arc_tool_room" )

	array<string> lines = [
		"Facility_TurbineIteration1",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred eighty seven - complete.
		"Facility_TurbineIteration2",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred eighty eight - complete.
		"Facility_TurbineIteration3",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred eighty nine - complete.
		"Facility_TurbineIteration4",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred ninety - complete.
		"Facility_TurbineIteration5",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred ninety-one - complete.
		"Facility_TurbineIteration6",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred ninety-two - complete.
		"Facility_TurbineIterationReverse"	// Marvin Delta-Five-One-X-Ray - standby for iteration in reverse sequence for efficiency analysis.
		"Facility_TurbineIteration5",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred ninety-one - complete.
		"Facility_TurbineIteration4",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred ninety - complete.
		"Facility_TurbineIteration3",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred eighty nine - complete.
		"Facility_TurbineIteration2",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred eighty eight - complete.
		"Facility_TurbineIteration1",		// Marvin Delta-Five-One-X-Ray - turbine power cycle iteration sixteen thousand four hundred eighty seven - complete.
	]

	EndSignal( arc_switch, "OnDestroy" )
	while( true )
	{
		foreach( string line in lines )
		{
			WaitSignal( arc_switch, "ArcEntityDamaged" )
			wait 2.4
			PlayDialogue( line, speaker )
		}
	}
}

void function GetArcToolFromMarvinDialogue( entity marvin, entity player )
{
	//WaitTillLookingAt( player, marvin, true, 45, 1300, 20.0 )
	FlagWait( "ArcToolDetected" )

	Objective_Set( "#BEACON_OBJECTIVE_GET_ARC_TOOL_FROM_MARVIN", GetEntByScriptName( "arc_marvin_node" ).GetOrigin() + < 0, 0, 52 > )

	if ( IsValid( marvin ) )
	{
		// Arc Tool detected at 30 meters.
		waitthread PlayDialogue( "BT_MarvinHasArcTool", player )
	}
}

void function MarvinGivesArcToolToPlayerPeacefully( entity marvin )
{
	EndSignal( marvin, "OnDeath" )
	EndSignal( marvin, "OnDestroy" )

	marvin.SetUsableByGroup( "pilot" )
	marvin.SetUsePrompts( "#BEACON_MARVIN_USE_HINT_HOLD" , "#BEACON_MARVIN_USE_HINT_PRESS" )
	marvin.SetUsable()

	entity player
	while( true )
	{
		table results = marvin.WaitSignal( "OnPlayerUse" )
		player = expect entity( results.player )
		if ( !IsValid( player ) )
			continue
		if ( !player.IsPlayer() )
			continue
		break
	}
	marvin.UnsetUsable()

	thread TriggerManualCheckPoint( player, player.GetOrigin(), true )

	// Stop marvin from doing arc tool cycle
	Signal( marvin, "MarvinStopWorkingArcTool" )
	marvin.Code_Anim_Stop()

	// Player first person sequence taking the gun
	waitthread ArcToolFirstPersonSequence( player, marvin )

	// Idle after losing the arc tool
	entity marvin_node = GetEntByScriptName( "arc_marvin_node" )
	marvin.Anim_ScriptedPlayWithRefPoint( "mv_arctool_steal_endidle", marvin_node.GetOrigin(), marvin.GetAngles(), 1.0 )
}

void function ArcToolFirstPersonSequence( entity player, entity marvin )
{
	marvin.SetInvulnerable()
	player.DisableWeapon()

	entity node = GetEntByScriptName( "arc_marvin_node" )
	vector playerFacingAngles = VectorToAngles( node.GetOrigin() - player.GetOrigin() )
	entity mover = CreateScriptMover( node.GetOrigin(), FlattenAngles( playerFacingAngles ) )

	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.3
	sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_beacon_arc_tool_steal"
	sequence.thirdPersonAnim = "pt_beacon_arc_tool_steal"
	sequence.viewConeFunction = ViewConeTight

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
				
				// Give arc tool to player
				// if ( !HasWeapon( player, CHARGE_TOOL ) )
				GiveBatteryChargeTool( player )
				player.SetActiveWeaponByName( CHARGE_TOOL )
				player.EnableWeapon()
		}
		}
	)

	entity fpProxy = player.GetFirstPersonProxy()
	int attachID = fpProxy.LookupAttachment( "PROPGUN" )
	entity weaponModel = CreatePropDynamic( ARC_TOOL_VIEW_MODEL, fpProxy.GetAttachmentOrigin( attachID ), fpProxy.GetAttachmentAngles( attachID ) )
	weaponModel.SetParent( player.GetFirstPersonProxy(), "PROPGUN", false, 0.0 )
	//weaponModel.RenderWithViewModels( true )
	weaponModel.Anim_Play( "arc_tool_steal" )

	weaponModel.Hide()

	thread MarvinLoseArcToolSignal( marvin )
	thread AnimAttachArcTool( player, weaponModel )
	thread PlayAnim( marvin, "mv_arctool_steal", mover, null, 0.0 )
	marvin.Anim_AdvanceCycleEveryFrame( true )
	waitthread FirstPersonSequence( sequence, player, mover )

	if ( IsValid( weaponModel ) )
		weaponModel.Destroy()
}

void function MarvinLoseArcToolSignal( entity marvin )
{
	EndSignal( marvin, "OnDeath" )

	WaitSignal( marvin, "marvin_lose_arc_tool" )

	marvin.TakeActiveWeapon()

	wait 3.0
	marvin.SetSkin(2) //sad face
}

void function AnimAttachArcTool( entity player, entity weaponModel )
{
	EndSignal( player, "OnDeath" )
	WaitSignal( player.GetFirstPersonProxy(), "attach_arc_tool" )
	weaponModel.Show()
}

void function HeatSinkActivationThink()
{
	bool active = false
	while( true )
	{
		if ( active )
		{
			while( Flag( "WindPanels_HFan1" ) || Flag( "WindPanels_HFan2" ) || Flag( "WindPanels" ) )
				WaitFrame()
			active = false
		}
		else
		{
			FlagWaitAny( "WindPanels_HFan1", "WindPanels_HFan2", "WindPanels" )
			active = true
		}

		level.nv.heatSinkStartTime = Time()
		level.nv.heatSinksCooling = active

		WaitFrame()
	}
}

void function HandleWindTunnelAnimSignals( entity player )
{
	EndSignal( player, "OnAnimationDone" )
	
	// what if you never wallrun?
	while( true )
	{
		WaitSignal( player, "wallrun_start" )
		player.SetOneHandedWeaponUsageOn()

		WaitSignal( player, "wallrun_end" )
		player.SetOneHandedWeaponUsageOff()
	}
}

void function WindTunnelFriction( entity player )
{
	float defaultGroundFrictionScale = player.GetGroundFrictionScale()
	float defaultWallrunFrictionScale = player.GetWallrunFrictionScale()

	EndSignal( player, "OnDestroy" )
	OnThreadEnd(
		function() : ( player, defaultGroundFrictionScale, defaultWallrunFrictionScale )
		{
			if ( IsValid( player ) )
			{
				player.SetGroundFrictionScale( defaultGroundFrictionScale )
				player.SetWallrunFrictionScale( defaultWallrunFrictionScale )
			}
		}
	)

	player.SetGroundFrictionScale( 0.0 )
	player.SetWallrunFrictionScale( 0.0 )

	float duration = 2.5
	float delay = 0.5
	float startTime = Time() + delay
	float endTime = startTime + duration

	wait delay

	while( Time() <= endTime )
	{
		float frac = GraphCapped( Time(), startTime, endTime, 0.0, 1.0 )
		player.SetGroundFrictionScale( frac )
		player.SetWallrunFrictionScale( frac )
		WaitFrame()
	}
}

void function FacilityDialogueOnFlag( string flag, entity speaker, string dialogueName )
{
	Assert( IsValid( speaker ) )
	EndSignal( speaker, "OnDestroy" )
	FlagWait( flag )
	thread PlayDialogue( dialogueName, speaker )
}

void function DronePlatformsGroup1()
{
	FlagInit( "StartDronePlatformsGroup1" )
	FlagWait( "StartDronePlatformsGroup1" )

	entity droneSpawn01 = GetEntByScriptName( "DronePlatform01" )
	entity droneSpawn02 = GetEntByScriptName( "DronePlatform02" )
	entity droneSpawn03 = GetEntByScriptName( "DronePlatform03" )
	entity droneSpawn04 = GetEntByScriptName( "DronePlatform05" )
	entity droneSpawn05 = GetEntByScriptName( "DronePlatform05" )

	entity drone01 = droneSpawn01.SpawnEntity()
	DispatchSpawn( drone01 )
	entity drone02 = droneSpawn02.SpawnEntity()
	DispatchSpawn( drone02 )
	entity drone03 = droneSpawn03.SpawnEntity()
	DispatchSpawn( drone03 )
	wait 1.0
	entity drone04 = droneSpawn04.SpawnEntity()
	DispatchSpawn( drone04 )
	wait 1.0
	entity drone05 = droneSpawn05.SpawnEntity()
	DispatchSpawn( drone05 )
}

void function DronePlatformsGroup2()
{
	FlagInit( "StartDronePlatformsGroup2" )
	FlagWait( "StartDronePlatformsGroup2" )

	entity droneSpawn08 = GetEntByScriptName( "DronePlatform08" )

	entity drone08 = droneSpawn08.SpawnEntity()
	DispatchSpawn( drone08 )
}

void function LogRollRoomStalkerSpawnCallback( entity npc )
{
	file.logRollRoomEnemies.append( npc )
	thread ChangeGoalRadiusAfterDelay( npc )
}

void function ChangeGoalRadiusAfterDelay( entity npc )
{
	EndSignal( npc, "OnDeath" )
	EndSignal( npc, "OnDestroy" )

	WaitSignal( npc, "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
	wait 15

	npc.AssaultSetGoalRadius( 3000 )
	npc.AssaultPoint( npc.GetOrigin() )
}

void function GhostRecorderCallback_FirstArcFan( entity ghost, entity weapon )
{
	EndSignal( ghost, "OnDestroy" )

	weapon.Destroy()

	entity arcTool = CreatePropScript( ARC_TOOL_GHOST_WORLD_MODEL )
	arcTool.kv.skin = 1
	arcTool.kv.rendercolor = "94 174 255" //Blue
	arcTool.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	arcTool.SetOwner( ghost )
	arcTool.SetParent( ghost, "PROPGUN", false )

	entity target = GetEntByScriptName( "arc_tool_marvin_target" )

	while( IsValid( ghost ) )
	{
		table results = WaitSignal( ghost, "animRecordingSignal" )
		if ( results.value == "shoot_first_arc_fan" )
			break
	}

	thread GhostFireArcToolAtEntity( ghost, arcTool, target )
}

void function GhostRecorderCallback_TripleArcFans( entity ghost, entity weapon )
{
	EndSignal( ghost, "OnDestroy" )

	weapon.Destroy()

	entity arcTool = CreatePropScript( ARC_TOOL_GHOST_WORLD_MODEL )
	arcTool.kv.skin = 1
	arcTool.kv.rendercolor = "94 174 255" //Blue
	arcTool.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	arcTool.SetOwner( ghost )
	arcTool.SetParent( ghost, "PROPGUN", false )

	entity target1 = GetEntByScriptName( "TripleFanArcSwitch1" )
	entity target2 = GetEntByScriptName( "TripleFanArcSwitch2" )
	entity target3 = GetEntByScriptName( "TripleFanArcSwitch3" )

	while( IsValid( ghost ) )
	{
		table results = WaitSignal( ghost, "animRecordingSignal" )
		if ( results.value == "triple_fans_shoot1" )
		{
			thread GhostFireArcToolAtEntity( ghost, arcTool, target1 )
		}
		else if ( results.value == "triple_fans_shoot2" )
		{
			thread GhostFireArcToolAtEntity( ghost, arcTool, target2 )
		}
		else if ( results.value == "triple_fans_shoot3" )
		{
			thread GhostFireArcToolAtEntity( ghost, arcTool, target3 )
			break
		}
	}
}