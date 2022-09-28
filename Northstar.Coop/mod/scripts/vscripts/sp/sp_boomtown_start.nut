const asset PANEL_MODEL = $"models/beacon/crane_room_monitor_console.mdl"


global function CodeCallback_MapInit

//WaterScreenEffect - flag when player is in water

void function CodeCallback_MapInit()
{
	if ( reloadingScripts )
		return

	AssemblyArmsInit()

	PrecacheModel( PANEL_MODEL )
	PrecacheModel( ARM_MODEL )
	PrecacheModel( ARM_MODEL_SMALL )

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	ShSpBoomtownStartCommonInit()

	AddCallback_EntitiesDidLoad( Boomtown_EntitiesDidLoad )
	AddPlayerDidLoad( Boomtown_PlayerDidLoad )

	FlagInit( "DeleteIntroTurretsAndProwlers" )
	FlagInit( "PickupBT" )
	FlagInit( "IntroRadioResponseConversationDone" )
	//FlagInit( "HighSpeedDangerousArea" )

	AddDeathCallback( "player", Boomtown_HandleSpecialDeathSounds )
	AddDeathCallback( "npc_titan", Boomtown_HandleSpecialDeathSounds )

	AddStartPoint( "Intro",				StartPoint_Intro,			StartPoint_Setup_Intro,				StartPoint_Skipped_Intro )
	AddStartPoint( "Prop House",		StartPoint_PropHouse,		StartPoint_Setup_PropHouse,			StartPoint_Skipped_PropHouse )
	AddStartPoint( "Narrow Hallway", 	StartPoint_NarrowHallway,	StartPoint_Setup_NarrowHallway,		StartPoint_Skipped_NarrowHallway )
	AddStartPoint( "Titan Arena", 		StartPoint_TitanArena,		StartPoint_Setup_TitanArena,		StartPoint_Skipped_TitanArena )
	AddStartPoint( "Loading Dock", 		StartPoint_LoadingDock,		StartPoint_Setup_LoadingDock,		StartPoint_Skipped_LoadingDock )
}

void function Boomtown_EntitiesDidLoad()
{
	thread LoadingDockArm1()
	thread LoadingDockArm2()
	thread BTGetsGrabbed()
	thread ElevatorThink()
	thread HighSpeedDangerousArea()

	array<entity> highSpeedMovers = GetEntArrayByScriptName( "HighSpeedMover" )
	foreach( entity mover in highSpeedMovers )
		mover.SetKillNPCOnPush( true )

	Objective_InitEntity( GetEntByScriptName( "ElevatorButton" ) )
	Objective_InitEntity( GetEntByScriptName( "ElevatorControl" ) )
}

void function Boomtown_PlayerDidLoad( entity player )
{
	if ( !IsValid( GetPlayer0() ) )
		SetPlayer0( player )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗███╗   ██╗████████╗██████╗  ██████╗
// ██║████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗
// ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║
// ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║
// ██║██║ ╚████║   ██║   ██║  ██║╚██████╔╝
// ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_Intro( entity player )
{
	//ScreenFade( player, 0, 0, 0, 255, 5.0, 2.0, (FFADE_IN | FFADE_PURGE) )
	entity BT = player.GetPetTitan()
	Assert( IsValid( BT ) )
	AssaultMoveTarget( BT, GetEntByScriptName( "bt_intro_move_target" ) )

	player.SetPlayerNetBool( "shouldShowWeaponFlyout", false )

	ShowIntroScreen( player )
	// Remote_CallFunction_NonReplay( player, "ServerCallback_LevelIntroText" )
	StartLevelStartText()
	FlagWait( "IntroScreenFading" )
	EndEvent()

	//wait 3.0

	thread ExitedTunnelMusic()
	thread ExitProwlerCaveMusic()
	thread EnterPropWarehouseMusic()
	thread ProwlerIntro( player )
	thread OpeningDialogue( player )
	thread PlayerInWaterConversation( player )
	thread GrottoConversation( player )
	thread IntroRadioDialogue( player )
	thread FirstRailTrees()
	thread GrottoTransmission( player )

	// Temp for coolness
	PlayMusic( "music_boomtown_01_intro" )

	FlagWait( "EnteredPropWarehouse" )
}

void function StartPoint_Setup_Intro( entity player )
{
	TeleportPlayerAndBT( "start_player_Intro", "start_bt_Intro" )
}


void function StartPoint_Skipped_Intro( entity player )
{
	Objective_Set( "#BOOMTOWN_OBJECTIVE_FIND_EXIT", <0,0,0> )
	thread FirstRailTrees()
}

void function ExitedTunnelMusic()
{
	FlagWait( "ExitedTunnel" )
	StopMusicTrack( "music_boomtown_01_intro" )
	PlayMusic( "music_boomtown_02_waterfall" )
}

void function ExitProwlerCaveMusic()
{
	FlagWait( "ExitedProwlerCaveMusic" )
	StopMusicTrack( "music_boomtown_02_waterfall" )
	PlayMusic( "music_boomtown_03_downthestep" )
}

void function EnterPropWarehouseMusic()
{
	FlagWait( "EnterPropWarehouseMusic" )
	StopMusicTrack( "music_boomtown_03_downthestep" )
	PlayMusic( "music_boomtown_04_ontoslide" )
}

void function OpeningDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	// Wait for screen fade to finish
	wait 2.0
	PlayBTDialogue( "BT_EXIT_BEYOND_CAVES" )

	thread SetObjectiveAndShowWeaponFlyout( player )

	// BT mentions cliff when you approach
	FlagWait( "WatchYourStepDialogue" )
	if ( player.IsTitan() )
		PlayBTDialogue( "BT_WATCH_OUR_STEP" )
	else
		PlayBTDialogue( "BT_WATCH_YOUR_STEP" )

}

