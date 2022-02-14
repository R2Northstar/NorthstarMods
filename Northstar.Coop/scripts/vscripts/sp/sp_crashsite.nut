#if DEV
globalize_all_functions
#else
global function CodeCallback_MapInit
#endif // DEV

const FX_SHIP_EXPLOSION					 = $"P_wild_night_exp"

const asset POD_MODEL					 = $"models/vehicle/escape_pod/escape_pod_animated.mdl"
const asset POD_MODEL_POV				= $"models/vehicle/escape_pod/escape_pod_pov_animated.mdl"

const asset JACK_MODEL_ARMS				= $"models/Weapons/arms/pov_mlt_hero_jack.mdl"
const asset JACK_MODEL_RIFLEMAN			= $"models/humans/heroes/mlt_hero_jack_rifleman.mdl"

const asset INTRO_CRASH_MODEL			= $"models/vehicles_r2/aircraft/goblin_destroyed/goblin_dropship_dest_nose.mdl"

const FLYBY_EXPLOSION_FX				= $"P_drone_frag_exp"
const FLYBY_EXPLOSION_SFX				= "ai_reaper_explo_3p" //corporate_spectre_death_explode

const asset GRAVE_ROCK_MODEL			= $"models/stage_props/gravestone/gravestone_01_animated.mdl"
const asset HELMET_MODEL				= $"models/humans/heroes/mlt_hero_anderson_helmet.mdl"

const asset OG_PILOT_MODEL				= $"models/Humans/heroes/mlt_hero_lastimosa.mdl"

const asset BATTERY_MODEL				= $"models/props/bt_battery/bt_battery_animated.mdl"

const asset RIFLE_WEAPON_MODEL			= $"models/weapons/rspn101/w_rspn101.mdl"
const asset MILITIA_GRUNT_MODEL			= $"models/humans/grunts/mlt_grunt_rifle.mdl"
const asset STRATON_MODEL 				= $"models/vehicle/straton/straton_imc_gunship_01.mdl"

const asset PROWLER_MODEL				= $"models/creatures/prowler/r2_prowler.mdl"

const asset BT_IDLE_COLLISION_2			= $"models/titans/buddy/bt_battery_idle_2_static.mdl"
const asset BT_IDLE_COLLISION_3			= $"models/titans/buddy/bt_battery_idle_3_static.mdl"

const asset USE_DUMMY_MODEL				= $"models/domestic/light_switch_touchscreen.mdl"
const asset BATTERY_SLOT_OUTLINE_MODEL	= $"models/titans/buddy/ar_battery.mdl"

const asset RICHTER_WILDS_MODEL 		= $"models/Humans/heroes/imc_hero_richter.mdl"
const asset BLISK_WILDS_MODEL 			= $"models/Humans/heroes/imc_hero_blisk.mdl"
const asset GRUNT_EAR_MODEL		 		= $"models/props/grunt_ear/prop_grunt_ear_animated.mdl"

const asset SPACE_DEBRIS_MODEL			= $"models/dev/editor_ref.mdl"
const asset SPACE_DEBRIS_TRAIL_FX		= $"droppod_trail"
const asset SPACE_DEBRIS_IMPACT_FX		= $"droppod_impact"
const string SPACE_DEBRIS_IMPACT_SFX	= "Wilds_Scr_SpaceDebrisImpact"

const asset FX_POD_LASER 				= $"P_pod_scan_laser_FP"

const float MIN_WALLRUN_TIME = 0.5
const float MIN_WALLRUN_LENGTH = 48	// this is to stop players from just hanging on a wall and having the cailbration start
const float MIN_WALLRUN_NEAR_DIST = 128
const float WALLRUN_CALIBRATION_SPEED = 0.075	// 65need to match the one in jump_jet_calibration.rui
const float WALLRUN_FALL_TIMEOUT = 1.25

const float NIGHT_DAY_OFFSET = 12288

// need to match the number of string in calibrationStepArray on the client.
const int JUMPKIT_CALIBRATION_STEPS = 14

const string RUMBLE_SOUND = "boomtown_preashfight_rockexplosion"

global struct EntityLevelStruct
{
	bool dialoguePlaying = false
	float dialogueCompleted = 0
	vector pos
	entity script_weapon
	bool noBroadcast = false
	bool forceBroadcast = false
	entity waypointTrigger
	bool triggered = false
	entity useDummy
	entity BTHightlightModel
}

global struct LineSegment
{
	vector start
	vector end
}

struct
{
	entity vanquishedTitan
	entity buddyTitan
	entity ogPilot
	string oldBTTitle
	entity battery
	entity batteryCarryFx
	array<entity> highlightObjectArray
	int imcSpectreCap = 6
	int militiaGruntCap = 5
	int firstGhostId = -1
	int path2GhostId = -1
	int doubleJumpGhostId = -1
	float wallrunCalibrationProgress = 0.0
	int batteriesInstalled = 0
	array<entity> quickDeathEntArray
	array<LineSegment> wallrunSegmentArray
	array<LineSegment> currentWallrunSegmentArray
	float wallrunStartTime
	vector wallrunStartOrigin
	int wallrunStatusFlag
	int jumpKitCalibrationStep = 0
	array<entity> marchingSpectreArray
	array<entity> friendlyFloodSpawnerArray
	entity bliskTitan
	entity sloanTitan
	entity roninTitan
	array<array> droneDialogArray
	int waveEnemyCount = 0
	int vortexUsage = 0
	int missileUsage = 0
	float lastTimeWeaponFired = 0
	entity rockCluster
	entity tallGrass
	entity groundLeafy
	entity greenPlant
	int statusEffect_turnSlow
	entity buddyTitanCollision
	float dvsScaleMinDefault = 0.5
} file

void function CodeCallback_MapInit()
{
	printt( "*********** CRASH SITE ***********" )

	// initiate dialogues
	ShSpWildsCommonInit()

	// most if not all of these flags doesn't require initialization in script.
	// There are here so that I can omit layers when I export geo for quick compiles and not get script errors.

	// Flags initiated due to usage in LevelEd
	// should be able to remove these from the script
	FlagInit( "hatch_blown" )
	FlagInit( "start_intro_combat" )
	FlagInit( "flyby_go" )
	FlagInit( "flyby_kill" )
	FlagInit( "ditch_debris_start" )
	FlagInit( "start_imc_reinforcement" )
	FlagInit( "start_player_moved_up" )
	FlagInit( "disable_flood_spawn" )

	FlagInit( "bt_intro_moveup" )
	FlagInit( "bt_intro_start" )

	FlagInit( "pause_battery_nag" )
	FlagInit( "BuddyTitanspaFlyout" )
	FlagInit( "battery_tracker1_completed" )
	FlagInit( "give_wallrun" )
	FlagInit( "give_doublejump" )
	FlagInit( "forward_ship_entrance" )
	FlagInit( "calibration_possible" )

	FlagInit( "slot_battery2_begin" )
	FlagInit( "slot_battery2" )
	FlagInit( "slot_battery3_begin" )
	FlagInit( "slot_battery3" )

	FlagInit( "battery2_see_ship" )
	FlagInit( "battery2_see_light" )

	FlagInit( "battery2_combat" )
	FlagInit( "battery2_combat_custom_chatter" )
	FlagInit( "battery2_combat_upper_area" )
	FlagInit( "battery2_combat_zipline_landing" )
	FlagInit( "battery2_combat_cave_entrance" )
	FlagInit( "combat_canyon_lowerleft_cleared" )

	FlagInit( "battery2_combat_enter_cave" )
	FlagInit( "battery2_combat_prowler_attack" )
	FlagInit( "battery2_combat_sniper_attack" )
	FlagInit( "battery2_cave_dropdown_force" )
	FlagInit( "exit_combat_cave" )

	FlagInit( "battery2ship_enter" )
	FlagInit( "battery2ship_info" )
	FlagInit( "battery2ship_crawl_space" )
	FlagInit( "battery2ship_enable_loop_blocker" )
	FlagInit( "battery2ship_enable_backtrack_blocker" )
	FlagInit( "battery2_acquired" )
	FlagInit( "postshipprowlers_music_cue" )
	FlagInit( "battery2_crossed_river" )
	FlagInit( "battery_tracker2_commence" )
	FlagInit( "battery_tracker2_completed" )

	FlagInit( "rock_block_done" )
	FlagInit( "bat2_path_hint_active" )
	FlagInit( "path_hint_enemies_dead" )
	FlagInit( "hint_prowlers_dead" )

	FlagInit( "bat2_path_hint_drone_escape" )
	FlagInit( "first_wallrun_completed" )
	FlagInit( "stop_spectre_floodspawn" )

	FlagInit( "path2_canyon_combat" )
	FlagInit( "battery3_canyon_encounter_pilot_landing" )
	FlagInit( "bat3path_dialog" )
	FlagInit( "battery3_acquired" )
	FlagInit( "battery3_canyon_encounter_start" )
	FlagInit( "battery3_combat_ledge" )
	FlagInit( "battery3_combat_jumped_down" )
	FlagInit( "battery3_combat_upper_area" )
	FlagInit( "conv_ship_survivors" )

	FlagInit( "pilot_link_approach" )
	FlagInit( "bt_ready_for_battery3" )
	FlagInit( "neural_link_complete" )
	FlagInit( "restore_player_control" )
	FlagInit( "tt_drones_close" )

	FlagInit( "force_slide" )
	FlagInit( "show_grenade_hint" )

	// Flags in LevelEd but not initialized automaticaly
	FlagInit( "ditch_cover_destroy" )
	FlagInit( "ditch_cover_done" )

	// Flags not using in LevelEd
	FlagInit( "family_photo_start" )
	FlagInit( "prowler1_dead" )
	FlagInit( "bt_expels_og" )
	FlagInit( "og_final_words" )
	FlagInit( "promoted" )
	FlagInit( "first_ghost" )
	FlagInit( "path2_first_ghost" )
	FlagInit( "path_hint_drone_flown" )
	FlagInit( "player_near_bt" )
	FlagInit( "og_pilot_exited" )
	FlagInit( "TriedEmbark" )
	FlagInit( "ready_for_level_end" )
	FlagInit( "BuddyTitanFlyout" )

	FlagInit( "wallrun_recordings" )
	FlagInit( "doublejump_recordings" )
	FlagInit( "titan_entered" )
	FlagInit( "titan_training_spawn_enemies" )
	FlagInit( "initilize_critical_systems" )
	FlagInit( "titan_training_vortex" )
	FlagInit( "titan_training_rockets" )
	FlagInit( "titan_training_completed" )
	FlagInit( "spawn_final_enemies" )
	FlagInit( "final_fight_won" )

	// signals

	RegisterSignal( "intro_over" )
	RegisterSignal( "aiskit_alertbreakout" ) //?
	RegisterSignal( "blow_hatch" )
	RegisterSignal( "player_leaving_pod" )
	RegisterSignal( "hitting_ground" )
	RegisterSignal( "player_regain_control" )
	RegisterSignal( "clear_always_alert" )
	RegisterSignal( "create_ear" )
	RegisterSignal( "delete_ear" )

	RegisterSignal( "threw_grenade" )
	RegisterSignal( "used_melee" )
	RegisterSignal( "used_cloak" )
	RegisterSignal( "used_vortex" )
	RegisterSignal( "used_missiles" )

	RegisterSignal( "vanquished_titan_landed" )
	RegisterSignal( "bt_stash_player" )
	RegisterSignal( "bt_knocked_down" )
	RegisterSignal( "blisk_intro_over" )
	RegisterSignal( "music_cue" )
	RegisterSignal( "blackout_music_end" )

	RegisterSignal( "og_pilot_hits_ground" )
	RegisterSignal( "helmet_bootup_commence" )
	RegisterSignal( "helmet_bootup_complete" )
	RegisterSignal( "BuddyTitanFlyoutComplete" )

	RegisterSignal( "battery_pickup_music_cue" )
	RegisterSignal( "battery_pickup" )
	RegisterSignal( "battery_destroy" )
	RegisterSignal( "stop_surprise_attack" )
	RegisterSignal( "drone_broadcast_completed" )

	RegisterSignal( "combat_started" )
	RegisterSignal( "full_health_recovered" )

	RegisterSignal( "wallrun_started" )
	RegisterSignal( "wallrun_ended" )
	RegisterSignal( "double_jump_confirmed")

	RegisterSignal( "aiskit_forcedeathonskitend" )	// copFied from _ai_skits.nut because I'm using a skit anim in SP
	RegisterSignal( "aiskit_doomed" )				// copied from _ai_skits.nut because I'm using a skit anim in SP
	RegisterSignal( "aiskit_dontbreakout" )			// copied from _ai_skits.nut because I'm using a skit anim in SP

	RegisterSignal( "force_broadcast" )
	RegisterSignal( "hack_enable_offhand" )

	// precache
	PrecacheParticleSystem( FX_SHIP_EXPLOSION )
	PrecacheParticleSystem( FX_POD_LASER )

	PrecacheModel( JACK_MODEL_ARMS )
	PrecacheModel( $"models/weapons/arms/pov_mlt_hero_jack.mdl" )
	PrecacheModel( $"models/humans/heroes/mlt_hero_jack.mdl" )

	PrecacheModel( OG_PILOT_MODEL )
	PrecacheModel( PROWLER_MODEL )
	PrecacheModel( POD_MODEL )
	PrecacheModel( POD_MODEL_POV )
	PrecacheModel( INTRO_CRASH_MODEL )
	PrecacheModel( GRAVE_ROCK_MODEL )
	PrecacheModel( HELMET_MODEL )
	PrecacheModel( USE_DUMMY_MODEL )
	PrecacheModel( BATTERY_SLOT_OUTLINE_MODEL )
	PrecacheModel( MILITIA_GRUNT_MODEL )
	PrecacheModel( RICHTER_WILDS_MODEL )
	PrecacheModel( BLISK_WILDS_MODEL )
	PrecacheModel( GRUNT_EAR_MODEL )
	PrecacheModel( STRATON_MODEL )
	PrecacheModel( BATTERY_MODEL )
	PrecacheModel( BT_IDLE_COLLISION_2 )
	PrecacheModel( BT_IDLE_COLLISION_3 )

	PrecacheModel( $"models/props/rocks/rock_cluster_sm_02_animated.mdl" )
	PrecacheModel( $"models/props/foliage/tall_grass_animated.mdl" )
	PrecacheModel( $"models/props/foliage/ground_leafy_01_animated.mdl" )
	PrecacheModel( $"models/props/foliage/dark_green_plant_sm_02_animated.mdl" )

	// global callbacks
	AddSpawnCallback_ScriptName( "clear_quick_death", ClearQuickDeathTrigger )
	AddSpawnCallback_ScriptName( "ambient_flyer", CreateAmbientFlyer )
	AddSpawnCallback_ScriptName( "space_debris_trigger", SpaceDebrisTrigger )
	AddSpawnCallback_ScriptName( "quake_trigger", QuakeTriggerThink )
	AddSpawnCallback_ScriptName( "flyby_func_brush", FlybyFuncBrush )
	AddSpawnCallback_ScriptName( "friendly_floodspawner_trigger", FriendlyFloodSpawnerTrigger )
	AddSpawnCallback_ScriptName( "nighttime_random_explosion", RandomExplosionSetup )
	AddSpawnCallback_ScriptName( "broadcast_drone_trigger", DroneBroadcastTriggerThink )
	AddSpawnCallback_ScriptName( "battery3_turret", Battery3Turret )
	AddSpawnCallback_ScriptName( "trigger_delete", TriggerDeleteSetup )
	AddSpawnCallback_ScriptName( "dead_bodies_dynamic", AddHighlightObject )
	AddSpawnCallback_ScriptName( "trigger_force_stand", TriggerForceStand )
	AddSpawnCallback_ScriptName( "wilds_prowler", WildsProwlerSettings )
	AddSpawnCallback_ScriptName( "foliage_trigger", FoliageTriggerSetup )


	AddSpawnCallback( "npc_soldier", MilitiaGruntSettings )
	AddSpawnCallback( "script_mover", RefCreateCallback )
	AddSpawnCallback( "npc_spectre", NightTimeSpectreSettings )

	AddTriggerEditorClassFunc( "trigger_quickdeath", QuickDeathTriggerNPC )

	AddClientCommandCallback( "IntroOver", ClientCommand_IntroOver )
	AddClientCommandCallback( "HelmetBootUpComplete", ClientCommand_HelmetBootUpComplete )
	AddClientCommandCallback( "BuddyTitanFlyoutComplete", ClientCommand_BuddyTitanFlyoutComplete )

	AddClientCommandCallback( "NeuralLinkComplete", ClientCommand_NeuralLinkComplete )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddPlayerDidLoad( PlayerDidLoad )

	AddDamageCallbackSourceID( eDamageSourceId.burn, DamageCallbackBurn )

	#if DEV
	AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_quickdeath_checkpoint", TestQuickDeathInit )
	#endif // DEV

	#if CONSOLE_PROG
	file.dvsScaleMinDefault = GetConVarFloat( "dvs_scale_min" )
	#endif // CONSOLE_PROG

	// init flyers
	FlyersShared_Init()

	// startpoints
	AddStartPoint( "LevelStart", StartPoint_LevelStart, StartPoint_Setup_LevelStart, StartPoint_Skip_LevelStart )

	AddStartPoint( "BT_Intro", StartPoint_BTIntro, StartPoint_Setup_BTIntro, StartPoint_Skip_BTIntro )
	AddStartPoint( "Blisk_Intro", StartPoint_BliskIntro, StartPoint_Setup_BliskIntro, StartPoint_Skip_BliskIntro )
	AddStartPoint( "FamilyPhoto", StartPoint_FamilyPhoto, StartPoint_Setup_FamilyPhoto, StartPoint_Skip_FamilyPhoto )
	AddStartPoint( "Waking_Up", StartPoint_WakingUp, StartPoint_Setup_WakingUp, StartPoint_Skip_WakingUp )
	AddStartPoint( "Field_Promotion", StartPoint_FieldPromotion, StartPoint_Setup_FieldPromotion, StartPoint_Skip_FieldPromotion )
	AddStartPoint( "Grave", StartPoint_Grave, StartPoint_Setup_Grave, StartPoint_Skip_Grave )

	AddStartPoint( "Battery2_Path", StartPoint_Battery2Path, StartPoint_Setup_Battery2Path, StartPoint_Skip_Battery2Path )
	AddStartPoint( "Battery2_Combat", StartPoint_Battery2Combat, StartPoint_Setup_Battery2Combat, StartPoint_Skip_Battery2Combat )
	AddStartPoint( "Battery2_Ship", StartPoint_Battery2Ship, StartPoint_Setup_Battery2Ship, StartPoint_Skip_Battery2Ship )

	AddStartPoint( "Battery3_Path", StartPoint_Battery3Path, StartPoint_Setup_Battery3Path, StartPoint_Skip_Battery3Path )
	AddStartPoint( "Battery3_Combat", StartPoint_Battery3Combat, StartPoint_Setup_Battery3Combat, StartPoint_Skip_Battery3Combat )
	AddStartPoint( "Battery3_Ship", StartPoint_Battery3Ship, StartPoint_Setup_Battery3Ship, StartPoint_Skip_Battery3Ship )

	AddStartPoint( "PilotLink", StartPoint_PilotLink, StartPoint_Setup_PilotLink )

	file.firstGhostId = AddMobilityGhost( $"anim_recording/sp_crashsite_wallrun_1.rpak", "first_ghost" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_wallrun_2.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_return_from_prowler_pit.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_wallrun_3_long.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_wallrun_3_short.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_wallrun_4.rpak", "wallrun_recordings" )

	AddMobilityGhost( $"anim_recording/sp_crashsite_spiral_1.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_spiral_2.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_spiral_3.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_spiral_4.rpak", "wallrun_recordings" )

	AddMobilityGhost( $"anim_recording/sp_crashsite_combat_ravine_crossing.rpak", "wallrun_recordings" )
//	AddMobilityGhost( $"anim_recording/sp_crashsite_cave_left.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_cave_exit.rpak", "wallrun_recordings" )

	file.doubleJumpGhostId = AddMobilityGhost( $"anim_recording/sp_crashsite_first_double_jump.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_entering_ship.rpak", "wallrun_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_return_crossing.rpak", "wallrun_recordings" )

	file.path2GhostId = AddMobilityGhost( $"anim_recording/sp_crashsite_start_path_2.rpak", "path2_first_ghost" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_crossing_river.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_doublejump_3.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_doublejump_4.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_doublejump_5.rpak", "doublejump_recordings" )

	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_chained_1.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_chained_2.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_chained_3.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_path2_under_waterfall.rpak", "doublejump_recordings" )

	AddMobilityGhost( $"anim_recording/sp_crashsite_return_final_full.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_return_final_lower_right.rpak", "doublejump_recordings" )
	AddMobilityGhost( $"anim_recording/sp_crashsite_return_final_lower_left.rpak", "doublejump_recordings" )
}

void function EntitiesDidLoad()
{
	printt( "EntitiesDidLoad", Time() )
	//EmitSoundAtPosition( TEAM_UNASSIGNED, <0,0,0>, "sse_Wilds_Intro_MuteUnwanted" )

	GetEntByScriptName( "battery3_path_ramp_down" ).Hide()
	GetEntByScriptName( "battery3_path_ramp_down" ).NotSolid()

	thread EscapePodBroadcast( GetEntByScriptName( "escape_pod_broadcast_1" ), [
		"diag_sp_podChatter_WD741_01_01_mcor_gCaptain1",
		"diag_sp_podChatter_WD741_02_01_mcor_gCaptain2",
		"diag_sp_podChatter_WD741_03_01_mcor_gCaptain1"], 500 )

/*
	thread EscapePodBroadcast( GetEntByScriptName( "escape_pod_broadcast_2" ), [
		"diag_sp_podChatter_WD741_04_01_mcor_grunt1",
		"diag_sp_podChatter_WD741_05_01_mcor_grunt2",
		"diag_sp_podChatter_WD741_06_01_mcor_grunt3"] )
*/

	thread EscapePodBroadcast( GetEntByScriptName( "escape_pod_broadcast_3" ), [
		"diag_sp_podChatter_WD741_07_01_mcor_grunt1",
		"diag_sp_podChatter_WD741_08_01_mcor_grunt1",
		"diag_sp_podChatter_WD741_09_01_mcor_grunt3"], 500 )
}

void function PlayerDidLoad( entity player )
{
	printt( "PlayerDidLoad" )

	// this I think is the earliest we can play sounds on the player
//	EmitSoundOnEntity( player, "sse_Wilds_Intro_MuteUnwanted" )

	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.JUMP, OnPlayerJump )

	SetMobilityGhostDisplayDists( file.firstGhostId, 650, 670 )
	SetMobilityGhostAnalyzedByPlayer( file.firstGhostId, player )
	SetMobilityGhostIgnoreSpeed( file.firstGhostId )

	SetMobilityGhostDisplayDists( file.path2GhostId, 650, 670 )
	SetMobilityGhostAnalyzedByPlayer( file.path2GhostId, player )
	SetMobilityGhostIgnoreSpeed( file.path2GhostId )

	SetMobilityGhostDisplayDists( file.doubleJumpGhostId, 550, 570 )
	SetMobilityGhostAnalyzedByPlayer( file.doubleJumpGhostId, player )
	SetMobilityGhostIgnoreSpeed( file.doubleJumpGhostId )

	entity backtrackBlocker = GetEntByScriptName( "battery3_ship_backtrack_blocker" )
	backtrackBlocker.Hide()
	backtrackBlocker.NotSolid()

	QuickDeathTrigger_SetRealDeathFadeToBlack( player, true )

	thread ForceSlideThink( player )
}

void function OnPlayerJump( entity player )
{
	SetGlobalNetTime( "lastJumpTime", Time() )
}


//	##       ######## ##     ## ######## ##        ######  ########    ###    ########  ########
//	##       ##       ##     ## ##       ##       ##    ##    ##      ## ##   ##     ##    ##
//	##       ##       ##     ## ##       ##       ##          ##     ##   ##  ##     ##    ##
//	##       ######   ##     ## ######   ##        ######     ##    ##     ## ########     ##
//	##       ##        ##   ##  ##       ##             ##    ##    ######### ##   ##      ##
//	##       ##         ## ##   ##       ##       ##    ##    ##    ##     ## ##    ##     ##
//	######## ########    ###    ######## ########  ######     ##    ##     ## ##     ##    ##

void function StartPoint_Setup_LevelStart( entity player )
{
	// this should most likely stay empty
}

void function StartPoint_LevelStart( entity player )
{
	player.EndSignal( "OnDestroy" )

	EnableMorningLight( player )

	// grunts don't rodeo
	Rodeo_Disallow( player )
	SyncedMelee_Disable( player )

	// mangage marching spectres
	AddSpawnCallback_ScriptName( "marching_spectre", MarchinSpectreThink )

	// remove hud for grunt
	player.SetPlayerNetBool( "hideHudIcons", true )
	Remote_CallFunction_Replay( player, "ServerCallback_HideHudIcons" )

	// no grunt chetter that isn't custom, will get reset at the "waking up"
	SetPlayerForcedDialogueOnly( player, true )

	FlagClear( "DeathHintsEnabled" )

	// weapon will be enabled once the player is out of the escape pod
	player.DisableWeapon()
	player.FreezeControlsOnServer()

	#if CONSOLE_PROG
	// This gets cleared when the player hits the ground
	EnableDVSOverride( player )
	#endif

	thread LevelStartAudio( player )
	thread LevelStartSubtitles( player )
	waitthread ShowTitleScreen( player )

	player.UnfreezeControlsOnServer()

	thread PlayerInEscapePod( player )
	thread EscapePodSubtitles( player )
	thread EscapePodFriendlies( player )
	thread SpectreSkit( player )
	thread IntroDitchCrash( player )
	thread NightCrashedShipExplosions( player )
	thread NightAirShow( player )
	thread LevelStart_MilitiaFriendlies( player )
	thread LevelStart_IMCSpectreEnemies( player )
	thread LevelStart_GruntDialogue( player )
	thread ShowGrenadeHint( player )

	player.WaitSignal( "player_leaving_pod" )
	CheckPoint_ForcedSilent()

	#if CONSOLE_PROG
	player.WaitSignal( "hitting_ground" )
	DisableDVSOverride( player )
	#endif

	FlagWait( "start_intro_combat" )
	Objective_Set( "#WILDS_OBJECTIVE_NIGHTTIME", GetEntByScriptName( "nighttime_objective_loc" ).GetOrigin() )
	SetPlayerForcedDialogueOnly( player, false )

	FlagWait( "bt_intro_start" )
}

void function StartPoint_Skip_LevelStart( entity player )
{
	player.SetPlayerNetBool( "hideHudIcons", true )

	// remove clip used to funnel the player for the BT intro
	array<entity> clipArray = GetEntArrayByScriptName( "mantleBlocker" )
	foreach( clip in clipArray )
		clip.Destroy()

	FlagClear( "DeathHintsEnabled" )

	player.SetExtraWeaponMods( ["sp_disable_arc_indicator"] )
	Rodeo_Disallow( player )
	SyncedMelee_Disable( player )
}

void function LevelStartAudio( entity player )
{
	player.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( player, "Duck_Wilds_Intro_MuteUnwanted" )

	wait 3 // delay until respace logo shows
	PlayMusic( "Wilds_Scr_RespawnLogoToPodCrash" )
	PlayMusic( "music_wilds_00_escapepoddrop" )

	player.WaitSignal( "intro_over" )

	//EmitSoundOnEntity( player, "sse_Wilds_Intro_MuteUnwanted" )
	StopMusicTrack( "music_wilds_00_escapepoddrop" )
	PlayMusic( "music_wilds_01_intro" )
	EmitSoundOnEntity( player, "Wilds_Scr_PodIntro" )
	player.WaitSignal( "hitting_ground" )

	//EmitSoundOnEntity( player, "sse_Wilds_Intro_UnmuteUnwanted" )
	StopSoundOnEntity( player, "Duck_Wilds_Intro_MuteUnwanted" )
	SetGlobalNetInt( "nighttimeAmbient", 1 )
	Remote_CallFunction_Replay( player, "ServerCallback_NighttimeAmbient", 1 )

	FlagWait( "bt_intro_moveup" )
	SetGlobalNetInt( "nighttimeAmbient", 2 )
	Remote_CallFunction_Replay( player, "ServerCallback_NighttimeAmbient", 2 )
}

void function LevelStartSubtitles( entity player )
{
	player.EndSignal( "OnDestroy" )

	wait 3
	EmitSoundOnEntity( player, "diag_sub_extra_01" )
	wait 21.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_01" )
	wait 5.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_02" )
	wait 2.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_03" )
	wait 4.0
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_04" )
	wait 3.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_05" )
	wait 1.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_06" )
	wait 4.0
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_07" )
	wait 1.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_08" )
	wait 4.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_09" )
	wait 4.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_10" )
}

void function EscapePodSubtitles( entity player )
{
	player.EndSignal( "OnDestroy" )

	wait 5.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_11" )
	wait 3.8
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_12" )
	wait 4.3
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_13" )
	wait 6.2
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_14" )
	wait 7.5
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_15" )
	wait 2.0
	EmitSoundOnEntity( player, "diag_sub_WildsIntro_16" )
}

void function ShowTitleScreen( entity player )
{
	Remote_CallFunction_Replay( player, "ServerCallback_StartTitleSequence" )
	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	SetConVarInt( "dof_enable", 0 )

	entity titleRef = GetEntByScriptName( "title_ref" )
	player.SetOrigin( titleRef.GetOrigin() )
	player.Hide()
	player.SetParent( titleRef )

	entity skyboxModel = GetEntByScriptName( "intro_skybox_model" )
	skyboxModel.Hide()
	entity skyCam = GetEnt( "sky_cam_title" )

	player.SetSkyCamera( skyCam )

	player.WaitSignal( "intro_over" )

	skyCam.ClearParent()
	player.ClearParent()
	player.SetSkyCamera( GetEnt( "skybox_cam_night" ) ) // night time
	player.Show()
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	SetConVarInt( "dof_enable", 1 )
}

bool function ClientCommand_IntroOver( entity player, array<string> args )
{
	player.Signal( "intro_over" )
	return true
}

void function PlayerInEscapePod( entity player )
{
	player.EndSignal( "OnDestroy" )

	Remote_CallFunction_Replay( player, "ServerCallback_WakingUpInEscapePod" )
	ViewConeZeroInstant( player )

	player.SetInvulnerable()
	player.ContextAction_SetBusy()

	entity escapePod = GetEntByScriptName( "player_escape_pod" )
	entity escapePodPOV = CreatePropDynamic( POD_MODEL_POV, escapePod.GetOrigin(), escapePod.GetAngles() )
	escapePod.Hide()

	entity scriptRef = GetEntByScriptName( "anim_ref_crashpod" )

	entity animRef = CreateOwnedScriptMover( scriptRef )
	entity animRef2 = CreateScriptMover( scriptRef.GetOrigin(), scriptRef.GetAngles() + <0,90,0> )

	FirstPersonSequenceStruct playerSequenceIdle
	playerSequenceIdle.attachment = "ref"
	playerSequenceIdle.teleport = true
	playerSequenceIdle.firstPersonAnim = "ptpov_wilds_escape_pod_wake_idle"
	playerSequenceIdle.thirdPersonAnim = "pt_wilds_escape_pod_wake_idle"
	playerSequenceIdle.viewConeFunction = PlayerInEscapePodViewCone

	thread PlayAnim( escapePod, "escape_pod_wilds_wake_idle", animRef2 )
	thread PlayAnim( escapePodPOV, "escape_pod_wilds_wake_idle", animRef2 )

//	player.SetAnimNearZ(1)

	// Hack: to add a longer delay at the start of the level
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	playerSequenceIdle.teleport = false
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )
	waitthread FirstPersonSequence( playerSequenceIdle, player, animRef )

	FirstPersonSequenceStruct playerSequence
	playerSequence.attachment = "ref"
	playerSequence.firstPersonAnim = "ptpov_wilds_escape_pod_wake"
	playerSequence.thirdPersonAnim = "pt_wilds_escape_pod_wake"
	playerSequence.viewConeFunction = PlayerInEscapePodViewCone

	entity fpProxy = player.GetFirstPersonProxy()

	int attachID = fpProxy.LookupAttachment( "PROPGUN" )

	thread PlayAnim( escapePod, "escape_pod_wilds_wake", animRef2 )
	thread PlayAnim( escapePodPOV, "escape_pod_wilds_wake", animRef2 )
	waitthread FirstPersonSequence( playerSequence, player, animRef )

//	player.ClearAnimNearZ()

	player.Signal( "player_regain_control" )

	player.ClearInvulnerable()
	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.EnableWeaponWithSlowDeploy()

	player.SetExtraWeaponMods( ["sp_disable_arc_indicator"] )

	escapePodPOV.Destroy()
	animRef.Destroy()
	animRef2.Destroy()

	escapePod.Show()
	wait 5

	FlagSet( "start_intro_combat" )
}

void function EscapePodFirstPersonSequence( FirstPersonSequenceStruct escapePodSequence, entity escapePod, entity player, entity animRef )
{
	player.EndSignal( "OnDestroy" )
	escapePod.EndSignal( "OnDestroy" )
	animRef.EndSignal( "OnDestroy" )

	waitthread FirstPersonSequence( escapePodSequence, escapePod, animRef )
}

void function PlayerInEscapePodViewCone( entity player )
{
	player.PlayerCone_SetLerpTime( 0.0 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -35 )		//-35
	player.PlayerCone_SetMaxYaw( 35 )		//35
	player.PlayerCone_SetMinPitch( -25 )	//-25
	player.PlayerCone_SetMaxPitch( 25 )		//25
}

