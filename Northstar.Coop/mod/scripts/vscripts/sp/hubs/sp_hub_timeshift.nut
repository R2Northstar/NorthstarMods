untyped

global function CodeCallback_MapInit
global function TimeshiftDebug
global function TransitionSpoke2

const FX_GREEN_BLINKIE = $"runway_light_green"
const FX_RED_BLINKIE = $"runway_light_red"
const FLYER_TIMESHIFT_HEALTH = 500
const PANEL_MODEL = $"models/communication/terminal_usable_imc_01.mdl"
const DUMMY_MODEL = $"models/Robots/stalker/robot_stalker.mdl"
//const IMC_CORPSE_MODEL_LMG = $"models/Humans/grunts/imc_grunt_lmg_corpse.mdl"
const IMC_CORPSE_MODEL_RIFLE = $"models/Humans/grunts/imc_grunt_rifle_corpse.mdl"
//const IMC_CORPSE_MODEL_SHOTGUN = $"models/Humans/grunts/imc_grunt_shotgun_corpse.mdl"
//const IMC_CORPSE_MODEL_SMG = $"models/Humans/grunts/imc_grunt_smg_corpse.mdl"
const LAMPPOST_MODEL = $"models/lamps/parking_post_off_animated.mdl"
//const HELMET_MODEL = $"models/Humans/heroes/mlt_hero_anderson_helmet.mdl"
const HELMET_MODEL = $"models/Humans/heroes/mlt_hero_anderson_helmet.mdl"
const ANDERSON_HOLOGRAM_MODEL = $"models/humans/heroes/mlt_hero_anderson.mdl"
const ANDERSON_MODEL = $"models/humans/heroes/mlt_hero_anderson.mdl"
const SARAH_HOLOGRAM_MODEL = $"models/humans/heroes/mlt_hero_sarah.mdl"
const ENEMY_HOLOGRAM_MODEL = $"models/humans/heroes/mlt_hero_jack.mdl"
const FX_DLIGHT_HELMET 	= $"interior_Dlight_blue_MED"
const DEVICE_HOLO_MODEL = $"models/props/jack_gauntlet_ts/jack_gauntlet_ts_static.mdl"

const SOUND_HELMET_SPARK = "Timeshift_Emit_Sparks"
const SOUND_RING_EXPLOSION_01 = "Explo_Satchel_Impact_1P"
const SOUND_RING_EXPLOSION_02 = "Default.Rocket_Explosion_1P_vs_3P"
const SOUND_RING_EXPLOSION_03 = "Explo_Archer_Impact_1P"
const SOUND_CORE_RUMBLE_CLOSE = "Boomtown_Explosion_Rumble_Close"
const SOUND_CORE_RUMBLE_DISTANT = "Boomtown_Explosion_Rumble_Dist"

const FX_ANDERSON_DEVICE_FX = $"P_timeshift_gauntlet_hld"
const FX_HOLOGRAM_FLASH_EFFECT = $"P_ar_holopilot_flash"
const FX_HOLOGRAM_HEX_EFFECT = $"P_ar_holopilot_hextrail"
const FX_ARK_PULSE = $"P_ts_core_hld_sm_lock"
const FX_FLYER_INTRO_GLASS_EXPLODE = $"P_env_glass_ceiling_exp"
const FX_FLYER_INTRO_GLASS_RAIN = $"fx_ts_flyer_glass"
const FX_LECTURE_HOLOGRAM = $"P_ts_holo_rings"
const FX_HELMET_SPARK = $"P_env_sparks_dir_1"
const FX_EXPLOSION_RINGS_01 = $"P_impact_exp_XLG_concrete"
const FX_EXPLOSION_RINGS_02 = $"P_exp_building_med"
const FX_RING_STEAM = $"P_ts_ring_amb_steam"
const FX_EXPLOSION_01 	= $"P_exp_birm_Impact_LG_1"
const FX_EXPLOSION_02 	= $"P_exp_birm_death"

const TIMEZONE_DAY = 0
const TIMEZONE_NIGHT = 1
const TIMEZONE_ALL = 2
const TIMEZONE_FROZEN = 3

const TIME_ZOFFSET_OVERGROWN_FROM_EXPLOSION = 10624

struct
{
	int numberSecurityZombiesFollowing = 0
	entity bt
	vector btObjectiveOffset = Vector( 0, 0, 72 )
	entity lamppost
	table <entity> ziplineEnts
	array <entity> hallwayTalkers
	entity marvinLobbyOvergrown
	bool timeshiftKilledLobbyMarvin

} file