void function SetObjectiveAndShowWeaponFlyout( entity player )
{
	EndSignal( player, "OnDeath" )

	wait 2.0
	Objective_Set( "#BOOMTOWN_OBJECTIVE_FIND_EXIT" )

	wait 2.0
	player.SetPlayerNetBool( "shouldShowWeaponFlyout", true )
}

void function GrottoConversation( entity player )
{
	FlagWait( "PlayerEnteringProwlerArea" )

	while ( IsDialoguePlaying() )
		wait 0.2

	PlayerConversation( "Grotto", player )
}

void function GrottoTransmission( entity player )
{
	entity trigger = GetEntByScriptName( "grotto_droppod_transmission_trigger" )
	entity org = trigger.GetLinkEnt()

	trigger.WaitSignal( "OnTrigger" )

	entity soundSource = CreateScriptMover()
	soundSource.SetOrigin( org.GetOrigin() )

	wait 0.5
	waitthread PlayDialogue( "diag_sp_podChatter_WD741_04_01_mcor_grunt1", soundSource )
	wait 0.5
	waitthread PlayDialogue( "diag_sp_podChatter_WD741_05_01_mcor_grunt2", soundSource )
	wait 0.5
	waitthread PlayDialogue( "diag_sp_podChatter_WD741_06_01_mcor_grunt3", soundSource )
}

void function PlayerInWaterConversation( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagEnd( "PlayerEnteringProwlerArea" )

	FlagWait( "PlayerInWater" )
	FlagClear( "PlayerOutOfWater" )

	wait 1.0
	if ( !player.IsTitan() )
		PlayerConversation( "PlayerJumpedInWater", player )

	// Player exited the water and got back up top, BT talks
	FlagWait( "PlayerOutOfWater" )
	if ( !player.IsTitan() )
		thread PlayBTDialogue( "BT_IMPRESSIVE" )
}

void function ProwlerIntro( entity player )
{
	// ?? get within 750 units of prowler OR within 1400 and in FOV, OR player shoots prowler or turret

	array<entity> prowlerSpawners = GetEntArrayByScriptName( "intro_prowler_spawner" )
	array<entity> turretSpawners = GetEntArrayByScriptName( "intro_turret_spawner" )

	// Wait for trigger
	FlagWait( "SpawnTurretsAndProwls" )

/*
	// Spawn turrets and prowlers
	array<entity> prowlers
	foreach( entity spawner in prowlerSpawners )
	{
		entity prowler = spawner.SpawnEntity()
		DispatchSpawn( prowler )
		prowlers.append( prowler )
	}

	array<entity> turrets
	foreach( entity spawner in turretSpawners )
	{
		entity turret = spawner.SpawnEntity()
		DispatchSpawn( turret )
		turrets.append( turret )
	}
*/
	FlagWait( "DeleteIntroTurretsAndProwlers" )
/*
	foreach( entity turret in turrets )
	{
		if ( IsValid( turret ) )
			turret.Destroy()
	}
	foreach( entity prowler in prowlers )
	{
		if ( IsValid( prowler ) )
			prowler.Destroy()
	}
*/
}

