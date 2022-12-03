//spawn_test
global function InjectorFire
global function LightstripSounds

global function CodeCallback_MapInit

global function DoWorldRumble
global function InjectorLightUp
global function InjectorSpoolDown

const float FRAME_INTERVAL = .1
const FX_CANNON_BEAM 				= $"P_rail_fire_beam_scale"

//TORTURE ROOM ASSETS
const asset COMBAT_KNIFE = $"models/weapons/combat_knife/w_combat_knife.mdl"
const asset WINGMAN = $"models/Weapons/b3wing/b3_wingman_hero_static.mdl"

const asset STRATON_MODEL	= $"models/vehicle/straton/straton_imc_gunship_01.mdl"

//RISING WORLD RUN ASSETS
const asset ROCK_IMPACT_DUST = $"P_sw_rock_impact_XL"
const asset ROCK_IMPACT_DEBRIS = $"P_gate_smash"
const asset PHYS_ROCK_TRAIL = $"Rocket_Smoke_Trail_Large"

//SCULPTOR RING MODELS
const asset OUTER_RING_CHUNK_MAIN = $"models/levels_terrain/sp_skyway/sculpter_outer_ring_dmg.mdl"
const asset MIDDLE_RING_CHUNK_MAIN = $"models/levels_terrain/sp_skyway/sculpter_middle_ring_dmg.mdl"
const asset INNER_RING_CHUNK_MAIN = $"models/levels_terrain/sp_skyway/sculpter_inner_ring_dmg.mdl"

//CORE MODELS/FX
const asset CORE_ENERGY = $"models/props/core_energy/core_energy_animated.mdl"
const asset FX_CORE_FLARE = $"env_star_blue"
const asset FX_CORE_GLOW = $"P_sw_introom_core_light"

//WORLD RUN DEBRIS
const asset LARGE_BEAM = $"models/industrial/beam_curved_metal02.mdl"
const asset TRUCK = $"models/vehicle/vehicle_truck_modular/vehicle_truck_modular_closed_bed.mdl"

//GOBLIN PARTS
const asset GOBLIN_DEBRIS_CABIN = $"models/vehicle/goblin_dropship/goblin_dropship_dest_center.mdl"
const asset GOBLIN_DEBRIS_WING_LEFT = $"models/vehicle/goblin_dropship/goblin_dropship_dest_wing_l.mdl"
const asset GOBLIN_DEBRIS_WING_RIGHT = $"models/vehicle/goblin_dropship/goblin_dropship_dest_wing_r.mdl"

//ROCK CHUNKS
const asset SMALL_ROCK_01 =  $"models/rocks/rock_jagged_granite_small_01_phys.mdl"
const asset SMALL_ROCK_02 =  $"models/rocks/rock_jagged_granite_small_02_phys.mdl"
const asset SMALL_ROCK_03 =  $"models/rocks/rock_jagged_granite_small_03_phys.mdl"
const asset SMALL_ROCK_04 =  $"models/rocks/rock_jagged_granite_small_04_phys.mdl"
const asset SMALL_ROCK_05 =  $"models/rocks/rock_jagged_granite_small_05_phys.mdl"
const asset SMALL_ROCK_06 =  $"models/rocks/rock_jagged_granite_small_06_phys.mdl"
const asset SMALL_ROCK_07 =  $"models/rocks/rock_jagged_granite_small_07_phys.mdl"

//CHARACTER MODELS
const asset CROW_HERO_MODEL = $"models/vehicle/crow_dropship/crow_dropship_hero.mdl"
const asset SW_CROW = $"models/vehicle/crow_dropship/crow_dropship.mdl"
const asset SLONE_MODEL = $"models/Humans/heroes/imc_hero_slone.mdl"
const asset SW_BLISK_MODEL = $"models/Humans/heroes/imc_hero_blisk.mdl"
const asset SW_SARAH_MODEL = $"models/humans/heroes/mlt_hero_sarah.mdl"
const asset MARDER_HOLOGRAM_MODEL = $"models/humans/heroes/imc_hero_marder.mdl"
const asset TORTURE_HARNESS = $"models/props/skyway_harness_01_animated.mdl"

const string SFX_WORLD_RUMBLE_CLOSE 				= "Skyway_Explosion_Rumble_Close"
const string SFX_WORLD_RUMBLE_DISTANT 				= "Skyway_Explosion_Rumble_Dist"

const asset FLAK_FX = $"P_sw_impact_exp_flak"
const asset COCKPIT_LIGHT = $"P_sw_cockpit_dlight_damaged"//$"veh_interior_Dlight_cockpit"

global const STRATON_SB_MODEL	= $"models/vehicle/straton/straton_imc_gunship_01_1000x.mdl"

const FX_CARRIER_ATTACK 	= $"P_weapon_tracers_megalaser"
const FX_REDEYE_ATTACKS_CARRIER 	= $"P_Rocket_Phaser_Swirl"
const FX_EXP_BIRM_SML = $"p_exp_redeye_sml"
const FIRE_TRAIL = $"Rocket_Smoke_Swirl_LG"
const FX_REDEYE_WARPIN_SKYBOX = $"veh_red_warp_in_full_SB_1000"
const FX_BIRMINGHAM_WARPIN_SKYBOX = $"veh_birm_warp_in_full_SB_1000"
const FX_EXPLOSION_MED = $"P_exp_redeye_sml_elec"

const asset SKYBOX_TRACER = $"P_muzzleflash_MaltaGun_sw"
const asset SKYBOX_MFLASH = $"P_muzzleflash_MaltaGun_sw_NoTracer"

const asset FX_BT_ARM_DAMAGED 	= $"P_xo_arm_damaged"
const asset FX_BT_ARM_DAMAGED_POP 	= $"P_xo_arm_damaged_pop"
const asset FX_BT_ARM_DAMAGED_POP_SM = $"P_xo_arm_damaged_pop_SM"

const asset FX_BT_BODY_DAMAGED_POP 	= $"xo_spark_small"
const asset FX_BT_BODY_DAMAGED_POP_SM = $"P_xo_BT_damaged_elec"

const asset FX_BT_COCKPIT_SPARK 	= $"xo_cockpit_spark_01"

const asset CORE_MODEL = $"models/core_unit/core_unit.mdl"
const asset BT_EYE_CASE_MODEL = $"models/Titans/buddy/titan_buddy_hatch_eye.mdl"
const asset SMART_PISTOL_MODEL = $"models/weapons/p2011sp/w_p2011sp.mdl"
const asset CARD_MODEL = $"models/props/blisk_card_animated.mdl"

const asset CORE_GLOW_ON_FX = $"P_sw_core_hld_sm"

const asset LIGHTSTRIP_1 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_01.mdl"
const asset LIGHTSTRIP_2 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_02.mdl"
const asset LIGHTSTRIP_3 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_03.mdl"
const asset LIGHTSTRIP_4 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_04.mdl"

const asset BARREL = $"models/containers/barrel.mdl"

struct
{
	entity tortureRoomGrate
	entity bliskKnife
	entity TRBTCore
	entity TRSloneCore

	GunBatteryData& gunBattery01
	GunBatteryData& gunBattery02
	GunBatteryData& gunBattery03
	GunBatteryData& gunBattery04
	GunBatteryData& gunBattery06

	vector tortureFogOnPos
	vector tortureFogOffPos

	array<entity> bombardTargets
	array<entity> forcedBombardList

	int statusEffect
	string bombardString = "BOMBARD_"
	entity bombardGun

	int currentPhase
	int idealPhase

	array<float> phaseDelays = [
		60.0,
		60.0,
		120.0,
		120.0,
		240.0,
		90.0
	]

	entity worldRunLandingNode
	entity dropship
	entity dropshipAnimNode
	entity core
	float pitch
	float lastPulldownTime

	float lastActionTime

	float lastPlayerActionTime
	bool glowDone = false
	int BtReunionChoice
	array<string> soundsToStop

	int heat
	int injectorFlapSet
	float extraDelay
} file

//Called when the map is initialized
void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	PrecacheImpactEffectTable( "exp_medium" )
	PrecacheImpactEffectTable( CLUSTER_ROCKET_FX_TABLE )

	PrecacheModel( BARREL )

	PrecacheParticleSystem( CORE_GLOW_ON_FX )

	PrecacheParticleSystem( FX_CARRIER_ATTACK )
	PrecacheParticleSystem( FX_EXP_BIRM_SML )
	PrecacheParticleSystem( FIRE_TRAIL )

	PrecacheParticleSystem( FX_HORNET_DEATH )
	PrecacheParticleSystem( FX_EXPLOSION_MED )

	PrecacheParticleSystem( SKYBOX_MFLASH )
	PrecacheParticleSystem( SKYBOX_TRACER )

	PrecacheParticleSystem( FX_BT_ARM_DAMAGED )
	PrecacheParticleSystem( FX_BT_ARM_DAMAGED_POP )
	PrecacheParticleSystem( FX_BT_ARM_DAMAGED_POP_SM )

	PrecacheParticleSystem( FX_BT_BODY_DAMAGED_POP )
	PrecacheParticleSystem( FX_BT_BODY_DAMAGED_POP_SM )

	PrecacheParticleSystem( FX_BT_COCKPIT_SPARK )

	PrecacheParticleSystem( $"P_sw_core_weather" )
	PrecacheParticleSystem( $"P_bt_cockpit_dlight_skyway" )
	PrecacheParticleSystem( $"P_impact_exp_med_metal" )

	Init_SkywayUtility()
	Init_Bombardment()
	ShSpSkywayCommonInit()

	//START POINT END FLAGS
	FlagInit( "TitanHillDone" )
	FlagInit( "InjectorRoomDone" )
	FlagInit( "BliskFareweelDone" )
	FlagInit( "BliskFareweelPlayerGetup" )
	FlagInit( "BTSacrificeDone" )
	FlagInit( "RisingWorldRunDone" )

	//Flags for Torture Room
	FlagInit( "TR_StartBurn" )
	FlagInit( "slone_kill_bt" )
	FlagInit( "slone_exit_tr" )
	FlagInit( "PlayerStartedTortureRoomDrag" )
	FlagInit( "DropEyeCase" )
	FlagInit( "DroppingEyeCase" )
	FlagInit( "TRDoorHackable" )
	FlagInit( "TortureRoomDone" )
	FlagInit( "TorturePlayerResponded" )
	FlagInit( "TorturePlayerGetup" )
	FlagInit( "TortureBTAwake" )

	FlagInit( "TR_Burn_Stage_Black" )
	FlagInit( "TR_Burn_Stage_1" )
	FlagInit( "TR_Burn_Stage_2" )
	FlagInit( "TR_Burn_Stage_3" )
	FlagInit( "TR_Burn_Stage_4" )
	FlagInit( "TR_Burn_Stage_5" )

	FlagInit( "TR_PauseRoomTemp" )

	FlagInit( "sp_run_rocks_light" )
	FlagInit( "sp_run_rocks_heavy" )
	FlagInit( "InjectorReadyToFire" )

	RegisterSignal( "ClientCommand_RequestTitanFake" )
	RegisterSignal( "begin_torture_id" )
	RegisterSignal( "pre_impact_barrels" )
	RegisterSignal( "impact_barrels" )
	RegisterSignal( "impact_ground" )
	RegisterSignal( "start_fire" )
	RegisterSignal( "BTSacrificeDialogue_BTMemory" )
	RegisterSignal( "PullDown" )
	RegisterSignal( "OnStopPulldown" )
	RegisterSignal( "BT_Returns_ChoiceMade" )
	RegisterSignal( "BTSacrificeDialogue" )
	RegisterSignal( "MissionFailAfterDelay" )
	RegisterSignal( "InjectorSpoolDown" )
	RegisterSignal( "Init_BTLoadingBayClimb" )

	FlagInit( "PickUpEyeCase" )

	//Flags for BT Reunion
	FlagInit( "AcceptEye" )
	FlagInit( "EyeInserted" )
	FlagInit( "BTReunionConversationDone" )
	FlagInit( "BTStoodUp" )
	FlagInit( "injector_lighting_FX" )

	//RegisterSignal( "InsertEyeCore" )

	// Titan Hill
	FlagInit( "titan_hill_arena" )
	FlagInit( "titan_hill_arena_2" )
	FlagInit( "titan_hill_arena_3" )
	FlagInit( "titan_hill_arena_door_open" )
	FlagInit( "BombardDialogueEnabled" )
	FlagInit( "BombardPaused" )
	FlagInit( "music_skyway_10_titanhillwave02" )

	FlagInit( "StoppingInjector" )
	FlagInit( "BTSacrifice_BTExplodes" )
	FlagInit( "BTMemorySequenceDone" )
	FlagInit( "BliskFarewellRadioPlayDone" )
	FlagInit( "BTSacrificeEnteredInjector" )
	FlagInit( "InjectorInteractionAvailable" )

	FlagInit( "BT_Throws_Player" )

	//Flags for Rising World Run
	FlagInit( "SpawnRingChunk" )
	FlagInit( "slam_rocks_01" )
	FlagInit( "embed_droppod_01" )
	FlagInit( "StartRise" )
	FlagInit( "PreLandingAreaRise" )
	FlagInit( "StartLandingAreaRise" )
	FlagInit( "tilting_platform_end" )
	FlagInit( "HideWorldRunRandoms" )
	FlagInit( "rising_world_core_FX" )
	FlagInit( "rising_world_core_FX_end" )

	FlagInit( "HarmonySceneStart" )
	FlagInit( "HarmonyRadio2" )
	FlagInit( "HarmonyRadio3" )

	FlagInit( "InjectorConversationDone" )

	RegisterSignal( "RockStrike" )
	RegisterSignal( "DoWorldRumble" )
	RegisterSignal( "StopFlybys" )
	RegisterSignal( "StartNextPhase" )
	RegisterSignal( "ForceNextPhase" )
	RegisterSignal( "BT_GOODBYE_DIALOGUE" )

	PrecacheParticleSystem( $"ar_target_CP_controlled" )
	PrecacheParticleSystem( $"veh_carrier_warp_full" )
	PrecacheParticleSystem( FLAK_FX )
	PrecacheParticleSystem( FX_CANNON_BEAM )
	PrecacheParticleSystem( $"P_rail_fire_flash" )

	//PRECACHE TORTURE ROOM ASSETS
	PrecacheModel( MARDER_HOLOGRAM_MODEL )
	PrecacheModel( SW_BLISK_MODEL )
	PrecacheModel( SW_SARAH_MODEL )
	PrecacheModel( COMBAT_KNIFE )
	PrecacheModel( WINGMAN )
	PrecacheModel( CARD_MODEL )
	PrecacheModel( BT_EYE_CASE_MODEL )
	PrecacheModel( SMART_PISTOL_MODEL )
	PrecacheModel( SW_CROW )
	PrecacheModel( TORTURE_HARNESS )
	PrecacheModel( LIGHTSTRIP_1 )
	PrecacheModel( LIGHTSTRIP_2 )
	PrecacheModel( LIGHTSTRIP_3 )
	PrecacheModel( LIGHTSTRIP_4 )
	PrecacheModel( $"models/fx/xo_shield_coll_small.mdl" )

	//PRECACHE RISING WORLD RUN ASSETS
	PrecacheParticleSystem( ROCK_IMPACT_DEBRIS )
	PrecacheParticleSystem( $"hotdrop_radial_smoke" )
	PrecacheParticleSystem( ROCK_IMPACT_DUST )
	PrecacheParticleSystem( PHYS_ROCK_TRAIL )

	PrecacheModel( OUTER_RING_CHUNK_MAIN )
	PrecacheModel( MIDDLE_RING_CHUNK_MAIN )
	PrecacheModel( INNER_RING_CHUNK_MAIN )

	PrecacheModel( $"models/dev/editor_ref.mdl" )

	PrecacheModel( LARGE_BEAM )

	PrecacheModel( TRUCK )
	PrecacheModel( GOBLIN_DEBRIS_CABIN )
	PrecacheModel( GOBLIN_DEBRIS_WING_LEFT )
	PrecacheModel( GOBLIN_DEBRIS_WING_RIGHT )

	PrecacheModel( $"models/rocks/rock_jagged_granite_flat_02.mdl" )

	PrecacheModel( SMALL_ROCK_01 )
	PrecacheModel( SMALL_ROCK_02 )
	PrecacheModel( SMALL_ROCK_03 )
	PrecacheModel( SMALL_ROCK_04 )
	PrecacheModel( SMALL_ROCK_05 )
	PrecacheModel( SMALL_ROCK_06 )
	PrecacheModel( SMALL_ROCK_07 )

	PrecacheModel( STRATON_SB_MODEL )

	//SCULPTOR CORE ASSETS
	PrecacheModel( CORE_ENERGY )
	PrecacheParticleSystem( FX_CORE_FLARE )
	PrecacheParticleSystem( FX_CORE_GLOW )

	PrecacheParticleSystem( COCKPIT_LIGHT )

	//------------------
	// Start points
	//------------------
					//startPoint, 					mainFunc,							setupFunc							skipFunc
	AddStartPoint( "Level Start", 					SP_LevelStartThread, 				null, 								LevelStartSkipped )
	AddStartPoint( "Torture Room B",				SP_TortureRoomThread, 				TortureRoomSetup,					TortureRoomSkipped )
	AddStartPoint( "Smart Pistol Run",				SP_SmartPistolRunThread,			SmartPistolRunStartPointSetup,		SmartPistolRunSkipped)
	AddStartPoint( "Bridge Fight", 					SP_BridgeFightThread,				BridgeFightStartPointSetup, 		BridgeFightSkipped )
	AddStartPoint( "BT Reunion", 					SP_BTReunionThread,					BTReunionStartPointSetup, 			BTReunionSkipped )
	AddStartPoint( "Titan Hill",					SP_TitanHillThread,					TitanHillStartPointSetup,			TitanHillSkipped )
	AddStartPoint( "Titan Smash Hallway",			SP_TitanSmashHallwayThread,			TitanSmashHallwayStartPointSetup,	TitanSmashHallwaySkipped )
	AddStartPoint( "Sculptor Climb",				SP_SculptorClimbThread,				SculptorClimbStartPointSetup,		SculptorClimbSkipped )
	AddStartPoint( "Targeting Room",				SP_TargetingRoomThread,				TargetingRoomStartPointSetup,		TargetingRoomSkipped )
	AddStartPoint( "Injector Room",					SP_InjectorRoomThread,				InjectorRoomStartPointSetup,		InjectorRoomSkipped )
	AddStartPoint( "Blisk's Farewell",				SP_BliskFarewellThread,				BliskFarewellStartPointSetup,		BliskFarewellSkipped )
	AddStartPoint( "BT Sacrifice",					SP_BTSacrificeThread,				BTSacrificeStartPointSetup,			BTSacrificeSkipped )
	AddStartPoint( "Rising World Run",				SP_RisingWorldRunThread,			RisingWorldRunStartPointSetup, 	 	RisingWorldRunSkipped )
	AddStartPoint( "Rising World Jump",				SP_RisingWorldJumpThread,			RisingWorldJumpStartPointSetup, 	 	RisingWorldJumpSkipped )
	AddStartPoint( "Exploding Planet",				SP_ExplodingPlanetThread,			ExplodingPlanetStartPointSetup,  	ExplodingPlanetSkipped )
	AddStartPoint( "Harmony",						SP_HarmonyThread,					HarmonyStartPointSetup,		 	 	HarmonySkipped )
	
	AddState( "Torture" )
	AddState( "Action1" )
	AddState( "Action2" )
	AddState( "OnlyTitans" )
	AddState( "OnlyPilots" )

	AddCallback_OnPlayerRespawned( PlayerRespawned )

	FlagInit( "BreakWorld" )


	AddScriptNoteworthySpawnCallback( "die_at_end", NPC_DieAtPathEnd )
	AddScriptNoteworthySpawnCallback( "bridge_turrets", BridgeTurretsSpawnThink )
	AddScriptNoteworthySpawnCallback( "no_self_damage", AISetNoSelfDamage )
	AddScriptNoteworthySpawnCallback( "bombard_me", BombardTarget )
	AddScriptNoteworthySpawnCallback( "bombard_me_instant", BombardTargetInstant )
	AddScriptNoteworthySpawnCallback( "npc_bullseye", BullseyeSettings )

	AddSpawnCallback_ScriptName( "titan_hill_turret", 	EnableMegaTurret )
	AddSpawnCallback_ScriptName( "trigger_level_signal", TriggerSignal )
	AddSpawnCallback_ScriptName( "disable_disembark_trigger", TriggerDisableDisembark )
	AddSpawnCallback_ScriptName( "random_flying_chunks", RandomFlyingChunksThink )
	AddSpawnCallback_ScriptName( "random_rotating_chunks", RandomRotatingChunksThink )
	AddSpawnCallback_ScriptName( "world_run_sound_emitter", WorldRunSoundEmitterThink )
	// AddSpawnCallback_ScriptName( "fake_guy_spawner", FakeGuySpawnerThink )

	AddClientCommandCallback( "enable_jumpkit", ClientCommand_EnableJumpkit )
	AddClientCommandCallback( "ClientCommand_RequestTitanFake", ClientCommand_RequestTitanFake )
	AddClientCommandCallback( "ClientCommand_Pulldown", ClientCommand_Pulldown )
	AddClientCommandCallback( "ClientCommand_StopPulldown", ClientCommand_StopPulldown )

	AddDeathCallback( "npc_turret_mega", SpawnTitanBatteryOnDeath )
	AddDamageCallbackSourceID( eDamageSourceId.bombardment, Bombardment_DamagedEntity )

	AddCallback_OnLoadSaveGame( RestartInjectorSounds )
	AddCallback_OnClientConnected( PlayerJoined )

	FlagSet( "DogFights" )
	FlagSet( "FlightPath_TitanDrop" )

	Credits_MapInit() //MUST BE THE LAST ENTRY
}

//Callback checking if the map entities loaded
void function EntitiesDidLoad()
{
	FlagInit( "aiskit_dontbreakout" )
	FlagInit( "bombardment_env_target_01" )
	FlagInit( "bombardment_titan_target_01" )
	FlagInit( "bombardment_target_01" )
	Init_FloatingWorldStuff()
	//thread WaitForFuelSegment()
	//thread WaitForHillCounterAttackStart( "start_hill_assault" )
	//StartPlatformSpawning( "approach_drone_01", 2.0 )
	//StartPlatformSpawning( "drone_ambient_loop_01", 10.0 )
	//StartPlatformSpawning( "drone_crossing_loop_01", 10.0 )

	//thread HangarElevatorThread( "hangar_lift_03", "hangar_lift_doors_03_a", "hangar_lift_up_03" )
	//thread HangarElevatorThread( "hangar_lift_04", "hangar_lift_doors_04_a", "hangar_lift_up_04" )

	InitTortureFogVolume()

	entity malta = GetEntByScriptName( "malta" )
	malta.Hide()

 	file.bombardGun = GetEntByScriptName( "mil_ship2_starboard_gun_02" )

	thread WarpShips( "vista_warp", "sp_run_vista_titan_hill" )
	thread WarpShips( "ship_01", "sp_run_vista_titan_hill" )

	array<entity> boulders = GetEntArrayByScriptName( "floating_boulder" )
	foreach ( b in boulders )
		b.Hide()

	array<entity> chunks = GetEntArrayByScriptName( "start_chunk_flyby" )
	foreach( c in chunks )
		c.Hide()

	InitHillGuns()

	entity helmet = GetEntByScriptName( "jack_helmet" )
	helmet.EnableRenderAlways()

	int loadoutIndex = GetSPTitanLoadoutIndexForWeapon( "mp_titanweapon_predator_cannon" )
	SetBTLoadoutUnlocked( loadoutIndex )

	entity core = GetEntByScriptName( "core_origin" )
	file.core = CreateScriptMover()
	file.core.SetOrigin( core.GetOrigin() )

	entity tr_door = GetEntByScriptName( "tr_door" )
	tr_door.DisableHibernation()
	// EmitSoundOnEntity( file.core, "skyway_emit_foldweapon_normalstate_loop" )

	entity dropship = GetEntByScriptName( "escape_ship" )
	dropship.Hide()

	FlagSet( "injector_lighting_FX" )

	array<entity> godrays = GetEntArrayByScriptName( "skyway_injector_godrays" )
	foreach( piece in godrays )
		piece.Destroy()

	entity injector_door_anim = GetEntByScriptName( "injector_door_anim" )
	injector_door_anim.Hide()
	entity injector_door_art = GetEntByScriptName( "injector_door_art" )
	injector_door_art.SetParent( injector_door_anim, "BODY", true, 0.0 )

	entity loadingBayButton = GetEntByScriptName( "loading_bay_useable" )
	loadingBayButton.NotSolid()
}

void function PlayerJoined( entity player )
{
	entity bt = player.GetPetTitan()
	if ( IsValid( bt ) && ( GetState() == "Torture" || GetState() == "Action1" ) )
	{
		bt.Destroy()
	}

	if ( GetState() == "Torture" )
	{
		player.SetNoTarget( true )
		player.DisableWeapon()
		player.SetInvulnerable()
		player.ContextAction_SetBusy()
		TakeAllWeapons( player )
		player.TakeOffhandWeapon( 1 )

		thread RemoveWeaponsOnRespawn( player ) // pain

		player.SetOrigin( < -11558, -7031, 3520 > )
	}
	
	if ( !IsValid( GetPlayer0() ) )
		SetPlayer0( player )
}

void function RemoveWeaponsOnRespawn( entity player )
{
	EndSignal( player, "OnDestroy" )

	while( !IsAlive( player ) )
		WaitFrame()
	
	TakeAllWeapons( player )
}

void function PlayerRespawned( entity player )
{
	entity bt = player.GetPetTitan()
	if ( IsValid( bt ) && ( GetState() == "Torture" || GetState() == "Action1" ) )
	{
		bt.Destroy()
	}

	if ( GetState() == "Torture" )
	{
		player.SetNoTarget( true )
		player.DisableWeapon()
		player.SetInvulnerable()

		if ( player.ContextAction_IsBusy() )
			player.ContextAction_SetBusy()

		TakeAllWeapons( player )
		player.TakeOffhandWeapon( 1 )
	}

	if ( GetState() == "OnlyTitans" )
		thread MakePlayerTitan( player, player.GetOrigin() )
	else if ( GetState() == "OnlyPilots" )
		thread MakePlayerPilot( player, player.GetOrigin() )
}


 /*
  _                   _   ____  _             _
 | |    _____   _____| | / ___|| |_ __ _ _ __| |_
 | |   / _ \ \ / / _ \ | \___ \| __/ _` | '__| __|
 | |__|  __/\ V /  __/ |  ___) | || (_| | |  | |_
 |_____\___| \_/ \___|_| |____/ \__\__,_|_|   \__|

*/

void function SP_LevelStartThread( entity player )
{
	FlagSet( "TitanDeathPenalityDisabled" )
	FlagClear( "TitanDeathPenalityDisabled" )

	level.nv.coreSoundActive = 0
	level.nv.fireStage = 0

	FlagClear( "WeaponDropsAllowed" )

	entity loadingBayButton = GetEntByScriptName( "loading_bay_useable" )
	loadingBayButton.Hide()

	StartRingRotation()
	HideWorldRunStuff()

	TakeAllWeapons( player )
	player.TakeOffhandWeapon( 1 )

	thread ShowIntroScreen( player )
	// huh no intro text?

	entity sequenceRef = GetEntByScriptName( "tr_sequence_ref" )
	player.SetOrigin( sequenceRef.GetOrigin() )

	FlagWait( "IntroScreenFading" )

	PlayMusic( "music_skyway_01_intro" )

	// thread ShadowDepthResTweak( player )
	foreach( entity p in GetPlayerArray() )
		thread TortureRoomOpeningBlur( p )
	thread SloneTortureRoom( sequenceRef, player )
	thread BliskTortureRoom( sequenceRef, player )
	thread BTTortureRoom( sequenceRef, player )
	thread PlayerTortureRoom( sequenceRef, player )
	thread HarnessTortureRoom( sequenceRef )
	thread GuardATortureRoom( sequenceRef )
	thread GuardBTortureRoom( sequenceRef )
	thread MarderTortureRoom( sequenceRef )
	//player.SetNoTarget( false )
}

void function ShadowDepthResTweak( entity player )
{
	int oldDepth = GetConVarInt( "shadow_depthres" )
	int idealDepth = 512
	if ( oldDepth >= idealDepth )
		return

	ClientCommand( player, "shadow_depthres " + idealDepth )
	FlagWait( "TR_Burn_Stage_Black" )
	ClientCommand( player, "shadow_depthres " + oldDepth )
}

bool function ClientCommand_EnableJumpkit( entity player, array<string> args )
{
	if ( Flag( "LevelStartDone" ) )
		player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [] )
	return true
}

void function LevelStartSkipped( entity player )
{

//	FlagSet( "TitanDeathPenalityDisabled" )
//	entity bt = player.GetPetTitan()
//	bt.Destroy()
//	FlagClear( "TitanDeathPenalityDisabled" )

	entity loadingBayButton = GetEntByScriptName( "loading_bay_useable" )
	loadingBayButton.Hide()

	StartRingRotation()
	HideWorldRunStuff()
}

void function InitTortureFogVolume()
{
	entity fogVolume = GetEntByScriptName( "torture_fog_volume" )
	file.tortureFogOnPos = fogVolume.GetOrigin() + <0,0,512>
	file.tortureFogOffPos = fogVolume.GetOrigin()
}

void function TortureFogOn()
{
	entity fogVolume = GetEntByScriptName( "torture_fog_volume" )
	fogVolume.SetOrigin( file.tortureFogOnPos )
}

void function TortureFogOff()
{
	entity fogVolume = GetEntByScriptName( "torture_fog_volume" )
	fogVolume.SetOrigin( file.tortureFogOffPos )
}

void function TortureRoomOpeningBlur( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 1, 1, 0 )
	wait 4
	Remote_CallFunction_Replay( player, "ScriptCallback_LevelIntroText" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", .5, 3, 0 )
	wait 3
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", .75, 2, 0 )
	wait 2
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", .25, 1, 0 )
	wait 1
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", .5, 1, 0 )
	wait 1
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0, 1, 0 )
	wait 1
}

void function PlayerTortureRoom( entity scriptRef, entity player, string firstPersonAnim = "pov_torture_intro_player", string thirdPersonAnim = "pt_torture_intro_player" )
{
	int status = StatusEffect_AddEndless( player, eStatusEffect.turn_slow, 0.3 )

	foreach( entity p in GetPlayerArray() )
	{
		p.SetPlayerSettingsWithMods( "civilian_solo_skyway", [] )
	}

	waitthread PlayerTortureRoomSequence( scriptRef, player, firstPersonAnim, thirdPersonAnim )

	foreach( entity p in GetPlayerArray() )
	{
		StatusEffect_Stop( p, status )
		StatusEffect_AddTimed( p, eStatusEffect.turn_slow, 0.15, 8, 8 )
		StatusEffect_AddTimed( p, eStatusEffect.move_slow, 0.3, 20, 20 )
	}

	Signal( level, "StopDOFTracking" )
	CheckPoint_Forced()

	//Wait for player to pick up eye case
	FlagWait( "PickUpEyeCase" )
}

void function PlayerTortureRoomSequence( entity scriptRef, entity player, string firstPersonAnim = "pov_torture_intro_player", string thirdPersonAnim = "pt_torture_intro_player" )
{
	FullyHidePlayers()

	foreach( player in GetPlayerArray() )
	{
		player.SetNoTarget( true )
		//EmitSoundAtPosition( TEAM_UNASSIGNED, helmet.GetOrigin(), "Player_Melee_Backhand_1P" )

		player.DisableWeapon()
		player.SetInvulnerable()
		//player.FreezeControlsOnServer()
		player.ContextAction_SetBusy()
	}

	//----------------------------------
	// Player torture room sequence
	//------------------------------------
	entity moverIntro = CreateOwnedScriptMover( scriptRef ) //need a mover for first person sequence

	FlagSet( "PlayerStartedTortureRoomDrag" )

	thread WaitForBTThrowPlayerImpact( player, scriptRef )

	foreach( player in GetPlayerArray() )
		thread WaitForTortureRoomID( player )
	
	foreach( player in GetPlayerArray() )
		delaythread( 2.5 ) ViewConeRestrained( player )

	if ( !Flag( "TorturePlayerResponded" ) )
  	{
  		FirstPersonSequenceStruct sequenceTortureRoom
		sequenceTortureRoom.blendTime = 0.0
		sequenceTortureRoom.attachment = "ref"
		sequenceTortureRoom.firstPersonAnim = "pov_torture_intro_player_beforeQuestion"
		sequenceTortureRoom.thirdPersonAnim = "pt_torture_intro_player_beforeQuestion"
		sequenceTortureRoom.viewConeFunction = ViewConeZero
		foreach( player in GetPlayerArray() )
		{
			if ( player != GetPlayer0() )
				thread FirstPersonSequence( sequenceTortureRoom, player, moverIntro )
		}
		waitthread FirstPersonSequence( sequenceTortureRoom, GetPlayer0(), moverIntro )

  		FirstPersonSequenceStruct sequenceTortureRoomIdle
		sequenceTortureRoomIdle.blendTime = 0.0
		sequenceTortureRoomIdle.attachment = "ref"
		sequenceTortureRoomIdle.firstPersonAnim = "pov_torture_intro_player_beforeQuestion_idle"
		sequenceTortureRoomIdle.thirdPersonAnim = "pt_torture_intro_player_beforeQuestion_idle"
		sequenceTortureRoomIdle.viewConeFunction = ViewConeRestrained
		foreach( player in GetPlayerArray() )
			thread FirstPersonSequence( sequenceTortureRoomIdle, player, moverIntro )
  		FlagWait( "TorturePlayerResponded" )
  	}

	FirstPersonSequenceStruct sequenceTortureRoomDrag
	sequenceTortureRoomDrag.blendTime = 0.0
	sequenceTortureRoomDrag.attachment = "ref"
	sequenceTortureRoomDrag.firstPersonAnim = firstPersonAnim
	sequenceTortureRoomDrag.thirdPersonAnim = thirdPersonAnim
	sequenceTortureRoomDrag.viewConeFunction = ViewConeRestrained
	
	foreach( player in GetPlayerArray() )
	{
		if ( player != GetPlayer0() )
			thread FirstPersonSequence( sequenceTortureRoomDrag, GetPlayer0(), moverIntro )
	}
	waitthread FirstPersonSequence( sequenceTortureRoomDrag, player, moverIntro )

	FirstPersonSequenceStruct sequenceTortureRoomKill
	sequenceTortureRoomKill.blendTime = 0.0
	sequenceTortureRoomKill.attachment = "ref"
	sequenceTortureRoomKill.firstPersonAnim = "pov_torture_kill_player"
	sequenceTortureRoomKill.thirdPersonAnim = "pt_torture_kill_player"
	sequenceTortureRoomKill.viewConeFunction = ViewConeZero
	
	foreach( player in GetPlayerArray() )
	{
		if ( player != GetPlayer0() )
			thread FirstPersonSequence( sequenceTortureRoomKill, player, moverIntro )
	}
	waitthread FirstPersonSequence( sequenceTortureRoomKill, GetPlayer0(), moverIntro )

	FullyHidePlayers()

	FirstPersonSequenceStruct sequenceTortureRoomKillIdle
	sequenceTortureRoomKillIdle.blendTime = 0.0
	sequenceTortureRoomKillIdle.attachment = "ref"
	sequenceTortureRoomKillIdle.firstPersonAnim = "pov_torture_kill_player_endidle"
	sequenceTortureRoomKillIdle.thirdPersonAnim = "pt_torture_kill_player_endidle"
	sequenceTortureRoomKillIdle.viewConeFunction = ViewConeZero
	
	foreach( player in GetPlayerArray() )
	{
		thread FirstPersonSequence( sequenceTortureRoomKillIdle, player, moverIntro )
	}
	vector org = player.EyePosition()

	FlagWait( "TorturePlayerGetup" )

	wait 5.0

	FirstPersonSequenceStruct sequenceTortureRoomGetup
	sequenceTortureRoomGetup.blendTime = 0.0
	sequenceTortureRoomGetup.attachment = "ref"
	sequenceTortureRoomGetup.firstPersonAnim = "pov_torture_kill_player_get_up"
	sequenceTortureRoomGetup.thirdPersonAnim = ""
	sequenceTortureRoomGetup.viewConeFunction = ViewConeZero
	
	foreach( player in GetPlayerArray() )
	{
		if ( player != GetPlayer0() )
			thread FirstPersonSequence( sequenceTortureRoomGetup, player, moverIntro )
	}
	waitthread FirstPersonSequence( sequenceTortureRoomGetup, GetPlayer0(), moverIntro )

	Objective_Set( "#SKYWAY_OBJECTIVE_SURVIVE" )
	
	foreach( player in GetPlayerArray() )
	{
		player.ClearInvulnerable()
		player.Anim_Stop()
		player.ClearParent()
		ClearPlayerAnimViewEntity( player )
		if ( player.ContextAction_IsBusy() )
			player.ContextAction_ClearBusy()
		player.EnableWeaponWithSlowDeploy()
		player.SetNoTarget( false )

		player.GiveWeapon( "mp_weapon_smart_pistol_og" )
	}
	moverIntro.Destroy()

	NextState()

	FullyShowPlayers()
}