/////////////////////////////////////////////////////////////////////////////////////////
//
//
//			TIMESHIFT HUB - MAP INIT
//
//
/////////////////////////////////////////////////////////////////////////////////////////
void function CodeCallback_MapInit()
{

	ShSpTimeshiftHubCommonInit()
	RegisterSignal( "AnimTimeshift" )
	RegisterSignal( "javelin_start_throw" )
	RegisterSignal( "FlyingAway" )
	RegisterSignal( "FlyerDying" )
	RegisterSignal( "crush_helmet" )
	RegisterSignal( "ShowHoloTimeshiftDevice" )
	RegisterSignal( "HideHoloTimeshiftDevice" )

	PrecacheParticleSystem( FX_HOLOGRAM_FLASH_EFFECT )
	PrecacheParticleSystem( FX_FLYER_INTRO_GLASS_EXPLODE )
	PrecacheParticleSystem( FX_LECTURE_HOLOGRAM )
	PrecacheParticleSystem( FX_HELMET_SPARK )
	PrecacheParticleSystem( FX_EXPLOSION_RINGS_01 )
	PrecacheParticleSystem( FX_EXPLOSION_RINGS_02 )
	PrecacheParticleSystem( FX_DLIGHT_HELMET )
	PrecacheParticleSystem( FX_RING_STEAM )
	PrecacheParticleSystem( FX_EXPLOSION_01 )
	PrecacheParticleSystem( FX_EXPLOSION_02 )
	PrecacheParticleSystem( FX_ARK_PULSE )
	PrecacheParticleSystem( FX_HOLOGRAM_HEX_EFFECT )
	PrecacheParticleSystem( FX_GREEN_BLINKIE )
	PrecacheParticleSystem( FX_RED_BLINKIE )
	PrecacheParticleSystem( FX_ANDERSON_DEVICE_FX )




	PrecacheModel( LAMPPOST_MODEL )
	PrecacheModel( DUMMY_MODEL )
	PrecacheModel( HELMET_MODEL )
	//PrecacheModel( IMC_CORPSE_MODEL_LMG )
	PrecacheModel( IMC_CORPSE_MODEL_RIFLE )
	//PrecacheModel( IMC_CORPSE_MODEL_SHOTGUN )
	//PrecacheModel( IMC_CORPSE_MODEL_SMG )
	PrecacheModel( ANDERSON_MODEL )
	PrecacheModel( ANDERSON_HOLOGRAM_MODEL )
	PrecacheModel( SARAH_HOLOGRAM_MODEL )
	PrecacheModel( ENEMY_HOLOGRAM_MODEL )
	PrecacheModel( DEVICE_HOLO_MODEL )
	PrecacheModel( PANEL_MODEL )
	AddCallback_OnPilotBecomesTitan( OnPilotBecomesTitan )
	AddCallback_OnTitanBecomesPilot( OnTitanBecomesPilot )
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddPlayerDidLoad( TimeShiftHub_PlayerDidLoad )
	AddSpawnCallback( "npc_soldier", OnSpawnedLevelNPC )
	AddSpawnCallback( "npc_marvin", OnSpawnedLevelNPC )
	AddSpawnCallback( "npc_prowler", OnSpawnedLevelNPC )
	AddSpawnCallback( "npc_spectre", OnSpawnedLevelNPC )
	AddSpawnCallback( "npc_dropship", OnSpawnedLevelNPC )
	AddSpawnCallback( "npc_dropship", OnSpawnedLevelDropship )
	AddSpawnCallback( "prop_dynamic", OnSpawnedPropDynamic )
	AddSpawnCallback( "prop_control_panel", OnSpawnedPanel )

	AddCallback_OnPlayerInventoryChanged( OnPlayerInventoryChangedTimeshift )
	SPTimeshiftUtilityInit()

	//------------------
	// Flags
	//------------------
	FlagInit( "SecurityServicesStalkersSpawning" )
	FlagInit( "LectureHallSceneOver" )
	FlagInit( "player_near_whiteboard_dudes")
	FlagInit( "player_ripped_off_device" )
	FlagInit( "AutoSecurityDialogueDone" )
	FlagInit( "PlayerCloseEnoughToJavelinSequence" )
	FlagInit( "CorpseFlyerTakingDamage" )
	FlagInit( "AllLobbyReduxPristineStalkersSpawned" )
	FlagInit( "AllLobbyReduxZombiesSpawned" )
	FlagInit( "AllLobbyReduxProwlersSpawned" )
	FlagInit( "BT_is_in_frozen_world" )
	FlagInit( "StartCoreScannedMusic" )
	FlagInit( "FirstCampusConversationOver" )
	FlagInit( "PlayerEmbarkedTimeshift" )
	FlagInit( "FirstCampusConversationSkipped" )
	FlagInit( "BTthrowsJavelin" )
	FlagInit( "PlayerLookingAtJavelinThrowIdle" )
	FlagInit( "OverloadDialoguePlaying" )
	FlagInit( "ZiplineObjectiveGiven" )
	FlagInit( "PlaySparksOnHelmet")
	FlagInit( "PlayerInSecondIntroLabTimeshift")
	FlagInit( "StartReactorMeltdown" )
	FlagInit( "HelmetConversationDone" )
	FlagInit( "HelmetConversationSkipped" )
	FlagInit( "GiveHelmetToBTObjectiveGiven" )
	FlagInit( "StartHelmetNags" )
	FlagInit( "HelmetNagInProgress" )
	FlagInit( "KilledFirstLobbySoldier" )
	FlagInit( "KilledSecondLobbySoldier" )
	FlagInit( "CoreScanStarting" )
	FlagInit( "BridgeExtendObjectiveGiven" )
	FlagInit( "FadingToFrozenWorld" )
	FlagInit( "SwappedToFrozenWorld" )
	FlagInit( "SecurityTimeshiftPopToPast1" )
	FlagInit( "SecurityTimeshiftPopToPast2" )
	FlagInit( "HelmetRecoveryDroppedToFloor" )
	FlagInit( "PoppedIntoVistaHallwayTimewarp" )
	FlagInit( "FirstIntroLabTimeshiftRampup" )
	FlagInit( "StartLevelMusic" )
	FlagInit( "IntroCampusConversationsOver" )
	FlagInit( "TimeshiftedToLectrureHall" )
	FlagInit( "IntroLabTimeshiftsStart" )
	FlagInit( "FullWhiteOut" )
	FlagInit( "EndingDialogeFinished" )
	FlagInit( "PlayerAtLevelEnd" )
	FlagInit( "GoingBackToTheFuture" )
	FlagInit( "RingsShouldBeSpinning" )
	FlagInit( "CoreScanned" )
	FlagInit( "ReactorScanObjectiveGiven" )
	FlagInit( "play_core_effect_pristine" )
	FlagInit( "retract_bridge_reactor" )
	FlagInit( "PlayerHasTimeTraveledInsideBT" )
	FlagInit( "SomeLobbyDudesAreDead" )
	FlagInit( "PostHologramDialoguePartyOver" )
	FlagInit( "PlayerStartedHelmetRecovery" )
	FlagInit( "PlayerSwappingToCampusVistaPast" )
	FlagInit( "HallwayCivilianTimeSwapOver" )
	FlagInit( "PlayerSwappingToHallwayVistaPast")
	FlagInit( "BTstartingJavelinSequence" )
	FlagInit( "player_near_bt_intro_and_one_line_played" )
	FlagInit( "HidePlayerWeaponsDuringShifts")
	FlagInit( "IntroLabTimeshiftsOver" )
	FlagInit( "VistaTimeshiftsFinished" )
	FlagInit( "WeaponConversationOver" )
	FlagInit( "BTStartsHologram" )
	FlagInit( "DialogueHologramSequenceFinished" )
	FlagInit( "playerFailsafesProwlersAttackBT" )
	FlagInit( "BTpointedAtLobby" )
	FlagInit( "retract_bridge_control_panel_pressed" )
	FlagInit( "door_open_amenities_lobby_return_pristine" )
	FlagInit( "finishedHumanVistaSequence" )
	FlagInit( "spawnHumanBridgeEnemies" )
	FlagInit( "player_looking_at_reactor_window" )
	FlagInit( "open_door_lobby_main_overgrown" )
	FlagInit( "HologramSequenceOver" )
	FlagInit( "PlayerGivesHelmet" )
	FlagInit( "FlyerIntroSequenceStarted")
	FlagInit( "RecoveredHelmet" )
	FlagInit( "SecurityZombieVentsSpawn" )
	FlagInit( "ProwlerFlyerSequenceCanStart" )
	FlagInit( "PlayerLookingTowardsElevators" )
	FlagInit( "SpawnHubWeapons" )
	FlagInit( "SecurityStalkerRackSequenceFinished" )
	FlagInit( "SecuritySpectresWakeUp" )
	FlagInit( "HideHubWeapons" )
	FlagInit( "ConcoursePanelHacked01" )
	FlagInit( "ConcoursePanelHacked02" )
	FlagInit( "PlayerPickedUpTimeshiftDevice" )
	FlagInit( "FirstSpectreDeployedLobbyReduxPristine" )

	//------------------
	// Start points
	//------------------
					//startPoint, 					mainFunc,							setupFunc							skipFunc
	AddStartPoint( "LECTURE HALLS", 				AA_IntroSectionThread, 				null, 								IntroSectionSkipped )
	AddStartPoint( "OVERGROWN CAMPUS", 				AA_EnterCampusThread,				EnterCampusStartPointSetup, 		EnterCampusSkipped )
	AddStartPoint( "Corpse Search", 				AA_CorpseSearchThread,				CorpseSearchStartPointSetup, 		CorpseSearchSkipped )
	AddStartPoint( "BT EXPLAINS IT ALL", 			AA_HologramThread,					HologramStartPointSetup, 			HologramSkipped )
	AddStartPoint( "Zipline", 						AA_ZiplineThread,					ZiplineStartPointSetup, 			ZiplineSkipped )
	AddStartPoint( "Security", 						AA_SecurityThread,					SecurityStartPointSetup, 			SecuritySkipped )
	AddStartPoint( "Skybridge", 					AA_SkybridgeThread,					SkybridgeStartPointSetup, 			SkybridgeSkipped )
	AddStartPoint( "PRISTINE CAMPUS", 				AA_LobbyReduxThread,				LobbyReduxStartPointSetup, 			LobbyReduxSkipped )
	AddStartPoint( "Hub Fight", 					AA_HubFightThread,					HubFightStartPointSetup, 			HubFightSkipped )
	AddStartPoint( "Extended Bridge", 				AA_ExtendedBridgeThread,			ExtendedBridgeStartPointSetup, 		ExtendedBridgeSkipped )
	AddStartPoint( "REACTOR MELTDOWN", 				AA_ReactorBridgeThread,				ReactorBridgeStartPointSetup, 		ReactorBridgeSkipped )
	AddStartPoint( "Core Scan", 					AA_CoreScanThread,					CoreScanStartPointSetup, 			CoreScanSkipped )
	AddStartPoint( "Level End", 					AA_LevelEndThread,					LevelEndStartPointSetup, 			LevelEndSkipped )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftDebug()
{

}
/////////////////////////////////////////////////////////////////////////////////////////
void function EntitiesDidLoad()
{
	delaythread ( 2 ) LaserMeshDeactivateByInstanceName( "lasermesh_bunker_armory_lockdown" )

	RemoveBlocker( "security_window_blockers_overgrown" )

	HideStuff( "core_dummy" )
	HideStuff( "core_model_pristine" )
	HideStuff( "core_glow_model_pristine" )
	HideStuff( "hallway_glass_broken" )
	HideStuff( "blocker_fan_start" )
	HideStuff( "blockers_startlab_backtrack" )
	HideStuff( "blockers_lecture_backtrack" )
	HideStuff( "blocker_fan_intro" )
	HideStuff( "marvin_lobby_dead" )
	//HideStuff( "flyer_intro_hallway_fly_a" )
	//HideStuff( "flyer_intro_hallway_fly_b" )
	HideStuff( "blocker_overgrown_start_vista" ) // TODO: Is the right thing to remove?

	thread SkyboxStart()
	delaythread ( 3 ) WeaponDrops()


	CleanupEnts( "prowlers_bridge_control_room" )

	//thread TitanRackSpawnersThink( "titans_racks_bridge_room_02" )
	thread TitanRackSpawnersThink( "titans_racks_bridge_room_03" )

	FlagSet( "retract_bridge_reactor" )

	thread RingsThink()

	AndersonSetupLobby()
	AndersonSetupSkybridge()
	FlagSet( "PlaySparksOnHelmet")

	entity core_dummy = GetEntByScriptName( "core_dummy" )
	core_dummy.SetOrigin( Vector( -1162.75, 6054.51, -10548 ) )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function TimeShiftHub_PlayerDidLoad( entity player )
{
	// runs once right?

	/*
	This will run before any start points run.
	Useful for doing common	player-specific setup,
	saving you from having to put a common player
	setup function in each of your start points
	*/

	//---------------------
	// Timeshift thread
	//----------------------
	thread TimeshiftPlayerThink( player ) // TODO: MAKE THIS FOR EVERYONE 

	//---------------------
	// Setup BT
	//----------------------
	file.bt = player.GetPetTitan()
	Assert( IsValid( file.bt) )
	Objective_InitEntity( file.bt )
	thread PetTitanThink( player )
	if ( !Flag( "PlayerPickedUpTimeshiftDevice") )
		Embark_Disallow( player )

	//---------------------
	// Weapons
	//----------------------
	//if ( !Flag( "HologramSequenceOver") )
		//player.TakeOffhandWeapon( 0 ) //no satchels till after lobby

	SetPlayer0( player ) // :)
}


/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗     ███████╗██╗   ██╗███████╗██╗             ███████╗████████╗ █████╗ ██████╗ ████████╗
██║     ██╔════╝██║   ██║██╔════╝██║             ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
██║     █████╗  ██║   ██║█████╗  ██║             ███████╗   ██║   ███████║██████╔╝   ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║             ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗        ███████║   ██║   ██║  ██║██║  ██║   ██║
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝        ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗     ███████╗██╗   ██╗███████╗██╗             ███████╗████████╗ █████╗ ██████╗ ████████╗
██║     ██╔════╝██║   ██║██╔════╝██║             ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
██║     █████╗  ██║   ██║█████╗  ██║             ███████╗   ██║   ███████║██████╔╝   ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║             ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗        ███████║   ██║   ██║  ██║██║  ██║   ██║
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝        ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗     ███████╗██╗   ██╗███████╗██╗             ███████╗████████╗ █████╗ ██████╗ ████████╗
██║     ██╔════╝██║   ██║██╔════╝██║             ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
██║     █████╗  ██║   ██║█████╗  ██║             ███████╗   ██║   ███████║██████╔╝   ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║             ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗        ███████║   ██║   ██║  ██║██║  ██║   ██║
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝        ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗     ███████╗██╗   ██╗███████╗██╗             ███████╗████████╗ █████╗ ██████╗ ████████╗
██║     ██╔════╝██║   ██║██╔════╝██║             ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
██║     █████╗  ██║   ██║█████╗  ██║             ███████╗   ██║   ███████║██████╔╝   ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║             ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗        ███████║   ██║   ██║  ██║██║  ██║   ██║
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝        ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function IntroSectionSkipped( entity player )
{
	//FlagSet( "flagSetSpectrePanelIntroOpen" )
	//FlagSet( "flagSetDoorBunkerPanelOpen")
	//FlagSet( "door_security_services_front_open" )
	//FlagSet( "door_security_services_side_open" )
	FlagSet( "HidePlayerWeaponsDuringShifts" )
	FlagSet( "HideHubWeapons" )
	IntroSectionCleanup( player )
	thread BTIntroThink( player )
	thread ZiplineLamppostSetup()
	Rodeo_Disallow( player )
	thread StopRingSounds( player )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function IntroSectionCleanup( entity player )
{
	CleanupEnts( "civilian_lectern" )
	CleanupEnts( "civilian_audience" )
	CleanupEnts( "civilian_audience_walkers" )
	CleanupEnts( "whiteboard_dudes" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_IntroSectionThread( entity player )
{
	// AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD  )
	// Remote_CallFunction_Replay( player, "ServerCallback_LevelInfoText" )
	StartLevelStartText()
	// this is a test so if it doesn't work out remove it plz
	// ! this is a thread and if player0 leaves we get oh no

	Rodeo_Disallow( player )
	thread MusicIntro( player )
	thread ZiplineLamppostSetup()
	SetGlobalForcedDialogueOnly( true )
	thread StopRingSounds( player )
	player.DisableWeapon()
	player.ForceStand()

	TeleportPlayers( GetEntByScriptName( "checkpointStart" ) )

	ShowIntroScreen( player )
	FlagWait( "IntroScreenFading" )
	FlagSet( "StartLevelMusic" )
	FlagWait( "IntroScreenBGFading" )
	WaitFrame()
	player.FreezeControlsOnServer()

	FlagSet( "HideHubWeapons" )
	FlagSet( "HidePlayerWeaponsDuringShifts" )



	SetGlobalNetBool( "squadConversationEnabled", false )

	thread BTIntroThink( player )

	delaythread ( 5 ) DialogueIntro( player )
	
	TeleportPlayers( GetEntByScriptName( "checkpointStartDrop" ) )
	foreach( entity p in GetPlayerArray() )
	{
		p.SetOrigin( p.GetOrigin() + Vector( 0, 0, 1024 ) )
	}

	entity node = GetEntByScriptName( "nodeVentfallStart" )
	
	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			thread PlayerDropLand( p, node )
	}

	waitthread PlayerDropLand( player, node )

	TriggerSilentCheckPoint( GetEntByScriptName( "checkpointStartDrop" ).GetOrigin() - <0,0,100>, true )

	ShowStuff( "blocker_fan_intro" )
	
	foreach( entity p in GetPlayerArray() )
		RemoveCinematicFlag( p, CE_FLAG_HIDE_MAIN_HUD )
	EndEvent()

	//-----------------------------------------
	// Erratic time swaps in lab
	//-----------------------------------------

	entity whiteboardNode = GetEntByScriptName( "node_whiteboard" )
	vector whiteboardNodeOrigin =  whiteboardNode.GetOrigin()
	entity whiteboardNode2 = CreateLoudspeakerEnt( whiteboardNodeOrigin )
	vector whiteboardNode2Origin =  whiteboardNode2.GetOrigin()
									//skitNode										failsafeFlagToStart
	thread QuickSkit( player, GetEntByScriptName( "node_whiteboard" ), 	"player_entering_lecture_hall" )
	thread DialogueLabChatter( player )

	// we need this because triggers trigger on all players and since this part is too scripted we can't afford to crash 
	// thread SetFlagWhenPlayerWithinRangeOfEnt( player, whiteboardNode, 500, "player_entering_creature_labs" )
	// or not, seams to do some weird stuff

	FlagWait( "player_entering_creature_labs" )
	
	TriggerSilentCheckPoint( whiteboardNodeOrigin, true )

	// ShowStuff( "blocker_fan_start" ) // nah

	FlagSet( "FirstIntroLabTimeshiftRampup" )
	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	FlagSet( "IntroLabTimeshiftsStart" )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//PA - ...requests all teams working on World Sculptor artifact analysis
	//report to the lecture hall for General Marder's presentation. Thank you
	delaythread ( 1 ) PlayTimeShiftDialogue( player, soundEnt, "diag_sp_artifact_TS111_01_01_imc_scientist1" )

	wait 6.2

	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )

	FlagWait( "player_creature_labs_mid" )

	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	FlagSet( "PlayerInSecondIntroLabTimeshift")

	TriggerSilentCheckPoint( whiteboardNode2Origin, true )

	thread SetFlagWhenPlayerWithinRangeOfEnt( player, whiteboardNode2, 200, "player_near_whiteboard_dudes" )

	FlagWaitWithTimeout( "player_exiting_creature_labs", 5 )

	FlagWaitWithTimeout( "player_near_whiteboard_dudes", 2 )


	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )

	FlagSet( "IntroLabTimeshiftsOver" )

	soundEnt.Destroy()
	CleanupEnts( "whiteboard_dudes" )

	FlagWait( "player_exiting_creature_labs" )

	//-----------------------------------------
	// OBJECTIVE: "Get to the abandoned research campus"
	//-----------------------------------------
	vector objectivePos = GetEntByScriptName( "objective_campus_vista_breadcrumb00" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_START", objectivePos )

	// TriggerSilentCheckPoint( objectivePos, true )

	//-----------------------------------------
	// Entering lecture hall
	//-----------------------------------------

	thread SequenceLectureHall( player )

	CleanupEnts( "civilian_audience_walkers" )

	FlagWait( "player_entering_lecture_hall" )

	ShowStuff( "blockers_startlab_backtrack" )

	delaythread ( 1.8 ) LectureHallFx( player )

	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	FlagSet( "TimeshiftedToLectrureHall" )

	HideStuff( "seat_blocker_overgrown_lecturehall" ) //get rid of clip brush in overgrown so player can explore between seats

	FlagWaitWithTimeout( "player_approaching_stage", 6 )

	if ( Flag( "player_approaching_stage") )
		wait 1

	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )

	FlagSet( "LectureHallSceneOver" )
	wait 0.1
	CleanupEnts( "civilian_audience" )
	CleanupEnts( "civilian_lectern" )


	thread ObjectiveRemindUntilFlag( "player_exiting_lecture_hall" )

	FlagWait( "player_exiting_lecture_hall" )

	// ShowStuff( "blockers_lecture_backtrack" ) // right thing?

	objectivePos = GetEntByScriptName( "objective_campus_vista_breadcrumb1" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	// TriggerSilentCheckPoint( objectivePos, true )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicIntro( entity player )
{
	FlagWait( "StartLevelMusic" )

	StopMusic()
	PlayMusic( "music_timeshift_01_intro" )

	FlagWait( "player_approaching_intro_labs" )

	StopMusic()
	PlayMusic( "music_timeshift_02_buildup" )

	FlagWait( "FirstIntroLabTimeshiftRampup" )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_03_flashback01" )


}
/////////////////////////////////////////////////////////////////////////////////////////
void function LectureHallFx( entity player )
{

	entity hologram_org = GetEntByScriptName( "hologram_org" )
	entity fx = PlayFX( FX_LECTURE_HOLOGRAM, hologram_org.GetOrigin(), hologram_org.GetAngles() )

	/*
	FlagWait( "player_exiting_lecture_hall" )

	if ( IsValid( fx ) )
		StopFX( fx )
	*/
}

/////////////////////////////////////////////////////////////////////////////////////////
void function BTIntroThink( entity player )
{
	//entity bt = player.GetPetTitan()
	entity node = GetEntByScriptName( "node_bt_crashsite" )
	thread PlayAnimTeleport( file.bt, "bt_beacon_approach_b_loop", node )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueIntro( entity player )
{
	player.EndSignal( "OnDeath" )

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	//BT		Pilot, I recommend we split up, in order to locate Major Anderson more quickly. I can scout ahead to the main facility.
	waitthread PlayBTDialogue( "diag_sp_vents_TS101_01_01_mcor_bt" )

	if ( !Flag( "player_entering_creature_labs") )
	{
		waitthread PlayerConversationStopOnFlagImmediate( "TsSplitUp", player, "IntroLabTimeshiftsStart" )

		//Player	Option A	Don't get captured again, BT
		//BT	Option A	I will avoid all shortcuts.

		//Player	Option B	It's too quiet...we could be walking into an ambush...	diag_sp_vents_TS101_04_01_mcor_player
		//BT	Option B	Agreed. However - close-quarters recon is the sole domain of the Pilot.	diag_sp_vents_TS101_05_01_mcor_bt

		//Player	Option B - Suboption 1	I'll keep my eyes peeled.	diag_sp_vents_TS101_06a_01_mcor_player
		//BT	Option B - Suboption 1	Proceed with caution.	diag_sp_vents_TS101_07a_01_mcor_bt

		//Player	Option B - Suboption 2	That's true. I make less noise than you do.	diag_sp_vents_TS101_08a_01_mcor_player
		//BT	Option B - Suboption 2	Agreed. Titans were not built for stealth.	diag_sp_vents_TS101_09a_01_mcor_bt
	}


	FlagWait( "IntroLabTimeshiftsOver" )

	//Player	Option A	What just happened?	diag_sp_artifact_TS111_02_01_mcor_player
	//BT	Option A	These temporal distortions appear to be causing a rift in time. I advise caution until we have further information.	diag_sp_artifact_TS111_03a_01_mcor_bt

	//Player	Option B	I got a bad feeling about this...	diag_sp_artifact_TS111_05_01_mcor_player
	//BT	Option B	The temporal distrubances in the area are a plausible cause of your ailment. Medical Routine J-12 suggests slow and deep breaths.	diag_sp_artifact_TS111_06_01_mcor_bt
	//Player	Option B - Auto	(*takes slow/deep breaths*)... Nope.	diag_sp_artifact_TS111_07a_01_mcor_player


	//Player	Option A - Suboption 1	All right - wish me luck...	diag_sp_artifact_TS111_04_01_mcor_player
	//BT	Option A - Suboption 1	I wish you luck.	diag_sp_artifact_TS111_04a_01_mcor_bt

	//Player	Option A - Suboption 2	A rift in time? How does that happen?	diag_sp_artifact_TS111_04b_01_mcor_player
	//BT	Option A - Suboption 2	There have been multple cases of temporal distortions documented by the IMC. A common element among them appears to be a massive energy surge. Be careful, Pilot.	diag_sp_artifact_TS111_04c_01_mcor_bt

	wait 1

	waitthread PlayerConversationStopOnFlagImmediate( "TsWtf", player, "TimeshiftedToLectrureHall" )




}
/////////////////////////////////////////////////////////////////////////////////////////

void function DialogueLabChatter( entity player )
{
	FlagWait( "PlayerInSecondIntroLabTimeshift" )

	entity soundEnt = CreateLoudspeakerEnt( Vector( -132, -8696, 12400 ) )

	//Scientist 2	 (very faint, almost background noise) ...found problems maintaining stability. I don't think we're ready for testing...
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_vistaHall_TS141_02_01_imc_scientist2" )

	//Scientist 3	(very faint, almost background noise) You're forgetting he's got Hammond in his corner, so if he says we go...we go.
	thread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_vistaHall_TS141_03_01_imc_scientist3" )

	FlagWait( "player_entering_lecture_hall" )

	soundEnt.Destroy()
}

/////////////////////////////////////////////////////////////////////////////////////////
void function SequenceLectureHall( entity player )
{
	thread CivilianSpeakerThink( player )
	array <entity> students = GetEntArrayByScriptName( "civilian_audience" )
	foreach( student in students )
		thread CivilianStudentThink( student )

	//FlagWait( "player_approaching_stage" )
	FlagWait( "player_in_audience" )

	entity soundent_audience = GetEntByScriptName( "soundent_audience" )

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/
	//Audience	<muffled crescendoing murmurs as player approaches stage.>
	EmitSoundAtPosition( TEAM_UNASSIGNED, soundent_audience.GetOrigin(), "diag_sp_lecture_TS121_02_01_imc_lectureWalla" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function CivilianSpeakerThink( entity player )
{
	entity civilianSpeaker = GetEntByScriptName( "civilian_lectern" )
	entity animModelLectern = civilianSpeaker.GetLinkEnt()
	vector origin = animModelLectern.GetOrigin()
	vector angles = animModelLectern.GetAngles()
	thread PlayAnimTeleport( civilianSpeaker, "pt_lecture_teacher_start", origin, angles )

	FlagWait( "player_entering_lecture_hall" )

	thread PlayAnim( civilianSpeaker, "pt_lecture_teacher", origin, angles )
	thread DialogueCivilianSpeaker( civilianSpeaker, player )


	FlagWait( "player_approaching_stage" )

	thread PlayAnim( civilianSpeaker, "pt_lecture_teacher_react", origin, angles )

}

void function DialogueCivilianSpeaker( entity civilianSpeaker, entity player )
{
	FlagEnd( "player_approaching_stage" )
	FlagEnd( "LectureHallSceneOver" )


	entity soundent_lecture_speaker = GetEntByScriptName( "soundent_lecture_speaker" )
	entity soundEnt = CreateLoudspeakerEnt( soundent_lecture_speaker.GetOrigin() )
	float startTime


	wait 1.5
	startTime = Time()

	OnThreadEnd(
	function() : ( soundEnt, civilianSpeaker, player, startTime )
		{
			if ( IsValid( soundEnt ) )
				soundEnt.Destroy()

			if ( !Flag( "player_approaching_stage" ) )
				return


			// Teacher reaction dialogue done in QC now
			//thread DialogueCivilianSpeakerPlayerInterrupts( civilianSpeaker, player )
			FlagSet( "PlayerInterruptedLecture" )
			SetLectureHallLineDuration( Time() - startTime )
		}
	)




	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_lecture_TS121_01_01_imc_genMarder" )

	wait 0.1


}


/////////////////////////////////////////////////////////////////////////////////////////
void function CivilianStudentThink( entity student )
{

	array< entity > linkedEnts = student.GetLinkEntArray()
	string classname
	entity animProp
	foreach( entity ent in linkedEnts )
	{
		classname = ent.GetClassName()
		if ( classname == "prop_dynamic_lightweight" )
			animProp = ent

	}
	// I hate this function always breaks
	return

	Assert( IsValid( animProp ) )
	vector origin = animProp.GetOrigin()
	vector angles = animProp.GetAngles()
	animProp.Destroy()

	string animIdle = expect string( student.kv.script_noteworthy )
	thread GivePropForAnim( student, animIdle )
	Assert( IsValid( animIdle ), "Ent at " + student.GetOrigin() +  " needs an anim name in its script_noteworthy" )
	string animReact = ""
	float randomWait = RandomFloatRange( 0.2, 0.85 )

	if ( animIdle == "pt_lecture_student_1_idle" )
		animReact = "pt_lecture_student_1_react"

	if ( animIdle == "pt_lecture_student_2_idle" )
		animReact = "pt_lecture_student_2_react"

	if ( animIdle == "pt_lecture_student_4_idle" )
		animReact = "pt_lecture_student_4_react"

	if ( animIdle == "pt_lecture_student_5_idle" )
		animReact = "pt_lecture_student_5_react"

	if ( animIdle == "pt_lecture_student_6_idle" )
		animReact = "pt_lecture_student_6_react"

	if ( animIdle == "pt_lecture_student_7_idle" )
		animReact = "pt_lecture_student_7_react"

	///3A and B are synced neighbors, don't do random wait
	if ( animIdle == "pt_lecture_student_3A_idle" )
	{
		animReact = "pt_lecture_student_3A_react"
		randomWait = 0.0
	}

	if ( animIdle == "pt_lecture_student_3B_idle" )
	{
		animReact = "pt_lecture_student_3B_react"
		randomWait = 0.0
	}


	Assert( animReact != "" )

	thread PlayAnim( student, animIdle, origin, angles )

	/*

	//don't worry about playing audience reaction anims

	FlagWait( "player_entering_lecture_hall" )

	FlagWait( "player_approaching_stage" )



	wait randomWait

	thread PlayAnim( student, animReact, origin, angles )

	*/

}


/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███╗   ██╗████████╗███████╗██████╗              ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗
██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗            ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝
█████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝            ██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗
██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗            ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║
███████╗██║ ╚████║   ██║   ███████╗██║  ██║            ╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║
╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝             ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███╗   ██╗████████╗███████╗██████╗              ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗
██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗            ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝
█████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝            ██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗
██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗            ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║
███████╗██║ ╚████║   ██║   ███████╗██║  ██║            ╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║
╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝             ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███╗   ██╗████████╗███████╗██████╗              ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗
██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗            ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝
█████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝            ██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗
██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗            ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║
███████╗██║ ╚████║   ██║   ███████╗██║  ██║            ╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║
╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝             ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███╗   ██╗████████╗███████╗██████╗              ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗
██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗            ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝
█████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝            ██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗
██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗            ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║
███████╗██║ ╚████║   ██║   ███████╗██║  ██║            ╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║
╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝             ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////

void function EnterCampusStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointEnterCampus" ) )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function EnterCampusSkipped( entity player )
{
	FlagSet( "player_moving_forward_through_campus" )
	FlagSet( "VistaTimeshiftsFinished" )
	FlagSet( "player_flyer_reactor_reveal_skit" )
	FlagSet( "entered_intro_vista_hallway" )
	CleanupEnts( "civilian_walker_intro_vista" )
	CleanupEnts( "civilian_walker_campus_vista" )
	CleanupEnts( "flyer_crashsite" )
	CleanupEnts( "flyer_victim_crashsite" )
	CleanupEnts( "flyer_intro_hallway_fly_a" )
	CleanupEnts( "flyer_intro_hallway_fly_b" )
	CleanupEnts( "flyer_intro_hallway" )
	CleanupEnts( "prowler_intro_hallway" )
	CleanupEnts( "flyers_reactor" )
	CleanupEnts( "dropships_intro_vista" )
	FlagClear( "HidePlayerWeaponsDuringShifts" )
	FlagSet( "IntroCampusConversationsOver" )
	FlagSet( "FirstCampusConversationOver" )
	thread QuickSkit( player, GetEntByScriptName( "node_marvin_lobby_overgrown" ) )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AA_EnterCampusThread( entity player )
{
	FlagWait( "player_exiting_lecture_hall" )

	entity entRingSteam = GetEntByScriptName( "fx_org_ring_steam" )
	PlayFX( FX_RING_STEAM, entRingSteam.GetOrigin(), entRingSteam.GetAngles() )

	FlagSet( "open_door_lobby_main_overgrown" )

	thread MusicVistaHallway( player )
	thread SequenceProwlerFlyerIntro( player )
	thread DialogueWalkToBTCorpseSearch( player )
	thread DialogueCiviliansNoticePilot( player )
	thread SequenceHallwayCivilians( player )


	thread FlyerAndCorpseThink()

								//skitNode										failsafeFlagToStart
	//thread QuickSkit( player, GetEntByScriptName( "node_flyer_crashsite" ), 	"player_near_crashsite" )
	thread QuickSkit( player, GetEntByScriptName( "node_reactor_flyers" ) )


	//void function QuickSkit( entity player, entity skitNode, string failsafeFlagToStart = "", entity lookAtEnt = null, entity lookAtTrigger = null  )


	FlagWait( "entered_intro_vista_hallway" )


	//-----------------------------------------
	// Erratic time swaps as approach vista
	//-----------------------------------------

	vector objectivePos = GetEntByScriptName( "objective_campus_vista" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )


	IntroSectionCleanup( player )

	thread ScriptedTimeShiftVistaHallway( player )


	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	FlagSet( "PoppedIntoVistaHallwayTimewarp" )

	//-----------------------------------------
	// Prowler/Flyer skit
	//-----------------------------------------
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
	TimeshiftUpdateObjective( player, < 0, 0, 0 >, file.bt )

	//FlagClear( "HidePlayerWeaponsDuringShifts" )

	FlagClear( "open_door_intro_hallway" ) //close so clever player can't go explore
	CleanupEnts( "civilian_walker_intro_vista" )
	CleanupEnts( "civilian_walker_intro_vista_talkers" )


	FlagSet( "ProwlerFlyerSequenceCanStart" )

	FlagWait( "player_flyer_reactor_reveal_skit" )

	thread QuickSkit( player, GetEntByScriptName( "node_marvin_lobby_overgrown" ) )

}


void function FlyerAndCorpseThink()
{
	entity node = GetEntByScriptName( "node_flyer_crashsite" )
	entity victim = GetEntByScriptName( "flyer_victim_crashsite" )
	entity flyerModel = GetEntByScriptName( "flyer_crashsite" )
	entity flyer = CreateTimeshiftCinematicFlyerWithVictim( flyerModel, victim, "corpse" )

	thread PlayAnimTeleport( flyer, "fl_timeshift_eat_corpse_idle", node )
	thread PlayAnimTeleport( victim, "pt_timeshift_flyer_corpse_idle", node )

	flyer.EndSignal( "FlyerDeath" )
	thread FlyerCorpseThink( flyer )
	FlagWaitAny( "player_near_crashsite", "CorpseFlyerTakingDamage" )

	thread PlayAnimTeleport( flyer, "fl_timeshift_eat_corpse", node )
	thread PlayAnimTeleport( victim, "pt_timeshift_flyer_corpse", node )

	wait 4

	flyer.Signal( "FlyerNewPath" )
}


void function FlyerCorpseThink( flyer )
{
	flyer.EndSignal( "FlyerDeath" )
	flyer.WaitSignal( "OnDamaged" )
	FlagSet( "CorpseFlyerTakingDamage" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicVistaHallway( entity player )
{
	FlagWait( "entered_intro_vista_hallway_from_fans" )

	StopMusic()
	PlayMusic( "music_timeshift_04_corridor" )

	FlagWait( "PoppedIntoVistaHallwayTimewarp" )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_04b_flashback04" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueCiviliansNoticePilot( entity player )
{

	FlagEnd( "ProwlerFlyerSequenceCanStart" )

	FlagWait( "PoppedIntoVistaHallwayTimewarp" )

	while( true )
	{
		wait 0.2
		if ( !player.IsOnGround() || player.IsWallRunning() )
			break

	}


	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )
	soundEnt.EndSignal( "OnDestroy" )
	OnThreadEnd(
	function() : ( soundEnt )
		{
			if ( IsValid( soundEnt ) )
				soundEnt.Destroy()
		}
	)

	if ( CoinFlip() )
	{
		//Scientist 4	 Pfft. Pilots.
		EmitSoundAtPosition( TEAM_UNASSIGNED, soundEnt.GetOrigin(), "diag_sp_vistaHall_TS141_05_01_imc_scientist4" )
	}
	else
	{
		//Scientist 5	 Pilots. Thinking they run this place...
		EmitSoundAtPosition( TEAM_UNASSIGNED, soundEnt.GetOrigin(), "diag_sp_vistaHall_TS141_06a_01_imc_scientist5" )
	}
}
/////////////////////////////////////////////////////////////////////////////////////////
void function SequenceHallwayCivilians( entity player )
{
	entity soundent_vista_hallway = GetEntByScriptName( "soundent_vista_hallway" )

	FlagWait( "PlayerSwappingToHallwayVistaPast")

	entity loudspeakerEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	wait 1

	//Crowd noise	<need general background conversation noise for the hallways leading to the vista>
	EmitSoundAtPosition( TEAM_UNASSIGNED, loudspeakerEnt.GetOrigin(), "diag_sp_vistaHall_TS141_01_01_imc_lectureWalla" )

	wait 2

	array <entity> civilianTalkers = file.hallwayTalkers
	Assert( civilianTalkers.len() == 2 )

	civilianTalkers[ 0 ].EndSignal( "OnDestroy" )
	civilianTalkers[ 1 ].EndSignal( "OnDestroy" )

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/



	//IMC Security 1 - PA	 (ding) Security team Charlie, please report to the lecture hall.
	//delaythread ( 3 ) PlayTimeShiftDialogue( player, loudspeakerEnt, "diag_sp_vistaHall_TS141_04_01_imc_security1" )

	//IMC Security 1 - PA	Reminder. Identification credentials must be displayed at all times. Any suspicious activity should be reported to your nearest automated security personnel.
	delaythread ( 1 ) PlayTimeShiftDialogue( player, loudspeakerEnt, "diag_sp_vistaHall_TS141_07_01_imc_security1" )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueWalkToBTCorpseSearch( entity player )
{
	player.EndSignal( "OnDeath" )

	FlagWait( "VistaTimeshiftsFinished" )



/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/



	//Option A - Player (Option A)	What is this place? diag_sp_watersEdge_TS151_01_01_mcor_player
	//Option B - BT The IMC has multiple scientific research facilities throughout the Frontier. However, this particular one is unlike any known to the Militia.	diag_sp_watersEdge_TS152_01_01_mcor_bt

	//Option B	What happened to everyone here? 	diag_sp_watersEdge_TS151_04a_01_mcor_player
	//Option B	Their bodies have aged unusually, however, some show signs of weapon fire.	diag_sp_watersEdge_TS152_04_01_mcor_bt


	//Option A - Suboption 1	How many of these facilities are there? 	diag_sp_watersEdge_TS152_02_01_mcor_player
	//Option A - Suboption 1	In the eight standand months prior to Operation Broadsword, the 9th Militia Fleet captured or destroyed over twenty-nine such installations	diag_sp_watersEdge_TS152_03_01_mcor_bt

	//Option A - Suboption 2	How so?	diag_sp_watersEdge_TS151_02d_01_mcor_player
	//Option A - Suboption 2	The large rings within the main campus are not an IMC techonology. Its design is foreign and its function is unknown.	diag_sp_watersEdge_TS151_02e_01_mcor_bt

	//Option B - Suboption 1	I hope that doesn't happen to me.	diag_sp_watersEdge_TS151_06_01_mcor_player
	//Option B - Suboption 1	Your fear is justified, but I will do my best to protect you.	diag_sp_watersEdge_TS151_07_01a_mcor_bt

	//Option B - Suboption 2	Hopefully Anderson's alive.	diag_sp_watersEdge_TS151_08_01a_mcor_player
	//Option B - Suboption 2	Anderson is a Veteran SRS Pilot. He has survived multiple covert missions within enemy territory.	diag_sp_watersEdge_TS151_09_01a_mcor_bt


	wait 1

	AddConversationCallback( "TsWhatHappenedHere", ConvoCallback_TsWhatHappenedHere )
	//waitthread PlayerConversationStopOnFlag( "TsWhatHappenedHere", player, "player_near_bt_intro" )
	waitthread PlayerConversationStopOnFlag( "TsWhatHappenedHere", player, "PlayerStartedHelmetRecovery" )


	FlagWait( "FirstCampusConversationOver" )

	if ( Flag( "FirstCampusConversationSkipped" ) )
	{
		//BT These temporal distortions appear to be causing a rift in time. I advise caution until we have further information.
		waitthread PlayBTDialogue( "diag_sp_artifact_TS111_03a_01_mcor_bt" )
	}



	for ( int i = 0; i < 5; i++ )
	{
		wait 1
		if ( Flag( "player_near_bt_intro" ) )
		{
			FlagSet( "IntroCampusConversationsOver" )
			return
		}

	}


	//try not to overlap if player found an audio log
	while ( IsAudioLogPlaying ( player ) )
		wait 1

	if ( !Flag( "player_near_bt_intro" ) )
	{
		//Strange... I am picking up traces of my own data signature within this area. The distortions must be affecting my scans.	diag_sp_extra_TS501_01_01_mcor_bt
		waitthread PlayBTDialogue( "diag_sp_extra_TS501_01_01_mcor_bt" )
	}


	for ( int i = 0; i < 15; i++ )
	{
		wait 1
		if ( Flag( "player_near_bt_intro" ) )
		{
			FlagSet( "IntroCampusConversationsOver" )
			return
		}

	}

	//try not to overlap if player found an audio log
	while ( IsAudioLogPlaying ( player ) )
		wait 1

	if ( !Flag( "player_near_bt_intro" ) )
	{
		//Interesting. I am detecting traces of a massive energy explosion throughout this facility,
		// however, your helmet data does not detect the same in the other timeline.
		waitthread PlayBTDialogue( "diag_sp_vistaHall_TS141_08_01_mcor_bt" )

	}



	FlagSet( "IntroCampusConversationsOver" )

}



void function ConvoCallback_TsWhatHappenedHere( int choice )
{
	if ( choice == 0 ) //choice "0" means no options were picked
	{
		FlagSet( "FirstCampusConversationSkipped" )
	}
	FlagSet( "FirstCampusConversationOver" )



}





/////////////////////////////////////////////////////////////////////////////////////////
void function SequenceProwlerFlyerIntro( entity player )
{
	entity node = GetEntByScriptName( "node_intro_prowler_flyer_sequence" )
	vector origin = node.GetOrigin()
	vector angles = node.GetAngles()
	entity flyer = GetEntByScriptName( "flyer_intro_hallway" )
	//entity flyerSpawner = GetEntByScriptName( "flyer_intro_hallway" )
	//entity flyer = CreateServerFlyer( flyerSpawner.GetOrigin(), flyerSpawner.GetAngles() )
	//flyerSpawner.Destroy()
	entity prowler = GetEntByScriptName( "prowler_intro_hallway" )
	entity flyerBuddyAModel = GetEntByScriptName( "flyer_intro_hallway_fly_a" )
	entity flyerBuddyBModel = GetEntByScriptName( "flyer_intro_hallway_fly_b" )

	entity flyerBuddyA = CreateServerFlyer( flyerBuddyAModel.GetOrigin(), flyerBuddyAModel.GetAngles(), FLYER_TIMESHIFT_HEALTH )
	flyerBuddyAModel.Destroy()
	entity flyerBuddyB = CreateServerFlyer( flyerBuddyBModel.GetOrigin(), flyerBuddyBModel.GetAngles(), FLYER_TIMESHIFT_HEALTH )
	flyerBuddyBModel.Destroy()

	flyerBuddyA.Show()
	flyerBuddyB.Show()

	//thread ScriptedDeathFlyerIntro( flyer, prowler )
	node.Destroy()

	flyer = CreateTimeshiftCinematicFlyerWithVictim( flyer, prowler, "prowler" )

	thread PlayAnimTeleport( flyer, "fl_timeshift_campus_jumpscare_idle", origin, angles )
	thread PlayAnimTeleport( prowler, "pr_timeshift_campus_jumpscare_idle", origin, angles )
	thread PlayAnimTeleport( flyerBuddyA, "fl_timeshift_campus_flyby_a_idle", origin, angles )
	thread PlayAnimTeleport( flyerBuddyB, "fl_timeshift_campus_flyby_b_idle", origin, angles )


	flyer.Hide()
	prowler.Hide()



	FlagWait( "ProwlerFlyerSequenceCanStart" )


	//if ( GetBugReproNum() != 123 )
		//return

	entity lookEnt = GetEntByScriptName( "looktarget_intro_prowler" )
	entity trigger = GetEntByScriptName( "intro_hallway_prowler_skit_zone" )

 									 				//doTrace	degrees		minDist	 	timeOut 	trigger, 	failsafeFlag )
	waitthread WaitTillLookingAt( player, lookEnt, 	true, 		30, 		0, 			0, 			trigger, 	"player_intro_hallway_prowler_skit_failsafe")

	flyer.Show()

	prowler.Show()
	flyerBuddyA.Show()
	flyerBuddyB.Show()

	float fxDelay = 1.8
	entity glassFxEnt = GetEntByScriptName( "fx_ent_glass_break_intro_hall" )
	delaythread ( fxDelay ) PlayFX( FX_FLYER_INTRO_GLASS_EXPLODE, glassFxEnt.GetOrigin(), glassFxEnt.GetAngles() )
	FlagSetDelayed( "fx_ts_flyer_glass", fxDelay )
	delaythread ( fxDelay ) CreateAirShake( glassFxEnt.GetOrigin(), 10, 105, 1.25 )
	delaythread ( fxDelay ) HideStuff( "hallway_glass_intact" )
	delaythread ( fxDelay ) ShowStuff( "hallway_glass_broken" )

	FlagSet( "FlyerIntroSequenceStarted")

	flyerBuddyA.Show()
	flyerBuddyB.Show()

	thread PlayAnimThenDelete( prowler, "pr_timeshift_campus_jumpscare", origin, angles )
	thread PlayAnimThenDelete( flyerBuddyA, "fl_timeshift_campus_flyby_a", origin, angles )
	thread PlayAnimThenDelete( flyerBuddyB, "fl_timeshift_campus_flyby_b", origin, angles )
	thread PlayAnimThenDelete( flyer, "fl_timeshift_campus_jumpscare", origin, angles )


}

entity function CreateTimeshiftCinematicFlyerWithVictim( entity flyerModel, entity victim, string whichSequence )
{
	entity newFlyer = CreateServerFlyer( flyerModel.GetOrigin(), flyerModel.GetAngles(), FLYER_TIMESHIFT_HEALTH )
	thread FlyerAndVictimThink( newFlyer, victim, whichSequence )
	flyerModel.Destroy()
	return newFlyer

}

void function FlyerAndVictimThink( entity flyer, entity victim, string whichSequence )
{
	flyer.s.perched <- true
	thread FlyerDeathAnimThink( flyer, whichSequence )
	flyer.WaitSignal( "FlyerDeath" )
	victim.BecomeRagdoll( Vector( 0,0,-100 ), false )
}

void function FlyerDeathAnimThink( flyer, whichSequence )
{
	//if ( whichSequence == "corpse" )
	flyer.WaitSignal( "FlyerNewPath" )

	delete flyer.s.perched
}


/*
void function ScriptedDeathFlyerIntro( entity flyer, entity prowler )
{
	FlagWait( "FlyerIntroSequenceStarted" )

	float startTime = Time()
	float currentTime

	flyer.SetTakeDamageType( DAMAGE_EVENTS_ONLY )
	flyer.SetDamageNotifications( true )
	flyer.SetMaxHealth( 150 )
	flyer.SetHealth( 150 )

	OnThreadEnd(
	function() : ( currentTime, startTime, flyer, prowler )
		{
			string deathAnim
			float currentTime = Time() - startTime
			if ( currentTime < 2 )
				deathAnim = "fl_timeshift_campus_jumpscare_death"
			else
				deathAnim = "fl_fly_death"
			if ( IsValid( flyer ) )
				thread PlayAnim( flyer, deathAnim )
			if ( IsValid( prowler ) )
				prowler.BecomeRagdoll( Vector( 0, 0, 0), false )
		}
	)


	while( true )
	{
		flyer.WaitSignal( "OnDamaged" )
		break
	}
}
*/


/////////////////////////////////////////////////////////////////////////////////////////
void function ScriptedTimeShiftVistaHallway( entity player )
{
	//------------------
	// Vista Hallway time shift
	//-------------------

	entity triggerToDoFluxIn = GetEntByScriptName( "player_inside_intro_vista_hallway_overgrown" )
	entity lookTarget = triggerToDoFluxIn.GetLinkEnt()

 									 				//doTrace	degrees		minDist	 	timeOut 	trigger, 	failsafeFlag )
	waitthread WaitTillLookingAt( player, lookTarget, 	true, 		30, 		0, 			0, 			triggerToDoFluxIn, 	"start_vista_hall_timeshift_failsafe")

	FlagSet( "PlayerSwappingToHallwayVistaPast" )

	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )

	FlagWaitWithTimeout( "player_intro_hallway_prowler_skit_failsafe_pristine", 8 )

	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
	FlagSet( "HallwayCivilianTimeSwapOver" )

	thread CleanupAI( player, "trigger_ai_pristine" )

	//------------------
	// Vista time shift
	//-------------------
	FlagWait( "player_entered_campus" )
	//triggerToDoFluxIn = GetEntByScriptName( "player_at_campus_start" )
	//lookTarget = triggerToDoFluxIn.GetLinkEnt()
 									 				//doTrace	degrees		minDist	 	timeOut 	trigger, 	failsafeFlag )
	//waitthread WaitTillLookingAt( player, lookTarget, 	true, 		30, 		0, 			0, 			triggerToDoFluxIn, 	"start_vista_hall_timeshift_failsafe")


	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )
	FlagSet( "PlayerSwappingToCampusVistaPast" )

	FlagWait( "PlayerSwappingToCampusVistaPast" )

	FlagWaitWithTimeout( "player_moving_forward_through_campus", 4 )

	waitthread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )

	FlagClear( "HidePlayerWeaponsDuringShifts" )
	FlagSet( "VistaTimeshiftsFinished" )
	CheckPoint_Silent()

	thread QuickSkit( player, GetEntByScriptName( "node_prowler_howlers" ), "player_entered_campus" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
	thread CleanupAI( player, "trigger_ai_pristine" )
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ ██████╗ ██████╗ ██████╗ ███████╗███████╗            ███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝            ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║     ██║   ██║██████╔╝██████╔╝███████╗█████╗              ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║     ██║   ██║██╔══██╗██╔═══╝ ╚════██║██╔══╝              ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚██████╗╚██████╔╝██║  ██║██║     ███████║███████╗            ███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝            ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ ██████╗ ██████╗ ██████╗ ███████╗███████╗            ███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝            ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║     ██║   ██║██████╔╝██████╔╝███████╗█████╗              ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║     ██║   ██║██╔══██╗██╔═══╝ ╚════██║██╔══╝              ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚██████╗╚██████╔╝██║  ██║██║     ███████║███████╗            ███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝            ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ ██████╗ ██████╗ ██████╗ ███████╗███████╗            ███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝            ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║     ██║   ██║██████╔╝██████╔╝███████╗█████╗              ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║     ██║   ██║██╔══██╗██╔═══╝ ╚════██║██╔══╝              ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚██████╗╚██████╔╝██║  ██║██║     ███████║███████╗            ███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝            ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ ██████╗ ██████╗ ██████╗ ███████╗███████╗            ███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝            ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║     ██║   ██║██████╔╝██████╔╝███████╗█████╗              ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║     ██║   ██║██╔══██╗██╔═══╝ ╚════██║██╔══╝              ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚██████╗╚██████╔╝██║  ██║██║     ███████║███████╗            ███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝            ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function CorpseSearchStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointCorpseSearch" ) )
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_START", < 0, 0, 0 >, file.bt )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function CorpseSearchSkipped( entity player )
{
	BTCorpseSearchCleanup()
	FlagSet( "RecoveredHelmet" )
	CleanupEnts( "helmet_dogtag" )
	FlagSet( "HelmetRecoveryDroppedToFloor" )
	FlagSet( "GiveHelmetToBTObjectiveGiven" )
	delaythread ( 1 ) AndersonHideOutlines()
	FlagClear( "PlaySparksOnHelmet" )
	// ShowStuff( "blocker_overgrown_start_vista" )
}


/////////////////////////////////////////////////////////////////////////////////////////

void function AA_CorpseSearchThread( entity player )
{
	FlagWait( "player_flyer_reactor_reveal_skit" )

	entity bt = file.bt
	entity node = GetEntByScriptName( "node_bt_corpse_search" )


	thread MusicWalkToCorpseSearch( player )
	thread PickupHelmetThink( player )
	thread MusicCorpseSearch( player )

	FlagWait( "VistaTimeshiftsFinished" )
	CleanupEnts( "dropships_intro_vista" )
	CleanupEnts( "civilian_walker_campus_vista" )


	//----------------------------------
	// BT searching for Anderson Corpse
	//----------------------------------
	thread BTCorpseSearch( player )
	thread DialogueCheckLobby( player )
	thread DialogueHelmetRecovered( player )
	thread DialogueHelmetNags( player )

	TimeshiftUpdateObjective( player, < 0, 0, 0 >, file.bt )

	FlagWait( "player_moving_forward_through_campus" )
	// ShowStuff( "blocker_overgrown_start_vista" )

	thread LobbyObjectiveThink( player )
	thread LobbyProwler( player )

	CheckPoint_Silent()


	SetGlobalNetBool( "squadConversationEnabled", true )

	FlagWait( "player_near_bt_intro" )
	CheckPoint()


	//-----------------------
	// Find Anderson's helmet
	//------------------------
	FlagWait( "HelmetRecoveryDroppedToFloor" )
	FlagClear( "PlaySparksOnHelmet" )

	FlagWait( "RecoveredHelmet" )
}
/////////////////////////////////////////////////////////////////////////////////////////////////
void function LobbyObjectiveThink( entity player )
{
	vector posHelmet = GetHelmetOrigin()
	vector posLobbyDoor = GetEntByScriptName( "objective_lobby_door" ).GetOrigin()
	vector posLobbyUpperRoom = GetEntByScriptName( "objective_lobby_upper_room" ).GetOrigin()
	vector objectivePos
	FlagWait( "BTpointedAtLobby" )

	wait 5

	if ( Flag( "PlayerStartedHelmetRecovery" ) )
		return

	bool objectiveHasBeenSet = false
	string objectiveText

	FlagEnd( "PlayerStartedHelmetRecovery" )

	while( !Flag( "PlayerStartedHelmetRecovery" ) )
	{
		wait 1

		if ( !Flag( "player_inside_lobby_overgrown" ) )
		{
			objectivePos = posLobbyDoor
			objectiveText = "#TIMESHIFT_OBJECTIVE_EXPLORE_LOBBY"
		}
		else if ( Flag( "player_in_lobby_escalator_room_overgrown" ) )
		{
			objectiveText = "#TIMESHIFT_OBJECTIVE_TAKE_HELMET"
			objectivePos = posHelmet
		}
		else //not upstairs, but not outside
		{
			objectivePos = posLobbyUpperRoom
			objectiveText = "#TIMESHIFT_OBJECTIVE_EXPLORE_LOBBY"
		}

		//Set or update the objective
		if ( !objectiveHasBeenSet )
		{
			TimeshiftSetObjective( player, objectiveText, objectivePos )
			objectiveHasBeenSet = true
		}
		else
		{
			TimeshiftSetObjectiveSilent( player, objectiveText, objectivePos )
		}
	}



}
/////////////////////////////////////////////////////////////////////////////////////////////////
void function LobbyProwler( entity player )
{
	FlagWait( "player_in_lobby_escalator_room_overgrown" )

	//-----------------------------------------------------
	// token prowlers
	//-------------------------------------------------------
	array< entity > propSpawners = GetEntArrayByScriptName( "lobby_prowler_intro_spawnvents" )
	float delayMin = 2
	float delayMax = 4
	int maxToSpawn = 1
	string flagToAbort = "RecoveredHelmet"
	bool requiresLookAt = true
	string flagToSetWhenProwlerSpawned = ""
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "", delayMin, delayMax, flagToSetWhenProwlerSpawned, requiresLookAt )

}
/////////////////////////////////////////////////////////////////////////////////////////////////
void function ProwlersLobbyThink( entity prowler )
{
	if ( Flag( "player_back_in_amenities_lobby" ) )
		return

	if ( !IsAlive( prowler ) )
		return


	prowler.EndSignal( "OnDeath" )
	//if this is where player is getting Anderson's helmet, bind the prowler(s) to the lobby building
	prowler.AssaultPoint( Vector( 816, -2704, -1056) )
	prowler.AssaultSetGoalRadius( 1300 )
	prowler.AssaultSetFightRadius( 0 )

	//if he's still alive while player is taking the helmet, delete him
	FlagWait( "PlayerStartedHelmetRecovery" )

	prowler.Destroy()

}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicCorpseSearch( entity player )
{
	FlagWait( "player_entered_lobby_overgrown_start" )

	StopMusic()
	PlayMusic( "music_timeshift_06_findanderson" )

	FlagWait( "HelmetRecoveryDroppedToFloor" )

	StopMusic()
	PlayMusic( "music_timeshift_07_gethelmet" )
}


/////////////////////////////////////////////////////////////////////////////////////////
void function MusicWalkToCorpseSearch( entity player )
{
	FlagWait( "VistaTimeshiftsFinished" )

	FlagWaitAny( "dropped_into_campus", "player_moving_forward_through_campus" )

	wait 0.5

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_05_jumpdown" )
}


/////////////////////////////////////////////////////////////////////////////////////////
void function BTCorpseSearch( entity player )
{
	entity bt = file.bt
	vector origin = bt.GetOrigin()
	vector angles = bt.GetAngles()
	entity node = GetEntByScriptName( "node_bt_corpse_search" )
	entity corpse01 = CreatePropDynamic( IMC_CORPSE_MODEL_RIFLE, origin, angles, 0 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	entity corpse02 = CreatePropDynamic( IMC_CORPSE_MODEL_RIFLE, origin, angles, 0 )
	entity corpse03 = CreatePropDynamic( IMC_CORPSE_MODEL_RIFLE, origin, angles, 0 )
	entity corpse04 = CreatePropDynamic( IMC_CORPSE_MODEL_RIFLE, origin, angles, 0 )
	entity corpse05 = CreatePropDynamic( IMC_CORPSE_MODEL_RIFLE, origin, angles, 0 )

	corpse01.kv.fadedist = 5000
	corpse02.kv.fadedist = 5000
	corpse03.kv.fadedist = 5000
	corpse04.kv.fadedist = 5000
	corpse05.kv.fadedist = 5000



	//$bodygroup imc_corpse_rifle
	//$bodygroup imc_corpse_shotgun
	//$bodygroup imc_corpse_smg
	//$bodygroup imc_corpse_lmg

	//ChangeIMCCorpse( corpse01, "imc_corpse_rifle" )
	//ChangeIMCCorpse( corpse02, "imc_corpse_shotgun" )
	//ChangeIMCCorpse( corpse03, "imc_corpse_smg" )
	//ChangeIMCCorpse( corpse04, "imc_corpse_lmg" )
	//ChangeIMCCorpse( corpse05, "imc_corpse_rifle" )

	corpse01.kv.script_name = "corpse01"
	corpse02.kv.script_name = "corpse02"
	corpse03.kv.script_name = "corpse03"
	corpse04.kv.script_name = "corpse04"
	corpse05.kv.script_name = "corpse05"

	FlagEnd( "RecoveredHelmet" )

	OnThreadEnd(
	function() : ( bt )
		{
			bt.Anim_Stop()
			BTCorpseSearchCleanup()
		}
	)

	float animStartTime = 0.0
	float currentTime
	bool btPointedAtLobby = false
	float startTime
	float animLength = file.bt.GetSequenceDuration( "bt_timeshift_corpse_search_loop" )
	startTime = Time()
	bool playLoop = true
	float animTimeRemaining
	float blendTime = 0.4


	while( true )
	{

		if ( playLoop )
		{
			//function PlayAnim( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, initialTime = -1.0 )
			thread PlayAnim( file.bt, "bt_timeshift_corpse_search_loop", node, null, blendTime, animStartTime )
			thread PlayAnim( corpse01, "pt_timeshift_corpse_search_01_loop", node, null, blendTime, animStartTime )
			thread PlayAnim( corpse02, "pt_timeshift_corpse_search_02_loop", node, null, blendTime, animStartTime )
			thread PlayAnim( corpse03, "pt_timeshift_corpse_search_03_loop", node, null, blendTime, animStartTime )
			thread PlayAnim( corpse04, "pt_timeshift_corpse_search_04_loop", node, null, blendTime, animStartTime )
			thread PlayAnim( corpse05, "pt_timeshift_corpse_search_05_loop", node, null, blendTime, animStartTime )
			animTimeRemaining = animLength
		}

		if ( btPointedAtLobby )
			break

		FlagWaitWithTimeout( "player_near_bt_intro_and_one_line_played", animTimeRemaining )

		currentTime = Time() - startTime


		//-----------BREAKOUT SEQUENCE 01 -----------------//
		if ( ( currentTime >= 7.14 ) && ( currentTime < 11.21 ) )
		{
			btPointedAtLobby = true
			FlagSet( "BTpointedAtLobby" )
			thread PlayAnim( file.bt, "bt_timeshift_corpse_search_breakout_01", node, null, blendTime )
			waitthread PlayAnim( corpse01, "pt_timeshift_corpse_search_01_breakout", node, null, blendTime )
			animStartTime = currentTime
			playLoop = true
			continue
		}

		//-----------BREAKOUT SEQUENCE 02 -----------------//
		else if ( ( currentTime >= 22.15 ) && ( currentTime < 25.27 ) )
		{
			btPointedAtLobby = true
			FlagSet( "BTpointedAtLobby" )
			thread PlayAnim( file.bt, "bt_timeshift_corpse_search_breakout_02", node, null, blendTime )
			waitthread PlayAnim( corpse02, "pt_timeshift_corpse_search_02_breakout", node, null, blendTime )
			animStartTime = currentTime
			playLoop = true
			continue
		}

		//-----------BREAKOUT SEQUENCE 03 -----------------//
		else if ( ( currentTime >= 34.08 ) && ( currentTime < 38.01 ) )
		{
			btPointedAtLobby = true
			FlagSet( "BTpointedAtLobby" )
			thread PlayAnim( file.bt, "bt_timeshift_corpse_search_breakout_03", node, null, blendTime )
			waitthread PlayAnim( corpse03, "pt_timeshift_corpse_search_03_breakout", node, null, blendTime )
			animStartTime = currentTime
			playLoop = true
			continue
		}

		//-----------BREAKOUT SEQUENCE 04 -----------------//
		else if ( ( currentTime >= 47.00 ) && ( currentTime < 50.13 ) )
		{
			btPointedAtLobby = true
			FlagSet( "BTpointedAtLobby" )
			thread PlayAnim( file.bt, "bt_timeshift_corpse_search_breakout_04", node, null, blendTime )
			waitthread PlayAnim( corpse04, "pt_timeshift_corpse_search_04_breakout", node, null, blendTime )
			animStartTime = currentTime
			playLoop = true
			continue
		}

		//-----------BREAKOUT SEQUENCE 05 -----------------//
		else if ( ( currentTime >= 60.15 ) && ( currentTime < 64.11 ) )
		{
			btPointedAtLobby = true
			FlagSet( "BTpointedAtLobby" )
			thread PlayAnim( file.bt, "bt_timeshift_corpse_search_breakout_05", node, null, blendTime )
			waitthread PlayAnim( corpse05, "pt_timeshift_corpse_search_05_breakout", node, null, blendTime )
			animStartTime = currentTime
			playLoop = true
			continue
		}

		//-----------TOO FAR IN THE SEQUENCE TO PLAY BREAKOUTS, START OVER-----------------//
		else if ( currentTime > 64.11 )
		{
			wait ( animLength - currentTime )
			startTime = Time()
			playLoop = true
		}

		//-----------STILL COULD PLAY A BREAKOUT, LOOP THROUGH AGAIN-----------------//
		else
		{
			WaitFrame()
			playLoop = false
			animTimeRemaining = ( animLength - currentTime )
		}
	}


	WaitForever()

}


/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueCheckLobby( entity player )
{

	FlagWait( "player_near_bt_intro" )

	entity helmet = GetEntByScriptName( "helmet_dogtag" )
/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagWait( "IntroCampusConversationsOver" )
	FlagWait( "FirstCampusConversationOver" )

	wait 0.5

	entity bt = player.GetPetTitan()
	if ( !Flag( "PlayerStartedHelmetRecovery" ) )
	{
		//BT	None of these remains match the genetic profile of Major Anderson.
		waitthread PlayBTDialogue( "diag_sp_watersEdge_TS150_01_01_mcor_bt" )
	}


	FlagSet( "player_near_bt_intro_and_one_line_played" )

	if ( !Flag( "PlayerStartedHelmetRecovery" ) )
		FlagWait( "BTpointedAtLobby" )

	// BT		I recommend you check the main lobby and reception. I would accompany you but unfortunately my chassis will not fit in the door.

	// Player (Option A)		Lucky you...
	// BT (Option A)		I detect sarcasm.
	// Player (Option A - Auto)		(brief chuckle)

	// Player (Option B)		Time to earn my keep...
	// BT (Option B)		Close-quarters recon is the sole domain of the Pilot.

	if ( !Flag( "player_entered_lobby_overgrown_start" ) )
		waitthread PlayerConversationStopOnFlag( "TsCheckTheLobby", player, "player_entered_lobby_overgrown_start" )


	FlagSet( "StartHelmetNags" )


}

void function DialogueHelmetRecovered( entity player )
{
	//------------------------------
	// Player takes Anderson helmet
	//-------------------------------
	FlagWait( "PlayerStartedHelmetRecovery" )
	FlagWaitClear( "HelmetNagInProgress" )


	wait 13

	//Player	Option A	I found Anderson. He's..uh..in a wall...
	//BT	Option A	Objective complete. We have rendezvoused with Major Anderson.

	//Player 	Option B	Anderson located. I grabbed his helmet. Unlike him, it appears to be in one piece.
	//BT 	Option B	Well done. Bring it to me. I can analyze his helmet for important data.
	//Player 	Option B - Auto	Got it.


	//Player	Option A - Suboption 1	That’s cold, BT.
	//BT	Option A - Suboption 1	Correct. Anderson’s current temperature is 17 degrees Celsius, below the threshold of human survival.

	//Player	Option A - Suboption 2	Very funny...
	//BT	Option A - Suboption 2	My intention was not humor.

	AddConversationCallback( "TsPlayerFoundAnderson", ConvoCallback_TsPlayerFoundAnderson )
	waitthread PlayerConversationStopOnFlag( "TsPlayerFoundAnderson", player, "playerFailsafesProwlersAttackBT" )

	if ( Flag( "HelmetConversationSkipped" ) )
	{
		//BT	Pilot, bring me his helmet, I will analyze it.
		waitthread PlayBTDialogue( "diag_sp_anderson_TS171_12_01_mcor_bt" )
	}

	if ( !Flag( "HelmetConversationDone" ) )
		FlagSet( "HelmetConversationDone" )

	FlagSet( "GiveHelmetToBTObjectiveGiven" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function ConvoCallback_TsPlayerFoundAnderson( int choice )
{
	if ( choice == 0 ) //choice "0" means no options were picked
	{
		FlagSet( "HelmetConversationSkipped" )
		FlagSet( "HelmetConversationDone" )
	}


}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueHelmetNags( entity player )
{

	if ( Flag( "PlayerStartedHelmetRecovery" ) )
		return

	FlagWait( "StartHelmetNags" )

	if ( Flag( "PlayerStartedHelmetRecovery" ) )
		return

	//---------------------------------
	// Wait till player finds Anderson
	//---------------------------------
	vector objectivePos = GetHelmetOrigin()
	string nagAlias
	entity helmet = GetEntByScriptName( "helmet_dogtag" )

	while( !Flag( "PlayerStartedHelmetRecovery" ) )
	{
		wait RandomFloatRange( 30, 45 )

		if ( !IsValid( helmet) )
			break

		if ( Flag( "PlayerStartedHelmetRecovery" ) )
			break

		if ( IsAudioLogPlaying( player ) )
			continue

		if ( PlayerInRange( player.GetOrigin(), objectivePos, 256 ) )
		{
			//BT	I will analyze Major Anderson's helmet for mission critical data. I recommend you retrieve it.
			nagAlias = "diag_sp_anderson_TS171_14_01_mcor_bt"
		}

		else if ( Flag( "player_in_lobby_escalator_room_overgrown" ) )
		{
			//BT	Pilot, there may be important data within Major Anderson's helmet. Retrieve it for analysis.
			nagAlias = "diag_sp_anderson_TS171_13_01_mcor_bt"
		}

		else if ( Flag( "player_inside_lobby_overgrown" ) )
		{
			// BT	Uphold the mission. I am detecting a faint bio-signature in the lobby of main reception. Recommend you investigate.
			nagAlias = "diag_sp_overgrown_TS161_11_01_mcor_bt"

		}
		else
		{
			// BT	Major Anderson's location is unknown. It is possible he proceeded through the entrance of the reception lobby.
			nagAlias = "diag_sp_overgrown_TS161_12_01_mcor_bt"
		}

		FlagSet( "HelmetNagInProgress" )
		waitthread PlayBTDialogue( nagAlias )
		Objective_Remind()
		//Objective_Clear()
		//TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_EXPLORE_LOBBY", objectivePos, helmet )
		FlagClear( "HelmetNagInProgress" )
	}

}
/////////////////////////////////////////////////////////////////////////////////////////
void function BTCorpseSearchCleanup()
{
	CleanupEnts( "corpse01" )
	CleanupEnts( "corpse02" )
	CleanupEnts( "corpse03" )
	CleanupEnts( "corpse04" )
	CleanupEnts( "corpse05" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function PickupHelmetThink( entity player )
{
	entity node = GetEntByScriptName( "org_get_helmet_sequence" )
	entity anderson = GetEntByScriptName( "anderson_first_half" )
	entity helmet = GetEntByScriptName( "helmet_dogtag" )
	SetupAndersonHelmet( helmet )
	//anderson.SetAimAssistAllowed( true )
	/*
	entity info_target = helmet.GetLinkEnt()
	vector origin = info_target.GetOrigin()
	vector angles = info_target.GetAngles()
	*/


	thread PlayAnimTeleport( anderson, "pt_timeshift_helmet_grab_corpse_sequence_idle", node )
	thread PlayAnimTeleport( helmet, "helmet_timeshift_helmet_grab_sequence_idle", node )

	wait 1

	thread HelmetFx( helmet )

	//int attachmentID = helmet.LookupAttachment( "ORIGIN" )
	//vector useDummyOrigin = helmet.GetAttachmentOrigin( attachmentID )
	vector useDummyOrigin = helmet.GetOrigin()
	entity useDummy = CreatePropDynamic( DUMMY_MODEL, useDummyOrigin, Vector( 0, 0, 0 ), 2 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only


	useDummy.SetOrigin( useDummyOrigin + Vector( -20, -30, 80 ) )
	useDummy.SetUsable()
	//useDummy.SetUsableRadius( 200 )
	//useDummy.SetUsableFOVByDegrees( 50 )
	useDummy.Hide()
	useDummy.SetUsableByGroup( "pilot" )
	useDummy.SetUsePrompts( "#TIMESHIFT_HINT_TAKE_HELMET" , "#TIMESHIFT_HINT_TAKE_HELMET_PC" )


	OnThreadEnd(
		function() : ( helmet, useDummy )
		{
			if ( !IsValid( helmet) )
				return
			helmet.Destroy()
		}
	)

	entity playerActivator
	while( true )
	{
		playerActivator = expect entity( useDummy.WaitSignal( "OnPlayerUse" ).player )
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() )
			break
	}

	playerActivator.SetNoTarget( true )
	useDummy.UnsetUsable()
	useDummy.Destroy()
	//EmitSoundAtPosition( TEAM_UNASSIGNED, helmet.GetOrigin(), "Player_Melee_Backhand_1P" )

	helmet.Highlight_HideInside( 0 )
	helmet.Highlight_HideOutline( 0 )
	anderson.Highlight_HideInside( 0 )
	anderson.Highlight_HideOutline( 0 )
	//anderson.SetAimAssistAllowed( false )
	
	playerActivator.DisableWeaponWithSlowHolster()
	playerActivator.SetInvulnerable()
	//player.FreezeControlsOnServer()
	playerActivator.ContextAction_SetBusy()

	//----------------------------------
	// Player takes helmet off Anderson
	//------------------------------------
	entity mover = CreateOwnedScriptMover( node ) //need a mover for first person sequence

	FirstPersonSequenceStruct sequenceTakeHelmet
	//sequenceTakeHelmet.blendTime = 0.5
	sequenceTakeHelmet.attachment = "ref"
	sequenceTakeHelmet.firstPersonAnim = "ptpov_timeshift_helmet_grab_sequence"
	sequenceTakeHelmet.thirdPersonAnim = "pt_timeshift_helmet_grab_sequence"
	sequenceTakeHelmet.viewConeFunction = ViewConeTight

	FlagSet( "PlayerStartedHelmetRecovery" )

	FlagSetDelayed( "HelmetRecoveryDroppedToFloor", 6 )
	thread PlayAnim( anderson, "pt_timeshift_helmet_grab_corpse_sequence", mover )
	thread PlayAnim( helmet, "helmet_timeshift_helmet_grab_sequence", mover )
	waitthread FirstPersonSequence( sequenceTakeHelmet, playerActivator, mover )
	
	WaitFrame()

	playerActivator.UnfreezeControlsOnServer()
	playerActivator.ClearInvulnerable()
	playerActivator.Anim_Stop()
	playerActivator.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( playerActivator.ContextAction_IsBusy() )
		playerActivator.ContextAction_ClearBusy()
	playerActivator.EnableWeaponWithSlowDeploy()
	playerActivator.SetNoTarget( false )

	FlagSet( "RecoveredHelmet" )
}

void function AndersonSetupLobby()
{
	entity node = GetEntByScriptName( "org_get_helmet_sequence" )
	entity anderson = GetEntByScriptName( "anderson_first_half" )
	thread PlayAnimTeleport( anderson, "pt_timeshift_helmet_grab_corpse_sequence_idle", node )
	int bodyGroupIndex = anderson.FindBodyGroup( "head" )
	anderson.SetBodygroup( bodyGroupIndex, 1 )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AndersonSetupSkybridge()
{
	entity node = GetEntByScriptName( "org_get_device_sequence" )
	entity anderson = GetEntByScriptName( "anderson_other_half" )
	anderson.SetModel( ANDERSON_MODEL )
	thread PlayAnimTeleport( anderson, "pt_timeshift_device_equip_corpse_sequence_idle", node )
	entity AndersonDeviceFX = PlayLoopFXOnEntity( FX_ANDERSON_DEVICE_FX, anderson, "L_BACKHAND" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AndersonHideOutlines()
{
	entity anderson = GetEntByScriptName( "anderson_first_half" )
	anderson.Highlight_HideInside( 0 )
	anderson.Highlight_HideOutline( 0 )
}


/////////////////////////////////////////////////////////////////////////////////////////
/*
void function ProwlersAttackBT( entity player )
{
	FlagWait( "RecoveredHelmet")

	entity node = GetEntByScriptName( "node_bt_hologram" )
	entity bt = file.bt

	entity prowler1 = GetEntByScriptName( "prowler_BT_attacker01" ).SpawnEntity()
	entity prowler2 = GetEntByScriptName( "prowler_BT_attacker02" ).SpawnEntity()
	DispatchSpawn( prowler1 )
	DispatchSpawn( prowler2 )

	Assert( IsValid( prowler1 ) )
	Assert( IsValid( prowler2 ) )

	MakeInvincible( prowler1 )
	MakeInvincible( prowler2 )

	thread ProwlersAttackBTfailsafe( prowler1 )
	thread ProwlersAttackBTfailsafe( prowler2 )

	thread PlayAnimTeleport( bt, "bt_timeshift_fights_prowlers_idle", node )
	thread PlayAnimTeleport( prowler1, "pr_timeshift_fights_bt_idle", node )
	thread PlayAnimTeleport( prowler2, "pr_timeshift_fights_bt_from_behind_idle", node )

		 									 	//doTrace	degrees		minDist	 	timeOut 	trigger, 	failsafeFlag )
	waitthread WaitTillLookingAt( player, bt, 	true, 		30, 		1500, 			0, 		null, 		"playerFailsafesProwlersAttackBT" )

	thread PlayAnim( prowler1, "pr_timeshift_fights_bt_death", node )
	thread PlayAnimTeleport( prowler2, "pr_timeshift_fights_bt_from_behind", node )
	waitthread PlayAnim( bt, "bt_timeshift_fights_prowlers_end", node )

	prowler1.Destroy()
	prowler2.Destroy()

}
*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
void function ProwlersAttackBTfailsafe( entity prowler )
{

	FlagEnd( "ProwlersAttackBTfinished" )
	FlagEnd( "playerFailsafesProwlersAttackBT" )
	FlagEnd( "player_near_prowlers_attacking_bt" )

	prowler.EndSignal( "OnDamaged" )

	WaitForever()

	OnThreadEnd(
	function() : (  )
		{
			FlagSet( "playerFailsafesProwlersAttackBT" )
		}
	)

}
*/


/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗ ██████╗ ██╗      ██████╗  ██████╗ ██████╗  █████╗ ███╗   ███╗
██║  ██║██╔═══██╗██║     ██╔═══██╗██╔════╝ ██╔══██╗██╔══██╗████╗ ████║
███████║██║   ██║██║     ██║   ██║██║  ███╗██████╔╝███████║██╔████╔██║
██╔══██║██║   ██║██║     ██║   ██║██║   ██║██╔══██╗██╔══██║██║╚██╔╝██║
██║  ██║╚██████╔╝███████╗╚██████╔╝╚██████╔╝██║  ██║██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗ ██████╗ ██╗      ██████╗  ██████╗ ██████╗  █████╗ ███╗   ███╗
██║  ██║██╔═══██╗██║     ██╔═══██╗██╔════╝ ██╔══██╗██╔══██╗████╗ ████║
███████║██║   ██║██║     ██║   ██║██║  ███╗██████╔╝███████║██╔████╔██║
██╔══██║██║   ██║██║     ██║   ██║██║   ██║██╔══██╗██╔══██║██║╚██╔╝██║
██║  ██║╚██████╔╝███████╗╚██████╔╝╚██████╔╝██║  ██║██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////

 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗ ██████╗ ██╗      ██████╗  ██████╗ ██████╗  █████╗ ███╗   ███╗
██║  ██║██╔═══██╗██║     ██╔═══██╗██╔════╝ ██╔══██╗██╔══██╗████╗ ████║
███████║██║   ██║██║     ██║   ██║██║  ███╗██████╔╝███████║██╔████╔██║
██╔══██║██║   ██║██║     ██║   ██║██║   ██║██╔══██╗██╔══██║██║╚██╔╝██║
██║  ██║╚██████╔╝███████╗╚██████╔╝╚██████╔╝██║  ██║██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function HologramStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointHologramSequence" ) )
	vector objectivePos = GetBTObjectivePos()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_BACK_TO_BT_WITH_HELMET", objectivePos, file.bt )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function HologramSkipped( entity player )
{
	FlagSet( "PlayerGivesHelmet" )
	FlagSet( "HologramSequenceOver" )
	FlagSet( "PostHologramDialoguePartyOver" )

	FlagSet( "ShowAlternateMissionLog" )
	UpdatePauseMenuMissionLog( player )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AA_HologramThread( entity player )
{
	FlagWait( "RecoveredHelmet" )

	thread DialogueGiveHelmetNag( player )
	thread HologramSequence( player )
	thread DialogueHologramSequence( player )
	thread MusicHologram( player )

	FlagWait( "PlayerGivesHelmet" )

	FlagWait( "HologramSequenceOver" )

	FlagSet( "ShowAlternateMissionLog" )
	UpdatePauseMenuMissionLog( player )

	delaythread ( 2 ) DisplayLogbookHintTimeshift( player, 6.0 )
}

void function SetupAndersonHelmet( entity helmet )
{
	int bodyGroupIndex = helmet.FindBodyGroup( "helmet" )
	helmet.SetBodygroup( bodyGroupIndex, 2 )
}


void function DisplayLogbookHintTimeshift( entity player, float timeout )
{
	player.EndSignal( "OnDestroy" )

	// client script is waiting for "ingamemenu_activate" to close the hint when the menu opens
	// if that doesn't happend it'll get cleared from here after the timeout
	// there is no ill effects of calling ClearOnscreenHint( player ) if the hint has alredy been cleared by client script.

	SetGlobalNetBool( "DestroyHintOnMenuOpen", true )
	DisplayOnscreenHint( player, "logbook_updated", -1, false, true )

	wait timeout
	SetGlobalNetBool( "DestroyHintOnMenuOpen", false )
	ClearOnscreenHint( player )
}


/////////////////////////////////////////////////////////////////////////////////////////
void function HologramSequence( entity player )
{
	entity bt = file.bt

	//--------------------------
	// BT Idles witing for player and helmet
	//--------------------------
	entity node = GetEntByScriptName( "node_bt_hologram" )
	entity mover = CreateOwnedScriptMover( node ) //need a mover for first person sequence

	thread PlayAnimTeleport( bt, "bt_timeshift_helmet_wait_idle", mover, "ref" )

	CheckPoint()
	Objective_Clear()

	//thread ProwlersAttackBT( player )

	//-----------------------------------------
	// OBJECTIVE: take helmet back to BT
	//-----------------------------------------
	FlagWait( "GiveHelmetToBTObjectiveGiven" )


	vector objectivePos = GetBTObjectivePos()
	TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_BACK_TO_BT_WITH_HELMET", objectivePos, file.bt )


	player.EndSignal("OnDeath" )
	entity sarahHologram = CreatePropDynamic( SARAH_HOLOGRAM_MODEL, bt.GetOrigin(), bt.GetAngles(), 0 ) // 0 = no collision
	entity andersonHologram = CreatePropDynamic( ANDERSON_HOLOGRAM_MODEL, bt.GetOrigin(), bt.GetAngles(), 0 ) // 0 = no collision
	entity timeshiftDeviceHologram = CreatePropDynamic( DEVICE_HOLO_MODEL, bt.GetOrigin(), bt.GetAngles(), 0 ) // 0 = no collision
	sarahHologram.SetSkin( 1 )
	andersonHologram.SetSkin( 1 )
	timeshiftDeviceHologram.SetSkin( 1 )
	entity helmet = CreatePropDynamic( HELMET_MODEL, bt.GetOrigin(), bt.GetAngles(), 0 ) // 0 = no collision
	SetupAndersonHelmet( helmet )
	helmet.Hide()
	sarahHologram.Hide()
	andersonHologram.Hide()
	timeshiftDeviceHologram.Hide()

	thread TimeshiftDeviceHologramThink( timeshiftDeviceHologram, andersonHologram )


	wait 0.1

	//--------------------------
	// Wait for player to press "USE"
	//--------------------------
	entity useDummy = CreatePropDynamic( DUMMY_MODEL, file.bt.GetOrigin(), file.bt.GetAngles(), 2 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	useDummy.SetOrigin( file.bt.GetOrigin() )
	useDummy.SetUsable()
	useDummy.SetUsableRadius( 200 )
	//useDummy.SetUsableFOVByDegrees( 50 )
	useDummy.Hide()
	useDummy.SetUsableByGroup( "pilot" )
	useDummy.SetUsePrompts( "#TIMESHIFT_HINT_GIVE_HELMET" , "#TIMESHIFT_HINT_GIVE_HELMET_PC" )

	entity playerActivator
	while( true )
	{
		playerActivator = expect entity( useDummy.WaitSignal( "OnPlayerUse" ).player )
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() )
			break
	}
	useDummy.UnsetUsable()
	useDummy.Destroy()

	FlagSet( "PlayerGivesHelmet" )
	CheckPoint()
	Objective_Clear()
	//--------------------------
	// Player hands helmet to BT
	//--------------------------

	FirstPersonSequenceStruct sequence
	//sequence.blendTime = 0.0
	sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_timeshift_hologram_sequence_start"
	sequence.thirdPersonAnim = "pt_timeshift_hologram_sequence_start"
	sequence.viewConeFunction = ViewConeTight

	playerActivator.DisableWeaponWithSlowHolster()
	playerActivator.ContextAction_SetBusy()
	thread FirstPersonSequence( sequence, playerActivator, mover )
	float animLength = playerActivator.GetSequenceDuration( "pt_timeshift_hologram_sequence_start" )
	delaythread ( animLength ) PlayerResetAfterSequence( playerActivator )
	//thread PlayAnimTeleport( sarahHologram, "sa_timeshift_hologram_sequence_start", mover, "ref" )
	thread PlayAnimTeleport( helmet, "helmet_timeshift_hologram_seq_start", mover, "ref" )
	helmet.Show()
	thread HelmetFx( helmet )
	waitthread PlayAnimTeleport( bt, "bt_timeshift_hologram_sequence_start", mover, "ref" )

	//--------------------------
	// BT and Sarah hologram
	//--------------------------
	FlagSet( "BTStartsHologram" )
	thread PlayAnim( bt, "bt_timeshift_hologram_sequence_idle", mover, "ref" )
	thread PlayAnim( helmet, "helmet_timeshift_hologram_seq_idle", mover, "ref" )
	thread PlayAnim( helmet, "helmet_timeshift_hologram_seq_idle", mover, "ref" )

	wait 3
	sarahHologram.Show()
	andersonHologram.Show()

	int attachIndex = andersonHologram.LookupAttachment( "CHESTFOCUS" )
	StartParticleEffectOnEntity( andersonHologram, GetParticleSystemIndex( FX_HOLOGRAM_HEX_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	StartParticleEffectOnEntity( andersonHologram, GetParticleSystemIndex( FX_HOLOGRAM_FLASH_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )

	attachIndex = sarahHologram.LookupAttachment( "CHESTFOCUS" )
	StartParticleEffectOnEntity( sarahHologram, GetParticleSystemIndex( FX_HOLOGRAM_HEX_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	StartParticleEffectOnEntity( andersonHologram, GetParticleSystemIndex( FX_HOLOGRAM_FLASH_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )

	EmitSoundOnEntity( sarahHologram, "PathHologram_Materialized_3P" )
	EmitSoundOnEntity( sarahHologram, "PathHologram_Sustain_Loop_3P" )


	thread PlayAnimTeleport( andersonHologram, "anderson_holo_scene", mover, "ref" )
	waitthread PlayAnimTeleport( sarahHologram, "sarah_holo_scene", mover, "ref" )

	attachIndex = andersonHologram.LookupAttachment( "CHESTFOCUS" )
	vector andersonEndPos = andersonHologram.GetAttachmentOrigin( attachIndex )

	attachIndex = sarahHologram.LookupAttachment( "CHESTFOCUS" )
	vector sarahEndPos = sarahHologram.GetAttachmentOrigin( attachIndex )

	EmitSoundAtPosition( TEAM_UNASSIGNED, andersonEndPos, "PathHologram_Materialized_3P" )


	PlayFX( FX_HOLOGRAM_FLASH_EFFECT, andersonEndPos )
	PlayFX( FX_HOLOGRAM_FLASH_EFFECT, sarahEndPos )


	FlagSet( "DialogueHologramSequenceFinished" )

	sarahHologram.Destroy()
	andersonHologram.Destroy()

	thread HelmetHologramThink( bt, helmet )
	//thread PlayAnim( sarahHologram, "sa_timeshift_hologram_sequence_end", mover, "ref" )
	thread PlayAnim( helmet, "helmet_timeshift_hologram_seq_end", mover, "ref" )
	waitthread PlayAnim( bt, "bt_timeshift_hologram_sequence_end", mover, "ref" )
	thread PlayAnimTeleport( bt, "bt_timeshift_campus_idle", node )


	FlagSet( "HologramSequenceOver" )

	FlagWait( "PostHologramDialoguePartyOver" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftDeviceHologramThink( entity timeshiftDeviceHologram, entity andersonHologram )
{
	timeshiftDeviceHologram.SetParent( andersonHologram, "KNIFE", false )

	andersonHologram.WaitSignal( "ShowHoloTimeshiftDevice" )

	//DebugDrawSphere( timeshiftDeviceHologram.GetOrigin(), 25.0, 255, 200, 0, true, 999.0 )
	timeshiftDeviceHologram.Show()

	andersonHologram.WaitSignal( "HideHoloTimeshiftDevice" )

	timeshiftDeviceHologram.Hide()

	//TODO: show bodygroup for device

}
/////////////////////////////////////////////////////////////////////////////////////////

void function HelmetHologramThink( entity bt, entity helmet )
{
	bt.WaitSignal( "crush_helmet" )
	helmet.Destroy()

}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicHologram( entity player )
{
	FlagWait( "BTStartsHologram" )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_08_andersonlog01" )
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
void function HelmetFx( entity helmet )
{
	//FX_HELMET_SPARK
	helmet.EndSignal( "OnDestroy" )

	helmet.SetMaxHealth( 9999 )
	helmet.SetHealth( 9999 )

	entity fx

	int attach_id = helmet.LookupAttachment( "HEAD_FRONT" )
	vector helmetOrigin = helmet.GetAttachmentOrigin( attach_id )

	while( true )
	{
		wait RandomFloatRange( 0.5, 0.6 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_LEFT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}
		wait RandomFloatRange( 0.3, 0.4 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )

		wait RandomFloatRange( 0.5, 0.6 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_RIGHT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}

		wait RandomFloatRange( 0.5, 0.6 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )



		wait RandomFloatRange( 0.01, 0.02 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_FRONT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}


		wait RandomFloatRange( 0.01, 0.02 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )

		wait RandomFloatRange( 0.01, 0.02 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_LEFT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}


		wait RandomFloatRange( 0.02, 0.03 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )


		wait RandomFloatRange( 1, 1.1 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_RIGHT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}

		wait RandomFloatRange( 0.2, 0.3 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )


		wait RandomFloatRange( 0.2, 0.3 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_FRONT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}


		wait RandomFloatRange( 0.01, 0.02 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )

		wait RandomFloatRange( 0.01, 0.02 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_LEFT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}

		wait RandomFloatRange( 0.01, 0.02 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )

		wait RandomFloatRange( 0.01, 0.02 )
		SetTeam( helmet, TEAM_MILITIA )
		if ( !Flag( "PlayerGivesHelmet" ) )
			fx = PlayFXOnEntity( FX_DLIGHT_HELMET, helmet, "HEAD_FRONT" )
		if ( Flag( "PlaySparksOnHelmet" ) )
		{
			PlayFXOnEntity( FX_HELMET_SPARK, helmet, "HEAD_RIGHT" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, helmetOrigin, SOUND_HELMET_SPARK )
		}


		wait RandomFloatRange( 0.02, 0.03 )
		SetTeam( helmet, TEAM_UNASSIGNED )
		if ( IsValid( fx ) )
			EntFireByHandle( fx, "Stop", "", 0, null, null )
		//StopFX( fx )
	}

}

void function DialogueGiveHelmetNag( entity player )
{
	player.EndSignal( "OnDeath" )
	file.bt.EndSignal( "OnDeath" )

	FlagWait( "player_near_prowlers_attacking_bt" )

	if ( Flag( "PlayerGivesHelmet" ) )
		return

	FlagEnd( "PlayerGivesHelmet" )

	FlagWait( "HelmetConversationDone" )

	wait 1

	//don't bother playing nag if player is close enough to trigger sequence...dialogue will overlap
	while ( PlayerInRange( player.GetOrigin(), file.bt.GetOrigin(), 512 ) )
		wait 0.25


	//BT	Pilot, if you hand me Anderson's helmet, I will analyze it.
	waitthread PlayBTDialogue( "diag_sp_anderson_TS171_14a_01_mcor_bt" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueHologramSequence( entity player )
{
	FlagWait( "PlayerGivesHelmet" )

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	wait 2

	// BT	With the death of Anderson, command of Special Operation 2-1-7 now transfers to you.
	waitthread PlayBTDialogue( "diag_sp_anderson_TS171_15_01_mcor_bt" )

	// BT	Congratulations on your field promotion, Pilot Cooper.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_15a_01_mcor_bt" )

	// BT	The following is Anderson's mission briefing from Commander Sarah Briggs of the Militia SRS.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_15_01_mcor_bt" )

	FlagWait( "BTStartsHologram" )

	FlagWait( "DialogueHologramSequenceFinished" )

	wait 1

	//BT: Pilot, the data Major Anderson collected appears to be damaged and incomplete.
	//We are duty-bound to uphold and fulfill Special Operation 217. Recommend we locate Anderson's wrist mounted device before proceeding.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_16_01_mcor_bt" )

	//Player	Option A 	I didn't see any device on Anderson.
	//BT	Option A 	It must be on the other half of his corpse.

	//Player 	Option B	What are we supposed to do?
	//Sarah	Option B 	Your mission is to find out what Blisk and his mercs are being paid to protect.
	//Anderson (BT: Pilot Cooper) will infiltrate using the wrist-mounted device we recovered during Operation Grizzly.
	//Report back as soon as you have something. Good luck.
	waitthread PlayerConversation( "TsHologramOver", player )

	FlagSet( "PostHologramDialoguePartyOver" )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function PlayerResetAfterSequence( entity player )
{
	if( !IsValid( player ) )
		return

	vector playerOrg = player.GetOrigin()
	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.EnableWeaponWithSlowDeploy()
	//player.SetOrigin( playerOrg )
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗██████╗ ██╗     ██╗███╗   ██╗███████╗
╚══███╔╝██║██╔══██╗██║     ██║████╗  ██║██╔════╝
  ███╔╝ ██║██████╔╝██║     ██║██╔██╗ ██║█████╗
 ███╔╝  ██║██╔═══╝ ██║     ██║██║╚██╗██║██╔══╝
███████╗██║██║     ███████╗██║██║ ╚████║███████╗
╚══════╝╚═╝╚═╝     ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗██████╗ ██╗     ██╗███╗   ██╗███████╗
╚══███╔╝██║██╔══██╗██║     ██║████╗  ██║██╔════╝
  ███╔╝ ██║██████╔╝██║     ██║██╔██╗ ██║█████╗
 ███╔╝  ██║██╔═══╝ ██║     ██║██║╚██╗██║██╔══╝
███████╗██║██║     ███████╗██║██║ ╚████║███████╗
╚══════╝╚═╝╚═╝     ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗██████╗ ██╗     ██╗███╗   ██╗███████╗
╚══███╔╝██║██╔══██╗██║     ██║████╗  ██║██╔════╝
  ███╔╝ ██║██████╔╝██║     ██║██╔██╗ ██║█████╗
 ███╔╝  ██║██╔═══╝ ██║     ██║██║╚██╗██║██╔══╝
███████╗██║██║     ███████╗██║██║ ╚████║███████╗
╚══════╝╚═╝╚═╝     ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗██████╗ ██╗     ██╗███╗   ██╗███████╗
╚══███╔╝██║██╔══██╗██║     ██║████╗  ██║██╔════╝
  ███╔╝ ██║██████╔╝██║     ██║██╔██╗ ██║█████╗
 ███╔╝  ██║██╔═══╝ ██║     ██║██║╚██╗██║██╔══╝
███████╗██║██║     ███████╗██║██║ ╚████║███████╗
╚══════╝╚═╝╚═╝     ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////

void function ZiplineStartPointSetup( entity player )
{
	entity node = GetEntByScriptName( "node_bt_hologram" )
	entity bt = file.bt
	thread PlayAnimTeleport( bt, "bt_timeshift_campus_idle", node )
	TeleportPlayers( GetEntByScriptName( "checkpointHologramSequence" ) )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function ZiplineSkipped( entity player )
{
	CleanupEnts( "flyer_zipline" )
	CleanupEnts( "zipline_bundle")
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AA_ZiplineThread( entity player )
{
	FlagWait( "PostHologramDialoguePartyOver" )

	thread ZiplineSequence( player )

	FlagWait( "ZiplineObjectiveGiven" )
	//-----------------------------------------
	// OBJECTIVE: explore the labs
	//-----------------------------------------
	vector objectivePos = GetEntByScriptName( "objectiveSecurityBreach" ).GetOrigin()
	TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_ZIPLINE", objectivePos )

	FlagWait( "hit_security_window_trigger" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function ZiplineSequence( entity player )
{
	if ( !IsValid( player ) )
		return
	player.EndSignal( "OnDeath" )
	entity node = GetEntByScriptName( "node_bt_hologram" )
	entity bt = file.bt
	bt.EndSignal( "OnDeath" )

	while( !IsValid( file.lamppost ) )
		wait 0.1
	entity lamppost = file.lamppost


	FlagWait( "PostHologramDialoguePartyOver" )
	CheckPoint()

	thread MusicZipline( player )
	thread DialogueZipline( player )
	//wait 5

	FlagSet( "BTstartingJavelinSequence" )

	//--------------
	// Javelin start
	//--------------
	thread PlayAnimTeleport( bt, "bt_timeshift_javelin_throw_start", node )
	waitthread PlayAnimTeleport( lamppost, "post_timeshift_javelin_throw_start", node )

	//---------------------------------
	// Javelin idle till player looks
	//---------------------------------
	thread SetFlagWhenPlayerLookingAtEnt( player, "PlayerLookingAtJavelinThrowIdle", bt )

	thread PlayAnimTeleport( bt, "bt_timeshift_javelin_throw_wait", node )
	thread PlayAnimTeleport( lamppost, "post_timeshift_javelin_throw_wait", node )
	thread SetFlagWhenPlayerWithinRangeOfEnt( player, bt, 256, "PlayerCloseEnoughToJavelinSequence" )
	FlagWaitAny( "PlayerLookingAtJavelinThrowIdle", "PlayerCloseEnoughToJavelinSequence" )

	delaythread ( 2 ) DeleteZiplineBundle()
	//---------------------------------
	// Javelin throw, remove blocker, etc
	//---------------------------------
	RemoveBlocker( "security_fastball_blocker" )
	thread ZiplineWiggle( bt, lamppost )
	//float animLength = bt.GetSequenceDuration( "bt_timeshift_javelin_throw_end" )

	FlagSetDelayed( "BTthrowsJavelin", 4.5 )
	thread PlayAnimTeleport( lamppost, "post_timeshift_javelin_throw_end", node )
	waitthread PlayAnimTeleport( bt, "bt_timeshift_javelin_throw_end", node )


	//--------------------------------------------
	// Javelin done. BT turns and idles forever
	//--------------------------------------------
	//wait animLength
	bt.AssaultPoint( bt.GetOrigin() )

	thread PlayAnimTeleport( bt, "bt_timeshift_javelin_scan_idle", node )

}

void function DeleteZiplineBundle()
{
	entity zipline_bundle = GetEntByScriptName( "zipline_bundle" )
	zipline_bundle.Destroy()
}
/////////////////////////////////////////////////////////////////////////////////////////

void function ZiplineWiggle( entity bt, entity lamppost)
{
	entity ziplineStartEnt = GetEntByScriptName( "ziplineStart" )



	bt.WaitSignal( "javelin_start_throw" )

	//FlagSet( "ThrowingJavelin" )


	vector startPos = ziplineStartEnt.GetOrigin()
	vector endPos = GetEntByScriptName( "ziplineEnd" ).GetOrigin()

	// wiggle the rope as it moves
	float len = Distance( startPos, endPos )
	float movespeed = 3000
	//float movetime = len / movespeed
	float movetime = 2
	entity wigglePoint = file.ziplineEnts.rope_start
	float wiggleMagnitude = 0.05
	float wiggleSpeed = 3.0
	float wiggleLengthFrac = 1.2  // after rope reaches this fraction of the total length, stop wiggling
	// RopeWiggle( maxlen, wiggleMagnitude, wiggleSpeed, duration, fadeDuration )
	float fadeDuration = 2


	// Makes the rope wiggle, straightening as it reaches a max length or max time,
	//to simulate fast motion.
	//Wiggle fades as length reaches maxlen and within fadeDuration seconds of duration. Magnitude scales with rope length.
							//maxlen, 				magnitude, 			speed, 			duration, 					fadeDuration.
	wigglePoint.RopeWiggle( len * wiggleLengthFrac, wiggleMagnitude, 	wiggleSpeed, 	movetime * wiggleLengthFrac, fadeDuration )
	//wigglePoint.SetParent( lamppost, "ATTACH_POINT" )


}

/////////////////////////////////////////////////////////////////////////////////////////
void function MusicZipline( entity player )
{

	while( !player.IsZiplining() )
		wait 0.1

	StopMusic()
	PlayMusic( "music_timeshift_09_onzipline" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueZipline( entity player )
{
	FlagWait( "BTstartingJavelinSequence" )

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/
	wait 1

	//BT	I detect a breach in the Security Services building. I will provide access.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_24_01_mcor_bt" )

	wait 2
	//FlagWait( "PlayerLookingAtJavelinThrowIdle" )

	// BT	I will remain here and scan the ringed structure while you investigate the facility for intel and the missing device.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_26_01_mcor_bt" )


	FlagWait( "BTthrowsJavelin" )
	FlagSetDelayed( "ZiplineObjectiveGiven", 5 )

	if ( Flag( "hit_security_window_trigger" ) )
		return

	waitthread PlayerConversationStopOnFlagImmediate( "TsZipline", player, "player_entered_security_services_pristine" )

	//Player	Option A 	There's gotta be an easier way, BT.	diag_sp_overgrown_TS162_01_01_mcor_player
	//BT	Option A 	I am still working on it, Pilot.	diag_sp_overgrown_TS162_02_01_mcor_bt

	//Player 	Option B	Nice. Maybe next time you can throw me. 	diag_sp_overgrown_TS162_03_01_mcor_player
	//BT	Option B 	Noted.	diag_sp_overgrown_TS162_04_01_mcor_bt



	string nagAlias
	int nagLines = 4
	int nextNagNumber = 1
	vector objectivePos = GetEntByScriptName( "objectiveSecurityBreach" ).GetOrigin()

	while( !Flag( "hit_security_window_trigger" ) )
	{
		wait( RandomFloatRange( 35, 45 ) )

		if ( player.IsZiplining() )
			continue

		if ( IsAudioLogPlaying( player ) )
			continue

		if ( Flag( "hit_security_window_trigger" ) )
			break

		if ( nextNagNumber == 1 )
		{
			// BT	The breach in the security services building is now accessible. Recommend you start your search for the device there while I continue scanning the ringed structure here.
			nagAlias = "diag_sp_overgrown_TS161_25_01_mcor_bt"
		}
		else if ( nextNagNumber == 2 )
		{
			// BT	Advisory: Use the zipline to access the upper section of the Security Services building. I will remain here until you return.
			nagAlias = "diag_sp_overgrown_TS161_27_01_mcor_bt"
		}
		else if ( nextNagNumber == 3 )
		{
			// BT	I suspect the ringed structure is somehow related to the devastation here. Further analysis is required. Recommend you locate Anderson's wrist-mounted device in the meantime.
			nagAlias = "diag_sp_overgrown_TS161_28_01_mcor_bt"
		}
		else if ( nextNagNumber == 4 )
		{
			// BT	Finding Anderson's wrist mounted device should be our top priority. I suggest you navigate to the breach in Security Services to continue the search.
			nagAlias = "diag_sp_overgrown_TS161_29b_01_mcor_bt"

		}

		waitthread PlayBTDialogue( nagAlias )
		Objective_Remind()
		//Objective_Clear()
		//TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )
		nextNagNumber++
		if ( nextNagNumber > 4 )
			nextNagNumber = 1

	}


}


/////////////////////////////////////////////////////////////////////////////////////////
void function ZiplineLamppostSetup()
{
	wait 0.2

	if ( Flag( "player_back_in_amenities_lobby" ) )
		return

	entity lamppostNode = GetEntByScriptName( "node_bt_hologram" )
	file.lamppost = CreatePropDynamic( LAMPPOST_MODEL, lamppostNode.GetOrigin(), lamppostNode.GetAngles(), 0 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	Assert( IsValid( file.lamppost ) )
	thread PlayAnimTeleport( file.lamppost, "post_timeshift_javelin_throw_idle", lamppostNode )

	thread ZiplineSetupAndThink()
}

/////////////////////////////////////////////////////////////////////////////////////////
void function ZiplineSetupAndThink()
{
	entity lamppost = file.lamppost
	entity ziplineStartEnt = GetEntByScriptName( "ziplineStart" )
	int attachID = lamppost.LookupAttachment( "ATTACH_POINT" )
	vector attachOrigin = lamppost.GetAttachmentOrigin( attachID )

	string tnameStart 	= UniqueString( "rope_startpoint" )
	string tnameEnd 	= UniqueString( "rope_endpoint" )

	// create them both at startPos because one of the points will move to the target
	entity rope_end 	= CreateZiplineEnd( attachOrigin, tnameEnd )
	entity rope_start 	= CreateZiplineStart( ziplineStartEnt.GetOrigin(), tnameStart, tnameEnd )
	rope_end.SetParent( lamppost, "ATTACH_POINT", false )
	rope_start.Zipline_Disable()

	table <entity> ropeEnts = { rope_start = rope_start, rope_end = rope_end }
	file.ziplineEnts = ropeEnts

	FlagWait( "BTthrowsJavelin" )
	rope_start.Zipline_Enable()
}




entity function CreateZiplineStart( vector createPos, string tnameStart, string tnameEnd )
{
	entity rope_start = CreateEntity( "move_rope" )
	SetTargetName( rope_start, tnameStart )
	rope_start.kv.NextKey = tnameEnd
	rope_start.kv.MoveSpeed = 128 // default = 64
	rope_start.kv.Slack = 5
	rope_start.kv.Subdiv = "0"
	rope_start.kv.Width = "2"
	rope_start.kv.Type = "0"
	rope_start.kv.TextureScale = "1"
	rope_start.kv.RopeMaterial = "cable/zipline.vmt"
	rope_start.kv.PositionInterpolator = 2
	rope_start.kv.Zipline = "1"
	rope_start.kv.ZiplineAutoDetachDistance = "200"
	rope_start.kv.ZiplineSagEnable = "1"
	rope_start.kv.ZiplineSagHeight = "125"
	rope_start.kv.ZiplineAutoDetachDistance = "250"
	rope_start.SetOrigin( createPos )

	DispatchSpawn( rope_start )

	return rope_start
}

entity function CreateZiplineEnd( vector createPos, string tname )
{
	entity rope_end = CreateEntity( "keyframe_rope" )
	SetTargetName( rope_end, tname )
	rope_end.SetOrigin( createPos )

	DispatchSpawn( rope_end )

	return rope_end
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗███████╗
██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝██╔════╝
███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗  ███████╗
╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝  ╚════██║
███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗███████║
╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗███████╗
██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝██╔════╝
███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗  ███████╗
╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝  ╚════██║
███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗███████║
╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗███████╗
██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝██╔════╝
███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗  ███████╗
╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝  ╚════██║
███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗███████║
╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗            ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗███████╗
██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝            ██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝██╔════╝
███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝             ███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗  ███████╗
╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝              ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝  ╚════██║
███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║               ███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗███████║
╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝               ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function SecurityStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointSecurity" ) )
	vector objectivePos = GetEntByScriptName( "objective_bunker_breadcrumb00" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )

	TriggerSilentCheckPoint( GetEntByScriptName( "checkpointSecurity" ).GetOrigin(), true )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function SecuritySkipped( entity player )
{
	CleanupEnts( "security_dude" )
	RestoreBlocker( "security_window_blockers_overgrown" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AA_SecurityThread( entity player )
{
	FlagWait( "hit_security_window_trigger" )

	thread MusicSecurity( player )
	CheckPoint()

	RestoreBlocker( "security_window_blockers_overgrown" )

	thread DialogueSecurityServices( player )

	thread ObjectiveThreadSecurity( player )

	//----------------------------------------------------------------------
	// Player dropped in....swap to past...Stalkers spawn and intimidate
	//----------------------------------------------------------------------
	FlagWait( "player_entered_security_services_overgrown" )

	wait 3
	thread QuickSkit( player, GetEntByScriptName( "node_security_dude" ), "player_entered_security_services_pristine" )
	wait 1.25

	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )
	FlagWait( "player_entered_security_services_pristine" )

	wait 0.25

	//-------------------------------
	// Pristine wall Spectres in past
	//-------------------------------
	array< entity > propSpawners = GetEntArrayByScriptNameInInstance( "spectre_door_spawner", "spectre_spawner_security_pristine" )
	float delayMin = 0.0
	float delayMax = 0.2
	int maxToSpawn = 16
	string flagToAbort = "SecurityStalkerRackSequenceFinished"
	bool requiresLookAt = false
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "", delayMin, delayMax, "", requiresLookAt )

	FlagSet( "SecurityServicesStalkersSpawning" )
	wait 5.3
	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )

	FlagSet( "SecurityStalkerRackSequenceFinished" )

	wait 2

	CheckPoint()

	CleanupEnts( "security_dude" )



	wait 2

	//-----------------------------------------
	// Security Spectres Wake up
	//-----------------------------------------
	FlagSet( "SecuritySpectresWakeUp" )


	//-----------------------------------------
	// Security Spectres pry open door
	//-----------------------------------------
	wait 5

	FlagSet( "SecurityZombieVentsSpawn" )

	//-------------------------------
	// Token overgrown wall Spectres
	//-------------------------------
	propSpawners = GetEntArrayByScriptNameInInstance( "spectre_door_spawner", "spectre_spawner_security_overgrown" )
	delayMin = 0.4
	delayMax = 2
	maxToSpawn = 2
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, "", "", delayMin, delayMax )
																											//lookAtEnt
	thread QuickSkit( player, GetEntByScriptName( "node_security_door_skit" ), 	"player_near_security_door", GetEntByScriptName( "look_ent_security_door" ) )

	//---------------------------------------------------------------
	// Player got through security door, quick scripted Timeflip
	//---------------------------------------------------------------
	FlagWait( "player_entered_security_fallout_door" )

	FlagWait( "player_security_barracks_corridor" )

	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	FlagSet( "SecurityTimeshiftPopToPast1" )

	wait 7

	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )

	FlagWait( "player_security_to_bunker_skybridge_approach" )


}


void function ObjectiveThreadSecurity( entity player )
{
	vector objectivePos = GetEntByScriptName( "objective_bunker_breadcrumb00" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )

	FlagWait( "player_entered_security_fallout_door" )

	objectivePos = GetEntByScriptName( "objective_bunker_breadcrumb00a" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	FlagWait( "top_of_security_stairs" )
	objectivePos = GetEntByScriptName( "objective_bunker_breadcrumb01" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )
}


/////////////////////////////////////////////////////////////////////////////////////////
void function MusicSecurity( entity player )
{
	//FlagWait( "player_entered_security_services_overgrown" )
	FlagWait( "SecurityServicesStalkersSpawning" )
	wait 0.25

	StopMusic()
	PlayMusic( "music_timeshift_10_hitthefloor" )

	FlagWait( "player_entered_security_fallout_door" )

	StopMusic()
	PlayMusic( "music_timeshift_11_secondwave" )

	FlagWait( "SecurityTimeshiftPopToPast1" )

	StopMusic()
	PlayMusic( "music_timeshift_12_flashback07" )
}



/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueSecurityServices( entity player )
{
	FlagWait( "player_entered_security_services_pristine" )

	wait 0.25

	entity loudspeakerEntPristine = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/


	//IMC Security 1 PA	Unauthorized personnel detected. Activate automated security.
	thread PlayDialogue( "diag_sp_security_TS181_05_01_imc_facilityPA", loudspeakerEntPristine )


	FlagWait( "SecuritySpectresWakeUp" )

	wait 3

	entity loudspeakerEntOvergrown = CreateBestLoudspeakerEnt( player, TIMEZONE_NIGHT )


	WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )


	loudspeakerEntPristine.SetOrigin( player.GetOrigin() + Vector( 0, 0, 72 ) )

	//Grunt Radio (Security Booth)	Unauthorized personnel breach at security services. Intruder may have advanced cloaking package.
	waitthread PlayDialogue( "diag_sp_security_TS181_07_01_imc_grunt1", loudspeakerEntPristine )

	//IMC Security 2 (Radio)	Copy that, laser meshes coming online. Sending a team to investigate.
	thread PlayTimeShiftDialogue( player, loudspeakerEntPristine, "diag_sp_security_TS181_08_01_imc_grunt2" )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function SpectreSecurityPristineThink( npc )
{
	EndSignal( npc, "OnDeath" )
	npc.kv.allowShoot = 0


	while( true )
	{
		wait( RandomFloatRange( 4, 6.5 ) )
		npc.kv.allowShoot = 1
		wait( RandomFloatRange( 3, 5 ) )
		npc.kv.allowShoot = 0
	}
}


/////////////////////////////////////////////////////////////////////////////////////////
void function SpectreSecurityOvergrownThink( npc )
{
	EndSignal( npc, "OnDeath" )
	npc.kv.allowShoot = 0

	while( true )
	{
		wait( RandomFloatRange( 4, 6.5 ) )
		npc.kv.allowShoot = 1
		wait( RandomFloatRange( 3, 5 ) )
		npc.kv.allowShoot = 0
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function StalkerAsleepThink( entity propDynamic )
{
	string animIdlePoweredDown
	string animGetup
	string animMove
	string animMoveIdle
	bool isSecurityStalker = false
	entity node = propDynamic.GetLinkEnt()
	Assert( IsValid( node ) )
	vector origin = node.GetOrigin()
	vector angles = node.GetAngles()
	string animName = node.GetScriptName()

	if ( propDynamic.GetScriptName() == "stalker_asleep_security" )
	{
		isSecurityStalker = true
		propDynamic.SetSkin( 1 ) //mossy
		SetTeam( propDynamic, TEAM_UNASSIGNED )
	}

	switch ( animName )
	{
		case "st_awakening_prone":
			animIdlePoweredDown = "st_awakening_prone_start"
			animGetup = "st_awakening_prone"
			//animMove = "st_damaged_walk_stumble"
			//animMoveIdle = "sp_zombie_walk_idle"
			break
		case "st_awakening_kneel_A":
			animIdlePoweredDown = "st_awakening_kneel_A_start"
			animGetup = "st_awakening_kneel_A"
			//animMove = "st_damaged_walk_stumble"
			//animMoveIdle = "sp_zombie_walk_idle"
			break
		case "st_awakening_kneel_B":
			animIdlePoweredDown = "st_awakening_kneel_B_start"
			animGetup = "st_awakening_kneel_B"
			//animMove = "st_damaged_walk_stumble"
			//animMoveIdle = "sp_zombie_walk_idle"
			break
		case "st_awakening_prone":
			animIdlePoweredDown = "st_awakening_prone_start"
			animGetup = "st_awakening_prone"
			//animMove = "st_damaged_walk_stumble"
			//animMoveIdle = "sp_zombie_walk_idle"
			break
		case "st_awakening_wall_lean":
			animIdlePoweredDown = "st_awakening_wall_lean_start"
			animGetup = "st_awakening_wall_lean"
			//animMove = "st_damaged_walk_stumble"
			//animMoveIdle = "sp_zombie_walk_idle"
			break
		case "st_awakening_wall_lean_fall":
			animIdlePoweredDown = "st_awakening_wall_lean_fall_start"
			animGetup = "st_awakening_wall_lean_fall"
			//animMove = "st_damaged_walk_stumble"
			//animMoveIdle = "sp_zombie_walk_idle"
			break
		default:
			Assert( 0, "Unhandled script_name " + animName + " for node: " + node.GetOrigin() )
	}
	thread PlayAnimTeleport( propDynamic, animIdlePoweredDown, origin, angles )

	if ( isSecurityStalker )
		FlagWait( "SecuritySpectresWakeUp" )

	wait ( RandomFloatRange( 0.5, 2 ) )
	entity player

	while( true )
	{
		wait 0.25
		array<entity> players = GetPlayerArray()
		if ( players.len() <= 0 )
			continue

		player = players[0]
		if ( !PlayerInRange( player.GetOrigin(), origin, 512 ) )
			continue

		break
	}

														//doTrace, 	degrees, 	minDist
	waitthread WaitTillLookingAt( player, propDynamic, true, 		30, 		1024 )

	entity spectre = CreateZombieStalkerMossy( TEAM_IMC, origin, angles )
	DispatchSpawn( spectre )

	spectre.EndSignal( "OnDestroy" )

	//spectre.MakeInvisible()
	thread PlayAnimTeleport( spectre, animIdlePoweredDown, origin, angles )
	TakeAllWeapons( spectre )
	spectre.EndSignal( "OnDeath" )
	propDynamic.Destroy()
	//spectre.MakeVisible()
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "diag_zombiestalker_generic" )
	spectre.EnableNPCFlag( NPC_IGNORE_ALL )
	//spectre.SetNoTarget( true )

	//EnableLeeching( spectre )
	//spectre.SetAllowMelee( false )
	//MakeSpectreOwnedByPlayer( spectre, player )
	//spectre.EnableNPCFlag( NPC_IGNORE_ALL )
	//spectre.SetNoTarget( true )
	//spectre.SetOwner( player )
	//spectre.SetOwnerPlayer( player )
	//spectre.SetBossPlayer( player )
	//SetTeam( spectre, TEAM_IMC )

	thread SleepingSpectreFX( spectre, "OnLeeched" )
	waitthread PlayAnimTeleport( spectre, animGetup, origin, angles )

	//spectre.SetIdleAnim( animMoveIdle )
	//spectre.SetMoveAnim( animMove )

	if ( isSecurityStalker )
	{
		wait 3
		//Only make a certain amount aggro...otherwise player is overwhelmed
		if ( file.numberSecurityZombiesFollowing > 2 )
			return
		file.numberSecurityZombiesFollowing++
	}

	spectre.DisableNPCFlag( NPC_IGNORE_ALL )

	if ( !isSecurityStalker )
	{
		//kill when player gets out of range
		while( true )
		{
			wait 0.25
			array<entity> players = GetPlayerArray()
			if ( players.len() <= 0 )
				continue

			player = players[0]
			if ( PlayerInRange( player.GetOrigin(), origin, 1024 ) )
				continue

			break
		}

		if ( IsValid( spectre ) )
			spectre.TakeDamage( spectre.GetMaxHealth() + 1, null, null, { damageSourceId=damagedef_suicide } )
	}

}


/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔════╝██║ ██╔╝╚██╗ ██╔╝██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
███████╗█████╔╝  ╚████╔╝ ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
╚════██║██╔═██╗   ╚██╔╝  ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
███████║██║  ██╗   ██║   ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔════╝██║ ██╔╝╚██╗ ██╔╝██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
███████╗█████╔╝  ╚████╔╝ ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
╚════██║██╔═██╗   ╚██╔╝  ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
███████║██║  ██╗   ██║   ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔════╝██║ ██╔╝╚██╗ ██╔╝██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
███████╗█████╔╝  ╚████╔╝ ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
╚════██║██╔═██╗   ╚██╔╝  ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
███████║██║  ██╗   ██║   ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function SkybridgeStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointSkybridge" ) )
	vector objectivePos = GetEntByScriptName( "objective_time_device" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos, GetEntByScriptName( "objective_time_device" ) )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function SkybridgeSkipped( entity player )
{
	foreach( player in GetPlayerArray() )
		GiveTimeshiftAbility( player )
	FlagSet( "PlayerPickedUpTimeshiftDevice" )
}
/////////////////////////////////////////////////////////////////////////////////////////

void function AA_SkybridgeThread( entity player )
{
	FlagWait( "player_security_to_bunker_skybridge_approach" )

	thread MusicSkybridge( player )
	FlagSet( "open_skybridge_door_end_pristine" )
	FlagSet( "open_skybridge_door_end_overgrown" )

	SetGlobalForcedDialogueOnly( false )

	if ( GetBugReproNum() == 123 )
		thread SequenceProwlerSkybridge( player )

	CheckPoint()

	//GiveLowAmmo( player )
	//--------------------------
	// Approaching skybridge
	//--------------------------

	vector objectivePos = GetEntByScriptName( "objective_time_device" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	//thread SkybridgeSequence( player )

	wait 0.25

	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_DAY )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	FlagSet( "SecurityTimeshiftPopToPast2" )

	wait 1.5

	thread SwapTimelinesScriptedEveryone( player, TIMEZONE_NIGHT )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )

	thread CleanupAI( player, "trigger_indoor_area_security_services_pristine" )



	//-----------------------------------------
	// Cross the skybridge
	//-----------------------------------------
	FlagWait( "player_skybridge_1" )
	wait 0.2

	thread SwapTimelines( player, TIMEZONE_DAY )
	CreateAirShake( player.GetOrigin(), 10, 105, 0.5 )
	wait 0.75

	thread SwapTimelines( player, TIMEZONE_NIGHT )
	CreateAirShake( player.GetOrigin(), 10, 105, 0.5 )

	thread SkybridgeLoudspeaker( player )

	thread SkybridgeCrossingSequence( player )

	FlagWait( "player_security_to_bunker_skybridge_crossed" )

	thread CleanupAI( player, "trigger_indoor_area_security_services_overgrown" )

	FlagWait( "player_security_to_bunker_skybridge_end" )

	//ScreenFadeToBlack( player, 1.5, 5 )
	//wait 1.5
	//player.SetInvulnerable()
	//player.FreezeControlsOnServer()

	thread TransitionSpoke2()

	WaitForever() //never want to risk loading the next start point chunk since we are detouring to spoke 2 first
}

void function TransitionSpoke2()
{
	LevelTransitionStruct trans = SaveBoyleAudioLogs()
	//expect LevelTransitionStruct( trans )
	trans.timeshiftKilledLobbyMarvin = file.timeshiftKilledLobbyMarvin
	Coop_LoadMapFromStartPoint( "sp_timeshift_spoke02", "Timeshift Device", trans )
}

void function MusicSkybridge( entity player )
{

	FlagWait( "SecurityTimeshiftPopToPast2" )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_13_flashback08" )
}
//////////////////////////////////////////////////////////////////////////////////////
void function SequenceProwlerSkybridge( entity player )
{
	entity node = GetEntByScriptName( "node_prowler_skybridge" )


	entity spawner = GetEntByScriptName( "prowler_skybridge_scare" )
	entity prowler = spawner.SpawnEntity()
	DispatchSpawn( prowler )

	thread PlayAnimTeleport( prowler, "pr_timeshift_skywalk_jumpscare_idle", node )

	prowler.Hide()

	FlagWait( "player_security_to_bunker_skybridge_crossed" )

	prowler.Show()

	thread PlayAnim( prowler, "pr_timeshift_skywalk_jumpscare", node )

}
//////////////////////////////////////////////////////////////////////////////////////
void function SkybridgeLoudspeaker( entity player )
{
	FlagWait( "player_skybridge_near_crossing_overgrown" )

	wait 0.2

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//IMC Security 3 - PA	Attention. Security lockdown measures are being temporarily activated due to a minor security breach in your area. Thank you for your patience.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_security_TS181_09_01_imc_grunt3" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function SoldiersSkybridgeThink( npc )
{
	expect entity( npc )
	npc.EndSignal( "OnDeath" )
	while( !IsValid( npc.GetEnemy() ) )
		wait 0.1

	//npc.ForceCombat()

	FlagWait( "player_skybridge_1" )

	npc.Destroy()

}
/////////////////////////////////////////////////////////////////////////////////////////
void function SkybridgeCrossingSequence( entity player )
{

	entity triggerSkybridgeCrossing = GetEntByScriptName( "trig_crossing_skybridge_chasm_pristine" )

	FlagWait( "player_skybridge_near_crossing_overgrown" )
	FlagClear( "door_open_skybridge_pristine" )

	while( true )
	{
		//FlagWait( "player_skybridge_2" )
		FlagWait( "player_skybridge_near_crossing_overgrown" )

		thread SwapTimelines( player, TIMEZONE_DAY )
		CreateAirShake( player.GetOrigin(), 10, 105, 0.5 )
		wait 1
		while ( triggerSkybridgeCrossing.IsTouching( player ) )
			wait 0.1

		thread SwapTimelines( player, TIMEZONE_NIGHT )
		CreateAirShake( player.GetOrigin(), 10, 105, 0.5 )

		wait 2

		if ( Flag( "player_security_to_bunker_skybridge_crossed" ) )
			break
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗      ██████╗ ██████╗ ██████╗ ██╗   ██╗            ██████╗ ███████╗██████╗ ██╗   ██╗██╗  ██╗
██║     ██╔═══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝            ██╔══██╗██╔════╝██╔══██╗██║   ██║╚██╗██╔╝
██║     ██║   ██║██████╔╝██████╔╝ ╚████╔╝             ██████╔╝█████╗  ██║  ██║██║   ██║ ╚███╔╝
██║     ██║   ██║██╔══██╗██╔══██╗  ╚██╔╝              ██╔══██╗██╔══╝  ██║  ██║██║   ██║ ██╔██╗
███████╗╚██████╔╝██████╔╝██████╔╝   ██║               ██║  ██║███████╗██████╔╝╚██████╔╝██╔╝ ██╗
╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝    ╚═╝               ╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗      ██████╗ ██████╗ ██████╗ ██╗   ██╗            ██████╗ ███████╗██████╗ ██╗   ██╗██╗  ██╗
██║     ██╔═══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝            ██╔══██╗██╔════╝██╔══██╗██║   ██║╚██╗██╔╝
██║     ██║   ██║██████╔╝██████╔╝ ╚████╔╝             ██████╔╝█████╗  ██║  ██║██║   ██║ ╚███╔╝
██║     ██║   ██║██╔══██╗██╔══██╗  ╚██╔╝              ██╔══██╗██╔══╝  ██║  ██║██║   ██║ ██╔██╗
███████╗╚██████╔╝██████╔╝██████╔╝   ██║               ██║  ██║███████╗██████╔╝╚██████╔╝██╔╝ ██╗
╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝    ╚═╝               ╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗      ██████╗ ██████╗ ██████╗ ██╗   ██╗            ██████╗ ███████╗██████╗ ██╗   ██╗██╗  ██╗
██║     ██╔═══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝            ██╔══██╗██╔════╝██╔══██╗██║   ██║╚██╗██╔╝
██║     ██║   ██║██████╔╝██████╔╝ ╚████╔╝             ██████╔╝█████╗  ██║  ██║██║   ██║ ╚███╔╝
██║     ██║   ██║██╔══██╗██╔══██╗  ╚██╔╝              ██╔══██╗██╔══╝  ██║  ██║██║   ██║ ██╔██╗
███████╗╚██████╔╝██████╔╝██████╔╝   ██║               ██║  ██║███████╗██████╔╝╚██████╔╝██╔╝ ██╗
╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝    ╚═╝               ╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗      ██████╗ ██████╗ ██████╗ ██╗   ██╗            ██████╗ ███████╗██████╗ ██╗   ██╗██╗  ██╗
██║     ██╔═══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝            ██╔══██╗██╔════╝██╔══██╗██║   ██║╚██╗██╔╝
██║     ██║   ██║██████╔╝██████╔╝ ╚████╔╝             ██████╔╝█████╗  ██║  ██║██║   ██║ ╚███╔╝
██║     ██║   ██║██╔══██╗██╔══██╗  ╚██╔╝              ██╔══██╗██╔══╝  ██║  ██║██║   ██║ ██╔██╗
███████╗╚██████╔╝██████╔╝██████╔╝   ██║               ██║  ██║███████╗██████╔╝╚██████╔╝██╔╝ ██╗
╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝    ╚═╝               ╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////

void function LobbyReduxStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointLobbyReturn" ) )
	foreach( player in GetPlayerArray() )
	{
		Rodeo_Allow( player )
	}

	FlagSet( "door_open_amenities_lobby_return_pristine" )
	FlagSet( "player_back_in_amenities_lobby" )
	
	// TriggerSilentCheckPoint( GetEntByScriptName( "checkpointLobbyReturn" ).GetOrigin(), true )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function LobbyReduxSkipped( entity player )
{
	CleanupEnts( "hub_entities_start" )
	//thread TitanTimeshiftLoadout( player )
	FlagSet( "player_back_in_amenities_lobby" )
	FlagSet( "door_open_amenities_lobby_return_pristine" )
	FlagSet( "SpawnHubWeapons" )
	file.bt.Anim_Stop()
	Embark_Allow( player )
	ShowStuff( "core_model_pristine" )
	ShowStuff( "core_glow_model_pristine" )
	FlagSet( "play_core_effect_pristine" )
	FlagSet( "RingsShouldBeSpinning" )
	thread QuickSkit( player, GetEntByScriptName( "node_marvin_lobby_pristine" ) )
	thread DeleteUnnecessaryFlyers()
	FlagClear( "door_open_skybridge_overgrown" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AA_LobbyReduxThread( entity player )
{
	FlagWait( "player_back_in_amenities_lobby" )

	FlagClear( "door_open_skybridge_overgrown" )

	thread LevelTransitionSpoke2backToHub( player )

	thread DeleteUnnecessaryFlyers()
	CheckPoint_ForcedSilent()

	Rodeo_Allow( player )

	/*
	entity lightBlockerLobby = GetEntByScriptName( "light_blocker_door_lobby_return" )
	vector lightBlockerLobbyOrigin = lightBlockerLobby.GetOrigin()
	lightBlockerLobby.SetOrigin( lightBlockerLobbyOrigin + Vector( 0, 0, 128 ) )
	*/

	thread TimeshiftHint( player, TIMEZONE_NIGHT, "open_lobby_upper_door_main_pristine", "timeshift_hint_default", GetEntByScriptName( "player_near_lobby_redux_return_door_overgrown" ) )
	thread MusicLobbyRedux( player )

	foreach( entity p in GetPlayerArray() )
		GiveTimeshiftAbility( p )

	FlagSet( "RingsShouldBeSpinning" )

	ShowStuff( "core_model_pristine" )
	ShowStuff( "core_glow_model_pristine" )
	FlagSet( "play_core_effect_pristine" )

	CleanupEnts( "hub_entities_start" )

	//thread TitanTimeshiftLoadout( player )

	delaythread ( 1 ) QuickSkit( player, GetEntByScriptName( "node_marvin_lobby_pristine" ) )

	CheckPoint()

	file.bt.Anim_Stop()
	Embark_Allow( player )

	FlagClear( "open_door_lobby_main_overgrown" )

	vector objectivePos = GetBTObjectivePos()
	TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_RETURN", objectivePos, file.bt )

	FlagSet( "SpawnHubWeapons" )

	thread DialogueLobbyRedux( player )
	thread DialogueLobbyReduxPristine( player )


	CheckPoint()

	WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	FlagWait( "open_lobby_upper_door_main_pristine" )

	SetGlobalNetBool( "music14LoopPausable", true )

	FlagSet( "DisplayTheDamageHint" )
	delaythread ( 0.5 ) WaittillSomeDudesAreDead( "grunts_lobby_amenities_pristine", 4, "SomeLobbyDudesAreDead" )

	int difficulty = GetSpDifficulty()

	//------------------------------------------------------
	// token prowlers in present
	//-------------------------------------------------------
	array< entity > propSpawners = GetEntArrayByScriptName( "lobby_prowler_intro_spawnvents" )
	float delayMin = 4
	float delayMax = 6
	int maxToSpawn = 6

	string flagToAbort = "player_exited_spoke1"
	bool requiresLookAt = true

	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "AllLobbyReduxProwlersSpawned", delayMin, delayMax, "", requiresLookAt )

	//-------------------------------
	// Pristine wall Spectres in past
	//-------------------------------
	propSpawners = GetEntArrayByScriptNameInInstance( "spectre_door_spawner", "spectre_spawner_amenities_lobby_pristine" )
	delayMin = 3
	delayMax = 8

	if ( difficulty < DIFFICULTY_HARD )
		maxToSpawn = 3
	else
		maxToSpawn = 8

	flagToAbort = "player_exited_spoke1"
	requiresLookAt = true

	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "AllLobbyReduxPristineStalkersSpawned", delayMin, delayMax, "", requiresLookAt )

	wait 3

	//------------------------------------------------------
	// zombie spectres in the overgrown past
	//-------------------------------------------------------
	propSpawners = GetEntArrayByScriptNameInInstance( "spectre_door_spawner", "spectre_spawner_amenities_lobby_overgrown" )
	delayMin = 3
	delayMax = 8
	maxToSpawn = 10
	flagToAbort = "player_exited_spoke1"
	requiresLookAt = true

	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "AllLobbyReduxZombiesSpawned", delayMin, delayMax, "", requiresLookAt )



	FlagWait( "player_past_lobby_return_stairs" )
	FlagClear( "open_lobby_upper_door_main_pristine" )

	//------------------------
	// Player returns to hub
	//------------------------
	FlagWait( "player_exited_spoke1" )
	FlagClear( "DisplayTheDamageHint" )

}

void function LevelTransitionSpoke2backToHub( entity player )
{
	InitBoyleAudioLogs()

	LevelTransitionStruct ornull trans = GetLevelTransitionStruct()
	if ( trans == null )
		return

	expect LevelTransitionStruct( trans )

	if ( trans.timeshiftKilledLobbyMarvin )
		CleanupEnts( "marvin_lobby_overgrown" )

	if ( ( trans.timeshiftMostRecentTimeline == TIMEZONE_DAY ) && ( level.timeZone != TIMEZONE_DAY ) )
	{
		player.FreezeControlsOnServer()
		printl( "PLAYER USED TO BE IN PRISTINE" )

		waitthread SwapTimelines( player, TIMEZONE_DAY )

		player.UnfreezeControlsOnServer()
	}
}


/////////////////////////////////////////////////////////////////////////////////////////
void function MusicLobbyRedux( entity player )
{
	//After the level load, when the player hits PAST - Play music_timeshift_14_pastloop
	wait 1.5

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_30a_prefight" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_14_pastloop" )

	//When you kill the guard and trigger the dialogue "Got a shooter in the area" - Play music_timeshift_18_startelevatorfight
	FlagWaitAny( "KilledFirstLobbySoldier", "KilledSecondLobbySoldier" )

	StopMusic()
	PlayMusic( "music_timeshift_18_startelevatorfight" )

	if ( Flag( "player_exited_spoke1" ) )
		return

	FlagEnd( "player_exited_spoke1" )


	//-----------------------------------------------------------------------------------------------
	// Don't start playing different time period-specific tracks till the player starts time traveling
	//-----------------------------------------------------------------------------------------------
	if ( level.timeZone == TIMEZONE_NIGHT )
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	else
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )





	while( true )
	{
		if ( level.timeZone == TIMEZONE_NIGHT )
		{
			//----------------------
			// Enemies still alive TIMEZONE_NIGHT
			//----------------------
			if ( ( Flag( "enemies_inside_trigger_lobby_overgrown") )
				//|| ( !Flag( "AllLobbyReduxZombiesSpawned" ) )
				|| ( !Flag( "AllLobbyReduxProwlersSpawned" ) )
				)
			{
				//During the combat, if the player switches to PRESENT - Play music_timeshift_20_combatpresent
				//StopMusic()
				StopMusicTrack( "music_timeshift_18_startelevatorfight" )
				PlayMusicThatCantBeStopped( "music_timeshift_20_combatpresent" )
				//While in TIMEZONE_DAY, check to see when all are dead, so we can stop combat music
				while( level.timeZone == TIMEZONE_NIGHT )
				{
					wait 0.1
					if ( ( !Flag( "enemies_inside_trigger_lobby_overgrown" ) )
						//&& ( Flag( "AllLobbyReduxZombiesSpawned" ) )
						&& ( Flag( "AllLobbyReduxProwlersSpawned" ) )
						)
						break
				}
			}

			//------------------------------------------------
			// If all enemies spawned and dead in TIMEZONE_NIGHT, play the "done" track
			//------------------------------------------------
			if ( ( !Flag( "enemies_inside_trigger_lobby_overgrown") )
				//&& ( Flag( "AllLobbyReduxZombiesSpawned" ) )
				&& ( Flag( "AllLobbyReduxProwlersSpawned" ) )
				)
			{
				//Each time the player switches to the PRESENT where there are no more enemies - Play music_timeshift_21_combatpresentdone
				//StopMusic()
				if ( IsValid( player ) )
					StopSoundOnEntity( player, "music_timeshift_21_combatpresentdone" )
				PlayMusicThatCantBeStopped( "music_timeshift_21_combatpresentdone" )
			}


			waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
		}
		else //TIMEZONE_DAY
		{
			//----------------------
			// Enemies still alive TIMEZONE_DAY
			//----------------------
			if ( ( Flag( "enemies_inside_trigger_lobby_pristine" ) )
				|| ( !Flag( "AllLobbyReduxPristineStalkersSpawned" ) )
				)
			{
				//During the combat, if the player switches to PAST - Play music_timeshift_19_combatpast
				//StopMusic()
				PlayMusic( "music_timeshift_19_combatpast" )

				//While in TIMEZONE_DAY, check to see when all are dead, so we can stop combat music
				while( level.timeZone == TIMEZONE_DAY )
				{
					wait 0.1
					if ( ( !Flag( "enemies_inside_trigger_lobby_pristine" ) )
						&& ( Flag( "AllLobbyReduxPristineStalkersSpawned" ) )
						)
						break
				}

			}

			//------------------------------------------------
			//If all enemies dead in TIMEZONE_DAY, play the "done" track
			//------------------------------------------------
			if ( ( !Flag( "enemies_inside_trigger_lobby_pristine" ) )
				&& ( Flag( "AllLobbyReduxPristineStalkersSpawned" ) )
				)
			{
				//Each time the player switches to the PAST where there are no more enemies - Play music_timeshift_21a_combatpastdone
				//StopMusic()
				PlayMusic( "music_timeshift_21a_combatpastdone" )
			}

			waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
		}
	}


}

/////////////////////////////////////////////////////////////////////////////////////////
void function ProwlersHubReturnThink( npc )
{
	npc.EndSignal( "OnDeath" )
	FlagWait( "player_exited_spoke1" )
	npc.SetMaxHealth( 10 )
	npc.SetHealth( 10 )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLobbyRedux( entity player )
{

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	wait 0.5
	//BT	Uphold the mission: Pilot, I recommend you meet me at the rings in order to scan the Sculptor Core's energy signature.
	waitthread PlayBTDialogue( "diag_sp_targeting_TS231_13_01_mcor_bt" )


}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLobbyReduxPristine( entity player )
{

	FlagWait( "FirstSpectreDeployedLobbyReduxPristine" )
	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	wait 1.5

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	//hammondPA	(Ding) Hammond automated security personnel are being deployed at your location. Please remain calm and present Hammond identification credentials if asked. Thank you.
	//waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_ambAnnc_TS107_06_01_ntrl_hammondpa" )

	soundEnt.Destroy()
}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLobbyReduxOvergrown( entity player )
{
	FlagWait( "FirstSpectreDeployedLobbyReduxOvergrown")


	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_NIGHT )
	wait 1.5

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
	//DISTRESSED hammondPA	(Ding) Hammond automated security personnel are being deployed at your location. Please remain calm and present Hammond identification credentials if asked. Thank you.
	//waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_ambAnnc_TS107_06_01d_ntrl_hammondpa" )

	soundEnt.Destroy()
}


/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██║  ██║██║   ██║██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
███████║██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══██║██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
██║  ██║╚██████╔╝██████╔╝            ██║     ██║╚██████╔╝██║  ██║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚═════╝             ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██║  ██║██║   ██║██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
███████║██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══██║██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
██║  ██║╚██████╔╝██████╔╝            ██║     ██║╚██████╔╝██║  ██║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚═════╝             ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██║  ██║██║   ██║██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
███████║██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══██║██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
██║  ██║╚██████╔╝██████╔╝            ██║     ██║╚██████╔╝██║  ██║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚═════╝             ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██║  ██║██║   ██║██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
███████║██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══██║██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
██║  ██║╚██████╔╝██████╔╝            ██║     ██║╚██████╔╝██║  ██║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚═════╝             ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
void function HubFightStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointHubFight" ) )
	TriggerSilentCheckPoint( GetEntByScriptName( "checkpointHubFight" ).GetOrigin(), true )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function HubFightSkipped( entity player )
{
	FlagSet( "panel_bridge_extend_activated" )
	FlagSet( "BridgeExtendObjectiveGiven" )
	FlagSet( "door_open_reactor_entrance_pristine" )
	//CleanupEnts( "titans_racks_bridge_room_02" )
	CleanupEnts( "titans_racks_bridge_room_03" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_HubFightThread( entity player )
{
	FlagWait( "player_exited_spoke1" )

	thread HubCheckpoints( player )
	Objective_Clear()
	FlagSet( "path_connect_lobby_pristine")
	entity path_connect_lobby_pristine_brush = GetEntByScriptName( "path_connect_lobby_pristine_brush" )
	path_connect_lobby_pristine_brush.Destroy()

	thread MusicHubFight( player )
	thread TitanTimeshiftHubHint( player )
	thread SpawnPristineStalkersWithDopplegangers( "hub_stalkers" )
	thread SetFlagWhenPlayerLookingAtEnt( player, "door_open_reactor_entrance_pristine", GetEntByScriptName( "lookent_door_bridge_bldg_pristine" ), GetEntByScriptName( "trigger_near_bridge_door_pristine" ) )
	thread OpenReactorDoorFailsafe()
	//thread SetFlagWhenPlayerLookingAtEnt( player, "door_open_reactor_entrance_overgrown", GetEntByScriptName( "lookent_door_bridge_bldg_overgrown" ), GetEntByScriptName( "trigger_near_bridge_door_overgrown" ) )
	thread DialogueHubFight( player )
	thread DialogueSoldiersSeePlayerTitan( player )
	thread DialogueMarderStartsTest( player )
	thread RackTitansThink( TIMEZONE_DAY )
	thread RackTitansThink( TIMEZONE_NIGHT )
	thread SpawnAutoSecurityGroup( "titans_bridge_room" )

	array <entity> hubProwlers = GetNPCArrayByClass( "npc_prowler" )
	foreach( prowler in hubProwlers )
	{
		if ( !IsAlive( prowler ) )
			continue
		prowler.SetMaxHealth( 10 )
		prowler.SetHealth( 10 )
	}


	FlagWait( "BridgeExtendObjectiveGiven" )

	vector objectivePos

	if ( ( Flag( "player_inside_bridge_room_overgrown" ) ) || ( Flag( "player_inside_bridge_room_pristine" ) ) )
		objectivePos = GetEntByScriptName( "objective_bridge_control" ).GetOrigin()
	else
		objectivePos = GetEntByScriptName( "objective_bridge_control_breadcrumb_01" ).GetOrigin()

	TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_BRIDGE_EXTEND", objectivePos )

	thread BridgeControlObjectiveTracker( player )

	CheckPoint()

	FlagWaitAny( "player_inside_bridge_room_overgrown", "player_inside_bridge_room_pristine" )


	//------------------------
	// Player extended bridge
	//-------------------------
	FlagWait( "panel_bridge_extend_activated" )
}


void function OpenReactorDoorFailsafe()
{
	if ( Flag( "door_open_reactor_entrance_pristine") )
		return
	FlagEnd( "door_open_reactor_entrance_pristine")

	FlagWait( "player_touching_near_bridge_control_door_pristine" )
	FlagSet( "door_open_reactor_entrance_pristine" )

}

void function DialogueSoldiersSeePlayerTitan( entity player )
{

	player.EndSignal( "OnDeath" )
	FlagEnd( "player_crossing_reactor_bridge" )

	FlagWait( "AutoSecurityDialogueDone" )

	wait 1

	while( true )
	{
		wait 1
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

		if ( !player.IsTitan() )
			continue

		if ( Flag( "player_inside_bridge_room_pristine" ) )
			continue

		if ( Flag( "player_inside_bridge_room_overgrown" ) )
			continue

		break
	}

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	wait 0.2

	//IMC Grunt 10 (Radio)	Vanguard-class titan! Taking heavy casualties!
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_16_01_imc_grunt2" )

	//IMC Grunt 11 (Radio)	Where'd it come from!
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_17_01_imc_grunt3" )

}



void function HubCheckpoints( entity player )
{
	if ( !Flag( "panel_bridge_extend_activated" ) )
		return

	FlagEnd( "panel_bridge_extend_activated" )

	FlagWaitAny( "hub_titans_killed_pristine", "hub_titans_killed_overgrown" )

	CheckPoint()

	wait 10

	if ( !Flag( "hub_titans_killed_pristine" ) )
		FlagWait( "hub_titans_killed_pristine" )
	else if ( !Flag( "hub_titans_killed_overgrown" ) )
		FlagWait( "hub_titans_killed_overgrown" )
	else
		return


	CheckPoint()
}
/////////////////////////////////////////////////////////////////////////////////////////
void function BridgeControlObjectiveTracker( entity player )
{
	FlagEnd( "panel_bridge_extend_activated" )
	player.EndSignal( "OnDeath" )

	vector objectivePos

	vector orgPanel = GetEntByScriptName( "objective_bridge_control" ).GetOrigin()
	vector orgControlRoomDoor = GetEntByScriptName( "objective_bridge_control_breadcrumb_01" ).GetOrigin()

	FlagEnd( "panel_bridge_extend_activated" )
	while ( true )
	{
		wait 1
		if ( ( Flag( "player_inside_bridge_room_overgrown" ) ) || ( Flag( "player_inside_bridge_room_pristine" ) ) )
			objectivePos = orgPanel
		else
			objectivePos = orgControlRoomDoor
		TimeshiftUpdateObjective( player, objectivePos )
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
void function TitanTimeshiftHubHint( entity player )
{
	player.EndSignal( "OnDeath" )

	FlagEnd( "PlayerHasTimeTraveledInsideBT" )

	while( true )
	{
		wait 10
		if ( !player.IsTitan() )
			continue

		thread TitanTimeshiftHint( player )
	}

}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicHubFight( entity player )
{
	FlagWait( "player_exited_spoke1" )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_21c_pastloop_stop" )
	if ( IsValid( player ) )
		StopSoundOnEntity( player, "music_timeshift_14_pastloop" )

	FlagWait( "BridgeExtendObjectiveGiven" )
	StopMusic()
	if ( IsValid( player ) )
		StopSoundOnEntity( player, "music_timeshift_21_combatpresentdone" )
	PlayMusic( "music_timeshift_31_backwithbt" )

	FlagWait( "door_open_reactor_entrance_pristine" )

	StopMusic()
	PlayMusic( "music_timeshift_32_doordown" )

	//when you activate the controls - Play music_timeshift_33_locatedthecontrols
	FlagWait( "panel_bridge_extend_activated" )

	StopMusic()
	PlayMusic( "music_timeshift_33_locatedthecontrols" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function RackTitansThink( var timeZone )
{
	string flagToSpawn = ""
	if ( timeZone == TIMEZONE_DAY )
		flagToSpawn = "player_inside_bridge_room_pristine"
	else
		flagToSpawn = "player_inside_bridge_room_overgrown"

	FlagWait( flagToSpawn )

	//thread TitanRackDeploy( "titans_racks_bridge_room_02", timeZone )
	//delaythread ( 1.5 ) TitanRackDeploy( "titans_racks_bridge_room_03", timeZone )

}


void function DialogueMarderStartsTest( entity player )
{
	FlagWait( "player_is_near_bridge_control_pristine" )


	//entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//General Marder (Radio)	Damn the safety protocols, initiate the test, now!
	waitthread PlayTimeShiftDialogue( player, player, "diag_sp_pristine_TS241_06_01_imc_genMarder" )

	//IMC Base (Radio)	Copy that. Do not allow the intruder to reach the Sculptor Core under any circumstances.
	waitthread PlayTimeShiftDialogue( player, player, "diag_sp_pristine_TS241_18_01_imc_command" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueHubFight( entity player )
{
	FlagWait( "player_exited_spoke1" )
	FlagEnd( "panel_bridge_extend_activated")

	OnThreadEnd(
	function() : ( player )
		{
			FlagSet( "BridgeExtendObjectiveGiven" )
		}
	)


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/
	entity bt = player.GetPetTitan()

	//BT	Pilot, I have located the controls to extend the bridge to the rings. I have marked it on your HUD.
	waitthread PlayBTDialogue( "diag_sp_pristine_TS241_07_01_mcor_bt" )
	FlagSet( "BridgeExtendObjectiveGiven" )

	wait 5

	//BT	It appears that whatever actions you took in the past have caused the remaining automated security systems to be quite hostile towards us in the present.
	waitthread PlayBTDialogue( "diag_sp_pristine_TS241_01_01_mcor_bt" )

	FlagSet( "AutoSecurityDialogueDone" )
	int EmbarkNagsNagged = 0
	int BridgeNagsNagged = 0
	vector objectivePos = GetEntByScriptName( "objective_bridge_control_breadcrumb_01" ).GetOrigin()



	while( true )
	{
		wait RandomFloatRange( 30, 45 )

		if ( Flag( "panel_bridge_extend_activated") )
			break


		else if ( ShouldDoBridgeNag( player ) )
		{

			if ( BridgeNagsNagged == 0 )
			{
				//BT	Uphold the mission: I have marked the bridge controls on your HUD. You will need to extend the bridge before the World Sculptor testbed explodes.
				waitthread PlayBTDialogue( "diag_sp_pristine_TS241_08_01_mcor_bt" )
			}
			else if ( BridgeNagsNagged == 1 )
			{
				//no dialogue
			}
			else if  ( BridgeNagsNagged == 2 )
			{
				//BT	Pilot, I have located the controls to extend the bridge to the rings. I have marked it on your HUD.
				waitthread PlayBTDialogue( "diag_sp_pristine_TS241_07_01_mcor_bt" )

			}
			else  if  ( BridgeNagsNagged == 3 )
			{
				//no dialogue
			}

			Objective_Remind()

			BridgeNagsNagged++
			if ( BridgeNagsNagged == 4 )
				BridgeNagsNagged = 0
		}

		else
			continue

	}

}

/////////////////////////////////////////////////////////////////////////////////////////
bool function ShouldDoBridgeNag( entity player )
{
	if ( Flag( "hub_titans_killed_pristine" ) )
		return  true

	if ( level.timeZone == TIMEZONE_NIGHT )
		return true

	if ( !Flag( "panel_bridge_extend_activated") )
		return true

	if ( !IsAudioLogPlaying( player ) )
		return true

	return false

}


/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗████████╗███████╗███╗   ██╗██████╗ ███████╗██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
█████╗   ╚███╔╝    ██║   █████╗  ██╔██╗ ██║██║  ██║█████╗  ██║  ██║            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██║  ██║            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
███████╗██╔╝ ██╗   ██║   ███████╗██║ ╚████║██████╔╝███████╗██████╔╝            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═════╝             ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗████████╗███████╗███╗   ██╗██████╗ ███████╗██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
█████╗   ╚███╔╝    ██║   █████╗  ██╔██╗ ██║██║  ██║█████╗  ██║  ██║            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██║  ██║            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
███████╗██╔╝ ██╗   ██║   ███████╗██║ ╚████║██████╔╝███████╗██████╔╝            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═════╝             ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗████████╗███████╗███╗   ██╗██████╗ ███████╗██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
█████╗   ╚███╔╝    ██║   █████╗  ██╔██╗ ██║██║  ██║█████╗  ██║  ██║            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██║  ██║            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
███████╗██╔╝ ██╗   ██║   ███████╗██║ ╚████║██████╔╝███████╗██████╔╝            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═════╝             ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗████████╗███████╗███╗   ██╗██████╗ ███████╗██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
█████╗   ╚███╔╝    ██║   █████╗  ██╔██╗ ██║██║  ██║█████╗  ██║  ██║            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══╝   ██╔██╗    ██║   ██╔══╝  ██║╚██╗██║██║  ██║██╔══╝  ██║  ██║            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
███████╗██╔╝ ██╗   ██║   ███████╗██║ ╚████║██████╔╝███████╗██████╔╝            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═════╝             ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
void function ExtendedBridgeStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointExtendedBridge" ) )

	TriggerSilentCheckPoint( GetEntByScriptName( "checkpointExtendedBridge" ).GetOrigin(), true )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function ExtendedBridgeSkipped( entity player )
{
	FlagClear( "retract_bridge_reactor" )
	FlagSet( "player_leaving_bridge_control" )
	FlagSet( "StartReactorMeltdown" )
	CleanupEnts( "blocker_bridge_pristine" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AA_ExtendedBridgeThread( entity player )
{
	FlagWait( "panel_bridge_extend_activated" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, Vector( -1217.015137, -240.011566, -1293.567139 ), "Timeshift_Scr_BridgeToRings_Extend" )


	//Put BT in a good spot so player can re-unite
	entity bt = player.GetPetTitan()

	//early out if BT died
	if ( !IsAlive( bt ) )
		return

	array<entity> BTnodes = GetEntArrayByScriptName( "bt_bridge_door_wait" )
	entity btTeleportNode = GetClosest( BTnodes, bt.GetOrigin() )
	if ( ( IsValid( btTeleportNode ) ) && ( IsAlive( bt ) ) )
	{
		bt.SetOrigin( btTeleportNode.GetOrigin() )
		bt.SetAngles( btTeleportNode.GetAngles() )
	}


	CleanupEnts( "blocker_bridge_pristine" )

	FlagSet( "ReactorScanObjectiveGiven" )



	CheckPoint()

	SetGlobalForcedDialogueOnly( true )

	thread MusicExtendedBridge( player )
	thread ReactorStartsBlowingUp( player )

	wait 0.5

	//FlagSet( "play_core_effect_pristine" )
	thread DialogueReactorMeltingDown( player )
	thread DialogueExtendedBridge( player )
	thread ScanObjective( player )
	FlagClear( "retract_bridge_reactor" )

	FlagWait( "player_leaving_bridge_control" )

	FlagWait( "player_headed_to_meltdown" )


	FlagSet( "StartReactorMeltdown" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function ScanObjective( entity player )
{
	FlagWait( "ReactorScanObjectiveGiven" )
	vector objectivePos = GetEntByScriptName( "objective_bridge_cross" ).GetOrigin()
	TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_SCAN", objectivePos )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueExtendedBridge( entity player )
{


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagWait( "panel_bridge_extend_activated" )

	FlagWait( "player_leaving_bridge_control" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//IMC Grunt 9 (Radio)	Requesting reinforcements!
	//waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_15_01_imc_grunt1" )

	//IMC Base (Radio)	Reinforcements and orbital Titanfalls are en route.
	//waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_19_01_imc_command" )

	//thread DialogueSoldiersSeePlayerTitan( player )

	if ( Flag( "player_crossing_reactor_bridge") )
		return

	FlagEnd( "player_crossing_reactor_bridge" )


	vector objectivePos = GetEntByScriptName( "objective_bridge_cross" ).GetOrigin()

	int ReactorNagsNagged = 0
	bool reactorIMCLinesPlayed = false
	string nagAlias
	string imcLineAlias
	while( true )
	{
		wait RandomFloatRange( 35, 60 )


		if ( ReactorNagsNagged == 0 )
		{
			//BT	Pilot, we must uphold the mission. I advise you get as close as possible to the center of the rings.
			nagAlias = "diag_sp_pristine_TS241_11a_01_mcor_bt"
			if ( !reactorIMCLinesPlayed )
			{

				imcLineAlias = ""
			}
			else
				imcLineAlias = ""
		}

		else if ( ReactorNagsNagged == 1 )
		{
			//BT	To uphold the mission, you will need to get as close as possible to the center of the active rings in the past.
			nagAlias = "diag_sp_pristine_TS241_12a_01_mcor_bt"
			if ( !reactorIMCLinesPlayed )
			{
				//We have to get out of here. That things going to blow.
				imcLineAlias = "diag_sp_meltDown_TS252_06_01_imc_grunt"
			}
			else
				imcLineAlias = ""
		}
		else if ( ReactorNagsNagged == 2 )
		{
			//BT	Pilot, I recommend you scan the center of the rings in order to uphold the mission. Use the service bridge in the past to access the Ark.
			nagAlias = "diag_sp_pristine_TS241_13a_01_mcor_bt"
			if ( !reactorIMCLinesPlayed )
			{
				//Scientist 1 (Radio)	The Sculptor Core is overloading!
				imcLineAlias = "diag_sp_pristine_TS241_20_01_imc_scientist1"
			}
			else
				imcLineAlias = ""
		}
		else if ( ReactorNagsNagged == 3 )
		{
			//BT	Uphold the mission: You will need to get as close as possible to the center of the rings in the past. Use the bridge to access and scan the Ark.
			nagAlias = "diag_sp_pristine_TS241_10_01_mcor_bt"
			if ( !reactorIMCLinesPlayed )
			{
				//Scientist 2 (Radio)	Everyone evacuate now!
				imcLineAlias = "diag_sp_pristine_TS241_21_01_imc_scientist2"
			}
			else
				imcLineAlias = ""
		}

		else if ( ReactorNagsNagged == 4 )
		{
			//BT	You must get to the center of those rings. Cross the bridge.
			nagAlias = "diag_sp_tsAlts_TS401_13_mcor_bt"
			imcLineAlias = ""
		}




		if ( ( imcLineAlias != "" ) && ( level.timeZone == TIMEZONE_DAY ) && ( !Flag( "OverloadDialoguePlaying" ) ) )
		{
			soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )
			waitthread PlayTimeShiftDialogue( player, soundEnt, imcLineAlias )
		}

		waitthread PlayBTDialogue( nagAlias )
		Objective_Remind()
		ReactorNagsNagged++
		if ( ReactorNagsNagged == 5 )
		{
			ReactorNagsNagged = 0
			reactorIMCLinesPlayed = true
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueReactorMeltingDown( entity player )
{

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/
	FlagWait( "player_leaving_bridge_control" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	FlagSet( "OverloadDialoguePlaying" )
	//Scientist 1 (Radio)	The Sculptor Core is overloading!
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_20_01_imc_scientist1" )

	//Scientist 2 (Radio)	Everyone evacuate now!
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_21_01_imc_scientist2" )
	FlagClear( "OverloadDialoguePlaying" )

}
/////////////////////////////////////////////////////////////////////////////////////////////
/*
void function DialogueSoldiersSeePlayerTitan( entity player )
{
	if ( Flag( "player_crossing_reactor_bridge") )
		return

	player.EndSignal( "OnDeath" )
	FlagEnd( "player_crossing_reactor_bridge" )

	while( true )
	{
		wait 1
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

		if ( !player.IsTitan() )
			continue

		if ( Flag( "player_inside_bridge_room_pristine" ) )
			continue

		if ( Flag( "player_inside_bridge_room_overgrown" ) )
			continue

		break
	}

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	wait 0.2

	//IMC Grunt 10 (Radio)	Vanguard-class titan! Taking heavy casualties!
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_16_01_imc_grunt2" )

	//IMC Grunt 11 (Radio)	Where'd it come from!
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_pristine_TS241_17_01_imc_grunt3" )

}

*/

/////////////////////////////////////////////////////////////////////////////////////////
void function MusicExtendedBridge( entity player )
{
	FlagWait( "player_crossing_reactor_bridge" )

	StopMusic()
}

/////////////////////////////////////////////////////////////////////////////////////////
void function ReactorStartsBlowingUp( entity player )
{
	player.EndSignal( "OnDeath" )
	FlagEnd( "FullWhiteOut" )

	entity rings = GetEntByScriptName( "rings_pristine" )
	vector origin = rings.GetOrigin()
	vector angles = rings.GetAngles()
	if ( !IsValid( rings ) )
		return
	rings.EndSignal( "OnDestroy" )

	AddAnimEvent( rings, "rings_local_explosion_normal", RingsLocalExplosionNormal )
	AddAnimEvent( rings, "rings_local_explosion_big", RingsLocalExplosionBig )

	FlagWait( "player_leaving_bridge_control" )

	thread MeltdownPulses( player )

	//-----------------------
	// Meldown Stage 1
	//-----------------------
	float animLength = rings.GetSequenceDuration( "animated_damaged_stage_1" )

	while( !Flag( "player_headed_to_meltdown" ) )
	{
		waitthread PlayAnimTeleport( rings, "animated_damaged_stage_1", origin, angles )
	}

	animLength = rings.GetSequenceDuration( "animated_damaged_stage_2" )
	//-----------------------
	// Meldown Stage 2
	//-----------------------
	while( !Flag( "player_crossing_reactor_bridge_start" ) )
	{
		waitthread PlayAnimTeleport( rings, "animated_damaged_stage_2", origin, angles )
	}

	//-----------------------
	// Meldown Stage 3
	//-----------------------
	thread PlayAnimTeleport( rings, "animated_damaged_stage_3", origin, angles )

	WaitForever()
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
██████╗ ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
██████╔╝█████╗  ███████║██║        ██║   ██║   ██║██████╔╝            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══██╗██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
██║  ██║███████╗██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██████╗ ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
██████╔╝█████╗  ███████║██║        ██║   ██║   ██║██████╔╝            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══██╗██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
██║  ██║███████╗██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██████╗ ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
██████╔╝█████╗  ███████║██║        ██║   ██║   ██║██████╔╝            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══██╗██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
██║  ██║███████╗██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
██████╗ ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗             ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗            ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
██████╔╝█████╗  ███████║██║        ██║   ██║   ██║██████╔╝            ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██╔══██╗██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗            ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
██║  ██║███████╗██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║            ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////

void function ReactorBridgeStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointReactorBridge" ) )
	vector objectivePos = GetEntByScriptName( "objective_bridge_cross" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_SCAN", objectivePos )
	CleanupAI( player )

	TriggerSilentCheckPoint( GetEntByScriptName( "checkpointReactorBridge" ).GetOrigin(), true )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function ReactorBridgeSkipped( entity player )
{
	//thread FrozenWorldAmbientSoundAndFx( player )
	CleanupEnts( "rings_pristine" )
	thread FrozenWorldGlove( player )
	level.allowTimeTravel = false
	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD  )
	FlagSet( "SwappedToFrozenWorld" )
	thread ElectricalScreenEffects( player, "SwappedToFrozenWorld" )
	Remote_CallFunction_Replay( player, "ServerCallback_DisableAllLasers" )


}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_ReactorBridgeThread( entity player )
{
	FlagWait( "StartReactorMeltdown" )

	entity rings = GetEntByScriptName( "rings_pristine" )

	SetGlobalForcedDialogueOnly( true )

	//thread FrozenWorldAmbientSoundAndFx( player )
	thread MusicReactorBridge( player )

	foreach( entity p in GetPlayerArray() )
		Remote_CallFunction_NonReplay( p, "ServerCallback_FrozenLightStart" )

	FlagWait( "player_crossing_reactor_bridge_start" )
	thread DialogueReactorBridge( player )


	FlagWait( "player_crossing_reactor_bridge" )

	thread StopAllDialogue( player )
	thread MeltdownPulses( player, "FullWhiteOut" )

	thread BridgeCrossScreenShake( player )

	level.allowTimeTravel = false
	FlagSet( "FadingToFrozenWorld" )
	player.SetInvulnerable()
	entity titan = player.GetPetTitan()
	if ( IsValid( titan ) )
	{
		titan.SetHealth( titan.GetMaxHealth() )
		titan.SetInvulnerable()
	}
	if ( player.IsTitan() )
		Disembark_Disallow( player )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	float fadeTime = 0.1
	float holdTime = 4.2

	EmitSoundOnEntity( player, "Timeshift_Scr_ArkOverload" )
	EmitSoundOnEntity( soundEnt, "diag_sp_meltDown_TS252_05_01_imc_grunt" )  //The Ark! It's losing stability.
	Remote_CallFunction_NonReplay( player, "ServerCallback_FlippingToFrozen" )
	Remote_CallFunction_Replay( player, "ServerCallback_DisableAllLasers" )

	wait 1.8
	ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_OUT | FFADE_PURGE )
	wait 0.1

	//---------------------------------
	// WHITE OUT - Transitioning to Frozen World
	//----------------------------------

	var skyCam = GetEnt( "skybox_cam_explosion" )
	
	foreach( entity p in GetPlayerArray() )
	{
		if ( player.IsTitan() )
			player.SetOrigin( GetEntByScriptName( "node_bt_frozen" ).GetOrigin() )
		else
			player.SetOrigin( GetEntByScriptName( "player_frozen_start" ).GetOrigin() )

		p.SetSkyCamera( skyCam )

		Remote_CallFunction_NonReplay( p, "ServerCallback_TimeFlipped", TIMEZONE_FROZEN )
	}

	if ( IsValid( rings ) )
		rings.Destroy()

	EmitSoundOnEntity( player, "timeshift_scr_finalexplo_rings" )
	FlagClear( "turn_on_daytime_sun_flare" )
	FlagSet( "FullWhiteOut" )
	soundEnt.Destroy()
	CleanupEnts( "enemies_hub_end" )
	CleanupEnts( "dropship_end_scripted_right" )
	CleanupEnts( "dropship_end_scripted_left" )
	
	foreach( entity p in GetPlayerArray() )
		AddCinematicFlag( p, CE_FLAG_HIDE_MAIN_HUD  )

	thread FrozeSplosionDudes( player )


	SetGlobalForcedDialogueOnly( true )
	player.FreezeControlsOnServer()

	bool titanTimeTraveled = false
	if ( player.IsTitan() )
		titanTimeTraveled = true
	delaythread ( 3 ) BTexplosionThink( player, titanTimeTraveled )
	wait 2

	//---------------------------------------------
	// END WHITE OUT - now we are in Frozen World
	//----------------------------------------------
	FlagSet( "SwappedToFrozenWorld" )

	TriggerSilentCheckPoint( GetEntByScriptName( "checkpointReactorBridge" ).GetOrigin(), true )

	thread ElectricalScreenEffects( player, "SwappedToFrozenWorld" )
	wait 2

	fadeTime = 1
	holdTime = 3
	CheckPoint()
	
	foreach( entity p in GetPlayerArray() )
	{
		ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_IN | FFADE_PURGE )
		Embark_Disallow( player )
	}
	/*
	entity bridgeTrigger = GetEntByScriptName( "trigger_bridge_frozen" )
	if ( !bridgeTrigger.IsTouching( player ) )
	{
		TeleportPlayers( GetEntByScriptName( "player_frozen_start" ) )
	}
	*/

	vector objectivePos = GetEntByScriptName( "objective_core" ).GetOrigin()
	Objective_Update( objectivePos )

	FlagWait( "player_inside_core_zone_outer" )
	
	foreach( entity p in GetPlayerArray() )
		StatusEffect_AddTimed( p, eStatusEffect.emp, 10, 3, 1 )
	EmitSoundOnEntity( player, EMP_IMPARED_SOUND )
	
	thread CreateShakeWhileFlagSet( 0.5, 0.5, 1, "player_inside_core_zone_outer", "CoreScanStarting" )

	FlagWait( "player_inside_core_zone_inner" )
	
	foreach( entity p in GetPlayerArray() )
		StatusEffect_AddTimed( p, eStatusEffect.emp, 10, 3, 1 )
}

void function StopAllDialogue( entity player )
{
	//TODO - cut off BT if he's in the middle of blabbing
	//xxx


}

void function MeltdownPulses( player, string flagToAbort = "player_crossing_reactor_bridge" )
{
	if ( Flag( flagToAbort ) )
		return

	FlagEnd( flagToAbort )

	float interval = 4
	string sound = "timeshift_scr_core_rise_end"

	if ( flagToAbort != "player_crossing_reactor_bridge" )
	{
		interval = 0.4
	}

	entity fx

	entity arkShell = GetEntByScriptName( "core_model_pristine" )
	vector pulseOrigin = arkShell.GetOrigin()
	while( true )
	{
		wait interval
		fx = PlayFXOnEntity( FX_ARK_PULSE, arkShell )
		EmitSoundAtPosition( TEAM_UNASSIGNED, pulseOrigin, "timeshift_scr_core_pulse" )
		thread CreateAirShake( pulseOrigin, 32, 200, 1.5, 10000 )

	}

}

/////////////////////////////////////////////////////////////////////////////////////////

void function FrozenWorldGlove( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_PlayGloveGlow", TIMEZONE_FROZEN )
	entity timeShiftOffhand = player.GetFirstPersonProxy()
	SetTimeshiftArmDeviceSkin( 2 )
	timeShiftOffhand.SetSkin( 2 ) //red
}

/////////////////////////////////////////////////////////////////////////////////////////
void function MusicReactorBridge( entity player )
{
	// At the beginning of the white-out when you cross the bridge - Play music_timeshift_34_timestop
	FlagWait( "SwappedToFrozenWorld" )
	wait 1.5
	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_34_timestop" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function DropshiftBridgeThink( entity dropship )
{
	dropship.EndSignal( "OnDeath" )
	string scriptName = dropship.GetScriptName()
	bool isLeftDropship = true
	if ( scriptName == "dropship_end_scripted_right" )
		isLeftDropship = false

	float waitTime = 4
	asset explosionFx = FX_EXPLOSION_01
	string explosionSound = "Beacon_Straton_MissileFire_RocketExplo"
	if ( isLeftDropship )
	{
		waitTime = 4
		explosionFx = FX_EXPLOSION_02
		explosionSound = "Beacon_Straton_MissileFire_RocketExplo"
	}


	wait waitTime

	PlayFXOnEntity( explosionFx, dropship, "PILOT_SEAT" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, dropship.GetOrigin(), explosionSound )

	if ( isLeftDropship )
	{
		wait 10
		dropship.Destroy()
	}
}

/////////////////////////////////////////////////////////////////////////////////////////

void function DialogueReactorBridge( entity player )
{

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	//waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	//entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	FlagWait( "FullWhiteOut" )

	if ( player.IsTitan() )
		wait 0.1
	else
		wait 0.1



	//Player: Slow breaths.....BT?
	//EmitSoundOnEntity( player, "diag_sp_meltDown_TS252_01_01_mcor_player" )

	//Player: Slow breaths.....BT? (longer version)
	EmitSoundOnEntity( player, "diag_sp_meltDown_TS252_02_01_mcor_player" )

}

void function DialogueFadeToFrozen( entity player )
{
	FlagWait( "FadingToFrozenWorld" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function BridgeCrossScreenShake( entity player )
{
	player.EndSignal( "OnDeath" )
	FlagEnd( "FullWhiteOut" )

	while( true )
	{
		//CreateShake( vector org, float amplitude = 16, float frequency = 150, float duration = 1.5, float radius = 2048 )
		CreateAirShake( player.GetOrigin(), 8, 105, 1.5 )
		wait 1.25
	}


}

/////////////////////////////////////////////////////////////////////////////////////////
void function BTexplosionThink( entity player, bool titanTimeTraveled )
{

	entity node
	entity titan
	
	FlagWait( "SwappedToFrozenWorld" )
	thread EjectPlayersFromTitan()

	//-------------------
	// BT Stayed Behind
	//-------------------
	if ( titanTimeTraveled == false )
	{
		titan = player.GetPetTitan()
		node = GetEntByScriptName( "nodeTitanReturn" )
		thread PlayAnimTeleport( titan, "bt_timeshift_frozen_stand_idle", node )
		titan.SetHealth( titan.GetMaxHealth() )
		wait 3.9
	}

	//-------------------
	// BT Came Along
	//-------------------

	else
	{
		wait 1

		titan = player.GetPetTitan()
		titan.SetHealth( titan.GetMaxHealth() )
		node = GetEntByScriptName( "node_bt_frozen" )

		thread PlayAnimTeleport( titan, "bt_timeshift_frozen_pose", node )
		
		FlagSet( "BT_is_in_frozen_world" )
	}
	
	wait 0.1

	// TODO: MAKE THIS FASTER

	//----------------------------------
	// Player looks at device
	//------------------------------------
	
	foreach( entity p in GetPlayerArray() )
		thread FrozenGloveAnim( p )
}

void function EjectPlayersFromTitan()
{
	foreach( entity player in GetPlayerArray() )
	{
		if ( !player.IsTitan() )
			continue
		
		player.FreezeControlsOnServer()
		Disembark_Allow( player )

		if ( PlayerCanDisembarkTitan( player ) )
		{
			//EmitSoundOnEntity( player, "Embark_Standing_Front_1P" )
			player.CockpitStartDisembark()
			Remote_CallFunction_Replay( player, "ServerCallback_TitanDisembark" )
			thread PlayerDisembarksTitan( player )
		}
	}
}

void function FrozenGloveAnim( entity player )
{
	thread FrozenWorldGlove( player )

	entity node = GetEntByScriptName( "player_frozen_start" )
	entity mover = CreateOwnedScriptMover( node ) //need a mover for first person sequence

	player.SetNoTarget( true )
	player.DisableWeapon()
	player.SetInvulnerable()
	player.ContextAction_SetBusy()

	FirstPersonSequenceStruct sequencePlayerDeviceBroke
	//sequencePlayerDeviceBroke.blendTime = 0.0
	sequencePlayerDeviceBroke.attachment = "ref"
	sequencePlayerDeviceBroke.firstPersonAnim = "ptpov_timeshift_broken"
	sequencePlayerDeviceBroke.thirdPersonAnim = "pt_timeshift_broken"
	sequencePlayerDeviceBroke.viewConeFunction = ViewConeTight

	entity timeShiftOffhand = player.GetFirstPersonProxy()
	delaythread ( 0.1 ) TimeshiftDeviceBlinkRed( timeShiftOffhand )
	player.UnfreezeControlsOnServer()
	waitthread FirstPersonSequence( sequencePlayerDeviceBroke, player, mover )


	player.ClearInvulnerable()
	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.EnableWeaponWithSlowDeploy()
	player.SetNoTarget( false )
	mover.Destroy()
}

/////////////////////////////////////////////////////////////////////////////////////////

void function FrozeSplosionDudes( entity player )
{
	Rodeo_Disallow( player )

	//----------------------------
	// Frozen soldiers
	//-----------------------------
	array <entity> explosiondudes
	array <entity> spawners = GetEntArrayByScriptName( "explosiondudes" )
	spawners.extend( GetEntArrayByScriptName( "explosiondudesdynamic" ) )
	Assert( spawners.len() > 0 )
	foreach( spawner in spawners )
	{
		Assert( IsSpawner( spawner ), "Entity is not a spawner " + spawner.GetOrigin() )
		entity dude = spawner.SpawnEntity()
		DispatchSpawn( dude )
		FrozeSplosionActorThink( dude )
	}

	wait 0.2

	thread CleanupAI( player, "trigger_ai_pristine", true )
	thread CleanupAI( player, "trigger_ai_overgrown", true )
}


/////////////////////////////////////////////////////////////////////////////////////////
void function FrozeSplosionActorThink( entity npc )
{
	npc.DisableHibernation()
	npc.DisableBehavior( "Assault" )
	//npc.AssaultSetFightRadius( 0 )
	//npc.AssaultSetGoalRadius( 0 )
	npc.Signal( "StopAssaultMoveTarget" )
	npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.EnableNPCFlag( NPC_DISABLE_SENSING )
	MakeInvincible( npc )
	//npc.Freeze()
	if ( ( npc.IsTitan() ) || IsSuperSpectre( npc ) )
	{
		HideCritTimeshift( npc )
		npc.SetValidHealthBarTarget( false )
		HideName( npc )
	}

	//npc.Signal( "OnFinishedAssault" )
	//npc.Signal( "OnSendAIToAssaultPoint" )
	//npc.Signal( "OnFailedToPath" )
	npc.SetNoTarget( true )
	SetTeam( npc, TEAM_UNASSIGNED )
	npc.SetTitle( "" )
	entity animNode = npc.GetLinkEnt()
	Assert( IsValid( animNode), "No valid animNode for ent npc at " + npc.GetOrigin() )
	Assert( animNode.HasKey( "leveled_animation" ), "No leveled_animation key at " + animNode.GetOrigin() )
	string anim = expect string( animNode.kv.leveled_animation )
	Assert( anim!= "" )
	thread PlayAnimTeleport( npc, anim, animNode )

	int attachID
	vector attachOrigin
	vector attachAngles
	entity weapon

	thread DeleteFrozenDudeIfCounterpartIsDead( npc )
	/*
	wait 0.1
	if ( npc.HasKey( "script_noteworthy" ) )
	{
		if ( npc.GetClassName() == "npc_super_spectre" )
		{
			printl( "*********************************************" )
			attachID = npc.LookupAttachment( "muzzle_flash" )
			attachOrigin = npc.GetAttachmentOrigin( attachID )
			attachAngles = npc.GetAttachmentAngles( attachID )
			printl( npc.kv.script_noteworthy + " right weapon origin: " + attachOrigin + " angles: " + attachAngles )
			DebugDrawSphere( attachOrigin, 25.0, 255, 200, 0, true, 999.0 )

			attachID = npc.LookupAttachment( "muzzle_flash2" )
			attachOrigin = npc.GetAttachmentOrigin( attachID )
			attachAngles = npc.GetAttachmentAngles( attachID )
			printl( npc.kv.script_noteworthy + " left weapon origin: " + attachOrigin + " angles: " + attachAngles )
			DebugDrawSphere( attachOrigin, 25.0, 255, 200, 0, true, 999.0 )
		}
		else
		{
			printl( "*********************************************" )
			weapon = npc.GetActiveWeapon()
			attachID = weapon.LookupAttachment( "muzzle_flash" )
			attachOrigin = npc.GetAttachmentOrigin( attachID )
			DebugDrawSphere( attachOrigin, 25.0, 255, 200, 0, true, 999.0 )
			attachAngles = npc.GetAttachmentAngles( attachID )
			printl( npc.kv.script_noteworthy + " weapon origin: " + attachOrigin + " angles: " + attachAngles )
		}

	}
	*/


}

void function DeleteFrozenDudeIfCounterpartIsDead( npc )
{
	if ( !IsValid( npc ) )
		return

	if ( !npc.HasKey( "script_noteworthy" ) )
		return

	string deathFlagOfCounterpart = expect string ( npc.kv.script_noteworthy )
	if ( !FlagExists( deathFlagOfCounterpart ) )
		return

	//FlagWait( "SwappedToFrozenWorld" )
	string npcName = deathFlagOfCounterpart

	if ( !Flag( deathFlagOfCounterpart ) )
	{
		//Npc is alive...start relevant fx
		if ( npcName == "bridge_superspectre1_dead" )
		{
			FlagSet( "reaper_frozen_left" )
			WaitFrame()
			FlagClear( "reaper_frozen_left" )
		}
		else if  ( npcName == "bridge_titan1_dead" )
		{
			FlagSet( "titan_frozen_left" )
			WaitFrame()
			FlagClear( "titan_frozen_left" )
		}
		else if  ( npcName == "bridge_titan2_dead" )
		{
			FlagSet( "titan_frozen_right" )
			WaitFrame()
			FlagClear( "titan_frozen_right" )
		}

		return
	}

	//kill the npc
	if ( IsValid( npc ) )
		npc.Destroy()



}

/*
void function FrozenWorldAmbientSoundAndFx( entity player )
{
	FlagWait( "player_inside_frozen_dropship" )

	FlagEnd( "CoreScanStarting" )

	float amplitude
	float frequency
	float duration
	string shakeSound = SOUND_CORE_RUMBLE_DISTANT

	//RandomFloatRange(1.0,2.0), 10, RandomFloatRange(1,4) )

	while( true )
	{
		wait RandomFloatRange( 7, 14 )
		if( Flag( "player_inside_core_zone_max" ) )
		{
			amplitude = 1.5
			frequency = 10
			duration = 4
			shakeSound = SOUND_CORE_RUMBLE_DISTANT //need to maybe change to unique sound
		}
		else if( Flag( "player_inside_core_zone_inner" ) )
		{
			amplitude = 1.5
			frequency = 10
			duration = 4
			shakeSound = SOUND_CORE_RUMBLE_DISTANT //need to maybe change to unique sound
		}
		else if( Flag( "player_inside_core_zone_outer" ) )
		{
			amplitude = 1.5
			frequency = 10
			duration = 4
			shakeSound = SOUND_CORE_RUMBLE_DISTANT //need to maybe change to unique sound
		}
		else
		{
			amplitude = 1.5
			frequency = 10
			duration = 4
			shakeSound = SOUND_CORE_RUMBLE_DISTANT //need to maybe change to unique sound
		}

		thread CreateShakeTimeshift( amplitude, frequency, duration )
		EmitSoundOnEntity( player, shakeSound )

	}
}
*/



/*
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
 ██████╗ ██████╗ ██████╗ ███████╗            ███████╗ ██████╗ █████╗ ███╗   ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝            ██╔════╝██╔════╝██╔══██╗████╗  ██║
██║     ██║   ██║██████╔╝█████╗              ███████╗██║     ███████║██╔██╗ ██║
██║     ██║   ██║██╔══██╗██╔══╝              ╚════██║██║     ██╔══██║██║╚██╗██║
╚██████╗╚██████╔╝██║  ██║███████╗            ███████║╚██████╗██║  ██║██║ ╚████║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝            ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
 ██████╗ ██████╗ ██████╗ ███████╗            ███████╗ ██████╗ █████╗ ███╗   ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝            ██╔════╝██╔════╝██╔══██╗████╗  ██║
██║     ██║   ██║██████╔╝█████╗              ███████╗██║     ███████║██╔██╗ ██║
██║     ██║   ██║██╔══██╗██╔══╝              ╚════██║██║     ██╔══██║██║╚██╗██║
╚██████╗╚██████╔╝██║  ██║███████╗            ███████║╚██████╗██║  ██║██║ ╚████║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝            ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝
 ////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
 ██████╗ ██████╗ ██████╗ ███████╗            ███████╗ ██████╗ █████╗ ███╗   ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝            ██╔════╝██╔════╝██╔══██╗████╗  ██║
██║     ██║   ██║██████╔╝█████╗              ███████╗██║     ███████║██╔██╗ ██║
██║     ██║   ██║██╔══██╗██╔══╝              ╚════██║██║     ██╔══██║██║╚██╗██║
╚██████╗╚██████╔╝██║  ██║███████╗            ███████║╚██████╗██║  ██║██║ ╚████║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝            ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝
 */

void function CoreScanStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointCoreScan" ) )
	vector objectivePos = GetEntByScriptName( "objective_core" ).GetOrigin()
	Objective_Update( objectivePos )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function CoreScanSkipped( entity player )
{
	FlagSet( "PlayerAtLevelEnd" )
}
/////////////////////////////////////////////////////////////////////////////////////////

void function AA_CoreScanThread( entity player )
{
	FlagWait( "player_inside_core_zone_inner" )

	thread MusicCoreScan( player )
	thread ReactorCoreThink( player )

	FlagWait( "CoreScanned" )

	Objective_Clear()

	//CreateShake( vector org, float amplitude = 16, float frequency = 150, float duration = 1.5, float radius = 2048 )
	wait 2
	thread CreateAirShake( player.GetOrigin(), 2, 50, 7 )
	EmitSoundOnEntity( player, SOUND_CORE_RUMBLE_DISTANT )

	wait 3

	/*
	float fadeTime = 1
	float holdTime = 1
	ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_OUT | FFADE_PURGE )
	*/

	FlagSet( "StartCoreScannedMusic" )
	wait 1


	FlagSet( "GoingBackToTheFuture" )
	CleanupAI( player )

	player.ClearParent()
	TeleportPlayers( GetEntByScriptName( "checkpointEnd" ) )
	var skyCam = GetEnt( "skybox_cam_night" )
	player.SetSkyCamera( skyCam )
	FlagClear( "player_is_indoors")


	//ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_IN | FFADE_PURGE )

	FlagSet( "PlayerAtLevelEnd" )
}


/////////////////////////////////////////////////////////////////////////////////////////
void function MusicCoreScan( entity player )
{
	//FlagWait( "CoreScanStarting" )
	FlagWait( "StartCoreScannedMusic" )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_35_coreandepilogue" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function ReactorCoreThink( entity player )
{
	entity coreObjective = GetEntByScriptName( "objective_core" )
	vector origin = coreObjective.GetOrigin()


	entity useDummy = CreatePropDynamic( DUMMY_MODEL, origin, Vector( 0, 0, 0 ), 2 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	useDummy.SetOrigin( origin + Vector( 0, 0, -50 ) )
	useDummy.SetUsable()
	useDummy.Hide()
	useDummy.SetUsableByGroup( "pilot" )
	useDummy.SetUsePrompts( "#TIMESHIFT_HINT_SCAN_CORE" , "#TIMESHIFT_HINT_SCAN_CORE_PC" )


	entity playerActivator
	while( true )
	{
		playerActivator = expect entity( useDummy.WaitSignal( "OnPlayerUse" ).player )
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() )
			break
	}

	foreach( entity p in GetPlayerArray() )
	{
		RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
		p.SetInvulnerable()
	}

	useDummy.UnsetUsable()
	useDummy.Destroy()


	entity node = CreateScriptMover( Vector( -1162, 6071.9, -10570 ), Vector( 46.5899, -88.972, 0.242813 ) )
	thread DataStab( playerActivator, node )

	delaythread( 1.5 )StopCoreElectricalEffects( playerActivator )


	entity fx = PlayFXOnEntity( FX_DLIGHT_HELMET, player, "HEADSHOT" )


	FlagSet( "CoreScanStarting" )

	Remote_CallFunction_NonReplay( playerActivator, "ServerCallback_ShowCoreDecoding" )

	wait 15

	FlagSet( "CoreScanned" )


	if ( IsValid( fx ) )
		EntFireByHandle( fx, "Stop", "", 0, null, null )

/*
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "DataKnife_Hack_Console_Pt3" )
	wait 0.2
	for ( int i = 0; i < 5; i++ )
	{
		wait 0.5
		Dev_PrintMessage( player, "#BLANK_TEXT", "#TIMESHIFT_INFO_SCANNING", 1 )
		EmitSoundAtPosition( TEAM_UNASSIGNED, player.GetOrigin(), "Dataknife_Complete" )
	}
	FlagSet( "CoreScanned" )
	wait 0.5
	EmitSoundAtPosition( TEAM_UNASSIGNED, player.GetOrigin(), "DataKnife_Hack_Console_Pt4" )

*/



}


void function StopCoreElectricalEffects( entity player )
{
	player.Signal( "StopCoreEffects" )

}

/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗     ███████╗██╗   ██╗███████╗██╗             ███████╗███╗   ██╗██████╗
██║     ██╔════╝██║   ██║██╔════╝██║             ██╔════╝████╗  ██║██╔══██╗
██║     █████╗  ██║   ██║█████╗  ██║             █████╗  ██╔██╗ ██║██║  ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║             ██╔══╝  ██║╚██╗██║██║  ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗        ███████╗██║ ╚████║██████╔╝
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝        ╚══════╝╚═╝  ╚═══╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗     ███████╗██╗   ██╗███████╗██╗             ███████╗███╗   ██╗██████╗
██║     ██╔════╝██║   ██║██╔════╝██║             ██╔════╝████╗  ██║██╔══██╗
██║     █████╗  ██║   ██║█████╗  ██║             █████╗  ██╔██╗ ██║██║  ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║             ██╔══╝  ██║╚██╗██║██║  ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗        ███████╗██║ ╚████║██████╔╝
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝        ╚══════╝╚═╝  ╚═══╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗     ███████╗██╗   ██╗███████╗██╗             ███████╗███╗   ██╗██████╗
██║     ██╔════╝██║   ██║██╔════╝██║             ██╔════╝████╗  ██║██╔══██╗
██║     █████╗  ██║   ██║█████╗  ██║             █████╗  ██╔██╗ ██║██║  ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║             ██╔══╝  ██║╚██╗██║██║  ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗        ███████╗██║ ╚████║██████╔╝
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝        ╚══════╝╚═╝  ╚═══╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function LevelEndStartPointSetup( entity player )
{
	TeleportPlayers( GetEntByScriptName( "checkpointEnd" ) )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function LevelEndSkipped( entity player )
{

}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_LevelEndThread( entity player )
{
	FlagWait( "PlayerAtLevelEnd" )
	
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( p, "ServerCallback_TimeFlipped", TIMEZONE_NIGHT )
		//FlagSet( "turn_on_daytime_sun_flare" ) //doesn't really matter since we are never going back there again

		//player.SetPlayerSettings( DEFAULT_PILOT_SETTINGS )
		if ( IsValid( p.GetOffhandWeapon( OFFHAND_SPECIAL ) ) )
			p.TakeOffhandWeapon( OFFHAND_SPECIAL )
		p.GiveOffhandWeapon( "mp_ability_cloak", 1 )

		thread PlayerLevelEndThink( p )
		FullyHidePlayers()
	}

	thread MusicEnd( player )
	thread BTlevelEndThink( player )
	thread DialogueLevelEnd( player )

	FlagWait( "EndingDialogeFinished" )

	FullyShowPlayers()

	wait 2
	foreach( player in GetPlayerArray() )
	{
		player.SetInvulnerable()
		ScreenFadeToBlack( player, 1.5, 5 )
	}
	wait 1.5
	foreach( player in GetPlayerArray() )
		player.FreezeControlsOnServer()
	Coop_LoadMapFromStartPoint( "sp_beacon", "Level Start" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function BTlevelEndThink( entity player )
{
	entity titan = player.GetPetTitan()
	if( !IsValid( titan ) )
		return

	entity node = GetEntByScriptName( "nodeTitanReturn" )
	thread PlayAnimTeleport( titan, "bt_timeshift_frozen_stand_idle", node )

	titan.EnableNPCFlag( NPC_IGNORE_ALL )
	titan.ClearEnemy()

	FlagWait( "PlayerAtLevelEnd" )

	//wait 8

	//titan.Anim_Stop()
	//waitthread PlayAnim( titan, "bt_timeshift_frozen_stand", node )
	//Embark_Allow( player )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function PlayerLevelEndThink( entity player )
{
	FlagWait( "PlayerAtLevelEnd" )
	
	UnlockAchievement( player, achievements.COMPLETE_OP217 )

	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD  )

	entity timeShiftOffhand = player.GetFirstPersonProxy()
	AddAnimEvent( timeShiftOffhand, "AnimTimeshiftSkinSwapRed", TimeshiftDeviceBlinkRed )
	AddAnimEvent( timeShiftOffhand, "AnimTimeshiftSkinSwapNone", TimeshiftDeviceBlinkOff )

	Remote_CallFunction_Replay( player, "ServerCallback_WakingUpLevelEnd" )

	entity node = GetEntByScriptName( "node_end_scene" )
	entity mover = CreateOwnedScriptMover( node ) //need a mover for first person sequence

	vector flyerOrg = Vector( -464, -344.5, -1280 )
	vector flyerAng = Vector( 0, -133, 0 )
	entity flyer = CreatePerchedFlyer( flyerOrg, flyerAng, false )
	//flyer.DisableHibernation()
	//thread FlyerTakeOff( flyer, true )

	player.SetNoTarget( true )
	player.DisableWeapon()
	player.SetInvulnerable()
	player.ContextAction_SetBusy()

	//----------------------------------
	// Player wake up idle
	//------------------------------------
	FirstPersonSequenceStruct sequencePlayerWakesUpIdle
	//sequencePlayerWakesUpIdle.blendTime = 0.5
	sequencePlayerWakesUpIdle.attachment = "ref"
	sequencePlayerWakesUpIdle.firstPersonAnim = "ptpov_timeshift_wake_idle"
	sequencePlayerWakesUpIdle.thirdPersonAnim = "pt_timeshift_wake_idle"
	sequencePlayerWakesUpIdle.viewConeFunction = ViewConeZero

	thread FirstPersonSequence( sequencePlayerWakesUpIdle, player, mover )
	EmitSoundOnEntity( player, "Timeshift_Scr_CoreScan_WakeupStatic" )
	wait 0

	Remote_CallFunction_NonReplay( player, "ServerCallback_StopGloveGlow" )

	wait 8

	//----------------------------------
	// Player wake up and stand
	//------------------------------------
	FirstPersonSequenceStruct sequencePlayerWakesUp
	sequencePlayerWakesUp.blendTime = 0.0
	sequencePlayerWakesUp.attachment = "ref"
	sequencePlayerWakesUp.firstPersonAnim = "ptpov_timeshift_wake"
	sequencePlayerWakesUp.thirdPersonAnim = "pt_timeshift_wake"
	sequencePlayerWakesUp.viewConeFunction = ViewConeTight

	delaythread ( 0.1 ) TimeshiftDeviceBlinkOff( timeShiftOffhand )
	waitthread FirstPersonSequence( sequencePlayerWakesUp, player, mover )


	//----------------------------------
	// Player discards device - Start
	//------------------------------------
	FirstPersonSequenceStruct sequencePlayerDiscardsDeviceStart
	sequencePlayerDiscardsDeviceStart.blendTime = 0.0
	sequencePlayerDiscardsDeviceStart.attachment = "ref"
	sequencePlayerDiscardsDeviceStart.firstPersonAnim = "ptpov_timeshift_discard_start"
	sequencePlayerDiscardsDeviceStart.thirdPersonAnim = "pt_timeshift_discard_start"
	sequencePlayerDiscardsDeviceStart.viewConeFunction = ViewConeTight

	waitthread FirstPersonSequence( sequencePlayerDiscardsDeviceStart, player, mover )
	FlagSet( "player_ripped_off_device" )


	player.SetPlayerSettings( DEFAULT_PILOT_SETTINGS )

	//----------------------------------
	// Player discards device - End
	//------------------------------------
	FirstPersonSequenceStruct sequencePlayerDiscardsDeviceEnd
	sequencePlayerDiscardsDeviceEnd.blendTime = 0.0
	sequencePlayerDiscardsDeviceEnd.attachment = "ref"
	sequencePlayerDiscardsDeviceEnd.firstPersonAnim = "ptpov_timeshift_discard_end"
	sequencePlayerDiscardsDeviceEnd.thirdPersonAnim = "pt_timeshift_discard_end"
	sequencePlayerDiscardsDeviceEnd.viewConeFunction = ViewConeTight

	waitthread FirstPersonSequence( sequencePlayerDiscardsDeviceEnd, player, mover )

	entity playerOffhand = player.GetFirstPersonProxy()
	if ( IsValid( playerOffhand) )
		playerOffhand.SetSkin( 0 )
	SetTimeshiftArmDeviceSkin( 0 )

	player.ClearInvulnerable()
	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	//player.EnableWeaponWithSlowDeploy()
	player.SetNoTarget( false )


}
/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftDeviceBlinkRed( entity timeShiftOffhand )
{
	if ( Flag( "player_ripped_off_device" ) )
		return
	timeShiftOffhand.SetSkin( 2 ) //red = 2
	SetTimeshiftArmDeviceSkin( 2 )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftDeviceBlinkOff( entity timeShiftOffhand )
{
	if ( Flag( "player_ripped_off_device" ) )
		return
	timeShiftOffhand.SetSkin( 3 ) //off = 3
	SetTimeshiftArmDeviceSkin( 3 )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicEnd( entity player )
{

}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLevelEnd( entity player )
{

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagWait( "PlayerAtLevelEnd" )

	wait 8


	//BT	Well done, Pilot. You successfully recorded the Sculptor Core's energy signature.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_29_01_mcor_bt" )

	//BT	It appears the IMC will soon target the Militia planet Harmony, using a full scale version of the Fold Weapon, located elsewhere on Typhon.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_30a_01_mcor_bt" )

	//Pilot Cooper, our journey is far from over.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_30b_01_mcor_bt" )

	//BT	We must relay this information to the Fleet.
	waitthread PlayBTDialogue( "diag_sp_overgrown_TS161_31_01_mcor_bt" )


	FlagSet( "EndingDialogeFinished")
}




/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/

/////////////////////////////////////////////////////////////////////////////////////////
vector function GetHelmetOrigin()
{
	entity helmet = GetEntByScriptName( "helmet_dogtag" )

	int attachmentID = helmet.LookupAttachment( "HEAD_FRONT" )
	vector origin = helmet.GetAttachmentOrigin( attachmentID )

	return origin
}
////////////////////////////////////////////////////////////////////////
void function StalerSecurityOvergrownThink( entity npc )
{
	TakeAllWeapons( npc )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function WeaponDrops()
{
	/*
	if ( Flag( "HideHubWeapons" ) )
		HideWeaponsAndAmmoTillFlag( "hub_weapons", "SpawnHubWeapons" )
	*/
}

/////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedPropDynamic( entity propDynamic )
{
	string scriptName = propDynamic.GetScriptName()

	if ( scriptName.find( "stalker_asleep_security" ) != null )
		thread StalkerAsleepThink( propDynamic )

	if ( scriptName.find( "stalker_asleep_hub" ) != null )
		thread StalkerAsleepThink( propDynamic )

	if ( scriptName == "panel_overgrown" )
	{
		SetTeam( propDynamic, TEAM_IMC )
		propDynamic.SetFadeDistance( 10000 )
		Highlight_SetEnemyHighlight( propDynamic, "enemy_sonar" )
	}

}
/////////////////////////////////////////////////////////////////////////////////////////
vector function GetBTObjectivePos()
{
	return file.bt.GetOrigin() + file.btObjectiveOffset
}


/////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedLevelNPC( entity npc )
{
	string scriptName = npc.GetScriptName()

	if ( scriptName == "spectre_security_services_pristine" )
		thread SpectreSecurityPristineThink( npc )

	if ( scriptName == "spectre_security_services_overgrown" )
		thread SpectreSecurityOvergrownThink( npc )

	if ( scriptName.find( "soldiers_skybridge" ) != null )
		thread SoldiersSkybridgeThink( npc )

	if ( scriptName == "stalker_vents_security_overgrown" )
		thread StalerSecurityOvergrownThink( npc )

	if ( scriptName == "intro_hallway_actors" )
		npc.EnableNPCFlag( NPC_IGNORE_ALL )

	if ( scriptName == "civilian_walker_intro_vista_talkers" )
		file.hallwayTalkers.append( npc )

	if ( scriptName == "prowlers_hub_return" )
		ProwlersHubReturnThink( npc )

	if ( scriptName == "marvin_lobby_overgrown" )
		thread MarvinLobbyOvergrownThink( npc )

	if ( scriptName == "marvin_lobby_pristine" )
		thread MarvinLobbyPristineThink( npc )

	if ( scriptName == "dropship_end_scripted_left" )
		thread DropshiftBridgeThink( npc )

	if ( scriptName == "dropship_end_scripted_right" )
		thread DropshiftBridgeThink( npc )

	if ( scriptName == "prowler_vents_lobby_start_overgrown" )
		thread ProwlersLobbyThink( npc )

	if ( scriptName == "dropships_skybridge" )
		thread DropshipSpawnAndRepeat( npc )


}


void function OnSpawnedLevelDropship( entity dropship )
{
	if ( !IsValid( dropship ) )
		return
	thread LevelDropshipThink( dropship )
}

void function LevelDropshipThink( entity dropship )
{
	dropship.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDestroy" )

	while( true )
	{
		wait 0.1
		if ( level.timeZone == TIMEZONE_DAY )
			dropship.Show()
		else
			dropship.Hide()
	}
}
void function MarvinLobbyPristineThink( entity npc )
{
	npc.EndSignal( "OnDeath" )
	wait 1
	entity marvinLobbyOvergrown = file.marvinLobbyOvergrown
	if ( !IsValid( marvinLobbyOvergrown ) )
		return
	if ( !marvinLobbyOvergrown.IsNPC() )
		return
	thread KillMyInterdimensionalBrother( npc, marvinLobbyOvergrown )

	/*
	OnThreadEnd(
	function() : ( )
		{
			ShowStuff( "marvin_lobby_dead" )
		}
	)
	npc.WaitSignal( "OnDeath" )
	*/

}

void function MarvinLobbyOvergrownThink( entity npc )
{
	file.marvinLobbyOvergrown = npc
	//npc.SetSkin( 2 )
	npc.WaitSignal( "OnDeath" )
	npc.SetSkin( 1 )
	file.timeshiftKilledLobbyMarvin = true
}

void function StopRingSounds( entity player )
{
	wait 1
	if ( !Flag( "player_back_in_amenities_lobby" ) )
		Remote_CallFunction_Replay( player, "ServerCallback_StopRingSounds" )
}


void function OnPilotBecomesTitan( entity pilot, entity titan )
{
	FlagSet( "PlayerEmbarkedTimeshift" )
}

void function OnTitanBecomesPilot( entity pilot, entity titan )
{
	FlagClear( "PlayerEmbarkedTimeshift" )
}


/////////////////////////////////////////////////////////////////////////////////////////
void function PetTitanThink( entity player )
{
	if ( !IsValid( player ) )
		return
	entity BT
	player.EndSignal( "OnDeath" )

	//string rainAlias = "beacon_emit_electricaldeathpanel_a_louder_lp"
	string rainAlias = "Timeshift_Emit_RainOnBT"
	while( true )
	{
		wait 1
		FlagWaitClearAll( "BT_is_in_daytime", "BT_is_indoors", "PlayerEmbarkedTimeshift" )
		BT = player.GetPetTitan()
		if ( !IsValid( BT ) )
			continue

		EmitSoundOnEntity( BT, rainAlias )
		//printl( "Starting BT Rain sound" )

		FlagWaitAny( "BT_is_in_daytime", "BT_is_indoors", "PlayerEmbarkedTimeshift", "BT_is_in_frozen_world" )

		BT = player.GetPetTitan()

		if ( IsValid( BT ) )
		{
			StopSoundOnEntity( BT, rainAlias )
			//printl( "Stopping BT Rain sound" )
		}


	}

}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedPanel( entity panel )
{
	SetTeam( panel, TEAM_IMC )
	panel.SetFadeDistance( 10000 )
	//panel.s.leechTimeNormal = 0.5
	//panel.s.leechTimeFast 	= 0.5
	if ( !("scriptedPanel" in panel.s ) )
		panel.s.scriptedPanel <- true  // HACK tells control panel scripts that this isn't connected to a turret

	panel.s.fx <- PlayLoopFXOnEntity( FX_GREEN_BLINKIE, panel, "", Vector( 0, 0, 60 ), Vector( 0, 0, 0) )

	SetControlPanelUseFunc( panel, PanelUse )

	Highlight_SetEnemyHighlight( panel, "enemy_sonar" )

	//make overgrown version for objective

	thread BridgePanelsThink( panel )
}

void function BridgePanelsThink( entity pristinePanel )
{
	//entity overgrownPanel = CreatePropDynamic( PANEL_MODEL, GetPosInOtherTimeline( pristinePanel.GetOrigin() ), pristinePanel.GetAngles(), 0 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	//Highlight_SetEnemyHighlight( overgrownPanel, "enemy_sonar" )
	//overgrownPanel.Hide()

	wait 0.5



	entity overgrownPanel = GetEntByScriptName( "panel_overgrown" )

	Highlight_ClearEnemyHighlight( pristinePanel )
	Highlight_ClearEnemyHighlight( overgrownPanel )

	if ( !Flag( "player_back_in_amenities_lobby" ) )
		return

	//FlagWait( "BridgeExtendObjectiveGiven" )
	FlagWaitAny( "player_inside_bridge_room_pristine", "player_inside_bridge_room_overgrown" )

	Highlight_SetEnemyHighlight( pristinePanel, "enemy_sonar" )
	Highlight_SetEnemyHighlight( overgrownPanel, "enemy_sonar" )

	FlagWait( "panel_bridge_extend_activated" )

	Highlight_ClearEnemyHighlight( overgrownPanel )
	Highlight_ClearEnemyHighlight( pristinePanel )

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
function PanelUse( panel, activator )
{
	expect entity( panel )

	StopFX( expect entity( panel.s.fx ) )
	panel.s.fx = PlayLoopFXOnEntity( FX_RED_BLINKIE, panel, "", Vector( 0, 0, 60 ), Vector( 0, 0, 0) )

	array<entity> players = GetPlayerArray()
	if ( players.len() == 0 )
		return
	entity player = players[0]
	if ( !IsValid( player ) )
		return


}



void function OnPlayerInventoryChangedTimeshift( entity player )
{
	if ( player.IsTitan() )
		TitanTimeshiftLoadout( player )
}