void function IntroRadioDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagWait( "IntroRadioDialogueStart" )

	// Ash, this is Blisk. How copy, over?
	PlayDialogue( "RADIO_BLISK_INTRO_RADIO_1", player )

	wait 0.5

	// This is Ash, go ahead.
	PlayDialogue( "RADIO_BLISK_INTRO_RADIO_2", player )

	// Kane is not responding. I think our Militia Pilot's tryin' to be a hero... He's got to be headed your way. Kill him.
	PlayDialogue( "RADIO_BLISK_INTRO_RADIO_3", player )

	wait 0.5

	// Understood. Ash out.
	PlayDialogue( "RADIO_BLISK_INTRO_RADIO_4", player )

	PlayerConversation( "IntroRadioResponse", player )

	FlagSet( "IntroRadioResponseConversationDone" )
}

void function FirstRailTrees()
{
	FlagWait( "FirstRailTreesGo" )

	while( Flag( "FirstRailTreesGo" ) )
	{
		FlagSet( "FirstRailTreesGo1" )
		wait 1.0
		FlagClear( "FirstRailTreesGo1" )
		wait 12.0

		FlagSet( "FirstRailTreesGo2" )
		wait 1.0
		FlagClear( "FirstRailTreesGo2" )
		wait 12.0
	}
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗ ██████╗  ██████╗ ██████╗     ██╗  ██╗ ██████╗ ██╗   ██╗███████╗███████╗
// ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗    ██║  ██║██╔═══██╗██║   ██║██╔════╝██╔════╝
// ██████╔╝██████╔╝██║   ██║██████╔╝    ███████║██║   ██║██║   ██║███████╗█████╗
// ██╔═══╝ ██╔══██╗██║   ██║██╔═══╝     ██╔══██║██║   ██║██║   ██║╚════██║██╔══╝
// ██║     ██║  ██║╚██████╔╝██║         ██║  ██║╚██████╔╝╚██████╔╝███████║███████╗
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝         ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_PropHouse( entity player )
{
	entity SavePoint = GetEntByScriptName( "start_player_PropHouse" )
	TriggerSilentCheckPoint( SavePoint.GetOrigin(), false )

	printt( "Start Point - Prop Warehouse" )

	FlagSet( "DeleteIntroTurretsAndProwlers" )
	thread GammaSquadSpotsYouDialogue( player )

	FlagWait( "NarrowHallway" )
}


void function StartPoint_Setup_PropHouse( entity player )
{
	TeleportPlayerAndBT( "start_player_PropHouse", "start_bt_PropHouse" )
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
}


void function StartPoint_Skipped_PropHouse( entity player )
{
}

void function GammaSquadSpotsYouDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagWait( "GammaSpotsPilotDialogue" )

	PlayDialogue( "RADIO_GAMMA_SQUAD_ITS_A_TITAN", player )
	//EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "GammaSpotsPilotDialogueLocation" ).GetOrigin(), "RADIO_GAMMA_SQUAD_ITS_A_TITAN" )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ███╗   ██╗ █████╗ ██████╗ ██████╗  ██████╗ ██╗    ██╗    ██╗  ██╗ █████╗ ██╗     ██╗     ██╗    ██╗ █████╗ ██╗   ██╗
// ████╗  ██║██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██║    ██║    ██║  ██║██╔══██╗██║     ██║     ██║    ██║██╔══██╗╚██╗ ██╔╝
// ██╔██╗ ██║███████║██████╔╝██████╔╝██║   ██║██║ █╗ ██║    ███████║███████║██║     ██║     ██║ █╗ ██║███████║ ╚████╔╝
// ██║╚██╗██║██╔══██║██╔══██╗██╔══██╗██║   ██║██║███╗██║    ██╔══██║██╔══██║██║     ██║     ██║███╗██║██╔══██║  ╚██╔╝
// ██║ ╚████║██║  ██║██║  ██║██║  ██║╚██████╔╝╚███╔███╔╝    ██║  ██║██║  ██║███████╗███████╗╚███╔███╔╝██║  ██║   ██║
// ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_NarrowHallway( entity player )
{
	FlagWait( "TitanArenaFightStarted" )
}

void function StartPoint_Setup_NarrowHallway( entity player )
{
	TeleportPlayerAndBT( "start_player_NarrowHallway", "start_bt_NarrowHallway" )
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	FlagSet( "HighSpeedPassByMoversGo" )
}

void function StartPoint_Skipped_NarrowHallway( entity player )
{

}

void function HighSpeedDangerousArea()
{
	vector pos = GetEntByScriptName( "bt_badplace_fastmover" ).GetOrigin()
	float radius = 256
	entity lifetimeEnt

	while( true )
	{
		FlagWait( "HighSpeedDangerousArea" )

		// Create the dangerous area
		lifetimeEnt = CreateScriptRef( pos )
		AI_CreateDangerousArea_Static( lifetimeEnt, null, radius, TEAM_INVALID, true, true, pos )

		FlagWaitClear( "HighSpeedDangerousArea" )
		lifetimeEnt.Destroy()
	}
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ████████╗██╗████████╗ █████╗ ███╗   ██╗     █████╗ ██████╗ ███████╗███╗   ██╗ █████╗
// ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║    ██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗
//    ██║   ██║   ██║   ███████║██╔██╗ ██║    ███████║██████╔╝█████╗  ██╔██╗ ██║███████║
//    ██║   ██║   ██║   ██╔══██║██║╚██╗██║    ██╔══██║██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║
//    ██║   ██║   ██║   ██║  ██║██║ ╚████║    ██║  ██║██║  ██║███████╗██║ ╚████║██║  ██║
//    ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_TitanArena( entity player )
{
	entity SavePoint = GetEntByScriptName( "start_player_TitanArena" )
	TriggerSilentCheckPoint( SavePoint.GetOrigin(), false )

	//thread ArenaMovingGeo()
	thread TitanFight_Wave1( player )
	thread TitanFight_Wave2( player )

	StopMusicTrack( "music_boomtown_04_ontoslide" )
	PlayMusic( "music_boomtown_05_enemytitans" )

	FlagWait( "LoadingDock" )
}

void function StartPoint_Setup_TitanArena( entity player )
{
	TeleportPlayerAndBT( "start_player_TitanArena", "start_bt_TitanArena" )
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	FlagSet( "HighSpeedRackIntoTitanArena1" )
	FlagSet( "HighSpeedRackIntoTitanArena2" )
	FlagSet( "HighSpeedRackIntoTitanArena3" )
}

void function StartPoint_Skipped_TitanArena( entity player )
{

}
/*
void function ArenaMovingGeo()
{
	FlagWait( "StartMovingArenaGeo" )

	FlagSet( "ArenaRearrange1" )
	wait 20.0
	FlagSet( "ArenaRearrange2" )
	wait 20.0
	FlagSet( "ArenaRearrange3" )
	wait 20.0
	FlagSet( "ArenaRearrange4" )
	wait 20.0
	FlagSet( "ArenaRearrange5" )
}
*/
void function TitanFight_Wave1( entity player )
{
	// First titan spawns
	printt( "SPAWNING TITAN 1" )
	entity titan1_spawner = GetEntByScriptName( "TitanArenaTitan1" )
	entity titan1 = titan1_spawner.SpawnEntity()
	DispatchSpawn( titan1 )

	float titan2Timer = Time() + 45.0
	while( Time() <= titan2Timer )
	{
		if ( !IsAlive( titan1 ) )
			break
		if ( Flag( "CanSeeSecondTitanSpawner" ) )
			break
		WaitFrame()
	}

	printt( "SPAWNING TITAN 2" )

	entity titan2_spawner = GetEntByScriptName( "TitanArenaTitan2" )
	entity titan2 = titan2_spawner.SpawnEntity()
	DispatchSpawn( titan2 )

	while( IsAlive( titan1 ) || IsAlive( titan2 ) )
		WaitFrame()

	printt( "BOTH TITANS DEAD!" )

	FlagSet( "Wave1TitansDead" )
}

void function TitanFight_Wave2( entity player )
{
	FlagWait( "SpawnBlastDoorTitans" )

	printt( "SPAWNING BLAST GATE ENEMIES" )

	// Spawn blast door enemies
	array<entity> titans
	array<entity> spawners = GetEntArrayByScriptName( "TitanArenaBlastDoorSpawners" )
	foreach( entity spawner in spawners )
	{
		entity guy = spawner.SpawnEntity()
		DispatchSpawn( guy )
		if ( guy.IsTitan() )
			titans.append( guy )
	}
	Assert( titans.len() == 3 )

	// Open the doors
	FlagSet( "BlastDoor1Open" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "blastdoor1sound" ).GetOrigin(), "Boomtown_PropWarehouse_LargeDoorOpen" )
	wait 4.0

	// Connect NPC paths through the door
	array<entity> doorParts = GetEntArrayByScriptName( "BlastDoor1" )
	foreach( entity part in doorParts )
		ToggleNPCPathsForEntity( part, true )

	// Wait until both titans are killed
	while( IsAlive( titans[0] ) || IsAlive( titans[1] ) || IsAlive( titans[2] ) )
		WaitFrame()

	printt( "SECOND WAVE TITANS DEAD" )

	wait 1.0
	StopMusicTrack( "music_boomtown_05_enemytitans" )
	PlayMusic( "music_boomtown_06_enemytitansdefeated" )
	wait 1.0

	// Good work, Pilot. Your skills are greatly improving.
	thread PlayBTDialogue( "BT_GOOD_WORK_PILOT" )

	wait 1.5

	// Open the second blast gate
	FlagSet( "BlastDoor2Open" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "blastdoor2sound" ).GetOrigin(), "Boomtown_PropWarehouse_LargeDoorOpen" )
	array<entity> doorParts2 = GetEntArrayByScriptName( "BlastDoor2" )
	foreach( entity part in doorParts2 )
		ToggleNPCPathsForEntity( part, true )
}




// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗      ██████╗  █████╗ ██████╗ ██╗███╗   ██╗ ██████╗     ██████╗  ██████╗  ██████╗██╗  ██╗
// ██║     ██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝     ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝
// ██║     ██║   ██║███████║██║  ██║██║██╔██╗ ██║██║  ███╗    ██║  ██║██║   ██║██║     █████╔╝
// ██║     ██║   ██║██╔══██║██║  ██║██║██║╚██╗██║██║   ██║    ██║  ██║██║   ██║██║     ██╔═██╗
// ███████╗╚██████╔╝██║  ██║██████╔╝██║██║ ╚████║╚██████╔╝    ██████╔╝╚██████╔╝╚██████╗██║  ██╗
// ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_LoadingDock( entity player )
{
	entity SavePoint = GetEntByScriptName( "start_player_LoadingDock" )
	TriggerSilentCheckPoint( SavePoint.GetOrigin(), false )

	foreach( player in GetPlayerArray() )
	{
		if ( !IsValid( player.GetPetTitan() ) )
			CreatePetTitanAtOrigin( player, SavePoint.GetOrigin(), <0,0,0> )
	}

	PlayMusic( "music_boomtown_07_downthestepagain" )

	// Pilot, scans indicate a control room nearby. This action requires maneuvering in close quarters. I will hold this position.
	waitthread PlayBTDialogue( "BT_CONTROL_ROOM_NEARBY" )

	entity panel = GetEntByScriptName( "ElevatorButton" )

	foreach( player in GetPlayerArray() )
		Objective_Set_WithAltHighlight( "#BOOMTOWN_OBJECTIVE_RAISE_ELEVATOR", <0,0,48>, panel )
	
	foreach( player in GetPlayerArray() )
		thread PlayerConversation( "ControlPanelShortcut", player )

	thread ControlPanelNag( player )

	thread EndingSequence( player )
}