void function EscapePodFriendlies( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity escapePod = GetEntByScriptName( "grunt_escape_pod" )
	entity escapePodGuy = SpawnFromSpawner( GetEntByScriptName(  "escape_pod_militia_guy" ) )
	entity escapePodHelper = SpawnFromSpawner( GetEntByScriptName(  "escape_pod_militia_helper" ) )
	escapePodHelper.NotSolid()

	Assert( IsValid( escapePod ) )
	Assert( IsValid( escapePodGuy ) )
	Assert( IsValid( escapePodHelper ) )

	escapePodGuy.SetInvulnerable()
	escapePodHelper.SetInvulnerable()
	escapePodGuy.SetNoTarget( true )
	escapePodHelper.SetNoTarget( true )

	entity scriptRef = GetEntByScriptName( "anim_ref_escape_pod_militia" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	animRef.SetAngles( animRef.GetAngles() + <0,90,0> )
	scriptRef.SetAngles( scriptRef.GetAngles() + <0,180,0> )

	thread PlayAnimTeleport( escapePod, "mcor_pod02_wilds_escapepod_idle", scriptRef )
	thread PlayAnimTeleport( escapePodGuy, "pt_gruntA_wilds_escapepod_idle", animRef )
	thread PlayAnimTeleport( escapePodHelper, "pt_gruntB_wilds_escapepod_idle", animRef )

//	player.WaitSignal( "player_leaving_pod" )
	player.WaitSignal( "blow_hatch" )
	wait 4.0 //6.3

	escapePodHelper.SetNoTarget( false )

	thread PlayAnimTeleport( escapePod, "mcor_pod02_wilds_escapepod", scriptRef )
	thread PlayAnimTeleport( escapePodGuy, "pt_gruntA_wilds_escapepod", animRef )
	if ( IsValid( escapePodHelper ) )
	{
		waitthread PlayAnimTeleport( escapePodHelper, "pt_gruntB_wilds_escapepod", animRef )
		escapePodHelper.Solid()
	}

	escapePodGuy.SetNoTarget( false )
	escapePodGuy.ClearInvulnerable()
	escapePodHelper.ClearInvulnerable()
}

void function SpectreSkit( entity player )
{
	player.WaitSignal( "blow_hatch" )

	entity spectre = SpawnFromSpawner( GetEntByScriptName( "synced_melee_spectre" ) )
	entity grunt = SpawnFromSpawner( GetEntByScriptName( "synced_melee_grunt" ) )

	spectre.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2, false )
	spectre.DisableNPCFlag( NPC_ALLOW_PATROL )
	spectre.SetLookDistOverride( 256 )
	spectre.SetNoTarget( true )
	spectre.SetEnemy( grunt )

	grunt.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2, false )
	grunt.DisableNPCFlag( NPC_ALLOW_PATROL )
	grunt.SetCapabilityFlag( bits_CAP_INITIATE_SYNCED_MELEE, false )

	player.WaitSignal( "player_leaving_pod" )
	spectre.DisableLookDistOverride()
	spectre.SetEnemy( player )
	spectre.kv.WeaponProficiency = eWeaponProficiency.POOR

	spectre.EndSignal( "OnDeath" )

	printt( "start death protection" )
	AddDamageCallback( "player", EscapePodDeathProtection )

	OnThreadEnd(
		function() : ()
		{
			RemoveDamageCallback( "player", EscapePodDeathProtection )
		}
	)

	player.WaitSignal( "hitting_ground" )
	spectre.SetNoTarget( false )

	wait 10 //only give protection for a limited time.
	printt( "end death protection" )
}

void function EscapePodDeathProtection( entity player, var damageInfo )
{
	float scalar = 1.0 / GetDamageScalarByDifficulty()
	DamageInfo_ScaleDamage( damageInfo, scalar )

	if ( player.GetHealth() < player.GetMaxHealth() / 3 )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
	}
}

void function NightAirShow( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "start_intro_combat" )
	wait 2

	thread StratonFlyBy( 0, "ht_Haven_FlyBy_Attacker_1", GetEntByScriptName( "anim_ref_straton1_flyby" ) )
	thread StratonFlyBy( 1.5, "ht_Haven_FlyBy_Attacker_2", GetEntByScriptName( "anim_ref_straton2_flyby" ) )

	thread CreateExplosionChain( "flyby_explosion_chain_1", 3.5 )
	thread CreateExplosionChain( "flyby_explosion_chain_2", 4.5 )

	FlagWait( "start_player_moved_up" )
	wait 5

	entity animRef = GetEntByScriptName( "anim_ref_dropship_1_night" )
	entity dropship = SpawnNPCByClassname( "npc_dropship", TEAM_IMC, <0,0,1000>, <0,0,0> )
	dropship.EndSignal( "OnDestroy" )

	waitthread PlayAnimTeleport( dropship, "ds_beacon_flyin_3_shipA", animRef )
	dropship.Destroy()
}

void function StratonFlyBy( float delay, string animation, entity animRef )
{
	wait delay
	entity straton = CreatePropDynamic( STRATON_MODEL )
	waitthread PlayAnimTeleport( straton, animation, animRef )
	straton.Destroy()
}

void function CreateExplosionChain( string name, float initialDelay = 0 )
{
	const float delayMultiplier = 0.15

	wait initialDelay

	entity ent = GetEntByScriptName( name )
	while( true )
	{
		vector origin = ent.GetOrigin()
		StartParticleEffectInWorld( GetParticleSystemIndex( FLYBY_EXPLOSION_FX ), ent.GetOrigin(), ent.GetAngles() )
		EmitSoundAtPosition( TEAM_MILITIA, ent.GetOrigin(), FLYBY_EXPLOSION_SFX )

		Explosion(
			origin,
			ent,						// attacker
			ent,						// inflictor
			30, 						// normal damage
			30, 						// heavy armor damage
			32, 						// inner radius
			256,  						// outer radius
			SF_ENVEXPLOSION_NO_DAMAGEOWNER,
			origin,
			1000,						// force
			damageTypes.explosive,
			eDamageSourceId.burn,
			"" )

		array<entity> entArray = ent.GetLinkEntArray()
		if ( entArray.len() == 0 )
			break
		ent = entArray[0]

		float dist = Distance( ent.GetOrigin(), origin )
		float delay = ( dist / 250.0 ) * delayMultiplier	// 250 is an average distance between explosions
		wait delay
	}
}

void function NightCrashedShipExplosions( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( "bt_intro_start" )

	int particleID = GetParticleSystemIndex( FX_SHIP_EXPLOSION )

	// this pattern is good for the while the player is in the pod
	array<float> delayArray = [ 6.0, 0.75, 7, 2, 8, 2, 15, 0.5, 1 ]
	array<entity> entArray = GetEntArrayByScriptName( "night_ship_explosion_fx_info_target" )

	while( true )
	{
		foreach( delay in delayArray )
		{
			wait delay	// do delay first
			entity ent = entArray.getrandom()
			vector origin = ent.GetOrigin()
			vector angles = ent.GetAngles()
			StartParticleEffectInWorld( particleID, origin, angles )

			float dist =  Distance( origin, player.GetOrigin() )
			float soundDelay = dist / 13503 // speed of spound
			float shakeMultiplier = 8000 / dist
			thread DelaySound( player, soundDelay, "Wilds_Scr_MacAllan_Explo_Dist", origin )
			thread DelayShake( player, soundDelay, shakeMultiplier )
		}
		delayArray.randomize()
	}
}

void function IntroDitchCrash( entity player )
{
	player.EndSignal( "OnDestroy" )

	GetEntByScriptName( "ditch_debris1" ).Hide()
	GetEntByScriptName( "ditch_debris2" ).Hide()
	GetEntByScriptName( "ditch_debris3" ).Hide()

	FlagWait( "ditch_debris_start" )

	entity startPos = GetEntByScriptName( "intro_crash_start" )
	entity debris = CreatePropDynamicLightweight( INTRO_CRASH_MODEL, startPos.GetOrigin(), startPos.GetAngles(), 6, 9000 )

	entity trig = GetEntByScriptName( "ditch_trigger" )

	trig.SetParent( debris )
	trig.ConnectOutput( "OnStartTouch", DitchDebrisTriggerHurt )

	thread MoveAlongPath( debris, "intro_crash_start" )
	thread IntroDitchCrashAudio( debris )

	FlagWait( "ditch_cover_destroy" )
	Remote_CallFunction_Replay( player, "ServerCallback_RumblePlay", 0 )

	wait 0.15
	GetEntByScriptName( "ditch_cover1" ).Destroy()
	GetEntByScriptName( "ditch_debris1" ).Show()
	wait 0.20
	GetEntByScriptName( "ditch_cover2" ).Destroy()
	GetEntByScriptName( "ditch_debris2" ).Show()
	wait 0.25
	GetEntByScriptName( "ditch_cover3" ).Destroy()
	GetEntByScriptName( "ditch_debris3" ).Show()

	FlagWait( "ditch_cover_done" )
	trig.Destroy()
}

void function IntroDitchCrashAudio( entity debris )
{
	wait 2 //tune to be 1.5 sec before the impact
	EmitSoundOnEntity( debris, "Wilds_Scr_NPCPodCrash" )
	FlagWait( "ditch_cover_destroy" )
	EmitSoundOnEntity( debris, "Wilds_Scr_NPCPodCrashDebris" )
}

void function DitchDebrisTriggerHurt( entity self, entity activator, entity caller, var value )
{
	if ( IsAlive( activator ) )
	{
		if ( activator.IsNPC() )
		{
			vector velocity = self.GetVelocity()
			velocity = velocity *25
			velocity.z = velocity.z * -4
			if ( !activator.BecomeRagdoll( velocity, false ) )
				activator.Die()
		}
		else if ( activator.IsPlayer() )
		{
			activator.Die()
		}
	}
}

void function LevelStart_MilitiaFriendlies( entity player )
{
	player.EndSignal( "OnDestroy" )

	player.WaitSignal( "blow_hatch" )

	array<entity> spawnerArray = GetSpawnerArrayByScriptName( "levelstart_militia_grunt" )
	array<entity> npcArray = SpawnFromSpawnerArray( spawnerArray )

	foreach( npc in npcArray )
	{
		npc.SetInvulnerable()
	}

	FlagWait( "start_player_moved_up" )

	foreach( npc in npcArray )
	{
		if ( !IsAlive( npc ) )
			continue

		npc.ClearInvulnerable()
	}

	file.militiaGruntCap = 5
	thread FriendlyGruntCountManagement( player )

	FlagWait( "bt_intro_moveup" )

	file.militiaGruntCap = 3
}

void function FriendlyGruntCountManagement( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( "bt_intro_start" )

	int spawnIndex = 0
	const float minTimeBelowCount = 0 //disable spacing
	float belowCoundTime = -1

	while( true )
	{
		wait 1
		array<entity> npcArray = GetNPCArrayEx( "npc_soldier", TEAM_MILITIA, -1, player.GetOrigin(), -1 )

		if ( npcArray.len() < file.militiaGruntCap && !Flag( "disable_flood_spawn" ) )
		{
			if ( belowCoundTime < 0 )
				belowCoundTime = Time()
			if ( Time() < belowCoundTime + minTimeBelowCount )
				continue

			file.friendlyFloodSpawnerArray.randomize()
			int spawnCount = minint( file.militiaGruntCap - npcArray.len(), file.friendlyFloodSpawnerArray.len() )
			for( int i = 0; i < spawnCount; i++ )
			{
				entity spawner = file.friendlyFloodSpawnerArray[i]
				entity npc = SpawnFromSpawner( file.friendlyFloodSpawnerArray[i] )
				array<entity> linkParentArray = npc.GetLinkParentArray()
				foreach( linkParent in linkParentArray )
					linkParent.UnlinkFromEnt( npc )
			}
			belowCoundTime = -1
		}
		else if ( npcArray.len() > file.militiaGruntCap )
		{
			npcArray = ArrayFarthest( npcArray, player.GetOrigin() )
			for ( int i = 0; i < npcArray.len(); i++ )
			{
				if ( PlayerCanSee( player, npcArray[i], true, 80 ) )
					continue

				npcArray[i].Die()
				wait RandomFloatRange( 1, 3 )
				break
			}
		}
	}
}

void function FriendlyFloodSpawnerTrigger( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )
	array<entity> spawnerArray = trigger.GetLinkEntArray()

	while( true )
	{
		trigger.WaitSignal( "OnTrigger" )
		file.friendlyFloodSpawnerArray = spawnerArray
	}
}

void function SpectreCountManagement( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( "stop_spectre_floodspawn" )

	array<entity> floodSpawnerArray = GetEntArrayByScriptName( "enemy_floodspawner" )
	int spawnIndex = 0
	int spawns = 0
	float spawnDelay = 0

	while( true )
	{
		array<entity> npcArray = GetNPCArrayEx( "npc_spectre", TEAM_IMC, -1, player.GetOrigin(), -1 )
		if ( npcArray.len() < file.imcSpectreCap )
		{
			wait spawns

			npcArray = GetNPCArrayEx( "npc_spectre", TEAM_IMC, -1, player.GetOrigin(), -1 )

			floodSpawnerArray.randomize()
			int spawnCount = minint( file.imcSpectreCap - npcArray.len(), floodSpawnerArray.len() )
			for( int i = 0; i < spawnCount; i++ )
			{
				entity spawner = floodSpawnerArray[i]
				entity npc = SpawnFromSpawner( floodSpawnerArray[i] )
				array<entity> linkParentArray = npc.GetLinkParentArray()
				npc.AssaultSetFightRadius( 750 )
				foreach( linkParent in linkParentArray )
					linkParent.UnlinkFromEnt( npc )
				spawns++
				wait i+1	// wait between spawns
			}
		}

		wait 1
	}
}

void function LevelStart_GruntDialogue( entity player )
{
	player.EndSignal( "OnDestroy" )

	//	Are we near the drop zone?
	//	We are way off target.
	//	We are the target.
	AddGruntConversation( player, [
		"diag_sp_intro_WD104_01_01_mcor_grunt1",
		"diag_sp_intro_WD104_02_01_mcor_grunt2",
		"diag_sp_intro_WD104_03_01_mcor_grunt3",
	], "hatch_blown", 7, "start_player_moved_up" )

	//	I can't find a landmark.
	//	I can't see who's shooting at us.
	AddGruntConversation( player, [ "diag_sp_intro_WD104_04_01_mcor_grunt4",
		"diag_sp_intro_WD104_05_01_mcor_grunt5",
	], "hatch_blown", 20, "start_player_moved_up" )

	//	Spectres.
	//	Watch out. Spectres.
	//	Where the hell's our Titan support?!
	AddGruntConversation( player, [ "diag_sp_intro_WD104_07_01_mcor_grunt2",
		"diag_sp_intro_WD104_08_01_mcor_grunt3",
		"diag_sp_intro_WD103_03_01_mcor_grunt3",
	], "start_player_moved_up", 0, "bt_intro_moveup" )

	//	Get on the radio.
	//	I'm trying.
	//	(into radio) Home Plate, this is Badger One-One, Echo Company, 41st Militia Rifle Battalion,
	//	we are from the carrier James MacAllan! We've been shot down. Do you read, over!
	AddGruntConversation( player, [ "diag_sp_intro_WD104_11_01_mcor_grunt2",
			"diag_sp_intro_WD104_12_01_mcor_grunt3",
			"diag_sp_intro_WD101_02_01_mcor_grunt2",
	], "start_player_moved_up", 10, "bt_intro_moveup" )

	//	Partlow's hit - Dixon, give me cover.
	//	I can't give myself cover. (ALT - I can't. I'm already covering half the platoon.)
	AddGruntConversation( player, [ "diag_sp_intro_WD104_17_01_mcor_grunt4",
			"diag_sp_intro_WD104_18_01_mcor_grunt5",
	], "start_player_moved_up", 15, "bt_intro_moveup" )

	//	No one's responding. We're on our own down here.
	//	Who's left? Who's in charge?
	//	We need Titans.
	//	Just keep firing.
	AddGruntConversation( player, [ "diag_sp_intro_WD104_19_01_mcor_grunt1",
			"diag_sp_intro_WD104_20_01_mcor_grunt2",
			"diag_sp_intro_WD104_21_01_mcor_grunt3",
			"diag_sp_intro_WD104_22_01_mcor_grunt4",
	], "start_player_moved_up", 25, "bt_intro_moveup" )

	//	The Spectres keep coming. Where are they coming from?
	//	They're trying to corner us.
	//	We can't let them pin us down. We need to move.
	//	We can't stay here. Move. Move.
	//	We'll have to shoot our way out of this.
	//	Keep moving forward.
	AddGruntConversation( player, [ "diag_sp_intro_WD104_23_01_mcor_grunt5",
			"diag_sp_intro_WD104_24_01_mcor_grunt1",
			"diag_sp_intro_WD104_25_01_mcor_grunt2",
			"diag_sp_intro_WD104_26_01_mcor_grunt3",
			"diag_sp_intro_WD104_27_01_mcor_grunt4",
			"diag_sp_intro_WD104_28_01_mcor_grunt5",
	], "bt_intro_moveup", 0, "bt_intro_start" )


	array<string> militiaGruntChatter = [
		//	I can't see anything.
		"diag_sp_intro_WD104_06_01_mcor_grunt1",
		//	Spectres everywhere! We're in danger of being overrun! Return fire return fire!
		"diag_sp_intro_WD103_06_01_mcor_grunt3",
		//	None of this was in our briefing.
		"diag_sp_intro_WD104_09_01_mcor_grunt5",
		//	Grab a gun. Shoot. (ALT - Grab a gun and shoot.)
		"diag_sp_intro_WD104_10_01_mcor_grunt1",
		//	Where's SRS?
		"diag_sp_intro_WD104_13_01_mcor_grunt5",
		//	Where's Commander Briggs?
		"diag_sp_intro_WD104_14_01_mcor_grunt1",
		//	Watch ouuut! Spectrrrres!
		"diag_sp_intro_WD103_01_01_mcor_grunt1",
		//	Back up! Back up!
		"diag_sp_intro_WD103_02_01_mcor_grunt2",
		//	Fire at the Spectres.
		"diag_sp_intro_WD104_15_01_mcor_grunt2",
		//	Calero's down.
		"diag_sp_intro_WD104_16_01_mcor_grunt3",
	]

	player.WaitSignal( "blow_hatch" )
	FlagSet( "hatch_blown" )

	FlagWait ( "start_intro_combat" )

	thread MilitiaGruntChatterThread( player, militiaGruntChatter, "stop_spectre_floodspawn" )

	FlagWait ( "ditch_debris_start" )
	wait 2

	//	INCOMING DEBRIIIIS!! MOVE MOOO<VE>!
	//	Move it! Move it! We're inside the debris impact field!!! Go! <Go! (impact death effort sound) >
	waitthread ForceGruntDialog( player, "diag_sp_intro_WD103_05_01_mcor_grunt2" )
	waitthread ForceGruntDialog( player, "diag_sp_intro_WD103_04_01_mcor_grunt1" )

	FlagWait ( "stop_spectre_floodspawn" )
	//	Do we have any Pilots in the area?
	//	This is Captain Lastimosa - I got a fix on your location. On my way.
	waitthread ForceGruntDialog( player, "diag_sp_intro_WD104_29_01_mcor_grunt6", false )
	EmitSoundOnEntity( player, "diag_sp_intro_WD104_30_01_mcor_og" )

	FlagWait ( "bt_intro_start" )
	//	Hostile Titan, hostile Titan --- Ruuun!
	//	That's a mercenary Titan! Apex Predators!  What the hell are they doing here?
	waitthread ForceGruntDialog( player, "diag_sp_intro_WD103_07_01_mcor_grunt1", false )
	waitthread ForceGruntDialog( player, "diag_sp_intro_WD103_08_01_mcor_grunt1", false )
}

void function ForceGruntDialog( entity player, string dialogue, bool endOnDeath = true )
{
	if ( endOnDeath )
	{
		entity grunt = GetClosestNPC( player.GetOrigin() )
		if ( !IsValid( grunt ) )
			return

		grunt.EndSignal( "OnDestroy" )

		grunt.l.dialoguePlaying = true
		PlayDialogue( dialogue, grunt )
		grunt.l.dialoguePlaying = false
		grunt.l.dialogueCompleted = Time()
	}
	else
	{
		entity grunt = GetClosestNPC( player.GetOrigin() )
		vector pos
		if ( IsValid( grunt ) && Distance( player.GetOrigin(), grunt.GetOrigin() ) < 512 )
			pos = grunt.GetOrigin()
		else
			pos = player.GetOrigin() + player.GetForwardVector() * -256

		float duration = EmitSoundAtPosition( TEAM_UNASSIGNED, pos, dialogue )
		printt( dialogue, duration )
		wait duration
	}
}

void function MilitiaGruntChatterThread( entity player, array<string> chatterArray, string endFlag )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( endFlag )

	const float minDelay = 7.0
	const float maxDelay = 14.0

	for ( int i = 0; i < chatterArray.len(); i++ )
	{
		waitthread PlayDialogueFromClosestGrunt( chatterArray[i], player )
		wait RandomFloatRange( minDelay, maxDelay )
	}
}

void function AddGruntConversation( entity player, array<string> lineArray, string waitFlag, float delay, string endFlag )
{
	thread GruntConversationThread( player, lineArray, waitFlag, delay, endFlag )
}

void function GruntConversationThread( entity player, array<string> lineArray, string waitFlag, float delay, string endFlag )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( endFlag )

	FlagWait( waitFlag )
	wait delay

	for ( int i = 0; i < lineArray.len(); i++ )
	{
		waitthread PlayDialogueFromClosestGrunt( lineArray[i], player )
	}
}

void function LevelStart_IMCSpectreEnemies( entity player )
{
	player.EndSignal( "OnDestroy" )

	player.WaitSignal( "blow_hatch" )

	array<entity> spawnerArray = GetSpawnerArrayByScriptName( "levelstart_first_imc_spectre" )
	array<entity> npcArray = SpawnFromSpawnerArray( spawnerArray )

	foreach( npc in npcArray )
	{
		npc.SetLookDistOverride( 2000 )
	}

	FlagWait( "start_intro_combat" )

	spawnerArray = GetSpawnerArrayByScriptName( "levelstart_imc_spectre" )
	npcArray = SpawnFromSpawnerArray( spawnerArray )

	FlagWait( "start_player_moved_up" )
	thread SpectreCountManagement( player )

	FlagWait( "bt_intro_moveup" )
	file.imcSpectreCap = 3
}

void function NightTimeSpectreSettings( entity spectre )
{
	if ( Flag( "family_photo_start" ) )
		return

	DisableLeeching( spectre )
}

void function MarchinSpectreThink( entity npc )
{
	npc.EndSignal( "OnDestroy" )

	npc.SetNPCMoveSpeedScale( 1.8 )
	npc.EnableNPCFlag( NPC_IGNORE_ALL ) // allowes it to rotate while flying
	npc.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS )

	file.marchingSpectreArray.append( npc )

	table result = WaitSignal( npc, "OnDeath", "maching_spectre_free" )
	if ( result.signal == "OnDeath" )
	{
		foreach( npc in file.marchingSpectreArray )
		{
			if ( IsAlive( npc ) )
				npc.Signal( "maching_spectre_free" )
		}
	}

	if ( !npc.HasKey( "script_noteworthy" ) || npc.kv.script_noteworthy != "" )
		wait float( npc.kv.script_noteworthy ) * 2

	npc.SetNPCMoveSpeedScale( 1.0 )
	npc.DisableNPCFlag( NPC_IGNORE_ALL ) // allowes it to rotate while flying
	npc.DisableNPCMoveFlag( NPCMF_WALK_ALWAYS )
}

void function MilitiaGruntSettings( entity grunt )
{
	if ( grunt.GetTeam() != TEAM_MILITIA )
		return

	Highlight_ClearFriendlyHighlight( grunt )
	ShowName( grunt )
	entity weapon = grunt.GetActiveWeapon()
	if ( weapon.GetWeaponClassName() == "mp_weapon_vinson" )
		weapon.AddMod( "hcog" )
}

void function ShowGrenadeHint( entity player )
{
	player.EndSignal( "OnDestroy" )

	const HINT_DISPLAY_TIME = 8.0

	FlagWait( "show_grenade_hint" )

	while( PlayerInADS( player ) )
		WaitFrame()

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
			if ( IsValid( player ) )
				RemoveButtonPressedPlayerInputCallback( player, IN_OFFHAND0, PlayerThrewGrenade )
		}
	)

	if ( GetGreandeAmmoCount( player ) > 0 )
	{
		AddButtonPressedPlayerInputCallback( player, IN_OFFHAND0, PlayerThrewGrenade )
		DisplayOnscreenHint( player, "grenade_hint" )
		waitthread WaitSignalOrTimeout( player, HINT_DISPLAY_TIME, "threw_grenade" )
		wait 0.5
	}
}

void function PlayerThrewGrenade( entity player )
{
	player.Signal( "threw_grenade" )
}

int function GetGreandeAmmoCount( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_ORDNANCE )
	Assert( IsValid( weapon ) )

	return player.GetWeaponAmmoLoaded( weapon )
}

bool function PlayerInADS( entity player )
{
	entity weapon = player.GetActiveWeapon()
	if ( !IsValid ( weapon ) )
		return false

	return weapon.IsWeaponInAds()
}

//	########  ########    #### ##    ## ######## ########   #######
//	##     ##    ##        ##  ###   ##    ##    ##     ## ##     ##
//	##     ##    ##        ##  ####  ##    ##    ##     ## ##     ##
//	########     ##        ##  ## ## ##    ##    ########  ##     ##
//	##     ##    ##        ##  ##  ####    ##    ##   ##   ##     ##
//	##     ##    ##        ##  ##   ###    ##    ##    ##  ##     ##
//	########     ##       #### ##    ##    ##    ##     ##  #######

void function StartPoint_Setup_BTIntro( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_bt_intro" )
	player.EndSignal( "OnDestroy" )

	EnableMorningLight( player )

	// remove hud for grunt
	Remote_CallFunction_Replay( player, "ServerCallback_HideHudIcons" )

	SetGlobalNetInt( "nighttimeAmbient", 2 )
	Remote_CallFunction_Replay( player, "ServerCallback_NighttimeAmbient", 2 )

	FlagWait( "bt_intro_start" )
}

void function StartPoint_BTIntro( entity player )
{
	player.EndSignal( "OnDestroy" )

	//EmitSoundOnEntity( player, "sse_Wilds_EnemyTitanAmbushBegin" )

	thread LerpPlayerSpeed( player, 1.0, 0.25, 1.5 )

	// no grunt chetter that isn't custom, will get reset at the "waking up"
	SetPlayerForcedDialogueOnly( player, true )

	// remove weapons that can be picked up around the player
	thread DestroyDroppedWeapons( player.GetOrigin(), 512, 3 )

	thread BTIntro_MilitiaGrunts()
	thread BTIntro_Player( player )
	thread BTIntro_EnemyTitan( player )
	thread BTIntro_EnemyTitan2( player )

	player.ForceStand()

	WaitSignal( level, "vanquished_titan_landed" ) //50 frames

	#if CONSOLE_PROG
	// This gets cleared at the end of the waking up
	EnableDVSOverride( player )
	#endif

	Objective_Clear()
	thread CleanUpNPCs()

	entity ogPilot = CreateOGPilot()
	entity buddyTitan = SpawnBT( player, GetEntByScriptName( "bt_spawn_location" ).GetOrigin() )

	AddAnimEvent( buddyTitan, "bt_intro_surprise_attack", AnimEvent_SurpriseAttack )

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )

	thread PlayAnimTeleport( buddyTitan, "BT_wilds_OG_victory_late", scriptRef )
	waitthread PlayAnimTeleport( ogPilot, "OG_wilds_OG_victory_late", scriptRef )

	buddyTitan.TakeOffhandWeapon( 0 )
	buddyTitan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", 0 )

	buddyTitan.ClearInvulnerable()

	player.UnforceStand()

	ogPilot.Destroy()
}

void function StartPoint_Skip_BTIntro( entity player )
{
	// no grunt chetter that isn't custom, will get reset at the "waking up"
	SetPlayerForcedDialogueOnly( player, true )

	#if CONSOLE_PROG
	// This gets cleared at the end of the waking up
	EnableDVSOverride( player )
	#endif

	// spawn BT
	entity buddyTitan = SpawnBT( player, GetEntByScriptName( "bt_spawn_location" ).GetOrigin() )
	entity scriptRef = GetEntByScriptName( "anim_ref_night" )
	thread PlayAnimTeleport( buddyTitan, "BT_first_battery_idle", scriptRef )
}

void function SpawnCoverFoliage( entity player, entity scriptRef, int stage )
{
	player.EndSignal( "OnDestroy" )

	if ( !IsValid( file.rockCluster ) )
	{
		file.rockCluster = CreatePropDynamic( $"models/props/rocks/rock_cluster_sm_02_animated.mdl" )
		file.tallGrass = CreatePropDynamic( $"models/props/foliage/tall_grass_animated.mdl" )
		file.groundLeafy = CreatePropDynamic( $"models/props/foliage/ground_leafy_01_animated.mdl" )
		file.greenPlant = CreatePropDynamic( $"models/props/foliage/dark_green_plant_sm_02_animated.mdl" )
	}

	array<string> rockArray		= [ "prop_family_photo_rocks_fightA", "prop_family_photo_rocks_fightB", "prop_family_photo_rocks"]
	array<string> grassArray	= [ "prop_family_photo_grass_fightA", "prop_family_photo_grass_fightB", "prop_family_photo_grass"]
	array<string> leafArray		= [ "prop_family_photo_leaf_fightA", "prop_family_photo_leaf_fightB", "prop_family_photo_leaf"]
	array<string> plantArray	= [ "prop_family_photo_plant_fightA", "prop_family_photo_plant_fightB", "prop_family_photo_plant"]

	thread PlayAnimTeleport( file.rockCluster, rockArray[stage], scriptRef )
	thread PlayAnimTeleport( file.tallGrass, grassArray[stage], scriptRef )
	thread PlayAnimTeleport( file.groundLeafy, leafArray[stage], scriptRef )
	thread PlayAnimTeleport( file.greenPlant, plantArray[stage], scriptRef )
}

void function DestroyCoverFoliage()
{
	if ( !IsValid( file.rockCluster ) )
	{
		file.rockCluster.Destroy()
		file.tallGrass.Destroy()
		file.groundLeafy.Destroy()
		file.greenPlant.Destroy()
	}
}

void function CleanUpNPCs()
{
	array<entity> npcArray = GetNPCArrayEx( "npc_spectre", TEAM_IMC, -1, <0,0,0>, -1)
	entity node = GetEntByScriptName( "imc_destroy_pos" )
	entity lineEnt = GetEntByScriptName( "spectre_cull_line" ) // <84.976, 6.18271, -12262.2 > <0,15,0>
	vector cullOrigin = lineEnt.GetOrigin()
	vector cullVec = lineEnt.GetForwardVector()

	foreach ( npc in npcArray )
	{
		// destroy right away if they are behind the cull line.
		vector dir = npc.GetOrigin() - cullOrigin
		float dot = DotProduct( dir, cullVec )
		if ( dot > 0 )
		{
			npc.Destroy()
			continue
		}

		npc.SetNoTarget( true )
		thread AssaultMoveTarget( npc, node )
		thread DestroyOnSignal( npc, "destroy_me" )
	}

//	WaitSignal( level, "vanquished_titan_landed" ) //50 frames

	npcArray = GetNPCArrayEx( "npc_soldier", TEAM_MILITIA, -1, <0,0,0>, -1)
	node = GetEntByScriptName( "militia_destroy_pos" )
	foreach ( npc in npcArray )
	{
		if ( npc.HasKey( "script_group" ) && npc.kv.script_group == "bt_intro_delete" )
		{
			npc.Destroy()
		}
		else
		{
			npc.SetNoTarget( true )
			thread AssaultMoveTarget( npc, node )
			thread DestroyOnSignal( npc, "destroy_me" )
		}
	}
}

void function BTIntro_EnemyTitan( entity player )
{
	entity vanquishedTitan = SpawnFromSpawner( GetEntByScriptName( "start_imc_titan" ) )
	vanquishedTitan.EnableNPCFlag( NPC_IGNORE_ALL )
	vanquishedTitan.SetNoTarget( true )
	vanquishedTitan.SetInvulnerable()
	vanquishedTitan.SetTitle( "" )
	vanquishedTitan.SetValidHealthBarTarget( false )

	vanquishedTitan.ai.bossTitanVDUEnabled = false
	HideCrit( vanquishedTitan )

	file.vanquishedTitan = vanquishedTitan

	vanquishedTitan.EndSignal( "OnDestroy" )

	AddAnimEvent( vanquishedTitan, "titan_impact", HotdropImpactFX )
	AddAnimEvent( vanquishedTitan, "wilds_killshot", MakeTitanLookDamaged )

	entity landingRef = GetEntByScriptName( "anim_ref_night" )
	entity scriptRef = GetEntByScriptName( "anim_ref_night" )

	vector origin = FindValidHotDrop( player )

	entity mover = CreateScriptMover( origin, < 0,-180,0> )
	vanquishedTitan.SetParent( mover )

	thread MoveAnimWithPlayer( mover, player )
	waitthread PlayAnimTeleport( vanquishedTitan, "MT_wilds_fight_hotdrop", mover )

	vanquishedTitan.ClearParent()
	mover.Destroy()

	Signal( level, "vanquished_titan_landed" )

	waitthread PlayAnimTeleport( vanquishedTitan, "mt_wilds_OG_victory_late_Tone", scriptRef ) //mt_wilds_OG_victory_late
	vanquishedTitan.Destroy()
}

void function BTIntro_EnemyTitan2( entity player )
{
	WaitSignal( level, "vanquished_titan_landed" )

	entity titan = SpawnFromSpawner( GetEntByScriptName( "sloan_imc_titan" ) )
	titan.EnableNPCFlag( NPC_IGNORE_ALL )
	titan.SetNoTarget( true )
	titan.SetInvulnerable()
	titan.SetTitle( "" )
	titan.SetValidHealthBarTarget( false )
	titan.EndSignal( "OnDestroy" )

	titan.ai.bossTitanVDUEnabled = false
	HideCrit( titan )

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )

	waitthread PlayAnimTeleport( titan, "mt_wilds_OG_victory_late", scriptRef )
	titan.Destroy()
}