void function WaitForTortureRoomID( entity player )
{
	WaitSignal( player, "begin_torture_id" )
	waitthread PlayerConversation( "Blisk_Torture", player )

	wait 0.2

	FlagSet( "TorturePlayerResponded" )
}

void function WaitForBTThrowPlayerImpact( entity player, entity scriptRef )
{
	Assert( IsNewThread(), "Must be threaded off" )
	entity proxy = player.GetFirstPersonProxy()
	entity animatedBarrel = GetEntByScriptName( "tr_barrel_animated" )
	thread PlayAnim( animatedBarrel, "barrel_torture_intro_idle", scriptRef )

	WaitSignal( player, "pre_impact_barrels" )

	StopMusicTrack( "music_skyway_01_intro" )
	PlayMusic( "music_skyway_02a_bithitcylinder" )

	WaitSignal( player, "impact_barrels" )
	delaythread( 5.5 ) BlowupBarrel( animatedBarrel )
	CreateShake( player.GetOrigin(), 15, 105, 0.75, 768 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 0 )

	thread PlayAnim( animatedBarrel, "barrel_torture_intro", scriptRef )

	entity pusher = GetEntByScriptName( "tr_physics_push" )
	array<entity> barrels = GetEntArrayByScriptName( "tr_barrel" )
	foreach ( b in barrels )
	{
		vector vel = Normalize( b.GetOrigin() - pusher.GetOrigin() )
		vel = <vel.x, vel.y, 0.45>

		vel = RotateVector( vel, <0,-20,0> )

		b.SetVelocity( vel * 150 )
	}

	WaitSignal( player, "impact_ground" )

	CreateShake( player.GetOrigin(), 15, 105, 1.25, 768 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 0 )

	// file.statusEffect = StatusEffect_AddEndless( player, eStatusEffect.emp, 0.1 )
	// StatusEffect_AddTimed( player, eStatusEffect.emp, 1.0, 1.0, 0.75 )
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 1, .1, 0 )
	wait 1
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", .5, 2, 0 )
	wait 2
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", .75, 3, 0 )
}

void function BlowupBarrel( entity barrel )
{
	StartParticleEffectInWorld( GetParticleSystemIndex($"P_impact_exp_med_metal"), barrel.GetOrigin(), <0,0,0> )
	barrel.Destroy()
}

void function BTTortureRoom( entity scriptRef, entity player, string animation = "BT_torture_intro" )
{
	entity bt = GetEntByScriptName( "torture_room_BT" )

	entity titan = CreatePetTitan( player, bt.GetOrigin(), bt.GetAngles() )
	Highlight_ClearOwnedHighlight( titan )
	titan.SetSkin( 1 )
	bt.Hide()
	bt = titan
	// array<string> bodyGroups = [
	// "hip",
	// "front",
	// "right_arm",
	// "hatch"
	// ]
	// foreach ( part in bodyGroups )
	// {
	// 	int bodyGroupIndex = bt.FindBodyGroup( part )
	// 	bt.SetBodygroup( bodyGroupIndex, 1 )
	// }

	bt.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	bt.SetInvulnerable()
	bt.SetNoTarget( true )
	HideName( bt )
	player.SetPetTitan( bt )

	AddAnimEvent( bt, "dof_bt_head", FocusOnBTHead )
	AddAnimEvent( bt, "dof_bt_cockpit", FocusOnBTCockpit )
	AddAnimEvent( bt, "dof_bt_r_hand", FocusOnBTRightHand )
	AddAnimEvent( bt, "bt_warn_player", TortureBTWarnPlayer )
	AddAnimEvent( bt, "bt_show_core_in_cockpit", ShowCoreInCockpit )
	AddAnimEvent( bt, "bt_destroy_core_in_cockpit", DestroyCoreInCockpit )
	thread CreateBTArmDamagedFX( bt )
	thread CreateBTBodyDamagedFX( bt )

	if ( !Flag( "TorturePlayerResponded" ) )
  	{
  		waitthread PlayAnimTeleport( bt, "BT_torture_intro_beforeQuestion", scriptRef )
  		thread PlayAnimTeleport( bt, "BT_torture_intro_beforeQuestion_idle", scriptRef )
  		FlagWait( "TorturePlayerResponded" )
  	}

	waitthread PlayAnimTeleport( bt, animation, scriptRef )
	FlagSet( "slone_kill_bt" )

	bt.NotSolid()
	EmitSoundOnEntity( bt, "skyway_scripted_tortureroom_bt_dead_fx_loop" )
	// titan.Destroy()
	// bt = GetEntByScriptName( "torture_room_BT" )
	// bt.Show()

	// AddAnimEvent( bt, "dof_bt_head", FocusOnBTHead )
	// AddAnimEvent( bt, "dof_bt_cockpit", FocusOnBTCockpit )
	// AddAnimEvent( bt, "dof_bt_r_hand", FocusOnBTRightHand )
	// AddAnimEvent( bt, "bt_show_core_in_cockpit", ShowCoreInCockpit )
	// AddAnimEvent( bt, "bt_destroy_core_in_cockpit", DestroyCoreInCockpit )
	waitthread PlayAnimTeleport( bt, "BT_torture_kill", scriptRef )
	thread PlayAnimTeleport( bt, "BT_torture_kill_idle", scriptRef )

	//Create eyecase for player to pick up
	waitthread PlayerTortureRoomGiveEyeCase( bt, player, scriptRef )

	//Wait for player to pick up eyecase
	FlagWait( "PickUpEyeCase" )

	waitthread PlayAnimTeleport( bt, "BT_torture_cache_pickup", scriptRef )
	thread PlayAnimTeleport( bt, "BT_torture_cache_pickup_idle", scriptRef )

	entity panel = GetEntByScriptName( "tr_door_pannel" )
	Objective_Set( "#SKYWAY_OBJECTIVE_ESCAPE" )
}

//BT ARM FX
void function CreateBTArmDamagedFX( entity bt )
{
	bt.EndSignal( "OnDeath" )
	bt.EndSignal( "OnDestroy" )
	EndSignal( level, "TortureRoomDone" )

	int fx_small = GetParticleSystemIndex( FX_BT_ARM_DAMAGED_POP_SM )
	int fx_large = GetParticleSystemIndex( FX_BT_ARM_DAMAGED_POP )
	int attachID = bt.LookupAttachment( "fx_L_socket" )

	entity fxHandle = StartParticleEffectOnEntity_ReturnEntity( bt, GetParticleSystemIndex( FX_BT_ARM_DAMAGED ), FX_PATTACH_POINT_FOLLOW, attachID )

	OnThreadEnd(
		function() : ( fxHandle )
			{
			if ( IsValid( fxHandle ) )
				EffectStop( fxHandle )
		}
	)

	while( 1 )
	{
		StartParticleEffectOnEntity( bt, fx_small, FX_PATTACH_POINT_FOLLOW, attachID )
		EmitSoundOnEntity( bt, "skyway_scripted_tortureroom_bt_orange_spark" )
		wait RandomFloatRange(3,5)

		StartParticleEffectOnEntity( bt, fx_large, FX_PATTACH_POINT_FOLLOW, attachID )
		EmitSoundOnEntity( bt, "skyway_scripted_tortureroom_bt_orange_spark" )
		wait RandomFloatRange(1,2)
	}
}

//BT COCKPIT FX
void function CreateBTCockpitDamagedFX( entity bt )
{
	bt.EndSignal( "OnDeath" )
	bt.EndSignal( "OnDestroy" )

	int fx_small = GetParticleSystemIndex( FX_BT_COCKPIT_SPARK )

	entity fxHandle

	OnThreadEnd(
		function() : ( fxHandle )
			{
			if ( IsValid( fxHandle ) )
				EffectStop( fxHandle )
		}
	)

	array<string> tags = [
	"FX_TL_PANEL",
	"FX_TR_PANEL",
	"FX_TC_PANELA",
	"FX_TC_PANELB",
	"FX_BL_PANEL",
	"FX_BR_PANEL"
	]

	while( 1 )
	{
		int attachID = bt.LookupAttachment( tags.getrandom() )

		StartParticleEffectOnEntity( bt, fx_small, FX_PATTACH_POINT_FOLLOW, attachID )
		EmitSoundOnEntity( bt, "skyway_scripted_tortureroom_bt_orange_spark" )
		wait RandomFloatRange(0.2,0.5)

	}
}

void function CreateBTBodyDamagedFX( entity bt )
{
	bt.EndSignal( "OnDeath" )
	bt.EndSignal( "OnDestroy" )
	EndSignal( level, "TortureRoomDone" )

	int fx_small = GetParticleSystemIndex( FX_BT_BODY_DAMAGED_POP_SM )
	int fx_large = GetParticleSystemIndex( FX_BT_BODY_DAMAGED_POP )

	entity fxHandle

	OnThreadEnd(
		function() : ( fxHandle )
			{
			if ( IsValid( fxHandle ) )
				EffectStop( fxHandle )
		}
	)

	array<string> tags = [
	"FX_HAND_R",
	"HATCH_PANEL",
	"DAM_R_ARM_UPPER",
	"FX_R_SOCKET",
	"HATCH_BOLT1",
	"DAM_VENT_RIGHT"
	]

	while( 1 )
	{
		int attachID = bt.LookupAttachment( tags.getrandom() )

		StartParticleEffectOnEntity( bt, fx_small, FX_PATTACH_POINT_FOLLOW, attachID )
		EmitSoundOnEntity( bt, "skyway_scripted_tortureroom_bt_orange_spark" )
		wait RandomFloatRange(0.8,1)

		attachID = bt.LookupAttachment( tags.getrandom() )

		StartParticleEffectOnEntity( bt, fx_large, FX_PATTACH_POINT_FOLLOW, attachID )
		EmitSoundOnEntity( bt, "skyway_scripted_tortureroom_bt_orange_spark" )
		wait RandomFloatRange(0.5,0.9)
	}
}

void function WaitForBTTortureTrigger( entity trigger, entity player )
{
	EndSignal( level, "TortureBTAwake" )

	// wait for player to enter
	while ( !trigger.GetTouchingEntities().contains( player ) )
		wait 0.1

	printt( "1" )

	// wait for player to leave
	while ( trigger.GetTouchingEntities().contains( player ) )
		wait 0.1

	printt( "2" )

	wait 4.5 // make the player uncomfortable

	// wait for player to leave
	while ( trigger.GetTouchingEntities().contains( player ) )
		wait 0.1

	printt( "3" )
}

void function PlayerTortureRoomGiveEyeCase( entity bt, entity player, entity scriptRef )
{
	FlagWait( "TorturePlayerGetup" )

	int attachID = bt.LookupAttachment( "EYEGLOW" )
	vector eyePos = bt.GetAttachmentOrigin( attachID )
	vector eyeAng = bt.GetAttachmentAngles( attachID )
	vector fwd = AnglesToForward( eyeAng ) * 16
	entity prop1 = CreatePropDynamic( BARREL, eyePos - <0,0,16> + fwd, <0,0,0>, SOLID_VPHYSICS )
	prop1.SetPusher( true )
	fwd = AnglesToUp( eyeAng ) * 16
	entity prop2 = CreatePropDynamic( BARREL, prop1.GetOrigin() + fwd, <0,0,0>, SOLID_VPHYSICS )
	prop2.SetPusher( true )

	prop1.Hide()
	prop2.Hide()

	bt.NotSolid()
	entity tempCollision = GetEntByScriptName( "bt_tr_collision" )

	float radius = 250

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetRadius( radius )
	trigger.SetAboveHeight( radius ) //Still not quite a sphere, will see if close enough
	trigger.SetBelowHeight( radius )

	vector org = bt.GetAttachmentOrigin( bt.LookupAttachment( "CHESTFOCUS" ) )

	trigger.SetOrigin( org )
	DispatchSpawn( trigger )
	// DebugDrawSphere( org, radius, 255, 0, 0, true, 15.0 )

	delaythread( 20 ) FlagSet( "TortureBTAwake" )

	waitthread WaitForBTTortureTrigger( trigger, player )

	FlagSet( "TortureBTAwake" )

	waitthread PlayDialogue( "BT_Torture_1", bt )

	float startTime = Time()

	// wait for player to enter
	while ( !trigger.GetTouchingEntities().contains( player ) && Time() - startTime < 10 )
		wait 0.1

	wait 0.5

	waitthread PlayDialogue( "BT_Torture_b_1", bt )

	wait 0.5

	waitthread PlayDialogue( "BT_Torture_b_2", bt )

	thread BTEyeCaseDialogue( bt )

	wait 1.25

	FlagSet( "DroppingEyeCase" )
	waitthread PlayAnimTeleport( bt, "BT_torture_cache_drop", scriptRef )
	FlagSet( "DropEyeCase" )
	thread PlayAnimTeleport( bt, "BT_torture_cache_drop_idle", scriptRef )

	prop1.Destroy()
	prop2.Destroy()
	trigger.Destroy()
	tempCollision.Destroy()
}

void function BTEyeCaseDialogue( entity bt )
{
	wait 0.5

	waitthread PlayDialogue( "BT_Torture_b_3", bt )
}

void function FocusOnBTHead( entity bt )
{
	entity player = GetPlayerByIndex( 0 )
	Assert( IsValid( player ), "player is not valid." )
	Signal( level, "StopDOFTracking" )
	thread TrackTargetAttachmentWithDOF( player, bt, "HEADFOCUS" , 0, 128, 1.5 )
}

void function FocusOnBTCockpit( entity bt )
{
	entity player = GetPlayerByIndex( 0 )
	Assert( IsValid( player ), "player is not valid." )
	Signal( level, "StopDOFTracking" )
	thread TrackTargetAttachmentWithDOF( player, bt, "CHESTFOCUS" , 0, 16, 1.5 )
}

void function FocusOnBTRightHand( entity bt )
{
	entity player = GetPlayerByIndex( 0 )
	Assert( IsValid( player ), "player is not valid." )
	Signal( level, "StopDOFTracking" )
	thread TrackTargetAttachmentWithDOF( player, bt, "HAND_R" , 0, 128, 1.5 )
}

void function TortureBTWarnPlayer( entity bt )
{
	foreach ( player in GetPlayerArray() )
		Remote_CallFunction_Replay( player, "ServerCallback_Torture_BT_Transmission" )
}

void function ShowCoreInCockpit( entity bt )
{
	int attachID = bt.LookupAttachment( "SCULPTOR_CORE" )
	vector attachmentOrigin = bt.GetAttachmentOrigin( attachID )

	PlayMusic( "music_skyway_02_btopens" )

	entity coreEnergy = CreateCoreEnergy( attachmentOrigin - <0,0,32> )
	coreEnergy.SetParent( bt, "SCULPTOR_CORE", true, 0.0 )

	file.TRBTCore = coreEnergy

	delaythread( 0.65 ) ShowCoreInCockpitGlow()
}

void function ShowCoreInCockpitGlow()
{
	if ( !file.glowDone )
	{
		foreach ( player in GetPlayerArray() )
		 	Remote_CallFunction_Replay( player, "ServerCallback_GlowFlash", 1, 1 )
		 file.glowDone = true
	}
}

void function DestroyCoreInCockpit( entity bt )
{
	if ( IsValid( file.TRBTCore ) )
		file.TRBTCore.Destroy()
}

void function BliskTortureRoom( entity scriptRef, entity player, string animation = "pt_torture_intro_Blisk" )
{
	//Spawn Blisk
	entity blisk = SpawnBlisk_TortureRoom()
	blisk.SetModel( SW_BLISK_MODEL )
	blisk.NotSolid()

	//Give Wingman Prop
	TakePrimaryWeapon( blisk )

	//Play torture room sequence
	AddAnimEvent( blisk, "draw_knife", BliskDrawKnife )
   	AddAnimEvent( blisk, "sheath_knife", BliskSheathKnife )
  	AddAnimEvent( blisk, "dof_blisk_face", FocusOnBliskFace )
  	AddAnimEvent( blisk, "dof_blisk_gun", FocusOnBliskGun )

  	if ( !Flag( "TorturePlayerResponded" ) )
  	{
  		waitthread PlayAnimTeleport( blisk, "pt_torture_intro_Blisk_beforeQuestion", scriptRef )
  		thread PlayAnim( blisk, "pt_torture_intro_Blisk_idle", scriptRef, null, 3.0 )
  		FlagWait( "TorturePlayerResponded" )
  	}

	entity wingman = CreatePropDynamic( WINGMAN )
	wingman.SetParent( blisk, "propgun", false, 0.0 )
	wingman.Hide()
	delaythread( 3.0 ) _Show( wingman )
	waitthread PlayAnim( blisk, animation, scriptRef, null, 1.0 )

	//replace prop wingman with real wingman
	wingman.Destroy()
	blisk.Destroy()
}

void function _Show( entity ent )
{
	ent.Show()
}

void function BliskDrawKnife( entity blisk )
{
	entity knife = CreatePropDynamic( COMBAT_KNIFE )
	knife.SetParent( blisk, "knife", false, 0.0 )
	file.bliskKnife = knife
	int bodyGroupIndex = blisk.FindBodyGroup( "KNIFE" )
	blisk.SetBodygroup( bodyGroupIndex, 1 )
}

void function BliskSheathKnife( entity blisk )
{
	Assert( IsValid( file.bliskKnife ), "Blisk's knife is not valid." )
	file.bliskKnife.Destroy()
	int bodyGroupIndex = blisk.FindBodyGroup( "KNIFE" )
	blisk.SetBodygroup( bodyGroupIndex, 0 )
}

void function FocusOnBliskFace( entity blisk )
{
	entity player = GetPlayerByIndex( 0 )
	Assert( IsValid( player ), "player is not valid." )
	Signal( level, "StopDOFTracking" )
	thread TrackTargetAttachmentWithDOF( player, blisk, "HEADFOCUS" , 0, 64, .5 )
}

void function FocusOnBliskGun( entity blisk )
{
	entity player = GetPlayerByIndex( 0 )
	Assert( IsValid( player ), "player is not valid." )
	Signal( level, "StopDOFTracking" )
	thread TrackTargetAttachmentWithDOF( player, blisk, "propgun" , 0, 16, .5 )
}

void function SloneTortureRoom( entity scriptRef, entity player )
{
	array<entity> doorsOpen = GetEntArrayByScriptName( "core_doors_open" )
	array<entity> doorsClosed = GetEntArrayByScriptName( "core_doors_closed" )

	foreach ( door in doorsClosed )
	{
		door.Hide()
		door.NotSolid()
	}

	entity slone = SpawnSlone_TortureRoom()
	entity spawner = GetEntByScriptName(  "torture_room_slonePilot" )
	entity slonePilot = spawner.SpawnEntity()
	DispatchSpawn( slonePilot )
	slonePilot.SetModel( SLONE_MODEL )
	slonePilot.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	slonePilot.DisableNPCFlag( NPC_ALLOW_PATROL )

	slone.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	HideName( slone )

	AddAnimEvent( slone, "dof_slone_head", FocusOnSloneHead )
	AddAnimEvent( slone, "slone_grab_core", SloneGrabCore )

	thread PlayAnimTeleport( slone, "mt_torture_intro_slone", scriptRef )

	entity sloneRef = GetEntByScriptName( "tr_slone_ref" )
	entity pos1 = GetEntByScriptName( "tr_slone_ref_pos1" )
	entity pos2 = GetEntByScriptName( "tr_slone_ref_pos2" )

	// wait 0.2

	thread SloneTortureRoomB( scriptRef, player, slone, slonePilot )

	slonePilot.EndSignal( "OnDeath" )

	waitthread PlayAnimTeleport( slonePilot, "pt_torture_intro_slone_beforeQuestion", scriptRef )
	if ( !Flag( "TorturePlayerResponded" ) )
	{
		thread PlayAnimTeleport( slonePilot, "pt_torture_intro_slone_beforeQuestion_idle", scriptRef )
  		FlagWait( "TorturePlayerResponded" )
  	}
	waitthread PlayAnimTeleport( slonePilot, "pt_torture_intro_slone", scriptRef )
}

void function SloneTortureRoomB( entity scriptRef, entity player, entity slone, entity slonePilot )
{
	array<entity> doorsOpen = GetEntArrayByScriptName( "core_doors_open" )
	array<entity> doorsClosed = GetEntArrayByScriptName( "core_doors_closed" )

	FlagWait( "slone_kill_bt" )

	slonePilot.Destroy()

	thread CoreEnergyKillThread( scriptRef )
	waitthread PlayAnimTeleport( slone, "mt_torture_kill_slone", scriptRef )

	FlagSet( "slone_exit_tr" )
	slone.Destroy()

	foreach ( door in doorsClosed )
	{
		door.Show()
		door.Solid()
	}

	foreach ( door in doorsOpen )
	{
		door.Hide()
		door.NotSolid()
	}
}

void function CoreEnergyKillThread( entity scriptRef )
{
	if ( IsValid( file.TRBTCore ) )
		file.TRBTCore.Destroy()
	entity coreEnergy = CreateCoreEnergy( scriptRef.GetOrigin() )
	delaythread(7) PlayLoopFXOnEntity( FX_CORE_GLOW, coreEnergy, "__illumPosition" )
	waitthread PlayAnimTeleport( coreEnergy, "arc_torture_kill", scriptRef )
	coreEnergy.Destroy()
}

void function FocusOnSloneHead( entity slone )
{
	entity player = GetPlayerByIndex( 0 )
	Assert( IsValid( player ), "player is not valid." )
	Signal( level, "StopDOFTracking" )
	thread TrackTargetAttachmentWithDOF( player, slone, "HEADFOCUS" , 0, 196, .25 )
}

void function SloneGrabCore( entity slone )
{
	// int attachID = slone.LookupAttachment( "HAND_L" )
	// vector attachmentOrigin = slone.GetAttachmentOrigin( attachID )

	// file.TRSloneCore = coreEnergy

	// ShowCoreInCockpitGlow()
}

void function HarnessTortureRoom( entity scriptRef, string animation = "harness_torture_intro" )
{
	entity harness = CreatePropDynamic( TORTURE_HARNESS )
	harness.NotSolid()
  	if ( !Flag( "TorturePlayerResponded" ) )
  	{
  		waitthread PlayAnimTeleport( harness, "harness_torture_intro_beforeQuestion", scriptRef )
  		thread PlayAnimTeleport( harness, "harness_torture_intro_beforeQuestion_idle", scriptRef )
  		FlagWait( "TorturePlayerResponded" )
  	}
	waitthread PlayAnimTeleport( harness, animation, scriptRef )
	waitthread PlayAnimTeleport( harness, "harness_torture_kill", scriptRef )
	thread PlayAnimTeleport( harness, "harness_torture_cache_drop_idle", scriptRef )

	FlagWait( "DroppingEyeCase" )

	waitthread PlayAnimTeleport( harness, "harness_torture_cache_drop", scriptRef )

	FlagWait( "PickUpEyeCase" )

	waitthread PlayAnimTeleport( harness, "harness_torture_cache_pickup", scriptRef )

	FlagWait( "TortureRoomDone" )

	harness.Destroy()
}

void function GuardATortureRoom( entity scriptRef, string animation = "pt_torture_intro_guardA" )
{
	entity guardA = SpawnGuardA_TortureRoom()
	guardA.NotSolid()

  	if ( !Flag( "TorturePlayerResponded" ) )
  	{
  		waitthread PlayAnimTeleport( guardA, "pt_torture_intro_guardA_beforeQuestion", scriptRef )
  		thread PlayAnimTeleport( guardA, "pt_torture_intro_guardA_beforeQuestion_idle", scriptRef )
  		FlagWait( "TorturePlayerResponded" )
  	}
	waitthread PlayAnimTeleport( guardA, animation, scriptRef )
	guardA.Destroy()
}

void function GuardBTortureRoom( entity scriptRef, string animation = "pt_torture_intro_guardB" )
{
	entity guardB = SpawnGuardB_TortureRoom()
	guardB.NotSolid()
	if ( !Flag( "TorturePlayerResponded" ) )
  	{
  		waitthread PlayAnimTeleport( guardB, "pt_torture_intro_guardB_beforeQuestion", scriptRef )
  		thread PlayAnimTeleport( guardB, "pt_torture_intro_guardB_beforeQuestion_idle", scriptRef )
  		FlagWait( "TorturePlayerResponded" )
  	}
  	guardB.EndSignal( "OnDeath" )
	waitthread PlayAnimTeleport( guardB, animation, scriptRef )
	guardB.Die()
}

void function MarderTortureRoom( entity sequenceRef )
{
	sequenceRef = GetEntByScriptName( "marder_temp_node" )
	entity marder = SpawnHoloMarder( sequenceRef.GetOrigin(), sequenceRef.GetAngles() )
	thread PlayAnimTeleport( marder, "marder_torture_intro", sequenceRef )
	wait 15.0

	EmitSoundOnEntity( marder, "skyway_scripted_hologram_end" )
	marder.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 0 )
}

void function BlowUpTortureRoom( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )

	WaitSignal( player, "start_fire" )
	FlagSet( "TR_StartBurn" )

	array<entity> fire_triggers = GetEntArrayByScriptName( "fire_trigger" )
	foreach ( trig in fire_triggers )
		thread FireTriggerThink( trig )
	
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_StartPilotCockpitRebootSeq" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 1.0, 3.0, 0 )
		ScreenFadeToBlackForever( player, 2.5 )
	}
	wait 5.0
	FlagSet( "TR_Burn_Stage_Black" )
	level.nv.fireStage = 1

	thread FireSounds()

	TortureFogOn()
	foreach( player in GetPlayerArray() )
		ScreenFadeFromBlack( player, 8.0, 1.0 )
	wait 1.5
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0.0, 1.5, 0 )
	wait 6.0

	FlagSet( "TR_Burn_Stage_1" )
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0.5, 3.0, 0 )
	wait 3.5
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0.0, 3.0, 0 )
	wait 7.0

	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 1.0, 4.0, 0 )
	wait 3.0
	foreach( player in GetPlayerArray() )
		ScreenFadeToBlackForever( player, 3.0 )
	wait 8.5
	foreach( player in GetPlayerArray() )
		player.SetPlayerSettingsWithMods( "civilian_solo_pilot", [] )
	FlagWait( "slone_exit_tr" )
	SetGlobalNetBool( "skywayBurningRoom", true )
	Signal( level, "StopDOFTracking" )
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_SetDOF", 150, 350, 1.5 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_SetBurnColorCorrectionWeight", 0.75, 10 )
	}
	wait 0.5
	array<entity> barrels = GetEntArrayByScriptName( "tr_barrel" )
	foreach ( b in barrels )
	{
		b.Destroy()
	}
	foreach( player in GetPlayerArray() )
		ScreenFadeFromBlack( player, 10.0, 1.0 )
	PlayMusic( "music_skyway_03_fireroom" )
	FlagSet( "TorturePlayerGetup" )
	wait 4.5
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0.0, 4.0, 0 )
	wait 2.5
	FlagSet( "TR_Burn_Stage_2" )
	FlagSet( "TR_Burn_Stage_3" )

	CheckPoint_Silent()
	foreach( player in GetPlayerArray() )
		thread ManageRoomTemp( player )
	FlagWaitClear( "open_torture_room_blast_door" )
	FlagWait( "open_torture_room_blast_door" )
	file.extraDelay += 20.0

	Objective_SetSilent( "#SKYWAY_OBJECTIVE_ESCAPE", <0,0,0> )

	TortureFogOff()
	foreach( player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "ServerCallback_ResetDOF" )
	
	wait 2.0

	StopMusicTrack( "music_skyway_03_fireroom" )
	PlayMusic( "music_skyway_04_smartpistolrun" )
}

void function FireSounds()
{
	array<entity> fireSoundSources = GetEntArrayByScriptName( "fire_sound_source" )

	array<entity> emitters = []

	foreach ( f in fireSoundSources )
	{
		entity ent = CreateScriptMover()
		ent.SetOrigin( f.GetOrigin() )
		string sound = expect string( f.kv.script_sound )
		EmitSoundOnEntity( ent, sound )
		emitters.append( ent )
	}

	FlagWait( "sp_run_outside" )

	foreach ( ent in emitters )
	{
		ent.Destroy()
	}

	foreach ( f in fireSoundSources )
	{
		f.Destroy()
	}
}

void function FireTriggerThink( entity trig )
{
	string flag = expect string( trig.kv.script_flag )

	trig.EndSignal( "OnDestroy" )

	FlagWait( flag )

	while ( 1 )
	{
		table results = trig.WaitSignal( "OnTrigger" )
		entity guy = expect entity( results.activator )
		while ( trig.GetTouchingEntities().contains( guy ) )
		{
			EmitSoundOnEntity( guy, "flesh_fire_damage_1p" )
			guy.TakeDamage( 5, trig, trig, { scriptType = DF_INSTANT, damageSourceId = eDamageSourceId.burn } )
			wait 0.1
		}
		wait 0.1
	}
}

void function ManageRoomTemp( entity player )
{
	EndSignal( level, "LevelStartDone" )

	int heat = 64
	bool killedPlayer = false

	FlagWaitWithTimeout( "PickUpEyeCase", 60.0 )

	if ( Flag( "PickUpEyeCase" ) )
		wait 33.0

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsAlive( player ) )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_ClearRoomTemp" )
			}
		}
	)

	thread FireL2Sounds( player )

	while( 1 )
	{
		float delay = 0.1

		if ( !killedPlayer )
			Remote_CallFunction_NonReplay( player, "ServerCallback_SetRoomTemp", heat++ )

		file.heat = heat

		if ( heat > 70 )
		{
			delay = 0.5
			FlagSet( "TR_Burn_Stage_3" )
		}
		if ( heat > 75 )
		{
			delay = 1.0
			FlagSet( "TR_Burn_Stage_4" )
			level.nv.fireStage = 2
		}
		if ( heat > 80 )
		{
			delay = 2.0
			FlagSet( "TR_Burn_Stage_5" )
		}
		if ( heat > 85 )
		{
			FlagWait( "TortureBTAwake" )
		}
		if ( heat > 90 )
		{
			delay = 5.5
			FlagSet( "TR_Burn_Stage_5" )
			FlagWaitClear( "TR_PauseRoomTemp" )
		}
		if ( heat > 99 && !killedPlayer )
		{
			killedPlayer = true
			PlayerSuffocate( player )
		}

		if ( Flag( "open_torture_room_blast_door" ) )
		{
			delay *= 2.0
		}

		wait delay

		wait file.extraDelay
		file.extraDelay = 0.0
	}
}

void function FireL2Sounds( entity player )
{
	if ( Flag( "LevelStartDone" ) )
		return

	EndSignal( level, "LevelStartDone" )

	array<vector> firePos = [
	< -11834.839844, -6813.757324, 3558.287598 >,
	< -11135.800781, -7109.025391, 3634.662842 >,
	< -11454.696289, -6601.835449, 3632.616943 >,
	]

	OnThreadEnd(
	function() : ( firePos )
		{
			StopSoundAtPosition( firePos[0], "skyway_scripted_tortureroom_aggressivefire_1" )
			StopSoundAtPosition( firePos[1], "skyway_scripted_tortureroom_aggressivefire_2" )
			StopSoundAtPosition( firePos[2], "skyway_scripted_tortureroom_aggressivefire_3" )
		}
	)

	EmitSoundAtPosition( TEAM_ANY, firePos[0], "skyway_scripted_tortureroom_aggressivefire_1" )

	while ( file.heat < 80 )
		wait 0.1

	EmitSoundAtPosition( TEAM_ANY, firePos[1], "skyway_scripted_tortureroom_aggressivefire_2" )

	while ( file.heat < 85 )
		wait 0.1

	EmitSoundAtPosition( TEAM_ANY, firePos[2], "skyway_scripted_tortureroom_aggressivefire_3" )

	FlagWait( "LevelStartDone" )
}

void function PlayerSuffocate( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 1.0, 1.0, 0 )
	wait 2.0
	player.Die()
}

void function ClearBurningRoomBlur( entity player )
{
	array<entity> fire_triggers = GetEntArrayByScriptName( "fire_trigger" )
	foreach ( trig in fire_triggers )
		trig.Destroy()

	// Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0, 3, 0 )
	Remote_CallFunction_NonReplay( player, "ServerCallback_SetBurnColorCorrectionWeight", 0.0, 2 )
	SetGlobalNetBool( "skywayBurningRoom", false )

	wait RandomFloatRange( 2, 3 )

	Remote_CallFunction_NonReplay( player, "ServerCallback_StopPilotCockpitRebootSeq"  )
	float weight = StatusEffect_Get( player, eStatusEffect.emp )
	StatusEffect_Stop( player, file.statusEffect )
	StatusEffect_AddTimed( player, eStatusEffect.emp, weight, 2.0, 2.0 )
}

void function WaitForBliskExit( entity blisk )
{
	Assert( IsNewThread(), "Must be threaded off." )

	blisk.ClearEnemyMemory()
	blisk.ClearEnemy()
	blisk.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )

	NpcMoveToMark( blisk, GetEntByScriptName( "tr_blisk_leave_mark" ) )
	WaitSignal( blisk, "OnFinishedAssault"  )
	blisk.Destroy()
}

entity function SpawnSlone_TortureRoom()
{
	entity spawner = GetEntByScriptName(  "torture_room_slone" )
	entity slone = spawner.SpawnEntity()
	DispatchSpawn( slone )
	slone.SetNoTarget( true )
	slone.SetInvulnerable()
	return slone
}

void function ConfigureSloneAIForGrateHuntSequence( entity slone )
{
	slone.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
}

entity function SpawnBlisk_TortureRoom()
{
	entity spawner = GetEntByScriptName(  "torture_room_blisk" )
	entity blisk = spawner.SpawnEntity()
	DispatchSpawn( blisk )
	blisk.SetNoTarget( true )
	blisk.SetInvulnerable()
	return blisk
}

void function ConfigureBliskAIForGrateHuntSequence( entity blisk )
{
	//blisk.EnableNPCFlag( NPC_DISABLE_SENSING )
	blisk.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )
	blisk.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
	MakeInvincible( blisk )
}

entity function SpawnGuardA_TortureRoom()
{
	entity spawner = GetEntByScriptName(  "torture_room_guard_A" )
	entity guardA = spawner.SpawnEntity()
	DispatchSpawn( guardA )
	guardA.SetNoTarget( true )
	guardA.SetInvulnerable()
	return guardA
}

entity function SpawnGuardB_TortureRoom()
{
	entity spawner = GetEntByScriptName(  "torture_room_guard_B" )
	entity guardB = spawner.SpawnEntity()
	DispatchSpawn( guardB )
	guardB.SetNoTarget( true )
	guardB.SetInvulnerable()
	return guardB
}

void function ViewConeRestrained( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -25 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -20 )
	player.PlayerCone_SetMaxPitch( 20 )
}

void function Init_BTEyeCase( entity player, entity scriptRef )
{
	entity panel = GetEntByScriptName( "tr_door_pannel" )
	Highlight_ClearNeutralHighlight( panel )

	FlagWait( "DropEyeCase" )

	entity bt =  player.GetPetTitan()
	// entity bt = GetEntByScriptName( "torture_room_BT" )

	int attachID = bt.LookupAttachment( "EYEGLOW" )
	vector caseOrigin = bt.GetAttachmentOrigin( attachID )
	vector caseAngles = bt.GetAttachmentAngles( attachID )

	entity eyeButton = CreatePropDynamic( SMALL_ROCK_01, caseOrigin, caseAngles, 2, -1 )
	eyeButton.Hide()
	eyeButton.SetUsable()
	eyeButton.SetUsableByGroup( "pilot" )
	eyeButton.SetUsePrompts( "#SKYWAY_HINT_INSPECT_EYE" , "#SKYWAY_HINT_INSPECT_EYE_PC" )
	entity eyecase = CreatePropDynamic( BT_EYE_CASE_MODEL )
	thread PlayAnimTeleport( eyecase, "bt_eye_torture_cache_pickup_idle", scriptRef )
	Highlight_SetNeutralHighlight( eyecase, "interact_object_always_far" )
	
	
	player = expect entity( eyeButton.WaitSignal( "OnPlayerUse" ).player ) 

	Highlight_ClearNeutralHighlight( eyecase )
	eyeButton.Destroy()
	FlagSet( "PickUpEyeCase" )

	player.SetNoTarget( true )
	player.DisableWeapon()
	player.SetInvulnerable()
	player.ContextAction_SetBusy()

	//Eye Case Pickup
	entity moverPickup = CreateOwnedScriptMover( scriptRef ) //need a mover for first person sequence

	entity dataKnife = CreatePropDynamic( DATA_KNIFE_MODEL )
	entity smartPistol = CreatePropDynamic( SMART_PISTOL_MODEL )
	smartPistol.SetSkin( 2 )

	FirstPersonSequenceStruct sequenceTortureRoomPickup
	sequenceTortureRoomPickup.blendTime = 1.0
	sequenceTortureRoomPickup.attachment = "ref"
	sequenceTortureRoomPickup.firstPersonAnim = "ptpov_torture_cache_pickup"
	sequenceTortureRoomPickup.thirdPersonAnim = "pt_torture_cache_pickup"
	sequenceTortureRoomPickup.viewConeFunction = ViewConeRestrained

	dataKnife.SetParent( eyecase, "R_ATTACH_SIDE", false, 0.0 )
	smartPistol.SetParent( eyecase, "L_ATTACH_SIDE", false, 0.0 )
	thread PlayAnimTeleport( eyecase, "bt_eye_torture_cache_pickup", moverPickup )
	// thread PlayAnimTeleport( dataKnife, "data_knife_torture_cache_pickup", moverPickup )
	// thread PlayAnimTeleport( smartPistol, "w_p2011sp_torture_cache_pickup", moverPickup )
	FlagSet( "TR_PauseRoomTemp" )
	delaythread( 4.5 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 1 )
	delaythread( 5.75 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 0 )
	delaythread( 23.1 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 1 )
	delaythread( 23.6 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 1 )
	delaythread( 23.9 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 1 )
	delaythread( 26.5 ) Remote_CallFunction_NonReplay( player, "ServerCallback_SetNearDOF", 1, 6, 0.2 )
	delaythread( 26.5 ) Remote_CallFunction_NonReplay( player, "ServerCallback_SetDOF", 15, 25, 0.2 )
	delaythread( 29.0 ) Remote_CallFunction_NonReplay( player, "ServerCallback_SetDOF", 150, 350, 1.5 )
	waitthread FirstPersonSequence( sequenceTortureRoomPickup, player, moverPickup )
	file.extraDelay += 20.0
	FlagClear( "TR_PauseRoomTemp" )

	GivePlayerEyeCache( player )

	player.ClearInvulnerable()
	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	
	foreach( p in GetPlayerArray() )
		p.EnableWeaponWithSlowDeploy()
	player.SetNoTarget( false )

	eyecase.Destroy()
	dataKnife.Destroy()
	smartPistol.Destroy()

	Highlight_SetNeutralHighlight( panel, "interact_object_always" )
}