void function StartPoint_Setup_LoadingDock( entity player )
{
	TeleportPlayerAndBT( "start_player_LoadingDock", "start_bt_LoadingDock" )
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	FlagSet( "BlastDoor2Open" )
}

void function StartPoint_Skipped_LoadingDock( entity player )
{

}

void function ControlPanelNag( entity player )
{
	FlagEnd( "LoadingDockButtonPressed" )

	wait 60.0

	// We cannot proceed through this facility without the cargo lift. I am marking your HUD with the location of the controls.
	PlayBTDialogue( "BT_CONTROL_ROOM_NEARBY_NAG" )
	Objective_Remind()
}

void function LiftActivatedPA( entity player )
{
	entity speaker = GetEntByScriptName( "loading_dock_pa" )
	Assert( IsValid( speaker ) )

	wait 1.0

	// Cargo lift activated.
	PlayDialogue( "PA_LIFT_ACTIVATED", speaker )
}

// Fake panel to prime streaming
void function CreateFakeControlPanel()
{
	vector org = <9852.610352, -4135.829102, 7453.116211>

	while( !Flag( "LoadingDockButtonPressed" ) )
	{
		FlagWait( "InControlRoom" )
		FlagClear( "GrabBT" )
		entity panel = CreatePropDynamic( PANEL_MODEL, org, <0,0,0> )
		panel.SetSkin( 2 )
		WaitFrame()
		FlagWait( "GrabBT" )
		FlagClear( "InControlRoom" )
		WaitFrame()
		panel.Destroy()
	}
}