vector function FindValidHotDrop( entity player )
{
	float minAngle = -110
	float maxAngle = -70
	float angle = min( maxAngle, max( minAngle, player.EyeAngles().y ) )
	vector vec = AnglesToForward( <0,angle,0> )
	vector origin = player.GetOrigin() + vec * 196
	return origin
}

void function MoveAnimWithPlayer( entity mover, entity player )
{
	mover.EndSignal( "OnDestroy" )
	vector playerOrigin = player.GetOrigin()
	vector startOrigin = mover.GetOrigin() + < 0,0,64 >

	while( true )
	{
		vector old = mover.GetOrigin()
		wait 0.1

		vector movement = player.GetOrigin() - playerOrigin
		vector origin = startOrigin + movement
		vector endOrigin = origin - <0,0,256>

		TraceResults traceResult = TraceLine( origin, endOrigin, [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
		origin = traceResult.endPos

		mover.NonPhysicsMoveTo( origin, 0.1, 0, 0 )

		// DebugDrawLine( mover.GetOrigin(), old, RandomInt( 255 ), RandomInt( 255 ), RandomInt( 255 ), true, 50 )
	}
}

void function BTIntro_Player( entity player )
{
	player.EndSignal( "OnDestroy" )

	// do this here so that we don't die from the eneny titan fall
	player.SetInvulnerable()

	WaitSignal( level, "vanquished_titan_landed" ) //50 frames

	StopMusicTrack( "music_wilds_01_intro" )
	PlayMusic( "music_wilds_02_titanfall" )

	thread ShellShockStart()

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	thread SpawnCoverFoliage( player, scriptRef, 0 )

	// these gets restored after waking up with the prowers in the morning
	player.DisableWeapon()
	player.SetNoTarget( true )

	FirstPersonSequenceStruct OGVictorySequence
	OGVictorySequence.blendTime = 0
	OGVictorySequence.attachment = "ref"
	OGVictorySequence.teleport = true
	OGVictorySequence.firstPersonAnim = "pov_wilds_OG_victory_late"
	OGVictorySequence.thirdPersonAnim = "pt_wilds_OG_victory_late"
	OGVictorySequence.viewConeFunction = ViewConeBTIntro

	file.statusEffect_turnSlow = StatusEffect_AddEndless( player, eStatusEffect.turn_slow, 0.4 )

	player.SetAnimNearZ(3)

	waitthread FirstPersonSequence( OGVictorySequence, player, animRef )

	player.ClearAnimNearZ()

	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

	animRef.Destroy()
}

void function ViewConeBTIntro( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.25 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -5 )
	player.PlayerCone_SetMaxYaw( 5 )
	player.PlayerCone_SetMinPitch( 5 )
	player.PlayerCone_SetMaxPitch( 5 )
	wait 0.25
	ViewConeTight( player )
}

void function BTIntro_MilitiaGrunts()
{
	entity scriptRef = GetEntByScriptName( "anim_ref_night" )
	WaitSignal( level, "vanquished_titan_landed" ) //50 frames

	asset modelName = MILITIA_GRUNT_MODEL
	entity gruntA = SpawnNPCByClassname( "npc_soldier", TEAM_MILITIA, scriptRef.GetOrigin(), <0,0,0> )
	gruntA.SetInvulnerable()
	gruntA.SetNoTarget( true )

	entity gruntB = SpawnNPCByClassname( "npc_soldier", TEAM_MILITIA, scriptRef.GetOrigin(), <0,0,0> )
	gruntB.SetInvulnerable()
	gruntB.SetNoTarget( true )

	thread PlayAnimTeleport( gruntA, "pt_wilds_fight_start_gruntA_late", scriptRef )
	waitthread PlayAnimTeleport( gruntB, "pt_wilds_fight_start_gruntB_late", scriptRef )

	if ( IsValid( gruntB ) )
		gruntB.Destroy()
}

void function AnimEvent_SurpriseAttack( entity buddyTitan )
{
	buddyTitan.EndSignal( "OnDestroy" )
	buddyTitan.EndSignal( "stop_surprise_attack" )

	buddyTitan.TakeOffhandWeapon( 0 )
	buddyTitan.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", 0 )
	entity weapon = buddyTitan.GetOffhandWeapon( 0 )
	Assert( weapon.GetWeaponClassName() == "mp_titanweapon_salvo_rockets" )

	WeaponPrimaryAttackParams attachParams

	int muzzleAttachmentID = buddyTitan.LookupAttachment( "CHESTFOCUS" )
	attachParams.pos = buddyTitan.GetAttachmentOrigin( muzzleAttachmentID )

	int enemyAtachmentID = file.vanquishedTitan.LookupAttachment( "CHESTFOCUS" )

	vector enemyAngles = file.vanquishedTitan.GetAttachmentAngles( enemyAtachmentID )
	vector offsetDir = AnglesToForward( enemyAngles )
	vector enemyPos = file.vanquishedTitan.GetAttachmentOrigin( enemyAtachmentID ) + offsetDir * 110

	attachParams.dir = Normalize( enemyPos - attachParams.pos )
	attachParams.firstTimePredicted = false
	attachParams.burstIndex = 0
	attachParams.barrelIndex = 0
	bool shouldPredict = false

	const SALVOROCKETS_MISSILE_SFX_LOOP			= "Weapon_Sidwinder_Projectile"
	const SALVOROCKETS_NUM_ROCKETS_PER_SHOT 	= 1
	const SALVOROCKETS_MISSILE_SPEED 			= 1800.0
	const SALVOROCKETS_MISSILE_LIFE				= 10
	const SALVOROCKETS_APPLY_RANDOM_SPREAD 		= true
	const SALVOROCKETS_LAUNCH_OUT_ANG 			= 7
	const SALVOROCKETS_LAUNCH_OUT_TIME 			= 0.20
	const SALVOROCKETS_LAUNCH_IN_LERP_TIME 		= 0.2
	const SALVOROCKETS_LAUNCH_IN_ANG 			= -10
	const SALVOROCKETS_LAUNCH_IN_TIME 			= 0.10
	const SALVOROCKETS_LAUNCH_STRAIGHT_LERP_TIME = 0.1
	const SALVOROCKETS_DEBUG_DRAW_PATH 			= false

	while( true )
	{
		array<entity> firedMissiles = FireExpandContractMissiles( weapon, attachParams, attachParams.pos, attachParams.dir, damageTypes.projectileImpact, damageTypes.explosive, shouldPredict, SALVOROCKETS_NUM_ROCKETS_PER_SHOT, SALVOROCKETS_MISSILE_SPEED, SALVOROCKETS_LAUNCH_OUT_ANG, SALVOROCKETS_LAUNCH_OUT_TIME, SALVOROCKETS_LAUNCH_IN_ANG, SALVOROCKETS_LAUNCH_IN_TIME, SALVOROCKETS_LAUNCH_IN_LERP_TIME, SALVOROCKETS_LAUNCH_STRAIGHT_LERP_TIME, SALVOROCKETS_APPLY_RANDOM_SPREAD, -1, SALVOROCKETS_DEBUG_DRAW_PATH )
		foreach( missile in firedMissiles )
		{
			#if SERVER
				missile.SetOwner( buddyTitan )
				EmitSoundOnEntity( missile, SALVOROCKETS_MISSILE_SFX_LOOP )
			#endif
			// missile.kv.lifetime = SALVOROCKETS_MISSILE_LIFE
			SetTeam( missile, buddyTitan.GetTeam() )
			wait 0.1
		}
	}
}


//	########  ##       ####  ######  ##    ##         #### ##    ## ######## ########   #######
//	##     ## ##        ##  ##    ## ##   ##           ##  ###   ##    ##    ##     ## ##     ##
//	##     ## ##        ##  ##       ##  ##            ##  ####  ##    ##    ##     ## ##     ##
//	########  ##        ##   ######  #####             ##  ## ## ##    ##    ########  ##     ##
//	##     ## ##        ##        ## ##  ##            ##  ##  ####    ##    ##   ##   ##     ##
//	##     ## ##        ##  ##    ## ##   ##           ##  ##   ###    ##    ##    ##  ##     ##
//	########  ######## ####  ######  ##    ## ####### #### ##    ##    ##    ##     ##  #######

void function StartPoint_Setup_BliskIntro( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_blisk_intro" )

	EnableMorningLight( player )

	// no grunt chetter that isn't custom, will get reset at the "waking up"
	SetPlayerForcedDialogueOnly( player, true )

	// player should start with his weapon disabled and in shell shock
	player.DisableWeapon()
	ShellShockStart()
	file.statusEffect_turnSlow = StatusEffect_AddEndless( player, eStatusEffect.turn_slow, 0.4 )

	// remove hud for grunt
	Remote_CallFunction_Replay( player, "ServerCallback_HideHudIcons" )

	SetGlobalNetInt( "nighttimeAmbient", 2 )
	Remote_CallFunction_Replay( player, "ServerCallback_NighttimeAmbient", 2 )
}

void function StartPoint_BliskIntro( entity player )
{
	Assert( IsValid( file.buddyTitan ) )
	player.EndSignal( "OnDestroy" )

	thread BliskIntro_Music( file.buddyTitan, player )

	thread BliskIntro_BuddyTitan( file.buddyTitan )
	thread BliskIntro_EnemyTitans()
	waitthread BliskIntro_Player( player )

	// unfreeze titans
	file.buddyTitan.Unfreeze()
	file.bliskTitan.Unfreeze()
	file.sloanTitan.Unfreeze()
}

void function StartPoint_Skip_BliskIntro( entity player )
{
}

void function BliskIntro_Music( entity buddyTitan, entity player )
{
	buddyTitan.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )

	buddyTitan.WaitSignal( "bt_knocked_down" )
	PlayMusic( "music_wilds_03_btdown" )

	// stop sounds as the screen fades to black
	player.WaitSignal( "blisk_intro_over" )

	SetGlobalNetInt( "nighttimeAmbient", -1 )
	Remote_CallFunction_Replay( player, "ServerCallback_NighttimeAmbient", -1 )
}

void function BliskIntro_Player( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	thread SpawnCoverFoliage( player, scriptRef, 1 )

	FirstPersonSequenceStruct OGDefeatedSequence
	OGDefeatedSequence.blendTime = 0
	OGDefeatedSequence.attachment = "ref"
	OGDefeatedSequence.firstPersonAnim = "pov_wilds_OG_defeated"
	OGDefeatedSequence.thirdPersonAnim = "pt_wilds_OG_defeated"
	OGDefeatedSequence.viewConeFunction = ViewConeTight

	player.SetAnimNearZ(3)

	waitthread FirstPersonSequence( OGDefeatedSequence, player, animRef )

	player.ClearAnimNearZ()

	wait 3 // time under black before family photo
	player.ClearParent()
	animRef.Destroy()
}

void function BliskIntro_BuddyTitan( entity buddyTitan )
{
	buddyTitan.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )
	waitthread PlayAnimTeleport( buddyTitan, "BT_wilds_OG_defeated", scriptRef )

	// need to freeze the npc or have them play idle
	buddyTitan.Freeze()
}

void function BliskIntro_EnemyTitans()
{
	// spawn enemy titans
	entity bliskSpawner = GetSpawnerByScriptName( "blisk_imc_titan" )
	file.bliskTitan = bliskSpawner.SpawnEntity()
	file.bliskTitan.SetInvulnerable()
	DispatchSpawn( file.bliskTitan )
	file.bliskTitan.SetNoTarget( true )
	file.bliskTitan.SetTitle( "" )
	file.bliskTitan.SetValidHealthBarTarget( false )
	file.bliskTitan.EnableNPCFlag( NPC_IGNORE_ALL )
	file.bliskTitan.ai.bossTitanVDUEnabled = false

	entity sloanTitanSpawner = GetSpawnerByScriptName( "sloan_imc_titan" )
	file.sloanTitan = sloanTitanSpawner.SpawnEntity()
	file.sloanTitan.SetInvulnerable()
	DispatchSpawn( file.sloanTitan )
	file.sloanTitan.SetNoTarget( true )
	file.sloanTitan.SetTitle( "" )
	file.sloanTitan.SetValidHealthBarTarget( false )
	file.sloanTitan.EnableNPCFlag( NPC_IGNORE_ALL )
	file.sloanTitan.ai.bossTitanVDUEnabled = false

	entity roninTitanSpawner = GetSpawnerByScriptName( "ronin_imc_titan" )
	file.roninTitan = roninTitanSpawner.SpawnEntity()
	file.roninTitan.SetInvulnerable()
	DispatchSpawn( file.roninTitan )
	file.roninTitan.SetNoTarget( true )
	file.roninTitan.SetTitle( "" )
	file.roninTitan.SetValidHealthBarTarget( false )
	file.roninTitan.EnableNPCFlag( NPC_IGNORE_ALL )
	file.roninTitan.ai.bossTitanVDUEnabled = false

	file.bliskTitan.EndSignal( "OnDestroy" )
	file.sloanTitan.EndSignal( "OnDestroy" )
	file.roninTitan.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )

	thread PlayAnimTeleport( file.sloanTitan, "mt_wilds_OG_defeated", scriptRef )
	thread PlayAnimTeleport( file.roninTitan, "LT_wilds_fight_end", scriptRef )
	waitthread PlayAnimTeleport( file.bliskTitan, "ht_wilds_OG_defeated", scriptRef )

	// need to freeze the npc or have them play idle
	file.bliskTitan.Freeze()
	file.sloanTitan.Freeze()
	file.roninTitan.Destroy()
}


//  ########    ###    ##     ## #### ##       ##    ##    ########  ##     ##  #######  ########  #######
//  ##         ## ##   ###   ###  ##  ##        ##  ##     ##     ## ##     ## ##     ##    ##    ##     ##
//  ##        ##   ##  #### ####  ##  ##         ####      ##     ## ##     ## ##     ##    ##    ##     ##
//  ######   ##     ## ## ### ##  ##  ##          ##       ########  ######### ##     ##    ##    ##     ##
//  ##       ######### ##     ##  ##  ##          ##       ##        ##     ## ##     ##    ##    ##     ##
//  ##       ##     ## ##     ##  ##  ##          ##       ##        ##     ## ##     ##    ##    ##     ##
//  ##       ##     ## ##     ## #### ########    ##       ##        ##     ##  #######     ##     #######

void function StartPoint_Setup_FamilyPhoto( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_blisk_intro" )

	EnableMorningLight( player )

	// no grunt chetter that isn't custom, will get reset at the "waking up"
	SetPlayerForcedDialogueOnly( player, true )

	// player should start with his weapon disabled and in shell shock
	player.DisableWeapon()
	ShellShockStart()
	file.statusEffect_turnSlow = StatusEffect_AddEndless( player, eStatusEffect.turn_slow, 0.4 )

	// remove hud for grunt
	Remote_CallFunction_Replay( player, "ServerCallback_HideHudIcons" )

	entity bliskSpawner = GetSpawnerByScriptName( "blisk_imc_titan" )
	file.bliskTitan = bliskSpawner.SpawnEntity()
	file.bliskTitan.SetInvulnerable()
	DispatchSpawn( file.bliskTitan )
	file.bliskTitan.SetNoTarget( true )
	file.bliskTitan.SetTitle( "" )
	file.bliskTitan.SetValidHealthBarTarget( false )
	file.bliskTitan.EnableNPCFlag( NPC_IGNORE_ALL )

	entity sloanTitanSpawner = GetSpawnerByScriptName( "sloan_imc_titan" )
	file.sloanTitan = sloanTitanSpawner.SpawnEntity()
	file.sloanTitan.SetInvulnerable()
	DispatchSpawn( file.sloanTitan )
	file.sloanTitan.SetNoTarget( true )
	file.sloanTitan.SetTitle( "" )
	file.sloanTitan.SetValidHealthBarTarget( false )
	file.sloanTitan.EnableNPCFlag( NPC_IGNORE_ALL )
}

void function StartPoint_FamilyPhoto( entity player )
{
	player.EndSignal( "OnDestroy" )

	Assert( IsValid( file.buddyTitan ) )

	FlagSet( "family_photo_start" )

	thread FamilyPhoto_Audio( player )

	thread FamilyPhoto_BuddyTitan( file.buddyTitan )
	thread FamilyPhoto_Enemies()
	thread FamilyPhoto_Corpses()
	thread FamilyPhotoExtras()
	waitthread FamilyPhoto_Player( player )

	ShellShockStop()
}

void function StartPoint_Skip_FamilyPhoto( entity player )
{
	FlagSet( "family_photo_start" )
}

void function FamilyPhoto_Audio( entity player )
{
	EmitSoundOnEntity( player, "wilds_amb_ext_aftermath" )

	player.WaitSignal( "blackout_music_end" )

	StopSoundOnEntity( player, "wilds_amb_ext_aftermath" )
	EmitSoundOnEntity( player, "Wilds_EndOfFamilyPhoto_4_second_fadeout" )
}

void function FamilyPhoto_Player( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	thread SpawnCoverFoliage( player, scriptRef, 2 )

	// family photo
	FirstPersonSequenceStruct FamilyPhotoSequence
	FamilyPhotoSequence.blendTime = 0
	FamilyPhotoSequence.attachment = "ref"
	FamilyPhotoSequence.teleport = true
	FamilyPhotoSequence.firstPersonAnim = "pov_family_photo_camera"
	FamilyPhotoSequence.thirdPersonAnim = "pt_family_photo_camera"
	FamilyPhotoSequence.viewConeFunction = ViewConeTight

	player.SetAnimNearZ(3)

	waitthread FirstPersonSequence( FamilyPhotoSequence, player, animRef )

	player.ClearAnimNearZ()

	DestroyCoverFoliage()

	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

	animRef.Destroy()
}

void function FamilyPhoto_BuddyTitan( entity buddyTitan )
{
	buddyTitan.EndSignal( "OnDestroy" )

	buddyTitan.NotSolid() // so that he doesn't block AI

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )
	waitthread PlayAnimTeleport( buddyTitan, "BT_family_photo", scriptRef ) // puts BT in an idle anim for the duration
	buddyTitan.Solid()
}

void function FamilyPhoto_Enemies()
{
	file.bliskTitan.EndSignal( "OnDestroy" )
	file.sloanTitan.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_night" )

	entity richter = SpawnNPCByClassname( "npc_soldier", TEAM_IMC, scriptRef.GetOrigin(), <0,0,0>, "mp_weapon_wingman" )
	richter.SetModel( RICHTER_WILDS_MODEL )
	thread AttachEar( richter )

	entity blisk = CreatePropScript( BLISK_WILDS_MODEL )
	blisk.SetFootstepType( "human" )
	entity weaponModel = CreatePropDynamic( RIFLE_WEAPON_MODEL )
	weaponModel.SetParent( blisk, "PROPGUN", false, 0 )

	OnThreadEnd(
		function() : ( richter, blisk )
		{
			if ( IsValid( file.sloanTitan ) )
				file.sloanTitan.Destroy()
			if ( IsValid( file.bliskTitan ) )
				file.bliskTitan.Destroy()
			if ( IsValid( richter ) )
				richter.Destroy()
			if ( IsValid( blisk ) )
				blisk.Destroy()
		}
	)

	// pt_family_photo_Blisk
	thread PlayAnimTeleport( richter, "pt_family_photo_Richter", scriptRef )
	thread PlayAnimTeleport( blisk, "pt_family_photo_Blisk", scriptRef )

	thread PlayAnimTeleport( file.sloanTitan, "mt_family_photo", scriptRef )
	waitthread PlayAnimTeleport( file.bliskTitan, "ht_family_photo", scriptRef )
}

void function AttachEar( entity richter )
{
	richter.EndSignal( "OnDestroy" )

	richter.WaitSignal( "create_ear" )
	entity earModel = CreatePropDynamic( GRUNT_EAR_MODEL )
	earModel.SetParent( richter, "KNIFE", false, 0 )
	richter.WaitSignal( "delete_ear" )
	earModel.Destroy()
}

void function FamilyPhoto_Corpses()
{
	entity scriptRef = GetEntByScriptName( "anim_ref_night" )

	entity corpse1 = CreatePropScript( MILITIA_GRUNT_MODEL )
	corpse1.SetFootstepType( "human" )

	int bodyGroupIndex = corpse1.FindBodyGroup( "head" )
	Assert( bodyGroupIndex != -1 )
	corpse1.SetBodygroup( bodyGroupIndex, 1 )

	entity corpse2 = CreatePropScript( MILITIA_GRUNT_MODEL )
	corpse2.SetFootstepType( "human" )

	bodyGroupIndex = corpse2.FindBodyGroup( "head" )
	Assert( bodyGroupIndex != -1 )
	corpse2.SetBodygroup( bodyGroupIndex, 1 )

	OnThreadEnd(
		function() : ( corpse1, corpse2 )
		{
			if ( IsValid( corpse1 ) )
				corpse1.Destroy()
			if ( IsValid( corpse2 ) )
				corpse2.Destroy()
		}
	)

	thread PlayAnimTeleport( corpse1, "pt_family_photo_corpse", scriptRef )
	waitthread PlayAnimTeleport( corpse2, "pt_family_photo_Slone", scriptRef )

	corpse1.Destroy()
	corpse2.Destroy()
}

void function FamilyPhotoExtras()
{
	wait 12

	entity titan = SpawnFromSpawner( GetEntByScriptName( "family_photo_extra_2" ) )
	titan.SetTitle( "" )
	titan.SetNoTarget( true )
	titan.SetValidHealthBarTarget( false )
	titan.SetNPCMoveSpeedScale( 0.5 )
	titan.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS )
	titan.EnableNPCFlag( NPC_IGNORE_ALL )
	titan.ai.bossTitanVDUEnabled = false
	thread DestroyOnSignal( titan, "destroy_me")

	wait 2.0
	array<entity> spectreArray = SpawnFromSpawnerArray( GetSpawnerArrayByScriptName( "family_photo_extra_spectres" ) )
	foreach ( spectre in spectreArray )
	{
		spectre.SetNPCMoveSpeedScale( 0.7 )
		spectre.EnableNPCFlag( NPC_IGNORE_ALL )
		thread DestroyOnSignal( spectre, "destroy_me" )
	}
}

//  ##      ##    ###    ##    ## #### ##    ##  ######      ##     ## ########
//  ##  ##  ##   ## ##   ##   ##   ##  ###   ## ##    ##     ##     ## ##     ##
//  ##  ##  ##  ##   ##  ##  ##    ##  ####  ## ##           ##     ## ##     ##
//  ##  ##  ## ##     ## #####     ##  ## ## ## ##   ####    ##     ## ########
//  ##  ##  ## ######### ##  ##    ##  ##  #### ##    ##     ##     ## ##
//  ##  ##  ## ##     ## ##   ##   ##  ##   ### ##    ##     ##     ## ##
//   ###  ###  ##     ## ##    ## #### ##    ##  ######       #######  ##

void function StartPoint_Setup_WakingUp( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_field_promotion" )
	player.DisableWeapon()
	file.statusEffect_turnSlow = StatusEffect_AddEndless( player, eStatusEffect.turn_slow, 0.4 )

	// remove hud for grunt
	Remote_CallFunction_Replay( player, "ServerCallback_HideHudIcons" )
}

void function StartPoint_WakingUp( entity player )
{
	player.EndSignal( "OnDestroy" )

	DisableMorningLight( player )

	BuddyTitanRemoveBatteyCaps()

	player.FreezeControlsOnServer()
	SetPlayerForcedDialogueOnly( player, false )

	HideGrave()

	// this need to be adjusted once the proper animation gets in.
	ScreenFade( player, 0, 0, 0, 255, 15, 6.5, FFADE_IN | FFADE_PURGE ) // fade out the black screen
	wait 6

	//StopSoundOnEntity( player, "Wilds_EndOfFamilyPhoto_4_second_fadeout" )

	player.UnfreezeControlsOnServer()

	thread WakingUp_Prowler1()
	thread WakingUp_Prowler2()
	thread WakingUp_Player( player )
	thread WakingUp_Music( player )
	waitthread WakingUp_BuddyTitan()

	CheckPoint()
}

void function StartPoint_Skip_WakingUp( entity player )
{
	SetPlayerForcedDialogueOnly( player, false )

	#if CONSOLE_PROG
	// Clear DVS override started in bt_intro skip
	DisableDVSOverride( player )
	#endif

	HideGrave()
	BuddyTitanRemoveBatteyCaps()
	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	thread PlayAnimTeleport( file.buddyTitan, "BT_second_battery_idle", scriptRef )
}

void function WakingUp_Player( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

//	entity rock = CreatePropDynamic( GRAVE_ROCK_MODEL )

	FirstPersonSequenceStruct ProwlerSequence
	ProwlerSequence.attachment = "ref"
	ProwlerSequence.blendTime = 0
	ProwlerSequence.teleport = true
	ProwlerSequence.firstPersonAnim = "ptpov_wilds_prowler_encounter"
	ProwlerSequence.thirdPersonAnim = "pt_player_wilds_prowler_encounter"
	ProwlerSequence.viewConeFunction = WakingUpViewCone

	player.SetAnimNearZ(1)

//	thread PlayAnimTeleport( rock, "stone_wilds_prowler_encounter", animRef )
	waitthread FirstPersonSequence( ProwlerSequence, player, animRef )

	player.ClearAnimNearZ()

	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

//	rock.Destroy()
	animRef.Destroy()

	// these things where set at the start of BT_Intro
	player.SetPlayerNetBool( "shouldShowWeaponFlyout", false )

	player.SetNoTarget( false )
	player.ClearInvulnerable()
	player.EnableWeaponWithSlowDeploy()

	#if CONSOLE_PROG
	// Clear DVS override started in bt_intro
	DisableDVSOverride( player )
	#endif

	// slow player speed down for a short while
	thread LerpPlayerSpeed( player, 0.35, 1.0, 4.0 )

	StatusEffect_Stop( player, file.statusEffect_turnSlow )
	StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 0.3, 4, 4 )

	wait 2 // disable flyouts
	Remote_CallFunction_NonReplay( player, "ServerCallback_LevelIntroText" )

	wait 5
	player.SetPlayerNetBool( "shouldShowWeaponFlyout", true )

}

void function WakingUpViewCone( entity player )
{
	thread WakingUpViewConeThread( player )
}

void function WakingUpViewConeThread( entity player )
{
	if ( !player.IsPlayer() )
		return

	player.PlayerCone_SetLerpTime( 0.0 )
	player.PlayerCone_SetMinYaw( 0 )
	player.PlayerCone_SetMaxYaw( 0 )
	player.PlayerCone_SetMinPitch( 0 )
	player.PlayerCone_SetMaxPitch( 0 )

	wait 0.5
	player.PlayerCone_SetLerpTime( 9.0 )
	player.PlayerCone_SetMinYaw( 0 )        //screen right
	player.PlayerCone_SetMaxYaw( 5 )        //screem left
	player.PlayerCone_SetMinPitch( -5 )     //screen top
	player.PlayerCone_SetMaxPitch( 5 )      //screen bottom

	wait 9.0
	player.PlayerCone_SetLerpTime( 0.0 )
	player.PlayerCone_SetMinYaw( -10 )     //screen right
	player.PlayerCone_SetMaxYaw( 15 )      //screen left
	player.PlayerCone_SetMinPitch( -5 )    //screen top
	player.PlayerCone_SetMaxPitch( 20 )    //screen bottom
}

void function WakingUp_Music( entity player )
{
	entity proxy = player.GetFirstPersonProxy()
	proxy.WaitSignal( "music_cue" )

	StopMusicTrack( "music_wilds_02_titanfall" )
	StopMusicTrack( "music_wilds_03_btdown" )
	PlayMusic( "music_wilds_04_prowlers" )
}

void function WakingUp_Prowler1()
{
	entity prowler1 = CreatePropScript( PROWLER_MODEL )
	AddHighlightObject( prowler1 )
	prowler1.SetFootstepType( "prowler" )
	prowler1.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	thread PlayAnimTeleport( prowler1, "pr_attacker_wilds_prowler_encounter", scriptRef )
}

void function WakingUp_Prowler2()
{
	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )

	entity corpse = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL )
	AddHighlightObject( corpse )

	entity prowler2 = CreatePropScript( PROWLER_MODEL )
	Highlight_ClearFriendlyHighlight( prowler2 )
	prowler2.SetFootstepType( "prowler" )

	thread PlayAnimTeleport( corpse, "pt_corpse_wilds_prowler_encounter", scriptRef )
	waitthread PlayAnimTeleport( prowler2, "pr_eating_wilds_prowler_encounter", scriptRef )

	prowler2.Destroy()
}

void function WakingUp_BuddyTitan()
{
	file.buddyTitan.EndSignal( "OnDestroy" )

	entity buddyTitan = file.buddyTitan
	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )

	// kill prowlers
	waitthread PlayAnimTeleport( buddyTitan, "bt_wilds_prowler_encounter", scriptRef )

	thread AttachBTCollision( "bt_collision", "og_final_words" )

	// trasitioning to idle before OG prilot falls out
	waitthread PlayAnim( buddyTitan, "BT_first_battery_trans", scriptRef )
	thread PlayAnim( buddyTitan, "BT_second_battery_idle", scriptRef )
}


//	######## #### ######## ##       ########          ########  ########   #######  ##     ##  #######  ######## ####  #######  ##    ##
//	##        ##  ##       ##       ##     ##         ##     ## ##     ## ##     ## ###   ### ##     ##    ##     ##  ##     ## ###   ##
//	##        ##  ##       ##       ##     ##         ##     ## ##     ## ##     ## #### #### ##     ##    ##     ##  ##     ## ####  ##
//	######    ##  ######   ##       ##     ##         ########  ########  ##     ## ## ### ## ##     ##    ##     ##  ##     ## ## ## ##
//	##        ##  ##       ##       ##     ##         ##        ##   ##   ##     ## ##     ## ##     ##    ##     ##  ##     ## ##  ####
//	##        ##  ##       ##       ##     ##         ##        ##    ##  ##     ## ##     ## ##     ##    ##     ##  ##     ## ##   ###
//	##       #### ######## ######## ########          ##        ##     ##  #######  ##     ##  #######     ##    ####  #######  ##    ##

void function StartPoint_Setup_FieldPromotion( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_field_promotion" )

	// remove hud for grunt
	Remote_CallFunction_Replay( player, "ServerCallback_HideHudIcons" )
}

void function StartPoint_FieldPromotion( entity player )
{
	player.EndSignal( "OnDestroy" )

	thread FieldPromotion_Obj( player )

	thread FieldPromotion_Promotion_Player( player )
	thread FieldPromotion_Promotion_BuddyTitan( player )
	waitthread FieldPromotion_Promotion_OGPilot( player )
}

void function StartPoint_Skip_FieldPromotion( entity player )
{
	file.batteriesInstalled = 1
}

void function FieldPromotion_Obj( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "og_pilot_exited" )

	Objective_Set( "#WILDS_OBJECTIVE_FIELD_PROMOTION", file.ogPilot.GetOrigin() + <0,0,16>)
	FlagWait( "og_final_words" )

	Objective_Clear()
}

void function FieldPromotion_Promotion_Player( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWaitWithTimeout( "player_near_bt", 10 )
	FlagSet( "bt_expels_og" )

	FlagWait( "og_final_words" )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	// weapon gets returned after the grave sequence
	player.DisableWeapon()

	FirstPersonSequenceStruct ogFinalWordsSequence
	ogFinalWordsSequence.attachment = "ref"
	ogFinalWordsSequence.teleport = false
	ogFinalWordsSequence.firstPersonAnim = "pov_wilds_OG_final_words"
	ogFinalWordsSequence.thirdPersonAnim = "pt_wilds_OG_final_words"
	ogFinalWordsSequence.viewConeFunction = ViewConeTight

	vector origin = player.GetOrigin()
	vector angles = player.GetAngles()

	player.SetAnimNearZ(1)
	Remote_CallFunction_Replay( player, "ServerCallback_FieldPromotionShadows", true )

	waitthread FirstPersonSequence( ogFinalWordsSequence, player, animRef )

	Remote_CallFunction_Replay( player, "ServerCallback_FieldPromotionShadows", false )
	player.ClearAnimNearZ()

	FlagSet( "promoted" )

	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

	animRef.Destroy()
}

void function FieldPromotion_Promotion_OGPilot( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "bt_expels_og" )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )

	entity ogPilot = CreateOGPilot()
	file.ogPilot = ogPilot
	ogPilot.SetSkin( 1 ) // make the pilot look hurt
//	ogPilot.NotSolid()
	ogPilot.UseSequenceBounds( true )
	ogPilot.TakeActiveWeapon()

	thread FieldPromotion_Music( ogPilot )
	waitthread PlayAnimTeleport( ogPilot, "OG_wilds_1st_battery_fall", scriptRef )
	FlagSet( "og_pilot_exited" )

	thread PlayAnimTeleport( ogPilot, "OG_wilds_OG_final_words_idle", scriptRef )

	entity useDummy = CreateUseDummy( ogPilot, "CHESTFOCUS",  <16,0,0>, "#WILDS_OG_PILOT_PROMPT_HOLD" , "#WILDS_OG_PILOT_PROMPT_HOLD" )
	useDummy.WaitSignal( "OnPlayerUse" )
	useDummy.Destroy()

	Objective_Clear()

	FlagSet( "og_final_words" )

	waitthread PlayAnimTeleport( ogPilot, "OG_wilds_OG_final_words", scriptRef )

	ogPilot.Destroy()
	file.ogPilot = null
}

void function FieldPromotion_Music( entity ogPilot )
{
	ogPilot.EndSignal( "OnDestroy" )
	ogPilot.WaitSignal( "og_pilot_hits_ground" )

	StopMusicTrack( "music_wilds_04_prowlers" )
	PlayMusic( "music_wilds_05_ogdown" )

	thread Battery2PathExplorationMusic()
}