void function GivePlayerEyeCache( entity player )
{
	array<string> mods = [ "og_pilot", "pas_fast_reload" ]

	foreach( player in GetPlayerArray() )
	{
		TakeAllWeapons( player )
		player.GiveWeapon( "mp_weapon_smart_pistol_og", mods )
		player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE )

		entity smartPistol = player.GetMainWeapons()[0]
		smartPistol.SetWeaponSkin( 2 )
	}

	FlagSet( "TRDoorHackable" )
}

void function OnOuterRingTrigEnter( entity trigger, entity ent )
{
	if ( !Flag( "RingWooshEnabled" ) )
		return

	EmitSoundOnEntity( trigger.GetParent(), "skyway_emit_foldweapon_outerring_passby" )
}

void function OnMidRingTrigEnter( entity trigger, entity ent )
{
	if ( !Flag( "RingWooshEnabled" ) )
		return

	EmitSoundOnEntity( trigger.GetParent(), "skyway_emit_foldweapon_2nd_ring_passby" )
}

void function StartRingRotation()
{
	entity outer = GetEntByScriptName( "outer_ring_mover" )
	entity middle = GetEntByScriptName( "middle_ring_mover" )
	entity inner = GetEntByScriptName( "inner_ring_mover" )

	outer.SetPusher( false )
	middle.SetPusher( false )
	inner.SetPusher( false )

	array<entity> ents = GetEntArrayByScriptName( "outer_ring_sound_trig" )
	foreach ( ent in ents )
	{
		entity ringMoverOuter = ent.GetLinkEnt()
		ringMoverOuter = CreateScriptMover( ringMoverOuter.GetOrigin(), <0,0,0> )
		ringMoverOuter.SetParent( outer )
		ent.SetParent( ringMoverOuter )
		ent.SetEnterCallback( OnOuterRingTrigEnter )
	}

	ents = GetEntArrayByScriptName( "mid_ring_sound_trig" )
	foreach ( ent in ents )
	{
		entity ringMover = ent.GetLinkEnt()
		ringMover = CreateScriptMover( ringMover.GetOrigin(), <0,0,0> )
		ringMover.SetParent( middle )
		ent.SetParent( ringMover )
		ent.SetEnterCallback( OnMidRingTrigEnter )
	}

	inner.SetParent( middle, "", true )
	inner.NonPhysicsSetRotateModeLocal( true )
	middle.SetParent( outer, "", true )
	middle.NonPhysicsSetRotateModeLocal( true )

	vector outerAngles = outer.GetAngles()
	vector middleAngles = middle.GetLocalAngles()
	vector innerAngles = inner.GetLocalAngles()

	vector outerForward = AnglesToForward( outerAngles )
	vector middleForward = AnglesToUp( middleAngles )
	vector innerForward = AnglesToRight( innerAngles )

	//outer.NonPhysicsRotate( outerForward, 75 )
	//middle.NonPhysicsRotate( middleForward, -85 )
	//inner.NonPhysicsRotate( innerForward, 95 )

	outer.NonPhysicsRotate( outerForward, 25 )
	middle.NonPhysicsRotate( middleForward, -28 )
	inner.NonPhysicsRotate( innerForward, 31 )
}

entity function CreateCoreEnergy( vector origin )
{
	entity coreEnergy = CreatePropDynamic( CORE_ENERGY, origin )
	// PlayLoopFXOnEntity( FX_CORE_FLARE, coreEnergy )

	return coreEnergy
}

void function SP_TortureRoomThread( entity player )
{
	FlagClear( "DeathHintsEnabled" )
	Embark_Disallow( player )
	entity sequenceRef = GetEntByScriptName( "tr_sequence_ref" )
	
	thread BlowUpTortureRoom( player )
	thread Init_BTEyeCase( player, sequenceRef )

	FlagWait( "slone_exit_tr" )
	FlagClear( "open_torture_room_blast_door" )
	FlagWait( "LevelStartDone" )
	Embark_Allow( player )
	foreach( player in GetPlayerArray() )
		thread ClearBurningRoomBlur( player )
	FlagSet( "DeathHintsEnabled" )
}

void function TortureRoomSkipped( entity player )
{
	NextState()
}

void function TortureRoomSetup( entity player )
{
	level.nv.coreSoundActive = 0

	TakeAllWeapons( player )
	FlagSet( "TorturePlayerResponded" )

	entity sequenceRef = GetEntByScriptName( "tr_sequence_ref" )
	thread SloneTortureRoom( sequenceRef, player )

	thread PlayerTortureRoom( sequenceRef, player, "pov_torture_intro_player_2ndhalfonly", "pt_torture_intro_player_2ndhalfonly" )
	thread BliskTortureRoom( sequenceRef, player, "pt_torture_intro_Blisk_2ndhalfonly" )
	thread HarnessTortureRoom( sequenceRef, "harness_torture_intro_2ndhalfonly" )
	thread GuardATortureRoom( sequenceRef, "pt_torture_intro_guardA_2ndhalfonly" )
	thread GuardBTortureRoom( sequenceRef, "pt_torture_intro_guardB_2ndhalfonly" )
	thread BTTortureRoom( sequenceRef, player, "BT_torture_intro_2ndhalfonly" )

	FlagClear( "WeaponDropsAllowed" )
}

/*
   _____                      _       _____ _     _        _     _____
  / ____|                    | |     |  __ (_)   | |      | |   |  __ \
 | (___  _ __ ___   __ _ _ __| |_    | |__) | ___| |_ ___ | |   | |__) |   _ _ __
  \___ \| '_ ` _ \ / _` | '__| __|   |  ___/ / __| __/ _ \| |   |  _  / | | | '_ \
  ____) | | | | | | (_| | |  | |_    | |   | \__ \ || (_) | |   | | \ \ |_| | | | |
 |_____/|_| |_| |_|\__,_|_|   \__|   |_|   |_|___/\__\___/|_|   |_|  \_\__,_|_| |_|
*/

void function SmartPistolRunStartPointSetup( entity player )
{
	FlagClear( "WeaponDropsAllowed" )
	TeleportPlayers( GetEntByScriptName( "smart_pistol_run" ) )

	PlayMusic( "music_skyway_04_smartpistolrun" )

	player.ReplaceActiveWeapon( "mp_weapon_smart_pistol_og" )
	player.GetMainWeapons()[0].SetMods( [ "og_pilot", "pas_fast_reload" ] )
	player.GetMainWeapons()[0].SetWeaponSkin( 2 )
}

void function SmartPistolRunSkipped( entity player )
{
	//FlagSet( "lower_widow_01" )
	FlagSet( "sp_run_vista_titan_hill" )
	thread StratonHornetDogfights()
	thread DropshipTakeOffs()
}

void function SP_SmartPistolRunThread( entity player )
{
	FlagClear( "open_torture_room_blast_door" )
	entity tr_door = GetEntByScriptName( "tr_door" )
	tr_door.SetSkin( 1 )

	thread StratonHornetDogfights()
	thread SP_Run_Dialogue( player )
	thread RandomRumbles( player )
	thread DropshipTakeOffs()
	thread FireVistaGun()
	thread DroneLaunch()
	thread FleetWarp()

	level.nv.coreSoundActive = 1

	FlagWait( "SmartPistolRunDone" )
}

void function FleetWarp()
{
	FlagWait( "sp_run_vista_titan_hill" )
	entity src = GetEntByScriptName( "warp_sound_source" )
	EmitSoundAtPosition( TEAM_ANY, src.GetOrigin(), "skyway_scripted_distantfleet_warp_in" )
}

void function DroneLaunch()
{
	entity trigger = GetEntByScriptName( "drone_launch_trigger" )
	trigger.WaitSignal( "OnTrigger" )

	array<entity> drones = trigger.GetLinkEntArray()

	foreach ( d in drones )
	{
		thread DroneLaunchThink( d )
	}
}

void function DroneLaunchThink( entity droneProp )
{
	entity target = droneProp.GetLinkEnt()

	droneProp.SetAngles( droneProp.GetAngles() )

	thread PlayAnim( droneProp, "dr_activate_drone_idle", droneProp )

	wait float( droneProp.kv.script_delay )

	waitthread PlayAnim( droneProp, "dr_activate_drone_fast", droneProp )

	entity drone = CreateGenericDrone( TEAM_IMC, droneProp.GetOrigin(), droneProp.GetAngles() )
	SetSpawnOption_AISettings( drone, "npc_drone_plasma" )
	DispatchSpawn( drone )
	droneProp.Hide()
	droneProp.NotSolid()

	target = target.GetLinkEnt()

	drone.EndSignal( "OnDeath" )
	drone.SetThinkEveryFrame( true )

	waitthread AssaultMoveTarget( drone, target )

	if ( IsAlive( drone ) )
		drone.Die()

	droneProp.Destroy()
}

void function FireVistaGun()
{
	// entity trigger = GetEntByScriptName( "sp_run_outside_turn" )
	// trigger.WaitSignal( "OnTrigger" )
	FlagWait( "sp_run_outside" )
	level.nv.fireStage = 0
	waitthread StartFireSequence( file.gunBattery06, null )
	delaythread(1) StartFireSequence( file.gunBattery01, null )
	thread FireGunAtArrayOfTargets( file.gunBattery06, GetEntArrayByScriptName( "gun_6_targets" ) )
}

void function SP_Run_Dialogue( entity player )
{
	thread SP_Run_Dialogue_2( player )

	EndSignal( level, "sp_run_outside" )

	// wait 0.5
	// waitthread PlayDialogue( "SP_RUN_RADIO_1", player )
	wait 0.5
	waitthread PlayDialogue( "SP_RUN_RADIO_2", player )
	wait 0.5
	waitthread PlayDialogue( "SP_RUN_RADIO_3", player )
	wait 0.15
	waitthread PlayDialogue( "SP_RUN_RADIO_4", player )
	wait 0.5
	// waitthread PlayDialogue( "SP_RUN_RADIO_5", player )
	wait 0.5
	waitthread PlayDialogue( "SP_RUN_RADIO_6", player )
	wait 0.5
	waitthread PlayDialogue( "SP_RUN_RADIO_7", player )
	wait 0.5
	waitthread PlayDialogue( "SP_RUN_RADIO_8", player )
	wait 3.5
	waitthread PlayDialogue( "SP_RUN_RADIO_9", player )
	wait 3.5
	waitthread PlayDialogue( "SP_RUN_RADIO_10", player )
}

void function SP_Run_Dialogue_2( entity player )
{
	FlagWait( "sp_run_outside" )
	PlayMusic( "music_skyway_05_arcfolddrones" )

	FlagWait( "sp_run_vista_titan_hill" ) //wait 2.0
	waitthread PlayDialogue( "SP_RUN_RADIO_11", player )
	wait 0.15
	//delaythread( 2 ) Objective_Set( "#SKYWAY_OBJECTIVE_REACH_BRIDGE", GetEntByScriptName("bridge_objective").GetOrigin() )
	waitthread PlayDialogue( "SP_RUN_RADIO_12", player )

	wait 0.25
	waitthread PlayDialogue( "SP_RUN_RADIO_13", player )
	wait 0.15
	waitthread PlayDialogue( "SP_RUN_RADIO_14", player )
	wait 0.15
	waitthread PlayDialogue( "SP_RUN_RADIO_15", player )

	FlagWait( "sp_run_garage" )
	PlayMusic( "music_skyway_06_smartpistolrun02" )

	FlagWait( "sp_run_wallruns" )
	wait 0.15
	waitthread PlayDialogue( "SP_RUN_RADIO_16", player )
	wait 0.15
	waitthread PlayDialogue( "SP_RUN_RADIO_17", player )
	wait 0.25
	waitthread PlayDialogue( "SP_RUN_RADIO_18", player )

	FlagWait( "sp_run_silent_hall" )
	wait 0.15
	waitthread PlayDialogue( "SP_RUN_RADIO_19", player )
	wait 0.25
	waitthread PlayDialogue( "SP_RUN_RADIO_20", player )
}

void function DropshipTakeOffs()
{
	array<entity> triggers = GetEntArrayByScriptName( "dropship_launch_trigger" )
	foreach ( t in triggers )
	{
		thread DropshipLaunchTriggerThink( t )
	}
}

void function DropshipLaunchTriggerThink( entity trigger )
{
	trigger.WaitSignal( "OnTrigger" )

	array<entity> nodes = trigger.GetLinkEntArray()
	foreach ( node in nodes )
	{
		thread CreateDrophipAndLaunch( node )
	}
}

void function CreateDrophipAndLaunch( entity node )
{
	EndSignal( level, "TitanHillDone" )

	string modelRef = "dropship"
	if ( node.HasKey( "script_noteworthy" ) )
	{
		modelRef = expect string( node.kv.script_noteworthy )
	}

	table<string,asset> refs = {}
	refs[ "dropship" ] <- DROPSHIP_MODEL
	refs[ "straton" ] <- STRATON_MODEL
	refs[ "straton_sb" ] <- STRATON_SB_MODEL

	bool loop = false
	float delayMin = 0.0
	float delayMax = 0.0
	if ( node.HasKey( "script_loop" ) )
	{
		loop = (node.kv.script_loop == "1")
		delayMin = float( node.kv.script_delay_min )
		delayMax = float( node.kv.script_delay_max )
		svGlobal.levelEnt.EndSignal( "StopFlybys" )
	}

	entity dropship = CreatePropDynamic( refs[ modelRef ] )

	OnThreadEnd(
	function() : ( dropship )
		{
			dropship.Hide()
		}
	)

	while( 1 )
	{
		string animation = string( node.kv.leveled_animation )

		AnimRefPoint info = GetAnimStartInfo( dropship, animation, node )
		dropship.SetOrigin( info.origin )
		dropship.SetAngles( info.angles )
		dropship.DisableHibernation()

		float delay = RandomFloatRange( 1, 2 )

		if ( node.HasKey( "script_delay" ) )
			delay = float( node.kv.script_delay )

		wait delay

		if ( node.HasKey( "script_sound" ) )
		{
			string sound = expect string( node.kv.script_sound )
			float sounddelay = float( node.kv.script_sound_delay )
			delaythread( sounddelay ) EmitSoundOnEntity( dropship, sound )
		}

		waitthread PlayAnim( dropship, animation, node )

		dropship.Hide()

		if ( loop )
		{
			wait RandomFloatRange( delayMax, delayMax )
			dropship.Show()
		}
		else
		{
			break
		}
	}
}

void function WarpShips( string arrayName, string flagName )
{
	array<entity> ships = GetEntArrayByScriptName( arrayName )
	foreach( s in ships )
	{
		thread WarpInShipOnFlag( s, flagName )
	}
}

void function WarpInShipOnFlag( entity ship, string flagName )
{
	ship.EndSignal( "OnDestroy" )
	ship.Hide()
	FlagWait( flagName )
	ship.DisableHibernation()
	EmitSoundOnEntity( ship, "AngelCity_Scr_MegaCarrierWarpIn" )
	if ( ship.HasKey( "script_delay" ) )
		wait ( float( ship.kv.script_delay ) )
	else
		wait RandomFloatRange( 0, 2 )
	waitthread CarrierWarpinEffect( ship.GetOrigin(), ship.GetAngles() )
	ship.Show()
	ship.EnableHibernation()
	thread BeginFlak( ship )
	thread BeginShipFire( ship.GetLinkEntArray(), ship )

	FlagWait( "TitanSmashHallwayDone" )
	ship.Destroy()
}

void function BeginShipFire( array<entity> guns, entity ship = null )
{
	if ( guns.len() == 0 )
		return

	EndSignal( level, "TitanHillDone" )
	if ( IsValid( ship ) )
		ship.EndSignal( "OnDestroy" )

	while ( 1 )
	{
		int burstcount = RandomIntRange( 1, 5 )
		guns.randomize()

		for ( int i=0; i<burstcount && i<guns.len(); i++ )
		{
			entity gun = guns[i]

			vector angles = gun.GetAngles() + < RandomFloatRange( -10,10 ), RandomFloatRange( -10,10 ), 0 >

			StartParticleEffectInWorld( GetParticleSystemIndex( SKYBOX_TRACER ), gun.GetOrigin(), angles )

			wait RandomFloatRange( 0.0, 0.1 )
		}

		wait RandomFloatRange( 0.1, 0.2 )
	}
}

void function BeginFlak( entity ship )
{
	EndSignal( level, "TitanHillDone" )
	ship.EndSignal( "OnDestroy" )

	int fxID = GetParticleSystemIndex( FLAK_FX )

	int maxBurst = RandomIntRange( 4, 6 )
	int count = 0

	while ( 1 )
	{
		vector origin = ship.GetOrigin()
		vector newVec = origin + RandomVec( RandomFloatRange( 2000, 5000 ) )

		StartParticleEffectInWorld( fxID, newVec, Vector( 0, RandomFloat( 360.0 ), 0 ) )
		count++

		if ( count < maxBurst )
		{
			wait RandomFloatRange( 0.8, 1.3 )
		}
		else
		{
			wait RandomFloatRange( 0.1, 0.2 )
			maxBurst = RandomIntRange( 6, 9 )
			count = 0
		}
	}
}

void function CarrierWarpinEffect( vector origin, vector angles )
{
	float time = 0.6

	float totalTime = 2.0
	float preWait = 0

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "dropship_warpin" )
	wait ( totalTime - preWait )
	entity fx = PlayFX( $"veh_carrier_warp_full", origin, angles )
	fx.DisableHibernation()
	fx.FXEnableRenderAlways()

	wait time
	wait 0.16
}

void function RandomRumbles( entity player )
{
	EndSignal( level, "BridgeFightDone" )

	while ( 1 )
	{
		wait RandomFloatRange( 3.0, 8.0 )
		waitthread DoWorldRumble( player )
	}
}

void function DoWorldRumble( entity player )
{
	svGlobal.levelEnt.Signal( "DoWorldRumble" )
	svGlobal.levelEnt.EndSignal( "DoWorldRumble" )

	if ( !Flag( "sp_world_rumble_enabled" ) )
		return

	FlagSet( "sp_run_rocks_heavy" )

	Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", RandomFloatRange(1.0,2.0), 10, RandomFloatRange(1,4) )
	EmitSoundOnEntity( player, SFX_WORLD_RUMBLE_DISTANT )

	wait 1.0

	FlagClear( "sp_run_rocks_heavy" )
}

/*
  ____       _     _              ______ _       _     _
 |  _ \     (_)   | |            |  ____(_)     | |   | |
 | |_) |_ __ _  __| | __ _  ___  | |__   _  __ _| |__ | |_
 |  _ <| '__| |/ _` |/ _` |/ _ \ |  __| | |/ _` | '_ \| __|
 | |_) | |  | | (_| | (_| |  __/ | |    | | (_| | | | | |_
 |____/|_|  |_|\__,_|\__, |\___| |_|    |_|\__, |_| |_|\__|
                      __/ |                 __/ |
                     |___/                 |___/
*/

void function SP_BridgeFightThread( entity player )
{
	array<entity> ships = GetEntArrayByScriptName( "vista_warp" )
	foreach( ship in ships )
	{
		// ship.Destroy()
	}

	thread StartFireSequence( file.gunBattery06, null )

	FlagWait( "BridgeFightDone" )
}

void function BridgeFightStartPointSetup( entity player )
{
	FlagClear( "WeaponDropsAllowed" )
	TeleportPlayers( GetEntByScriptName( "bridge_fight" ) )
}

void function BridgeFightSkipped( entity player )
{
	array<entity> ships = GetEntArrayByScriptName( "vista_warp" )
	foreach( ship in ships )
	{
		// ship.Destroy()
	}
}

/*
  ____ _______     _____                  _
 |  _ \__   __|   |  __ \                (_)
 | |_) | | |      | |__) |___ _   _ _ __  _  ___  _ __
 |  _ <  | |      |  _  // _ \ | | | '_ \| |/ _ \| '_ \
 | |_) | | |      | | \ \  __/ |_| | | | | | (_) | | | |
 |____/  |_|      |_|  \_\___|\__,_|_| |_|_|\___/|_| |_|

*/

void function SP_BTReunionThread( entity player )
{
	Objective_Set( "#SKYWAY_OBJECTIVE_CALL_IN_TITAN", GetEntByScriptName("bt_titanfall_ref").GetOrigin() )

	//Assemble Hill Guns and Spawn Movers needed to control them.
	thread TitanHillBackupTriggerThink( player )
	InitBombardment()
	OverrideCockpitLightFX( $"P_bt_cockpit_dlight_skyway" )

	TriggerSilentCheckPoint( <3869, -6032, 3320>, true )

	//Pack info targets of the following names into a targeting array for each gun.
	array<entity> targets_01 = PackTargets( ["gb1_target_01", "gb1_target_02", "gb1_target_03"] )
	array<entity> targets_02 = PackTargets( ["gb2_target_01", "gb2_target_02", "gb2_target_03"] )
	array<entity> targets_03 = PackTargets( ["gb3_target_01", "gb3_target_02", "gb3_target_03"] )
	array<entity> targets_04 = PackTargets( ["gb4_target_01", "gb4_target_02", "gb4_target_03"] )

	waitthread PlayerRequestsTitan( player )

	thread PlayDialogue( "SARAH_RADIO_HOTDROP", player )

	entity sequenceRef = GetEntByScriptName( "bt_titanfall_ref" )
	vector origin = sequenceRef.GetOrigin()

	FlagSet( "TitanDeathPenalityDisabled")
	

	CreatePetTitan( player, origin, sequenceRef.GetAngles() )
	
	if ( !IsValid( player.GetPetTitan() ) )
	{
		RestartMapWithDelay()
		return
	}

	entity bt = player.GetPetTitan()

	foreach( entity p in GetPlayerArray() )
	{
		entity titan = player.GetPetTitan()
		if ( !IsValid( titan ) )
			continue

		titan.GetMainWeapons()[0].SetMods( [ "LongRangeAmmo" ] )
		titan.GetOffhandWeapon(OFFHAND_ORDNANCE).SetMods( [ "power_shot_ranged_mode" ] )
		titan.GetOffhandWeapon(OFFHAND_ANTIRODEO).SetMods( [ "ammo_swap_ranged_mode" ] )
		titan.SetTitle( "#NPC_BT_SPARE_NAME" )
		titan.SetSkin( 2 )
		titan.SetInvulnerable()
	}

	float impactTime = GetHotDropImpactTime( bt, "bt_hotdrop_skyway" )

	Attachment result = bt.Anim_GetAttachmentAtTime( "bt_hotdrop_skyway", "OFFSET", impactTime )
	vector maxs = bt.GetBoundingMaxs()
	vector mins = bt.GetBoundingMins()
	int mask = bt.GetPhysicsSolidMask()
	origin = ModifyOriginForDrop( origin, mins, maxs, result.position, mask )
	sequenceRef.SetOrigin( origin )

	thread Init_BTInsertEye( player )
	Embark_Disallow( player )

	svGlobal.bubbleShieldEnabled = false

	player.SetHotDropImpactDelay( impactTime )
	Remote_CallFunction_Replay( player, "ServerCallback_ReplacementTitanSpawnpoint", origin.x, origin.y, origin.z, Time() + impactTime )

	delaythread( impactTime - 1.0 ) StopMusicTrack( "music_skyway_04_smartpistolrun" )
	delaythread( impactTime - 1.0 ) PlayMusic( "music_skyway_07_calltitan" )
	FlagSet( "AcceptEye" )
	
	// foreach( entity p in GetPlayerArray() )
	// {
	// 	UnlockAchievement( p, achievements.NEW_BT )
	// 	if ( p != player && IsValid( player.GetPetTitan() ) )
	// 		thread PlayersTitanHotdrops( player.GetPetTitan(), sequenceRef.GetOrigin(), sequenceRef.GetAngles(), p, "bt_hotdrop_skyway" )
	// }
	waitthread PlayersTitanHotdrops( bt, sequenceRef.GetOrigin(), sequenceRef.GetAngles(), player, "bt_hotdrop_skyway" )
	
	TriggerSilentCheckPoint( sequenceRef.GetOrigin(), false )

	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			CreatePetTitanAtOriginWithTf( p, origin, sequenceRef.GetAngles() )
	}

	FlagClear( "TitanDeathPenalityDisabled")
	svGlobal.bubbleShieldEnabled = true

	NextState()

	thread PlayAnim( bt, "BT_reunion_idle", bt )
	player.SetPetTitan( bt )
	bt.DisableHibernation()

	FlagWait( "EyeInserted" )
	player.SetPlayerNetBool( "shouldShowWeaponFlyout", false )

	bt.SetTitle( "#NPC_BT_NAME" )
	bt.ClearInvulnerable()

	//Each gun should loop through its target array and fire at each of its targets.
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery01, targets_01 )
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery02, targets_02 )
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery03, targets_03 )
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery04, targets_04 )

	FlagWait( "BTStoodUp" )
	FlagWait( "BTReunionDone" )

	player.SetPlayerNetBool( "shouldShowWeaponFlyout", true )
	Embark_Allow( player )
	Objective_Clear()

	if ( IsValid( bt ) )
	{
		bt.Anim_Stop()
		CockpitLightStop( bt )
	}
	
	SPTitanLoadout_UnlockLoadout( player, "mp_titanweapon_predator_cannon" )
}

void function TitanHillBackupTriggerThink( entity player )
{
	EndSignal( level, "EyeInserted" )

	entity trigger = GetEntByScriptName( "titan_hill_volume" )

	float waittime = 3.0

	while ( 1 )
	{
		WaitSignal( trigger, "OnTrigger" )
		wait waittime
		array<entity> touchingEnts = trigger.GetTouchingEntities()
		if ( touchingEnts.contains( player ) )
		{
			player.TakeDamage( 50, null, null, { damageSourceId=damagedef_suicide, scriptType = DF_SKIP_DAMAGE_PROT } )
		}
		waittime = max( 1.0, waittime - 0.5 )
	}
}

void function BT_Reunion_Embark( entity player, entity bt )
{
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.5
	sequence.attachment = "REF"
	sequence.firstPersonAnim = "ptpov_skyway_reunion_embark"
	sequence.thirdPersonAnim = "pt_skyway_reunion_embark"
	// sequence.thirdPersonCameraAttachments = [ "VDU" ]
	// sequence.useAnimatedRefAttachment = true
	sequence.viewConeFunction = ViewConeTight

	player.DisableWeapon()
	thread PlayAnim( bt, "bt_skyway_reunion_embark", bt )
	bt.Anim_AdvanceCycleEveryFrame( true )

	float animDuration = player.GetSequenceDuration( sequence.thirdPersonAnim ) - 0.3
	thread Embark_DelayedFadeOut( player, bt, animDuration )

	waitthread FirstPersonSequence( sequence, player, bt )
	CockpitLightStop( bt )
	player.EnableWeapon()
	ForceScriptedEmbark( player, bt )
	bt.Destroy()
}

void function ConvoCallback_BTReunion( int choice )
{
	printt( "BT_Returns_ChoiceMade", choice )
	table e
	e.choice <- choice
	Signal( svGlobal.levelEnt, "BT_Returns_ChoiceMade", e )
}


void function PlayerRequestsTitan( entity player )
{
	thread PlayDialogue( "SARAH_RADIO_HOTDROP_1", player )
	
	// TODO: not a todo but should this be for everyone?
	Remote_CallFunction_NonReplay( player, "ServerCallback_ShowTitanfallHint" )

	svGlobal.levelEnt.EndSignal( "ClientCommand_RequestTitanFake" )

	wait 10.0
	waitthread PlayDialogue( "SARAH_RADIO_HOTDROP_2", player )

	wait 10.0
	waitthread PlayDialogue( "SARAH_RADIO_HOTDROP_3", player )

	WaitForever()
}

void function BTReunionStartPointSetup( entity player )
{
	FlagClear( "WeaponDropsAllowed" )
	TeleportPlayers( GetEntByScriptName( "bt_reunion" ) )
}

void function BTReunionSkipped( entity player )
{
	NextState()

	entity sequenceRef = GetEntByScriptName( "bt_titanfall_ref" )
	CreatePetTitan( player, sequenceRef.GetOrigin(), sequenceRef.GetAngles() )
}

void function Init_BTInsertEye( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )

	FlagWait( "AcceptEye" )
	entity sequenceRef = GetEntByScriptName( "bt_titanfall_ref" )

	entity bt = player.GetPetTitan()
	Highlight_ClearOwnedHighlight( bt )
	entity mover = CreateScriptMover()

	float impactTime = GetHotDropImpactTime( bt, "bt_hotdrop_skyway" )
	mover.SetOrigin( sequenceRef.GetOrigin() )
	mover.SetAngles( sequenceRef.GetAngles() )
	entity eyecase = CreatePropDynamic( BT_EYE_CASE_MODEL )
	waitthread PlayAnimTeleport( eyecase, "bt_eye_skyway_hotdrop", mover )
	mover.SetOrigin( bt.GetOrigin() )
	mover.SetAngles( bt.GetAngles() )
	thread PlayAnimTeleport( eyecase, "bt_eye_skyway_reunion_insert_idle", mover )

	int attachID = eyecase.LookupAttachment( "EYE_CENTER" )
	vector caseOrigin = eyecase.GetAttachmentOrigin( attachID )
	vector caseAngles = eyecase.GetAttachmentAngles( attachID )

	entity eyeButton = CreatePropDynamic( SMALL_ROCK_01, caseOrigin, caseAngles, 2, -1 )
	eyeButton.Hide()
	eyeButton.SetUsable()
	eyeButton.SetUsableRadius( 250 )
	eyeButton.SetUsableByGroup( "pilot" )
	eyeButton.SetUsePrompts( "#SKYWAY_HINT_INSERT_EYE" , "#SKYWAY_HINT_INSERT_EYE_PC" )

	Objective_Set( "#SKYWAY_OBJECTIVE_INITIALIZE_TITAN", <0,0,0>, eyeButton )

	eyeButton.WaitSignal( "OnPlayerUse" )

	bt.SetNoTarget( true )

	eyeButton.Destroy()
	//Signal( player, "InsertEyeCore" )
	//Signal( bt, "InsertEyeCore" )

  	Objective_Hide( player )
  	Objective_SetSilent( "#SKYWAY_OBJECTIVE_INITIALIZE_TITAN", <0,0,0>, bt )

	player.HolsterWeapon()

	HideName( bt )
	thread PlayAnimTeleport( eyecase, "bt_eye_skyway_reunion_insert", mover )

	thread PlayerInsertsEye( player, mover )
	delaythread( 13 ) BT_PostEyeInset( bt, player )
	waitthread PlayAnim( bt, "bt_skyway_reunion_insert", mover )

	Highlight_SetOwnedHighlight( bt, "pet_titan" )

	eyecase.Destroy()

	FlagSet( "WeaponDropsAllowed" )
	FlagSet( "EyeInserted" )
	ShowName( bt )

	bt.SetNoTarget( false )

	EndSignal( bt, "OnDestroy" )

	float buffer = 2.25
	float duration = bt.GetSequenceDuration( "bt_skyway_reunion_getup" )
	waitthread PlayAnimGravity( bt, "bt_skyway_reunion_getup", mover )
	thread PlayAnim( bt, "bt_skyway_reunion_wait_idle", mover )
	FlagSet( "BTStoodUp" )
	FlagClear( "BTReunionDone" )

	// if ( !Flag( "BTReunionDone" ) )
	{
		EndSignal( level, "BTReunionDone" )

		FlagWait( "BTReunionConversationDone" )

		switch ( file.BtReunionChoice )
		{
			case 0: // no selection
			thread PlayDialogue( "BT_REUNION_1", bt )
			waitthread PlayAnim( bt, "bt_skyway_reunion_response_03", mover )
				break
			case 1: // over 5000 pieces actually
			waitthread PlayAnim( bt, "bt_skyway_reunion_response_01", mover )
			thread PlayDialogue( "BT_REUNION_1", bt )
				break
			case 2: // old paint, same datacore
			waitthread PlayAnim( bt, "bt_skyway_reunion_response_02", mover )
			thread PlayDialogue( "BT_REUNION_1", bt )
				break
		}

		thread StartCockpitLightThink( bt, -1 )
		thread PlayAnim( bt, "bt_skyway_reunion_embark_idle", mover )

		int attachID = bt.LookupAttachment( "PROPGUN" )
		vector caseOrigin = bt.GetAttachmentOrigin( attachID )
		vector caseAngles = bt.GetAttachmentAngles( attachID )

		vector fwd = AnglesToForward( caseAngles ) * 50
		vector up = AnglesToUp( caseAngles ) * 10

		entity prop = CreatePropDynamic( BARREL, caseOrigin + fwd + up, caseAngles + <90,0,0>, SOLID_VPHYSICS )
		prop.SetPusher( true )
		prop.Hide()

		fwd = AnglesToForward( caseAngles ) * 120
		entity prop2 = CreatePropDynamic( BARREL, caseOrigin + fwd + up, caseAngles + <90,0,0>, SOLID_VPHYSICS )
		prop2.SetPusher( true )
		prop2.Hide()

		OnThreadEnd(
		function() : ( prop, prop2 )
			{
				if ( IsValid( prop ) )
					prop.Destroy()
				if ( IsValid( prop2 ) )
					prop2.Destroy()
			}
		)

		attachID = bt.LookupAttachment( "CHESTFOCUS" )
		caseOrigin = bt.GetAttachmentOrigin( attachID )
		caseAngles = bt.GetAttachmentAngles( attachID )

		entity eyeButton = CreatePropDynamic( SMALL_ROCK_01, caseOrigin, caseAngles, 2, -1 )
		eyeButton.Hide()
		eyeButton.SetUsable()
		eyeButton.SetUsableRadius( 200 )
		eyeButton.SetUsableFOVByDegrees( 50 )
		eyeButton.SetUsableByGroup( "pilot" )
		eyeButton.SetUsePrompts( "#HOLD_TO_EMBARK" , "#PRESS_TO_EMBARK" )

		eyeButton.WaitSignal( "OnPlayerUse" )
		eyeButton.Destroy()

		waitthread BT_Reunion_Embark( player, bt )

		mover.Destroy()
	}
}

void function PlayerInsertsEye( entity player, entity mover )
{
	player.SetNoTarget( true )
	FirstPersonSequenceStruct sequence
	sequence.attachment = "REF"
	sequence.firstPersonAnim = "ptpov_skyway_reunion_insert"
	sequence.thirdPersonAnim = "pt_skyway_reunion_insert"
	sequence.viewConeFunction = ViewConeTight
	waitthread FirstPersonSequence( sequence, player, mover )
	player.ReplaceActiveWeapon( "mp_weapon_smart_pistol" )
	player.GetMainWeapons()[0].SetWeaponSkin( 2 )

	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	player.DeployWeapon()
	player.SetNoTarget( false )
	StatusEffect_AddTimed( player, eStatusEffect.move_slow, 0.75, 4.0, 3.75 )
	StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 0.3, 4.0, 3.75 )
}

void function BT_PostEyeInset( entity bt, entity player )
{
	waitthread PlayDialogue( "BT_REUNION_0", bt )

	wait 4.25

	if ( !IsValid( bt ) )
	{
		bt = player
	}

	AddConversationCallback( "BT_Returns", ConvoCallback_BTReunion )
	thread PlayerConversation( "BT_Returns", player, bt )
	table result = WaitSignal( svGlobal.levelEnt, "BT_Returns_ChoiceMade" )
	file.BtReunionChoice = expect int( result.choice )
	FlagSet( "BTReunionConversationDone" )
}