void function EndingSequence( entity player )
{
	EndSignal( player, "OnDeath" )

	entity loudspeaker = GetEntByScriptName( "loading_dock_pa" )
	Assert( IsValid( loudspeaker ) )

	// Close the large blast door when the player enteres the control room
	FlagWait( "InControlRoom" )

	thread CreateFakeControlPanel()

	entity bt = player.GetPetTitan()
	if ( IsValid( bt ) )
		Highlight_ClearOwnedHighlight( bt )
	else
	{
		entity SavePoint = GetEntByScriptName( "start_player_LoadingDock" )
		TriggerSilentCheckPoint( SavePoint.GetOrigin(), false )

		foreach( entity p in GetPlayerArray() )
		{
			if ( !IsValid( p.GetPetTitan() ) )
				CreatePetTitanAtOrigin( p, SavePoint.GetOrigin(), <0,0,0> )
		}
	}

	FlagSet( "BlastDoor2Close" )
	FlagClear( "BlastDoor2Open" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "blastdoor2sound" ).GetOrigin(), "Boomtown_PropWarehouse_LargeDoorClose" )

	// Wait for control room button press
	FlagWait( "LoadingDockButtonPressed" )

	FlagClear( "GrabBT" )
	Objective_Clear()
	Objective_SetSilent( "#BOOMTOWN_OBJECTIVE_RETURN_TO_BT", <0,0,128>, player.GetPetTitan() )

	thread LiftActivatedPA( player )

	// Wait for BT grab sequence to start
	FlagWait( "GrabBT" )
	Objective_Clear()

	// Position BT and arm
	FlagSet( "PickupBT" )

	StopMusicTrack( "music_boomtown_06_enemytitansdefeated" )
	StopMusicTrack( "music_boomtown_07_downthestepagain" )
	PlayMusic( "music_boomtown_08_btsnatched" )

	// Make the elevator work when the player stands on it
	FlagSet( "ElevatorActive" )

	// <ALARM> <ALARM>
	//waitthread PlayDialogue( "PA_ALARM", loudspeaker )

	// Pilot. I require assistance.
	waitthread PlayBTDialogue( "BT_GRABBED_I_NEED_HELP" )

	// Warning. Warning. Unauthorized Titan detected in Loading Dock 13.
	waitthread PlayDialogue( "PA_UNAUTHORIZED_TITAN", loudspeaker )

	// Transferring Titan to Asset Reassignment.
	waitthread PlayDialogue( "PA_TRANSFERING_TITAN", loudspeaker )

	waitthread PlayDialogue( "ASH_SECURITY_BREACH", player )		// Ash to Kappa three. I have located a security breach. Loading Dock 13, over.
	waitthread PlayDialogue( "RADIO_ROGER_EN_ROUTE", player ) 		// Roger. Kappa three en route, out.
	thread PlayBTDialogue( "BT_CANNOT_FREE_MYSELF" )				// Pilot... <static> I cannot free myself.... <static> Cooper....

	// Update objective to use the elevator
	entity panel = GetEntByScriptName( "ElevatorControl" )
	if ( !Flag( "ElevatorMoveDown" ) )
	Objective_Set_WithAltHighlight( "#BOOMTOWN_OBJECTIVE_ACTIVATE_ELEVATOR", <0,0,48>, panel )
}