void function Battery2PathExplorationMusic()
{
	FlagEnd( "battery2_see_ship" )

	wait 82	// time to wait as directed by Nick Laviers
	StopMusicTrack( "music_wilds_05_ogdown" )
	PlayMusic( "music_wilds_06_explore" )
}


void function FieldPromotion_Promotion_BuddyTitan( entity player )
{
	file.buddyTitan.EndSignal( "OnDestroy" )
	entity buddyTitan = file.buddyTitan
	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )

	player.EndSignal( "OnDestroy" )
	buddyTitan.EndSignal( "OnDestroy" )

	FlagWait( "bt_expels_og" )

	// need to the new anim work
	waitthread PlayAnim( buddyTitan, "BT_wilds_1st_battery_fall", scriptRef )
	thread PlayAnim( buddyTitan, "BT_wilds_OG_final_words", scriptRef )
	FlagWait( "og_final_words" )
	FlagWait( "promoted" )

	// this is the correct looping anim
	thread PlayAnim( buddyTitan, "BT_second_battery_idle", scriptRef )
}

//   ######   ########     ###    ##     ## ########
//  ##    ##  ##     ##   ## ##   ##     ## ##
//  ##        ##     ##  ##   ##  ##     ## ##
//  ##   #### ########  ##     ## ##     ## ######
//  ##    ##  ##   ##   #########  ##   ##  ##
//  ##    ##  ##    ##  ##     ##   ## ##   ##
//   ######   ##     ## ##     ##    ###    ########

void function StartPoint_Setup_Grave( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_field_promotion" )

	player.DisableWeapon()

	// remove hud for grunt
	Remote_CallFunction_Replay( player, "ServerCallback_HideHudIcons" )
}

void function StartPoint_Grave( entity player )
{
	player.EndSignal( "OnDestroy" )

	ShowGrave()

	FlagSet( "ShowAlternateMissionLog" )
	UpdatePauseMenuMissionLog( player )

	player.FreezeControlsOnServer()
	Remote_CallFunction_Replay( player, "ServerCallback_GraveShadowsAndDOF", true )

	thread DisplayLogbookHint( player, 4.0 )

	ScreenFade( player, 0, 0, 0, 255, 10, 5, FFADE_IN | FFADE_PURGE ) // fade out the black screen
	wait 4.5

	PrimeWaypoints( GetEntByScriptName( "waypoint_start" ) )

	// might need to move this into don helmet
	player.UnfreezeControlsOnServer()
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "disable_doublejump" ] )
	SyncedMelee_Enable( player )

	FlagSet( "give_wallrun" )

	CreateBTStaticCollision( BT_IDLE_COLLISION_2 )

	thread Grave_DonHelmet( player )
	FlagWait( "BuddyTitanFlyout" )
}

void function DisplayLogbookHint( entity player, float timeout )
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

void function StartPoint_Skip_Grave( entity player )
{
	FlagSet( "give_wallrun" )

	ShowGrave()

	CreateBTStaticCollision( BT_IDLE_COLLISION_2 )

	player.SetExtraWeaponMods( [] )
	player.SetPlayerNetBool( "hideHudIcons", false )
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "disable_doublejump" ] )
	player.GiveOffhandWeapon( "mp_ability_cloak", OFFHAND_SPECIAL )
	SyncedMelee_Enable( player )
}

void function Grave_DonHelmet( entity player )
{
	player.EndSignal( "OnDestroy" )

	thread DelayCheckpoint( 17.5 )

	entity scriptRef = GetEntByScriptName( "anim_ref_grave" )
	entity animRef = CreateOwnedScriptMover( scriptRef )
	entity rock = CreatePropDynamic( GRAVE_ROCK_MODEL )
	entity helmet = CreatePropDynamic( HELMET_MODEL )

	int bodyGroupIndex = helmet.FindBodyGroup( "helmet" )
	Assert( bodyGroupIndex != -1 )
	helmet.SetBodygroup( bodyGroupIndex, 1 )

	FirstPersonSequenceStruct helmetBootSequence
	helmetBootSequence.attachment = "ref"
	helmetBootSequence.blendTime = 0
	helmetBootSequence.teleport = true
	helmetBootSequence.firstPersonAnim = "ptpov_OG_grave" // "ptpov_timeshift_device_equip_sequence"
	helmetBootSequence.thirdPersonAnim = "pt_OG_grave"	// "pt_timeshift_device_equip_sequence"
	helmetBootSequence.viewConeFunction = GraveViewCone

	player.SetAnimNearZ(1)
	file.statusEffect_turnSlow = StatusEffect_AddEndless( player, eStatusEffect.turn_slow, 0.35 )

	thread PlayAnimTeleport( rock, "rock_OG_grave", animRef )
	thread PlayAnimTeleport( helmet, "helmet_OG_grave", animRef )
	waitthread FirstPersonSequence( helmetBootSequence, player, animRef )

	Remote_CallFunction_Replay( player, "ServerCallback_GraveShadowsAndDOF", false )

	thread HelmetBootUpSequence( player )

	player.ClearAnimNearZ()

	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	animRef.Destroy()
	rock.Destroy()
	helmet.Destroy()

	player.SetMoveSpeedScale( 0.4 )
	SetPlayerSprint( player, false )

	vector startOrigin = player.GetOrigin()
	float endTime = Time() + 15
	while( Distance( player.GetOrigin(), startOrigin ) < 128 && Time() < endTime )
	{
		// rintt( "*****", Distance( player.GetOrigin(), startOrigin ), Time(), endTime )
		wait 0.25
	}

	StatusEffect_Stop( player, file.statusEffect_turnSlow )
	StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 0.35, 3, 3 )
	thread LerpPlayerSpeed( player, 0.4, 1.0, 3.0 )
}

void function DelayCheckpoint( float delay )
{
	wait delay
	CheckPoint_ForcedSilent()
}

void function GraveViewCone( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -20 )
	player.PlayerCone_SetMaxYaw( 20 )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 2 )
}

void function WaitForBootupCompleteOrTimeout( entity player, string signal, float timeout )
{
	// Using a timeout instead of just waiting on the signal because Savegame can happen while client script is doing HelmetBootUpSequence
	// This causes Loadgame to not restore client state and server will wait for the signal forever. Now it will timeout.

	player.EndSignal( "OnDeath" )
	player.EndSignal( signal )
	wait timeout

	printt( "WAITING FOR SIGNAL:", signal, "TIMED OUT ON SERVER, PROBABLY BECAUSE OF SAVE GAME STOPPING CLIENT SCRIPT" )

	// Also send the signal after the timeout because other threads have EndSignal on it
	player.Signal( signal )
}

void function HelmetBootUpSequence( entity player )
{
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )

	const giveDelay = 19.5 // the dalay matched the time it takes until the cloak is "activated"
	thread GiveOffhandWeaponAfterDelay( player, "mp_ability_cloak", OFFHAND_SPECIAL, giveDelay )

	thread EnableWeaponOnPickup( player )

	Remote_CallFunction_Replay( player, "ServerCallback_HelmetBootUpSequence" )
	waitthread WaitForBootupCompleteOrTimeout( player, "helmet_bootup_complete", 35.0 )

	// weapon is disabled at the start of OGs final words
	player.EnableWeaponWithSlowDeploy()
	player.SetExtraWeaponMods( [] )

	player.SetPlayerNetBool( "hideHudIcons", false )

	HelmetBootUpHighlight()
	CheckPoint()
	wait 4

	FlagSet( "BuddyTitanFlyout" )

	Remote_CallFunction_Replay( player, "ServerCallback_BuddyTitanFlyout", file.buddyTitan.GetEncodedEHandle() )
	waitthread WaitForBootupCompleteOrTimeout( player, "BuddyTitanFlyoutComplete", 10.0 )

	waitthread BatteryTracker1( player )
	FlagSet( "battery_tracker1_completed" )

	thread GraveObjectiveHintThread( player )
	thread WallrunningReminder( player, "first_wallrun_completed" )
	thread LowBatteryFlyoutNag( player )
	thread BatteryNag( player )

	wait 2
}

void function EnableWeaponOnPickup( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "helmet_bootup_complete" )

	entity currentWeapon = player.GetActiveWeapon()
	while( currentWeapon == player.GetActiveWeapon() )
		WaitFrame()

	currentWeapon = player.GetActiveWeapon()
	// For some reason when just enabling weapon would bring up the pistol instead of the picked up weapon.
	// Setting active weapon seemed to fix it. Don't ask me why,
	player.SetActiveWeaponByName( currentWeapon.GetWeaponClassName() )
	player.EnableWeaponWithSlowDeploy()
	player.SetExtraWeaponMods( [] )
}

void function GraveObjectiveHintThread( entity player )
{
	const hintTimeout = 60

	Objective_Clear()
	thread WaypointThread( player, "#WILDS_OBJECTIVE_BATTERY2", GetEntByScriptName( "waypoint_start" ), GetEntByScriptName( "location_obj_battery2" ), true )
	waitthread ShowObjectiveHint( player, hintTimeout )
	thread ObjectiveRecurringReminder( player, "rock_block_done" )
}

void function GiveOffhandWeaponAfterDelay( entity player, string weaponName, int slotIndex, float delay)
{
	player.EndSignal( "OnDestroy" )
	wait delay

	player.GiveOffhandWeapon( weaponName, slotIndex )
}

bool function ClientCommand_HelmetBootUpComplete( entity player, array<string> args )
{
	player.Signal( "helmet_bootup_complete" )
	return true
}

bool function ClientCommand_BuddyTitanFlyoutComplete( entity player, array<string> args )
{
	player.Signal( "BuddyTitanFlyoutComplete" )
	return true
}

void function HelmetBootUpHighlight()
{
	foreach( ent in file.highlightObjectArray )
	{
		switch( ent.GetTeam() )
		{
			case TEAM_UNASSIGNED:
				Highlight_SetNeutralHighlight( ent, "enemy_sonar" )
				break
			case TEAM_IMC:
				Highlight_SetEnemyHighlight( ent, "enemy_sonar" )
				break
			case TEAM_MILITIA:
				Highlight_SetFriendlyHighlight( ent, "enemy_sonar" )
				break
		}

		if ( ent != file.buddyTitan )
		{
			float delay = RandomFloatRange( 5, 7 )
			thread HelmetBootUpHighlightOff( ent, delay )
		}
		else
		{
			thread HelmetBootUpHighlightBT()
		}
	}
}

void function HelmetBootUpHighlightBT()
{
	entity player = GetPlayerArray()[0]
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )

	wait 3
	Highlight_SetFriendlyHighlight( file.buddyTitan, "friendly_ai" )
	wait 3
	Highlight_SetFriendlyHighlight( file.buddyTitan, "fw_friendly" )

	player.WaitSignal( "BuddyTitanFlyoutComplete" )
	thread HelmetBootUpHighlightOff( file.buddyTitan, 0.0 )
}

void function HelmetBootUpHighlightOff( entity ent, float delay )
{
	ent.EndSignal( "OnDestroy" )
	wait delay

	switch( ent.GetTeam() )
	{
		case TEAM_UNASSIGNED:
			Highlight_ClearNeutralHighlight( ent )
			break
		case TEAM_IMC:
			Highlight_ClearEnemyHighlight( ent )
			break
		case TEAM_MILITIA:
			Highlight_ClearFriendlyHighlight( ent )
			break
	}
}

void function AddHighlightObject( entity ent )
{
	Highlight_ClearFriendlyHighlight( ent )
	file.highlightObjectArray.append( ent )
}

void function BatteryTracker1( entity player )
{
	player.EndSignal( "OnDestroy" )

	array<entity> fakelocs = GetEntArrayByScriptName( "fake_battery_locs_1" )
	entity realLoc = GetEntByScriptName( "location_obj_battery2" )

	waitthread BatteryTrackerThread( player, fakelocs, realLoc, 7.5 )
}

void function HideGrave()
{
	entity grave = GetEntByScriptName( "og_pilot_grave" )
	grave.Hide()
	grave.NotSolid()

	entity clip = GetEntByScriptName( "og_pilot_grave_clip" )
	clip.NotSolid()
}

void function ShowGrave()
{
	entity grave = GetEntByScriptName( "og_pilot_grave" )
	grave.Show()
	grave.Solid()

	entity clip = GetEntByScriptName( "og_pilot_grave_clip" )
	clip.Solid()
}

void function LowBatteryFlyoutNag( entity player )
{
	FlagEnd( "battery2_acquired" )
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )

	const degrees = 15.0
	const minDistSqrd = 1500 * 1500
	const debounceTime = 10.0
	const hovertime = 1.25

	float startSeeing = -1

	while( true )
	{
		bool canSee = false

		if ( DistanceSqr( player.GetOrigin(), file.buddyTitan.GetOrigin() ) < minDistSqrd )
		{
			if ( !IsValid( file.buddyTitanCollision ) )
				canSee = PlayerCanSee( player, file.buddyTitan, true, degrees )
			else
				canSee = PlayerCanSee( player, file.buddyTitanCollision, true, degrees )
		}

		if ( !canSee )
			startSeeing = -1
		else if ( startSeeing == -1 )
			startSeeing = Time()

		if ( startSeeing > 0 && Time() > startSeeing + hovertime )
		{
			Remote_CallFunction_Replay( player, "ServerCallback_BuddyTitanFlyout", file.buddyTitan.GetEncodedEHandle(), true )
			Highlight_SetFriendlyHighlight( file.buddyTitan, "fw_friendly" )
			thread HelmetBootUpHighlightOff( file.buddyTitan, 5.0 )

			wait debounceTime
		}

		WaitFrame()
	}
}

//        ## ##     ## ##     ## ########     ##    ## #### ########
//        ## ##     ## ###   ### ##     ##    ##   ##   ##     ##
//        ## ##     ## #### #### ##     ##    ##  ##    ##     ##
//        ## ##     ## ## ### ## ########     #####     ##     ##
//  ##    ## ##     ## ##     ## ##           ##  ##    ##     ##
//  ##    ## ##     ## ##     ## ##           ##   ##   ##     ##
//   ######   #######  ##     ## ##           ##    ## ####    ##

void function JumpKitCalibrationThread( entity player, float startProgress = 0.0 )
{
	player.EndSignal( "OnDestroy" )

	file.wallrunCalibrationProgress = startProgress
	int currentStep = int( floor( file.wallrunCalibrationProgress * JUMPKIT_CALIBRATION_STEPS ) )
	SetGlobalNetBool( "doubleJumpDisabled", true )
	player.SetPlayerNetInt( "jumpKitCalibrationStep", currentStep )
	Remote_CallFunction_Replay( player, "ServerCallback_JumpKitCalibrationStart", currentStep )

	thread JumpKitCalibrationProgressOverTime( player )
	thread FinalWallrunCalibration( player )

	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.BEGIN_WALLRUN, Callback_WallrunBegin )
	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.END_WALLRUN, Callback_WallrunEnd )
	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, Callback_GroundTouch )

	FlagWaitAny( "give_doublejump", "exit_combat_cave" )

	// can't clear callback while a wallrun is active
	while( file.wallrunStatusFlag == eWallrunStatusFlag.IN_PROGRESS )
		wait 1

	RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.BEGIN_WALLRUN, Callback_WallrunBegin )
	RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.END_WALLRUN, Callback_WallrunEnd )
	RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, Callback_GroundTouch )

	waitthread WaitForBreakInCombat( player, "exit_combat_cave" )

	if ( !Flag( "give_doublejump" ) )
	{
		printt( "calibration not enough" )
		FlagSet( "give_doublejump" )
	}

	SetGlobalNetBool( "doubleJumpDisabled", false )

	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [] )
	SetJumpKitCalibrationStep( player, JUMPKIT_CALIBRATION_STEPS )

	// flag is cleared in StartPoint_LevelStart
	FlagSet( "DeathHintsEnabled" )

	wait 3
	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.DOUBLE_JUMP, PlayerDoubleJumped )

	thread DisplayDoubleJumpHint( player )
}

void function DisplayDoubleJumpHint( entity player )
{
	wait 2
	SetJumpKitCalibrationStep( player, -1 )

	while( true )
	{
		DisplayOnscreenHint( player, "doublejump_hint" )

		table result = WaitSignal( player, "double_jump_confirmed", "OnDamaged" )
		ClearOnscreenHint( player )

		if ( result.signal == "double_jump_confirmed" )
			break

		waitthread WaitForBreakInCombat( player, "exit_combat_cave" )
	}
}


void function PlayerDoubleJumped( entity player )
{
	player.Signal( "double_jump_confirmed" )
}

void function FinalWallrunCalibration( entity player )
{
	FlagEnd( "give_doublejump" )
	FlagEnd( "exit_combat_cave" )
	player.EndSignal( "OnDestroy" )

	FlagWait( "final_wallrun" )

	if ( file.jumpKitCalibrationStep != JUMPKIT_CALIBRATION_STEPS - 1 )
	{
		file.jumpKitCalibrationStep = JUMPKIT_CALIBRATION_STEPS - 1
		SetJumpKitCalibrationStep( player, file.jumpKitCalibrationStep )
	}

	if ( file.wallrunCalibrationProgress < 1 )
		file.wallrunCalibrationProgress = 0.99
}

void function JumpKitCalibrationProgressOverTime( entity player )
{
	FlagEnd( "give_doublejump" )
	FlagEnd( "exit_combat_cave" )
	FlagEnd( "final_wallrun" )
	player.EndSignal( "OnDestroy" )

	array<string> progressFlags = [
		"flyby_go",
		"battery2_see_light",
		"ledge_guy_move",
		"battery2_combat_ravine_crossed",
		"battery2_combat_prowler_attack",
		"exit_combat_cave"
	]

	int index = 0

	const secondsPerFlag = 60
	const stepsPerFlag = 3
	float startTime = Time()
	int startStep = int( floor( file.wallrunCalibrationProgress * JUMPKIT_CALIBRATION_STEPS ) )
	int maxStep = int( min( startStep + stepsPerFlag, JUMPKIT_CALIBRATION_STEPS ) )

	while( file.jumpKitCalibrationStep < JUMPKIT_CALIBRATION_STEPS )
	{
		if ( Flag( progressFlags[ index ] ) )
		{
			// printt( "next step flag", startStep, file.jumpKitCalibrationStep )
			index++
			startTime = Time()
			startStep = file.jumpKitCalibrationStep
			maxStep = int( min( startStep + stepsPerFlag, JUMPKIT_CALIBRATION_STEPS ) )
		}

		float elapsedTime = Time() - startTime
		float progress = elapsedTime / secondsPerFlag

		int currentStep = int( GraphCapped( progress, 0, 1, startStep, maxStep ) )
		if ( currentStep > file.jumpKitCalibrationStep )
		{
			// printt( "push step", startStep, file.jumpKitCalibrationStep, currentStep )
			file.jumpKitCalibrationStep = currentStep
		}
		wait 1
	}

	FlagSet( "give_doublejump" )
}

void function WaitForBreakInCombat( entity player, string endFlag = "" )
{
	player.EndSignal( "OnDestroy" )

	const TIME_NOT_SEEN = 8
	const MIN_DIST_SQRD = 512 * 512
	const LAST_SHOT_TIME = 4.0

	if ( endFlag != "" )
	{
		if ( Flag( endFlag ) )
			return
		FlagEnd( endFlag )
	}

	AddButtonPressedPlayerInputCallback( player, IN_ATTACK, PlayerFiredMainWeapon )
	OnThreadEnd(
		function() : ( player )
		{
			RemoveButtonPressedPlayerInputCallback( player, IN_ATTACK, PlayerFiredMainWeapon )
		}
	)

	while( true )
	{
		wait 1

		array<entity> npcArray = GetNPCArrayOfEnemies( TEAM_MILITIA )
		if ( npcArray.len() == 0 )
			return

		bool calm = true
		foreach( npc in npcArray )
		{
			if ( npc.IsNonCombatAI() )
				continue

			//printt( npc.GetEnemyLastTimeSeen(), Distance( npc.GetOrigin(), player.GetOrigin() ) , npc )
			if ( Time() - npc.GetEnemyLastTimeSeen() < TIME_NOT_SEEN )
			{
				calm = false
				break
			}
			else if ( DistanceSqr( npc.GetOrigin(), player.GetOrigin() ) < MIN_DIST_SQRD )
			{
				calm = false
				break
			}
		}

		if ( Time() - file.lastTimeWeaponFired < LAST_SHOT_TIME )
			calm = false

		if ( calm == true )
			return
	}
}

void function PlayerFiredMainWeapon( entity player )
{
	file.lastTimeWeaponFired = Time()
}

void function Callback_WallrunBegin( entity player )
{
//	printt( "file.wallrunStatusFlag", file.wallrunStatusFlag )

	if ( file.wallrunStatusFlag != eWallrunStatusFlag.IN_PROGRESS )
	{
		// only allow new wallruns where I've placed triggers
		if ( !Flag( "calibration_possible" ) )
			return

//		printt( "NEW WALLRUN" )
		// this means it's a brand new wallrun sequence
		file.wallrunStartTime = Time()
		thread WallrunStartCalibrationWithVerification( player )
	}

	player.Signal( "wallrun_started" )

//	printt( "new segment")
	file.wallrunStatusFlag = eWallrunStatusFlag.IN_PROGRESS
	file.wallrunStartOrigin = player.GetOrigin()
}

void function WallrunStartCalibrationWithVerification( entity player )
{
	player.EndSignal( "OnDestroy" )

	wait MIN_WALLRUN_TIME // * 0.75

	if ( !WallrunStartVerification( player ) )
	{
//		printt( "clear segment - verification failed", file.wallrunStatusFlag )

		file.wallrunStartTime = 0
		file.wallrunStartOrigin = <0, 0, 0>
		return
	}

	float progress = ( Time() - file.wallrunStartTime ) * WALLRUN_CALIBRATION_SPEED
	float startProgress = file.wallrunCalibrationProgress + progress
}

bool function WallrunStartVerification( entity player )
{
//	printt( "verification", file.wallrunStatusFlag )
	if ( !player.IsWallRunning() )
	{
//		printt( "---abort not wallrunning" )
		file.wallrunStatusFlag = eWallrunStatusFlag.ABORTED
		return false
	}

	// this it to stop the calibration from stating if the player just hangs on the wall
	if ( Distance2D( file.wallrunStartOrigin, player.GetOrigin() ) < MIN_WALLRUN_LENGTH )
	{
//		printt( "---abort run longer", Distance2D( file.wallrunStartOrigin, player.GetOrigin() ) )
		file.wallrunStatusFlag = eWallrunStatusFlag.ABORTED
		return false
	}

	vector testPoint = player.GetOrigin()
	vector start = file.wallrunStartOrigin

	foreach ( wallrunSegment in file.wallrunSegmentArray )
	{
		float startDist = GetDistanceFromLineSegment( wallrunSegment.start, wallrunSegment.end, start )
		float currentDist = GetDistanceFromLineSegment( wallrunSegment.start, wallrunSegment.end, testPoint )

		if ( currentDist < MIN_WALLRUN_NEAR_DIST )
		{
//			printt( "---abort reuse" )
			file.wallrunStatusFlag = eWallrunStatusFlag.FAIL_REUSE
			return false
		}
	}

//	printt( "---clear" )
	return true
}

void function Callback_WallrunEnd( entity player )
{
//	printt( "wallrun end", file.wallrunStatusFlag )
	thread Callback_WallrunEndThread( player )
}

void function Callback_WallrunEndThread( entity player )
{
	player.EndSignal( "OnDestroy" )

	if ( file.wallrunStatusFlag != eWallrunStatusFlag.IN_PROGRESS )
	{
//		printt( "no wallrun in progess - end" )
		WallrunCalibrationEnd( player )
		return
	}

	// wallrun ended, add the segment to current set
	WallrunAddSegment( player )

	// wait a fram so that if the player is falling of a wall isOnGround can update correctly
	WaitFrame()

	if ( !player.IsOnGround() )
	{
		thread WallrunFallTimeout( player )
		return
	}

	// wallrun sequence is over
	WallrunCalibrationEnd( player )
}

void function WallrunFallTimeout( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "wallrun_started" )
	player.EndSignal( "wallrun_ended" )

//	printt( "      timeout starting" )
	//	Dev_PrintMessage( player, "t start", "", 1.0 )

	wait WALLRUN_FALL_TIMEOUT
//	printt( "     fall timeout" )
	//	Dev_PrintMessage( player, "t end", "", 1.0 )

	// player fell for too long
	WallrunCalibrationEnd( player )
}

void function Callback_GroundTouch( entity player )
{
	if ( file.wallrunStatusFlag != eWallrunStatusFlag.IN_PROGRESS )
	{
//		printt( "landed with no wallrun in progess - end" )
		WallrunCalibrationEnd( player )
		return
	}

	if ( player.IsWallRunning() )
		return

	// add the wallrun segment if one is available
	if ( file.wallrunStartOrigin != <0,0,0> )
		WallrunAddSegment( player )

	WallrunCalibrationEnd( player )
}

void function WallrunAddSegment( entity player )
{
	Assert( file.wallrunStartOrigin != <0,0,0> )
	// printt( "ADDED SEGMENT", file.wallrunStatusFlag )

	LineSegment wallrunSegment
	wallrunSegment.start = file.wallrunStartOrigin
	wallrunSegment.end = player.GetOrigin()

	file.currentWallrunSegmentArray.append( wallrunSegment )
	file.wallrunStartOrigin = <0,0,0>
}

void function WallrunCalibrationEnd( entity player )
{
//	printt( "WallrunCalibrationEnd", file.wallrunStatusFlag )

	if ( file.wallrunStatusFlag == eWallrunStatusFlag.IN_PROGRESS && file.currentWallrunSegmentArray.len() > 0 )
	{
		file.wallrunStatusFlag = eWallrunStatusFlag.SUCCESS
		file.wallrunSegmentArray.extend( file.currentWallrunSegmentArray )

		// calulate new progress
		float progress = ( Time() - file.wallrunStartTime ) * WALLRUN_CALIBRATION_SPEED
		printt( "  PROGRESS:", progress, file.wallrunCalibrationProgress )
		file.wallrunCalibrationProgress = min( file.wallrunCalibrationProgress + progress, 1.0 )

		int currentStep = int( floor( file.wallrunCalibrationProgress * JUMPKIT_CALIBRATION_STEPS ) )
		if ( currentStep > file.jumpKitCalibrationStep )
		{
			if ( currentStep == JUMPKIT_CALIBRATION_STEPS && file.jumpKitCalibrationStep != JUMPKIT_CALIBRATION_STEPS - 1 )
			{
				currentStep = JUMPKIT_CALIBRATION_STEPS - 1
				file.wallrunCalibrationProgress = 0.99
			}

			file.jumpKitCalibrationStep = currentStep
			if ( currentStep < JUMPKIT_CALIBRATION_STEPS )
				SetJumpKitCalibrationStep( player, currentStep )
		}
	}

	if ( file.wallrunCalibrationProgress >= 1 )
		FlagSet( "give_doublejump" )

	// reset calibration
	player.Signal( "wallrun_ended" )
	file.wallrunStatusFlag = eWallrunStatusFlag.NOT_ACTIVE
	file.wallrunStartTime = 0
	file.wallrunStartOrigin = <0,0,0>
	file.currentWallrunSegmentArray	= []
}

void function SetJumpKitCalibrationStep( entity player, int step )
{
	// printt( "SetJumpKitCalibrationStep", step )
	player.SetPlayerNetInt( "jumpKitCalibrationStep", step )
	Remote_CallFunction_Replay( player, "ServerCallback_JumpKitCalibrationStep", step )
}

#if DEV
void function ClearWallruns()
{
	// reset calibration
	file.wallrunCalibrationProgress = 0
	file.wallrunStatusFlag = eWallrunStatusFlag.NOT_ACTIVE
	file.wallrunSegmentArray = []
	file.wallrunStartTime = 0
	file.wallrunStartOrigin = <0,0,0>
}

void function DrawSavedWallruns()
{
	printt( "wallrunCalibrationProgress", file.wallrunCalibrationProgress )
	foreach ( wallrunSegment in file.wallrunSegmentArray )
	{
		DebugDrawLine( wallrunSegment.start + <0,0,2>, wallrunSegment.end +  <0,0,2>, 255, 0, 0, true, 2 )
		DebugDrawLine( wallrunSegment.start, wallrunSegment.start + <2, 2, 64>, 255, 0, 0, true, 2 )
	}
}
#endif

//	########     ###    ########   #######          ########     ###    ######## ##     ##
//	##     ##   ## ##      ##     ##     ##         ##     ##   ## ##      ##    ##     ##
//	##     ##  ##   ##     ##            ##         ##     ##  ##   ##     ##    ##     ##
//	########  ##     ##    ##      #######          ########  ##     ##    ##    #########
//	##     ## #########    ##     ##                ##        #########    ##    ##     ##
//	##     ## ##     ##    ##     ##                ##        ##     ##    ##    ##     ##
//	########  ##     ##    ##     ######### ####### ##        ##     ##    ##    ##     ##

void function StartPoint_Setup_Battery2Path( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_battery2_path" )
//	Objective_Set( "#WILDS_OBJECTIVE_BATTERY2", GetEntByScriptName( "location_obj_battery2" ).GetOrigin() )
	PrimeWaypoints( GetEntByScriptName( "waypoint_start" ) )

	thread WaypointThread( player, "#WILDS_OBJECTIVE_BATTERY2", GetEntByScriptName( "waypoint_start" ), GetEntByScriptName( "location_obj_battery2" ) )
	thread ObjectiveRecurringReminder( player, "rock_block_done" )
	thread WallrunningReminder( player, "first_wallrun_completed" )
	thread LowBatteryFlyoutNag( player )
	thread BatteryNag( player )

	PlayMusic( "music_wilds_06_explore" )
}

void function StartPoint_Battery2Path( entity player )
{
	player.EndSignal( "OnDestroy" )

//	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_01_01_imc_genMarder", "diag_sp_callOut_WD752_02_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_01_01_imc_genMarder" ] )
//	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_03_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_04_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_06_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_05_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_07_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_08_01_imc_genMarder" ] )
	file.droneDialogArray.reverse()

	thread Battery2PathDirectionHintThread()
	thread Battery2PathMusic( player )
	thread Battery2PathRadio()

	FlagSet( "wallrun_recordings" )
	FlagSet( "first_ghost" )

	FlagWait( "first_wallrun_completed" )
	FlagClear( "first_ghost" )

	CheckPoint_Silent()

	// start jump kit calibration
	thread JumpKitCalibrationThread( player )

	FlagWait( "rock_block_done" )

	FlagWait( "battery2_combat" )
}

void function StartPoint_Skip_Battery2Path( entity player )
{
	FlagSet( "battery2_combat" )
	FlagSet( "wallrun_recordings" )
}

void function ObjectiveRecurringReminder( entity player, string endFlag )
{
	if ( Flag( endFlag ) )
		return
	FlagEnd( endFlag )

	const showHintAfter = 60
	const hintTimeout = 6

	wait 1 // need to wait a so that last shown time can get set correctly

	while( true )
	{
		if ( Time() > Objective_LastShownTime() + showHintAfter )
			waitthread ShowObjectiveHint( player, hintTimeout )

		// show objective even if the player doesn't press the button.
		if ( Time() > Objective_LastShownTime() + showHintAfter )
			Objective_Remind()

		wait 1
	}
}

void function WallrunningReminder( entity player, string endFlag )
{
	if ( !Flag( endFlag ) )
		FlagEnd( endFlag )
	else
		return

	const debounceTime = 2

	while( true )
	{
		FlagWait( "show_wallrun_hint" )

		DisplayOnscreenHint( player, "wallrun_reminder" )
		FlagWaitClear( "show_wallrun_hint" )

		ClearOnscreenHint( player )
		wait debounceTime
	}
}

void function Battery2PathMusic( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "battery2_see_ship" )

	StopMusicTrack( "music_wilds_06_explore" )
	StopMusicTrack( "music_wilds_05_ogdown" ) //could be playing if we rush ahead
	PlayMusic( "music_wilds_06a_seetheship" )

	FlagWait( "battery2_see_light" )

	StopMusicTrack( "music_wilds_06a_seetheship" )
	PlayMusic( "music_wilds_6b_towardthelight" )
}

void function Battery2PathRadio()
{
	FlagWait( "first_wallrun_completed" )

	wait 3

	entity radio = GetEntByScriptName( "dead_imc_grunt_first_radio" )

	// The Ark is being transferred for recasing. Tech has a new shell design.
	// Blisk wants no less than four regiments securing that firebase before the Draconis jumps in.
	float duration = EmitSoundAtPosition( TEAM_UNASSIGNED, radio.GetOrigin(), "diag_sp_patrolChat_WD762_11_01_imc_gCaptain" )
	wait duration

	// Kappa One is on deck.
	duration = EmitSoundAtPosition( TEAM_UNASSIGNED, radio.GetOrigin(), "diag_sp_patrolChat_WD762_12_01_imc_grunt1" )
	wait duration

	// Negative, Kappa One, I need you at the testing facility. Alpha Six, reposition at the firebase.
	duration = EmitSoundAtPosition( TEAM_UNASSIGNED, radio.GetOrigin(), "diag_sp_patrolChat_WD762_13_01_imc_gCaptain" )
	wait duration

	// Copy that. We're on our way.
	duration = EmitSoundAtPosition( TEAM_UNASSIGNED, radio.GetOrigin(), "diag_sp_patrolChat_WD762_14_01_imc_grunt2" )
}

void function Battery2PathDirectionHintThread()
{
	// if the player is loitering around in the BT area spawn some
	// prowlers and maybe a drone to draw the player in the right direction
	if ( Flag( "first_wallrun_completed" ) )
		return

	FlagEnd( "first_wallrun_completed" )

	wait 5

	waitthread BatteryPathHintProwlers()

	wait 8
	FlagWait( "bat2_path_hint_active" )

	thread BatteryPathHintDrone()
}