/*
  _______ _ _                  _    _ _ _ _
 |__   __(_) |                | |  | (_) | |
    | |   _| |_ __ _ _ __     | |__| |_| | |
    | |  | | __/ _` | '_ \    |  __  | | | |
    | |  | | || (_| | | | |   | |  | | | | |
    |_|  |_|\__\__,_|_| |_|   |_|  |_|_|_|_|

*/

void function SP_TitanHillThread( entity player )
{
	FlagClear( "SP_MeteorIncreasedDuration" )

	StopMusicTrack( "music_skyway_07_calltitan" )
	PlayMusic( "music_skyway_08_titanhill" )

	CheckPoint()

	entity injector = GetEntByScriptName( "loading_bay_useable" )
	Objective_Set( "#SKYWAY_OBJECTIVE_STOP_SLONE", injector.GetOrigin() )

	thread TitanHill_Phase_1()
	thread TitanHill_Phase_2( player )
	thread TitanHill_Arena( player )
	thread BombardTargetsThread( player )
	thread BeginShipFire( GetEntArrayByScriptName("cliff_fake_guns"), null )

	FlagWait( "TitanHillDone" )
	CheckPoint_Silent()
	Signal( file.gunBattery01, "StopFiring" )
	Signal( file.gunBattery02, "StopFiring" )
	Signal( file.gunBattery03, "StopFiring" )
	Signal( file.gunBattery04, "StopFiring" )
}

void function TitanHillStartPointSetup( entity player )
{
	entity scriptRef = GetEntByScriptName( "titan_hill" )
	TeleportPlayers( scriptRef )
	entity BT = player.GetPetTitan()
	BT.SetOrigin( scriptRef.GetOrigin() )
	BT.SetAngles( scriptRef.GetAngles() )
	PilotBecomesTitan( player, BT )
  	BT.Destroy()

	//Assemble Hill Guns and Spawn Movers needed to control them.
	InitBombardment()

	//Pack info targets of the following names into a targeting array for each gun.
	array<entity> targets_01 = PackTargets( ["gb1_target_01", "gb1_target_02", "gb1_target_03"] )
	array<entity> targets_02 = PackTargets( ["gb2_target_01", "gb2_target_02", "gb2_target_03"] )
	array<entity> targets_03 = PackTargets( ["gb3_target_01", "gb3_target_02", "gb3_target_03"] )
	array<entity> targets_04 = PackTargets( ["gb4_target_01", "gb4_target_02", "gb4_target_03"] )

	//Each gun should loop through its target array and fire at each of its targets.
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery01, targets_01 )
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery02, targets_02 )
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery03, targets_03 )
	thread FireGunAtArrayOfTargets_Looping( file.gunBattery04, targets_04 )
}

void function TitanHillSkipped( entity player )
{
	FlagSet( "bombardment_env_target_01" )
	FlagSet( "bombardment_titan_target_01" )
	FlagSet( "bombardment_target_01" )
}

void function TitanHill_Phase_1()
{
	thread Phase_1_TitanSpawn()
	entity trig = GetEntByScriptName( "titan_hill_combat_1_1" )
	trig.WaitSignal( "OnTrigger" )
	WaitFrame()

	while ( GetNPCArrayEx( "npc_titan", TEAM_IMC, TEAM_ANY, Vector(0,0,0), -1 ).len() > 0 )
		WaitFrame()

	FlagSet( "titan_hill_phase_1" )
}

void function Phase_1_TitanSpawn()
{
	FlagWait( "titan_hill_phase_1" )

	array<entity> spawners = GetEntArrayByScriptName( "titan_hill_phase_1_titans" )
	array<entity> titans = SpawnFromSpawnerArray( spawners )

	while ( GetNPCArrayEx( "npc_titan", TEAM_IMC, TEAM_ANY, Vector(0,0,0), -1 ).len() > 0 )
		WaitFrame()

	if ( !Flag( "music_skyway_10_titanhillwave02" ) )
	{
		StopMusicTrack( "music_skyway_08_titanhill" )
		PlayMusic( "music_skyway_09_titanhillcomplete" )
	}
}

void function TitanHill_Phase_2( entity player )
{
	entity trig = GetEntByScriptName( "titan_hill_combat_1_2" )
	trig.WaitSignal( "OnTrigger" )

	thread PlayDialogue( "TITAN_HILL_A_0", player )

	array<entity> titans = SpawnFromSpawnerArray( GetEntArrayByScriptName( "titan_hill_bombardment_victims" ) )

	entity gun = GetEntByScriptName( "mil_ship2_starboard_gun_02" )
	float delay = 0.0

	FlagSet( "music_skyway_10_titanhillwave02" )
	StopMusicTrack( "music_skyway_08_titanhill" )
	StopMusicTrack( "music_skyway_09_titanhillcomplete" )
	PlayMusic( "music_skyway_10_titanhillwave02" )

	wait 8.0

	foreach ( target in titans )
	{
		if ( IsAlive( target ) )
		{
			thread BombardTargetInstant_Internal( target, delay )
			thread BombardTarget_Mortar( gun, target, delay )
			delay += RandomFloatRange( 1.25, 2.00 )
		}
	}
}

void function BombardTargetsThread( entity player )
{
	EndSignal( level, "TitanHillDone" )

	thread BombardDialoge( player )
	thread BombardDialoge2( player )

	int dialogueIndex = 0

	while ( 1 )
	{
		FlagWaitClear( "BombardPaused" )

		if ( file.bombardTargets.len() == 0 )
		{
			wait 1
			continue
		}

		int burstcount = RandomIntRange( 1,2 )
		int fireCount = 0

		ArrayRemoveInvalid( file.bombardTargets )
		ArrayRemoveDead( file.bombardTargets )

		array<ArrayDistanceEntry> allResults = ArrayDistanceResults( file.bombardTargets, player.GetOrigin() )
		allResults.sort( DistanceCompareClosest )

		float delay = 0.0

		for ( int i=0; i<burstcount && i<allResults.len(); i++ )
		{
			entity target = allResults[i].ent
			// file.bombardTargets.fastremovebyvalue( target )

			if ( IsAlive( target ) && ( PlayerCanSee( player, target, true, 40 ) || file.forcedBombardList.contains( target ) ) )
			{
				entity gun = file.bombardGun
				int num = RandomIntRange( 2, 4 )
				for ( int j=0; j<num; j++ )
				{
					delay += RandomFloatRange( 0.75, 0.9 )
					thread BombardTarget_Mortar( gun, target, delay )
				}
				fireCount++
			}
		}

		if ( fireCount > 0 )
		{
			if ( Flag( "BombardDialogueEnabled" ) )
			{
				thread PlayDialogue( file.bombardString + dialogueIndex, player )
				dialogueIndex = (dialogueIndex+1)%3
			}

			wait RandomFloatRange( 8.25, 12.75 )
		}

		wait 1.0
	}
}

void function BombardDialoge( entity player )
{
	wait 3.0
	waitthread PlayDialogue( "TITAN_HILL_1", player )
	wait 0.3
	waitthread PlayDialogue( "TITAN_HILL_2", player )
	wait 0.3
	waitthread PlayDialogue( "TITAN_HILL_3", player )
	wait 0.3
	waitthread PlayDialogue( "TITAN_HILL_4", player )
	wait 0.3
	FlagSet( "BombardDialogueEnabled" )
}

void function BombardDialoge2( entity player )
{
	FlagWait( "titan_hill_bombard_pause" )
	FlagSet( "BombardPaused" )
	FlagClear( "BombardDialogueEnabled" )

	StopMusicTrack( "music_skyway_10_titanhillwave02" )
	PlayMusic( "music_skyway_11_intermission" )

	// waitthread PlayDialogue( "TITAN_HILL_A_1", player )
	// wait 0.1
	// waitthread PlayDialogue( "TITAN_HILL_A_2", player )
	// wait 0.1
	// waitthread PlayDialogue( "TITAN_HILL_A_3", player )
	// wait 0.5
	waitthread PlayDialogue( "TITAN_HILL_A_4", player )
	wait 0.2
	thread PlayDialogue( "TITAN_HILL_A_5", player )

	entity malta = GetEntByScriptName( "malta" )
	entity gunOrg = GetEntByScriptName( "malta_guns_1" )

	entity mover = CreateScriptMover()
	mover.SetAngles( gunOrg.GetAngles() )
	mover.SetOrigin( gunOrg.GetOrigin() )
	mover.SetParent( malta )

	thread MaltaWarpIn( malta )
	FlagWait( "titan_hill_malta_enter" )

	wait 3.0
	waitthread PlayDialogue( "TITAN_HILL_B_1", player )
	wait 0.2
	waitthread PlayDialogue( "TITAN_HILL_B_2", player )
	wait 0.2
	waitthread PlayDialogue( "TITAN_HILL_B_3", player )
	wait 0.1
	thread PlayDialogue( "TITAN_HILL_B_4", player )

	file.bombardGun = mover
	file.bombardString = "BOMBARD_B_"

	FlagClear( "BombardPaused" )

	wait 2.0

	FlagSet( "BombardDialogueEnabled" )
}

void function MaltaWarpIn( entity malta )
{
	array<entity> fakeGuns = []
	array<entity> fakeGunPos = GetEntArrayByScriptName( "malta_fake_guns" )
	foreach ( pos in fakeGunPos )
	{
		entity gun = CreateScriptMover()
		gun.SetOrigin( pos.GetOrigin() )
		gun.SetAngles( pos.GetAngles() )
		gun.SetParent( malta )
		fakeGuns.append( gun )
	}

	vector finalPos = malta.GetOrigin()
	vector fwd = AnglesToForward( malta.GetAngles() )
	fwd += <0,0,0.3>
	vector offset = 30000*fwd
	malta.SetOrigin( malta.GetOrigin() - offset )

	malta.Hide()
	FlagWait( "titan_hill_malta_enter" )
	EmitSoundOnEntity( malta, "AngelCity_Scr_MegaCarrierWarpIn" )
	malta.Show()
	thread BeginFlak( malta )
	thread BeginShipFire( fakeGuns, malta )
	thread BeginShipFire( fakeGuns, malta )

	entity mover = CreateScriptMover()
	mover.SetAngles( malta.GetAngles() )
	mover.SetOrigin( malta.GetOrigin() )
	malta.SetParent( mover )

	vector oldAngles = mover.GetAngles()

	// mover.NonPhysicsRotateTo( mover.GetAngles() + < -5,0,0 >, 10, 2, 2 )
	// wait 3.0
	mover.NonPhysicsMoveTo( finalPos, 30, 0, 25 )
	wait 5.0
	mover.NonPhysicsRotateTo( oldAngles, 30, 2, 10 )

	FlagWait( "TitanSmashHallwayDone" )

	malta.Destroy()
}

void function TitanHill_Arena( entity player )
{
	FlagWait( "titan_hill_arena_start" )

	StopMusicTrack( "music_skyway_11_intermission" )
	PlayMusic( "music_skyway_12_titanhillwave03" )

	array<entity> titans = SpawnFromSpawnerArray( GetEntArrayByScriptName( "titan_hill_arena_spawners_1" ) )
	thread SetFlagOnArrayDeath( titans, "titan_hill_arena_2" )

	FlagWait( "titan_hill_arena_2" )
	// FlagSet( "titan_hill_arena_door_open" )

	titans = SpawnFromSpawnerArray( GetEntArrayByScriptName( "titan_hill_arena_spawners_2" ) )
	thread SetFlagOnArrayDeath( titans, "titan_hill_arena_door_open" )
	thread SetFlagOnArrayDeath( titans, "titan_hill_arena_3" )

	FlagWait( "titan_hill_arena_3" )

	GetEntByScriptName( "titan_hill_bunker_trigger" ).Destroy()

	delaythread( 1 ) PlayDialogue( "SMASH_HALL_4", player )

	titans = SpawnFromSpawnerArray( GetEntArrayByScriptName( "titan_hill_arena_spawners_3" ) )

	FlagSet( "titan_hill_arena_door_open" )
}

void function SetFlagOnArrayDeath( array<entity> ents, string flagName )
{
	while ( ents.len() > 0 )
	{
		WaitFrame()
		ArrayRemoveDead( ents )
	}

	FlagSet( flagName )
}

void function InitHillGuns()
{
	//Get the First Gun (Barrel and Base)
	entity base01 = GetEntByScriptName( "hillside_cannon_base_01" )
	entity barrel01 = GetEntByScriptName( "hillside_cannon_barrel_01" )

	//Get the Second Gun (Barrel and Base)
	entity base02 = GetEntByScriptName( "hillside_cannon_base_02" )
	entity barrel02 = GetEntByScriptName( "hillside_cannon_barrel_02" )

	//Get the Third Gun (Barrel and Base)
	entity base03 = GetEntByScriptName( "hillside_cannon_base_03" )
	entity barrel03 = GetEntByScriptName( "hillside_cannon_barrel_03" )

	//Get the Fourth Gun (Barrel and Base)
	entity base04 = GetEntByScriptName( "hillside_cannon_base_04" )
	entity barrel04 = GetEntByScriptName( "hillside_cannon_barrel_04" )

	//Store the initilized gun data in the file table so we can access them later
	file.gunBattery01 = Init_GunBattery( base01, barrel01 )
	file.gunBattery02 = Init_GunBattery( base02, barrel02 )
	file.gunBattery03 = Init_GunBattery( base03, barrel03 )
	file.gunBattery04 = Init_GunBattery( base04, barrel04 )
	file.gunBattery06 = Init_GunBattery( GetEntArrayByScriptName( "bridge_cannon_base_01" )[0], GetEntArrayByScriptName( "bridge_cannon_barrel_01" )[0] )
}

void function InitBombardment()
{
	//Enviormental Targets
	entity envTarget_01 = GetEntByScriptName( "bombardment_env_target_01" )
	entity envTarget_02 = GetEntByScriptName( "bombardment_env_target_02" )
	entity envTarget_03 = GetEntByScriptName( "bombardment_env_target_03" )
	entity envTarget_04 = GetEntByScriptName( "bombardment_env_target_04" )
	entity envTarget_05 = GetEntByScriptName( "bombardment_env_target_05" )
	entity envTarget_06 = GetEntByScriptName( "bombardment_env_target_06" )

	//Infantry Positions
	entity infTarget_01 = GetEntByScriptName( "bombardment_target_01" )
	entity infTarget_02 = GetEntByScriptName( "bombardment_target_02" )

	//Titan Positions
	entity titanTarget_01 = GetEntByScriptName( "bombardment_titan_target_01" )

	//Milita Ship 1 Guns
	entity milShip1_starboard_gun_01 = GetEntByScriptName( "mil_ship1_starboard_gun_01" )
	entity milShip1_starboard_gun_02 = GetEntByScriptName( "mil_ship1_starboard_gun_02" )
	entity milShip1_starboard_gun_03 = GetEntByScriptName( "mil_ship1_starboard_gun_03" )
	entity milShip1_starboard_gun_04 = GetEntByScriptName( "mil_ship1_starboard_gun_04" )

	//Militia Ship 2 Guns
	entity milShip2_starboard_gun_01 = GetEntByScriptName( "mil_ship2_starboard_gun_01" )
	entity milShip2_starboard_gun_02 = GetEntByScriptName( "mil_ship2_starboard_gun_02" )
	entity milShip2_starboard_gun_03 = GetEntByScriptName( "mil_ship2_starboard_gun_03" )
	entity milShip2_starboard_gun_04 = GetEntByScriptName( "mil_ship2_starboard_gun_04" )

	//Ship Battle Cannon Targets
	thread BombardTargetOnFlag_Mortar( milShip1_starboard_gun_01, envTarget_01, "bombardment_env_target_01", 0  )
	thread BombardTargetOnFlag_Mortar( milShip1_starboard_gun_02, envTarget_02, "bombardment_env_target_01", .5 )
	thread BombardTargetOnFlag_Mortar( milShip1_starboard_gun_03, envTarget_03, "bombardment_env_target_01", 2  )

	thread BombardTargetOnFlag_Mortar( milShip1_starboard_gun_01, envTarget_04, "bombardment_env_target_04", 0 )
	thread BombardTargetOnFlag_Mortar( milShip1_starboard_gun_02, envTarget_05, "bombardment_env_target_04", 1 )
	thread BombardTargetOnFlag_Mortar( milShip1_starboard_gun_03, envTarget_06, "bombardment_env_target_04", 2 )

	thread BombardTargetOnFlag_Mortar( milShip1_starboard_gun_01, titanTarget_01, "bombardment_titan_target_01", 3 )

	//Ship Heavy Mortar Targets
	thread BombardTargetOnFlag_ClusterMortar( milShip1_starboard_gun_01 ,infTarget_01, "bombardment_target_01", 1 )
	thread BombardTargetOnFlag_ClusterMortar( milShip1_starboard_gun_02 ,infTarget_02, "bombardment_target_01", 2.25 )

//	thread BombardTargetOnFlag_ClusterMortar( milShip1_starboard_gun_01 ,envTarget_01, "bombardment_env_target_01", 2.5 )
//	thread BombardTargetOnFlag_ClusterMortar( milShip1_starboard_gun_02 ,envTarget_02, "bombardment_env_target_01", 2.75 )
//	thread BombardTargetOnFlag_ClusterMortar( milShip1_starboard_gun_03 ,envTarget_03, "bombardment_env_target_01", 3.0 )
}

/*
  _______ _ _                   _____                     _         _    _       _ _
 |__   __(_) |                 / ____|                   | |       | |  | |     | | |
    | |   _| |_ __ _ _ __     | (___  _ __ ___   __ _ ___| |__     | |__| | __ _| | |_      ____ _ _   _
    | |  | | __/ _` | '_ \     \___ \| '_ ` _ \ / _` / __| '_ \    |  __  |/ _` | | \ \ /\ / / _` | | | |
    | |  | | || (_| | | | |    ____) | | | | | | (_| \__ \ | | |   | |  | | (_| | | |\ V  V / (_| | |_| |
    |_|  |_|\__\__,_|_| |_|   |_____/|_| |_| |_|\__,_|___/_| |_|   |_|  |_|\__,_|_|_| \_/\_/ \__,_|\__, |
                                                                                                    __/ |
                                                                                                   |___/
*/
void function TitanSmashHallwayStartPointSetup ( entity player )
{
	entity scriptRef = GetEntByScriptName( "Titan_Smash_Hallway" )
	TeleportPlayers( scriptRef )
	entity BT = player.GetPetTitan()
	BT.SetOrigin( scriptRef.GetOrigin() )
	BT.SetAngles( scriptRef.GetAngles() )
	PilotBecomesTitan( player, BT )
  	BT.Destroy()
}

void function TitanSmashHallwaySkipped( entity player )
{

}

void function SP_TitanSmashHallwayThread( entity player )
{
	svGlobal.levelEnt.Signal( "StratonHornetDogfights" )

	Objective_Remind()

	StopMusicTrack( "music_skyway_12_titanhillwave03" )
	PlayMusic( "music_skyway_13_enroutetobliskandslone" )
	thread SmashHallDialogue( player )

	thread TitanCrouchHint( player )

	CheckPoint()

	FlagWait( "TitanSmashHallwayDone" )
}

void function SmashHallDialogue( entity player )
{
	player.EndSignal( "OnDeath" )

	waitthread PlayDialogue( "SMASH_HALL_5", player )
	wait 0.5
	waitthread PlayDialogue( "SMASH_HALL_6", GetTitanFromPlayer( player ) )
}

void function TitanCrouchHint( entity player )
{
	EndSignal( level, "TitanSmashHallwayDone" )

	bool hintGiven = false
	float lastHintTime = 0.0

	entity trigger = GetEntByScriptName( "titan_smash_hint_crouch" )

	while( 1 )
	{
		trigger.WaitSignal( "OnTrigger" )

		if ( !hintGiven )
		{
			// waitthread PlayDialogue( "SMASH_HALL_1", player )
			// wait 0.5
			// thread PlayDialogue( "SMASH_HALL_2", player )
			hintGiven = true
		}

		Remote_CallFunction_NonReplay( player, "ServerCallback_ShowCrouchHint" )

		wait 10.0
	}
}

/*
   _____            _       _                  _____ _ _           _
  / ____|          | |     | |                / ____| (_)         | |
 | (___   ___ _   _| |_ __ | |_ ___  _ __    | |    | |_ _ __ ___ | |__
  \___ \ / __| | | | | '_ \| __/ _ \| '__|   | |    | | | '_ ` _ \| '_ \
  ____) | (__| |_| | | |_) | || (_) | |      | |____| | | | | | | | |_) |
 |_____/ \___|\__,_|_| .__/ \__\___/|_|       \_____|_|_|_| |_| |_|_.__/
                     | |
                     |_|
*/

void function SculptorClimbStartPointSetup( entity player )
{
	svGlobal.levelEnt.Signal( "StopFlybys" )

	entity scriptRef = GetEntByScriptName( "sculptor_climb" )
	TeleportPlayers( scriptRef )
	entity BT = player.GetPetTitan()
	BT.SetOrigin( scriptRef.GetOrigin() )
	BT.SetAngles( scriptRef.GetAngles() )
	PilotBecomesTitan( player, BT )
  	BT.Destroy()
}

void function SculptorClimbSkipped( entity player )
{
}

void function SP_SculptorClimbThread( entity player )
{
	// PlayMusic( "music_skyway_14_arcfoldagain" )
	CheckPoint()
	thread TargetingRoomDialogue()
	FlagWait( "SculptorClimbDone" )
}

/*
  _______                   _   _                _____
 |__   __|                 | | (_)              |  __ \
    | | __ _ _ __ __ _  ___| |_ _ _ __   __ _   | |__) |___   ___  _ __ ___
    | |/ _` | '__/ _` |/ _ \ __| | '_ \ / _` |  |  _  // _ \ / _ \| '_ ` _ \
    | | (_| | | | (_| |  __/ |_| | | | | (_| |  | | \ \ (_) | (_) | | | | | |
    |_|\__,_|_|  \__, |\___|\__|_|_| |_|\__, |  |_|  \_\___/ \___/|_| |_| |_|
                  __/ |                  __/ |
                 |___/                  |___/
*/

void function TargetingRoomStartPointSetup( entity player )
{
	entity scriptRef = GetEntByScriptName( "targeting_room" )
	TeleportPlayers( scriptRef )
	entity BT = player.GetPetTitan()
	BT.SetOrigin( scriptRef.GetOrigin() )
	BT.SetAngles( scriptRef.GetAngles() )
	PilotBecomesTitan( player, BT )
  	BT.Destroy()
}

void function TargetingRoomSkipped( entity player )
{
	FlagClear( "injector_lighting_FX" )
}

void function SP_TargetingRoomThread( entity player )
{
	CheckPoint()
	StopMusicTrack( "music_skyway_13_enroutetobliskandslone" )
	PlayMusic( "music_skyway_15_blueroom" )

	FlagClear( "injector_lighting_FX" )

	if ( !player.IsTitan() )
	{
		entity BT = player.GetPetTitan()
		if ( BT != null )
		{
			entity scriptRef = GetEntByScriptName( "bt_failsafe_node" )
			BT.SetOrigin( scriptRef.GetOrigin() )
			BT.SetAngles( scriptRef.GetAngles() )
		}
	}

	FlagWait( "TargetingRoomDone" )
}

void function TargetingRoomDialogue()
{
	entity speaker = GetEntByScriptName( "targeting_room_speaker" )
	thread PlayPA( "TARGETING_ROOM_1" )
	waitthread PlayDialogue( "TARGETING_ROOM_1", speaker )
	wait 0.5
	thread PlayPA( "TARGETING_ROOM_2" )
	waitthread PlayDialogue( "TARGETING_ROOM_2", speaker )
	wait 1.0
	thread PlayPA( "TARGETING_ROOM_3" )
	waitthread PlayDialogue( "TARGETING_ROOM_3", speaker )
	wait 0.5
	thread PlayPA( "TARGETING_ROOM_4" )
	waitthread PlayDialogue( "TARGETING_ROOM_4", speaker )
	wait 1.0
	thread PlayPA( "TARGETING_ROOM_5" )
	waitthread PlayDialogue( "TARGETING_ROOM_5", speaker )
	wait 0.5
}

/*
  _____       _           _                _____
 |_   _|     (_)         | |              |  __ \
   | |  _ __  _  ___  ___| |_ ___  _ __   | |__) |___   ___  _ __ ___
   | | | '_ \| |/ _ \/ __| __/ _ \| '__|  |  _  // _ \ / _ \| '_ ` _ \
  _| |_| | | | |  __/ (__| || (_) | |     | | \ \ (_) | (_) | | | | | |
 |_____|_| |_| |\___|\___|\__\___/|_|     |_|  \_\___/ \___/|_| |_| |_|
            _/ |
           |__/
 */

void function InjectorRoomStartPointSetup( entity player )
{
	entity scriptRef = GetEntByScriptName( "injector_room" )
	TeleportPlayers( scriptRef )
	entity BT = player.GetPetTitan()
	BT.SetOrigin( scriptRef.GetOrigin() )
	BT.SetAngles( scriptRef.GetAngles() )
	PilotBecomesTitan( player, BT )
  	BT.Destroy()

	foreach( player in GetPlayerArray() )
	{
		MakePlayerTitan( player, scriptRef.GetOrigin() )
		Disembark_Disallow( player )
	}
}

void function InjectorRoomSkipped( entity player )
{
	svGlobal.levelEnt.Signal( "StratonHornetDogfights" )
}

void function SP_InjectorRoomThread( entity player )
{
	if ( GetBugReproNum() != 162213 )
	{
		entity injector = GetEntByScriptName( "injector_gun" )
		// injector.NotSolid()
	}

	// cleanup
	foreach ( ai in GetNPCArrayOfEnemies( player.GetTeam() ) )
	{
		ai.Destroy()
	}

	svGlobal.levelEnt.Signal( "StratonHornetDogfights" )
	FlagSet( "SP_MeteorIncreasedDuration" )
	CheckPoint()
	entity sequenceRef = GetEntByScriptName( "injector_room_sequence_ref" )
	thread SloneBossSequence( player, sequenceRef )
	thread BliskInjectorRoomPilot( sequenceRef )
	thread BliskInjectorRoomTitan( sequenceRef )
	thread MarderInjectorRoom( sequenceRef )

	FlagWait( "InjectorRoomDone" )
}

void function PlayPA( string sound )
{
	array<entity> orgs = GetEntArrayByScriptName( "facility_PA" )
	foreach( org in orgs )
	{
		thread PlayDialogue( sound, org )
	}
}

void function SloneBossSequence( entity player, entity sequenceRef )
{
	entity injector = GetEntByScriptName( "injector_gun" )

	entity spawner = GetEntByScriptName( "slone" )
	entity slone = spawner.SpawnEntity()
	slone.SetScriptName( "slane" )
	DispatchSpawn( slone )
	thread PlayAnimTeleport( slone, "mt_injectore_room_slone_pose", sequenceRef )

	slone.SetNoTarget( true )
	HideCrit( slone )
	slone.SetValidHealthBarTarget( false )
	AddEntityCallback_OnDamaged( slone, PushLastActionTime )
	AddEntityCallback_OnDamaged( slone, NoSelfDamage )
	AddEntityCallback_OnDamaged( player, NoTitanFallDamage )
	HideName( slone )
	
	foreach( entity p in GetPlayerArray() )
		thread SloneFightMovePlayer( p )
	TriggerSilentCheckPoint( sequenceRef.GetOrigin(), false )

	svGlobal.levelEnt.WaitSignal( "BossTitanStartAnim" )

	thread SloneFightInjectorInteraction( player, slone, sequenceRef )
	thread PlayAnim( injector, "injector_room_core_railgun", sequenceRef )

	wait 10.9

	injector.Hide()
	FlagSet( "InjectorInteractionAvailable" )
	wait 0.2
	injector.Show()

	slone.WaitSignal( "BossTitanIntroEnded" )

	thread SloneFightPhases( player, slone )

	entity ref = GetEntByScriptName( "slone_fight_dash_ref_b" )
	entity slideRef = CreateScriptMover( slone.GetOrigin(), ref.GetAngles() )

	waitthread PlayAnimGravity( slone, "mt_evade_dash_L", slideRef, null, 0.0 )
	slideRef.Destroy()

	CheckPoint_Forced()

	slone.EndSignal( "OnDeath" )
	Objective_Remind()

	waitthread RunToAndPlayAnimGravityForced( slone, "mt_dash_backwards", ref )
	ref = GetEntByScriptName( "slone_fight_dash_ref_l" )
	waitthread RunToAndPlayAnimGravityForced( slone, "at_elite_dash_L", ref )
	ref = GetEntByScriptName( "slone_phase_1_pos" )
	float radius = float( ref.kv.script_goal_radius )
	slone.AssaultSetGoalRadius( radius )
	slone.AssaultSetFightRadius( radius )
	slone.AssaultPoint( ref.GetOrigin() )
	slone.WaitSignal( "OnFinishedAssault" )
	SoulTitanCore_SetNextAvailableTime( slone.GetTitanSoul(), 1.0 )
	slone.WaitSignal( "CoreBegin" )
	ref = GetEntByScriptName( "slone_phase_1_pos_2" )
	radius = float( ref.kv.script_goal_radius )
	slone.AssaultSetGoalRadius( radius )
	slone.AssaultSetFightRadius( radius )
	slone.AssaultPoint( ref.GetOrigin() )
	slone.WaitSignal( "OnFinishedAssault" )

	wait 2
	slone.AssaultSetGoalRadius( 5000 )
}

void function SloneFightInjectorInteraction( entity player, entity slone, entity sequenceRef )
{
	entity injector = GetEntByScriptName( "injector_gun" )

	entity core = CreatePropDynamic( CORE_MODEL )
	Objective_InitEntity( core )
	vector org = injector.GetAttachmentOrigin( injector.LookupAttachment( "CORE" ) )
	core.SetOrigin( org )
	core.SetParent( injector, "CORE", false, 0.0 )

	FlagWait( "InjectorInteractionAvailable" )

	entity mover = CreateScriptMover( sequenceRef.GetOrigin(), sequenceRef.GetAngles(), 0 )
	thread PlayAnim( injector, "skyway_core_railgun_pull_idle", mover, null, 0.0 )

	OnThreadEnd(
	function() : ( injector, mover )
		{
			mover.Destroy()
		}
	)

	Objective_SetSilent( "#SKYWAY_OBJECTIVE_STOP_ARK", <0,0,0>, core )

	file.pitch = 0

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, "skyway_scripted_injector_bt_futile_pry_core_loop" )
			}
		}
	)

	slone.WaitSignal( "BossTitanIntroEnded" )
	wait 3.0 // let the slam cam finish

	array<entity> spawnerArray = GetEntArrayByScriptName( "slone_fight_phase_1" )

	while ( !Flag( "InjectorRoomDone" ) )
	{
		waitthread PulldownLoopThink( injector, player, slone, mover, spawnerArray )
	}

}

void function PulldownLoopThink( entity injector, entity player, entity slone, entity mover, array<entity> spawnerArray )
{
	entity teleportOrg = GetEntByScriptName( "slone_fight_teleport" )

	injector.SetPoseParameterOverTime( injector.LookupPoseParameterIndex( "aim_pitch" ), file.pitch, 0.1 )

	waitthread Init_BTLoadingBayClimb( "SKYWAY_HINT_DISABLE_INJECTOR", "SKYWAY_HINT_DISABLE_INJECTOR_PC" )

	if ( Flag( "InjectorRoomDone" ) )
		return

	player.GetFirstPersonProxy().SetSkin( 2 )
	vector origin = player.GetOrigin()

	HolsterAndDisableWeapons( player )

	FirstPersonSequenceStruct btSequence
	
	// TODO: this seams to be a titan anim
	btSequence.firstPersonAnim = "btpov_skyway_core_railgun_grab"
	btSequence.thirdPersonAnim = "bt_skyway_core_railgun_grab"
	btSequence.attachment = "ref"
	btSequence.viewConeFunction = ViewConeZero

	EmitSoundOnEntity( player, "skyway_scripted_injector_bt_futile_pry_core_loop" )
	// foreach( entity p in GetPlayerArray() )
	// {
	// 	thread FirstPersonSequence( btSequence, p, mover )
	// }
	waitthread FirstPersonSequence( btSequence, player, mover )

	SpawnFromSpawnerArray( spawnerArray )

	entity entToTeleport = slone
	if ( slone.Anim_IsActive() )
	{
		entToTeleport = null

		array<entity> titans = GetNPCArrayEx( "npc_titan", TEAM_IMC, TEAM_ANY, Vector(0,0,0), -1 )
		foreach ( t in titans )
		{
			if ( IsAlive( t ) && !PlayerCanSee( player, t, false, 60 ) )
			{
				entToTeleport = t
				break
			}
		}

		if ( entToTeleport == null )
		{
			array<entity> reapers = GetNPCArrayEx( "npc_super_spectre", TEAM_IMC, TEAM_ANY, Vector(0,0,0), -1 )
			foreach ( r in reapers )
			{
				if ( IsAlive( r ) && !PlayerCanSee( player, r, false, 60 ) )
				{
					entToTeleport = r
					break
				}
			}
		}
	}

	if ( IsAlive( entToTeleport ) )
	{
		entToTeleport.SetOrigin( teleportOrg.GetOrigin() )
		entToTeleport.SetAngles( teleportOrg.GetAngles() )
	}

	if ( !Flag( "InjectorRoomDone" ) )
	{
		btSequence.firstPersonAnim = "btpov_skyway_core_railgun_idle"
		btSequence.thirdPersonAnim = "bt_skyway_core_railgun_idle"
		btSequence.attachment = "ref"
		btSequence.viewConeFunction = ViewConeZero
		thread FirstPersonSequence( btSequence, player, mover )

		// player.SnapEyeAngles( < -12.153360, 160.297989, -15.030890 > )

		Disembark_Disallow( player )

		waitthread EnablePulldown( injector, player )

		Disembark_Allow( player )
	}
	StopSoundOnEntity( player, "skyway_scripted_injector_bt_futile_pry_core_loop" )

	btSequence.firstPersonAnim = "btpov_skyway_core_railgun_release"
	btSequence.thirdPersonAnim = "bt_skyway_core_railgun_release"
	btSequence.attachment = "ref"
	btSequence.viewConeFunction = ViewConeZero
	waitthread FirstPersonSequence( btSequence, player, mover )

	player.ClearParent()
	player.Anim_Stop()
	player.GetFirstPersonProxy().Anim_Stop()
	player.GetFirstPersonProxy().ClearParent()
	ClearPlayerAnimViewEntity( player )
	DeployAndEnableWeapons( player )
	player.SetOrigin( origin )

	while ( file.pitch > 0 )
	{
		file.pitch -= 2.0
		file.pitch = clamp( file.pitch, 0, 45 )
		injector.SetPoseParameterOverTime( injector.LookupPoseParameterIndex( "aim_pitch" ), file.pitch, 0.1 )
		player.GetFirstPersonProxy().SetPoseParameterOverTime( player.GetFirstPersonProxy().LookupPoseParameterIndex( "aim_pitch" ), file.pitch, 0.1 )
		wait 0.1
	}
}

void function EnablePulldown( entity injector, entity player )
{
	EndSignal( level, "InjectorRoomDone" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnStopPulldown" )

	file.lastPulldownTime = Time()
	thread StopPulldown( player )

	Remote_CallFunction_NonReplay( player, "ServerCallback_ShowMashHint" )

	OnThreadEnd(
	function() : ( player )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_HideMashHint" )
		}
	)

	while ( 1 )
	{
		player.WaitSignal( "PullDown" )
		file.lastPulldownTime = Time()
		file.pitch += 0.5
		file.pitch = clamp( file.pitch, 0, 45 )
		printt( file.pitch )
		injector.SetPoseParameterOverTime( injector.LookupPoseParameterIndex( "aim_pitch" ), file.pitch, 0.1 )
		injector.SetNextThinkNow()
		player.GetFirstPersonProxy().SetPoseParameterOverTime( player.GetFirstPersonProxy().LookupPoseParameterIndex( "aim_pitch" ), file.pitch, 0.1 )
		player.GetFirstPersonProxy().SetNextThinkNow()
		wait 0.1
		thread PullDownResist( injector, player )
	}
}


void function PullDownResist( entity injector, entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "PullDown" )
	player.EndSignal( "OnStopPulldown" )

	wait 0.3

	while ( file.pitch > 0 )
	{
		file.pitch -= 0.5
		file.pitch = clamp( file.pitch, 0, 45 )
		injector.SetPoseParameterOverTime( injector.LookupPoseParameterIndex( "aim_pitch" ), file.pitch, 0.1 )
		player.GetFirstPersonProxy().SetPoseParameterOverTime( player.GetFirstPersonProxy().LookupPoseParameterIndex( "aim_pitch" ), file.pitch, 0.1 )
		wait 0.1
	}
}