void function LoadingDockArm1()
{
	FlagWait( "StartLoadingDockCargoArms" )

	entity startNode = GetEntByScriptName( "arm_track_straight_end" )
	entity pickupPoint = GetEntByScriptName( "loading_arm_pos1" )
	entity cargo = GetEntByScriptName( "loading_dock_cargo1" )

	// Create the arm at starting pose
	PlatformArm arm = CreateArm( ARM_MODEL_SMALL, startNode.GetOrigin(), startNode.GetAngles(), true, false )
	SetArmPose( arm, -90, 90, 90, -90, -90, -45, 0, 0.0 )

	// Move to the crate pickup location
	thread MoveArmForDuration( arm, pickupPoint.GetOrigin(), 6.0, 0.0, 1.5 )

	// Wait for second arm to be out of the way
	wait 5.0
	thread SetArmPose( arm, 0, 90, 90, -90, -90, -45, 0, 3.0 )
	EmitSoundOnEntity( arm.mover, "Boomtown_PropWarehouse_RobotArm_RotateFirst" )
	wait 8.0

	// Pose for pre-grab
	EmitSoundOnEntity( arm.mover, "Boomtown_PropWarehouse_RobotArm_CageGrabFirst" )
	thread SetArmPose( arm, -61.5, 0, 41, -41, -56, 42, 0, 2.0 )
	wait 2.0

	// Grab the cargo and link it to the arm
	thread SetArmPose( arm, -62.5, 0, 18, -41, -31, 33, 0, 1.5 )
	wait 1.5
	thread SetArmPose( arm, -62.5, 0, 18, -41, -31, 33, 7, 0.5 )
	wait 0.5
	AttachEntityToArm( arm, cargo, true )
	cargo.SetPusher( true )
	arm.model.SetPusher( true )
	arm.mover.SetPusher( true )

	wait 1.0

	// Carry position
	thread SetArmPose( arm, -180, 0, 0, -90, -90, -90, 7, 4.0 )

	// Move to the end of the track below the elevator
	arm.mover.SetParent( GetEntByScriptName( "LoadingDockArm1LeaveMover" ), "", true )
	FlagSet( "LoadingDockArm1Leave" )

	// Pose after clearing the control room and going down angle
	wait 7.0
	thread SetArmPose( arm, -90, -90, 68, -81, -73, -67, 7, 2.0 )
	EmitSoundOnEntity( arm.mover, "Boomtown_PropWarehouse_RobotArm_LowerRotateFirst" )
}

void function LoadingDockArm2()
{
	FlagWait( "StartLoadingDockCargoArms" )

	entity startNode = GetEntByScriptName( "arm_track_straight_end" )
	entity pickupPoint = GetEntByScriptName( "loading_arm_pos2" )
	entity cargo = GetEntByScriptName( "loading_dock_cargo2" )
	cargo.SetPusher( true )

	// Create the arm at starting pose
	PlatformArm arm = CreateArm( ARM_MODEL_SMALL, startNode.GetOrigin(), startNode.GetAngles(), true, false )
	SetArmPose( arm, -90, 90, 90, -90, -90, -45, 0, 0.0 )

	wait 3.0

	// Move to the crate pickup location
	thread MoveArmForDuration( arm, pickupPoint.GetOrigin(), 6.5, 0.0, 1.5 )
	wait 3.5

	// Pose for pre-grab
	EmitSoundOnEntity( arm.mover, "Boomtown_PropWarehouse_RobotArm_CageGrabSecond" )
	thread SetArmPose( arm, 17, 0, 90, -56, -12, 84, 0, 2.0 )
	wait 2.5

	// Grab the cargo and link it to the arm
	thread SetArmPose( arm, 17, 0, 71, -69, 5, 73, 0, 1.5 )
	wait 1.5
	thread SetArmPose( arm, 17, 0, 71, -69, 5, 73, 7, 0.5 )
	wait 0.5
	AttachEntityToArm( arm, cargo, true )
	cargo.SetPusher( true )
	arm.model.SetPusher( true )
	arm.mover.SetPusher( true )

	// Pick it up off the ground
	thread SetArmPose( arm, -27, 0, 90, -81, -18, 58, 7, 1.2 )
	wait 1.2

	// Carry position
	thread SetArmPose( arm, -180, 0, 0, -90, -90, -90, 7, 7.0 )

	// Move to the end of the track below the elevator
	arm.mover.SetParent( GetEntByScriptName( "LoadingDockArm2LeaveMover" ), "", true )
	FlagSet( "LoadingDockArm2Leave" )

	// Pose after clearing the control room and going down angle
	wait 6.0
	thread SetArmPose( arm, -90, -90, 68, -81, -73, -67, 7, 3.0 )
	EmitSoundOnEntity( arm.mover, "Boomtown_PropWarehouse_RobotArm_LowerRotateSecond" )
}