void function BatteryPathHintProwlers()
{
	FlagEnd( "first_wallrun_completed" )

	array<entity> spawnerArray = GetSpawnerArrayByScriptName( "bat2_intro_prowler" ) //bat2_path_hint_prowler

	array<entity> prowerlArray = SpawnFromSpawnerArray( spawnerArray )
	foreach( prowler in prowerlArray )
	{
		thread DestroyOnFlag( prowler, "battery2_combat" )
		thread HintProwlersThinkhread( prowler )
		WildsProwlerSettings( prowler )
		prowler.SetLookDistOverride( 1500 )
	}

	FlagWait( "prowler_retreat" )

	wait 5
	WaitUntilAllDead( prowerlArray )
}

void function HintProwlersThinkhread( entity prowler )
{
	prowler.EndSignal( "OnDeath" )
	prowler.EndSignal( "OnDamaged" )

	OnThreadEnd(
		function() : ()
		{
			FlagSet( "prowler_retreat" )
		}
	)

	while( prowler.GetEnemy() == null )
		wait 1
}

void function BatteryPathHintDrone()
{
	FlagSet( "path_hint_drone_flown" )

	entity spawner = GetSpawnerByScriptName( "bat2_path_hint_drone" )
	entity drone = SpawnFromSpawner( spawner )
	drone.EndSignal( "OnDeath" )
	int newHealth = drone.GetMaxHealth() * 4
	drone.SetMaxHealth( newHealth  )
	drone.SetHealth( newHealth  )

	drone.EndSignal( "OnDestroy" )
	drone.Signal( "StopDoingJobs" )
	thread DestroyOnSignal( drone, "destroy_me")

	thread AssaultLinkedMoveTarget( drone )

	WaitSignal( drone, "OnDamaged" )

	if ( Flag( "bat2_path_hint_drone_escape" ) )
		return

	StopAssaultMoveTarget( drone )

	entity node = GetEntByScriptName( "bat2_path_hint_drone_escape" )
	thread AssaultMoveTarget( drone, node )
}

void function FlybyFuncBrush( entity funcBrush )
{
	funcBrush.Hide()
	FlagWait( "flyby_go" )
	funcBrush.Show()
	entity mover = funcBrush.GetParent()
	EmitSoundOnEntity ( mover, "Wilds_Scr_ShipsTowingCargo")
	FlagWait( "flyby_kill" )

	mover.Destroy()
}

//	########     ###    ########   #######           ######   #######  ##     ## ########     ###    ########
//	##     ##   ## ##      ##     ##     ##         ##    ## ##     ## ###   ### ##     ##   ## ##      ##
//	##     ##  ##   ##     ##            ##         ##       ##     ## #### #### ##     ##  ##   ##     ##
//	########  ##     ##    ##      #######          ##       ##     ## ## ### ## ########  ##     ##    ##
//	##     ## #########    ##     ##                ##       ##     ## ##     ## ##     ## #########    ##
//	##     ## ##     ##    ##     ##                ##    ## ##     ## ##     ## ##     ## ##     ##    ##
//	########  ##     ##    ##     #########          ######   #######  ##     ## ########  ##     ##    ##

void function StartPoint_Setup_Battery2Combat( entity player )
{
	Objective_Set( "#WILDS_OBJECTIVE_BATTERY2", GetEntByScriptName( "location_obj_battery2" ).GetOrigin() )
	thread BatteryNag( player )

	PlayMusic( "music_wilds_6b_towardthelight" )

	thread MovePlayerToStartpoint( player, "startpoint_battery2_combat" )
	thread JumpKitCalibrationThread( player, 0.70 )

	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_04_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_06_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_05_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_07_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_08_01_imc_genMarder" ] )
	file.droneDialogArray.reverse()
}

void function StartPoint_Battery2Combat( entity player )
{
	player.EndSignal( "OnDestroy" )

	thread Battery2CombatMusic( player )

	thread LedgeGuys( player )
	thread ShowMeleeHint( player )

	thread Battery2Combat_ShowCloakHint( player )
	thread Battery2CustomCombatChatter( player )
	thread CanyonCombat( player )

	thread Battery2CombatCave( player )

	thread CheckpointOnFlag( "combat_canyon_lowerleft_cleared", true, GetEntArrayByScriptName( "safepoint_lowerleft_cleared" ) )
	thread CheckpointOnFlag( "battery2_combat_upper_area", true, GetEntArrayByScriptName( "safepoint_upper_area" ) )
	thread CheckpointOnFlag( "battery2_combat_zipline_landing", true, GetEntArrayByScriptName( "safepoint_zipline_landing" ) )
	thread CheckpointOnFlag( "battery2_combat_cave_entrance", true )

	// cull leftover enemies as the player progresses
	thread CullEnemies( player, "prowler_group_2", "battery2_combat" )
	thread CullEnemies( player, "ledge_group", "battery2_combat_ravine_crossed" )
	thread CullEnemies( player, "combat_canyon_leftside_group", "battery2_combat_ravine_crossed", 3 )
	thread CullEnemies( player, "combat_canyon_leftside_group", "battery2_combat_sniper_attack" )
	thread CullEnemies( player, "combat_canyon_rightside_group", "battery2_combat_sniper_attack" )
	thread CullEnemies( player, "combat_cave_drone_group", "battery2ship_enter" )
	thread CullEnemies( player, "combat_cave_grunt_group", "battery2ship_enter" )
	thread CullEnemies( player, "combat_cave_spectre_group", "battery2ship_enter" )
	thread CullEnemies( player, "combat_cave_prowler_group", "battery2ship_enter" )

	FlagWait( "exit_combat_cave" )
}

void function StartPoint_Skip_Battery2Combat( entity player )
{
	FlagSet( "DeathHintsEnabled" )

	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [] )
}

void function Battery2Combat_ShowCloakHint( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	const HINT_DISPLAY_TIME = 8.0

	FlagWait( "battery2_combat_custom_chatter" )
	wait 2

	// make sure we don't hint when you can't actually use the cloak
	entity weapon = player.GetOffhandWeapon( OFFHAND_LEFT )
	weapon.EndSignal( "OnDestroy" )
	while( weapon.GetWeaponPrimaryClipCount() != weapon.GetWeaponPrimaryClipCountMax() )
		wait 0.5

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
			if ( IsValid( player ) )
				RemoveButtonPressedPlayerInputCallback( player, IN_OFFHAND1, PlayerUsedCloak )
		}
	)

	AddButtonPressedPlayerInputCallback( player, IN_OFFHAND1, PlayerUsedCloak )
	DisplayOnscreenHint( player, "cloak_hint" )
	waitthread WaitSignalOrTimeout( player, HINT_DISPLAY_TIME, "used_cloak" )
	wait 0.5
}

void function Battery2CombatMusic( entity player )
{
	player.EndSignal( "OnDestroy" )

	// play drums on top of current music
	thread Battery2CombatMusicDrumsUpper()
	thread Battery2CombatMusicDrumsZip()
	thread Battery2CombatMusicDrumsEntrance()

	// combat has started
	player.WaitSignal( "combat_started" )
	StopMusicTrack( "music_wilds_6b_towardthelight" )
	PlayMusic( "music_wilds_07_combatstart" )
	PlayMusic( "music_wilds_07_combat" )

	// crossed the ravine
	FlagWaitAny( "battery2_combat_cave_entrance", "battery2_combat_zipline_landing" )
	StopMusicTrack( "music_wilds_07_combatstart" )
	StopMusicTrack( "music_wilds_07_combat" )
	PlayMusic( "music_wilds_08_combatphase02" )

	// entered the cave area
	FlagWait( "battery2_combat_enter_cave" )

	StopMusicTrack( "music_wilds_08_combatphase02" )
	PlayMusic( "music_wilds_09_combatphase03" )
}

void function Battery2CombatMusicDrumsUpper()
{
	FlagEnd( "battery2_combat_cave_entrance" )
	FlagEnd( "battery2_combat_zipline_landing" )

	// play drums
	FlagWait( "battery2_combat_upper_area" )
	PlayMusic( "music_wilds_07_combatstart" )
}

void function Battery2CombatMusicDrumsZip()
{
	FlagEnd( "battery2_combat_enter_cave" )

	// play drums
	FlagWait( "battery2_combat_zipline_landing" )
	StopMusicTrack( "music_wilds_08_combatphase02start" )
	PlayMusic( "music_wilds_08_combatphase02start" )
}

void function Battery2CombatMusicDrumsEntrance()
{
	FlagEnd( "battery2_combat_enter_cave" )

	// play drums
	FlagWait( "battery2_combat_cave_entrance" )
	StopMusicTrack( "music_wilds_08_combatphase02start" )
	PlayMusic( "music_wilds_08_combatphase02start" )
}

void function LedgeGuys( entity player )
{
	player.EndSignal( "OnDestroy" )

	array<entity> npcSpawnerArray = GetSpawnerArrayByScriptName( "ledge_guy" )
	array<entity> npcArray = SpawnFromSpawnerArray( npcSpawnerArray )

	npcArray = ArrayClosest( npcArray, player.GetOrigin() )
	Assert( npcArray.len() >= 2 )

	entity npc1 = npcArray[0]
	entity npc2 = npcArray[1]
	entity npc3 = npcArray[2]

	thread LedgeGuy3Dialog( npc3 )

	npc1.DisableNPCFlag( NPC_ALLOW_PATROL )
	npc2.DisableNPCFlag( NPC_ALLOW_PATROL )

	npc1.SetHearingSensitivity( 0.75 )
	npc2.SetHearingSensitivity( 0.75 )

	npc1.AssaultSetArrivalTolerance( 32 )
	npc1.AssaultSetArrivalTolerance( 32 )

	npc1.EndSignal( "OnHearCombat" )
	npc1.EndSignal( "OnFoundEnemy" )
	npc1.EndSignal( "OnSeeEnemy" )
	npc1.EndSignal( "OnDeath" )

	npc2.EndSignal( "OnHearCombat" )
	npc2.EndSignal( "OnFoundEnemy" )
	npc2.EndSignal( "OnSeeEnemy" )
	npc2.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			FlagSet( "player_at_ledge" )
			if ( IsValid( player ) )
			{
				player.Signal( "combat_started" )
			}
		}
	)

	wait 1

	// We work for the IMC. Not Blisk or his Mercenaries.
	// We work for whoever the IMC say we work for.
	// What are you trying to get? A medal?
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD701_01_01_mcor_grunt1", npc1 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD701_02_01_mcor_grunt2", npc2 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD701_03_01_mcor_grunt1", npc1 )

	wait 2

	// I don't care who's giving the orders. Blisk and his mercs...General Marder...us grunts get paid the same either way.
	// All that matters is that thing in the mountains goes online as scheduled.
	// You think it's true? What the techs are saying about it?
	// Do I look like a bloody anorak to you mate?...But if it is true then the Militia are going to have a very bad day.
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD701_04_01_imc_grunt2", npc2 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD701_05_01_imc_grunt1", npc1 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD701_06_01_imc_grunt2", npc2 )

	FlagWait( "show_melee_hint" )
	wait 10
}

void function LedgeGuy3Dialog( entity npc3 )
{
	npc3.EndSignal( "OnDeath" )

	WaitSignal( npc3, "OnSeeEnemy" ) //, "OnFoundEnemy" )
	thread PlayDialogue( "diag_sp_batteryC_WD161_10_01_imc_grunt1", npc3 )
}

void function ShowMeleeHint( entity player )
{
	player.EndSignal( "OnDestroy" )

	const HINT_DISPLAY_TIME = 4.0

	FlagWait( "show_melee_hint" )
	wait 1

	if ( svGlobalSP.gruntCombatState != eGruntCombatState.IDLE || Flag( "ledge_guys_dead" ) )
		return

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
			if ( IsValid( player ) )
				RemoveButtonPressedPlayerInputCallback( player, IN_MELEE, PlayerUsedMelee )
		}
	)

	AddButtonPressedPlayerInputCallback( player, IN_MELEE, PlayerUsedMelee )
	DisplayOnscreenHint( player, "melee_hint" )
	waitthread WaitSignalOrTimeout( player, HINT_DISPLAY_TIME, "used_melee" )
	wait 0.5
}

void function PlayerUsedMelee( entity player )
{
	player.Signal( "used_melee" )
}

void function CanyonCombat( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWaitAny( "battery2_combat_cave_entrance", "battery2_combat_zipline_landing" )

	entity assaultEnt = GetEntByScriptName( "after_zipline_assaultpoint" )

	array<entity> npcArray = GetNPCArrayEx( "npc_soldier", TEAM_IMC, -1, <0,0,0>, -1 )
	foreach( npc in npcArray )
	{
		if ( !npc.HasKey( "script_group" ) || npc.kv.script_group != "combat_canyon_leftside_group" )
			continue
		if ( IsAlive( npc ) )
			thread GruntUseZipline( npc, assaultEnt )
	}
}

void function Battery2CombatCave( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "battery2_combat_sniper_attack" )

	array<entity> weaponArray = player.GetMainWeapons()
	foreach( weapon in weaponArray )
	{
		// could also check weapon subclass? but since I only have the dmr in the level, that seems unnecessary
		if ( weapon.GetWeaponClassName() == "mp_weapon_dmr" )
		{
			CheckPointData cpData
			cpData.safeLocations = GetEntArrayByScriptName( "safepoint_combat_cave" )
			cpData.skipSaveToActualPlayerLocation = true
			CheckPoint_Silent( cpData )
			break
		}
	}

	entity ent = GetEntByScriptName( "battery2_cave_dropdown_pos" )

	array<entity> spawnerArray = GetSpawnerArrayByScriptName( "battery2_cave_dropdown_sniper" )
	array<entity> npcArray = SpawnFromSpawnerArray( spawnerArray )

	waitthread WaitTillLookingAt( player, ent, true, 25, 0, 0, null, "battery2_cave_dropdown_force" )
	SpawnFromSpawner( GetEntByScriptName( "battery2_cave_dropdown_drone" ) )

	FlagWait( "battery2_cave_dropdown_force" )
	SpawnFromSpawnerArray( GetSpawnerArrayByScriptName( "battery2_cave_dropdown_spectre" ) )

	thread DisplaySpectreLeechHint( player, 10.0 )

	FlagWaitWithTimeout( "battery2_cave_prowler_force", 10 )
	SpawnFromSpawnerArray( GetSpawnerArrayByScriptName( "battery2_cave_dropdown_prowler" ) )
}

void function Battery2CustomCombatChatter( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( "battery2_combat_zipline_landing" )
	FlagEnd( "battery2_combat_cave_entrance" )

	SetPlayerForcedDialogueOnly( player, true )

	FlagWait( "battery2_combat_custom_chatter" )
	// wait for combat to start
	while( svGlobalSP.gruntCombatState != eGruntCombatState.COMBAT )
		wait 1

	OnThreadEnd(
		function() : ( player )
		{
			SetPlayerForcedDialogueOnly( player, false )
		}
	)

	array<array> conversationArray = [
		[ "diag_sp_alerted_WD730_01_01_imc_grunt1", "diag_sp_alerted_WD730_02_01_imc_grunt2", "diag_sp_alerted_WD730_03_01_imc_grunt3" ],
		[ "diag_sp_alerted_WD730_04_01_imc_grunt1", "diag_sp_alerted_WD730_05_01_imc_grunt2", "diag_sp_alerted_WD730_06_01_imc_grunt3" ]
	]

	for( int conversationIndex = 0; conversationIndex < conversationArray.len(); conversationIndex++ )
	{
		array<entity> npcArray

		int minNpcCount = conversationArray[ conversationIndex ].len()
		while( true )
		{
			npcArray = GetNPCArrayEx( "npc_soldier", TEAM_IMC, -1, player.GetOrigin(), 768 )
			if ( npcArray.len() < minNpcCount )
			{
				wait 1
				minNpcCount = maxint( 1, minNpcCount -1 )
				continue
			}
			break
		}

		int lineIndex = 0
		foreach( npc in npcArray )
		{
			if ( !IsAlive( npc ) )
				continue

			if ( lineIndex >= conversationArray[ conversationIndex ].len() )
				break

			string line = expect string( conversationArray[ conversationIndex ][ lineIndex ] )
			//			printt( "combat chatter:", line )
			wait EmitSoundOnEntity( npc, line )

			lineIndex++
		}

		wait RandomFloatRange( 5, 10 )
	}
}

void function DisplaySpectreLeechHint( entity player, float delay = 0.0 )
{
	player.EndSignal( "OnDeath" )

	wait delay

	DisplayOnscreenHint( player, "leech_hint" )

	OnThreadEnd(
	function() : ( player )
		{
			ClearOnscreenHint( player )
		}
	)

	waitthread WaitSignalOrTimeout( player, 10.0, "OnStartLeech" )

	wait 0.5
}

//	########     ###    ########   #######           ######  ##     ## #### ########
//	##     ##   ## ##      ##     ##     ##         ##    ## ##     ##  ##  ##     ##
//	##     ##  ##   ##     ##            ##         ##       ##     ##  ##  ##     ##
//	########  ##     ##    ##      #######           ######  #########  ##  ########
//	##     ## #########    ##     ##                      ## ##     ##  ##  ##
//	##     ## ##     ##    ##     ##                ##    ## ##     ##  ##  ##
//	########  ##     ##    ##     #########          ######  ##     ## #### ##


void function StartPoint_Setup_Battery2Ship( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_battery2_ship" )

	AddSpawnCallback_ScriptName( "bat2_return_prowler", Battery2ReturnProwler )

	Objective_Set( "#WILDS_OBJECTIVE_BATTERY2", GetEntByScriptName( "location_obj_battery2" ).GetOrigin() )
	thread BatteryNag( player )

//	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_05_01_imc_genMarder", "diag_sp_callOut_WD752_07_01_imc_genMarder", "diag_sp_callOut_WD752_08_01_imc_genMarder"] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_05_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_07_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_08_01_imc_genMarder" ] )
	file.droneDialogArray.reverse()
}

void function StartPoint_Battery2Ship( entity player )
{
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )

	Objective_Remind()

	thread Battery2ShipMusic( player )
	thread ShipAmbientDialogue( "ship_stern_speaker", "slot_battery2" )
	thread Battery2ShipCrouchHint( player )

	thread Battery2ShipLoopBlocker()
	thread Battery2ShipBacktrackBlocker( player )

	thread Battery2ShipObjectiveReminder()

	thread Battery2Ship_Battery_Pickup( player )
	thread Battery2ReturnEnemies( player )

	// cull leftover enemies as the player progresses
	thread CullEnemies( player, "battery2_ship_drone_group", "battery2_acquired" )
	thread CullEnemies( player, "battery2_return_prowler", "battery2_crossed_river" )

	FlagWait( "battery2_acquired" )

	// remove passby blocker
	entity ent = GetEntByScriptName( "battery2_ship_passby_blocker" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, ent.GetOrigin(), "Wilds_Scr_ShipDebrisFall_2" )
//	EmitSoundOnEntity( player, "Wilds_Scr_ShipDebrisFall_2" )
	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 2.5, 10, 2.0 )
	ent.Destroy()

	Objective_Set( "#WILDS_OBJECTIVE_BATTERY2_RETURN", file.buddyTitan.l.BTHightlightModel.GetOrigin() )

	ClearQuickDeath()
	CheckPoint()

	FlagWait( "battery2_crossed_river" )
	ClearQuickDeath()
	CheckPoint()
}

void function StartPoint_Skip_Battery2Ship( entity player )
{
	FlagSet( "battery2_acquired" )
	FlagSet( "scavengers_dead" )
}

void function Battery2ShipMusic( entity player )
{
	player.EndSignal( "OnDestroy" )

	StopMusicTrack( "music_wilds_09_combatphase03" )
	PlayMusic( "music_wilds_10_postcombatpreship" )

	FlagWait( "battery2ship_enter" )
	StopMusicTrack( "music_wilds_10_postcombatpreship" )
	PlayMusic( "music_wilds_11_insideship" )

	player.WaitSignal( "battery_pickup_music_cue" )

	StopMusicTrack( "music_wilds_11_insideship" )
	PlayMusic( "music_wilds_12_batterytwo" )

	FlagWait( "postshipprowlers_music_cue" )

	StopMusicTrack( "music_wilds_12_batterytwo" )
	PlayMusic( "music_wilds_13_postshipprowlers" )

	FlagWait( "scavengers_dead" )
	StopMusicTrack( "music_wilds_13_postshipprowlers" )
	PlayMusic( "music_wilds_14_timetoinstallbatterytwo" )

	wait 80	// time to wait as directed by Nick Laviers
	StopMusicTrack( "music_wilds_07_combat" )
	StopMusicTrack( "music_wilds_08_combatphase02" )
	StopMusicTrack( "music_wilds_14_timetoinstallbatterytwo" )
	PlayMusic( "music_wilds_15_explorealt" )
}

void function Battery2ShipObjectiveReminder()
{
	FlagWait( "battery2ship_enable_backtrack_blocker_threat" )
	Objective_Remind()
}

void function Battery2ShipCrouchHint( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagEnd( "battery2_acquired" )
	while( true )
	{
		FlagWait( "battery2ship_crawl_space" )
		waitthread Battery2ShipCrouchHintDelay( player )
	}
}

void function Battery2ShipCrouchHintDelay( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagClearEnd( "battery2ship_crawl_space" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
				ClearOnscreenHint( player )
		}
	)

	wait 1

	if ( player.IsCrouched() )
		return

	thread DisplayOnscreenHint( player, "crouch_hint", 5 )

	while( !player.IsCrouched() )
		wait 0.1
}

void function Battery2ShipBacktrackBlocker( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity ent = GetEntByScriptName( "battery2_ship_backtrack_blocker" )
	entity mover = CreateScriptMover( ent.GetOrigin(), ent.GetAngles() )
	ent.SetParent( mover )

	FlagWait( "battery2ship_enable_backtrack_blocker_threat" )

	entity pos = ent.GetLinkEnt()
	mover.NonPhysicsMoveTo( pos.GetOrigin(), 0.5, 0.0, 0.25 )
	mover.NonPhysicsRotateTo( pos.GetAngles(), 0.5, 0.0, 0.25 )

	EmitSoundOnEntity( player, "Wilds_Scr_ShipTremor_Crate" )
	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 2.5, 10, 2.0 )

	FlagWait( "battery2ship_enable_backtrack_blocker" )

	pos = pos.GetLinkEnt()
	mover.NonPhysicsMoveTo( pos.GetOrigin(), 0.5, 0.5, 0.0 )
	mover.NonPhysicsRotateTo( pos.GetAngles(), 0.5, 0.5, 0.0 )

	array<entity> debrisArray = GetEntArrayByScriptName( "battery2ship_backtrack_debris" )
	foreach( debris in debrisArray )
		EntFireByHandle( debris, "wake", "", 0, null, null )

	EmitSoundOnEntity( player, "Wilds_Scr_ShipDebrisFall_1" )
	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 4, 16, 3.5 )
}

void function Battery2ShipLoopBlocker()
{
	array<entity> entArray = GetEntArrayByScriptName( "battery2_ship_loop_blocker" )
	while( true )
	{
		FlagWaitClear( "battery2ship_enable_loop_blocker" )
		foreach( ent in entArray )
		{
			ent.Hide()
			ent.NotSolid()
		}

		FlagWait( "battery2ship_enable_loop_blocker" )
		foreach( ent in entArray )
		{
			ent.Show()
			ent.Solid()
		}
	}
}

void function Battery2Ship_Battery_Pickup( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity battery = CreatePickupBattery( "anim_ref_battery2_new", "wilds_battery_pickup", "battery2_use_proxy" )
	battery.l.useDummy.WaitSignal( "OnPlayerUse" )

	player.DisableWeapon()
	battery.l.useDummy.Destroy()

	Objective_Clear()
	player.Signal( "battery_pickup_music_cue" )

	entity scriptRef = GetEntByScriptName( "anim_ref_battery2_new" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	FirstPersonSequenceStruct sequenceTakeBattery
	sequenceTakeBattery.attachment = "ref"
	sequenceTakeBattery.firstPersonAnim = "ptpov_wilds_battery_pickup"
	sequenceTakeBattery.thirdPersonAnim = "pt_wilds_battery_pickup"
	sequenceTakeBattery.viewConeFunction = ViewConeTight

	player.SetAnimNearZ(1)

	thread PlayAnim( battery, "wilds_battery_pickup", animRef )
	waitthread FirstPersonSequence( sequenceTakeBattery, player, animRef )

	player.ClearAnimNearZ()

	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

	ShowBatteryIcon( player )
	player.EnableWeaponWithSlowDeploy()

	animRef.Destroy()
	battery.Destroy()

	int fxId = GetParticleSystemIndex( $"P_xo_battery" )
	int attachmentId = player.LookupAttachment( "BATTERY_ATTACH" )
	file.batteryCarryFx = StartParticleEffectOnEntity_ReturnEntity( player, fxId, FX_PATTACH_POINT_FOLLOW, attachmentId )

	FlagSet( "battery2_acquired" )
}

void function Battery2ReturnProwler( entity prowler )
{
	prowler.SetBehaviorSelector( "behavior_prowler_cqb" )
	WildsProwlerSettings( prowler )
}

void function ShipAmbientDialogue( string speakerName = "ship_stern_speaker", string endSignal = "slot_battery2" )
{
	array<entity> speakerArray = GetEntArrayByScriptName( speakerName )

	FlagEnd( endSignal )

	while( true )
	{
		if ( speakerName == "ship_stern_speaker" )
		{
			// EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD120_01_01_mcor_sarah" )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_23_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_24_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_25_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_26_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_27_01_mcor_sarah" )
			wait RandomFloatRange( 6, 12 )
		}
		else
		{
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_27a_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_28_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_29_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_29a_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_29b_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_30_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_30a_01_mcor_sarah" )
			wait RandomFloatRange( 4, 6 )
			EmitSoundOnEntArray( speakerArray, "diag_sp_batteryA_WD121_31_01_mcor_sarah" )
			wait RandomFloatRange( 6, 12 )
		}
	}
}

void function Battery2ReturnEnemies( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "battery2_return_enemies" )

	FlagSet( "pause_battery_nag" ) // Pause until enemies are dead

	array<entity> npcSpawnerArray = GetSpawnerArrayByScriptName( "bettery2_return_enemy" )
	array<entity> npcArray = SpawnFromSpawnerArray( npcSpawnerArray )

	npcArray = ArrayClosest( npcArray, player.GetOrigin() )
	Assert( npcArray.len() >= 2 )

	foreach( npc in npcArray )
	{
		npc.DisableNPCFlag( NPC_ALLOW_PATROL )
		if( npc.HasKey( "script_noteworthy" ) && npc.kv.script_noteworthy != "" )
			npc.SetIdleAnim( string( npc.kv.script_noteworthy ) )

		entity node = npc.GetLinkEnt()
		npc.SetOrigin( node.GetOrigin() )
		npc.SetAngles( node.GetAngles() )
	}

	thread ReturnEnemiesDialogue( player, npcArray )

	player.WaitSignal( "combat_started" )

/*
	foreach( npc in npcArray )
	{
		if ( !IsAlive( npc ) )
			continue
		npc.EnableNPCFlag( NPC_ALLOW_PATROL )
		if( npc.HasKey( "script_noteworthy" ) && npc.kv.script_noteworthy != "" )
		{
			entity animRef = npc.GetLinkEnt()
			if ( !npc.ContextAction_IsActive() )
				thread PlayAnim( npc, npc.kv.script_noteworthy, animRef )
		}
		else
		{
			if ( !npc.ContextAction_IsActive() )
				npc.Anim_Stop()
		}
	}
*/

	FlagWait( "scavengers_dead" )
	FlagClear( "pause_battery_nag" )
}

void function ReturnEnemiesDialogue( entity player, array<entity> npcArray )
{
	player.EndSignal( "OnDestroy" )

	entity npc1 = npcArray[0]
	entity npc2 = npcArray[1]
	entity npc3 = npcArray[2]

	OnThreadEnd(
		function() : ( player, npcArray )
		{
			player.Signal( "combat_started" )

			foreach( npc in npcArray )
			{
				if ( IsAlive( npc ) )
				{
					npc.ClearIdleAnim()
					npc.DisableLookDistOverride()
				}
			}
		}
	)

	foreach( npc in npcArray )
	{
		npc.SetLookDistOverride( 640 )
		npc.EndSignal( "OnHearCombat" )
		npc.EndSignal( "OnFoundEnemy" )
		npc.EndSignal( "OnSeeEnemy" )
		npc.EndSignal( "OnDeath" )
	}

	FlagWait( "battery2_crossed_river" )
	wait 2


	// these should be replaced with new converstaions
/*
	Around BT
	- A Vanguard-class Titan.
	- These things are rare. We should sell it.
	- No bloody way. Those weren't Blisk's orders.
	- That guy doesn't scare me. None of those mercenaries do.
	- Sure. You say that now. Just wait till they got a gun to your head.

	- I still got my piece of MacAllan's Titan from Demeter.
	- I wouldn't bring up Demeter when Blisk's around.
	- Careful - I wouldn't bring up Demeter when Blisk's around. You remember what happened to Manny.
	- Yeah. Yeah...yeah. Maybe you're right...uh...let's forget I said anything.
*/


	waitthread PlayGabbyDialogue( "diag_sp_batteryA_WD122_01_01_mcor_grunt1", npc1 )
	waitthread PlayGabbyDialogue( "diag_sp_batteryA_WD122_01_01_mcor_grunt2", npc2 )
	waitthread PlayGabbyDialogue( "diag_sp_batteryA_WD122_01_01_mcor_grunt3", npc3 )
	waitthread PlayGabbyDialogue( "diag_sp_batteryA_WD122_04_01_imc_grunt1", npc1 )
	waitthread PlayGabbyDialogue( "diag_sp_batteryA_WD122_05_01_imc_grunt3", npc3 )

	wait 6

	foreach( npc in npcArray )
	{
		if ( IsAlive( npc ) )
			npc.DisableLookDistOverride()
	}

	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD703_01_01_mcor_grunt5", npc1 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD703_02_01_mcor_grunt6", npc2 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD703_03_01_mcor_grunt5", npc1 )

	wait 4
}

//	########     ###    ########   #######          ########     ###    ######## ##     ##
//	##     ##   ## ##      ##     ##     ##         ##     ##   ## ##      ##    ##     ##
//	##     ##  ##   ##     ##            ##         ##     ##  ##   ##     ##    ##     ##
//	########  ##     ##    ##      #######          ########  ##     ##    ##    #########
//	##     ## #########    ##            ##         ##        #########    ##    ##     ##
//	##     ## ##     ##    ##     ##     ##         ##        ##     ##    ##    ##     ##
//	########  ##     ##    ##      #######          ##        ##     ##    ##    ##     ##

void function StartPoint_Setup_Battery3Path( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_battery3_path" )

	Objective_Set( "#WILDS_OBJECTIVE_BATTERY2_RETURN", file.buddyTitan.l.BTHightlightModel.GetOrigin() )

	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_05_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_07_01_imc_genMarder" ] )
	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_08_01_imc_genMarder" ] )
	file.droneDialogArray.reverse()

	ShowBatteryIcon( player )
}

void function StartPoint_Battery3Path( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagClear( "wallrun_recordings" )

	thread InstallBatteryObjective( player, "scavengers_dead", 5, "slot_battery2_begin" )
	waitthread Battery3Path_SlotBattery( player )
	CreateBTStaticCollision( BT_IDLE_COLLISION_3 )

	thread Battery3Path_Dialog( player )
	thread Battery3Path_Conversation( player )
	thread Battery3Path_BuddyTitan( player )
	thread Battery3Path_CanyonCombat( player )

	PrimeWaypoints( GetEntByScriptName( "waypoint_battery3_start" ) )

	FlagSet( "path2_first_ghost" )
	FlagSet( "doublejump_recordings" )

	// clear passby blocker
	GetEntByScriptName( "battery3_path_ramp_up" ).Destroy()
	GetEntByScriptName( "battery3_path_ramp_down" ).Show()
	GetEntByScriptName( "battery3_path_ramp_down" ).Solid()

	FlagWait( "battery_tracker2_commence" )
	waitthread BatteryTracker2( player )

//	Objective_Set( "#WILDS_OBJECTIVE_BATTERY3", GetEntByScriptName( "location_obj_battery3" ).GetOrigin() )
	thread WaypointThread( player, "#WILDS_OBJECTIVE_BATTERY3", GetEntByScriptName( "waypoint_battery3_start" ), GetEntByScriptName( "location_obj_battery3" ) )

	wait 2
	CheckPoint()

	thread Battery3Nag( player )
	thread CullEnemies( player, "battery3_canyon_group", "battery3_combat_start" )

	FlagWait( "battery3_combat_start" )
}

void function StartPoint_Skip_Battery3Path( entity player )
{
	file.batteriesInstalled = 2
	FlagSet( "slot_battery2_begin" )
	FlagSet( "slot_battery2" )
	FlagSet( "doublejump_recordings" )

	CreateBTStaticCollision( BT_IDLE_COLLISION_3 )

	GetEntByScriptName( "battery3_path_ramp_up" ).Destroy()
	GetEntByScriptName( "battery3_path_ramp_down" ).Show()
	GetEntByScriptName( "battery3_path_ramp_down" ).Solid()

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	thread PlayAnimTeleport( file.buddyTitan, "BT_third_battery_idle", scriptRef )

	int bodyGroupIndex = file.buddyTitan.FindBodyGroup( "battery_cap_center" )
	file.buddyTitan.SetBodygroup( bodyGroupIndex, 0 )
}

void function Battery3Nag( entity player )
{
	if ( Flag( "battery3_crossed_river" ) )
		return

	FlagEnd( "battery3_crossed_river" )

	wait 45
	waitthread PlayerConversation( "Battery3Nag", player )
	Objective_Remind()
}