void function StopPulldown( entity player )
{
	player.EndSignal( "OnStopPulldown" )

	while ( Time() < file.lastPulldownTime + 2.0 )
	{
		WaitFrame()
	}

	player.Signal( "OnStopPulldown" )
}

void function NoSelfDamage( entity ent, var damageInfo )
{
	if ( IsValid( DamageInfo_GetAttacker( damageInfo ) ) )
	{
		if ( DamageInfo_GetAttacker( damageInfo ).GetTeam() == ent.GetTeam() )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}
	}

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == damagedef_reaper_nuke )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

}

void function PushLastActionTime( entity ent, var damageInfo )
{
	if ( IsValid( DamageInfo_GetAttacker( damageInfo ) ) )
	{
		if ( DamageInfo_GetAttacker( damageInfo ).IsPlayer() )
		{
			file.lastActionTime = Time()
		}
	}

}

void function NoTitanFallDamage( entity ent, var damageInfo )
{
	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == damagedef_reaper_fall
		|| DamageInfo_GetDamageSourceIdentifier( damageInfo ) == damagedef_titan_fall
	 )
		DamageInfo_SetDamage( damageInfo, 500 )
}

void function SloneFightMovePlayer( entity player )
{
	player.EndSignal( "OnDeath" )
	FlagWait( "BossTitanViewFollow" )
	entity ref = GetEntByScriptName( "slone_fight_player_start" )
	player.SetAngles( ref.GetAngles() )
	player.SnapEyeAngles( ref.GetAngles() )
	wait 1.0
	entity mover = CreateScriptMover( ref.GetOrigin(), ref.GetAngles(), 0 )
	ViewConeZero( player )
	player.SetParent( mover, "", false )
	wait 1.0
	player.ClearParent()
	FlagClear( "SloneSlamzoomStart" ) // closes the door

	if ( player.GetPetTitan() != null )
	{
		entity titan = player.GetPetTitan()
		titan.SetOrigin( ref.GetOrigin() )
		titan.SetAngles( ref.GetAngles() )
		PilotBecomesTitan( player, titan )
		titan.Destroy()
	}

	mover.Destroy()
}

void function SloneFightPhases( entity player, entity slone )
{
	slone.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
				UnlockAchievement( player, achievements.BEAT_SLONE )
			FlagSet( "InjectorRoomDone" )
		}
	)

	// FlagWait("BossTitanViewFollow")
	// FlagWaitClear("BossTitanViewFollow")

	thread ManagePhases( player )

	// Phase 1
	// SpawnFromSpawnerArray( GetEntArrayByScriptName( "slone_fight_phase_1" ) )

	wait 1.2

	SpawnFromSpawnerArray( GetEntArrayByScriptName( "slone_fight_phase_1_titan" ) )

	while ( GetHealthFrac(slone) > 0.6 )
		WaitFrame()

	file.idealPhase = 2
	thread ForceNextPhase()

	slone.ai.buddhaMode = true
	SloneFightMobs( player, slone, ["slone_fight_phase_2_a", "slone_fight_phase_2_b"], true, "SLONE_FIGHT_1", "SLONE_FIGHT_2", "SLONE_FIGHT_3" )
	SoulTitanCore_SetNextAvailableTime( slone.GetTitanSoul(), 1.0 )
	slone.SetHealth( slone.GetMaxHealth() * 0.6 )
	// slone.ai.buddhaMode = false

	file.idealPhase = 3
	thread ForceNextPhase()

	while ( GetHealthFrac(slone) > 0.3 )
		WaitFrame()

	file.idealPhase = 4
	thread ForceNextPhase()

	// slone.ai.buddhaMode = true
	// array<entity> spawners = GetEntArrayByScriptName( "slone_fight_phase_3" )
	// foreach ( ent in spawners )
	// {
	// 	thread TriggerSpawnSpawner( ent )
	// }
	SloneFightMobs( player, slone, ["slone_fight_phase_3"], false, "SLONE_FIGHT_4", "SLONE_FIGHT_5", "SLONE_FIGHT_6" )
	SoulTitanCore_SetNextAvailableTime( slone.GetTitanSoul(), 1.0 )
	slone.SetHealth( slone.GetMaxHealth() * 0.3 )
	slone.ai.buddhaMode = false

	file.idealPhase = 5
	thread ForceNextPhase()

	WaitForever()
}

void function ManagePhases( entity player )
{
	entity injector = GetEntByScriptName( "injector_gun" )
	entity lightstrip = GetEntByScriptName( "injector_lightstrip" )

	wait 6.5

	PlayPA( "SLONE_PHASE_1" )
	EmitSoundOnEntity( injector, "skyway_scripted_injector_stage1" )
	file.currentPhase = 1
	file.idealPhase = 1
	SetGlobalNetInt( "injectorRoomPhase", file.currentPhase )
	Remote_CallFunction_NonReplay( player, "ServerCallback_InjectorNextPhase" )
	// thread LightstripSounds()

	while ( file.currentPhase < 6 )
	{
		string sound = "skyway_scripted_injector_stage" + file.currentPhase
		file.soundsToStop.append( sound )
		waitthread WaitNextPhase()
		file.currentPhase += 1
		SetGlobalNetInt( "injectorRoomPhase", file.currentPhase )
		Remote_CallFunction_NonReplay( player, "ServerCallback_InjectorNextPhase" )
		svGlobal.levelEnt.Signal( "StartNextPhase" )

		if ( file.currentPhase != 6 )
		{
			thread PlayPA( "SLONE_PHASE_" + file.currentPhase )
		}

		EmitSoundOnEntity( injector, "skyway_scripted_injector_stage" + file.currentPhase )

		switch ( file.currentPhase )
		{
			case 1:
				lightstrip.SetModel( LIGHTSTRIP_1 )
				break
			case 2:
				break
			case 3:
				lightstrip.SetModel( LIGHTSTRIP_2 )
				break
			case 4:
				break
			case 5:
				thread InjectorLightUp( player, 0.75, false )
				lightstrip.SetModel( LIGHTSTRIP_3 )
				break
			case 6:
				lightstrip.SetModel( LIGHTSTRIP_4 )
				break
		}
	}

	float startTime = Time()

	if ( !Flag( "StoppingInjector" ) )
	{
		// EndSignal( level, "StoppingInjector" )
		// while ( Time() < startTime + 200.0 || Time() < file.lastActionTime + 200.0 )
		// 	WaitFrame()
		// Remote_CallFunction_Replay( player, "ServerCallback_InjectorFired" )
		// waitthread InjectorFire()
		// ReloadForMissionFailure()
		// delaythread( 2.0 ) ScreenFadeToBlackForever( player )
	}
}

void function LightstripSounds()
{
	svGlobal.levelEnt.EndSignal( "StartNextPhase" )

	array<string> names = [
		"skyway_scripted_lightstrips_1L",
		"skyway_scripted_lightstrips_1R",
		"skyway_scripted_lightstrips_2L",
		"skyway_scripted_lightstrips_2R",
		"skyway_scripted_lightstrips_3L",
		"skyway_scripted_lightstrips_3R",
		"skyway_scripted_lightstrips_4L_ring",
		"skyway_scripted_lightstrips_4R_ring",
	]

	while ( 1 )
	{
		foreach ( name in names )
		{
			entity org = GetEntByScriptName( name )
			int currentPhase = maxint( file.currentPhase, 1 )
			string sound = name + "_stage" + currentPhase
			EmitSoundAtPosition( TEAM_ANY, org.GetOrigin(), sound )
		}

		wait 2.5
	}
}

void function ForceNextPhase( float delay = -1.0 )
{
	svGlobal.levelEnt.Signal( "ForceNextPhase" )
	svGlobal.levelEnt.EndSignal( "StartNextPhase" )
	svGlobal.levelEnt.EndSignal( "ForceNextPhase" )

	if ( file.currentPhase >= file.idealPhase )
		return

	if ( delay < 0 )
		wait RandomFloatRange( 7.0, 10.0 )
	else
		wait delay

	svGlobal.levelEnt.Signal( "StartNextPhase" )
}

void function WaitNextPhase()
{
	svGlobal.levelEnt.EndSignal( "StartNextPhase" )

	if ( file.currentPhase < file.idealPhase )
		thread ForceNextPhase()

	wait file.phaseDelays[ file.currentPhase-1 ]
}

void function SloneFightMobs( entity player, entity slone, array<string> spawnerNames, bool viewSpawn, string line1, string line2, string line3 )
{
	slone.EndSignal( "OnDeath" )

	WaitFrame()

	ForceTitanSustainedDischargeEnd( slone )
	while( slone.Anim_IsActive() )
		WaitFrame()

	slone.SetActiveWeaponByName( "mp_titanweapon_particle_accelerator" )

	vector fwd = AnglesToForward( slone.GetAngles() )
	entity soul = slone.GetTitanSoul()

	SetStanceKneeling( soul )
	// slone.SetThinkEveryFrame( true )

	slone.SetInvulnerable()
	slone.SetNoTarget( true )
	slone.EnableNPCFlag( NPC_IGNORE_ALL )
	HideName( slone )
	thread PlayDialogue( line1, slone )

	entity mover = CreateScriptMover( slone.GetOrigin(), slone.GetAngles() )

	waitthread PlayAnimGravity( slone, "at_mortar_stand2knee", mover )
	// slone.SetThinkEveryFrame( false )
	// SetStanceKneel( soul )
	thread PlayAnimGravity( slone, "at_mortar_knee_idle", mover )

	vector oldOrigin = slone.GetOrigin()
	slone.SetParent( mover )

	if ( Rodeo_IsAttached( player ) )
	{
		player.Signal( "RodeoOver" )
	}

	PhaseShift( slone, 0.0, 9999 )
	mover.NonPhysicsMoveTo( mover.GetOrigin() + <0,0,2000>, 2, 2, 0 )
	entity battery = CreateTitanBattery( slone.GetOrigin() )
	battery.SetVelocity( < 0, 0, 400 > )

	foreach ( ai in GetNPCArrayOfEnemies( player.GetTeam() ) )
	{
		if ( !IsTurret( ai ) )
			ai.AssaultSetGoalRadius( 5000 )
	}

	foreach ( spawnerName in spawnerNames )
	{
		array<entity> spawners = GetEntArrayByScriptName( spawnerName )
		if ( !viewSpawn )
		{
			foreach ( ent in spawners )
			{
				thread TriggerSpawnSpawner( ent )
			}
		}
		else
		{
			thread SpawnBestSpawn( player, spawners, slone )
		}
	}

	foreach ( ai in GetNPCArrayOfEnemies( player.GetTeam() ) )
	{
		ai.SetEnemy( player )
	}

	wait 2.0

	thread PlayDialogue( line2, slone )

	wait 2.0

	float maxdist = 4000
	while ( GetNPCArrayEx( "npc_titan", TEAM_IMC, TEAM_ANY, player.GetOrigin(), maxdist ).len() + GetNPCArrayEx( "npc_super_spectre", TEAM_IMC, TEAM_ANY, player.GetOrigin(), maxdist ).len() > 2 )
		WaitFrame()

	wait 5.0

	// SetStanceStanding( soul )
	// if ( IsValid(soul.soul.bubbleShield) )
	// 	soul.soul.bubbleShield.Destroy()
	// SetStanceStand( soul )

	array<entity> testPoints = GetEntArrayByScriptName( "slone_fight_phase_3_a" )
	entity spawner = GetBestSpawnerForPlayer( player, testPoints, slone )

	slone.ClearParent()
	vector origin = StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) )
	slone.SetOrigin( origin )
	fwd = player.GetOrigin() - slone.GetOrigin()
	vector angles = VectorToAngles( fwd )
	slone.SetAngles( <0,angles.y,0> )
	mover.SetAngles( <0,angles.y,0> )
	DropToGround( slone )
	mover.SetOrigin( slone.GetOrigin() )
	CancelPhaseShift( slone )

	waitthread PlayAnimGravity( slone, "at_mortar_knee2stand", mover )
	waitthread PlayDialogue( line3, slone )

	slone.ClearInvulnerable()
	slone.SetNoTarget( false )
	slone.DisableNPCFlag( NPC_IGNORE_ALL )
	slone.SetEnemy( player )
	ShowName( slone )

	mover.Destroy()
}

void function SpawnBestSpawn( entity player, array<entity> spawners, entity slone )
{
	entity spawner = GetBestSpawnerForPlayer( player, spawners, slone )
	vector fwd = player.GetOrigin() - spawner.GetOrigin()
	vector angles = VectorToAngles( fwd )

	table spawnerKeyValues = spawner.GetSpawnEntityKeyValues()
	if ( "script_delay" in spawnerKeyValues && float( spawnerKeyValues[ "script_delay" ] ) > 0 )
		wait float( spawnerKeyValues[ "script_delay" ] )

	entity npc = spawner.SpawnEntity()
	npc.SetAngles( <0,angles.y,0> )
	DispatchSpawn( npc )
}


entity function GetBestSpawnerForPlayer( entity player, array<entity> spawners, entity slone )
{
	vector p = player.GetOrigin()
	vector s = slone.GetOrigin()

	Assert( spawners.len() > 0 )

	array<entity> validSpawners
	foreach( entity spawner in spawners )
	{
		if ( Distance( StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) ), p ) < 400 )
			continue
		if ( Distance( StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) ), s ) < 400 )
			continue
		validSpawners.append( spawner )
	}

	entity bestSpawner
	foreach( entity spawner in validSpawners )
	{
		if ( !PlayerCanSeePos( player, StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) ), true, 40 ) )
			continue
		bestSpawner = spawner
		break
	}

	if ( bestSpawner == null )
	{
		foreach( entity spawner in validSpawners )
		{
			if ( !PlayerCanSeePos( player, StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) ), false, 40 ) )
				continue
			bestSpawner = spawner
			break
		}
	}

	// If we didn't find a spawner the player can see just select a random one
	if ( !IsValid( bestSpawner ) )
		bestSpawner = validSpawners.getrandom()
	Assert( IsValid( bestSpawner ) )

	return bestSpawner
}

entity function SpawnHoloMarder( vector origin, vector angles )
{
	entity marder = CreatePropDynamic( MARDER_HOLOGRAM_MODEL, origin, angles, 0 ) // 0 = no collision
	marder.SetSkin( 1 )
	int attachIndex = marder.LookupAttachment( "CHESTFOCUS" )
	StartParticleEffectOnEntity( marder, GetParticleSystemIndex( GHOST_TRAIL_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	StartParticleEffectOnEntity( marder, GetParticleSystemIndex( GHOST_FLASH_EFFECT ), FX_PATTACH_POINT, attachIndex )
	EmitSoundOnEntity( marder, "skyway_scripted_hologram_loop" )
	return marder
}

void function MarderInjectorRoom( entity scriptRef )
{
	svGlobal.levelEnt.WaitSignal( "BossTitanStartAnim" )

	entity marder = SpawnHoloMarder( scriptRef.GetOrigin(), scriptRef.GetAngles() )

	entity mover = CreateScriptMover( scriptRef.GetOrigin() - <0,0,100>, scriptRef.GetAngles() )
	waitthread PlayAnim( marder, "pt_injectore_room_villain", mover )
	mover.Destroy()

	EmitSoundOnEntity( marder, "skyway_scripted_hologram_end" )
	marder.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 0 )
}

void function BliskInjectorRoomPilot( entity scriptRef )
{
	//Spawn Blisk
	entity blisk = SpawnBliskPilot_InjectorRoom()
	blisk.SetModel( SW_BLISK_MODEL )
	blisk.SetInvulnerable()
	blisk.SetNoTarget( true )
	blisk.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	blisk.DisableNPCFlag( NPC_ALLOW_PATROL )
	TakePrimaryWeapon( blisk )
	thread PlayAnimTeleport( blisk, "pt_injectore_room_blisk_pose", scriptRef )

	blisk.Hide()

	entity trigger = GetEntByScriptName( "injector_blisk_start_anim" )
	trigger.WaitSignal( "OnTrigger" )

	blisk.Show()

	svGlobal.levelEnt.WaitSignal( "BossTitanStartAnim" )
	waitthread PlayAnimTeleport( blisk, "pt_injectore_room_blisk", scriptRef )
	blisk.Destroy()
}

entity function SpawnBliskPilot_InjectorRoom()
{
	entity spawner = GetEntByScriptName(  "blisk_pilot" )
	entity blisk = spawner.SpawnEntity()
	blisk.SetInvulnerable()
	DispatchSpawn( blisk )
	return blisk
}

void function BliskInjectorRoomTitan( entity scriptRef )
{
	//Spawn Blisk
	entity bliskTitan = SpawnBliskTitan_InjectorRoom()
	bliskTitan.SetInvulnerable()
	bliskTitan.SetNoTarget( true )
	bliskTitan.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	bliskTitan.DisableNPCFlag( NPC_ALLOW_PATROL )

	entity trigger = GetEntByScriptName( "injector_blisk_start_move" )
	trigger.WaitSignal( "OnTrigger" )

	AnimRefPoint info = GetAnimStartInfo( bliskTitan, "ht_injectore_room_blisk_pose", scriptRef )
	entity ref = GetEntByScriptName( "bt_sacrifice" )
	bliskTitan.SetThinkEveryFrame( true )
	bliskTitan.AssaultSetGoalRadius( 256 )
	bliskTitan.AssaultPoint( ref.GetOrigin() )
	bliskTitan.SetMoveAnim( "at_patrol_walk" )

	trigger = GetEntByScriptName( "injector_blisk_start_anim" )
	trigger.WaitSignal( "OnTrigger" )

	thread PlayAnimTeleport( bliskTitan, "ht_injectore_room_blisk_pose", scriptRef )

	HideCrit( bliskTitan )
	bliskTitan.SetValidHealthBarTarget( false )
	HideName( bliskTitan )

	svGlobal.levelEnt.WaitSignal( "BossTitanStartAnim" )

	StopMusicTrack( "music_skyway_15_blueroom" )
	PlayMusic( "music_skyway_16_slonefight" )

	waitthread PlayAnimTeleport( bliskTitan, "ht_injectore_room_blisk", scriptRef )
	bliskTitan.Destroy()
}

entity function SpawnBliskTitan_InjectorRoom()
{
	entity spawner = GetEntByScriptName( "blisk_titan" )
	entity bliskTitan = spawner.SpawnEntity()
	DispatchSpawn( bliskTitan )
	return bliskTitan
}

/*
  ____  _ _     _    _         ______                          _ _
 |  _ \| (_)   | |  ( )       |  ____|                        | | |
 | |_) | |_ ___| | _|/ ___    | |__ __ _ _ __ _____      _____| | |
 |  _ <| | / __| |/ / / __|   |  __/ _` | '__/ _ \ \ /\ / / _ \ | |
 | |_) | | \__ \   <  \__ \   | | | (_| | | |  __/\ V  V /  __/ | |
 |____/|_|_|___/_|\_\ |___/   |_|  \__,_|_|  \___| \_/\_/ \___|_|_|
*/

void function BliskFarewellStartPointSetup( entity player )
{
	entity scriptRef = GetEntByScriptName( "bt_sacrifice" )
	TeleportPlayers( scriptRef )
	entity BT = player.GetPetTitan()
	BT.SetOrigin( scriptRef.GetOrigin() )
	BT.SetAngles( scriptRef.GetAngles() )
	PilotBecomesTitan( player, BT )
  	BT.Destroy()

	foreach( player in GetPlayerArray() )
		MakePlayerTitan( player, player.GetOrigin() )
}

void function BliskFarewellSkipped( entity player )
{
	NextState()

	entity core = GetEntByScriptName( "core" )
	core.Hide()
	entity coreRef = GetEntByScriptName( "core_origin" )
	entity coreEnergy = CreateCoreEnergy( coreRef.GetOrigin() )
	HolsterAndDisableWeapons( player )
	Disembark_Disallow( player )

	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	AddCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )
}

void function RemindObjective( string endFlag, float initialDelay )
{
	EndSignal( level, endFlag )

	wait initialDelay
	Objective_Remind()

	while ( 1 )
	{
		wait 12
		Objective_Remind()
	}
}

void function SP_BliskFarewellThread( entity player )
{
	NextState()

	entity sequenceRef
	file.idealPhase = 6
	thread ForceNextPhase( 3 )
	file.lastActionTime = Time() + 60.0

	CheckPoint()

	StopMusicTrack( "music_skyway_16_slonefight" )
	PlayMusic( "music_skyway_17_slonedies" )

	Objective_Remind()
	thread RemindObjective( "StoppingInjector", 5.0 )

	delaythread( 1.5 ) PlayDialogue( "BLISK_FAREWELL_1", player )
	
	// this is made so only player0 can be supported
	waitthread Init_BTLoadingBayClimb( "SKYWAY_HINT_DISABLE_INJECTOR", "SKYWAY_HINT_DISABLE_INJECTOR_PC" )
	
	foreach( entity p in GetPlayerArray() )
	{
		Disembark_Disallow( p )
		MakePlayerTitan( p, p.GetOrigin() )
	}

	SetGlobalNetBool( "titanOSDialogueEnabled", false )

	Objective_Clear()

	Remote_CallFunction_NonReplay( player, "ServerCallback_ShowMashHint" )

	player.GetFirstPersonProxy().SetSkin( 3 )

	HolsterAndDisableWeapons( player )
	Disembark_Disallow( player )

	FlagSet( "StoppingInjector" )

	float duration = player.GetSequenceDuration( "bt_skyway_core_railgun_stop_01" )

	entity injector = GetEntByScriptName( "injector_gun" )
	sequenceRef = GetEntByScriptName( "injector_room_sequence_ref" )
	entity animRef = CreateScriptMover( sequenceRef.GetOrigin(), sequenceRef.GetAngles(), 0 )
	FirstPersonSequenceStruct btSequence
	btSequence.firstPersonAnim = "btpov_skyway_core_railgun_stop_01"
	btSequence.thirdPersonAnim = "bt_skyway_core_railgun_stop_01"
	btSequence.attachment = "ref"
	thread PlayAnim( injector, "skyway_core_railgun_bt_stop_01", animRef )

	player.GetFirstPersonProxy().SetSkin( 3 )

	thread FirstPersonSequence( btSequence, player, animRef )
	EmitSoundOnEntity( player, "skyway_scripted_injector_bt_begin_failed_injector_attempt" )
	delaythread( 0.1 ) PlayPA( "SLONE_PHASE_6" )

	wait duration - 1.6 - 0.6

	waitthread InjectorFire( false )
	thread InjectorSpoolDown( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 2 )

	StopMusicTrack( "music_skyway_17_slonedies" )
	PlayMusic( "music_skyway_18_backblast" )

	CreateShake( player.GetOrigin(), 5, 105, 1.25, 768 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	thread FlashWhite( player )
	StatusEffect_AddTimed( player, eStatusEffect.emp, 1.0, 1.0, 0.2 )
	EmitSoundOnEntity( player, "titan_healthbar_tier1_down_1P" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_HideMashHint" )

	level.nv.coreSoundActive = 2
	wait 0.2
	thread BliskFarewellRadioPlay( player )
	Remote_CallFunction_Replay( player, "ServerCallback_FlickerCockpitOff" )
	wait 1.4

	float fadetime = 0.1
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 1.0, 0.1, 0 )
	ScreenFadeToBlack( player, fadetime, 5.0 )

	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	AddCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )

	array<entity> npcs = GetNPCArray()
	npcs.extend( GetProjectileArray() )
	foreach ( n in npcs )
	{
		n.Destroy()
	}

	ClearGenerators()
	array<entity> batteries = GetEntArrayByClass_Expensive( "item_titan_battery" )
	foreach ( b in batteries )
	{
		b.Destroy()
	}
	array<entity> weapons = GetWeaponArray( true )
	foreach ( w in weapons )
	{
		w.Destroy()
	}

	wait fadetime

	entity core = GetEntByScriptName( "core" )
	core.Hide()
	entity coreRef = GetEntByScriptName( "core_origin" )
	entity coreEnergy = CreateCoreEnergy( coreRef.GetOrigin() )
	CheckPoint_Silent()
	sequenceRef = GetEntByScriptName( "injector_room_sequence_ref" )
	player.SetInvulnerable()
	player.ClearParent()
	animRef.Destroy()
	ClearPlayerAnimViewEntity( player )
	FlagClear( "OnLoadSaveGame_PlayerRecoveryEnabled" )

	thread PlayAnimTeleport( injector, "skyway_core_railgun_bt_enter_short_idle", sequenceRef )

	entity lightstrip = GetEntByScriptName( "injector_lightstrip" )
	lightstrip.Hide()

	waitthread PlayerBlankCockpit( sequenceRef, player )

	thread PlayerCardThrow( sequenceRef, player )

	waitthread BliskFootstepShakes( player )

	thread BliskCardThrowPilot( sequenceRef, player )
	thread BliskCardThrowTitan( sequenceRef )

	FlagWait( "BliskFareweelDone" )
	FlagWait( "BliskFareweelPlayerGetup" )
}

void function InjectorFire( bool fireSound = true )
{
	entity injector = GetEntByScriptName( "injector_gun" )

	foreach ( sound in file.soundsToStop )
	{
		StopSoundOnEntity( injector, sound )
	}

	if ( fireSound )
		EmitSoundOnEntity( injector, "Outpost207_Railgun_Fire" )

	wait 0.6

	int cannonAttach = injector.LookupAttachment( "rail_flap_0" )
	vector cannonAttachOrg = injector.GetAttachmentOrigin( cannonAttach )
	vector cannonAttachAng = injector.GetAttachmentAngles( cannonAttach )

	entity beamFX = PlayFX( FX_CANNON_BEAM, cannonAttachOrg, cannonAttachAng )
	beamFX.FXEnableRenderAlways()

	cannonAttach = injector.LookupAttachment( "rail_flap_0" )
	cannonAttachOrg = injector.GetAttachmentOrigin( cannonAttach )
	cannonAttachAng = injector.GetAttachmentAngles( cannonAttach )

	vector fwd = AnglesToForward( cannonAttachAng )
	vector up = AnglesToUp( cannonAttachAng )
	vector rgt = AnglesToRight( cannonAttachAng )

	entity beamFX2 = PlayFX( $"P_rail_fire_flash", cannonAttachOrg, VectorToAngles( rgt ) )
	beamFX2.FXEnableRenderAlways()
}

void function BliskFarewellRadioPlay( entity player )
{
	wait 1.0
	waitthread PlayDialogue( "BLISK_FAREWELL_b_1", player )
	wait 1.0
	waitthread PlayDialogue( "BLISK_FAREWELL_b_4", player )
	wait 7.0
	waitthread PlayDialogue( "BT_SACRIFICE_1", player )
	wait 2.0
	waitthread PlayDialogue( "BLISK_FAREWELL_b_5", player )

	// waitthread PlayDialogue( "BLISK_FAREWELL_b_2", player )
	// wait 3.8
	// waitthread PlayDialogue( "BLISK_FAREWELL_b_3", player )
	// wait 1.1
	// wait 0.3
	// waitthread PlayDialogue( "BLISK_FAREWELL_b_5", player )
	// wait 0.3
	// waitthread PlayDialogue( "BT_SACRIFICE_3", player )
	// wait 1.3

	FlagWait( "BliskFareweelDone" )
	thread ThrowIsOurOnlyOptionLines( player )

	wait 5.0 // wait for 1st "throw is our only option" line

	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.REBOOT )

	wait 12.0 // wait for 2nd "throw is our only option" line

	FlagSet( "BliskFarewellRadioPlayDone" )
}

void function ThrowIsOurOnlyOptionLines( entity player )
{
	waitthread PlayDialogue( "BLISK_FAREWELL_a_5", player )
	waitthread PlayDialogue( "BLISK_FAREWELL_a_5b", player )
}

void function FlashWhite( entity player, float fadeIntime = 0.1, float fadeOutTime = 0.4, float alpha = 155.0 )
{
	float fadetime = fadeIntime
	ScreenFadeToColor( player, 255, 255, 255, alpha, fadetime, fadetime )
	wait fadetime
	fadetime = fadeOutTime
	ScreenFadeFromColor( player, 255, 255, 255, alpha, fadetime, fadetime )
	wait fadetime
}

void function BliskFootstepShakes( entity player )
{
	thread BlankCockpitDialogue( player )
	wait 3.0
	FakeBliskFootstep( player, 500, 1 )
	wait 2.0
	FakeBliskFootstep( player, 300, 2 )
	wait 2.0
	FakeBliskFootstep( player, 100, 5 )
	wait 2.0
	FakeBliskFootstep( player, 100, 5 )
	wait 2.0
}

void function BlankCockpitDialogue( entity player )
{
	wait 4.0

	delaythread( 3.5 ) PlayDialogue( "BLISK_FAREWELL_a_6", player )
	waitthread PlayDialogue( "BLISK_FAREWELL_a_4", player )
	wait 0.5
}

void function FakeBliskFootstep( entity player, float dist, float intensity )
{
	vector ref = <7748, 13406, 5632>
	vector fwd = Normalize(ref - player.EyePosition())
	// EmitSoundAtPosition( TEAM_ANY, player.GetOrigin() + fwd*dist, "exo_stomp" )
	EmitSoundOnEntity( player, "exo_stomp" )
	CreateShake( player.GetOrigin(), intensity, 105, 1.25, 768 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
}

void function PlayerBlankCockpit( entity scriptRef, entity player )
{
	if ( player.IsTitan() )
	{
		//Remove them from their titan and spawn bt for sequence
		entity titan = CreateAutoTitanForPlayer_ForTitanBecomesPilot( player )
		TitanBecomesPilot( player, titan )
		titan.Destroy()
		CreatePetTitan( player, player.GetOrigin(), player.GetAngles() )
		HolsterAndDisableWeapons( player )
	}
	ScreenFadeFromBlack( player, 3.5, 3.5 )

	//----------------------------------
	// Player torture room sequence
	//------------------------------------
	entity moverIntro = CreateOwnedScriptMover( scriptRef ) //need a mover for first person sequence

	moverIntro.SetOrigin( moverIntro.GetOrigin() + <0,0,-20> )

	FirstPersonSequenceStruct sequenceBliskCardThrow
	sequenceBliskCardThrow.blendTime = 0.0
	sequenceBliskCardThrow.attachment = "ref"
	sequenceBliskCardThrow.firstPersonAnim = "pov_blisk_taunt_scene_player"
	sequenceBliskCardThrow.thirdPersonAnim = "pt_blisk_taunt_scene_player"
	sequenceBliskCardThrow.viewConeFunction = ViewConeCardThrow
	thread FirstPersonSequence( sequenceBliskCardThrow, player, moverIntro )

	player.SetAnimNearZ( 1 )
	entity fakePlayer = CreatePropDynamic( player.GetModelName() )
	thread PlayAnimTeleport( fakePlayer, "pt_blisk_taunt_scene_player", scriptRef )

	entity bt = player.GetPetTitan()
	thread PlayAnimTeleport( bt, "BT_blisk_taunt_scene_cam_third", scriptRef )

	thread CreateBTCockpitDamagedFX( bt )
	entity fx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( COCKPIT_LIGHT ), bt.GetAttachmentOrigin( bt.LookupAttachment("OFFSET") ) + <0,0,16> , <0,0,0> )
	delaythread( 14 ) EmitSoundOnEntity( player, "skyway_scripted_injector_UI_lightsout" )

	array<int> ids = []
	ids.append( StatusEffect_AddEndless( player, eStatusEffect.move_slow, 0.8 ) )
	ids.append( StatusEffect_AddEndless( player, eStatusEffect.turn_slow, 0.25 ) )

	wait 0.5
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0.0, 40.0, EASING_SINE_IN )
	thread BlankCockpitShakes( player )
	wait 2.7
	waitthread PlayDialogue( "BLISK_FAREWELL_a_1", player )
	wait 0.5
	waitthread PlayDialogue( "BLISK_FAREWELL_a_2", player )

	float fadetime = 0.25
	ScreenFadeToBlack( player, fadetime, fadetime )
	wait fadetime
	SetGlobalNetBool( "titanOSDialogueEnabled", false )
	DoomMyTitan( player )
	EffectStop( fx )

	EmitSoundOnEntity( player, "skyway_scripted_injector_UI_lightsout_thruauxpoweronline" )

	player.ClearParent()
	Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 2 )
	PilotBecomesTitan( player, bt )
  	bt.Destroy()
  	ScreenFadeFromBlack( player, 0.25, 0.25 )

  	foreach ( id in ids )
  	{
  		StatusEffect_Stop( player, id )
  	}

	moverIntro.Destroy()
	fakePlayer.Destroy()
	player.ClearAnimNearZ()

  	delaythread( 1.25 ) PlayDialogue( "BLISK_FAREWELL_a_3", player )
}

void function BlankCockpitShakes( entity player )
{
	wait 10.0
	FakeBliskFootstep( player, 700, 0.05 )
	wait 4.0
	FakeBliskFootstep( player, 700, 0.1 )
	wait 2.0
	FakeBliskFootstep( player, 700, 0.1 )
	wait 2.0
}

void function PlayerCardThrow( entity scriptRef, entity player )
{
	player.SetNoTarget( true )

	//----------------------------------
	// Player torture room sequence
	//------------------------------------
	entity moverIntro = CreateOwnedScriptMover( scriptRef ) //need a mover for first person sequence

	FirstPersonSequenceStruct sequenceBliskCardThrow
	sequenceBliskCardThrow.blendTime = 0.0
	sequenceBliskCardThrow.attachment = "ref"
	sequenceBliskCardThrow.firstPersonAnim = "BT_blisk_taunt_scene_cam_first"
	sequenceBliskCardThrow.thirdPersonAnim = "BT_blisk_taunt_scene_cam_third"
	sequenceBliskCardThrow.viewConeFunction = ViewConeZero

	thread FirstPersonSequence( sequenceBliskCardThrow, player, moverIntro )

	Remote_CallFunction_Replay( player, "ServerCallback_StartCockpitLook", true )
	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.START )
	player.SetInvulnerable()

	FlagWait( "BliskFareweelDone" )

	// thread BTSacrificeDialogue_BTMemory( player )

	player.ClearInvulnerable()
	player.SetNoTarget( false )

	Signal( level, "StopDOFTracking" )

	entity loadingBayButton = GetEntByScriptName( "loading_bay_useable" )
	// Objective_Set( "#SKYWAY_OBJECTIVE_LOAD_BT", loadingBayButton.GetOrigin() )

	FlagSet( "BliskFareweelPlayerGetup" )
}

void function DoomMyTitan( entity player )
{
	entity titan
	if ( player.IsTitan() )
		titan = player
	else
		titan = player.GetPetTitan()

	if ( !IsAlive( titan ) )
		return

	if ( GetDoomedState( titan ) )
		return

	entity soul = titan.GetTitanSoul()
	soul.SetShieldHealth( 0 )

	titan.TakeDamage( titan.GetHealth(), null, null, { damageSourceId=damagedef_suicide, scriptType = DF_SKIP_DAMAGE_PROT } )

	player.Server_SetDodgePower( 0.0 )
	player.SetDodgePowerDelayScale( 0.0 )
	player.SetPowerRegenRateScale( 0.0 )
	SoulTitanCore_SetNextAvailableTime( soul, 0.0 )

	entity weapon = player.GetActiveWeapon()
	if ( weapon != null )
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
}

void function ViewConeCardThrow( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -25 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -20 )
	player.PlayerCone_SetMaxPitch( 20 )
}

void function BliskCardThrowTitan( entity scriptRef )
{
	entity bliskTitan = SpawnBliskTitan_InjectorRoom()
	bliskTitan.DisableHibernation()
	waitthread PlayAnimTeleport( bliskTitan, "ht_blisk_taunt_scene_blisk", scriptRef )
	bliskTitan.Destroy()
}

void function BliskCardThrowPilot( entity scriptRef, entity player )
{
	entity card = CreatePropDynamic( CARD_MODEL )
	thread PlayAnimTeleport( card, "blisk_taunt_scene_card", scriptRef )

	entity blisk = SpawnBliskPilot_InjectorRoom()
	blisk.DisableHibernation()
	blisk.SetModel( SW_BLISK_MODEL )
	TakePrimaryWeapon( blisk )
	thread TrackTargetAttachmentWithDOF_ANIMATION( player, blisk, "HEADFOCUS" , 0, 256, 1.0 )

	AddAnimEvent( blisk, "cockpit_thump", HitPlayerCockpit, player )

	//AddAnimEvent( blisk, "dof_blisk_face", FocusOnBliskFace )
	delaythread( 5 ) FocusOnBliskFace( blisk )
	waitthread PlayAnimTeleport( blisk, "pt_blisk_taunt_scene_blisk", scriptRef )
	blisk.Destroy()
	FlagSet( "BliskFareweelDone" )
}

void function HitPlayerCockpit( entity blisk )
{
	entity player = expect entity( GetOptionalAnimEventVar( blisk, "cockpit_thump" ) )
	Remote_CallFunction_Replay( player, "ServerCallback_CockpitThump" )
}

void function BTCardThrow( entity scriptRef, entity player )
{
	entity bt = player.GetPetTitan()
	waitthread PlayAnimTeleport( bt, "BT_blisk_taunt_scene", scriptRef )
}