void function BTGetsGrabbed()
{
	// Create the arm and pose it in the corner until needed
	entity startNode = GetEntByScriptName( "bt_grab_arm_start" )
	PlatformArm arm = CreateArm( ARM_MODEL_SMALL, startNode.GetOrigin(), startNode.GetAngles(), true, false )
	SetArmPose( arm, -20, 0, 90, -65, 0, 90, 8.0, 0.0 )

	FlagWait( "PickupBT" )

	entity armNode = GetEntByScriptName( "bt_pickup_arm_pos" )
	arm.mover.SetOrigin( armNode.GetOrigin() )
	arm.mover.SetAngles( < 0, -19, 0 > )

	entity player = GetClosest( GetPlayerArray(), armNode.GetOrigin() )
	if ( !IsValid( player.GetPetTitan() ) )
		CreatePetTitanAtOrigin( player, player.GetOrigin() + <0,0,1000>, player.GetAngles() )
	entity bt = player.GetPetTitan()

	thread BTGetsGrabbedAnims( bt, arm )

	wait 10.0

	// Tell the arm to take BT away
	arm.mover.NonPhysicsRotateTo( < 0, 90, 0 >, 2.0, 1.0, 1.0 )
	wait 2.0

	// Parent arm to mover that takes it away
	arm.mover.SetParent( GetEntByScriptName( "BTArmLeaveMover" ), "", true )
	FlagSet( "BTArmLeave" )

	wait 50.0
	bt.Destroy()
}

void function BTGetsGrabbedAnims( entity bt, PlatformArm arm )
{
	if ( !IsValid( bt ) )
		bt = CreatePetTitanAtOrigin( GetPlayer0(), GetPlayer0().GetOrigin(), GetPlayer0().GetAngles() )

	TakeAllWeapons( bt )
	bt.GiveWeapon( "mp_titanweapon_xo16_shorty", [] )

	SetArmPose( arm, 0, 0, 0, 0, 0, 90, 0, 0.0 )

	arm.model.Anim_Play( "arm_boomtown_bt_grabbed_intro" )
	bt.SetParent( arm.model, "ref", false )
	waitthread PlayAnimTeleport( bt, "bt_boomtown_body_grabbed_intro", arm.model, "ref" )

	arm.model.Anim_Play( "arm_boomtown_bt_grabbed" )
	thread PlayAnim( bt, "bt_boomtown_body_grabbed", arm.model, "ref" )
}

void function ElevatorThink()
{
	entity bottomNode = GetEntByScriptName( "elevator_bottom" )
	entity topNode = GetEntByScriptName( "elevator_top" )
	entity mover = GetEntByScriptName( "elevator_mover" )

	// Elevator starts in the middle
	mover.SetOrigin( ( topNode.GetOrigin() + bottomNode.GetOrigin() ) / 2.0 )

	// Wait for elevator to be called up
	FlagWait( "LoadingDockButtonPressed" )

	// Move elevator up
	mover.NonPhysicsMoveTo( topNode.GetOrigin(), 9.5, 2.0, 2.0 )
	EmitSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorMoveUp" )
	wait 7.5
	EmitSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorStop" )
	wait 2.0
	StopSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorMoveUp" )

	// Wait for player to stand on elevator
	FlagWait( "ElevatorMoveDown" )
	Objective_Clear()
	Objective_Set( "#BOOMTOWN_OBJECTIVE_FOLLOW_BT" )
	thread NextLevel()

	float rumbleAmplitude = 100.0
	float rumbleFrequency = 150
	float rumbleDuration = 25.0
	entity rumbleHandle = CreateShakeRumbleOnly( mover.GetOrigin(), rumbleAmplitude, rumbleFrequency, rumbleDuration )
	rumbleHandle.SetParent( mover, "", false )

	// Move elevator down
	mover.NonPhysicsMoveTo( bottomNode.GetOrigin(), 20.0, 4.0, 2.0 )
	EmitSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorMoveDown" )
	wait 18.0
	EmitSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorStop" )
	wait 2.0
	StopSoundOnEntity( mover, "Boomtown_PropWarehouse_ElevatorMoveDown" )
}

void function NextLevel()
{
	wait 5.0
	Coop_LoadMapFromStartPoint( "sp_boomtown", "Start" )
	// GameRules_ChangeMap( "sp_boomtown", GAMETYPE )
}