void function Battery3Path_Dialog( entity player )
{
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )
	FlagEnd( "battery3_combat_start" )

	wait 1
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143_02_01_mcor_bt" )
	wait 0.5
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143_03_01_mcor_bt" )

	waitthread PlayerConversation( "StatusUpdate", player )

	wait 1.5

	// My systems are rebooting, but a third battery will accelerate the process. I will remain here.
	waitthread PlayBTDialogue( "diag_sp_postBattery2_WD141b_01_01_mcor_bt" )

	FlagSet( "battery_tracker2_commence" )
	FlagWait( "battery_tracker2_completed" )

	// make sure we don't overlap with some other dialog
	while( IsConversationPlaying() )
		wait 1.0

	// Until I am mobile, I will assist you through your helmet radio when possible.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143_05_01_mcor_bt" )

	FlagWait( "bat3path_dialog" )
	wait 2

	while( IsConversationPlaying() )
		wait 1.0

	// Pilot, my mapping systems have been restored.
	waitthread PlayBTDialogue( "diag_sp_postBattery2_WD141b_03_01_mcor_bt" )

	// The ambush of the 9th Militia Fleet has landed us far off course from our original destination.
	waitthread PlayBTDialogue( "diag_sp_postBattery2_WD141b_04_01_mcor_bt" )

	// We are located in hostile territory. Be careful. We cannot stay here long.
	waitthread PlayBTDialogue( "diag_sp_postBattery2_WD141b_05_01_mcor_bt" )

	waitthread PlayerConversation( "Survival", player )
}

void function Battery3Path_Conversation( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( "battery3_combat_start" )

	WaitSignal( level, "drone_broadcast_completed" )

	// make sure we don't overlap with some other dialog
	while( IsDialoguePlaying() || IsConversationPlaying() )
		wait 0.5

	waitthread PlayerConversation( "BroadcastWarning", player )
}

void function BatteryTracker2( entity player )
{
	player.EndSignal( "OnDestroy" )

	array<entity> fakelocs = GetEntArrayByScriptName( "fake_battery_locs_2" )
	entity realLoc = GetEntByScriptName( "location_obj_battery3" )

	waitthread BatteryTrackerThread( player, fakelocs, realLoc, 3.0 )
	FlagSet( "battery_tracker2_completed" )
}

//	inserting battery 2
void function Battery3Path_SlotBattery( entity player )
{
	Assert( IsAlive( file.buddyTitan ) )
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )

	entity useDummy = CreateUseDummy( file.buddyTitan, "CHESTFOCUS",  < 15, -20, -15 >, "#WILDS_BATTERY_NEUTRALIZE_ENEMIES", "#WILDS_BATTERY_NEUTRALIZE_ENEMIES" )

	FlagWait( "scavengers_dead" )
	thread DestroyDroppedWeapons( file.buddyTitan.GetOrigin(), 256 )

	useDummy.SetUsePrompts( "#WILDS_BATTERY_INSERT_PROMPT_HOLD", "#WILDS_BATTERY_INSERT_PROMPT_HOLD" )
	useDummy.WaitSignal( "OnPlayerUse" )

	useDummy.UnsetUsable()
	player.DisableWeapon()
	player.SetNoTarget( true )
	player.SetInvulnerable()

	if ( IsValid( file.batteryCarryFx ) )
		file.batteryCarryFx.Destroy()

	FlagSet( "slot_battery2_begin" )

	HideBatteryIcon( player )

	Objective_Clear()

	file.battery = CreatePropDynamic( BATTERY_MODEL, <0,0,0>, <0,0,0>, 2 )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	FirstPersonSequenceStruct sequenceTakeBattery
	sequenceTakeBattery.attachment = "ref"
	sequenceTakeBattery.firstPersonAnim = "ptpov_wilds_second_battery_insert"
	sequenceTakeBattery.thirdPersonAnim = "pt_wilds_second_battery_insert"
	sequenceTakeBattery.viewConeFunction = ViewConeTight

	player.SetAnimNearZ(1)

	thread PlayAnimTeleport( file.battery, "wilds_battery_insert_01", scriptRef )
	thread PlayAnimTeleport( file.buddyTitan, "BT_second_battery_insert", scriptRef )
	waitthread FirstPersonSequence( sequenceTakeBattery, player, animRef )

	file.batteriesInstalled = 2
	FlagSet( "slot_battery2" )

	player.ClearAnimNearZ()

	// put back in idle
	thread PlayAnimTeleport( file.buddyTitan, "BT_second_battery_idle", scriptRef )

	int bodyGroupIndex = file.buddyTitan.FindBodyGroup( "battery_cap_center" )
	file.buddyTitan.SetBodygroup( bodyGroupIndex, 0 )

	player.EnableWeaponWithSlowDeploy()
	player.SetNoTarget( false )
	player.ClearInvulnerable()

	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

	useDummy.Destroy()
	animRef.Destroy()
	file.battery.Destroy()
}

void function Battery3Path_BuddyTitan( entity player )
{
	Assert( IsAlive( file.buddyTitan ) )
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )

	waitthread PlayAnim( file.buddyTitan, "BT_second_battery_trans_2_guard", scriptRef )
	thread PlayAnim( file.buddyTitan, "BT_third_battery_idle", scriptRef )
}

void function Battery3Path_CanyonCombat( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "path2_canyon_combat" )

	array<entity> npcSpawnerArray = GetSpawnerArrayByScriptName( "path2_canyon_guy" )
	array<entity> npcArray = SpawnFromSpawnerArray( npcSpawnerArray )

	npcArray = ArrayClosest( npcArray, player.GetOrigin() )
	Assert( npcArray.len() >= 2 )

	foreach( npc in npcArray )
		npc.DisableNPCFlag( NPC_ALLOW_PATROL )

	entity npc1 = npcArray[0]
	entity npc2 = npcArray[1]

	npc1.EndSignal( "OnHearCombat" )
	npc1.EndSignal( "OnFoundEnemy" )
	npc1.EndSignal( "OnSeeEnemy" )

	npc2.EndSignal( "OnHearCombat" )
	npc2.EndSignal( "OnFoundEnemy" )
	npc2.EndSignal( "OnSeeEnemy" )

	wait 3

	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD702_01_01_mcor_grunt3", npc1 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD702_02_01_mcor_grunt4", npc2 )
	waitthread PlayGabbyDialogue( "diag_sp_patrolchat_WD702_03_01_mcor_grunt3", npc1 )
}

//	########     ###    ########   #######      ######   #######  ##     ## ########     ###    ########
//	##     ##   ## ##      ##     ##     ##    ##    ## ##     ## ###   ### ##     ##   ## ##      ##
//	##     ##  ##   ##     ##            ##    ##       ##     ## #### #### ##     ##  ##   ##     ##
//	########  ##     ##    ##      #######     ##       ##     ## ## ### ## ########  ##     ##    ##
//	##     ## #########    ##            ##    ##       ##     ## ##     ## ##     ## #########    ##
//	##     ## ##     ##    ##     ##     ##    ##    ## ##     ## ##     ## ##     ## ##     ##    ##
//	########  ##     ##    ##      #######      ######   #######  ##     ## ########  ##     ##    ##


void function StartPoint_Setup_Battery3Combat( entity player )
{
	Objective_Set( "#WILDS_OBJECTIVE_BATTERY3", GetEntByScriptName( "location_obj_battery3" ).GetOrigin() )

	thread MovePlayerToStartpoint( player, "startpoint_battery3_combat" )

	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_08_01_imc_genMarder" ] )
	file.droneDialogArray.reverse()
}

void function StartPoint_Battery3Combat( entity player )
{
	player.EndSignal( "OnDestroy" )

	AddSpawnCallback_ScriptName( "battery3_combat_sniper", Battery3CombatSniperThink )
	AddSpawnCallback_ScriptName( "battery3_combat_early_guy", Battery3CombatEarlyGuy )

	thread ShowCloakHint( player )
	thread Battery3CombatMusic( player )
	thread Battery3CombatDrones()

	FlagWait( "battery3_combat_jumped_down" )

	CheckPointData cpDataJumpDown
	cpDataJumpDown.safeLocations = GetEntArrayByScriptName( "safepoint_jumped_down" )
	CheckPoint_Silent( cpDataJumpDown )

	FlagWait( "battery3_combat_upper_area" )

	CheckPointData cpDataUpperArea
	cpDataUpperArea.safeLocations = GetEntArrayByScriptName( "safepoint_upper_area" )
	CheckPoint_Silent( cpDataUpperArea )

	thread CullEnemies( player, "battery3_combat_group", "forward_ship_upstairs" )

	FlagWait( "forward_ship_approach" )
}

void function StartPoint_Skip_Battery3Combat( entity player )
{
}

void function Battery3CombatMusic( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( "forward_ship_entrance" )

	while( svGlobalSP.gruntCombatState != eGruntCombatState.COMBAT )
		wait 1

	PlayMusic( "music_wilds_07_combat" )
	PlayMusic( "music_wilds_07_combatstart" )

	wait RandomFloatRange( 20, 30 )
	PlayMusic( "music_wilds_07_combatstart" )

	wait RandomFloatRange( 20, 30 )
	PlayMusic( "music_wilds_07_combatstart" )

	wait RandomFloatRange( 20, 30 )
	PlayMusic( "music_wilds_08_combatphase02" )
	PlayMusic( "music_wilds_08_combatphase02start" )

	wait RandomFloatRange( 20, 30 )
	PlayMusic( "music_wilds_08_combatphase02start" )

	wait RandomFloatRange( 20, 30 )
	PlayMusic( "music_wilds_08_combatphase02start" )
}

void function ShowCloakHint( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	FlagEnd( "forward_ship_approach" )

	const HINT_DISPLAY_TIME = 8.0

	FlagWait( "battery3_combat_jumped_down" )

	thread SignalOnRecovered( player )
	waitthread WaitSignalOrTimeout( player, 20, "full_health_recovered" )

	// make sure we don't hint when you can't actually use the cloak
	entity weapon = player.GetOffhandWeapon( OFFHAND_LEFT )
	weapon.EndSignal( "OnDestroy" )
	while( weapon.GetWeaponPrimaryClipCount() != weapon.GetWeaponPrimaryClipCountMax() )
		wait 0.5

	thread PlayBTDialogue( "diag_sp_postBattery2_WD141b_06_01_mcor_bt" )

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
			if ( IsValid( player ) )
				RemoveButtonPressedPlayerInputCallback( player, IN_OFFHAND1, PlayerUsedCloak )
		}
	)

	AddButtonPressedPlayerInputCallback( player, IN_OFFHAND1, PlayerUsedCloak )
	DisplayOnscreenHint( player, "cloak_hint" )
	waitthread WaitSignalOrTimeout( player, HINT_DISPLAY_TIME, "used_cloak" )
	wait 0.5
}

void function PlayerUsedCloak( entity player )
{
	player.Signal( "used_cloak" )
}

void function SignalOnRecovered( entity player )
{
	player.EndSignal( "OnDestroy" )

	float hintHealth = player.GetMaxHealth() * 0.75
	while( player.GetHealth() > hintHealth )
		player.WaitSignal( "OnDamaged" )

	while( player.GetHealth() < player.GetMaxHealth() )
		wait 0.5

	player.Signal( "full_health_recovered" )
}

void function Battery3CombatDrones()
{
	FlagEnd( "battery3_combat_jumped_down" )

	FlagWait( "battery3_combat_ledge" )

	float endTime = Time() + 15
	while( svGlobalSP.gruntCombatState == eGruntCombatState.IDLE && Time() < endTime )
		wait 1

	wait 5

	array<entity> npcArray = SpawnFromSpawnerArray( GetEntArrayByScriptName( "battery3_combat_drone" ) )
}

void function Battery3CombatSniperThink( entity sniper )
{
	sniper.EndSignal( "OnDeath" )

	sniper.DisableNPCFlag( NPC_ALLOW_PATROL )

	while( svGlobalSP.gruntCombatState != eGruntCombatState.COMBAT )
		wait 1

	sniper.EnableNPCFlag( NPC_ALLOW_PATROL )
	sniper.DisableBehavior( "Assault" )
}

void function Battery3CombatEarlyGuy( entity npc )
{
	npc.EndSignal( "OnDeath" )

	npc.SetLookDistOverride( 1000 )

	while( svGlobalSP.gruntCombatState != eGruntCombatState.COMBAT && !Flag( "battery3_combat_jumped_down" ) )
		wait 1

	npc.DisableLookDistOverride()
}

void function Battery3Turret( entity turret )
{
	turret.EnableTurret()
}

//	########     ###    ########   #######      ######  ##     ## #### ########
//	##     ##   ## ##      ##     ##     ##    ##    ## ##     ##  ##  ##     ##
//	##     ##  ##   ##     ##            ##    ##       ##     ##  ##  ##     ##
//	########  ##     ##    ##      #######      ######  #########  ##  ########
//	##     ## #########    ##            ##          ## ##     ##  ##  ##
//	##     ## ##     ##    ##     ##     ##    ##    ## ##     ##  ##  ##
//	########  ##     ##    ##      #######      ######  ##     ## #### ##

void function StartPoint_Setup_Battery3Ship( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_battery3_ship" )

	Objective_Set( "#WILDS_OBJECTIVE_BATTERY3", GetEntByScriptName( "location_obj_battery3" ).GetOrigin() )

	file.droneDialogArray.append( [ "diag_sp_callOut_WD752_08_01_imc_genMarder" ] )
}

void function StartPoint_Battery3Ship( entity player )
{
	player.EndSignal( "OnDestroy" )

	CheckPoint()
	thread Battery3ShipObjectiveReminder()
	thread Battery3ShipBacktrackBlocker()
	thread Battery3Conversation( player )
	thread Battery3ShipMusic( player )
	thread ShipAmbientDialogue( "ship_forward_speaker", "battery3_acquired" )

	entity backtrackBlocker = GetEntByScriptName( "battery3_backtrack_blocker" )
	entity backtrackBlockerClip = GetEntByScriptName( "battery3_backtrack_blocker_clip" )
	backtrackBlocker.Hide()
	backtrackBlocker.NotSolid()
	backtrackBlockerClip.NotSolid()

	GetEntByScriptName( "battery3_wrong_path_blocker" ).Destroy()
	GetEntByScriptName( "battery3_path_ramp_down" ).Destroy()
	FlagClear( "path2_first_ghost" )

	thread Battery3Ship_Battery_Pickup( player )

	player.WaitSignal( "battery_pickup" )

	// request custom sound
	entity ent = GetEntByScriptName( "ship_a1_passthrough_blocker_sound" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, ent.GetOrigin(), "Wilds_Scr_ShipDebrisFall_3" )
//	EmitSoundOnEntity( player, "Wilds_Scr_ShipDebrisFall_3" )
	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 1.0, 10, 3.0 )

	backtrackBlocker.Show()
	backtrackBlocker.Solid()
	backtrackBlockerClip.Solid()

	FlagWait( "battery3_acquired" )

	PrimeWaypoints( GetEntByScriptName( "waypoint_pilotlink" ) )
//	Objective_Set( "#WILDS_OBJECTIVE_BATTERY3_RETURN", file.buddyTitan.l.BTHightlightModel.GetOrigin() )
	thread WaypointThread( player, "#WILDS_OBJECTIVE_BATTERY3_RETURN", GetEntByScriptName( "waypoint_pilotlink" ), file.buddyTitan.l.BTHightlightModel )
}

void function StartPoint_Skip_Battery3Ship( entity player )
{
	FlagSet( "battery3_acquired" )

	GetEntByScriptName( "battery3_wrong_path_blocker" ).Destroy()
	GetEntByScriptName( "battery3_path_ramp_down" ).Destroy()

	Objective_Set( "#WILDS_OBJECTIVE_BATTERY3_RETURN", file.buddyTitan.l.BTHightlightModel.GetOrigin() )
}

void function Battery3ShipObjectiveReminder()
{
	FlagWait( "battery3_insight" )
	Objective_Remind()
}


void function Battery3ShipBacktrackBlocker()
{
	FlagWait( "forward_ship_upstairs" )

	entity backtrackBlocker = GetEntByScriptName( "battery3_ship_backtrack_blocker" )
	backtrackBlocker.Show()
	backtrackBlocker.Solid()
}

void function Battery3Conversation( entity player )
{
	FlagWait( "conv_ship_survivors" )
	PlayerConversation( "ShipSurvivors", player )

	FlagWait( "SloanRadioMessage" )

	wait 2

	entity radio = GetEntByScriptName( "dead_imc_grunt_radio" )

	// Slone to Salvage Team Gamma. There's a Vanguard-class Titan near the wreckage of the MacAllan.
	// Chassis number Bravo Tango Seven Two, Seven Four. Bring it in for me, eh? It's a real trophy, that one is.  Over.
	float duration = EmitSoundAtPosition( TEAM_UNASSIGNED, radio.GetOrigin(), "diag_sp_patrolChat_WD762_09_01_imc_slone" )
	wait duration

	// Roger that. You don't see one of those every day. Salvage Team Gamma is en route. Out.
	EmitSoundAtPosition( TEAM_UNASSIGNED, radio.GetOrigin(), "diag_sp_patrolChat_WD762_10_01_imc_grunt1" )
}

void function Battery3ShipMusic( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "forward_ship_entrance" )

	PlayMusic( "music_wilds_11_insideship" )

	player.WaitSignal( "battery_pickup_music_cue" )

	StopMusicTrack( "music_wilds_07_combat" )
	StopMusicTrack( "music_wilds_08_combatphase02" )
	StopMusicTrack( "music_wilds_11_insideship" )
	PlayMusic( "music_wilds_16_batterythree" )
}

void function Battery3Ship_Battery_Pickup( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity battery = CreatePickupBattery( "anim_ref_battery3", "wilds_battery_pickup_02", "battery3_use_proxy" )
	battery.l.useDummy.WaitSignal( "OnPlayerUse" )

	player.DisableWeapon()
	battery.l.useDummy.Destroy()

	Objective_Clear()
	player.Signal( "battery_pickup_music_cue" )

	entity scriptRef = GetEntByScriptName( "anim_ref_battery3" )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	FirstPersonSequenceStruct sequenceTakeBattery
	sequenceTakeBattery.attachment = "ref"
	sequenceTakeBattery.firstPersonAnim = "ptpov_wilds_battery_pickup_02"
	sequenceTakeBattery.thirdPersonAnim = "pt_wilds_battery_pickup_02"
	sequenceTakeBattery.viewConeFunction = ViewConeTight

	player.SetAnimNearZ(1)

	thread PlayAnim( battery, "wilds_battery_pickup_02", animRef )
	waitthread FirstPersonSequence( sequenceTakeBattery, player, animRef )

	player.ClearAnimNearZ()

	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

	ShowBatteryIcon( player )
	player.EnableWeaponWithSlowDeploy()

	animRef.Destroy()
	file.battery.Destroy()

	int fxId = GetParticleSystemIndex( $"P_xo_battery" )
	int attachmentId = player.LookupAttachment( "BATTERY_ATTACH" )
	file.batteryCarryFx = StartParticleEffectOnEntity_ReturnEntity( player, fxId, FX_PATTACH_POINT_FOLLOW, attachmentId )

	FlagSet( "battery3_acquired" )
}

//	########  #### ##        #######  ######## ##       #### ##    ## ##    ##
//	##     ##  ##  ##       ##     ##    ##    ##        ##  ###   ## ##   ##
//	##     ##  ##  ##       ##     ##    ##    ##        ##  ####  ## ##  ##
//	########   ##  ##       ##     ##    ##    ##        ##  ## ## ## #####
//	##         ##  ##       ##     ##    ##    ##        ##  ##  #### ##  ##
//	##         ##  ##       ##     ##    ##    ##        ##  ##   ### ##   ##
//	##        #### ########  #######     ##    ######## #### ##    ## ##    ##

void function StartPoint_Setup_PilotLink( entity player )
{
	thread MovePlayerToStartpoint( player, "startpoint_pilotlink" )
	ShowBatteryIcon( player )
}

void function StartPoint_PilotLink( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	CheckPoint()

	thread PilotLink_Dialog( player )
	thread PilotLink_SlotBattery( player )

	FlagWait( "pilot_link_approach" )
	Objective_Set( "#WILDS_OBJECTIVE_SECURE_AREA", file.buddyTitan.l.BTHightlightModel.GetOrigin() )
	thread InstallBatteryObjective( player, "bt_ready_for_battery3", 5, "slot_battery3_begin" )

	waitthread PilotLink_EarlyFight( player )

	FlagWait( "slot_battery3" )

	UnlockAchievement( player, achievements.POWERED_BT )

	if ( IsValid( file.buddyTitanCollision ) )
		file.buddyTitanCollision.Destroy()

	waitthread PilotLink_EmbarkBuddyTitan( player )
	thread PilotLink_TitanTraining( player )

	FlagWait( "spawn_final_enemies" )

	thread FinalFight( player )

	FlagWait( "final_fight_won" )

	CheckPoint()

	StopMusicTrack( "music_wilds_17_titanfight" )
	PlayMusic( "music_wilds_18_fightfinished" )

	FlagWait( "ready_for_level_end" )
	if( Flag( "exit_bad_area" ) )
		wait 7
	else
		FlagWait( "level_end" )

	PickStartPoint( "sp_sewers1", "Channel Mortar Run" )
}

void function PilotLink_EarlyFight( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	thread CreateCirclingDrone( "pilot_link_circle_path_1", "pilot_link_escape_path_1", "npc_drone_worker_fast" )
	thread CreateCirclingDrone( "pilot_link_circle_path_2", "pilot_link_escape_path_2", "npc_drone_worker_fast" )

	ClearQuickDeath()
	CheckPoint()

	array<entity> spawnerArray = GetSpawnerArrayByScriptName( "pilot_link_early_fight_spectre" )
	array<entity> npcArray = SpawnFromSpawnerArray( spawnerArray )
	Assert( npcArray.len() == spawnerArray.len() )

	// safety script that I proabbly could remove, but it's not hurting anything.
	foreach( npc in npcArray )
		thread TrackNPCHeight( player, npc )

	FlagWait( "pilot_link_early_fight_done" )

	FlagSet( "bt_ready_for_battery3" )
}

void function TrackNPCHeight( entity player, entity npc )
{
	player.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDeath" )

	float endTime = Time() + 30
	while( Time() < endTime )
	{
		vector diff = npc.GetOrigin() - player.GetOrigin()
		if ( diff.z < 256 )
			return
		wait 1
	}

//	Assert( false, "NPC never made it down from the cliffs" )
	npc.Die()
}

void function CreateCirclingDrone( string pathName, string retreatName, string aiSetting )
{
	entity pathNode = GetEntByScriptName( pathName )
	entity retreatNode = GetEntByScriptName( retreatName )

	entity drone = SpawnNPCByClassname( "npc_drone", TEAM_IMC, pathNode.GetOrigin(), <0,0,0>, null, aiSetting )
	int newHealth = drone.GetMaxHealth() * 4
	drone.SetMaxHealth( newHealth  )
	drone.SetHealth( newHealth  )

	drone.EndSignal( "OnDestroy" )

	thread AssaultMoveTarget( drone, pathNode )

	FlagWait( "pilot_link_approach" )
	waitthread WaitSignalOrTimeout( drone, 4, "OnDamaged" )

	thread DestroyOnSignal( drone, "destroy_me" )
	StopAssaultMoveTarget( drone )

	thread AssaultMoveTarget( drone, retreatNode )
}

void function PilotLink_SlotBattery( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	Assert( IsAlive( file.buddyTitan ) )
	file.buddyTitan.EndSignal( "OnDestroy" )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )

	thread PlayAnimTeleport( file.buddyTitan, "BT_third_battery_idle", scriptRef )

	entity useDummy = CreateUseDummy( file.buddyTitan, "CHESTFOCUS",  < 15, -20, -15 >, "#WILDS_BATTERY_NEUTRALIZE_ENEMIES", "#WILDS_BATTERY_NEUTRALIZE_ENEMIES" )

	FlagWait( "bt_ready_for_battery3" )
	thread DestroyDroppedWeapons( file.buddyTitan.GetOrigin(), 256 )
	useDummy.SetUsePrompts( "#WILDS_BATTERY_INSERT_PROMPT_HOLD", "#WILDS_BATTERY_INSERT_PROMPT_HOLD" )
	useDummy.WaitSignal( "OnPlayerUse" )

	useDummy.UnsetUsable()
	player.DisableWeapon()
	player.SetNoTarget( true )
	player.SetInvulnerable()

	if ( IsValid( file.batteryCarryFx ) )
		file.batteryCarryFx.Destroy()

	Objective_Clear()
	FlagSet( "slot_battery3_begin" )

	HideBatteryIcon( player )

	StopMusicTrack( "music_wilds_16b_spectres" )
	PlayMusic( "music_wilds_16a_installbatterythree" )


	file.battery = CreatePropDynamic( BATTERY_MODEL, <0,0,0>, <0,0,0>, 2 )
	entity animRef = CreateOwnedScriptMover( scriptRef )

	FirstPersonSequenceStruct sequenceTakeBattery
	sequenceTakeBattery.attachment = "ref"
	sequenceTakeBattery.firstPersonAnim = "ptpov_wilds_third_battery_insert"
	sequenceTakeBattery.thirdPersonAnim = "pt_wilds_third_battery_insert"
	sequenceTakeBattery.viewConeFunction = ViewConeTight

	player.SetAnimNearZ(1)

	thread PlayAnimTeleport( file.battery, "wilds_battery_insert_02", scriptRef )
	thread PlayAnimTeleport( file.buddyTitan, "BT_third_battery_insert", scriptRef )
	waitthread FirstPersonSequence( sequenceTakeBattery, player, animRef )

	player.ClearAnimNearZ()

	// put back in idle
	thread PlayAnimTeleport( file.buddyTitan, "BT_third_battery_idle", scriptRef )

	int bodyGroupIndex = file.buddyTitan.FindBodyGroup( "battery_cap_outer" )
	file.buddyTitan.SetBodygroup( bodyGroupIndex, 0 )

	player.EnableWeaponWithSlowDeploy()
	player.SetNoTarget( false )
	player.ClearInvulnerable()

	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )

	useDummy.Destroy()
	animRef.Destroy()
	file.battery.Destroy()

	file.batteriesInstalled = 3
	FlagSet( "slot_battery3" )
}

void function PilotLink_EmbarkBuddyTitan( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	waitthread PlayAnim( file.buddyTitan, "BT_third_battery_trans", scriptRef )

	int attachmentID = file.buddyTitan.LookupAttachment( "HATCH_PANEL" )
	vector pos = file.buddyTitan.GetAttachmentOrigin( attachmentID )
	Objective_Set( "#WILDS_OBJECTIVE_EMBARK_BT", pos )

	file.buddyTitan.DisableNPCFlag( NPC_IGNORE_ALL )
	file.buddyTitan.DisableNPCFlag( NPC_ALLOW_PATROL )
	file.buddyTitan.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )

	file.buddyTitan.ClearInvulnerable()
	file.buddyTitan.SetNoTarget( false )

	thread PlayAnim( file.buddyTitan, "at_MP_embark_idle" )
	file.buddyTitan.UseSequenceBounds( true )

	SetGlobalNetBool( "titanOSDialogueEnabled", false )

	// protocols might be moved to after the final fight
	// Remote_CallFunction_Replay( player, "ServerCallback_DisplayProtocols_PilotLink" )

	entity useDummy = CreateUseDummy( file.buddyTitan, "ChestFocus", <0, 0, 0>, "#HOLD_TO_EMBARK", "#HOLD_TO_EMBARK" )
	useDummy.SetUsableRadius( 64 )
	useDummy.SetUsableFOVByDegrees( 25 )

	useDummy.WaitSignal( "OnPlayerUse" )

	StopMusicTrack( "music_wilds_16a_installbatterythree" )
	PlayMusic( "music_wilds_16d_embark" )
	Objective_Clear()

	SetGlobalNetBool( "enteredTitanCockpit", true )

	waitthread CustomEmbark( player, file.buddyTitan )

	if ( !player.IsTitan() )
		player.WaitSignal( "TitanEntered" )

	CheckPoint_ForcedSilent()

	// drop the titan to the ground so that it's not stuck
	player.SetOrigin( player.GetOrigin() + <0,0,8> )

	FlagSet( "titan_entered" )
}

void function PilotLink_Dialog( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	FlagWait( "pilot_link_approach" )

	StopMusicTrack( "music_wilds_16_batterythree" )
	PlayMusic( "music_wilds_16b_spectres" )

	// Pilot, our location has been compromised.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD140_01_01_mcor_bt" )
	FlagWait( "bt_ready_for_battery3" )
	wait 2

	// Those drones are IMC scouts.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD140_02_01_mcor_bt" )
	// Enemy reinforcements will be on their way.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD140_03_01_mcor_bt" )
	// We must complete the neural link immediately. Please install the final battery.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD140_04_01_mcor_bt" )

	FlagWait( "slot_battery3" )

	// Power at full capacity
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143_07_01_mcor_bt" )

	wait 3.5

	// Pilot, we must establish a neural link in order to proceed.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD141_64_01_mcor_bt" )

	wait 1.5
	// Please embark when ready.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD141_66_01_mcor_bt" )

	FlagWait( "titan_entered" )

	wait 1 //animation is 12 seconds long?

	Remote_CallFunction_Replay( player, "ServerCallback_PilotLinkHud" )
	// Protocol 1 - Link to Pilot
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD141_40_01_mcor_bt" )

	Remote_CallFunction_Replay( player, "ServerCallback_NeuralLink" )
	// Establishing neural link
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143_08_01_mcor_bt" )

	FlagWait( "neural_link_complete" )

	// Neural Link: Established... Rifleman Jack Cooper - you are now confirmed as Acting Pilot of BT-7274.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD141_41_01_mcor_bt" )
	wait 1

	// Protocol 2 - Uphold the Mission
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD141_42_01_mcor_bt" )

	FlagSet( "titan_training_spawn_enemies" )
	// Our orders are to resume Special Operation #217 - Rendezvous with Major Anderson of the SRS.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD141_46_01_mcor_bt" )

	wait 1.0	// need to be timed so that it feels ok.

	StopMusicTrack( "music_wilds_16d_embark" )
	PlayMusic( "music_wilds_16c_linking" )

	// I am detecting incoming enemy forces.
	waitthread PlayBTDialogue( "diag_sp_extra_GB101_19_01_mcor_bt" )

	// activate cockpit screens
	Remote_CallFunction_Replay( player, "ServerCallback_ActivateCockpitScreens" )

	// Protocol 3: Protect The Pilot
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD141_44_01_mcor_bt" )

	// LINE MISSING
	// Transferring controls to Pilot;
	// waitthread PlayBTDialogue( "diag_gs_titanBt_embark_02" )

	FlagSet( "initilize_critical_systems" )

	// Re-initializing critical systems...
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143a_01_01_mcor_bt" )

	FlagWait( "titan_training_vortex" )
	// Vortex shield online.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143a_02_01_mcor_bt" )
	// The Vortex shield catches incoming rounds and missiles. Release the button to launch any captured objects back at the enemy.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143a_03_01_mcor_bt" )

	FlagWait( "titan_training_rockets" )
	// Pilot, the Acolyte Pod is online. This shoulder mounted rocket pod will lock onto multiple enemy targets.
	// The longer you hold down the button the more locks you will achieve.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143a_04_01_mcor_bt" )

	FlagWait( "titan_training_completed" )

	// Neural link complete. Primary Weapon Control and Motion Link reestablished.
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143a_05_01_mcor_bt" )
	FlagSet( "restore_player_control" )

	WaitForEnemyCount( 1, 30 )
	wait 3

	// Pilot, enemy Titanfall detected..
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143a_07_01_mcor_bt" )
	// We will have to fight our way to safety. Get ready
	waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143b_07_01_mcor_bt" )
	thread PlayerConversation( "FinalFight", player )

	wait 4
	FlagSet( "spawn_final_enemies" )

	SetGlobalNetBool( "titanOSDialogueEnabled", true )

	FlagWait( "final_fight_won" )

	wait 2
	// Well done, Pilot. Our combat effectiveness rating has increased.
	waitthread PlayBTDialogue( "diag_sp_postFight_WD171_02_01_mcor_bt" )
	wait 1

	// Pilot, I detect more IMC salvage teams on the way.
	waitthread PlayBTDialogue( "diag_sp_postFight_WD171a_01_01_mcor_bt" )
	// Our only chance of survival is to uphold our mission of rendezvousing with Major Anderson.
	// Until then, you and I are on our own.
	waitthread PlayBTDialogue( "diag_sp_postFight_WD171a_03_01_mcor_bt" )

	FlagSet( "ready_for_level_end" )

	entity objEnt = GetEntByScriptName( "anderson_objective_location" )
	entity dirEnt = objEnt.GetLinkEnt()
	if ( Flag( "exit_bad_area" ) )
		dirEnt = dirEnt.GetLinkEnt()

	vector dir = Normalize( dirEnt.GetOrigin() - objEnt.GetOrigin() )
	vector objPosition = objEnt.GetOrigin() + dir * 10000
	objEnt.SetOrigin( objPosition )

	if ( !Flag( "exit_bad_area" ) )
	{
		PrimeWaypoints( GetEntByScriptName( "waypoint_levelend" ) )
		thread WaypointThread( player, "#WILDS_OBJECTIVE_ANDERSON", GetEntByScriptName( "waypoint_levelend" ), objEnt )
	}
	else
	{
		Objective_Set( "#WILDS_OBJECTIVE_ANDERSON", objPosition )
	}

	Objective_AddKilometers( 106.0 )
	thread ObjectiveRecurringReminder( player, "level_end" )

	// Marking your HUD
	waitthread PlayBTDialogue( "diag_sp_postFight_WD171a_03a_01_mcor_bt" )

	wait 2
	// We must move quickly
	waitthread PlayBTDialogue( "diag_sp_postFight_WD171a_03b_01_mcor_bt" )

	wait 15
	waitthread PlayBTDialogue( "diag_sp_extra_SE812_02_01_mcor_bt" )
	Objective_Remind()
}

bool function ClientCommand_NeuralLinkComplete( entity player, array<string> args )
{
	FlagSet( "neural_link_complete" )
	return true
}