/*
  ____ _______      _____                 _  __ _
 |  _ \__   __|    / ____|               (_)/ _(_)
 | |_) | | |      | (___   __ _  ___ _ __ _| |_ _  ___ ___
 |  _ <  | |       \___ \ / _` |/ __| '__| |  _| |/ __/ _ \
 | |_) | | |       ____) | (_| | (__| |  | | | | | (_|  __/
 |____/  |_|      |_____/ \__,_|\___|_|  |_|_| |_|\___\___|
*/

void function BTSacrificeStartPointSetup( entity player )
{
	entity scriptRef = GetEntByScriptName( "bt_sacrifice" )
	TeleportPlayers( scriptRef )
	entity BT = player.GetPetTitan()
	BT.SetOrigin( scriptRef.GetOrigin() )
	BT.SetAngles( scriptRef.GetAngles() )
	PilotBecomesTitan( player, BT )
  	BT.Destroy()

	entity sequenceRef = GetEntByScriptName( "injector_room_sequence_ref" )
  	entity injector = GetEntByScriptName( "injector_gun" )
	thread PlayAnimTeleport( injector, "skyway_core_railgun_bt_enter_short_idle", sequenceRef )

	entity moverIntro = CreateOwnedScriptMover( sequenceRef ) //need a mover for first person sequence

	FirstPersonSequenceStruct sequenceBliskCardThrow
	sequenceBliskCardThrow.blendTime = 0.0
	sequenceBliskCardThrow.attachment = "ref"
	sequenceBliskCardThrow.firstPersonAnim = "BT_blisk_taunt_scene_cam_first"
	sequenceBliskCardThrow.thirdPersonAnim = "BT_blisk_taunt_scene_cam_third"
	sequenceBliskCardThrow.viewConeFunction = ViewConeZero
	
	foreach( player in GetPlayerArray() )
	{
		thread FirstPersonSequence( sequenceBliskCardThrow, player, moverIntro )

		Remote_CallFunction_Replay( player, "ServerCallback_StartCockpitLook", true )
	}

	thread BTSacrificeDialogue_BTMemory( GetPlayer0() )

	FlagSet( "BliskFarewellRadioPlayDone" )
	FlagClear( "OnLoadSaveGame_PlayerRecoveryEnabled" )

	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.COMPLETE_PROTOCOL_1 )
	SetGlobalNetBool( "titanOSDialogueEnabled", false )
	foreach( player in GetPlayerArray() )
		DoomMyTitan( player )
}

void function BTSacrificeSkipped( entity player )
{
	StartCoreDebrisRotation()
	StartFloatingDebrisRotation()
	HurtleTest()
	FlagSet( "StartLandingAreaRise" )

	//Don't Fail Mission When BT Dies
	FlagSet( "TitanDeathPenalityDisabled" )
	entity bt = player.GetPetTitan()
	bt.Destroy()
	RemoveCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )

	NextState()
}

void function SP_BTSacrificeThread( entity player )
{
	entity soul = player.GetTitanSoul()
	StatusEffect_AddEndless( soul, eStatusEffect.move_slow, 0.8 )
	StatusEffect_AddEndless( soul, eStatusEffect.turn_slow, 0.3 )
	player.SetPlayerSettingsWithMods( "titan_buddy_slow_walk", [] )
	player.Server_TurnDodgeDisabledOn()
	CheckPoint_Silent()
	// waitthread Init_BTLoadingBayClimb( "#SKYWAY_HINT_ENTER_INJECTOR" , "#SKYWAY_HINT_ENTER_INJECTOR_PC" )
	waitthread EjectionSequence( player )

	//FlagWait( "BTSacrificeDone" )
}

void function BTSacrificeDialogue( entity player )
{
	svGlobal.levelEnt.Signal( "BTSacrificeDialogue" )

	waitthread PlayDialogue( "BT_SACRIFICE_2", player )
	wait 0.5
	waitthread PlayDialogue( "BT_SACRIFICE_3", player )
	wait 0.5

	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.BEGIN_PROTOCOL_2 )

	thread PlayDialogue( "BT_SACRIFICE_5", player )
	wait 10.0 // Manual wait time since the dialogue has random echoes that we want to ignore
	// waitthread PlayDialogue( "BT_SACRIFICE_6", player )
	// wait 0.5
	waitthread PlayDialogue( "BT_SACRIFICE_7", player )
	wait 0.25
	thread PlayDialogue( "BT_SACRIFICE_8", player )
	wait 4.75 // Manual wait time since the dialogue has random echoes that we want to ignore
	waitthread PlayDialogue( "BT_SACRIFICE_9", player )
	wait 0.5
	thread PlayDialogue( "BT_SACRIFICE_10", player )
	wait 3.75 // Manual wait time since the dialogue has random echoes that we want to ignore
	waitthread PlayDialogue( "BT_SACRIFICE_11", player )
	wait 0.5

	FlagSet( "BTMemorySequenceDone" )

	thread BTNags( player )
}

void function BTNags( entity player )
{
	svGlobal.levelEnt.EndSignal( "BTSacrificeDialogue" )

	if ( !Flag( "BTSacrificeEnteredInjector" ) )
	{
		EndSignal( level, "BTSacrificeEnteredInjector" )
		while ( 1 )
		{
			waitthread WaitForPlayerAction( 8.0 )
			waitthread PlayDialogue( "BT_SACRIFICE_NAG_1", player )
			waitthread WaitForPlayerAction( 5.0 )
			waitthread PlayDialogue( "BT_SACRIFICE_NAG_2", player )
			waitthread WaitForPlayerAction( 8.0 )
		}
	}
}

void function WaitForPlayerAction( float timeout )
{
	file.lastPlayerActionTime = max( Time(), file.lastPlayerActionTime )

	while ( Time() - file.lastPlayerActionTime < timeout )
		wait 0.1
}

void function BTSacrificeDialogue_BTMemory( entity player )
{
	svGlobal.levelEnt.Signal( "BTSacrificeDialogue_BTMemory" )
	if ( GetGlobalNetInt( "titanRebootPhase" ) < skywayTitanCockpitStatus.BEGIN_PROTOCOLS )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_BTSacrifice_Cockpit" )
	}

	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.BEGIN_PROTOCOLS )
}

void function Init_BTLoadingBayClimb( string hintConsole, string hintPC )
{
	svGlobal.levelEnt.Signal( "Init_BTLoadingBayClimb" )
	svGlobal.levelEnt.EndSignal( "Init_BTLoadingBayClimb" )

	entity loadingBayButton = GetEntByScriptName( "loading_bay_useable" )

	entity eyeButton = CreatePropDynamic( SMALL_ROCK_01, loadingBayButton.GetOrigin(), <0,0,0>, 2, -1 )

	eyeButton.Hide()
	eyeButton.SetUsable()
	eyeButton.SetUsableRadius( 500.0 )
	eyeButton.SetUsableByGroup( "titan" )
	eyeButton.SetUsePrompts( hintConsole , hintPC )

	OnThreadEnd(
	function() : ( eyeButton )
		{
			if ( IsValid( eyeButton ) )
				eyeButton.Destroy()
		}
	)

	eyeButton.WaitSignal( "OnPlayerUse" )
}

void function KeepShowingStickHint( entity player )
{
	EndSignal( level, "BTSacrificeEnteredInjector" )

	while ( 1 )
	{
		if ( player.GetInputAxisForward() < 0.2 )
		{
			Remote_CallFunction_Replay( player, "ServerCallback_ShowStickHint" )
		}
		wait 2.0
	}
}

void function MissionFailAfterDelay( entity player, float delay, float fadeTime )
{
	player.Signal( "MissionFailAfterDelay" )
	player.EndSignal( "MissionFailAfterDelay" )

	table e
	e.missionFailed <- false

	wait delay

	OnThreadEnd(
	function() : ( player, e )
		{
			if ( !e.missionFailed )
				ScreenFadeFromBlack( player, 0.5, 0.0 )
		}
	)

	ScreenFadeToBlackForever( player, fadeTime )
	wait fadeTime
	e.missionFailed = true
	Remote_CallFunction_Replay( player, "ServerCallback_InjectorFired" )
	ReloadForMissionFailure()
}

void function EjectionSequence( entity player )
{
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( p, "ServerCallback_SetDOF", 600, 900, 1.0 )
		HolsterAndDisableWeapons( p )
		AddCinematicFlag( p, CE_FLAG_TITAN_3P_CAM )
	}

	entity core = GetEntByScriptName( "core_origin" )
	vector coreOrigin = core.GetOrigin()
	entity coreMover = CreateScriptMover( coreOrigin, <0,0,0> )

	entity glowFX = StartParticleEffectOnEntity_ReturnEntity( coreMover, GetParticleSystemIndex( CORE_GLOW_ON_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, 0 )
	entity runHurtTrigger = GetEntByScriptName( "sculptor_bottom_trigger" )
	runHurtTrigger.Disable()

	entity sequenceRef = GetEntByScriptName( "injector_room_sequence_ref" )

	player.SetInvulnerable()

	entity injector = GetEntByScriptName( "injector_gun" )

	entity animRef = CreateScriptMover( sequenceRef.GetOrigin(), sequenceRef.GetAngles(), 0 )


	FlagWait( "BliskFarewellRadioPlayDone" )

	CheckPoint_ForcedSilent()

	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.BEGIN_PROTOCOLS )

	wait 2.0

	thread PlayDialogue( "BT_SACRIFICE_4", player )

	wait 11.0 // can't reliably wait for the previous line to end since it has some echoey bits what we don't want to wait for

	file.lastActionTime = Time()
	thread BTNags( player )
	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.COMPLETE_PROTOCOL_1 )
	Objective_SetSilent( "#SKYWAY_OBJECTIVE_LOAD_BT" )
	thread RemindObjective( "MissionFailAfterDelay", 8.0 )
	thread KeepShowingStickHint( player )
	thread MissionFailAfterDelay( player, 25, 5 )
	while( player.GetInputAxisForward() < 0.2 )
		WaitFrame()
	player.Signal( "MissionFailAfterDelay" )
	Signal( level, "MissionFailAfterDelay" )
	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.GOT_PLAYER_INPUT )

	delaythread( 2 ) BTSacrificeDialogue( player )
	
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( p, "ServerCallback_StopCockpitLook" )

		p.GetFirstPersonProxy().SetSkin( 3 )

		Remote_CallFunction_Replay( p, "ServerCallback_SetDOF", 600, 900, 1.0 )
	}

	FullyHidePlayers()

	FirstPersonSequenceStruct sequenceBliskCardThrowGetup
	sequenceBliskCardThrowGetup.blendTime = 1.0
	sequenceBliskCardThrowGetup.attachment = "ref"
	sequenceBliskCardThrowGetup.firstPersonAnim = "btpov_skyway_core_railgun_get_up"
	sequenceBliskCardThrowGetup.thirdPersonAnim = "bt_skyway_core_railgun_get_up"
	sequenceBliskCardThrowGetup.viewConeFunction = ViewConeZero
	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			thread FirstPersonSequence( sequenceBliskCardThrowGetup, p, animRef )
	}
	waitthread FirstPersonSequence( sequenceBliskCardThrowGetup, player, animRef )

	int pt = 1
	int maxPt = 8

	for ( int i=pt; i<=maxPt; i++ )
	{
		file.lastPlayerActionTime = Time() + 3.0

		FirstPersonSequenceStruct btSequence
		btSequence.firstPersonAnim = "btpov_skyway_core_walk_to_railgun_pt" + pt
		btSequence.thirdPersonAnim = "bt_skyway_core_walk_to_railgun_pt" + pt
		btSequence.blendTime = 0.2
		btSequence.attachment = "ref"
		btSequence.viewConeFunction = ViewConeTight
		foreach( entity p in GetPlayerArray() )
		{
			if ( p != player )
				thread FirstPersonSequence( btSequence, p, animRef )
		}
		waitthread FirstPersonSequence( btSequence, player, animRef )

		CreateShake( player.GetOrigin(), 6, 150, 0.75, 8000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR

		FirstPersonSequenceStruct btSequenceIdle
		btSequenceIdle.firstPersonAnim = "btpov_skyway_core_walk_to_railgun_pt" + pt + "_idle"
		btSequenceIdle.thirdPersonAnim = "bt_skyway_core_walk_to_railgun_pt" + pt + "_idle"
		btSequenceIdle.blendTime = 0.2
		btSequenceIdle.attachment = "ref"
		btSequenceIdle.viewConeFunction = ViewConeTight
		foreach( entity p in GetPlayerArray() )
		{
			thread FirstPersonSequence( btSequenceIdle, p, animRef )
		}

		thread MissionFailAfterDelay( player, 2, 5 )
		while( player.GetInputAxisForward() < 0.2 )
			WaitFrame()
		player.Signal( "MissionFailAfterDelay" )

		pt++
	}

	delaythread( 3 ) Remote_CallFunction_Replay( player, "ServerCallback_SetDOF", 100.0, 2000.0, 1.0 )
	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.COMPLETE_PROTOCOL_2 )

	pt = 1
	maxPt = 6

	for ( int i=pt; i<maxPt; i++ )
	{
		file.lastPlayerActionTime = Time() + 3.0

		thread PlayAnim( injector, "skyway_core_railgun_bt_enter_short_pt" + pt, animRef )

		FirstPersonSequenceStruct btSequence
		btSequence.firstPersonAnim = "btpov_skyway_core_railgun_climb_short_pt" + pt
		btSequence.thirdPersonAnim = "bt_skyway_core_railgun_climb_short_pt" + pt
		btSequence.blendTime = 0.2
		btSequence.attachment = "ref"
		btSequence.viewConeFunction = ViewConeTight
		foreach( entity p in GetPlayerArray() )
		{
			if ( p != player )
				thread FirstPersonSequence( btSequence, p, animRef )
		}
		waitthread FirstPersonSequence( btSequence, player, animRef )

		FirstPersonSequenceStruct btSequenceIdle
		btSequenceIdle.firstPersonAnim = "btpov_skyway_core_railgun_climb_short_pt" + pt + "_idle"
		btSequenceIdle.thirdPersonAnim = "bt_skyway_core_railgun_climb_short_pt" + pt + "_idle"
		btSequenceIdle.blendTime = 0.2
		btSequenceIdle.attachment = "ref"
		btSequenceIdle.viewConeFunction = ViewConeTight
		foreach( entity p in GetPlayerArray() )
		{
			thread FirstPersonSequence( btSequenceIdle, p, animRef )
		}

		thread MissionFailAfterDelay( player, 2, 5 )
		while( player.GetInputAxisForward() < 0.2 )
			WaitFrame()
		player.Signal( "MissionFailAfterDelay" )

		pt++
	}

	FlagSet( "BTSacrificeEnteredInjector" )
	Objective_Clear()

	// pt should be maxPt
	delaythread( 13 ) Remote_CallFunction_Replay( player, "ServerCallback_GlowFlash", 2.0, 1 )
	delaythread( 3 ) Remote_CallFunction_Replay( player, "ServerCallback_SetDOF", 2000.0, 3000.0, 1.0 )
	EmitSoundOnEntity( player, "skyway_scripted_injector_bt_load_injector_start" )
	thread PlayAnim( injector, "skyway_core_railgun_bt_enter_short_pt" + pt, animRef )
	FirstPersonSequenceStruct btSequence
	btSequence.firstPersonAnim = "btpov_skyway_core_railgun_climb_short_pt" + pt
	btSequence.thirdPersonAnim = "bt_skyway_core_railgun_climb_short_pt" + pt
	btSequence.blendTime = 0.0
	btSequence.attachment = "ref"
	btSequence.viewConeFunction = ViewConeTight
	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			thread FirstPersonSequence( btSequence, p, animRef )
	}
	waitthread FirstPersonSequence( btSequence, player, animRef )

	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.BEGIN_PROTOCOL_3 )

	FirstPersonSequenceStruct btSequenceIdle
	btSequenceIdle.firstPersonAnim = "btpov_skyway_core_railgun_climb_idle"
	btSequenceIdle.thirdPersonAnim = "bt_skyway_core_railgun_climb_idle"
	btSequenceIdle.blendTime = 0.0
	btSequenceIdle.attachment = "ref"
	btSequenceIdle.useAnimatedRefAttachment = true
	btSequenceIdle.viewConeFunction = ViewConeTight
	foreach( entity p in GetPlayerArray() )
	{
		thread FirstPersonSequence( btSequenceIdle, p, animRef )
	}

	// FlagWait( "BTMemorySequenceDone" )

	delaythread( 1 ) InjectorLightUp( player, 0.75, true )
	delaythread( 5 ) StopMusicTrack( "music_skyway_18_backblast" )
	delaythread( 2 ) PlayMusic( "music_skyway_19_btinplace" )
	AddConversationCallback( "BT_Sacrifice", ConvoCallback_BTReunion )
	thread PlayerConversation( "BT_Sacrifice", player )

	table result = WaitSignal( svGlobal.levelEnt, "BT_Returns_ChoiceMade" )
	thread BT_Sacrifice_PlayFollowupDialogue( player, expect int( result.choice ) )

	if ( result.choice == 0 )
	{
		waitthread PlayDialogue( "diag_sp_extra_GB101_95_03_mcor_bt", player )
		wait 0.5
		waitthread PlayDialogue( "diag_sp_extra_GB101_94_01_mcor_bt", player )
	}
	FlagSet( "InjectorConversationDone" )

	FlagWait( "InjectorReadyToFire" )

	EmitSoundOnEntity( player, "skyway_scripted_injector_shoot_bt" )
	SyncRingsToGunShot()
	ViewConeZero( player )
	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.COMPLETE_PROTOCOL_3 )
	wait 1.5
	level.nv.coreSoundActive = 0

	foreach( entity p in GetPlayerArray() )
		Remote_CallFunction_Replay( p, "ServerCallback_ResetDOF" )

	CreateShake( player.GetOrigin(), 6, 150, 4, 800000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR

	foreach( entity p in GetPlayerArray() )
		Remote_CallFunction_Replay( p, "ServerCallback_InjectorFireScreenFX" )

	entity scriptRef = GetEntByScriptName( "bt_in_barrel" )
	//Create a mover and parent the player to the mover
	entity mover = CreateScriptMover( scriptRef.GetOrigin(), scriptRef.GetAngles(), 0 )
	mover.DisableHibernation()
	mover.SetPusher( true )
	animRef.SetParent( mover )

	mover.NonPhysicsMoveTo( coreOrigin - < 0, 0, 256 > , 12, 0, 4.0 )

	wait 3.4

	// ScreenFadeToBlackForever( player, 0.2 )
	// wait 0.2
	// ScreenFadeFromBlack( player, 0.2 )
	foreach( entity p in GetPlayerArray() )
		thread FlashWhite( p, 0.2, 0.4, 155.0 )
	wait 0.1

	//Eject the player
	foreach( entity p in GetPlayerArray() )
		p.ClearParent()

	//Don't Fail Mission When BT Dies
	FlagSet( "TitanDeathPenalityDisabled" )

	TitanSkipsDeathOnEject( player )
	SetGlobalNetInt( "titanRebootPhase", skywayTitanCockpitStatus.END )
	player.FreezeControlsOnServer()
	player.Server_SetDodgePower( 100.0 )
	player.SetDodgePowerDelayScale( 1.0 )
	player.SetPowerRegenRateScale( 1.0 )
	player.SetGroundFrictionScale( 0 )

	waitthread BTThrowsPlayer( player, mover )
	foreach( entity p in GetPlayerArray() )
		RemoveCinematicFlag( p, CE_FLAG_TITAN_3P_CAM )

	wait( .25 )

	//vector shotDir = Normalize( coreOrigin - scriptRef.GetOrigin() )
	//CreateRockBurst(coreOrigin, 5, 0, shotDir, 45, 2000, "", 5)

	wait( 2 )
	player.UnfreezeControlsOnServer()
	FlagSet( "BTSacrifice_BTExplodes" )

	level.nv.coreSoundActive = 3

	EffectStop( glowFX )
	FlagSet( "rising_world_core_FX" )
	thread BTSacrifice_BTExplodesFX( player, coreOrigin )

	entity landTarget = GetEntByScriptName( "rising_world_run" )
	//RedirectPlayerForceToTarget( "", landTarget, 5 )
	vector velocity = GetPlayerVelocityForDestOverTime( player.GetOrigin(), landTarget.GetOrigin(), 9.00 ) //10.10
	player.SetVelocity( velocity )
	player.SetGroundFrictionScale( 1.0 )
	thread NoAirControl( player )

	delaythread( 6 ) PlayDialogue( "RWR_1", player )

	wait( 5.0 )

	FlagSet( "PreLandingAreaRise" )

	array<entity> chunks = GetEntArrayByScriptName( "start_chunk_flyby" )
	foreach( c in chunks )
		c.Show()

	wait( 1.0 )

	FlagSet( "StartLandingAreaRise" )

	entity trigger = GetEntByScriptName( "rising_world_run_landing_trig" )
	trigger.WaitSignal( "OnTrigger" )

	coreMover.Destroy()

	FullyShowPlayers()
}

void function BT_Sacrifice_PlayFollowupDialogue( entity player, int choice )
{
	FlagWait( "InjectorReadyToFire" )
	FlagWait( "InjectorConversationDone" )

	wait 2.0

	waitthread PlayDialogue( "diag_sp_pilotLink_WD141_44_01_mcor_bt", player )

	FlagWait( "BT_Throws_Player" )
	thread BT_GoodbyeDialogue( player, choice )

	if ( choice != 0 )
	{
		// BT!
		// What are you doing!
		waitthread PlayDialogue( "BT_PreFire_1b", player )

		wait 2.75
		waitthread PlayDialogue( "diag_sp_extra_GB101_78_01_mcor_player", player )
	}

	FlagWait( "PreLandingAreaRise" )

	// BT...
	waitthread PlayDialogue( "BT_PreFire_1a", player )
}

void function BT_GoodbyeDialogue( entity player, int choice )
{
	entity bt
	while ( bt == null )
	{
		wait 0.1
		bt = player.GetPetTitan()
	}

	bt.WaitSignal( "BT_GOODBYE_DIALOGUE" )

	if ( choice == 0 )
	{
		waitthread PlayDialogue( "BT_GOODBYE_JACK", bt )
	}
	else
	{
		wait 0.5
		waitthread PlayDialogue( "BT_TRUST_ME", bt )
	}
}

void function BTSacrifice_BTExplodesFX( entity player, vector coreOrigin )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 2 )
	CreateShake( coreOrigin, 5, 150, 2, 8000000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	wait( 0.5 )
	CreateRockBurst( coreOrigin, 50, 0, < 0, 0, 1 >, 360, 4000, "", 15)
	wait( 0.35 )
	CreateShake( coreOrigin, 10, 150, 8, 8000000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 2 )
	Remote_CallFunction_Replay( player, "ServerCallback_GlowFlash", 5, 2 )

	StartCoreDebrisRotation()
	StartFloatingDebrisRotation()
	HurtleTest()
}

void function InjectorLightUp( entity player, float delayBetweenFlaps = 0.3, bool doFlash = false )
{
	EndSignal( svGlobal.levelEnt, "InjectorSpoolDown" )
	int numFlaps = 13
	entity injector = GetEntByScriptName( "injector_gun" )
	file.injectorFlapSet = numFlaps
	for ( int i=numFlaps; i>0; i-- )
	{
		file.injectorFlapSet = i
		int bodyGroupIndex = injector.FindBodyGroup( "flap_" + i )
		injector.SetBodygroup( bodyGroupIndex, 1 )
		wait delayBetweenFlaps
	}
	if ( doFlash )
		Remote_CallFunction_Replay( player, "ServerCallback_GlowFlash", 2, 1 )
	FlagSet( "InjectorReadyToFire" )
}

void function InjectorSpoolDown( entity player, float delayBetweenFlaps = 0.3 )
{
	Signal( svGlobal.levelEnt, "InjectorSpoolDown" )
	FlagClear( "InjectorReadyToFire" )
	int numFlaps = 13
	entity injector = GetEntByScriptName( "injector_gun" )
	for ( int i=1; i<=numFlaps; i++ )
	{
		int bodyGroupIndex = injector.FindBodyGroup( "flap_" + i )
		injector.SetBodygroup( bodyGroupIndex, 0 )
		wait delayBetweenFlaps
	}
}

void function BTThrowsPlayer( entity player, entity mover )
{
	FlagSet( "BT_Throws_Player" )
	entity titan = CreateAutoTitanForPlayer_ForTitanBecomesPilot( player )
	DispatchSpawn( titan )

	titan.SetInvulnerable()
	HideName( titan )

	titan.EndSignal( "OnDeath" )

	player.SetSyncedEntity( titan )
	HolsterViewModelAndDisableWeapons( player )  //Holstering weapon before becoming pilot so we don't play the holster animation as a pilot. Player as Titan won't play the holster animation either since it'll be interrupted by the disembark animation
	
	TriggerSilentCheckPoint( GetSaveLocation(), true )

	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			MakePlayerPilot( p, p.GetOrigin() )
	}
	TitanBecomesPilot( player, titan )
	TakeAllWeapons( titan )
	player.ForceStand()
	player.SetPetTitan( titan )
	titan.SetSkin( 3 )

	NextState()

	// GibBodyPart( titan, "left_arm" )
	// GibBodyPart( titan, "right_arm" )
	// GibBodyPart( titan, "front" )
	// GibBodyPart( titan, "hatch" )
	// GibBodyPart( titan, "hip" )
	// GibBodyPart( titan, "left_leg" )
	// GibBodyPart( titan, "right_leg" )

	thread BTThrowsPlayer_BT( titan, mover )
	waitthread BTThrowsPlayer_Player( player, mover )
	player.UnforceStand()
}

void function BTThrowsPlayer_BT( entity titan, entity mover )
{
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.0
	sequence.firstPersonAnim = ""
	sequence.thirdPersonAnim = "bt_skyway_injector_throw"
	sequence.useAnimatedRefAttachment = true
	
	waitthread FirstPersonSequence( sequence, titan, mover ) // lmao they are using a fp sequence on bt

	thread PlayAnim( titan, "bt_skyway_injector_throw_idle", mover )
	titan.SetParent( mover )
	FlagWait( "BTSacrifice_BTExplodes" )
	titan.Die()
}

void function BTThrowsPlayer_Player( entity player, entity mover )
{
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.0
	sequence.firstPersonAnim = "ptpov_skyway_injector_throw"
	sequence.thirdPersonAnim = "pt_skyway_injector_throw"
	sequence.viewConeFunction = ViewConeZero
	sequence.useAnimatedRefAttachment = true
	
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( p, "ServerCallback_GlowFlash", 1, 5 )
		delaythread( 0.75 ) Remote_CallFunction_NonReplay( p, "ServerCallback_DoRumble", 0 )
		delaythread( 1.5 ) Remote_CallFunction_NonReplay( p, "ServerCallback_SetDOF", 200, 300, 0.5 )
		delaythread( 5 ) Remote_CallFunction_NonReplay( p, "ServerCallback_DoRumble", 2 )
		delaythread( 5 ) ThrowShake( p )
		
		if ( p != player )
			thread FirstPersonSequence( sequence, p, mover )
	}
	waitthread FirstPersonSequence( sequence, player, mover )

	foreach( entity p in GetPlayerArray() )
	{
		p.ClearParent()
		ClearPlayerAnimViewEntity( p )
	}

	entity core = GetEntByScriptName( "core_origin" )
	vector fwd = Normalize( player.CameraPosition() - core.GetOrigin() )
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "disable_doublejump" ] )
	Remote_CallFunction_NonReplay( player, "ServerCallback_ResetDOF" )

	wait 0.1

	entity titan = player.GetPetTitan()
	titan.NotSolid()

	wait 0.1
	
	foreach( entity p in GetPlayerArray() )
	{
		p.SetVelocity( 900*fwd + <0,0,2000> )
		// EmitSoundOnEntity( titan, "titan_nuclear_death_charge" )

		Remote_CallFunction_Replay( p, "ServerCallback_GlowFlash", 1.5, 1 )
	}
	
	foreach( entity p in GetPlayerArray() )
	{
		fwd = core.GetOrigin() - p.CameraPosition()
		p.SnapEyeAngles( VectorToAngles( fwd ) + < 30,0,0 > )
	}
}

void function ThrowShake( entity player )
{
	CreateShake( player.GetOrigin(), 6, 150, 5, 8000000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
}

void function NoAirControl( entity player, float delay = 0.0 )
{
	player.Signal( "TempAirControl" )

	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "disable_doublejump" ] )
	player.kv.airSpeed = 0
	player.kv.airAcceleration = 0 // 500

	if ( delay == 0 )
	{
		while ( !player.IsOnGround() )
			wait 0.0
	}
	else
	{
		wait delay
	}

	player.kv.airSpeed = player.GetPlayerSettingsField( "airSpeed" )
	player.kv.airAcceleration = player.GetPlayerSettingsField( "airAcceleration" )
	player.SetPlayerSettingsWithMods( "pilot_solo_rising_world_run", [] )
}

//Ensure player goes between rings
void function SyncRingsToGunShot()
{
	//entity outer = GetEntByScriptName( "outer_ring" )
	//entity middle = GetEntByScriptName( "middle_ring" )
	//entity inner = GetEntByScriptName( "inner_ring" )

	entity outerMover = GetEntByScriptName( "outer_ring_mover" )
	entity middleMover = GetEntByScriptName( "middle_ring_mover" )
	entity innerMover = GetEntByScriptName( "inner_ring_mover" )

	middleMover.ClearParent()
	innerMover.ClearParent()

	outerMover.SetAngles( < 90, 0, 75 > )
	middleMover.SetAngles( < 90, 0, 57 > )
	innerMover.SetAngles( < 90, 0, 50 > )

	//outer.SetAngles( < 0, 0, 0 > )
	//middle.SetAngles( < 0, 0, 0 > )
	//inner.SetAngles( < 0, 0, 0 > )

	StartRingRotation()
}

/*
  _____  _     _                __          __        _     _     _____
 |  __ \(_)   (_)               \ \        / /       | |   | |   |  __ \
 | |__) |_ ___ _ _ __   __ _     \ \  /\  / /__  _ __| | __| |   | |__) |   _ _ __
 |  _  /| / __| | '_ \ / _` |     \ \/  \/ / _ \| '__| |/ _` |   |  _  / | | | '_ \
 | | \ \| \__ \ | | | | (_| |      \  /\  / (_) | |  | | (_| |   | | \ \ |_| | | | |
 |_|  \_\_|___/_|_| |_|\__, |       \/  \/ \___/|_|  |_|\__,_|   |_|  \_\__,_|_| |_|
                        __/ |
                       |___/
*/
void function RisingWorldRunStartPointSetup( entity player )
{
	entity runHurtTrigger = GetEntByScriptName( "sculptor_bottom_trigger" )
	runHurtTrigger.Disable()

	entity scriptRef = GetEntByScriptName( "rising_world_run" )
	TeleportPlayers( scriptRef )
}

void function RisingWorldRunSkipped( entity player )
{
	BreakRings()
	//StartCoreDebrisRotation()
	//StartFloatingDebrisRotation()
	FlagSet( "embed_droppod_01" )
	FlagSet( "embed_beam_01" )
	FlagSet( "shoot_rock_01" )
	FlagSet( "intercept_dropship_with_rock" )
	FlagSet( "slam_rocks_01" )
	FlagSet( "big_jump_rock" )
	FlagSet( "final_rock_burst" )
	player.SetPlayerSettingsWithMods( "pilot_solo_rising_world_run", [] )
}

void function WindRushSound( entity player )
{
	player.EndSignal( "OnDeath" )
	EmitSoundOnEntity( player, "skyway_scripted_risingworld_falling_windrush" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, "skyway_scripted_risingworld_falling_windrush" )
			}
		}
	)

	while ( IsAlive( player ) && !player.IsOnGround() )
		WaitFrame()

}

void function SP_RisingWorldRunThread( entity player )
{
	foreach( entity p in GetPlayerArray() )
	{
		p.SetPlayerSettingsWithMods( "pilot_solo_rising_world_run", [] )
		//Give control back to player when they land.
		thread PlayerLooksForward( p )
	}
	//CheckPoint()
	//StartRingRotation()
	BreakRings()
	//StartCoreDebrisRotation()
	//StartFloatingDebrisRotation()
	thread SpawnRingChunk()
	thread RisingMetalSpecialSounds()

	//Logic for steel beam that slams into rock mid-run.
	entity beamOrigin01 = GetEntByScriptName( "beam_origin_01" )
	entity beamTarget01 = GetEntByScriptName( "beam_embed_point_01" )
	ParentScriptRefToLinkedEntity( beamTarget01 )
	thread ShootRockAtMovingTarget( beamTarget01, beamOrigin01, 3000, LARGE_BEAM, "embed_beam_01", ResolveImpactEmbed, "skyway_scripted_risingworld_platform11_left_beam_incoming", "skyway_scripted_risingworld_platform11_left_beam_impact" )

	//Logic for giant rock smash sequence
	entity destroyedIsland = GetEntByScriptName( "floating_island_destroyed" )
	entity redirectIsland = GetEntByScriptName( "floating_island_redirect" )
	entity rockSpawn1 = GetEntByScriptName( "rock_spawn_01" )
	thread RedirectPlayerForceToTarget( "shoot_rock_01", redirectIsland, .5 )
	thread ShootRockAtTarget( destroyedIsland, rockSpawn1, < 0, 0, 300 >, 6000, "shoot_rock_01", "skyway_scripted_risingworld_platform5_left_incomingobject", "skyway_scripted_risingworld_platform5_left_explode" )

	entity destroyedIsland2 = GetEntByScriptName( "floating_island_destroyed_2" )
	entity rockSpawn2 = GetEntByScriptName( "rock_spawn_02" )
	thread ShootRockAtTarget( destroyedIsland2, rockSpawn2, < 0, 0, 300 >, 6000, "redirect_to_tilting_platform", "skyway_scripted_risingworld_platform11B_rock6_incoming", "skyway_scripted_risingworld_platform11B_rock6_explo" )

	//Crashing Goblin Getting Creamed By Bus Sequence.
	thread CrashingGoblinSequence()

	//Logic for gun that flies past big jump
	entity flyingGunMover = GetEntByScriptName( "gun_mover_01" )
	thread FlyingGunThread( flyingGunMover )

	//Player's Freefall to platform below.
	entity bigJumpLandingRef = GetEntByScriptName( "big_jump_landing" )
	thread RedirectPlayerForceToTarget( "redirect_to_tilting_platform", bigJumpLandingRef, 1.5 )

	//Final Big Jump to Escape Dropship
	entity dropship = GetEntByScriptName( "escape_ship" )
	file.dropship = CreatePropDynamic( CROW_HERO_MODEL )
	SetTeam( file.dropship, TEAM_MILITIA )
	file.dropshipAnimNode = CreateScriptMover()
	file.dropshipAnimNode.SetOrigin( dropship.GetOrigin() )
	file.dropshipAnimNode.SetAngles( dropship.GetAngles() )
	file.dropship.Hide()
	dropship.Destroy()
	dropship = file.dropship

	// thread RedirectPlayerForceToTarget( "final_jump_redirection_01", dropship, .75 )

	//Big rock that flies past and explodes while player is falling
	entity bigJumpRockTarget = GetEntByScriptName( "big_jump_rock_origin" )
	entity bigJumpRockOrigin = GetEntByScriptName( "big_jump_rock_target" )
	thread ShootRockAtMovingTarget( bigJumpRockOrigin, bigJumpRockTarget, 7000, $"models/rocks/rock_jagged_granite_large_03.mdl", "big_jump_rock", ResolveImpactExplodeThrough, "", "Goblin_Dropship_Explode" )

	//Two rocks slamming into eachother in mid-air.
	entity breakLooseRock = GetEntByScriptName( "rock_break_loose_01" )
	entity rockSlamTarget01 = GetEntByScriptName( "rock_target_01" )
	entity rockSlamOrigin1a = GetEntByScriptName( "rock_target_origin_01a" )
	entity rockSlamOrigin1b = GetEntByScriptName( "rock_target_origin_01b" )

	//Rock that clips edge of platform and breaks a chunk loose
	thread ShootRockAtMovingTarget( breakLooseRock, rockSlamOrigin1b, 2800, $"models/rocks/rock_jagged_granite_flat_02.mdl", "slam_rocks_01", ResolveImpactBreakThrough, "", "Goblin_Dropship_Explode" )

	//Final burst of rocks when player jumps for dropship.
	entity rockBurstFinal = GetEntByScriptName( "final_rock_burst_origin" )
	thread CreateRockBurst( rockBurstFinal.GetOrigin(), 25, 5, rockBurstFinal.GetForwardVector(), 56, 2500,"final_rock_burst" )
	
	
	thread CreateEvacPoint( player, dropship, file.dropshipAnimNode )

	thread AutoSaveMidRun( player )

	//Wait for the player to freefall for the first time
	FlagWait( "shoot_rock_01" )
	GetEntByScriptName( "outer_ring" ).Hide()
	GetEntByScriptName( "middle_ring" ).Hide()
	GetEntByScriptName( "inner_ring" ).Hide()
	// thread NoAirControl( player ) // bad idea for co-op since we don't know who is near the event
	thread WindRushSound( player )
	vector redirectFwdVec = < -3000,1500,0 >
	delaythread( 0.4 ) ForceLookAt( player, redirectIsland, redirectFwdVec + < 0,0,500 >, < 30, -30, 0 > )
	StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 0.3, 4.0, 3.0 )
	thread SlideOnLanding( player, redirectFwdVec )
	wait 4.0
	delaythread( 12 ) FlagSet( "start_run_03" )
	thread PlayDialogue( "RWR_6", player )

	FlagWait( "start_run_03" )
	delaythread( 8 ) FlagSet( "start_run_03b" )

	FlagWait( "redirect_to_tilting_platform" )
	thread WindRushSound( player )
	// thread NoAirControl( player ) // same thing
	StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 0.3, 3.0, 3.0 )

	delaythread( 3 ) PlayDialogue( "RWR_7", player )

	FlagWait( "tilting_platform_end" )
	thread PlayDialogue( "RWR_b_1", player )

	FlagWait( "final_jump_redirection_01" )
}

void function SlideOnLanding( entity player, vector vel )
{
	player.EndSignal( "OnDeath" )

	wait 0.5

	while ( !player.IsOnGround() )
		WaitFrame()

	entity redirectIsland = GetEntByScriptName( "floating_island_redirect" )
	entity collision = redirectIsland.GetLinkEnt()

	printt( redirectIsland )
	printt( collision )

	if ( player.GetGroundEntity() != redirectIsland && player.GetGroundEntity() != collision )
		return

	player.SetVelocity( Normalize( vel ) * 200 )
	player.ForceSlide()

	WaitFrame()

	while ( player.IsOnGround() )
		WaitFrame()

	player.UnforceSlide()
}

void function RisingMetalSpecialSounds()
{
	FlagWait( "start_run_03" )

	wait 4.0

	int i = 0
	array<entity> entities = GetEntArrayByScriptName( "floating_island_grp_3" )
	foreach ( ent in entities )
	{
		if ( ent.GetModelName() == $"models/levels_terrain/sp_skyway/skyway_floating_rubble_01_02.mdl" )
		{
			string sound = "skyway_scripted_risingworld_metalplatform_rise_into_place_" + (i+1)
			//printt( sound )
			EmitSoundOnEntity( ent, sound )
			i = (i+1)%2
		}
	}
}

void function AutoSaveMidRun( entity player )
{
	entity trigger = GetEntByScriptName( "rwr_mid_autosave" )
	entity info = trigger.GetLinkEnt()

	if ( GetSpDifficulty() > DIFFICULTY_NORMAL )
		return

	bool saved = false
	float minDot = 0.6
	vector idealView = AnglesToForward( info.GetAngles() )
	trigger.WaitSignal( "OnTrigger" )
	while ( !saved && trigger.GetTouchingEntities().contains( player ) )
	{
		vector playerView = Normalize( player.GetViewVector() )
		float dot = DotProduct( idealView, playerView )
		if ( dot >= minDot && IsAlive( player ) && player.IsOnGround() )
		{
			vector playerVel = Normalize( player.GetVelocity() )
			float dot2 = DotProduct( idealView, playerView )
			CheckPoint_Forced()
			saved = true
		}
		wait 0.1
	}
}

void function ForceLookAt( entity player, entity ent, vector offset, vector angleOffset )
{
	vector fwd = (ent.GetOrigin()+offset) - player.CameraPosition()
	player.SnapEyeAngles( VectorToAngles( fwd ) + angleOffset )
}

void function CreateEvacPoint( entity player, entity dropship, entity animNode )
{
	CheckPoint_Forced()

	entity scriptRef = GetEntByScriptName( "world_run_first_evac_marker" )

	entity ent = CreateEntity( MARKER_ENT_CLASSNAME )
	ent.SetOrigin( scriptRef.GetOrigin() )
	ent.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	ent.DisableHibernation()
	DispatchSpawn( ent )

	wait 0.5

	entity mover = CreateScriptMover()
	mover.SetOrigin( scriptRef.GetOrigin() )

	ent.SetParent( mover )
	SetGlobalNetEnt( "evacPoint", mover )
	
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( p, "ServerCallback_CreateEvacIcon", ent.GetEncodedEHandle() )
		Remote_CallFunction_Replay( p, "ServerCallback_SetDOF", 8000, 500000, 3.0 )
	}

	Objective_Set( "#SKYWAY_OBJECTIVE_LZ", <0,0,0>, mover )

	waitthread PlayDialogue( "RWR_2", player )
	waitthread PlayDialogue( "RWR_4", player )
	thread PlayDialogue( "RWR_5", player )

	FlagWait( "start_run_02" )

	AnimRefPoint info = GetAnimStartInfo( dropship, "dropship_skyway_world_run_start", animNode )
	mover.NonPhysicsMoveTo( info.origin, 5, 0, 0 )

	FlagSet( "run_ready" ) //start rising world run
}

void function RisingWorldJumpStartPointSetup( entity player )
{
	entity dropship = GetEntByScriptName( "escape_ship" )
	file.dropship = CreatePropDynamic( CROW_HERO_MODEL )
	SetTeam( file.dropship, TEAM_MILITIA )
	file.dropshipAnimNode = CreateScriptMover()
	file.dropshipAnimNode.SetOrigin( dropship.GetOrigin() )
	file.dropshipAnimNode.SetAngles( dropship.GetAngles() )
	file.dropship.Hide()
	dropship.Destroy()
	dropship = file.dropship

	player.SetInvulnerable()
	player.DisableWeapon()
	entity ref = GetEntByScriptName( "final_rock_burst_origin" )
	player.SetOrigin( ref.GetOrigin() )
	player.SetAngles( ref.GetAngles() )

	FlagSet( "rising_world_core_FX" )

	entity skycam = GetEnt( "skybox_cam_world_run" )
	player.SetSkyCamera( skycam )
	entity fogTrigger = GetEntByScriptName( "world_run_fog_trigger" )
	fogTrigger.SetOrigin( fogTrigger.GetOrigin() + <0,0,10000> )
}

void function RisingWorldJumpSkipped( entity player )
{

}

void function SP_RisingWorldJumpThread( entity player )
{
	StopMusicTrack( "music_skyway_20_landed" )
	PlayMusic( "music_skyway_21_leaptoship" )

	Objective_Clear()

	entity dropship = file.dropship
	entity dropshipRef = file.dropshipAnimNode

	entity runHurtTrigger = GetEntByScriptName( "sculptor_bottom_trigger" )
	runHurtTrigger.Disable()
	array<entity> runHurtTriggers = GetEntArrayByScriptName( "run_hurt_trigger" )
	foreach ( t in runHurtTriggers )
		t.Disable()

	entity idleMover = CreateScriptMover()
	idleMover.SetParent( dropship, "RESCUE", false, 0.0 )

	int id = dropship.LookupAttachment( "RESCUE" )
	vector angles = dropship.GetAttachmentAngles( id )
	vector fwd = AnglesToForward( angles )
	fwd *= -1
	angles = VectorToAngles( fwd )
	idleMover.SetAbsAngles( angles )

	entity playerMover = CreateScriptMover()
	playerMover.SetOrigin( player.GetOrigin() )
	playerMover.SetAngles( player.GetAngles() )

	FirstPersonSequenceStruct firstPersonSequence
	firstPersonSequence.blendTime = 0.5
	firstPersonSequence.attachment = "ref"
	firstPersonSequence.firstPersonAnim = "ptpov_skyway_world_run"
	firstPersonSequence.thirdPersonAnim = "pt_skyway_world_run"
	firstPersonSequence.viewConeFunction = ViewConeTight
	firstPersonSequence.useAnimatedRefAttachment = true
	entity sarah = CreatePropDynamic( SW_SARAH_MODEL, dropshipRef.GetOrigin(), dropshipRef.GetAngles() )
	sarah.DisableHibernation()

	FlagClear( "rising_world_core_FX" )
	FlagSet( "rising_world_core_FX_end" )
	delaythread( 0.5 ) Remote_CallFunction_NonReplay( player, "ServerCallback_SetDOF", 2000, 4000, 0.5 )
	delaythread( 1.25 ) PlayDialogue( "RWR_8", player )
	delaythread( 3 ) Remote_CallFunction_NonReplay( player, "ServerCallback_SetDOF", 120, 160, 0.5 )
	delaythread( 3 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 0 )
	delaythread( 4.2 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 1 )
	delaythread( 5.1 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 1 )
	delaythread( 4.4 ) PlayDialogue( "RWR_b_2", player )
	delaythread( 8.5 ) PlayDialogue( "RWR_b_3", player )
	delaythread( 10.5 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 0 )
	delaythread( 8 ) Remote_CallFunction_NonReplay( player, "ServerCallback_ResetDOF" )
	delaythread( 11 ) Remote_CallFunction_Replay( player, "ServerCallback_SetNearDOF", 0, 300, 5 )
	delaythread( 11.5 ) PlayDialogue( "RWR_b_4", player )

	player.SetAnimNearZ( 1 )
	thread PlayAnimTeleport( sarah, "pt_skyway_world_run_sarah", dropshipRef )

	FullyHidePlayers()

	foreach( entity p in GetPlayerArray() )
	{
		thread FirstPersonSequence( firstPersonSequence, p, playerMover )
		TakeAllWeapons( p )
	}

	EmitSoundOnEntity( player, "skyway_scripted_risingworld_jump" )

	playerMover.NonPhysicsMoveTo( dropshipRef.GetOrigin(), 3.0, 0, 0 )
	playerMover.NonPhysicsRotateTo( dropshipRef.GetAngles(), 3.0, 0, 0 )

	dropship.DisableHibernation()
	player.SetInvulnerable()
	player.DisableWeapon()
	string leaveAnim = "dropship_skyway_world_run"
	float duration = dropship.GetSequenceDuration( leaveAnim ) - 0.1 // subtract a fraction of a second just to be safe
	float timeToWarp = duration - WARPINFXTIME
	thread PlayAnimTeleport( dropship, "dropship_skyway_world_run", dropshipRef )
	thread WarpInThread( player, dropship, idleMover, dropshipRef )
	FlagSet( "HideWorldRunRandoms" )
	waitthread WarpOutThread( player, dropship, timeToWarp )
	foreach( entity p in GetPlayerArray() )
		UnlockAchievement( p, achievements.RISING_WORLD_RUN )
}

void function WarpInThread( entity player, entity dropship, entity idleMover, entity dropshipRef )
{
	Point start = GetWarpinPosition( CROW_HERO_MODEL, "dropship_skyway_world_run", dropshipRef.GetOrigin(), dropshipRef.GetAngles() )

	vector origin = dropshipRef.GetOrigin()
	vector angles = dropshipRef.GetAngles()

	entity dummyDropship = CreatePropDynamic( CROW_HERO_MODEL, origin, angles )
	dummyDropship.Hide()
	dummyDropship.SetOrigin( origin )
    dummyDropship.SetAngles( angles )
	Attachment attachResult = dummyDropship.Anim_GetAttachmentAtTime( "dropship_skyway_world_run", "ORIGIN", 1 )
	dummyDropship.Destroy()

	dropship.Hide()
	waitthread __WarpInEffectShared( attachResult.position, attachResult.angle, "skyway_scripted_risingworld_jump_ship_warp_in", 0.0 )
	dropship.Show()
	
	foreach( entity p in GetPlayerArray() )
		Remote_CallFunction_Replay( p, "ServerCallback_HideEvacIcon" )
	SetGlobalNetEnt( "evacPoint", null )

	GetEntByScriptName( "outer_ring" ).Show()
	GetEntByScriptName( "middle_ring" ).Show()
	GetEntByScriptName( "inner_ring" ).Show()

	WaittillAnimDone( player )
	player.ClearAnimNearZ()

	// entity mover = CreateScriptMover()
	// mover.SetOrigin( dropship.GetOrigin() )
	// mover.SetAngles( dropship.GetAngles() + < 0,-90,0 > )

	// FirstPersonSequenceStruct sequence
	// sequence.blendTime = 0.0
	// sequence.attachment = ""
	// sequence.firstPersonAnim = "ptpov_skyway_world_run_idle"
	// sequence.thirdPersonAnim = "pt_skyway_world_run_idle"
	// sequence.viewConeFunction = ViewConeTight
	// sequence.useAnimatedRefAttachment = true
	// thread FirstPersonSequence( sequence, player, idleMover )
	// player.SetParent( idleMover, "", true, 0.0 )
	// printt( "1" )
}

void function WarpOutThread( entity player, entity dropship, float timeToWarp )
{
	wait timeToWarp - 0.5
	thread PlayDialogue( "RWR_b_5", player )
	wait 0.5
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( p, "ServerCallback_DoRumble", 2 )
		Remote_CallFunction_Replay( p, "ServerCallback_PlayScreenFXWarpJump" )
		delaythread( WARPINFXTIME - 0.2 ) Remote_CallFunction_Replay( p, "ServerCallback_DoRumble", 0 )
	}
	wait WARPINFXTIME
	WarpoutEffectFPS( dropship )
	printt( "2" )
	FlagClear( "rising_world_core_FX_end" )
}

void function PlayerLooksForward( entity player )
{
	player.EndSignal( "OnDeath" )

	PlayMusic( "music_skyway_20_landed" )

	FlagSet( "StartRise" ) // Tell platforms to get into position for rising world run.
	FlagSet( "start_run" )

	int id = player.LookupAttachment("REF")
	entity fx = StartParticleEffectOnEntityWithPos_ReturnEntity( player, GetParticleSystemIndex( $"P_sw_core_weather" ), FX_PATTACH_POINT_FOLLOW_NOROTATE, id, <0,0,0>, <0,90,0> )

	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.1
	sequence.firstPersonAnim = "ptpov_s2s_lifeboats_land"
	sequence.thirdPersonAnim = "pt_s2s_lifeboats_land"
	sequence.viewConeFunction = ViewConeZero
	sequence.useAnimatedRefAttachment = true

	delaythread( 0.10 ) WorldRunChangeAmbience( player )
	player.SetAnimNearZ( 1 )
	EmitSoundOnEntity( player, "skyway_scripted_risingworld_platform1_player_land" )
	delaythread( 0.1 ) Remote_CallFunction_NonReplay( player, "ServerCallback_DoRumble", 0 )
	waitthread FirstPersonSequence( sequence, player, file.worldRunLandingNode )
	player.ClearAnimNearZ()

	player.SetPlayerSettingsWithMods( "pilot_solo_rising_world_run", [] )

	DeployAndEnableWeapons( player )
	player.UnfreezeControlsOnServer()
	player.ClearInvulnerable()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player, 0.5 )

	array<entity> triggers = GetEntArrayByScriptName( "world_run_flag_triggers" )
	foreach ( t in triggers )
	{
		t.Enable()
	}

	array<entity> runHurtTriggers = GetEntArrayByScriptName( "run_hurt_trigger" )
	foreach ( t in runHurtTriggers )
		t.Enable()

	wait 12 // buffer

	printt( "WorldRunPlayerStarted forced" )

	FlagSet( "WorldRunPlayerStarted" )

	wait 6 // buffer

	printt( "WorldRunPlayerStarted_2 forced" )

	FlagSet( "WorldRunPlayerStarted_2" )

	FlagWait( "final_jump_redirection_01" )

	EffectStop( fx )
}

void function WorldRunChangeAmbience( entity player )
{
	entity skycam = GetEnt( "skybox_cam_world_run" )
	player.SetSkyCamera( skycam )
	entity fogTrigger = GetEntByScriptName( "world_run_fog_trigger" )
	fogTrigger.SetOrigin( fogTrigger.GetOrigin() + <0,0,10000> )
	thread WorldRunOpeningBlur( player )
}

void function WorldRunOpeningBlur( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 1.0, 0, 0 )
	wait 1
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", .5, 1, 0 )
	wait 1
	Remote_CallFunction_NonReplay( player, "ServerCallback_BlurCamera", 0, 1, 0 )
	wait 1
}

void function HideWorldRunStuff()
{
	array<entity> coreRocks = GetEntArrayByScriptName( "core_debris_mid" )
	HideAllInArray( coreRocks )

	entity flyingGun = GetEntByScriptName( "flying_gun" )
	flyingGun.Hide()

	entity crashingGoblin = GetEntByScriptName( "crashing_goblin_01" )
	crashingGoblin.Hide()
}

// Hide all the floating platforms and get them ready to deploy when a flag is set.
void function Init_FloatingWorldStuff()
{
	entity runDriverS = GetEntByScriptName( "run_driver_starting_area" )
	entity runDriver = GetEntByScriptName( "run_driver" )
	entity runDriver2 = GetEntByScriptName( "run_driver_02" )
	entity runDriver3 = GetEntByScriptName( "run_driver_03" )
	entity runDriver4 = GetEntByScriptName( "run_driver_04" )

	array<entity> debrisMid = GetEntArrayByScriptName( "floating_debris" )
	HideAllInArray( debrisMid )

	entity startingArea = GetEntByScriptName( "starting_boulder" )

	entity node = GetEntByScriptName( "rising_world_run_landing_node" )
	entity mover = CreateScriptMover()
	vector fwd = AnglesToForward( node.GetAngles() )
	mover.SetOrigin( node.GetOrigin() + < 0,0,-37 >  )
	mover.SetAngles( node.GetAngles() )
	mover.SetParent( startingArea )
	file.worldRunLandingNode = mover

	thread FloatingIslandThread( startingArea, true, runDriverS, "StartLandingAreaRise", < 360, 0, 360 > )

	array<entity> islands = GetEntArrayByScriptName( "floating_island" )
	foreach ( entity island in islands )
	{
		thread FloatingIslandThread( island, true, runDriver )
	}

	array<entity> islands2 = GetEntArrayByScriptName( "floating_island_grp_2" )
	foreach ( entity island2 in islands2 )
	{
		thread FloatingIslandThread( island2, true, runDriver2 )
	}

	entity island2BreakLoose = GetEntByScriptName( "floating_island_grp_2_break_loose" )
	entity breakLooseRock = GetEntByScriptName( "rock_break_loose_01" )
	breakLooseRock.SetParent( island2BreakLoose, "", true )
	thread FloatingIslandThread( island2BreakLoose, true, runDriver2 )

	array<entity> islands3 = GetEntArrayByScriptName( "floating_island_grp_3" )
	foreach ( entity island3 in islands3 )
	{
		thread FloatingIslandThread( island3, true, runDriver3 )
	}

	array<entity> islands4 = GetEntArrayByScriptName( "floating_island_grp_4" )
	foreach ( entity island4 in islands4 )
	{
		thread FloatingIslandThread( island4, true, runDriver4 )
	}

	entity redirectIsland = GetEntByScriptName( "floating_island_redirect" )
	thread FloatingIslandThread( redirectIsland, true, runDriver2 )

	entity tiltingIsland = GetEntByScriptName( "floating_island_turning" )
	thread FloatingIslandThread( tiltingIsland, true, runDriver4 )

	entity destroyedIsland = GetEntByScriptName( "floating_island_destroyed" )
	thread FloatingIslandThread( destroyedIsland, true, runDriver )

	entity destroyedIsland2 = GetEntByScriptName( "floating_island_destroyed_2" )
	thread FloatingIslandThread( destroyedIsland2, true, runDriver3 )

	entity fogTrigger = GetEntByScriptName( "world_run_fog_trigger" )
	fogTrigger.SetOrigin( fogTrigger.GetOrigin() - <0,0,10000> )
}

void function BreakRings()
{
	entity outerRing = GetEntByScriptName( "outer_ring" )
	entity middleRing = GetEntByScriptName( "middle_ring" )
	entity innerRing = GetEntByScriptName( "inner_ring" )

	outerRing.SetModel( OUTER_RING_CHUNK_MAIN )
	middleRing.SetModel( MIDDLE_RING_CHUNK_MAIN )
	innerRing.SetModel( INNER_RING_CHUNK_MAIN )
}

void function CrashingGoblinSequence()
{
	FlagWait( "crash_dropship_01" )
	entity crashingGoblin = GetEntByScriptName( "crashing_goblin_01" )
	crashingGoblin.Show()
	entity crashingDropshipMover = GetEntByScriptName( "crashing_dropship_mover_01" )
	PlayFXOnEntity( PHYS_ROCK_TRAIL, crashingDropshipMover )
	entity rockSpawn2 = GetEntByScriptName( "dropship_rock_spawn_01" )

	//Hit the dropship with a truck when the flag is set.
	thread ShootRockAtMovingTarget( crashingDropshipMover, rockSpawn2, 7750, TRUCK, "intercept_dropship_with_rock", ResolveImpactExplodeThrough, "", "Goblin_Dropship_Explode" )
}

void function StartCoreDebrisRotation()
{
	entity moverMid = GetEntByScriptName( "vortex_origin_mid" )
	array<entity> debrisMid = GetEntArrayByScriptName( "core_debris_mid" )
	ShowAllInArray( debrisMid )

	foreach ( entity dMid in debrisMid )
	{
		entity rotator = CreateScriptMover( dMid.GetOrigin(), < 0, 0, 0 >, 0 )
		//rotator.SetOrigin( dMid.GetOrigin() )
		//rotator.kv.SpawnAsPhysicsMover = 0
		rotator.NonPhysicsSetMoveModeLocal( true )
		//DispatchSpawn( rotator )
		//rotator.Hide()

		dMid.SetParent( rotator, "", true )
		rotator.SetParent( moverMid, "", true )

		rotator.NonPhysicsRotate( < 1, 1, 1 >, 15 )
	}
}

void function HurtleTest()
{

	array<entity> movers
	int moverCount = 0

	while ( moverCount < 200 )
	{
		entity mover = CreateExpensiveScriptMover( <0,0,0>, <0.0, 0.0, 0.0>, 0 )
		mover.DisableHibernation()
		mover.SetModel( GetRandomDebris() )
		mover.Show()
		mover.kv.fadedist = 100000
		//mover.kv.fadedist = 10000
		//PlayFXOnEntity( PHYS_ROCK_TRAIL, mover )
		movers.append( mover )
		moverCount += 1
	}

	thread HurtleDebrisAroundCore( movers )
}

void function HurtleDebrisAroundCore( array<entity> movers )
{
	EndSignal( level, "HarmonySceneStart" )

	OnThreadEnd(
	function() : ( movers )
		{
			foreach ( m in movers )
			{
				m.Destroy()
			}
		}
	)

	entity moverMid = GetEntByScriptName( "outer_ring_mover" )
	vector moverMidPos = moverMid.GetOrigin()
	array<vector> velArray
	//mover.EndSignal( "OnDestroy" )
	//moverMid.EndSignal( "OnDestroy" )

	//float gravityStrength = 1200
	float gravityStrength = 1200
	float initialExplosion = 150
	float startDistance = 6000

	float lastFrameTime = Time()
	//vector lastPos

	foreach ( entity mover in movers )
	{
		float offsetX  = RandomFloatRange( startDistance / 2, startDistance * ( RandomInt( 2 ) == 1 ? 1 : -1 ) )
		float offsetY = RandomFloatRange( startDistance / 2, startDistance * ( RandomInt( 2 ) == 1 ? 1 : -1 ) )
		float offsetZ = RandomFloatRange( startDistance / 2, startDistance * ( RandomInt( 2 ) == 1 ? 1 : -1 ) )

		float velX = RandomFloatRange( -10, 10 )
		float velY = RandomFloatRange( -10, 10 )
		float velZ = RandomFloatRange( -10, 10 )

		mover.SetOrigin( moverMidPos + < offsetX, offsetY, offsetZ > )
		//lastPos = moverMidPos + < offsetX, offsetY, offsetZ >

		velArray.append( < velX, velY, velZ > * initialExplosion )
	}

	while ( true )
	{
		wait ( .1 )

		float frameTime = Time()
		float dt = frameTime - lastFrameTime
		int index = 0
		foreach( entity mover in movers )
		{
			vector moverPos = mover.GetOrigin()
			vector gravityDirection = Normalize( moverMidPos - moverPos )
			float dist2 = Distance( moverPos, moverMidPos )
			velArray[ index ] = velArray[ index ] + ( gravityDirection ) * ( ( gravityStrength ) * dt )
			//float gravityScalar = dist2 / 200000 * 200000
			//velArray[ index ] = velArray[ index ] + ( gravityDirection ) * ( ( gravityStrength * .1 ) * gravityScalar )
			mover.NonPhysicsMoveTo( moverPos + velArray[ index ], .2, 0, 0 )

			//mover.SetForwardVector( gravityDirection )
			mover.NonPhysicsRotate( gravityDirection, 360 )
			//DebugDrawLine( lastPos,  moverPos, 255, 0, 0, true, 60 )
			//lastPos = moverPos
			index += 1
		}

		lastFrameTime = frameTime
	}
}

void function StartFloatingDebrisRotation()
{
	array<entity> debrisMid = GetEntArrayByScriptName( "floating_debris" )
	ShowAllInArray( debrisMid )

	foreach ( entity dMid in debrisMid )
	{
		entity rotator = CreateScriptMover( dMid.GetOrigin(), < 0, 0, 0 >, 0 )
		dMid.SetParent( rotator, "", true )
		rotator.NonPhysicsRotate( < 1, 1, 1 >, 15 )
	}
}

void function FloatingIslandThread( entity island, bool useSyncedRot, entity runDriver, string startFlag = "StartRise", vector rotArc = < 360, 360, 360 >, vector startOff = <0.0,0.0,0.0>, vector startRotOff = <0.0,0.0,0.0> )
{

	island.EndSignal( "OnDestroy" )
	island.EndSignal( "RockStrike" )

	float time = RandomFloatRange( 0, 10 )
	float spinXMod = RandomFloatRange( -1, 1 )
	float spinYMod = RandomFloatRange( -1, 1 )
	float spinZMod = RandomFloatRange( -1, 1 )

	//float sinkDist = 2048
	float sinkDist = 4096
	float riseSpeed = 32
	float riseSpeadIncrement = 1.01
	float spinSpeed = .75
	//float sinkDist = RandomFloatRange( 2048, 4096 )

	vector startingPos = island.GetOrigin()
	vector startingAngles = island.GetAngles()
	vector sinkPos = startingPos - < 0, 0, -sinkDist >

	entity collision = island
	if ( island.GetLinkEnt() != null )
	{
		collision = island.GetLinkEnt()
		collision.SetParent( island )
	}

	string editorClass = GetEditorClass( island )
	if ( editorClass == "script_mover" || editorClass == "script_mover_lightweight" || editorClass == "script_rotator" )
	{
		island.SetPusher( true )
	}

	//entity mover = CreateScriptMover( startingPos, < 0, 0, 0 >, 0 )
	entity mover = CreateScriptMover( startingPos, startingAngles, 0 )
	island.SetParent( mover, "", true )
	mover.SetPusher( true )

	//vector startingAngles = mover.GetAngles()
	bool rise = false
	//mover.SetOrigin( < startingPos.x, startingPos.y, startingPos.z - sinkDist > )

	mover.EndSignal( "OnDestroy" )
	//runDriver.SetModel( $"models/dev/editor_ref.mdl" )
	//runDriver.Show()

	entity hideRef = GetEntByScriptName( "run_stuff_hide_ref" )

	mover.SetOrigin( hideRef.GetOrigin() )

	FlagWait( startFlag )

	mover.SetOrigin( startingPos - < startOff.x, startOff.y, sinkDist> )
	mover.SetAngles( mover.GetAngles() + startRotOff )

	while ( true )
	{
		time += .1
		entity player = GetPlayerByIndex( 0 )

		if ( IsValid( player ) )
		{

			//mover.SetModel( $"models/dev/editor_ref.mdl" )
			//mover.Show()

			float dist2 = DistanceSqr( runDriver.GetOrigin(), startingPos )
			float dist2Start = DistanceSqr( mover.GetOrigin(), startingPos )
			float dist2Clamped = clamp( dist2, 0, sinkDist * sinkDist )
			float modSinkDist = dist2Clamped / ( sinkDist * sinkDist )
			float modSpinRate = dist2 / ( sinkDist * sinkDist )

			float bob = sin( time )
			//float spin = 360 * modSpinRate
			float spinX = rotArc.x * modSpinRate
			float spinY = rotArc.y * modSpinRate
			float spinZ = rotArc.z * modSpinRate

			float xSpin = clamp( ( spinX * spinSpeed ) , 0, 360 )
			float ySpin = clamp( ( spinY * spinSpeed ) , 0, 360 )
			float zSpin = clamp( ( spinZ * spinSpeed ) , 0, 360 )
			vector spinVector = < xSpin, ySpin, zSpin >
			//printt( modSinkDist )

			vector playerDir = Normalize( player.GetOrigin() - mover.GetOrigin() )
			playerDir *= 32 //< playerDir.x * 32, playerDir.y * 32, playerDir.z * 128 >

			if ( dist2 <= 300 * 300 && dist2Start <= 300 * 300 )
				rise = true

			if ( rise )
			{
				//mover.NonPhysicsMoveTo( mover.GetOrigin() + < 0, 0, riseSpeed >, .5, 0, .1 )
				//riseSpeed *= riseSpeadIncrement
				//mover.NonPhysicsMoveTo( ( startingPos + playerDir ) + < bob * 16, bob * 16, ( sinkDist * modSinkDist ) + ( bob * 64 ) >, .5, 0, .1 )
				mover.NonPhysicsMoveTo( ( startingPos + playerDir ) + < 0, 0, ( sinkDist * modSinkDist ) >, .5, 0, 0 )
				spinVector *= -1
			}
			else
			{
				//mover.NonPhysicsMoveTo( ( startingPos + playerDir ) - < bob * 16, bob * 16, ( sinkDist * modSinkDist ) + ( bob * 64 ) >, .5, 0, .1 )
				mover.NonPhysicsMoveTo( ( startingPos + playerDir ) - < 0, 0, ( sinkDist * modSinkDist ) > , .5, 0, 0 )
			}

			if ( !useSyncedRot )
			{
				mover.NonPhysicsRotate( < bob / 2, bob / 2, bob / 2 >, 5 )
			}
			else
			{
				vector angles = startingAngles + spinVector
				angles.x = AngleNormalize( angles.x )
				angles.y = AngleNormalize( angles.y )
				angles.z = AngleNormalize( angles.z )
				mover.NonPhysicsRotateTo( angles, .5, 0, .1 )
			}

			if ( mover.GetOrigin().z - startingPos.z >= sinkDist )
			{
				return
				//island.ClearParent()
				//island.Destroy()
				//mover.Destroy()
			}

		}

		wait( .1 )
	}
}

void function PlayerCatcherThread()
{
	entity mover = GetEntByScriptName( "player_catcher" )

	while ( true )
	{
		entity player = GetPlayerByIndex( 0 )
		float speed = 64

		if ( IsValid( player ) )
		{
			vector offset = player.GetOrigin() - mover.GetOrigin()
			offset = Normalize( offset )
			//mover.SetForwardVector( offset )
			mover.NonPhysicsRotateTo( VectorToAngles( offset ), .25, 0, 0 )
			mover.NonPhysicsMoveTo(  mover.GetOrigin() + ( offset * speed ), .25, 0, 0 )
		}

		wait( 0.1 )
	}
}