//  ######## #### ########    ###    ##    ##    ######## ########     ###    #### ##    ## #### ##    ##  ######
//     ##     ##     ##      ## ##   ###   ##       ##    ##     ##   ## ##    ##  ###   ##  ##  ###   ## ##    ##
//     ##     ##     ##     ##   ##  ####  ##       ##    ##     ##  ##   ##   ##  ####  ##  ##  ####  ## ##
//     ##     ##     ##    ##     ## ## ## ##       ##    ########  ##     ##  ##  ## ## ##  ##  ## ## ## ##   ####
//     ##     ##     ##    ######### ##  ####       ##    ##   ##   #########  ##  ##  ####  ##  ##  #### ##    ##
//     ##     ##     ##    ##     ## ##   ###       ##    ##    ##  ##     ##  ##  ##   ###  ##  ##   ### ##    ##
//     ##    ####    ##    ##     ## ##    ##       ##    ##     ## ##     ## #### ##    ## #### ##    ##  ######

void function PilotLink_TitanTraining( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	AddCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )

	// fade back in from black screen
	ScreenFade( player, 0, 0, 0, 255, 0.5, 0.1, FFADE_IN | FFADE_PURGE )

	AddDamageCallback( "player", MitigateDifficultyDamageCallback )

	thread PilotLink_PlayerControls( player )
	DisableMainTitanWeapon( player )
	FlagClear( "OnLoadSaveGame_PlayerRecoveryEnabled" )

	// flag gets set when the client side animation of looking around inside the cockpit is done.
	FlagWait( "neural_link_complete" )

	// need to do this again because are save system is a bit lacking
//	DisableMainTitanWeapon( player )

	// Need to do this well after entering the titan so dying and reloading doesn't cause the weapon to be out.
	int ammoLoaded = player.GetActiveWeaponPrimaryAmmoLoaded()
	thread HackDisableOffhand( player, OFFHAND_RIGHT ) // rockets
	thread HackDisableOffhand( player, OFFHAND_LEFT ) // vortex
	//	thread HackDisableOffhand( player, OFFHAND_TITAN_CENTER ) // smoke

	// clear this here so that it's cleared for sure when the later save happens
	SetGlobalNetBool( "enteredTitanCockpit", false )

	FlagWait( "titan_training_spawn_enemies" )

	// first batch of enemies
	thread EnemyWave( player, "tt_rifle_spectre_center", 2 )

	FlagWait( "initilize_critical_systems" )

	// more enemies
	thread EnemyWave( player, "tt_rifle_spectre_right" )
	thread EnemyWave( player, "tt_rifle_spectre_center", 1 )

	RemoveCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )
	player.ForceStand()
	player.UnfreezeControlsOnServer()
	Remote_CallFunction_Replay( player, "ServerCallback_StopCockpitLook" )

	wait 5

	// ***** VORTEX AVAILABLE *****
	FlagSet( "titan_training_vortex" )
	HackEnableOffhand( player, OFFHAND_LEFT )
	entity vortexWeapon = player.GetOffhandWeapon( OFFHAND_LEFT )
	if ( GetSpDifficulty() < DIFFICULTY_HARD )
		vortexWeapon.AddMod( "sp_wider_return_spread" )

	Remote_CallFunction_Replay( player, "ServerCallback_ShowHudIcon", OFFHAND_LEFT )
	thread DisplayVortexHint( player )

	WaitForEnemyCount( 3, 20 )

	thread EnemyWave( player, "tt_rifle_spectre_center", 2 )
	thread EnemyWave( player, "tt_rifle_spectre_right", 2 )
	thread EnemyWave( player, "tt_smr_spectre" )
	WaitForEnemyCount( 2, 10 )

	thread EnemyWave( player, "tt_rifle_spectre_low_center", 2 )
	thread EnemyWave( player, "rr_drone_beam" )

	FlagWaitWithTimeout( "tt_drones_close", 6 )

	// let the dones fire at the player for a while
	WaitForEnemyCount( 0, 5 )

	thread EnemyWave( player, "rr_drone_beam" )
//	thread EnemyWave( player, "tt_smr_spectre", 1 )

	// ***** MISSILES AVAILABLE *****
	FlagSet( "titan_training_rockets" )
	HackEnableOffhand( player, OFFHAND_RIGHT )
	Remote_CallFunction_Replay( player, "ServerCallback_ShowHudIcon", OFFHAND_RIGHT )
	thread DisplayMissileSystemHint( player )

	if ( vortexWeapon.HasMod( "sp_wider_return_spread" ) )
		vortexWeapon.RemoveMod( "sp_wider_return_spread" )

	WaitForEnemyCount( 1, 5 )
	thread EnemyWave( player, "tt_rifle_spectre_left" )
	thread EnemyWave( player, "tt_rifle_spectre_right" )

	WaitForEnemyCount( 4, 10 )
	thread EnemyWave( player, "tt_smr_spectre" )
	thread EnemyWave( player, "tt_rifle_spectre_center", 2 )
	thread EnemyWave( player, "rr_drone_beam" )

	WaitForEnemyCount( 2, 20 )
	thread EnemyWave( player, "tt_rifle_spectre_low_center", 4 )

	FlagSet( "OnLoadSaveGame_PlayerRecoveryEnabled" )

	if ( player.GetHealth() > player.GetHealth() * 0.5 )
		CheckPoint_Forced()
	else
		CheckPoint()

	FlagSet( "titan_training_completed" )

	wait 3
	RemoveDamageCallback( "player", MitigateDifficultyDamageCallback )

//	vortexWeapon = player.GetOffhandWeapon( OFFHAND_LEFT )
//	vortexWeapon.RemoveMod( "vortex_extended_effect_and_no_use_penalty" )

	player.SetTitanDisembarkEnabled( true )

	FlagWait( "spawn_final_enemies" )

	// kill all enemy spectres and drones
	while( true )
	{
		array<entity> npcArray = GetNPCArrayByClass( "npc_spectre" )
		npcArray.extend( GetNPCArrayByClass( "npc_drone" ) )

		if ( npcArray.len() == 0 )
			break

		foreach( npc in npcArray )
		{
			if ( !PlayerCanSee( player, npc, true, 180 ) )
				npc.Die()
		}
		wait 1
	}
}

void function PilotLink_PlayerControls( entity player )
{
	Assert( player.IsTitan() )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	player.SetTitanDisembarkEnabled( false )
	player.MovementDisable()
	player.FreezeControlsOnServer()
	SetDodgeDisabled( player, true )

	FlagWait( "restore_player_control" )

	// enable main weapon
	EnableMainTitanWeapon( player )
	Remote_CallFunction_Replay( player, "ServerCallback_ShowHudIcon", OFFHAND_TITAN_CENTER )
	Remote_CallFunction_Replay( player, "ServerCallback_ShowHudIcon", 3 )

	player.UnforceStand()
	SetDodgeDisabled( player, false )
	player.MovementEnable()
	player.SetTitanDisembarkEnabled( true )
	player.SetTitanEmbarkEnabled( true )
	Rodeo_Allow( player )
	thread LerpPlayerSpeed( player, 0.2, 1.0, 5.0 )
}

void function MitigateDifficultyDamageCallback( entity player, var damageInfo )
{
	Assert( player.IsTitan() )

	if ( GetSpDifficulty() < DIFFICULTY_HARD )
		return

	float scalar = 1.0 / GetDamageScalarByDifficulty()
	DamageInfo_ScaleDamage( damageInfo, scalar )
}

void function CustomEmbark( entity player, entity buddyTitan )
{
	player.DisableWeapon()
	player.SetAnimNearZ(3)

	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.5
	sequence.attachment = "REF"
	sequence.firstPersonAnim = "ptpov_wilds_first_embark"
	sequence.thirdPersonAnim = "pt_wilds_first_embark"
	sequence.viewConeFunction = ViewConeTight

	thread PlayAnim( file.buddyTitan, "bt_wilds_first_embark", buddyTitan )
	buddyTitan.Anim_AdvanceCycleEveryFrame( true )
	waitthread FirstPersonSequence( sequence, player, buddyTitan )

	player.ClearAnimNearZ()
	player.EnableWeapon()

	ForceScriptedEmbark( player, buddyTitan )
	buddyTitan.Destroy()
}

void function DisplayVortexHint( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	FlagEnd( "tt_drones_close" )

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
			if ( IsValid( player ) )
				RemoveButtonPressedPlayerInputCallback( player, IN_OFFHAND1, PlayerUsedVortex )
		}
	)

	AddButtonPressedPlayerInputCallback( player, IN_OFFHAND1, PlayerUsedVortex )
	DisplayOnscreenHint( player, "vortex_hint" )
	WaitSignal( player, "used_vortex" )

	// waiting forever
	WaitForever()
	wait 0.5
}

void function PlayerUsedVortex( entity player )
{
	file.vortexUsage++

	if ( file.vortexUsage > 3 )
		player.Signal( "used_vortex" )
}

void function DisplayMissileSystemHint( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	FlagEnd( "titan_training_completed" )

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
			if ( IsValid( player ) )
				RemoveButtonPressedPlayerInputCallback( player, IN_OFFHAND0, PlayerUsedMissiles )
		}
	)

	AddButtonPressedPlayerInputCallback( player, IN_OFFHAND0, PlayerUsedMissiles )
	DisplayOnscreenHint( player, "missile_system_hint" )
	WaitSignal( player, "used_missiles" )

	WaitForever()
	wait 0.5
}

void function PlayerUsedMissiles( entity player )
{
	file.missileUsage++

	if ( file.missileUsage > 2 )
		player.Signal( "used_missiles" )
}

void function EnemyWave( entity player, string scriptName, int maxCount = -1 )
{
	array<entity> npcSpawnerArray = GetSpawnerArrayByScriptName( scriptName )

	if ( maxCount > 0 && maxCount < npcSpawnerArray.len() )
		npcSpawnerArray.resize( maxCount )

	array<entity> npcArray = SpawnFromSpawnerArray( npcSpawnerArray )

	foreach( npc in npcArray )
	{
		npc.SetEnemy( player )
		file.waveEnemyCount++
		thread DepricateOnDeath( npc )
	}
}

void function DepricateOnDeath( entity npc )
{
	WaitSignal( npc, "OnDeath", "OnDestroy", "OnLeeched" )
	file.waveEnemyCount--
}

void function WaitForEnemyCount( int count = 0, float timeout = 9999 )
{
	float endTime = Time() + timeout
	while( Time() < endTime )
	{
		if ( file.waveEnemyCount <= count )
		{
			printt( "#### ENEMY COUNT REACHED", file.waveEnemyCount, count )
			break
		}

		wait 0.5
	}

	if ( file.waveEnemyCount > count )
		printt( "******* COUNT NOT!!! REACHED", file.waveEnemyCount, count )

}

void function SetDodgeDisabled( entity player, bool state = true )
{
	if ( state == true )
	{
		player.Server_TurnDodgeDisabledOn()	// hud still updates as normal with just this
		player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), ["disable_dodge"] )
		player.Server_SetDodgePower( 0 )
	}
	else
	{
		player.Server_TurnDodgeDisabledOff()
		player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), [] )
	}
}

void function HackDisableOffhand( entity player, int slot )
{
	entity weapon = player.GetOffhandWeapon( slot )
	weapon.EndSignal( "hack_enable_offhand" )
	weapon.EndSignal( "OnDestroy" )

	while( true )
	{
		weapon.SetWeaponChargeFractionForced( 1.0 )
		wait 1
	}
}

void function HackEnableOffhand( entity player, int slot )
{
	if ( !player.IsTitan() )
		return

	entity weapon = player.GetOffhandWeapon( slot )
	weapon.Signal( "hack_enable_offhand" )
	weapon.SetWeaponChargeFractionForced( 0.0 )
}

//	######## #### ##    ##    ###    ##          ######## ####  ######   ##     ## ########
//	##        ##  ###   ##   ## ##   ##          ##        ##  ##    ##  ##     ##    ##
//	##        ##  ####  ##  ##   ##  ##          ##        ##  ##        ##     ##    ##
//	######    ##  ## ## ## ##     ## ##          ######    ##  ##   #### #########    ##
//	##        ##  ##  #### ######### ##          ##        ##  ##    ##  ##     ##    ##
//	##        ##  ##   ### ##     ## ##          ##        ##  ##    ##  ##     ##    ##
//	##       #### ##    ## ##     ## ########    ##       ####  ######   ##     ##    ##

void function FinalFight( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	StopMusicTrack( "music_wilds_16c_linking" )
	PlayMusic( "music_wilds_17_titanfight" )

	entity spawner = GetEntByScriptName( "final_fight_titan" )
	if ( Flag( "use_alt_final_titan" ) )
		spawner = GetEntByScriptName( "final_fight_titan_alt" )

	entity final_titan = SpawnFromSpawner( spawner )

	final_titan.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( final_titan )
		{
			FlagSet( "final_fight_won" )
			if ( IsValid( final_titan ) )
				EmitSoundAtPosition( TEAM_UNASSIGNED, final_titan.GetOrigin(), "diag_imc_pilot6_hc_death" )
		}
	)

	final_titan.WaitSignal( "TitanHotDropComplete" )

	while( final_titan.GetEnemy() == null )
		wait 1

	PlayDialogue( "diag_imc_pilot6_wildsEndBattle", final_titan )

	thread EnemyTitanDialogueOnDamage( final_titan )
	thread EnemyTitanDialogueOnPlayerDamage( final_titan, player )

	final_titan.WaitSignal( "OnDeath" )
}

void function EnemyTitanDialogueOnDamage( entity titan )
{
	titan.EndSignal( "OnDeath" )

	array<string> hurtLines = [ "diag_imc_pilot6_hc_lostChicket5_09", "diag_imc_pilot6_hc_lostChicket3_06", "diag_imc_pilot6_hc_lostChicket1_02" ]
	int lineIndex = 0
	int oldHealth = titan.GetMaxHealth()
	int triggerDamage = titan.GetMaxHealth() / ( hurtLines.len() + 1 )

	while( true )
	{
		titan.WaitSignal( "OnDamaged" )
		int newHealth = titan.GetHealth()
		printt( newHealth, oldHealth, triggerDamage )
		if ( oldHealth - newHealth < triggerDamage )
			continue
		oldHealth = newHealth
		if( IsDialoguePlaying() )
			continue

		PlayDialogue( hurtLines[ lineIndex++ ], titan )
	}
}

void function EnemyTitanDialogueOnPlayerDamage( entity titan, entity player )
{
	titan.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	// this script assumes the player is the titan. If he's not lets just not do any dialog
	if ( !player.IsTitan() )
		return

	array<string> tauntLines = [ "diag_imc_pilot6_hc_plyrLostChicklet_06", "diag_imc_pilot6_hc_plyrLostChicklet_13" ]
	int lineIndex = 0
	int oldHealth = player.GetMaxHealth()
	int triggerDamage = player.GetMaxHealth() / ( tauntLines.len() + 1 )

	while( true )
	{
		player.WaitSignal( "OnDamaged" )
		int newHealth = player.GetHealth()
		printt( newHealth, oldHealth, triggerDamage )
		if ( oldHealth - newHealth < triggerDamage )
			continue

		oldHealth = newHealth
		if( IsDialoguePlaying() )
			continue

		PlayDialogue( tauntLines[ lineIndex++ ], titan )
	}
}

//	##     ## ####  ######   ######
//	###   ###  ##  ##    ## ##    ##
//	#### ####  ##  ##       ##
//	## ### ##  ##   ######  ##
//	##     ##  ##        ## ##
//	##     ##  ##  ##    ## ##    ##
//	##     ## ####  ######   ######

//	##     ## ######## #### ##       #### ######## #### ########  ######
//	##     ##    ##     ##  ##        ##     ##     ##  ##       ##    ##
//	##     ##    ##     ##  ##        ##     ##     ##  ##       ##
//	##     ##    ##     ##  ##        ##     ##     ##  ######    ######
//	##     ##    ##     ##  ##        ##     ##     ##  ##             ##
//	##     ##    ##     ##  ##        ##     ##     ##  ##       ##    ##
//	 #######     ##    #### ######## ####    ##    #### ########  ######

#if CONSOLE_PROG
void function EnableDVSOverride( entity player )
{
	SetConVarFloat( "dvs_scale_min", 1 )
}

void function DisableDVSOverride( entity player )
{
	// reset to defaults
	SetConVarFloat( "dvs_scale_min", file.dvsScaleMinDefault )
}
#endif

void function ShowBatteryIcon( entity player )
{
	player.SetPlayerNetBool( "showBatteryIcon", true )
	Remote_CallFunction_Replay( player, "ServerCallback_ShowBatteryIcon", true )
}

void function HideBatteryIcon( entity player )
{
	player.SetPlayerNetBool( "showBatteryIcon", false )
	Remote_CallFunction_Replay( player, "ServerCallback_ShowBatteryIcon", false )
}

void function DamageCallbackBurn( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) || !ent.IsPlayer() )
		return

	EmitSoundAtPositionOnlyToPlayer( TEAM_MILITIA, ent.GetOrigin(), ent, "flesh_fire_damage_1p" )
}

void function InstallBatteryObjective( entity player, string startFlag, float delay, string endFlag )
{
	FlagEnd( endFlag )
	FlagWait( startFlag )

	FlagWaitWithTimeout( "player_near_bt", delay )

	Objective_Set( "#WILDS_OBJECTIVE_INSTALL_BATTERY", file.buddyTitan.l.BTHightlightModel.GetOrigin() )
	thread HightlightObjectiveWhenClose( player, file.buddyTitan.l.BTHightlightModel, 1024, endFlag )
}

void function HightlightObjectiveWhenClose( entity player, entity highlightEnt, float maxDist, string endFlag )
{
	if ( endFlag != "" )
		FlagEnd( endFlag )

	player.EndSignal( "OnDestroy" )
	highlightEnt.EndSignal( "OnDestroy" )

	bool hightlightOn = false

	while( true )
	{
		float dist = Distance( highlightEnt.GetOrigin(), player.GetOrigin() )
		if ( dist < maxDist && !hightlightOn )
		{
			Objective_Update( <0,0,0>, highlightEnt )
			Objective_StaticModelHighlightOverrideEntity( highlightEnt )
			hightlightOn = true
		}
		else if ( dist >= maxDist && hightlightOn )
		{
			Objective_Update( highlightEnt.GetOrigin() )
			hightlightOn = false
		}

		wait 0.5
	}
}

void function FoliageTriggerSetup( entity trigger )
{
	if ( !trigger.HasKey( "scr_sound" ) )
		trigger.Destroy()

	trigger.ConnectOutput( "OnTrigger", FoliageTriggerOnEnter )
}

void function FoliageTriggerOnEnter( entity trigger, entity activator, entity caller, var value )
{
	Assert( trigger.HasKey( "scr_sound" ) )

	if ( !IsValid( activator ) )
		return
	if ( !activator.IsPlayer() )
		return

	string sound
	string soundIndex = expect string( trigger.kv.scr_sound )

	switch( soundIndex )
	{
		case "broad_leafed_plant":
			sound = "Wilds_Emit_BroadLeafedPlant_Rustle"
			break
		case "bright_green_bush":
			sound = "Wilds_Emit_BrightGreenBush_Rustle"
			break
		case "palm_tree":
			sound = "Wilds_Emit_MiniPalmTree_Rustle"
			break
		case "tree_branches":
			sound = "Wilds_Emit_TreeBranches_Rustle"
			break
		default:
			return
	}

	EmitSoundAtPositionOnlyToPlayer( TEAM_MILITIA, trigger.GetOrigin(), activator, sound )
	// printt( "foliage sound", sound )
}

void function QuickDeathTriggerNPC( entity trigger )
{
	while ( true )
	{
		table results = trigger.WaitSignal( "OnTrigger" )
		entity activator = expect entity( results.activator )
		if ( IsAlive( activator ) && activator.IsNPC() )
		{
			printt( "quick death trigger killed", activator )
			activator.Die()
		}
	}
}

void function PrimeWaypoints( entity startEnt )
{
	const WAYPOINT_TRIGGER_RADIUS = 512

	entity waypointEnt = startEnt
	while( IsValid( waypointEnt ) )
	{
		int triggerHeight = WAYPOINT_TRIGGER_RADIUS
		if ( waypointEnt.HasKey( "script_height" ) )
			triggerHeight = int( waypointEnt.kv.script_height )

		entity trigger = GetLinkedWaypointTrigger( waypointEnt )
		if ( !trigger )
		{
			trigger = CreateEntity( "trigger_cylinder" )
			trigger.SetRadius( WAYPOINT_TRIGGER_RADIUS )
			trigger.SetAboveHeight( triggerHeight )
			trigger.SetBelowHeight( triggerHeight )
			trigger.kv.triggerFilterNpc = "none" // none
			trigger.kv.triggerFilterPlayer = "all" // titan players only
			trigger.kv.triggerFilterNonCharacter = 0
			trigger.SetOrigin( waypointEnt.GetOrigin() )
			DispatchSpawn( trigger )
		}

		waypointEnt.l.waypointTrigger = trigger
		thread PrimeWaypointThread( waypointEnt )

		Assert( waypointEnt.GetLinkEntArray().len() <= 1 )
		waypointEnt = waypointEnt.GetLinkEnt()
	}
}

entity function GetLinkedWaypointTrigger( entity waypointEnt )
{
	array<entity> linkedEnts = waypointEnt.GetLinkEntArray()
	foreach( ent in linkedEnts )
	{
		if ( ent.GetClassName() == "trigger_multiple" )
		{
			waypointEnt.UnlinkFromEnt( ent )
			return ent
		}
	}
	return null
}

void function PrimeWaypointThread( entity waypointEnt )
{
	waypointEnt.EndSignal( "OnDestroy" )

	table result = WaitSignal( waypointEnt.l.waypointTrigger, "OnStartTouch" )
	waypointEnt.l.triggered = true
	waypointEnt.l.waypointTrigger.Destroy()
}

void function WaypointThread( entity player, string objectiveText, entity startEnt, entity mainEnt, bool silent = false )
{
	const WAYPOINT_TRIGGER_RADIUS = 512

	entity waypointEnt = FirstValidWaypoint( startEnt )
	if ( !IsValid( waypointEnt ) )
	{
		Objective_Set( objectiveText, mainEnt.GetOrigin() )
		return
	}

	Objective_WayPointEneable( true )
	if ( silent )
		Objective_SetSilent( objectiveText, waypointEnt.GetOrigin() )
	else
		Objective_Set( objectiveText, waypointEnt.GetOrigin() )

	bool nextSilent = false
	while( true )
	{
		WaitSignal( waypointEnt.l.waypointTrigger, "OnStartTouch" )

		if ( waypointEnt.HasKey( "script_delay" ) )
			wait float( waypointEnt.kv.script_delay )

		nextSilent = false
		if ( waypointEnt.HasKey( "next_silent" ) && waypointEnt.GetValueForKey( "next_silent" ) == "1" )
			nextSilent = true

		waypointEnt = waypointEnt.GetLinkEnt()
		if ( !IsValid( waypointEnt ) )
			break

		Objective_Update( waypointEnt.GetOrigin() )
		if ( !nextSilent )
			Objective_Remind()
	}

	Objective_WayPointEneable( false )
	Objective_Update( mainEnt.GetOrigin() )
	if ( !nextSilent )
		Objective_Remind()
}

entity function FirstValidWaypoint( entity startEnt )
{
	entity waypointEnt = startEnt
	while( IsValid( waypointEnt) )
	{
		if ( waypointEnt.l.triggered == false )
			return waypointEnt

		waypointEnt = waypointEnt.GetLinkEnt()
	}

	return null
}

void function ShowObjectiveHint( entity player, float timeout = 0.0 )
{
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			ClearOnscreenHint( player )
			Objective_SuppressCloseMenuShowsObjective( false )
		}
	)

	Objective_SuppressCloseMenuShowsObjective( true )

	printt( "showObjective", player.GetPlayerNetBool( "showObjective" ) )
	if ( player.GetPlayerNetBool( "showObjective" ) )
		return

	DisplayOnscreenHint( player, "objective_hint" )
	if ( timeout <= 0 )
		WaitSignal( player, "ShowingObjective" )
	else
		waitthread WaitSignalOrTimeout( player, timeout, "ShowingObjective" )
	wait 0.5
}

entity function CreateOGPilot()
{
//	entity ogPilot = SpawnNPCByClassname( "npc_soldier", TEAM_MILITIA, <0,0,1000>, <0,0,0>, "mp_weapon_rspn101" )
	entity ogPilot = SpawnNPCByClassname( "npc_soldier", TEAM_MILITIA, <0,0,1000>, <0,0,0>, "mp_weapon_vinson" )

	ogPilot.EnableNPCFlag( NPC_IGNORE_ALL )
	ogPilot.SetNoTarget( true )
	ogPilot.SetInvulnerable()
	ogPilot.SetTitle( "" )
	ogPilot.SetModel( OG_PILOT_MODEL )

	int bodyGroupIndex = ogPilot.FindBodyGroup( "head" )
	Assert( bodyGroupIndex != -1 )
	ogPilot.SetBodygroup( bodyGroupIndex, 1 )

	return ogPilot
}

void function CullEnemies( entity player, string group, string flag, int maxCount = 0 )
{
	player.EndSignal( "OnDestroy" )
	const minCullDistSqrd = 1000000 // 1000 units

	FlagWait( flag )

	printt( "******************" )
	printt( "CullEnemies starting", group, flag, maxCount )
	printt( "******************" )

	while( true )
	{
		array<entity> npcArray = GetNpcArrayByGroup( group )
		if ( npcArray.len() <= maxCount )
			break

		printt( "found", npcArray.len(), "ai in group", group )

		// by starting at maxCount we will leave that many AI alive after the cull
		for ( int i = maxCount; i < npcArray.len(); i++ )
		{
			entity npc = npcArray[i]

			if ( DistanceSqr( player.GetOrigin(), npc.GetOrigin() ) <= minCullDistSqrd )
			{
				printt( "guy too close", Distance( player.GetOrigin(), npc.GetOrigin() ) )
				continue
			}

			if ( PlayerCanSee( player, npcArray[i], true, 80 ) )
			{
				printt( "could see guy" )
				continue
			}

			printt( "destroyed a guy in group", group )
			npc.Destroy() // it's happeneing out of sight so no need to be gentle.
		}
		wait 1
	}

	printt( "******************" )
	printt( "CullEnemies completed", group, flag, maxCount )
	printt( "******************" )
}

array<entity> function GetNpcArrayByGroup( string group )
{
	array<entity> groupNpcArray
	array<entity> npcArray = GetNPCArray()

	foreach( npc in npcArray )
	{
		if ( npc.HasKey( "script_group" ) && npc.kv.script_group == group )
			groupNpcArray.append( npc )
	}

	return groupNpcArray
}

void function CheckpointOnFlag( string flag, bool silent = false, array<entity> safeLocations = [] )
{
	FlagWait( flag )

	CheckPointData cpData
	cpData.safeLocations = safeLocations

	if ( silent )
		CheckPoint_Silent( cpData )
	else
		CheckPoint( cpData )
}

bool function AreThereEnemies( entity player, float radius = 1024 )
{
	array<entity> npcArray = GetNPCArrayEx( "any", TEAM_IMC, -1, player.GetOrigin(), radius )
	return ( npcArray.len() > 0 )
}

void function EscapePodBroadcast( entity podSpeaker, array<string> dialogArray, float radius = 750 )
{
	entity trigger = CreateTriggerRadiusMultiple( podSpeaker.GetOrigin(), radius )

	trigger.WaitSignal( "OnTrigger" )

	for ( int i =0; i < dialogArray.len(); i++ )
	{
		float duration = EmitSoundAtPosition( TEAM_UNASSIGNED, podSpeaker.GetOrigin(), dialogArray[i] )
		wait duration //+ 1.0 // shouldn't need padding
	}
}

void function DisableMainTitanWeapon( entity titan )
{
	// is this just the player?
	// entity titan = soul.GetTitan()

	titan.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "allow_as_primary" )
	titan.SetActiveWeaponByName( "melee_titan_punch" )

	entity mainWeapon = titan.GetMainWeapons()[0]
	mainWeapon.AllowUse( false )
}

void function EnableMainTitanWeapon( entity titan )
{
	Assert( IsAlive( titan ) )

	entity meleeWeapon = titan.GetOffhandWeapon( OFFHAND_MELEE )
	if ( IsValid( meleeWeapon ) )
		meleeWeapon.RemoveMod( "allow_as_primary" )

	entity mainWeapon = titan.GetMainWeapons()[0]
	mainWeapon.AllowUse( true )
	titan.SetActiveWeaponByName( mainWeapon.GetWeaponClassName() )
}

void function BatteryNag( entity player )
{
	FlagEnd( "slot_battery2_begin" )
	player.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )

	if ( Flag( "slot_battery2" ) )
		return

	while( true )
	{
		if ( !Flag( "player_near_bt" ) )
			FlagWait( "player_near_bt" )

		if ( IsConversationPlaying() || IsDialoguePlaying() )
		{
			wait 5
			continue
		}
		if( Flag( "pause_battery_nag" ) )
		{
			wait 5
			continue
		}
		waitthread PlayBTDialogue( "diag_sp_pilotLink_WD143_01_01_mcor_bt" )
		wait 5
	}
}

void function DroneBroadcastTriggerThink( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )
	FlagEnd( "pilot_link_approach" )

	trigger.WaitSignal( "OnTrigger" )

	array<entity> pathArray = trigger.GetLinkEntArray()
	foreach ( node in pathArray )
	{
		const string aiSetting = "npc_drone_worker_fast"
		entity drone = SpawnNPCByClassname( "npc_drone", TEAM_BOTH, node.GetOrigin(), node.GetAngles(), null, aiSetting )

		if ( IsValid( drone ) )
		{
			int newHealth = drone.GetMaxHealth() * 8
			drone.SetMaxHealth( newHealth )
			drone.SetHealth( newHealth )
			drone.SetNoTarget( true )
			thread AssaultMoveTarget( drone, node )

			if ( !node.HasKey( "script_noteworthy" ) || node.kv.script_noteworthy != "silent" )
				thread DroneBroadcastThread( drone )

			if ( node.HasKey( "script_noteworthy" ) && node.kv.script_noteworthy == "ignore_enemies" )
				drone.EnableNPCFlag( NPC_IGNORE_ALL )

			if ( node.HasKey( "script_noteworthy" ) && node.kv.script_noteworthy == "survivor" )
				thread DroneSurvivor( drone, node )

		}
	}
}

void function DroneBroadcastThread( entity drone )
{
	entity player = GetPlayerArray()[0]
	player.EndSignal( "OnDestroy" )

	drone.EndSignal( "OnDestroy" )
	drone.EndSignal( "destroy_me" )

	const float dialogStartDist = 1500.0

	OnThreadEnd(
		function() : ( drone )
		{
			if ( IsAlive( drone ) )
				thread DestroyWhenDialogueOver( drone )
		}
	)

	if ( file.droneDialogArray.len() == 0 )
		WaitForever()

	thread DroneForceBroadcastThink( drone )

	array dialogArray = file.droneDialogArray.pop()
	while( !drone.l.forceBroadcast )
	{
		if ( Distance( player.GetOrigin(), drone.GetOrigin() ) < dialogStartDist )
			break
		wait 1
	}

	while( IsDialoguePlaying() || IsConversationPlaying() )
		wait 0.1

	foreach( dialog in dialogArray )
	{
		expect string ( dialog )
		// using waitthread PlayDialogue(...) didin't work because that thread also gets ended on the endsignals of this thread.
		thread BroadcastDroneMessage( dialog, drone )
		drone.WaitSignal( "drone_broadcast_completed" )
		wait 1
	}

	Signal( level, "drone_broadcast_completed" )

	WaitForever()
}

void function BroadcastDroneMessage( string dialog, entity drone )
{
	drone.EndSignal( "OnDestroy" )
	waitthread PlayDialogue( dialog, drone )
	drone.Signal( "drone_broadcast_completed" )
}

void function DestroyWhenDialogueOver( entity drone )
{
	drone.EndSignal( "OnDestroy" )
	while( IsDialoguePlaying() )
		wait 1

	drone.Destroy()
}

void function DroneForceBroadcastThink( entity drone )
{
	drone.EndSignal( "OnDestroy" )
	drone.EndSignal( "destroy_me" )

	WaitSignal( drone, "force_broadcast", "OnDamaged" )
	drone.l.forceBroadcast = true
}