void function ShootRockAtTarget( entity target, entity spawn, vector leadTargetBy, float speed, string triggerFlag, string incomingSound, string impactSound )
{
	FlagWait( triggerFlag )

	vector modifiedTargetOrigin = ( target.GetOrigin() + leadTargetBy )
	entity mover = CreateExpensiveScriptMover( spawn.GetOrigin(), <0.0, 0.0, 0.0>, 0 )
	mover.SetModel( $"models/rocks/rock_jagged_granite_large_03.mdl" )
	mover.Show()
	EmitSoundOnEntity( mover, incomingSound )
	vector rockForward = Normalize( modifiedTargetOrigin - mover.GetOrigin() )
	float dist = Distance( modifiedTargetOrigin, mover.GetOrigin() )
	mover.SetForwardVector( rockForward )
	mover.SetForwardVector( mover.GetUpVector() )

	float impactTime = ( ( dist / speed ) / 10 )

	mover.NonPhysicsMoveTo( modifiedTargetOrigin, impactTime, 0, 0 )
	//DebugDrawLine( mover.GetOrigin(),  modifiedTargetOrigin, 255, 0, 0, true, 30 )
	//CreateShake( mover.GetOrigin(), 2, 25, 10, 64000 )
	//PlayLoopFXOnEntity( $"hotdrop_radial_smoke", mover )

	wait( impactTime )

	StartParticleEffectInWorld( GetParticleSystemIndex( ROCK_IMPACT_DUST ), target.GetOrigin(), <0,0,0> )
	// DebugDrawSphere( target.GetOrigin(), 50, 255, 0, 0, true, 1.0 )
	//target.Destroy()
	target.ClearParent()
	target.SetParent( mover, "", true )
	target.Signal( "RockStrike" )

	EmitSoundAtPosition( TEAM_ANY, mover.GetOrigin(), impactSound )

	CreateRockBurst( mover.GetOrigin(), 25, 3, <0,0.5,1>, 45, 1500 )
	if ( !Flag( "final_jump_redirection_01" ) )
		CreateShake( mover.GetOrigin(), 8, 150, 5, 4096 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	mover.NonPhysicsMoveTo( mover.GetOrigin() - mover.GetUpVector() * speed, 1, 0, 0 )
	//DebugDrawLine( mover.GetOrigin(),  mover.GetOrigin() - mover.GetUpVector() * dist, 255, 0, 0, true, 30 )
}

void function ShootRockAtMovingTarget( entity target, entity spawn, float speed, asset model, string triggerFlag, void functionref( entity, entity, vector, float ) resolveFunction, string incomingSound, string impactSound )
{
	FlagWait( triggerFlag )

	spawn.NotSolid()

	vector modifiedTargetOrigin = ( target.GetOrigin() )
	entity mover = CreateExpensiveScriptMover( spawn.GetOrigin(), <0.0, 0.0, 0.0>, 0 )
	spawn.SetParent( mover, "", true )
	mover.SetModel( model )
	mover.kv.fadedist = 100000
	mover.Show()
	PlayFXOnEntity( PHYS_ROCK_TRAIL, mover )
	vector rockForward = Normalize( modifiedTargetOrigin - mover.GetOrigin() )
	//float dist = Distance( modifiedTargetOrigin, mover.GetOrigin() )
	mover.SetForwardVector( rockForward )
	mover.SetForwardVector( mover.GetUpVector() )
	mover.NonPhysicsMoveTo( modifiedTargetOrigin, 1, 0, 0 )
	//DebugDrawLine( mover.GetOrigin(),  modifiedTargetOrigin, 255, 0, 0, true, 30 )
	//CreateShake( mover.GetOrigin(), 2, 25, 10, 64000 )
	//PlayLoopFXOnEntity( $"hotdrop_radial_smoke", mover )

	//float startTime = Time()
	float impactTime = Time()
	float lastFrameTime = Time()
	vector newMoverVel = < 0, 0, 0 >

	mover.EndSignal( "OnDestroy" )

	if ( incomingSound != "" )
		EmitSoundOnEntity( mover, incomingSound )

	while ( true )
	{

		float frameTime = Time()
		float dt = frameTime - lastFrameTime

		if ( impactTime - dt <= dt )
		{
			break
		}

		vector moverPos = mover.GetOrigin()
		vector targetPos = target.GetOrigin()
		vector targetVelocity = target.GetVelocity() * dt

		float speedMod = speed * dt
		float dist = Distance( targetPos + targetVelocity, moverPos )

		//if ( speed > dist )
		//	speed = dist

		//impactTime = ( ( dist / speed ) * FRAME_INTERVAL ) - FRAME_INTERVAL
		impactTime = ( ( dist / speedMod ) / 10 )

		//printt("")
		//printt( "DT: " + dt )
		//printt( "Speed: " + speed )
		//printt( "SpeedMod: " + speedMod )
		//printt( "Distance: " + dist )
		//printt( "Impact Time: " + impactTime )

		//vector newMoverVel = GetVelocityForDestOverTime( moverPos, targetPos + targetVelocity, timeRemaining )
		newMoverVel = LeadTargetOverTime( moverPos, targetPos + targetVelocity, impactTime )
		mover.NonPhysicsMoveTo( moverPos + ( newMoverVel * dt ), .1, 0, 0 )
		mover.NonPhysicsRotate( < .25, 1, .5 >, 360 )

		lastFrameTime = frameTime

		WaitFrame()

	}

	EmitSoundAtPosition( TEAM_ANY, mover.GetOrigin(), impactSound )
	resolveFunction( mover, target, newMoverVel, speed )
}

void function ResolveImpactExplodeThrough( entity mover, entity target, vector velDirection, float impactSpeed )
{
	CreateRockBurst( mover.GetOrigin(), 25, 0, Normalize( velDirection ), 90, impactSpeed )
	PlayFXOnEntity( ROCK_IMPACT_DUST, mover )
	if ( !Flag( "final_jump_redirection_01" ) )
		CreateShake( mover.GetOrigin(), 6, 150, 5, 8000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	//EmitSoundOnEntity( mover, "Goblin_Dropship_Explode" )
	target.Destroy()
	mover.NonPhysicsMoveTo( mover.GetOrigin() + Normalize( velDirection ) * ( impactSpeed * 2 ) , 2, 0, 0 )

	wait ( 2.0 )

	mover.Destroy()
}

void function ResolveImpactBreakThrough( entity mover, entity target, vector velDirection, float impactSpeed )
{
	CreateRockBurst( mover.GetOrigin(), 25, 5, Normalize( velDirection ), 45, impactSpeed )
	//PlayFXOnEntity( ROCK_IMPACT_DUST, mover )
	if ( !Flag( "final_jump_redirection_01" ) )
		CreateShake( mover.GetOrigin(), 6, 150, 5, 8000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	EmitSoundAtPosition( TEAM_ANY, target.GetOrigin(), "Goblin_Dropship_Explode" )
	//EmitSoundOnEntity( mover, "Goblin_Dropship_Explode" )
	target.Destroy()
	mover.NonPhysicsMoveTo( mover.GetOrigin() + Normalize( velDirection ) * ( impactSpeed * 2 ) , 2, 0, 0 )

	wait ( 2.0 )

	mover.Destroy()
}

void function ResolveImpactEmbed( entity mover, entity target, vector velDirection, float impactSpeed )
{
	CreateRockBurst( mover.GetOrigin(), 25, 0, Normalize( velDirection ), 90, impactSpeed )
	PlayFXOnEntity( ROCK_IMPACT_DUST, mover )
	if ( !Flag( "final_jump_redirection_01" ) )
		CreateShake( mover.GetOrigin(), 6, 150, 5, 8000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	EmitSoundAtPosition( TEAM_ANY, target.GetOrigin(), "Goblin_Dropship_Explode" )
	//EmitSoundOnEntity( mover, "Goblin_Dropship_Explode" )
	//target.Destroy()
	//mover.NonPhysicsMoveTo( mover.GetOrigin() + Normalize( velDirection ) * ( impactSpeed * 2 ) , 2, 0, 0 )

	//wait ( 2.0 )

	//mover.Destroy()
	mover.NonPhysicsStop()
	mover.SetAngles( target.GetAngles() )
	mover.SetOrigin( target.GetOrigin() )
	mover.SetParent( target.GetParent(), "", true )
}

asset function GetRandomDebris()
{

	int randInt = RandomInt( 10 )

	switch ( randInt )
	{
		case 0:
			return $"models/rocks/rock_jagged_granite_small_01_phys.mdl"
		break

		case 1:
			return $"models/rocks/rock_jagged_granite_small_02_phys.mdl"
		break

		case 2:
			return $"models/rocks/rock_jagged_granite_small_03_phys.mdl"
		break

		case 3:
			return  $"models/rocks/rock_jagged_granite_small_04_phys.mdl"
		break

		case 4:
			return  $"models/rocks/rock_jagged_granite_small_05_phys.mdl"
		break

		case 5:
			return  $"models/rocks/rock_jagged_granite_small_06_phys.mdl"
		break

		case 6:
			return  $"models/rocks/rock_jagged_granite_small_07_phys.mdl"
		break

		case 7:
			return  TRUCK
		break

		case 8:
			return  GOBLIN_DEBRIS_CABIN
		break

		case 9:
			return  GOBLIN_DEBRIS_WING_LEFT
		break

		case 10:
			return  GOBLIN_DEBRIS_WING_RIGHT
		break

	}

	unreachable
}

void function FlyingGunThread( entity gunMover )
{

	gunMover.EndSignal( "OnDestroy" )


	FlagWait( "fling_gun_01" )
	entity flyingGun = GetEntByScriptName( "flying_gun" )
	flyingGun.Show()
	EmitSoundOnEntity( flyingGun, "skyway_scripted_risingworld_injector_by" )

	FlagWait( "gun_impact" )
	PlayFXOnEntity( ROCK_IMPACT_DUST, gunMover )
	CreateRockBurst( gunMover.GetOrigin(), 25, 0, -gunMover.GetForwardVector(), 45, 4000 )

	FlagWait( "gun_path_end" )
	gunMover.Destroy()

}

void function RedirectPlayerForceToTarget( string triggerFlag, entity target, float stopTime )
{
	target.EndSignal( "OnDestroy" )

	if( triggerFlag != "" )
		FlagWait( triggerFlag )

	entity player = GetPlayerByIndex( 0 )

	//thread BlackholePlayerToShip( player, target, 1 )

	float duration = GetMovingTargetFastballDuration( player, target )
	float endTime = Time() + duration

	while ( 1 )
	{
		float timeRemaining = endTime - Time()
		if ( timeRemaining <= stopTime )
			return

		vector endPos = target.GetOrigin() + ( target.GetVelocity() * max( 0, timeRemaining - FRAME_INTERVAL ) )
		//vector endPos = target.GetOrigin()
		vector velocity = GetPlayerVelocityForDestOverTime( player.GetOrigin(), endPos, timeRemaining )
		player.SetVelocity( velocity )

		//vector playerRedirectVel = GetPlayerVelocityForDestOverTime( player.GetOrigin(), target.GetOrigin(), .05 )
		//player.SetVelocity( playerRedirectVel * .05 )
		WaitFrame()
	}
	/*
	vector playerVel = ( player.GetVelocity() )
	float playerVelLength = Length( playerVel )
	vector redirectDir = Normalize( target.GetOrigin() - player.GetOrigin() )
	vector playerVelRedirected = < redirectDir.x * playerVelLength, redirectDir.y * playerVelLength, redirectDir.z * playerVelLength >
	player.SetVelocity( playerVelRedirected )
	DebugDrawLine( player.GetOrigin(),  player.GetOrigin() + playerVelRedirected, 255, 0, 0, true, 30 )
	*/
}

void function SpawnRingChunk()
{
	FlagWait( "SpawnRingChunk" )

	entity outer = GetEntByScriptName( "outer_ring" )
	entity middle = GetEntByScriptName( "middle_ring_mover" )
	entity inner = GetEntByScriptName( "inner_ring_mover" )

	vector outerAngles = outer.GetAngles()
	vector middleAngles = middle.GetLocalAngles()
	vector innerAngles = inner.GetLocalAngles()

	vector outerForward = AnglesToForward( outerAngles )
	vector middleForward = AnglesToUp( middleAngles )
	vector innerForward = AnglesToRight( innerAngles )

	entity oChunk1 = CreateEntity( "script_mover" )
	oChunk1.SetValueForModelKey( $"models/levels_terrain/sp_skyway/sculpter_outer_ring_damage_chunk_one.mdl" )
	oChunk1.SetOrigin( outer.GetOrigin() )
	oChunk1.SetAngles( outer.GetAngles() )
	oChunk1.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( oChunk1 )

	//oChunk1.SetParent( outer, "", false )
	//oChunk1.NonPhysicsSetRotateModeLocal( true )
	//oChunk1.NonPhysicsSetMoveModeLocal( true )

	//oChunk1.NonPhysicsMoveTo( -outerForward * 256, 1, 0, 0 )
	//oChunk1.NonPhysicsRotate( oChunk1.GetForwardVector(), 45 )

	//Wait( 3.0 )

	//oChunk1.NonPhysicsMoveWithGravity( outerForward * 500, < 0, 0, -200> )
	oChunk1.NonPhysicsRotate( -outerForward, 50 )


	//Middle Chunks
	entity mChunk1 = CreateEntity( "script_mover" )
	mChunk1.SetValueForModelKey( $"models/levels_terrain/sp_skyway/sculpter_middle_ring_damaged_chunk_one.mdl" )
	mChunk1.SetOrigin( middle.GetOrigin() )
	mChunk1.SetAngles( middle.GetAngles() )
	mChunk1.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( mChunk1 )

	mChunk1.NonPhysicsRotate( -outerForward, -48 )

	entity mChunk2 = CreateEntity( "script_mover" )
	mChunk2.SetValueForModelKey( $"models/levels_terrain/sp_skyway/sculpter_middle_ring_damaged_chunk_two.mdl" )
	mChunk2.SetOrigin( middle.GetOrigin() )
	mChunk2.SetAngles( middle.GetAngles() )
	mChunk2.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( mChunk2 )

	mChunk2.NonPhysicsRotate( -outerForward, -48 )

	//Inner Chunks
	entity iChunk1 = CreateEntity( "script_mover" )
	iChunk1.SetValueForModelKey( $"models/levels_terrain/sp_skyway/sculpter_inner_ring_destroyed_chunk_one.mdl" )
	iChunk1.SetOrigin( middle.GetOrigin() )
	iChunk1.SetAngles( middle.GetAngles() )
	iChunk1.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( iChunk1 )

	iChunk1.NonPhysicsRotate( -outerForward, 150 )

	entity iChunk2 = CreateEntity( "script_mover" )
	iChunk2.SetValueForModelKey( $"models/levels_terrain/sp_skyway/sculpter_inner_ring_destroyed_chuck_two.mdl" )
	iChunk2.SetOrigin( middle.GetOrigin() )
	iChunk2.SetAngles( middle.GetAngles() )
	iChunk2.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( iChunk2 )

	iChunk2.NonPhysicsRotate( -outerForward, 150 )

	entity iChunk3 = CreateEntity( "script_mover" )
	iChunk3.SetValueForModelKey( $"models/levels_terrain/sp_skyway/sculpter_inner_ring_destroyed_chunk_three.mdl" )
	iChunk3.SetOrigin( middle.GetOrigin() )
	iChunk3.SetAngles( middle.GetAngles() )
	iChunk3.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( iChunk3 )

	iChunk3.NonPhysicsRotate( outerForward, 150 )

}

float function GetMovingTargetFastballDuration( entity player, entity throwTarget )
{
	float speed = 1000 //1000 units / s
	float throwDist = Distance( player.GetOrigin(), throwTarget.GetOrigin() )
	float throwDuration = throwDist / speed

	vector targetVelocity = throwTarget.GetVelocity()
	throwDist = Distance( player.GetOrigin(), throwTarget.GetOrigin() + ( targetVelocity * throwDuration ) )
	throwDuration = throwDist / speed

	return throwDuration
}

vector function LeadTargetOverTime( vector startPoint, vector endPoint, float duration )
{
	float Vox = ( endPoint.x - startPoint.x ) / duration
	float Voy = ( endPoint.y - startPoint.y ) / duration
	//float Voz = (endPoint.z + 0.5 * GRAVITY * duration * duration - startPoint.z) / duration
	float Voz = ( endPoint.z - startPoint.z ) / duration

	return Vector( Vox, Voy, Voz )
}

void function ParentScriptRefToLinkedEntity( entity ref )
{
	entity link = ref.GetLinkEnt()
	ref.SetParent( link, "", true )
}

void function NPC_DieAtPathEnd( entity npc )
{
	thread NPC_DieAtPathEnd_Internal( npc )
}

void function NPC_DieAtPathEnd_Internal( entity npc )
{
	npc.EndSignal( "OnDeath" )
	npc.WaitSignal( "OnFinishedAssaultChain" )
	npc.Die()
}

void function BridgeTurretsSpawnThink( entity npc )
{
	SetPreventSmartAmmoLock( npc, true )
	TakeAllWeapons( npc )
	npc.GiveWeapon( "mp_weapon_turretplasma", [ "fast_projectiles" ] )
}

void function AISetNoSelfDamage( entity npc )
{
	AddEntityCallback_OnDamaged( npc, PushLastActionTime )
	AddEntityCallback_OnDamaged( npc, NoSelfDamage )
}

void function TriggerSignal( entity trigger )
{
	trigger.WaitSignal( "OnTrigger" )
	svGlobal.levelEnt.Signal( expect string( trigger.kv.script_signal ) )
}

void function BombardTarget( entity npc )
{
	thread BombardTarget_Internal( npc )
}

void function BombardTarget_Internal( entity npc )
{
	npc.EndSignal( "OnDeath" )

	if ( npc.IsTitan() )
		waitthread WaitForHotdropToEnd( npc )

	FlagWait( "PlayerDidSpawn" )
	entity player = GetPlayerArray()[0]
	waitthread WaitTillLookingAt( player, npc, true, 40, 3000 )

	wait RandomFloatRange( 2, 5 )

	file.bombardTargets.append( npc )
}


void function BombardTargetInstant( entity npc )
{
	thread BombardTargetInstant_Internal( npc, 0.0 )
}

void function BombardTargetInstant_Internal( entity npc, float delay )
{
	npc.EndSignal( "OnDeath" )

	if ( npc.IsTitan() )
		waitthread WaitForHotdropToEnd( npc )

	FlagWait( "PlayerDidSpawn" )
	entity player = GetPlayerArray()[0]
	waitthread WaitTillLookingAt( player, npc, true, 60, 5000 )

	wait delay

	file.bombardTargets.append( npc )
	file.forcedBombardList.append( npc )
}

void function EnableMegaTurret( entity turret )
{
	turret.EnableTurret()
	thread TurretShootBullseye( turret )
}

void function TurretShootBullseye( entity turret )
{
	turret.EndSignal( "OnDeath" )

	vector origin = turret.GetOrigin() + <0,0,32>

	array<entity> targets = turret.GetLinkEntArray()

	entity mover = CreateScriptMover()
	entity bullseye = SpawnBullseye( TEAM_MILITIA )
	bullseye.SetParent( mover, "", false )
	mover.SetOrigin( targets.getrandom().GetOrigin() )
	turret.LockEnemy( bullseye )

	OnThreadEnd(
	function() : ( bullseye, mover, turret, origin )
		{
			if ( IsValid( mover ) )
				mover.Destroy()
			if ( IsValid( bullseye ) )
				bullseye.Destroy()
			if ( IsValid( turret ) )
				turret.Destroy()
			StartParticleEffectInWorld( GetParticleSystemIndex( $"P_deathfx_turretlaser" ), origin, <0,0,0> )
		}
	)

	turret.TakeActiveWeapon()
	turret.GiveWeapon( "mp_weapon_yh803_bullet", [] )
	turret.SetMaxHealth( 4000 )
	turret.SetHealth( 4000 )

	while ( targets.len() > 0 && IsAlive( turret ) )
	{
		turret.ClearInvulnerable()

		entity target = targets.getrandom()

		float moveTime = RandomFloatRange( 1.0, 3.0 )
		float holdTime = RandomFloat( 1.5 )
		mover.NonPhysicsMoveTo( target.GetOrigin(), moveTime, moveTime * 0.33, moveTime * 0.33 )

		wait ( moveTime + holdTime )
	}
}

bool function ClientCommand_RequestTitanFake( entity player, array<string> args )
{
	svGlobal.levelEnt.Signal( "ClientCommand_RequestTitanFake" )
	return true
}

bool function ClientCommand_Pulldown( entity player, array<string> args )
{
	player.Signal( "PullDown" )
	return true
}

bool function ClientCommand_StopPulldown( entity player, array<string> args )
{
	player.Signal( "OnStopPulldown" )
	return true
}

void function ExplodingPlanetStartPointSetup( entity player )
{
	file.dropship = GetEntByScriptName( "escape_ship" )
	entity dropship = file.dropship
	dropship.SetModel( SW_CROW )
	SetTeam( dropship, TEAM_MILITIA )
	dropship.DisableHibernation()
	dropship.Show()
	player.SetInvulnerable()
	player.DisableWeapon()

	entity runHurtTrigger = GetEntByScriptName( "sculptor_bottom_trigger" )
	runHurtTrigger.Disable()
}

void function ExplodingPlanetSkipped( entity player )
{
	GetEntByScriptName( "outer_ring" ).Hide()
	GetEntByScriptName( "middle_ring" ).Hide()
	GetEntByScriptName( "inner_ring" ).Hide()
}

void function SP_ExplodingPlanetThread( entity player )
{
	level.nv.coreSoundActive = 0
	
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( p, "ServerCallback_SetTyphonColorCorrectionWeight", 1.0, 1.0 )
		p.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [] )
		Remote_CallFunction_Replay( p, "ServerCallback_SetNearDOF", 0, 75, 0.1 )
	}

	GetEntByScriptName( "outer_ring" ).Hide()
	GetEntByScriptName( "middle_ring" ).Hide()
	GetEntByScriptName( "inner_ring" ).Hide()

	entity dropship = file.dropship
	dropship.SetModel( SW_CROW )
	SetTeam( dropship, TEAM_MILITIA )
	dropship.ClearParent()
	dropship.Anim_Stop()
	thread PlayAnim( dropship, "ref" )
	dropship.SetNextThinkNow()
	dropship.RenderWithViewModels( true )

	entity spacenode = GetEnt( "spacenode_1" )

	entity mover = CreateScriptMover()
	entity planet = GetEntByScriptName( "planet_typhon_animated" )
	EmitSoundOnEntity( planet, "skyway_scripted_risingworld_postwarp_world_breakup" )

	mover.SetOrigin( planet.GetOrigin() )
	mover.SetAngles( planet.GetAngles() )
	
	foreach( entity p in GetPlayerArray() )
	{
		p.ClearParent()
		ClearPlayerAnimViewEntity(p)
	}

	thread AnimateStuff( player, planet, dropship, mover )

	// entity idleMover = CreateScriptMover()
	// idleMover.SetParent( dropship, "RESCUE", false, 0.0 )
	// int id = dropship.LookupAttachment( "RESCUE" )
	// vector angles = dropship.GetAttachmentAngles( id )
	// vector fwd = AnglesToForward( angles )
	// fwd *= -1
	// angles = VectorToAngles( fwd )
	// idleMover.SetAbsAngles( angles )

	// FirstPersonSequenceStruct sequence
	// sequence.blendTime = 0.0
	// sequence.firstPersonAnim = "ptpov_skyway_world_run_end_idle"
	// sequence.thirdPersonAnim = "pt_skyway_world_run_end_idle"
	// sequence.viewConeFunction = ViewConeTight
	// sequence.useAnimatedRefAttachment = true
	// thread FirstPersonSequence( sequence, player, idleMover )

	// vector right = AnglesToRight( spacenode.GetAngles() )
	// entity mover = CreateScriptMover()
	// fwd = AnglesToForward( spacenode.GetAngles() )
	// mover.SetOrigin( spacenode.GetOrigin() + < 0,0,-50 > )
	// mover.SetAngles( spacenode.GetAngles() + < 0,-10,-8 > )

	// vector planetRight = AnglesToForward( mover.GetAngles() ) * -1
	// vector targetAngles = mover.GetAngles()
	// vector targetOrigin = mover.GetOrigin() - fwd*250 - right*400

	// mover.SetAngles( spacenode.GetAngles() + < -25,-10,-16 > )
	// right = AnglesToRight( mover.GetAngles() )
	// fwd = AnglesToForward( mover.GetAngles() )
	// vector up = AnglesToUp( mover.GetAngles() )
	// mover.SetOrigin( mover.GetOrigin() + right*300 - up*100 )

	// vector anglesOffset = < 0,55,0 >
	// mover.SetAngles( mover.GetAngles() + < 0,55,0 > )

	// right = AnglesToRight( mover.GetAngles() )
	// fwd = AnglesToForward( mover.GetAngles() )
	// up = AnglesToUp( mover.GetAngles() )
	// mover.SetOrigin( mover.GetOrigin() ) // + up*200 - <0,0,250> + planetRight*50 )

	// mover.SetAngles( mover.GetAngles() + < 0,0,-20 > )

	// printt( " - mover - " )
	// printt( mover.GetOrigin() )
	// printt( mover.GetAngles() )
	// printt( " - ---- - " )

	// entity rotator = CreateScriptMover()
	// rotator.SetAngles( mover.GetAngles() )
	// rotator.SetOrigin( mover.GetOrigin() )
	// dropship.SetAngles( rotator.GetAngles() )
	// dropship.SetOrigin( rotator.GetOrigin() )
	// // wait 1.0
	// rotator.SetParent( mover, "", false, 0.0 )
	// dropship.SetParent( rotator, "", false, 0.0 )

	// // entity skyCamExplode = GetEnt( "skybox_cam_skyway_explode" )
	// player.ForceCrouch()
	// // player.SetSkyCamera( skyCamExplode )
	// // player.LerpSkyScale( 0.0, 0.01 )

	// thread AnimatePlanet( player, rotator )

	// printt( " - target - " )
	// printt( targetOrigin )
	// printt( targetAngles + <0,60,0> )
	// printt( " - ---- - " )

	// mover.NonPhysicsMoveTo( targetOrigin, 35.0, 0.0, 10.0 )
	// mover.NonPhysicsRotateTo( targetAngles + <0,60,0>, 35.0, 0.0, 10.0 )
	
	foreach( entity p in GetPlayerArray() )
	{
		delaythread( 4.75 ) Remote_CallFunction_Replay( p, "ServerCallback_DoRumble", 0 )
		delaythread( 5.5 ) Remote_CallFunction_Replay( p, "ServerCallback_DoRumble", 2 )
	}
	wait 20.5
	waitthread PlayDialogue( "TYPHON_1a", player )
	wait 0.75
	waitthread PlayDialogue( "TYPHON_1b", player )
	wait 0.75
	waitthread PlayDialogue( "TYPHON_1c", player )
	wait 1.9
	thread TyphonDialogue( player )
	wait 1.0

	float fadetime = 4.0
	foreach( entity p in GetPlayerArray() )
		ScreenFadeToBlack( p, fadetime, 20.0 )
	wait fadetime
	dropship.ClearParent()

	foreach( entity p in GetPlayerArray() )
		p.ClearParent()

	mover.Destroy()
	player.SetPlayerSettingsWithMods( "civilian_solo_pilot", [] )
	
	foreach( entity p in GetPlayerArray() )
		Remote_CallFunction_NonReplay( p, "ServerCallback_SetTyphonColorCorrectionWeight", 0.0, 0.1 )
		
	wait 5.0
}

void function TyphonDialogue( entity player )
{
	waitthread PlayDialogue( "TYPHON_2", player )
	wait 0.2
	waitthread PlayDialogue( "TYPHON_3", player )
}

void function AnimateStuff( entity player, entity planet, entity dropship, entity mover )
{
	player.SetOrigin( mover.GetOrigin() )
	
	FullyHidePlayers()

	// delaythread( 4.5 ) FlashWhite( player, 0.1, 0.3, 255.0 )
	foreach( entity p in GetPlayerArray() )
		delaythread( 4.5 ) Remote_CallFunction_Replay( p, "ServerCallback_GlowFlash", 1.0, 5.0 )

	thread PlayAnimTeleport( dropship, "dropship_planet_ex_ending", mover )
	thread PlayAnim( planet, "planet_ex_ending" )
	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.0
	sequence.firstPersonAnim = "ptpov_planet_ex_ending"
	sequence.thirdPersonAnim = "pt_planet_ex_ending"
	sequence.viewConeFunction = ViewConeTight
	
	foreach( entity p in GetPlayerArray() )
	{
		if ( p != player )
			thread FirstPersonSequence( sequence, p, mover )
	}

	waitthread FirstPersonSequence( sequence, player, mover )

	// thread PlayAnimTeleport( dropship, "dropship_planet_explosion_slow_2", mover )
	// thread PlayAnim( planet, "animation_slow_2" )
	// FirstPersonSequenceStruct sequence2
	// sequence2.blendTime = 0.0
	// sequence2.firstPersonAnim = "ptpov_planet_explosion_slow_2"
	// sequence2.thirdPersonAnim = "pt_planet_explosion_slow_2"
	// sequence2.viewConeFunction = ViewConeTight
	// waitthread FirstPersonSequence( sequence2, player, mover )
}

void function AnimatePlanet( entity player, entity rotator )
{
	entity planet = GetEntByScriptName( "planet_typhon_animated" )
	EmitSoundOnEntity( planet, "skyway_scripted_risingworld_postwarp_world_breakup" )
	waitthread PlayAnim( planet, "animation_slow_1" )
	thread MoverRoll( rotator )
	thread PlayAnim( planet, "animation_slow_2" )
	wait 0.1
	CreateShake( player.GetOrigin(), 2.5, 105, 15, 5000 ).kv.spawnflags = 4 // SF_SHAKE_INAIR
	// waitthread PlayAnim( planet, "animation" )
}

void function MoverRoll( entity mover )
{
	mover.EndSignal( "OnDestroy" )

	float roll = 5.0
	float rollTime = 4.0

	float firstRollTime = 1.0
	float firstRoll = 10.0
	mover.NonPhysicsSetRotateModeLocal( true )
	mover.NonPhysicsRotateTo( <0,0,-firstRoll>, firstRollTime, 0.0, firstRollTime )
	wait firstRollTime

	while ( 1 )
	{
		mover.NonPhysicsRotateTo( <0,0,roll>, rollTime, rollTime*0.5, rollTime*0.5 )
		wait rollTime
		mover.NonPhysicsRotateTo( <0,0,-roll>, rollTime, rollTime*0.5, rollTime*0.5 )
		wait rollTime
	}
}

void function HarmonyStartPointSetup( entity player )
{
	file.dropship = GetEntByScriptName( "escape_ship" )
	entity dropship = file.dropship
	dropship.SetModel( CROW_HERO_MODEL )
	dropship.DisableHibernation()
	player.SetInvulnerable()
	player.DisableWeapon()

	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.0
	sequence.attachment = "RESCUE"
	sequence.firstPersonAnim = "ptpov_skyway_world_run_idle"
	sequence.thirdPersonAnim = "pt_skyway_world_run_idle"
	sequence.viewConeFunction = ViewConeTight
	thread FirstPersonSequence( sequence, player, dropship )
	player.SetParent( dropship, "RESCUE", true, 0.2 )

	ScreenFadeToBlack( player, 0.0, 20.0 )
}

void function HarmonySkipped( entity player )
{
	entity helmet = GetEntByScriptName( "jack_helmet" )
	vector hOrg = helmet.GetOrigin()
	vector hAng = helmet.GetAngles()
	Remote_CallFunction_Replay( player, "ServerCallback_CreateHelmet", hOrg.x, hOrg.y, hOrg.z, hAng.x, hAng.y, hAng.z )
	helmet.Destroy()
}

void function Parent( entity p, entity ref )
{
	p.SetParent( ref, "", false, 0.0 )
}

void function SP_HarmonyThread( entity player )
{
	foreach( entity p in GetPlayerArray() )
	{
		MarkThisLevelAsCompleted( p )
		UpdateHeroStatsForPlayer( p )
	}

	SetConVarInt( "sp_unlockedMission", 9 )
	

	// if ( GetBugReproNum() == 184330 )
	{
		array<entity> allprops = GetEntArrayByClass_Expensive( "prop_dynamic" )
		foreach ( p in allprops )
		{
			if ( p.GetModelName() == $"models/vehicle/crow_dropship/crow_dropship_xsmall.mdl" )
			{
				entity ref = p.GetParent()
				if ( ref != null )
				{
					p.ClearParent()
					p.Anim_Stop()
					p.Anim_Play( "crow_wheels_up_xs" )
					delaythread( 0.2 ) Parent( p, ref )
				}
			}
		}
	}

	wait 0.2

	FlagSet( "HarmonySceneStart" )

	FlagSet( "ShowAlternateMissionLog" )
	UpdatePauseMenuMissionLog( player )

	array<entity> props = GetEntArrayByScriptName( "harmony_props" )
	foreach ( p in props )
	{
		p.SetFadeDistance( 80000 )
		p.EnableRenderAlways()
		p.DisableHibernation()
	}

	entity helmet = GetEntByScriptName( "jack_helmet" )
	vector hOrg = helmet.GetOrigin()
	vector hAng = helmet.GetAngles()
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( p, "ServerCallback_CreateHelmet", hOrg.x, hOrg.y, hOrg.z, hAng.x, hAng.y, hAng.z )
		thread HarmonyBGRadio( p )
	}
	helmet.Destroy()

	wait 2.0

	float fadetime = 20.0
	foreach( entity p in GetPlayerArray() )
		ScreenFadeFromBlack( p, fadetime, 1.0 )

	array<entity> debrisMid = GetEntArrayByScriptName( "core_debris_mid" )
	foreach ( d in debrisMid )
	{
		d.Hide()
	}
	debrisMid = GetEntArrayByScriptName( "floating_debris" )
	foreach ( d in debrisMid )
	{
		d.Hide()
	}

	entity dropship = file.dropship

	player.ClearParent()

	dropship.Destroy()

	entity spacenode = GetEnt( "spacenode_2" )
	entity spacenodeEnd = GetEnt( "spacenode_end_move" )

	entity mover = CreateEntity( "point_viewcontrol" )
	mover.kv.spawnflags = 56 // infinite hold time, snap to goal angles, make player non-solid

	mover.SetOrigin( spacenode.GetOrigin() )
	mover.SetAngles( spacenode.GetAngles() )
	DispatchSpawn( mover )

	entity skyCamHarmony = GetEnt( "skybox_cam_skyway_harmony" )
	// vector fwd = AnglesToForward( skyCamHarmony.GetAngles() )
	// skyCamHarmony.SetOrigin( -1*fwd )
	foreach( entity p in GetPlayerArray() )
	{
		p.SetSkyCamera( skyCamHarmony )
		p.LerpSkyScale( 0.0, 0.01 )
		p.SetOrigin( spacenodeEnd.GetOrigin() )
		p.SetParent( mover, "", false, 0.0 )
		p.Hide()
		ViewConeZero( p )
		p.SetViewEntity( mover, true )
	}

	entity trueMover = CreateScriptMover()
	trueMover.SetOrigin( mover.GetOrigin() )
	trueMover.SetAngles( mover.GetAngles() )

	mover.SetParent( trueMover )
	EmitSoundOnEntity( mover, "skyway_scripted_harmony_sequence" )

	thread HarmonyDialogue( player )

	float M = 1000000
	foreach( entity p in GetPlayerArray() )
	{
		Remote_CallFunction_Replay( p, "ServerCallback_SetNearDOF", 290, 300, 0.1 )
		Remote_CallFunction_Replay( p, "ServerCallback_SetDOF", 9*M, 10*M, 0.1 )
	}

	wait 2.0

	float time = 1.5
	foreach( entity p in GetPlayerArray() )
	{
		delaythread( 22.0 ) Remote_CallFunction_Replay( p, "ServerCallback_SetDOF", 0, 10*M, time )
		// you may think this lerp time is ridiculously high, but it looks good so WHATEVER RIGHT?
		delaythread( 16.0 + time ) Remote_CallFunction_Replay( p, "ServerCallback_SetNearDOF", 0, 10, 85 )
		delaythread( 22.0 + time ) Remote_CallFunction_Replay( p, "ServerCallback_SetDOF", 1000, 2000, 6 )
	}

	trueMover.NonPhysicsMoveTo( spacenodeEnd.GetOrigin(), 32.0, 5.0, 15.0 )

	wait 28.3
	//Remote_CallFunction_Replay( player, "ServerCallback_BeginHelmetBlink" ) --> moved to end of credits
	wait 5.0
	foreach( entity p in GetPlayerArray() )
		Remote_CallFunction_Replay( p, "ServerCallback_ScreenFlickerToBlack" )
	wait 1.0
}

void function HarmonyDialogue( entity player )
{
	wait 3.0
	waitthread PlayDialogue( "HARMONY_1", player )
	FlagSet( "HarmonyRadio2" )
	wait 0.75
	waitthread PlayDialogue( "HARMONY_2", player )
	wait 1.25
	FlagSet( "HarmonyRadio3" )
	waitthread PlayDialogue( "HARMONY_3", player )
	wait 3.5
	waitthread PlayDialogue( "HARMONY_4", player )
}

void function HarmonyBGRadio( entity player )
{
	waitthread PlayDialogue( "HARMONY_RD_1", player )
	wait 3.0
	waitthread PlayDialogue( "HARMONY_RD_2", player )

	FlagWait( "HarmonyRadio2" )

	waitthread PlayDialogue( "HARMONY_RD_3", player )

	FlagWait( "HarmonyRadio3" )

	wait 2.0

	waitthread PlayDialogue( "HARMONY_RD_4", player )
}

void function TriggerDisableDisembark( entity trigger )
{
	trigger.SetEnterCallback( TriggerDisableDisembarkEnter )
	trigger.SetLeaveCallback( TriggerDisableDisembarkLeave )
}

void function TriggerDisableDisembarkEnter( entity trigger, entity player )
{
	Disembark_Disallow( player )
}

void function TriggerDisableDisembarkLeave( entity trigger, entity player )
{
	Disembark_Allow( player )
}

void function RandomFlyingChunksThink( entity chunk )
{
	chunk.Hide()
	FlagWait( expect string( chunk.kv.script_flag ) )
	// if ( chunk.HasKey( "script_delay" ) )
	// {
	// 	wait float( chunk.kv.script_delay )
	// }
	chunk.Show()
	FlagWait( "HideWorldRunRandoms" )
	chunk.Destroy()
}

void function RandomRotatingChunksThink( entity chunk )
{
	chunk.EndSignal( "OnDestroy" )
	chunk.Hide()
	FlagWait( "StartRise" )
	chunk.Show()
	entity coreOrigin = GetEntByScriptName( "core_origin" )
	entity mover = CreateScriptMover( coreOrigin.GetOrigin() )
	chunk.SetParent( mover )

	float rotateAmount = RandomFloatRange( 50, 100 )
	rotateAmount *= RandomFloatRange( 0, 1 ) > 0.5 ? 1 : -1
	entity rotator = CreateScriptMover( chunk.GetOrigin(), < 0, 0, 0 >, 0 )
	rotator.NonPhysicsSetMoveModeLocal( true )
	// while ( 1 )
	{
		//rotator.SetOrigin( dMid.GetOrigin() )
		//rotator.kv.SpawnAsPhysicsMover = 0
		//DispatchSpawn( rotator )
		//rotator.Hide()

		chunk.SetParent( rotator, "", true )
		rotator.SetParent( mover, "", true )

		rotator.NonPhysicsRotate( < 1, 1, 1 >, RandomFloatRange(15,50) )
		mover.NonPhysicsRotate( <0,0,1>, rotateAmount )
		wait 3.0
	}
	FlagWait( "HideWorldRunRandoms" )
	mover.Destroy()
}

void function WorldRunSoundEmitterThink( entity org )
{
	entity island = org.GetLinkEnt()
	entity mover = CreateScriptMover( org.GetOrigin(), org.GetAngles() )
	string sound = expect string( org.kv.script_sound )
	mover.SetParent( island )
	org.Destroy()
	FlagWait( "StartRise" )

	wait 1.0 // wait for things to get into position

	mover.DisableHibernation()

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetRadius( 1500 )
	trigger.SetAboveHeight( 1500 )
	trigger.SetBelowHeight( 1500 )
	trigger.SetOrigin( mover.GetOrigin() )
	DispatchSpawn( trigger )
	trigger.SetParent( mover, "REF", false )
	trigger.SetEnterCallback( StartSound )

	WaitSignal( trigger, "OnTrigger" )

	trigger.Destroy()

	EmitSoundOnEntity( mover, sound )
	// while ( !Flag( "HideWorldRunRandoms" ) )
	// {
	// 	DebugDrawSphere( mover.GetOrigin(), 10, 255, 0, 0, true, 0.5 )
	// 	wait 0.1
	// }
	FlagWait( "HideWorldRunRandoms" )
	mover.Destroy()
}

void function StartSound( entity trigger, entity player )
{
	trigger.Signal( "OnTrigger" )
}

void function Bombardment_DamagedEntity( entity victim, var damageInfo )
{
	if ( victim.IsPlayer() )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.2 )
	}
}

void function BullseyeSettings( entity npc )
{
	npc.SetNPCPriorityOverride( 10 )
}

void function FakeGuySpawnerThink( entity org )
{
	entity guy = CreateSoldier( TEAM_MILITIA, org.GetOrigin(), org.GetAngles() )
	DispatchSpawn( guy )
	entity mover = CreateScriptMover( org.GetOrigin(), org.GetAngles() )
	entity trigger = org.GetLinkEnt()
	guy.SetParent( mover )
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.SetNoTarget( true )
	guy.SetInvulnerable()
	guy.Hide()
	TakeAllWeapons( guy )
	mover.SetOwner( trigger )

}

void function RestartInjectorSounds( entity player )
{
	thread RestartInjectorSounds_Internal( player )
}

void function RestartInjectorSounds_Internal( entity player )
{
	FlagWait( "EntitiesDidLoad" )

	wait 0.1

	// in between killing slone and pulling the injector
	if ( Flag( "InjectorRoomDone" ) && !Flag( "StoppingInjector" ) )
	{
		entity injector = GetEntByScriptName( "injector_gun" )
		StopSoundOnEntity( injector, "skyway_scripted_injector_stage1" )
		StopSoundOnEntity( injector, "skyway_scripted_injector_stage2" )
		StopSoundOnEntity( injector, "skyway_scripted_injector_stage3" )
		StopSoundOnEntity( injector, "skyway_scripted_injector_stage4" )

		EmitSoundOnEntity( injector, "skyway_scripted_injector_stage1_loop_only" )
		EmitSoundOnEntity( injector, "skyway_scripted_injector_stage2_loop_only" )
		EmitSoundOnEntity( injector, "skyway_scripted_injector_stage3_loop_only" )
		file.soundsToStop.append( "skyway_scripted_injector_stage1_loop_only" )
		file.soundsToStop.append( "skyway_scripted_injector_stage2_loop_only" )
		file.soundsToStop.append( "skyway_scripted_injector_stage3_loop_only" )
	}
}