void function DroneSurvivor( entity drone, entity pathNode )
{
	drone.EndSignal( "OnDestroy" )
	drone.EndSignal( "destroy_me" )
	EndSignal( level, "drone_broadcast_completed" )

	OnThreadEnd(
		function() : ()
		{
			Signal( level, "drone_broadcast_completed" )
		}
	)

	array<entity> nodeChain = GetEntityLinkChain( pathNode )

	int newHealth = drone.GetMaxHealth() * 3
	drone.SetMaxHealth( newHealth )
	drone.SetHealth( newHealth )

	vector maxs = < 64, 64, 53.5 >
	vector mins = < -64, -64, -64 >
	int mask = drone.GetPhysicsSolidMask()

	while( true )
	{
		WaitSignal( drone, "OnDamaged" )

		vector origin = drone.GetOrigin()
		TraceResults result = TraceHull( origin, origin + <0,0,768>, mins, maxs, drone, mask, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < 0.2 )
			continue

		StopAssaultMoveTarget( drone )
		drone.AssaultPoint( result.endPos )
		WaitSignal( drone, "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )

		entity node = GetClosest( nodeChain, drone.GetOrigin() )
		thread AssaultMoveTarget( drone, node )
	}
}

void function RunToAndPlayRecordedAnim( entity guy, asset anim )
{
	guy.EndSignal( "OnDeath" )
	var recording = LoadRecordedAnimation( anim )

	waitthread RunToRecordedAnimStart( guy, recording )

	guy.e.forceRagdollDeath = true

	guy.PlayRecordedAnimation( recording, <0,0,0>, <0,0,0> )
	float duration = GetRecordedAnimationDuration( recording )
	wait duration

	guy.e.forceRagdollDeath = false
}

void function RunToRecordedAnimStart( entity guy, var recording, vector origin = <0,0,0>, vector angles = <0,0,0>, entity ref = null, bool disableArrival = true )
{
	Assert( IsAlive( guy ) )
	guy.Anim_Stop() // in case we were doing an anim already
	guy.EndSignal( "OnDeath" )

	bool allowFlee 			= guy.GetNPCFlag( NPC_ALLOW_FLEE )
	bool allowHandSignal 	= guy.GetNPCFlag( NPC_ALLOW_HAND_SIGNALS )
	bool allowArrivals 		= guy.GetNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )

	if ( disableArrival )
		guy.EnableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )

	guy.DisableNPCFlag( NPC_ALLOW_FLEE | NPC_ALLOW_HAND_SIGNALS )

	if ( ref != null )
	{
		origin = ref.GetOrigin() + origin
		angles = ref.GetAngles() + angles
	}

	vector animStartPos = GetRecordedAnimationStartForRefPoint( recording, origin, angles )

	float goalRadius 		= guy.AssaultGetGoalRadius()
	float fightRadius 		= guy.AssaultGetFightRadius()
	float arrivalTolerance 	= guy.AssaultGetArrivalTolerance()
	float runtoRadius = 71.16
	guy.AssaultSetGoalRadius( runtoRadius )
	guy.AssaultSetFightRadius( runtoRadius )
	guy.AssaultSetArrivalTolerance( runtoRadius )

	guy.AssaultPoint( animStartPos )

	WaitSignal( guy, "OnFinishedAssault" )

	guy.DisableBehavior( "Assault" )

	//in case the scripter reset during run, we want to honor the intended change
	if ( guy.AssaultGetGoalRadius() == runtoRadius )
		guy.AssaultSetGoalRadius( goalRadius )

	if ( guy.AssaultGetFightRadius() == runtoRadius )
		guy.AssaultSetFightRadius( fightRadius )

	if ( guy.AssaultGetArrivalTolerance() == runtoRadius )
		guy.AssaultSetArrivalTolerance( arrivalTolerance )

	guy.SetNPCFlag( NPC_ALLOW_FLEE, allowFlee )
	guy.SetNPCFlag( NPC_ALLOW_HAND_SIGNALS, allowHandSignal )
	guy.SetNPCMoveFlag( NPCMF_DISABLE_ARRIVALS, allowArrivals )
}

void function SetPlayerSprint( entity player, bool active )
{
	if ( !active )
	{
		array<string> mods = player.GetPlayerSettingsMods()
		if ( !mods.contains( "disable_sprint" ) )
		{
			mods.append( "disable_sprint" )
			player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), mods )
		}
	}
	else
	{
		array<string> mods = player.GetPlayerSettingsMods()
		if ( mods.contains( "disable_sprint" ) )
		{
			mods.fastremovebyvalue( "disable_sprint" )
			player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), mods )
		}
	}
}

void function LerpPlayerSpeed( entity player, float startSpeed, float endSpeed, float lerpTime, float holdTime = 0 )
{
	player.EndSignal( "OnDestroy" )

	if ( holdTime > 0 )
	{
		player.SetMoveSpeedScale( startSpeed )
		SetPlayerSprint( player, startSpeed > 0.75 )

		wait holdTime
	}

	float startTime = Time()
	float endTime = Time() + lerpTime
	float waittime = max( IntervalPerTick(), lerpTime / 20.0 )

	while( Time() < endTime )
	{
		float p = min( 1, ( Time() - startTime ) / lerpTime )
		float currentSpeed = Graph( QuadEaseIn( p ), 0, 1, startSpeed, endSpeed )
		player.SetMoveSpeedScale( currentSpeed )
		SetPlayerSprint( player, currentSpeed > 0.75 )

		wait waittime
	}
}

float function QuadEaseIn( float frac )
{
	return 1 * frac * frac
}

float function QuadEaseInOut( float frac )
{
	frac /= 0.5;
	if (frac < 1)
		return 0.5 * frac * frac
	frac--
	return -0.5 * ( frac * ( frac - 2 ) - 1 )
}

void function CreateSyncedSpectreVGruntMelee( vector origin, vector angles )
{
	vector origin2
	vector angles2
	vector vec = AnglesToForward( <0,angles.y,0> )

	switch( RandomInt( 4 ) )
	{
		case 0:
			// sp_stand_melee_behind_A
			origin2 = origin + vec * 96 //< 96, 0, 0 >
			angles2 = angles + < 0, 0, 0 >
			break
		case 1:
			// sp_stand_melee_left_A
			origin2 = origin + vec * 96 //< 96, 0, 0 >
			angles2 = angles + < 0, 64, 0 >
			break
		case 2:
			// sp_stand_melee_A
			origin2 = origin + vec * 64
			angles2 = angles + < 0, 180, 0 >
			break
		case 3:
			// sp_stand_melee_headrip_A
			origin2 = origin + vec * 72
			angles2 = angles + < 0, 180, 0 >
			break
	}

	entity spectre = SpawnNPCByClassname( "npc_spectre", TEAM_IMC, origin, angles )
	entity grunt = SpawnNPCByClassname( "npc_soldier", TEAM_MILITIA, origin2, angles2 )

	Assert( IsValid( spectre ) )
	Assert( IsValid( grunt ) )

	spectre.kv.alwaysalert = true
	spectre.SetEnemyLKP( grunt, grunt.GetOrigin() )
	spectre.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2, false )

	grunt.kv.alwaysalert = true
	grunt.SetEnemyLKP( spectre, spectre.GetOrigin() )
	grunt.SetCapabilityFlag( bits_CAP_INITIATE_SYNCED_MELEE, false )
	grunt.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2, false )

	spectre.Freeze()
	grunt.Freeze()

	wait 1

	spectre.Unfreeze()
	grunt.Unfreeze()
}

void function DelayShake( entity player, float delay, float shakeMultiplier )
{
	player.EndSignal( "OnDestroy" )

	wait delay
	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 1.0 * shakeMultiplier, 30, 2.0 )
}

void function DelaySound( entity player, float delay, string sound, vector origin )
{
	vector dir = origin - player.GetOrigin()
	origin = player.GetOrigin() + dir * 0.2

	wait delay
	EmitSoundAtPosition( TEAM_MILITIA, origin, sound )
}

// SpawnNPCByClassname( "npc_drone", TEAM_IMC, origin, angles, null, "npc_drone_worker_fast" )
// SpawnNPCByClassname( "npc_titan", 2, <0,0,100>, <0,0,0>, "mp_titanweapon_leadwall", "npc_titan_auto_stryder_arc" )
entity function SpawnNPCByClassname( string aiClass, int team, vector origin, vector angles, string ornull weaponName = null, string ornull aiSetting = null )
{
	entity npc = CreateNPC( aiClass, team, origin, angles )
	if ( aiSetting != null )
		SetSpawnOption_AISettings( npc, string( aiSetting ) )

	if ( weaponName != null )
		SetSpawnOption_Weapon( npc, string( weaponName ) )

	DispatchSpawn( npc )
	return npc
}

void function RandomExplosionSetup( entity ent )
{
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetRadius( 750 )
	trigger.SetAboveHeight( 128 )
	trigger.SetBelowHeight( 128 )
	trigger.SetOrigin( ent.GetOrigin() )
	DispatchSpawn( trigger )

	trigger.SetEnterCallback( RandomExplosionTrigger )
}

void function RandomExplosionTrigger( entity trigger, entity player )
{
	if ( player.IsPlayer() )
		thread RandomExplosionThread( trigger, player )
}

void function RandomExplosionThread( entity trigger, entity player )
{
	player.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnEndTouch" )

	const holdTime = 1.0
	const fovDot = 0.9

	bool looking = DotProduct( player.GetViewVector(), Normalize( trigger.GetOrigin() - player.GetOrigin() ) ) > fovDot
	float endTime = 0

	while( true )
	{
		//		printt( string( looking ) )
		wait holdTime
		float dot = DotProduct( player.GetViewVector(), Normalize( trigger.GetOrigin() - player.GetOrigin() ) )
		if ( dot < fovDot )
		{
			looking = false
			continue
		}
		else if ( !looking )
		{
			looking = true
			continue
		}

		break    // looked long enough
	}

	float distance = Distance( player.GetOrigin(), trigger.GetOrigin() )
	if ( distance < 256 )
		return

	float shakeMultiplier = GraphCapped( distance / 750, 0.35, 1.0, 1.0, 0.5 )

	StartParticleEffectInWorld( GetParticleSystemIndex( FLYBY_EXPLOSION_FX ), trigger.GetOrigin(), trigger.GetAngles() )
	EmitSoundAtPosition( TEAM_MILITIA, trigger.GetOrigin(), FLYBY_EXPLOSION_SFX )
	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 3.0 * shakeMultiplier, 30, 1.5 )

	Explosion(
		trigger.GetOrigin(),
		trigger,						// attacker
		trigger,						// inflictor
		50, 						// normal damage
		50, 						// heavy armor damage
		32, 						// inner radius
		256,  						// outer radius
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,
		trigger.GetOrigin(),
		1000,						// force
		damageTypes.explosive,
		eDamageSourceId.burn,
		"" )

	trigger.Destroy()
}

void function RefCreateCallback( entity ref )
{
	ref.DisableHibernation()
}

void function BatteryTrackerThread( entity player, array<entity> fakelocs, entity realLoc, float realDelay )
{
	player.EndSignal( "OnDestroy" )

	fakelocs = ArrayClosest( fakelocs, player.GetOrigin() )

	foreach ( loc in fakelocs )
	{
		vector o = loc.GetOrigin()
		Remote_CallFunction_Replay( player, "ServerCallback_TrackBatteryLocations", o.x, o.y, o.z, false )
		wait RandomFloatRange( 1.0, 1.8 )
	}

	vector o = realLoc.GetOrigin()
	Remote_CallFunction_Replay( player, "ServerCallback_TrackBatteryLocations", o.x, o.y, o.z, true )

	wait 3.0
	Remote_CallFunction_Replay( player, "ServerCallback_ClearBatteryLocations", false, realDelay )

	wait realDelay
}

void function QuakeTriggerThink( entity trigger )
{
	trigger.WaitSignal( "OnTrigger" )

	float multiplier = 2 //RandomFloatRange( 1.0, 2.0 )
	float amplitude = 2.5 * multiplier
	float frequency = 10 * multiplier
	float duration = 2.0 * multiplier

	entity player = GetPlayerArray()[0]
	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", amplitude, frequency, duration )

	array<entity> debrisArray = trigger.GetLinkEntArray()

	bool soundPlayed = false
	foreach( debris in debrisArray )
	{
		if ( !soundPlayed )
			EmitSoundAtPosition( TEAM_UNASSIGNED, player.GetOrigin(), "Wilds_Scr_ShipTremor_Generic" )
		soundPlayed = true
		debris.SetVelocity( <0,0,75> )
		debris.SetAngularVelocity( 30, 60, 90 )
		wait RandomFloatRange( 0, duration / debrisArray.len() )
	}
}


void function EmitSoundOnEntArray( array<entity> entArray, string soundAlias )
{
	float duration
	foreach( ent in entArray )
	{
		duration = EmitSoundAtPosition( TEAM_UNASSIGNED, ent.GetOrigin(), soundAlias )

	}

	wait duration
}

void function PlayDialogueFromClosestGrunt( string dialogue, entity player, int team = TEAM_MILITIA )
{
	player.EndSignal( "OnDestroy" )

	entity grunt = GetClosestNPCNotTalking( player.GetOrigin(), team )
	if ( !IsValid( grunt ) )
		return

	grunt.EndSignal( "OnDeath" )

	grunt.l.dialoguePlaying = true
	PlayDialogue( dialogue, grunt )
	grunt.l.dialoguePlaying = false
	grunt.l.dialogueCompleted = Time()
}

entity function GetClosestNPCNotTalking( vector origin, int team = TEAM_MILITIA, float maxRange = -1 )
{
	const float gapTime = 2.0

	array<entity> npcArray = GetNPCArrayEx( "npc_soldier", team, -1, origin, maxRange )
	npcArray = ArrayClosest( npcArray, origin )

	foreach( npc in npcArray )
	{
		if ( !IsAlive( npc ) )
			continue
		if ( npc.l.dialoguePlaying == true )
			continue
		if ( Time() < npc.l.dialogueCompleted + gapTime )
			continue

		return npc
	}

	return null
}

entity function GetClosestNPC( vector origin, int team = TEAM_MILITIA, float maxRange = -1 )
{
	array<entity> npcArray = GetNPCArrayEx( "npc_soldier", team, -1, origin, maxRange )
	npcArray = ArrayClosest( npcArray, origin )

	foreach( npc in npcArray )
	{
		if ( IsAlive( npc ) )
			return npc
	}

	return null
}

void function EnableMorningLight( entity player, bool teleport = false )
{
	if ( teleport )
		player.SetOrigin( player.GetOrigin() + <0,0,-NIGHT_DAY_OFFSET> )

	entity skyCam = GetEnt( "skybox_cam_night" )
	player.SetSkyCamera( skyCam )
}

void function DisableMorningLight( entity player, bool teleport = false )
{
	if ( teleport )
		player.SetOrigin( player.GetOrigin() + <0,0,NIGHT_DAY_OFFSET> )

	entity skyCam = GetEnt( "skybox_cam_level" )
	player.SetSkyCamera( skyCam )
}

entity function CreatePickupBattery( string refName, string animation, string useProxyName )
{
	if ( IsValid( file.battery ) )
		file.battery.Destroy()

	// create battery
	entity scriptRef = GetEntByScriptName( refName )
	file.battery = CreatePropDynamic( BATTERY_MODEL, <0,0,0>, <0,0,0>, 2 )
	PlayAnim( file.battery, animation + "_idle", scriptRef )

	// create use dummy
	entity locationEnt = GetEntByScriptName( useProxyName )
	entity useDummy = CreatePropDynamic( USE_DUMMY_MODEL, locationEnt.GetOrigin(), locationEnt.GetAngles(), 2 )
	useDummy.Hide()
	useDummy.SetUsable()
	useDummy.SetUsableByGroup( "pilot" )
	useDummy.SetUsePrompts( "#WILDS_BATTERY_PICKUP_PROMPT_HOLD" , "#WILDS_BATTERY_PICKUP_PROMPT_HOLD" )
//	useDummy.SetUsableRadius( 128 )
//	useDummy.SetUsableFOVByDegrees( 50 )
	file.battery.l.useDummy = useDummy

	return file.battery
}

void function DestroyDroppedWeapons( vector origin, float radius = 256, float delay = 0 )
{
	if ( delay > 0 )
		wait delay

	array<entity> weaponArray = GetWeaponArray( true )
	foreach ( weapon in weaponArray )
	{
		if ( weapon.GetParent() != null )
			continue

		if ( Distance( weapon.GetOrigin(), origin ) <= radius )
			weapon.Destroy()
	}
}

void function GruntUseZipline( entity npc, entity assaultEnt )
{
	npc.EndSignal( "OnDeath" )

	array<asset> animArray = [ $"anim_recording/sp_crashsite_grunt_zipline_1.rpak",
		$"anim_recording/sp_crashsite_grunt_zipline_2.rpak",
		$"anim_recording/sp_crashsite_grunt_zipline_3.rpak" ]

	waitthread RunToAndPlayRecordedAnim( npc, animArray.getrandom() )

	thread AssaultMoveTarget( npc, assaultEnt )
}

void function SpaceDebrisTrigger( entity trigger )
{
	trigger.WaitSignal( "OnTrigger" )

	array<entity> entArray = trigger.GetLinkEntArray()
	foreach( ent in entArray )
	{
		thread FallingSpaceDebris( ent )
	}
}

void function FallingSpaceDebris( entity pathEnt )
{
	if ( pathEnt.HasKey( "path_wait" ) )
		wait float( pathEnt.GetValueForKey( "path_wait" ) )

	entity startEnt = pathEnt.GetLinkEnt()

	vector startOrigin = startEnt.GetOrigin()
	vector endOrigin = pathEnt.GetOrigin()

	vector dir = Normalize( endOrigin - startOrigin )
	startOrigin = startOrigin + dir * -20000
	vector right = Normalize( CrossProduct( <0,0,1>, dir) )
	vector down = Normalize( CrossProduct( right, dir) )
	vector angles = VectorToAngles( down )

	entity spaceDebris = CreateScriptMoverModel( SPACE_DEBRIS_MODEL, startOrigin, angles )
	spaceDebris.Hide()
	spaceDebris.DisableHibernation()

	int attachID = spaceDebris.LookupAttachment( "REF" )
	StartParticleEffectOnEntity( spaceDebris, GetParticleSystemIndex( SPACE_DEBRIS_TRAIL_FX ), FX_PATTACH_POINT_FOLLOW, attachID )
	EmitSoundOnEntity( spaceDebris, "Wilds_Scr_SpaceDebrisIncoming" )


	const float moveSpeed = 8000
	float distance = Distance( startOrigin, endOrigin )
	float movetime = distance / moveSpeed

	spaceDebris.NonPhysicsMoveTo( endOrigin, movetime, movetime * 0.25, 0 )

	wait movetime

	entity player = GetPlayerArray()[0]
	float distToPlayer = Distance( endOrigin, player.GetOrigin() )

	float amplitude = GraphCapped( distToPlayer, 3500, 800, 0, 3 )
	float frequency = GraphCapped( distToPlayer, 3500, 800, 0.5, 1.5 )
	float duration = GraphCapped( distToPlayer, 3500, 800, 1.0, 2.5 )

	if ( amplitude > 0 )
		Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", amplitude, frequency, duration )

	StartParticleEffectInWorld( GetParticleSystemIndex( SPACE_DEBRIS_IMPACT_FX ), spaceDebris.GetOrigin(), spaceDebris.GetAngles() )
	EmitSoundAtPosition( TEAM_UNASSIGNED, endOrigin, SPACE_DEBRIS_IMPACT_SFX )

	WaitFrame()
	spaceDebris.Destroy()
}

void function CreateAmbientFlyer( entity spawner )
{
	entity flyer = CreatePerchedFlyer( spawner.GetOrigin(), spawner.GetAngles() )
	spawner.Destroy()
}

// copied and modified from PlayHotdropImpactFX in _titan_hotdrop.gnut
void function HotdropImpactFX( entity titan )
{
	vector origin = titan.GetOrigin()

	Explosion_DamageDefSimple(
		damagedef_titan_fall,
		origin,
		titan,								// attacker
		titan,								// inflictor
		origin )

	CreateShake( titan.GetOrigin(), 16, 150, 2, 1500 )
	// No Damage - Only Force
	// Push players
	// Push radially - not as a sphere
	// Test LOS before pushing

	int flags = 15
	vector impactOrigin = titan.GetOrigin() + < 0,0,10 >
	float impactRadius = 512
	CreatePhysExplosion( impactOrigin, impactRadius, PHYS_EXPLOSION_LARGE, flags )
}

void function MakeTitanLookDamaged( entity ent )
{
	array<string> bodyGroupArray = [ "torso", "hip", "right_arm", "left_leg" ]
	foreach( bodyGroup in bodyGroupArray )
	{
		int bodyGroupIndex = ent.FindBodyGroup( bodyGroup )
		if ( bodyGroupIndex == -1 )
			continue
		ent.SetBodygroup( bodyGroupIndex, 1 )
	}
}

entity function CreateUseDummy( entity ent, string attachment, vector offset = <0,0,0>, string usePrompt = "#HOLD_TO_USE_GENERIC", string usePromptPC = "#PRESS_TO_USE_GENERIC" )
{
	int attachmentID = ent.LookupAttachment( attachment )
	vector origin = ent.GetAttachmentOrigin( attachmentID )
	vector angles = ent.GetAttachmentAngles( attachmentID )
	vector forward = AnglesToForward( angles )
	vector right = AnglesToRight( angles )
	vector up = AnglesToUp( angles )
	offset = forward * offset.x +  right * offset.y + up * offset.z

	entity useDummy = CreatePropDynamic( USE_DUMMY_MODEL, origin + offset, angles, 2 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only

	useDummy.Hide()
	useDummy.SetUsable()
	useDummy.SetUsableByGroup( "pilot" )
	useDummy.SetUsePrompts( usePrompt, usePromptPC )
//	useDummy.SetUsableRadius( 200 )
//	useDummy.SetUsableFOVByDegrees( 50 )

	useDummy.SetParent( ent, attachment, true )

//	thread DrawTag( useDummy, "light0" )

	return useDummy
}

void function DestroyOnSignal( entity ent, string signal )
{
	ent.EndSignal( "OnDestroy" )
	ent.WaitSignal( signal )
	ent.Destroy()
}

void function ShellShockStart( float delay = 0 )
{
	if ( delay > 0 )
		wait delay

	Remote_CallFunction_Replay( GetPlayerArray()[0], "ServerCallback_ShellShock" )
}

void function ShellShockStop()
{
	Remote_CallFunction_Replay( GetPlayerArray()[0], "ServerCallback_ShellShockStop" )
}

entity function SpawnBT( entity player, vector origin )
{
	vector angles = < 0, 0, 0 >

	//	entity npcTitan = CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, origin, angles )
	TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()
	entity npcTitan = CreateNPCTitan( loadout.setFile, TEAM_MILITIA, origin, angles, loadout.setFileMods )
	npcTitan.ai.titanSpawnLoadout = loadout

	npcTitan.EnableNPCFlag( NPC_IGNORE_FRIENDLY_SOUND )

	SetSpawnOption_AISettings( npcTitan, "npc_titan_buddy" )

	//	npcTitan.SetBossPlayer( player )
	DispatchSpawn( npcTitan )

	file.buddyTitan = npcTitan

	npcTitan.EnableNPCFlag( NPC_IGNORE_ALL )
	npcTitan.SetInvulnerable()
	npcTitan.SetNoTarget( true )
	npcTitan.ai.bossTitanVDUEnabled = false

	HideCrit( npcTitan )
	Highlight_ClearFriendlyHighlight( npcTitan )
	AddHighlightObject( npcTitan )

	file.oldBTTitle = npcTitan.GetTitle()
	npcTitan.SetTitle( "" )
	npcTitan.SetNoTarget( true )

	player.SetPetTitan( npcTitan )

	thread CreateNearBTTrigger( npcTitan, player )
	npcTitan.l.BTHightlightModel = AttachOutlineModel( npcTitan )

	return npcTitan
}

entity function BuddyTitanRemoveBatteyCaps()
{
	Assert( IsValid( file.buddyTitan ) )

	int bodyGroupIndex = file.buddyTitan.FindBodyGroup( "battery_cap_center" )
	file.buddyTitan.SetBodygroup( bodyGroupIndex, 1 )
	bodyGroupIndex = file.buddyTitan.FindBodyGroup( "battery_cap_outer" )
	file.buddyTitan.SetBodygroup( bodyGroupIndex, 1 )
}

entity function AttachOutlineModel( entity buddyTitan )
{
	entity ent = CreatePropScript( BATTERY_SLOT_OUTLINE_MODEL, buddyTitan.GetOrigin(), buddyTitan.GetAngles(), 0, 99999 )
	ent.SetParent( buddyTitan, "CHESTFOCUS", false )
	ent.Hide()
	Objective_InitEntity( ent )

	return ent
}

void function AttachBTCollision( string collisionName, string endFlag )
{
	entity mover = CreateScriptMover( file.buddyTitan.GetOrigin(), file.buddyTitan.GetAngles() )
	mover.SetPusher( true )
	entity collision = GetEntByScriptName( collisionName )
	collision.SetParent( mover, "REF", false, 0 )
	collision.SetPusher( true )

	mover.EndSignal( "OnDestroy" )
	file.buddyTitan.EndSignal( "OnDestroy" )
	collision.EndSignal( "OnDestroy" )

	if (!Flag( endFlag ) )
		FlagEnd( endFlag )

	OnThreadEnd(
		function() : ( mover, collision )
		{
			if ( IsValid( mover ) )
				mover.Destroy()

			if ( IsValid( collision ) )
				collision.Destroy()

			if ( IsAlive( file.buddyTitan ) )
				file.buddyTitan.Solid()
		}
	)

	file.buddyTitan.NotSolid()

	vector oldOrigin = <0,0,0>
	vector oldAngles = <0,0,0>
	while( true )
	{
		vector origin = file.buddyTitan.GetOrigin()
		vector angles = file.buddyTitan.GetAngles()
		if ( origin != oldOrigin || angles != oldAngles )
		{
			mover.NonPhysicsMoveTo( origin, 0.1, 0, 0 )
			mover.NonPhysicsRotateTo( angles, 0.1, 0, 0 )
			oldOrigin = origin
			oldAngles = angles
		}
		wait 0.1
	}
}

void function CreateBTStaticCollision( asset modelName )
{
	if ( IsValid( file.buddyTitanCollision ) )
		file.buddyTitanCollision.Destroy()

	entity scriptRef = GetEntByScriptName( "anim_ref_BT_hurt" )
	file.buddyTitanCollision = CreatePropDynamicLightweight( modelName, scriptRef.GetOrigin(), scriptRef.GetAngles() + <0,-85,0>, 6 )
}

void function CreateNearBTTrigger( entity buddyTitan, entity player )
{
	FlagEnd( "slot_battery3" )
	buddyTitan.EndSignal( "OnDeath" )

	entity trigger = GetEntByScriptName( "near_bt_trigger" )
	trigger.SetOrigin( buddyTitan.GetOrigin() )

//	this never got fixed will have to go with the hack
//	trigger.SetParent( buddyTitan )
	thread FakeAttach( trigger, buddyTitan )

	OnThreadEnd(
		function() : ( trigger )
		{
			trigger.Destroy()
		}
	)

	while ( true )
	{
		if ( !trigger.IsTouched() )
		{
			table result = WaitSignal( trigger, "OnStartTouch" )
		}
		FlagSet( "player_near_bt" )

		if ( trigger.IsTouched() )
			trigger.WaitSignal( "OnEndTouchAll" )

		FlagClear( "player_near_bt" )
	}
}

void function FakeAttach( entity trigger, entity bt )
{
	trigger.EndSignal( "OnDestroy" )
	bt.EndSignal( "OnDestroy" )

	while( true )
	{
		trigger.SetOrigin( bt.GetOrigin() )
		wait 1
	}
}

void function MakeBTPetTitan( entity player, entity buddyTitan )
{
	entity soul = buddyTitan.GetTitanSoul()

	if ( IsValid( soul ) )
	{
		soul.soul.lastOwner = player
		SoulBecomesOwnedByPlayer( soul, player )
	}

	SetupAutoTitan( buddyTitan, player )
}

entity function SpawnFromSpawner( entity spawner, void functionref( entity ) ornull spawnSettingsFunc = null )
{
	entity spawned
	if ( spawnSettingsFunc == null )
	{
		spawned = spawner.SpawnEntity()
		DispatchSpawn( spawned )
	}
	else
	{
		expect void functionref( entity )( spawnSettingsFunc )
		spawned = spawner.SpawnEntity()
		spawnSettingsFunc( spawned )
		DispatchSpawn( spawned )
	}

	return spawned
}

void function WildsProwlerSettings( entity prowler )
{
	prowler.SetBehaviorSelector( "behavior_prowler_cqb" )
	thread ClearAlwaysAlertOnSignal( prowler )
	//	int maxHealth = prowler.GetMaxHealth()
	//	int newHealth = int( maxHealth * 0.6 )
	//	prowler.SetMaxHealth( newHealth  )
	//	prowler.SetHealth( newHealth  )
}

void function ClearAlwaysAlertOnSignal( entity npc )
{
	npc.WaitSignal( "clear_always_alert" )
	if ( npc.HasKey( "alwaysalert" ) )
		npc.kv.alwaysalert = false
}

void function ClearQuickDeathTrigger( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )

	while( true )
	{
		trigger.WaitSignal( "OnTrigger" )

		ClearQuickDeath()
	}
}

void function MovePlayerToStartpoint( entity player, string startpoint )
{
	player.EndSignal( "OnDestroy" )

	entity startpointEnt = GetEntByScriptName( startpoint )

	vector origin = startpointEnt.GetOrigin()
	vector angles = startpointEnt.GetAngles()

	player.SetOrigin( origin )
	player.SetAngles( angles )
}

void function MoveAlongPath( entity ent, string pathScriptName = "" )
{
	entity scriptMover = CreateScriptMover( ent.GetOrigin(), ent.GetAngles() )
	scriptMover.SetPusher( true )

	ent.SetParent( scriptMover )

	ent.EndSignal( "OnDestroy" )
	scriptMover.EndSignal( "OnDestroy" )

	//  since stuff might link to other things then script_mover_paths
	array<entity> entArray
	if ( pathScriptName != "" )
		entArray = GetEntArrayByScriptName( pathScriptName )
	else
		entArray = ent.GetLinkEntArray()

	entity pathpoint
	foreach ( ent in entArray )
	{
		if ( ent.GetClassName() == "info_particle_system" )
		{
			EntFireByHandle( ent, "start", "", 0, null, null )
			continue
		}

		pathpoint = ent
		break
	}

	if ( pathpoint == null )
		return

	OnThreadEnd(
		function () : ( ent, scriptMover )
		{
			if ( IsValid( ent ) )
				ent.ClearParent()

			if ( IsValid( scriptMover ) )
				scriptMover.Destroy()
		}
	)

	// grabbing the initial speed from the first node will be good enough for this.
	float unitsPerSec = 1024
	if ( pathpoint.HasKey( "path_speed" ) && pathpoint.GetValueForKey( "path_speed" ) != "" )
		unitsPerSec = float( pathpoint.GetValueForKey( "path_speed" ) )

	entity lastPathpoint = null
	while( IsValid( pathpoint ) )
	{
		if ( pathpoint.HasKey( "teleport_to_node" ) && int( pathpoint.GetValueForKey( "teleport_to_node" ) ) == 1 )
		{
			// teleport
			scriptMover.SetOrigin( pathpoint.GetOrigin() )
			scriptMover.SetAngles( pathpoint.GetAngles() )
		}
		else
		{
			// move over time

			float dist = Distance( scriptMover.GetOrigin(), pathpoint.GetOrigin() )
			float moveTime = dist / unitsPerSec/// * 2

			float easeIn = 0.0
			float easeOut = 0.0

			if ( IsValid( lastPathpoint ) )
			{
				if ( lastPathpoint.HasKey( "ease_from_node" ) && int( lastPathpoint.GetValueForKey( "ease_from_node" ) ) == 1 )
					easeIn = moveTime
			}

			if ( pathpoint.HasKey( "ease_to_node" ) && int( pathpoint.GetValueForKey( "ease_to_node" ) ) == 1 )
				easeOut = moveTime

			if ( easeIn > 0 && easeOut > 0 )
			{
				easeIn *= 0.75
				easeOut *= 0.25
			}

			scriptMover.NonPhysicsMoveTo( pathpoint.GetOrigin(), moveTime, easeIn, easeOut )
			scriptMover.NonPhysicsRotateTo( pathpoint.GetAngles(), moveTime, easeIn, easeOut )
			wait moveTime - 0.1
		}

		if ( pathpoint.HasKey( "sound_move" ) && pathpoint.kv.sound_move != "" )
			EmitSoundOnEntity( ent, string( pathpoint.kv.sound_move ) )

		if ( pathpoint.HasKey( "scr_flag_set" ) )
			FlagSet( pathpoint.GetValueForKey( "scr_flag_set" ) )
		if ( pathpoint.HasKey( "scr_flag_clear" ) )
			FlagClear( pathpoint.GetValueForKey( "scr_flag_clear" ) )

		if ( pathpoint.HasKey( "scr_flag_wait" ) )
			FlagWait( pathpoint.GetValueForKey( "scr_flag_wait" ) )
		if ( pathpoint.HasKey( "scr_flag_wait_clear" ) )
			FlagWaitClear( pathpoint.GetValueForKey( "scr_flag_wait_clear" ) )

		if ( pathpoint.HasKey( "path_wait" ) && float( pathpoint.GetValueForKey( "path_wait" ) ) > 0 )
			wait float( pathpoint.GetValueForKey( "path_wait" ) )


		if ( pathpoint.HasKey( "path_speed" ) && pathpoint.GetValueForKey( "path_speed" ) != "" )
			unitsPerSec = float( pathpoint.GetValueForKey( "path_speed" ) )

		lastPathpoint = pathpoint

		entArray = pathpoint.GetLinkEntArray()
		pathpoint = null
		foreach ( ent in entArray )
		{
			if ( ent.GetClassName() == "info_particle_system" )
			{
				EntFireByHandle( ent, "start", "", 0, null, null )
				continue
			}

			if ( pathpoint == null )
				pathpoint = ent
		}
	}
}

void function TriggerDeleteSetup( entity trigger )
{
	trigger.ConnectOutput( "OnStartTouch", TriggerDelete )
}

void function TriggerDelete( entity trigger, entity activator, entity caller, var value )
{
	if ( IsValid( activator ) )
		activator.Destroy()
}

void function DestroyOnFlag( entity ent, string flag )
{
	ent.EndSignal( "OnDestroy" )

	if ( FlagExists( flag ) )
		FlagWait( flag )

	ent.Destroy()
}

void function ForceSlideThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	while( true )
	{
		FlagWait( "force_slide" )
		player.ForceSlide()

		FlagWaitClear(  "force_slide" )
		player.UnforceSlide()
	}
}

void function TriggerForceStand( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )

	while( true )
	{
		table results = WaitSignal( trigger, "OnTrigger" )
		entity activator = expect entity( results.activator )
		if ( !IsValid( activator ) )
			continue
		if ( !activator.IsPlayer() )
			continue

		activator.ForceStand()
		WaitFrame()
		activator.UnforceStand()

		break
	}
}

#if DEV
void function TestQuickDeathInit( entity trigger )
{
	file.quickDeathEntArray.extend( trigger.GetLinkEntArray() )
}

void function TestQuickDeath()
{
	if ( file.quickDeathEntArray.len() == 0 )
		return

	entity ent = file.quickDeathEntArray.pop()
	entity player = gp()[0]

	player.SetOrigin( ent.GetOrigin() )
	player.SetAngles( ent.GetAngles() )
}

#endif // DEV