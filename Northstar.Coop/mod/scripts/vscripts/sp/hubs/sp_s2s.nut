global function gf 			// get file
global function killall 	// kill all enemies
global function DeckTitanFallsOffEdge
global function MaltaGuns_GunnerDeathAnim

//fast testing purposes
global function Trinity_Explode
global function CreateAirBattle
global function MaltaBay_ElevatorGag
global function PlayerStumbleThink
global function AirBattle_LaunchFromMalta
global function AirBattle_LaunchFromTrinity
global function AirBattle_Replace
global function MaltaSideGunsRandomFire

#if DEV
global function RecordWidowJump
global function Record1
global function Record2
global function Record3
global function Record4
#endif

global function MaltaWidow_UseRecordedAnim
global function MaltaWidow_UseRecordedAnimBear
global function MaltaWidow_UseRecordedAnimDroz
global function MaltaWidow_UseRecordedAnimGates
global function MaltaWidow_UseRecordedAnimDavis
global function MaltaWidow_TeamJump
global function PlayBridgeWindFx
global function LifeBoats_SpawnRunners
global function CoreRoom_ForwardHint
global function PlayerFallingDeath

global function AnimCallback_ParentBeforeAnimating
global function AnimCallback_ParentBeforeAnimating_MaltaWidow

global function BT_WaitOnBarkerShip

global function ReplacePlayer0

struct SkyBoxLandSection
{
	//lanes
	table<string,entity> lane
	array<entity> extras
}

struct FCVO
{
	string line
	entity speaker
}

struct AirBattleStruct
{
	float xRange
	float yRange
	float zRange
	vector bounds

	table<int,void functionref(ShipStruct,vector)> AirBattle_ReplaceShipFunc
	vector functionref(int) AirBattle_GetOffsetFunc
	int functionref(int) AirBattle_GetTeamFunc
	int functionref(int,int) AirBattle_GetMainIndexFunc
}

struct MyFile
{
	// spawnpointWidow
	ShipStruct& SpawnPointWidow

	entity player
	ShipStruct& playerWidow
	vector playerWidow_scrOffset
	ShipStruct& crow64
	ShipStruct& sarahWidow
	ShipStruct& respawnWidow

	ShipStruct& gibraltar
	ShipStruct& barkership
	ShipStruct& malta
	ShipStruct& OLA
	ShipStruct& trinity
	ShipStruct& viperShip

	entity skyRig
	float worldCenterLeadDist
	int maltaRunnersComplete = 0

	//heroes
	entity davis
	entity droz
	entity gates
	entity bear
	entity sarahTitan
	entity viper

	//airbattle
	entity airBattleNode
	AirBattleStruct& airBattleData
	table<int,entity> rocketDummy
	table<int,array<ShipStruct> > dropships

	//misc
	entity sculptor
	entity objBridgePanel
	float driftWC_MaxSpeed
	float driftWC_MaxAcc
	table<string,table<asset,array<asset> > > landTree
	table<entity,vector> edgeMeleeForce
	array<entity> draconis_PA
	PilotLoadoutDef& loadout
	int callsignIndex = 0
	int gunRackLines = 0
	string draconisPAsnd = ""

	entity coreGlowFX1
	entity coreGlowFX2

	table< int, StreamingData > DynamicStreamingData
}
MyFile file

const asset ANIM_widowJumpBear_A = $"anim_recording/s2s_record_widowJump1a.rpak"
const asset ANIM_widowJumpBear_B = $"anim_recording/s2s_record_widowJump1b.rpak"
const asset ANIM_widowJumpBear_C = $"anim_recording/s2s_record_widowJump1c.rpak"

const asset ANIM_widowJumpDroz_A = $"anim_recording/s2s_record_widowJump2a.rpak"
const asset ANIM_widowJumpDroz_B = $"anim_recording/s2s_record_widowJump2b.rpak"
const asset ANIM_widowJumpDroz_C = $"anim_recording/s2s_record_widowJump2c.rpak"

const asset ANIM_widowJumpGates_A = $"anim_recording/s2s_record_widowJump3a.rpak"
const asset ANIM_widowJumpGates_B = $"anim_recording/s2s_record_widowJump3b.rpak"
const asset ANIM_widowJumpGates_C = $"anim_recording/s2s_record_widowJump3c.rpak"

const asset ANIM_widowJumpDavis_A = $"anim_recording/s2s_record_widowJump4a.rpak"
const asset ANIM_widowJumpDavis_B = $"anim_recording/s2s_record_widowJump4b.rpak"
const asset ANIM_widowJumpDavis_C = $"anim_recording/s2s_record_widowJump4c.rpak"

const asset MODEL_DAVIS 	= $"models/humans/pilots/sp_medium_stalker_m.mdl"
const asset MODEL_DROZ 		= $"models/humans/pilots/sp_medium_reaper_m.mdl"
const asset MODEL_GATES 	= $"models/humans/pilots/sp_medium_geist_f.mdl"
const asset MODEL_BEAR 		= $"models/humans/pilots/sp_heavy_roog_m.mdl"
const asset MODEL_VIPER_HATCH = $"models/props/titan_northstar_hatch/titan_northstar_hatch_animated.mdl"
const asset MODEL_VIPER_PILOT = $"models/humans/heroes/imc_hero_viper.mdl"
const asset MODEL_BT_ARM	= $"models/props/bt_left_arm/bt_left_arm_animated.mdl"

const asset PLAYER_WIND_FX 	= $"P_wind_cruising"
const asset BOSS_TITAN_DEATH_FX	= $"P_s2s_viper_death_fire"
const asset BOSS_TITAN_EXP_FX	= $"xo_exp_death_s2s"
const asset ION_BALL 		= $"P_ion_moving_proj"
const asset CANNON_FX		= $"P_muzzleflash_MaltaGun"
const asset CANNON_IMPACT	= $"P_exp_flak_s2s"
const asset BREACH_FX1 		= $"p_impact_exp_smll_air"
const asset BREACH_FX_GLASS		= $"P_glass_exp_breach"
const asset BT_FX_GLASS		= $"P_glass_exp_bridge"
const asset BT_FX_GLASS_SML	= $"P_glass_exp_bridge_SML"
const asset SATCHEL_BLINK_FX = $"wpn_satchel_clacker_glow_LG_1"
const asset BRIDGE_GLASS_WIND_FX = $"P_s2s_bridge_wind"
const asset FX_KILLSHOT_BLOODSPRAY = $"P_deathfx_human"
const asset FX_LIFEBOAT_LAUNCH 		= $"P_veh_ePod_launch"
const asset FX_LIFEBOAT_LIGHT 		= $"P_veh_ePod_light"
const asset FX_BT_ARM_DAMAGED 	= $"P_xo_arm_damaged"
const asset FX_BT_ARM_DAMAGED_POP 	= $"P_xo_arm_damaged_pop"
const asset FX_BT_ARM_DAMAGED_POP_SM = $"P_xo_arm_damaged_pop_SM"
const asset FX_BT_VENT_FIRE = $"xo_health_dam_exhaust_fire_1"
const asset FX_VIPER_COCKPIT_DLIGHT = $"P_dlight_cokpit_viper"

const asset VIPER_CORE_EFFECT = $"P_titan_core_atlas_blast"
const asset ARK_LIGHT_FX 		= $"P_s2s_coreroom_core_light"
const asset SHIPFIRE_FX			= $"P_ship_fire_large"

const asset RIG_LAND_SKYBOX = $"models/vistas/s2s_land_attachpoints_neg1000x.mdl"

const asset SE_LAND_A 		= $"models/vistas/s2s_se_a.mdl"
const asset SE_LAND_B 		= $"models/vistas/s2s_se_b.mdl"
const asset SE_LAND_AB 		= $"models/vistas/s2s_se_trans_ab.mdl"
const asset SE_LAND_BA 		= $"models/vistas/s2s_se_trans_ba.mdl"

const asset SE_VISTA_A1		= $"models/vistas/s2s_se_canyon_vista_a.mdl"
const asset SE_VISTA_A2		= $"models/vistas/s2s_se_canyon_vista_c.mdl"
const asset SE_VISTA_A3		= $"models/vistas/s2s_se_canyon_vista_e.mdl"
const asset SE_VISTA_A4		= $"models/vistas/s2s_se_canyon_vista_g.mdl"
const asset SE_VISTA_B1		= $"models/vistas/s2s_se_canyon_vista_b.mdl"
const asset SE_VISTA_B2		= $"models/vistas/s2s_se_canyon_vista_d.mdl"
const asset SE_VISTA_B3		= $"models/vistas/s2s_se_canyon_vista_f.mdl"
const asset SE_VISTA_B4		= $"models/vistas/s2s_se_canyon_vista_h.mdl"

const asset SE_CLOUDS_A		= $"models/vistas/s2s_se_clouds_front_a.mdl"
const asset SE_CLOUDS_B		= $"models/vistas/s2s_se_clouds_front_b.mdl"
const asset SE_CLOUDS_C		= $"models/vistas/s2s_se_clouds_front_c.mdl"
const asset SE_SPIRE 		= $"models/vistas/s2s_se_spire_a.mdl"

const asset SE_DRACONIS 	= $"models/vehicles_r2/spacecraft/draconis/draconis_flying_1000x.mdl"
const asset SE_MALTA 		= $"models/vehicles_r2/spacecraft/malta/malta_flying_hero_1000x.mdl"

const asset SATCHEL_MODEL 		= $"models/weapons/caber_shot/caber_shot_thrown.mdl"
const asset BRIDGE_GLASS_CRACKED = $"models/s2s/s2s_bridge_glass_cracked.mdl"
const asset BRIDGE_GLASS_CRACKED_V2 = $"models/s2s/s2s_bridge_glass_cracked_v2.mdl"
const asset BRIDGE_GLASS_CRACKED_V3 = $"models/s2s/s2s_bridge_glass_cracked_v3.mdl"
const asset BRIDGE_GLASS_CRACKED_V4 = $"models/s2s/s2s_bridge_glass_cracked_v4.mdl"
const asset BRIDGE_GLASS_CRACKED_V5 = $"models/s2s/s2s_bridge_glass_cracked_v5.mdl"
const asset BRIDGE_GLASS_CRACKED_V6 = $"models/s2s/s2s_bridge_glass_cracked_v6.mdl"

const asset OLA_FLYING_MODEL 	= $"models/vehicles_r2/spacecraft/draconis/draconis_flying_hero.mdl"
const asset CORE_USE_MODEL 		= $"models/containers/pelican_case_large_open.mdl"
const asset ESCAPE_POD_MODEL_CHEAP 	= $"models/vehicle/escape_pod/escape_pod_dyn.mdl"
const asset JACK_MODEL 			= $"models/humans/heroes/mlt_hero_jack.mdl"

const asset PLAYERWIDOWDEATHFX = $"P_veh_exp_crow"

const string REALDRONELIFT = "droneBayReal2"
const float LIGHTCOVERDELTA = 512

//cs_canyon_run_A
//vs_canyon_run_A
//vs_canyon_run_loop


const asset MILITIA_DECOY_SHIP_MODEL 	= $"models/vehicles_r2/spacecraft/trinity/s2s_trinity_destroyed.mdl"

const asset FX_DECOY_SHIP_DESTRUCTION 	= $"P_exp_trin_death"
const asset FX_DECK_FLAP_WIND 			= $"P_s2s_flap_wind"

const float DEF_WORLDCENTERLEADDIST = 5000
const float GRAVITYFRAC = 0.87

global function CodeCallback_MapInit
void function CodeCallback_MapInit()
{
	FlagInit( "DriftWorldCenter" )

	FlagInit( "Fastball_PickedUpPlayer" )
	FlagInit( "Barkership_EnderVO" )
	FlagInit( "MaltaLiftDoorsOpen" )
	FlagInit( "Stop_MaltaStressSounds" )
	FlagInit( "StopAirBattleDeaths_IMC" )
	FlagInit( "StopAirBattleDeaths_MILITIA" )
	FlagInit( "StopAirBattleRespawns_IMC" )
	FlagInit( "StopAirBattleRespawns_MILITIA" )
	FlagInit( "StopWindFx" )
	FlagInit( "EndAirBattle" )
	FlagInit( "StopDynamicSky" )
	FlagInit( "PlayerInSarahWidow" )
	FlagInit( "PlayerOnSarahWidow" )
	FlagInit( "PlayerInOrOnSarahWidow" )
	FlagInit( "PlayerOutsidePlayerWidow" )
	FlagInit( "PlayerInsidePlayerWidow" )
	FlagInit( "PlayerInOrOnCrow64" )
	FlagInit( "PlayingGunsMusic" )
	FlagInit( "Hangar_LandBear" )
	FlagInit( "Hangar_LandDavis" )
	FlagInit( "Hangar_LandDroz" )
	FlagInit( "Hangar_LandGates" )

	RegisterSignal( "ButtonPressedJump" )
	RegisterSignal( "ButtonPressedAttack" )
	RegisterSignal( "Init_StreamingClient" )

	RegisterSignal( "coreAlarm" )
	RegisterSignal( "fireCore" )
	RegisterSignal( "AirBattle_ShipDied" )
	RegisterSignal( "FlightPanelAnimEnd" )
	RegisterSignal( "EndFlightControlOutputFunc" )
	RegisterSignal( "maltaRunnersComplete" )
	RegisterSignal( "landpop" )
	RegisterSignal( "customDeployNow" )
	RegisterSignal( "MaltaSideGunAimAtThink" )
	RegisterSignal( "ShouldReact" )
	RegisterSignal( "animRecordingSignal" )
	RegisterSignal( "satchelgrab" )
	RegisterSignal( "satchelthrow" )
	RegisterSignal( "satchelblow" )
	RegisterSignal( "vo64" )
	RegisterSignal( "OnWeaponNpcPrimaryAttack_weapon_DMR" )
	RegisterSignal( "OnWeaponNpcPrimaryAttack_weapon_mastiff" )
	RegisterSignal( "OnWeaponNpcPrimaryAttack_weapon_lstar_start" )
	RegisterSignal( "OnWeaponNpcPrimaryAttack_weapon_lstar" )
	RegisterSignal( "OnWeaponNpcPrimaryAttack_weapon_lstar_end" )
	RegisterSignal( "deckGunOff" )
	RegisterSignal( "pilot_Embark" )
	RegisterSignal( "pilot_Disembark" )
	RegisterSignal( "crack" )
	RegisterSignal( "break" )
	RegisterSignal( "DoCore" )
	RegisterSignal( "StopAimingFlightCore" )
	RegisterSignal( "shoot" )
	RegisterSignal( "stop" )
	RegisterSignal( "MaltaDeck_GunsSoundThink" )
	RegisterSignal( "ViperDeleteGun" )
	RegisterSignal( "EndFightTackle" )
	RegisterSignal( "EndFightCockpitLost" )
	RegisterSignal( "armRip" )
	RegisterSignal( "armDrop" )
	RegisterSignal( "hatchopen" )
	RegisterSignal( "GunnerReact" )

	RegisterSignal( "CCSM_Ready" )
	RegisterSignal( "CCSM_Stop" )
	RegisterSignal( "CCSM_Jump" )
	RegisterSignal( "CCSM_Wait" )

	FlagInit( "trinityLeftHangarDoor1" )
	FlagInit( "trinityLeftHangarDoor2" )
	FlagInit( "FlankSpeed" )
	FlagInit( "Start_TrinityDoorsClosed" )
	FlagInit( "BossIntro_TitanFightHit" )
	FlagInit( "PlayerFallOut")
	FlagInit( "FreeFall_VO_gotchakid" )
	FlagInit( "StartFastball1" )
	FlagInit( "BTFastballConvoDone" )
	FlagInit( "FastBallLaunched" )
	FlagInit( "MaltaIntroGuysGo" )
	FlagInit( "MaltaIntroFlyOver" )
	FlagInit( "MaltaIntro_ContactVoGood" )
	FlagInit( "PlayerJumpingToMalta" )
	FlagInit( "MaltaBayLiftGuySpawn" )
	FlagInit( "MaltaGuns_React" )
	FlagInit( "MaltaGunsClear" )
	FlagInit( "HeroCrewOnboard" )
	FlagInit( "malta_introGuys2_spawned" )
	FlagInit( "malta_introGuys3_spawned" )
	FlagInit( "maltaIntroGoToRacksVO_order" )
	FlagInit( "maltaIntroGoToRacksVO_going" )
	FlagInit( "maltaIntroGoToRacksVO_power" )
	FlagInit( "maltaIntroGoToRacksVO_online" )
	FlagInit( "maltaIntroGoToRacksVO_takecover" )
	FlagInit( "MaltaGunsCrowVOGo")
	FlagInit( "DoTheWidowJump" )
	FlagInit( "DavisLandedInHangar" )
	FlagInit( "windowRunPositions" )
	FlagInit( "Hangar_IntroIdles" )
	FlagInit( "HangarLiftDone" )
	FlagInit( "BreachBearRec1Done" )
	FlagInit( "BreachBearRec2Done" )
	FlagInit( "BreachDrozRec1Done" )
	FlagInit( "BreachDrozRec2Done" )
	FlagInit( "BreachGatesRec1Done" )
	FlagInit( "BreachGatesRec2Done" )
	FlagInit( "BreachDavisRec1Done" )
	FlagInit( "BreachDavisRec2Done" )
	FlagInit( "HangarFinished" )
	FlagInit( "CrewRunToBreach" )
	FlagInit( "breachRunGoBear" )
	FlagInit( "breachRunGoDavis" )
	FlagInit( "breachRunGoDroz" )
	FlagInit( "breachRunGoGates" )
	FlagInit( "StartingBreach" )
	FlagInit( "BridgeReact" )
	FlagInit( "BridgeBreached" )
	FlagInit( "BreachBearReady" )
	FlagInit( "BreachDavisReady" )
	FlagInit( "BreachDrozReady" )
	FlagInit( "BreachGatesReady" )
	FlagInit( "BridgeClear" )
	FlagInit( "PlayerUsedBridgeConsole" )
	FlagInit( "DeckGunsTurnedOff" )
	FlagInit( "BarkerBringsBtToReunite" )
	FlagInit( "PanelAnimEnded" )
	FlagInit( "MaltaOnCourse" )
	FlagInit( "BridgeSkipped" )
	FlagInit( "ViperFakeDead" )
	FlagInit( "MaltaDeckClear" )
	FlagInit( "Tackle_PlayerDisembarked" )
	FlagInit( "bt_tackle_fastball_started" )
	FlagInit( "ViperKillsBT" )
	FlagInit( "PlayerSavesBT" )
	FlagInit( "OLA_HatchOpen" )
	FlagInit( "LifeboatStart" )
	FlagInit( "CoreRoomPlayerPressedForward" )
	FlagInit( "CoreRoomFinalPush" )
	FlagInit( "EndingFailed" )
	FlagInit( "DroneLiftUsed" )
	FlagInit( "Start_PlayerWidowJoinsConvoy" )
	FlagInit( "TrinityDown" )
	FlagInit( "malta_gunGunner1Down" )
	FlagInit( "malta_gunGunner2Down" )
	FlagInit( "malta_gunGunner3Down" )
	FlagInit( "ViperReturns" )
	FlagInit( "PlayerJumpedIntoCore" )
	FlagInit( "KillCoreShake" )
	FlagInit( "CutToBlack" )

	PrecacheModel( MODEL_DAVIS )
	PrecacheModel( MODEL_DROZ )
	PrecacheModel( MODEL_GATES )
	PrecacheModel( MODEL_BEAR )
	PrecacheModel( RIG_LAND_SKYBOX )
	PrecacheModel( SE_LAND_A )
	PrecacheModel( SE_LAND_B )
	PrecacheModel( SE_LAND_AB )
	PrecacheModel( SE_LAND_BA )
	PrecacheModel( SE_VISTA_A1 )
	PrecacheModel( SE_VISTA_A2 )
	PrecacheModel( SE_VISTA_A3 )
	PrecacheModel( SE_VISTA_A4 )
	PrecacheModel( SE_VISTA_B1 )
	PrecacheModel( SE_VISTA_B2 )
	PrecacheModel( SE_VISTA_B3 )
	PrecacheModel( SE_VISTA_B4 )
	PrecacheModel( SE_CLOUDS_A )
	PrecacheModel( SE_CLOUDS_B )
	PrecacheModel( SE_CLOUDS_C )
	PrecacheModel( SE_DRACONIS )
	PrecacheModel( SE_MALTA )
	PrecacheModel( TITAN_VIPER_SCRIPTED_MODEL )
	PrecacheModel( MODEL_BT_ARM )
	PrecacheModel( MODEL_VIPER_HATCH )
	PrecacheModel( MODEL_VIPER_PILOT )
	PrecacheModel( MILITIA_DECOY_SHIP_MODEL )
	PrecacheModel( BRIDGE_GLASS_CRACKED )
	PrecacheModel( BRIDGE_GLASS_CRACKED_V2 )
	PrecacheModel( BRIDGE_GLASS_CRACKED_V3 )
	PrecacheModel( BRIDGE_GLASS_CRACKED_V4 )
	PrecacheModel( BRIDGE_GLASS_CRACKED_V5 )
	PrecacheModel( BRIDGE_GLASS_CRACKED_V6 )
	PrecacheModel( SATCHEL_MODEL )
	PrecacheModel( OLA_FLYING_MODEL )
	PrecacheModel( CORE_USE_MODEL )
	PrecacheModel( ESCAPE_POD_MODEL_CHEAP )

	PrecacheParticleSystem( PLAYER_WIND_FX )
	PrecacheParticleSystem( FX_BT_ARM_DAMAGED )
	PrecacheParticleSystem( FX_BT_ARM_DAMAGED_POP )
	PrecacheParticleSystem( FX_BT_ARM_DAMAGED_POP_SM )
	PrecacheParticleSystem( FX_BT_VENT_FIRE )
	PrecacheParticleSystem( FX_VIPER_COCKPIT_DLIGHT )
	PrecacheParticleSystem( ION_BALL )
	PrecacheParticleSystem( CANNON_FX )
	PrecacheParticleSystem( CANNON_IMPACT )
	PrecacheParticleSystem( BREACH_FX1 )
	PrecacheParticleSystem( BREACH_FX_GLASS )
	PrecacheParticleSystem( BT_FX_GLASS )
	PrecacheParticleSystem( BT_FX_GLASS_SML )
	PrecacheParticleSystem( SATCHEL_BLINK_FX )
	PrecacheParticleSystem( BRIDGE_GLASS_WIND_FX )
	PrecacheParticleSystem( BOSS_TITAN_DEATH_FX )
	PrecacheParticleSystem( BOSS_TITAN_EXP_FX )
	PrecacheParticleSystem( FX_DECOY_SHIP_DESTRUCTION )
	PrecacheParticleSystem( FX_DECK_FLAP_WIND )
	PrecacheParticleSystem( VIPER_CORE_EFFECT )
	PrecacheParticleSystem( ARK_LIGHT_FX )
	PrecacheParticleSystem( SHIPFIRE_FX )
	PrecacheParticleSystem( PLAYERWIDOWDEATHFX )
	PrecacheParticleSystem( FX_KILLSHOT_BLOODSPRAY )
	PrecacheParticleSystem( FX_LIFEBOAT_LAUNCH )
	PrecacheParticleSystem( FX_LIFEBOAT_LIGHT )

	InitS2SDialogue()
	ShSpS2SCommonInit()
	S2S_CommonInit()
	S2S_FSMInit()
	S2S_FlightInit()
	S2S_FastballInit()
	S2S_CapShipsInit()
	S2S_DropshipInit()
	S2S_WidowInit()
	MoUtilityInit()

	SPWeaponSwarmRockets_S2S_Init()
	SPWeaponViperBossRockets_S2S_Init()

	SetGlobalForcedDialogueOnly( true )

	AddCallback_EntitiesDidLoad( S2S_EntitiesDidLoad )
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	#if DEV
		AddDeathCallback( "npc_pilot_elite", DamageDebug )
		AddDeathCallback( "npc_turret_mega", DamageDebug2 )
	#endif

	AddCallback_OnPlayerRespawned( PlayerSpawned )
	AddSpawnCallback( "npc_pilot_elite", NoGeoCrush )
	AddSpawnCallback( "npc_soldier", NoGeoCrush )
	AddSpawnCallback( "npc_spectre", NoGeoCrush )
	AddSpawnCallback( "npc_stalker", NoGeoCrush )
	AddSpawnCallback( "npc_turret_mega", NoGeoCrush )
	AddPlayerDidLoad( PlayerDidLoad )
	AddCallback_OnLoadSaveGame( OnLoadSaveGame )
	AddCallback_OnPilotBecomesTitan( OnPilotBecomesTitan )
	AddCallback_OnTitanBecomesPilot( OnTitanBecomesPilot )

	AddStartPoint( "Level Start",		Start2_Main, 		Start2_Setup, 		Start2_Skip )
	AddStartPoint( "Intro",				Intro_Main, 		Intro_Setup, 		Intro_Skip )
	AddStartPoint( "Gibraltar",			Gibraltar_Main, 	Gibraltar_Setup, 	Gibraltar_Skip )
	AddStartPoint( "Boss Intro",		BossIntro_Main, 	BossIntro_Setup, 	BossIntro_Skip )
	AddStartPoint( "Widow Fall",		FreeFall_Main, 		FreeFall_Setup, 	FreeFall_Skip )
	AddStartPoint( "Barker Ship", 		Barkership_Main, 	BarkerShip_Setup, 	BarkerShip_Skip )
	AddStartPoint( "FastBall 1", 		Fastball_1_Main, 	Fastball_1_Setup, 	Fastball_1_Skip )
	AddStartPoint( "Malta Intro", 		MaltaIntro_Main,	MaltaIntro_Setup, 	MaltaIntro_Skip )
	AddStartPoint( "Malta Drone Room",	MaltaDrone_Main,	MaltaDrone_Setup, 	MaltaDrone_Skip )
	AddStartPoint( "Malta Guns", 		MaltaGuns_Main,		MaltaGuns_Setup, 	MaltaGuns_Skip )
	AddStartPoint( "Malta Widow Jump", 	MaltaWidow_Main,	MaltaWidow_Setup, 	MaltaWidow_Skip )
	AddStartPoint( "Malta Hangar", 		MaltaHangar_Main, 	MaltaHangar_Setup, 	MaltaHangar_Skip )
	AddStartPoint( "Malta Breach", 		MaltaBreach_Main, 	MaltaBreach_Setup, 	MaltaBreach_skip )
	AddStartPoint( "Malta Bridge", 		MaltaBridge_Main,	MaltaBridge_Setup, 	MaltaBridge_Skip )
	AddStartPoint( "Reunite with BT", 	Reunited_Main, 		Reunited_Setup, 	Reunite_Skip )
	AddStartPoint( "Malta Deck", 		MaltaDeck_Main, 	MaltaDeck_Setup,    MaltaDeck_Skip )
	AddStartPoint( "BT Tackle", 		BT_Tackle_Main, 	BT_Tackle_Setup, 	BT_Tackle_Skip )
	AddStartPoint( "Boss Fight", 		BossFight_Main, 	BossFight_Setup, 	BossFight_Skip )
	AddStartPoint( "Viper Dead", 		ViperDead_Main, 	ViperDead_Setup, 	ViperDead_Skip )
	AddStartPoint( "Life Boats", 		LifeBoats_Main, 	LifeBoats_Setup, 	LifeBoats_Skip )
	AddStartPoint( "Core Room", 		CoreRoom_Main, 		CoreRoom_Setup, 	CoreRoom_Skip )
	AddStartPoint( "OLA Crash", 		Ending_Main, 		Ending_Setup )

	AddStartPoint( "--------------", 		EOF, 					null, 		EOF_Skip )

	AddStartPoint( "TestBed", 				TestBedMain )
	AddStartPoint( "Dropship Combat Test", 	DropshipCombatTestMain )
	AddStartPoint( "LightEdit Connect", 	LightEditConnect )
	AddStartPoint( "TRAILER bridge", 		Trailer_Bridge )

	/////////////////////////////////////////////////
	//                   States
	
	AddState( "None" )
	AddState( "MaltaGuns" )
	AddState( "MaltaHanger" )
	AddState( "MaltaDeck" )
	AddState( "Fall" )
}

void function PlayerSpawned( entity player )
{
	AddButtonPressedPlayerInputCallback( player, IN_JUMP, ButtonPressedJump )
	thread PlayerWindFX( player )
	thread PlayerFallingDeath( player )
	thread Init_StreamingClient( player )
}

void function ReplacePlayer0()
{
	if ( GetPlayerArray().len() == 0 )
	{
		while( GetPlayerArray().len() == 0 )
		{
			wait 1
		}
	}
	
	file.player = GetPlayerArray()[0]
	SetPlayer0( file.player )
}

void function OnLoadSaveGame( entity player )
{
	thread Init_StreamingClient( player )
}

void function OnPilotBecomesTitan( entity pilot, entity titan )
{
	entity soul = GetSoulFromPlayer( pilot )
	soul.Signal( "pilot_Embark" )
	pilot.Signal( "pilot_Embark" )
	thread PlayerWindFX( titan )
}

void function OnTitanBecomesPilot( entity pilot, entity titan )
{
	entity soul = GetSoulFromPlayer( pilot )
	soul.Signal( "pilot_Disembark" )
	pilot.Signal( "pilot_Disembark" )
	thread PlayerWindFX( pilot )
}

void function ButtonPressedJump( entity player )
{
	player.Signal( "ButtonPressedJump" )
}

void function ButtonPressedAttack( entity player )
{
	player.Signal( "ButtonPressedAttack" )
}

void function NoGeoCrush( entity npc )
{
	npc.EnableNPCFlag( NPC_NO_MOVING_PLATFORM_DEATH )
}

MyFile function gf()
{
	return file
}

void function killall()
{
	array<entity> guys = GetNPCArrayOfTeam( TEAM_IMC )
	foreach( guy in guys )
	{
		if ( guy.IsInvulnerable() )
			continue

		guy.Destroy()
	}
}

void function EOF( entity player )
{
	bool loadNextLevel = true

	#if DEV
		if ( GetBugReproNum() != 0 )
			loadNextLevel = false
	#endif

	if ( loadNextLevel )
		Coop_LoadMapFromStartPoint( "sp_skyway_v1", "Level Start" )
	else
		Coop_LoadMapFromStartPoint( "sp_s2s", "OLA Crash" )


	WaitForever()
}

void function DamageDebug( entity npc, var damageInfo )
{
	if ( npc.GetTeam() != TEAM_MILITIA )
		return

	entity GetAttacker 	= DamageInfo_GetAttacker( damageInfo )
	float GetDamage 	= DamageInfo_GetDamage( damageInfo )
	int GetID 			= DamageInfo_GetDamageSourceIdentifier( damageInfo )

	printt( "NPC damage:  ", npc )
	printt( "Attacker:    ", GetAttacker )
	printt( "Damage:      ", GetDamage )
	printt( "Damage ID:   ", GetID )

	Assert( 0, "this should not be killed, if this happens, call over Mo or Haggerty immediately with the debugger attached" )
}

void function DamageDebug2( entity npc, var damageInfo )
{
	entity GetAttacker 	= DamageInfo_GetAttacker( damageInfo )
	float GetDamage 	= DamageInfo_GetDamage( damageInfo )
	int GetID 			= DamageInfo_GetDamageSourceIdentifier( damageInfo )

	printt( "NPC damage:  ", npc )
	printt( "Attacker:    ", GetAttacker )
	printt( "Damage:      ", GetDamage )
	printt( "Damage ID:   ", GetID )

	Assert( 0, "this should not be killed, if this happens, call over Mo or Haggerty immediately with the debugger attached" )
}

//CONST LIKE VALUES ( can't use consts because can't initialize LocalVec )
//###########################
// LEVEL START
//###########################
LocalVec V_START_MALTA
LocalVec V_START_OLA
void function Init_LevelStart()
{
	V_START_MALTA.v 				= < -8000, 30000, -500 >
	V_START_OLA.v 					= < 0, 80000, 9000 >
}
const vector START_MALTA_BOUNDS 	= < 1500, 500, 1000 >
const vector START_OLA_BOUNDS 		= < 3500, 500, 2500 >

//###########################
// LEVEL START 2
//###########################
LocalVec V_START2_PLAYER_0
LocalVec V_START2_PLAYER_1
LocalVec V_START2_TRINITY_0
LocalVec V_START2_TRINITY_1
LocalVec V_START2_TRINITY_2

LocalVec V_START2_DS_0_0
LocalVec V_START2_DS_1_0
LocalVec V_START2_DS_2_0
LocalVec V_START2_DS_3_0
LocalVec V_START2_DS_4_0

const vector START2_DS_OFFSET_0_0 	= < 2500,-2000,1100 >
const vector START2_DS_OFFSET_1_0 	= < 6000,0, 1500 >
const vector START2_DS_OFFSET_2_0 	= < 2500,-8000, 800 >
const vector START2_DS_OFFSET_3_0 	= < 7000,5000,150 >
const vector START2_DS_OFFSET_4_0 	= < 10000,1000,200 >

const vector START2_DS_OFFSET_0_1 	= < 2200,0,1300 >
const vector START2_DS_OFFSET_1_1 	= < 6000,2500,500 >
const vector START2_DS_OFFSET_2_1 	= < 2500,-3000,50 >
const vector START2_DS_OFFSET_3_1 	= < 6500,1000,-500 >
const vector START2_DS_OFFSET_4_1 	= < 9000,-3000, 100 >

const vector START2_DS_OFFSET_5_0 	= < 3000, 6000, 100 >
const vector START2_DS_OFFSET_5_1 	= < 4000, 1500, 1000 >
const vector START2_DS_OFFSET_6_0 	= < 4500, -1600, -100 >
const vector START2_DS_OFFSET_6_1 	= < 5500, -5000, -100 >
const vector START2_DS_OFFSET_7_0 	= < 4000, -3000, 600 >
const vector START2_DS_OFFSET_7_1 	= < 4000, -5000, 1300 >
const vector START2_DS_OFFSET_8_0 	= < 6000, -4000, 800 >
const vector START2_DS_OFFSET_8_1 	= < 8000, -4000, 1500 >

const float START2_PLAYER_GOALRADIUS = 1500

void function Init_LevelStart2()
{
	V_START2_PLAYER_0.v 			= < 0, -58000, 10000 >
	V_START2_PLAYER_1.v 			= V_START2_PLAYER_0.v + <0,27000 + START2_PLAYER_GOALRADIUS ,0>
	V_START2_TRINITY_0.v 			= V_START2_PLAYER_0.v + < 3500, 15000, -1300 >
	V_START2_TRINITY_1.v 			= V_START2_TRINITY_0.v + <3000,0,-1000>
	V_START2_TRINITY_2.v 			= V_START2_TRINITY_1.v + <4500,-3000,-1500>

	V_START2_DS_0_0.v 				= V_START2_PLAYER_0.v + < 0, 15000, 0 > + START2_DS_OFFSET_0_0
	V_START2_DS_1_0.v 				= V_START2_PLAYER_0.v + < 0, 15000, 0 > + START2_DS_OFFSET_1_0
	V_START2_DS_2_0.v 				= V_START2_PLAYER_0.v + < 0, 15000, 0 > + START2_DS_OFFSET_2_0
	V_START2_DS_3_0.v 				= V_START2_PLAYER_0.v + < 0, 15000, 0 > + START2_DS_OFFSET_3_0
	V_START2_DS_4_0.v 				= V_START2_PLAYER_0.v + < 0, 15000, 0 > + START2_DS_OFFSET_4_0
}
const vector START2_WIDOW_OFFSET_0 	= < 300, 200, -1000 >
const vector START2_WIDOW_BOUNDS 	= < 400, 850, 50 >
const vector START2_WIDOW_BOUNDS2 	= < 700, 850, 100 >
const vector START2_WIDOW_OFFSET_0b = < 1100, 300, 50 >
const vector START2_WIDOW_OFFSET_1 	= < 1500, -300, 0 >
const vector START2_WIDOW_OFFSET_2 	= < 4000, -300, 100 >

const vector START2_CROW_OFFSET_0 	= < 1000, -2700, 0 >
const vector START2_CROW_OFFSET_1 	= < 1500, 2000, 0 >
const vector START2_CROW_BOUNDS_0 	= < 500, 300, 0 >
const vector START2_CROW_BOUNDS 	= < 600, 850, 100 >

const vector START2_PLAYER_BOUNDS 	= <20, 20, 20>
const vector START2_DROPSHIP_BOUNDS = < 600, 850, 100 >
const vector START2_DROPSHIP_BOUNDS2 = < 1000, 900, 100 >
const vector START2_TRINITY_BOUNDS = < 800, 0, 100>

//###########################
// INTRO
//###########################
LocalVec V_INTRO2_PLAYER_1
LocalVec V_INTRO2_AIRBATTLE
LocalVec V_INTRO2_GIBRALTAR

const vector INTRO2_GB_OFFSET_0_0 	= < 1100,	3500 + -500,	400 >
const vector INTRO2_GB_OFFSET_1_0 	= < 3000,	3500 + 500,		-800 >
const vector INTRO2_GB_OFFSET_2_0 	= < 3500,	3500 + 0,		400 >
const vector INTRO2_GB_OFFSET_3_0 	= < 6000,	3500 + 200,		200 >
const vector INTRO2_GB_OFFSET_4_0 	= < 10000,	3500 + 0,		0 >

const vector INTRO2_GB_OFFSET_5_0 	= < 5000 + 1100,	500 + -500,		400 >
const vector INTRO2_GB_OFFSET_6_0 	= < 5000 + 3000,	500 + 500,		-800 >
const vector INTRO2_GB_OFFSET_7_0 	= < 5000 + 3500,	500 + 0,		400 >
const vector INTRO2_GB_OFFSET_8_0 	= < 5000 + 6000,	500 + 200,		200 >
const vector INTRO2_GB_OFFSET_9_0 	= < 5000 + 10000,	500 + 0,		0 >

const vector INTRO2_TRINITY_0 = < 14000, 0, -6000 >

const float INTRO2_PLAYER_GOALRADIUS = 1500

void function Init_Intro()
{
	V_INTRO2_PLAYER_1.v 			= V_START2_PLAYER_0.v + <0,40000 + INTRO2_PLAYER_GOALRADIUS ,0>
	V_INTRO2_AIRBATTLE.v 			= V_START2_PLAYER_0.v + < 0,50000, 0 >
	V_INTRO2_GIBRALTAR.v 			= V_INTRO2_PLAYER_1.v + < 0, 20000, 0 >
}
const vector INTRO2_GB_BOUNDS = < 800, 300, 100 >
const vector INTRO_GIBRALTAR_BOUNDS	= < 0, 0, 0 >
const vector INTRO_DROPSHIP_BOUNDS 	= < 200, 200, 200 >

//###########################
// GIBRALTAR
//###########################
LocalVec V_GIBRALTAR_PLAYER0
LocalVec V_GIBRALTAR_PLAYER1
LocalVec V_GIBRALTAR_PLAYER2

const float GIBRALTAR_DELTA_X = 3500

const vector GIBRALTAR_WIDOW_OFFSET_0 = START2_WIDOW_OFFSET_2 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_0_0 = START2_DS_OFFSET_0_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_1_0 = START2_DS_OFFSET_1_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_2_0 = START2_DS_OFFSET_2_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_3_0 = START2_DS_OFFSET_3_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_4_0 = START2_DS_OFFSET_4_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_5_0 = START2_DS_OFFSET_5_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_6_0 = START2_DS_OFFSET_6_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_7_0 = START2_DS_OFFSET_7_1 + < GIBRALTAR_DELTA_X, 0, 0 >
const vector GIBRALTAR_DS_OFFSET_8_0 = START2_DS_OFFSET_8_1 + < GIBRALTAR_DELTA_X, 0, 0 >

const vector GIBRALTAR_CROW_OFFSET_0 = < 500, 1500, 0 >

const GIBRALTAR_PLAYER_GOALRADIUS = 1500
const GIBRALTAR_PLAYER_GOALRADIUS2 = 600
void function Init_Gibraltar()
{
	V_GIBRALTAR_PLAYER0.v 			= V_INTRO2_PLAYER_1.v + < 0, 3000,0 >
	V_GIBRALTAR_PLAYER1.v 			= V_GIBRALTAR_PLAYER0.v + < -3500, 3000,0 >
	V_GIBRALTAR_PLAYER2.v 			= V_INTRO2_PLAYER_1.v + < -3000, 9500, 0 >
}
const vector GIBRALTAR_TRINITY_BOUNDS	= < 700, 0, 200 >
const vector GIBRALTAR_GIBRALTAR_BOUNDS	= < 5000, 0, 5000 >
const vector GIBRALTAR_PLAYER_BOUNDS	= < 200, 0, 200 >
const vector GIBRALTAR_DS_BOUNDS 		= < 600, 800, 100 >

//###########################
// BOSS INTRO
//###########################
LocalVec V_BOSSINTRO_PLAYER1
void function Init_BossIntro()
{
	V_BOSSINTRO_PLAYER1.v 			= V_START2_PLAYER_0.v + <0, 63000 ,0>
}
const vector BOSSINTRO_VIPER_DELTA0	= < 4500, 0, 250 >
const vector BOSSINTRO_VIPER_BOUNDS = < 100, 50, 50 >

LocalVec V_FREEFALL_BARKER
void function Init_Freefall()
{
	V_FREEFALL_BARKER.v 			= < 0, 2400, -4000 >
}
const vector FREEFALL_BARKER_BOUNDS = < 300, 0, 0 >

//###########################
// BARKERSHIP
//###########################
LocalVec V_BARKER_BARKER1A
LocalVec V_BARKER_BARKER1B
LocalVec V_BARKER_BARKER2
LocalVec V_BARKER_CROW
LocalVec V_BARKER_WIDOW
LocalVec V_BARKER_MALTA
LocalVec V_BARKER_TRINITY
LocalVec V_BARKER_OLA
LocalVec V_BARKER_GIBRALTAR
LocalVec V_BARKER_AIRBATTLE
const vector BARKER_WIDOW_OFFSET = < 1500, -1000, 1500 >
void function Init_Barker()
{
	V_BARKER_BARKER1A.v 			= < 500, 13000, -4000 >
	V_BARKER_BARKER1B.v 			= < -500, 13000, -4000 >
	V_BARKER_BARKER2.v 				= < 0,13000,-2000 >
	V_BARKER_CROW.v 				= V_BARKER_BARKER2.v + < 5000, 3000, 500 >
	V_BARKER_WIDOW.v 				= V_BARKER_BARKER2.v + BARKER_WIDOW_OFFSET
	V_BARKER_MALTA.v 				= < -8000, 30000, -500 >
	V_BARKER_TRINITY.v 				= < 9500, 30000, -500 >
	V_BARKER_OLA.v 					= < 0, 80000, 7000 >
	V_BARKER_GIBRALTAR.v 			= < 3000, -10000, 0 >
	V_BARKER_AIRBATTLE.v 			= < 0,20000, -500 >
}
const vector BARKER_BARKER_BOUNDS 	= < 550, 0, 100 >
const vector BARKER_CROW_BOUNDS 	= < 1000, 0, 0 >
const vector BARKER_WIDOW_BOUNDS 	= < 1000, 500, 500 >
const vector BARKER_MALTA_BOUNDS 	= < 1500, 500, 1000 >
const vector BARKER_TRINITY_BOUNDS	= < 1500, 3500, 1500 >
const vector BARKER_OLA_BOUNDS 		= < 3500, 500, 2500 >
const vector BARKER_GIBRALTAR_BOUNDS = < 5000, 500, 2000 >

//###########################
// FASTBALL 1
//###########################
LocalVec V_FASTBALL_BARKER
LocalVec V_FASTBALL_WIDOW
const vector FASTBALL_WIDOW_OFFSET = < 1500, 2000, 150 >
void function Init_Fastball1()
{
	V_FASTBALL_BARKER.v 			= V_BARKER_BARKER2.v + < 0,-3000,0 >
	V_FASTBALL_WIDOW.v 				= V_BARKER_BARKER2.v + FASTBALL_WIDOW_OFFSET
}
const vector FASTBALL_WIDOW_BOUNDS 	= < 400, 50, 50 >
const vector FASTBALL_CROW_BOUNDS 	= < 450, 100, 50 >
const vector FASTBALL_CROW_OFFSET1a	= < -1600, 2700, 300 >
const vector FASTBALL_CROW_OFFSET1b	= < -1600, 1500, 150 >
const vector FASTBALL_CROW_OFFSET3 	= < 3900, -14000, -1500 >
const vector FASTBALL_CROW_OFFSET2 	= FASTBALL_CROW_OFFSET3 + < -2000, 0, 0 >

//###########################
// MALTA INTRO
//###########################
LocalVec V_MALTAINTRO_AIRBATTLE
LocalVec V_MALTAINTRO_WIDOW
void function Init_MaltaIntro()
{
	V_MALTAINTRO_AIRBATTLE.v 		= < 0, 24000, -500 >
	V_MALTAINTRO_WIDOW.v 			= V_BARKER_AIRBATTLE.v + <5000, -1000, -200 >
}
const vector MALTAINTRO_CROW_OFFSET = < 1800, -100, -100 >
const vector MALTAINTRO_CROW_BOUNDS = < 1100, 0, 0 >
const vector MALTAINTRO_WIDOW_BOUNDS = < 1000, 500, 500 >

//###########################
// MALTA DRONE ROOM
//###########################
LocalVec V_MALTADRONE_MALTA
void function Init_MaltaDrone()
{
	V_MALTADRONE_MALTA.v 				= V_BARKER_MALTA.v
}
const vector MALTADRONE_MALTA_BOUNDS	= <500, 0, 0>

//###########################
// MALTA GUNS
//###########################
void function Init_MaltaGuns()
{

}
const vector MALTAGUNS_CROW_OFFSET = <1000, 0, 200>
const vector MALTAGUNS_CROW_BOUNDS = <400,500,100>

//###########################
// MALTA WIDOW
//###########################
LocalVec V_MALTAWIDOW_AIRBATTLE
LocalVec V_MALTAWIDOW_WIDOW
void function Init_MaltaWidow()
{
	V_MALTAWIDOW_AIRBATTLE.v 		= < 0, 30000, -500 >
	V_MALTAWIDOW_WIDOW.v 			= V_MALTADRONE_MALTA.v + < 12000, -4000, 0 >
}
const vector MALTAWIDOW_WIDOW_BOUNDS = < 20, 20, 50 >
const vector MALTAWIDOW_WIDOW_OFFSET = <800, 650, -130>
const vector MALTAWIDOW_WIDOW_OFFSET_PRE = <850, 800, -3000>
const vector MALTAWIDOW_MALTA_BOUNDS = <100, 0, 0>

const vector MALTAHANGAR_WIDOW_OFFSET = < 12000, -2000, 0 >
const vector MALTAHANGAR_WIDOW_BOUNDS = < 700, 1000, 400 >

//###########################
// MALTA BRIDGE
//###########################
LocalVec V_MALTABRIDGE_OLA
LocalVec V_MALTABRIDGE_MALTA
LocalVec V_MALTABRIDGE_GIBRALTAR
void function Init_MaltaBridge()
{
	V_MALTABRIDGE_OLA.v 			= V_BARKER_OLA.v
	V_MALTABRIDGE_MALTA.v 			= V_MALTADRONE_MALTA.v
	V_MALTABRIDGE_GIBRALTAR.v 			= < 0, -6000, 2000 >
}
const vector MALTABRDIGE_MALTA_BOUNDS	= < 250, 0, 0 >
const vector MALTABRDIGE_OLA_BOUNDS		= < 1000, 0, 0 >
const vector MALTABRIDGE_BARKER_BOUNDS  = < 100, 0, 0 >
const vector MALTABRIDGE_BARKER_DELTA 	= < 3000, 4500, 1500 >

//###########################
// MALTA DECK
//###########################
LocalVec V_MALTADECK_OLA
LocalVec V_MALTADECK_MALTA
void function Init_MaltaDeck()
{
	V_MALTADECK_MALTA.v 			= < V_MALTABRIDGE_OLA.v.x, V_MALTABRIDGE_MALTA.v.y, V_MALTABRIDGE_OLA.v.z >
	V_MALTADECK_OLA.v 				= V_MALTADECK_MALTA.v + <0,24000,-1000>
}
const vector MALTADECK_OLA_BOUNDS 	= MALTABRDIGE_OLA_BOUNDS
const vector MALTADECK_MALTA_BOUNDS	= < 1000, 0, 0 >
const vector DECK_VIPER_DELTA 		= <0,13300,300>
const vector MALTADECK_WIDOW_OFFSET = < 2000, 11000, -1000 >

//###########################
// MALTA TACKLE
//###########################
const vector MALTATACKLE_RETREAT_DELTA1 = < 6000, -1000, -2000 >
const vector MALTATACKLE_RETREAT_DELTA2 = < -6000, -1000, -2000 >

const vector MALTATACKLE_WIDOW_OFFSET = < 2000, 12500, 1000 >
const vector MALTATACKLE_WIDOW_BOUNDS = < 300, 400, 100 >
const vector MALTATACKLE_WIDOW_OFFSET2 = MALTATACKLE_WIDOW_OFFSET + MALTATACKLE_RETREAT_DELTA1
const vector MALTATACKLE_WIDOW_BOUNDS2 = < 600, 400, 100 >

const vector MALTATACKLE_DS_OFFSET_0_0 = < 7000, 12500, 1100>
const vector MALTATACKLE_DS_OFFSET_0_1 = < -6500, 11500, 900>
const vector MALTATACKLE_DS_OFFSET_0_2 = < 4000, 10000, 1200>
const vector MALTATACKLE_DS_OFFSET_0_3 = < -2500, 10500, 700 >
const vector MALTATACKLE_DS_OFFSET_0_4 = < 5000, 15000, 500>
const vector MALTATACKLE_DS_OFFSET_0_5 = < -4000, 13000, 1300 >
const vector MALTATACKLE_DS_OFFSET_0_6 = < 1800, 15000, 1500 >
const vector MALTATACKLE_DS_OFFSET_0_7 = < -1500, 14000, 1200>

const vector MALTATACKLE_DS_OFFSET_1_0 = MALTATACKLE_DS_OFFSET_0_0 + MALTATACKLE_RETREAT_DELTA1
const vector MALTATACKLE_DS_OFFSET_1_1 = MALTATACKLE_DS_OFFSET_0_1 + MALTATACKLE_RETREAT_DELTA2
const vector MALTATACKLE_DS_OFFSET_1_2 = MALTATACKLE_DS_OFFSET_0_2 + MALTATACKLE_RETREAT_DELTA1
const vector MALTATACKLE_DS_OFFSET_1_3 = MALTATACKLE_DS_OFFSET_0_3 + MALTATACKLE_RETREAT_DELTA2
const vector MALTATACKLE_DS_OFFSET_1_4 = MALTATACKLE_DS_OFFSET_0_4 + MALTATACKLE_RETREAT_DELTA1
const vector MALTATACKLE_DS_OFFSET_1_5 = MALTATACKLE_DS_OFFSET_0_5 + MALTATACKLE_RETREAT_DELTA2
const vector MALTATACKLE_DS_OFFSET_1_6 = MALTATACKLE_DS_OFFSET_0_6 + MALTATACKLE_RETREAT_DELTA1
const vector MALTATACKLE_DS_OFFSET_1_7 = MALTATACKLE_DS_OFFSET_0_7 + MALTATACKLE_RETREAT_DELTA2


const vector MALTATACKLE_CROW_BOUNDS 	= < 500, 600, 150 >

/************************************************************************************************\

███████╗███╗   ██╗████████╗██╗████████╗██╗███████╗███████╗    ██╗      ██████╗  █████╗ ██████╗
██╔════╝████╗  ██║╚══██╔══╝██║╚══██╔══╝██║██╔════╝██╔════╝    ██║     ██╔═══██╗██╔══██╗██╔══██╗
█████╗  ██╔██╗ ██║   ██║   ██║   ██║   ██║█████╗  ███████╗    ██║     ██║   ██║███████║██║  ██║
██╔══╝  ██║╚██╗██║   ██║   ██║   ██║   ██║██╔══╝  ╚════██║    ██║     ██║   ██║██╔══██║██║  ██║
███████╗██║ ╚████║   ██║   ██║   ██║   ██║███████╗███████║    ███████╗╚██████╔╝██║  ██║██████╔╝
╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝    ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝

\************************************************************************************************/
void function S2S_EntitiesDidLoad()
{
	file.worldCenterLeadDist = DEF_WORLDCENTERLEADDIST
	Init_LevelStart()
	Init_LevelStart2()
	Init_Intro()
	Init_Gibraltar()
	Init_BossIntro()
	Init_Freefall()
	Init_Barker()
	Init_Fastball1()
	Init_MaltaIntro()
	Init_MaltaDrone()
	Init_MaltaGuns()
	Init_MaltaWidow()
	Init_MaltaBridge()
	Init_MaltaDeck()

	//the main ships that are always there
	file.malta 		= SpawnMalta()
	file.gibraltar 	= SpawnGibraltar( CLVec( < 8000, 0, -5000 > ) )
	file.OLA 		= SpawnOLA( CLVec( < -8000, 0, -5000 > ) )

	//setup the lifts
	LiftSetup( file.malta, GetEntByScriptName( "droneBay0" ) )
	LiftSetup( file.malta, GetEntByScriptName( "droneBayReal2" ) )

	//hide the fakes for cube map building
	ShipGeoHide( file.malta, "GEO_CHUNK_BACK_FAKE" )
	ShipGeoHide( file.malta, "GEO_CHUNK_HANGAR_FAKE" )
	ShipGeoHide( file.malta, "GEO_CHUNK_DECK_FAKE" )
	ShipGeoHide( file.OLA, 	"DRACONIS_CHUNK_LOWDEF" )

	GetEntByScriptName( "MaltaSideClip" ).NotSolid()

	thread HangarLiftPanelsClose( 0.1 )

	//prepare all the skybox data
	Sky_InitData()

	//SE element that gets closer
	entity ref = GetEntByScriptName( "se_Sculptor" )
	entity sculptor 	= CreateScriptMover( ref.GetOrigin(), ref.GetAngles() )
	sculptor.SetModel( ref.GetModelName() )
	file.sculptor = sculptor
	ref.Destroy()

	//dummy AI to be able to shoot real rockets from goblins and crows
	vector origin = <13400, 128, -15100>
	entity anchor = CreateScriptMover( origin )
	entity dummy = CreateSoldier( TEAM_MILITIA, origin + <40,0,0>, <0,0,0> )
	SetSpawnOption_Weapon( dummy, "sp_weapon_swarm_rockets_s2s" )
	DispatchSpawn( dummy )
	dummy.SetInvulnerable()
	dummy.SetEfficientMode( true )
	dummy.SetParent( anchor, "REF" )
	thread PlayAnim( dummy, "CQB_Idle_MP", anchor, "REF" )
	Highlight_ClearFriendlyHighlight( dummy )
	file.rocketDummy[ TEAM_MILITIA ] <- dummy

	dummy = CreateSoldier( TEAM_IMC, origin - <40,0,0>, <0,0,0> )
	SetSpawnOption_Weapon( dummy, "sp_weapon_swarm_rockets_s2s" )
	DispatchSpawn( dummy )
	dummy.SetInvulnerable()
	dummy.SetEfficientMode( true )
	dummy.SetParent( anchor, "REF" )
	thread PlayAnim( dummy, "CQB_Idle_MP", anchor, "REF" )
	Highlight_ClearFriendlyHighlight( dummy )
	file.rocketDummy[ TEAM_IMC ] <- dummy

	thread NiceWorkCoop()

	//air battle
	file.airBattleNode = CreateScriptMover( <0,0,0>, CONVOYDIR )
	file.airBattleData = GetAirBattleStructMaltaIntro()
	file.dropships[ TEAM_IMC ] <- []
	file.dropships[ TEAM_MILITIA ] <- []

	//highlight for the bridge controls
	entity panel = GetEntByScriptName( "maltaBridgeControl" )

	file.objBridgePanel = CreatePropScript( panel.GetModelName(), panel.GetOrigin(), panel.GetAngles(), 0, 99999 )
	file.objBridgePanel.SetParent( panel.GetParent(), "", true )
	file.objBridgePanel.Hide()
	Objective_InitEntity( file.objBridgePanel )

	//the window covers in the back of the bridge
	entity shield = GetEntByScriptName( "bridgeBackShield" )
	shield.NotSolid()
	shield.Hide()

	//the elevator doors
	file.malta.lifts[ REALDRONELIFT ][0].doorTopC.Hide()
	file.malta.lifts[ REALDRONELIFT ][0].doorTopS.Hide()
	GetEntByScriptName( "maltaGunTurret1" ).Hide()
	GetEntByScriptName( "maltaGunTurret2" ).Hide()
	GetEntByScriptName( "maltaGunTurret3" ).Hide()

	//init all the scripts nodes that parent everything
	file.playerWidow_scrOffset = InitScript( "scr_pwidow_node_0", GetEntArrayByScriptName( "widowTemplate" )[0], "BODY" )
	InitScript( "scr_swidow_node_0", GetEntArrayByScriptName( "widowTemplate" )[1], "BODY" )

	InitScript( "scr_trinity_node_1" )
	InitScript( "scr_gibraltar_node_1" )
	InitScript( "scr_malta_node_0" )
	InitScript( "scr_malta_node_1" )
	InitScript( "scr_malta_node_1b" )
	InitScript( "scr_malta_node_2" )
	InitScript( "scr_malta_node_3" )
	InitScript( "scr_malta_node_3b" )
	InitScript( "scr_malta_node_4" )
	InitScript( "scr_malta_node_5" )
	InitScript( "scr_ola_node_1" )
	InitScript( "scr_ola_node_2" )

	thread StopHelmetSpin( "widowhelmet" )

	InitMaltaSideGuns()
	InitObjectives()

	file.draconis_PA = GetEntArrayByScriptName( "draconis_PA_2" )
	file.draconis_PA.append( GetEntByScriptName( "draconis_PA" ) )

	//dev
	#if DEV
		if ( DEV_DRAWWORLDEDGE )
			thread DEV_DrawWorldEdges()
	#endif
}

void function InitObjectives()
{
	Objective_InitEntity( GetEntByScriptName( "droneBay0" ) )
	Objective_InitEntity( GetEntByScriptName( "maltaGunTurret1" ) )
	Objective_InitEntity( GetEntByScriptName( "maltaGunTurret2" ) )
	Objective_InitEntity( GetEntByScriptName( "maltaGunTurret3" ) )
	Objective_InitEntity( GetEntByScriptName( "ola_hatch" ) )
}

void function NiceWorkCoop()
{
	entity trigger = GetEntByScriptName( "niceWorkCoop" )
	trigger.WaitSignal( "OnTrigger" )

	waitthreadsolo PlayDialogue( "NiceWorkCoop", file.player )
}

void function InitMaltaSideGuns()
{
	array<entity> guns = []
	guns.append( GetEntByScriptName( "maltaGunTurret1" ) )
	guns.append( GetEntByScriptName( "maltaGunTurret2" ) )
	guns.append( GetEntByScriptName( "maltaGunTurret3" ) )

	foreach ( ent in guns )
	{
		entity clip = ent.GetLinkEnt()
		clip.SetPusher( true )
		clip.SetParent( ent, "muzzle_flash", true, 0 )
	}
}

void function PlayerDidLoad( entity player )
{
	file.player = player
//	ClientCommand( player, "net_threadedProcessPacket 0" )
//	ClientCommand( player, "moving_collision_accel_threshold 1000000" )
	FastBallPlayerInit( player )

	SetPlayer0( player )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.SetInvulnerable()
	bt.DisableHibernation()

	thread DriftWorldCenterWithPlayer( player )
	FlagSet( "DriftWorldCenter" )
}

void function PlayerGetMainWeapons( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
	if ( weapons.len() != 2 )
		return //weapons were taken away

	PilotLoadoutDef newloadout

	newloadout.primary = weapons[0].GetWeaponClassName()
	newloadout.primaryModsBitfield = weapons[0].GetModBitField()
	newloadout.secondary = weapons[1].GetWeaponClassName()
	newloadout.secondaryModsBitfield = weapons[1].GetModBitField()

	file.loadout = newloadout
}

void function ReturnMainWeapons( entity player, PilotLoadoutDef loadout )
{
	player.GiveWeapon( loadout.primary )
	player.SetActiveWeaponByName( loadout.primary )
	int mods = expect int( loadout.primaryModsBitfield )
	entity weapon = player.GetMainWeapons()[0]
	weapon.SetModBitField( mods )

	player.GiveWeapon( loadout.secondary )
	mods = expect int( loadout.secondaryModsBitfield )
	weapon = player.GetMainWeapons()[1]
	weapon.SetModBitField( mods )
}

void function Init_StreamingClient( entity player )
{
	player.Signal( "Init_StreamingClient" )
	player.EndSignal( "Init_StreamingClient" )

	//hacky, but no way around it, using this ent because this ent is never deleted
	while( GetEntArrayByScriptName( "endKnockback" ).len() == 0 )
		WaitFrame()

	ShipStreamingSetupServer( "trinityTemplate", SHIPSTREAMING_TRINITY )
	ShipStreamingSetupServer( "gibraltarTemplate", SHIPSTREAMING_GIBRALTAR )
	ShipStreamingSetupServer( "lewTemplate", SHIPSTREAMING_BARKER )
	ShipStreamingSetupServer( "maltaTemplate", SHIPSTREAMING_MALTA )
	ShipStreamingSetupServer( "draconisTemplate", SHIPSTREAMING_DRACONIS )

	foreach ( streaming, data in file.DynamicStreamingData )
	{
		int eHandle = data.template.GetEncodedEHandle()
		vector origin = data.origin
		vector angles = data.angles
		Remote_CallFunction_NonReplay( player, "ServerCallback_ShipStreamingSetup", eHandle, streaming, origin.x, origin.y, origin.z, angles.x, angles.y, angles.z )
	}

	printt( "" )
	printt( "--------------------------------------------" )
	printt( "STREAMING INITIALIZED ON SERVER" )
	printt( "--------------------------------------------" )
	printt( "" )
}

void function ShipStreamingSetupServer( string name, int streaming )
{
	//because ents can be deleted
	entity template
	if ( GetEntArrayByScriptName( name ).len() )
		template = GetEntByScriptName( name )
	else
		template = GetEntByScriptName( "endKnockback" )

	StreamingData data
	data.template = template
	data.origin = data.template.GetOrigin()
	data.angles = data.template.GetAngles()

	file.DynamicStreamingData[ streaming ] <- data
}

/************************************************************************************************\

 ██████╗ █████╗ ██████╗     ███████╗██╗  ██╗██╗██████╗     ███████╗███████╗████████╗██╗   ██╗██████╗ ███████╗
██╔════╝██╔══██╗██╔══██╗    ██╔════╝██║  ██║██║██╔══██╗    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗██╔════╝
██║     ███████║██████╔╝    ███████╗███████║██║██████╔╝    ███████╗█████╗     ██║   ██║   ██║██████╔╝███████╗
██║     ██╔══██║██╔═══╝     ╚════██║██╔══██║██║██╔═══╝     ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ ╚════██║
╚██████╗██║  ██║██║         ███████║██║  ██║██║██║         ███████║███████╗   ██║   ╚██████╔╝██║     ███████║
 ╚═════╝╚═╝  ╚═╝╚═╝         ╚══════╝╚═╝  ╚═╝╚═╝╚═╝         ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚══════╝

\************************************************************************************************/
void function SetupShips_LevelStart2()
{
	ShipIdleAtTargetPos_Teleport( file.gibraltar,	V_INTRO2_GIBRALTAR, INTRO_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_START_MALTA, 		START_MALTA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_START_OLA, 		START_OLA_BOUNDS )

	file.trinity 	= SpawnTrinity()
	ShipGeoHide( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )
	ShipIdleAtTargetPos_Teleport( file.trinity,		V_START2_TRINITY_0, 	<0,0,0> )

	StartSetupPlayerWidow( file.player, V_START2_PLAYER_0 )
	ShipIdleAtTargetPos_Teleport( file.playerWidow, 	V_START2_PLAYER_0, <0,0,0> )

	bool teleport = true
	bool incombat = true

	SpawnSarahWidow( null, incombat )
	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, 	file.playerWidow.mover, <0,0,0>, <0,0,0>, START2_WIDOW_OFFSET_0 )

	file.crow64 = SpawnIntro64()
	Start_64ReadyForCombat()
	ShipIdleAtTargetEnt_M2_Teleport( file.crow64, 		file.playerWidow.mover, START2_CROW_BOUNDS_0, <0,0,0>, START2_CROW_OFFSET_0 )

	array<LocalVec> destinations = [ V_START2_DS_0_0, V_START2_DS_1_0, V_START2_DS_2_0, V_START2_DS_3_0, V_START2_DS_4_0 ]
	foreach ( index, pos in destinations )
	{
		ShipStruct crow = SpawnIntroCrow( destinations[ index ], index )
		ShipIdleAtTargetPos_Teleport( crow, destinations[ index ],	START2_DROPSHIP_BOUNDS )
	}
}

ShipStruct function SpawnIntroCrow( LocalVec pos, int index )
{
	bool animating 	= true

	ShipStruct crow = SpawnCrowLight( pos, CONVOYDIR, animating )
	crow.model.SetScriptName( DropshipGetCallsign( index ) )
	//Intro_CrowReadyForCombat( crow )

	Highlight_SetNeutralHighlight( crow.model, "sp_s2s_crow_outline" )
	Highlight_SetFriendlyHighlight( crow.model, "sp_s2s_crow_outline" )

	SetMaxSpeed( 	crow, START2_MAXSPEED )
	SetMaxAcc( 		crow, START2_MAXACC )
	SetMaxPitch( 	crow, START2_MAXPITCH )
	crow.bug_reproNum = 1

	file.dropships[ TEAM_MILITIA ].append( crow )

	return crow
}

void function SetupShips_Intro()
{
	ShipIdleAtTargetPos_Teleport( file.gibraltar,	V_INTRO2_GIBRALTAR, INTRO_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_START_MALTA, 		START_MALTA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_START_OLA, 		START_OLA_BOUNDS )

	bool teleport = true

	file.trinity 	= SpawnTrinity()
	ShipGeoHide( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )
	Start2_TrinityThink( teleport )
	file.trinity.localVelocity.v = < 375.506, -253.433, -125.17 > //grabbed at the end of level start from the console

	StartSetupPlayerWidow( file.player, V_START2_PLAYER_1 )
	SetMaxPitch( file.playerWidow, START2_MAXPITCH )

	SetupShips_IntroFollowerOffsets()
	Intro2_EnemySquadron1()
}

void function SetupShips_IntroFollowerOffsets()
{
	bool teleport = true
	bool incombat = true

	SpawnSarahWidow( null, incombat )
	SetMaxSpeed( 	file.sarahWidow, START2_MAXSPEED )
	SetMaxAcc( 		file.sarahWidow, START2_MAXACC )
	SetMaxPitch( 	file.sarahWidow, START2_MAXPITCH )
	ShipIdleAtTargetEnt_M2_Teleport( file.sarahWidow, file.playerWidow.mover, START2_WIDOW_BOUNDS2, <0,0,0>, START2_WIDOW_OFFSET_2 )

	file.crow64 = SpawnIntro64()
	Start_64ReadyForCombat()
	SetMaxPitch( 	file.crow64, START2_MAXPITCH )
	Start2_CrowThink( teleport )

	array<vector> offsets = [ 	START2_DS_OFFSET_0_1,
								START2_DS_OFFSET_1_1,
								START2_DS_OFFSET_2_1,
								START2_DS_OFFSET_3_1,
								START2_DS_OFFSET_4_1,
								START2_DS_OFFSET_5_1,
								START2_DS_OFFSET_6_1,
								START2_DS_OFFSET_7_1,
								START2_DS_OFFSET_8_1 ]

	array<vector> bounds = [ 	START2_DROPSHIP_BOUNDS,
								START2_DROPSHIP_BOUNDS,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2	]

	foreach ( index, pos in offsets )
	{
		ShipStruct crow = SpawnIntroCrow( V_START2_DS_0_0, index )
		ShipIdleAtTargetEnt_M2_Teleport( crow, file.playerWidow.mover, bounds[ index ], <0,0,0>, offsets[ index ] )
	}
}

void function SetupShips_Gibraltar()
{
	ShipIdleAtTargetPos_Teleport( file.gibraltar,	V_INTRO2_GIBRALTAR, INTRO_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_START_MALTA, 		START_MALTA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_START_OLA, 		START_OLA_BOUNDS )

	bool teleport = true

	LocalVec origin = clone V_INTRO2_PLAYER_1
	origin.v -= < 0, INTRO2_PLAYER_GOALRADIUS, 0 >
	StartSetupPlayerWidow( file.player, origin )
	SetMaxPitch( file.playerWidow, START2_MAXPITCH )
	file.playerWidow.localVelocity.v = <0,500,0>

	file.trinity 	= SpawnTrinity()
	ShipGeoHide( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )
	Intro_TrinityThink( teleport )

	SetupShips_IntroFollowerOffsets()
}

void function SetupShips_BossIntro()
{
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_START_MALTA, 		START_MALTA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_START_OLA, 		START_OLA_BOUNDS )

	bool teleport = true
	bool incombat = true
	vector StartingVel = <211,336,0>

	LocalVec origin = clone V_GIBRALTAR_PLAYER2
	origin.v -= < -40, GIBRALTAR_PLAYER_GOALRADIUS2, 0 >
	StartSetupPlayerWidow( file.player, origin )
	SetMaxPitch( file.playerWidow, START2_MAXPITCH )
	file.playerWidow.localVelocity.v = <43,377,0>

	thread Gibraltar_PullAway( teleport )

	file.trinity 	= SpawnTrinity()
	ShipGeoHide( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )
	Intro_TrinityThink( teleport )
	file.trinity.localVelocity.v = StartingVel

	file.crow64 = SpawnIntro64()
	Start_64ReadyForCombat()
	SetMaxPitch( 	file.crow64, START2_MAXPITCH )
	Gibraltar_Crow64Think( teleport )
	file.crow64.localVelocity.v = StartingVel

	SpawnSarahWidow( null, incombat )
	SetMaxSpeed( 	file.sarahWidow, START2_MAXSPEED )
	SetMaxAcc( 		file.sarahWidow, START2_MAXACC )
	SetMaxPitch( 	file.sarahWidow, START2_MAXPITCH )
	file.sarahWidow.localVelocity.v = StartingVel
	ShipIdleAtTargetEnt_M2_Teleport( file.sarahWidow, file.playerWidow.mover, GIBRALTAR_DS_BOUNDS, <0,0,0>, GIBRALTAR_WIDOW_OFFSET_0 )

	array<vector> offsets = [ 	GIBRALTAR_DS_OFFSET_0_0,
								GIBRALTAR_DS_OFFSET_1_0,
								GIBRALTAR_DS_OFFSET_2_0,
								GIBRALTAR_DS_OFFSET_3_0,
								GIBRALTAR_DS_OFFSET_4_0,
								GIBRALTAR_DS_OFFSET_5_0 ]

	foreach ( index, offset in offsets )
	{
		ShipStruct crow = SpawnIntroCrow( V_START2_DS_0_0, index )
		crow.localVelocity.v = StartingVel

		ShipIdleAtTargetEnt_M2_Teleport( crow, file.playerWidow.mover, GIBRALTAR_DS_BOUNDS, <0,0,0>, offset )
	}

	ResetMaxPitch( file.dropships[ TEAM_MILITIA ][ 4 ] )
	thread SetBehavior( file.dropships[ TEAM_MILITIA ][ 4 ], eBehavior.DEATH_ANIM ) //2-4
	ResetMaxPitch( file.dropships[ TEAM_MILITIA ][ 0 ] )
	thread SetBehavior( file.dropships[ TEAM_MILITIA ][ 0 ], eBehavior.DEATH_ANIM ) // actual
}

void function SetupShips_Freefall()
{
	file.trinity 	= SpawnTrinity()
	ShipGeoHide( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )

	ShipIdleAtTargetPos_Teleport( file.trinity,		V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_BARKER_MALTA, 	BARKER_MALTA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )

	StartSetupPlayerWidow( file.player, V_BOSSINTRO_PLAYER1 )
	ShipIdleAtTargetPos_Teleport( file.playerWidow, V_BOSSINTRO_PLAYER1, <0,0,0> )
	SetMaxPitch( file.playerWidow, START2_MAXPITCH )

	BossIntro_SpawnBossTitan( BOSSINTRO_VIPER_DELTA0 )
}

void function SetupShips_Barker()
{
	file.barkership = SpawnBarkerShip()
	file.trinity 	= SpawnTrinity()
	ShipGeoHide( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )

	ShipIdleAtTargetPos_Teleport( file.trinity,		V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_BARKER_MALTA, 	BARKER_MALTA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
}

void function SetupShips_Fastball1()
{
	file.barkership = SpawnBarkerShip()
	file.barkership.triggerFallingDeath.Disable()
	delaythread( 1.0 ) BarkerShipShake()
	SetMaxRoll( file.barkership, 20 )

	file.trinity	= SpawnTrinity()
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2", true )
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1", true )
	FreeFall_CustomTrinitySettings()
	file.crow64 	= SpawnCrow64()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.barkership, 	V_BARKER_BARKER2, 	BARKER_BARKER_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_BARKER_MALTA, 	BARKER_MALTA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.trinity,		V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.sarahWidow, 	V_FASTBALL_WIDOW, 	FASTBALL_WIDOW_BOUNDS )
	delaythread( 0.5 ) Barkership_SarahLeave()

	bool teleport = true
	BarkerShip_CrowMovementFinal( teleport )
	thread Barkership_CrowSeatedAnims()
}

void function SetupShips_MaltaIntro()
{
	file.barkership = SpawnBarkerShip()
	file.trinity	= SpawnTrinity()
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2", true )
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1", true )
	FreeFall_CustomTrinitySettings()
	file.crow64 	= SpawnCrow64()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.barkership, 	V_FASTBALL_BARKER, 	BARKER_BARKER_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.trinity,		V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_BARKER_MALTA, 	BARKER_MALTA_BOUNDS )
	ShipIdleAtTargetEnt_Teleport( file.crow64, file.malta.mover, <0,0,0>, <0,0,0>, FASTBALL_CROW_OFFSET3 )
	thread Barkership_CrowSeatedAnims()

	ShipIdleAtTargetPos_Teleport( file.sarahWidow, 	V_MALTAINTRO_WIDOW, MALTAINTRO_WIDOW_BOUNDS )
}

void function SetupShips_MaltaDrone()
{
	file.barkership = SpawnBarkerShip()
	file.trinity	= SpawnTrinity()
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2", true )
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1", true )
	FreeFall_CustomTrinitySettings()
	file.crow64 	= SpawnCrow64()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.barkership, 	V_FASTBALL_BARKER, 	BARKER_BARKER_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.trinity, 	V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.sarahWidow, 	V_MALTAINTRO_WIDOW, MALTAINTRO_WIDOW_BOUNDS )

	ShipIdleAtTargetPos_Teleport( file.malta, 		V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )
	file.malta.FuncGetBankMagnitude = GetBankMagnitudeMalta

	EnableScript( file.malta, "scr_malta_node_1" )
	EnableScript( file.malta, "scr_malta_node_1b" )
	bool teleport = true
	thread MaltaIntro_CrowFlightPath( teleport )
}

void function SetupShips_MaltaGuns()
{
	file.barkership = SpawnBarkerShip()
	file.trinity 		= SpawnTrinity()
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2", true )
	thread TrinityHangarDoorsOpen( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1", true )
	FreeFall_CustomTrinitySettings()
	file.crow64 	= SpawnCrow64()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.barkership, 	V_FASTBALL_BARKER, 	BARKER_BARKER_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.trinity, 	V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )
	file.malta.FuncGetBankMagnitude = GetBankMagnitudeMalta
	ShipIdleAtTargetPos_Teleport( file.sarahWidow, 	V_MALTAINTRO_WIDOW, MALTAINTRO_WIDOW_BOUNDS )

	EnableScript( file.malta, "scr_malta_node_1" )
	EnableScript( file.malta, "scr_malta_node_1b" )
	bool teleport = true
	thread MaltaDrone_CrowFlightPath( teleport )
}

void function SetupShips_MaltaWidow()
{
	file.barkership = SpawnBarkerShip()
	file.crow64 	= SpawnCrow64()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.barkership, 	V_FASTBALL_BARKER, 	BARKER_BARKER_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )
	file.malta.FuncGetBankMagnitude = GetBankMagnitudeMalta

	EnableScript( file.malta, "scr_malta_node_2" )

	bool teleport = true
	MaltaGuns_WidowPrepare()
	MaltaWidow_ZipPosition( teleport )
}

void function SetupShips_MaltaHangar()
{
	file.barkership = SpawnBarkerShip()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.barkership, 	V_FASTBALL_BARKER, 	BARKER_BARKER_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )
	file.malta.FuncGetBankMagnitude = GetBankMagnitudeMalta

	EnableScript( file.malta, "scr_malta_node_2" )

	entity maltaRef = file.malta.mover
	entity node 	= GetEntByScriptName( "maltawidowrunRef" )
	vector delta	= GetRelativeDelta( node.GetOrigin(), maltaRef )
	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, maltaRef, MALTAWIDOW_WIDOW_BOUNDS, delta, MALTAWIDOW_WIDOW_OFFSET )
}

void function SetupShips_MaltaBridge()
{
	file.barkership = SpawnBarkerShip()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.barkership, 	V_FASTBALL_BARKER, 	BARKER_BARKER_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_MALTABRIDGE_OLA, 	MALTABRDIGE_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_MALTABRIDGE_MALTA, MALTABRDIGE_MALTA_BOUNDS )

	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, file.malta.mover, MALTAHANGAR_WIDOW_BOUNDS, <0,0,0>, MALTAHANGAR_WIDOW_OFFSET )
}

void function SetupShips_MaltaReunite()
{
	file.barkership = SpawnBarkerShip()
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_MALTABRIDGE_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	MaltaChasesOla( true )

	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, file.malta.mover, MALTAHANGAR_WIDOW_BOUNDS, <0,0,0>, MALTAHANGAR_WIDOW_OFFSET )
	ShipIdleAtTargetEnt_Teleport( file.barkership, file.malta.mover, MALTABRIDGE_BARKER_BOUNDS, MALTABRIDGE_BARKER_DELTA, <0,0,0> )
}

void function SetupShips_Deck()
{
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_MALTABRIDGE_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	MaltaChasesOla( true )

	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, file.malta.mover, MALTAHANGAR_WIDOW_BOUNDS, <0,0,0>, MALTAHANGAR_WIDOW_OFFSET )
}

void function SetupShips_BT_Tackle()
{
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_MALTABRIDGE_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_MALTADECK_OLA, 	MALTADECK_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_MALTADECK_MALTA, 	MALTADECK_MALTA_BOUNDS )

	bool teleport = true
	MaltaDeck_SarahWidow( teleport )
}

void function SetupShips_BossFight()
{
	SpawnSarahWidow()

	ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_MALTABRIDGE_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.OLA, 		V_MALTADECK_OLA, 	MALTADECK_OLA_BOUNDS )
	ShipIdleAtTargetPos_Teleport( file.malta, 		V_MALTADECK_MALTA, 	MALTADECK_MALTA_BOUNDS )

	for ( int i = 0; i < 8; i++ )
	{
		ShipStruct ship = SpawnCrowLight()
		file.dropships[ TEAM_MILITIA ].append( ship )
	}

	bool teleport = true
	thread BT_Tackle_Crows( teleport )
	thread BT_Tackle_SarahWidow( teleport )
}

void function DeleteTrinity()
{
	switch( GetCurrentStartPoint() )
	{
		case "--------------":
		case "TestBed":
		case "Dropship Combat Test":
		case "LightEdit Connect":
		case "TRAILER bridge":
			//don't destroy the trinity
			return
			break
	}

	file.trinity = SpawnTrinity()
	FakeDestroy( file.trinity )
	if ( IsValid( file.trinity.mover ) )
		file.trinity.mover.Destroy()
	if ( IsValid( file.trinity.model ) )
		file.trinity.model.Destroy()

	array<entity> geoChunks = GetEntArrayByScriptName( "TRINITY_CHUNK_INTERIOR" )
	geoChunks.extend( GetEntArrayByScriptName( "TRINITY_CHUNK_INTERIOR_FAKE" ) )
	foreach ( chunk in geoChunks )
	{
		if ( IsValid( chunk) )
			chunk.Destroy()
	}

}

bool function ConnectIntro()
{
	return true
}

/************************************************************************************************\

██╗     ███████╗██╗   ██╗███████╗██╗         ███████╗████████╗ █████╗ ██████╗ ████████╗
██║     ██╔════╝██║   ██║██╔════╝██║         ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
██║     █████╗  ██║   ██║█████╗  ██║         ███████╗   ██║   ███████║██████╔╝   ██║
██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║         ╚════██║   ██║   ██╔══██║██╔══██╗   ██║
███████╗███████╗ ╚████╔╝ ███████╗███████╗    ███████║   ██║   ██║  ██║██║  ██║   ██║
╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝    ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

\************************************************************************************************/
void function Start2_Setup( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	Start_ShipGeoSettings()
	thread SkyAnimatePart1()
	WORLD_CENTER.SetOrigin( <0,43000,0> )
	SetupShips_LevelStart2()

	Embark_Disallow( player )

	TakeAllWeapons( player )
	PilotLoadoutDef pilotLoadout = GetPilotLoadoutForCurrentMapSP()
	GivePilotLoadout( player, pilotLoadout )
}

void function Start_ShipGeoSettings()
{
	entity skyboxModel = CreatePropDynamic( SE_DRACONIS )
	Ship_WorldToSkybox( file.OLA, skyboxModel )
	skyboxModel = CreatePropDynamic( SE_MALTA )
	Ship_WorldToSkybox( file.malta, skyboxModel )

	ShipGeoHide( file.malta, "GEO_CHUNK_HANGAR" )
	ShipGeoHide( file.malta, "GEO_CHUNK_BRIDGE" )
	ShipGeoHide( file.malta, "GEO_CHUNK_DECK" )
	ShipGeoHide( file.malta, "GEO_CHUNK_EXTERIOR_ENGINE" )
	ShipGeoHide( file.malta, "GEO_CHUNK_EXTERIOR_L" )
	ShipGeoHide( file.malta, "GEO_CHUNK_EXTERIOR_R" )
	ShipGeoHide( file.malta, "GEO_CHUNK_BACK" )

	ShipGeoHide( file.gibraltar, "GIBRALTAR_CHUNK_INTERIOR" )
	ShipGeoHide( file.OLA, 	"DRACONIS_CHUNK_HIGHDEF" )
}

const vector START2_OBJOFFSET = < -5000, 65000, 25000 >
void function Start2_Skip( entity player )
{
	level.nv.ShipTitles = SHIPTITLES_NOTRINITY
	level.nv.ShipStreaming = SHIPSTREAMING_TRINITY

	Start_ShipGeoSettings()
	thread SkyAnimatePart1()

	switch( GetCurrentStartPoint() )
	{
		case "--------------":
		case "TestBed":
		case "Dropship Combat Test":
		case "LightEdit Connect":
		case "TRAILER bridge":
			//don't destroy the trinity
			break

		default:
			GetEntByScriptName( "TRINITY_CHUNK_INTERIOR" ).Destroy()
			break
	}

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.TakeActiveWeapon()
	bt.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream", [ "sp_s2s_settings_npc" ] )
	SetAISettingsWrapper( bt, "npc_titan_buddy_s2s" )
	Embark_Disallow( player )

	DriftWorldSettingsLevelStart()

	FlagSet( "FlankSpeed" )
	FlagSet( "IntroScreenFading" )
	SetOriginLocal( file.airBattleNode, V_INTRO2_AIRBATTLE )

	Objective_SetSilent( "#S2S_OBJECTIVE_BOARDDRACONIS", START2_OBJOFFSET, file.OLA.skyboxModel )
}

const float START2_MAXSPEED = 500 * 1.25
const float START2_MAXACC 	= 100 * 1.75
const float START2_MAXPITCH = 5
void function Start2_Main( entity player )
{
	level.nv.ShipTitles = SHIPTITLES_NOTRINITY
	level.nv.ShipStreaming = SHIPSTREAMING_TRINITY

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.DisableHibernation()
	bt.TakeActiveWeapon()
	bt.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream", [ "sp_s2s_settings_npc" ] )
	SetAISettingsWrapper( bt, "npc_titan_buddy_s2s" )
	Embark_Disallow( player )

	Objective_SetSilent( "#S2S_OBJECTIVE_BOARDDRACONIS", START2_OBJOFFSET, file.OLA.skyboxModel )

	DriftWorldSettingsLevelStart()

	ShowIntroScreen( player )
	StartLevelStartText()
	// Remote_CallFunction_NonReplay( player, "ServerCallback_LevelIntroText" )

	FlagWait( "IntroScreenFading" )
	EndEvent()

	SetOriginLocal( file.airBattleNode, V_INTRO2_AIRBATTLE )
	Intro2_EnemySquadron1()
	thread Start2_PushPlayerOffSarahWidow()

	PlayMusic( "music_s2s_00a_intro" )

	foreach ( index, crow in file.dropships[ TEAM_MILITIA ] )
		SetMaxPitch( crow, START2_MAXPITCH )

	SetMaxPitch( 	file.crow64, START2_MAXPITCH )
	SetMaxSpeed( 	file.crow64, START2_MAXSPEED )
	SetMaxAcc( 		file.crow64, START2_MAXACC )

	SetMaxPitch( file.playerWidow, 3 )
	thread ShipFlyToPos( file.playerWidow, V_START2_PLAYER_1 )

	file.sarahTitan.TakeActiveWeapon()
	file.sarahTitan.SetParent( file.sarahWidow.model, "ORIGIN" )
	file.sarahTitan.Anim_ScriptedPlay( "bt_widow_intro_dialogue_Sarah_idle" )

	thread Start2_TrinityPullAway()
	thread Start2_TrinityHangar()
	thread Start2_Sounds()

	file.sarahWidow.model.Anim_Play( "wd_doors_closed_idle" )

	wait 7

	thread Start2_SarahWidowRise()

	FlagWait( "FlankSpeed" )

	thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.playerWidow.mover, START2_WIDOW_BOUNDS2, <0,0,0>, START2_WIDOW_OFFSET_2 )
	delaythread( 3.0 ) Enable_AfterBurner( file.sarahWidow )
	delaythread( 11.5 ) Disable_AfterBurner( file.sarahWidow )

	thread Start2_PlayerWidowThink()
	thread Start2_TrinityThink()
	thread Start2_CrowThink()
	thread Start2_MilDropships()

	file.playerWidow.goalRadius = START2_PLAYER_GOALRADIUS
	WaitSignal( file.playerWidow, "Goal" )
	file.playerWidow.goalRadius = SHIPGOALRADIUS

	CheckPointData data
	data.safeLocations = GetEntArrayByScriptName( "pWidowPlayerStart" )
	CheckPoint( data )
}

void function Start2_PushPlayerOffSarahWidow()
{
	FlagEnd( "FlankSpeed" )

	FlagWait( "PlayerInOrOnSarahWidow" )

	thread Start2_PushPlayerOffSarahWidowToDeath()
}

void function Start2_PushPlayerOffSarahWidowToDeath()
{
	file.player.EndSignal( "OnDeath" )

	vector wind1 = < 0, -700, 0 >
	vector wind2 = < 0, -75, 0 >

	while( 1 )
	{
		if ( Distance( file.player.GetOrigin(), file.sarahWidow.mover.GetOrigin() ) > 1500 )
			FlagSet( "PlayerFallingDeathFlag" )

		vector vel = file.player.GetVelocity()
		if ( file.player.IsOnGround() )
		{
			vector windB = <0,0,0>
			if ( Flag( "PlayerInSarahWidow" ) )
				windB = < -700,0,0 >

			file.player.SetVelocity( vel + wind1 + windB )
		}
		else
		{
			vector windB = <0,0,0>
			if ( Flag( "PlayerInSarahWidow"  ) )
				windB = < -75, 0, 0 >

			file.player.SetVelocity( vel + wind2 + windB )
		}
		wait 0.1 //make sure
	}
}

const float INTROSOUNDSDELAY = 32.0
void function Start2_Sounds()
{
	wait 1.0
	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_intro_first_crow_flyback", 2.14 )
	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_intro_first_crow_out_of_seyar", 10.25 )
	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_intro_second_crow_flyback", 14.31 )
	EmitSoundOnEntityAfterDelay( file.playerWidow.model, "scr_s2s_intro_widow_engage_warp_speed", 22.22 )
	EmitSoundOnEntityAfterDelay( file.crow64.model, "scr_s2s_intro_crow_engage_warp_speed", 27.10 )

	EmitSoundOnEntityAfterDelay( file.dropships[ TEAM_MILITIA ][ 5 ].model, "amb_scr_s2s_crow_flight_lp_03", 30 )
	EmitSoundOnEntityAfterDelay( file.dropships[ TEAM_MILITIA ][ 0 ].model, "amb_scr_s2s_crow_flight_lp_04", 30 )

	float delay = INTROSOUNDSDELAY
	delaythread( delay ) Intro_Sounds( INTROSOUNDSDELAY )
}

void function Intro_Sounds( float correction )
{
	EmitSoundOnEntityAfterDelay( file.dropships[ TEAM_MILITIA ][ 0 ].model, "scr_s2s_intro_goblin_rocket_trails", 39.49 - correction )
	Gibraltar_Sounds( correction )
}

void function Gibraltar_Sounds( float correction )
{
	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_intro_seyar_flyby", 56.53 - correction )
	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_intro_northstar_distant_battle", 58.32 - correction  )
}

void function DriftWorldSettingsLevelStart()
{
	file.driftWC_MaxSpeed 	= 750
	file.driftWC_MaxAcc 	= 75
	file.worldCenterLeadDist = 15000
}

void function Start2_TrinityPullAway()
{
	SetBankTime( file.trinity, 1.5 )
	SetMaxRoll( file.trinity, 0 )
	thread ShipIdleAtTargetPos( file.trinity, V_START2_TRINITY_1, <0,0,0> )
	delaythread( 1.6 ) ResetBankTime( file.trinity )
	delaythread( 1.6 ) SetMaxRoll( file.trinity, 20 )
}

void function Start2_SarahWidowRise()
{
	SetMaxSpeed( 	file.sarahWidow, 2000 )
	SetMaxAcc( 		file.sarahWidow, 300 )
	thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.playerWidow.mover, <0,0,0>, <0,0,0>, START2_WIDOW_OFFSET_0b )
	EmitSoundOnEntityAfterDelay( file.sarahWidow.model, "amb_scr_s2s_intro_widow_fly_up", 1.0 )

	file.sarahWidow.goalRadius = 200
	WaitSignal( file.sarahWidow, "Goal" )

	thread Start2_SarahAnim()

	float blendTime = 2.0
	SetMaxSpeed( 	file.sarahWidow, START2_MAXSPEED, 	blendTime )
	SetMaxAcc( 		file.sarahWidow, START2_MAXACC, 	blendTime )
	SetMaxPitch( 	file.sarahWidow, START2_MAXPITCH, 	blendTime )
	thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.playerWidow.mover, START2_WIDOW_BOUNDS, <0,0,0>, START2_WIDOW_OFFSET_1 )
	file.sarahWidow.goalRadius = SHIPGOALRADIUS
}

void function Start2_PlayerWidowThink()
{
	ResetMaxPitch( file.playerWidow )
	SetMaxSpeed( file.playerWidow, 1500 )
	SetMaxAcc( file.playerWidow, 250 )

	delaythread( 3.0 ) ResetMaxSpeed( file.playerWidow, 3.0 )
	delaythread( 3.0 ) ResetMaxAcc( file.playerWidow, 3.0 )
	delaythread( 3.0 ) SetMaxPitch( file.playerWidow, START2_MAXPITCH, 3.0 )
}

void function Start2_TrinityThink( bool teleport = false )
{
	SetMaxSpeed( file.trinity, 1000 )
	SetMaxAcc( file.trinity, 200 )

	if ( teleport )
		ShipIdleAtTargetPos_Teleport( file.trinity, V_START2_TRINITY_2, <0,0,0> )
	else
	{
		SetBankTime( file.trinity, 1.5 )
		delaythread( 1.6 ) ResetBankTime( file.trinity )
		thread ShipIdleAtTargetPos( file.trinity, V_START2_TRINITY_2, <0,0,0> )
	}
}

void function Start2_CrowThink( bool teleport = false )
{
	float blendTime = 2.5

	if ( !teleport )
	{
		wait 0.8
		delaythread( 1.2 ) Start2_64VO()

		Enable_AfterBurner( file.crow64 )
		thread ShipIdleAtTargetEnt_Method2( file.crow64, file.playerWidow.mover, START2_CROW_BOUNDS, <0,0,0>, START2_CROW_OFFSET_1 )
		SetMaxSpeed( file.crow64, 2000 )
		SetMaxAcc( file.crow64, 300 )

		file.crow64.goalRadius = 1000
		WaitSignal( file.crow64, "Goal" )

		delaythread( 1.5 ) Disable_AfterBurner( file.crow64 )
	}
	else
	{
		ShipIdleAtTargetEnt_M2_Teleport( file.crow64, file.playerWidow.mover, START2_CROW_BOUNDS, <0,0,0>, START2_CROW_OFFSET_1 )
		blendTime = 0.0
	}

	file.crow64.goalRadius = SHIPGOALRADIUS
	SetMaxSpeed( 	file.crow64, START2_MAXSPEED, 	blendTime )
	SetMaxAcc( 		file.crow64, START2_MAXACC, 	blendTime )
}

void function Enable_AfterBurner( ShipStruct ship )
{
	if ( !IsValid( ship.model ) )
		return
	int eHandle = ship.model.GetEncodedEHandle()
	// this crashes the game sometimes
	// Remote_CallFunction_NonReplay( file.player, "ServerCallBack_Afterburners_On", eHandle )
}

void function Disable_AfterBurner( ShipStruct ship )
{
	if ( !IsValid( ship.model ) )
		return
	int eHandle = ship.model.GetEncodedEHandle()
	// Remote_CallFunction_NonReplay( file.player, "ServerCallBack_Afterburners_Off", eHandle )
}

void function Start2_TrinityHangar()
{
	EnableScript( file.trinity, "scr_trinity_node_1" )
	delaythread( 2.0 ) TrinityHangarDoorsOpen( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2" )
	delaythread( 10.0 ) TrinityHangarDoorsOpen( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1" )

	array<string> startEnts = [ "trinity_shipL3",
								"trinity_shipL4",
								"trinity_shipL1",
								"trinity_shipL2" ]

	foreach ( name in startEnts )
	{
		entity ent = GetEntByScriptName( name )
		ShipStruct ship = Start_CreateLandedCrow( ent )
		int index = file.dropships[ TEAM_MILITIA ].len()
		ship.model.SetScriptName( DropshipGetCallsign( index ) )
		file.dropships[ TEAM_MILITIA ].append( ship )
	}

	array<ShipStruct> ships = file.dropships[ TEAM_MILITIA ]

	#if DEV
		foreach ( index, ship in ships )
			thread AirBattle_DEVPrint( ship, index )
	#endif

	FlagWait( "trinityLeftHangarDoor2" )
	delaythread( 0.0 ) Start_CrowTakesOff( ships[5], START2_DS_OFFSET_5_0, INTRO_DROPSHIP_BOUNDS, -1 )
	delaythread( 6.0 ) Start_CrowTakesOff( ships[6], START2_DS_OFFSET_6_0, INTRO_DROPSHIP_BOUNDS, -1 )
	delaythread( 6.0 + 7.0 ) TrinityHangarDoorsClose( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2" )

	FlagWait( "trinityLeftHangarDoor1" )
	delaythread( 1.0 ) Start_CrowTakesOff( ships[7], START2_DS_OFFSET_7_0, INTRO_DROPSHIP_BOUNDS, -1 )
	delaythread( 4.0 ) Start_CrowTakesOff( ships[8], START2_DS_OFFSET_8_0, INTRO_DROPSHIP_BOUNDS, -1 )
	delaythread( 4.0 + 7.0 ) TrinityHangarDoorsClose( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1" )

	FlagWait( "FlankSpeed" )
	delaythread( 0.0 ) Start2_MilDropshipThink( ships[5], START2_DS_OFFSET_5_1, START2_DROPSHIP_BOUNDS2, 	1000, 	1.5, 1.5 )
	delaythread( 0.5 ) Start2_MilDropshipThink( ships[6], START2_DS_OFFSET_6_1, START2_DROPSHIP_BOUNDS2, 	1000, 	1.5, 1.5 )
	delaythread( 2.0 ) Start2_MilDropshipThink( ships[7], START2_DS_OFFSET_7_1, START2_DROPSHIP_BOUNDS2, 	1000, 	1.5, 1.5 )
	delaythread( 3.0 ) Start2_MilDropshipThink( ships[8], START2_DS_OFFSET_8_1, START2_DROPSHIP_BOUNDS2, 	1500, 	1.5, 3.0 )

	delaythread( 0.0 ) Enable_AfterBurner( ships[5] )
	delaythread( 0.3 ) Enable_AfterBurner( ships[6] )
	delaythread( 0.4 ) Enable_AfterBurner( ships[7] )
	delaythread( 0.7 ) Enable_AfterBurner( ships[8] )

	FlagWaitClear( "trinityLeftHangarDoor2" )
	FlagWaitClear( "trinityLeftHangarDoor1" )
	GetEntByScriptName( "TRINITY_CHUNK_INTERIOR" ).Destroy()
}

void function Start2_MilDropships()
{
	array<ShipStruct> ships = file.dropships[ TEAM_MILITIA ]

	delaythread( 0.0 ) Start2_MilDropshipThink( ships[0], START2_DS_OFFSET_0_1, START2_DROPSHIP_BOUNDS, 	800, 	1.5, 2.5 )
	delaythread( 0.1 ) Start2_MilDropshipThink( ships[1], START2_DS_OFFSET_1_1, START2_DROPSHIP_BOUNDS, 	1000, 	1.5, 3.0 )
	delaythread( 0.1 ) Start2_MilDropshipThink( ships[2], START2_DS_OFFSET_2_1, START2_DROPSHIP_BOUNDS2, 	2000, 	1.5, 5.0 )
	delaythread( 2.0 ) Start2_MilDropshipThink( ships[3], START2_DS_OFFSET_3_1, START2_DROPSHIP_BOUNDS, 	500, 	1.5, 1.5 )
	delaythread( 1.2 ) Start2_MilDropshipThink( ships[4], START2_DS_OFFSET_4_1, START2_DROPSHIP_BOUNDS2, 	500, 	1.5, 1.5 )

	delaythread( 0.0 ) Enable_AfterBurner( ships[0] )
	delaythread( 0.1 ) Enable_AfterBurner( ships[1] )
	delaythread( 0.2 ) Enable_AfterBurner( ships[2] )
	delaythread( 0.5 ) Enable_AfterBurner( ships[3] )
	delaythread( 0.3 ) Enable_AfterBurner( ships[4] )
}

void function Start2_MilDropshipThink( ShipStruct crow, vector offset, vector bounds, float radius, float speedBlend, float accblend )
{
	thread ShipIdleAtTargetEnt_Method2( crow, file.playerWidow.mover, bounds, <0,0,0>, offset )
	SetMaxSpeed( crow, START2_MAXSPEED * 2 )
	SetMaxAcc( crow, START2_MAXACC * 2 )

	crow.goalRadius = radius
	WaitSignal( crow, "Goal" )

	crow.goalRadius = SHIPGOALRADIUS
	SetMaxSpeed( crow, START2_MAXSPEED, speedBlend )
	SetMaxAcc( 	crow, START2_MAXACC, 	accblend )
	delaythread( 1.5 ) Disable_AfterBurner( crow )
}

void function Start2_64VO()
{
	//Copy that! 6-4 en route!
	waitthreadsolo PlayDialogue( "diag_sp_intro_STS101_07_01_mcor_droz", file.droz )
	//Woo! Here we come!
	waitthreadsolo PlayDialogue( "diag_sp_intro_STS101_08_01_mcor_davis", file.davis )

	//This is Captain Meas of the Campbell. We'll provide a support platform.
	waitthreadsolo PlayDialogue( "diag_sp_intro_STS101_04_01_mcor_seyedCptn", file.player )
}

void function Start2_SarahAnim()
{
	thread WidowAnimateOpen( file.sarahWidow, "left" )

	delaythread( 13 ) FlagSet( "FlankSpeed" )
	delaythread( 2.6 ) PlayDialogue( "diag_sp_intro_STS101_03_01_mcor_sarah", file.sarahTitan )

	wait 0.8

	file.sarahTitan.Anim_ScriptedPlay( "bt_widow_intro_dialogue_Sarah" )
	file.sarahTitan.SetPlaybackRate( 1.25 )
	WaittillAnimDone( file.sarahTitan )
	thread PlayAnim( file.sarahTitan, "bt_widow_intro_hang_idle_sarah", file.sarahWidow.model, "ORIGIN" )
}

ShipStruct function SpawnIntro64( LocalVec ornull origin = null )
{
	bool animating = true
	ShipStruct crow = SpawnCrowLight( origin, CONVOYDIR, animating )
	Highlight_SetNeutralHighlight( crow.model, "sp_s2s_crow_outline" )
	Highlight_SetFriendlyHighlight( crow.model, "sp_s2s_crow_outline" )
	crow.bug_reproNum = 1
	crow.model.SetModel( CROW_HERO_MODEL  )
	crow.model.SetScriptName( "S2S_CALLSIGN_BB64" )

	bool alert = true
	crow.guys = SpawnSquad64( alert )
	return crow
}

void function Start_64ReadyForCombat()
{
	file.crow64.model.Anim_Play( "gd_goblin_open_doors" )

	SetAISettingsWrapper( file.bear, "npc_pilot_elite_s2s" )
	SetAISettingsWrapper( file.gates, "npc_pilot_elite_s2s" )
	SetAISettingsWrapper( file.davis, "npc_pilot_elite_s2s" )
	SetAISettingsWrapper( file.droz, "npc_pilot_elite_s2s" )

	GiveSwarmRocket( file.droz )
	GiveSMRRocket( file.davis )
	GiveSMRRocket( file.bear )
	GiveSMRRocket( file.gates )

	array<string> tags = [ "RESCUE", "RESCUE", "ORIGIN", "ORIGIN" ]
	array<string> anims =  [ "pt_S2S_crew_A_idle", "pt_S2S_crew_B_idle", "pt_S2S_crew_C_idle", "pt_S2S_crew_D_idle" ]

	foreach ( i, guy in file.crow64.guys )
	{
		guy.SetLookDistOverride( 20000 )

		guy.SetParent( file.crow64.model, tags[ i ], false, 0 )
		guy.Anim_ScriptedPlay( anims[ i ] )
	}
}

void function GiveSwarmRocket( entity guy )
{
	ReplaceATWeapon( guy, "sp_weapon_swarm_rockets_s2s", [ "HomingMissiles" ] )
}

void function GiveSMRRocket( entity guy )
{
	ReplaceATWeapon( guy, "mp_weapon_smr", [ "sp_s2s_settings" ] )
}

void function ReplaceATWeapon( entity guy, string weapon, array<string> mods )
{
	entity previousATWeapon = guy.GetAntiTitanWeapon()
	string previousATWeaponClassName = ""
	if ( IsValid( previousATWeapon ) )
		previousATWeaponClassName = previousATWeapon.GetWeaponClassName()

	if ( previousATWeaponClassName != "" )
		guy.TakeWeapon( previousATWeaponClassName )

	guy.GiveWeapon( weapon, mods )
	guy.SetActiveWeaponByName( weapon )
}

void function ReplaceWeapon( entity guy, string weapon, array<string> mods )
{
	guy.TakeActiveWeapon()
	guy.GiveWeapon( weapon, mods )
	guy.SetActiveWeaponByName( weapon )
}

void function SpawnRespawnWidow( LocalVec origin )
{
	//respawn WIDOW
	ShipStruct widow = SpawnWidow( origin )
	ClearShipBehavior( widow, eBehavior.ENEMY_ONBOARD )
	widow.model.SetScriptName( "RS Widow" )
	
	Highlight_SetFriendlyHighlight( widow.model, "friendly_ai" )
	widow.model.Anim_DisableUpdatePosition()
	widow.model.Anim_DisableAnimDelta()
	widow.model.SetInvulnerable()

	int fxID = GetParticleSystemIndex( FX_DECK_FLAP_WIND )
	array<entity> fxNodes = GetEntArrayByScriptName( "startP_widow_windfx" )
	foreach ( anchor in fxNodes )
	{
		int attachID = anchor.LookupAttachment( "REF" )
		StartParticleEffectOnEntity( anchor, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	}

	file.respawnWidow = widow

	AddFunctionForMapRespawn( GetMapName(), RespawnPlayer_s2s )

	SetMaxRoll( widow, 10 )
	WidowAnimateOpen( widow, "left" )
	DisableHullCrossing( widow )
}


void function StartSetupPlayerWidow( entity player, LocalVec origin )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	//player WIDOW
	ShipStruct widow = SpawnWidow( origin )
	ClearShipBehavior( widow, eBehavior.ENEMY_ONBOARD )

	AddShipEventCallback( widow, eShipEvents.PLAYER_ONHULL_START, PlayerWidowPlayerOnHullStart )
	AddShipEventCallback( widow, eShipEvents.PLAYER_ONHULL_END, PlayerWidowPlayerOnHullEnd )
	AddShipEventCallback( widow, eShipEvents.PLAYER_INCABIN_START, PlayerWidowPlayerInCabinStart )
	AddShipEventCallback( widow, eShipEvents.PLAYER_INCABIN_END, PlayerWidowPlayerInCabinEnd )
	thread Start_PushPlayerOffPlayerWidow()

	widow.model.Anim_Play( "wd_doors_open_idle_R" )
	widow.model.Anim_DisableUpdatePosition()
	widow.model.Anim_DisableAnimDelta()
	widow.model.SetInvulnerable()
	widow.triggerFallingDeath.Disable()

	EnableScript( widow, "scr_pwidow_node_0", "BODY", file.playerWidow_scrOffset )
	PlayerSetStartPoint( player, GetEntByScriptName( "pWidowPlayerStart" ) )

	bt.SetParent( widow.model, "BODY" )
	bt.Anim_ScriptedPlay( "bt_s2s_widow_idle" )

	thread StartPlayerWidowShake( widow )

	int fxID = GetParticleSystemIndex( FX_DECK_FLAP_WIND )
	array<entity> fxNodes = GetEntArrayByScriptName( "startP_widow_windfx" )
	foreach ( anchor in fxNodes )
	{
		int attachID = anchor.LookupAttachment( "REF" )
		StartParticleEffectOnEntity( anchor, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	}

	file.playerWidow = widow
}

void function Start_PushPlayerOffPlayerWidow()
{
	FlagEnd( "PlayerFallOut" )

	file.player.EndSignal( "OnDeath" )

	vector wind1 = < -75, -500, 0 >
	vector wind2 = < -75, -75, 0 >

	while( 1 )
	{
		wait 0.1

		if ( Flag( "PlayerInsidePlayerWidow" ) )
			continue

		if ( Distance( file.player.GetOrigin(), file.playerWidow.mover.GetOrigin() ) > 1500 )
			FlagSet( "PlayerFallingDeathFlag" )

		vector vel = file.player.GetVelocity()
		if ( file.player.IsOnGround() )
			file.player.SetVelocity( vel + wind1 )
		else
			file.player.SetVelocity( vel + wind2 )
	}
}

void function StartPlayerWidowShake( ShipStruct ship )
{
	ship.model.EndSignal( "OnDestroy" )
	EndSignal( ship, "FakeDestroy" )

	FlagWait( "IntroScreenFading" )

	float amplitude = 0.5
	float frequency = 50
	float duration = 600 //10 min
	float radius = 1024
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( ship.model )

	table e
	e.ent <- shake

	OnThreadEnd(
	function() : ( e )
		{
			entity ent = expect entity( e.ent )
			if ( IsValid( ent ) )
			{
				thread KillShake( ent )
			}
		}
	)

	FlagWait( "FlankSpeed" )
	thread KillShake( shake )

	if ( GetCurrentStartPoint() == "Level Start" )
	{
		amplitude = 3.0
		frequency = 200
		duration = 12
		radius = 1024
		if ( !IsValid( file.player ) )
			return
		
		shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
		shake.SetParent( ship.model )

		amplitude = 0.75
		frequency = 100
		duration = 20
		radius = 1024
		shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
		shake.SetParent( ship.model )

		e.ent = shake

		wait 15
	}

	amplitude = 0.5
	frequency = 100
	duration = 600 //10 min
	radius = 1024
	shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( ship.model )

	e.ent = shake

	FlagWait( "PlayerFallOut" )
}

void function KillShake( entity shake )
{
	if ( IsValid( shake ) )
	{
		EntFireByHandle( shake, "StopShake", "", 0, null, null )
		shake.Destroy()
	}
}

void function TrinityHangarDoorsOpen( string doorname1, string doorname2, string _setFlag, bool teleport = false )
{
	entity door1, door2, link1, link2
	vector origin1, origin2
	entity _parent = GetEntByScriptName( "scr_trinity_node_1b" )

	door1 = GetEntByScriptName( doorname1 )
	link1 = door1.GetLinkEnt()
	origin1 = link1.GetLocalOrigin()
	link1.ClearParent()
	link1.SetOrigin( door1.GetOrigin() )
	link1.SetParent( _parent, "", true, 0 )

	door2 = GetEntByScriptName( doorname2 )
	link2 = door2.GetLinkEnt()
	origin2 = link2.GetLocalOrigin()
	link2.ClearParent()
	link2.SetOrigin( door2.GetOrigin() )
	link2.SetParent( _parent, "", true, 0 )

	float time = 11
	float acc = 0.5
	if ( teleport )
	{
		time = 0.4
		acc = 0.1
	}

	door1.NonPhysicsSetMoveModeLocal( true )
	door2.NonPhysicsSetMoveModeLocal( true )

	door1.NonPhysicsMoveTo( origin1, time, acc, acc )
	wait ( time * 0.4 )

	time *= 0.5

	door2.NonPhysicsMoveTo( origin2, time, acc, acc )

	FlagSet( _setFlag )
}

void function TrinityHangarDoorsClose( string doorname1, string doorname2, string _clearflag, bool teleport = false )
{
	entity door1, door2, link1, link2
	vector origin1, origin2
	entity _parent = GetEntByScriptName( "scr_trinity_node_1b" )

	door1 = GetEntByScriptName( doorname1 )
	link1 = door1.GetLinkEnt()
	origin1 = link1.GetLocalOrigin()
	link1.ClearParent()
	link1.SetOrigin( door1.GetOrigin() )
	link1.SetParent( _parent, "", true, 0 )

	door2 = GetEntByScriptName( doorname2 )
	link2 = door2.GetLinkEnt()
	origin2 = link2.GetLocalOrigin()
	link2.ClearParent()
	link2.SetOrigin( door2.GetOrigin() )
	link2.SetParent( _parent, "", true, 0 )

	float time = 11
	float acc = 0.5
	if ( teleport )
	{
		time = 0.4
		acc = 0.1
	}

	door1.NonPhysicsMoveTo( origin1, time, acc, acc )

	float time2 = time * 0.5
	door2.NonPhysicsMoveTo( origin2, time2, acc, acc )

	wait time + 0.1
	FlagClear( _clearflag )
}

string function DropshipGetCallsign( int index )
{
	Assert( index < 10 )
	array<string> names = [ "S2S_CALLSIGN_BBAC",
							"S2S_CALLSIGN_BB21",
							"S2S_CALLSIGN_BB22",
							"S2S_CALLSIGN_BB23",
							"S2S_CALLSIGN_BB24",
							"S2S_CALLSIGN_BB31",
							"S2S_CALLSIGN_BB32",
							"S2S_CALLSIGN_BB33",
							"S2S_CALLSIGN_BB34" ]

	return names[ index ]
}

string function DropshipGetRandomCallsign()
{
	array<string> names = [ "S2S_CALLSIGN_RVAC",
							"S2S_CALLSIGN_RV21",
							"S2S_CALLSIGN_RV22",
							"S2S_CALLSIGN_RV23",
							"S2S_CALLSIGN_RV24",
							"S2S_CALLSIGN_RV31",
							"S2S_CALLSIGN_RV32",
							"S2S_CALLSIGN_RV33",
							"S2S_CALLSIGN_RV34",
							"S2S_CALLSIGN_CRAC",
							"S2S_CALLSIGN_CR21",
							"S2S_CALLSIGN_CR22",
							"S2S_CALLSIGN_CR23",
							"S2S_CALLSIGN_CR24",
							"S2S_CALLSIGN_CR31",
							"S2S_CALLSIGN_CR32",
							"S2S_CALLSIGN_CR33",
							"S2S_CALLSIGN_CR34",
							"S2S_CALLSIGN_VLAC",
							"S2S_CALLSIGN_VL21",
							"S2S_CALLSIGN_VL22",
							"S2S_CALLSIGN_VL23",
							"S2S_CALLSIGN_VL24",
							"S2S_CALLSIGN_VL31",
							"S2S_CALLSIGN_VL32",
							"S2S_CALLSIGN_VL33",
							"S2S_CALLSIGN_VL34"   ]

	int index = file.callsignIndex
	file.callsignIndex++
	if ( file.callsignIndex >= names.len() )
		file.callsignIndex = 0

	return names[ index ]
}

/************************************************************************************************\

███████╗████████╗ █████╗ ██████╗ ████████╗    ███████╗██╗  ██╗██╗██████╗     ████████╗███████╗ ██████╗██╗  ██╗
██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝    ██╔════╝██║  ██║██║██╔══██╗    ╚══██╔══╝██╔════╝██╔════╝██║  ██║
███████╗   ██║   ███████║██████╔╝   ██║       ███████╗███████║██║██████╔╝       ██║   █████╗  ██║     ███████║
╚════██║   ██║   ██╔══██║██╔══██╗   ██║       ╚════██║██╔══██║██║██╔═══╝        ██║   ██╔══╝  ██║     ██╔══██║
███████║   ██║   ██║  ██║██║  ██║   ██║       ███████║██║  ██║██║██║            ██║   ███████╗╚██████╗██║  ██║
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝       ╚══════╝╚═╝  ╚═╝╚═╝╚═╝            ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝

\************************************************************************************************/

void function Start_CrowTakesOff( ShipStruct crow, vector offsetP, vector boundsP, float side = 1.0 )
{
	thread PlayAnimTeleport( crow.model, "s2s_takeoff", crow.mover )
	crow.bug_reproNum = 1
	wait 4.5

	vector vel = crow.model.GetVelocity() - WORLD_CENTER.GetVelocity()
	vel += GetVelocityLocal( file.trinity.mover ).v
	crow.localVelocity.v = vel

	crow.model.ClearParent()
	crow.mover.ClearParent()
	crow.model.Anim_Stop()

	vector outVec 	= file.trinity.mover.GetRightVector() * side
	vector upVec 	= file.trinity.mover.GetUpVector()
	LocalVec origin = WorldToLocalOrigin( crow.model.GetOrigin() )
	origin.v += ( outVec * 600 ) + ( upVec * 200 )
	SetOriginLocal( crow.mover, origin )
	crow.mover.SetAngles( crow.model.GetAngles() )

	vector delta = GetRelativeDelta( crow.model.GetOrigin(), file.trinity.mover )
	vector offset = <5000,0,0>

	SetMaxAcc( crow, 600 )			//100
	SetMaxSpeed( crow, 3000 )		//500
	float x
	vector angles
	if ( side < 0 )
	{
		angles = <0,180,0>
		x = min( -150, file.trinity.localVelocity.v.x - 300  )
	}
	else
	{
		angles = <0,0,0>
		x = max( 150, file.trinity.localVelocity.v.x + 300 )
	}
	crow.localVelocity.v = < x ,0,0>
	thread ShipFlyToRelativePos( crow, file.trinity.mover, delta, offset, angles )

	float blendTime = 2.0
	crow.model.SetParent( crow.mover, "", false, blendTime )

	wait 2

	SetMaxAcc( crow, 200 )			//100
	SetMaxRoll( crow, 70 ) 			//37
	offset = < 5000,5000,0>
	thread ShipIdleAtTargetEnt_Method2( crow, file.trinity.mover, <0,0,0>, delta, offset )

	wait 1.5

	if ( !Flag( "FlankSpeed" ) )
	{
		SetMaxAcc( crow, START2_MAXACC * 1.5 )
		SetMaxSpeed( crow, START2_MAXSPEED * 1.5 )
	}

	SetMaxPitch( crow, START2_MAXPITCH )
	ResetBankTime( crow, 1.0 )
	ResetMaxRoll( crow, 3.0 )

	thread ShipIdleAtTargetEnt_Method2( crow, file.playerWidow.mover, boundsP, <0,0,0>, offsetP )
}

ShipStruct function Start_CreateLandedCrow( entity ref )
{
	LocalVec origin = WorldToLocalOrigin( ref.GetOrigin() )
	bool animating 	= true
	ShipStruct crow = SpawnCrowLight( origin, ref.GetAngles(), animating )

	Highlight_SetNeutralHighlight( crow.model, "sp_s2s_crow_outline" )
	Highlight_SetFriendlyHighlight( crow.model, "sp_s2s_crow_outline" )
	entity mover = CreateScriptMover( ref.GetOrigin(), ref.GetAngles() )

	crow.mover = mover
	crow.bug_reproNum = 1
	mover.DisableHibernation()
	mover.SetParent( file.trinity.model, "", true, 0 )
	crow.model.SetModel( CROW_HERO_MODEL  )
	crow.model.SetParent( mover, "", false, 0 )
	ref.Destroy()

	thread PlayAnimTeleport( crow.model, "s2s_rampdown_idle", crow.mover )

	return crow
}

/************************************************************************************************\

██╗███╗   ██╗████████╗██████╗  ██████╗
██║████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗
██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║
██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║
██║██║ ╚████║   ██║   ██║  ██║╚██████╔╝
╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝

\************************************************************************************************/
void function Intro_Setup( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	WORLD_CENTER.SetOrigin( <0,23500,0> )
	SetupShips_Intro()
	thread Intro_Sounds( INTROSOUNDSDELAY + 1.3 )
}

void function Intro_Skip( entity player )
{
	level.nv.ShipStreaming = SHIPSTREAMING_GIBRALTAR
}

void function Intro_Main( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	ReplaceWeapon( file.rocketDummy[ TEAM_MILITIA ], "mp_weapon_rocket_launcher", [ "sp_s2s_settings" ] )
	file.rocketDummy[ TEAM_MILITIA ].SetNoTarget( true )
	vector anchor = file.rocketDummy[ TEAM_MILITIA ].GetParent().GetOrigin()

	OnThreadEnd(
	function() : ( anchor )
		{
			if ( !IsValid( file.rocketDummy[ TEAM_MILITIA ] ) )
				return
			file.rocketDummy[ TEAM_MILITIA ].GetParent().ClearParent()
			file.rocketDummy[ TEAM_MILITIA ].GetParent().SetOrigin( anchor )
			file.rocketDummy[ TEAM_MILITIA ].SetNoTarget( false )
			ReplaceWeapon( file.rocketDummy[ TEAM_MILITIA ], "sp_weapon_swarm_rockets_s2s", [] )
		}
	)

	thread Intro_VO()
	thread ShipFlyToPos( file.playerWidow, V_INTRO2_PLAYER_1 )
	thread Intro_TrinityThink()

	LocalVec origin = GetOriginLocal( file.airBattleNode )
	origin.v += < 0,-50000, 0 >
	NonPhysicsMoveToLocal( file.airBattleNode, origin, 70, 3, 0 )

	array<ShipStruct> ships
	ships.append( file.sarahWidow )
	ships.append( file.crow64 )
	ships.extend( file.dropships[ TEAM_MILITIA ] )

	foreach ( ship in ships )
	{
		if ( !ship.model.IsInvulnerable() )
			ship.model.SetInvulnerable()
	}

	file.dropships[ TEAM_IMC ][0].model.SetHealth( 100 )
	file.dropships[ TEAM_IMC ][2].model.SetHealth( 100 )
	file.dropships[ TEAM_IMC ][4].model.SetHealth( 100 )
	file.dropships[ TEAM_IMC ][6].model.SetHealth( 100 )
	file.dropships[ TEAM_IMC ][8].model.SetHealth( 100 )

	thread IntroGoblinExplodeEarly( file.dropships[ TEAM_IMC ][1], 3 )
	thread IntroGoblinExplodeEarly( file.dropships[ TEAM_IMC ][3], 3.5 )
	thread IntroGoblinExplodeEarly( file.dropships[ TEAM_IMC ][5], 4 )
	thread IntroGoblinExplodeEarly( file.dropships[ TEAM_IMC ][7], 5 )
	thread IntroGoblinExplodeEarly( file.dropships[ TEAM_IMC ][9], 5.5 )

	wait 3
	Intro2_SpreadOut( ships )
	wait 3

	delaythread( 0.0 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 4 ], file.dropships[ TEAM_IMC ][ 4 ] )
	delaythread( 0.5 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 0 ], file.dropships[ TEAM_IMC ][ 0 ] )
	delaythread( 0.75 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 1 ], file.dropships[ TEAM_IMC ][ 3 ] )
	delaythread( 1.0 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 2 ], file.dropships[ TEAM_IMC ][ 1 ] )
	delaythread( 1.2 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 3 ], file.dropships[ TEAM_IMC ][ 2 ] )
	delaythread( 1.7 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 5 ], file.dropships[ TEAM_IMC ][ 5 ] )
	delaythread( 2.0 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 6 ], file.dropships[ TEAM_IMC ][ 6 ] )
	delaythread( 2.5 ) Intro_CrowFiresMissile( file.crow64, file.dropships[ TEAM_IMC ][ 7 ] )
	delaythread( 2.7 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 7 ], file.dropships[ TEAM_IMC ][ 8 ] )
	delaythread( 3.0 ) Intro_CrowFiresMissile( file.dropships[ TEAM_MILITIA ][ 8 ], file.dropships[ TEAM_IMC ][ 9 ] )

	wait 8

	level.nv.ShipStreaming = SHIPSTREAMING_GIBRALTAR

	Intro2_Regroup( ships )
	Intro2_KillStragglers( file.dropships[ TEAM_IMC ] )

	file.playerWidow.goalRadius = INTRO2_PLAYER_GOALRADIUS
	WaitSignal( file.playerWidow, "Goal" )
	file.playerWidow.goalRadius = SHIPGOALRADIUS

	foreach ( ship in file.dropships[ TEAM_MILITIA ] )
		ship.model.ClearInvulnerable()

	CheckPointData data
	data.safeLocations = GetEntArrayByScriptName( "pWidowPlayerStart" )
	CheckPoint( data )
}

void function IntroGoblinExplodeEarly( ShipStruct ship, float delay )
{
	WaitSignal( ship, "FakeDeath" )

	wait delay
	ship.goalRadius = 15000
}

void function Intro_CrowFiresMissile( ShipStruct crow, ShipStruct target )
{
	entity anchor = file.rocketDummy[ TEAM_MILITIA ].GetParent()
	anchor.ClearParent()
	anchor.SetOrigin( crow.model.GetOrigin() + ( crow.model.GetRightVector() * 165 ) + ( crow.model.GetForwardVector() * -50 ) + ( crow.model.GetUpVector() * 36 ) )
	anchor.SetAngles( AnglesCompose( crow.model.GetAngles(), <90,0,0> ) )
	anchor.SetParent( crow.model, "", true, 0 )

	entity weapon 	= file.rocketDummy[ TEAM_MILITIA ].GetActiveWeapon()
	WeaponPrimaryAttackParams attackParams

	int attachID = weapon.LookupAttachment( "muzzle_flash" )
	attackParams.pos = weapon.GetAttachmentOrigin( attachID )
	attackParams.dir = AnglesToForward( weapon.GetAttachmentAngles( attachID ) )

	EmitSoundOnEntity( crow.model, "weapon_archer_fire_3p" )
	OnWeaponNpcPrimaryAttack_S2S_weapon_rocket_launcher( weapon, attackParams, target.model )
}

void function Intro_VO()
{
	wait 1.0

	//Enemy squadron in sight!
	thread Intro_SarahPoint()
	thread PlayDialogue( "diag_sp_intro_STS101_05_01_mcor_sarah", file.player )
	wait 2.0

	//Lock archers! We got the drop on them!
	thread PlayDialogue( "diag_sp_intro_STS101_10_01_mcor_sarah", file.player )
	wait 3.0


	//Light 'em up!
	thread PlayDialogue( "diag_sp_intro_STS101_13_01_mcor_sarah", file.player )
	wait 1.0

	//Fox 2, Fox 2
	thread PlayDialogue( "diag_sp_adds_STS801_09_01_mcor_grunt", file.player )
	wait 1.5

	//Missile off the rail
	thread PlayDialogue( "diag_sp_adds_STS801_10_01_mcor_grunt", file.player )
	wait 3.0

	//Splash 1
	thread PlayDialogue( "diag_sp_adds_STS801_11_01_mcor_grunt", file.player )
	wait 1.0

	//Splash 2
	thread PlayDialogue( "diag_sp_adds_STS801_12_01_mcor_grunt", file.player )
	wait 1.0

	//Good hit! Good hit!
	thread PlayDialogue( "diag_sp_gibraltar_STS102_03_01_mcor_radCom", file.player )
	wait 1.5

	//Confirm splash on all trail units
	thread PlayDialogue( "diag_sp_adds_STS801_13_01_mcor_grunt", file.player )
}

void function Intro_SarahPoint()
{
	waitthread PlayAnimTeleport( file.sarahTitan, "bt_widow_intro_hang_point_sarah", file.sarahWidow.model, "ORIGIN" )
	thread PlayAnimTeleport( file.sarahTitan, "bt_widow_intro_hang_idle_sarah", file.sarahWidow.model, "ORIGIN" )
}


void function Intro_TrinityThink( bool teleport = false )
{
	SetMaxSpeed( file.trinity, 810 )
	SetMaxAcc( file.trinity, 100 )
	vector bounds = <0,0,0>

	if( !teleport )
		thread ShipIdleAtTargetEnt_Method2( file.trinity, file.playerWidow.mover, bounds, <0,0,0>, INTRO2_TRINITY_0 )
	else
		ShipIdleAtTargetEnt_M2_Teleport( file.trinity, file.playerWidow.mover, bounds, <0,0,0>, INTRO2_TRINITY_0 )
}

void function Intro2_SpreadOut( array<ShipStruct> ships )
{
	array<vector> offsets = Intro2_GetOffsets()
	array<vector> bounds = Intro2_GetBounds()

	foreach ( index, ship in ships )
	{
		vector offset = offsets[ index ]
		vector newoffset = < offset.x * 2, offset.y, offset.z >
		thread ShipIdleAtTargetEnt_Method2( ship, file.playerWidow.mover, bounds[ index ], <0,0,0>, newoffset )
	}
}

void function Intro2_Regroup( array<ShipStruct> ships )
{
	array<vector> offsets = Intro2_GetOffsets()
	array<vector> bounds = Intro2_GetBounds()

	foreach ( index, ship in ships )
		thread ShipIdleAtTargetEnt_Method2( ship, file.playerWidow.mover, bounds[ index ], <0,0,0>, offsets[ index ] )
}

array<vector> function Intro2_GetOffsets()
{
	array<vector> offsets = [	START2_WIDOW_OFFSET_2,
								START2_CROW_OFFSET_1,
								START2_DS_OFFSET_0_1,
								START2_DS_OFFSET_1_1,
								START2_DS_OFFSET_2_1,
								START2_DS_OFFSET_3_1,
								START2_DS_OFFSET_4_1,
								START2_DS_OFFSET_5_1,
								START2_DS_OFFSET_6_1,
								START2_DS_OFFSET_7_1,
								START2_DS_OFFSET_8_1 ]
	return offsets
}

array<vector> function Intro2_GetBounds()
{
	array<vector> bounds = [	START2_WIDOW_BOUNDS2,
								START2_CROW_BOUNDS,
								START2_DROPSHIP_BOUNDS,
								START2_DROPSHIP_BOUNDS,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2,
								START2_DROPSHIP_BOUNDS2 ]
	return bounds
}

void function Intro2_KillStragglers( array<ShipStruct> ships )
{
	foreach( ship in ships )
	{
		if ( !IsValid( ship.model ) )
			continue

		if ( !IsShipOnBattleField( ship ) )
			continue

		thread SetBehavior( ship, eBehavior.DEATH_ANIM )
	}
}

void function Intro2_EnemySquadron1()
{
	array<vector> offsets = [ 	INTRO2_GB_OFFSET_0_0,
								INTRO2_GB_OFFSET_1_0,
								INTRO2_GB_OFFSET_2_0,
								INTRO2_GB_OFFSET_3_0,
								INTRO2_GB_OFFSET_4_0,
								INTRO2_GB_OFFSET_5_0,
								INTRO2_GB_OFFSET_6_0,
								INTRO2_GB_OFFSET_7_0,
								INTRO2_GB_OFFSET_8_0,
								INTRO2_GB_OFFSET_9_0 ]
	bool animating 	= true

	LocalVec origin = GetOriginLocal( file.airBattleNode )

	foreach ( index, offset in offsets )
	{
		ShipStruct ship = SpawnGoblinLight( CLVec( origin.v + offset ), CONVOYDIR, animating )
		ship.bug_reproNum = 1

		Highlight_SetNeutralHighlight( ship.model, "sp_s2s_goblin_outline" )
		Highlight_SetEnemyHighlight( ship.model, "sp_s2s_goblin_outline" )

		thread ShipIdleAtTargetEnt_Method2( ship, file.airBattleNode, INTRO2_GB_BOUNDS, <0,0,0>, offset )
		SetMaxSpeed( ship, START2_MAXSPEED * 1.56 )
		SetMaxAcc( ship, START2_MAXACC * 1.56 )
		SetMaxPitch( ship, START2_MAXPITCH )
		ClearShipBehavior( ship, eBehavior.DEATH_ANIM )
		AddShipBehavior( ship, eBehavior.DEATH_ANIM, Behavior_GoblinIntroDeathAnim )

		file.dropships[ TEAM_IMC ].append( ship )
	}

	#if DEV
		foreach ( index, ship in file.dropships[ TEAM_IMC ] )
			thread AirBattle_DEVPrint( ship, index )
	#endif
}

void function Behavior_GoblinIntroDeathAnim( ShipStruct ship )
{
	thread Behavior_GoblinIntroDeathAnimThread( ship )
}

void function Behavior_GoblinIntroDeathAnimThread( ShipStruct ship )
{
	Signal( ship, "FakeDeath" )
	EndSignal( ship, "FakeDestroy" )
	ResetMaxPitch( ship )

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )

	entity fxRef = GoblinDeathFx( ship )

	OnThreadEnd(
	function() : ( ship, fxRef )
		{
			if ( IsValid( fxRef ) )
				fxRef.Destroy()

			ExplodeGoblin( ship )

			if ( IsValid( ship.model ) )
				SetCustomSmartAmmoTarget( ship.model, false )
		}
	)

	SetMaxSpeed( ship, ship.defSpeedMax * 3, 1.5 )
	SetMaxAcc( ship, ship.defAccMax * 3, 1.5 )

	entity noFollowTarget = null

	float x = 0
	float y = -9000
	float z = -9000

	LocalVec pos = CLVec( GetOriginLocal( mover ).v + < x, y, z > )
	vector offset = <0,0,0>
	thread __ShipFlyToPosInternal( ship, noFollowTarget, pos, offset, CONVOYDIR )

	ship.goalRadius = RandomFloatRange( 3000, 6000 )
	WaitSignal( ship, "Goal" )
}

void function Intro_CrowReadyForCombat( ShipStruct crow )
{
	crow.model.Anim_Play( "gd_goblin_open_doors" )

	array<string> tags = [ "RESCUE", "RESCUE", "ORIGIN", "ORIGIN" ]
	array<string> anims =  [ "pt_S2S_crew_A_idle", "pt_S2S_crew_B_idle", "pt_S2S_crew_C_idle", "pt_S2S_crew_D_idle" ]

	for ( int i = 0; i < 4; i++ )
	{
		entity guy = CreateSoldier( TEAM_MILITIA, crow.model.GetOrigin(), crow.model.GetAngles() )
		if ( IsOdd( i ) )
			SetSpawnOption_Weapon( guy, "sp_weapon_swarm_rockets_s2s", [ "HomingMissiles" ] )
		else
			SetSpawnOption_Weapon( guy, "mp_weapon_smr", [ "sp_s2s_settings" ] )

		DispatchSpawn( guy )
		guy.DisableHibernation()
		guy.SetLookDistOverride( 20000 )
		Highlight_ClearFriendlyHighlight( guy )

		guy.SetParent( crow.model, tags[ i ], false, 0 )
		guy.Anim_ScriptedPlay( anims[ i ] )
		crow.guys.append( guy )
	}
}

/************************************************************************************************\

 ██████╗ ██╗██████╗ ██████╗  █████╗ ██╗  ████████╗ █████╗ ██████╗
██╔════╝ ██║██╔══██╗██╔══██╗██╔══██╗██║  ╚══██╔══╝██╔══██╗██╔══██╗
██║  ███╗██║██████╔╝██████╔╝███████║██║     ██║   ███████║██████╔╝
██║   ██║██║██╔══██╗██╔══██╗██╔══██║██║     ██║   ██╔══██║██╔══██╗
╚██████╔╝██║██████╔╝██║  ██║██║  ██║███████╗██║   ██║  ██║██║  ██║
 ╚═════╝ ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝

\************************************************************************************************/
void function Gibraltar_Setup( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	WORLD_CENTER.SetOrigin( <0,10000,0> )
	SetupShips_Gibraltar()
	thread Gibraltar_Sounds( INTROSOUNDSDELAY + 19 )
}

void function Gibraltar_Skip( entity player )
{
	ShipGeoShow( file.gibraltar, "GIBRALTAR_CHUNK_INTERIOR" )
}

void function Gibraltar_Main( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	ShipGeoShow( file.gibraltar, "GIBRALTAR_CHUNK_INTERIOR" )
	EnableScript( file.gibraltar, "scr_gibraltar_node_1" )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	thread Gibraltar_PullAway()
	thread Gibraltar_VO()

	thread ShipFlyToPos( file.playerWidow, V_GIBRALTAR_PLAYER0 )

	file.playerWidow.goalRadius = GIBRALTAR_PLAYER_GOALRADIUS + 700
	WaitSignal( file.playerWidow, "Goal" )

	thread Gibraltar_Crow64Think()

	file.playerWidow.goalRadius = GIBRALTAR_PLAYER_GOALRADIUS
	WaitSignal( file.playerWidow, "Goal" )

	array<vector> offsets = [ 	GIBRALTAR_DS_OFFSET_0_0,
								GIBRALTAR_DS_OFFSET_1_0,
								GIBRALTAR_DS_OFFSET_2_0,
								GIBRALTAR_DS_OFFSET_3_0,
								GIBRALTAR_DS_OFFSET_4_0,
								GIBRALTAR_DS_OFFSET_5_0,
								GIBRALTAR_DS_OFFSET_6_0,
								GIBRALTAR_DS_OFFSET_7_0,
								GIBRALTAR_DS_OFFSET_8_0 ]

	foreach ( index, ship in file.dropships[ TEAM_MILITIA ] )
		thread ShipIdleAtTargetEnt_Method2( ship, file.playerWidow.mover, GIBRALTAR_DS_BOUNDS, <0,0,0>, offsets[ index ] )

	thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.playerWidow.mover, GIBRALTAR_DS_BOUNDS, <0,0,0>, GIBRALTAR_WIDOW_OFFSET_0 )
	thread ShipFlyToPos( file.playerWidow, V_GIBRALTAR_PLAYER1 )

	Enable_AfterBurner( file.sarahWidow )
	delaythread( 6.0 ) Disable_AfterBurner( file.sarahWidow )

	file.playerWidow.goalRadius = 4500
	WaitSignal( file.playerWidow, "Goal" )
	thread Gibraltar_Enemies( player, file.playerWidow )
	thread Gibraltar_EngineShake()

	file.playerWidow.goalRadius = 3000
	WaitSignal( file.playerWidow, "Goal" )
	thread Gibraltar_VO2()
	thread Gibraltar_CrowsCrashing()

	file.playerWidow.goalRadius = GIBRALTAR_PLAYER_GOALRADIUS
	WaitSignal( file.playerWidow, "Goal" )
	thread ShipFlyToPos( file.playerWidow, V_GIBRALTAR_PLAYER2 )

	file.playerWidow.goalRadius = GIBRALTAR_PLAYER_GOALRADIUS2
	WaitSignal( file.playerWidow, "Goal" )
	file.playerWidow.goalRadius = SHIPGOALRADIUS

	CheckPointData data
	data.safeLocations = GetEntArrayByScriptName( "pWidowPlayerStart" )
	CheckPoint( data )
}

void function Gibraltar_EngineShake()
{
	float amplitude = 2.5
	float frequency = 100
	float duration = 3.0
	float radius = 1024
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.playerWidow.model )

	wait 0.5
	amplitude = 5.0
	frequency = 100
	duration = 4.5
	radius = 1024
	shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.playerWidow.model )
}

void function Gibraltar_Crow64Think( bool teleport = false )
{
	vector bounds = < 400, 100, 100 >
	SetMaxSpeed( 	file.crow64, START2_MAXSPEED * 2.0, 3.0 )
	SetMaxAcc( 		file.crow64, START2_MAXACC * 2.0, 3.0 )

	if ( !teleport )
	{
		Enable_AfterBurner( file.crow64 )
		thread ShipIdleAtTargetEnt_Method2( file.crow64, 	file.playerWidow.mover, bounds, <0,0,0>, GIBRALTAR_CROW_OFFSET_0 )

		file.crow64.goalRadius = 300
		WaitSignal( file.crow64, "Goal" )
		file.crow64.goalRadius = SHIPGOALRADIUS

		delaythread( 1.0 ) Disable_AfterBurner( file.crow64 )
		SetMaxSpeed( 	file.crow64, START2_MAXSPEED, 3.0 )
		SetMaxAcc( 		file.crow64, START2_MAXACC, 3.0 )
	}
	else
	{
		SetMaxSpeed( file.crow64, START2_MAXSPEED )
		SetMaxAcc( 	file.crow64, START2_MAXACC )
		thread ShipIdleAtTargetEnt_M2_Teleport( file.crow64, 	file.playerWidow.mover, bounds, <0,0,0>, GIBRALTAR_CROW_OFFSET_0 )
	}
}

void function Gibraltar_PullAway( bool teleport = false )
{
	SetMaxSpeed( 	file.gibraltar, 1000 )
	SetMaxAcc( 		file.gibraltar, 150 )
	SetMaxPitch( 	file.gibraltar, 0 )

	float time 	= 45
	float acc 	= 4
	float dist 	= 50000
	LocalVec origin = clone V_INTRO2_GIBRALTAR
	LocalVec end 	= clone origin
	end.v += < 0, -dist, 0 >

	if ( teleport )
	{
		float skip = 20000
		time *= ( dist - skip ) / dist
		origin.v -= < 0, skip, 0 >
		acc = 0
	}

	SetOriginLocal( file.airBattleNode, origin )
	NonPhysicsMoveToLocal( file.airBattleNode, end, time, acc, 0 )

	vector offset
	if ( !teleport )
	{
		offset = <1000,0,-100>
		thread ShipIdleAtTargetEnt_Method2( file.gibraltar, file.airBattleNode, <0,0,0>, <0,0,0>, offset )

		wait 9.5
	}

	offset = < -800,0,-300>
	SetMaxAcc( 		file.gibraltar, 200 )

	if ( !teleport )
		thread ShipIdleAtTargetEnt_Method2( file.gibraltar, file.airBattleNode, <0,0,0>, <0,0,0>, offset )
	else
	{
		ShipIdleAtTargetEnt_M2_Teleport( file.gibraltar, file.airBattleNode, <0,0,0>, <0,0,0>, offset )
		file.gibraltar.localVelocity.v = <0,-500,0>
	}
}

void function Gibraltar_VO()
{
	thread Intro_SarahPoint()
	//We're coming up on a transport! Just burn past it! We have to catch the Draconis!
	waitthreadsolo PlayDialogue( "diag_sp_gibraltar_STS103_01_01_mcor_sarah", file.player )
}

void function Gibraltar_VO2()
{
	wait 0.2

	StopMusic()
	PlayMusic( "music_s2s_00b_unidentifiedbogey" )

	//I got an unidentified <bogey at 11 o'clock>!
	thread PlayDialogue( "diag_sp_gibraltar_STS105_01_01_mcor_radCom", file.player )
	wait 2.3

	//What the hell is that? Anyone got a clear visual?
	thread PlayDialogue( "diag_sp_gibraltar_STS106_01_01_mcor_sarah", file.sarahTitan )
	wait 1.5

	//Break right break right! Blackbird Actual is down! It's on our six! AAAAA<AAAAA!!>
	thread PlayDialogue( "diag_sp_gibraltar_STS107_02_01_mcor_radCom", file.player )
	wait 2.0

	//Mayday! Mayday! We're going down we're <going down!!!!>
	thread PlayDialogue( "diag_sp_gibraltar_STS105_03_01_mcor_radCom", file.player )

	wait 1.2
	StopDialogue()
}

void function Gibraltar_CrowsCrashing()
{
	LocalVec pos

	wait 1.5
	//EmitSoundOnEntity( file.player, "northstar_rocket_fire" )
	wait 3.5

	pos = GetOriginLocal( file.dropships[ TEAM_MILITIA ][ 6 ].mover )
	pos.v += <0,9000,0>
	file.dropships[ TEAM_MILITIA ][ 6 ].mover.NonPhysicsStop()
	SetOriginLocal( file.dropships[ TEAM_MILITIA ][ 6 ].mover, pos )
	ResetMaxPitch( file.dropships[ TEAM_MILITIA ][ 6 ] )
	thread SetBehavior( file.dropships[ TEAM_MILITIA ][ 6 ], eBehavior.DEATH_ANIM )

	wait 1.5

	pos = GetOriginLocal( file.dropships[ TEAM_MILITIA ][ 4 ].mover )
	pos.v += <0,15000,0>
	file.dropships[ TEAM_MILITIA ][ 4 ].mover.NonPhysicsStop()
	SetOriginLocal( file.dropships[ TEAM_MILITIA ][ 4 ].mover, pos )
	ResetMaxPitch( file.dropships[ TEAM_MILITIA ][ 4 ] )
	thread SetBehavior( file.dropships[ TEAM_MILITIA ][ 4 ], eBehavior.DEATH_ANIM ) //2-4

	wait 0.2

	ResetMaxPitch( file.dropships[ TEAM_MILITIA ][ 0 ] )
	thread SetBehavior( file.dropships[ TEAM_MILITIA ][ 0 ], eBehavior.DEATH_ANIM ) // actual

	wait 0.2

	pos = GetOriginLocal( file.dropships[ TEAM_MILITIA ][ 7 ].mover )
	pos.v += <0,7000,0>
	file.dropships[ TEAM_MILITIA ][ 7 ].mover.NonPhysicsStop()
	SetOriginLocal( file.dropships[ TEAM_MILITIA ][ 7 ].mover, pos )
	ResetMaxPitch( file.dropships[ TEAM_MILITIA ][ 7 ] )
	thread SetBehavior( file.dropships[ TEAM_MILITIA ][ 7 ], eBehavior.DEATH_ANIM )

	wait 0.2

	ResetMaxPitch( file.dropships[ TEAM_MILITIA ][ 8 ] )
	thread SetBehavior( file.dropships[ TEAM_MILITIA ][ 8 ], eBehavior.DEATH_ANIM )
}

void function Gibraltar_Enemies( entity player, ShipStruct widow )
{
	array<entity> spawners
	array<entity> ents

	spawners = GetEntArrayByScriptName( "gibraltar_guy1" )
	foreach ( spawner in spawners )
		Gibraltar_EnemiesThink( spawner )

	wait 1.5
	spawners = GetEntArrayByScriptName( "gibraltar_guy2" )
	foreach ( spawner in spawners )
		Gibraltar_EnemiesThink( spawner )

	wait 2.5
	spawners = GetEntArrayByScriptName( "gibraltar_guy3" )
	foreach ( spawner in spawners )
		Gibraltar_EnemiesThink( spawner )

	wait 3.0
	ents = GetEntArrayByScriptName( "gibraltar_guy1" )
	foreach ( ent in ents )
		ent.Destroy()

	wait 0.5
	spawners = GetEntArrayByScriptName( "gibraltar_guy4" )
	foreach ( spawner in spawners )
		Gibraltar_EnemiesThink( spawner )

	wait 1.0
	ents = GetEntArrayByScriptName( "gibraltar_guy2" )
	foreach ( ent in ents )
		ent.Destroy()

	wait 1.0
	ents = GetEntArrayByScriptName( "gibraltar_guy3" )
	foreach ( ent in ents )
		ent.Destroy()

	wait 4.0
	ents = GetEntArrayByScriptName( "gibraltar_guy4" )
	foreach ( ent in ents )
		ent.Destroy()
}

entity function Gibraltar_EnemiesThink( entity spawner )
{
	entity guy = SpawnOnShip( spawner, file.gibraltar )
	guy.kv.allowshoot = false
	guy.AssaultSetGoalRadius( 100 )
	guy.AssaultPoint( guy.GetLinkEnt().GetOrigin() )
	guy.DisableHibernation()
	guy.SetLookDistOverride( 2000 )
	guy.SetNoTarget( true )
	return guy
}

/************************************************************************************************\

██████╗  ██████╗ ███████╗███████╗    ██╗███╗   ██╗████████╗██████╗  ██████╗
██╔══██╗██╔═══██╗██╔════╝██╔════╝    ██║████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗
██████╔╝██║   ██║███████╗███████╗    ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║
██╔══██╗██║   ██║╚════██║╚════██║    ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║
██████╔╝╚██████╔╝███████║███████║    ██║██║ ╚████║   ██║   ██║  ██║╚██████╔╝
╚═════╝  ╚═════╝ ╚══════╝╚══════╝    ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝

\************************************************************************************************/
void function BossIntro_Setup( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	WORLD_CENTER.SetOrigin( <0,-2400,0> )
	SetupShips_BossIntro()
}

void function BossIntro_Skip( entity player )
{
	bool skipping = true
	MaltaReal_ShipGeoSettings( skipping )
	EnableScript( file.malta, "scr_malta_node_0" )
	thread MaltaDeck_SpawnDeckGuns()

	switch( GetCurrentStartPoint() )
	{
		case "--------------":
		case "TestBed":
		case "Dropship Combat Test":
		case "LightEdit Connect":
		case "TRAILER bridge":
			//don't destroy it
			return
			break
	}

	GetEntByScriptName( "GIBRALTAR_CHUNK_INTERIOR" ).Destroy()
}

void function BossIntro_Main( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	//It's too fast, I can't track it I can't track it!!!
	thread PlayDialogue( "diag_sp_gibraltar_STS107_01_01_mcor_radCom", file.player )

	SetMaxSpeed( file.trinity, 1500 )
	SetMaxAcc( file.trinity, 300 )
	SetBankTime( file.trinity, 1.0 )
	delaythread( 1.5 ) ResetBankTime( file.trinity )
	thread ShipIdleAtTargetPos( file.trinity,	V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )

	LocalVec origin = GetOriginLocal( file.sarahWidow.mover )
	origin.v += <8000,30000,2000 >
	ResetMaxPitch( file.sarahWidow )
	SetMaxSpeed( file.sarahWidow, 2000 )
	SetMaxAcc( file.sarahWidow, 400 )

	thread ShipIdleAtTargetPos( file.sarahWidow, 	origin, 	<0,0,0> )
	thread ShipIdleAtTargetPos( file.malta, 	V_BARKER_MALTA, 	BARKER_MALTA_BOUNDS )
	thread ShipIdleAtTargetPos( file.OLA, 		V_BARKER_OLA, 		BARKER_OLA_BOUNDS )

	ResetMaxSpeed( file.gibraltar )
	ResetMaxAcc( file.gibraltar)
	thread ShipIdleAtTargetPos( file.gibraltar, V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )

	thread ShipFlyToPos( file.playerWidow, V_BOSSINTRO_PLAYER1 )
	file.playerWidow.goalRadius = SHIPGOALRADIUS

	delaythread( 4.0 ) Enable_AfterBurner( file.sarahWidow )
	delaythread( 6.5 ) Disable_AfterBurner( file.sarahWidow )

	foreach ( ship in file.dropships[ TEAM_MILITIA ] )
		thread BossIntro_PreventShipFromBlowingUp( ship )

	BossIntro_SpawnBossTitan( BOSSINTRO_VIPER_DELTA0 )
	waitthread BossIntro_ViperThink( player )

	while( file.playerWidow.model.IsInvulnerable() )
		file.playerWidow.model.ClearInvulnerable()

	file.playerWidow.model.WaitSignal( "OnDamaged" )
	file.playerWidow.model.SetInvulnerable()

	FlagSet( "PlayerFallOut" )
}

void function BossIntro_ViperThink( entity player )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	float time = 1.0
	float angle = -45
	int yawID 	= file.viper.LookupPoseParameterIndex( "move_yaw" )
	file.viper.SetPoseParameterOverTime( yawID, angle, time )
	entity link = file.viper.GetParent()
	link.NonPhysicsSetRotateModeLocal( true )
	link.NonPhysicsRotateTo( <0,0,angle * 0.5>, time, time * 0.25, time * 0.25 )

	delaythread( 0.5 ) BossIntro_BTPoint( bt )

	entity ref = file.playerWidow.model
	ShipStruct crow1 = file.dropships[ TEAM_MILITIA ][1]
	ShipStruct crow2 = file.dropships[ TEAM_MILITIA ][3]
	ShipStruct crow3 = file.dropships[ TEAM_MILITIA ][5]

	thread DoCustomBehavior( crow1, BossIntroCustomNothing )
	thread DoCustomBehavior( crow2, BossIntroCustomNothing )
	thread DoCustomBehavior( crow3, BossIntroCustomNothing )

	ClearShipBehavior( crow1, eBehavior.DEATH_ANIM )
	ClearShipBehavior( crow2, eBehavior.DEATH_ANIM )
	ClearShipBehavior( crow3, eBehavior.DEATH_ANIM )
	AddShipBehavior( crow1, eBehavior.DEATH_ANIM, BossIntro_Behavior_DeathAnim )
	AddShipBehavior( crow2, eBehavior.DEATH_ANIM, BossIntro_Behavior_DeathAnim )
	AddShipBehavior( crow3, eBehavior.DEATH_ANIM, BossIntro_Behavior_DeathAnim )

	file.viper.SetParent( ref, "REF", false, 0 )
	crow1.model.SetParent( ref, "REF", false, 0 )
	crow2.model.SetParent( ref, "REF", false, 0 )
	crow3.model.SetParent( ref, "REF", false, 0 )

	thread PlayAnimTeleport( file.viper, "lt_viper_main_intro_idle", ref, "REF" )
	thread PlayAnimTeleport( crow1.model, "cd_01_viper_main_intro_idle", ref, "REF" )
	thread PlayAnimTeleport( crow2.model, "cd_02_viper_main_intro_idle", ref, "REF" )
	thread PlayAnimTeleport( crow3.model, "cd_03_viper_main_intro_idle", ref, "REF" )

	delaythread( 1.5 ) BossIntro_BTVO( bt )
	wait 2.0

	thread PlayAnim( file.viper, "lt_viper_main_intro", ref, "REF" )
	thread PlayAnim( crow1.model, "cd_01_viper_main_intro", ref, "REF" )
	thread PlayAnim( crow2.model, "cd_02_viper_main_intro", ref, "REF" )
	thread PlayAnim( crow3.model, "cd_03_viper_main_intro", ref, "REF" )

	thread BossIntro_StartIntro( player, file.viper, ref )

	array<ShipStruct> ships
	ships.append( crow1 )
	ships.append( crow2 )
	ships.append( crow3 )
	ships.append( file.dropships[ TEAM_MILITIA ][2] )

	thread BossIntro_CoreAlarm()
	thread BossIntro_SalvoThink( ships )

	file.viper.WaitSignal( "fireCore" )

	ShipStruct target = file.playerWidow
	float launchdelay = 2.0
	float homingSpeedScalar = 2.0
	float missileSpeedScalar = 0.75
	thread BossIntro_FireCore( file.viper, [ target ], <0,0,50>, launchdelay, homingSpeedScalar, missileSpeedScalar, 10 )

	delaythread( 1 ) BossIntro_BTCombatIdle( bt )
	delaythread( 1 ) BossIntro_ConnectBarkerShip()

	WaittillAnimDone( file.viper )

	thread BossIntro_ViperFlyAway( file.viper, ref )
	bt.DisableNPCFlag( NPC_IGNORE_ALL )

	waitthread BossIntro_EndIntro( player, file.viper )
}

void function BossIntro_ViperFlyAway( entity viper, entity ship )
{
	float blendTime = 0.5
	entity ref = CreateScriptMover( ship.GetOrigin(), CONVOYDIR )
	viper.SetParent( ref, "REF", false, blendTime )
	waitthread PlayAnim( viper, "lt_viper_main_intro_end", ref, "REF", blendTime )

	string anim = "lt_viper_main_intro_idle"
	vector origin = HackGetDeltaToRef( viper.GetOrigin(), viper.GetAngles(), viper, anim )
	entity anchor = CreateScriptMover( origin, viper.GetAngles() )

	viper.SetParent( anchor, "REF", false, blendTime )
	ref.Destroy()

	viper.Anim_ScriptedPlay( anim )

	thread BossIntro_ViperFlyAway_Fire( viper )

	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + < -4000,2000,-7000>, 10, 0, 0 )
	wait 10

	float time = 40
	anchor.NonPhysicsMoveTo( anchor.GetOrigin() + < 3000,60000,4000>, time, 17, 0 )

	wait time
	anchor.Destroy()
}

void function BossIntro_ViperFlyAway_Fire( entity viper )
{
	viper.EndSignal( "OnDestroy" )

	float homingSpeed = 1.0
	float missileSpeed = 0.75

	wait 4

	array<ShipStruct> ships = []
	BossIntro_TryAddVictom( ships, file.dropships[ TEAM_MILITIA ][0] )
	BossIntro_TryAddVictom( ships, file.dropships[ TEAM_MILITIA ][1] )
	ships.append( file.trinity )
	thread BossIntro_SalvoAnim( file.viper, ships, 10, homingSpeed, missileSpeed )

	wait 12

	ships = []
	BossIntro_TryAddVictom( ships, file.dropships[ TEAM_MILITIA ][5] )
	ships.append( file.trinity )
	thread BossIntro_SalvoAnim( file.viper, ships, 10, homingSpeed, missileSpeed )

	wait 6

	ships = []
	BossIntro_TryAddVictom( ships, file.dropships[ TEAM_MILITIA ][7] )
	ships.append( file.trinity )
	thread BossIntro_SalvoAnim( file.viper, ships, 10, homingSpeed, missileSpeed )
}

void function BossIntro_TryAddVictom( array<ShipStruct> shipArray, ShipStruct ship )
{
	if ( IsValid( ship.model ) )
	{
		ship.model.SetHealth( 200 )
		shipArray.append( ship )
	}
}

void function BossIntro_SalvoThink( array<ShipStruct> ships )
{
	foreach ( ship in ships )
	{
		ship.model.SetMaxHealth( 1000 )
		ship.model.SetHealth( 1000 )
	}

	float homingSpeed = 2.0
	float missileSpeed = 0.75

	//1
	table result = WaitSignal( file.viper, "fireSalvo" )
	thread BossIntro_SalvoAnim( file.viper, [ ships[2] ], expect int( result.num ), homingSpeed, missileSpeed )

	delaythread( 6 ) BossIntro_CleanupShips()

	//2
	result = WaitSignal( file.viper, "fireSalvo" )
	thread BossIntro_SalvoAnim( file.viper, [ ships[1] ], expect int( result.num ), homingSpeed, missileSpeed )

	//3
	result = WaitSignal( file.viper, "fireSalvo" )
	thread BossIntro_SalvoAnim( file.viper, [ ships[0] ], expect int( result.num ), homingSpeed, missileSpeed )

	//all
	result = WaitSignal( file.viper, "fireSalvo" )
	thread BossIntro_SalvoAnim( file.viper, ships, expect int( result.num ), homingSpeed, missileSpeed )
}

void function BossIntro_SalvoAnim( entity viper, array<ShipStruct> ships, int num, float homingSpeedScalar = 1.0, float missileSpeedScalar = 1.0 )
{
	//EmitSoundOnEntity( file.player, "northstar_rocket_fire" )
	entity weapon 		= viper.GetOffhandWeapon( 0 )

	vector offset = <0,0,0>

	for( int i = 0; i < num; i++ )
	{
		int burstIndex = i
		int targetIndex = i%ships.len()
		entity target = ships[targetIndex].model

		if ( IsValid( target ) )
			thread OnWeaponScriptAttack_s2s_BossIntro( weapon, burstIndex, target, offset, homingSpeedScalar, missileSpeedScalar )
		wait 0.1
	}
}

void function BossIntro_CoreAlarm()
{
	WaitSignal( file.viper, "coreAlarm" )

	//play tell warning sound and fx
	EmitSoundOnEntity( file.player, "northstar_rocket_warning" )
	SetCoreEffect( file.viper, CreateCoreEffect, VIPER_CORE_EFFECT )
	thread ViperKillCoreFx( file.viper, 2.0 )
}

void function BossIntro_Behavior_DeathAnim( ShipStruct ship )
{
	LocalVec origin = WorldToLocalOrigin( ship.model.GetOrigin() )
	SetOriginLocal( ship.mover, origin )
	ship.localVelocity.v = file.playerWidow.localVelocity.v
	ship.model.ClearParent()
	if ( ship.model != ship.mover )
		ship.model.SetParent( ship.mover, "REF", false, 0 )

	thread BossIntro_Behavior_DeathAnimThread( ship )
}

void function BossIntro_Behavior_DeathAnimThread( ShipStruct ship )
{
	Signal( ship, "FakeDeath" )
	EndSignal( ship, "FakeDestroy" )

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )
	entity enemy = ship.chaseEnemy

	entity fxRef = GoblinDeathFx( ship )

	OnThreadEnd(
	function() : ( ship, fxRef )
		{
			if ( IsValid( fxRef ) )
				fxRef.Destroy()

			ExplodeGoblin( ship )

			if ( IsValid( ship.model ) )
				SetCustomSmartAmmoTarget( ship.model, false )
		}
	)

	SetMaxSpeed( ship, ship.defSpeedMax * 3, 1.5 )
	SetMaxAcc( ship, ship.defAccMax * 3, 1.5 )

	entity noFollowTarget = null

	float x = 6000
	float y = 2000
	float z = -9000

	float rightOfTarget = GetBestRightOfTargetForLeaving( ship )
	LocalVec pos = CLVec( GetOriginLocal( mover ).v + < x * rightOfTarget, y, z > )
	vector offset = <0,0,0>
	thread __ShipFlyToPosInternal( ship, noFollowTarget, pos, offset, CONVOYDIR )

	ship.goalRadius = 3000
	WaitSignal( ship, "Goal" )
}

void function BossIntroCustomNothing( ShipStruct ship )
{
	Signal( ship, "NewFlyStyle" )
	EndSignal( ship, "NewFlyStyle" )
	EndSignal( ship, "FakeDestroy" )
	EndSignal( ship, "FakeDeath" )

	ship.mover.NonPhysicsStop()

	WaitForever()
}

void function BossIntro_CleanupShips()
{
	foreach ( ship in file.dropships[ TEAM_MILITIA ] )
	{
		if ( IsShipOnBattleField( ship ) )
			thread SetBehavior( ship, eBehavior.DEATH_ANIM )
	}

	file.sarahTitan.Destroy()
	DisableScript( "scr_swidow_node_0" )
	FakeDestroy( file.sarahWidow )
	FakeDestroy( file.crow64 )
}

void function BossIntro_BTPoint( entity bt )
{
	bt.Anim_ScriptedPlay( "bt_s2s_widow_point" )
	WaittillAnimDone( bt )
	bt.Anim_ScriptedPlay( "bt_s2s_widow_idle" )
}

void function BossIntro_BTCombatIdle( entity bt )
{
	entity link = GetEntByScriptName( "pWidowBtNode" )
	entity node = link.GetParent()
	vector angles = AnglesCompose( link.GetLocalAngles(), <0,135,0> )
	link.ClearParent()
	link.SetAngles( angles )
	link.SetParent( node, "", true, 0 )
	bt.SetParent( link, "REF", false, 0 )
	bt.Anim_ScriptedPlay( "bt_s2s_widow_combat_idle" )
}

void function BossIntro_ConnectBarkerShip()
{
	//CONNECT TO BARKERSHIP part 1
	GetEntByScriptName( "GIBRALTAR_CHUNK_INTERIOR" ).Destroy()
	delaythread( 0.2 ) ShipIdleAtTargetPos_Teleport( file.OLA, 			V_BARKER_OLA, 		BARKER_OLA_BOUNDS )

	foreach ( ship in file.dropships[ TEAM_IMC ] )
		Ship_CleanDelete( ship )
	foreach ( ship in file.dropships[ TEAM_MILITIA ] )
	{
		if ( IsShipOnBattleField( ship ) )
			Ship_CleanDelete( ship )
	}

	file.dropships[ TEAM_MILITIA ] = []
	file.dropships[ TEAM_IMC ] = []

	MaltaReal_ShipGeoSettings()
	EnableScript( file.malta, "scr_malta_node_0" )
	thread MaltaDeck_SpawnDeckGuns()

	SetOriginLocal( file.airBattleNode, V_BARKER_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()
	thread MaltaSideGunsRandomFire()
}

void function BossIntro_BTVO( entity bt )
{
	//Airborne bogey acquired.
	waitthreadsolo PlayBTDialogue( "diag_sp_bossIntro_STS676_01_01_mcor_bt" )
}

void function BossIntro_PreventShipFromBlowingUp( ShipStruct ship )
{
	WaitSignal( ship, "FakeDeath" )
	ResetMaxPitch( ship )
	ship.model.SetInvulnerable()
}

void function BossIntro_StartIntro( entity player, entity titan, entity ref )
{
	BossTitanIntroData defaultData = GetBossTitanIntroData( titan.ai.bossCharacterName )
	defaultData.doCockpitDisplay = false
	StartBossIntro( player, titan, defaultData )

	foreach( entity p in GetPlayerArray() )
	{
		p.SetInvulnerable()
		AddCinematicFlag( p, CE_FLAG_INTRO )
		thread BossTitanPlayerView( p, titan, ref, "vehicle_driver_eyes" )
		p.DisableWeapon()
		p.Hide()
		p.FreezeControlsOnServer()
		p.SetNoTarget( true )
	}

	titan.EnableNPCFlag( NPC_IGNORE_ALL )

	// Do special player view movement
	FlagSet( "BossTitanViewFollow" )

	HideCrit( titan )
	titan.SetValidHealthBarTarget( false )
	HideName( titan )

	wait 0.5

	thread BossTitanPlayerView( player, titan, ref, "vehicle_driver_eyes" )
	svGlobal.levelEnt.Signal( "BossTitanStartAnim" )
}

void function BossIntro_EndIntro( entity player, entity titan )
{
	// Player view returns to normal
	FlagClear( "BossTitanViewFollow" )

	wait SLAMZOOM_TIME

	// Return the player screen and movement back to normal
	EndBossIntro( player, titan )

	foreach( entity p in GetPlayerArray() )
	{
		if ( HasCinematicFlag( p, CE_FLAG_INTRO ) )
		{
			p.ClearInvulnerable()
			EndBossIntro( p, titan )
			RemoveCinematicFlag( p, CE_FLAG_INTRO )
			p.UnfreezeControlsOnServer()
			ClearPlayerAnimViewEntity( p )
			p.SetInvulnerable()
		}
	}
	
	player.SetNoTarget( false )

	if ( IsValid( titan ) )
	{
		titan.Solid()
		titan.DisableNPCFlag( NPC_IGNORE_ALL )
		//AddEntityCallback_OnDamaged( titan, OnBossTitanDamaged )
		//AddTitanCallback_OnHealthSegmentLost( titan, OnBossTitanLostSegment )
		ShowName( titan )
		titan.SetValidHealthBarTarget( true )
		ShowCrit( titan )
		Signal( titan, "BossTitanIntroEnded" )
	}

	wait 2.0

	player.Show()
}

void function BossIntro_FireCore( entity viper, array<ShipStruct> ships, vector offset = <0,0,0>, float launchdelay = 1.5, float homingSpeedScalar = 1.0, float missileSpeedScalar = 1.0, int num = VIPERMAXVOLLEY )
{

	//play tell warning sound and fx
	EmitSoundOnEntity( file.player, "northstar_rocket_warning" )
	SetCoreEffect( viper, CreateCoreEffect, VIPER_CORE_EFFECT )

	thread ViperKillCoreFx( viper, launchdelay + 1.0 )
	wait launchdelay

	EmitSoundOnEntity( file.player, "northstar_rocket_widowfall_fire" )
	EmitSoundOnEntity( file.player, "scr_s2s_intro_widowfall_incoming_missles" )
	entity weapon 		= viper.GetOffhandWeapon( 0 )

	foreach ( ship in ships )
	{
		ship.model.SetMaxHealth( 1000 )
		ship.model.SetHealth( 1000 )
	}

	for( int i = 0; i < num; i++ )
	{
		int burstIndex = i

		int targetIndex = i%ships.len()//GraphCapped( i, 0, VIPERMAXVOLLEY - 1, 0, ships.len() - 1 ).tointeger()

		entity target = ships[targetIndex].model

		if ( IsValid( target ) )
			thread OnWeaponScriptAttack_s2s_BossIntro( weapon, burstIndex, target, offset, homingSpeedScalar, missileSpeedScalar )

		wait 0.1
	}

	wait 1.0
}

ShipStruct function BossIntro_SpawnBossTitan( vector delta )
{
	LocalVec origin = GetOriginLocal( file.playerWidow.mover )
	origin.v += delta

	entity spawner 	= GetEntByScriptName( "deckBossTitan" )
	entity viper 	= SpawnFromSpawner( spawner )
	viper.ai.bossTitanVDUEnabled = false

	viper.SetModel( TITAN_VIPER_SCRIPTED_MODEL )
	viper.SetSkin( 1 )
	viper.SetInvulnerable()
	viper.SetNoTarget( true )
	viper.SetNoTargetSmartAmmo( false )

	TakeAllWeapons( viper )
	viper.GiveOffhandWeapon( "sp_weapon_ViperBossRockets_s2s", 0, [ "DarkMissiles" ] )
	//viper.GiveWeapon( "mp_titanweapon_sniper", [ "BossTitanViper" ] )

	entity mover = CreateScriptMover( <0,0,0>, CONVOYDIR )
	entity link = CreateScriptMover( <0,0,0>, CONVOYDIR )
	SetOriginLocal( mover, origin )
	link.SetParent( mover, "", false, 0 )
	viper.SetParent( link, "", false, 0 )
	viper.Anim_ScriptedPlay( "s2s_viper_flight_core_idle" )

	ShipStruct viperShip
	viperShip.model = viper
	viperShip.mover = mover
	viperShip.boundsMinRatio 	= 0.5
	viperShip.defBankTime		= 0.5	//1.5
	viperShip.defAccMax 		= 300	//350
	viperShip.defSpeedMax 		= 750	//500
	viperShip.defRollMax 		= 15
	viperShip.defPitchMax 		= 3
	viperShip.FuncGetBankMagnitude = ViperBankMagnitude

	InitEmptyShip( viperShip )

	int backID 	= viper.LookupPoseParameterIndex( "move_yaw_backward" )
	viper.SetPoseParameterOverTime( backID, 45, 0.1 )

	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_BOT_THRUST" ) )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_BOT_THRUST" ) )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_TOP_THRUST" ) )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_TOP_THRUST" ) )

	file.viperShip = viperShip
	file.viper = viper

	file.viperShip.localVelocity.v = <0,500,0>
	SetMaxSpeed( 	file.viperShip,  	700 )
	SetMaxAcc( 		file.viperShip, 	300 )

	thread ShipIdleAtTargetEnt_Method2( file.viperShip, file.playerWidow.mover, BOSSINTRO_VIPER_BOUNDS, <0,0,0>, delta )

	return viperShip
}

/************************************************************************************************\

███████╗██████╗ ███████╗███████╗    ███████╗ █████╗ ██╗     ██╗
██╔════╝██╔══██╗██╔════╝██╔════╝    ██╔════╝██╔══██╗██║     ██║
█████╗  ██████╔╝█████╗  █████╗      █████╗  ███████║██║     ██║
██╔══╝  ██╔══██╗██╔══╝  ██╔══╝      ██╔══╝  ██╔══██║██║     ██║
██║     ██║  ██║███████╗███████╗    ██║     ██║  ██║███████╗███████╗
╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝

\************************************************************************************************/
void function FreeFall_Setup( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	WORLD_CENTER.SetOrigin( <0,-15000,0> )
	SetupShips_Freefall()

	SetOriginLocal( file.airBattleNode, V_BARKER_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()
	thread MaltaSideGunsRandomFire()

	delaythread( 1.5 ) FlagSet( "PlayerFallOut" )
}

void function FreeFall_Skip( entity player )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.TakeActiveWeapon()

	foreach( entity p in GetPlayerArray() )
		GivePlayerDefaultWeapons( p )

	level.nv.ShipStreaming = SHIPSTREAMING_BARKER
	level.nv.ShipTitles = SHIPTITLES_EVERYTHING
}

void function FreeFall_Main( entity player )
{
	#if DEV
		if ( !ConnectIntro() )
			return
	#endif

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	FlagWait( "PlayerFallOut" )

	level.nv.ShipStreaming = SHIPSTREAMING_BARKER
	level.nv.ShipTitles = SHIPTITLES_EVERYTHING

	file.playerWidow.triggerFallingDeath.Destroy()

	EmitSoundOnEntity( file.player, "scr_s2s_intro_widowfall" )
	thread FreeFall_VO()

	float amplitude = 10
	float frequency = 200
	float duration = 1.0
	float radius = 2048
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( player )

	entity node = CreateScriptMover( file.playerWidow.model.GetOrigin(), < 0,0,0 > )

	FullyHidePlayers()

	foreach( entity p in GetPlayerArray() )
	{
		float blendTime = 0.5
		p.SetParent( node, "REF", false, blendTime )
		p.DisableWeapon()
		TakeAllWeapons( p )
		p.ForceStand()
		Melee_Disable( p )
	}

	vector fakeGravity = <0,0,-400>//<0,0,-450>
	node.NonPhysicsMoveWithGravity( < -500,0,0>, fakeGravity )
	thread PlayFPSAnimTeleportShowProxy( player, "pt_s2s_widowfall_02", "ptpov_s2s_widowfall_02", node, "REF", ViewConeSmall )
	player.SetAnimNearZ( 4 )

	bt.ClearParent()
	bt.TakeActiveWeapon()
	bt.Anim_ScriptedPlay( "bt_s2s_widow_fall" )
	bt.EnableNPCFlag( NPC_IGNORE_ALL )

	wait 0.5

	int fxID = GetParticleSystemIndex( PLAYERWIDOWDEATHFX )
	StartParticleEffectInWorld( fxID, file.playerWidow.model.GetOrigin(), CONVOYDIR )
	FakeDestroy( file.playerWidow )

	amplitude = 5
	frequency = 200
	duration = 1.0
	radius = 2048
	shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( player )

	wait 1.6
	
	foreach( entity p in GetPlayerArray() )
		thread Freefall_ViewCone( p )

	wait 0.7

	foreach( entity p in GetPlayerArray() )
	{
		p.ClearAnimNearZ()

		GivePlayerDefaultWeapons( p )
		// p.DeployWeapon()
	}
	
	wait 2.5

	FlagSet( "FreeFall_VO_gotchakid" )

	wait 1.0

	entity nodeHack = CreateScriptMover( player.GetOrigin() + <140,140,0>, CONVOYDIR )
	file.barkership = SpawnBarkerShip()

	delaythread( 0.5 ) FreeFall_Shake()

	entity dsHack = CreatePropDynamic( DROPSHIP_MODEL )
	int eHandle = dsHack.GetEncodedEHandle()
	Remote_CallFunction_NonReplay( player, "ServerCallback_DisableDropshipLights", eHandle )
	dsHack.Hide()

	nodeHack.SetParent( node, "REF", true, 0 )
	dsHack.SetParent( nodeHack, "REF", false, 0 )
	file.barkership.model.SetParent( dsHack, "ORIGIN", false, 0 )
	dsHack.Anim_Play( "ds_barker_proxy_catch_follownode_alt" )
	dsHack.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	float time = 3.0 //anim length

	wait time

	node.NonPhysicsStop()

	SetOriginLocal( file.barkership.mover, WorldToLocalOrigin( file.barkership.model.GetOrigin() ) )
	file.barkership.mover.SetAngles( file.barkership.model.GetAngles() )
	file.barkership.model.SetParent( file.barkership.mover )
	nodeHack.Destroy()
	if ( IsValid( dsHack ) )
		dsHack.Destroy()
}

void function FreeFall_Shake()
{
	float amplitude = 3
	float frequency = 100
	float duration = 1.0 //15 min
	float radius = 8000
	entity shake = CreateShakeExpensive( file.barkership.model.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.barkership.model )
	shake.DisableHibernation()
}

void function FreeFall_SetupSarahWidow()
{
	SpawnSarahWidow()

	SpawnSarahTitan( file.sarahWidow.model.GetOrigin() )

	ResetMaxSpeed( file.sarahWidow )
	ResetMaxAcc( file.sarahWidow )
	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, 	file.barkership.mover, <0,0,0>, <0,0,0>, BARKER_WIDOW_OFFSET )
}

void function Freefall_WidowArrive()
{
	SetMaxSpeed( 	file.sarahWidow, 2000 )
	SetMaxAcc( 		file.sarahWidow, 300 )

	delaythread( 1.0 ) Enable_AfterBurner( file.sarahWidow )

	entity follow 	= file.barkership.mover
	thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, follow, <0,0,0>, <0,1000,300>, FASTBALL_WIDOW_OFFSET )

	EmitSoundOnEntityAfterDelay( file.sarahWidow.model, "amb_scr_s2s_widow_flyby_intro", 2.0 )

	file.sarahWidow.goalRadius = 200
	WaitSignal( file.sarahWidow, "Goal" )
	file.sarahWidow.goalRadius = SHIPGOALRADIUS
	delaythread( 0.5 ) Disable_AfterBurner( file.sarahWidow )

	float blendTime = 4.0

	ResetMaxSpeed( 	file.sarahWidow, blendTime )
	ResetMaxAcc( 	file.sarahWidow, blendTime )
	SetMaxPitch( 	file.sarahWidow, 10, blendTime )

	wait blendTime

	thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, follow, FASTBALL_WIDOW_BOUNDS, <0,0,0>, FASTBALL_WIDOW_OFFSET )
}

void function FreeFall_CustomTrinitySettings()
{
	file.trinity.defAccMax 				= 50 	//50
	file.trinity.defSpeedMax 			= 250 	//200
	file.trinity.defRollMax 			= 45
	file.trinity.defPitchMax 			= 15

	ResetMaxPitch( file.trinity )
	ResetMaxRoll( file.trinity )
	ResetMaxSpeed( file.trinity )
	ResetMaxAcc( file.trinity )
}

void function FreeFall_VO()
{
	//Cooper!!! BT!!!
	thread PlayDialogue( "diag_sp_gibraltar_STS108_02_01_mcor_sarah", file.player )

	FlagWait( "FreeFall_VO_gotchakid" )

	//I got you, kid!
	thread PlayDialogue( "diag_sp_widowFall_STS475_01_01_mcor_barker", file.player )
	wait 2.5

	// Brace yourself!
	thread PlayDialogue( "diag_sp_widowFall_STS475_02_01_mcor_barker", file.player )
}

void function Freefall_ViewCone( entity player )
{
	if ( !player.IsPlayer() )
		return
	player.PlayerCone_SetLerpTime( 1.0 )

	//player.PlayerCone_FromAnim()

	float minDown = 65

/*	player.PlayerCone_SetMinYaw( -1 )
	player.PlayerCone_SetMaxYaw( 1 )
	player.PlayerCone_SetMinPitch( minDown - 2 )
	player.PlayerCone_SetMaxPitch( minDown )

	wait 1.1*/
	player.PlayerCone_SetMinYaw( -65 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( minDown )
}


void function FreeFall_PlayerLands( entity player, entity land )
{
	vector nOG = HackGetDeltaToRefOnPlane( land.GetOrigin(), land.GetAngles(), player, "pt_s2s_lifeboats_land", file.barkership.model.GetUpVector() )
	land.ClearParent()
	land.SetOrigin( nOG )
	land.SetParent( file.barkership.model, "", true, 0 )
	
	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_player_land_on_barker", 0.1 )
	float blendTime = 0.0
	foreach( entity p in GetPlayerArray() )
	{
		p.SetParent( land, "REF", false, blendTime )
		p.DisableWeapon()

		p.SetAnimNearZ( 4 )
		thread PlayFPSAnimShowProxy( p, "pt_s2s_lifeboats_land", "ptpov_s2s_lifeboats_land", land, "REF", ViewConeZero, 0 )
	}

	delaythread( 0.5 ) BarkerShipShake()

	wait 0.2

	while ( player.IsInvulnerable() )
		player.ClearInvulnerable()

	float health = player.GetMaxHealth() * 0.5
	foreach( entity p in GetPlayerArray() )
	{
		if ( IsAlive( p ) )
			p.SetHealth( health.tointeger() )
	}
}

void function GivePlayerDefaultWeapons( entity player )
{
	PilotLoadoutDef pilotLoadout = GetPilotLoadoutForCurrentMapSP()

	pilotLoadout.primary 				= "mp_weapon_lmg"
	pilotLoadout.primaryMods 			= [ "holosight" ]
	pilotLoadout.secondary 				= "mp_weapon_doubletake"
	pilotLoadout.secondaryMods 			= [ "ricochet" ]

	GivePilotLoadout( player, pilotLoadout )
}


/************************************************************************************************\

 █████╗ ██╗██████╗     ██████╗  █████╗ ████████╗████████╗██╗     ███████╗
██╔══██╗██║██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██║     ██╔════╝
███████║██║██████╔╝    ██████╔╝███████║   ██║      ██║   ██║     █████╗
██╔══██║██║██╔══██╗    ██╔══██╗██╔══██║   ██║      ██║   ██║     ██╔══╝
██║  ██║██║██║  ██║    ██████╔╝██║  ██║   ██║      ██║   ███████╗███████╗
╚═╝  ╚═╝╚═╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝

\************************************************************************************************/
const AIRBATTLEMAX = 16
void function CreateAirBattle()
{
	vector bounds = file.airBattleData.bounds

	table<int,ShipStruct functionref(LocalVec ornull = 0, vector = 0, bool = 0)> SpawnFunc
	SpawnFunc[ TEAM_MILITIA ] 	<- SpawnCrowLight
	SpawnFunc[ TEAM_IMC ] 		<- SpawnGoblinLight

	for ( int mainIndex = 0; mainIndex < AIRBATTLEMAX; mainIndex++ )
	{
		vector offset = file.airBattleData.AirBattle_GetOffsetFunc( mainIndex )
		float x = RandomFloatRange( -bounds.x, bounds.x )
		float y = RandomFloatRange( -bounds.y, bounds.y )
		float z = RandomFloatRange( -bounds.z, bounds.z )
		vector spawnOffset	= offset + < x, y, z >
		int team = file.airBattleData.AirBattle_GetTeamFunc( mainIndex )

		ShipStruct ship = SpawnFunc[ team ]( CLVec( GetOriginLocal( file.airBattleNode ).v + spawnOffset ) )
		file.dropships[ team ].append( ship )

		thread ShipIdleAtTargetEnt( ship, file.airBattleNode, bounds, <0,0,0>, offset )
		thread AirBattle_HandleDeath( ship, team, file.dropships[ team ].len() - 1 )
	}

	RunAirBattle()
}

void function CreateAirBattleEnd()
{
	vector bounds = file.airBattleData.bounds

	table<int,ShipStruct functionref(LocalVec ornull = 0, vector = 0, bool = 0)> SpawnFunc
	SpawnFunc[ TEAM_MILITIA ] 	<- SpawnCrowLight
	SpawnFunc[ TEAM_IMC ] 		<- SpawnGoblinLight

	for ( int mainIndex = 0; mainIndex < AIRBATTLEMAX; mainIndex++ )
	{
		int team = file.airBattleData.AirBattle_GetTeamFunc( mainIndex )
		if ( team == TEAM_IMC )
			continue

		vector offset = file.airBattleData.AirBattle_GetOffsetFunc( mainIndex )
		float x = RandomFloatRange( -bounds.x, bounds.x )
		float y = RandomFloatRange( -bounds.y, bounds.y )
		float z = RandomFloatRange( -bounds.z, bounds.z )
		vector spawnOffset	= offset + < x, y, z >


		ShipStruct ship = SpawnFunc[ team ]( CLVec( GetOriginLocal( file.airBattleNode ).v + spawnOffset ) )
		file.dropships[ team ].append( ship )

		thread ShipIdleAtTargetEnt( ship, file.airBattleNode, bounds, <0,0,0>, offset )
		thread AirBattle_HandleDeath( ship, team, file.dropships[ team ].len() - 1 )
	}

	//RunAirBattle()
}

void function UpdateAirBattle()
{
	foreach ( team, dropships in file.dropships )
	{
		foreach ( teamIndex, ship in dropships )
		{
			if ( !IsValid( ship.model ) )
				continue
			if ( !IsShipOnBattleField( ship ) )
				continue

			int mainIndex = file.airBattleData.AirBattle_GetMainIndexFunc( teamIndex, team )
			vector offset = file.airBattleData.AirBattle_GetOffsetFunc( mainIndex )
			thread ShipIdleAtTargetEnt( ship, file.airBattleNode, file.airBattleData.bounds, <0,0,0>, offset )
		}
	}
}

void function RunAirBattle()
{
	thread AirBattle_ShootThink( TEAM_MILITIA )
	thread AirBattle_ShootThink( TEAM_IMC )
	thread AirBattle_DeathThink( TEAM_MILITIA )
	thread AirBattle_DeathThink( TEAM_IMC )
}

/*///////////////////////////////////////////////////////////////////////*/
AirBattleStruct function GetAirBattleStructMaltaDeck()
{
	AirBattleStruct airBattleData

	airBattleData.xRange 	= 2500
	airBattleData.yRange 	= 3500
	airBattleData.zRange 	= 1500

	float xBuffer 	= 700
	float yBuffer 	= 2500
	float zBuffer 	= 100
	float xBounds 	= airBattleData.xRange - xBuffer
	float yBounds 	= airBattleData.yRange - yBuffer
	float zBounds 	= airBattleData.zRange - zBuffer

	airBattleData.bounds 	= < xBounds, yBounds, zBounds >

	airBattleData.AirBattle_ReplaceShipFunc[ TEAM_MILITIA ] 	<- AirBattle_LaunchFromBehindMalta
	airBattleData.AirBattle_ReplaceShipFunc[ TEAM_IMC ] 		<- AirBattle_LaunchFromBehindMalta
	airBattleData.AirBattle_GetOffsetFunc 						= AirBattle_GetOffset_MaltaDeck
	airBattleData.AirBattle_GetTeamFunc 						= AirBattle_GetTeam_MaltaDeck
	airBattleData.AirBattle_GetMainIndexFunc 					= AirBattle_GetMainIndex_MaltaDeck

	return airBattleData
}

vector function AirBattle_GetOffset_MaltaDeck( int mainIndex )
{
	float xRange = file.airBattleData.xRange
	float yRange = file.airBattleData.yRange
	float zRange = file.airBattleData.zRange

	float xPos = 1.0
	int xTest 	= floor( mainIndex * 0.5 ).tointeger()
	if ( IsOdd( xTest) )
		xPos = -1.0

	xRange *= xPos
	int team = file.airBattleData.AirBattle_GetTeamFunc( mainIndex )
	if ( team == TEAM_IMC )
		xRange *= -1

	int yPos 	= floor( mainIndex * 0.25 ).tointeger()
	float zPos 	= 1500

	return < ( xPos * ( fabs( xRange * 2 ) + 3200 ) ) + xRange, ( yPos * yRange ) + 3000, zPos >
}

int function AirBattle_GetTeam_MaltaDeck( int mainIndex )
{
	if ( IsEven( mainIndex ) )
		return TEAM_MILITIA

	return TEAM_IMC
}

int function AirBattle_GetMainIndex_MaltaDeck( int teamIndex, int team )
{
	switch ( team )
	{
		case TEAM_IMC:
			return ( teamIndex * 2 ) + 1

		case TEAM_MILITIA:
			return ( teamIndex * 2 )
	}

	unreachable
}

/*///////////////////////////////////////////////////////////////////////*/
AirBattleStruct function GetAirBattleStructMaltaIntro()
{
	AirBattleStruct airBattleData

	airBattleData.xRange 	= 0
	airBattleData.yRange 	= 700
	airBattleData.zRange 	= 1500

	float yBuffer 	= 700
	float zBuffer 	= 100
	float xBounds 	= 4700
	float yBounds 	= airBattleData.yRange - yBuffer
	float zBounds 	= airBattleData.zRange - zBuffer

	airBattleData.bounds 	= < xBounds, yBounds, zBounds >

	airBattleData.AirBattle_ReplaceShipFunc[ TEAM_MILITIA ] 	<- AirBattle_LaunchFromTrinity
	airBattleData.AirBattle_ReplaceShipFunc[ TEAM_IMC ] 		<- AirBattle_LaunchFromMalta
	airBattleData.AirBattle_GetOffsetFunc 						= AirBattle_GetOffset_MaltaIntro
	airBattleData.AirBattle_GetTeamFunc 						= AirBattle_GetTeam_MaltaIntro
	airBattleData.AirBattle_GetMainIndexFunc 					= AirBattle_GetMainIndex_MaltaIntro

	return airBattleData
}

AirBattleStruct function GetAirBattleStructMaltaGuns()
{
	AirBattleStruct airBattleData = GetAirBattleStructMaltaIntro()
	airBattleData.AirBattle_ReplaceShipFunc[ TEAM_MILITIA ] = AirBattle_LaunchFromBehindMalta
	return airBattleData
}

AirBattleStruct function GetAirBattleStructMaltaWidow()
{
	AirBattleStruct airBattleData = GetAirBattleStructMaltaGuns()
	airBattleData.AirBattle_ReplaceShipFunc[ TEAM_IMC ] = AirBattle_LaunchFromBehindMalta
	return airBattleData
}

vector function AirBattle_GetOffset_MaltaIntro( int mainIndex )
{
	float xRange = file.airBattleData.xRange
	float yRange = file.airBattleData.yRange
	float zRange = file.airBattleData.zRange

	int yPos 	= floor( mainIndex * 0.5 ).tointeger()
	float zPos 	= ( ( ( mainIndex + 2 ) % 2 ) - 0.5 ) * 2.0

	return < 0, yPos * yRange * 2, zPos * zRange >
}

int function AirBattle_GetTeam_MaltaIntro( int mainIndex )
{
	if ( IsOdd( floor( mainIndex * 0.5 ).tointeger() ) )
		return TEAM_MILITIA

	return TEAM_IMC
}

int function AirBattle_GetMainIndex_MaltaIntro( int teamIndex, int team )
{
	switch ( team )
	{
		case TEAM_IMC:
			return ( ( teamIndex * 2 ) - ( teamIndex % 2 ) ).tointeger()

		case TEAM_MILITIA:
			return ( ( teamIndex * 2 ) + ( teamIndex % 2 ) ).tointeger()
	}

	unreachable
}

/*///////////////////////////////////////////////////////////////////////*/
void function AirBattle_LaunchFromMalta( ShipStruct ship, vector offset )
{
	entity mover = ship.mover

	entity ref = GetEntByScriptName( "launchHangardummy" )
	LocalVec origin = WorldToLocalOrigin( ref.GetOrigin() )
	vector angles = ref.GetAngles()

	SetOriginLocal( mover, origin )
	mover.SetAngles( angles )

	vector forward = AnglesToForward( angles )
	LocalVec endPos = CLVec( origin.v + ( forward * -2500 ) )

	SetMaxSpeed( ship, 4000 )
	SetMaxAcc( ship, 3000 )
	SetMaxRoll( ship, 50 )
	SetMaxPitch( ship, 0 )

	delaythread( 0.5 ) ResetMaxSpeed( ship, 1.0 )
	delaythread( 1.0 ) ResetMaxAcc( ship, 1.0 )
	delaythread( 0.5 ) ResetMaxRoll( ship, 1.0 )
	delaythread( 0.5 ) ResetMaxPitch( ship, 1.0 )

	ship.localVelocity.v = forward * 5000
	SetBankTime( ship, 0.5 )
	thread ShipFlyToPos( ship, endPos, CONVOYDIR )

	wait 1.0

	ResetBankTime( ship )
}

void function AirBattle_LaunchFromTrinity( ShipStruct ship, vector offset )
{
	entity mover = ship.mover

	entity ref = GetEntByScriptName( "trinityLaunchPoint" )
	LocalVec origin = WorldToLocalOrigin( ref.GetOrigin() )
	vector angles = ref.GetAngles()

	SetOriginLocal( mover, origin )
	mover.SetAngles( angles )

	vector forward = AnglesToForward( angles )
	vector up = AnglesToUp( angles )
	LocalVec endPos = CLVec( origin.v + ( forward * -2000 ) )
	SetMaxSpeed( ship, 2000 )
	SetMaxAcc( ship, 1000 )
	SetMaxRoll( ship, 50 )
	SetMaxPitch( ship, 0 )

	delaythread( 1.0 ) ResetMaxSpeed( ship, 1.0 )
	delaythread( 1.5 ) ResetMaxAcc( ship, 1.0 )
	delaythread( 1.0 ) ResetMaxRoll( ship, 1.0 )
	delaythread( 1.0 ) ResetMaxPitch( ship, 1.0 )

	ship.localVelocity.v = forward * 2500 + up * 500
	SetBankTime( ship, 0.5 )
	thread ShipFlyToPos( ship, endPos, CONVOYDIR )

	wait 2.0

	ResetBankTime( ship )
}

void function AirBattle_LaunchFromBehindMalta( ShipStruct ship, vector offset )
{
	ShipStruct capShip = file.malta
	entity mover = ship.mover

	LocalVec origin = WorldToLocalOrigin( capShip.model.GetOrigin() )
	origin.v += ( capShip.model.GetForwardVector() * -12000 )

	SetOriginLocal( mover, origin )

	float x = 5000
	if ( offset.x < 0 )
		x *= -1.0

	LocalVec endPos = CLVec( origin.v + <x,0,0> )

	thread ShipFlyToPos( ship, endPos )
	ship.goalRadius = 1000

	SetMaxAcc( ship, ship.defAccMax * 3 )
	SetMaxSpeed( ship, ship.defSpeedMax * 3 )

	WaitSignal( ship, "Goal" )

	delaythread( 2.9 ) ResetMaxAcc( ship, 8 )
	delaythread( 2.9 ) ResetMaxSpeed( ship, 8 )
}

void function AirBattle_Replace( int team, int teamIndex )
{
	if ( Flag( "EndAirBattle" ) )
		return
	FlagEnd( "EndAirBattle" )

	switch ( team )
	{
		case TEAM_IMC:
			FlagWaitClear( "StopAirBattleRespawns_IMC" )
			break
		case TEAM_MILITIA:
			FlagWaitClear( "StopAirBattleRespawns_MILITIA" )
			break
	}

	array<ShipStruct> ships = file.dropships[ team ]

	table<int,ShipStruct functionref(LocalVec ornull = 0, vector = 0, bool = 0)> SpawnFunc
	SpawnFunc[ TEAM_MILITIA ] 	<- SpawnCrowLight
	SpawnFunc[ TEAM_IMC ] 		<- SpawnGoblinLight

	ShipStruct ship = SpawnFunc[ team ]( CLVec( <5000,0,-20000> ) )
	file.dropships[ team ][ teamIndex ] = ship

	if ( team == TEAM_MILITIA )
		ship.model.SetScriptName( DropshipGetRandomCallsign() )

	//will not pass test for "on the battlefield" and won't fire missiles yet
	ship.free 			= true

	int mainIndex = file.airBattleData.AirBattle_GetMainIndexFunc( teamIndex, team )
	vector offset = file.airBattleData.AirBattle_GetOffsetFunc( mainIndex )

	waitthread file.airBattleData.AirBattle_ReplaceShipFunc[ team ]( ship, offset )

	thread ShipIdleAtTargetEnt( ship, file.airBattleNode, file.airBattleData.bounds, <0,0,0>, offset )
	thread AirBattle_HandleDeath( ship, team, teamIndex )

	wait 3

	//now will fire missiles
	ship.free = false
}

void function AirBattle_DEVPrint( ShipStruct ship, int teamIndex )
{
	EndSignal( ship, "FakeDestroy" )
	ship.mover.EndSignal( "OnDestroy" )

	while( 1 )
	{
		WaitFrame()

		if ( GetBugReproNum() != ship.bug_reproNum )
			continue

		DebugDrawText( ship.mover.GetOrigin() + < 0,0,200 >, "teamIndex: " + teamIndex, true, FRAME_INTERVAL )
	}
}

void function AirBattle_HandleDeath( ShipStruct ship, int team, int teamIndex )
{
	if ( Flag( "EndAirBattle" ) )
		return
	FlagEnd( "EndAirBattle" )

	EndSignal( ship, "FakeDeath" )
	EndSignal( ship, "FakeDestroy" )

	OnThreadEnd(
		function() : ( ship, team, teamIndex )
			{
				delaythread( RandomFloatRange( 5, 10 ) ) AirBattle_Replace( team, teamIndex )
				Signal( svGlobal.levelEnt, "AirBattle_ShipDied" )
			}
		)

	#if DEV
		thread AirBattle_DEVPrint( ship, teamIndex )
	#endif

	ship.mover.WaitSignal( "OnDestroy" )
}

void function AirBattle_DeathThink( int team, int lastIndex = 0 )
{
	if ( Flag( "EndAirBattle" ) )
		return
	FlagEnd( "EndAirBattle" )

	switch ( team )
	{
		case TEAM_IMC:
			FlagWaitClear( "StopAirBattleDeaths_IMC" )
			break

		case TEAM_MILITIA:
			FlagWaitClear( "StopAirBattleDeaths_MILITIA" )
			break
	}

	table<string,int> e
	e.lastIndex <- lastIndex

	EndSignal( svGlobal.levelEnt, "AirBattle_ShipDied" )
	switch ( team )
	{
		case TEAM_IMC:
			FlagEnd( "StopAirBattleDeaths_IMC" )
			break

		case TEAM_MILITIA:
			FlagEnd( "StopAirBattleDeaths_MILITIA" )
			break
	}

	OnThreadEnd(
	function() : ( team, e )
		{
			//recursive -> delaythread so debugger doesn't freak out on reloads
			delaythread( 0.25 ) AirBattle_DeathThink( team, e.lastIndex )
		}
	)

	wait RandomFloatRange( 10, 20 )

	int teamIndex = 0
	array<ShipStruct> ships = file.dropships[ team ]
	while( 1 )
	{
		WaitFrame()

		teamIndex = RandomInt( ships.len() )
		if ( teamIndex == lastIndex )
			continue
		if ( !IsValid( ships[ teamIndex ].model ) )
			continue
		if ( !IsShipOnBattleField( ships[ teamIndex ] ) )
			continue

		break
	}

	e.lastIndex = teamIndex
	ShipStruct ship = ships[ teamIndex ]

	if ( CoinFlip() )
		thread SetBehavior( ship, eBehavior.DEATH_ANIM )
	else
		ExplodeGoblin( ship )
}

void function AirBattle_ShootThink( int team )
{
	if ( Flag( "EndAirBattle" ) )
		return
	FlagEnd( "EndAirBattle" )

	if ( Flag( "MaltaDeckClear" ) )
		return
	FlagEnd( "MaltaDeckClear" )

	vector dir 		= < 1, 0, 0 >
	vector offset 	= < 100, 32, -64 >
	entity weapon 	= file.rocketDummy[ team ].GetActiveWeapon()

	array<int> indices = []
	for ( int i = 0; i < file.dropships[ team ].len(); i++ )
		indices.append( i )

	while( 1 )
	{
		indices.randomize()
		foreach( index in indices )
		{
			if ( Flag( "BridgeClear" ) )
				wait RandomFloatRange( 0.5, 0.6 )
			else
				wait RandomFloatRange( 0.3, 0.4 )

			ShipStruct ship = file.dropships[ team ][ index ]

			if ( !IsValid( ship.model ) )
				continue
			if ( !IsShipOnBattleField( ship ) )
				continue
			if ( !ship.allowShoot )
				continue

			WeaponPrimaryAttackParams attackParams

			//make sure imc always fires away from malta, mcor fires at malta
			vector rightVec = ship.model.GetRightVector()
			vector testVec = Normalize( file.malta.mover.GetOrigin() - ship.model.GetOrigin() )
			float sign = 1.0
			if ( team == TEAM_IMC )
				sign *= -1
			if ( DotProduct( rightVec, testVec ) < 0  )
				sign*= -1

			vector x = rightVec * offset.x * sign
			vector y = ship.model.GetForwardVector() * offset.y
			vector z = ship.model.GetUpVector() * offset.z
			vector origin = ship.model.GetOrigin() + x + y + z

			//weapon.SetAbsOrigin( origin )
			attackParams.pos = origin
			attackParams.dir = dir * sign
			OnWeaponPrimaryAttack_swarm_rockets_s2s( weapon, attackParams )
		}
		WaitFrame()
	}
}

/************************************************************************************************\

██████╗  █████╗ ██████╗ ██╗  ██╗███████╗██████╗ ███████╗██╗  ██╗██╗██████╗
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗██╔════╝██║  ██║██║██╔══██╗
██████╔╝███████║██████╔╝█████╔╝ █████╗  ██████╔╝███████╗███████║██║██████╔╝
██╔══██╗██╔══██║██╔══██╗██╔═██╗ ██╔══╝  ██╔══██╗╚════██║██╔══██║██║██╔═══╝
██████╔╝██║  ██║██║  ██║██║  ██╗███████╗██║  ██║███████║██║  ██║██║██║
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝

\************************************************************************************************/
void function BarkerShip_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-19000,0> )
	SetupShips_Barker()

	SetOriginLocal( file.airBattleNode, V_BARKER_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()
	thread MaltaSideGunsRandomFire()
}

void function BarkerShip_Skip( entity player )
{
	DriftWorldSettingsReset()

	bool skipping = true
	OlaReal_ShipGeoSettings( skipping )

	level.nv.ShipTitles = SHIPTITLES_NOBARKER
	FlagSet( "StartFastball1" )
}

void function MaltaReal_ShipGeoSettings( bool skipping = false )
{
	if ( skipping )
		Ship_SkyboxToWorld( file.malta )
	else
		Ship_SkyboxToWorldInstant( file.malta )

	ShipGeoShow( file.malta, "GEO_CHUNK_EXTERIOR_L" )
	ShipGeoShow( file.malta, "GEO_CHUNK_EXTERIOR_R" )
	ShipGeoShow( file.malta, "GEO_CHUNK_HANGAR_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_DECK_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_BACK" )
	ShipGeoShow( file.malta, "GEO_CHUNK_EXTERIOR_ENGINE" )

	file.malta.lifts[ REALDRONELIFT ][0].doorTopC.Show()
	file.malta.lifts[ REALDRONELIFT ][0].doorTopS.Show()

	GetEntByScriptName( "maltaGunTurret1" ).Show()
	GetEntByScriptName( "maltaGunTurret2" ).Show()
	GetEntByScriptName( "maltaGunTurret3" ).Show()
}

void function OlaReal_ShipGeoSettings( bool skipping = false )
{
	if ( skipping )
		Ship_SkyboxToWorld( file.OLA )
	else
		Ship_SkyboxToWorldInstant( file.OLA )

	ShipGeoShow( file.OLA, 	"DRACONIS_CHUNK_LOWDEF" )
	Objective_SetSilent( "#S2S_OBJECTIVE_BOARDDRACONIS", <0,0,0>, file.OLA.model )
}

void function Barkership_Main( entity player )
{
	//CONNECT TO BARKERSHIP part 2
	{
		FreeFall_CustomTrinitySettings()
		ShipGeoShow( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )
		thread TrinityHangarDoorsOpen( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2", true )
		thread TrinityHangarDoorsOpen( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1", true )
		delaythread( 0.2 ) ShipIdleAtTargetPos_Teleport( file.trinity,		V_BARKER_TRINITY, 	BARKER_TRINITY_BOUNDS )

		ResetMaxSpeed( file.barkership )
		ResetMaxAcc( file.barkership )
		SetMaxRoll( file.barkership, 20 )
		delaythread( 0.2 ) ShipIdleAtTargetPos_Teleport( file.barkership,	V_BARKER_BARKER1A, 	<0,0,0> )
		delaythread( 1.5 ) ShipIdleAtTargetPos( file.barkership,	V_BARKER_BARKER1B, 	<0,0,0> )

		ResetMaxSpeed( file.gibraltar )
		ResetMaxAcc( file.gibraltar )
		delaythread( 0.2 ) ShipIdleAtTargetPos_Teleport( file.gibraltar, 	V_BARKER_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )

		Ship_CleanDelete( file.crow64 )
		Ship_CleanDelete( file.viperShip )
		if ( IsValid( file.viper ) )
			file.viper.Show()

		CleanupScript( "scr_pwidow_node_0" )

		delaythread( 1.0 ) FreeFall_SetupSarahWidow()

		file.crow64 	= SpawnCrow64()
		ResetMaxSpeed( file.crow64 )
		ResetMaxAcc( file.crow64 )
		ShipIdleAtTargetPos_Teleport( file.crow64, 		V_BARKER_CROW, 	BARKER_CROW_BOUNDS )
		thread Barkership_CrowSeatedAnims()

		DriftWorldSettingsReset()

		level.nv.ShipTitles = SHIPTITLES_NOBARKER
	}

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.SetVelocity( <0,0,500> )

	entity land = GetEntByScriptName( "lew_pt_land" )
	entity btLand = GetEntByScriptName( "lew_bt_land" )

	StopMusic()
	PlayMusic( "music_s2s_01_briefing" )

	thread FreeFall_PlayerLands( player, land )
	thread Barkership_VO()

	wait 2

	bt.SetParent( btLand, "REF", false, 0 )
	thread PlayAnimTeleport( bt, "bt_s2s_fall_to_kneel", btLand, "REF" )

	wait 0.4

	float amplitude = 20
	float frequency = 200
	float duration = 1.0
	float radius = 2048
	entity shake = CreateShake( player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( player )

	OlaReal_ShipGeoSettings()

	thread BarkerShip_PlayerAnim( player, land )

	wait 3.36
	thread PlayAnim( file.sarahTitan, "bt_widow_barker_Sarah_idle1", file.sarahWidow.model, "ORIGIN" )
	thread Barkership_flybys()
	thread Freefall_WidowArrive()

	WaittillAnimDone( bt )

	entity engines = GetEntByScriptName( "amb_emit_s2s_Malta_Thrusters" )
	Assert( IsValid( engines ) )
	EmitSoundOnEntity( engines, "amb_emit_s2s_Malta_Thrusters" )

	OnThreadEnd(
	function() : (  )
		{
			ResetMaxSpeed( file.barkership, 0.5 )
			ResetMaxAcc( file.barkership, 0.5 )
		}
	)

	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.SetNoTarget( true )

	//is BT ok dialogue
	WaitFrame()
	bt.Anim_ScriptedPlay( "bt_s2s_post_jump_idle" )
	thread BarkerShip_BTAnimatesToEnd( bt )

	wait 0.5

	//move the barkership up
	SetMaxSpeed( file.barkership, 100, 0.5 )
	SetMaxAcc( file.barkership, 25, 0.5 )
	SetMaxPitch( file.barkership, 10 )
	thread ShipIdleAtTargetPos( file.barkership, 	V_BARKER_BARKER2, 	BARKER_BARKER_BOUNDS )
	delaythread( 4 ) ShipIdleAtTargetPos( file.crow64, 		V_BARKER_CROW, 		<0,0,0> )

	wait 1.5

	//Battleship Malta at 10 o'clock, guarding the Draconis! We can't get past it!
	waitthreadsolo PlayDialogue( "diag_sp_widowFall_STS130_11_01_mcor_sarah", player )

	thread BarkerShip_CrowMovement()

	thread Barkership_SarahAnim1()

	// now we spawn the respawn ship somewhere
	LocalVec org = WorldToLocalOrigin( file.barkership.mover.GetOrigin() )
	org.v += <0,-2000,-1000>

	SpawnRespawnWidow( org )

	thread ShipIdleAtTargetEnt_Method2( file.respawnWidow, file.barkership.mover, <0,0,0>, <0,0,0>, <500,-1500,500> )
	WidowAnimateOpen( file.respawnWidow, "left" )

	//Cooper, I need a Pilot on board the Malta to secure the deck now!
	waitthreadsolo PlayDialogue( "diag_sp_barkerShip_STS151_11_01_mcor_sarah", player )
	ResetMaxSpeed( file.barkership, 1.0 )
	ResetMaxAcc( file.barkership, 1.0 )

	Objective_Set( "#S2S_OBJECTIVE_TAKECONTROL1", <0,0,0>, file.malta.model )

	wait 1.0
	//Commander Briggs, this is Blackbird Six-Four - we can get him there. BT - we need a fastball.
	waitthreadsolo PlayDialogue( "diag_sp_barkerShip_STS151_12_01_mcor_CrowCptn", player )
	wait 0.2

	thread Barkership_EnderVO( player, bt )

	ResetMaxPitch( file.barkership )
	
	// move the respawn ship
	ShipFlyToPos( file.respawnWidow, WorldToLocalOrigin( file.barkership.mover.GetOrigin() + < 0,1000,600> ) )
	Enable_AfterBurner( file.respawnWidow )
}

void function BarkerShip_PlayerAnim( entity player, entity land )
{
	file.barkership.triggerFallingDeath.Disable()

	foreach( entity p in GetPlayerArray() )
	{
		if ( IsValid( p ) && p != player )
		{
			p.ClearAnimNearZ()
			thread PlayFPSAnimShowProxy( p, "pt_s2s_end_fight_knockback", "ptpov_s2s_end_fight_knockback", land, "REF", ViewConeZero, 0 )
		}
	}

	player.ClearAnimNearZ()
	waitthread PlayFPSAnimShowProxy( player, "pt_s2s_end_fight_knockback", "ptpov_s2s_end_fight_knockback", land, "REF", ViewConeZero, 0 )

	entity node = player.GetParent()
	foreach( entity p in GetPlayerArray() )
	{
		p.ClearParent()
		p.UnforceStand()
		p.Anim_Stop()
		p.Signal( "ScriptAnimStop" )
		p.Signal( "FlightPanelAnimEnd" )
		ClearPlayerAnimViewEntity( p )
		p.DeployWeapon()
		Melee_Enable( p )
	}
	CheckPoint_ForcedSilent()

	if ( IsValid( node ) )
		node.Destroy()
	
	FullyShowPlayers()
}

void function Barkership_SarahAnim1()
{
	waitthread PlayAnim( file.sarahTitan, "bt_widow_barker_Sarah_talk1", file.sarahWidow.model, "ORIGIN" )
	thread PlayAnim( file.sarahTitan, "bt_widow_barker_Sarah_idle2", file.sarahWidow.model, "ORIGIN" )
}

void function Barkership_SarahAnim2()
{
	waitthread PlayAnim( file.sarahTitan, "bt_widow_barker_Sarah_talk2", file.sarahWidow.model, "ORIGIN" )
	if ( IsAlive( file.sarahTitan ) )
		thread PlayAnim( file.sarahTitan, "bt_widow_side_idle_end_Sarah", file.sarahWidow.model, "ORIGIN" )
}

void function Barkership_SarahLeave()
{
	//if safe to close
	while( 1 )
	{
		FlagWaitClear( "PlayerInOrOnSarahWidow" )

		float blendTime = 2.0
		ResetMaxPitch( file.sarahWidow, blendTime )
		ResetMaxSpeed( file.sarahWidow, blendTime )
		ResetMaxAcc( file.sarahWidow, blendTime )
		thread ShipIdleAtTargetPos( file.sarahWidow, 	V_MALTAINTRO_WIDOW, 	MALTAINTRO_WIDOW_BOUNDS )

		wait 4.0

		if ( Flag( "PlayerInOrOnSarahWidow" ) )
		{
			thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.barkership.mover, FASTBALL_WIDOW_BOUNDS, <0,0,0>, FASTBALL_WIDOW_OFFSET )
			continue
		}

		waitthread WidowAnimateClose( file.sarahWidow, "left" )

		if ( Flag( "PlayerInOrOnSarahWidow" ) )
		{
			thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.barkership.mover, FASTBALL_WIDOW_BOUNDS, <0,0,0>, FASTBALL_WIDOW_OFFSET )
			waitthread WidowAnimateOpen( file.sarahWidow, "left" )
			continue
		}

		break
	}

	file.sarahTitan.Destroy()
}

void function Crow64_CreatePilot()
{
	entity guy = CreateSoldier( TEAM_MILITIA, file.crow64.model.GetOrigin(), file.crow64.model.GetAngles() )
	DispatchSpawn( guy )

	guy.SetParent( file.crow64.model, "ORIGIN" )
	thread PlayAnim( guy, "Militia_flyinA_idle_mac", file.crow64.model, "ORIGIN")

	FlagWait( "PlayerInDroneRoom" )

	guy.Destroy()
}

void function BarkerShip_CrowMovement()
{
	wait 0.5

	entity follow 	= file.barkership.mover
	vector delta 	= <0,0,0>
	vector bounds 	= <0,0,0>
	SetMaxSpeed( file.crow64, 1500, 0.5 )
	SetMaxAcc( file.crow64, 250, 0.5 )

	thread ShipIdleAtTargetEnt_Method2( file.crow64, follow, bounds, delta, FASTBALL_CROW_OFFSET1a )
	float delay = 3.5
	EmitSoundOnEntityAfterDelay( file.crow64.model, "amb_scr_s2s_crow_flight_lp_01", delay )
	EmitSoundOnEntityAfterDelay( file.crow64.model, "amb_scr_s2s_crow_flyby_01", delay )

	file.crow64.goalRadius = 500
	WaitSignal( file.crow64, "Goal" )
	file.crow64.goalRadius = SHIPGOALRADIUS

	BarkerShip_CrowMovementFinal()
}

void function BarkerShip_CrowMovementFinal( bool teleport = false )
{
	entity follow 	= file.barkership.mover
	vector delta 	= <0,0,0>
	SetMaxSpeed( file.crow64, 500, 2 )
	SetMaxAcc( file.crow64, 250, 2 )

	if ( teleport )
		ShipIdleAtTargetEnt_M2_Teleport( file.crow64, follow, FASTBALL_CROW_BOUNDS, delta, FASTBALL_CROW_OFFSET1b )
	else
		thread ShipIdleAtTargetEnt_Method2( file.crow64, follow, FASTBALL_CROW_BOUNDS, delta, FASTBALL_CROW_OFFSET1b )
}

void function Barkership_CrowSeatedAnims()
{
	thread DropshipAnimateOpen( file.crow64, "right" )

	string tag = "ORIGIN"
	entity model = file.crow64.model
	int attachID = model.LookupAttachment( tag )
	vector origin = model.GetAttachmentOrigin( attachID ) + ( model.GetRightVector() * 42 ) + ( model.GetUpVector() * -4 )
	vector angles = model.GetAngles()
	entity node = CreateScriptMover( origin, angles )
	node.SetParent( model, tag, true, 0 )

	file.bear.SetParent( node, "REF", false, 0 )
	file.gates.SetParent( node, "REF", false, 0 )
	file.davis.SetParent( node, "REF", false, 0 )
	file.droz.SetParent( node, "REF", false, 0 )

	file.bear.Anim_ScriptedPlay( "pt_ds_side_intro_gen_idle_B" )
	file.gates.Anim_ScriptedPlay( "pt_ds_side_intro_gen_idle_A" )
	file.davis.Anim_ScriptedPlay( "pt_ds_side_intro_gen_idle_C" )
	file.droz.Anim_ScriptedPlay( "pt_ds_side_intro_gen_idle_D" )

	FlagWait( "MaltaIntroFlyOver" )

	Assert( file.bear.GetParent() != node )
	Assert( file.gates.GetParent() != node )
	Assert( file.davis.GetParent() != node )
	Assert( file.droz.GetParent() != node )
	node.Destroy()
}

void function Barkership_VO()
{
	wait 4.0

	//Barker. Nice of you to show up.
	thread PlayDialogue( "diag_sp_adds_STS801_02_01_mcor_sarah", file.player )
	wait 2.0

	//You're welcome.
	waitthreadsolo PlayDialogue( "diag_sp_widowFall_STS123_13_01_mcor_barker", file.player )
}

void function Barkership_flybys()
{
	FlagSet( "StopAirBattleDeaths_IMC" )
	FlagSet( "StopAirBattleDeaths_MILITIA" )

	int indexG, indexC
	ShipStruct goblin
	ShipStruct crow

	foreach( index, ship in file.dropships[ TEAM_IMC ] )
	{
		if ( !IsShipOnBattleField( ship ) )
			continue
		if ( !IsValid( ship.model ) )
			continue
		goblin = ship
		indexG = index
		break
	}

	foreach( index, ship in file.dropships[ TEAM_MILITIA ] )
	{
		if ( !IsShipOnBattleField( ship ) )
			continue
		if ( !IsValid( ship.model ) )
			continue
		crow = ship
		indexC = index
		break
	}

	LocalVec originG = WorldToLocalOrigin( file.player.GetOrigin() )
	LocalVec originC

	originG.v += < -1300,-7000,650 >
	originC.v = originG.v + <0,-10000,0>

	goblin.mover.NonPhysicsStop()
	crow.mover.NonPhysicsStop()
	SetOriginLocal( goblin.mover, originG )
	SetOriginLocal( crow.mover, originC )
	goblin.mover.SetAngles( < 0,90,60 > )
	crow.mover.SetAngles( < 0,90,50 > )

	float mag = 10
	float speed = 500 * mag
	float acc = 100 * mag
	goblin.localVelocity.v = <0,speed,0>
	crow.localVelocity.v = <0,speed,0>
	SetMaxSpeed( goblin, speed )
	SetMaxSpeed( crow, speed )
	SetMaxAcc( goblin, acc )
	SetMaxAcc( crow, acc )
	SetMaxPitch( goblin, 0 )
	SetMaxPitch( crow, 0 )

	float dist = 35000
	originG.v += <0,dist,0>
	originC.v += <0,dist,0>
	thread ShipFlyToPos( goblin, originG, < 0,90,30 > )
	thread ShipFlyToPos( crow, originC, < 0,90,20 > )

	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_barker_first_crow_flyby_fast", 0.1 )
	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_barker_second_crow_flyby_fast", 1.7 )

	wait 1.5

	float amplitude = 3
	float frequency = 200
	float duration = 1.0
	float radius = 6000
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	wait 1
	shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )

	goblin.goalRadius = 500
	WaitSignal( goblin, "Goal" )

	goblin.goalRadius = SHIPGOALRADIUS

	int mainIndex = file.airBattleData.AirBattle_GetMainIndexFunc( indexG, TEAM_IMC )
	vector offset = file.airBattleData.AirBattle_GetOffsetFunc( mainIndex )
	thread ShipIdleAtTargetEnt( goblin, file.airBattleNode, file.airBattleData.bounds, <0,0,0>, offset )

	mainIndex = file.airBattleData.AirBattle_GetMainIndexFunc( indexC, TEAM_MILITIA )
	offset = file.airBattleData.AirBattle_GetOffsetFunc( mainIndex )
	thread ShipIdleAtTargetEnt( crow, file.airBattleNode, file.airBattleData.bounds, <0,0,0>, offset )

	delaythread( 4.0 ) ResetMaxSpeed( goblin, 3 )
	delaythread( 4.0 ) ResetMaxSpeed( crow, 3 )
	delaythread( 4.0 ) ResetMaxAcc( goblin, 3 )
	delaythread( 4.0 ) ResetMaxAcc( crow, 3 )
	ResetMaxPitch( goblin )
	ResetMaxPitch( crow )

	FlagClear( "StopAirBattleDeaths_IMC" )
	FlagClear( "StopAirBattleDeaths_MILITIA" )
}

void function Barkership_EnderVO( entity player, entity bt )
{
	OnThreadEnd(
	function() : (  )
		{
			thread Barkership_SarahLeave()
			delaythread( 3.0 ) FlagClear( "Barkership_EnderVO" )
		}
	)

	FlagSet( "Barkership_EnderVO" )

	if ( Flag( "PlayerInOrOnCrow64" ) )
		return
	FlagEnd( "PlayerInOrOnCrow64" )

	//Copy that Six-Four.
	waitthreadsolo PlayBTDialogue( "diag_sp_barkerShip_STS151_13_01_mcor_bt" )
	wait 0.25

	if ( Flag( "Fastball_PickedUpPlayer" ) )
		return
	FlagEnd( "Fastball_PickedUpPlayer" )

	delaythread( 0.6 ) Barkership_SarahAnim2()

	//You can do this, Pilot.
	waitthreadsolo PlayBTDialogue( "diag_sp_barkerShip_STS151_14_01_mcor_bt" )
	wait 0.25
	//Let's do it! Cooper, get ready!
	thread PlayDialogue( "diag_sp_barkerShip_STS153_01_01_mcor_sarah", player )

	wait 1.5
}

void function BarkerShip_BTAnimatesToEnd( entity bt )
{
	waitthread PlayAnim( bt, "bt_s2s_post_jump_briefing", bt.GetParent() )

	entity node = GetEntByScriptName( "lew_bt_point" )
	bt.SetParent( node )

	thread PlayAnimTeleport( bt, "bt_s2s_post_jump_briefing_idle2", node )
	FlagSet( "StartFastball1" )
}

void function AnimCallback_ParentBeforeAnimating( entity guy )
{
	entity node = guy.ai.carryBarrel
	guy.SetParent( node )
}

void function BarkerShipShake()
{
	float amplitude = 0.75
	float frequency = 50
	float duration = 900 //15 min
	float radius = 8000
	entity shake = CreateShakeExpensive( file.barkership.model.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.barkership.model )
	shake.DisableHibernation()

	#if DEV
		if ( GetBugReproNum() == 1 )
			DebugDrawCircleOnEnt( shake, 64, 255, 255, 255, 60 )
	#endif

	FlagWait( "FastBallLaunched" )

	thread KillShake( shake )
}

/************************************************************************************************\

███████╗ █████╗ ███████╗████████╗██████╗  █████╗ ██╗     ██╗          ██╗
██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██║     ██║         ███║
█████╗  ███████║███████╗   ██║   ██████╔╝███████║██║     ██║         ╚██║
██╔══╝  ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║██║     ██║          ██║
██║     ██║  ██║███████║   ██║   ██████╔╝██║  ██║███████╗███████╗     ██║
╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝     ╚═╝

\************************************************************************************************/
void function Fastball_1_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-20000,0> )
	SetupShips_Fastball1()

	entity engines = GetEntByScriptName( "amb_emit_s2s_Malta_Thrusters" )
	Assert( IsValid( engines ) )
	EmitSoundOnEntity( engines, "amb_emit_s2s_Malta_Thrusters" )

	SetOriginLocal( file.airBattleNode, V_BARKER_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()
	thread MaltaSideGunsRandomFire()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	entity node = GetEntByScriptName( "lew_bt_point" )
	player.SetOrigin( node.GetOrigin() + ( node.GetForwardVector() * -400 ) + <0,0,64> )

	bt.SetOrigin( node.GetOrigin() )
	bt.SetAngles( <0,0,0> )
	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.SetNoTarget( true )

	StopMusic()
	PlayMusic( "music_s2s_01_briefing" )

	delaythread( 0.25 ) PlayAnim( bt, "bt_s2s_post_jump_briefing_idle2", node )
}

void function Fastball_1_Skip( entity player )
{
	level.nv.ShipStreaming = SHIPSTREAMING_MALTA
}

void function Fastball_1_Main( entity player )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	if ( Flag( "PlayerInOrOnCrow64" ) )
	{
		thread BT_WaitOnBarkerShip( bt )
		return
	}
	FlagEnd( "PlayerInOrOnCrow64" )

	OnThreadEnd(
	function() : ( bt )
		{
			if ( !Flag( "Fastball_PickedUpPlayer" ) )
				thread BT_WaitOnBarkerShip( bt )
		}
	)

	CheckPoint()

	wait 0.5
	FlagWait( "StartFastball1" )

	entity node = GetEntByScriptName( "lew_bt_point" )
	entity throwNode = CreateScriptMover( node.GetOrigin(), node.GetAngles() )
	throwNode.SetParent( file.barkership.model, "", true, 0 )

	// BT Gets ready to throw the player

	float x = 0
	float y = -64
	float z = 95
	entity model 	= file.crow64.model
	vector up 		= model.GetUpVector()
	vector forward 	= model.GetForwardVector()
	entity target 	= CreateScriptMover()
	target.SetOrigin( model.GetOrigin() + ( forward * y ) + ( up * z ) )
	target.SetParent( model, "", true, 0.0 )

	SetFastballAnims( "bt_s2s_post_jump_briefing_2_fastball", "bt_s2s_post_jump_fastball_idle", "bt_s2s_post_jump_fastball_end", "ptpov_s2s_fastball_throw_end", "pt_s2s_fastball_throw_end" )
	SetFastballVars( throwNode, GetMovingTargetFastballVelocity )

	thread FastBall_VO( player, bt )
	thread ScriptedTitanFastball( player, bt, throwNode, target )
	thread Fastball_DoObj( bt )

	WaitSignal( bt, "FastballStarting" )
	FlagSet( "Fastball_PickedUpPlayer" )

	FullyHidePlayers()

	ClearShipEventCallback( file.crow64, eShipEvents.PLAYER_ONHULL_START, Crow64PlayerOnHullStart )
	ClearShipEventCallback( file.crow64, eShipEvents.PLAYER_ONHULL_END, Crow64PlayerOnHullEnd )
	FlagClear( "PlayerInOrOnCrow64" )

	thread FastBall_GoodLuckVO( bt )

	Objective_Hide( file.player )
	WaitFrame()
	Objective_SetSilent( "#S2S_OBJECTIVE_FASTBALL1" )
	entity marker = Objective_GetMarkerEntity()
	marker.ClearParent()

	file.barkership.triggerFallingDeath.Destroy()

	HideName( file.bear )
	HideName( file.gates )
	HideName( file.droz )
	HideName( file.davis )

	//move the barker ship back and the crow into position
	FlagClear( "DriftWorldCenter" ) //do this before the release so the duration is accurate
	thread Fastball_1_CrowFlightPath( file.crow64, player, bt, target )
	thread ShipIdleAtTargetPos( file.barkership, 	V_FASTBALL_BARKER, 	BARKER_BARKER_BOUNDS )

	float time = 15
	NonPhysicsMoveToLocal( file.airBattleNode, V_MALTAINTRO_AIRBATTLE, time, time * 0.5, time * 0.5 )

	WaitSignal( bt, "fastball_release" )
	FlagSet( "FastBallLaunched" )

	EmitSoundOnEntity( player, "scr_s2s_fastball_whoosh_to_crow" )

	delaythread( 0.2 ) BT_WaitOnBarkerShip( bt )

	//wait for the player to be close
	float blendTime = 0.1
	waitthread BlackholePlayerToShip( player, target, blendTime )

	if ( !IsAlive( player ) )
		WaitForever()

	thread Crow64Shake()

	#if DEV
		if ( GetMoDevState() )
		{
			thread Fastball_TrackTarget( player, target )
		}
	#endif

	vector angles = AnglesCompose( file.crow64.model.GetAngles(), player.GetAngles() - CONVOYDIR )
	vector nOG = HackGetDeltaToRefOnPlane( target.GetOrigin(), player.GetAngles(), player, "pt_s2s_lifeboats_land", model.GetUpVector() )
	node = CreateScriptMover( nOG, angles )
	node.SetParent( file.crow64.model, "", true, 0 )
	foreach( entity p in GetPlayerArray() )
	{
		player.SetParent( node, "REF", false, blendTime )
		player.DisableWeapon()
		player.ForceStand()
	}

	StopMusic()
	PlayMusic( "music_s2s_02_throw2blackbird64_land" )

	EmitSoundOnEntityAfterDelay( file.player, "scr_s2s_player_land_on_crow", 0.1 )
	foreach( entity p in GetPlayerArray() )
	{
		p.SetAnimNearZ( 3 )
		thread PlayFPSAnimShowProxy( p, "pt_s2s_lifeboats_land", "ptpov_s2s_lifeboats_land" , node, "REF", ViewConeSmall, blendTime, 0.2 )
	}
	wait blendTime

	level.nv.ShipStreaming = SHIPSTREAMING_MALTA

	float amplitude = 10
	float frequency = 200
	float duration = 1.0
	float radius = 2048
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( player )

	WaittillAnimDone( player )
	player.ClearAnimNearZ()
	
	foreach( entity p in GetPlayerArray() )
	{
		p.UnforceStand()
		p.Anim_Stop()
		p.Signal( "ScriptAnimStop" )
		ClearPlayerAnimViewEntity( p )
		p.ClearParent()
		p.DeployWeapon()
	}

	if ( IsValid( target ) )
		target.Destroy()
	if ( IsValid( node ) )
		node.Destroy()
	
	FullyShowPlayers()
}

void function Fastball_DoObj( entity bt )
{
	WaitSignal( bt, "ReadyForFastball" )
	Objective_Hide( file.player )
	WaitFrame()
	Objective_Set( "#S2S_OBJECTIVE_FASTBALL1", <0,0,1> )
	Objective_SetFastball( bt )
}

void function FastBall_GoodLuckVO( entity bt )
{
	wait 13.7
	StopMusic()
	PlayMusic( "music_s2s_02_throw2blackbird64_throw" )

	wait 0.3
	if ( Flag( "BTFastballConvoDone" ) )
	{
		//good luck
		waitthreadsolo PlayBTDialogue( "diag_sp_adds_STS801_15_01_mcor_bt" )
	}
}

void function FastBall_VO( entity player, entity bt )
{
	FlagWaitClear( "Barkership_EnderVO" )

	if ( !Flag( "Fastball_PickedUpPlayer" ) )
	{
		//BT: "Climb into my hand, and I'll throw you to blackbird 6-4."
		waitthreadsolo PlayBTDialogue( "diag_sp_barkerShip_STS155_01_01_mcor_bt" )
	}

	FlagWait( "Fastball_PickedUpPlayer" )

	waitthreadsolo PlayerConversation( "Barker_ClimbIn", player, bt )

	FlagSet( "BTFastballConvoDone" )
}

void function Fastball_TrackTarget( entity player, entity target )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ScriptAnimStop" )

	while( 1 )
	{
		DebugDrawCircle( target.GetOrigin(), <0,0,0>, 32, 0, 0, 255, true, 0.15, 6  )
		GraphTrajectory( player.GetOrigin(), player.GetVelocity() )

		WaitFrame()
	}
}

void function Fastball_1_CrowFlightPath( ShipStruct crow64, entity player, entity bt, entity target )
{
	SetMaxSpeed( crow64, 1000, 0.5 )
	delaythread( 3 ) SetMaxAcc( crow64, 300 )

	vector pos 		= <0,0,0>
	vector bounds 	= <0,0,0>
	thread ShipIdleAtTargetEnt_Method2( crow64, file.malta.mover, bounds, pos, FASTBALL_CROW_OFFSET2 )

	WaitSignal( bt, "fastball_release" )
	ResetMaxAcc( crow64 )

	thread ShipIdleAtTargetEnt_Method2( crow64, file.malta.mover, bounds, pos, FASTBALL_CROW_OFFSET3 )
}

void function BT_WaitOnBarkerShip( entity bt, bool teleport = false )
{
	if ( !teleport )
	{
		//	WaittillAnimDone( bt )
		bt.Anim_Stop()
		wait 0.1
	}

	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.SetNoTarget( true )

	entity node 		= GetEntByScriptName( "lew_bt_point" )
	bt.SetParent( node )
	bt.MarkAsNonMovingAttachment()
	thread PlayAnimTeleport( bt, "bt_s2s_post_jump_idle", node )
}

/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗     ██╗███╗   ██╗████████╗██████╗  ██████╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██║████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗
██╔████╔██║███████║██║     ██║   ███████║    ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ██║██║ ╚████║   ██║   ██║  ██║╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝    ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝

\************************************************************************************************/
void function MaltaIntro_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-20000,0> )
	SetupShips_MaltaIntro()

	entity engines = GetEntByScriptName( "amb_emit_s2s_Malta_Thrusters" )
	Assert( IsValid( engines ) )
	EmitSoundOnEntity( engines, "amb_emit_s2s_Malta_Thrusters" )

	SetOriginLocal( file.airBattleNode, V_MALTAINTRO_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()
	thread MaltaSideGunsRandomFire()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_WaitOnBarkerShip( bt, true )

	player.SetOrigin( file.crow64.model.GetOrigin() + <0,0,128> )
	entity saveNode = CreateInfoTarget( player.GetOrigin() + <0,0,4>, player.GetAngles() )
	saveNode.SetParent( file.crow64.mover )
	saveNode.SetScriptName( "FastballLandCheckpointNode" )

	delaythread( 0.5 ) Crow64Shake()

	HideName( file.bear )
	HideName( file.gates )
	HideName( file.droz )
	HideName( file.davis )

	// added stuff
	TeleportAllExceptOne( file.crow64.model.GetOrigin() + <0,0,128>, player, false )
	
	MaltaIntro_PutRespawnShipOnStandBy()
}

void function MaltaIntro_Skip( entity player )
{
	level.nv.ShipTitles = SHIPTITLES_NOMALTA

	WaitFrame()

	// SpawnRespawnWidow( WorldToLocalOrigin( < -3903, -7061, 367 > ) )

	LocalVec org = WorldToLocalOrigin( file.malta.mover.GetOrigin() )
	org.v += <2000,2000,-1000>

	SpawnRespawnWidow( org )

	WidowAnimateOpen( file.respawnWidow, "left" )

	// file.respawnWidow.mover.SetOrigin( < -3903, -9861, 367 > )
}

void function MaltaIntro_Main( entity player )
{
	//setup stuff that used to be at the end of fastball
	if ( !Flag( "Fastball_PickedUpPlayer" ) )
	{
		StopMusic()
		PlayMusic( "music_s2s_02_throw2blackbird64_land" )
		level.nv.ShipStreaming = SHIPSTREAMING_MALTA
		NonPhysicsMoveToLocal( file.airBattleNode, V_MALTAINTRO_AIRBATTLE, 1, 0.5, 0.5 )
	}

	// do movement of respawn ship to new location and tp all players
	// added stuff
	TeleportAllExceptOne( file.crow64.model.GetOrigin() + <0,0,128>, player, false )
	
	MaltaIntro_PutRespawnShipOnStandBy()

	entity saveNode = CreateInfoTarget( player.GetOrigin() + <0,0,4>, player.GetAngles() )
	saveNode.SetParent( file.crow64.mover )
	saveNode.SetScriptName( "FastballLandCheckpointNode" )

	CheckPointData data
	data.safeLocations = GetEntArrayByScriptName( "FastballLandCheckpointNode" )
	CheckPoint( data )


	ResetMaxRoll( file.barkership )
	ResetMaxSpeed( file.crow64 )
	ResetMaxAcc( file.crow64 )

	FlagSet( "DriftWorldCenter" )
	thread UpdatePosWithLocalSpace( file.airBattleNode )

	FlagEnd( "PlayerInDroneRoom" )

	level.nv.ShipTitles = SHIPTITLES_NOMALTA

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	OnThreadEnd(
	function() : (  )
		{
			if ( !IsValid( file.player ) )
				return

			ResetMaxPitch( file.crow64, 1.0 )
			ResetMaxSpeed( file.crow64, 1.0 )
			ResetMaxAcc( file.crow64, 1.0 )
			file.crow64.boundsMinRatio = 0.5 //back to default
			thread ShipIdleAtTargetPos( file.malta, V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )
			file.malta.FuncGetBankMagnitude = GetBankMagnitudeMalta

			if ( IsDoorClosedOrClosing( file.crow64 ) )
				delaythread( 0.2 ) DropshipAnimateOpen( file.crow64, "left" )

			file.davis.DisableNPCFlag( NPC_IGNORE_ALL )
			file.droz.DisableNPCFlag( NPC_IGNORE_ALL )
			file.gates.DisableNPCFlag( NPC_IGNORE_ALL )
			file.bear.DisableNPCFlag( NPC_IGNORE_ALL )

			ShowName( file.bear )
			ShowName( file.gates )
			ShowName( file.droz )
			ShowName( file.davis )

			file.crow64.triggerFallingDeath.Destroy()
		}
	)

	Objective_SetSilent( "#S2S_OBJECTIVE_TAKECONTROL1", <0,0,0>, file.malta.model )

	EnableScript( file.malta, "scr_malta_node_1" )
	EnableScript( file.malta, "scr_malta_node_1b" )
	thread Crow64_CreatePilot()
	file.crow64.triggerFallingDeath.Disable()

	//Spawn First guys
	AddSpawnCallback_ScriptName( "malta_introGuys1", MaltaIntro_GuysThink )
	SpawnOnShipFromScriptName( "malta_introGuys1", file.malta )
	thread MaltaIntro_GuysReact( "malta_introGuys1_react1", "pt_generic_commander_wave_duck_A", "pt_generic_commander_wave_duck_B" )
	thread MaltaIntro_GuysReact( "malta_introGuys1_react2", "pt_generic_commander_wave_short_A", "pt_generic_commander_wave_short_B" )

	//fly over to the malta... near the rear engines
	entity maltaRef = file.malta.mover
	entity node 	= GetEntByScriptName( "maltaIntroCrowNode" )
	vector delta 	= GetRelativeDelta( node.GetOrigin() + <0,0,1000>, maltaRef )
	vector offset 	= < 800, -3000, 0 >

	//get to know the crew
	thread MaltaIntro_FlavorVO( player )
	SetMaxPitch( file.crow64, 	10 )
	SetMaxSpeed( file.crow64, 750, 0.5 )
	SetMaxAcc( file.crow64, 150, 0.5 )

	thread DropshipAnimateOpen( file.crow64, "left" )

	thread ShipFlyToRelativePos( file.crow64, maltaRef, delta, offset )
	thread ShipFlyToPos( file.malta, V_MALTADRONE_MALTA )
	file.crow64.goalRadius = 1500
	WaitSignal( file.crow64, "Goal" )

	//reposition the MALTA
	thread ShipIdleAtTargetPos( file.malta, V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )

	//fly back away
	delta 			= GetRelativeDelta( node.GetOrigin(), maltaRef )
	offset 			= < 2000, -1000, 0 >
	thread ShipFlyToRelativePos( file.crow64, maltaRef, delta, offset )
	file.crow64.goalRadius = 3000
	WaitSignal( file.crow64, "Goal" )

	vector bounds = <300,0,50>
	thread ShipIdleAtTargetEnt( file.crow64, maltaRef, bounds, delta, offset )

	ResetMaxSpeed( file.crow64, 1.0 )
	ResetMaxAcc( file.crow64, 1.0 )
	FlagWait( "MaltaIntroFlyOver" )

	//fly over to the drone room
	thread MaltaIntro_CrowFlightPath()

	file.davis.EnableNPCFlag( NPC_IGNORE_ALL )
	file.droz.EnableNPCFlag( NPC_IGNORE_ALL )
	file.gates.EnableNPCFlag( NPC_IGNORE_ALL )
	file.bear.EnableNPCFlag( NPC_IGNORE_ALL )

	FlagWait( "MaltaIntro_ContactVoGood" )

	file.davis.DisableNPCFlag( NPC_IGNORE_ALL )
	file.droz.DisableNPCFlag( NPC_IGNORE_ALL )
	file.gates.DisableNPCFlag( NPC_IGNORE_ALL )
	file.bear.DisableNPCFlag( NPC_IGNORE_ALL )

	CheckPointData saveData
	saveData.safeLocations = GetEntArrayByScriptName( "FastballLandCheckpointNode" )
	CheckPoint_Silent( saveData )

	//help player land on malta

	thread MaltaIntro_JumpMusic()

	string voReady, voJump, voStop, voWait
	while( !Flag( "PlayerJumpingToMalta" ) )
	{
		//Crow Captain: 	“Get ready.”
		voReady = "diag_sp_barkerShip_STS180_01_01_mcor_crowCptn"
		//Crow Captain: 	“Now! Go! Go!”
		voJump = "diag_sp_barkerShip_STS181_01_01_mcor_crowCptn"
		//Crow Captain: 	“Wait wait, I gotta pull away.”
		voStop = "diag_sp_barkerShip_STS182_01_01_mcor_crowCptn"
		//Crow Captain: 	“Hold on.”
		voWait = "diag_sp_barkerShip_STS183_01_01_mcor_crowCptn"
		waitthreadsolo MaltaIntro_VOHelpCycle( player, voReady, voJump, voStop, voWait )

		//Crow Captain: 	“Ok I'm pulling her back in get ready.”
		voReady = "diag_sp_barkerShip_STS184_01_01_mcor_crowCptn"
		//Crow Captain: 	“Okay jump!”
		voJump = "diag_sp_barkerShip_STS185_01_01_mcor_crowCptn"
		//Crow Captain: 	“Don't jump, we're moving away”
		voStop = "diag_sp_barkerShip_STS186_01_01_mcor_crowCptn"
		//Crow Captain: 	“Let me get her back into position”
		voWait = "diag_sp_barkerShip_STS187_01_01_mcor_crowCptn"
		waitthreadsolo MaltaIntro_VOHelpCycle( player, voReady, voJump, voStop, voWait )

		//Crow Captain: 	“I'm banking towards her again, get ready”
		voReady = "diag_sp_barkerShip_STS188_01_01_mcor_crowCptn"
		//Crow Captain: 	“Do it! Jump!”
		voJump = "diag_sp_barkerShip_STS189_01_01_mcor_crowCptn"
		//Crow Captain: 	“Don't! Don't! You missed your window”
		voStop = "diag_sp_barkerShip_STS190_01_01_mcor_crowCptn"
		//Crow Captain: 	“Just hold on a sec.”
		voWait = "diag_sp_barkerShip_STS191_01_01_mcor_crowCptn"
		waitthreadsolo MaltaIntro_VOHelpCycle( player, voReady, voJump, voStop, voWait )

		//Crow Captain: 	“I'm moving into position now”
		voReady = "diag_sp_barkerShip_STS192_01_01_mcor_crowCptn"
		//Crow Captain: 	“Your good! Go! Go!”
		voJump = "diag_sp_barkerShip_STS193_01_01_mcor_crowCptn"
		//Crow Captain: 	“Stop! I can't hold it, backing off.”
		voStop = "diag_sp_barkerShip_STS194_01_01_mcor_crowCptn"
		//Crow Captain: 	“Ok you got it this time”
		voWait = "diag_sp_barkerShip_STS195_01_01_mcor_crowCptn"
		waitthreadsolo MaltaIntro_VOHelpCycle( player, voReady, voJump, voStop, voWait )

		//Crow Captain: 	“Closing the gap”
		voReady = "diag_sp_barkerShip_STS196_01_01_mcor_crowCptn"
		//Crow Captain: 	“Now! Jump!”
		voJump = "diag_sp_barkerShip_STS197_01_01_mcor_crowCptn"
		//Crow Captain: 	“Don't jump! I gotta pull away.”
		voStop = "diag_sp_barkerShip_STS198_01_01_mcor_crowCptn"
		//Crow Captain: 	“Let me line it up.”
		voWait = "diag_sp_barkerShip_STS199_01_01_mcor_crowCptn"
		waitthreadsolo MaltaIntro_VOHelpCycle( player, voReady, voJump, voStop, voWait )

		//Crow Captain: 	“Okay bringing you back in!”
		//thread PlayDialogue( "diag_sp_barkerShip_STS200_01_01_mcor_crowCptn", player )
	}

	FlagWait( "PlayerInDroneRoom" )
}

void function MaltaIntro_PutRespawnShipOnStandBy()
{
	thread ShipIdleAtTargetEnt_Method2( file.respawnWidow, file.malta.mover, <0,0,0>, <0,0,0>, <6000,-4000,-1000> )
}

void function MaltaIntro_GuysReact( string name, string anim1, string anim2 )
{
	array<entity> guys = SpawnOnShipFromScriptName( name, file.malta )
	entity node = guys[0].GetLinkEnt()

	vector origin = node.GetOrigin()
	vector angles = AnglesCompose( <0,node.GetAngles().y,0>, <0,180,0> )
	array<string> anims = [ anim1, anim2 ]

	foreach ( index, guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		guy.SetNoTarget( true )
		guy.EnableNPCFlag( NPC_IGNORE_ALL )

		thread RunToAnimStartForced_Deprecated( guy, anims[index], origin, angles, false )
	}

	FlagWaitAny( "PlayerInDroneRoom", "MaltaIntroGuysGo" )

	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		guy.SetNoTarget( false )
		guy.DisableNPCFlag( NPC_IGNORE_ALL )
	}

	if ( Flag( "PlayerInDroneRoom" ) )
		return

	origin = node.GetOrigin()
	angles = AnglesCompose( <0,node.GetAngles().y,0>, <0,180,0> )
	foreach ( index, guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		thread PlayAnimGravity( guy, anims[ index ], origin, angles )
	}
}

void function MaltaIntro_JumpMusic()
{
	entity trigger = file.crow64.triggerTop
	entity player
	table result
	if ( !trigger.IsTouched() )
	{
		result = trigger.WaitSignal( "OnStartTouch" )
		player = expect entity( result.activator )
	}
	else
	{
		player = trigger.GetTouchingEntities()[0]
	}

	Assert( player.IsPlayer() )

/*	while ( trigger.IsTouched() )
	{
		trigger.WaitSignal( "OnEndTouchAll" )
		WaitFrame() //make sure
	}*/

	file.player.WaitSignal( "ButtonPressedJump" )
	FlagSet( "PlayerJumpingToMalta")

	StopMusic()
	PlayMusic( "music_s2s_03_jump2malta" )
}

void function MaltaIntro_CrowFlightPath( bool teleport = false )
{
	FlagEnd( "PlayerInDroneRoom" )

	entity maltaRef = file.malta.mover
	entity node 	= GetEntByScriptName( "maltaIntroCrowNode" )
	vector delta 	= GetRelativeDelta( node.GetOrigin(), maltaRef )

	SetMaxPitch( file.crow64, 	10 )
	SetMaxSpeed( file.crow64, 	750 )
	SetMaxAcc( file.crow64, 	100 )

	OnThreadEnd(
	function() : (  )
		{
			ResetMaxPitch( file.crow64, 1 )
			ResetMaxSpeed( file.crow64, 1 )
			ResetMaxAcc( file.crow64, 	1 )
		}
	)

	if ( teleport )
		ShipIdleAtTargetEnt_M2_Teleport( file.crow64, maltaRef, MALTAINTRO_CROW_BOUNDS, delta, MALTAINTRO_CROW_OFFSET )
	else
	{
	/*	ShipStruct ship = SpawnCrowLight( CLVec( <0,0,0> ), CONVOYDIR, true )
		SetMaxPitch( ship, 	10 )
		SetMaxSpeed( ship, 	750 )
		SetMaxAcc( ship, 	100 )
		ShipIdleAtTargetEnt_M2_Teleport( ship, maltaRef, MALTAINTRO_CROW_BOUNDS, delta, MALTAINTRO_CROW_OFFSET )
	*/
		file.crow64.flyBounds[ eBehavior.CUSTOM ] 	= MALTAINTRO_CROW_BOUNDS
		file.crow64.customEnt 						= maltaRef
		file.crow64.customPos 						= delta
		file.crow64.flyOffset[ eBehavior.CUSTOM ] 	= MALTAINTRO_CROW_OFFSET
		thread DoCustomBehavior( file.crow64, CustomCrowStrafeMalta )
	}

	FlagWait( "PlayerInDroneRoom" )
}

void function CustomCrowStrafeMalta( ShipStruct ship )
{
	Signal( ship, "NewFlyStyle" )
	EndSignal( ship, "NewFlyStyle" )
	EndSignal( ship, "FakeDestroy" )

	vector bounds 	= ship.flyBounds[ eBehavior.CUSTOM ]
	entity maltaRef	= ship.customEnt
	vector delta	= ship.customPos
	vector offset 	= ship.flyOffset[ eBehavior.CUSTOM ]

	vector pos 		= GetWorldOriginFromRelativeDelta( delta, maltaRef )
	entity anchor 	= CreateScriptMover( pos + offset, <0,0,0> )
	entity link 	= SpawnRefEnt( anchor )

	anchor.SetPusher( true )

	link.SetAngles( CONVOYDIR )
	link.SetParent( anchor, "REF" )
	link.Anim_Play( "ref" )
	link.Anim_IgnoreParentRotation( true )
	link.SetAngles( CONVOYDIR )

	thread CustomShipStrafeMalta_UpdateBase( anchor, delta, offset, maltaRef )

	float x = -bounds.x
	float roll = ship.rollMax * -0.75
	float bankDelay = ship.fullBankTime * 0.66

	ship.mover.SetParent( link, "REF", true, 0.0 )
	ship.mover.NonPhysicsSetMoveModeLocal( true )
	ship.mover.NonPhysicsSetRotateModeLocal( true )

	OnThreadEnd(
	function() : ( ship, anchor, link )
		{
			if ( !IsValid( ship.model ) ) //on a level ending from restart this could be true
				return

			ship.mover.NonPhysicsSetMoveModeLocal( false )
			ship.mover.NonPhysicsSetRotateModeLocal( false )
			ship.mover.ClearParent()
			SetOriginLocal( ship.mover, WorldToLocalOrigin( ship.mover.GetOrigin() ) )
			ship.localVelocity.v = GetVelocityLocal( ship.mover ).v

			if ( IsValid( anchor ) )
				anchor.Destroy()
			if ( IsValid( link ) )
				link.Destroy()
		}
	)

	ship.mover.NonPhysicsRotateTo( <0, 90, roll>, ship.fullBankTime * 2, ship.fullBankTime * 0.6, ship.fullBankTime * 1.4 )

	while( 1 )
	{
		float timeTotal, timeAcc
		vector origin = ship.mover.GetLocalOrigin()
		vector goal = < x,0,0 >

		//figure out the distance
		float dist = Distance( goal, origin )
		float halfDist = dist * 0.5

		//at full acceleration how long will it take us to reach our max speed
		float accTime = sqrt( ship.speedMax / ship.accMax )
		float accDist = ship.accMax * pow( accTime, 2 )

		//is that more or less than our halfDist
		if ( accDist >= halfDist )
		{
			timeAcc = sqrt( halfDist / ship.accMax )
			timeTotal = timeAcc * 2
		}
		else
		{
			float distAtTopSpeed = halfDist - accDist
			float topSpeedTime = distAtTopSpeed / ship.speedMax
			timeAcc = accTime
			timeTotal = ( topSpeedTime * 2 ) + ( accTime * 2 )
		}

		ship.mover.NonPhysicsMoveTo( goal, timeTotal, timeAcc, timeAcc )

		if ( x < 0 )
			thread ShipSignalDelayed( ship, "CCSM_Jump", timeTotal * 0.5 )
		else
			thread ShipSignalDelayed( ship, "CCSM_Wait", timeTotal * 0.5 )

		wait timeTotal - ( timeAcc + bankDelay )

		roll *= -1
		ship.mover.NonPhysicsRotateTo( <0, 90, roll>, ship.fullBankTime * 2, ship.fullBankTime * 0.6, ship.fullBankTime * 1.4 )

		float waitTime = ( timeAcc + bankDelay )
		if ( x < 0 )
			thread ShipSignalDelayed( ship, "CCSM_Stop", waitTime * 0.75 )
		else
			thread ShipSignalDelayed( ship, "CCSM_Ready", waitTime * 0.75 )

		wait waitTime

		x *= -1
	}
}

void function CustomShipStrafeMalta_UpdateBase( entity anchor, vector delta, vector offset, entity maltaRef )
{
	anchor.EndSignal( "OnDestroy" )

	while( 1 )
	{
		vector pos = GetWorldOriginFromRelativeDelta( delta, maltaRef ) + offset
		anchor.NonPhysicsMoveTo( pos, FRAME_INTERVAL * 1.5, 0, 0 )
		WaitFrame()
	}
}

void function ShipSignalDelayed( ShipStruct ship, string msg, float delay )
{
	wait delay

	Signal( ship, msg )
}

void function MaltaIntro_VOHelpCycle( entity player, string voReady, string voJump, string voStop, string voWait )
{
	if ( Flag( "PlayerJumpingToMalta" ) )
		return
	FlagEnd( "PlayerJumpingToMalta" )

	OnThreadEnd(
	function() : ( player, voStop )
		{
			StopSoundOnEntity( player, voStop )
		}
	)

	WaitSignal( file.crow64, "CCSM_Jump" )
		thread PlayDialogue( voJump, player )

	WaitSignal( file.crow64, "CCSM_Stop" )
		thread PlayDialogue( voStop, player )

	WaitSignal( file.crow64, "CCSM_Wait" )
		thread PlayDialogue( voWait, player )

	WaitSignal( file.crow64, "CCSM_Ready" )
		thread PlayDialogue( voReady, player )
}

vector function GetVelocityRelativeToRef( entity mover, entity ref )
{
	LocalVec vel1 = GetVelocityLocal( mover )
	LocalVec vel2 = GetVelocityLocal( ref )

	return vel1.v - vel2.v
}

void function MaltaIntro_FlavorVO( entity player )
{
	if ( Flag( "PlayerInDroneRoom" ) )
		return
	FlagEnd( "PlayerInDroneRoom" )

	wait 1.0
	if ( file.crow64.triggerTop.IsTouching( player ) && player.IsOnGround() )
		CheckPoint()

	//Droz:	 "Welcome to the 6-4, Coop."
	waitthreadsolo PlayDialogue( "diag_sp_barkerShip_STS169_01_01_mcor_droz", file.droz )
	delaythread( 4.0 ) FlagSet( "MaltaIntroGuysGo" )

	wait 0.5

	delaythread( 4 ) MaltaGunsObjective()
	//Crow Captain:	 "Cooper. Listen up, we can't take you directly to the bridge. We'll never get past those guns. We'll drop you off at the stern, and you'll have to work your way forward."
	waitthreadsolo PlayDialogue( "diag_sp_barkerShip_STS176_01_01_mcor_crowCptn", player )
	thread MaltaIntro_BoardObjective()

	wait 1.0

	//Gates:	 Contact Left!
	waitthreadsolo PlayDialogue( "diag_sp_barkerShip_STS177_01_01_mcor_gates", player )

	FlagSet( "MaltaIntro_ContactVoGood" )
	delaythread( 3.0 ) FlagSet( "MaltaIntroFlyOver" )

	//Crow Captain: 	Cooper. I'm going to get as close as I can, without crashing.  Time your jump.
	waitthreadsolo PlayDialogue( "diag_sp_barkerShip_STS179_01_01_mcor_crowCptn", player )

	if ( file.crow64.triggerTop.IsTouching( player ) && player.IsOnGround() )
		CheckPoint()
}

void function MaltaIntro_BoardObjective()
{
	Objective_Hide( file.player )
	WaitFrame()

	Objective_Set( "#S2S_OBJECTIVE_BOARDMALTA", <0,0,1> )
	entity marker = Objective_GetMarkerEntity()
	marker.SetOrigin( GetEntByScriptName( "maltaPlayerStart1" ).GetOrigin() )
	marker.SetParent( file.malta.mover )
}

void function MaltaGunsObjective( bool silent = false )
{
	if ( silent )
		Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret2" ) )
	else
		Objective_Set( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret2" ) )

	Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret1" ) )
	Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret3" ) )
}

void function MaltaIntro_GuysThink( entity guy )
{
	guy.EndSignal( "OnDeath" )

	guy.SetNoTarget( true )
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.SetEfficientMode( true )

	wait 0.2

	vector origin = HackGetDeltaToRefOnPlane( guy.GetOrigin(), guy.GetAngles(), guy, "CQB_Idle_Casual", file.malta.model.GetUpVector() )
	thread PlayAnim( guy, "CQB_Idle_Casual", origin, guy.GetAngles() )

	FlagWaitAny( "PlayerInDroneRoom", "MaltaIntroGuysGo" )

	guy.SetNoTarget( false )
	guy.DisableNPCFlag( NPC_IGNORE_ALL )
	guy.SetEfficientMode( false )
	guy.Anim_Stop()
}

void function Crow64Shake()
{
	float amplitude = 1.5
	float frequency = 200
	float duration = 900 //15 min
	float radius = 500
	entity shake = CreateShakeExpensive( file.crow64.model.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.crow64.model )
	shake.DisableHibernation()

	#if DEV
		if ( GetBugReproNum() == 1 )
		{
			printt( "playerPOS: " + file.player.GetOrigin() )
			printt( "ShakePOS: " + shake.GetOrigin() )
			DebugDrawCircleOnEnt( shake, 64, 255, 255, 255, 60 )
		}
	#endif

	FlagWait( "PlayerInDroneRoom" )

	thread KillShake( shake )
}


/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗     ██████╗ ██████╗  ██████╗ ███╗   ██╗███████╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗████╗  ██║██╔════╝
██╔████╔██║███████║██║     ██║   ███████║    ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╗
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██║  ██║██╔══██╗██║   ██║██║╚██╗██║██╔══╝
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ██████╔╝██║  ██║╚██████╔╝██║ ╚████║███████╗
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

\************************************************************************************************/
void function MaltaDrone_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-22000,0> )
	SetupShips_MaltaDrone()

	SetOriginLocal( file.airBattleNode, V_MALTAINTRO_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()
	thread MaltaSideGunsRandomFire()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_WaitOnBarkerShip( bt, true )

	EnableScript( file.malta, "scr_malta_node_1" )
	EnableScript( file.malta, "scr_malta_node_1b" )

	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart1" ) )

	SpawnOnShipFromScriptName( "malta_introGuys1", file.malta )
	SpawnOnShipFromScriptName( "malta_introGuys1_react1", file.malta )
	SpawnOnShipFromScriptName( "malta_introGuys1_react2", file.malta )
}

void function MaltaDrone_Skip( entity player )
{
	file.malta.triggerFallingDeath.Disable()

	thread MaltaDrone_StressSounds()
	ShipGeoHide( file.malta, "GEO_CHUNK_EXTERIOR_ENGINE" )
	ShipGeoHide( file.malta, "GEO_CHUNK_EXTERIOR_L" )

	NextState()
	thread HandleRespawnPlayer_s2s()
}

void function MaltaDrone_Main( entity player )
{
	FlagInit( "MaltaDroneRoomClearMusic" )

	file.bear.kv.allowshoot = false
	file.bear.SetNoTarget( true )
	file.gates.SetNoTarget( true )
	file.davis.SetNoTarget( true )
	file.droz.SetNoTarget( true )

	file.malta.triggerFallingDeath.Disable()

	StopMusic()
	PlayMusic( "music_s2s_04_maltabattle" )
	thread MaltaDrone_ClearMusic()
	entity engines = GetEntByScriptName( "amb_emit_s2s_Malta_Thrusters" )
	Assert( IsValid( engines ) )
	EmitSoundOnEntity( engines, "amb_emit_s2s_Stop_Malta_Thrusters" )
	thread MaltaDrone_StressSounds()

	ShipGeoHide( file.malta, "GEO_CHUNK_EXTERIOR_ENGINE" )
	ShipGeoHide( file.malta, "GEO_CHUNK_EXTERIOR_L" )

	CheckPoint()
	entity marker = Objective_GetMarkerEntity()
	marker.ClearParent()
	Objective_WayPointEneable( true )
	Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", < 0, 0, 0 >, GetEntByScriptName( "droneBay0" ) )

	MaltaDrone_CrowFlightPath()
	thread MaltaBay_HardBank( file.malta )
	thread MaltaBay_StartVO( player )

	entity liftClip = GetEntByScriptName( "malta_bay_lift_clip" )
	entity npcClip = GetEntByScriptName( "droneLiftNpcClip" )
	liftClip.NotSolid()
	npcClip.NotSolid()
	file.malta.lifts[ "droneBay0" ][0].travelTime = 9.0 //speed of the cargo lift
	file.malta.lifts[ REALDRONELIFT ][0].travelTime = 9.0 //speed of the cargo lift
	file.malta.lifts[ "droneBay0" ][0].lift.SetPusher( true )
	file.malta.lifts[ "droneBay0" ][0].lift.DisableHibernation()
	file.malta.lifts[ REALDRONELIFT ][0].lift.SetPusher( true )
	file.malta.lifts[ REALDRONELIFT ][0].lift.DisableHibernation()

	//spawn pistol dudes as soon as you land
	SpawnOnShipFromScriptName( "malta_pistolGuys", file.malta )

	entity trigger = GetEntByScriptName( "malta_introGuys2_spawnTrig" )
	trigger.WaitSignal( "OnTrigger" )
	FlagSet( "malta_introGuys2_spawned" )

	AddSpawnCallback_ScriptName( "malta_introGuys2a", Malta_RackRunners_Think )
	AddSpawnCallback_ScriptName( "malta_introGuys2a", MaltaBay_SpecreVO )
	SpawnOnShipFromScriptName( "malta_introGuys2b", file.malta )

	array<entity> guys = SpawnOnShipFromScriptName( "malta_introGuys2a", file.malta )

	trigger = GetEntByScriptName( "malta_introGuys3_spawnTrig" )
	trigger.WaitSignal( "OnTrigger" )
	FlagSet( "malta_introGuys3_spawned" )

	if ( IsAlive( guys[0] ) )
	{
		guys[0].UnlinkFromEnt( guys[0].GetLinkEnt() )
		guys[0].LinkToEnt( GetEntByScriptName( "droneRoomSpectreRackButton1" ) )
	}

	AddSpawnCallback_ScriptName( "malta_introGuys3", Malta_RackRunners_Think )
	AddSpawnCallback_ScriptName( "malta_introGuys3", MaltaBay_SpecreVO )
	SpawnOnShipFromScriptName( "malta_introGuys3", file.malta )

	thread MaltaDrone_GuysCleanupLogic( player )
	entity door1 = GetEntByScriptName( "maltaBayLiftDoors" )
	thread MaltaBayCheckReadyForLift( door1, player )
	thread MaltaBay_ElevatorGag()

	FlagWait( "MaltaBayLiftGuySpawn" )
	file.gates.kv.allowshoot = false

	FlagWait( "droneRoomLiftUp" )
	FlagSet( "DroneLiftUsed" )

	LiftStruct lift = file.malta.lifts[ "droneBay0" ][0]
	thread LiftSendUp( lift )

	liftClip.Solid()
	thread MaltaBay_ElevatorSwitch( player )
	// thread DroneLiftLoop()
	delaythread ( CAGEDOORDELAY + SLIDEDOORTIME ) MaltaDrone_liftMusic()

	EnableScript( file.malta, "scr_malta_node_2" )

	thread MaltaBay_LiftVO( player )

	SetMaxRoll( file.malta, 5 )

	file.bear.SetNoTarget( false )
	file.gates.SetNoTarget( false )
	file.davis.SetNoTarget( false )
	file.droz.SetNoTarget( false )
	file.gates.kv.allowshoot = true
}

void function MaltaDrone_liftMusic()
{
	StopMusic()
	PlayMusic( "music_s2s_06_ridelift" )
}

void function MaltaDrone_GuysCleanupLogic( entity player )
{
	while ( file.maltaRunnersComplete < 2 )
		WaitSignal( svGlobal.levelEnt, "maltaRunnersComplete" )
	wait 1.5

	array<entity> enemies = GetNPCArrayByScriptName( "droneRoomSpectre1", TEAM_IMC )
	enemies.extend( GetNPCArrayByScriptName( "droneRoomSpectre2", TEAM_IMC ) )

	if ( enemies.len() )
	{
		waitthread WaitUntilNumDeadOrLeeched( enemies, enemies.len() - 1 )
		thread MaltaDrone_GoodKillVO()
	}

	//at this point if there are any stragglers, kill them.
	enemies = GetNPCArrayByScriptName( "malta_introGuys1", TEAM_IMC )
	enemies.extend( GetNPCArrayByScriptName( "malta_introGuys1_react1", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "malta_introGuys1_react2", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "malta_pistolGuys", TEAM_IMC ) )
	array<entity> targets
	foreach ( guy in enemies )
	{
		if ( PlayerCanSee( player, guy, true, 45 ) )
			continue

		guy.TakeDamage( guy.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.mp_weapon_dmr } )
	}

	thread MaltaBay_EnderVO( player )
}

void function MaltaDrone_GoodKillVO()
{
	wait 1

	if ( Flag( "DroneLiftUsed" ) )
		return

	//“Good kill! Good kill
	PlayDialogue( "diag_sp_maltaDrone_STS207_01_01_mcor_droz", file.player )
}

void function MaltaDrone_ClearMusic()
{
	FlagWait( "MaltaDroneRoomClearMusic" )
	if ( !Flag( "DroneLiftUsed" ) )
	{
		StopMusic()
		PlayMusic( "music_s2s_05_maltabattle_end" )
	}
}

void function MaltaDrone_StressSounds()
{
	if ( Flag( "Stop_MaltaStressSounds" ) )
		return
	FlagEnd( "Stop_MaltaStressSounds" )

	wait 1.0

	bool oldSign = file.malta.model.GetAngles().z > 0

	while( 1 )
	{
		float newroll = file.malta.model.GetAngles().z
		bool newSign = newroll > 0
		
		// unitl we know how to disable sounds on death this should stay like this
		// if ( newSign != oldSign )
		// 	EmitSoundOnEntity( file.player, "s2s_ship_stress_mid_v1" )

		oldSign = newSign

		wait 0.5
	}
}

void function MaltaDrone_HandleNPCinLift()
{
	entity useTrigger = GetEntByScriptName( "droneRoomLiftUpTrig" )
	useTrigger.EndSignal( "OnDestroy" )

	while( 1 )
	{
		FlagWait( "MaltaDrone_NPC_in_lift" )
		useTrigger.Disable()

		FlagWaitClear( "MaltaDrone_NPC_in_lift" )
		useTrigger.Enable()
	}
}

void function MaltaBay_HardBank( ShipStruct malta )
{
	wait 7
	
	if ( !IsValid( file.player ) )
	{
		thread RestartMapWithDelay()
		return
	}

	if ( !file.player.IsOnGround() )
		file.player.WaitSignal( "PME_TouchGround" )

	float amplitude = 20
	float frequency = 150
	float duration = 2.0
	float radius = 2048
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )
	EmitSoundOnEntity( file.player, "scr_s2s_malta_ship_impact_01" )

	vector angles = <0,180,0>

	//do stumble anims
	SyncedStumble( angles )
}

void function MaltaBay_ElevatorSwitch( entity player )
{
	LiftStruct fakeLift = file.malta.lifts[ "droneBay0" ][0]
	LiftStruct realLift = file.malta.lifts[ REALDRONELIFT ][0]

	wait CAGEDOORDELAY
	wait SLIDEDOORTIME

	float amplitude = 1.0
	float frequency = 100
	float duration = 1.0
	float radius = 2048
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )

	// vector delta = realLift.lift.GetOrigin() - fakeLift.lift.GetOrigin()
	// player.SetOrigin( player.GetOrigin() + delta )

	LiftSendUp( realLift )

	// added stuff
	TeleportAllExceptOneInstant( realLift.lift.GetOrigin() + <0,0,50>, null )

	NextState()
	thread HandleRespawnPlayer_s2s()
}

void function MaltaBay_LiftVO( entity player )
{
	//“Sarah, this the Seyed. Between the Malta's guns and that flying Titan, we're getting torn up here!”
	PlayDialogue( "diag_sp_maltaGuns_STS236_01_01_mcor_seyedCptn", player )
	wait 0.5

	//“We're working on it - just hang on. Cooper's en route to the Malta's main gun battery.”
	PlayDialogue( "diag_sp_maltaGuns_STS237_01_01_mcor_sarah", player )
	wait 0.5

	//“I don't know if that's going to be enough.”
	PlayDialogue( "diag_sp_maltaGuns_STS238_01_01_mcor_seyedCptn", player )
	wait 0.5

	//“Cooper hurry!”
	PlayDialogue( "diag_sp_maltaGuns_STS239_01_01_mcor_sarah", player )
}


void function MaltaBay_EnderVO( entity player )
{
	if ( Flag( "DroneLiftUsed" ) )
		return
	FlagEnd( "DroneLiftUsed" )

	OnThreadEnd(
	function() : (  )
		{
			FlagSet( "MaltaDroneRoomClearMusic" )
		}
	)

	//check to see if everyone in the room is dead
	array<entity> guys = GetEnemiesClosest( "npc_soldier", player.GetOrigin(), 5000 )
	guys.extend( GetEnemiesClosest( "npc_spectre", player.GetOrigin(), 5000 ) )
	waitthread WaitUntilAllDeadOrLeeched( guys )

	wait 2.0

	//now check to see if the elevator guys have happened
	FlagWait( "MaltaBayLiftGuySpawn" )
	wait 0.1

	//ok so now wait for everyone to die
	guys = GetEnemiesClosest( "npc_soldier", player.GetOrigin(), 5000 )
	if ( guys.len() )
		waitthread WaitUntilAllDeadOrLeeched( guys )

	FlagSet( "MaltaDroneRoomClearMusic" )
	CheckPoint()

	wait 2.0

	//“The room's clear!”
	waitthreadsolo PlayDialogue( "diag_sp_maltaDrone_STS234_01_01_mcor_gates", player )

	AddConversationCallback( "s2s_Hint_Droneroom", ConvoCallback_s2s_Hint_Droneroom )
	thread HintConvo( "s2s_Hint_Droneroom", "DroneLiftUsed" )
}

void function ConvoCallback_s2s_Hint_Droneroom( int choice )
{
	if ( choice == 1 )
	{
		//Pilot, use the cargo lift.
		waitthreadsolo PlayBTDialogue( "diag_sp_maltaDrone_STS235_01a_01_mcor_bt" )
	}
}

void function MaltaBay_StartVO( entity player )
{
	if ( Flag( "maltaIntroGoToRacksFlag" ) )
		return
	FlagEnd( "maltaIntroGoToRacksFlag" )

	//“Nice jump!”
	PlayDialogue( "diag_sp_maltaDrone_STS204_01_01_mcor_davis", player )

	//“We'll cover you from out here, Coop!”
	PlayDialogue( "diag_sp_maltaDrone_STS205_01_01_mcor_droz", player )

	wait 1.5
	//“Bridge, I got an enemy titan pilot inside Drone Bay 5, I need security down here, now!”
	PlayDialogue( "diag_sp_maltaDrone_STS210_01_01_imc_grunt1", player )

	wait 2.0
	//“You got a guy underneath the stairs!”
	thread PlayDialogue( "diag_sp_maltaDrone_STS206_01_01_mcor_davis", player )

	wait 5.0
	//“They're around the corner! Watch your left side!”
	PlayDialogue( "diag_sp_maltaDrone_STS208_01_01_mcor_gates", player )
}

void function MaltaBay_SpecreVO( entity guy )
{
	guy.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : (  )
		{
			if ( Flag( "maltaIntroGoToRacksVO_order" ) )
				delaythread( 0.25 ) FlagSet( "maltaIntroGoToRacksVO_going" )
			if ( Flag( "maltaIntroGoToRacksVO_online" ) )
				delaythread( 0.25 ) FlagSet( "maltaIntroGoToRacksVO_takecover" )
		}
	)

	FlagWait( "maltaIntroGoToRacksFlag" )

	if ( !Flag( "maltaIntroGoToRacksVO_order" ) )
	{
		FlagSet( "maltaIntroGoToRacksVO_order" )
		//"Power up the Stalkers!"
		waitthreadsolo PlayDialogue( "diag_sp_maltaDrone_STS220_01_01_imc_grunt2", guy )

		FlagSet( "maltaIntroGoToRacksVO_going" )
	}
	else( FlagWait( "maltaIntroGoToRacksVO_going" ) )
	{
		//“I'm Going! Cover me!”
		thread PlayDialogue( "diag_sp_maltaDrone_STS215_01_01_imc_grunt3", guy )
	}
/*
	guy.WaitSignal( "SpectreRack_PoweringUp" )
	if ( !Flag( "maltaIntroGoToRacksVO_power" ) )
	{
		FlagSet( "maltaIntroGoToRacksVO_power" )
		//“Powering up the spectres now!”
		thread PlayDialogue( "diag_sp_maltaDrone_STS216_01_01_imc_grunt2", guy )
	}
*/
	guy.WaitSignal( "SpectreRack_Online" )
	if ( !Flag( "maltaIntroGoToRacksVO_online" ) )
	{
		FlagSet( "maltaIntroGoToRacksVO_online" )
		//"Stalkers online!"
		PlayDialogue( "diag_sp_maltaDrone_STS227_01_01_imc_grunt1", guy )
		wait 1.0
		FlagSet( "maltaIntroGoToRacksVO_takecover" )
	}
}

void function MaltaBay_ElevatorGag()
{
	FlagWait( "MaltaBayLiftGuySpawn" )

	EmitSoundOnEntity( file.malta.lifts[ "droneBay0" ][0].lift, "s2s_elevator_arrive" )

	array<entity> spawners = GetEntArrayByScriptName( "malta_liftGuy1" )
	array<entity> guys
	foreach ( spawner in spawners)
	{
		entity guy = SpawnOnShip( spawner, file.malta )
		guy.EnableNPCFlag( NPC_IGNORE_ALL )
		guy.SetNoTarget( true )
		#if DEV
			if ( GetBugReproNum() == 133549 )
				thread DrawLineToDude( guy )
		#endif
		guys.append( guy )

	}

	wait 0.2

	entity node = GetEntByScriptName( "malta_liftGuyAnimNode" )
	entity movetarget = GetEntByScriptName( "malta_introMovetarget2" )
	//array<string> anims = [ "pt_elevator_breach_gruntA", "pt_elevator_breach_gruntB", "pt_elevator_breach_gruntC", "pt_elevator_breach_gruntD" ]
	array<string> anims = [ "pt_elevator_clear_gruntB", "pt_elevator_clear_X_gruntA", "pt_elevator_clear_X_gruntB", "pt_elevator_clear_gruntA" ]

	foreach ( index, guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue
		thread PlayAnimTeleport( guy, anims[ index ] + "_idle", node )
	}

	wait 1.0

	thread MaltaDrone_HandleNPCinLift()
	thread LiftUnLock( file.malta.lifts[ "droneBay0" ][0] )

	wait 0.75

	foreach( index, guy in guys )
	{
		if ( index == 3 )
			wait 0.5

		if ( !IsAlive( guy ) )
			continue

		thread PlayAnimTeleport( guy, anims[ index ], node )
		guy.DisableNPCFlag( NPC_IGNORE_ALL )
		guy.SetNoTarget( false )
	}

	wait 0.5

	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		//“This is Sec 4, engaging the hostile.”
		thread PlayDialogue( "diag_sp_maltaDrone_STS232_01_01_imc_grunt1", guy )
		break
	}

	wait 0.5

	foreach( index, guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		thread AssaultMoveTarget( guy, movetarget )
	}

	entity npcClip = GetEntByScriptName( "droneLiftNpcClip" )
	entity mover = CreateScriptMover( npcClip.GetOrigin() )
	mover.SetParent( npcClip.GetParent(), "", true, 0 )
	npcClip.SetParent( mover, "", true, 0 )
	mover.NonPhysicsSetMoveModeLocal( true )
	vector origin = mover.GetLocalOrigin()

	mover.NonPhysicsMoveTo( origin + < 0,64,0>, 0.1, 0, 0 )

	wait 0.2
	npcClip.Solid()
	mover.NonPhysicsMoveTo( origin + < 0,-48,0>, 2, 0, 0 )
}

void function DroneLiftLoop()
{
	FlagEnd( "MaltaLandedInHangar" )

	while( 1 )
	{
		FlagWait( "MaltaGunsEnter" )
		FlagClear( "PlayerInDroneRoom" )

		FlagWait( "PlayerInDroneRoom" )
		FlagClear( "MaltaGunsEnter" )

		thread ResetDroneLift()
	}
}

void function ResetDroneLift()
{
	EmitSoundOnEntity( file.malta.lifts[ "droneBay0" ][0].lift, "s2s_elevator_arrive" )
	entity liftClip = GetEntByScriptName( "malta_bay_lift_clip" )
	liftClip.NotSolid()

	LiftStruct fakeLift = file.malta.lifts[ "droneBay0" ][0]
	LiftStruct realLift = file.malta.lifts[ REALDRONELIFT ][0]

	fakeLift.travelTime = 1.0
	realLift.travelTime = 1.0
	thread LiftSendDown( fakeLift )
	thread LiftSendDown( realLift )

	FlagClear( "droneRoomLiftUp" )

	wait 1.0
	wait CAGEDOORDELAY
	wait SLIDEDOORTIME

	fakeLift.travelTime = 5.0
	realLift.travelTime = 5.0

	FlagWait( "droneRoomLiftUp" )

	liftClip.Solid()
	thread LiftSendUp( fakeLift )
	thread MaltaBay_ElevatorSwitch( file.player )
}

void function DrawLineToDude( entity guy )
{
	guy.EndSignal( "OnDeath" )
	while( 1 )
	{
		DebugDrawLine( file.player.GetOrigin(), guy.GetOrigin(), 0, 255, 0, true, FRAME_INTERVAL )
		DebugDrawCircle( guy.GetOrigin(), < 90,0,0>, 36, 0, 255, 0, true, FRAME_INTERVAL, 5 )
		WaitFrame()
	}
}

void function MaltaBay_SpawnWave2Onwave1Death()
{
	array<entity> guys = GetNPCArrayByScriptName( "malta_introGuys1" )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys1_react1" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys1_react2" ) )
	entity trigger = GetEntByScriptName( "malta_introGuys2_spawnTrig" )

	trigger.EndSignal( "OnTrigger" )

	waitthread WaitUntilAllDeadOrLeeched( guys )

	trigger.Signal( "OnTrigger" )
}

void function Malta_RackRunners_Think( entity guy )
{
	guy.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : ( guy )
		{
			file.maltaRunnersComplete++
			Signal( svGlobal.levelEnt, "maltaRunnersComplete" )
		}
	)

	FlagWait( "maltaIntroGoToRacksFlag" )

	entity button = guy.GetLinkEnt()
	waitthread GruntRunsToAndActivatesSpectreRack( guy, button )
}

void function MaltaBayCheckReadyForLift( entity door, entity player )
{
	if ( Flag( "MaltaBayLiftGuySpawn" ) )
		return
	FlagEnd( "MaltaBayLiftGuySpawn" )

	FlagWait( "maltaIntroGoToRacksFlag" )
	wait 3

	entity touchTrig = GetEntByScriptName( "maltaBayLookingAtLiftTrig" )
	bool doTrace 	= true
	float degrees 	= 42
	float minDist 	= 0
	float timeOut 	= 4.0

	waitthread WaitTillLookingAt( player, door, doTrace, degrees, minDist, timeOut, touchTrig )
	FlagSet( "MaltaBayLiftGuySpawn" )
}

void function MaltaDrone_CrowFlightPath( bool teleport = false )
{
	entity maltaRef = file.malta.mover
	entity node 	= GetEntByScriptName( "maltaDroneCrowNode" )
	vector pos 		= GetRelativeDelta( node.GetOrigin(), maltaRef )
	vector bounds 	= <400, 300, 60>
	vector offset 	= <1000, 0, 120>
	if ( teleport )
		ShipIdleAtTargetEnt_Teleport( file.crow64, maltaRef, bounds, pos, offset )
	else
		thread ShipIdleAtTargetEnt( file.crow64, maltaRef, bounds, pos, offset )

	if ( IsDoorClosedOrClosing( file.crow64 ) )
		delaythread( 0.2 ) DropshipAnimateOpen( file.crow64, "left" )
}

/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗      ██████╗ ██╗   ██╗███╗   ██╗███████╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██╔════╝ ██║   ██║████╗  ██║██╔════╝
██╔████╔██║███████║██║     ██║   ███████║    ██║  ███╗██║   ██║██╔██╗ ██║███████╗
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██║   ██║██║   ██║██║╚██╗██║╚════██║
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ╚██████╔╝╚██████╔╝██║ ╚████║███████║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝

\************************************************************************************************/
void function MaltaGuns_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-27000,0> )
	SetupShips_MaltaGuns()

	SetMaxRoll( file.malta, 5 )

	file.bear.kv.allowshoot = false

	SetOriginLocal( file.airBattleNode, V_MALTAINTRO_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()
	thread MaltaSideGunsRandomFire()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_WaitOnBarkerShip( bt, true )

	EnableScript( file.malta, "scr_malta_node_1" )
	EnableScript( file.malta, "scr_malta_node_1b" )
	EnableScript( file.malta, "scr_malta_node_2" )

	LiftStruct lift = file.malta.lifts[ REALDRONELIFT ][0]
	lift.lift.SetPusher( true )
	lift.travelTime = 0.5
	thread LiftSendUp( lift )

	PlayerSetStartPoint( player, lift.upPos )
	player.SetAngles(<0,0,0>)
}

void function MaltaGuns_Skip( entity player )
{
	file.airBattleData = GetAirBattleStructMaltaGuns()

	ShipGeoHide( file.malta, "GEO_CHUNK_HANGAR_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_HANGAR" )
	ShipGeoShow( file.malta, "GEO_CHUNK_BRIDGE" )
	GetEntByScriptName( "MaltaSideClip" ).Solid()
	GetEntByScriptName( "MaltaSideClip" ).kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS//this it shootable but not have phys collision
	DeleteTrinity()
}

void function MaltaGuns_Main( entity player )
{
	Objective_WayPointEneable( false )
	bool silent = true
	MaltaGunsObjective( silent )

	file.airBattleData = GetAirBattleStructMaltaGuns()

	FlagInit( "malta_gun1Clear" )
	FlagInit( "malta_gun2Clear" )
	FlagInit( "malta_gun3Clear" )
	FlagInit( "wallrungapVO" )
	FlagInit( "gunrackline_playerOnGun1" )
	FlagInit( "gunrackline_playerOnGun2" )
	FlagInit( "gunrackline_playerOnGun3" )

	CheckPoint()

	LiftStruct liftData = file.malta.lifts[ REALDRONELIFT ][0]
	WaitSignal( liftData.lift, "LiftDoneMoving" )

	float amplitude = 0.5
	float frequency = 100
	float duration = 1.0
	float radius = 2048
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )

	//liftData.lift.SetParent( GetEntByScriptName( "GEO_CHUNK_BACK" ), "", true, 0 )

	ShipGeoHide( file.malta, "GEO_CHUNK_HANGAR_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_HANGAR" )

	delaythread( CAGEDOORDELAY + 0.2 ) FlagSet( "MaltaLiftDoorsOpen" )

	CleanupScript( "scr_malta_node_1" )
	MaltaGuns_WidowPrepare()

	//reposition the trinity
	LocalVec pos = CLVec( V_MALTADRONE_MALTA.v + < 10000, -5000, 500 > )
	entity trinityMover = file.trinity.mover
	trinityMover.NotSolid()
	file.trinity.model.NotSolid()
	trinityMover.NonPhysicsStop()
	SetOriginLocal( trinityMover, pos )
	trinityMover.SetAngles( CONVOYDIR )
	thread TrinityHangarDoorsClose( "trinity_hangardoorLT2", "trinity_hangardoorLB2", "trinityLeftHangarDoor2", true )
	thread TrinityHangarDoorsClose( "trinity_hangardoorLT", "trinity_hangardoorLB", "trinityLeftHangarDoor1", true )
	ShipGeoHide( file.trinity, "TRINITY_CHUNK_INTERIOR_FAKE" )

	//move it away
	pos.v += < 4000, 0, 500 >
	vector bounds = <1000, 500, 300>
	thread ShipIdleAtTargetPos( file.trinity, pos, bounds )

	//keep the malta completely still
	thread ShipFlyToPos( file.malta, GetOriginLocal( file.malta.mover ) )

	//spawn the dude face
	thread MaltaGuns_WindowGuy()

	waitthreadsolo MaltaGuns_WaitToDoTrinityMoment()

	//move malta away as the the boss guys by
	thread ShipFlyToPos( file.malta, WorldToLocalOrigin( file.malta.mover.GetOrigin() + < -3000,0,0> ) )
	delaythread( 0.5 ) MaltaGuns_TrinityVO()
	//put malta back on track after delay
	delaythread( 4.0 ) ShipFlyToPos( file.malta, WorldToLocalOrigin( file.malta.mover.GetOrigin() + < 3000,0,0> ) )
	delaythread( 4.0 ) ResetMaxRoll( file.malta )
	delaythread( 7.0 ) ShipIdleAtTargetPos( file.malta, V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )

	//clean up drone bay
	array<entity> guys = GetNPCArrayByScriptName( "malta_introGuys1" )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys1_react1" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys1_react2" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_pistolGuys" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys2" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys2a" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys2b" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_introGuys3" ) )
	guys.extend( GetNPCArrayByScriptName( "droneRoomSpectre1" ) )
	guys.extend( GetNPCArrayByScriptName( "droneRoomSpectre2" ) )
	guys.extend( GetNPCArrayByScriptName( "malta_liftGuy1" ) )
	foreach( guy in guys )
		guy.Destroy()

	ClearDroppedWeapons()

	FlagWait( "MaltaGunsEnter" )
	file.maltaRunnersComplete = 0

	file.bear.SetNoTarget( true )
	file.gates.SetNoTarget( true )
	file.davis.SetNoTarget( true )
	file.droz.SetNoTarget( true )

	thread MaltaGuns_CrewAccuracy()
	thread MaltaGuns_CrowThink()

	//setup the dudes at the guns
	string spawners, endflag, onFlag, deadFlag, killFlag
	entity gun

	spawners = "malta_gunGuys1"
	endflag = "malta_gunGuys1React"
	onFlag 	= "playerOnGun1"
	deadFlag = "malta_gunGunner1Down"
	killFlag = "playerOnGun2"
	gun = GetEntByScriptName( "maltaGunTurret1" )
	MaltaGun_ArenaThink( spawners, endflag, onFlag, gun, deadFlag, killFlag )

	spawners = "malta_gunGuys2"
	endflag = "malta_gunGuys2React"
	onFlag 	= "playerOnGun2"
	deadFlag = "malta_gunGunner2Down"
	killFlag = "playerOnGun3"
	gun = GetEntByScriptName( "maltaGunTurret2" )
	MaltaGun_ArenaThink( spawners, endflag, onFlag, gun, deadFlag, killFlag )

	spawners = "malta_gunGuys3"
	endflag = "malta_gunGuys3React"
	onFlag 	= "playerOnGun3"
	deadFlag = "malta_gunGunner3Down"
	killFlag = "malta_gunGunner3Down"
	gun = GetEntByScriptName( "maltaGunTurret3" )
	MaltaGun_ArenaThink( spawners, endflag, onFlag, gun, deadFlag, killFlag )

	//wait for some action
	thread MaltaGuns_HardBank( file.malta )
	thread MaltaGuns_KillStraglers()
	thread MaltaGunsKillEvents( "malta_gunGuys1", ["gunsStalker1", "Gun1ReinforcementGuys" ], "malta_gun1Clear" )
	thread MaltaGunsKillEvents( "malta_gunGuys2", ["gunsStalker2", "gunsStalker3", "Gun2ReinforcementGuys" ], "malta_gun2Clear" )
	thread MaltaGunsKillEvents( "malta_gunGuys3", ["gunsStalker4"], "malta_gun3Clear" )
	thread MaltaGuns_CrowEnder()
	thread MaltaGuns_MoveAirBattle()

	FlagSetOnFlag( "malta_gunGuys2React", "malta_gunGuys1React", 4.0 )
	FlagSetOnFlag( "malta_gunGuys2React", "malta_gunGuys3React", 4.0 )
	thread Gun1Reinforcement()
	thread Gun2Reinforcement()
	thread Gun1_Objective_Update()
	thread Gun2_Objective_Update()
	thread Gun3_Objective_Update()

	FlagWaitAny( "malta_gunGuys1React", "malta_gunGuys2React", "malta_gunGuys3React" )
	FlagSet( "PlayingGunsMusic" )
	StopMusic()
	PlayMusic( "music_s2s_04_maltabattle_alt" )

	FlagWaitAll( "malta_gun1Clear", "malta_gun2Clear", "malta_gun3Clear" )
	FlagSet( "MaltaGunsClear" )

	CheckPointData data
	data.additionalCheck = MakeSurePlayerIsInMaltaGunsArea
	CheckPoint( data )

	StopMusic()
	PlayMusic( "music_s2s_04a_maltabattle_alt_end")

 	wait 0.5

 	//“I think that's all of them
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS266_01_01_mcor_davis", file.player )
 	//“I got no hostiles in sight
 	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS265_01_01_mcor_gates", file.player )

 	file.bear.SetNoTarget( false )
	file.gates.SetNoTarget( false )
	file.davis.SetNoTarget( false )
	file.droz.SetNoTarget( false )
}

void function MaltaGuns_CrewAccuracy()
{
	file.bear.kv.AccuracyMultiplier = 0.5
	file.gates.kv.AccuracyMultiplier = 0.5
	file.davis.kv.AccuracyMultiplier = 0.5
	file.droz.kv.AccuracyMultiplier = 0.5

	FlagWaitAny( "playerOnGun1", "playerOnGun2", "playerOnGun3" )

	file.bear.kv.AccuracyMultiplier = 1.0
	file.gates.kv.AccuracyMultiplier = 1.0
	file.davis.kv.AccuracyMultiplier = 1.0
	file.droz.kv.AccuracyMultiplier = 1.0
}

void function Gun1_Objective_Update()
{
	FlagEnd( "MaltaGunsClear" )

	FlagWait( "malta_gun1Clear" )
	wait 0.1

	if ( !Flag( "malta_gun2Clear" ) )
	{
		Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret2" ) )
		Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret2" ) )

		if ( !Flag( "malta_gun3Clear" ) )
			Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret3" ) )
	}
	else
		Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret3" ) )
}

void function Gun2_Objective_Update()
{
	FlagEnd( "MaltaGunsClear" )

	FlagWait( "malta_gun2Clear" )
	wait 0.1

	if ( !Flag( "malta_gun1Clear" ) )
	{
		Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret1" ) )
		Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret1" ) )

		if ( !Flag( "malta_gun3Clear" ) )
			Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret3" ) )
	}
	else
		Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret3" ) )
}

void function Gun3_Objective_Update()
{
	FlagEnd( "MaltaGunsClear" )

	FlagWait( "malta_gun3Clear" )
	wait 0.1

	if ( !Flag( "malta_gun2Clear" ) )
	{
		Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret2" ) )
		Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret2" ) )

		if ( !Flag( "malta_gun1Clear" ) )
			Objective_AddHighlightEntity( GetEntByScriptName( "maltaGunTurret1" ) )
	}
	else
		Objective_SetSilent( "#S2S_OBJECTIVE_CLEARGUNS", <0,0,0>, GetEntByScriptName( "maltaGunTurret1" ) )
}

void function Gun1Reinforcement()
{
	FlagWait( "malta_gunGuys2React" )

	//is the player down yet?
	if ( Flag( "playerOnGun1" ) )
		return
	if ( Flag( "playerOnGun2" ) )
		return
	if ( Flag( "playerOnGun3" ) )
		return

	SpawnOnShipFromScriptName( "Gun1ReinforcementGuys", file.malta )
}

void function Gun2Reinforcement()
{
	FlagWait( "malta_gunGuys2React" )
	SpawnOnShipFromScriptName( "Gun2ReinforcementGuys", file.malta )
}

void function MaltaGuns_WidowPrepare()
{
	entity maltaRef = file.malta.mover
	vector bounds 	= <0, 0, 0>//<50, 50, 50>
	entity node 	= GetEntByScriptName( "maltawidowrunRef" )
	vector delta 	= GetRelativeDelta( node.GetOrigin(), maltaRef )
	vector offset 	= MALTAWIDOW_WIDOW_OFFSET_PRE

	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, maltaRef, bounds, delta, offset )
}

void function MaltaGuns_MoveAirBattle()
{
	FlagWait( "malta_gunGuys1React" )

	float time = 30
	NonPhysicsMoveToLocal( file.airBattleNode, V_MALTAWIDOW_AIRBATTLE, time, time * 0.5, time * 0.5 )

	wait time
	thread UpdatePosWithLocalSpace( file.airBattleNode )
}

void function MaltaGuns_CrowEnder()
{
	FlagWait( "playerOnGun3" )

	ShipGeoShow( file.malta, "GEO_CHUNK_BRIDGE" )

	MaltaWidow_ZipPosition()
}

float function GetBankMagnitudeGoblinTight( float dist )
{
	return GraphCapped( dist, 0, 300, 0.0, 1.0 )
}

void function MaltaGuns_WindowGuy()
{
	array<entity> guys = SpawnOnShipFromScriptName( "gunsWindowGuy", file.malta )

	entity guy = guys[0]
	guy.EndSignal( "OnDeath" )

	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.SetNoTarget( true )

	WaitFrame()

	vector angles = guy.GetAngles()
	vector origin = HackGetDeltaToRefOnPlane( guy.GetOrigin(), angles, guy, "pt_s2s_trinity_railing_R", file.malta.model.GetUpVector() )
	vector delta = GetRelativeDelta( origin, file.malta.model )
	float initialTime = 3.6
	thread PlayAnimTeleport( guy, "pt_s2s_trinity_railing_R", origin, angles, initialTime )

	float duration = guy.GetSequenceDuration( "pt_s2s_trinity_railing_R" )
	guy.SetDamageNotifications( true )
	RegisterSignal( "lookback" )
	SetSignalDelayed( guy, "lookback", duration - 0.2 - initialTime )

	WaitSignal( guy, "OnDamaged", "lookback" )

	guy.DisableNPCFlag( NPC_IGNORE_ALL )
	guy.SetNoTarget( false )
//	guy.Anim_Stop()
	origin = GetWorldOriginFromRelativeDelta( delta, file.malta.model )
	thread PlayAnim( guy, "pt_s2s_trinity_railing_R_react", origin, angles )

	guy.SetEnemy( file.player )
//	guy.SetDefaultSchedule( "SCHED_REACT_SURPRISED" )
	guy.SetEnemyLKP( file.player, file.player.GetOrigin() )
}

void function MaltaGunsKillEvents( string guyNames, array<string> spectreNames, string killFlag )
{
	//check seperatly from spectres because spectres spawning depends on grunts living
	array<entity> guys = GetNPCArrayByScriptName( guyNames )
	waitthread WaitUntilAllDead( guys )

	//now check the spectres
	guys = []
	foreach ( name in spectreNames )
		guys.extend( GetNPCArrayByScriptName( name, TEAM_IMC ) )
	waitthread WaitUntilAllDeadOrLeeched( guys )

	FlagSet( killFlag )
}

void function MaltaGuns_KillStraglers()
{
	FlagEnd( "MaltaGunsClear" )

	array<entity> guys

	//wait for platform 3 to die
	FlagWait( "malta_gun3Clear" )

	//player standing on 3
	FlagWait( "playerOnGun3" )

	OnThreadEnd(
	function() : (  )
		{
			file.gates.DisableNPCFlag( NPC_IGNORE_ALL )
		}
	)
	file.gates.EnableNPCFlag( NPC_IGNORE_ALL )

	wait 1.0

	guys = GetNPCArrayByScriptName( "malta_gunGuys2" )
	guys.extend( GetNPCArrayByScriptName( "gunsStalker2", TEAM_IMC ) )
	guys.extend( GetNPCArrayByScriptName( "gunsStalker3", TEAM_IMC ) )
	guys.extend( GetNPCArrayByScriptName( "gunsStalker1", TEAM_IMC ) )
	guys.extend( GetNPCArrayByScriptName( "malta_gunGuys1", TEAM_IMC ) )
	guys.extend( GetNPCArrayByScriptName( "Gun1ReinforcementGuys", TEAM_IMC ) )
	guys.extend( GetNPCArrayByScriptName( "Gun2ReinforcementGuys", TEAM_IMC ) )
	guys.extend( GetNPCArrayByScriptName( "gunsWindowGuy", TEAM_IMC ) )

	guys = ArrayFarthest( guys, file.player.GetOrigin() )
	array<entity> targets
	foreach ( guy in guys )
	{
		if ( IsStalker( guy ) && Distance2D( guy.GetOrigin(), file.player.GetOrigin() ) < 540 )
		{
			continue
		}
		else if ( PlayerCanSee( file.player, guy, true, 45 ) )
		{
			targets.append( guy )
			continue
		}
		else
		{
			guy.TakeDamage( guy.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.mp_weapon_dmr } )
		}
	}

	entity weapon = file.gates.GetActiveWeapon()
	WeaponPrimaryAttackParams attackParams
	int attachID = weapon.LookupAttachment( "muzzle_flash" )

	foreach ( guy in targets )
	{
		if ( IsStalker( guy ) && Distance2D( guy.GetOrigin(), file.player.GetOrigin() ) < 540 )
			continue

		attackParams.pos = weapon.GetAttachmentOrigin( attachID )
		attackParams.dir = Normalize( guy.GetOrigin() + <0,40,0> - attackParams.pos )
		OnWeaponNpcPrimaryAttack_weapon_DMR( weapon, attackParams )
		EmitSoundOnEntity( guy, "Weapon_DMR_Fire_NPC" )
		guy.TakeDamage( guy.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.mp_weapon_dmr } )

		wait 0.25
	}
}

void function MaltaGuns_HardBank( ShipStruct malta )
{
	FlagWait( "playerOnGun2" )

	FlagWaitWithTimeout( "playerOnGun3", 13 )

	while( 1 )
	{
		FlagWaitClear( "PlayerWallRunning" )
		try
		{
		if ( !file.player.IsOnGround() )
			file.player.WaitSignal( "PME_TouchGround" )
		else
			break
		}
		catch( exception )
		{
			Chat_ServerBroadcast( "smth broke in MaltaGuns_HardBank" )
			break
		}
	}

	if ( Flag( "playerOnGun3" ) )
		wait 1.5

	if ( !file.player.IsOnGround() )
		file.player.WaitSignal( "PME_TouchGround" )

	if ( Flag( "MaltaGunsClear" ) )
		return

	float amplitude = 20
	float frequency = 150
	float duration = 2.0
	float radius = 2048
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )
	EmitSoundOnEntity( file.player, "scr_s2s_malta_ship_impact_01" )

	vector angles = <0,0,0>

	SyncedStumble( angles )
}

void function MaltaGun_ArenaThink( string spawners, string endflag, string onFlag, entity gun, string deadFlag, string killFlag )
{
	array<entity> guys = SpawnOnShipFromScriptName( spawners, file.malta )

	foreach( guy in guys )
	{
		if ( guy.HasKey( "script_noteworthy" ) && guy.kv.script_noteworthy == "gunner" )
		{
			thread KillGuyOnFlag( guy, killFlag )
	 		thread MaltaGuns_GuyGunnerThink( guy, file.malta, endflag, deadFlag, gun )
		}
	 	else
	 		thread MaltaGuns_GuyThink( guy, file.malta, endflag, onFlag )
	}
}

void function KillGuyOnFlag( entity guy, string killFlag )
{
	guy.EndSignal( "OnDeath" )

	FlagWait( killFlag )
	guy.Die()
}

void function MaltaGuns_GuyGunnerThink( entity guy, ShipStruct ship, string endflag, string deadFlag, entity gun )
{
	if ( !IsValid( guy ) )
	{
		FlagSet( deadFlag )
		return
	}
	
	guy.EndSignal( "OnDeath" )
	guy.SetAllowMelee( false )
	guy.SetCanBeMeleeExecuted( false )
	//guy.SetModel( $"models/robots/spectre/imc_spectre.mdl" )
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
  	guy.SetNoTarget( true )

  	int health = guy.GetHealth()
	guy.SetMaxHealth( 1 )
	guy.SetHealth( 1 )

	OnThreadEnd(
	function() : ( guy, endflag, deadFlag )
		{
			delaythread( 0.25 ) FlagSet( deadFlag )
			FlagSet( endflag )
		}
	)
	WaitFrame()

	AddEntityCallback_OnDamaged( guy, MaltaGuns_GuyOnDamage )
	guy.SetDamageNotifications( true )

	guy.SetParent( gun, "ATTACH" )
	guy.Anim_ScriptedPlay( "pt_maltagun_crew_idle" )

	SetDeathFuncName( guy, "MaltaGuns_GunnerDeathAnim" )

	int attachID = guy.LookupAttachment( "HEADFOCUS" )
	while( 1 )
	{
		wait 0.1

		if ( !IsAlive( file.player) )
			continue

		if ( Distance( guy.GetOrigin(), file.player.GetOrigin() ) > 140 )
			continue

		vector guyAngles = guy.GetAttachmentAngles( attachID )
		vector guyFor = AnglesToForward( guyAngles )

		vector vec2P = Normalize( file.player.GetOrigin() - guy.GetOrigin() )

		float dot = DotProduct( guyFor, vec2P )
		printt( dot )
		if ( dot > -0.75 )
			break
	}

	gun.Signal( "GunnerReact" )

	wait 0.5

	ClearDeathFuncName( guy )
	guy.SetMaxHealth( health )
	guy.SetHealth( health )
	guy.Anim_ScriptedPlay( "pt_maltagun_crew_react" )

	WaittillAnimDone( guy )
	guy.ClearParent()

	guy.SetAllowMelee( true )
	guy.SetCanBeMeleeExecuted( true )
	guy.DisableNPCFlag( NPC_IGNORE_ALL )
  	guy.SetNoTarget( false )

  	guy.WaitSignal( "OnDeath" )
}

void function MaltaGuns_GunnerDeathAnim( entity guy )
{
	if ( IsValid( guy ) )
	{
		guy.Anim_Stop()
		guy.NotSolid()
		guy.Anim_ScriptedPlay( "pt_maltagun_crew_death" )
		wait 20
	}
}

void function MaltaGuns_GuyThink( entity guy, ShipStruct ship, string endflag, string onFlag )
{
	if ( !FlagExists( endflag ) )
		FlagInit( endflag)
	Assert( !Flag( endflag ) )

	guy.EndSignal( "OnDeath" )
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
  	guy.SetNoTarget( true )
	FlagEnd( endflag )

	entity node = CreateScriptMover()

	OnThreadEnd(
	function() : ( guy, endflag, onFlag, node )
		{
			delaythread( 0.75 ) FlagSet( endflag )
			if ( IsValid( guy ) )
				guy.ClearParent()
			if ( IsValid( node ) )
				node.Destroy()

			if( IsAlive( guy ) )
			{
				guy.DisableNPCFlag( NPC_IGNORE_ALL )
  				guy.SetNoTarget( false )
				guy.Anim_Stop()
				entity button = guy.GetLinkEnt()
				if ( IsValid( button ) && GetEditorClass( button ) == "script_switch" )
					thread MaltaGuns_ReactSpectreRackThink( guy, button, onFlag )
				else
					thread MaltaGuns_ReactThink( guy )
			}
		}
	)
	WaitFrame()

	vector origin = HackGetDeltaToRefOnPlane( guy.GetOrigin(), guy.GetAngles(), guy, "pt_bored_idle_console_A", file.malta.model.GetUpVector() )
	node.SetOrigin( origin )
	node.SetAngles( guy.GetAngles() )
	node.SetParent( file.malta.mover, "", true, 0 )
	guy.SetParent( node )

	thread PlayAnimTeleport( guy, "pt_bored_idle_console_A", node )

	AddEntityCallback_OnDamaged( guy, MaltaGuns_GuyOnDamage )
	guy.SetDamageNotifications( true )

	WaitSignal( guy, "ShouldReact" )
}

void function MaltaGuns_GuyOnDamage( entity guy, var damageInfo )
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	if ( IsValid( weapon ) && weapon.GetWeaponClassName() == "sp_weapon_swarm_rockets_s2s" )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	guy.Signal( "ShouldReact" )
}

void function MaltaGuns_ReactThink( entity guy )
{
	guy.EndSignal( "OnDeath" )

	//schedule names in common_schedules.txt
	guy.SetEnemy( file.player )
	guy.SetDefaultSchedule( "SCHED_REACT_SURPRISED" )
	guy.SetEnemyLKP( file.player, file.player.GetOrigin() )

	wait 2.0

	guy.ClearEnemy()
}

void function MaltaGuns_ReactSpectreRackThink( entity guy, entity button, string onFlag )
{
	guy.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : ( guy )
		{
			file.maltaRunnersComplete++
			Signal( svGlobal.levelEnt, "maltaRunnersComplete" )
		}
	)

	//schedule names in common_schedules.txt
	guy.SetEnemy( file.player )
	guy.SetDefaultSchedule( "SCHED_REACT_SURPRISED" )
	guy.SetEnemyLKP( file.player, file.player.GetOrigin() )

	wait 2.0

	guy.ClearEnemy()
	thread GruntRunsToAndActivatesSpectreRack( guy, button )

	wait 1.0

	string lineFlag = "gunrackline_" + onFlag
	if ( Flag( onFlag ) && file.gunRackLines < 2 && !Flag( lineFlag ) )
	{
		FlagSet( lineFlag )
		file.gunRackLines++

		if ( file.gunRackLines == 1 )
		{
			//"They're running for the stalker racks! Stop em!"
			thread PlayDialogue( "diag_sp_maltaGuns_STS249_01_01_mcor_droz", file.player )
		}
		else
		{
			//"He's going for the racks!"
			thread PlayDialogue( "diag_sp_maltaGuns_STS263_01_01_mcor_davis", file.player )
		}
	}
}

void function MaltaGuns_CrowThink()
{
	FlagInit( "malta_gunCrowMoveup1" )
	FlagInit( "malta_gunCrowMoveup2" )
	FlagInit( "malta_gunCrowMoveup3" )
	thread MaltaGuns_CrowVO()
	Assert( IsShipOnBattleField( file.crow64 ) )

	entity maltaRef = file.malta.mover
	entity node 	= GetEntByScriptName( "maltaGunsCrowNode" )
	vector pos 		= GetRelativeDelta( node.GetOrigin(), maltaRef )
	vector bounds 	= <400,300,200>
	vector offset 	= <1800, -750, 0>
	thread ShipIdleAtTargetEnt( file.crow64, maltaRef, bounds, pos, offset )

	FlagWait( "malta_gunCrowMoveup1" )
	node 	= GetEntByScriptName( "maltaGunsCrowAttack1" )
	thread MaltaGuns_CrowAttackPos( "playerOnGun1", node )

	FlagWait( "malta_gunCrowMoveup2" )
	node 	= GetEntByScriptName( "maltaGunsCrowAttack2" )
	thread MaltaGuns_CrowAttackPos( "playerOnGun2", node )
}

void function MaltaGuns_CrowAttackPos( string onFlag, entity node )
{
	if ( Flag( "MaltaGunsClear" ) )
		return
	FlagEnd( "MaltaGunsClear" )

	entity maltaRef = file.malta.mover

	while( !Flag( "playerOnGun3" ) )
	{
		FlagWait( onFlag )

		if ( Flag( "playerOnGun3" ) )
			return

		vector pos 		= GetRelativeDelta( node.GetOrigin(), maltaRef )
		thread ShipIdleAtTargetEnt( file.crow64, maltaRef, MALTAGUNS_CROW_BOUNDS, pos, MALTAGUNS_CROW_OFFSET )

		FlagWaitClear( onFlag )
	}
}

void function MaltaGuns_CrowVO()
{
	FlagWait( "MaltaGunsCrowVOGo" )

	thread MaltaGunsVO_platform1()
	thread MaltaGunsVO_platform2()
	thread MaltaGunsVO_platform3()

	FlagInit( "malta_gunGuysReacted" )
	FlagSetOnFlag( "malta_gunGuysReacted", "malta_gunGuys1React" )
	FlagSetOnFlag( "malta_gunGuysReacted", "malta_gunGuys2React" )
	FlagSetOnFlag( "malta_gunGuysReacted", "malta_gunGuys3React" )
	FlagWaitWithTimeout( "malta_gunGuysReacted", 3.0 )

	if ( !Flag( "malta_gunGuysReacted" ) )
	{
		//“Cooper, we can't move up while those guns are firing. Take out the gunner and we'll help you with the last t
 		waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS242_01_01_mcor_crowCptn", file.player )
 		FlagWait( "malta_gunGuysReacted" )
 	}
}

void function MaltaGunsVO_platform1()
{
	if ( Flag( "MaltaGunsClear" ) )
		return
	FlagEnd( "MaltaGunsClear" )

	FlagWait( "malta_gunGuys1React" )
	wait 0.5

	array<entity> guys = GetNPCArrayByScriptName( "malta_gunGuys1" )
	if ( guys.len() )
	{
		entity guy = ArrayFarthest( guys, file.player.GetOrigin() )[ 0 ]

		//“Contact!”
		waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS243_01_01_imc_grunt1", guy )
		wait 1.0
	}

	//“Gun 1 is down!”
	if ( !Flag( "malta_gunGunner1Down" ) )
	{
		waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS246_01_01_mcor_davis", file.player )
		wait 1.0
	}
	FlagSet( "malta_gunCrowMoveup1" )

	FlagWait( "malta_gun1Clear" )
	if ( Flag( "malta_gunCrowMoveup2" ) )
		return

	//“Gun one is clear, keep going!”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS251_01_01_mcor_crowCptn", file.player )
	wait 1.0
}

void function MaltaGunsVO_platform2()
{
	if ( Flag( "MaltaGunsClear" ) )
		return
	FlagEnd( "MaltaGunsClear" )

	FlagWait( "malta_gunGuys2React" )
	wait 0.5

	array<entity> guys = GetNPCArrayByScriptName( "malta_gunGuys2" )
	if ( guys.len() )
	{
		entity guy = ArrayFarthest( guys, file.player.GetOrigin() )[ 0 ]

		//“Hostile on the Gun platform!”
		waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS244_01_01_imc_grunt2", guy )
		wait 1.0
	}

	FlagSet( "malta_gunCrowMoveup2" )

	FlagWait( "malta_gun2Clear" )
	wait 1.0

	//“Gun two is down, Get the last one!”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS259_01_01_mcor_crowCptn", file.player )
}

void function MaltaGunsVO_platform3()
{
	if ( Flag( "MaltaGunsClear" ) )
		return
	FlagEnd( "MaltaGunsClear" )

	FlagWait( "malta_gunGunner3Down" )
	wait 0.5

	array<entity> guys = GetNPCArrayByScriptName( "malta_gunGuys3" )
	if ( guys.len() )
	{
		entity guy = ArrayFarthest( guys, file.player.GetOrigin() )[ 0 ]

		//“We're taking fire! Take cover!”
		waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS245_01_01_imc_grunt3", guy )
		wait 1.0
	}

	//“Gun 3 is down!”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS261_01_01_mcor_gates", file.player )
	FlagSet( "malta_gunCrowMoveup3" )

	wait 0.5
	//“That's it clean em up!”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS262_01_01_mcor_crowCptn", file.player )
}

void function Trinity_Explode()
{
	GetEntByScriptName( "MaltaSideClip" ).Solid() //the boss missiles should be passed by now
	GetEntByScriptName( "MaltaSideClip" ).kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS//this it shootable but not have phys collision
	FlagSet( "TrinityDown" )

	ShipStruct trinity = file.trinity
	entity mover = trinity.mover
	entity model = trinity.model

	entity decoyShip = CreateEntity( "script_mover" )
	decoyShip.kv.solid = 0
	decoyShip.SetModel( MILITIA_DECOY_SHIP_MODEL )
	decoyShip.kv.SpawnAsPhysicsMover = 0
	DispatchSpawn( decoyShip )

	decoyShip.SetOrigin( model.GetOrigin() )
	decoyShip.SetAngles( model.GetAngles() )
	LocalVec startOrigin = WorldToLocalOrigin( model.GetOrigin() )

	Ship_CleanDelete( trinity )
	SetOriginLocal( decoyShip, startOrigin )

	vector fwd = decoyShip.GetForwardVector()
	vector pos = GetOriginLocal( decoyShip ).v + < 0, -80000, -10000 >
	LocalVec shipEndPos = CLVec( pos )

	EmitSoundOnEntity( decoyShip, "Hermes_Explode_Temp" )
	if ( !Flag( "PlayingGunsMusic" ) )
	{
		StopMusic()
		PlayMusic( "music_s2s_07_shipexplode" )
	}

	string attachAlias = "Explosion_LG_Impact"
	int attachID = decoyShip.LookupAttachment( attachAlias )
	vector attachOrg = decoyShip.GetAttachmentOrigin( attachID )

	//Main Death Explosion
	entity destroyFX = StartParticleEffectOnEntity( decoyShip, GetParticleSystemIndex( FX_DECOY_SHIP_DESTRUCTION ), FX_PATTACH_POINT_FOLLOW, attachID )

	string crashAnim = "s2s_trinity_destroyed_explode"
	float animtime = 20//decoyShip.GetSequenceDuration( crashAnim )
	thread PlayAnim( decoyShip, crashAnim, decoyShip )

	//decoyShip.NonPhysicsMoveTo( shipEndPos, animtime, 0, 0 )
	NonPhysicsMoveToLocal( decoyShip, shipEndPos, animtime, 15, 0 )

	wait animtime - 4

	if ( IsValid( decoyShip ) )
		decoyShip.Destroy()
}

void function MaltaGuns_WaitToDoTrinityMoment()
{
	FlagEnd( "MaltaGunsEnter" )

	LiftStruct liftData = file.malta.lifts[ REALDRONELIFT ][0]

	while( liftData.liftState != eLiftState.TOP )
		WaitSignal( liftData, "UpdateLiftState" )
}

void function MaltaGuns_TrinityVO()
{
	FlagEnd( "playerOnGun1" )

	OnThreadEnd(
	function() : (  )
		{
			CheckPoint()
			float interval = 45
			CheckPointLoop( interval, "MaltaGunsClear" )

			FlagSet( "MaltaGunsCrowVOGo")
			thread MaltaGunsCheckPointHandler( interval, "malta_gun1Clear" )
			thread MaltaGunsCheckPointHandler( interval, "malta_gun2Clear" )
			thread MaltaGunsCheckPointHandler( interval, "malta_gun3Clear" )
		}
	)

	wait 0.5

	//“The jump drive is ruptured! abandon ship! aba...”
	thread PlayDialogue( "diag_sp_maltaGuns_STS240_01_01_mcor_seyedCptn", file.player )
	wait 2.5

	StopSoundOnEntity( file.player, "diag_sp_maltaGuns_STS240_01_01_mcor_seyedCptn" )
	thread Trinity_Explode()

	wait 5.0
	//We lost the Braxton! Stay the course!!
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS241_01a_01_mcor_sarah", file.player )
	wait 1.0
}

void function MaltaGunsCheckPointHandler( float interval, string waitFlag )
{
	if ( Flag( "MaltaGunsClear") )
		return
	FlagEnd( "MaltaGunsClear" )

	FlagWait( waitFlag )
	CheckPoint()
	CheckPointLoop( interval, "MaltaGunsClear" )
}

/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗      ██████╗ ██╗   ██╗███╗   ██╗███████╗    ████████╗███████╗ ██████╗██╗  ██╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██╔════╝ ██║   ██║████╗  ██║██╔════╝    ╚══██╔══╝██╔════╝██╔════╝██║  ██║
██╔████╔██║███████║██║     ██║   ███████║    ██║  ███╗██║   ██║██╔██╗ ██║███████╗       ██║   █████╗  ██║     ███████║
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██║   ██║██║   ██║██║╚██╗██║╚════██║       ██║   ██╔══╝  ██║     ██╔══██║
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ╚██████╔╝╚██████╔╝██║ ╚████║███████║       ██║   ███████╗╚██████╗██║  ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝       ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝

\************************************************************************************************/
void function MaltaSideGunsRandomFire()
{
	entity gun1 	= GetEntByScriptName( "maltaGunTurret1" )
	entity gun2 	= GetEntByScriptName( "maltaGunTurret2" )
	entity gun3 	= GetEntByScriptName( "maltaGunTurret3" )

	thread MaltaSideGunAimThink( gun1, "malta_gunGunner1Down" )
	thread MaltaSideGunAimThink( gun2, "malta_gunGunner2Down" )
	thread MaltaSideGunAimThink( gun3, "malta_gunGunner3Down" )
}


void function MaltaSideGunAimThink( entity gun, string endflag )
{
	FlagEnd( endflag )
	gun.EndSignal( "GunnerReact" )

	entity node1 	= gun.GetParent()

	OnThreadEnd(
	function() : ( gun )
		{
			//move gun back to zero position
			int yawID 		= gun.LookupPoseParameterIndex( "aim_yaw" )
			int pitchID 	= gun.LookupPoseParameterIndex( "aim_pitch" )
			gun.SetPoseParameterOverTime( pitchID, 0, 1.0 )
			gun.SetPoseParameterOverTime( yawID, 0, 1.0 )
		}
	)

	thread PlayAnim( gun, "s2s_malta_gun_idle", node1, "REF" )

	int fxID = GetParticleSystemIndex( CANNON_FX )
	int attachID = gun.LookupAttachment( "muzzle_flash" )

	while( 1 )
	{
		if ( Flag( "TrinityDown" ) )
		{
			float x = RandomFloatRange( 0, 2 )
			float y = RandomFloatRange( 10, 20 )

			if ( CoinFlip() )
				x *= -1.0
			if ( CoinFlip() )
				y *= -1.0

			vector angles = <x,y,0>
			vector dir = AnglesToForward( angles )

			thread MaltaSideGunAimAtThink( gun, endflag, dir )
		}
		else
		{
			vector origin1 = gun.GetAttachmentOrigin( attachID )
			vector origin2 = file.trinity.mover.GetOrigin()
			vector origin3 = < origin2.x, origin1.y, origin2.z >
			vector dir = Normalize( origin3 - origin1 )
			thread MaltaSideGunAimAtThink2( gun, endflag, dir )
		}

		wait RandomFloatRange( 2.5, 4.5 )

		int num = RandomInt( 5 ) + 5
		for ( int i = 0; i < num; i++ )
		{
			StartParticleEffectOnEntity( gun, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
			delaythread( 0.4 ) MaltaSideGunImpact( gun.GetAttachmentOrigin( attachID ), gun.GetAttachmentAngles( attachID ) )

			if ( Flag( "MaltaLiftDoorsOpen" ) )
				EmitSoundOnEntity( gun, "o2_core_meltdown_explosion" )
			else
				EmitSoundOnEntity( gun, "s2s_scr_malta_guns_muffled_01" )

			thread PlayAnim( gun, "s2s_malta_gun_fire", node1, "REF" )
			wait 0.5
		}
		WaittillAnimDone( gun )

		EmitSoundOnEntity( gun, "s2s_scr_malta_guns_reload" )

		thread PlayAnim( gun, "s2s_malta_gun_idle", node1, "REF" )

		wait 0.5
	}

}

void function MaltaSideGunImpact( vector pos, vector angles )
{
	if ( Flag( "TrinityDown" ) )
		return

	vector dir = AnglesToForward( AnglesCompose( angles, <0,-5,0>) )
	array<entity> ignore
	foreach ( ship in file.dropships[ TEAM_MILITIA ] )
	{
		if ( IsValid( ship.model ) )
			ignore.append( ship.model )
	}
	foreach ( ship in file.dropships[ TEAM_IMC ] )
	{
		if ( IsValid( ship.model ) )
			ignore.append( ship.model )
	}

	vector start = pos + dir * 1000
	vector end = pos + dir * 50000
	TraceResults traceResult = TraceLine( start, end, ignore, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	if ( traceResult.fraction < 1.0 )
	{
		vector origin = traceResult.endPos + dir * -200
		int fxID = GetParticleSystemIndex( CANNON_IMPACT )
		StartParticleEffectInWorld( fxID, origin, CONVOYDIR )
	}
}

void function MaltaSideGunAimAtThink2( entity gun, string endflag, vector dir )
{
	FlagEnd( endflag )
	gun.EndSignal( "GunnerReact" )
	gun.Signal( "MaltaSideGunAimAtThink" )
	gun.EndSignal( "MaltaSideGunAimAtThink" )

	int yawID 		= gun.LookupPoseParameterIndex( "aim_yaw" )
	int pitchID 	= gun.LookupPoseParameterIndex( "aim_pitch" )

	while( 1 )
	{
		vector forward = gun.GetForwardVector()
		float dot = DotProduct( forward, dir )
		float pitch = DotToAngle( dot )
		if ( DotProduct( forward, <0,0,1> ) < 0 )
			pitch *= -1.0

		gun.SetPoseParameterOverTime( pitchID, pitch * 2.0, 0.15 )

		WaitFrame()
	}
}

void function MaltaSideGunAimAtThink( entity gun, string endflag, vector dir )
{
	FlagEnd( endflag )
	gun.EndSignal( "GunnerReact" )
	gun.Signal( "MaltaSideGunAimAtThink" )
	gun.EndSignal( "MaltaSideGunAimAtThink" )

	int yawID 		= gun.LookupPoseParameterIndex( "aim_yaw" )
	int pitchID 	= gun.LookupPoseParameterIndex( "aim_pitch" )
	vector forward 	= < 1, 0, 0 >
	vector up 		= < 0,0,1 >
	vector right 	= < 0,-1,0 >

	float scalarUp 		= DotProduct( up, dir )
	float scalarRight 	= DotProduct( right, dir )
	float scalarForward = DotProduct( forward, dir )
	vector vecUp 		= Normalize( ( forward * scalarForward ) + ( up * scalarUp ) )
	vector vecRight 	= Normalize( ( forward * scalarForward ) + ( right * scalarRight ) )

	while( 1 )
	{
		float dotP 	= DotProduct( file.malta.model.GetRightVector(), vecUp )
		float pitch = min( DotToAngle( dotP ) * 2.0, 40 )

		float dotY 	= DotProduct( file.malta.model.GetRightVector(), vecRight )
		float yaw 	= min( DotToAngle( dotY ) * 2.0, 40 )

		if ( DotProduct( up, vecUp ) > 0 )
			pitch *= -1.0

		if ( DotProduct( right, vecRight ) > 0 )
			yaw *= -1.0

		float time = 2.0
		gun.SetPoseParameterOverTime( pitchID, pitch, time )
		gun.SetPoseParameterOverTime( yawID, yaw, time )

	//	printt( "P: " + pitch + ", Y: " + yaw )
	//	vector origin = gun.GetOrigin() + <0,0,220>
	//	DebugDrawLine( origin, origin + ( dir * 500 ), 255, 100, 100, true, FRAME_INTERVAL )
	//	DebugDrawLine( origin, origin + ( vecUp * 500 ), 100, 255, 100, true, FRAME_INTERVAL )
	//	DebugDrawLine( origin, origin + ( vecRight * 500 ), 100, 100, 255, true, FRAME_INTERVAL )

	//	DebugDrawLine( origin, origin + up * 200, 0, 255, 0, true, FRAME_INTERVAL )
	//	DebugDrawLine( origin, origin + right * 200, 0, 0, 255, true, FRAME_INTERVAL )
	//	DebugDrawLine( origin, origin + forward * 200, 255, 0, 0, true, FRAME_INTERVAL )

		wait 0.3
	}
}

/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗     ██╗    ██╗██╗██████╗  ██████╗ ██╗    ██╗         ██╗██╗   ██╗███╗   ███╗██████╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██║    ██║██║██╔══██╗██╔═══██╗██║    ██║         ██║██║   ██║████╗ ████║██╔══██╗
██╔████╔██║███████║██║     ██║   ███████║    ██║ █╗ ██║██║██║  ██║██║   ██║██║ █╗ ██║         ██║██║   ██║██╔████╔██║██████╔╝
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██║███╗██║██║██║  ██║██║   ██║██║███╗██║    ██   ██║██║   ██║██║╚██╔╝██║██╔═══╝
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ╚███╔███╔╝██║██████╔╝╚██████╔╝╚███╔███╔╝    ╚█████╔╝╚██████╔╝██║ ╚═╝ ██║██║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝     ╚══╝╚══╝ ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝      ╚════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝

\************************************************************************************************/
void function MaltaWidow_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-31000,0> )
	SetupShips_MaltaWidow()
	file.bear.kv.allowshoot = false

	SetOriginLocal( file.airBattleNode, V_MALTAWIDOW_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_WaitOnBarkerShip( bt, true )

	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart3" ) )

	delaythread( 1.0 ) FlagSet( "MaltaGunsClear" )
}

void function MaltaWidow_Skip( entity player )
{
	MaltaBreach_Objective()

	file.airBattleData = GetAirBattleStructMaltaWidow()
	array<entity> crew = SpawnSquad64()
	foreach ( guy in crew )
		Highlight_SetFriendlyHighlight( guy, "sp_friendly_hero" )
	
	NextState()
}

void function MaltaWidow_Main( entity player )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	file.airBattleData = GetAirBattleStructMaltaWidow()

	#if DEV
		if ( GetBugReproNum() == 5 )
		{
			MaltaWidow_DevTest()
		}
	#endif

	FlagWait( "MaltaGunsClear")
	thread Hangar_WaitToDoIntroIdles()

	Objective_Set( "#S2S_OBJECTIVE_RENDEZVOUS", <0,0,1> )
	entity marker = Objective_GetMarkerEntity()
	marker.SetOrigin( GetEntByScriptName( "maltaPlayerStart3" ).GetOrigin() )
	marker.SetParent( file.malta.mover )

	delaythread( 5 ) SetMaxRoll( file.malta, 15, 5 )
	delaythread( 10 ) SetMaxSpeed( file.malta, 24, 10 )
	delaythread( 10 ) SetMaxAcc( file.malta, 2.6, 10 )
	ShipIdleAtTargetPos( file.malta, 	V_MALTADRONE_MALTA, MALTAWIDOW_MALTA_BOUNDS )

	FlagInit( "Deploy64" )
	FlagInit( "WidowDeployGood" )
	FlagInit( "GoodShitConvoDone" )
	FlagInit( "WidowGatesDoTheTalking" )
	FlagInit( "WidowGatesStartTalking" )
	FlagInit( "WidowGatesDoneTalking" )

	EnableScript( file.malta, "scr_malta_node_3" )
	EnableScript( file.malta, "scr_malta_node_3b" )
	array<entity> spawners = GetEntArrayByScriptName( "hangar_fragDrones" )
	foreach ( spawner in spawners )
		spawner.Hide()

	FlagSet( "Deploy64" )

	thread MaltaWidow_DrozAfterLand()
	thread MaltaWidow_DavisAfterLand()
	thread MaltaWidow_GatesAfterLand()
	thread MaltaWidow_BearAfterLand()
	file.bear.kv.allowshoot = true

	thread MaltaWidow_CrowThink()
	thread MaltaWidow_WidowThink()

	StopMusic()
	PlayMusic( "music_s2s_08_ziplines" )

	thread MaltaWidow_VO( player )

	file.crow64.model.WaitSignal( "deploy" )
	FlagSet( "WidowDeployGood" )

	FlagWait( "GoodShitConvoDone" )
	FlagWait( "WidowGatesDoTheTalking" )
	FlagClear( "DriftWorldCenter" )

	CheckPointData data
	data.additionalCheck = MakeSurePlayerIsInMaltaGunsArea
	CheckPoint( data )

	// added stuff
	TeleportAllExceptOne( GetEntByScriptName( "maltaPlayerStart3" ).GetOrigin() + <0,0,50>, player )
	
	thread MaltaWidow_EndSection( player )

	NextState()
}

bool function MakeSurePlayerIsInMaltaGunsArea( entity player )
{
	return Flag( "PlayerInsideMaltaGunsArea" )
}

void function MaltaWidow_EndSection( entity player )
{
	FlagWait( "windowRunPositions" )
	player.kv.gravity = GRAVITYFRAC
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "s2s_widowrun" ] )

	MaltaWidow_BearPrepare()

	FlagWait( "DoTheWidowJump" )
	CheckPointData data
	data.additionalCheck = MakeSurePlayerIsInMaltaGunsArea
	data.searchTime = 2.0
	CheckPoint( data )

	thread MaltaWidow_TeamJump()
}

void function MaltaWidow_VO( entity player )
{
	//Cooper, stand by. The 6-4 are coming aboard.
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS274_03_01_mcor_sarah", player )

	//“Launching Ziplines!”
	//thread PlayDialogue( "diag_sp_maltaGuns_STS280_01_01_mcor_crowCptn", player )

	FlagWait( "WidowDeployGood" )

	//"There are still ion cannons active on the deck of the malta. They must be disabled from the bridge before we can approach."
	wait 0.5
	waitthreadsolo PlayBTDialogue( "diag_sp_maltaGuns_STS273_01_01_mcor_bt" )

	//we're on it
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS274_02_01_mcor_bear", player )
	wait 0.5

	FlagWait( "GoodShitConvoDone" )

	wait 0.5

	//“Commander Briggs, we'll also need your help.”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS278_01_01_mcor_bear", player )
	wait 0.5

	//“Copy that, Bear. On my way.”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS279_01_01_mcor_sarah", player )
	wait 0.5

	FlagSet( "WidowGatesDoTheTalking" )
}

void function MaltaWidow_DevTest()
{
	file.player.kv.gravity = GRAVITYFRAC

	file.bear.ClearParent()
	file.bear.Anim_Stop()
	file.gates.ClearParent()
	file.gates.Anim_Stop()
	file.droz.ClearParent()
	file.droz.Anim_Stop()
	file.davis.ClearParent()
	file.davis.Anim_Stop()

	entity maltaRef1 = file.malta.mover
	entity node 	= GetEntByScriptName( "maltawidowrunRef" )
	vector delta	= GetRelativeDelta( node.GetOrigin(), maltaRef1 )
	vector offset	= MALTAWIDOW_WIDOW_OFFSET
	vector bounds 	= <50, 0, 0>//<50, 50, 50>
	ShipIdleAtTargetEnt_Teleport( file.sarahWidow, maltaRef1, bounds, delta, offset )
	file.sarahWidow.model.Anim_Stop()
	wait 0.5
	thread PlayAnim( file.sarahWidow.model, "wd_doors_closed_idle", file.sarahWidow.mover )
	file.sarahTitan.Destroy()

	SetMaxSpeed( file.sarahWidow, 200 )
	SetMaxAcc( file.sarahWidow, 40 )
/*
	delaythread( 1.5 ) MaltaWidow_BearPrepare()
	delaythread( 1.5 ) MaltaWidow_GatesPrepare()
	delaythread( 1.5 ) MaltaWidow_DrozPrepare()
	delaythread( 1.5 ) MaltaWidow_DavisPrepare()
*/
	WaitForever()
}

void function MaltaWidow_DavisPrepare()
{
	entity maltaRef = file.malta.mover
	var anim 		= LoadRecordedAnimation( ANIM_widowJumpDavis_A )

	#if DEV
		if ( GetBugReproNum() == 5 )
		{
			vector origin 	= GetRecordedAnimationStartForRefPoint( anim, maltaRef.GetOrigin(), maltaRef.GetAngles() )
			file.davis.SetOrigin( origin )
			file.davis.SetAngles( <0,90,0> )
			WaitFrame()
		}
	#endif

	thread RunToRecordedAnimStart( file.davis, anim, <0,0,0>, <0,0,0>, maltaRef )
}

void function MaltaWidow_DrozPrepare()
{
	entity node = GetEntByScriptName( "widowjumpDroz1" )
	node.Destroy()

	#if DEV
		if ( GetBugReproNum() == 5 )
		{
			file.droz.SetOrigin( node.GetOrigin() )
			WaitFrame()
		}
	#endif

	entity anchor = CreateScriptMover()
	anchor.SetParent( file.malta.mover )
	anchor.SetLocalOrigin( < -2230, -1222, -110 > )
	anchor.SetLocalAngles( <0,0,0> )

	file.droz.ai.carryBarrel = anchor
	file.droz.AssaultPointToAnimSetCallback( "AnimCallback_ParentBeforeAnimating_MaltaWidow" )
	file.droz.AssaultPointToAnim( anchor.GetOrigin(), anchor.GetAngles(), "CQB_Crouch_Casual_B", true, 16.0 )
	file.droz.WaitSignal( "OnFinishedAssault" )
}

void function MaltaWidow_BearPrepare()
{
	entity start = GetEntByScriptName( "maltaGunsBearTalk" )


	#if DEV
		if ( GetBugReproNum() == 5 )
		{
			file.bear.SetOrigin( start.GetOrigin() )
			WaitFrame()
		}
	#endif
	vector angles = <0,80,0>
	vector origin = HackGetDeltaToRefOnPlane( start.GetOrigin(), angles, file.bear, "pt_generic_commander_turn_wave_a", file.malta.model.GetUpVector() )
	thread PlayAnimGravity( file.bear, "pt_generic_commander_turn_wave_a", origin, angles, 0.2 )
	float duration = file.bear.GetSequenceDuration( "pt_generic_commander_turn_wave_a" )
	wait duration - 0.2

	entity maltaRef = file.malta.mover
	entity node = GetEntByScriptName( "widowjumpbearprepare" )
	origin = HackGetDeltaToRefOnPlane( node.GetOrigin(), node.GetAngles(), file.bear, "run_2_stand_180R", file.malta.model.GetUpVector() )
	bool disableArrival = true
	bool disableAssaultAngles = true

	file.bear.EnableNPCMoveFlag( NPCMF_DISABLE_MOVE_TRANSITIONS )
	file.bear.EnableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )

	file.bear.SetMoveAnim( "pt_redeye_run_loop" )

	waitthread RunToAnimStartForced_Deprecated( file.bear, "run_2_stand_180R", origin, node.GetAngles(), disableArrival, disableAssaultAngles )

	origin = HackGetDeltaToRefOnPlane( node.GetOrigin(), node.GetAngles(), file.bear, "run_2_stand_180R", file.malta.model.GetUpVector() )
	waitthread PlayAnimGravity( file.bear, "run_2_stand_180R", origin, node.GetAngles(), 0.2 )

	file.bear.ClearMoveAnim()
	file.bear.DisableNPCMoveFlag( NPCMF_DISABLE_MOVE_TRANSITIONS )
	file.bear.DisableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )
}

void function MaltaWidow_GatesPrepare()
{
	entity node = GetEntByScriptName( "widowjumpgatesprepare" )
	#if DEV
		if ( GetBugReproNum() == 5 )
		{
			file.gates.SetOrigin( node.GetOrigin() )
			WaitFrame()
		}
	#endif

	entity maltaRef = file.malta.mover

	vector angles = AnglesCompose( node.GetAngles(), <0,180,0 > )
	vector origin = HackGetDeltaToRefOnPlane( node.GetOrigin(), angles, file.gates, "casual_walkturn_135L", file.malta.model.GetUpVector() )

	bool disableArrival = false
	bool disableAssaultAngles = true
	waitthread RunToAnimStartForced_Deprecated( file.gates, "casual_walkturn_135L", origin, angles, disableArrival, disableAssaultAngles )

	origin = HackGetDeltaToRefOnPlane( node.GetOrigin(), angles, file.gates, "casual_walkturn_135L", file.malta.model.GetUpVector() )
	waitthread PlayAnimGravity( file.gates, "casual_walkturn_135L", origin, angles, 0.2 )

	file.gates.Anim_ScriptedPlay( "walk_2_stand" )
	file.gates.Anim_EnablePlanting()
	WaittillAnimDone( file.gates )
}

void function MaltaWidow_TeamJump()
{
	waitthread MaltaWidow_UseRecordedAnimBear()
	waitthread MaltaWidow_UseRecordedAnimDroz()
	waitthread MaltaWidow_UseRecordedAnimGates()
	waitthread MaltaWidow_UseRecordedAnimDavis()
}

void function MaltaWidow_UseRecordedAnimBear()
{
	file.bear.ClearIdleAnim()
	thread MaltaWidow_UseRecordedAnim( file.bear, ANIM_widowJumpBear_A, ANIM_widowJumpBear_B, ANIM_widowJumpBear_C, Hangar_LandBear )

	//“Follow me"
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS292_01_01_mcor_bear", file.bear )
	wait 0.25
}

void function MaltaWidow_UseRecordedAnimDroz()
{
	file.droz.ClearIdleAnim()
	entity ent = file.droz.GetParent()
	file.droz.ClearParent()
	ent.Destroy()

	thread MaltaWidow_UseRecordedAnim( file.droz, ANIM_widowJumpDroz_A, ANIM_widowJumpDroz_B, ANIM_widowJumpDroz_C, Hangar_LandDroz )

	wait 0.5
	//“I love this job.”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS293_01_01_mcor_droz", file.droz )

	wait 0.5
	//“Well it's never boring” ( playful )
	thread PlayDialogue( "diag_sp_maltaGuns_STS294_01_01_mcor_davis", file.davis )
	wait 0.5
}

void function MaltaWidow_UseRecordedAnimGates()
{
	file.gates.ClearIdleAnim()
	thread MaltaWidow_UseRecordedAnim( file.gates, ANIM_widowJumpGates_A, ANIM_widowJumpGates_B, ANIM_widowJumpGates_C, Hangar_LandGates )

	wait 1.5
	//“Just move your ass, Davis.”	( all business )
	thread PlayDialogue( "diag_sp_maltaGuns_STS296_01_01_mcor_gates", file.gates )

	wait 1.0
}

void function MaltaWidow_UseRecordedAnimDavis()
{
	file.davis.ClearIdleAnim()
	thread MaltaWidow_UseRecordedAnim( file.davis, ANIM_widowJumpDavis_A, ANIM_widowJumpDavis_B, ANIM_widowJumpDavis_C, Hangar_LandDavis )

	wait 4.0
	//“Don't boost too early. Kinsey formation!” ( all business )
//	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS295_01_01_mcor_gates", file.player )
}

void function MaltaWidow_UseRecordedAnim( entity guy, asset anim1, asset anim2, asset anim3, void functionref(entity) outFunc )
{
	var rec1 = LoadRecordedAnimation( anim1 )
	var rec2 = LoadRecordedAnimation( anim2 )
	var rec3 = LoadRecordedAnimation( anim3 )

	float duration
	float blendTime = 0.5

	entity maltaRef = file.malta.mover
	entity widowRef = file.sarahWidow.model

	guy.ClearParent()
	guy.Anim_Stop()
	guy.NotSolid() //so the player doesn't get pushed off the widow

	waitthread PlayRecordedAnim( guy, rec1, <0,0,0>, <0,0,0>, maltaRef, 0.3 )
	waitthread PlayRecordedAnim( guy, rec2, <0,0,0>, <0,0,0>, widowRef, blendTime )
	waitthread PlayRecordedAnim( guy, rec3, <0,0,0>, <0,0,0>, maltaRef, blendTime, 0.2 )

	guy.Solid()
	thread outFunc( guy )
}

void function MaltaWidow_WidowThink()
{
	SpawnSarahTitan( file.sarahWidow.model.GetOrigin() )
	thread PlayAnimTeleport( file.sarahTitan, "bt_widow_side_idle_start_Sarah", file.sarahWidow.model, "ORIGIN" )
	thread WidowAnimateOpen( file.sarahWidow, "left" )

	entity maltaRef = file.malta.mover
	entity node 	= GetEntByScriptName( "maltawidowrunRef" )
	vector delta	= GetRelativeDelta( node.GetOrigin(), maltaRef )

	FlagWait( "WidowGatesStartTalking" )
	thread ShipIdleAtTargetEnt( file.sarahWidow, maltaRef, MALTAWIDOW_WIDOW_BOUNDS, delta, MALTAWIDOW_WIDOW_OFFSET )
	EmitSoundOnEntityAfterDelay( file.sarahWidow.model, "amb_scr_s2s_widow_flyby_zipline", 3.0 )

	SetMaxSpeed( file.sarahWidow, 1000 )
	SetMaxAcc( file.sarahWidow, 350 )
	delaythread( 7 ) SetMaxPitch( file.sarahWidow, 5 )
	SetMaxRoll( file.sarahWidow, 5 )
	float speedDelay = 1.0
	float accDelay = 5.0
	float speedRamp = 5.0
	delaythread( speedDelay ) SetMaxSpeed( file.sarahWidow, 200, speedRamp )
	delaythread( accDelay ) SetMaxAcc( file.sarahWidow, 40, 2.5 )

	wait 1.5
	FlagWait( "WidowGatesDoneTalking" )

	delaythread( 3.5 ) MaltaWidow_SarahWidowVO()
	delaythread( 9 ) MaltaWidow_DoorClose()

	waitthread PlayAnimTeleport( file.sarahTitan, "bt_widow_side_dialogue_Sarah", file.sarahWidow.model, "ORIGIN" )
	if ( IsValid( file.sarahTitan) )
		thread PlayAnim( file.sarahTitan, "bt_widow_side_idle_end_Sarah", file.sarahWidow.model, "ORIGIN" )
}

void function MaltaWidow_DoorClose()
{
	//if safe to close
	FlagWaitClear( "PlayerInSarahWidow" )
	waitthread WidowAnimateClose( file.sarahWidow, "left" )
	wait 0.1

	if ( !Flag( "PlayerInSarahWidow" ) )
	{
		FlagSet( "DoTheWidowJump" )
		file.sarahTitan.Destroy()
		return
	}
	else
	{
		waitthread WidowAnimateOpen( file.sarahWidow, "left" )
		thread MaltaWidow_DoorClose()
	}
}

void function MaltaWidow_SarahWidowVO()
{
	//“Briggs here, what do you need me to do?”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS288_01_01_mcor_sarah", file.player )

	FlagSet( "windowRunPositions" )
	wait 0.5

	//“Close the door and keep her steady.”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS289_01_01_mcor_bear", file.bear )
	wait 0.5

	//“He's not thinking… no, no…  wait a sec.”
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS290_01_01_mcor_davis", file.davis )
	wait 0.5

//	//“Oh yeah!”
//	RegisterDialogue( "diag_sp_maltaGuns_STS291_01_01_mcor_droz", "diag_sp_maltaGuns_STS291_01_01_mcor_droz", PRIORITY_NO_QUEUE )
}

void function MaltaWidow_ZipPosition( bool teleport = false )
{
	entity maltaRef = file.malta.mover
	entity node		= GetEntByScriptName( "maltaGunsCrow2" )
	vector pos 		= GetRelativeDelta( node.GetOrigin(), maltaRef )
	vector bounds 	= <100, 0, 0>
	vector offset 	= <0,0,0>

	ResetMaxSpeed( file.crow64 )
	SetMaxAcc( file.crow64, 150 )
	file.crow64.FuncGetBankMagnitude = GetBankMagnitudeGoblinTight
	file.crow64.goalRadius = 100

	if ( teleport )
		ShipIdleAtTargetEnt_Teleport( file.crow64, maltaRef, bounds, pos, offset )
	else if ( !Flag( "MaltaGunsClear" ) )
		thread ShipIdleAtTargetEnt( file.crow64, maltaRef, bounds, pos, offset )

	if ( IsDoorClosedOrClosing( file.crow64 ) )
		thread DropshipAnimateOpen( file.crow64, "left" )
}

void function MaltaWidow_CrowThink()
{
	FlagWait( "MaltaGunsClear" )

	entity nodesL = GetEntByScriptName( "maltaGunsZiplineNodeL" )
	entity nodesC = GetEntByScriptName( "maltaGunsZiplineNodeC" )
	entity nodesR = GetEntByScriptName( "maltaGunsZiplineNodeR" )

	//nodeL, nodeR, nodeC
	array<entity> hooks = [ nodesL, nodesR, nodesC ]
	AddZiplineDeployNodes( file.crow64, hooks )

	entity maltaRef = file.malta.mover
	entity node		= GetEntByScriptName( "maltaGunsCrow2" )
	vector pos 		= GetRelativeDelta( node.GetOrigin(), maltaRef )
	vector bounds 	= <100, 0, 0>
	vector offset 	= <0,0,0>

	//ResetMaxAcc( file.crow64 )
	ResetMaxSpeed( file.crow64 )
	SetMaxAcc( file.crow64, 150 )

	file.crow64.goalRadius = 100

	FlagWait( "Deploy64" )

	//zipline data
	file.davis.l.customZiplineRideTime = 2.5
	file.droz.l.customZiplineRideTime = 2.5
	file.gates.l.customZiplineRideTime = 2.5
	file.bear.l.customZiplineRideTime = 2.5

	float delay = 1.2
	file.davis.l.customZiplineDeployTime 	= 0.75
	file.droz.l.customZiplineDeployTime 	= delay + file.davis.l.customZiplineDeployTime + 0.1
	float dist = 150
	int bugnum = 2
	thread MaltaWidow_ZiplineGuyCustom( file.davis, file.droz, "pt_gundeck_zipline_Davis", "pt_gundeck_zipline_Droz", delay, MODEL_DAVIS, MODEL_DROZ, dist, bugnum )

	delay = 2.7
	file.gates.l.customZiplineDeployTime 	= 0.1
	file.bear.l.customZiplineDeployTime 	= 0.1
	file.gates.l.customZiplineDeploySignal 	= "customDeployNow"
	file.bear.l.customZiplineDeploySignal 	= "customDeployNow"
	dist = 200
	bugnum = 3
	thread MaltaWidow_ZiplineGuyCustom( file.gates, file.bear, "pt_gundeck_zipline_Gates", "pt_gundeck_zipline_Bear", delay, MODEL_GATES, MODEL_BEAR, dist, bugnum )

	SetDeployShip( file.crow64, file.malta )
	SetDeployPos( file.crow64, pos )
	SetFlyBounds( file.crow64, eBehavior.DEPLOYZIP, bounds )
	SetFlyOffset( file.crow64, eBehavior.DEPLOYZIP, offset )

	file.crow64.goalRadius = 200

	if ( !ShipEventExists( file.crow64, eShipEvents.PLAYER_ONHULL_START ) )
	{
		AddShipEventCallback( file.crow64, eShipEvents.PLAYER_ONHULL_START, Crow64PlayerOnHullStart )
		AddShipEventCallback( file.crow64, eShipEvents.PLAYER_ONHULL_END, Crow64PlayerOnHullEnd )
	}

	ClearShipBehavior( file.crow64, eBehavior.CREW_DEPLOYED )
	AddShipBehavior( file.crow64, eBehavior.CREW_DEPLOYED, Behavior_Crow64LeaveBattleField )
	ClearShipBehavior( file.crow64, eBehavior.LEAVING )
	AddShipBehavior( file.crow64, eBehavior.LEAVING, Behavior_Crow64LeaveBattleField )

	thread SetBehavior( file.crow64, eBehavior.DEPLOYZIP )

	array<entity> guys = GetShipCrew( file.crow64 )
	foreach ( guy in guys )
	{
		thread MaltaWidow_ShowHighlightOnZipline( guy )
		ShowName( guy )
	}

	file.droz.WaitSignal( "customDeployDetach" )
	wait 3.0
	file.gates.Signal( "customDeployNow" )
	wait delay + 0.1
	file.bear.Signal( "customDeployNow" )

	WaitSignal( file.crow64, "crewDeployed" )
	FlagSet( "HeroCrewOnboard" )
	ResetMaxAcc( file.crow64 )
	ResetMaxSpeed( file.crow64 )
}

void function Behavior_Crow64LeaveBattleField( ShipStruct ship )
{
	if ( Flag( "PlayerInOrOnCrow64" ) )
	{
		entity maltaRef = file.malta.mover
		entity node		= GetEntByScriptName( "maltaGunsCrow2" )
		vector pos 		= GetRelativeDelta( node.GetOrigin(), maltaRef )
		vector bounds 	= <100, 0, 0>
		vector offset 	= <0,0,0>

		thread __ShipFollowShip( ship, maltaRef, pos, bounds, offset )
	}

	while( Flag( "PlayerInOrOnCrow64" ) )
	{
		FlagWaitClear( "PlayerInOrOnCrow64" )
		wait 3
	}

	Behavior_LeaveBattleField( ship )
}

void function MaltaWidow_ShowHighlightOnZipline( entity guy )
{
	guy.WaitSignal( "BeginZipline" )
	Highlight_SetFriendlyHighlight( guy, "sp_friendly_hero" )
}

void function MaltaWidow_DrozAfterLand()
{
	entity guy  = file.droz
	guy.WaitSignal( "customDeployDetach" )

	wait 3.7
	guy.LockEnemy( file.rocketDummy[ TEAM_IMC ] )

	string anim = "stand_2_run_45R"
	vector dir = AnglesToForward( <0,180,0> )
	vector up = file.malta.model.GetUpVector()
	vector right = CrossProduct( up, dir )
	vector forward = CrossProduct( right, up )

	vector angles 	= VectorToAngles( forward )
	vector origin 	= HackGetDeltaToRefOnPlane( guy.GetOrigin(), angles, guy, anim, file.malta.model.GetUpVector() )

	entity node = CreateScriptMover( origin, angles )
	node.SetParent( file.malta.model, "", true, 0.0 )
	guy.SetParent( node, "REF", false, 0.2 )
	thread PlayAnim( guy, anim, node, "REF" )
	float time = guy.GetSequenceDuration( "stand_2_run_45R" )
	wait time - 0.2

	guy.ClearParent()
	guy.ForceCheckGroundEntity()
	node.Destroy()

	MaltaWidow_DrozPrepare()

	guy.ClearEnemy()
}

void function MaltaWidow_DavisAfterLand()
{
	entity guy = file.davis

	guy.ClearEnemy()
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.SetEfficientMode( true )

	guy.WaitSignal( "customDeployDetach" )
	guy.SetIdleAnim( "CQB_Idle_Casual" )

	wait 5.9

	vector dir = Normalize( file.player.GetOrigin() - guy.GetOrigin() )
	vector up = file.malta.model.GetUpVector()
	vector right = CrossProduct( up, dir )
	vector forward = CrossProduct( right, up )

	vector angles 	= VectorToAngles( forward )

	guy.ClearParent()
	guy.SetAngles( <0,angles.y,0> )
	guy.Anim_ScriptedPlay( "pt_deck_gun_talk_Davis" )
	guy.Anim_EnablePlanting()
	guy.ForceCheckGroundEntity()

	wait 2.1
	thread MaltaWidow_GoodShitConvo()

	guy.Anim_Stop()

	MaltaWidow_DavisPrepare()
}

void function MaltaWidow_GoodShitConvo()
{
	waitthread PlayerConversation( "GoodShit", file.player, file.davis )
	FlagSet( "GoodShitConvoDone" )
}

void function MaltaWidow_GatesAfterLand()
{
	entity guy = file.gates

	guy.ClearEnemy()
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.SetEfficientMode( true )

	guy.WaitSignal( "customDeployDetach" )
	guy.SetIdleAnim( "CQB_Idle_Casual" )

	wait 3.2

	guy.Anim_EnablePlanting()
	wait 3

	guy.EnableNPCMoveFlag( NPCMF_DISABLE_MOVE_TRANSITIONS )
	guy.EnableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )

	guy.ClearParent()
	guy.Anim_Stop()
	guy.ForceCheckGroundEntity()

	entity node = GetEntByScriptName( "maltaGunsGatesTalk" )
	table animStartPos = guy.Anim_GetStartForRefEntity_Old( "pt_deck_gun_talk_Gates_start", node, "REF" )
	vector dir = Normalize( expect vector( animStartPos.origin ) - guy.GetOrigin() )
	vector face = <0, VectorToAngles( dir ).y, 0 >

	guy.SetAngles(face)
	guy.Anim_ScriptedPlay( "pt_redeye_run_loop" )
	guy.Anim_EnablePlanting()

	wait 1.0

//	guy.Anim_ScriptedPlay( "stairclimb_down" )
//	guy.Anim_EnablePlanting()
//	wait 1.0

	guy.SetMoveAnim( "pt_redeye_run_loop" )

	string anim = "pt_deck_gun_talk_Gates_start"
	bool disableArrival = true
	bool disableAssaultAngles = true

	// HACK: hijacking this variable that is used for marvins so we don't add a new one
	guy.ai.carryBarrel = node

	guy.AssaultPointToAnimSetCallback( "AnimCallback_ParentBeforeAnimating_MaltaWidow" )
	waitthread RunToAndPlayAnimGravityForced( guy, anim, node, !disableArrival, "REF" )

	// waitthread PlayAnimGravity( guy, anim, node, "REF", 0.2 )
	thread PlayAnimGravity( guy, "pt_deck_gun_talk_Gates_idle", node, "REF" )

	FlagWait( "WidowGatesDoTheTalking" )

	thread MaltaWidow_GatesHowGetThereVO()
	waitthread PlayAnimGravity( guy, "pt_deck_gun_talk_Gates_end", node, "REF" )

	guy.ClearParent()
	guy.ForceCheckGroundEntity()

	guy.DisableNPCMoveFlag( NPCMF_DISABLE_MOVE_TRANSITIONS )
	guy.DisableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )
	MaltaWidow_GatesPrepare()
}

void function AnimCallback_ParentBeforeAnimating_MaltaWidow( entity guy )
{
	entity node = guy.ai.carryBarrel
	guy.SetParent( node, "REF", false, 0.2 )
	guy.ClearMoveAnim()
}

void function MaltaWidow_GatesHowGetThereVO()
{
	//"The bridge is through that hangar over there, any ideas?"
	FlagSet( "WidowGatesStartTalking" )
	delaythread( 1.5 ) FlagSet( "WidowGatesDoneTalking" )
	delaythread( 1.5 ) MaltaBreach_Objective()

	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS285_01a_01_mcor_gates", file.gates )
}

void function MaltaBreach_Objective()
{
	Objective_SetSilent( "#S2S_OBJECTIVE_TAKECONTROL2", <0,0,1> )
	entity marker = Objective_GetMarkerEntity()
	marker.ClearParent()
	marker.SetOrigin( GetWorldOriginFromRelativeDelta( < 0, 3448, 568 >, file.malta.mover ) )
	marker.SetParent( file.malta.mover )
}

void function MaltaWidow_BearAfterLand()
{
	entity guy = file.bear

	guy.ClearEnemy()
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.SetEfficientMode( true )

	guy.WaitSignal( "customDeployDetach" )
	guy.SetIdleAnim( "CQB_Idle_Casual" )

	wait 1.0
	guy.Anim_EnablePlanting()
	wait 3.2
	guy.Anim_EnablePlanting()

	guy.ClearParent()
	guy.Anim_Stop()
	guy.SetAngles( <0,guy.GetAngles().y,0> )
	guy.ForceCheckGroundEntity()

	entity node = GetEntByScriptName( "widowjumpbearcorner" )
	float arrivalTolerance = guy.AssaultGetArrivalTolerance()
	guy.AssaultPoint( node.GetOrigin() )
	guy.AssaultSetArrivalTolerance( 64 )

	wait 2.5

	node = GetEntByScriptName( "maltaGunsBearTalk" )
	guy.AssaultPoint( node.GetOrigin() )
	guy.AssaultSetArrivalTolerance( 64 )

	FlagWait( "windowRunPositions" )
	guy.AssaultSetArrivalTolerance( arrivalTolerance )
}

void function MaltaWidow_ZiplineGuyCustom( entity guy1, entity guy2, string anim1, string anim2, float delay, asset model1, asset model2, float dist, int bugnum )
{
	entity hook 	= GetEntByScriptName( "maltaGunsZiplineNodeC" )
	entity node 	= CreateScriptMover( hook.GetOrigin(), hook.GetAngles() )
	entity dummy1 	= CreatePropDynamic( model1, node.GetOrigin(), node.GetAngles() )

	dummy1.SetParent( node, "REF", false, 0 )
	dummy1.Hide()

	float blendTime = 0.5
	int tagID 		= file.crow64.model.LookupAttachment( "RopeAttachLeftB" )


	float distSqr = pow( 100, 2 )
	while( 1 )
	{
		thread PlayAnim( dummy1, anim1, node, "REF" )
		MaltaWidow_RepositionRef( node, tagID, hook, dist )

		#if DEV
			if ( GetBugReproNum() == bugnum )
			{
				dummy1.Show()
			}
			else
			{
				dummy1.Hide()
			}
		#endif

		WaitFrame()

		if ( Distance2DSqr( dummy1.GetOrigin(), guy1.GetOrigin() ) <= distSqr )
			break
	}

	dummy1.Destroy()
	guy1.SetEfficientMode( false )
	guy1.SetParent( node, "REF", false, blendTime )

	//these need to go into anim
	StopSoundOnEntity( guy1, "3p_zipline_loop" )
	EmitSoundOnEntity( guy1, "3p_zipline_detach" )
	delaythread( 0.2 ) MaltaWidow_CustomDeploy( guy1 )
	guy1.Signal( "customDeployDetach" )
	thread PlayAnim( guy1, anim1, node, "REF", blendTime )

	wait delay

	guy2.SetEfficientMode( false )
	guy2.SetParent( node, "REF", false, blendTime )

	StopSoundOnEntity( guy2, "3p_zipline_loop" )
	EmitSoundOnEntity( guy2, "3p_zipline_detach" )
	delaythread( 0.2 ) MaltaWidow_CustomDeploy( guy2 )
	guy2.Signal( "customDeployDetach" )
	waitthread PlayAnim( guy2, anim2, node, "REF", blendTime )

	//garauntee guys aren't parented to this node anymore
	wait 10.0

	node.Destroy()
}

void function MaltaWidow_CustomDeploy( entity guy )
{
	WaittillAnimDone( guy )
	guy.Signal( "npc_deployed" )
}

void function MaltaWidow_RepositionRef( entity node, int tagID, entity hook, float dist )
{
	vector origin = file.crow64.model.GetAttachmentOrigin( tagID )
	vector hookPos = hook.GetOrigin()
	vector dir = Normalize( origin - hookPos )

	vector up = file.malta.model.GetUpVector()
	vector right = CrossProduct( up, dir )
	vector forward = CrossProduct( right, up )
	vector pos = hookPos + ( forward * dist ) + ( up * 0.5 )
	dir = Normalize( hookPos - pos )
	vector angles = VectorToAngles( dir )

	node.ClearParent()
	node.SetOrigin( pos )
	node.SetAngles( angles )
	node.SetParent( file.malta.model, "", true, 0 )

	#if DEV
		if ( GetBugReproNum() == 2 )
		{
			DebugDrawLine( origin, hookPos, 0, 255, 0, true, FRAME_INTERVAL )
			DebugDrawLine( hookPos, pos, 255, 0, 0, true, FRAME_INTERVAL )
			DebugDrawCircle( node.GetOrigin(), node.GetAngles(), 8, 255, 0, 0, true, FRAME_INTERVAL, 5 )
		}
	#endif
}

/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗     ██╗  ██╗ █████╗ ███╗   ██╗ ██████╗  █████╗ ██████╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██║  ██║██╔══██╗████╗  ██║██╔════╝ ██╔══██╗██╔══██╗
██╔████╔██║███████║██║     ██║   ███████║    ███████║███████║██╔██╗ ██║██║  ███╗███████║██████╔╝
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══██║██╔══██╗
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ██║  ██║██║  ██║██║ ╚████║╚██████╔╝██║  ██║██║  ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

\************************************************************************************************/
void function MaltaHangar_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-33000,0> )
	SetupShips_MaltaHangar()

	SetOriginLocal( file.airBattleNode, V_MALTAWIDOW_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_WaitOnBarkerShip( bt, true )

	EnableScript( file.malta, "scr_malta_node_3" )
	EnableScript( file.malta, "scr_malta_node_3b" )
	array<entity> spawners = GetEntArrayByScriptName( "hangar_fragDrones" )
	foreach ( spawner in spawners )
		spawner.Hide()
	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart4" ) )

	thread Hangar_LandBear(file.bear )
	thread Hangar_LandDroz( file.droz )
	thread Hangar_LandGates( file.gates )
	thread Hangar_LandDavis( file.davis )

	FlagSet( "DoTheWidowJump" )
	FlagSet( "Hangar_IntroIdles" )
}

void function MaltaHangar_Skip( entity player )
{
	ShipGeoHide( file.malta, "GEO_CHUNK_BACK" )
	ShipGeoShow( file.malta, "GEO_CHUNK_BACK_FAKE" )
}

void function MaltaHangar_Main( entity player )
{
	FlagInit( "HangarTicksDead" )

	FlagWaitAny( "DoTheWidowJump", "PlayerInOrOnSarahWidow" )

	thread Hangar_GearupGuyHandle()
	thread Hangar_IntroVO()
	thread MaltaHangar_LiftDown()
	thread MaltaBreach_BridgeGuys()

	AddSpawnCallback_ScriptName( "hangar_backup1", MaltaHangar_BackupGuys1_Think )
	SpawnOnShipFromScriptName( "hangar_backup1", file.malta )

	FlagWait( "Hangar_IntroReact" )
	thread Hangar_ReactVO()
	delaythread( 1.5 ) MaltaHangar_FightMusic()

	//reset stuff back to normal
	FlagWait( "MaltaLandedInHangar" )
	thread MaltaHangar_ResetMaltaAndWidow()

	thread MaltaHangar_LandedCheckpoint( player )
	player.kv.gravity = 1.0
	player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [] )

	ClearDroppedWeapons()
	if ( !Flag( "DriftWorldCenter" ) )
		FlagSet( "DriftWorldCenter" )

	SetGlobalForcedDialogueOnly( false )

	//bring in troops if we hang back and kill these fools
	array<entity> enemies = GetNPCArrayByScriptName( "hangar_backup1", TEAM_IMC )
	int numAlive = 3
	if ( enemies.len() > numAlive )
		thread FlagSetOn_NumDeadOrLeeched( "hangarbackup2", enemies, enemies.len() - numAlive )

	FlagWait( "Hangar_LandBear" )
	FlagWait( "Hangar_LandDavis" )
	FlagWait( "Hangar_LandDroz" )
	FlagWait( "Hangar_LandGates" )

	// added stuff
	TeleportAllExceptOne( GetEntByScriptName( "maltaPlayerStart4" ).GetOrigin() + <0,0,50>, null )

	HideHelmet( "dronehelmet" )
	CleanupScript( "scr_malta_node_2" )
	CleanupScript( "scr_malta_node_1b" )

	ShipGeoHide( file.malta, "GEO_CHUNK_BACK" )
	ShipGeoShow( file.malta, "GEO_CHUNK_BACK_FAKE" )

	//send the team off
	asset animBear 	= $"anim_recording/s2s_record_hanger_Bear_1a.rpak"
	asset animDroz 	= $"anim_recording/s2s_record_hanger_Droz_1a.rpak"
	asset animGates = $"anim_recording/s2s_record_hanger_Gates_1a.rpak"
	asset animDavis = $"anim_recording/s2s_record_hanger_Davis_1a.rpak"
	thread MaltaHangar_TeamMoveup1( file.bear, 	animBear, 	0.0, Hangar_RecOut_Bear1 )
	thread MaltaHangar_TeamMoveup1( file.droz, 	animDroz, 	0.0, Hangar_RecOut_Droz1 )
	thread MaltaHangar_TeamMoveup1( file.gates, animGates, 	2.0, Hangar_RecOut_Gates1 )
	thread MaltaHangar_TeamMoveup1( file.davis, animDavis, 	0.0, Hangar_RecOut_Davis1 )

	FlagWait( "hangarbackup2")

	FlagSetOnFlag( "hangarTeamMoveUp2", "hangarLaunchTicks" )

	thread Hanger_BackLiftThink()
	SpawnOnShipFromScriptName( "hangar_backup2", file.malta )

	//launch ticks if kill enough guys
	enemies = GetNPCArrayByScriptName( "hangar_backup1", TEAM_IMC )
	enemies.extend( GetNPCArrayByScriptName( "hangar_backup2", TEAM_IMC ) )
	numAlive = 5
	if ( enemies.len() > numAlive )
	{
		thread FlagSetOn_NumDeadOrLeeched( "hangarLaunchTicks", enemies, enemies.len() - numAlive )
		thread FlagSetOn_NumDeadOrLeeched( "hangarbackup3", enemies, enemies.len() - numAlive )
	}

	FlagWait( "hangarLaunchTicks" )
	wait 0.5
	FlagSet( "HangarTicksDead" )

	animBear 	= $"anim_recording/s2s_record_hanger_Bear_2a.rpak"
	animDroz 	= $"anim_recording/s2s_record_hanger_Droz_2a.rpak"
	animGates 	= $"anim_recording/s2s_record_hanger_Gates_2a.rpak"
	animDavis 	= $"anim_recording/s2s_record_hanger_Davis_2a.rpak"
	thread MaltaHangar_TeamMoveup2( file.bear, 	animBear, 	0.2, "BreachBearRec1Done", Hangar_RecOut_Bear2 )
	thread MaltaHangar_TeamMoveup2( file.droz, 	animDroz, 	0.2, "BreachDrozRec1Done", Hangar_RecOut_Droz2 )
	thread MaltaHangar_TeamMoveup2( file.gates, animGates, 	0.2, "BreachGatesRec1Done", Hangar_RecOut_Gates2 )
	thread MaltaHangar_TeamMoveup2( file.davis, animDavis, 	0.2, "BreachDavisRec1Done", Hangar_RecOut_Davis2 )

	//when everyone is almost dead - draw eye up
	FlagWait( "hangarbackup3")
	SpawnOnShipFromScriptName( "hangar_backup3", file.malta )

	wait 1.0

	enemies = MaltaHangar_GetAllEnemies()
	numAlive = 4
	if ( enemies.len() > numAlive )
		waitthread WaitUntilNumDeadOrLeeched( enemies, enemies.len() - numAlive )

	enemies = MaltaHangar_GetAllEnemies()
	thread FlagSetOn_AllDead( "HangarFinished", enemies )

	entity weapon = file.gates.GetActiveWeapon()
	WeaponPrimaryAttackParams attackParams
	int attachID = weapon.LookupAttachment( "muzzle_flash" )

	float checkDistSqr = pow( 300, 2 )
	foreach ( guy in enemies )
	{
		if ( !IsAlive( guy ) )
			continue

		if ( DistanceSqr( file.player.GetOrigin(), guy.GetOrigin() ) < checkDistSqr )
		{
			if ( PlayerCanSee( player, guy, true, 45 ) )
				continue
		}

		attackParams.pos = weapon.GetAttachmentOrigin( attachID )
		attackParams.dir = Normalize( guy.GetOrigin() + <0,40,0> - attackParams.pos )
		OnWeaponNpcPrimaryAttack_weapon_DMR( weapon, attackParams )
		EmitSoundOnEntity( guy, "Weapon_DMR_Fire_NPC" )
		guy.TakeDamage( guy.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.mp_weapon_dmr } )

		wait 0.5
	}

	FlagWait( "HangarFinished" )

	thread MaltaHangar_EndVO()
	thread Breach_CrewRunToBreachPositions()
	SetGlobalForcedDialogueOnly( true )
}

void function MaltaHangar_FightMusic()
{
	StopMusic()
	PlayMusic( "music_s2s_09_teamfight" )
}

void function MaltaHangar_ResetMaltaAndWidow()
{
	FlagWait( "DavisLandedInHangar" )

	ResetMaxRoll( file.malta )
	ResetMaxSpeed( file.malta )
	ResetMaxAcc( file.malta )
	thread ShipIdleAtTargetPos( file.malta, 	V_MALTADRONE_MALTA, MALTADRONE_MALTA_BOUNDS )

	ResetMaxRoll( file.sarahWidow )
	ResetMaxPitch( file.sarahWidow )
	ResetMaxSpeed( file.sarahWidow )
	ResetMaxAcc( file.sarahWidow )
	ResetBankTime( file.sarahWidow )
	thread ShipIdleAtTargetEnt( file.sarahWidow, file.malta.mover, MALTAHANGAR_WIDOW_BOUNDS, <0,0,0>, MALTAHANGAR_WIDOW_OFFSET )
}

void function Hangar_ReactVO()
{
	array<entity> enemies = GetNPCArrayByScriptName( "hangar_gearupguys1", TEAM_IMC )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys2", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys3", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys4", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys5", TEAM_IMC ) )

	enemies = ArrayClosest( enemies, file.player.GetOrigin() )

	entity guy = enemies[ 0 ]

	//They're behind us!
	thread PlayDialogue( "diag_sp_maltaHangar_STS298a_08_01_imc_grunt2", guy )

	wait 4.0
	entity paEnt = GetEntByScriptName( "hangarPA" )
	//"Code Red. IMC forces engaged in combat on the hangar level.  All security forces, converge on the hangar level. Repeat, Code Red. All security forces, converge on the hangar level."
	waitthreadsolo PlayDialogue( "diag_sp_maltaHangar_STS298_01_01_imc_command", paEnt )

	wait 0.5

	//Get to cover!
	waitthreadsolo PlayDialogue( "diag_sp_maltaHangar_STS303_01a_02_mcor_droz", file.droz )
}

void function Hangar_IntroVO()
{
	FlagEnd( "Hangar_IntroReact" )

	FlagWait( "Hangar_IntroIdles" )

	entity paEnt = GetEntByScriptName( "hangarPA" )
	//Goblin BRAVO - six, prepare for boarding, preflight check list.
	waitthreadsolo PlayDialogue( "diag_sp_maltaHangar_STS298a_01_01_imc_command", paEnt )

	//Squad Altpha 2 Charlie, sending the lift down now
	waitthreadsolo PlayDialogue( "diag_sp_maltaHangar_STS298a_02_01_imc_command", paEnt )
}

void function MaltaHangar_EndVO()
{
	StopMusic()
	PlayMusic( "music_s2s_11_downtobusiness" )

	wait 1.0
	//"The room's clear!"
	waitthreadsolo PlayDialogue( "diag_sp_maltaDrone_STS234_01_01_mcor_gates_hangar", file.gates )

	wait 0.5
	//"That's the bridge up there."
	waitthreadsolo PlayDialogue( "diag_sp_maltaHangar_STS301_01_01_mcor_gates", file.gates )
	Objective_Remind()

	FlagSet( "CrewRunToBreach" )

	//"Follow me"
	waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS292_01_01_mcor_bear", file.bear )

	if ( Flag( "StartingBreach" ) )
		return
	FlagEnd( "StartingBreach" )

	wait 2.0

	if ( Flag( "PlayerInBreachPosition") )
		return
	//"Come on, Coop. Keep up"
	waitthreadsolo PlayDialogue( "diag_sp_maltaHangar_STS307_01_01_mcor_droz", file.droz )
}

array<entity> function MaltaHangar_GetAllEnemies()
{
	array<entity> enemies = GetNPCArrayByScriptName( "hangar_backup1", TEAM_IMC )
	enemies.extend( GetNPCArrayByScriptName( "hangar_backup2", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_backup2_shield", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_backup3", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys1", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys2", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys3", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys4", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangar_gearupguys5", TEAM_IMC ) )
	enemies.extend( GetNPCArrayByScriptName( "hangartick", TEAM_IMC ) )

	return enemies
}

void function MaltaHangar_TeamMoveup2( entity guy, asset anim, float delay, string waitFlag, void functionref(entity) outFunc = null )
{
	FlagWait( "HangarTicksDead" )
	FlagWait( waitFlag )
	wait delay

	guy.Signal( "StopAssaultMoveTarget" )

	//guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )

	if ( guy == file.davis )
	{
		var rec 		= LoadRecordedAnimation( anim )
		waitthread RunToRecordedAnimStart( guy, rec, <0,0,0>, <0,0,0>, file.malta.mover )
		thread RecordedAnimSignals( guy )
		waitthread PlayRecordedAnim( guy, rec, <0,0,0>, <0,0,0>, file.malta.mover, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, 0 )

		if ( outFunc != null )
			thread outFunc( guy )
	}

	else
		waitthread RunToAndPlayRecordedAnim( guy, anim, outFunc )

	guy.DisableNPCFlag( NPC_IGNORE_ALL )
	guy.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )
}

void function MaltaHangar_TeamMoveup1( entity guy, asset anim, float delay, void functionref(entity) outFunc = null )
{
	//set small radius so they don't move around much
	float radius = 64
	guy.AssaultPoint( guy.GetOrigin() )
	guy.AssaultSetGoalRadius( radius )
	guy.AssaultSetGoalHeight( 64 )

	//wait for all enemies to be out of the vacinity
	FlagWaitClear( "MaltaHangar_EnemiesAtIntro" )
	wait delay

	guy.Signal( "StopAssaultMoveTarget" )

	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )

	waitthread RunToAndPlayRecordedAnim( guy, anim, outFunc )

	guy.DisableNPCFlag( NPC_IGNORE_ALL )
	guy.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )
}

void function Hangar_RecOut_Bear1( entity guy )
{
	guy.Anim_ScriptedPlay( "Land_Rifle_Forward" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )

	entity node = GetEntByScriptName( "hangarBearMoveupOne" )
	thread AssaultMoveTarget( guy, node )
	wait 0.2

	FlagSet( "BreachBearRec1Done" )
}

void function Hangar_RecOut_Gates1( entity guy )
{
	guy.Anim_ScriptedPlay( "pt_strafeL_2_stand" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )

	entity node = GetEntByScriptName( "hangarGatesMoveupOne" )
	thread AssaultMoveTarget( guy, node )
	wait 0.2

	FlagSet( "BreachGatesRec1Done" )
}

void function Hangar_RecOut_Droz1( entity guy )
{
	entity node = GetEntByScriptName( "hangarDrozMoveupOne" )
	thread AssaultMoveTarget( guy, node )
	wait 0.2

	FlagSet( "BreachDrozRec1Done" )
}

void function Hangar_RecOut_Davis1( entity guy )
{
	entity node = GetEntByScriptName( "hangarDavisMoveupOne" )
	thread AssaultMoveTarget( guy, node )
	wait 0.2

	FlagSet( "BreachDavisRec1Done" )
}

void function Hangar_RecOut_Bear2( entity guy )
{
	guy.Anim_ScriptedPlay( "pt_strafeR_2_stand" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )

	entity node = GetEntByScriptName( "hangar_bear_end" )

	vector ornull clampedPos = NavMesh_ClampPointForAIWithExtents( guy.GetOrigin(), guy, <500,500,500> )

	if ( clampedPos != null )
	{
		expect vector( clampedPos )
		guy.SetOrigin( clampedPos )
	}
	else
	{
	//	Assert( clampedPos != null )
		vector origin = GetWorldPosRelativeToShip( < 994, 2806, -319 >, file.malta )
		file.bear.SetOrigin( origin )
	}

	thread AssaultMoveTarget( guy, node )
	wait 0.2

	FlagSet( "BreachBearRec2Done" )
}

void function Hangar_RecOut_Gates2( entity guy )
{
	guy.Anim_ScriptedPlay( "pt_strafeL_2_stand" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )

	wait 0.1
	guy.AssaultPoint( guy.GetOrigin() )
	guy.AssaultSetGoalRadius( 200 )
	guy.AssaultSetGoalHeight( 32 )
	wait 0.2

	FlagSet( "BreachGatesRec2Done" )
}

void function Hangar_RecOut_Davis2( entity guy )
{
	entity node = GetEntByScriptName( "hangar_davisdroz_end" )

	vector ornull clampedPos = NavMesh_ClampPointForAIWithExtents( guy.GetOrigin(), guy, <500,500,500> )

	if ( clampedPos != null )
	{
		expect vector( clampedPos )
		guy.SetOrigin( clampedPos )
	}
	else
	{
	//	Assert( clampedPos != null )
		vector origin = GetWorldPosRelativeToShip( < 651, 2711, -382 >, file.malta )
		file.davis.SetOrigin( origin )
	}

	thread AssaultMoveTarget( guy, node )
	wait 0.2

	FlagSet( "BreachDavisRec2Done" )
}

void function Hangar_RecOut_Droz2( entity guy )
{
	entity node = GetEntByScriptName( "hangar_davisdroz_end" )
	thread AssaultMoveTarget( guy, node )
	wait 0.2

	FlagSet( "BreachDrozRec2Done" )
}

void function Hanger_BackLiftThink()
{
	entity lift = GetEntByScriptName( "hangar_backlift" )
	entity upPos = lift.GetLinkEnt()

	float time = 1.5
	float animtime = 1.5

	entity mover = CreateScriptMover( lift.GetOrigin(), lift.GetAngles() )
	mover.SetParent( file.malta.model, "", true, 0 )
	lift.SetParent( mover, "REF" )

	mover.NonPhysicsSetMoveModeLocal( true )
	mover.NonPhysicsMoveTo( upPos.GetLocalOrigin(), time, 0, time * 0.2 )
	upPos.Destroy()

	array<entity> guys = SpawnOnShipFromScriptName( "hangar_backup2_shield", file.malta )
	//array<string> anims = [ "pt_elevator_breach_gruntA", "pt_elevator_breach_gruntB", "pt_elevator_breach_gruntC", "pt_elevator_breach_gruntD" ]
	array<string> anims = [ "pt_elevator_clear_gruntA", "pt_elevator_clear_gruntB", "pt_elevator_clear_X_gruntA", "pt_elevator_clear_X_gruntB" ]

	entity node = CreateScriptMover( lift.GetOrigin(), lift.GetAngles() )
	node.SetAngles( AnglesCompose( node.GetAngles(), <0,-90,0> ) )
	node.SetOrigin( node.GetOrigin() + ( node.GetForwardVector() * 60 ) )
	node.SetParent( lift, "", true, 0 )

	foreach ( index, guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		guy.SetParent( node, "REF" )
		guy.EnableNPCFlag( NPC_IGNORE_ALL )
		guy.SetNoTarget( true )
		thread PlayAnimTeleport( guy, anims[ index ] + "_idle", node, "REF" )
	}

	wait time - animtime

	foreach( index, guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		thread PlayAnim( guy, anims[ index ], node, "REF" )
		thread Hanger_BackLiftThinkEnd( guy )
	}

	wait animtime

	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		if ( !guy.Anim_IsActive() )
			continue

		WaittillAnimDone( guy )
	}

	wait 0.5

	lift.SetParent( file.malta.model, "", true, 0 )
	mover.Destroy()
	node.Destroy()
}

void function Hanger_BackLiftThinkEnd( entity guy )
{
	guy.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : ( guy )
		{
			if ( IsValid( guy  ) )
				guy.ClearParent()
			if ( IsAlive( guy ) )
				guy.SetNoTarget( false )
		}
	)

	guy.DisableNPCFlag( NPC_IGNORE_ALL )

	WaittillAnimDone( guy )
}

void function MaltaHangar_BackupGuys1_Think( entity guy )
{
	guy.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : (  )
		{
			FlagSet( "Hangar_IntroReact" )
		}
	)

	guy.SetNoTarget( true )
	guy.EnableNPCFlag( NPC_IGNORE_ALL )

	FlagWait( "Hangar_IntroReact" )

	guy.SetNoTarget( false )
	guy.DisableNPCFlag( NPC_IGNORE_ALL )
}

void function MaltaHangar_LiftDown()
{
	FlagWaitAny( "Hangar_IntroIdles", "MaltaLandedInHangar" )

	wait 1.0

	float liftTime 		= 7.0
	float panelTime 	= 3.0
	float panelDelay 	= 8.0

	HangarLiftLower( liftTime, panelDelay, panelTime )
}

void function HangarLiftLower( float liftTime, float panelDelay, float panelTime )
{
	//move the lift
	entity hangarLiftUp = GetEntByScriptName( "hangarLiftUpPos" )
	entity hangarLiftDown = GetEntByScriptName( "hangarLiftDownPos" )

	hangarLiftUp.NonPhysicsSetMoveModeLocal( true )
	hangarLiftUp.NonPhysicsMoveTo( hangarLiftDown.GetLocalOrigin(), liftTime, liftTime * 0.15, liftTime * 0.075 )
	EmitSoundOnEntity( hangarLiftUp, "s2s_hangar_platform_down" )
	hangarLiftDown.Destroy()

	delaythread( liftTime ) FlagSet( "HangarLiftDone" )

	wait panelDelay

	thread HangarLiftPanelsOpen( panelTime )
}

void function HangarLiftPanelsClose( float rotTime )
{
	array<entity> panels = GetEntArrayByScriptName( "hangar_lift_cover" )
	foreach ( panel in panels )
	{
		panel.NonPhysicsSetRotateModeLocal( true )
		vector angles = AnglesCompose( panel.GetLocalAngles(), < 90,0,0> )
		panel.NonPhysicsRotateTo( angles, rotTime, rotTime * 0.1, rotTime * 0.2 )
	}

	wait rotTime
}

void function HangarLiftPanelsOpen( float rotTime )
{
	array<entity> panels = GetEntArrayByScriptName( "hangar_lift_cover" )
	foreach ( panel in panels )
	{
		panel.NonPhysicsSetRotateModeLocal( true )
		vector angles = AnglesCompose( panel.GetLocalAngles(), < -90,0,0> )
		panel.NonPhysicsRotateTo( angles, rotTime, rotTime * 0.1, rotTime * 0.2 )
	}

	EmitSoundOnEntity( panels[0], "s2s_hangar_blast_cover_up" )

	wait rotTime
}

void function Hangar_GearupGuyHandle()
{
	array<entity> guys
	entity node

	guys = SpawnOnShipFromScriptName( "hangar_gearupguys1", file.malta )
	node = GetEntByScriptName( "hangar_gearupguys1_node" )
	thread Hangar_GearupGuys( guys[ 0 ], node, "pt_gruntA_armory_gearup_case_L_idle", "pt_gruntA_armory_gearup_case_L" )
	thread Hangar_GearupGuys( guys[ 1 ], node, "pt_gruntB_armory_gearup_case_L_idle", "pt_gruntB_armory_gearup_case_L" )

	guys = SpawnOnShipFromScriptName( "hangar_gearupguys2", file.malta )
	node = GetEntByScriptName( "hangar_gearupguys2_node" )
	thread Hangar_GearupGuys( guys[ 0 ], node, "pt_gruntA_armory_gearup_case_R_idle", "pt_gruntA_armory_gearup_case_R" )
	thread Hangar_GearupGuys( guys[ 1 ], node, "pt_gruntB_armory_gearup_case_R_idle", "pt_gruntB_armory_gearup_case_R" )

	guys = SpawnOnShipFromScriptName( "hangar_gearupguys3", file.malta )
	node = GetEntByScriptName( "hangar_gearupguys3_node" )
	thread Hangar_GearupGuys( guys[ 0 ], node, "pt_gruntA_armory_gearup_shelf_idle", "pt_gruntA_armory_gearup_shelf" )
	thread Hangar_GearupGuys( guys[ 1 ], node, "pt_gruntB_armory_gearup_shelf_idle", "pt_gruntB_armory_gearup_shelf" )

	guys = SpawnOnShipFromScriptName( "hangar_gearupguys4", file.malta )
	node = GetEntByScriptName( "hangar_gearupguys4_node" )
	thread Hangar_GearupGuys( guys[ 0 ], node, "pt_gruntA_armory_gearup_shelf_alt_idle", "pt_gruntA_armory_gearup_shelf_alt" )
	thread Hangar_GearupGuys( guys[ 1 ], node, "pt_gruntB_armory_gearup_shelf_alt_idle", "pt_gruntB_armory_gearup_shelf_alt" )

	guys = SpawnOnShipFromScriptName( "hangar_gearupguys5", file.malta )
	node = GetEntByScriptName( "hangar_gearupguys5_node" )
	thread Hangar_GearupGuys( guys[ 0 ], node, "pt_armory_walkers_gruntA_idle", "pt_armory_walkers_gruntA" )
	thread Hangar_GearupGuys( guys[ 1 ], node, "pt_armory_walkers_gruntB_idle", "pt_armory_walkers_gruntB" )
}

void function Hangar_WaitToDoIntroIdles()
{
	OnThreadEnd(
	function() : (  )
		{
			FlagSet( "Hangar_IntroIdles" )
		}
	)

	if ( Flag( "MaltaLandedInHangar" ) )
		return
	FlagEnd( "MaltaLandedInHangar" )

	entity trigger = file.sarahWidow.triggerTop
	Assert( !trigger.IsTouched() )

	table result
	result = trigger.WaitSignal( "OnStartTouch" )
	Assert( file.player == expect entity( result.activator ) )

	while ( trigger.IsTouched() )
	{
		trigger.WaitSignal( "OnEndTouchAll" )
		wait 0.1 //make sure
	}
}

void function Hangar_GearupGuys( entity guy, entity node, string idle, string anim )
{
	FlagEnd( "Hangar_IntroReact" )
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDamaged" )

	OnThreadEnd(
	function() : ( guy )
		{
			FlagSet( "Hangar_IntroReact" )
			thread Hangar_GearupReact( guy )
		}
	)

	guy.SetDamageNotifications( true )
	guy.SetNoTarget( true )
	guy.EnableNPCFlag( NPC_IGNORE_ALL )

	WaitFrame()

	guy.SetParent( node, "REF" )
	thread PlayAnimTeleport( guy, idle, node, "REF" )

	FlagWait( "Hangar_IntroIdles" )

	waitthread PlayAnimGravity( guy, anim, node, "REF" )
}

void function Hangar_GearupReact( entity guy )
{
	if ( !IsAlive( guy ) )
		return

	guy.EndSignal( "OnDeath" )

	wait RandomFloat( 0.5 )

	guy.Anim_Stop()
	guy.ClearParent()
	guy.SetNoTarget( false )
	guy.DisableNPCFlag( NPC_IGNORE_ALL )
	guy.SetDamageNotifications( false )

	guy.SetEnemy( file.player )
	guy.SetEnemyLKP( file.player, file.player.GetOrigin() )

	wait 4.0

	FlagWait( "HangarLiftDone" )

	//retreat
	float fightRadius 		= guy.AssaultGetFightRadius()
	guy.AssaultSetFightRadius( 100 )
	guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )

	entity node = GetEntByScriptName( "hangar_retreat_target" )
	thread AssaultMoveTarget( guy, node )

	wait 4.0

	guy.AssaultSetFightRadius( fightRadius )
	guy.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )
}

void function Hangar_LandBear( entity guy )
{
	vector delta	= <955.547, 558.945, -507.693>
	vector angles	= < 0, 135, 0>
	entity maltaRef = file.malta.mover
	vector pos 		= DeltaToWorldOrigin( delta, maltaRef )
	string anim 	= "run_2_stand_135R"
	vector origin 	= HackGetDeltaToRefOnPlane( pos, angles, guy, anim, maltaRef.GetUpVector() )

	entity node = CreateScriptMover( origin, angles )
	node.SetParent( maltaRef, "REF", true, 0 )
	guy.SetParent( node, "REF", false, 0 )

	waitthread PlayAnimGravity( guy, anim, node, "REF", 0.0 )
	guy.ClearParent()

	guy.Anim_ScriptedPlay( "pt_standwindow_R_A2C" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )

	OnThreadEnd(
	function() : ( guy )
		{
			guy.Anim_Stop()
			guy.DisableNPCFlag( NPC_IGNORE_ALL )
			guy.SetEfficientMode( false )
			guy.SetNoTarget( false )
			guy.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, true )
		}
	)

	FlagSet( "Hangar_LandBear" )
	if ( Flag( "Hangar_IntroReact" ) )
		return
	FlagEnd( "Hangar_IntroReact" )

	while( 1 )
	{
		guy.Anim_ScriptedPlay( "pt_standwindow_R_idle_C" )
		guy.Anim_EnablePlanting()
		WaittillAnimDone( guy )
	}
}

void function Hangar_LandDroz( entity guy )
{
	vector delta	= <953.253, 481.006, -511.1>
	vector angles	= < 0, 135, 0>
	entity maltaRef = file.malta.mover
	vector pos 		= DeltaToWorldOrigin( delta, maltaRef )
	string anim 	= "run_2_stand_45R"
	vector origin 	= HackGetDeltaToRefOnPlane( pos, angles, guy, anim, maltaRef.GetUpVector() )

	entity node 	= CreateScriptMover( origin, angles )
	node.SetParent( maltaRef, "REF", true, 0 )
	guy.SetParent( node, "REF", false, 0 )

	waitthread PlayAnimGravity( guy, anim, node, "REF", 0.0 )
	guy.ClearParent()

/*	guy.Anim_ScriptedPlay( "stand_2_run_90L" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )*/

	guy.Anim_ScriptedPlay( "pt_standcorner_R_B2A" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )

	guy.Anim_ScriptedPlay( "pt_standcorner_R_idle_A" )
	guy.Anim_EnablePlanting()

	wait 0.5

	guy.Anim_ScriptedPlay( "pt_standwindow_R_A2C" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )

	OnThreadEnd(
	function() : ( guy )
		{
			guy.Anim_Stop()
			guy.DisableNPCFlag( NPC_IGNORE_ALL )
			guy.SetEfficientMode( false )
			guy.SetNoTarget( false )
			guy.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, true )
		}
	)

	FlagSet( "Hangar_LandDroz" )
	if ( Flag( "Hangar_IntroReact" ) )
		return
	FlagEnd( "Hangar_IntroReact" )

	while( 1 )
	{
		guy.Anim_ScriptedPlay( "pt_standwindow_R_idle_C" )
		guy.Anim_EnablePlanting()
		WaittillAnimDone( guy )
	}
}

void function Hangar_LandGates( entity guy )
{
	vector delta	= <913.717, 535.293, -507.29>
	vector angles	= < 0, 135, 0>
	entity maltaRef = file.malta.mover
	vector pos 		= DeltaToWorldOrigin( delta, maltaRef )
	string anim 	= "Pt_Slide_Out_F_mp"
	vector origin 	= HackGetDeltaToRefOnPlane( pos, angles, guy, anim, maltaRef.GetUpVector() )

	entity node = CreateScriptMover( origin, angles )
	node.SetParent( maltaRef, "REF", true, 0 )
	guy.SetParent( node, "REF", false, 0 )

	waitthread PlayAnimGravity( guy, anim, node, "REF", 0.0 )
	guy.ClearParent()

	guy.Anim_ScriptedPlay( "run_2_crouch_45R" )
	guy.Anim_EnablePlanting()
	WaittillAnimDone( guy )
	OnThreadEnd(
	function() : ( guy )
		{
			guy.Anim_Stop()
			guy.DisableNPCFlag( NPC_IGNORE_ALL )
			guy.SetEfficientMode( false )
			guy.SetNoTarget( false )
			guy.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, true )
		}
	)

	FlagSet( "Hangar_LandGates" )
	if ( Flag( "Hangar_IntroReact" ) )
		return
	FlagEnd( "Hangar_IntroReact" )

	//We got the drop on them...6-4, we know what to do.
	thread PlayDialogue( "diag_sp_maltaGuns_STS296_02_01_mcor_gates", file.gates )

	while( 1 )
	{
		guy.Anim_ScriptedPlay( "CQB_CrouchIdle_MP" )
		guy.Anim_EnablePlanting()
		WaittillAnimDone( guy )
	}
}

void function Hangar_LandDavis( entity guy )
{
	FlagSet( "DavisLandedInHangar" )

	vector delta	= <1014.37, 445.518, -511.268>
	vector angles	= < 0, 117.199, 0>
	entity maltaRef = file.malta.mover
	vector pos 		= DeltaToWorldOrigin( delta, maltaRef )
	string anim 	= "run_2_crouch_45R"
	vector origin 	= HackGetDeltaToRefOnPlane( pos, angles, guy, anim, maltaRef.GetUpVector() )

	entity node = CreateScriptMover( origin, angles )
	node.SetParent( maltaRef, "REF", true, 0 )
	guy.SetParent( node, "REF", false, 0 )

	waitthread PlayAnimGravity( guy, anim, node, "REF", 0.0 )
	guy.ClearParent()

	OnThreadEnd(
	function() : ( guy )
		{
			guy.Anim_Stop()
			guy.DisableNPCFlag( NPC_IGNORE_ALL )
			guy.SetEfficientMode( false )
			guy.SetNoTarget( false )
			guy.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, true )
		}
	)

	FlagSet( "Hangar_LandDavis" )
	if ( Flag( "Hangar_IntroReact" ) )
		return
	FlagEnd( "Hangar_IntroReact" )

	while( 1 )
	{
		guy.Anim_ScriptedPlay( "CQB_CrouchIdle_MP" )
		guy.Anim_EnablePlanting()
		WaittillAnimDone( guy )
	}
}

vector function DeltaToWorldOrigin( vector delta, entity ref )
{
	vector r = ref.GetRightVector()
	vector f = ref.GetForwardVector()
	vector u = ref.GetUpVector()

	vector x =  r * delta.x
	vector y =  f * delta.y
	vector z =  u * delta.z

	return ref.GetOrigin() + x + y + z
}

void function MaltaHangar_LandedCheckpoint( entity player )
{
	FlagWait( "MaltaLandedInHangar" )

	//make sure player is still on the ship
	wait 1.0
	if ( Flag( "MaltaLandedInHangar") )
		CheckPoint()
}

/************************************************************************************************\

██████╗ ██████╗ ███████╗ █████╗  ██████╗██╗  ██╗
██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝██║  ██║
██████╔╝██████╔╝█████╗  ███████║██║     ███████║
██╔══██╗██╔══██╗██╔══╝  ██╔══██║██║     ██╔══██║
██████╔╝██║  ██║███████╗██║  ██║╚██████╗██║  ██║
╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

\************************************************************************************************/
void function MaltaBreach_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-38000,0> )
	SetupShips_MaltaHangar()

	SetOriginLocal( file.airBattleNode, V_MALTAWIDOW_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_WaitOnBarkerShip( bt, true )

	EnableScript( file.malta, "scr_malta_node_3" )
	EnableScript( file.malta, "scr_malta_node_3b" )
	thread HangarLiftLower( 0.1, 0, 0.1 )
	array<entity> spawners = GetEntArrayByScriptName( "hangar_fragDrones" )
	foreach ( spawner in spawners )
		spawner.Hide()
	FlagSet( "BridgeSpawnDudes" )

	thread MaltaBreach_BridgeGuys()
	bool teleport = true

	#if DEV
		if( GetBugReproNum() == 5 )
		{
			delaythread( 0.1 ) DevBreach_SetupFriendliesForRunTest()
			teleport = false
		}
	#endif
	StopMusic()
	PlayMusic( "music_s2s_11_downtobusiness" )
	thread Breach_CrewRunToBreachPositions( teleport )
	delaythread( 0.1 ) PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart4b" ) )
	delaythread( 0.5 ) FlagSet( "HangarFinished" )
}

void function DevBreach_SetupFriendliesForRunTest()
{
	entity node
	node = GetEntByScriptName( "breach_start_bear" )
	file.bear.SetOrigin( node.GetOrigin() )

	node = GetEntByScriptName( "breach_start_droz" )
	file.droz.SetOrigin( node.GetOrigin() )

	node = GetEntByScriptName( "breach_start_davis" )
	file.davis.SetOrigin( node.GetOrigin() )

	node = GetEntByScriptName( "breach_start_gates" )
	file.gates.SetOrigin( node.GetOrigin() )

	FlagSet( "BreachBearRec2Done" )
	FlagSet( "BreachDavisRec2Done" )
	FlagSet( "BreachDrozRec2Done" )
	FlagSet( "BreachGatesRec2Done" )
	//FlagSet( "CrewRunToBreach" )

	thread MaltaHangar_EndVO()
}

void function MaltaBreach_skip( entity player )
{
	GetEntByScriptName( "bridge_glass_right" ).SetModel( BRIDGE_GLASS_CRACKED_V6 )
	GetEntByScriptName( "bridge_glass_left" ).SetModel( BRIDGE_GLASS_CRACKED_V6 )
	ShipGeoShow( file.malta, "GEO_CHUNK_EXTERIOR_L" )
	ShipGeoHide( file.malta, "GEO_CHUNK_DECK_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_DECK" )

	SetBankTime( file.OLA, 10 ) //15
 	SetMaxPitch( file.OLA, 0 ) 	// 5

 	FlagSet( "BridgeBreached" )

 	switch( GetCurrentStartPoint() )
	{
		case "--------------":
		case "TestBed":
		case "Dropship Combat Test":
		case "LightEdit Connect":
		case "TRAILER bridge":
			//don't destroy the world
			return
			break
	}
}

void function MaltaBreach_Main( entity player )
{
	ShipGeoShow( file.malta, "GEO_CHUNK_EXTERIOR_L" )
	ShipGeoHide( file.malta, "GEO_CHUNK_DECK_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_DECK" )

	FlagInit( "BreachGoGoGo" )

	FlagWait( "HangarFinished" )
	CheckPoint()

	thread ShipIdleAtTargetPos( file.OLA, 	V_MALTABRIDGE_OLA, 	MALTABRDIGE_OLA_BOUNDS )
	SetBankTime( file.OLA, 10 )  //15
 	SetMaxPitch( file.OLA, 0 ) 	// 5

	thread ShipIdleAtTargetPos( file.malta, V_MALTABRIDGE_MALTA, MALTABRDIGE_MALTA_BOUNDS )

	//the friendlies get to the catwalk just outside the bridge from elsewhere in script... when they are ready... we get here
	FlagWaitAll( "BreachBearReady", "BreachDavisReady", "BreachDrozReady", "BreachGatesReady" )
	FlagWait( "PlayerInBreachPosition" )

	ClearDroppedWeapons()

	FlagSet( "StartingBreach")
	CheckPoint()

	wait 0.1

	entity glassR = GetEntByScriptName( "bridge_glass_right" )
	entity glassL = GetEntByScriptName( "bridge_glass_left" )

	thread Breach_TossSatchel( file.bear, 	"R_HAND", glassL, GetEntByScriptName( "breachPointBear" ) )
	thread Breach_TossSatchel( file.davis, 	"R_HAND", glassL, GetEntByScriptName( "breachPointDavis" ), true )
	thread Breach_TossSatchel( file.droz, 	"L_HAND", glassR, GetEntByScriptName( "breachPointDroz" ) )
	thread Breach_TossSatchel( file.gates, 	"L_HAND", glassR, GetEntByScriptName( "breachPointGates" ), true )
	thread Breach_WaitForPlayer()

	file.bear.Anim_ScriptedPlay( 	"pt_bridge_breach_Bear_start" 	)
	file.davis.Anim_ScriptedPlay( 	"pt_bridge_breach_Davis_start" 	)
	file.droz.Anim_ScriptedPlay( 	"pt_bridge_breach_Droz_start" 	)
	file.gates.Anim_ScriptedPlay( 	"pt_bridge_breach_Gates_start" 	)

	file.gates.WaitSignal( "BridgeReact" )
	glassR.SetModel( BRIDGE_GLASS_CRACKED )
	EmitSoundOnEntity( glassR, "scr_s2s_breech_scene_ricco" )

	FlagSet( "BridgeReact" )
	WaittillAnimDone( file.bear )

	file.bear.Anim_ScriptedPlay( 	"pt_bridge_breach_Bear_ready" 	)
	file.davis.Anim_ScriptedPlay( 	"pt_bridge_breach_Davis_ready" 	)
	file.droz.Anim_ScriptedPlay( 	"pt_bridge_breach_Droz_ready" 	)
	file.gates.Anim_ScriptedPlay( 	"pt_bridge_breach_Gates_ready" 	)

	FlagWait( "BreachGoGoGo" )

	array<entity> enemies = GetNPCArrayByScriptName( "bridge_guys" )
	enemies.append( GetNPCArrayByScriptName( "bridge_cpt" )[0] )
	enemies.randomize()

	thread HandleCustomSignals( file.bear )
	thread HandleCustomSignals( file.davis )
	thread HandleCustomSignals( file.droz )
	thread HandleCustomSignals( file.gates )
	file.bear.Anim_ScriptedPlay(  	"pt_bridge_breach_Bear_end"		)
	file.davis.Anim_ScriptedPlay(  	"pt_bridge_breach_Davis_end"	)
	file.droz.Anim_ScriptedPlay(  	"pt_bridge_breach_Droz_end"		)
	file.gates.Anim_ScriptedPlay(  	"pt_bridge_breach_Gates_end"	)

	float amplitude = 4
	float frequency = 200
	float duration = 1.0
	float radius = 2000

	file.bear.WaitSignal( "satchelblow" )
	EmitSoundOnEntity( glassL, "scr_s2s_breech_scene_glass_explode" )
	glassL.SetModel( BRIDGE_GLASS_CRACKED_V5 )
	CreateShake( glassL.GetOrigin(), amplitude, frequency, duration, radius )
	file.davis.WaitSignal( "satchelblow" )
	glassL.SetModel( BRIDGE_GLASS_CRACKED_V6 )
	CreateShake( glassL.GetOrigin(), amplitude, frequency, duration, radius )

	//destroy the ent playing the walla walla
	GetEntByScriptName( "bridgeWallaEnt" ).Destroy()

//	file.droz.WaitSignal( "satchelblow" )
	glassR.SetModel( BRIDGE_GLASS_CRACKED_V5 )
	CreateShake( glassR.GetOrigin(), amplitude, frequency, duration, radius )
	file.gates.WaitSignal( "satchelblow" )
	glassR.SetModel( BRIDGE_GLASS_CRACKED_V6 )
	CreateShake( glassR.GetOrigin(), amplitude, frequency, duration, radius )


	ShipGeoShow( file.malta, "GEO_CHUNK_EXTERIOR_L" )
	ShipGeoHide( file.malta, "GEO_CHUNK_DECK_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_DECK" )

	wait 0.2
	FlagSet( "BridgeBreached" )
	MaltaDeck_FlapsInit()
	EnableScript( file.malta, "scr_malta_node_5" )

	entity shield = GetEntByScriptName( "bridgeBackShield" )
	shield.NotSolid()
	shield.Hide()

	wait 0.2

	int fxId = GetParticleSystemIndex( FX_KILLSHOT_BLOODSPRAY )
	foreach ( enemy in enemies )
	{
		if ( IsAlive( enemy ) )
		{
			int attachID 	= enemy.LookupAttachment( "HEADSHOT" )
			StartParticleEffectOnEntity( enemy, fxId, FX_PATTACH_POINT_FOLLOW, attachID )
			EmitSoundAtPosition( TEAM_ANY, enemy.GetOrigin(), "diag_sp_s2s_glassBreach_deaths" )
			enemy.TakeDamage( enemy.GetMaxHealth() + 1, null, null, { damageSourceId = eDamageSourceId.mp_weapon_dmr } )
		}

		wait 0.3
	}

	WaittillAnimDone( file.bear )
	FlagSet( "BridgeClear" )
	CheckPoint()
}

void function Breach_CrewRunToBreachPositions( bool teleport = false )
{
	FlagWait( "HangarFinished" )

	wait 0.2 //wait to ensure that script node 4 is enabled

	array<entity> crew 		= Breach_GetCrew()
	array<asset> records 	= [ $"anim_recording/s2s_record_breach_Bear_1.rpak",
								$"anim_recording/s2s_record_breach_davis_1.rpak",
								$"anim_recording/s2s_record_breach_droz_1.rpak",
								$"anim_recording/s2s_record_breach_Gates_1.rpak" ]
	array<string> idles 	= [ "pt_bridge_breach_Bear_idle",
								"pt_bridge_breach_davis_idle",
								"pt_bridge_breach_droz_idle",
								"pt_bridge_breach_Gates_idle" ]
	array<string> flags 	= [	"BreachBearReady",
								"BreachDavisReady",
								"BreachDrozReady",
								"BreachGatesReady" ]
	array<string> waitFlag 	= [	"BreachBearRec2Done",
								"BreachDavisRec2Done",
								"BreachDrozRec2Done",
								"BreachGatesRec2Done" ]
	array<string> buddyFlag	= [	"CrewRunToBreach",
								"breachRunGoBear",
								"breachRunGoDavis",
								"breachRunGoBear" ]
	array<string> goFlag	= [	"breachRunGoBear",
								"breachRunGoDavis",
								"breachRunGoDroz",
								"breachRunGoGates" ]
	array<string> arrivals 	= [	"run_2_stand_90R",
								"run_2_stand_45R",
								"run_2_stand_90R",
								"pt_bridge_breach_Gates_arrive" ]

	entity bridgeCpt = GetNPCArrayByScriptName( "bridge_cpt" )[0]

	foreach( guy in crew )
	{
		guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )
	//	guy.EnableNPCFlag( NPC_IGNORE_ALL )
		guy.kv.allowshoot = false
		guy.LockEnemy( bridgeCpt )
		guy.SetNoTarget( true )
	}

	if ( !teleport )
	{
		foreach ( index, guy in crew )
			thread Breach_FriendlyBreachSetup( guy, records[ index ], idles[ index ], flags[ index ], waitFlag[ index ], buddyFlag[ index ], goFlag[ index ], arrivals[ index ] )
	}
	else
	{
		array<vector> deltas = Breach_GetCrewDeltas()
		array<vector> angles = Breach_GetCrewAngles()

		foreach ( index, guy in crew )
		{
			vector origin = GetWorldPosRelativeToShip( file.malta.templateOrigin, file.malta, deltas[ index ] )
			guy.SetOrigin( origin )
			guy.SetAngles( angles[ index ] )
			guy.Anim_ScriptedPlay( idles[ index ] )
			FlagSet( flags[ index ] )
		}
	}
}

array<entity> function Breach_GetCrew()
{
	array<entity> crew 		= [ file.bear,
								file.davis,
								file.droz,
								file.gates ]
	return crew
}

array<vector> function Breach_GetCrewDeltas()
{
	array<vector> deltas = [	< -139.913, 3459.14, 563.534 >,
								< -34.025, 3487.61, 563.406 >,
								< 38.6379, 3485.86, 562.486 >,
								< 143.848, 3495.9, 560.149 > ]
	return deltas
}

array<vector> function Breach_GetCrewAngles()
{
	array<vector> angles = [ 	< 0, 83.0587, 0 >,
									< 0, 117.817, 0 >,
									< 0, 76.3081, 0 >,
									< 0, 91.6717, 0 > ]
	return angles
}

void function Breach_WaitForPlayer()
{
	file.davis.WaitSignal( "vo64" )
	//need to get the duration of sounds on the server ( GetSoundDuration )
	wait 2.5

	AddConversationCallback( "Breach_Go", ConvoCallback_Breach_Go )
	waitthread PlayerConversation( "Breach_Go", file.player )

	if ( !Flag( "BreachGoGoGo" ) )
	{
		//Ready or not...
		waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS319_01a_01_mcor_bear", file.bear )
		FlagSet( "BreachGoGoGo" )
	}
}


void function ConvoCallback_Breach_Go( int choice )
{
	if ( choice != 0 )
		FlagSet( "BreachGoGoGo" )
}

void function Breach_TossSatchel( entity guy, string tag, entity glass, entity breachPoint, bool bigBreak = false )
{
	guy.WaitSignal( "satchelgrab" )

	int attachID 	= guy.LookupAttachment( tag )
	vector origin 	= guy.GetAttachmentOrigin( attachID )
	vector angles 	= guy.GetAttachmentAngles( attachID )
	entity satchel 	= CreateExpensiveScriptMoverModel( SATCHEL_MODEL, origin, angles )
	satchel.SetParent( guy, tag, false, 0 )
	satchel.MarkAsNonMovingAttachment()

	guy.WaitSignal( "satchelthrow" )

	//throw it.
	//EmitSoundOnEntity( guy, "weapon_r1_satchel.throw" )
	satchel.SetParent( file.malta.model, "", true, 0 )
	satchel.NonPhysicsSetMoveModeLocal( true )
	satchel.NonPhysicsSetRotateModeLocal( true )

	float time = 0.2
	satchel.NonPhysicsMoveTo( breachPoint.GetLocalOrigin(), time, 0, 0 )
	satchel.NonPhysicsRotateTo( AnglesCompose( breachPoint.GetLocalAngles(), <0,180,RandomFloat( 330 ) > ), time, 0, 0 )

	wait time
	int fxID0 = GetParticleSystemIndex( SATCHEL_BLINK_FX )
	attachID = satchel.LookupAttachment( "BLINKER" )
	entity particle = StartParticleEffectOnEntity_ReturnEntity( satchel, fxID0, FX_PATTACH_POINT_FOLLOW, attachID )
	EmitSoundOnEntity( satchel, "scr_s2s_breech_scene_mines_stick" )

	guy.WaitSignal( "satchelblow" )

	if ( IsValid( satchel ) )
		satchel.Hide()
	if ( IsValid( particle ) )
		particle.Destroy()

	//EmitSoundOnEntity( satchel, "glass_shatter_loud" )
	attachID = satchel.LookupAttachment( "REF" )
	StartParticleEffectOnEntity( satchel, GetParticleSystemIndex( BREACH_FX1 ), FX_PATTACH_POINT_FOLLOW, attachID )
	//StartParticleEffectOnEntity( satchel, GetParticleSystemIndex( BREACH_FX_GLASS ), FX_PATTACH_POINT_FOLLOW, attachID )

	entity fxDummy2
	if ( bigBreak )
	{
		entity maltaRef = file.malta.mover
		fxDummy2 = CreateScriptMover( glass.GetOrigin(), AnglesCompose( glass.GetAngles(), <0,0,0> ) )
		fxDummy2.SetParent( maltaRef, "", true, 0 )
		attachID = fxDummy2.LookupAttachment( "REF" )
		StartParticleEffectOnEntity( fxDummy2, GetParticleSystemIndex( BREACH_FX_GLASS ), FX_PATTACH_POINT_FOLLOW, attachID )
	}

	guy.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_IGNORE_CLUSTER_DANGER_TIME )
	guy.DisableNPCFlag( NPC_IGNORE_ALL )
	guy.kv.allowshoot = true
	guy.SetNoTarget( false )

	wait 10

	if ( IsValid( satchel ) )
		satchel.Destroy()
	if ( IsValid( fxDummy2 ) )
		fxDummy2.Destroy()
}

void function Breach_FriendlyBreachSetup( entity guy, asset recanim, string idle, string _flag, string waitFlag, string buddyFlag, string goFlag, string arrival = "" )
{
	entity maltaRef = file.malta.mover
	vector origin 	= <0,0,0>
	vector angles 	= <0,0,0>
	var rec 		= LoadRecordedAnimation( recanim )

	FlagWait( waitFlag )
	bool disableArrival = false
	waitthread RunToRecordedAnimStart( guy, rec, origin, angles, maltaRef, disableArrival )

	if ( !Flag( buddyFlag ) )
	{
		entity ref = GetEntByScriptName( "bridgeAimTarget" )
		vector vec = Normalize( ref.GetOrigin() - guy.GetOrigin() )
		vector face = VectorToAngles( vec )
		face = <0,face.y,0>
		if ( guy == file.gates )
			guy.SetAngles( face )
		else
			guy.SetAngles( CONVOYDIR )

		if ( guy != file.gates )
		{
			guy.Anim_ScriptedPlay( "Walk_Backward_mp" )
			guy.Anim_EnablePlanting()
			float duration = guy.GetSequenceDuration( "Walk_Backward_mp" )
			wait duration - 0.1
		}

		if ( !Flag( buddyFlag ) )
		{
			guy.Anim_ScriptedPlay( "CQB_Idle_MP" )
			guy.Anim_EnablePlanting()
		}

		FlagWait( buddyFlag )
		if ( guy != file.gates )
		{
			guy.Anim_ScriptedPlay( "stand_2_run_F_v2" )
			guy.Anim_EnablePlanting()
			float duration = guy.GetSequenceDuration( "stand_2_run_F_v2" )
			wait duration - 0.2
		}

		guy.SetEfficientMode( false )
	}
	FlagSet( goFlag )

	thread Breach_FriendlyBreachRunup( guy, rec, origin, angles, maltaRef, idle, _flag, arrival )
}

void function Breach_FriendlyBreachRunup( entity guy, var rec, vector origin, vector angles, entity maltaRef, string idle, string _flag, string arrival = "" )
{
	waitthread PlayRecordedAnim( guy, rec, origin, angles, maltaRef )
	if ( arrival != "" )
	{
		guy.Anim_ScriptedPlay( arrival )
		guy.Anim_EnablePlanting()
		guy.SetAngles( <0,guy.GetAngles().y,0> )
		float time = guy.GetSequenceDuration( arrival )
		wait time - 0.1
		guy.Anim_Stop()
	}

	#if DEV
		if ( GetBugReproNum() == 5 )
		{
			vector delta	= GetRelativeDelta( guy.GetOrigin(), maltaRef )
			printt( "" + guy.GetTitle() + " delta: " + delta )
			printt( "" + guy.GetTitle() + " angles: " + guy.GetAngles() )
		}
	#endif

	guy.Anim_ScriptedPlay( idle )

	FlagSet( _flag )
}

void function MaltaBreach_BridgeGuys()
{
	//handle guys animating at the bridge
	FlagWaitAny( "BridgeSpawnDudes", "HangarFinished" )
	EnableScript( file.malta, "scr_malta_node_4" )

	array<entity> guys = SpawnOnShipFromScriptName( "bridge_guys", file.malta )
	guys.append( SpawnOnShipFromScriptName( "bridge_cpt", file.malta )[0] )
	foreach ( guy in guys )
		thread MaltaBreach_Enemies( guy )

	//handle setting react notify on glass breaking
	entity glassR = GetEntByScriptName( "bridge_glass_right" )
	entity glassL = GetEntByScriptName( "bridge_glass_left" )
	thread MaltaBreach_ReactOnGlassShot( glassR )
	thread MaltaBreach_ReactOnGlassShot( glassL )
}

void function MaltaBreach_ReactOnGlassShot( entity glass )
{
	if ( Flag( "BridgeReact" ) )
		return
	FlagEnd( "BridgeReact" )

	glass.DisableHibernation()
	glass.SetDamageNotifications( true )

	OnThreadEnd(
	function() : ( glass )
		{
			glass.SetDamageNotifications( false )
			entity sndEnt = GetEntByScriptName( "bridgeWallaEnt" )
			EmitSoundOnEntity( sndEnt, "diag_sp_glassWalla_STS100_01_01_imc_grunts" )
		}
	)

	while( 1 )
	{
		WaitFrame() //handle infinite loops

		glass.WaitSignal( "OnDamaged" )

		if ( !Flag( "PlayerInBreachPosition" ) )
			continue

		FlagSet( "BridgeReact" )
	}
}

void function MaltaBreach_Enemies( entity guy )
{
	FlagEnd( "BridgeBreached" )
	guy.EndSignal( "OnDeath" )

	guy.SetEfficientMode( true )
	guy.SetNoTarget( true )
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.kv.allowshoot = false
	guy.DisableHibernation()

	entity refPos = guy.GetLinkEnt()
	Assert( IsValid( refPos ) )
	refPos.DisableHibernation()
	refPos.SetLocalAngles( AnglesCompose( refPos.GetLocalAngles(), <0,-90,0> ) )

	string anim = expect string( guy.kv.animIdle )
	vector originH = HackGetDeltaToRefOnPlane( refPos.GetOrigin(), refPos.GetAngles(), guy, anim, file.malta.model.GetUpVector() )
	entity anchor = CreateScriptMover( originH, refPos.GetAngles() )
	anchor.SetParent( file.malta.model, "", true, 0 )
	anchor.DisableHibernation()
	guy.SetParent( anchor )

	entity node = refPos.GetLinkEnt()
	Assert( IsValid( node ) )
	refPos.Destroy()

	guy.Anim_ScriptedPlay( anim )
	guy.Anim_SetInitialTime( RandomFloatRange( 0, 10 ) )

	OnThreadEnd(
	function() : ( guy, anchor )
		{
			if ( IsValid( guy ) )
				guy.ClearParent()

			if ( IsValid( anchor ) )
				anchor.Destroy()

			if ( !IsAlive( guy ) )
				return

			guy.Anim_Stop()
			guy.ClearParent()
			guy.SetEfficientMode( false )
			guy.SetNoTarget( false )
			guy.DisableNPCFlag( NPC_IGNORE_ALL )
			guy.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT )
			guy.kv.allowshoot = true

			array<string> anims = [ "pt_agent_react_cloak_panic_fire_far",
									"pt_agent_react_cloak_blindfire",
									"pt_agent_dodge_L",
									"pt_agent_dodge_L_duck",
									"pt_agent_dodge_R",
									"pt_agent_dodge_R_duck",
									"pt_agent_pain_helmet",
									"pt_agent_pain_head",
									"pt_agent_reload_backpedal_fast",
									"pt_agent_react_cloak_wildfire" ]

			guy.Anim_ScriptedPlay( anims.getrandom() )
			guy.Anim_EnablePlanting()
		}
	)

	FlagWait( "BridgeReact" )

	float delay = RandomFloat( 0.23 )
	if ( delay >= 0.1 )
		wait delay

	guy.ClearParent()
	guy.SetAngles( < 0, guy.GetAngles().y ,0 > )

	if ( IsValid( anchor) )
		anchor.Destroy()

	anim = expect string( guy.kv.animReact )
	guy.Anim_ScriptedPlay( anim )
	guy.Anim_EnablePlanting()

	float time = guy.GetSequenceDuration( anim )
	wait time - 0.5

	guy.SetEfficientMode( false )
	guy.DisableNPCFlag( NPC_IGNORE_ALL )
	guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	guy.SetEnemy( file.player )

	vector origin = guy.GetOrigin()
	string idle = "pt_agent_angry_scan"

	bool disableArrival = true
	vector angles1 = AnglesCompose( node.GetAngles(), <0,180,0> )
	waitthread RunToAnimStartForced_Deprecated( guy, idle, node.GetOrigin(), angles1, disableArrival )

	entity ref = GetEntByScriptName( "bridgeAimTarget" )
	vector vec = Normalize( ref.GetOrigin() - guy.GetOrigin() )
	vector angles = VectorToAngles( vec )
	angles = <0,angles.y,0>

	array<array<string> >  twitch
	twitch.append( [ "pt_agent_react_cloak_serach_F_far", "pt_agent_react_cloak_beckpedal" ] )
	twitch.append( [ "pt_agent_trans_2_search", "pt_agent_search_2_angry" ] )
	twitch.append( [ "pt_agent_react_2_search", "pt_agent_search_2_angry" ] )
	twitch.append( [ "pt_agent_twitch_twitch" ] )
	twitch.append( [ "pt_agent_signal_encircle" ] )
	twitch.append( [ "pt_agent_signal_readyup" ] )
	twitch.append( [ "pt_agent_signal_gogo" ] )
	twitch.append( [ "pt_agent_signal_hold" ] )
	twitch.append( [ "pt_agent_signal_spotted" ] )
	twitch.append( [ "pt_agent_react_cloak_panic" ] )
	twitch.append( [ "pt_agent_react_cloak_search" ] )
	twitch.append( [ "pt_agent_reload_dodge_shift", ] )


	//guy.SetAngles( angles )

	while( 1 )
	{
		guy.Anim_Stop()
		guy.Anim_ScriptedPlay( idle )
		guy.Anim_EnablePlanting()

		wait RandomFloatRange( 0.75, 1.5 )
		array<string> anims = twitch.getrandom()

		foreach ( anim in anims )
		{
			guy.Anim_Stop()
			guy.Anim_ScriptedPlay( anim )
			guy.Anim_EnablePlanting()
			time = guy.GetSequenceDuration( anim )
			wait time - 0.1
		}
	}
}

/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗     ██████╗ ██████╗ ██╗██████╗  ██████╗ ███████╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██╔══██╗██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝
██╔████╔██║███████║██║     ██║   ███████║    ██████╔╝██████╔╝██║██║  ██║██║  ███╗█████╗
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██╔══██╗██╔══██╗██║██║  ██║██║   ██║██╔══╝
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ██████╔╝██║  ██║██║██████╔╝╚██████╔╝███████╗
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝

\************************************************************************************************/
const float MALTA_FLIGHTCONTROL_ACC = 100
const float MALTA_FLIGHTCONTROL_SPEED = 500
const float MALTA_FLIGHTCONTROL_BANKTIME = 5.0
void function MaltaBridge_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-38000,0> )
	SetupShips_MaltaBridge()

	SetOriginLocal( file.airBattleNode, V_MALTAWIDOW_AIRBATTLE )
	thread UpdatePosWithLocalSpace( file.airBattleNode )
	thread CreateAirBattle()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_WaitOnBarkerShip( bt, true )

	EnableScript( file.malta, "scr_malta_node_4" )
	MaltaDeck_FlapsInit()
	EnableScript( file.malta, "scr_malta_node_5" )

	MaltaBridge_SetupCrew()
	StopMusic()
	PlayMusic( "music_s2s_11_downtobusiness" )
	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart4b" ) )
	delaythread( 0.5 ) FlagSet( "BridgeClear" )
}

void function MaltaBridge_SetupCrew()
{
	array<entity> crew 		= Breach_GetCrew()
	array<vector> deltas 	= Breach_GetCrewDeltas()
	array<vector> angles 	= Breach_GetCrewAngles()

	foreach ( index, guy in crew )
	{
		vector origin = GetWorldPosRelativeToShip( file.malta.templateOrigin, file.malta, deltas[ index ] )
		guy.SetOrigin( origin )
		guy.SetAngles( angles[ index ] )
		wait 0.1
		guy.Anim_ScriptedPlay( "CQB_Idle_Scan" )
	}
}

void function MaltaBridge_Skip( entity player )
{
	FlagSet( "BridgeSkipped" )
	GetEntByScriptName( "MaltaSideClip" ).NotSolid()

	file.airBattleNode = file.malta.mover
	file.airBattleData = GetAirBattleStructMaltaDeck()
	FlagSet( "StopAirBattleDeaths_IMC" )
	FlagSet( "StopAirBattleDeaths_MILITIA" )
	FlagSet( "StopAirBattleRespawns_IMC" )
}

void function MaltaBridge_Main( entity player )
{
	FlagWait( "BridgeClear" )

	ShipIdleAtTargetPos( file.gibraltar, 	V_MALTABRIDGE_GIBRALTAR, BARKER_GIBRALTAR_BOUNDS )
	
	array<entity> crew 		= Breach_GetCrew()
	array<asset> records 	= [ $"anim_recording/s2s_record_bridge_Bear_1.rpak",
								$"anim_recording/s2s_record_bridge_davis_1.rpak",
								$"anim_recording/s2s_record_bridge_droz_1.rpak",
								$"anim_recording/s2s_record_bridge_Gates_1.rpak" ]
	array<float> delays 	= [ 0.0,
								1.5,
								1.0,
								1.75 ]
	array<string> idles 	= [ "CQB_Idle_Casual",
								"CQB_Idle_Casual",
								"CQB_Idle_Casual",
								"CQB_Idle_Casual" ]
	array<string> arrivals 	= [	"run_2_stand_45R",
								"run_2_stand_45L",
								"run_2_stand_45L",
								"run_2_stand_45R" ]
	

	foreach ( index, guy in crew )
		thread MaltaBridge_CrewRunup( guy, records[ index ], delays[ index ], idles[ index ], arrivals[ index ] )

	thread FlightPanelThink( player, MaltaBridge_FlightControlOutput )

	waitthreadsolo MaltaBridge_NagConsole()
	waitthreadsolo MaltaBridge_NagUseConsole()

	file.malta.FuncGetBankMagnitude = GetBankMagnitudeCapShip

	thread MaltaBridge_MoveAirBattle()
	thread MaltaBridge_BarkerShipThink()

	LocalVec destination = GetMaltaOnCourseDestination()
	float distCheckSqr = pow( 3000, 2 )
	entity maltaRef = file.malta.mover
	entity olaRef = file.OLA.mover

	while( 1 )
	{
		LocalVec origin = GetOriginLocal( maltaRef )
		if ( DistanceSqr( destination.v, origin.v ) < distCheckSqr )
			break

		#if DEV
			if ( GetBugReproNum() == 20 )
				printt( "OLA: " + GetOriginLocal( olaRef ).v + ", MALTA: " + origin.v + ", dist: " + Distance( destination.v, origin.v ) )
		#endif

		WaitFrame()
	}

	thread MaltaChasesOla()
	GetEntByScriptName( "MaltaSideClip" ).NotSolid()
	FlagSet( "MaltaOnCourse" )
}

void function MaltaBridge_BarkerShipThink()
{
	FlagWait( "PlayerUsedBridgeConsole" )
	FlagEnd( "MaltaOnCourse" )

	entity bt = file.player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_BarkerShipRueniteIdle( bt )

	vector bounds = <0,0,0>
	vector offset = <0,0,0>
	vector delta = MALTABRIDGE_BARKER_DELTA + <0,0,-2500>
	ShipIdleAtTargetEnt_Teleport( file.barkership, file.malta.mover, bounds, delta, offset )

	float mag = 3
	SetMaxAcc( file.barkership, 	MALTA_FLIGHTCONTROL_ACC * mag )
	SetMaxSpeed( file.barkership, 	MALTA_FLIGHTCONTROL_SPEED * mag )
	SetBankTime( file.barkership, 	MALTA_FLIGHTCONTROL_BANKTIME * 0.5 )
	file.barkership.FuncGetBankMagnitude = BarkerTightBankMagnitude

	FlagWait( "BarkerBringsBtToReunite" )

	wait 3

	thread ShipIdleAtTargetEnt( file.barkership, file.malta.mover, MALTABRIDGE_BARKER_BOUNDS, MALTABRIDGE_BARKER_DELTA, offset )
}

float function BarkerTightBankMagnitude( float dist )
{
	return GraphCapped( dist, 0, 200, 0.0, 1.0 )
}

void function MaltaBridge_MoveAirBattle()
{
	foreach ( team, dropships in file.dropships )
	{
		foreach ( teamIndex, ship in dropships )
		{
			if ( !IsValid( ship.model ) )
				continue
			if ( !IsShipOnBattleField( ship ) )
				continue

			SetMaxAcc( ship, ship.defAccMax * 1.75, 4 )
			SetMaxSpeed( ship, ship.defSpeedMax * 1.75, 4 )
		}
	}

	float height = 2500

	//figure out where the airbattle is in relation to the malta so we can move it with the malta on the x
	LocalVec pos = GetOriginLocal( file.airBattleNode )
	pos.v += < 0,0,height >
	SetOriginLocal( file.airBattleNode, pos )
	vector airBattleDelta = file.airBattleNode.GetOrigin() - file.malta.mover.GetOrigin()

	//move the air battle
	float stopTime = Time() + 6.0
	while( Time() < stopTime )
	{
		LocalVec pos = GetOriginLocal( file.malta.mover )
		pos.v += airBattleDelta
		SetOriginLocal( file.airBattleNode, pos )
		file.airBattleNode.SetAngles( file.malta.mover.GetAngles() )
		WaitFrame()
	}

	FlagSet( "StopAirBattleDeaths_IMC" )
	FlagSet( "StopAirBattleDeaths_MILITIA" )
	FlagSet( "StopAirBattleRespawns_IMC" )

	pos = GetOriginLocal( file.malta.mover )
	pos.v += file.malta.mover.GetUpVector() * height
	SetOriginLocal( file.airBattleNode, pos )
	airBattleDelta = file.airBattleNode.GetOrigin() - file.malta.mover.GetOrigin()

	//new ships will go to the correct positions
	file.airBattleData 	= GetAirBattleStructMaltaDeck()
	UpdateAirBattle()

	stopTime = Time() + 10.0
	while( Time() < stopTime )
	{
		LocalVec pos = GetOriginLocal( file.malta.mover )
		pos.v += airBattleDelta
		SetOriginLocal( file.airBattleNode, pos )
		file.airBattleNode.SetAngles( file.malta.mover.GetAngles() )
		WaitFrame()
	}

	entity oldBattleNode 	= file.airBattleNode
	file.airBattleNode 		= file.malta.mover
	UpdateAirBattle()
	oldBattleNode.Destroy()

	wait 6.0
	foreach ( team, dropships in file.dropships )
	{
		foreach ( teamIndex, ship in dropships )
		{
			if ( !IsValid( ship.model ) )
				continue
			if ( !IsShipOnBattleField( ship ) )
				continue

			ResetMaxAcc( ship, 4 )
			ResetMaxSpeed( ship, 4 )
		}
	}
}

void function MaltaChasesOla( bool teleport = false )
{
	if ( teleport )
	{
		ShipIdleAtTargetPos_Teleport( file.OLA, V_MALTABRIDGE_OLA, 	MALTABRDIGE_OLA_BOUNDS )
		ShipIdleAtTargetPos_Teleport( file.malta, V_MALTADECK_MALTA, MALTADECK_MALTA_BOUNDS )
	}
	else
	{
		thread ShipIdleAtTargetPos( file.OLA, 	V_MALTABRIDGE_OLA, 	MALTABRDIGE_OLA_BOUNDS )
		thread ShipIdleAtTargetPos( file.malta, V_MALTADECK_MALTA, 	MALTADECK_MALTA_BOUNDS )
	}
}

void function MaltaBridge_NagConsole()
{
	if ( Flag( "PlayerUsedBridgeConsole" ) )
		return
	FlagEnd( "PlayerUsedBridgeConsole" )

	//6-4 on me. Cooper, get to the Captain's console and disable the guns.
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS327_01a_01_mcor_bear", file.bear )

	entity marker = Objective_GetMarkerEntity()
	marker.ClearParent()
	Objective_Set( "#S2S_OBJECTIVE_HACKBRIDGE" , <0,0,0>, GetEntByScriptName( "maltaBridgeControl" ) )
	Objective_StaticModelHighlightOverrideEntity( file.objBridgePanel )

	wait 4

	if ( Flag( "BridgePlayerNearConsole" ) )
		return
	FlagEnd( "BridgePlayerNearConsole" )

	while ( 1 )
	{
		//Coop, the console's up here.
		waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS328_01a_01_mcor_droz", file.droz )
		wait 15

		//"The console's over here, coop."
		waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS334_01_01_mcor_davis", file.davis )
		Objective_Remind()
		wait 15
	}
}

void function MaltaBridge_NagUseConsole()
{
	if ( Flag( "PlayerUsedBridgeConsole" ) )
		return
	FlagEnd( "PlayerUsedBridgeConsole" )

	while( IsDialoguePlaying() )
		wait 0.1

	wait 0.5

	while ( 1 )
	{
		//Cooper, bypass that console! Kill the guns.
		waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS337_01_01_mcor_bear", file.bear )
		Objective_Remind()
		wait 30
	}
}

LocalVec function GetMaltaOnCourseDestination()
{
	float x = V_MALTABRIDGE_OLA.v.x
	float z = V_MALTABRIDGE_OLA.v.z
	float y = V_MALTABRIDGE_MALTA.v.y

	LocalVec destination = CLVec( < x,y,z > )

	return destination
}

void function MaltaBridge_CrewRunup( entity guy, asset recanim, float delay, string idle, string arrival )
{
	entity maltaRef = file.malta.mover
	vector origin 	= <0,0,0>
	vector angles 	= <0,0,0>
	var rec 		= LoadRecordedAnimation( recanim )
	float blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME
	float blendOutTime = 0.1

	if ( guy == file.droz )
		blendOutTime = 0.0

	wait delay
	waitthread PlayRecordedAnim( guy, rec, origin, angles, maltaRef, blendTime, blendOutTime )

	if ( arrival != "" )
	{
		guy.Anim_ScriptedPlay( arrival )
		guy.Anim_EnablePlanting()
		float time = guy.GetSequenceDuration( arrival )
		wait time - 0.1
	}

	guy.Anim_ScriptedPlay( idle )
	guy.Anim_EnablePlanting()
}

void function MaltaBridge_FlightControlOutput( entity player, entity target )
{
	if ( Flag( "MaltaOnCourse" ) )
		return
	FlagEnd( "MaltaOnCourse" )

	//SetMaxRoll( file.malta, 60, 1 )
	SetMaxPitch( 	file.malta, 	10, 	5.0) 	//def 5
	SetMaxAcc( 		file.malta, 	MALTA_FLIGHTCONTROL_ACC, 	5.0 )	//def 13
	SetMaxSpeed( 	file.malta, 	MALTA_FLIGHTCONTROL_SPEED, 	5.0 ) 	//def 120
	SetBankTime( 	file.malta, 	MALTA_FLIGHTCONTROL_BANKTIME ) 		//def 15

	OnThreadEnd(
	function() : ()
		{
			thread MaltaBridge_ResetMaltaFlightParams()
		}
	)

	float targetDist = 5000
	entity maltaRef 	= file.malta.mover

	vector right = <1,0,0>
	vector up = <0,0,1>
	vector targetPos, dir, delta
	bool inputNeeded = false

	vector DEV_veiwDelta = <0,7000,500>

	while( 1 )
	{
		float pitch = player.GetInputAxisForward() * -1.0 //GetBinaryInput( player.GetInputAxisForward() * -1.0 )
		float roll 	= player.GetInputAxisRight() //GetBinaryInput( player.GetInputAxisRight() * -1.0 )

		vector origin 	= maltaRef.GetOrigin()

		//should we have a new dir?
		if ( pitch != 0 || roll != 0 )
		{
			//first get a direction
			dir 	= Normalize( ( right * roll ) + ( up * pitch ) )
			delta 	= dir * targetDist

			//now make an initial position
			targetPos = origin + delta

			//now check for bounds
			vector adjustedPos =  GetAdjustedPos( targetPos )

			//convert it into a local vec
			float localY = V_MALTADRONE_MALTA.v.y
			LocalVec finalDest = CLVec( < adjustedPos.x, localY, adjustedPos.z > )
			SetOriginLocal( target, finalDest )

			inputNeeded = true
		}
		else if ( inputNeeded )
		{
			//use the old dir
			float dec 		= -file.malta.accMax
			float dist = GetStopDistanceAtFullDeceleration( maltaRef, dec )
			delta 	= dir * dist

			//now make an initial position
			targetPos = origin + delta

			//now check for bounds
			vector adjustedPos = GetAdjustedPos( targetPos )

			//convert it into a local vec
			float localY = V_MALTADRONE_MALTA.v.y
			LocalVec finalDest = CLVec( < adjustedPos.x, localY, adjustedPos.z > )
			SetOriginLocal( target, finalDest )

			thread UpdatePosWithLocalSpace( target )

			inputNeeded = false
		}

		#if DEV
			if ( GetBugReproNum() == 5 )
			{
				printt( "malta origin: ", maltaRef.GetOrigin() )
				DebugDrawLine( origin + DEV_veiwDelta, target.GetOrigin() + DEV_veiwDelta, 255, 0, 0, true, FRAME_INTERVAL )
				DebugDrawCircle( target.GetOrigin() + DEV_veiwDelta, <0,0,0>, 75, 255, 0, 0, true, FRAME_INTERVAL, 3 )
			}
		#endif

		WaitFrame()
	}
}

void function MaltaBridge_ResetMaltaFlightParams()
{
	wait 1

	ResetMaxPitch( file.malta, 1 )
	ResetMaxRoll( file.malta, 1 )
	ResetMaxAcc( file.malta, 5 )
	ResetMaxSpeed( file.malta, 5 )
	ResetBankTime( file.malta )
}

vector function GetAdjustedPos( vector targetPos )
{
	float minX = -10000
	float maxX = 10000
	float minZ = -8000
	float maxZ = 10000
	float x,y,z

	x = max( targetPos.x, minX )
	x = min( x, maxX )
	z = max( targetPos.z, minZ )
	z = min( z, maxZ )
	y = targetPos.y

	vector adjustedPos = < x, y, z >

	return adjustedPos
}

float function GetBinaryInput( float input )
{
	if ( fabs( input ) < 0.1 )
		return 0.0
	else if ( input < 0 )
		return -1.0
	else
		return 1.0
	unreachable
}

/************************************************************************************************\

███████╗██╗     ██╗ ██████╗ ██╗  ██╗████████╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗
██╔════╝██║     ██║██╔════╝ ██║  ██║╚══██╔══╝    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║
█████╗  ██║     ██║██║  ███╗███████║   ██║       ██████╔╝███████║██╔██╗ ██║█████╗  ██║
██╔══╝  ██║     ██║██║   ██║██╔══██║   ██║       ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║
██║     ███████╗██║╚██████╔╝██║  ██║   ██║       ██║     ██║  ██║██║ ╚████║███████╗███████╗
╚═╝     ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝

\************************************************************************************************/
void function FlightPanelThink( entity player, void functionref(entity,entity) FlightControlOutputFunc )
{
	FlagEnd( "MaltaOnCourse" )
	player.EndSignal( "OnDeath" )

	entity panel = FlightPanelSetupConsole()

	entity trigger = GetEntByScriptName( "bridgeUseTrigger" )//panel
	trigger.SetUsable()
	trigger.SetUsableByGroup( "pilot" )
	trigger.SetUsePrompts( "#HOLD_TO_USE_GENERIC" , "#PRESS_TO_USE_GENERIC" )

	//wait for the player to use the panel
	entity playerActivator
	while( true )
	{
		playerActivator = expect entity( trigger.WaitSignal( "OnPlayerUse" ).player )
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() && !playerActivator.IsTitan() )
		{
			player = expect entity( trigger.WaitSignal( "OnPlayerUse" ).player )
			break
		}
	}

	FlagSet( "PlayerUsedBridgeConsole" )
	file.objBridgePanel.Destroy()
	Objective_SetSilent( "#S2S_OBJECTIVE_HACKBRIDGE" )
	delaythread( 4.0 ) FlightPanelMusic()
	delaythread( 2.0 ) FlagSet( "DeckGunsTurnedOff" )

	//undo the panel visuals
	trigger.UnsetUsable()
	//animate the player

	// NOTE- data knife is created on the client using 1P proxy anim callback "create_dataknife" in s2s_bridge_console_start
	// - unsheathing knife anim is played using 1P proxy anim callback "knife_popout" in s2s_bridge_console_start
	// - knife is automatically cleaned up by data knife scripts once player loses parent (1P proxy)

	entity fpsProxy = player.GetFirstPersonProxy()
	entity node = panel//GetEntByScriptName( "maltaHangarFlightPanel" )

	float blendTime = 0.5
	player.SetParent( node, "", false, blendTime )
	player.DisableWeaponWithSlowHolster()

	//create target that the malta will follow ( and the player will control )
	entity maltaRef = file.malta.mover
	entity target = CreateScriptMover()
	LocalVec currOrigin = GetOriginLocal( maltaRef )
	SetOriginLocal( target, currOrigin )
	thread UpdatePosWithLocalSpace( target )
	SetBankTime( file.malta, 2 ) //hack so it's immediately responsive
	thread ShipIdleAtTargetEnt( file.malta, target, <0,0,0> )

	//turn off the hurt trigger at the bottom of the level
	entity WorldEdgeTriggerHurt = GetEntByScriptName( "WorldEdgeTriggerHurt" )
	WorldEdgeTriggerHurt.Disable()

	OnThreadEnd(
	function() : ( player, node, target, WorldEdgeTriggerHurt )
		{
			if ( IsAlive( player ) )
				thread UseFlightPanelEnd( player, node )

			target.Destroy()
			thread UpdatePosWithLocalSpace( file.airBattleNode )
			WorldEdgeTriggerHurt.Enable()
		}
	)

	float hackDelay 	= 2.8  // delay until data knife hack elements start hacking
	float hackDuration 	= 3.5  // time until data knife hack elements finish hacking
	thread FlightPanel_DataKnifeLeech_Think( player, hackDelay, hackDuration )

	panel.Anim_Play( "s2s_bridge_console_start" )
	string anim3rd = "pt_s2s_bridge_console_start"
	string animPOV = "ptpov_s2s_bridge_console_start"
	waitthread PlayFPSAnimShowProxy( player, anim3rd, animPOV, node, "", ViewConeTight, blendTime )

	panel.Anim_Play( "s2s_bridge_console_idle" )
	anim3rd = "pt_s2s_bridge_console_idle"
	animPOV = "ptpov_s2s_bridge_console_idle"// "pt_pov_joystick_idle"
	thread PlayFPSAnimShowProxy( player, anim3rd, animPOV, node, "", ViewConeFlightPanel, 0 )

	//turn off the guns, do VO
	ResetBankTime( file.malta )
	thread FlightControlOutputFuncWrapper( player, FlightControlOutputFunc, target )
	thread FlightControl_OutlineOLA()
	thread FlightControlVO()


	int pitchID 	= fpsProxy.LookupPoseParameterIndex( "aim_pitch" )
	int rollID 		= fpsProxy.LookupPoseParameterIndex( "aim_yaw" )
	int pitchPan 	= panel.LookupPoseParameterIndex( "aim_pitch" )
	int rollPan		= panel.LookupPoseParameterIndex( "aim_yaw" )

	float time = 0.2

	float stickThreshold = 20
	float lastSndTime 	= Time()
	float oldRollFrac 	= 0
	float oldPitchFrac 	= 0
	while( 1 )
	{
		float pitch = player.GetInputAxisForward() * -1.0//GetBinaryInput( player.GetInputAxisForward() * -1.0 )
		float roll = player.GetInputAxisRight()//GetBinaryInput( player.GetInputAxisRight() )

		float pitchFrac = GraphCapped( pitch, -1.0, 1.0, -45, 45 )
		fpsProxy.SetPoseParameterOverTime( pitchID, pitchFrac, time )
		panel.SetPoseParameterOverTime( pitchPan, pitchFrac, time )

		float rollFrac = GraphCapped( roll, -1.0, 1.0, -60, 60 )
		fpsProxy.SetPoseParameterOverTime( rollID, rollFrac, time )
		panel.SetPoseParameterOverTime( rollPan, rollFrac, time )

		bool stickThresholdMet = ( fabs( rollFrac - oldRollFrac ) > stickThreshold || fabs( pitchFrac - oldPitchFrac ) > stickThreshold )
		bool timeThresholdMet = ( Time() -  lastSndTime ) > 0.3

		if( stickThresholdMet && timeThresholdMet )
		{
			oldRollFrac 	= rollFrac
			oldPitchFrac 	= pitchFrac
			lastSndTime 	= Time()
			EmitSoundOnEntity( file.player, "s2s_bridge_stick_navigation_control" )
		}

		WaitFrame()
	}
}

void function FlightPanelMusic()
{
	StopMusic()
	PlayMusic( "music_s2s_12_steering" )
}

void function FlightPanel_DataKnifeLeech_Think( entity player, float delay, float hackDuration )
{
	EndSignal( player, "OnDestroy" )

	if ( delay > 0 )
		wait delay

	Remote_CallFunction_Replay( player, "ServerCallback_DataKnifeStartLeech", hackDuration )

	wait hackDuration

	thread DataKnifeSuccessSounds( player )
}

entity function FlightPanelSetupConsole()
{
	entity panel = GetEntByScriptName( "maltaBridgeControl" )
	vector offset = <0,0,0>
	vector angles = panel.GetAngles()
	offset = file.malta.mover.GetForwardVector() * -16
	angles = AnglesCompose( panel.GetAngles(), <0,-90,0> )

	entity anchor = CreateScriptMover( panel.GetOrigin() + offset, angles )
	anchor.SetParent( file.malta.mover, "", true, 0 )
	panel.SetParent( anchor, "REF", false, 0 )
	panel.Anim_Play( "s2s_bridge_console_start_idle" )

	file.objBridgePanel.SetParent( anchor, "REF", false, 0 )
	file.objBridgePanel.Anim_Play( "s2s_bridge_console_start_idle" )

	return panel
}

void function FlightControl_OutlineOLA()
{
	ShipGeoHide( file.OLA, "DRACONIS_CHUNK_LOWDEF" )
	int solidType = 6
	entity highLightModel = CreatePropDynamic( OLA_FLYING_MODEL, file.OLA.model.GetOrigin(), file.OLA.model.GetAngles(), solidType )
	highLightModel.SetScriptName( "DRACONIS_HIGHLIGHT_MODEL" )
	highLightModel.SetParent( file.OLA.model, "", true, 0 )
	Highlight_SetNeutralHighlight( highLightModel, "sp_s2s_OLA_outline" )

	OnThreadEnd(
	function() : ( highLightModel )
		{
			ShipGeoShow( file.OLA, "DRACONIS_CHUNK_LOWDEF" )
			highLightModel.Destroy()
		}
	)

	FlagWait( "MaltaOnCourse" )
}

void function FlightControlOutputFuncWrapper( entity player, void functionref(entity,entity) FlightControlOutputFunc, entity target )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "EndFlightControlOutputFunc" )
	waitthread FlightControlOutputFunc( player, target )
}

void function ViewConeFlightPanel( entity player )
{
	player.PlayerCone_SetLerpTime( 0.5 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -55 )
	player.PlayerCone_SetMaxYaw( 55 )
	player.PlayerCone_SetMinPitch( -60 )
	player.PlayerCone_SetMaxPitch( 20 )
}

void function UseFlightPanelEnd( entity player, entity node )
{
	OnThreadEnd(
	function() : ()
		{
			FlagSet( "PanelAnimEnded" )
		}
	)

	player.EndSignal( "OnDeath" )
	player.Signal( "EndFlightControlOutputFunc" )

	player.ForceStand()
	entity panel = node

	panel.Anim_Play( "s2s_bridge_console_end" )
	string anim3rd = "pt_s2s_bridge_console_end"
	string animPOV = "ptpov_s2s_bridge_console_end"

	thread FlightControlEndVO()
	waitthread PlayFPSAnimShowProxy( player, anim3rd, animPOV, node, "", ViewConeTight, 0 )

	player.ClearParent()
	player.UnforceStand()
	player.Anim_Stop()
	player.Signal( "ScriptAnimStop" )
	player.Signal( "FlightPanelAnimEnd" )
	ClearPlayerAnimViewEntity( player, 0.2 )
	player.DeployWeapon()
}

void function FlightControlEndVO()
{
	//"That's it, you did it. Now full throttle."
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS369_01_01_mcor_bear", file.bear )
}

void function FlightControlVO()
{
	FlagEnd( "MaltaOnCourse" )
	wait 0.5
	//"Commander Briggs, the Malta is ours."
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS339_01_01_mcor_bear", file.bear )

	//Well done 6-4!  Cooper, you still have control of the bridge. Use your data knife to steer yourself right behind the Draconis.
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS342_02_01_mcor_sarah", file.player )

	Objective_Set( "#S2S_OBJECTIVE_STEERSHIP", <0,0,0>, GetEntByScriptName( "DRACONIS_HIGHLIGHT_MODEL" ) )
	entity objModel = CreatePropScript( OLA_FLYING_MODEL, file.OLA.model.GetOrigin(), file.OLA.model.GetAngles(), 0, 99999 )
	objModel.SetParent( file.OLA.model, "", true, 0 )
	objModel.Hide()
	Objective_InitEntity( objModel )
	Objective_StaticModelHighlightOverrideEntity( objModel )

	OnThreadEnd(
	function() : ( objModel )
		{
			objModel.Destroy()
		}
	)

	//"Barker, Get BT back to Cooper
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS342_03_01_mcor_sarah", file.player )

	//"You got it, on my way. (to BT) Hold on, tin man!"
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS343_01_01_mcor_barker", file.player )

	FlagSet( "BarkerBringsBtToReunite" )

	//"All call signs, clean up bogies and rendezvous at the Draconis. This is it!"
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS344_01_01_mcor_sarah", file.player )
	wait 0.5

	table<string,array<FCVO> > fcvoLines = FlightControlVO_InitLines()
	table<string,int> fcvoIndex
	fcvoIndex[ "OnCourse" ] 	<- 0
	fcvoIndex[ "SteerRight" ] 	<- 0
	fcvoIndex[ "SteerLeft" ] 	<- 0
	fcvoIndex[ "PushDown" ] 	<- 0
	fcvoIndex[ "PullUp" ] 		<- 0

	float startTime = Time()
	while( 1 )
	{
		string option = FlightControlVO_GetOption()
		Assert( option in fcvoLines )

		int index = fcvoIndex[ option ]
		fcvoIndex[ option ]++
		if ( fcvoIndex[ option ] >= fcvoLines[ option ].len() )
			fcvoIndex[ option ] = 0

		FCVO line = fcvoLines[ option ][ index ]
		waitthreadsolo PlayDialogue( line.line, line.speaker )

		if ( Time() - startTime > 25 )
			break

		wait 5
	}

	//6-4...just shut up and let him do the driving!
	waitthreadsolo PlayDialogue( "diag_sp_maltaBridge_STS370_11_01_mcor_bear", file.bear )
}

string function FlightControlVO_GetOption()
{
	LocalVec destination = GetMaltaOnCourseDestination()
	entity maltaRef = file.malta.mover

	float thresholdF = AngleToDot( 30 )

	//determine if we are headed in the right direction
	vector maltaOrigin 	= GetOriginLocal( maltaRef ).v
	vector trajectory 	= Normalize( GetVelocityLocal( maltaRef ).v )
	vector goalDir 		= Normalize( destination.v - maltaOrigin )

	if ( DotProduct( trajectory, goalDir ) > thresholdF )
	{
		//we're on course!
		return "OnCourse"
	}

	//find out what quadrant we're in
	vector g2m 		= goalDir * -1.0
	vector up 		= <0,0,1>
	vector right 	= <1,0,0>
	float quadU 	= DotProduct( g2m, up )
	float quadR 	= DotProduct( g2m, right )

	float trajectoryU 	= DotProduct( trajectory, up )
	float trajectoryR 	= DotProduct( trajectory, right )
	float trajectoryD 	= trajectoryU * -1.0
	float trajectoryL 	= trajectoryR * -1.0

	//lower half
	if ( quadU < 0 )
	{
		//lower left
		if ( quadR < 0 )
		{
			//we're going more up than right
			if ( trajectoryU >= trajectoryR )
				return "SteerRight"
		}
		//lower right
		else
		{	//we're going more up than left
			if ( trajectoryU >= trajectoryL )
				return "SteerLeft"
		}

		return "PullUp"
	}
	//upper half
	else
	{
		//upper left
		if ( quadR < 0 )
		{
			//we're going more down than right
			if ( trajectoryD >= trajectoryR )
				return "SteerRight"
		}
		//upper right
		else
		{
			//we're going more down than left
			if ( trajectoryD >= trajectoryL )
				return "SteerLeft"
		}

		return "PushDown"
	}

	Assert( 0, "should not have gotten here" )
	unreachable
}

table<string,array<FCVO> > function FlightControlVO_InitLines()
{
	table<string,array<FCVO> > fcvoLines

	fcvoLines[ "OnCourse" ] 	<- FlightControlVO_CreateOnCourse()
	fcvoLines[ "SteerRight" ] 	<- FlightControlVO_CreateSteerRight()
	fcvoLines[ "SteerLeft" ] 	<- FlightControlVO_CreateSteerLeft()
	fcvoLines[ "PushDown" ] 	<- FlightControlVO_CreatePushDown()
	fcvoLines[ "PullUp" ] 		<- FlightControlVO_CreatePullUp()

	return fcvoLines
}

array<FCVO> function FlightControlVO_CreateOnCourse()
{
	array<FCVO> long = FlightControlVO_CreateOnCourse_Long()
	array<FCVO> short = FlightControlVO_CreateOnCourse_Short()
	return FlightControlVO_CombineLongShort( long, short )
}

array<FCVO> function FlightControlVO_CreateSteerRight()
{
	array<FCVO> long = FlightControlVO_CreateSteerRight_Long()
	array<FCVO> short = FlightControlVO_CreateSteerRight_Short()
	return FlightControlVO_CombineLongShort( long, short )
}

array<FCVO> function FlightControlVO_CreateSteerLeft()
{
	array<FCVO> long = FlightControlVO_CreateSteerLeft_Long()
	array<FCVO> short = FlightControlVO_CreateSteerLeft_Short()
	return FlightControlVO_CombineLongShort( long, short )
}

array<FCVO> function FlightControlVO_CreateOnCourse_Long()
{
	array<FCVO> voLines

	//"That's it, Coop, just like that. Just line her up with the Draconis"
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS345_01_01_mcor_droz", file.droz ) )
	//"There you go, stay that course, you've almost got them lined up"
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS346_01_01_mcor_davis", file.davis ) )
	//"That the correct heading, just keep the stick there."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS347_01_01_mcor_gates", file.gates ) )

	voLines.randomize()
	return voLines
}

array<FCVO> function FlightControlVO_CreateOnCourse_Short()
{
	array<FCVO> voLines

	//"That's it, just like that."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS348_01_01_mcor_droz", file.droz ) )
	//"You're on the right course."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS349_01_01_mcor_davis", file.davis ) )
	//"Stay at that heading."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS350_01_01_mcor_gates", file.gates ) )

	voLines.randomize()
	return voLines
}

array<FCVO> function FlightControlVO_CreateSteerRight_Long()
{
	array<FCVO> voLines

	//"You're too far off, Coop.  Steer it more to the right"
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS351_01_01_mcor_droz", file.droz ) )
	//"You're heading away from her. Try to line them up. Pull the stick to the right."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS352_01_01_mcor_davis", file.davis ) )
	//"You're off course, Cooper.  Pull right. More to the right."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS353_01_01_mcor_gates", file.gates ) )

	voLines.randomize()
	return voLines
}

array<FCVO> function FlightControlVO_CreateSteerRight_Short()
{
	array<FCVO> voLines

	//"No, no. More right."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS354_01_01_mcor_droz", file.droz ) )
	//"No. Go right, go right."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS355_01_01_mcor_davis", file.davis ) )
	//"Stop, go to the right."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS356_01_01_mcor_gates", file.gates ) )

	voLines.randomize()
	return voLines
}

array<FCVO> function FlightControlVO_CreateSteerLeft_Long()
{
	array<FCVO> voLines

	//"Coop you're going the wrong way. Pull it to the left."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS357_01_01_mcor_droz", file.droz ) )
	//"That's not the correct heading, Coop. Steer left."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS358_01_01_mcor_davis", file.davis ) )
	//"You're pulling away from the Draconis. Go left."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS359_01_01_mcor_gates", file.gates ) )

	voLines.randomize()
	return voLines
}

array<FCVO> function FlightControlVO_CreateSteerLeft_Short()
{
	array<FCVO> voLines

	//"That's wrong, head left"
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS360_01_01_mcor_droz", file.droz ) )
	//"No, no. Steer left.  Left."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS361_01_01_mcor_davis", file.davis ) )
	//"Wrong way. Go left."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS362_01_01_mcor_gates", file.gates ) )

	voLines.randomize()
	return voLines
}

array<FCVO> function FlightControlVO_CreatePushDown()
{
	array<FCVO> voLines

	//"You're up too high, push the stick forward.."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS365_01_01_mcor_gates", file.gates ) )

	//"Too high, Coop.  Go down lower"
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS363_01_01_mcor_droz", file.droz ) )
	//"Pitch it down, Coop. You're too high."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS364_01_01_mcor_davis", file.davis ) )

	return voLines
}

array<FCVO> function FlightControlVO_CreatePullUp()
{
	array<FCVO> voLines

	//"That's too low. Pull back on the stick."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS367_01_01_mcor_davis", file.davis ) )

	//"Too low, Coop.  Pull up"
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS366_01_01_mcor_droz", file.droz ) )
	//"Cooper, You're too low, pull up."
	voLines.append( FlightControl_CreateVOLine( "diag_sp_maltaBridge_STS368_01_01_mcor_gates", file.gates ) )

	return voLines
}

array<FCVO> function FlightControlVO_CombineLongShort( array<FCVO> long, array<FCVO> short )
{
	array<FCVO> voLines
	voLines.append( long[ 0 ] )

	long.remove( 0 )
	long.extend( short )
	long.randomize()
	voLines.extend( long )

	return voLines
}

FCVO function FlightControl_CreateVOLine( string line, entity speaker )
{
	FCVO voLine
	voLine.line = line
	voLine.speaker = speaker
	return voLine
}

/************************************************************************************************\

██████╗ ███████╗ ██████╗██╗  ██╗     ██████╗ ██╗   ██╗███╗   ██╗    ████████╗███████╗ ██████╗██╗  ██╗
██╔══██╗██╔════╝██╔════╝██║ ██╔╝    ██╔════╝ ██║   ██║████╗  ██║    ╚══██╔══╝██╔════╝██╔════╝██║  ██║
██║  ██║█████╗  ██║     █████╔╝     ██║  ███╗██║   ██║██╔██╗ ██║       ██║   █████╗  ██║     ███████║
██║  ██║██╔══╝  ██║     ██╔═██╗     ██║   ██║██║   ██║██║╚██╗██║       ██║   ██╔══╝  ██║     ██╔══██║
██████╔╝███████╗╚██████╗██║  ██╗    ╚██████╔╝╚██████╔╝██║ ╚████║       ██║   ███████╗╚██████╗██║  ██║
╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝       ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝

\************************************************************************************************/
void function MaltaDeck_SpawnDeckGuns()
{
	array<entity> guns = SpawnOnShipFromScriptName( "maltadeck_guns", file.malta )
	guns = ArrayFarthest( guns, file.malta.mover.GetOrigin() )
	foreach ( index, gun in guns )
	{
		Assert( IsAlive( gun ) )
		thread MaltaDeck_GunsThink( gun )

		switch( index )
		{
			case 3:
				thread MaltaDeck_GunsSoundThink( gun, "scr_s2s_bridge_gun_loop_far_04", "scr_s2s_bridge_gun_stop_04" )
				break

			case 4:
				thread MaltaDeck_GunsSoundThink( gun, "scr_s2s_bridge_gun_loop_far_05", "scr_s2s_bridge_gun_stop_05" )
				break

			case 5:
				thread MaltaDeck_GunsSoundThink( gun, "scr_s2s_bridge_gun_loop_far_06", "scr_s2s_bridge_gun_stop_06" )
				break

			default:
				//do nothing
				break

		}
	}
	WaitFrame()
	FlagWait( "BridgeBreached" )

	guns = ArrayClosest( guns, file.malta.mover.GetOrigin() )
	foreach ( index, gun in guns )
	{
		switch( index )
		{
			case 0:
				thread MaltaDeck_GunsSoundThink( gun, "scr_s2s_bridge_gun_loop_Close_02", "scr_s2s_bridge_gun_stop_02" )
				break

			case 1:
				thread MaltaDeck_GunsSoundThink( gun, "scr_s2s_bridge_gun_loop_Close_03", "scr_s2s_bridge_gun_stop_03" )
				break

			case 2:
				thread MaltaDeck_GunsSoundThink( gun, "scr_s2s_bridge_gun_loop", "scr_s2s_bridge_gun_stop" )
				break

			default:
				//do nothing
				break
		}
	}
}

void function MaltaDeck_GunsSoundThink( entity gun, string snd, string stopSnd )
{
	gun.EndSignal( "OnDestroy" )
	gun.Signal( "MaltaDeck_GunsSoundThink" )
	gun.EndSignal( "MaltaDeck_GunsSoundThink" )

	OnThreadEnd(
	function() : ( gun, snd, stopSnd )
		{
			if ( IsValid( gun ) )
			{
				StopSoundOnEntity( gun, snd )
				EmitSoundOnEntity( gun, stopSnd )
			}
		}
	)

	bool firing = false
	while( 1 )
	{
		table result = WaitSignal( gun, "shoot", "stop" )
		if ( result.signal == "shoot" )
		{
			if ( !firing )
			{
				EmitSoundOnEntity( gun, snd )
				firing = true
			}

			thread __DeckGunStopLoopSignal( gun )
		}
		else
		{
			StopSoundOnEntity( gun, snd )
			EmitSoundOnEntity( gun, stopSnd )
			firing = false
		}
	}
}

void function __DeckGunStopLoopSignal( entity gun )
{
	gun.EndSignal( "shoot" )
	wait 0.2
	gun.Signal( "stop" )
}

void function MaltaDeck_GunsThink( entity gun )
{
	gun.Hide()
	gun.DisableHibernation()
	gun.SetHealth( gun.GetMaxHealth() )
	gun.SetInvulnerable()
	gun.NotSolid()

	if ( !Flag( "BridgeBreached" ) )
		gun.SetActiveWeaponByName( "mp_weapon_mega_turret_s2s" )

	gun.EnableNPCFlag( NPC_DISABLE_SENSING ) //NPC_DISABLE
	gun.SetEfficientMode( true )

	entity maltaRef = file.malta.mover
	float height = 175
	if ( MaltaDeck_GunIsLeft( gun ) )
		height = 300

	entity downpos = CreateScriptMover( gun.GetOrigin(), gun.GetAngles() )
	downpos.SetParent( maltaRef, "", true, 0 )

	gun.SetTitle( "" )
	TurretChangeTeam( gun, TEAM_IMC )
	gun.ClearBossPlayer()

	OnThreadEnd(
	function() : ( gun, downpos )
		{
			if ( !Flag( "BridgeSkipped" ) )
				return

			Assert( IsValid( downpos ) )
			gun.SetParent( downpos, "", false, 0 )
			gun.MarkAsNonMovingAttachment()
			gun.DisableTurret()
			TurretChangeTeam( gun, TEAM_UNASSIGNED )
			gun.Show()

			delaythread( 2.0 ) MaltaDeck_ReplaceGun( gun )
		}
	)

	if ( Flag( "BridgeSkipped" ) )
		return
	FlagEnd( "BridgeSkipped" )

	entity upPos = CreateScriptMover( gun.GetOrigin() + ( gun.GetUpVector() * height ), gun.GetAngles() )
	upPos.NotSolid()
	upPos.SetParent( maltaRef, "", true, 0 )
	gun.SetParent( upPos, "", false, 0 )
	gun.MarkAsNonMovingAttachment()

	wait 0.1

	gun.EnableTurret()

	entity target = CreateScriptMover()
	Assert( IsAlive( target ) )
	Assert( IsAlive( gun ) )
	thread MaltaDeck_GunUpdateEnemyPos( gun, target )

	FlagWait( "BridgeBreached" )
	gun.Show()
	gun.SetActiveWeaponByName( "mp_weapon_mega_turret_s2s" )
	EmitSoundOnEntity( gun, "scr_s2s_bridge_gun_loop" )

	FlagWait( "DeckGunsTurnedOff" )

	float delay = 1.5
	float interval = 0.5

	if ( gun.kv.script_noteworthy == "bridge1" && MaltaDeck_GunIsLeft( gun ) )
		EmitSoundOnEntityAfterDelay( file.player, "scr_bridge_gun_shutdown", delay + interval )

	switch( gun.kv.script_noteworthy )
	{
		case "bridge4":
			delay += interval
		case "bridge3":
			delay += interval
		case "bridge2":
			delay += interval
		case "bridge1":
			delay += interval
	}

	wait delay

	gun.Signal( "deckGunOff" )

	float time = 3.75 + RandomFloat( 0.5 )

	gun.DisableTurret()
	TurretChangeTeam( gun, TEAM_UNASSIGNED )
	upPos.NonPhysicsSetMoveModeLocal( true )
	upPos.NonPhysicsMoveTo( downpos.GetLocalOrigin(), time, 0.2, time * 0.2 )
	downpos.Destroy()
	target.Destroy()

	wait time
	MaltaDeck_ReplaceGun( gun )

}

void function MaltaDeck_ReplaceGun( entity gun )
{
	if ( !IsValid( gun ) )
		return

	entity dummy = CreatePropDynamic( gun.GetModelName(), gun.GetOrigin(), gun.GetAngles(), 6 )
	dummy.SetParent( file.malta.mover, "", true, 0 )
	gun.GetParent().Destroy()
}

void function MaltaDeck_GunUpdateEnemyPos( entity gun, entity target )
{
	Assert( IsAlive( target ) )
	Assert( IsAlive( gun ) )
	gun.EndSignal( "OnDestroy" )
	gun.EndSignal( "deckGunOff" )
	target.EndSignal( "OnDestroy" )

	SetTeam( target, TEAM_MILITIA )
	gun.LockEnemy( target )

	bool isLeft = MaltaDeck_GunIsLeft( gun )

	while( 1 )
	{
		int loops = RandomIntRange( 20, 30 )

		array<float> pitch
		array<float> yaw

		if ( isLeft )
		{
			pitch.append( RandomFloatRange( -5, 0 ) - 20 )
			pitch.append( RandomFloatRange( 0, 5 ) - 20 )
			yaw.append( RandomFloatRange( -10, 0 ) - 10 )
			yaw.append( RandomFloatRange( 0, 10 ) + 10 )
		}
		else
		{
			pitch.append( RandomFloatRange( 0, 10 ) + 0 )
			pitch.append( RandomFloatRange( -30, 0 ) + 0 )
			yaw.append( RandomFloatRange( -10, 0 ) - 5 )
			yaw.append( RandomFloatRange( 0, 10 ) + 5 )
		}

		pitch.randomize()
		yaw.randomize()

		//strange that I have to do this... ask jiesang
		for ( int i = 0; i < loops; i++ )
		{
			float frac2 = i.tofloat() / ( loops.tofloat() - 1.0 )
			float frac1 = 1.0 - frac2

			float x = ( pitch[0] * frac1 ) + ( pitch[1] * frac2 )
			float y = ( yaw[0] * frac1 ) + ( yaw[1] * frac2 )

			vector angles = <x,y,0>
			vector dir = AnglesToForward( angles )
			target.SetOrigin( gun.GetOrigin() + ( dir * 1000 ) )

			gun.SetEnemyLKP( target, target.GetOrigin() )
			//DebugDrawText( gun.GetOrigin() + < 0,0,200 >, "angles: " + angles, true, FRAME_INTERVAL )
			//DebugDrawLine( gun.GetOrigin() + < 0,0,200 >, target.GetOrigin(), 255, 200, 0, true, FRAME_INTERVAL )
			WaitFrame()
		}
	}
}

bool function MaltaDeck_GunIsLeft( entity gun )
{
	vector vec1 = Normalize( gun.GetOrigin() - file.malta.model.GetOrigin() )
	vector right = file.malta.model.GetRightVector()

	return ( DotProduct( vec1, right ) < 0.0 )
}

/************************************************************************************************\

██████╗ ███████╗██╗   ██╗███╗   ██╗██╗████████╗███████╗    ██╗    ██╗██╗████████╗██╗  ██╗    ██████╗ ████████╗
██╔══██╗██╔════╝██║   ██║████╗  ██║██║╚══██╔══╝██╔════╝    ██║    ██║██║╚══██╔══╝██║  ██║    ██╔══██╗╚══██╔══╝
██████╔╝█████╗  ██║   ██║██╔██╗ ██║██║   ██║   █████╗      ██║ █╗ ██║██║   ██║   ███████║    ██████╔╝   ██║
██╔══██╗██╔══╝  ██║   ██║██║╚██╗██║██║   ██║   ██╔══╝      ██║███╗██║██║   ██║   ██╔══██║    ██╔══██╗   ██║
██║  ██║███████╗╚██████╔╝██║ ╚████║██║   ██║   ███████╗    ╚███╔███╔╝██║   ██║   ██║  ██║    ██████╔╝   ██║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝   ╚══════╝     ╚══╝╚══╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝    ╚═════╝    ╚═╝

\************************************************************************************************/
void function Reunited_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-39500,0> )
	SetupShips_MaltaReunite()

	thread CreateAirBattle()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	BT_BarkerShipRueniteIdle( bt )

	EnableScript( file.malta, "scr_malta_node_4" )
	MaltaDeck_FlapsInit()
	EnableScript( file.malta, "scr_malta_node_5" )
	MaltaReunite_SetupCrew()

	StopMusic()
	PlayMusic( "music_s2s_12_steering" )
	Reunited_AnimSetup( player )
	entity node = GetEntByScriptName( "maltaBridgeControl" )
	float delay = 2.0
	delaythread( delay ) FlagSet( "MaltaOnCourse" )
	delaythread( delay ) UseFlightPanelEnd( player, node )
}

void function Reunited_AnimSetup( entity player )
{
	entity panel = FlightPanelSetupConsole()
	entity node = panel
	entity fpsProxy = player.GetFirstPersonProxy()
	panel.Anim_Play( "s2s_bridge_console_idle" )
	string anim3rd = "pt_s2s_bridge_console_idle"
	string animPOV = "ptpov_s2s_bridge_console_idle"// "pt_pov_joystick_idle"
	player.SetParent( node, "", false, 0 )
	player.DisableWeapon()
	thread PlayFPSAnimShowProxy( player, anim3rd, animPOV, node, "", ViewConeTight )
	delaythread( 1.0 ) ViewConeFlightPanel( player )
}

void function MaltaReunite_SetupCrew()
{
	array<entity> crew 		= Breach_GetCrew()

	array<vector> deltas = [	< -81.7473, 4439.29, 912.036 >,
								< -183.27, 4382.74, 864.001 >,
								< 42.0382, 4474.14, 912.001 >,
								< 155.763, 4348.49, 864.003 > ]

	array<vector> angles = [ 	< 0, 71.4, 0 >,
								< 0, 114.5, 0 >,
								< 0, 119.1, 0 >,
								< 0, 91.0, 0 > ]

	foreach ( index, guy in crew )
	{
		vector origin = GetWorldPosRelativeToShip( file.malta.templateOrigin, file.malta, deltas[ index ] )
		guy.SetOrigin( origin )
		guy.SetAngles( angles[ index ] )
		wait 0.1
		guy.Anim_ScriptedPlay( "CQB_Idle_Casual" )
		guy.Anim_EnablePlanting()
	}
}

void function Reunite_Skip( entity player )
{
	Embark_Allow( player )
	entity glass = GetEntByScriptName( "bridge_glass_front" )
	glass.SetModel( BRIDGE_GLASS_CRACKED_V6 )

	MaltaBridgeBackShield()
	CleanupScript( "scr_malta_node_0" )

	ShipGeoHide( file.malta, "GEO_CHUNK_HANGAR" )
	GetEntByScriptName( "maltaBridgeWindowClip" ).Destroy()

	bool skipping = true
	DeleteBarkerShip( skipping )

	array<entity> crew = Breach_GetCrew()
	foreach ( guy in crew )
		Highlight_ClearFriendlyHighlight( guy )

	entity bt = player.GetPetTitan()
	BT_ResetLoadout( bt )

	Objective_SetSilent( "#S2S_OBJECTIVE_BOARDDRACONIS", <0,0,0>, file.OLA.model )

	NextState()

	file.respawnWidow.mover.SetOrigin( file.malta.mover.GetOrigin() + <1500,5000,1000> )
}

void function BT_ResetLoadout( entity bt )
{
	TakeAllWeapons( bt )
	SetAISettingsWrapper( bt, "npc_titan_buddy" )

	string weapon
	int bitIndex = GetTitanLoadoutIndex( "mp_titanweapon_particle_accelerator" )
	if ( IsBTLoadoutUnlocked( bitIndex ) )
		weapon = "mp_titanweapon_particle_accelerator"
	else
		weapon = "mp_titanweapon_xo16_shorty"

	TitanLoadoutDef ornull loadout = GetTitanLoadoutForPrimary( weapon )
	expect TitanLoadoutDef( loadout )
	GiveTitanLoadout( bt, loadout )
}

void function DeleteBarkerShip( bool skipping = false )
{
	if ( skipping )
	{
		file.barkership = SpawnBarkerShip()
		FakeDestroy( file.barkership )
	}
	else
	{
		WaitSignal( file.barkership, "FakeDestroy" )
	}

	entity mover = file.barkership.mover
	entity model = file.barkership.model

	model.Destroy()
	mover.Destroy()
}

void function Reunited_Main( entity player )
{
	entity bt = player.GetPetTitan()
	if ( !IsValid( bt ) )
		bt = GetPlayer0().GetPetTitan()
	
	bt.EndSignal( "OnDeath" )

	OnThreadEnd(
		function () : ()
		{
			thread RestartMapWithDelay()
		}
	)

	FlagWait( "MaltaOnCourse" )

	NextState()

	Objective_SetSilent( "#S2S_OBJECTIVE_BOARDDRACONIS", <0,0,0>, file.OLA.model )

	CheckPoint()
	wait 1 //player looks away

	// Here's your Titan, Cooper. I'm done babysitting.
	thread PlayDialogue( "diag_sp_adds_STS801_04_01_mcor_barker", file.player )

	ShipIdleAtTargetEnt_Teleport( file.barkership, file.malta.mover, MALTABRIDGE_BARKER_BOUNDS, MALTABRIDGE_BARKER_DELTA, <0,0,0> )

	thread SetBehavior( file.barkership, eBehavior.LEAVING )
	thread DeleteBarkerShip()

	FlagWait( "PanelAnimEnded" )

	delaythread( 1.5 ) ReunitedMusic()

	entity oldRef = bt.GetParent()
	if ( IsValid( oldRef ) )
		oldRef.Destroy()

	entity node = GetEntByScriptName( "BTReunionNode" )
	

	if ( IsValid( bt ) )
	{
		bt.ClearParent()
		bt.Anim_Stop()

		bt.SetParent( node )
		thread PlayAnim( bt, "bt_s2s_bridge_punch", node )
	}

	entity glass = GetEntByScriptName( "bridge_glass_front" )
	float amplitude = 7
	float frequency = 200
	float duration = 0.5
	float radius = 500

	entity maltaRef = file.malta.mover
	entity fxDummy = CreateScriptMover( glass.GetOrigin(), AnglesCompose( glass.GetAngles(), <0,180,-90> ) )
	fxDummy.SetParent( maltaRef, "", true, 0 )
	int attachID = fxDummy.LookupAttachment( "REF" )

	float shakeDelay = 0.05

	bt.WaitSignal( "crack" )
	delaythread( shakeDelay ) CreateShake( bt.GetOrigin(), amplitude, frequency, duration, radius )
	glass.SetModel( BRIDGE_GLASS_CRACKED_V2 )

	bt.WaitSignal( "crack" )
	StartParticleEffectOnEntity( fxDummy, GetParticleSystemIndex( BT_FX_GLASS_SML ), FX_PATTACH_POINT_FOLLOW, attachID )
	delaythread( shakeDelay ) CreateShake( bt.GetOrigin(), amplitude, frequency, duration, radius )
	glass.SetModel( BRIDGE_GLASS_CRACKED_V3 )

	bt.WaitSignal( "crack" )
	StartParticleEffectOnEntity( fxDummy, GetParticleSystemIndex( BT_FX_GLASS_SML ), FX_PATTACH_POINT_FOLLOW, attachID )
	delaythread( shakeDelay ) CreateShake( bt.GetOrigin(), amplitude, frequency, duration, radius )
	glass.SetModel( BRIDGE_GLASS_CRACKED_V4 )

	bt.WaitSignal( "crack" )
	StartParticleEffectOnEntity( fxDummy, GetParticleSystemIndex( BT_FX_GLASS_SML ), FX_PATTACH_POINT_FOLLOW, attachID )
	delaythread( shakeDelay ) CreateShake( bt.GetOrigin(), amplitude, frequency, duration, radius )
	glass.SetModel( BRIDGE_GLASS_CRACKED_V5 )

	bt.WaitSignal( "break" )
	StartParticleEffectOnEntity( fxDummy, GetParticleSystemIndex( BT_FX_GLASS ), FX_PATTACH_POINT_FOLLOW, attachID )
	delaythread( shakeDelay ) CreateShake( bt.GetOrigin(), amplitude, frequency, duration, radius )
	glass.SetModel( BRIDGE_GLASS_CRACKED_V6 )
	EmitSoundOnEntity( glass, "s2s_scr_bridge_windrush_broke_glass" )
	PlayBridgeWindFx()

	//"Ready to transfer control to Pilot."
	delaythread( 2.0 ) PlayBTDialogue( "diag_sp_maltaBridge_STS370_01_01_mcor_bt" )

	WaittillAnimDone( bt )
	
	bt.Anim_ScriptedPlay( "bt_s2s_bridge_punch_idle" )
	bt.Anim_EnablePlanting()
	//bt.ClearParent()

	entity panel = GetEntByScriptName( "maltaBridgeWindowClip" )//GetEntByScriptName( "bridgeUseTrigger" )
	vector origin = panel.GetOrigin()
	origin += ( file.malta.mover.GetUpVector() * 40 )
	panel.ClearParent()
	panel.SetOrigin( origin )
	panel.SetParent( file.malta.mover, "", true, 0 )
	panel.SetUsable()
	panel.SetUsableByGroup( "pilot" )
	panel.SetUsePrompts( "#HOLD_TO_EMBARK" , "#PRESS_TO_EMBARK" )

	panel.WaitSignal( "OnPlayerUse" )
	panel.UnsetUsable()

	if ( !IsAlive( player ) )
		RestartMapWithDelay()

	player.SetInvulnerable()

	//Cooper, we'll give you cover from the rear, take the deck and get to the Draconis.
	delaythread( 0.5 ) PlayDialogue( "diag_sp_maltaDeck_STS372_01_01_mcor_bear", file.bear )

	player.ContextAction_SetBusy()
	player.ForceStand()
	player.DisableWeaponWithSlowHolster()

	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.5
	//sequence.attachment = "ref"
	sequence.firstPersonAnim = "ptpov_s2s_bridge_punch_embark"
	sequence.thirdPersonAnim = "pt_s2s_bridge_punch_embark"
	sequence.viewConeFunction = ViewConeTight

	delaythread( 1.5 ) MaltaDeck_SetupCrew()
	delaythread( 1.0 ) MaltaBridgeBackShield()
	CleanupScript( "scr_malta_node_0" )

	//bt.ClearParent()
	thread PlayAnim( bt, "bt_s2s_bridge_punch_embark", node )
	bt.Anim_AdvanceCycleEveryFrame( true )
	waitthread FirstPersonSequence( sequence, player, node )

	GetEntByScriptName( "maltaBridgeWindowClip" ).Destroy()
	player.DeployWeapon()
	player.UnforceStand()
	
	ForceScriptedEmbark( bt.GetOwner(), bt )
	bt.Destroy()

	Embark_Allow( player )

	fxDummy.Destroy()
	CheckPoint()

	ShipGeoHide( file.malta, "GEO_CHUNK_HANGAR" )
	ClearDroppedWeapons()
	HideHelmet( "hangarhelmet" )
	CleanupScript( "scr_malta_node_3" )
	CleanupScript( "scr_malta_node_3b" )

	player.ClearInvulnerable()

	foreach( entity p in GetPlayerArray() )
	{
		if ( !IsValid( p.GetPetTitan() ) && !p.IsTitan() )
		{
			CreatePetTitanAtOriginWithTf( p, file.malta.mover.GetOrigin() + <0,5000,1000>, p.GetAngles() )
		}
	}
}

void function ReunitedMusic()
{
	StopMusic()
	PlayMusic( "music_s2s_13_btarrives" )
}

void function MaltaBridgeBackShield()
{
	entity shield = GetEntByScriptName( "bridgeBackShield" )
	shield.Solid()
	shield.Show()
}

void function PlayBridgeWindFx()
{
	entity fxEnt = GetEntByScriptName( "bridge_glasswindfx" )
	fxEnt.DisableHibernation()
	StartParticleEffectOnEntity( fxEnt, GetParticleSystemIndex(BRIDGE_GLASS_WIND_FX), FX_PATTACH_POINT_FOLLOW, fxEnt.LookupAttachment( "REF" ) )
}

void function BT_BarkerShipRueniteIdle( entity bt )
{
	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.SetNoTarget( true )

	BT_ResetLoadout( bt )

	entity oldRef = bt.GetParent()
	if ( oldRef )
	{
		bt.ClearParent()
		oldRef.Destroy()
	}

	entity node = GetEntByScriptName( "bt_reunite_idle_node" )
	vector origin = node.GetOrigin()// HackGetDeltaToRefOnPlane( node.GetOrigin(), node.GetAngles(), bt, "bt_s2s_post_jump_idle", file.barkership.model.GetUpVector() )
	node.Destroy()
	entity ref 	= CreateScriptMover( origin, node.GetAngles() )

	ref.SetParent( file.barkership.mover, "", true, 0 )
	bt.SetParent( ref, "", false, 0 )

	bt.Anim_ScriptedPlay( "bt_s2s_post_jump_idle" )
}

void function MaltaDeck_SetupCrew( bool setup = false )
{
	array<entity> crew 		= Breach_GetCrew()
	foreach ( guy in crew )
		guy.SetNoTarget( true )

	entity panel
	if ( setup )
		panel = FlightPanelSetupConsole()
	else
		panel = GetEntByScriptName( "maltaBridgeControl" )

	if ( file.droz.GetParent() != panel )
	{
		file.droz.SetParent( panel )
		panel.Anim_Play( "s2s_bridge_console_idle" )
		thread PlayAnimTeleport( file.droz, "pt_s2s_bridge_console_idle", panel )
		entity weapon = file.droz.GetActiveWeapon()
		weapon.Hide()
		entity knife = CreatePropDynamic( DATA_KNIFE_MODEL )
		knife.SetParent( file.droz, "PROPGUN", false, 0.0 )
	}

	entity maltaRef = file.malta.mover
	entity node = CreateScriptMover( GetWorldOriginFromRelativeDelta( < 344, 4570, 912>, maltaRef ), AnglesCompose( maltaRef.GetAngles(), <0,-90,0> ) )
	node.SetParent( maltaRef, "", true, 0 )
	file.davis.SetParent( node )
	file.davis.Anim_ScriptedPlay( "pt_control_roomB_gruntA_idle" )

	node = CreateScriptMover( GetWorldOriginFromRelativeDelta( < 110, 4420, 912>, maltaRef ), AnglesCompose( maltaRef.GetAngles(), <0,135,0> ) )
	node.SetParent( maltaRef, "", true, 0 )
	file.gates.SetParent( node )
	file.gates.Anim_ScriptedPlay( "pt_welcomeback_start_idle" )

	node = CreateScriptMover( GetWorldOriginFromRelativeDelta( < 0, 4460, 912>, maltaRef ), AnglesCompose( maltaRef.GetAngles(), <0,0,0> ) )
	node.SetParent( maltaRef, "", true, 0 )
	file.bear.SetParent( node )

	Highlight_ClearFriendlyHighlight( file.davis )
	Highlight_ClearFriendlyHighlight( file.droz )
	Highlight_ClearFriendlyHighlight( file.gates )

	if ( !Flag( "MaltaDeckClear" ) )
	{
		wait 0.2

		file.bear.Anim_ScriptedPlay( "React_salute_titan_thumbsup" )

		if ( !setup )
			file.player.WaitSignal( "pilot_Embark" )
		else
			wait 0.1
	}
	else
	{
		file.bear.Anim_ScriptedPlay( "React_salute_titan_thumbsup" )
		wait 0.1
	}

	Highlight_ClearFriendlyHighlight( file.bear )

	vector origin = HackGetDeltaToRefOnPlane( file.bear.GetOrigin(), file.bear.GetAngles(), file.bear, "CQB_Idle_Casual", file.malta.model.GetUpVector() )
	node.ClearParent()
	node.SetOrigin( origin )
	node.SetParent( maltaRef, "", true, 0 )
	file.bear.Anim_ScriptedPlay( "CQB_Idle_Casual" )

	if ( Flag( "MaltaDeckClear" ) )
		return

	FlagWait( "BossTitanViewFollow" )

	foreach ( guy in crew )
	{
		if ( guy == file.droz )
			continue

		node = guy.GetParent()
		guy.ClearParent()
		node.Destroy()
		guy.Anim_Stop()
	}

	thread AssaultMoveTarget( file.bear, GetEntByScriptName( "deck_goal_bear" ) )
	thread AssaultMoveTarget( file.gates, GetEntByScriptName( "deck_goal_gates" ) )
	thread AssaultMoveTarget( file.davis, GetEntByScriptName( "deck_goal_davis" ) )

	//put them back in relaxed positions
	FlagWait( "MaltaDeckClear" )

	thread MaltaDeck_SetupCrew()
}

/************************************************************************************************\

███╗   ███╗ █████╗ ██╗  ████████╗ █████╗     ██████╗ ███████╗ ██████╗██╗  ██╗
████╗ ████║██╔══██╗██║  ╚══██╔══╝██╔══██╗    ██╔══██╗██╔════╝██╔════╝██║ ██╔╝
██╔████╔██║███████║██║     ██║   ███████║    ██║  ██║█████╗  ██║     █████╔╝
██║╚██╔╝██║██╔══██║██║     ██║   ██╔══██║    ██║  ██║██╔══╝  ██║     ██╔═██╗
██║ ╚═╝ ██║██║  ██║███████╗██║   ██║  ██║    ██████╔╝███████╗╚██████╗██║  ██╗
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝    ╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝

\************************************************************************************************/
void function MaltaDeck_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-39500,0> )
	SetupShips_Deck()

	CreateAirBattle()

	entity bt = player.GetPetTitan()
	PilotBecomesTitan( player, bt )
	bt.Destroy()

	EnableScript( file.malta, "scr_malta_node_4" )
	MaltaDeck_FlapsInit()
	EnableScript( file.malta, "scr_malta_node_5" )
	bool setup = true
	thread MaltaDeck_SetupCrew( setup )

	delaythread( 0.2 ) PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart5" ) )

	file.respawnWidow.mover.SetOrigin( file.malta.mover.GetOrigin() + <4000,0,0> )
}

void function MaltaDeck_Skip( entity player )
{
}

void function MaltaDeck_Main( entity player )
{
	FlagInit( "DeckViperStage2" )
	FlagInit( "DeckViperDoingCore" )
	FlagInit( "DeckViperDoingRelocate" )

	thread MaltaDeck_Flaps()

	FlagWait( "DeckSpawnBoss" )

	thread MaltaDeck_SarahWidow()

	ShipStruct viperShip =  MaltaDeck_SpawnBossTitan()
	entity viper 	= viperShip.model
	entity ref 		= viper.GetParent()

	//give viper the tether trap
	viper.GiveOffhandWeapon( "mp_titanability_tether_trap", OFFHAND_SPECIAL )

	//vector bounds 	= < 50,0,20 >
	//vector offset 	= < 0,0,700 >
	//thread ShipIdleAtTargetEnt( viperShip, file.malta.mover, bounds, DECK_VIPER_DELTA, offset )

	entity node = GetEntByScriptName( "viperDeckAnimNode" )
	ref.ClearParent()
	ref.SetOrigin( node.GetOrigin() )
	ref.SetAngles( node.GetAngles() )
	ref.SetParent( file.malta.mover )
	viper.Anim_ScriptedPlay( "lt_s2s_boss_intro_idle" )
	node.Destroy()

	delaythread( 0.5 ) MaltaDeck_SpawnThermiteTitans()
	delaythread( 2.0 ) MaltaDeck_OlaGetsCloser()
	delaythread( 2.5 ) MaltaDeck_VO()

	BossTitanIntroData introData
	introData.waitForLookat = false
	introData.lookatMinDist = 12000
	introData.parentRef 	= ref
	introData.checkpointOnlyIfPlayerTitan = true

	thread BossTitanIntro( player, viper, introData )

	FlagWait( "BossTitanViewFollow" )
	StopMusic()
	PlayMusic( "music_s2s_14_titancombat" )
	wait 0.5
	Objective_SetSilent( "#S2S_OBJECTIVE_VIPERBOSS" )

//	FlagWaitClear( "BossTitanViewFollow" )

	viper.WaitSignal( "DoCore" )
	bool firstTime = true
	viper.SetEnemy( file.player )
	thread ViperCoreThink( viper, firstTime )

	WaittillAnimDone( viper )

	delaythread( 1.0 ) DeckCheckpoint()
	waitthread ViperIntroEndAnim( viper, ref )

	thread MaltaDeck_ViperBehavior_Stage1_Forward( viperShip, firstTime )
	thread MaltaDeck_GoblinAttack( [ 1,3,5,7 ] ) //left
	thread MaltaDeck_GoblinAttack( [ 0,2,4,6 ] ) //right
	thread MaltaDeck_ViperAgroOnDeckTitansDead( viper )
	FlagClear( "StopAirBattleDeaths_IMC" )

	FlagWait( "DeckViperStage2" )
	DeckCheckpoint()

	FlagWait( "ViperFakeDead" )

	//if( IsAlive( viper ) && !GetDoomedState( viper ) )
	//	viper.TakeDamage( viper.GetMaxHealth() + 1, null, null, { damageSourceId=damagedef_suicide } )
	DeckCheckpoint()

	thread SetBehavior( viperShip, eBehavior.DEATH_ANIM )
	wait 1

	array<entity> titans = GetNPCArrayByClass( "npc_titan" )
	array<entity> enemies = []
	foreach ( titan in titans )
	{
		if ( !IsAlive( titan ) )
			continue

		if ( titan.GetTeam() != TEAM_IMC )
			continue

		if ( titan == viper )
			continue

		enemies.append( titan )
	}

	Assert( enemies.len() <= 2 )
	if ( enemies.len() > 0 )
		thread FlagSetOn_AllDead( "MaltaDeckClear", enemies )
	else
		FlagSet( "MaltaDeckClear" )
}

void function DeckCheckpoint()
{
	CheckPointData checkPointData
	checkPointData.searchTime = 10.0

	if ( file.player.IsTitan() )
		CheckPoint( checkPointData )
}

void function MaltaDeck_ViperAgroOnDeckTitansDead( entity viper )
{
	viper.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( viper )
		{
			if ( IsAlive( viper ) )
			{
				viper.TakeWeapon( "mp_titanweapon_sniper" )
				viper.GiveWeapon( "mp_titanweapon_sniper", [ "BossTitanViperAgro" ] )
			}
		}
	)

	FlagEnd( "DeckViperStage2" )

	while( GetNPCArrayByScriptName( "deckThermiteTitan", TEAM_IMC ).len() < 2 )
		wait 1

	array<entity> scorches = GetNPCArrayByScriptName( "deckThermiteTitan", TEAM_IMC )
	if( scorches.len() > 0 )
		waitthread WaitUntilAllDead( scorches )
}

void function MaltaDeck_VO()
{
	FlagInit( "DeckTitanDied" )
	array<entity> titans = GetNPCArrayByClass( "npc_titan" )
	array<entity> enemies = []
	foreach ( titan in titans )
	{
		if ( !IsAlive( titan ) )
			continue

		if ( titan.GetTeam() != TEAM_IMC )
			continue

		enemies.append( titan )
	}

	Assert( enemies.len() == 3 )

	float startTime = Time()

	thread FlagSetOn_NumDead( "DeckTitanDied", enemies, 1 )
	FlagWaitAny( "DeckTitanDied", "ViperFakeDead" )
	wait 0.5

	float elapsedTime = Time() - startTime

	if ( Flag( "ViperFakeDead" ) || elapsedTime < 60 )
	{
		//"good kill", commented out because it stomps on Viper's doomed line
		// waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS264_01_01_mcor_droz", file.player )
	}
	else
	{
		//"Man those things are tough!"
		waitthreadsolo PlayDialogue( "diag_sp_maltaGuns_STS258_01_01_mcor_davis", file.player )
	}

	FlagClear( "DeckTitanDied" )
	titans = GetNPCArrayByClass( "npc_titan" )
	enemies = []
	foreach ( titan in titans )
	{
		if ( !IsAlive( titan ) )
			continue

		if ( titan.GetTeam() != TEAM_IMC )
			continue

		if ( Flag( "ViperFakeDead" ) && titan == file.viper )
			continue

		enemies.append( titan )
	}

	if ( enemies.len() < 2 )
		return

	thread FlagSetOn_NumDead( "DeckTitanDied", enemies, 1 )
	if ( !Flag( "ViperFakeDead" ) )
		FlagWaitAny( "DeckTitanDied", "ViperFakeDead" )
	else
		FlagWait( "DeckTitanDied" )

	wait 0.5

	//"Good kill! Good kill
	waitthreadsolo PlayDialogue( "diag_sp_maltaDrone_STS207_01_01_mcor_droz", file.player )
}

void function ViperIntroEndAnim( entity viper, entity ref )
{
	viper.Anim_ScriptedPlay( "lt_s2s_boss_intro_end" )
	int backID 		= viper.LookupPoseParameterIndex( "move_yaw_backward" )
	float back 		= 45
	float moveTime 	= 5.6
	float blendTime = 1.0
	float adjustTime = 0.5
	viper.SetPoseParameterOverTime( backID, back, blendTime )

	entity node = GetEntByScriptName( "DeckViperMoveTargetC" )
	vector endPos = node.GetLocalOrigin()
	ref.NonPhysicsSetMoveModeLocal( true )
	ref.NonPhysicsMoveTo( endPos, moveTime, blendTime, blendTime )

	wait moveTime - blendTime - adjustTime - 0.2
	viper.SetPoseParameterOverTime( backID, -back, adjustTime )

	wait blendTime + adjustTime
	viper.SetPoseParameterOverTime( backID, 0, adjustTime )

	WaittillAnimDone( viper )
	viper.Anim_EnablePlanting()
	viper.ClearParent()
	ref.Destroy()
}

void function MaltaDeck_GoblinAttack( array<int> teamIndices )
{
	foreach ( teamIndex in teamIndices )
	{
		ShipStruct crow = file.dropships[ TEAM_MILITIA ][ teamIndex ]
		ShipStruct goblin = file.dropships[ TEAM_IMC ][ teamIndex ]
		thread MaltaDeck_CrowStopFiringOnGoblinDeath( crow, goblin )
	}

	FlagWait( "ViperFakeDead" )

	foreach ( teamIndex in teamIndices )
	{
		ShipStruct lightweight = file.dropships[ TEAM_IMC ][ teamIndex ]

		if ( IsValid( lightweight.mover ) && IsShipOnBattleField( lightweight ) )
			thread SetBehavior( lightweight, eBehavior.LEAVING )
	}
}

void function MaltaDeck_CrowStopFiringOnGoblinDeath( ShipStruct crow, ShipStruct goblin )
{
	EndSignal( goblin, "FakeDeath" )
	EndSignal( goblin, "FakeDestroy" )
	goblin.mover.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( crow )
		{
			crow.allowShoot = false
		}
	)

	FlagWait( "ViperFakeDead" )
}

void function Behavior_MaltaDeckGoblinDeathAnim( ShipStruct ship )
{
	//need to thread off because as soon as this ship is destroyed, the function will end
	thread Behavior_MaltaDeckGoblinDeathAnimThread( ship )
}
void function Behavior_MaltaDeckGoblinDeathAnimThread( ShipStruct ship )
{
	ShipStruct lightweight = ChangeRealDropshipToLight( ship, false )
	thread SetBehavior( lightweight, eBehavior.DEATH_ANIM )
}

void function Behavior_MaltaDeckGoblinLeaveBattleField( ShipStruct ship )
{
	//need to thread off because as soon as this ship is destroyed, the function will end
	thread Behavior_MaltaDeckGoblinLeaveBattleFieldThread( ship )
}
void function Behavior_MaltaDeckGoblinLeaveBattleFieldThread( ShipStruct ship )
{
	int behavior = ship.behavior

	ShipStruct lightweight = ChangeRealDropshipToLight( ship, false )
	thread SetBehavior( lightweight, behavior )
}

void function MaltaDeck_SpawnThermiteTitans()
{
	#if DEV
		if ( GetBugReproNum() == 101 )
			return
	#endif
	EmitSoundOnEntity( file.player, "amb_scr_s2s_deck_widows_flyout" )

	entity thermiteSpawner = GetEntByScriptName( "deckThermiteTitan" )
	array<entity> nodes = GetEntArrayByScriptName( "deck_scorchLand1" )
	foreach ( node in nodes )
		thread MaltaDeck_SpawnTitanOnWidow( thermiteSpawner, node )
}

void function MaltaDeck_SpawnTitanOnWidow( entity spawner, entity node )
{
	string side = "left"
	if ( DotProduct( node.GetForwardVector(), file.malta.mover.GetForwardVector() ) > 0 )
		side = "right"


	entity maltaRef = file.malta.mover
	bool animating = true
	vector origin = GetOriginLocal( maltaRef ).v

	float x = 3750
	float y = -2000
	float z = -1500
	table<string,vector> offset = { left = < -x,y,z >, right = < x,y,z > }
	origin += offset[ side ]
	ShipStruct widow = SpawnWidowLight( CLVec( origin ), CONVOYDIR, animating )

	x = 1500
	z = 200
	offset = { left = < -x,-900,z >, right = < x,500,z > }
	vector delta = GetRelativeDelta( node.GetOrigin(), maltaRef )
	vector bounds = < 200, 0, 50 >

	thread ShipIdleAtTargetEnt( widow, maltaRef, bounds, delta, offset[ side ] )
	SetMaxAcc( widow, widow.defAccMax * 4 )
	SetMaxSpeed( widow, widow.defSpeedMax * 4 )
	delaythread( 5.0 ) ResetMaxSpeed( widow, 2.0 )
	delaythread( 6.5 ) ResetMaxAcc( widow, 1.0 )
	widow.model.SetInvulnerable()

	table<string,string> doorSide = { left = "right", right = "left" }
	thread WidowAnimateOpen( widow, doorSide[ side ] )

	widow.goalRadius = 200

	wait 0.1

	entity titan = SpawnFromSpawner( spawner )
	WaitFrame()
//	float newHealth = 7500
//	titan.SetMaxHealth( newHealth )
//	titan.SetHealth( newHealth )

	//the anim isn't setup for this... so we need to hack it's ref position
	table<string,vector> refHack = { left =  < 1230,930,-480 >, right =  < -1230,-970,-480 > }
	table<string,vector> angles = { left = AnglesCompose( widow.model.GetAngles(), <0,180,0> ), right = widow.model.GetAngles() }
	origin = GetWorldOriginFromRelativeDelta( refHack[ side ], widow.model )
	entity ref = CreateScriptMover( origin, angles[ side ] )
	ref.SetParent( widow.model, "", true, 0 )

	//animate the titan
	titan.SetParent( ref )
	thread PlayAnimTeleport( titan, "s2s_ogre_widow_jump_idle", ref, "" )

	EndSignal( widow, "FakeDeath" )
	EndSignal( titan, "OnDeath" )

	thread CheckPointOnKill( titan )

	OnThreadEnd(
	function() : ( titan, widow, node, ref, side )
		{
			thread MaltaDeck_TitanWidowDeployThink( widow, titan, node, ref, side )
		}
	)

	WaitSignal( widow, "Goal" )
}

void function CheckPointOnKill( entity guy )
{
	guy.WaitSignal( "OnDeath" )
	DeckCheckpoint()
}

void function MaltaDeck_TitanWidowDeployThink( ShipStruct widow, entity titan, entity node, entity ref, string side )
{
	FlagWaitClear( "BossTitanViewFollow" )

	if ( IsAlive( titan ) )
	{
		thread MaltaDeck_TitanJumpsFromWidowToMalta( titan, node, ref, side )
	}
	else
	{
		if ( IsValid( titan ) )
			titan.ClearParent()

		node.Destroy()
		ref.Destroy()
	}

	if ( IsShipOnBattleField( widow ) )
	{
		SetChaseEnemy( widow, file.player )
		SetFlyOffset( widow, eBehavior.LEAVING, < 1200, -600, 2000 > )
		delaythread( 2.0 ) SetBehavior( widow, eBehavior.LEAVING )
	}
}

void function MaltaDeck_TitanJumpsFromWidowToMalta( entity titan, entity node, entity ref, string side )
{
	titan.EndSignal( "OnDeath" )

	float fps = 25.0
	float jumpTime 		= 66.0 / fps
	float landTime 		= 95.0 / fps
	float travelTime 	= landTime - jumpTime

	thread PlayAnim( titan, "s2s_ogre_widow_jump", ref, "" )

	//the anim isn't setup for the titan to land on the node... so we have a hack offset to use.
	vector hack = < -178, -237, -610 >
	vector origin = GetWorldOriginFromRelativeDelta( hack, node )

	//create an anchor where the hack offset needs to be for the titan to animate to the node
	entity anchor = CreateScriptMover( origin, node.GetAngles() )
	anchor.SetParent( file.malta.model, "", true, 0 )

	OnThreadEnd(
	function() : ( node, ref, anchor )
		{
			node.Destroy()
			ref.Destroy()
			anchor.Destroy()
		}
	)

	//wait to jump
	wait jumpTime

	//the titan's ref node moves to the anchor while he's in the air, and he'll land right at the node
	ref.SetParent( anchor, "", false, travelTime )

	wait travelTime - 0.1
	titan.ClearParent()
	titan.Anim_Stop()
	float yaw = titan.GetAngles().y
	titan.SetAngles( <0,yaw,0> )//fixes bad angles
	titan.Anim_ScriptedPlay( "jump_end_MP" )
	titan.Anim_EnablePlanting()

	entity moveTarget = node.GetLinkEnt()
	thread AssaultMoveTarget( titan, moveTarget )

	AddEntityCallback_OnDamaged( titan, DeckTitanOnDamaged )
}

void function MaltaDeck_Flaps()
{
	array<entity> flapsR = GetEntArrayByScriptName( "deck_flap_right" )
	array<entity> flapsL = GetEntArrayByScriptName( "deck_flap_left" )
	foreach ( flap in flapsR )
		thread MaltaDeck_FlapsThink( file.malta, flap, 1.0 )
	foreach ( flap in flapsL )
		thread MaltaDeck_FlapsThink( file.malta, flap, -1.0 )

	FlagWait( "deck_flap_right_Go" ) //gets set when the titan hits his goalnode ( leveled )
	entity flapR = GetEntByScriptName( "deck_flap_right_wait" )
	thread MaltaDeck_FlapsThink( file.malta, flapR, 1.0 )
}

void function MaltaDeck_FlapsInit()
{
	array<entity> flaps = GetEntArrayByScriptName( "deck_flap_right" )
	flaps.extend( GetEntArrayByScriptName( "deck_flap_left" ) )
	foreach ( flap in flaps )
	{
		array<entity> links = flap.GetLinkEntArray()
		foreach ( link in links )
			link.DisableHibernation()
	}
}

void function MaltaDeck_FlapsThink( ShipStruct ship, entity flap, float sign )
{
	flap.EndSignal( "OnDestroy" )

	//flap.DisableHibernation()
	flap.NonPhysicsSetRotateModeLocal( true )
	vector anglesDown 	= flap.GetLocalAngles()
	vector anglesUp 	= AnglesCompose( anglesDown, < 40,0,0> )
	float rotTime = 2.0

	bool flapUp = false
	float threshold = 300
	float pistonHeight = 165
	array<entity> fx

	entity triggerUnder = null
	entity triggerOver = null
	array<entity> fxNodes = []
	array<entity> pistons = []
	array<entity> links = flap.GetLinkEntArray()

	foreach ( link in links )
	{

		switch ( link.GetScriptName() )
		{
			case "fx":
				fxNodes.append( link )
				break

			case "triggerUnder":
				triggerUnder = link
				break

			case "triggerOver":
				triggerOver = link
				break

			case "piston":
				pistons.append( link )
				link.NonPhysicsSetMoveModeLocal( true )
				link.SetParent( file.malta.mover, "", true, 0 )
				break

			default:
				Assert( 0 )
				break
		}
	}

	while( 1 )
	{
		vector delta = ship.goalPos.v - GetOriginLocal( ship.mover ).v
		float rollDist 	= max( delta.x * sign, 0  )
		float pitchDist = delta.z
		bool shouldRoll = rollDist > threshold
		bool shouldPitch = pitchDist > threshold

		if ( ( shouldRoll || shouldPitch ) && !Flag( "bt_tackle_fastball_started" ) )
		{
			if ( !flapUp )
			{
				wait RandomFloat( 0.5 )

				if ( !triggerOver.IsTouched() )
				{
					EmitSoundOnEntity( flap, "scr_s2s_bridge_flap_open" )
					flap.NonPhysicsRotateTo( anglesUp, rotTime, rotTime * 0.2, rotTime * 0.2 )
					foreach ( piston in pistons )
						piston.NonPhysicsMoveTo( piston.GetLocalOrigin() + ( AnglesToUp( piston.GetLocalAngles() ) * -pistonHeight ), rotTime, rotTime * 0.2, rotTime * 0.2 )

					flapUp = true
					fx = MaltaDeck_PlayFlapFx( fxNodes, rotTime * 0.25 )
				}
				else
				{
					EmitSoundOnEntity( flap, "boomtown_robotarmtrack_stop" )
					wait 1.0
				}
			}
		}
		else if ( flapUp )
		{
			wait RandomFloat( 0.5 )

			if ( !triggerUnder.IsTouched() )
			{
				EmitSoundOnEntity( flap, "scr_s2s_bridge_flap_close" )
				flap.NonPhysicsRotateTo( anglesDown, rotTime, rotTime * 0.2, rotTime * 0.2 )
				foreach ( piston in pistons )
					piston.NonPhysicsMoveTo( piston.GetLocalOrigin() + ( AnglesToUp( piston.GetLocalAngles() ) * pistonHeight ), rotTime, rotTime * 0.2, rotTime * 0.2 )
				flapUp = false
				wait rotTime * 0.75
				foreach ( ent in fx )
				{
					if ( IsValid( ent ) )
						ent.Destroy()
				}
				fx = []
			}
			else
			{
				EmitSoundOnEntity( flap, "boomtown_robotarmtrack_stop" )
				flap.NonPhysicsRotateTo( anglesDown, rotTime, 0, 0 )

				array<vector> pistonStarts
				foreach ( index, piston in pistons )
				{
					pistonStarts.append( piston.GetLocalOrigin() )
					piston.NonPhysicsMoveTo( piston.GetLocalOrigin() + ( AnglesToUp( piston.GetLocalAngles() ) * pistonHeight ), rotTime, 0, 0 )
				}

				float pumpTime = 0.2
				wait pumpTime

				flap.NonPhysicsRotateTo( anglesUp, pumpTime, 0, 0 )
				foreach ( index, piston in pistons )
					piston.NonPhysicsMoveTo( pistonStarts[ index ], pumpTime, 0, 0 )

				wait 0.7
			}
		}

		#if DEV
			if ( DEV_DRAWBANKING && GetBugReproNum() == ship.bug_reproNum )
			{
				DebugDrawLine( flap.GetOrigin(), flap.GetOrigin() + delta, 255, 200, 0, true, FRAME_INTERVAL )
				DebugDrawCircle( flap.GetOrigin() + delta, <90,0,0>, 32, 255, 200, 0, true, FRAME_INTERVAL, 6 )
				DebugDrawCircle( flap.GetOrigin(), <0,90,0>, 16, 255, 200, 0, true, FRAME_INTERVAL, 3 )
			}
		#endif
		WaitFrame()
	}
}

array<entity> function MaltaDeck_PlayFlapFx( array<entity> links, float delay )
{
	int fxID = GetParticleSystemIndex( FX_DECK_FLAP_WIND )

	array<entity> fx = []
	array<vector> angles = []
	array<entity> fxNodes = []

	foreach ( node in links )
	{
		if ( node.GetClassName() != "script_mover_lightweight" )
			continue

		fxNodes.append( node )
		angles.append( node.GetAngles() )
	}

	wait delay

	foreach ( index, node in fxNodes )
	{
		int attachID = node.LookupAttachment( "REF" )
		entity effect = StartParticleEffectOnEntityWithPos_ReturnEntity( node, fxID, FX_PATTACH_POINT_FOLLOW_NOROTATE, attachID, <0,0,0>, angles[ index ] )
		//effect.DisableHibernation()
		fx.append( effect )
	}

	return fx
}

void function MaltaDeck_OlaGetsCloser()
{
	float time = 4.0
	float mag = 3.5
	SetMaxAcc( 		file.OLA, 	file.OLA.defAccMax * mag, 	time )  //13
	SetMaxSpeed( 	file.OLA, 	file.OLA.defSpeedMax * mag, time )  //120

	float deltaY = V_MALTADECK_OLA.v.y - V_MALTABRIDGE_OLA.v.y
	float deltaZ = V_MALTADECK_OLA.v.z - V_MALTABRIDGE_OLA.v.z

	file.OLA.goalRadius = 1500
	float sign = 1.0

	int numIterations = 6
	for ( int i = 1; i <= numIterations; i++ )
	{
		float deltaX = RandomFloatRange( MALTADECK_OLA_BOUNDS.x * file.OLA.boundsMinRatio, MALTADECK_OLA_BOUNDS.x )
		deltaX *= sign

		float frac = i.tofloat() / numIterations.tofloat()
		vector delta = < deltaX * 1.5, deltaY * frac, deltaZ * frac >

		LocalVec origin
		origin.v = V_MALTABRIDGE_OLA.v + delta

		thread ShipFlyToPos( file.OLA, origin )
		WaitSignal( file.OLA, "Goal" )

		sign *= -1.0
	}

	time = 5.0
	ResetMaxSpeed( file.OLA, time )
	ResetMaxAcc( file.OLA, time )
	file.OLA.goalRadius 		= SHIPGOALRADIUS
	thread ShipIdleAtTargetPos( file.OLA, V_MALTADECK_OLA, MALTADECK_OLA_BOUNDS )
}

void function MaltaDeck_SarahWidow( bool teleport = false )
{
	ResetMaxRoll( file.sarahWidow )
	ResetMaxAcc( file.sarahWidow )
	ResetMaxSpeed( file.sarahWidow )

	if ( teleport )
		ShipIdleAtTargetEnt_M2_Teleport( file.sarahWidow, file.malta.mover, <0,0,0>, <0,0,0>, MALTADECK_WIDOW_OFFSET )
	else
		thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.malta.mover, <0,0,0>, <0,0,0>, MALTADECK_WIDOW_OFFSET )
}

/************************************************************************************************\

██╗   ██╗██╗██████╗ ███████╗██████╗          █████╗ ██╗
██║   ██║██║██╔══██╗██╔════╝██╔══██╗        ██╔══██╗██║
██║   ██║██║██████╔╝█████╗  ██████╔╝        ███████║██║
╚██╗ ██╔╝██║██╔═══╝ ██╔══╝  ██╔══██╗        ██╔══██║██║
 ╚████╔╝ ██║██║     ███████╗██║  ██║        ██║  ██║██║
  ╚═══╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝        ╚═╝  ╚═╝╚═╝

\************************************************************************************************/
void function MaltaDeck_ViperBehavior_Stage1_Forward( ShipStruct viperShip, bool firstTime = false )
{
	entity viper 	= viperShip.model

	OnThreadEnd(
	function() : ( viperShip )
		{
			if ( Flag( "DeckViperStage2" ) )
				thread MaltaDeck_ViperBehavior_Stage2( viperShip )
			else
			{
				Assert( Flag( "DeckViperRetreat" ) )
				thread MaltaDeck_ViperBehavior_Stage1_Back( viperShip )
			}
		}
	)

	entity moveTarget = null
	if ( !firstTime )
	{
		//TAKE OFF AND MOVE UP
		FlagWaitClear( "DeckViperDoingCore" )
		FlagWaitClear( "DeckViperDoingRelocate" )
		moveTarget = MaltaDeck_GetViperMoveTarget()
		waitthread MaltaDeck_ViperRelocates( viper, moveTarget )
	}

	if ( Flag( "DeckViperStage2" ) )
		return
	FlagEnd( "DeckViperStage2" )
	if ( Flag( "DeckViperRetreat" ) )
		return
	FlagEnd( "DeckViperRetreat" )

	while( 1 )
	{
		waitthread WaitToRelocate()

		if ( !MaltaDeck_ViperShouldRelocate( moveTarget ) )
			continue

		moveTarget = MaltaDeck_GetViperMoveTarget()
		waitthreadsolo MaltaDeck_ViperRelocates( viper, moveTarget )
	}
}

void function MaltaDeck_ViperBehavior_Stage1_Back( ShipStruct viperShip )
{
	entity viper 	= viperShip.model

	OnThreadEnd(
	function() : ( viperShip )
		{
			if ( Flag( "DeckViperStage2" ) )
				thread MaltaDeck_ViperBehavior_Stage2( viperShip )
			else
			{
				Assert( !Flag( "DeckViperRetreat" ) )
				thread MaltaDeck_ViperBehavior_Stage1_Forward( viperShip )
			}
		}
	)

	//TAKE OFF AND MOVE BACK
	FlagWaitClear( "DeckViperDoingCore" )
	FlagWaitClear( "DeckViperDoingRelocate" )
	entity moveTarget = MaltaDeck_GetViperMoveTarget()
	waitthread MaltaDeck_ViperRelocates( viper, moveTarget )

	if ( Flag( "DeckViperStage2" ) )
		return
	FlagEnd( "DeckViperStage2" )

	WaitToRelocate()
	FlagWaitClear( "DeckViperRetreat" )
}

void function WaitToRelocate()
{
	wait RandomFloatRange( 8, 10 )
}

void function MaltaDeck_ViperRelocates( entity viper, entity moveTarget )
{
	OnThreadEnd(
	function() : ( viper )
		{
			Assert( !Flag( "DeckViperDoingRelocate") )
			if ( IsValid( viper ) )
				Assert( viper.GetParent() == null )
		}
	)
	FlagSet( "DeckViperDoingRelocate")

	entity ref = CreateScriptMover( viper.GetOrigin(), viper.GetAngles() )
	ref.SetParent( file.malta.mover, "", true, 0 )
	viper.SetParent( ref )
	thread PlayAnim( viper, "s2s_viper_flight_move", ref )//lt_npc_jump_hover

	wait 0.5

	vector up = file.malta.mover.GetUpVector() * 4
	float blendTime = 0.5
	float moveTime = 2.9
	float holdTime = moveTime - blendTime
	ref.NonPhysicsSetMoveModeLocal( true )
	ref.NonPhysicsMoveTo( moveTarget.GetLocalOrigin() + up, moveTime, blendTime, blendTime )
	ref.NonPhysicsRotateTo( CONVOYDIR * -1, 0.2, 0.1, 0.1 )

	thread MaltaDeck_ViperSetPoseParamsAnim( viper, moveTarget.GetOrigin(), blendTime, holdTime )

	WaittillAnimDone( viper )
	viper.ClearParent()
	ViperStuckSolidFailSafe( viper )
	ref.Destroy()

	thread AssaultMoveTarget( viper, moveTarget )

	FlagClear( "DeckViperDoingRelocate")
}

void function MaltaDeck_ViperRelocatesFromMelee( entity viper, entity moveTarget, vector force )
{
	FlagSet( "DeckViperDoingRelocate" )

	viper.NotSolid()

	float mag 		= 1.563
	vector push 	= force * mag
	vector angles 	= FlattenAngles( VectorToAngles( Normalize( force *  -1.0 ) ) )

	viper.SetAngles( angles )

	string anim = "s2s_lt_fall_death"
	vector origin = HackGetDeltaToRefOnPlane( viper.GetOrigin() + push, angles, viper, anim, file.malta.model.GetUpVector() )
	entity ref = CreateScriptMover( origin, angles )
	ref.SetParent( file.malta.mover, "", true, 0 )

	float blendTime = 1.5

	viper.SetParent( ref, "REF", false, blendTime )
	thread PlayAnim( viper, anim, ref, "REF", blendTime )

	float waitTime = 0.5
	wait waitTime

	viper.Solid()
	viper.ClearParent()
	ref.ClearParent()

	anim = "s2s_viper_flight_melee_2_move"
	origin = HackGetDeltaToRefOnPlane( viper.GetOrigin(), viper.GetAngles(), viper, anim, file.malta.model.GetUpVector() )
	ref.SetOrigin( origin )
	ref.SetAngles( viper.GetAngles() )
	ref.SetParent( file.malta.mover, "", true, 0 )

	viper.SetParent( ref, "REF", false, blendTime - waitTime )
	thread PlayAnim( viper, anim, ref, "REF", blendTime - waitTime )//lt_npc_jump_hover

	vector up = file.malta.mover.GetUpVector() * 4
	blendTime = 0.5
	float moveTime = 2.9
	float holdTime = moveTime - blendTime
	ref.NonPhysicsSetMoveModeLocal( true )
	ref.NonPhysicsMoveTo( moveTarget.GetLocalOrigin() + up, moveTime, blendTime, blendTime )
	ref.NonPhysicsRotateTo( CONVOYDIR * -1, 0.2, 0.1, 0.1 )

	thread MaltaDeck_ViperSetPoseParamsAnim( viper, moveTarget.GetOrigin(), blendTime, holdTime )

	WaittillAnimDone( viper )
	viper.ClearParent()
	ViperStuckSolidFailSafe( viper )
	ref.Destroy()

	thread AssaultMoveTarget( viper, moveTarget )

	FlagClear( "DeckViperDoingRelocate")
}

void function MaltaDeck_ViperSetPoseParamsAnim( entity viper, vector end, float blendTime, float holdTime )
{
	vector start = viper.GetOrigin()
	start = < start.x, start.y, 0.0 >
	end = < end.x, end.y, 0.0 >

	vector dir 	= Normalize( end - start )
	float yaw 	= GraphCapped( dir.x, -0.5, 0.5, 45, -45 )
	float back 	= GraphCapped( dir.y, -0.8, 0.8, 45, -45 )

	int yawID 	= viper.LookupPoseParameterIndex( "move_yaw" )
	int backID 	= viper.LookupPoseParameterIndex( "move_yaw_backward" )

	float poseTime = 1.0
	float adjustTime = 0.5

	viper.SetPoseParameterOverTime( yawID, yaw, poseTime )
	viper.SetPoseParameterOverTime( backID, back, poseTime )

	wait holdTime - blendTime - adjustTime

	viper.SetPoseParameterOverTime( yawID, -yaw * 0.5, adjustTime )
	viper.SetPoseParameterOverTime( backID, -back * 0.5, adjustTime )

	wait blendTime + adjustTime

	viper.SetPoseParameterOverTime( yawID, 0, adjustTime )
	viper.SetPoseParameterOverTime( backID, 0, adjustTime )
}

const float VIPERCOREMINAIMDIST = 2500
void function ViperDoesCoreAnim( entity viper )
{
	viper.EndSignal( "FakeDeath" )
	if ( Flag( "ViperFakeDead" ) )
		return
	FlagEnd( "ViperFakeDead" )

	FlagSet( "DeckViperDoingCore" )
	viper.kv.allowshoot = false

	thread ViperAimsDuringCoreAnim( viper, Flag( "DeckViperStage2" ) )

	if ( Flag( "DeckViperStage2" ) )
	{
		entity ref = viper.GetParent()
		waitthread PlayAnim( viper, "s2s_viper_flight_move_2_core", ref )
		thread PlayAnim( viper, "s2s_viper_flight_core_idle", ref )

		wait 5.5

		waitthread PlayAnim( viper, "s2s_viper_flight_core_2_move", ref )
		viper.Signal( "StopAimingFlightCore" )
		thread PlayAnim( viper, "s2s_viper_flight_move_idle", ref )
	}
	else
	{
		entity ref = CreateScriptMover( viper.GetOrigin(), viper.GetAngles() )
		ref.SetParent( file.malta.mover, "", true, 0 )
		viper.SetParent( ref )
		thread PlayAnim( viper, "s2s_viper_flight_core", ref )//lt_npc_flight_core

		float blendTime = 0.5
		ref.NonPhysicsSetMoveModeLocal( true )
		ref.NonPhysicsMoveTo( ref.GetLocalOrigin() + <0,0,4>, blendTime, blendTime * 0.5, blendTime * 0.5 )

		wait blendTime
		thread ViperCoreAnimStaysOutFront( viper, ref )
		ref.NonPhysicsRotateTo( CONVOYDIR * -1, blendTime, blendTime * 0.5, blendTime * 0.5 )

		WaittillAnimDone( viper )
		viper.Signal( "StopAimingFlightCore" )
		viper.ClearParent()
		ViperStuckSolidFailSafe( viper )
		ref.Destroy()
	}

	viper.kv.allowshoot = true
	FlagClear( "DeckViperDoingCore" )
}

void function ViperCoreVO( entity viper )
{
	viper.EndSignal( "OnDeath" )
	file.player.EndSignal( "OnDeath" )
	viper.EndSignal( "FakeDeath" )
	if ( Flag( "ViperFakeDead" ) )
		return
	FlagEnd( "ViperFakeDead" )

	wait 2.0

	Remote_CallFunction_NonReplay( file.player, "ServerCallback_BossTitanUseCoreAbility", viper.GetEncodedEHandle(), GetTitanCurrentRegenTab( viper ) )
}

void function ViperCoreAnimStaysOutFront( entity viper, entity ref )
{
	viper.EndSignal( "StopAimingFlightCore" )
	ref.EndSignal( "OnDestroy" )
	viper.EndSignal( "FakeDeath" )
	if ( Flag( "ViperFakeDead" ) )
		return
	FlagEnd( "ViperFakeDead" )

	float yRange = 900
	float xMax = 12700
	float blendTime = 1.0

	while( 1 )
	{
		WaitFrame()

		float deltaY = ref.GetOrigin().y - ViperGetEnemy( viper ).GetOrigin().y

		if ( deltaY >= yRange )
			continue

		float moveY = deltaY
		if ( moveY < 0 )
			moveY = yRange

		vector newOrigin = ref.GetLocalOrigin() + <moveY,0,0>
		if ( newOrigin.x > xMax )
			newOrigin = <xMax, newOrigin.y, newOrigin.z>

		//getlocal origin gives a different value than 	GetRelativeDelta
		vector fixDelta = < -newOrigin.y, newOrigin.x, newOrigin.z >
		vector worldOrigin = GetWorldOriginFromRelativeDelta( fixDelta, file.malta.mover )

		vector up = file.malta.mover.GetUpVector()
		array<entity> ignore = GetNPCArrayByClass( "npc_titan" )
		ignore.append( file.player )
		TraceResults traceResult = TraceLine( worldOrigin + ( up * 100 ), worldOrigin + ( up * -1000 ), ignore, TRACE_MASK_TITANSOLID, TRACE_COLLISION_GROUP_NONE )

		if ( traceResult.fraction < 1.0 )
			worldOrigin = traceResult.endPos + ( up * 4 )

		vector relDelta = GetRelativeDelta( worldOrigin, file.malta.mover )
		vector finalLoc = < relDelta.y, -relDelta.x, relDelta.z >

		ref.NonPhysicsMoveTo( finalLoc, blendTime, 0, blendTime * 0.25 )
	}
}

void function ViperAimsDuringCoreAnim( entity viper, bool dontCheckRange )
{
	if ( Flag( "ViperFakeDead" ) )
		return
	FlagEnd( "ViperFakeDead" )

	viper.Signal( "StopAimingFlightCore" )

	int yawID 	= viper.LookupPoseParameterIndex( "aim_yaw_scripted" )
	int pitchID = viper.LookupPoseParameterIndex( "aim_pitch_scripted" )
	float blendTime = 0.5
	float dist = -999

	OnThreadEnd(
	function() : ( viper, yawID, pitchID, blendTime )
		{
			viper.SetPoseParameterOverTime( yawID, 0, blendTime )
			viper.SetPoseParameterOverTime( pitchID, 0, blendTime )
		}
	)

	while( 1 )
	{
		vector start 	= viper.GetOrigin()
		vector end 		= ViperGetEnemy( viper ).GetOrigin()

		if ( dist < VIPERCOREMINAIMDIST || dontCheckRange )
		{
			vector dir 		= Normalize( end - start )
			vector angles  	= VectorToAngles( dir )
			vector localAng = angles - <0,270,0>

			float deltaX 	= end.x - start.x
			float deltaY 	= end.y - start.y

			float yaw 	= GraphCapped( localAng.y, -90, 90, -45, 45 )
			float pitch = GraphCapped( localAng.x, -30, 30, -30, 30 )

			viper.SetPoseParameterOverTime( yawID, yaw, blendTime )
			viper.SetPoseParameterOverTime( pitchID, pitch, blendTime )
		}

		dist = Distance( start, end )

		WaitFrame()
	}
}

void function ViperStuckSolidFailSafe( entity viper )
{
	if ( !EntityInSolid( viper ) )
		return

	vector ornull clampedPos
	clampedPos = NavMesh_ClampPointForAIWithExtents( viper.GetOrigin(), viper, < 100, 100, 400 > )

	if ( clampedPos != null )
	{
		viper.SetOrigin( expect vector( clampedPos ) + ( file.malta.mover.GetUpVector() * 8 ) )
		viper.Anim_ScriptedPlay( "jump_end_MP" )
		viper.Anim_EnablePlanting()
		printt( viper + " was in solid, teleported to nearest clamp pos" )
		return
	}

	vector up = file.malta.mover.GetUpVector() * 1000
	vector down = file.malta.mover.GetUpVector() * -1000
	array<entity> ignore = GetNPCArrayByClass( "npc_titan" )
	ignore.append( file.player )
	TraceResults traceResult = TraceLine( viper.GetOrigin() + up, viper.GetOrigin() + down, ignore, TRACE_MASK_TITANSOLID, TRACE_COLLISION_GROUP_NONE )

	if ( traceResult.fraction < 1.0 )
	{
		viper.SetOrigin( traceResult.endPos + ( file.malta.mover.GetUpVector() * 8 ) )
		viper.Anim_ScriptedPlay( "jump_end_MP" )
		viper.Anim_EnablePlanting()
		printt( viper + " was in solid, teleported to nearest trace result" )
		return
	}

	//just start process over
	entity moveTarget = MaltaDeck_GetViperMoveTarget()
	waitthread MaltaDeck_ViperRelocates( viper, moveTarget )
}

void function MaltaDeck_ViperBehavior_Stage2( ShipStruct viperShip )
{
	EndSignal( viperShip, "FakeDeath" )
	entity viper 	= viperShip.model
	viper.EndSignal( "FakeDeath" )

	FlagWaitClear( "DeckViperDoingCore" )
	FlagWaitClear( "DeckViperDoingRelocate" )

	entity ref = CreateScriptMover( viper.GetOrigin(), viper.GetAngles() )
	ref.SetParent( file.malta.mover, "", true, 0 )
	viper.SetParent( ref )
	thread PlayAnim( viper, "s2s_viper_flight_start", ref )//Jump_start
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_BOT_THRUST" ) )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_BOT_THRUST" ) )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_L_TOP_THRUST" ) )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "FX_R_TOP_THRUST" ) )
	wait 0.3

	entity mover 	= viperShip.mover
	LocalVec origin = WorldToLocalOrigin( ref.GetOrigin() )
	vector angles 	= ref.GetAngles()
	SetOriginLocal( mover, origin )
	Assert( Distance( mover.GetOrigin(), ref.GetOrigin() ) < 4.0 )
	mover.SetAngles( AnglesCompose( ref.GetAngles(), <0,180,0> ) )
	ref.SetParent( mover, "", true, 0 )

	viperShip.localVelocity.v 	= <0,0,400>
	viperShip.defRollMax 		= 0
	viperShip.defPitchMax 		= 0
	ResetMaxRoll( viperShip )
	ResetMaxPitch( viperShip )

	origin.v += <0,0,300 >
	thread ShipFlyToPos( viperShip, origin )

	thread PlayAnim( viper, "s2s_viper_flight_move_idle", ref )

	viperShip.goalRadius = 200
	WaitSignal( viperShip, "Goal" )

	thread ViperStage2Strafe( viperShip )

	//pose parameters
	int yawID 	= viper.LookupPoseParameterIndex( "move_yaw" )
	int backID 	= viper.LookupPoseParameterIndex( "move_yaw_backward" )
	float blendTime = 0.5
	while( 1 )
	{
		vector start 	= GetOriginLocal( viperShip.mover ).v
		vector end 		= viperShip.goalPos.v
		float deltaX 	= end.x - start.x
		float deltaY 	= end.y - start.y

		float yaw 	= GraphCapped( deltaX, -200, 200, 45, -45 )
		float back 	= GraphCapped( deltaY, -200, 200, 45, -45 )

		viper.SetPoseParameterOverTime( yawID, yaw, blendTime )
		viper.SetPoseParameterOverTime( backID, back, blendTime )

		WaitFrame()
	}
}

void function ViperStage2Strafe( ShipStruct viperShip )
{
	EndSignal( viperShip, "FakeDeath" )
	entity viper 	= viperShip.model
	viper.EndSignal( "FakeDeath" )

	int behavior = eBehavior.ENEMY_CHASE

	DisableHullCrossing( viperShip )
	SetChaseEnemy( viperShip, ViperGetEnemy( viper ) )
	SetFlyOffset( viperShip, behavior, < 500, 0, 450 > )
	SetFlyBounds( viperShip, behavior, < 400, 300, 100 > )
	SetSeekAhead( viperShip, behavior, 1250 )

	viperShip.crossHullHeight = 500
	viperShip.crossHullBufferTime = 10
	viperShip.minChasePoint = 6500
	SetMaxSpeed( viperShip, 1500 )
	SetMaxAcc( viperShip, 600 )

	SetBehavior( viperShip, behavior )

	while( 1 )
	{
		wait 5

		float x = RandomFloatRange( 500, 1500 )
		if ( CoinFlip() )
			x *= -1

		if ( behavior == eBehavior.ENEMY_CHASE )
			behavior = eBehavior.DEPLOY
		else
			behavior = eBehavior.ENEMY_CHASE

		SetFlyOffset( viperShip, behavior, < x, RandomFloatRange( -300, 300 ), 450 > )
		SetFlyBounds( viperShip, behavior, < RandomFloatRange( 300, 600 ), RandomFloatRange( 200, 1000 ), 100 > )
		SetSeekAhead( viperShip, behavior, 1250 )

		SetBehavior( viperShip, behavior )
	}
}

void function ViperCoreThink( entity viper, bool firstTime = false )
{
	if ( Flag( "ViperFakeDead" ) )
		return
	FlagEnd( "ViperFakeDead" )
	viper.EndSignal( "FakeDeath" )

	while( 1 )
	{
		if ( Flag( "DeckViperDoingRelocate" ) )
		{
			FlagWaitClear( "DeckViperDoingRelocate" )
			wait 4
		}

		//play anim
		if ( !firstTime )
		{
			thread ViperDoesCoreAnim( viper )
			thread ViperCoreVO( viper )
		}

		//play tell warning sound and fx
		EmitSoundOnEntity( file.player, "northstar_rocket_warning" )
		float launchdelay = 3.0
		SetCoreEffect( viper, CreateCoreEffect, VIPER_CORE_EFFECT )
		thread ViperKillCoreFx( viper, launchdelay + 1.0 )
		wait launchdelay

		entity weapon 		= viper.GetOffhandWeapon( 0 )
		vector targetPos 	= ViperGetEnemy( viper ).GetOrigin()
		vector dir 			= viper.GetOrigin() - targetPos
		float dist 			= dir.Length()

		targetPos = ViperCoreGetLeadTargetPos( targetPos, dir, dist )
		WeaponViperAttackParams	viperParams = ViperSwarmRockets_SetupAttackParams( targetPos, file.malta.mover )

		EmitSoundOnEntity( file.player, "northstar_rocket_fire" )

		for( int i = 0; i < VIPERMAXVOLLEY; i++ )
		{
			viperParams.burstIndex = i
			OnWeaponScriptPrimaryAttack_ViperSwarmRockets_s2s( weapon, viperParams )

			wait 0.1

			//update pos if player is close
			targetPos 	= ViperGetEnemy( viper ).GetOrigin()
			dir 		= viper.GetOrigin() - targetPos
			dist 		= dir.Length()
			if ( dist < VIPERCOREMINAIMDIST )
			{
				targetPos = ViperCoreGetLeadTargetPos( targetPos, dir, dist )
				viperParams = ViperSwarmRockets_SetupAttackParams( targetPos, file.malta.mover )
			}
		}

		wait viper.GetSequenceDuration( "lt_npc_flight_core" )
		float lastTime = Time()

		if ( Flag( "DeckViperStage2" ) )
			wait RandomFloatRange( 8, 11 )
		else
		{
			FlagWaitWithTimeout( "DeckViperStage2", RandomFloatRange( 20, 25 ) )
			float deltaTime = Time() - lastTime
			if ( deltaTime < 10 )
				wait 10 - deltaTime
		}

		firstTime = false
	}
}

void function ViperKillCoreFx( entity viper, float delay )
{
	viper.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( viper )
			{
				if ( IsValid( viper.GetTitanSoul() ) )
					CleanupCoreEffect( viper.GetTitanSoul() )
			}
		)


	wait delay
}

vector function ViperCoreGetLeadTargetPos( vector targetPos, vector dir, float dist  )
{
	float lead = GraphCapped( dist, 1000, VIPERCOREMINAIMDIST, 0, 600 )
	vector leadTarget = targetPos + ( Normalize( < dir.x, dir.y, 0 > ) * lead )

	return leadTarget
}

bool function MaltaDeck_ViperShouldRelocate( entity moveTarget )
{
	if ( Flag( "DeckViperDoingCore" ) )
		return false

	entity newTarget = MaltaDeck_GetViperMoveTarget()
	if ( newTarget == moveTarget )
		return false

	return true
}

entity function MaltaDeck_GetViperMoveTarget()
{
	if ( Flag( "DeckViperRetreat" ) )
		return GetEntByScriptName( "DeckViperMoveTargetB" )
	else if ( Flag( "DeckRightLane" ) )
		return GetEntByScriptName( "DeckViperMoveTargetR" )
	else if ( Flag( "DeckLeftLane" ) )
		return GetEntByScriptName( "DeckViperMoveTargetL" )

	return GetEntByScriptName( "DeckViperMoveTargetC" )
}



ShipStruct function MaltaDeck_SpawnBossTitan()
{
	entity spawner 	= GetEntByScriptName( "deckBossTitan" )
	entity viper 	= SpawnFromSpawner( spawner )
	viper.SetModel( TITAN_VIPER_SCRIPTED_MODEL )
	viper.SetSkin( 1 )

	file.viper = viper

	AddEntityCallback_OnDamaged( viper, ViperOnDamaged )

	viper.TakeOffhandWeapon( 0 )
	viper.GiveOffhandWeapon( "sp_weapon_ViperBossRockets_s2s", 0, [ "DarkMissiles" ] )
	viper.TakeWeapon( "mp_titanweapon_sniper" )
	viper.GiveWeapon( "mp_titanweapon_sniper", [ "BossTitanViper" ] )

	viper.GetOffhandWeapon( 0 ).AllowUse( false ) //stop trying to use shoulder rockets on your own

	viper.SetAngles( AnglesCompose( CONVOYDIR, <0,180,0> ) )
	entity ref = CreateScriptMover( viper.GetOrigin(), viper.GetAngles() )
	entity mover = CreateScriptMover( viper.GetOrigin(), CONVOYDIR )
	viper.SetParent( ref, "", false, 0 )
	ref.SetParent( mover, "", true, 0 )
	thread PlayAnimTeleport( viper, "s2s_viper_combat_float_idle", ref )

	vector pos 		= GetWorldOriginFromRelativeDelta( DECK_VIPER_DELTA, file.malta.mover )
	LocalVec origin = WorldToLocalOrigin( pos )

	SetOriginLocal( mover, origin )

	ShipStruct viperShip
	viperShip.model = viper
	viperShip.mover = mover
	viperShip.boundsMinRatio 	= 0.5
	viperShip.defBankTime		= 0.5	//1.5
	viperShip.defAccMax 		= 300	//350
	viperShip.defSpeedMax 		= 750	//500
	viperShip.defRollMax 		= 15
	viperShip.defPitchMax 		= 3
	viperShip.FuncGetBankMagnitude = ViperBankMagnitude

	InitEmptyShip( viperShip )

	return viperShip
}

void function ViperOnDamaged( entity ent, var damageInfo )
{
	entity player = DamageInfo_GetAttacker( damageInfo )

	if ( !player.IsPlayer() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	float damage 		= DamageInfo_GetDamage( damageInfo )
	entity inflictor 	= DamageInfo_GetInflictor( damageInfo )

	if ( IsValid( inflictor ) && inflictor.GetTeam() == ent.GetTeam() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	float extraDamage = ViperGetExtraDamage( ent, damageInfo )
	float calcDamage = damage + extraDamage - ent.GetTitanSoul().GetShieldHealth()

	float frac = ( ent.GetHealth().tofloat() - calcDamage ) / ent.GetMaxHealth().tofloat()

	//make sure this entity NEVER dies
	if ( calcDamage >= ent.GetHealth() )
	{
		if ( !Flag( "ViperFakeDead" ) )
		{
			ent.Signal( "FakeDeath" )
			FlagSet( "ViperFakeDead" )
			DamageInfo_SetDamage( damageInfo, ent.GetHealth() + 1 )
			Remote_CallFunction_NonReplay( player, "ServerCallback_BossTitanDoomed", ent.GetEncodedEHandle() )
			ent.SetInvulnerable()
		}
	}
	//go into stage 2
	else if ( !Flag( "DeckViperStage2" ) && frac <= 0.6 )
	{
		FlagSet( "DeckViperStage2" )
		ent.GetTitanSoul().SetShieldHealthMax( 1200 )
		if ( ent.GetTitanSoul().GetShieldHealth() > 1200 )
			ent.GetTitanSoul().SetShieldHealth( 1200 )
	}

	thread ViperMeleeOffEdge( ent, damageInfo )

	Signal( ent, "OnDamaged" )
}

float function ViperGetExtraDamage( entity victim, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return 0
	if ( !inflictor.IsProjectile() )
		return 0
	int extraDamage = int( CalculateTitanSniperExtraDamage( inflictor, victim ) )
	float damage = DamageInfo_GetDamage( damageInfo )

	float f_extraDamage = float( extraDamage )

	bool isCritical = IsCriticalHit( DamageInfo_GetAttacker( damageInfo ), victim, DamageInfo_GetHitBox( damageInfo ), damage, DamageInfo_GetDamageType( damageInfo ) )

	if ( isCritical )
	{
		float ornull value = expect float ornull( inflictor.ProjectileGetWeaponInfoFileKeyField( "critical_hit_damage_scale" ) )
		if ( value != null )
			f_extraDamage *= expect float( value )
	}

	return f_extraDamage
}

void function ViperMeleeOffEdge( entity titan, var damageInfo )
{
	if ( Flag( "DeckViperStage2" ) || Flag( "ViperFakeDead" ) )
		return

	if ( Flag( "DeckViperDoingCore" ) || Flag( "DeckViperDoingRelocate" ) )
		return

	if ( DamageInfo_GetAttacker( damageInfo ) != file.player )
		return

	int damageSourceId 	= DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( !DamageIsTitanMelee( damageSourceId ) )
		return

	vector force = GetMeleeForce( titan )

	if ( !MeleeForceWillKnockOffEdge( titan, force ) )
		return

	entity moveTarget = MaltaDeck_GetViperMoveTarget()
	MaltaDeck_ViperRelocatesFromMelee( titan, moveTarget, force )
}

void function InitEmptyShip( ShipStruct ship )
{
	ship.free 	= false
	ship.localVelocity.v 	= <0,0,0>
	ship.goalRadius 		= SHIPGOALRADIUS

	ship.defaultBehaviorFunc 	= DefaultBehavior_Viper
	ship.defaultEventFunc 		= DefaultEventCallbacks_Viper

	ResetAllEventCallbacksToDefault( ship )
	ResetAllBehaviorsToDefault( ship )
	ResetMaxSpeed( ship )
	ResetMaxAcc( ship )
	ResetMaxRoll( ship )
	ResetMaxPitch( ship )
	ResetBankTime( ship )
	ship.behavior 		= eBehavior.IDLE
	ship.prevBehavior 	= [ eBehavior.IDLE ]

	thread RunBehaviorFiniteStateMachine( ship )
}

void function DefaultBehavior_Viper( ShipStruct ship, int behavior )
{
	switch ( behavior )
	{
		case eBehavior.ENEMY_CHASE:
			AddShipBehavior( ship, behavior, Behavior_ViperChaseEnemy )
			break

		case eBehavior.DEPLOY:
			AddShipBehavior( ship, behavior, Behavior_ViperChaseEnemy )
			break

		case eBehavior.DEATH_ANIM:
			AddShipBehavior( ship, behavior, Behavior_ViperDeathAnim )
	}
}

void function Behavior_ViperChaseEnemy( ShipStruct ship )
{
	entity enemy 	= ship.chaseEnemy
	int behavior 	= ship.behavior
	vector bounds 	= ship.flyBounds[ behavior ]
	vector offset 	= ship.flyOffset[ behavior ]
	float seekAhead = ship.seekAhead[ behavior ]
	__ShipFlyAlongEdge( ship, bounds, offset, seekAhead, eShipEvents.SHIP_ATNEWEDGE )
}

void function Behavior_ViperDeathAnim( ShipStruct ship )
{
	thread Behavior_ViperDeathAnimThread( ship )
}

void function Behavior_ViperDeathAnimThread( ShipStruct ship )
{
	Signal( ship, "FakeDeath" )
	EndSignal( ship, "FakeDestroy" )

	entity mover 	= ship.mover
	mover.EndSignal( "OnDestroy" )

	entity ref = file.viper.GetParent()
	float blendTime = 1.0

	float dec 		= -ship.accMax
	LocalVec trajectory = GetCurrentTrajectoryAtFullDeceleration( ship.mover, dec )

	//vector delta = GetRelativeDelta( file.viper.GetOrigin(), file.malta.mover )
	vector delta = GetRelativeDelta( LocalToWorldOrigin( trajectory ), file.malta.mover )
	vector pos = < 0, delta.y, 1000 >
	//LocalVec pos = CLVec( <0,0,0> )
	//vector offset = < 1500, delta.y + 700, 1300 >
	vector offset = <0,0,0>

	int attachID = ship.model.LookupAttachment( "CHESTFOCUS" )
	int fxID = GetParticleSystemIndex( BOSS_TITAN_DEATH_FX )
	int fxID2 = GetParticleSystemIndex( BOSS_TITAN_EXP_FX )
	StartParticleEffectOnEntity( ship.model, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	StartParticleEffectOnEntity( ship.model, fxID2, FX_PATTACH_POINT, attachID )

	thread __ShipFlyToPosInternal( ship, file.malta.mover, CLVec( pos ), offset, CONVOYDIR )
	ship.goalRadius = SHIPGOALRADIUS

	string deathAnim = "s2s_viper_flight_death_screen_L"
	vector vel = GetVelocityLocal( mover ).v
	if ( vel.x > 0 )
		deathAnim = "s2s_viper_flight_death_screen_R"

	//file.viper.Anim_Play( deathAnim )
	file.viper.SetEfficientMode( true )
	file.viper.EnableNPCFlag( NPC_IGNORE_ALL )
	waitthread PlayAnim( file.viper, deathAnim, ref, "", blendTime )

//	float duration = file.viper.GetSequenceDuration( deathAnim )
//	wait duration

	file.viper.Destroy()
	mover.Destroy()
}

void function DefaultEventCallbacks_Viper( ShipStruct ship, int val )
{

}

float function ViperBankMagnitude( float dist )
{
	return GraphCapped( dist, 0, 500, 0.0, 1.0 )
}

entity function ViperGetEnemy( entity viper )
{
	if ( viper.GetEnemy() )
		return viper.GetEnemy()

	entity enemy = file.player.GetPetTitan()
	if ( enemy == null )
		enemy = file.player

	return enemy
}

/************************************************************************************************\

██████╗ ████████╗    ████████╗ █████╗  ██████╗██╗  ██╗██╗     ███████╗
██╔══██╗╚══██╔══╝    ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝██║     ██╔════╝
██████╔╝   ██║          ██║   ███████║██║     █████╔╝ ██║     █████╗
██╔══██╗   ██║          ██║   ██╔══██║██║     ██╔═██╗ ██║     ██╔══╝
██████╔╝   ██║          ██║   ██║  ██║╚██████╗██║  ██╗███████╗███████╗
╚═════╝    ╚═╝          ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝

\************************************************************************************************/
void function BT_Tackle_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-46000,0> )
	SetupShips_BT_Tackle()

	CreateAirBattleEnd()

	entity bt = player.GetPetTitan()
	PilotBecomesTitan( player, bt )
	bt.Destroy()

	EnableScript( file.malta, "scr_malta_node_4" )
	MaltaDeck_FlapsInit()
	EnableScript( file.malta, "scr_malta_node_5" )
	bool setup = true
	thread MaltaDeck_SetupCrew( setup )

	FlagSet( "deck_flap_right_Go" )
	thread MaltaDeck_Flaps()

	delaythread( 0.2 ) PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart6" ) )
	delaythread( 2 ) FlagSet( "MaltaDeckClear" )
}

void function BT_Tackle_Skip( entity player )
{
	Embark_Disallow( player )
	ShipGeoHide( file.OLA, 	"DRACONIS_CHUNK_LOWDEF" )
	ShipGeoShow( file.OLA, 	"DRACONIS_CHUNK_HIGHDEF" )

	FlagSet( "Stop_MaltaStressSounds" )

	//delete the 6-4
	switch( GetCurrentStartPoint() )
	{
		case "TRAILER bridge":
			//don't destroy the dudes
			break

		default:
			array<entity> crew = Breach_GetCrew()
			foreach ( guy in crew )
				guy.Destroy()
			break
	}

	level.nv.ShipTitles = SHIPTITLES_NODRACONIS
	level.nv.ShipStreaming = SHIPSTREAMING_DRACONIS
	GetEntByScriptName( "draconisOOB" ).Disable()
}

void function BT_Tackle_Main( entity player )
{
	FlagInit( "TackleReadyToStart" )
	FlagInit( "TackleReadyForFastball" )

	FlagWait( "MaltaDeckClear" )
	Objective_SetSilent( "#S2S_OBJECTIVE_BOARDDRACONIS", <0,0,0>, file.OLA.model )
	thread BT_Tackle_DisableEmbarkWhenReady( player )
	CheckPoint()
	StopMusic()
	PlayMusic( "music_s2s_15_bossgone" )

	thread BT_Tackle_Crows()
	thread BT_Tackle_SarahWidow()

	wait 3

	GetEntByScriptName( "draconisOOB" ).Disable()

	thread BT_Tackle_ThrowVO()

	FlagWait( "TackleReadyToStart" )
	CheckPoint_Silent()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	//get where bt is in relation to the ship
	vector relDelta = GetRelativeDelta( bt.GetOrigin(), file.malta.mover )
	float relY = relDelta.y + 50
	float maxY = 12000
	float minY = 10500

	//stay within the bounds and assign a spot on the center line
	float height 	= 1000
	vector up 		= file.malta.mover.GetUpVector()
	vector angles 	= AnglesCompose( file.malta.mover.GetAngles(), <0,-10,0> )
	float newY 		= max( relY, minY )
	newY = min( newY, maxY )

	vector newDelta = < 0, newY, height >
	vector origin 	= GetWorldOriginFromRelativeDelta( newDelta, file.malta.mover )

	array<entity> ignore 	= [ bt, player ]
	TraceResults traceResult = TraceLine( origin, origin + ( up * -height ), ignore, TRACE_MASK_TITANSOLID, TRACE_COLLISION_GROUP_NONE )
	Assert( traceResult.fraction < 1.0 )

	vector hackOrigin = HackGetDeltaToRefOnPlane( traceResult.endPos, angles, bt, "bt_s2s_viper_returns_throw_setup_idle", file.malta.model.GetUpVector() )

	entity anchor = CreateScriptMover( hackOrigin, angles )
	anchor.SetParent( file.malta.mover )

	//if the player is looking at this point, then walk BT there, otherwise teleport
	float dot = DotProduct( Normalize( traceResult.endPos - player.GetOrigin() ), player.GetViewVector() )
	float theta = DotToAngle( dot )
	float dist = Distance( traceResult.endPos, bt.GetOrigin() )

	if ( dist > 600 || ( dot > 0 && theta < 90 ) )
	{
		bt.AssaultPointToAnim( hackOrigin, angles, "bt_s2s_viper_returns_throw_setup_idle", true, 32.0 )
		bt.WaitSignal( "OnFinishedAssault" )
	}
	thread PlayAnim( bt, "bt_s2s_viper_returns_throw_setup_idle", anchor )

	FlagWait( "TackleReadyForFastball" )

	waitthread PlayAnim( bt, "bt_s2s_viper_returns_throw_setup_end", anchor )
	thread PlayAnim( bt, "bt_s2s_viper_returns_fastball_idle", anchor )
	anchor.Destroy()

	thread HintConvo( "s2s_Hint_OlaThrow", "bt_tackle_fastball_started" )
	Objective_Hide( file.player )
	WaitFrame()
	Objective_Set( "#S2S_OBJECTIVE_FASTBALL2", <0,0,1> )
	Objective_SetFastball( bt )

	int attachID = bt.LookupAttachment( "FASTBALL_R" )
	vector tagOrigin = bt.GetAttachmentOrigin( attachID )
	while( Distance( player.GetOrigin(), tagOrigin ) > 120 )
	{
		WaitFrame()
		tagOrigin = bt.GetAttachmentOrigin( attachID )
	}
	FlagSet( "bt_tackle_fastball_started" )

	Objective_Hide( file.player )
	WaitFrame()
	Objective_SetSilent( "#S2S_OBJECTIVE_FASTBALL2" )
	entity marker = Objective_GetMarkerEntity()
	marker.ClearParent()

	//heck because the anim doesn't line up directly under bt
	vector pos =  bt.GetOrigin() + file.malta.model.GetForwardVector() * -130
	entity node = CreateScriptMover( pos, AnglesCompose( file.malta.mover.GetAngles(), <0,-90,0> ) )
	node.SetParent( file.malta.mover, "", true, 0 )

	entity viper = SpawnFinalViper()

	viper.DisableHibernation()
	viper.SetNoTarget( true )
	viper.EnableNPCFlag( NPC_IGNORE_ALL )
	viper.SetMaxHealth( 90000 )
	viper.SetHealth( 90000 )
	viper.Anim_AdvanceCycleEveryFrame( true )

	bt.SetNoTarget( true )
	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.SetInvulnerable()
	bt.Anim_AdvanceCycleEveryFrame( true )
	bt.NotSolid()

	float blendTime = 0.0
	bt.SetParent( 		node, "REF", false, blendTime )
	//player.SetParent( 	node, "REF", false, blendTime )
	viper.SetParent( 	node, "REF", false, blendTime )

	//delete the 6-4
	array<entity> crew = Breach_GetCrew()
	foreach ( guy in crew )
		guy.Destroy()

	FlagSet( "Stop_MaltaStressSounds" )
	file.malta.triggerFallingDeath.Destroy()

	thread BT_Tackle_VO_and_Music( bt )
	thread BT_Tackle_DamageFx( player )

	// Titan and player animate together for throw
	player.DisableWeaponWithSlowHolster()
	player.RefillAllAmmo()
	player.ForceStand()
	player.SetInvulnerable()

	Rodeo_RemoveBatteryOffPlayer( player )

	player.SetAnimNearZ( 4 )
	thread PlayAnim( bt, 	"bt_s2s_viper_returns_start", node, "REF", blendTime )
	thread PlayAnim( viper, "lt_s2s_viper_returns_start", node, "REF", blendTime )
	//waitthread PlayFPSAnimShowProxy( player, "pt_s2s_viper_returns_start", "ptpov_s2s_viper_returns_start" , node, "REF", ViewConeTight )//, blendTime )

	FirstPersonSequenceStruct sequence
	sequence.firstPersonAnim	= "ptpov_s2s_viper_returns_start"
	sequence.thirdPersonAnim 	= "pt_s2s_viper_returns_start"
	sequence.attachment 		= "REF"
	sequence.viewConeFunction	= ViewConeTight
	sequence.teleport			= false
	sequence.hideProxy			= false

	waitthread FirstPersonSequence( sequence, player, node )

	entity node2 = CreateScriptMover( bt.GetOrigin(), bt.GetAngles() )
	bt.SetParent( 		node2, "REF", false, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
	player.SetParent( 	node2, "REF", false, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
	viper.SetParent( 	node2, "REF", false, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
	viper.Solid()
	node.Destroy()
	node = node2

	player.SetAnimNearZ( 4 )
	thread PlayAnim( bt, 	"bt_s2s_viper_returns_middle", node, "REF", DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, -1.0 )
	thread PlayAnim( viper, "lt_s2s_viper_returns_middle", node, "REF", DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, -1.0 )
	thread PlayFPSAnimShowProxy( player, "pt_s2s_viper_returns_middle", "ptpov_s2s_viper_returns_middle" , node, "REF", ViewConeTight, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )

	ShipGeoHide( file.OLA, 	"DRACONIS_CHUNK_LOWDEF" )
	ShipGeoShow( file.OLA, 	"DRACONIS_CHUNK_HIGHDEF" )
	EnableScript( file.OLA, "scr_ola_node_1" )
	level.nv.ShipTitles = SHIPTITLES_NODRACONIS
	level.nv.ShipStreaming = SHIPSTREAMING_DRACONIS

	//move node
	entity ref 		= GetEntByScriptName( "bossFightFlyNode" )
	float animTime1 = 1.5
	float animTime2 = player.GetSequenceDuration( "pt_s2s_viper_returns_end" )
	float moveTime 	= animTime1 + animTime2 + 1.5

	node.SetParent( ref, "REF", false, moveTime )
	wait animTime1

	thread PlayAnim( bt, 	"bt_s2s_viper_returns_end", node, "REF" )
	thread PlayAnim( viper, "lt_s2s_viper_returns_end", node, "REF" )

	EmitSoundOnEntity( player, "s2s_scr_player_freefall" )

/*	FirstPersonSequenceStruct sequence
	sequence.blendTime = 0.0
	sequence.attachment = "REF"
	sequence.firstPersonAnim 	= "ptpov_s2s_viper_returns_end"
	sequence.thirdPersonAnim 	= "pt_s2s_viper_returns_end"
	sequence.viewConeFunction 	= ViewConeTight
	sequence.useAnimatedRefAttachment = true
	sequence.teleport			= false
	sequence.hideProxy			= false
	waitthread FirstPersonSequence( sequence, player, node )*/

	waitthread PlayFPSAnimShowProxy( player, "pt_s2s_viper_returns_end", "ptpov_s2s_viper_returns_end" , node, "REF", ViewConeTight, 0 )

	viper.SetHealth( viper.GetMaxHealth() )
	viper.SetInvulnerable()
	bt.Solid()
}

void function BT_Tackle_DamageFx( entity player )
{
	player.WaitSignal( "EndFightTackle" )

	float health = player.GetMaxHealth() * 0.5
	player.SetHealth( health.tointeger() )
}

void function BT_Tackle_VO_and_Music( entity bt )
{
	//Adjusting for wind resistance… calculating…
	delaythread( 2.0 ) PlayBTDialogue( "diag_sp_BTTackle_STS386_01_01_mcor_bt" )
	delaythread( 5.0 ) BT_Tackle_FakeViperCore( bt )
	delaythread( 5.5 ) FlagSet( "ViperReturns" )
	//2-4 hard right!
	delaythread( 6.0 ) PlayDialogue( "diag_sp_gibraltar_STS102_11_01_mcor_radCom", file.player )
	delaythread( 6.5 ) BTTackleMusic()

	wait 7.2

	//EmitSoundOnEntity( file.player, "music_s2s_10_ticks" )

	wait 0.9
	//Brace for impact. - higher intensity
	//thread PlayDialogue( "diag_sp_olaCrash_STS454_17a_01_mcor_bt", bt )

	Objective_SetSilent( "#S2S_OBJECTIVE_KILLVIPER", <0,0,0>, file.viper )
}

void function BTTackleMusic()
{
	StopMusic()
	PlayMusic( "music_s2s_16_bossreturns" )
}

entity function BT_Tackle_FakeViperCore( entity bt )
{
	array<entity> ents 	= GetEntArrayByScriptName( "deckBossTitan" )
	entity spawner
	Assert( ents.len() == 2 )
	foreach ( ent in ents )
	{
		if ( ent == file.viper )
			continue

		spawner = ent
		break
	}

	Assert( IsValid( spawner ) )

	entity viper 	= SpawnFromSpawner( spawner )

	viper.SetModel( TITAN_VIPER_SCRIPTED_MODEL )
	viper.SetSkin( 1 )
	viper.SetValidHealthBarTarget( false )
	HideCrit( viper )
	TakeAllWeapons( viper )
	viper.GiveOffhandWeapon( "sp_weapon_ViperBossRockets_s2s", 0, [ "DarkMissiles" ] )
	viper.Hide()

	vector origin = GetWorldOriginFromRelativeDelta( < -2600, 700, -1500 >, bt.GetParent() )
	entity anchor = CreateScriptMover( origin, < 40, 90, 0> )
	anchor.SetParent( file.malta.mover, "", true, 0 )
	viper.SetParent( anchor, "", true, 0 )
	thread PlayAnimTeleport( viper, "s2s_viper_flight_core_idle", anchor )

	ShipStruct target = file.playerWidow
	float launchdelay = 0.0
	float homingSpeedScalar = 0.25
	float missileSpeedScalar = 1.0
	int num = 14
	waitthread BossIntro_FireCore( viper, file.dropships[ TEAM_MILITIA ], <0,0,0>, launchdelay, homingSpeedScalar, missileSpeedScalar, num )

	wait 1
	anchor.Destroy()
}

entity function SpawnFinalViper()
{
	entity spawner 	= GetEntByScriptName( "deckBossTitan" )
	entity viper 	= SpawnFromSpawner( spawner )
	viper.SetModel( TITAN_VIPER_SCRIPTED_MODEL )
	viper.SetSkin( 1 )
	viper.SetValidHealthBarTarget( false )
	DisableTitanRodeo( viper )
	HideCrit( viper )

	viper.SetTitle( "#BOSSNAME_VIPER" )
	ShowName( viper )

	file.viper = viper

	return viper
}

void function BT_Tackle_ThrowVO()
{
	//Commander Briggs, this is BT-7274. Viper is down.
	waitthreadsolo PlayBTDialogue( "diag_sp_maltaDeck_STS374_01_01_mcor_bt" )

	if ( !Flag( "Tackle_PlayerDisembarked" ) )
	{
		Objective_Set( "#S2S_OBJECTIVE_FASTBALL2pre" )
		DisplayOnscreenHint( file.player, "disembark_hint" )
	}

	//Copy that. Board the Draconis and secure the Ark. We'll prep for transfer.
	waitthreadsolo PlayDialogue( "diag_sp_maltaDeck_STS377_01_01_mcor_sarah", file.player )

	FlagSet( "TackleReadyForFastball" )

	//Cooper - ready for fastball.
	waitthreadsolo PlayBTDialogue( "diag_sp_maltaDeck_STS378_01_01_mcor_bt" )

	OnThreadEnd(
	function() : (  )
		{
			Objective_SetSilent( "#S2S_OBJECTIVE_FASTBALL2" )
		}
	)

	if ( Flag( "Tackle_PlayerDisembarked" ) )
		return
	FlagEnd	( "Tackle_PlayerDisembarked" )

	//Recommend you disembark.
	waitthreadsolo PlayBTDialogue( "diag_sp_maltaDeck_STS378_11_01_mcor_bt" )

	thread HintConvo( "s2s_Hint_DeckFinished", "Tackle_PlayerDisembarked" )
}

void function BT_Tackle_DisableEmbarkWhenReady( entity player )
{
	if ( player.IsTitan() )
	{
		player.WaitSignal( "pilot_Disembark" )
		Assert( IsValid( player.GetPetTitan() ) )
	}

	FlagSet( "Tackle_PlayerDisembarked" )
	ClearOnscreenHint( file.player )
	Embark_Disallow( player )
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	entity soul = bt.GetTitanSoul()
	
	if ( !IsValid( soul ) )
		CreatePetTitanAtOrigin( player, player.GetOrigin(), player.GetAngles() )

	if ( soul.IsDoomed() )
		UndoomTitan( bt, 5 )

	bt.SetHealth( bt.GetMaxHealth() )

	while( player.GetParent() )
		wait 0.1

	FlagSet( "TackleReadyToStart" )
}

void function BT_Tackle_Crows( bool teleport = false )
{
	if ( !teleport )
	{
		array<vector> offsets = [ 	MALTATACKLE_DS_OFFSET_0_0,
									MALTATACKLE_DS_OFFSET_0_1,
									MALTATACKLE_DS_OFFSET_0_2,
									MALTATACKLE_DS_OFFSET_0_3,
									MALTATACKLE_DS_OFFSET_0_4,
									MALTATACKLE_DS_OFFSET_0_5,
									MALTATACKLE_DS_OFFSET_0_6,
									MALTATACKLE_DS_OFFSET_0_7 ]

		foreach ( index, offset in offsets )
		{
			ShipStruct ship = file.dropships[ TEAM_MILITIA ][ index ]
			ship.bug_reproNum = 1

			SetMaxSpeed( ship, 1000 )
			SetMaxAcc( ship, 250 )
			ResetBankTime( ship )
			ResetMaxRoll( ship )

			thread ShipIdleAtTargetEnt_Method2( ship, file.malta.mover, MALTATACKLE_CROW_BOUNDS, <0,0,0>, offset )
		}

		FlagWait( "ViperReturns" )
	}

	array<vector> offsets = [ 	MALTATACKLE_DS_OFFSET_1_0,
								MALTATACKLE_DS_OFFSET_1_1,
								MALTATACKLE_DS_OFFSET_1_2,
								MALTATACKLE_DS_OFFSET_1_3,
								MALTATACKLE_DS_OFFSET_1_4,
								MALTATACKLE_DS_OFFSET_1_5,
								MALTATACKLE_DS_OFFSET_1_6,
								MALTATACKLE_DS_OFFSET_1_7 ]

	array<float> delays	= [ 0.5,	//0
							0.3,	//1
							0.5,	//2
							0.4,	//3
							1.0,	//4
							0.5,	//5
							0.0,	//6
							0.0	]	//7

	foreach ( index, offset in offsets )
	{
		ShipStruct ship = file.dropships[ TEAM_MILITIA ][ index ]

		if ( !teleport )
		{
			SetMaxSpeed( ship, 1500 )
			SetMaxAcc( ship, 400 )
			SetBankTime( ship, 0.75 )
			SetMaxRoll( ship, 60 )
			delaythread( delays[ index ] ) ShipIdleAtTargetEnt_Method2( ship, file.malta.mover, MALTATACKLE_CROW_BOUNDS, <0,0,0>, offset )
		}
		else
			ShipIdleAtTargetEnt_M2_Teleport( ship, file.malta.mover, MALTATACKLE_CROW_BOUNDS, <0,0,0>, offset )
	}

	if ( !teleport )
		wait 2.0

	foreach ( ship in file.dropships[ TEAM_MILITIA ] )
	{
		ResetMaxSpeed( ship, 1 )
		ResetMaxAcc( ship, 1 )
		ResetBankTime( ship )
		ResetMaxRoll( ship )
	}
}

void function BT_Tackle_SarahWidow( bool teleport = false )
{
	if ( !teleport )
	{
		ResetMaxSpeed( file.sarahWidow )
		ResetMaxAcc( file.sarahWidow )
		ResetBankTime( file.sarahWidow )
		ResetMaxRoll( file.sarahWidow )

		delaythread( 1.0 ) Enable_AfterBurner( file.sarahWidow )
		delaythread( 6.5 ) Disable_AfterBurner( file.sarahWidow )

		EmitSoundOnEntity( file.sarahWidow.model, "s2s_scr_widow_flyby_post_viper" )
		thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.malta.mover, MALTATACKLE_WIDOW_BOUNDS, <0,0,0>, MALTATACKLE_WIDOW_OFFSET )
		thread BT_Tackle_SarahAnimate()

		FlagWait( "ViperReturns" )

		wait 0.2

		SetMaxSpeed( file.sarahWidow, 1000 )
		SetMaxAcc( file.sarahWidow, 300 )
		SetBankTime( file.sarahWidow, 0.75 )
		SetMaxRoll( file.sarahWidow, 45 )

		thread ShipIdleAtTargetEnt_Method2( file.sarahWidow, file.malta.mover, MALTATACKLE_WIDOW_BOUNDS2, <0,0,0>, MALTATACKLE_WIDOW_OFFSET2 )

		wait 4
	}
	else
		ShipIdleAtTargetEnt_M2_Teleport( file.sarahWidow, file.malta.mover, MALTATACKLE_WIDOW_BOUNDS2, <0,0,0>, MALTATACKLE_WIDOW_OFFSET2 )

	ResetMaxSpeed( file.sarahWidow, 1 )
	ResetMaxAcc( file.sarahWidow, 1 )
	ResetBankTime( file.sarahWidow )
	ResetMaxRoll( file.sarahWidow )
}

void function BT_Tackle_SarahAnimate()
{
	thread WidowAnimateOpen( file.sarahWidow, "left" )

	SpawnSarahTitan( file.sarahWidow.model.GetOrigin() )

	wait 3.5

	delaythread( 9 ) BT_Tackle_DoorClose()

	waitthread PlayAnimTeleport( file.sarahTitan, "bt_widow_side_dialogue_Sarah", file.sarahWidow.model, "ORIGIN" )
	if ( IsValid( file.sarahTitan) )
		thread PlayAnim( file.sarahTitan, "bt_widow_side_idle_end_Sarah", file.sarahWidow.model, "ORIGIN" )
}

void function BT_Tackle_DoorClose()
{
	//if safe to close
	FlagWaitClear( "PlayerInOrOnSarahWidow" )
	waitthread WidowAnimateClose( file.sarahWidow, "left" )
	wait 0.1

	if ( !Flag( "PlayerInOrOnSarahWidow" ) )
	{
		file.sarahTitan.Destroy()
		return
	}
	else
	{
		waitthread WidowAnimateOpen( file.sarahWidow, "left" )
		thread BT_Tackle_DoorClose()
	}
}

/************************************************************************************************\

██████╗  ██████╗ ███████╗███████╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔══██╗██╔═══██╗██╔════╝██╔════╝    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
██████╔╝██║   ██║███████╗███████╗    █████╗  ██║██║  ███╗███████║   ██║
██╔══██╗██║   ██║╚════██║╚════██║    ██╔══╝  ██║██║   ██║██╔══██║   ██║
██████╔╝╚██████╔╝███████║███████║    ██║     ██║╚██████╔╝██║  ██║   ██║
╚═════╝  ╚═════╝ ╚══════╝╚══════╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

\************************************************************************************************/
void function BossFight_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-46500,0> )
	SetupShips_BossFight()

	EnableScript( file.OLA, "scr_ola_node_1" )
	SpawnFinalViper()

	Objective_SetSilent( "#S2S_OBJECTIVE_KILLVIPER", <0,0,0>, file.viper )

	player.DisableWeapon()
	player.ForceStand()
	player.SetInvulnerable()
	PlayerSetStartPoint( player, GetEntByScriptName( "bossFightPlayerNode" ), <0,-4000,5000> )

	wait 0.1
}

void function BossFight_Skip( entity player )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	int bodyIndex = bt.FindBodyGroup( "left_arm" )
	bt.SetBodygroup( bodyIndex, 2 )
	bt.TakeActiveWeapon()
	thread CreateBTArmDamagedFX( bt )
	BossFight_BTVentFireFx( bt )

	if ( IsValid( file.OLA.triggerFallingDeath ) )
		file.OLA.triggerFallingDeath.Disable()
	GetEntByScriptName( "draconisOOB" ).Enable()
}

void function BossFight_Main( entity player )
{
	entity bt 		= player.GetPetTitan()
	Assert( IsValid( bt ) )
	entity node 	= bt.GetParent()
	entity viper 	= file.viper

	CleanupScript( "scr_malta_node_4" )
	CleanupScript( "scr_malta_node_5" )

	string animPOV 	= "ptpov_s2s_end_fight_landing"
	string anim3rd 	= "pt_s2s_end_fight_landing"
	float blendTime = 1.5
	entity anchor 	= CreateScriptMover( player.GetOrigin(), player.GetAngles() )
	player.SetParent( anchor, "REF", false, 0 )
	anchor.SetParent( GetEntByScriptName( "scr_ola_node_1" ), "REF", true, 0 )

	entity ref 		= GetEntByScriptName( "bossFightPlayerNode0" )


	//EmitSoundOnEntityAfterDelay( player, "scr_s2s_player_land_on_crow", blendTime )
	//player.SetParent( ref, "REF", false, blendTime )
	anchor.NonPhysicsSetMoveModeLocal( true )
	anchor.NonPhysicsSetRotateModeLocal( true )
	anchor.NonPhysicsMoveTo( ref.GetLocalOrigin(), blendTime, 0, 0 )
	anchor.NonPhysicsRotateTo( ref.GetLocalAngles(), 0.1, 0, 0 )

	player.SetAnimNearZ( 2 )
	thread PlayFPSAnimShowProxy( player, anim3rd, animPOV , anchor, "REF", ViewConeTight, 0 )
	float duration = player.GetSequenceDuration( "pt_s2s_end_fight_landing" )
	wait duration - 0.1

	HurtPlayer( player, 0.5 )
	delaythread( 1.9 ) HurtPlayer( player, 0.5 )
	delaythread( 1.9 ) BossFight_Blur( player )

	bt.ClearParent()
	bt.TakeActiveWeapon()
	viper.ClearParent()
	if ( IsValid( node ) )
		node.Destroy()

	node = GetEntByScriptName( "bossFightStartNode" )
	bt.SetParent( node, "REF" )
	viper.SetParent( node, "REF" )

	thread BossFight_KnockBacks( viper, player )

	animPOV 	= "ptpov_s2s_end_fight_fall"
	anim3rd 	= "pt_s2s_end_fight_fall"
	blendTime 	= 0.2
	ref 		= GetEntByScriptName( "bossFightPlayerNode" )
	anchor.NonPhysicsMoveTo( ref.GetLocalOrigin(), blendTime, 0, 0 )
	anchor.NonPhysicsRotateTo( ref.GetLocalAngles(), blendTime, 0, 0 )

	entity arm = CreatePropDynamic( MODEL_BT_ARM, <0,0,0>, <0,0,0> )
	arm.SetParent( node )
	arm.Hide()

	entity viperPilot = SpawnFromSpawner( GetEntByScriptName( "viperPilot" ) )
	viperPilot.SetModel( MODEL_VIPER_PILOT )
	viperPilot.TakeActiveWeapon()
	Highlight_SetFriendlyHighlight( viperPilot, "sp_enemy_pilot" )
	Highlight_SetEnemyHighlight( viperPilot, "sp_enemy_pilot" )
	viperPilot.SetParent( node )
	viperPilot.SetInvulnerable()
	viperPilot.NotSolid()
	viperPilot.Hide()

	SetTeam( viperPilot, TEAM_IMC )

	Objective_SetSilent( "#S2S_OBJECTIVE_KILLVIPER", <0,0,0>, viperPilot )

	entity cockpit = CreatePropDynamic( MODEL_VIPER_HATCH, <0,0,0>, <0,0,0> )
	cockpit.SetParent( node )
	cockpit.Hide()
	cockpit.SetSkin( 1 )

	arm.SetNextThinkNow()
	cockpit.SetNextThinkNow()
	viper.SetNextThinkNow()
	bt.SetNextThinkNow()
	viperPilot.SetNextThinkNow()

	viper.Anim_AdvanceCycleEveryFrame( true )
	viperPilot.Anim_AdvanceCycleEveryFrame( true )
	bt.Anim_AdvanceCycleEveryFrame( true )

	arm.Anim_Play( "BTarm_s2s_end_fight_start" )
	cockpit.Anim_Play( "LThatch_s2s_end_fight_start" )
	thread PlayAnimTeleport( viper, "lt_s2s_end_fight_start", node )
	thread PlayAnimTeleport( viperPilot, "viper_s2s_end_fight_start", node )
	thread PlayAnimTeleport( bt, "bt_s2s_end_fight_start", node )

	thread BossFight_BTLosesArm( bt, arm )
	thread BossFight_ViperLosesCockpit( viper, cockpit, viperPilot )
	thread BossFight_Quakes( viper )

	delaythread( 2.5 ) CheckPoint_ForcedSilent()

	waitthread PlayFPSAnimShowProxy( player, anim3rd, animPOV , anchor, "REF", ViewConeTight, 0 )

	player.UnforceStand()
	player.Anim_Stop()
	ClearPlayerAnimViewEntity( player )
	player.ClearParent()
	player.ClearAnimNearZ()
	player.SetVelocity( <0,0,0> )
	player.ClearInvulnerable()
	anchor.Destroy()
	thread BossFight_DelayedWeaponDeploy( player )

	file.OLA.triggerFallingDeath.Disable()
	GetEntByScriptName( "draconisOOB" ).Enable()

	WaittillAnimDone( bt )

	//call this before destroying viper
	if ( Distance( player.GetOrigin(), viper.GetOrigin() ) < 300 )
		player.ClearTraverse()

	viper.Destroy()
	viper = CreatePropDynamic( TITAN_VIPER_SCRIPTED_MODEL, null, null, 6 )
	viper.SetSkin( 1 )
	int bodyIndex = viper.FindBodyGroup( "hatch" )
	viper.SetBodygroup( bodyIndex, 1 )
	viper.SetParent( node )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( FX_VIPER_COCKPIT_DLIGHT ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "HIJACK" ) )

	thread PlayAnimTeleport( viperPilot, "viper_s2s_end_fight_opening", node )
	thread PlayAnimTeleport( viper, "lt_s2s_end_fight_opening", node )
	thread PlayAnim( bt, "bt_s2s_end_fight_opening", node )

	duration = viper.GetSequenceDuration( "lt_s2s_end_fight_opening" )
	delaythread( duration ) FlagSet( "ViperKillsBT" )
	thread FlagSetOn_AllDead( "PlayerSavesBT", [ viperPilot ] )
	thread BossFight_ViperPilotDeath( viperPilot, node )

	thread BossFight_KillVO( bt, viperPilot, player )

	wait 0.5

	viperPilot.ClearInvulnerable()
	thread BossFight_ViperPilotHealthThink( viperPilot, viper )

	FlagWaitAny( "ViperKillsBT", "PlayerSavesBT" )

	if ( Flag( "ViperKillsBT" ) && IsAlive( viperPilot ) )
	{
		viperPilot.SetInvulnerable()
		FlagClear( "SaveGame_Enabled" ) // no more saving, you have lost
		StopMusic()
		PlayMusic( "music_s2s_17a_btdead" )

		thread PlayAnim( bt, "bt_s2s_end_fight_kill", node )
		thread PlayAnim( viperPilot, "viper_s2s_end_fight_kill", node )
		thread PlayAnim( viper, "lt_s2s_end_fight_kill", node )

		float duration = viper.GetSequenceDuration( "lt_s2s_end_fight_kill" )
		wait duration - 0.1

		ReloadForMissionFailure()
		ScreenFadeToBlackForever( player, 0.0 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_TitanDied", eDamageSourceId.titan_execution )

		WaitForever()
	}

	Assert( Flag( "PlayerSavesBT" ) )
	CheckPoint()

	bt.SetInvulnerable()

	EnableScript( file.OLA, "scr_ola_node_2" )
	entity hatch = GetEntByScriptName( "ola_hatch" )
	hatch.SetParent( node )

	hatch.SetNextThinkNow()
	viper.SetNextThinkNow()
	viper.NotSolid()
	bt.SetNextThinkNow()

	hatch.Anim_Play( "hatch_s2s_end_fight_finale" )
	thread PlayAnim( viper, "lt_s2s_end_fight_finale", node )
	thread PlayAnim( bt, "bt_s2s_end_fight_finale", node )
}

void function BossFight_DelayedWeaponDeploy( entity player )
{
	player.EndSignal( "OnDeath" )
	wait 0.5
	player.DeployWeapon()
}

void function BossFight_ViperPilotHealthThink( entity viperPilot, entity viper )
{
	viperPilot.EndSignal( "OnDeath" )

	float duration = viper.GetSequenceDuration( "lt_s2s_end_fight_opening" ) - 1.5
	float endTime = Time() + duration
	int maxHealth = viperPilot.GetMaxHealth()

	while( 1 )
	{
		float timeLeft = endTime - Time()
		int health = GraphCapped( timeLeft, 0, duration, 10, maxHealth ).tointeger()

		if ( health < viperPilot.GetHealth() )
			viperPilot.SetHealth( health )

		//printt( viperPilot.GetHealth() )
		WaitFrame()
	}
}

void function BossFight_Blur( entity player )
{
	Remote_CallFunction_NonReplay( file.player, "ServerCallback_s2sBossFightBlur" )
}

void function BossFight_ViperPilotDeath( entity viperPilot, entity node  )
{
	asset model = viperPilot.GetModelName()
	table signal = WaitSignal( viperPilot, "OnDeath" )

	if ( file.player.GetActiveWeapon().GetWeaponClassName() == "mp_weapon_lstar" )
	{
		if ( IsValid( viperPilot) )
			viperPilot.Dissolve( ENTITY_DISSOLVE_PINKMIST, Vector( 0, 0, 0 ), 500 )
		return
	}

	entity dummy = CreatePropDynamic( model, viperPilot.GetOrigin(), viperPilot.GetAngles() )
	dummy.SetParent( node )
	SetTeam( dummy, TEAM_IMC )

	if ( IsValid( viperPilot) )
		viperPilot.Destroy()

	EmitSoundOnEntity( dummy, "s2s_scr_hit_kill_northstar" )
	thread PlayAnimTeleport( dummy, "viper_s2s_end_fight_finale", node )
}

void function BossFight_BTLosesArm( entity bt, entity arm )
{
	bt.WaitSignal( "armRip" )

	int bodyIndex = bt.FindBodyGroup( "left_arm" )
	bt.SetBodygroup( bodyIndex, 2 )
	arm.Show()

	BossFight_BTVentFireFx( bt )
	thread CreateBTArmDamagedFX( bt )
}

void function BossFight_BTVentFireFx( entity bt )
{
	StartParticleEffectOnEntity( bt, GetParticleSystemIndex( FX_BT_VENT_FIRE ), FX_PATTACH_POINT_FOLLOW, bt.LookupAttachment( "dam_vent_right" ) )
	StartParticleEffectOnEntity( bt, GetParticleSystemIndex( FX_BT_VENT_FIRE ), FX_PATTACH_POINT_FOLLOW, bt.LookupAttachment( "dam_vent_left" ) )
}

void function CreateBTArmDamagedFX( entity bt )
{
	bt.EndSignal( "OnDeath" )
	bt.EndSignal( "OnDestroy" )

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
		EmitSoundOnEntity( bt, "titan_damage_spark" )
		wait RandomFloatRange(3,5)

		StartParticleEffectOnEntity( bt, fx_large, FX_PATTACH_POINT_FOLLOW, attachID )
		EmitSoundOnEntity( bt, "titan_damage_spark" )
		wait RandomFloatRange(1,2)
	}
}


void function BossFight_ViperLosesCockpit( entity viper, entity cockpit, entity viperPilot )
{
	viper.WaitSignal( "EndFightCockpitLost" )

	int bodyIndex = viper.FindBodyGroup( "hatch" )
	viper.SetBodygroup( bodyIndex, 1 )
	cockpit.Show()
	viperPilot.DisableHibernation()
	viperPilot.Show()
	viperPilot.Solid()
	Highlight_SetEnemyHighlight( viperPilot, "sp_enemy_pilot" )
	StartParticleEffectOnEntity( viper, GetParticleSystemIndex( FX_VIPER_COCKPIT_DLIGHT ), FX_PATTACH_POINT_FOLLOW, viper.LookupAttachment( "HIJACK" ) )

}

void function BossFight_KillVO( entity bt, entity viperPilot, entity player )
{
	FlagEnd( "PlayerSavesBT" )
	FlagEnd( "ViperKillsBT" )
	player.EndSignal( "OnDeath" )
	viperPilot.EndSignal( "OnDeath" )

	//I’ve lost my canopy! Need cover need cover!
	waitthreadsolo PlayDialogue( "diag_sp_bossFight_STS675_01_01_mcor_viper", viperPilot )

	wait 1.5
	//Cooper - Aim for the cockpit.
	waitthreadsolo PlayBTDialogue( "diag_sp_bossFight_STS392_01_01_mcor_bt" )

	wait 2.0
	//Take the shot
	waitthreadsolo PlayBTDialogue( "diag_sp_bossFight_STS393_01_01_mcor_bt" )
}

void function BossFight_KnockBacks( entity viper, entity player )
{
	viper.WaitSignal( "EndFightCockpitLost" )
	viper.WaitSignal( "EndFightTackle" )

	if ( !file.player.IsOnGround() )
		return

	vector dir	= viper.GetOrigin() - player.GetOrigin()
	float dist 	= dir.Length()

	if ( dist > 1000 )
		return

	if ( dist > 700 )
	{
		dir	= player.GetOrigin() - viper.GetOrigin()
		vector angles 	= VectorToAngles( Normalize( dir ) )

		thread PlayerStumbleThink( angles )
		return
	}

	int health = player.GetMaxHealth()
	float damage = GraphCapped( dist, 400, 700, health * 0.1, health * 0.8 )
	player.SetHealth( damage.tointeger() )

	vector angles 	= VectorToAngles( Normalize( dir ) )

	entity land = CreateScriptMover( player.GetOrigin(), angles )
	land.SetParent( file.OLA.mover, "", true, 0 )

	player.ForceStand()
	player.DisableWeapon()
	player.SetParent( land, "REF", false, 0 )

	waitthread PlayFPSAnimShowProxy( player, "pt_s2s_end_fight_knockback", "ptpov_s2s_end_fight_knockback", land, "REF", ViewConeZero, 0 )

	player.ClearParent()
	player.UnforceStand()
	player.Anim_Stop()
	player.Signal( "ScriptAnimStop" )
	player.Signal( "FlightPanelAnimEnd" )
	ClearPlayerAnimViewEntity( player )
	player.DeployWeapon()

	land.Destroy()
}

void function BossFight_Quakes( entity viper )
{
	viper.EndSignal( "OnDeath" )

	while( 1 )
	{
		viper.WaitSignal( "EndFightTackle" )

		float amplitude = 5
		float frequency = 200
		float duration = 1.0
		float radius = 2048
		entity shake = CreateShake( viper.GetOrigin(), amplitude, frequency, duration, radius )
	}
}

entity function PutWeaponModelInPlayersHand( entity player, entity playerWeapon )
{
	entity weaponModel = null

	if ( IsValid( playerWeapon ) )
	{
		asset weaponModelAsset = playerWeapon.GetWeaponInfoFileKeyFieldAsset( "playermodel" )
		entity fpProxy = player.GetFirstPersonProxy()
		int attachID = fpProxy.LookupAttachment( "PROPGUN" )
		weaponModel = CreatePropDynamic( weaponModelAsset, fpProxy.GetAttachmentOrigin( attachID ), fpProxy.GetAttachmentAngles( attachID ) )
		weaponModel.SetParent( player.GetFirstPersonProxy(), "PROPGUN", false, 0.0 )
	}

	return weaponModel
}

entity function GetWeapon( entity ent, string weaponClassName, array<string> mods = [] )
{
	Assert( ent.IsPlayer() || ent.IsNPC() )

	array<entity> weaponArray = ent.GetMainWeapons()
	foreach ( weapon in weaponArray )
	{
		if ( weapon.GetWeaponClassName() == weaponClassName )
		{
			if ( WeaponHasSameMods( weapon, mods ) )
				return weapon
		}
	}

	return null
}

/************************************************************************************************\

██╗   ██╗██╗██████╗ ███████╗██████╗     ██████╗ ███████╗ █████╗ ██████╗
██║   ██║██║██╔══██╗██╔════╝██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██╔══██╗
██║   ██║██║██████╔╝█████╗  ██████╔╝    ██║  ██║█████╗  ███████║██║  ██║
╚██╗ ██╔╝██║██╔═══╝ ██╔══╝  ██╔══██╗    ██║  ██║██╔══╝  ██╔══██║██║  ██║
 ╚████╔╝ ██║██║     ███████╗██║  ██║    ██████╔╝███████╗██║  ██║██████╔╝
  ╚═══╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝

\************************************************************************************************/
void function ViperDead_Setup( entity player )
{
	WORLD_CENTER.SetOrigin( <0,-46500,0> )
	SetupShips_BossFight()

	EnableScript( file.OLA, "scr_ola_node_1" )
	entity node = GetEntByScriptName( "bossFightStartNode" )
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.SetInvulnerable()
	bt.SetParent( node )

	entity viper = CreatePropDynamic( TITAN_VIPER_SCRIPTED_MODEL, null, null, 6 )
	viper.SetSkin( 1 )
	file.viper = viper
	viper.SetParent( node )

	EnableScript( file.OLA, "scr_ola_node_2" )
	entity hatch = GetEntByScriptName( "ola_hatch" )
	hatch.SetParent( node )

	hatch.SetNextThinkNow()
	viper.SetNextThinkNow()
	viper.NotSolid()
	bt.SetNextThinkNow()

	hatch.Anim_Play( "hatch_s2s_end_fight_finale" )
	thread PlayAnim( viper, "lt_s2s_end_fight_finale", node )
	thread PlayAnim( bt, "bt_s2s_end_fight_finale", node )

	PlayerSetStartPoint( player, GetEntByScriptName( "ola_PlayerStart1" ) )
}

void function ViperDead_Skip( entity player )
{
	FlagSet( "StopWindFx" )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.EnableNPCMoveFlag( NPCMF_IGNORE_CLUSTER_DANGER_TIME )

	entity sndEnt = GetEntByScriptName( "draconis_PA" )
	sndEnt.ClearParent()
	sndEnt.SetOrigin( GetEntByScriptName( "draconis_PA_move" ).GetOrigin() )

	foreach ( ent in file.draconis_PA )
		ent.DisableHibernation()
	
	// NextState()
	SetStateInt( 0 )
}

void function ViperDead_Main( entity player )
{
	entity bt = player.GetPetTitan()
	if ( !IsValid( bt ) )
	{
		bt = GetPlayer0().GetPetTitan()
		player = GetPlayer0()
		file.player = player
	}
	
	if ( !IsValid(bt) )
		bt = CreatePetTitanAtOrigin( GetPlayer0(), file.respawnWidow.mover.GetOrigin() + <0,0,300>, <0,0,0> )
	
	bt.EndSignal( "OnDeath" )

	// OnThreadEnd(
	// 	function () : ()
	// 	{
	// 		thread RestartMapWithDelay()
	// 	}
	// )

	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.EnableNPCMoveFlag( NPCMF_IGNORE_CLUSTER_DANGER_TIME )

	thread VipeDead_LaunchDeathBlossom()

	Objective_SetSilent( "#S2S_OBJECTIVE_BOARDDRACONIS", <0,0,0>, GetEntByScriptName( "ola_hatch" ) )

	StopMusic()
	PlayMusic( "music_s2s_17_bossdead" )

	delaythread( 5.0 ) ViperDead_VO( bt )
	delaythread( 5.0 ) ViperDead_PodSetup()
	delaythread( 5.0 ) ViperDead_DraconisPA()
	delaythread( 5.0 ) ViperDead_LifeboatPrerunners()
	thread ViperDead_BTIdlesAtHatch( bt )

	bt.WaitSignal( "hatchopen" )

	entity hatch = GetEntByScriptName( "ola_hatch" )
	hatch.NotSolid() //the physics model doesn't follow the anim ( need to fix that )
	FlagSet( "OLA_HatchOpen" )

	FlagWait( "PlayerJumpsToLifeboats" )

	AddSpawnCallback_ScriptName( "draconis_runner", ViperDead_RunnerThink )
	array<entity> spawners = GetEntArrayByScriptName( "draconis_runner" )
	foreach ( spawner in spawners )
		SpawnOnShip( spawner, file.OLA )

	StopConversation( player )

	player.ForceStand()
	player.DisableWeapon()

	entity node = GetEntByScriptName( "lifeboats_landNode_1" )

	node.NonPhysicsSetMoveModeLocal( true )
	node.NonPhysicsSetRotateModeLocal( true )
	vector origin = node.GetLocalOrigin()
	vector angles = node.GetLocalAngles()
	float blendTime = 0.2
	string anim3rd = "pt_s2s_lifeboats_jump"
	string animPOV = "ptpov_s2s_lifeboats_jump"

	vector hackOrigin = HackGetDeltaToRef( player.GetOrigin(), player.GetAngles(), player, anim3rd )

	node.ClearParent()
	node.SetOrigin( hackOrigin )
	node.SetAngles( player.GetAngles() )
	node.SetParent( file.OLA.model, "", true, 0 )

	FirstPersonSequenceStruct sequence

	sequence.firstPersonAnim	= animPOV
	sequence.thirdPersonAnim 	= anim3rd
	sequence.attachment 		= "REF"
	sequence.viewConeFunction	= ViewConeZeroSlowLerp
	sequence.teleport			= false
	sequence.hideProxy			= false

	thread FirstPersonSequence( sequence, player, node )

	float moveTime = 1.3
	node.NonPhysicsMoveTo( origin, moveTime, moveTime, 0 )
	node.NonPhysicsRotateTo( angles, moveTime, moveTime * 0.5, moveTime * 0.5 )
	wait moveTime

	StopSoundOnEntity( file.player, "s2s_scr_draconis_falling" )

	FlagSet( "StopWindFx" )

	blendTime = 0.2
	thread LifeBoats_Landing( player, node )

	wait blendTime
	FlagSet( "LifeboatStart" )

	entity ref = GetEntByScriptName( "lifeboats_landNode_2" )

	node.NonPhysicsStop()
	node.ClearParent()
	node.SetOrigin( ref.GetOrigin() )
	node.SetAngles( ref.GetAngles() )

	entity sndEnt = GetEntByScriptName( "draconis_PA" )
	sndEnt.ClearParent()
	sndEnt.SetOrigin( GetEntByScriptName( "draconis_PA_move" ).GetOrigin() )

	bt.ClearParent()

	TeleportAllExceptOne( player.GetOrigin(), player )
	SetStateInt( 0 )
}

void function LifeBoats_Landing( entity player, entity node )
{
	string anim3rd = "pt_s2s_lifeboats_land"
	string animPOV = "ptpov_s2s_lifeboats_land"
	player.SetAnimNearZ( 1 )

	EmitSoundOnEntityAfterDelay( file.player, "s2s_anim_coop_jump_into_ship", 0.1 )
	thread PlayFPSAnimShowProxy( player, anim3rd, animPOV, node, "REF", ViewConeZero, 0.0 )
}

void function VipeDead_LaunchDeathBlossom()
{
	entity spawner 	= GetEntByScriptName( "deckBossTitan" )
	entity viper 	= SpawnFromSpawner( spawner )
	viper.SetModel( TITAN_VIPER_SCRIPTED_MODEL )
	viper.SetSkin( 1 )
	viper.SetInvulnerable()
	viper.SetNoTarget( true )
	viper.SetNoTargetSmartAmmo( false )
	viper.SetValidHealthBarTarget( false )
	HideCrit( viper )
	viper.Hide()
	viper.NotSolid()

	TakeAllWeapons( viper )
	viper.GiveOffhandWeapon( "sp_weapon_ViperBossRockets_s2s", 0, [ "DarkMissiles" ] )

	entity node = GetEntByScriptName( "bossFightStartNode" )
	viper.SetParent( node )
	thread PlayAnim( viper, "lt_s2s_end_fight_finale", node )

	float homingSpeedScalar = 0.75
	float missileSpeedScalar = 0.75
	float launchdelay = 1.0
	vector offset = < 0,0,0 >

	//play tell warning sound and fx
	//EmitSoundOnEntity( file.player, "northstar_rocket_warning" )
	wait launchdelay

	EmitSoundOnEntity( file.player, "northstar_rocket_fire" )
	entity weapon = viper.GetOffhandWeapon( 0 )
	array<entity> targets = GetEntArrayByScriptName( "viperDeathRocketHit" )

	for( int i = 0; i < 12; i++ )
	{
		int burstIndex = i
		int targetIndex = i%targets.len()

		entity target = targets[targetIndex]

		thread OnWeaponScriptAttack_s2s_ViperDead( weapon, burstIndex, target, offset, homingSpeedScalar, missileSpeedScalar )

		wait 0.1
	}
	viper.Destroy()

	UnlockAchievement( file.player, achievements.BEAT_VIPER )

	wait 1.0

	EmitSoundOnEntity( file.player, "s2s_scr_draconis_falling" )
	thread DraconisShake()
	thread DoCustomBehavior( file.OLA, DraconisTilt )

	int fxID = GetParticleSystemIndex( SHIPFIRE_FX )
	bool firstTime = true
	//the while loop is a hack - should just loop

	FlagEnd( "LifeboatStart" )

	while( 1 )
	{
		foreach( target in targets )
		{
			if ( firstTime )
			{
				target.DisableHibernation()
				EmitSoundOnEntity( target, "s2s_emit_s2s_draconis_fires" )
				thread ViperDead_FireHurt( target )
			}

			StartParticleEffectOnEntity( target, fxID, FX_PATTACH_CUSTOMORIGIN_FOLLOW, -1 )

			wait 0.2
		}

		firstTime = false
		wait 8
	}
}

void function ViperDead_FireHurt( entity target )
{
	FlagEnd( "LifeboatStart" )
	target.EndSignal( "OnDestroy" )

	array<float> dist = [ 500.0, 500.0, 400.0 ]
	array<float> distSqr = [ pow( dist[0], 2 ), pow( dist[1], 2 ), pow( dist[2], 2 ) ]
	array<float> ranges = [ 250.0, 800.0, 1300.0 ]

	#if DEV
		if ( GetBugReproNum() == 1 )
			thread ViperDead_FireHurt_Debug( target, dist, ranges )
	#endif

	while( 1 )
	{
		wait 0.5

		vector newVec = Normalize( target.GetForwardVector() + <0,-0.5,0> )

		foreach ( index, range in ranges )
		{
			if ( DistanceSqr( target.GetOrigin() + ( newVec * range ), file.player.GetOrigin() ) < distSqr[ index ] )
			{
				EmitSoundOnEntity( file.player, "flesh_fire_damage_1p" )
				file.player.TakeDamage( 20, target, target, { damageSourceId=eDamageSourceId.burn } )
				break
			}
		}
	}
}

void function ViperDead_FireHurt_Debug( entity target, array<float> radius, array<float> ranges )
{
	FlagEnd( "LifeboatStart" )
	target.EndSignal( "OnDestroy" )

	while( 1 )
	{
		vector newVec = Normalize( target.GetForwardVector() + <0,-0.5,0> )

		foreach ( index, range in ranges )
			DebugDrawSphere( target.GetOrigin() + ( newVec * range ), radius[ index ], 255, 0, 0, true, FRAME_INTERVAL, 12 )

		wait FRAME_INTERVAL
	}
}

void function DraconisTilt( ShipStruct ship )
{
	Signal( ship, "NewFlyStyle" )
	EndSignal( ship, "NewFlyStyle" )
	EndSignal( ship, "FakeDestroy" )
	EndSignal( ship.model, "OnDestroy" )

	ship.mover.NonPhysicsRotateTo( <12, 90, -25 >, 15, 4, 4 )

	LocalVec origin = GetOriginLocal( ship.mover )
	origin.v = < origin.v.x, origin.v.y, -5000 >

	float time = 60
	float acc = 10
	float dec = 5

	NonPhysicsMoveToLocal( ship.mover, origin, time, acc, dec )
	file.skyRig.NonPhysicsMoveTo( file.skyRig.GetOrigin() + <0,0,25>, time, acc, dec )

	WaitForever()
}

void function DraconisShake()
{
	float amplitude = 2
	float frequency = 200
	float duration = 900 //15 min
	float radius = 2048

	entity shake = CreateAirShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )

	FlagWait( "PlayerJumpsToLifeboats" )
	thread KillShake( shake )

	FlagWait( "LifeboatStart" )
	thread LifeboatShake()
}

void function ViperDead_BTIdlesAtHatch( entity bt )
{
	FlagEnd( "LifeboatStart" )

	WaittillAnimDone( bt )
	entity node = GetEntByScriptName( "bossFightStartNode" )
	thread PlayAnim( bt, "bt_s2s_end_fight_waiting", node )
}

void function ViperDead_PodSetup()
{
	array<entity> pods = GetEntArrayByScriptName( "draconis_pods" )
	foreach ( pod in pods )
	{
		pod.Solid()
		pod.DisableHibernation()

		if ( pod.HasKey( "script_noteworthy" ) && pod.kv.script_noteworthy == "fakePod" )
			continue

		entity node = CreateScriptMover( pod.GetOrigin(), AnglesCompose( pod.GetAngles(), <0,90,0> ) )
		node.SetToSameParentAs( pod )
		pod.SetParent( node )
		pod.Anim_Play( "s2s_escape_pod_open" )
	}
}

void function ViewConeZeroSlowLerp( entity player )
{
	player.PlayerCone_SetLerpTime( 1.0 )

	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( 0 )
	player.PlayerCone_SetMaxYaw( 0 )
	player.PlayerCone_SetMinPitch( 0 )
	player.PlayerCone_SetMaxPitch( 0 )
}

void function ViperDead_RunnerThink( entity guy )
{
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.EnableNPCMoveFlag( NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_PREFER_SPRINT )
	guy.DisableHibernation()
	guy.SetEfficientMode( true )
	guy.SetMaxHealth( 25 )
	guy.SetHealth( 25 )

	guy.Signal( "StopAssaultMoveTarget" )
	file.player.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )

	entity firstLink = guy.GetLinkEnt()
	firstLink.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( guy )
		{
			if ( IsValid( guy ) )
				guy.Destroy()
		}
	)

	entity link = firstLink
	string anim
	entity node
	entity pod
	float blendTime = 0.3
	bool disableArrival = true
	bool disableAssaultAngles = false

	while( IsValid( link ) )
	{
		switch( link.GetClassName() )
		{
			//anim nodes
			case "script_mover_lightweight":
			{
				anim = expect string( link.kv.leveled_animation )
				if ( IsAlive( guy ) && guy.Anim_IsActive() )
					WaittillAnimDone( guy )

				switch( anim )
				{
					//time to get in the lifeboat
					case "pt_s2s_lifeboat_embark_R":
					case "pt_s2s_lifeboat_embark_L":
						if ( IsAlive( guy ) && link == firstLink )
							waitthread RunToAnimStartHACK( guy, anim, link, null, disableArrival, disableAssaultAngles )
						if ( IsAlive( guy )	)
						{
							node = link
							guy.SetParent( node, "REF", false, blendTime )
							thread PlayAnim( guy, anim, node, "REF", blendTime )
						}
						break

					default:
						if ( IsAlive( guy )	)
							waitthread RunToAnimStartHACK( guy, anim, link, null, disableArrival, disableAssaultAngles )

						if ( IsAlive( guy )	)
							guy.SetParent( link, "", false, blendTime )
							thread PlayAnim( guy, anim, link, "", blendTime )
						break
				}

			}break

			//the pod
			case "script_mover":
			{

			}break
		}

		link = link.GetLinkEnt()
	}

	WaitForever()
}

void function ViperDead_LifeboatPrerunners()
{
	array<entity> spawners = GetEntArrayByScriptName( "lifeboat_prerunners" )
	array<entity> guys

	foreach ( index, spawner in spawners )
	{
		entity guy = SpawnFromSpawner( spawner )

		guy.SetInvulnerable()
		guy.SetNoTarget( true )
		guy.EnableNPCFlag( NPC_IGNORE_ALL )
		guy.EnableNPCMoveFlag( NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_PREFER_SPRINT )
		guy.DisableHibernation()
		guy.SetEfficientMode( true )

		entity node = guy.GetLinkEnt()
		thread ViperDead_LifeboatPrerunnersThink( guy, node, expect string( node.kv.leveled_animation ) )

		guys.append( guy )
	}
}

void function ViperDead_LifeboatPrerunnersThink( entity guy, entity node, string anim )
{
	FlagEnd( "LifeboatStart" )
	node.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )

	entity node2 = CreateScriptMover()

	OnThreadEnd(
	function() : ( node, node2, guy )
		{
			if ( IsValid( node ) )
				node.Destroy()
			if ( IsValid( node2 ) )
				node2.Destroy()
			if ( IsValid( guy ) )
				guy.Destroy()
		}
	)

	float duration = guy.GetSequenceDuration( anim ) - 0.1
	float blendTime = 0.2

	guy.SetParent( node, "REF", false, 0 )
	thread PlayAnimTeleport( guy, anim, node, "REF" )
	wait duration

	node2.SetOrigin( guy.GetOrigin() )
	node2.SetAngles( node.GetAngles() )
	node2.SetParent( node.GetParent(), "", true, 0 )

	while( 1 )
	{
		guy.SetParent( node2, "REF", false, blendTime )
		thread PlayAnim( guy, anim, node2, "REF", blendTime )
		wait duration

		guy.SetParent( node, "REF", false, 0 )
		thread PlayAnimTeleport( guy, anim, node, "REF" )
		wait duration
	}
}

void function ViperDead_DraconisPA()
{
	FlagEnd( "LifeboatStart" )
	FlagWait( "PlayDraconisPA" )

	float duration
	foreach ( ent in file.draconis_PA )
		ent.DisableHibernation()

	while( 1 )
	{
		//Abandon ship. Please walk do not run to the nearest escape pod.
		duration = PlayDraconisPA( "diag_sp_lifeBoats_STS412_01_01_neut_cpupa" )
		wait 10
	}
}

void function ViperDead_VO( entity bt )
{
	FlagEnd( "PlayerJumpsToLifeboats" )

	waitthread PlayerConversation( "s2s_ViperDead2", file.player, bt )

	wait 1.0

	//This ship is rapidly losing altitude - it is up to us, Cooper.
	waitthreadsolo PlayBTDialogue( "diag_sp_bossFight_STS399_13_01_mcor_bt" )

	FlagWait( "OLA_HatchOpen" )

	//Down here.
	waitthreadsolo PlayBTDialogue( "diag_sp_lifeBoats_STS409_01_01_mcor_bt" )

	thread HintConvo( "s2s_Hint_Lifeboats", "PlayerJumpsToLifeboats" )
}


/************************************************************************************************\

██╗     ██╗███████╗███████╗    ██████╗  ██████╗  █████╗ ████████╗███████╗
██║     ██║██╔════╝██╔════╝    ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝
██║     ██║█████╗  █████╗      ██████╔╝██║   ██║███████║   ██║   ███████╗
██║     ██║██╔══╝  ██╔══╝      ██╔══██╗██║   ██║██╔══██║   ██║   ╚════██║
███████╗██║██║     ███████╗    ██████╔╝╚██████╔╝██║  ██║   ██║   ███████║
╚══════╝╚═╝╚═╝     ╚══════╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝

\************************************************************************************************/
void function LifeBoats_Setup( entity player )
{
	entity node = GetEntByScriptName( "lifeboats_landNode_1" )
	entity ref = GetEntByScriptName( "lifeboats_landNode_2" )
	node.ClearParent()
	node.SetOrigin( ref.GetOrigin() )
	node.SetAngles( ref.GetAngles() )

	string anim3rd = "pt_s2s_lifeboats_jump"
	string animPOV = "ptpov_s2s_lifeboats_jump"
	player.SetParent( node, "REF" )
	player.ForceStand()
	player.DisableWeapon()

	delaythread( 0.2 ) PlayFPSAnimTeleportShowProxy( player, anim3rd, animPOV, node, "REF", ViewConeZero )
	delaythread( 1.2 ) FlagSet( "LifeboatStart" )
	delaythread( 1.0 ) LifeBoats_Landing( player, node )

	PlayDraconisPA( "diag_sp_lifeBoats_STS412_01_01_neut_cpupa" )

	delaythread( 0.5 ) DraconisShake()
	delaythread( 0.6 ) FlagSet( "PlayerJumpsToLifeboats" )
}

void function LifeBoats_Skip( entity player )
{
	thread DestroyTheWorld()

	array<entity> pods = GetEntArrayByScriptName( "lifeboats_pods" )
	foreach ( pod in pods )
		pod.Destroy()

	GetEntByScriptName( "core_shell_piece" ).DisableHibernation()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	HideName( bt )

	entity coverLeft = GetEntByScriptName( "lightcoverLeft" )
	entity coverRight = GetEntByScriptName( "lightcoverRight" )
	coverLeft.DisableHibernation()
	coverRight.DisableHibernation()

	level.nv.ShipStreaming = SHIPSTREAMING_DEFAULT
}

void function LifeBoats_Main( entity player )
{
	AddSpawnCallback_ScriptName( "lifeboats_runner", LifeBoats_RunnerThink_Regular )
	AddSpawnCallback_ScriptName( "lifeboats_runner_0b", LifeBoats_RunnerThink_Special )
	AddSpawnCallback_ScriptName( "lifeboats_runner_2", LifeBoats_RunnerThink_Regular )

	FlagWait( "LifeboatStart" )

	level.nv.ShipStreaming = SHIPSTREAMING_DEFAULT

	Objective_SetSilent( "#S2S_OBJECTIVE_SECUREARK", <0,0,0>, GetEntByScriptName( "ark" ) )

	//EmitSoundOnEntity( GetEntByScriptName( "draconis_PA" ), "s2s_scr_lifeboats_alarm", 5.0 )
	EmitSoundOnEntity( file.player, "s2s_scr_lifeboats_alarm" )

	entity coverLeft = GetEntByScriptName( "lightcoverLeft" )
	entity coverRight = GetEntByScriptName( "lightcoverRight" )
	coverLeft.DisableHibernation()
	coverRight.DisableHibernation()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	HideName( bt )

	GetEntByScriptName( "core_shell_piece" ).DisableHibernation()

	LifeBoats_PodSetup()

	wait 0.1

	thread DestroyTheWorld()

	wait 0.3

	thread LifeBoats_SpawnRunners()
	thread LifeBoats_PA()

	delaythread( 0.9 ) LifeboatsMusic()

	wait 1.1

	thread Lifeboats_BtAnim( bt )

	wait 0.5

	float amplitude = 5
	float frequency = 200
	float duration = 1.0
	float radius = 2048
	entity shake = CreateShake( player.GetOrigin(), amplitude, frequency, duration, radius )
	EmitSoundOnEntity( player, "scr_s2s_player_land_on_crow" )

	player.UnforceStand()
	player.ForceCrouch()

	wait 2.2
	player.UnforceCrouch()
	player.ForceStand()
	wait 0.5

	player.UnforceStand()
	player.Anim_Stop()
	ClearPlayerAnimViewEntity( player )
	player.ClearParent()
	player.DeployWeapon()
	player.ClearAnimNearZ()
	bt.RenderWithViewModels( false )
	player.SetMoveSpeedScale( 0.7 )

	delaythread( 1.0 ) LifeBoats_HardBank()
	delaythread( 1.0 ) FlagSet( "endFX_Hallway1" )
	delaythread( 1.0 ) PlaySoundAtPos( < -10398.7, -1509.61, -12913.8 >, "stratton_bomb_explosions" )
	delaythread( 1.0 + 6 ) FlagClear( "endFX_Hallway1" )
	delaythread( 6.0 ) LifeBoats_HardBank()
	delaythread( 6.0 ) FlagSet( "endFX_Hallway2" )
	delaythread( 6.0 ) PlaySoundAtPos( < -10370.2, -450.409, -12853.2 >, "stratton_bomb_explosions" )
	delaythread( 6.0 + 6 ) FlagClear( "endFX_Hallway2" )
	delaythread( 10.5 ) LifeBoats_HardBank()
	delaythread( 10.5 ) FlagSet( "endFX_Hallway3" )
	delaythread( 10.5 ) PlaySoundAtPos( < -10164.5, 475.975, -12799.5 >, "stratton_bomb_explosions" )

	delaythread( 10.5 + 10 ) FlagClear( "endFX_Hallway3" )

	CleanupScript( "scr_ola_node_1" )
	CleanupScript( "scr_ola_node_2" )

	//We are approaching the Ark's containment unit.
	delaythread( 2.5 ) PlayBTDialogue( "diag_sp_lifeBoats_STS412_11_01_mcor_bt" )

	WaittillAnimDone( bt )
}

void function PlaySoundAtPos( vector pos, string snd )
{
	EmitSoundAtPosition( TEAM_ANY, pos, snd )
}

void function LifeboatsMusic()
{
	StopMusic()
	PlayMusic( "music_s2s_18_evac" )
}

void function LifeboatShake()
{
	float amplitude = 0.9
	float frequency = 200
	float duration = 3
	float radius = 2048

	entity shake = CreateAirShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )

	wait duration - 1.0

	amplitude = 2
	duration = 900

	shake = CreateAirShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )

	FlagWait( "PlayerJumpedIntoCore" )
	thread KillShake( shake )

	WaitFrame()

	amplitude = 1.5
	frequency = 200
	duration = 5
	radius = 2048

	shake = CreateAirShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )

	wait 4.5
	thread CoreRoomShake()
}

void function Lifeboats_BtAnim( entity bt )
{
	entity node = GetEntByScriptName( "core_bt_node" )

	bt.Anim_Stop()
	//bt.SetParent( node )
	bt.ClearParent()
	bt.RenderWithViewModels( true )
	thread PlayAnimTeleport( bt, "bt_s2s_sphere_land", node )
}

void function CreateCoreLightFX1()
{
	entity core = GetEntByScriptName( "ark" )
	int fxID = GetParticleSystemIndex( ARK_LIGHT_FX )
	file.coreGlowFX1 = StartParticleEffectOnEntityWithPos_ReturnEntity( core, fxID, FX_PATTACH_CUSTOMORIGIN_FOLLOW, -1, <0,0,0>, <0,0,0> )
}

void function LifeBoats_PodSetup()
{
	array<entity> pods = GetEntArrayByScriptName( "lifeboats_pods" )
	foreach ( pod in pods )
	{
		pod.Solid()
		pod.DisableHibernation()

		if ( pod.HasKey( "script_noteworthy" ) && pod.kv.script_noteworthy == "fakePod" )
		{
			entity fakeDude = pod.GetLinkEnt()
			if ( IsValid( fakeDude ) )
				fakeDude.DisableHibernation()

			thread LifeBoats_LaunchPod( pod )
		}
		else
		{
			int decalIndex = pod.FindBodyGroup( "decals" )
			pod.Anim_Play( "s2s_escape_pod_open" )
			pod.SetBodygroup( decalIndex, 1 )
			pod.SetSkin( 1 )
		}
	}
}

void function LifeBoats_HardBank()
{
	if ( Flag( "PlayerJumpedIntoCore" ) )
		return

//	if ( !file.player.IsOnGround() )
//		file.player.WaitSignal( "PME_TouchGround" )

	float amplitude = 20
	float frequency = 150
	float duration = 2.0
	float radius = 2048
	entity shake = CreateShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )
	//EmitSoundOnEntity( file.player, "scr_s2s_malta_ship_impact_01" )

	vector angles = <0,180,0>

	file.player.SetMoveSpeedScale( 0.8 )
	wait duration
	file.player.SetMoveSpeedScale( 0.9 )

	//thread PlayerStumbleThink( angles ) -> not until we fix the anim
}

void function LifeBoats_PA()
{
	wait 13

	float duration

	//Abandon ship. Altitude dropping. 9,000 meters.
	duration = PlayDraconisPA( "diag_sp_lifeBoats_STS411_01_01_neut_cpupa" )
}

float function PlayDraconisPA( string snd )
{
	if ( file.draconisPAsnd != "" )
	{
		if ( file.draconisPAsnd != snd )
			return 0
	}

	file.draconisPAsnd = snd

	float interval = 0.1
	float duration
	foreach ( index, ent in file.draconis_PA )
		duration = EmitSoundOnEntityAfterDelay( ent, snd, index * interval )

	duration += file.draconis_PA.len() * interval
	thread CleanupDraconisPA( duration )

	return duration
}

void function CleanupDraconisPA( float duration )
{
	wait duration
	file.draconisPAsnd = ""
}

void function DestroyTheWorld()
{
	switch( GetCurrentStartPoint() )
	{
		case "--------------":
		case "TestBed":
		case "Dropship Combat Test":
		case "LightEdit Connect":
		case "TRAILER bridge":
			//don't destroy the world
			return
			break
	}

	GetEntByScriptName( "GEO_CHUNK_HANGAR" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_HANGAR_FAKE" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_DECK" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_DECK_FAKE" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_BRIDGE" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_BACK" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_BACK_FAKE" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_EXTERIOR_ENGINE" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_EXTERIOR_L" ).Destroy()
	GetEntByScriptName( "GEO_CHUNK_EXTERIOR_R" ).Destroy()

	//amortize it
	wait 0.1
	GetEntByScriptName( "DRACONIS_CHUNK_LOWDEF" ).Destroy()
	GetEntByScriptName( "DRACONIS_CHUNK_HIGHDEF" ).Destroy()

	Ship_CleanDelete( file.malta )
	Ship_CleanDelete( file.OLA )
	Ship_CleanDelete( file.gibraltar )
	DisableScript( "scr_swidow_node_0" )
	Ship_CleanDelete( file.sarahWidow )

	FlagSet( "EndAirBattle" )
	FlagClear( "DriftWorldCenter" )
//	WORLD_CENTER.Destroy()

	file.sculptor.Destroy()
	file.airBattleNode.Destroy()
	file.rocketDummy[ TEAM_IMC ].Destroy()
	file.rocketDummy[ TEAM_MILITIA ].Destroy()

	foreach ( ship in file.dropships[ TEAM_IMC ] )
		Ship_CleanDelete( ship )

	//amortize it
	wait 0.1

	foreach ( ship in file.dropships[ TEAM_MILITIA ] )
		Ship_CleanDelete( ship )

	//amortize it
	wait 0.1

	FlagSet( "StopDynamicSky" )
	if ( IsValid( file.skyRig ) )
		file.skyRig.Destroy() //->this takes out like 30 ents

	//amortize it
	wait 0.1
}

void function Ship_CleanDelete( ShipStruct ship )
{
	if ( IsValid( ship.mover ) )
	{
		FakeDestroy( ship )
		if ( IsValid( ship.mover ) )
			ship.mover.Destroy()
	}
}

void function LifeBoats_SpawnRunners()
{
	array<entity> runners = GetEntArrayByScriptName( "lifeboats_runner" )
	foreach ( spawner in runners )
		delaythread( 0.5 ) SpawnFromSpawner( spawner )

	runners = GetEntArrayByScriptName( "lifeboats_runner_2" )
	foreach ( spawner in runners )
		delaythread( 1.0 ) SpawnFromSpawner( spawner )

	runners = GetEntArrayByScriptName( "lifeboats_runner_0b" )
	foreach ( spawner in runners )
		delaythread( 1.3 ) SpawnFromSpawner( spawner )
}

void function LifeBoats_RunnerThink_Special( entity guy )
{
	bool skipFirstRun = true
	LifeBoats_RunnerThink( guy, skipFirstRun )
}

void function LifeBoats_RunnerThink_Regular( entity guy )
{
	bool skipFirstRun = false
	LifeBoats_RunnerThink( guy, skipFirstRun )
}

void function LifeBoats_RunnerThink( entity guy, bool skipFirstRun )
{
	guy.EnableNPCFlag( NPC_IGNORE_ALL )
	guy.EnableNPCMoveFlag( NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_PREFER_SPRINT )
	guy.DisableHibernation()
	guy.SetEfficientMode( true )
	guy.SetMaxHealth( 25 )
	guy.SetHealth( 25 )

	guy.Signal( "StopAssaultMoveTarget" )
	file.player.EndSignal( "OnDestroy" )

	entity firstLink = guy.GetLinkEnt()
	entity link = firstLink
	string anim
	entity node
	entity pod
	float blendTime = 0.3
	bool disableArrival = true
	bool disableAssaultAngles = false

	if ( guy.HasKey( "script_noteworthy" ) && guy.kv.script_noteworthy == "lookback" )
		thread LifeBoats_RunnerLookback( guy )

	while( IsValid( link ) )
	{
		switch( link.GetClassName() )
		{
			//anim nodes
			case "info_target":
			{
				anim = expect string( link.kv.leveled_animation )
				if ( IsAlive( guy ) && guy.Anim_IsActive() )
					WaittillAnimDone( guy )

				switch( anim )
				{
					//time to get in the lifeboat
					case "pt_s2s_lifeboat_embark_R":
					case "pt_s2s_lifeboat_embark_L":
						if ( IsAlive( guy ) && link == firstLink )
							waitthread RunToAnimStartHACK( guy, anim, link, null, disableArrival, disableAssaultAngles )
						if ( IsAlive( guy )	)
						{
							node = CreateScriptMover( link.GetOrigin(), link.GetAngles() )

							guy.SetParent( node, "REF", false, blendTime )
							thread PlayAnim( guy, anim, node, "REF", blendTime )

							#if DEV
								while( GetBugReproNum() != 0 )
								{
									WaitFrame()
									thread PlayAnim( guy, anim, node, "REF", blendTime )
								}
							#endif
						}
						break

					default:
						if ( IsAlive( guy )	)
						{
							if ( ( link != firstLink ) || ( link == firstLink && !skipFirstRun ) )
								waitthread RunToAnimStartHACK( guy, anim, link, null, disableArrival, disableAssaultAngles )
						}

						if ( IsAlive( guy )	)
						{
							if ( link == firstLink && skipFirstRun )
								thread PlayAnimTeleport( guy, anim, link )
							else
								thread PlayAnim( guy, anim, link, null, blendTime )
						}
						break
				}

			}break

			//the pod
			case "script_mover_lightweight":
			case "script_mover":
			{
				pod = link
				if ( IsValid( node ) )
				{
					wait 0.5

					vector angles = pod.GetAngles()
					float y = node.GetAngles().y - angles.y
					angles = AnglesCompose( angles, <0,y,0> )

					float time = 1.0
					node.NonPhysicsRotateTo( angles, time, time * 0.5, time * 0.5 )
					wait time + 0.1

					node.SetParent( pod, "", true, 0 )
				}
			}
		}

		link = link.GetLinkEnt()
	}

	if ( IsAlive( guy )	)
		guy.SetInvulnerable()

	LifeBoats_LaunchPod( pod )
}

void function LifeBoats_LaunchPod( entity pod )
{
	Assert( IsValid( pod ) )

	if ( pod.HasKey( "start_delay" ) && float( pod.kv.start_delay ) > 0.0 )
		wait float( pod.kv.start_delay ) * 0.3

	float waitTime = 5

	float animDelay = 0.1
	float animTime 	= 0
	string anim 	= "s2s_escape_pod_close"


	wait animDelay
	if ( pod.Anim_HasSequence( anim ) )
	{
		pod.Anim_Play( anim )
		animTime = pod.GetSequenceDuration( anim ) + 0.1
	}

	wait animTime
	pod.SetModel( ESCAPE_POD_MODEL_CHEAP )

	//int fxLight = GetParticleSystemIndex( FX_LIFEBOAT_LIGHT )
	//int attachPoint = pod.LookupAttachment( "fx_window_int" )
	//StartParticleEffectOnEntity( pod, fxLight, FX_PATTACH_POINT_FOLLOW, attachPoint )
	StartParticleEffectOnEntity( pod, GetParticleSystemIndex( FX_LIFEBOAT_LIGHT ), FX_PATTACH_POINT_FOLLOW, pod.LookupAttachment( "fx_window_int" ) )

	float clankTime = 1.5
	float delay = 0.5
	wait waitTime - animTime - animDelay - clankTime - delay

	EmitSoundOnEntity( pod, "scr_s2s_single_lifeboat_eject" )

	pod.NonPhysicsMoveTo( pod.GetOrigin() + pod.GetUpVector() * 30, clankTime, 0.25, 0.25 )
	wait clankTime
	wait delay

	float time = 1.25
	pod.NonPhysicsMoveTo( pod.GetOrigin() + pod.GetUpVector() * -1000, time, 0, 0 )
	StartParticleEffectOnEntity( pod, GetParticleSystemIndex( FX_LIFEBOAT_LAUNCH ), FX_PATTACH_POINT, pod.LookupAttachment( "fx_launch" ) )

	wait time
	pod.Destroy()
}

void function LifeBoats_RunnerLookback( entity guy )
{
	guy.EndSignal( "OnDeath" )

	wait 0.5
	//Watch out! There's a Titan!
	delaythread( 0.5 ) PlayGabbyDialogue( "diag_sp_lifeBoats_STS472_01_01_imc_grunt3", guy, "face_generic_talker_emotion" )
	//Lifeboats! Everyone get to their lifeboat!!
	delaythread( 2.0 ) PlayDialogue( "diag_sp_lifeBoats_STS474_01_01_imc_grunt5", guy )

	wait 5.0

	if ( guy.IsInterruptable() )
		guy.Anim_ScriptedPlay( "CQB_react_behind_running" )
}

/************************************************************************************************\

 ██████╗ ██████╗ ██████╗ ███████╗    ██████╗  ██████╗  ██████╗ ███╗   ███╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝    ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║
██║     ██║   ██║██████╔╝█████╗      ██████╔╝██║   ██║██║   ██║██╔████╔██║
██║     ██║   ██║██╔══██╗██╔══╝      ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║
╚██████╗╚██████╔╝██║  ██║███████╗    ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝

\************************************************************************************************/
void function CoreRoom_Setup( entity player )
{
	PlayerSetStartPoint( player, GetEntByScriptName( "coreRoomPlayerStart" ), <0,-500,0> )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	entity node = GetEntByScriptName( "core_bt_node" )
	table animStartPos = bt.Anim_GetStartForRefPoint_Old( "bt_s2s_sphere_start", node.GetOrigin(), node.GetAngles() )
	vector startPos = expect vector( animStartPos.origin )

	bt.SetOrigin( startPos )
	delaythread( 0.5 ) LifeboatShake()

	wait 1.0
}

void function CoreRoom_Skip( entity player )
{
	bool teleport = true
	entity node = GetEntByScriptName( "core_bt_node" )
	entity piece = GetEntByScriptName( "core_shell_piece" )
	thread PlayAnim( piece, "torn_piece_s2s_sphere_start", node )
	piece.Anim_SetInitialTime( 14 )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	player.DisableWeapon()
	player.ForceStand()
	player.SetInvulnerable()

	entity core = GetEntByScriptName( "ark" )
	thread CoreRoom_ArkScreenStaticAndRumble( player, core )

	PlayerGetMainWeapons( player )
	TakeAllWeapons( player )
	Ending_TurnOnLight()

	FlagSet( "endFX_Core1" )
	FlagSet( "endFX_Core6" )
}

void function CoreRoom_Main( entity player )
{
	FlagEnd( "EndingFailed" )

	CheckPoint_Silent()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	thread CoreRoom_PA()
	thread CoreRoom_VO( bt )

	//animate bt to tear open the shield
	entity node = GetEntByScriptName( "core_bt_node" )
	entity piece = GetEntByScriptName( "core_shell_piece" )

	delaythread( 7.2 ) Ending_TurnOnLight()
	entity core = GetEntByScriptName( "ark" )
	delaythread( 7.2 ) CoreRoom_ArkScreenStaticAndRumble( player, core )
	delaythread( 5.0 ) CoreRoomFx()

	bt.SetNextThinkNow()
	piece.SetNextThinkNow()
	thread PlayAnimTeleport( piece, "torn_piece_s2s_sphere_start", node )

	EmitSoundOnEntityAfterDelay( GetEntByScriptName( "ark" ), "scr_s2s_draconis_sphere_ambient_loop", 7.3 )

	waitthread PlayAnim( bt, "bt_s2s_sphere_start", node )

	thread PlayAnim( bt, "bt_s2s_sphere_hand_idle", node )

	//enable the jump trigger
	int attachID = bt.LookupAttachment( "FASTBALL_R" )
	while( Distance( player.GetOrigin(), bt.GetAttachmentOrigin( attachID ) ) > 150 )
		WaitFrame()

	FlagSet( "PlayerJumpedIntoCore" )

	player.DisableWeaponWithSlowHolster()
	player.ForceStand()
	player.SetInvulnerable()
	player.SetAnimNearZ( 4 )
	PlayerGetMainWeapons( player )
	TakeAllWeapons( player )

	string anim3rd = "pt_s2s_sphere_insert_start1"
	string animPOV = "ptpov_s2s_sphere_insert_start1"
	float blendTime = 0.5

	entity pNode = CreateScriptMover( node.GetOrigin(), node.GetAngles() )
	//player.SetParent( pNode, "REF", false, blendTime )
	//waitthread PlayFPSAnimShowProxy( player, anim3rd, animPOV, pNode, "REF", ViewConeZero, blendTime )
	FirstPersonSequenceStruct sequence
	sequence.firstPersonAnim	= animPOV
	sequence.thirdPersonAnim 	= anim3rd
	sequence.attachment 		= "REF"
	sequence.viewConeFunction	= ViewConeZero
	sequence.teleport			= false
	sequence.hideProxy			= false

	thread CoreRoom_BT_AcceptArk( bt, node )
	waitthread FirstPersonSequence( sequence, player, pNode )

	thread CoreRoom_ForwardHint( core )

	anim3rd = "pt_s2s_sphere_insert_start2"
	animPOV = "ptpov_s2s_sphere_insert_start2"
	waitthread CoreRoom_PushCoreAnim( player, anim3rd, animPOV, pNode, "CoreRoomPlayerPressedForward", "pt_s2s_sphere_insert_start2" )

	//Quickly - we need to move the Ark. We are running out of time. (ALT - Quickly - we need to get off the ship. We are running out of time.)
	thread PlayBTDialogue( "diag_sp_olaCrash_STS426_13_01_mcor_bt" )
	core.SetParent( player.GetFirstPersonProxy(), "PROPGUN", false, 0 )

	FlagClear( "endFX_Core4" )
	FlagClear( "CoreRoomPlayerPressedForward" )
	thread CoreRoom_ForwardHint( core )

	anim3rd = "pt_s2s_sphere_insert_push_1"
	animPOV = "ptpov_s2s_sphere_insert_push_1"
	waitthread CoreRoom_PushCoreAnim( player, anim3rd, animPOV, pNode, "CoreRoomPlayerPressedForward", "scr_s2s_draconis_push_sphere_start" )

	anim3rd = "pt_s2s_sphere_insert_push_2"
	animPOV = "ptpov_s2s_sphere_insert_push_2"
	waitthread CoreRoom_PushCoreAnim( player, anim3rd, animPOV, pNode, "", "scr_s2s_draconis_push_sphere_start" )

	anim3rd = "pt_s2s_sphere_insert_push_3"
	animPOV = "ptpov_s2s_sphere_insert_push_3"
	thread CoreRoom_PushCoreAnim( player, anim3rd, animPOV, pNode, "CoreRoomFinalPush", "scr_s2s_draconis_push_sphere_start" )

	FlagWait( "CoreRoomFinalPush" )
	thread Ending_TurnOffLight()

	WaittillAnimDone( player )
}

void function CoreRoom_ArkScreenStaticAndRumble( entity player, entity ark )
{
	player.EndSignal( "OnDeath" )
	ark.EndSignal( "OnDestroy" )

	float rumbleAmp 		= 5.0
	float rumbleFreq 		= 50.0
	float rumbleDuration 	= 1.0
	float nextRumbleTime = Time()

	while( true )
	{
		float dist = Distance( ark.GetOrigin(), player.GetOrigin() )
		float amount = GraphCapped( dist, 0.0, 128, 1.0, 0.0 )

		if ( amount > 0 )
		{
			StatusEffect_AddTimed( player, eStatusEffect.emp, amount, 0.25, 0.05 )

			if ( nextRumbleTime <= Time() )
			{
				entity rumbleHandle = CreateAirShakeRumbleOnly( ark.GetOrigin(), rumbleAmp, rumbleFreq, rumbleDuration )
				rumbleHandle.SetParent( ark, "", false )

				nextRumbleTime = Time() + (rumbleDuration * 0.4)
			}
		}

		wait 0.1
	}
}

void function CoreRoomFx()
{
	FlagEnd( "PlayerJumpedIntoCore" )

	while( 1 )
	{
		delaythread( 0.5 ) FlagSet( "endFX_Core1" ) //jets lefft
		delaythread( 0.5 ) PlaySoundAtPos( < -10415, 1024.8, -12754.7 >, "stratton_bomb_explosions" )
		delaythread( 0.5 ) LifeBoats_HardBank()

		delaythread( 4.0 ) FlagSet( "endFX_Core2" ) //right
		delaythread( 4.0 ) PlaySoundAtPos( < -9975.69, 1253.45, -12804.7 >, "stratton_bomb_explosions" )
		delaythread( 4.0 ) LifeBoats_HardBank()

		delaythread( 9.0 ) FlagSet( "endFX_Core3" ) //bottom
		delaythread( 9.0 ) PlaySoundAtPos( < -10205, 884.081, -12799.9 >, "stratton_bomb_explosions" )
		delaythread( 9.0 ) LifeBoats_HardBank()

		delaythread( 10.0 ) FlagSet( "endFX_Core4" ) //jets right
		delaythread( 10.0 ) PlaySoundAtPos( < -10139.3, 1279.28, -12762.9 >, "stratton_bomb_explosions" )
		delaythread( 10.0 ) LifeBoats_HardBank()

		delaythread( 14.0 ) FlagSet( "endFX_Core5" ) //left
		delaythread( 14.0 ) PlaySoundAtPos( < -10500.3, 1114.91, -12806.1 >, "stratton_bomb_explosions" )
		delaythread( 14.0 ) LifeBoats_HardBank()

		delaythread( 19.0 ) FlagSet( "endFX_Core6" ) //jets stair left
		delaythread( 14.0 ) PlaySoundAtPos( < -10437.2, 1207.88, -13056 >, "stratton_bomb_explosions" )

		delaythread( 19.0 ) LifeBoats_HardBank()

		wait 25
		FlagClear( "endFX_Core1" )
		FlagClear( "endFX_Core2" )
		FlagClear( "endFX_Core3" )
		delaythread( 9 ) FlagClear( "endFX_Core4" )
		FlagClear( "endFX_Core5" )
		delaythread( 18 ) FlagClear( "endFX_Core6" )
	}
}

void function CoreRoom_VO( entity bt )
{
	//The containment unit is too large to carry. We must improvise.
	thread PlayBTDialogue( "diag_sp_lifeBoats_STS422_11_01_mcor_bt" )

	wait 15.5
	//I cannot reach the Ark. Cooper, I need your help.
	waitthreadsolo PlayBTDialogue( "diag_sp_olaCrash_STS426_11_01_mcor_bt" )
	thread HintConvo( "s2s_Hint_CoreRoom", "PlayerJumpedIntoCore", 10 )
}

void function CoreRoom_ForwardHint( entity core )
{
	FlagEnd( "CoreRoomPlayerPressedForward" )

	wait 3.5

	entity model = CreatePropDynamic( CORE_USE_MODEL, core.GetOrigin() + <0,0,-24>, <0,0,0>, 6 )

	OnThreadEnd(
	function() : ( model )
		{
			model.Destroy()
		}
	)

	model.Hide()
	model.SetUsable()
	model.SetUsableByGroup( "pilot" )
	model.SetUsePrompts( "#FORWARD_CONSOLE" , "#FORWARD_PC" )
	model.AddUsableValue( USABLE_NO_FOV_REQUIREMENTS )
	model.SetUsableRadius( 1024 )
	model.SetUsePromptSize( 64.0 )

	FlagWait( "CoreRoomPlayerPressedForward" )
}

void function CoreRoom_BT_AcceptArk( entity bt, entity node )
{
	//waitthread PlayAnim( bt, "bt_s2s_sphere_middle", node )
	waitthread PlayAnim( bt, "bt_s2s_sphere_player_enter", node )
	thread PlayAnim( bt, "bt_s2s_sphere_chest_idle", node )
}

void function CoreRoom_PushCoreAnim( entity player, string anim3rd, string animPOV, entity pNode, string _flag = "", string _snd = "" )
{
	float threshold = 0.2

	if ( player.GetInputAxisForward() < threshold )
	{

		thread PlayFPSAnimShowProxy( player, anim3rd + "_idle", animPOV + "_idle", pNode, "REF", ViewConeTight, 0 )

		while( player.GetInputAxisForward() < threshold )
			WaitFrame()
	}

	if ( _flag != "" )
		FlagSet( _flag )

	if ( _snd != "" )
		EmitSoundOnEntity( player, _snd )

	waitthread PlayFPSAnimShowProxy( player, anim3rd, animPOV, pNode, "REF", ViewConeTight, 0 )
}

void function CoreRoom_PA()
{
	FlagEnd( "CoreRoomFinalPush" )

	OnThreadEnd(
	function() : (  )
		{
			//The ship will impact in 15 seconds.
			//PlayDraconisPA( "diag_sp_olaCrash_STS445_01_01_neut_cpupa" )
		}
	)

	float duration

	wait 10.0

	//Abandon ship. Please walk do not run to the nearest escape pod.
	duration = PlayDraconisPA( "diag_sp_lifeBoats_STS412_01_01_neut_cpupa" )
	wait 15

	//Abandon ship. Altitude dropping. 6,000 meters.
	duration = PlayDraconisPA( "diag_sp_lifeBoats_STS422_01_01_neut_cpupa" )
	wait 15

	//Abandon ship. Altitude dropping. 3,000 meters.
	duration = PlayDraconisPA( "diag_sp_olaCrash_STS426_01_01_neut_cpupa" )
	wait 15

	//Abandon ship. Altitude dropping. 1,000 meters.
	duration = PlayDraconisPA( "diag_sp_olaCrash_STS429_01_01_neut_cpupa" )
	wait 15

	#if DEV
		if ( GetBugReproNum() != 0 )
			return
	#endif

	FlagSet( "EndingFailed" )
	bool failed = true
	EmitSoundOnEntity( file.player, "scr_s2s_draconis_final_explosion_pt_01" )
	thread Ending_CrashFX( failed )

	wait 2.1

	file.player.ClearParent()
	file.player.Anim_Stop()
	file.player.Signal( "ScriptAnimStop" )
	ClearPlayerAnimViewEntity( file.player )
	file.player.FreezeControlsOnServer()

	StopSoundOnEntity( file.player, "scr_s2s_draconis_push_sphere_start" )
	StopSoundOnEntity( file.player, "s2s_scr_lifeboats_alarm" )
	file.player.SetOrigin( GetEntByScriptName( "lifeboats_landNode_2" ).GetOrigin() )
}

void function CoreRoomShake()
{
	float amplitude = 0.2
	float frequency = 200
	float duration = 900
	float radius = 2048

	entity shake = CreateAirShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )

	FlagWait( "KillCoreShake" )
	thread KillShake( shake )
}

/************************************************************************************************\

███████╗███╗   ██╗██████╗ ██╗███╗   ██╗ ██████╗
██╔════╝████╗  ██║██╔══██╗██║████╗  ██║██╔════╝
█████╗  ██╔██╗ ██║██║  ██║██║██╔██╗ ██║██║  ███╗
██╔══╝  ██║╚██╗██║██║  ██║██║██║╚██╗██║██║   ██║
███████╗██║ ╚████║██████╔╝██║██║ ╚████║╚██████╔╝
╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝

\************************************************************************************************/
void function Ending_Setup( entity player )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	entity node = GetEntByScriptName( "core_bt_node" )
	entity pNode = CreateScriptMover( node.GetOrigin(), node.GetAngles() )

	thread PlayAnimTeleport( bt, "bt_s2s_sphere_chest_idle", node )
	string anim3rd = "pt_s2s_sphere_insert_push_3"
	string animPOV = "ptpov_s2s_sphere_insert_push_3"
	player.SetParent( pNode, "REF" )
	entity core = GetEntByScriptName( "ark" )
	core.DisableHibernation()
	core.SetParent( player.GetFirstPersonProxy(), "PROPGUN", false, 0 )

	delaythread( 0.5 ) CoreRoomShake()

	thread Ending_TurnOffLight()
	EmitSoundOnEntity( player, "scr_s2s_draconis_push_sphere_start" )
	waitthread PlayFPSAnimTeleportShowProxy( player, anim3rd, animPOV, pNode, "REF", ViewConeTight )

	EmitSoundOnEntityAfterDelay( GetEntByScriptName( "ark" ), "scr_s2s_draconis_sphere_ambient_loop", 1.0 )
}

void function Ending_Main( entity player )
{
	FlagInit( "CRASH" )
	FlagWaitClear( "EndingFailed" )

	//Altitude - Altitude - Altitude.
	thread PlayDraconisPA( "diag_sp_olaCrash_STS428_11_01_imc_cpupa" )

	entity pNode = player.GetParent()
	entity core = GetEntByScriptName( "ark" )
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	string anim3rd = "pt_s2s_sphere_insert_push_end"
	string animPOV = "ptpov_s2s_sphere_insert_push_end"

	file.coreGlowFX1.Destroy()

	core.SetParent( bt, "hijack", true, 0 )
	EntFireByHandle( core, "Kill", "", 1.9, null, null )

	UnlockAchievement( file.player, achievements.SECURE_ARK )

	//This way Coo<per>
	delaythread( 2.0 ) PlayBTDialogue( "diag_sp_olaCrash_STS426_14_01_mcor_bt" )

	thread PlayAnim( bt, "bt_s2s_sphere_end", pNode, "REF" )
	waitthread PlayFPSAnimTeleportShowProxy( player, anim3rd, animPOV, pNode, "REF", ViewConeTight )

	FlagSet( "KillCoreShake" )
	delaythread( 0.1 ) EndingShake()

	ReturnMainWeapons( player, file.loadout )

	player.ClearParent()
	player.UnforceStand()
	player.Anim_Stop()
	player.Signal( "ScriptAnimStop" )
	player.Signal( "FlightPanelAnimEnd" )
	ClearPlayerAnimViewEntity( player )
	player.DeployWeapon()
	player.SetMoveSpeedScale( 1.0 )
	player.ClearAnimNearZ()

	FlagClear( "PlayerJumpedIntoCore" )

	delaythread( 1.9 ) FlagSet( "exitFX1" )

	wait 2
	thread ExitExplosionLoop()
	StopMusic()
	PlayMusic( "music_s2s_19_btshut" )
	waitthread HackKnockback( bt, player, pNode )

	thread Ending_VO( bt )

	entity piece = GetEntByScriptName( "core_shell_piece" )
	bt.Anim_AdvanceCycleEveryFrame( true )
	bt.SetNextThinkNow()
	piece.SetNextThinkNow()

	thread PlayAnimTeleport( piece, "torn_piece_s2s_sphere_player_protect", pNode, "REF" )
	thread PlayAnimTeleport( bt, "bt_s2s_sphere_player_protect", pNode, "REF" )

	FirstPersonSequenceStruct sequence
	sequence.firstPersonAnim	= "ptpov_s2s_sphere_player_protect"
	sequence.thirdPersonAnim 	= "pt_s2s_sphere_player_protect"
	sequence.attachment 		= "REF"
	sequence.viewConeFunction	= ViewConeSmall
	sequence.teleport			= false
	sequence.hideProxy			= false

	thread FirstPersonSequence( sequence, player, pNode )

	WaittillAnimDone( bt )
	thread PlayAnim( bt, "bt_s2s_sphere_player_protect_idle", pNode, "REF" )
	thread PlayAnim( piece, "torn_piece_s2s_sphere_player_protect_idle", pNode, "REF" )

	anim3rd = "pt_s2s_sphere_player_protect_idle"
	animPOV = "ptpov_s2s_sphere_player_protect_idle"
	thread PlayFPSAnimTeleportShowProxy( player, anim3rd, animPOV, pNode, "REF", ViewConeSmall )

	FlagWait( "CRASH" )

	Ending_CrashFX()
}

void function ExitExplosionLoop()
{
	while (1)
	{
		FlagSet( "exploop" )

		wait 2

		FlagClear( "exploop" )

		wait RandomFloatRange( 0.1, 1 )
	}
}

void function HackKnockback( entity bt, entity player, entity pNode )
{
	EmitSoundOnEntity( player, "scr_s2s_draconis_final_explosion_pt_01" )

	player.DisableWeapon()
	TakeAllWeapons( player )
	player.ForceStand()
	player.SetAnimNearZ( 4 )

	float blendTime = 1.0
	entity land = GetEntByScriptName( "endKnockback" )
	player.SetParent( land, "REF", false, blendTime )
	thread PlayFPSAnimShowProxy( player, "pt_s2s_end_fight_knockback_02", "ptpov_s2s_end_fight_knockback_02", land, "REF", ViewConeSmall, 0.0 )
	thread HackKnockbackView( player )

	HurtPlayer( player, 0.6 )

	wait 0.2
	bt.SetAngles( <0,-110,0> )
	bt.SetOrigin( bt.GetOrigin() + <0,0,32> )
	bt.Anim_ScriptedPlay( "bt_s2s_ending_knockback" )

	wait 0.1
	Remote_CallFunction_NonReplay( file.player, "ServerCallback_s2sBossFightBlur" )

	wait 1.2
	player.ClearParent()

	FirstPersonSequenceStruct sequence
	sequence.firstPersonAnim	= "ptpov_s2s_sphere_player_protect"
	sequence.thirdPersonAnim 	= "pt_s2s_sphere_player_protect"
	sequence.attachment 		= "REF"
	sequence.viewConeFunction	= ViewConeSmall
	sequence.teleport			= false
	sequence.hideProxy			= false

	//thread FirstPersonSequence( sequence, player, pNode )
	// foreach( entity p in GetPlayerArray() )
	thread PlayFPSAnimShowProxy( player, "pt_s2s_sphere_player_protect", "ptpov_s2s_sphere_player_protect", pNode, "REF", ViewConeSmall, 0.0 )

	entity node = GetEntByScriptName( "endBtGetup" )
	thread PlayAnimTeleport( bt, "bt_s2s_fall_to_kneel", node, null, 0.9 )

	float duration = bt.GetSequenceDuration( "bt_s2s_fall_to_kneel" ) - 0.9 - 0.9

	wait duration - 0.2

	float hold = 0.4
	Remote_CallFunction_NonReplay( file.player, "ServerCallback_s2sBossFightBlur", hold )

	wait 1.2 + hold
}

void function HackKnockbackView( entity player )
{
	for ( int i = 0; i < 3; i++ )
	{
		player.SetLocalAngles( < 0, 25, 0 > )
		wait 0.1
	}
}

void function Ending_CrashFX( bool failed = false )
{
	FlagClear( "SaveGame_Enabled" )

	FlagSet( "crashFX1" )
	HurtPlayer( file.player, 0.7 )

	entity bt = file.player.GetPetTitan()
	Assert( IsValid( bt ) )

	Remote_CallFunction_NonReplay( file.player, "ServerCallback_s2sCrash" )

	float amplitude = 5
	float frequency = 400
	float duration = 5
	float radius = 2048
	entity shake = CreateAirShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )

	wait 2.1

	FlagSet( "CutToBlack" )
	StopMusic()
	StopSoundOnEntity( file.player, "scr_s2s_draconis_final_explosion_pt_01" )
	StopSoundOnEntity( file.player, "s2s_scr_lifeboats_alarm" )
	thread KillShake( shake )

	ScreenFade( file.player, 0, 0, 1, 255, 0, 0, FFADE_OUT | FFADE_STAYOUT )

	float time = 4

	if ( failed )
	{
		wait time - 3.8 //reload takes 3.8
		ReloadForMissionFailure()
	}

	wait 1

	MuteAll( file.player, 4 )
	wait time + 0.3
}

void function Ending_VO( entity bt )
{
	//Altitude - Altitude - Altitude.
	thread PlayDraconisPA( "diag_sp_olaCrash_STS428_11_01_imc_cpupa" )

	wait 2.0

	waitthread PlayerConversation( "s2s_Ending", file.player, bt )

	//I will not lose another Pilot.
	thread PlayBTDialogue( "diag_sp_olaCrash_STS454_16_01_mcor_bt" )
	//Altitude - Altitude - Altitude.
	delaythread( 1.2 ) PlayDraconisPA( "diag_sp_olaCrash_STS428_11_01_imc_cpupa" )
	//Brace for impact.
	delaythread( 3.5 ) PlayBTDialogue( "diag_sp_olaCrash_STS454_17_01_mcor_bt" )

	EmitSoundOnEntity( file.player, "scr_s2s_draconis_final_explosion_pt_02" )

	wait 6.0

	FlagSet( "CRASH" )
}

void function Ending_TurnOffLight()
{
	//cover the light in time with BT closing the hatch.
	float delta = 16
	entity coverLeft = GetEntByScriptName( "lightcoverLeft" )
	entity coverRight = GetEntByScriptName( "lightcoverRight" )
	coverLeft.DisableHibernation()
	coverRight.DisableHibernation()
	coverLeft.SetOrigin( coverLeft.GetOrigin() + < LIGHTCOVERDELTA - delta,0,0> )
	coverRight.SetOrigin( coverRight.GetOrigin() + < -LIGHTCOVERDELTA + delta,0,0> )

	wait 3.5
	float time = 0.5
	coverLeft.Show()
	coverRight.Show()
	coverLeft.NonPhysicsMoveTo( coverLeft.GetOrigin() + <delta,0,0>, time, 0, 0 )
	coverRight.NonPhysicsMoveTo( coverRight.GetOrigin() + < -delta,0,0>, time, 0, 0 )
}

void function Ending_TurnOnLight()
{
	entity coverLeft = GetEntByScriptName( "lightcoverLeft" )
	entity coverRight = GetEntByScriptName( "lightcoverRight" )

	coverLeft.SetOrigin( coverLeft.GetOrigin() + < -LIGHTCOVERDELTA,0,0> )
	coverRight.SetOrigin( coverRight.GetOrigin() + < LIGHTCOVERDELTA,0,0> )

	CreateCoreLightFX1()
}

void function EndingShake()
{
	float amplitude = 1.0
	float frequency = 200
	float duration = 900 //15 min
	float radius = 2048

	entity shake = CreateAirShake( file.player.GetOrigin(), amplitude, frequency, duration, radius )
	shake.SetParent( file.player )

	FlagWait( "CutToBlack" )
	thread KillShake( shake )
}

/************************************************************************************************\

███████╗██╗  ██╗██╗   ██╗██████╗  ██████╗ ██╗  ██╗
██╔════╝██║ ██╔╝╚██╗ ██╔╝██╔══██╗██╔═══██╗╚██╗██╔╝
███████╗█████╔╝  ╚████╔╝ ██████╔╝██║   ██║ ╚███╔╝
╚════██║██╔═██╗   ╚██╔╝  ██╔══██╗██║   ██║ ██╔██╗
███████║██║  ██╗   ██║   ██████╔╝╚██████╔╝██╔╝ ██╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═════╝  ╚═════╝ ╚═╝  ╚═╝

\************************************************************************************************/
//setpos -1155.452637 -1086.113159 -14938.269531
const int MAXLANDTAGS = 8
void function SkyAnimatePart1()
{
	//wait 0.1
	entity skyRig 	= CreateSkyRig()
	//thread PlayAnimTeleport( skyRig, "vs_canyon_run_loop" )
	skyRig.Anim_Play( "vs_canyon_run_loop" )
	array<SkyBoxLandSection> landModels = Sky_CreateInitialLandScape( skyRig )
	thread DynamicSkyThink( skyRig , landModels )

	#if DEV
		if ( DEV_DRAWSKYRIG )
			thread DEV_DrawSkyRig( skyRig, landModels )
	#endif
}

void function Sky_InitData()
{
	//create a tree of options that tell the script what next piece we can go too
	file.landTree[ "center" ] 	<- {}
	file.landTree[ "left" ] 	<- {}
	file.landTree[ "right" ] 	<- {}

	file.landTree[ "center" ][ SE_LAND_A ] 		<- [ SE_LAND_A, SE_LAND_AB ]
	file.landTree[ "center" ][ SE_LAND_B ] 		<- [ SE_LAND_B, SE_LAND_BA ]
	file.landTree[ "center" ][ SE_LAND_AB ] 	<- [ SE_LAND_B ]
	file.landTree[ "center" ][ SE_LAND_BA ] 	<- [ SE_LAND_A ]
	file.landTree[ "left" ][ SE_VISTA_A1 ] 		<- [ SE_VISTA_A2 ]
	file.landTree[ "left" ][ SE_VISTA_A2 ] 		<- [ SE_VISTA_A3 ]
	file.landTree[ "left" ][ SE_VISTA_A3 ] 		<- [ SE_VISTA_A4 ]
	file.landTree[ "left" ][ SE_VISTA_A4 ] 		<- [ SE_VISTA_A1 ]
	file.landTree[ "right" ][ SE_VISTA_B1 ] 	<- [ SE_VISTA_B2 ]
	file.landTree[ "right" ][ SE_VISTA_B2 ] 	<- [ SE_VISTA_B3 ]
	file.landTree[ "right" ][ SE_VISTA_B3 ] 	<- [ SE_VISTA_B4 ]
	file.landTree[ "right" ][ SE_VISTA_B4 ] 	<- [ SE_VISTA_B1 ]
}

void function DynamicSkyThink( entity skyRig, array<SkyBoxLandSection> landModels )
{
	if ( Flag( "StopDynamicSky" ) )
		return
	FlagEnd( "StopDynamicSky" )
	//the last one is the first one
	int prevLandTag = 0

	//bring in new land pieces
	while( 1 )
	{
		skyRig.WaitSignal( "landpop" )
		int nextLandTag = Sky_PrepareNextLandPiece( prevLandTag, landModels, skyRig )
		prevLandTag = nextLandTag

		#if DEV
			if ( DEV_DRAWSKYRIG && GetMoDevState() )
				DebugDrawText( skyRig.GetOrigin() + < 500,1500,200 >, "Last Land Tag: " + ( prevLandTag + 1 ), true, 8.0 )
		#endif
	}
}

int function Sky_PrepareNextLandPiece( int prevLandTag, array<SkyBoxLandSection> landModels, entity skyRig )
{
	int nextLandTag = Sky_GetNextLandTag( prevLandTag )
	SkyBoxLandSection nextLandSection = landModels[ nextLandTag ]
	SkyBoxLandSection prevLandSection = landModels[ prevLandTag ]

	//destroy the extras that were on it
	if ( nextLandSection.extras.len() )
	{
		foreach( element in nextLandSection.extras )
			element.Destroy()
		nextLandSection.extras = []
	}

	//prepare a new land piece
	foreach ( lane, landModel in nextLandSection.lane )
	{
		asset prevLandAsset = prevLandSection.lane[ lane ].GetModelName()
		asset nextLandAsset = file.landTree[ lane ][ prevLandAsset ].getrandom()
		nextLandSection.lane[ lane ].SetModel( nextLandAsset )
	}

	//options for extras

	//always have clouds
	array<asset> cloudModels = [ SE_CLOUDS_A, SE_CLOUDS_B, SE_CLOUDS_C ]
	entity clouds = CreatePropDynamic( cloudModels.getrandom() )
	string tagIndex = "LAND_" + ( nextLandTag + 1 )
	clouds.SetParent( skyRig, tagIndex, false, 0 )
	nextLandSection.extras.append( clouds )

	return nextLandTag
}

int function Sky_GetNextLandTag( int prevLandTag )
{
	int nextLandTag = prevLandTag - 1
	if ( nextLandTag < 0 )
		nextLandTag = MAXLANDTAGS - 1

	return nextLandTag
}

entity function CreateSkyRig()
{
	entity skycam = GetEnt( "skybox_cam_level" )
	skycam.DisableHibernation()

	entity skyRig = CreateExpensiveScriptMoverModel( RIG_LAND_SKYBOX, skycam.GetOrigin(), CONVOYDIR )
	skyRig.DisableHibernation()

	skyRig.EnableDebugBrokenInterpolation()

	file.skyRig = skyRig

	return skyRig
}

array<SkyBoxLandSection> function Sky_CreateInitialLandScape( entity skyRig )
{
	array<SkyBoxLandSection> landModels = []

	for ( int i = 0; i < MAXLANDTAGS; i++ )
	{
		string tagIndex = "LAND_" + ( i + 1 )
		SkyBoxLandSection landSection
		entity model

		model = CreatePropDynamic( SE_LAND_A )
		model.SetParent( skyRig, tagIndex, false, 0 )
		landSection.lane[ "center" ] <- model

		model = CreatePropDynamic( SE_VISTA_A1 )
		model.SetParent( skyRig, tagIndex, false, 0 )
		landSection.lane[ "left" ] <- model

		model = CreatePropDynamic( SE_VISTA_B2 )
		model.SetParent( skyRig, tagIndex, false, 0 )
		landSection.lane[ "right" ] <- model

		landModels.append( landSection )
	}

	//once it's built, randomize it using the regular path
	for ( int prevLandTag = MAXLANDTAGS-1; prevLandTag >= 0; prevLandTag-- )
		Sky_PrepareNextLandPiece( prevLandTag, landModels, skyRig )

	return landModels
}

const float DRIFT_WORLD_CENTER_MAXSPEED = 100
const float DRIFT_WORLD_CENTER_ACC 		= 10
void function DriftWorldCenterWithPlayer( entity player )
{
	player.EndSignal( "OnDestroy" )

	DriftWorldSettingsReset()

	while( 1 )
	{
		FlagWait( "DriftWorldCenter" )
		thread DriftWorldCenterWithPlayerThread( player )

		FlagWaitClear( "DriftWorldCenter" )
		WORLD_CENTER.NonPhysicsStop()
	}
}

void function DriftWorldSettingsReset()
{
	file.driftWC_MaxSpeed 	= DRIFT_WORLD_CENTER_MAXSPEED
	file.driftWC_MaxAcc 	= DRIFT_WORLD_CENTER_ACC
	file.worldCenterLeadDist = DEF_WORLDCENTERLEADDIST
}

void function DriftWorldCenterWithPlayerThread( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagClearEnd( "DriftWorldCenter" )

	float currSpeed = 0
	vector moveVec = AnglesToForward( -CONVOYDIR )

	//these are the bounds that control how close the player gets to the sculptor
	float sculptorStartY = 6500
	float sculptorEndY 	= 2000
	float sculptorStartZ = file.sculptor.GetOrigin().z - 100
	float sculptorEndZ 	= file.sculptor.GetOrigin().z
	float worldStart 	= -10000
	float worldEnd  	= -45000

	float sculptorX 	= file.sculptor.GetOrigin().x
	file.sculptor.DisableHibernation()

	while( 1 )
	{
		float distToGoal 	= max( 0, player.GetOrigin().y + file.worldCenterLeadDist )

		//do we need to slow down?
		float decelerateDist = pow( currSpeed, 2 ) / ( 2 * file.driftWC_MaxAcc )
		if ( distToGoal < decelerateDist )
		{
			currSpeed = max( 0, currSpeed - file.driftWC_MaxAcc * FRAME_INTERVAL )
		}
		else
		{
			float maxDesiredSpeed = distToGoal / FRAME_INTERVAL
			currSpeed = min( currSpeed + file.driftWC_MaxAcc * FRAME_INTERVAL, maxDesiredSpeed )
		}

		currSpeed = min( currSpeed, file.driftWC_MaxSpeed )
		vector newVel = moveVec * currSpeed
		vector nextFramePos = WORLD_CENTER.GetOrigin() + newVel * FRAME_INTERVAL * 1.5

		WORLD_CENTER.NonPhysicsMoveTo( nextFramePos, FRAME_INTERVAL * 1.5, 0, 0 )

		//move the sculptor up
		float sculptorY = GraphCapped( nextFramePos.y, worldStart, worldEnd, sculptorStartY, sculptorEndY )
		float sculptorZ = GraphCapped( nextFramePos.y, worldStart, worldEnd, sculptorStartZ, sculptorEndZ )
		file.sculptor.NonPhysicsMoveTo( < sculptorX, sculptorY, sculptorZ >, FRAME_INTERVAL * 1.5, 0, 0 )

		WaitFrame()
	}
}

void function DEV_DrawSkyRig( entity skyRig, array<SkyBoxLandSection> landModels )
{
	skyRig.EndSignal( "OnDestroy" )

	wait 0.5

	table<asset,string> names = {}
	names[ SE_LAND_A ] 		<- "LAND_A"
	names[ SE_LAND_B ] 		<- "LAND_B"
	names[ SE_LAND_AB ] 	<- "LAND_AB"
	names[ SE_LAND_BA ] 	<- "LAND_BA"
	names[ SE_VISTA_A1 ] 	<- "VISTA_A1"
	names[ SE_VISTA_A2 ] 	<- "VISTA_A2"
	names[ SE_VISTA_B1 ] 	<- "VISTA_B1"
	names[ SE_VISTA_B2 ] 	<- "VISTA_B2"

	while( 1 )
	{
		WaitFrame()
		if ( !GetMoDevState() )
			continue

		for ( int i = 0; i < MAXLANDTAGS; i++ )
		{
			string tagIndex = "LAND_" + ( i + 1 )
			int tagID 		= skyRig.LookupAttachment( tagIndex )
			vector origin 	= skyRig.GetAttachmentOrigin( tagID )

			string modelName 	= names[ landModels[ i ].lane[ "center" ].GetModelName() ]
			string value 		= modelName + "\n" + tagIndex

			DebugDrawText( origin + <0,0,2>, value, true, FRAME_INTERVAL )
		}
	}
}

/************************************************************************************************\

██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝

\************************************************************************************************/
void function DEV_DrawWorldEdges()
{
	wait 0.5

	int limit = 15500
	int bottom = -10500

	if ( !IsValid( WORLD_CENTER ) )
		return
	WORLD_CENTER.EndSignal( "OnDestroy" )

	while( 1 )
	{
		WaitFrame()
		if ( !GetMoDevState() )
			continue

		DebugDrawLine( < -limit, -limit, bottom >, < -limit, -limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < -limit, limit, bottom >, < -limit, limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < limit, limit, bottom >, < limit, limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < limit, -limit, bottom >, < limit, -limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )

		DebugDrawLine( < -limit, -limit, bottom >, < -limit, limit, bottom >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < -limit, -limit, limit >, < -limit, limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < limit, -limit, bottom >, < limit, limit, bottom >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < limit, -limit, limit >, < limit, limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )

		DebugDrawLine( < -limit, -limit, bottom >, < limit, -limit, bottom >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < -limit, -limit, limit >, < limit, -limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < -limit, limit, bottom >, < limit, limit, bottom >, 0, 255, 100, true, FRAME_INTERVAL )
		DebugDrawLine( < -limit, limit, limit >, < limit, limit, limit >, 0, 255, 100, true, FRAME_INTERVAL )


		DebugDrawCircle( WORLD_CENTER.GetOrigin(), < -90,0,90>, 512, 50, 25, 255, true, FRAME_INTERVAL, 5 )
		DebugDrawLine( WORLD_CENTER.GetOrigin(), <0,0,0>, 50, 25, 255, true, FRAME_INTERVAL )

		vector origin = WORLD_CENTER.GetOrigin()
		int speed = Length( WORLD_CENTER.GetVelocity() ).tointeger()

		DebugDrawText( <0,0,0>, "Center: <" + origin.x.tointeger() + "," + origin.y.tointeger() + "," + origin.z.tointeger()  + "> : " + speed, true, FRAME_INTERVAL )
		DebugDrawCircle( <0,0,0>, < -90,0,90>, 128, 50, 25, 255, true, FRAME_INTERVAL, 4 )
	}
}

void function PlayerSetStartPoint( entity player, entity node, vector offset = <0,0,0> )
{
	player.SetOrigin( node.GetOrigin() + <0,0,4> + offset )
	player.SetAngles( node.GetAngles() )
}

void function SyncedStumble( vector angles )
{
	array<entity> guys = GetNPCArrayByClass( "npc_soldier" )
	foreach( guy in guys )
		thread GruntStumbleThink( guy, angles )

	array<entity> stalkers = GetNPCArrayByClass( "npc_stalker" )
	foreach( stalker in stalkers )
		thread StalkerStumbleThink( stalker, angles )

	thread PlayerStumbleThink( angles )
}

void function GruntStumbleThink( entity guy, vector angles )
{
	if ( !IsAlive( guy ) )
		return
	guy.EndSignal( "OnDeath" )

	if ( !CanStumble( guy ) )
		return

	//string side = GetStumbleSide( player, angles )

	array<string> anims = [
		"CQB_Flinch_chest_multi_fall",
		"React_wallslam_fall",
		"pt_react_jumped_over_lookfall"
		]

	guy.SetAngles( AnglesCompose( angles, <0,180,0> ) )

	string anim = anims.getrandom()
	float time = guy.GetSequenceDuration( anim )

	guy.Anim_ScriptedPlay( anim )
	guy.Anim_EnablePlanting()
	wait time - 0.3
	guy.Anim_Stop()
}

bool function CanStumble( entity guy )
{
	if ( !(guy.IsPlayer()) && !guy.IsInterruptable() )
		return false
	if ( guy.Anim_IsActive() )
		return false
	if ( IsValid( guy.GetParent() )	)
		return false
	if ( !( guy.IsOnGround() ) )
		return false

	return true
}

void function StalkerStumbleThink( entity guy, vector angles )
{
	if ( !IsAlive( guy ) )
		return
	guy.EndSignal( "OnDeath" )

	if ( !CanStumble( guy ) )
		return

	array<string> anims = [
		"st_walk_pain_leg_stumble_R",
		"st_run_pain_stumble_R",
		]

	guy.SetAngles( angles )

	string anim = anims.getrandom()
	float time = guy.GetSequenceDuration( anim )

	guy.Anim_ScriptedPlay( anim )
	guy.Anim_EnablePlanting()
	wait time - 0.3
	guy.Anim_Stop()
}

const DOT_45_DEGREES = 0.707107
void function PlayerStumbleThink( vector angles )
{
	entity player = file.player

	if ( !CanStumble( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.SetNoTarget( true )
	player.ForceStand()
	//player.DisableWeapon()

	table<string,table<string,string> > anims = {}
	anims[ "front" ] <- {}
	anims[ "front" ][ "animPOV" ] 	<- "ptpov_s2s_player_stumble_01"
	anims[ "front" ][ "anim3rd" ] 	<- "pt_s2s_player_stumble_01"
	anims[ "back" ] <- {}
	anims[ "back" ][ "animPOV" ] 	<- "ptpov_s2s_player_stumble_03_back"
	anims[ "back" ][ "anim3rd" ] 	<- "pt_s2s_player_stumble_03_back"
	anims[ "left" ] <- {}
	anims[ "left" ][ "animPOV" ] 	<- "ptpov_s2s_player_stumble_02_left"
	anims[ "left" ][ "anim3rd" ] 	<- "pt_s2s_player_stumble_02_left"
	anims[ "right" ] <- {}
	anims[ "right" ][ "animPOV" ] 	<- "ptpov_s2s_player_stumble_04_right"
	anims[ "right" ][ "anim3rd" ] 	<- "pt_s2s_player_stumble_04_right"

	string side = GetStumbleSide( player, angles )

	//create a dummy
	entity dummy = GetEntByScriptName( "stumbleDummy" ).SpawnEntity()
	DispatchSpawn( dummy )
	dummy.SetNoTarget( true )
	dummy.EnableNPCFlag( NPC_IGNORE_ALL )
	dummy.SetEfficientMode( true )
	dummy.Hide()
	dummy.GetActiveWeapon().Hide()
	dummy.SetOrigin( player.GetOrigin() )
	dummy.SetOwner( player )

	vector faceAngles 	= <0, player.EyeAngles().y, 0>
	dummy.SetAngles( faceAngles )

	OnThreadEnd(
	function() : ( dummy, player )
		{
			if ( IsValid( dummy ) )
				dummy.Destroy()
			if ( IsValid( player ) )
				player.SetNoTarget( false )
		}
	)

	//viewmodel
	entity viewmodel = player.GetFirstPersonProxy()
	viewmodel.ShowFirstPersonProxy()
	viewmodel.RenderWithViewModels( true )
	viewmodel.Signal( "NewViewAnimEntity" )
	player.AnimViewEntity_SetEntity( viewmodel )
	viewmodel.SetNextThinkNow()

	viewmodel.ClearParent()
	viewmodel.SetAbsOrigin( player.GetOrigin() )
	viewmodel.SetAbsAngles( player.GetAngles() )

	player.AnimViewEntity_SetLerpInTime( 0.4 )
	player.PlayerCone_SetLerpTime( 0.5 )
	player.AnimViewEntity_SetLerpOutTime( 0.4 )

	//animate
	dummy.Anim_ScriptedPlay( anims[ side ][ "anim3rd" ] )
	dummy.Anim_EnablePlanting()

	float lerp = 0.4
	viewmodel.SetParent( dummy, "ORIGIN", false, lerp )
	player.SetParent( dummy, "ORIGIN", false, lerp )

	viewmodel.Anim_Play( anims[ side ][ "animPOV" ] )
	ViewConeSmall( player )

	WaittillAnimDone( viewmodel )
	ClearPlayerAnimViewEntity( player )

	player.ClearParent()
	viewmodel.ClearParent()
	player.UnforceStand()
	//player.EnableWeapon()
}

string function GetStumbleSide( entity guy, vector angles )
{
	string side = ""
	vector entAngles = guy.GetAngles()
	if ( guy.IsPlayer() )
		entAngles = guy.EyeAngles()

	vector dir 	= AnglesToForward( angles )
	vector faceAngles = <0, entAngles.y, 0>
	vector forward = AnglesToForward( faceAngles )

	float dotF = DotProduct( forward, dir )
	if ( fabs( dotF) > DOT_45_DEGREES )
	{
		//front or back
		if ( dotF > 0 )
			side = "front"
		else
			side = "back"
	}
	else
	{
		//left or right
		vector right = AnglesToRight( faceAngles )
		float dotR = DotProduct( right, dir )
		if ( dotR > 0 )
			side = "right"
		else
			side = "left"
	}

	Assert( side != "" )
	return side
}

ShipStruct function SpawnSarahWidow( LocalVec ornull pos = null, bool incombat = false )
{
	ShipStruct widow = SpawnWidow( pos )
	widow.model.SetScriptName( "S2S_CALLSIGN_SARAH" )
	Highlight_SetNeutralHighlight( widow.model, "sp_s2s_crow_outline" )
	ClearShipBehavior( widow, eBehavior.ENEMY_ONBOARD )

	file.sarahWidow = widow

	EmitSoundOnEntityAfterDelay( widow.model, "scr_s2s_widow_flight_lp_01", 0.25 )

	AddShipEventCallback( widow, eShipEvents.PLAYER_INCABIN_START, SarahWidowPlayerInCabinStart )
	AddShipEventCallback( widow, eShipEvents.PLAYER_INCABIN_END, SarahWidowPlayerInCabinEnd )
	AddShipEventCallback( widow, eShipEvents.PLAYER_ONHULL_START, SarahWidowPlayerOnHullStart )
	AddShipEventCallback( widow, eShipEvents.PLAYER_ONHULL_END, SarahWidowPlayerOnHullEnd )

	EnableScript( widow, "scr_swidow_node_0", "BODY", file.playerWidow_scrOffset )

	switch( GetCurrentStartPoint() )
	{
		case "Level Start":
		case "Intro":
		case "Gibraltar":
		case "Boss Intro":
		case "Widow Fall":
		case "Barker Ship":
		case "FastBall 1":
		case "":
			entity npc = SpawnSarahTitan( widow.model.GetOrigin() )
			widow.model.Anim_Play( "wd_doors_open_idle_L" )
			file.sarahTitan.SetParent( file.sarahWidow.model, "ORIGIN" )

			if ( incombat )
				thread PlayAnimTeleport( file.sarahTitan, "bt_widow_intro_hang_idle_sarah", file.sarahWidow.model, "ORIGIN" )
			else
				thread PlayAnimTeleport( file.sarahTitan, "bt_widow_side_idle_Sarah", file.sarahWidow.model, "ORIGIN" )

			file.sarahTitan.TakeActiveWeapon()
			break
	}

	return widow
}

void function SarahWidowPlayerInCabinStart( ShipStruct widow, entity player, int eventID )
{
	FlagSet( "PlayerInSarahWidow" )
	FlagSet( "PlayerInOrOnSarahWidow" )
}

void function SarahWidowPlayerInCabinEnd( ShipStruct widow, entity player, int eventID )
{
	FlagClear( "PlayerInSarahWidow" )
	if ( !Flag( "PlayerOnSarahWidow" ) )
		FlagClear( "PlayerInOrOnSarahWidow" )
}

void function SarahWidowPlayerOnHullStart( ShipStruct widow, entity player, int eventID )
{
	FlagSet( "PlayerOnSarahWidow" )
	FlagSet( "PlayerInOrOnSarahWidow" )
}

void function SarahWidowPlayerOnHullEnd( ShipStruct widow, entity player, int eventID )
{
	FlagClear( "PlayerOnSarahWidow" )
	if ( !Flag( "PlayerInSarahWidow" ) )
		FlagClear( "PlayerInOrOnSarahWidow" )
}

void function PlayerWidowPlayerOnHullStart( ShipStruct widow, entity player, int eventID )
{
	FlagSet( "PlayerOutsidePlayerWidow" )
}

void function PlayerWidowPlayerOnHullEnd( ShipStruct widow, entity player, int eventID )
{
	FlagClear( "PlayerOutsidePlayerWidow" )
}

void function PlayerWidowPlayerInCabinStart( ShipStruct widow, entity player, int eventID )
{
	FlagSet( "PlayerInsidePlayerWidow" )
}

void function PlayerWidowPlayerInCabinEnd( ShipStruct widow, entity player, int eventID )
{
	FlagClear( "PlayerInsidePlayerWidow" )
}

void function Crow64PlayerOnHullStart( ShipStruct widow, entity player, int eventID )
{
	FlagSet( "PlayerInOrOnCrow64" )
}

void function Crow64PlayerOnHullEnd( ShipStruct widow, entity player, int eventID )
{
	FlagClear( "PlayerInOrOnCrow64" )
}

entity function SpawnSarahTitan( vector origin = <0,0,0>, vector angles = <0,0,0> )
{
	if ( IsValid( file.sarahTitan ) )
		file.sarahTitan.Destroy()

	entity npc = CreateNPCTitan( "titan_buddy", TEAM_MILITIA, origin, angles )
	SetSpawnOption_AISettings( npc, "npc_titan_buddy_s2s" )
	SetSpawnOption_Weapon( npc, "mp_titanweapon_rocketeer_rocketstream", [ "sp_s2s_settings_npc" ] )

	DispatchSpawn( npc )
	npc.SetSkin( 2 )
	HideName( npc )
	DisableTitanRodeo( npc )

	npc.SetScriptName( "S2S_CALLSIGN_SARAH" )

	file.sarahTitan = npc

	Highlight_ClearFriendlyHighlight( file.sarahTitan )
	file.sarahTitan.TakeActiveWeapon()
	file.sarahTitan.SetParent( file.sarahWidow.model, "ORIGIN" )
	thread PlayAnimTeleport( file.sarahTitan, "bt_widow_side_idle_start_Sarah", file.sarahWidow.model, "ORIGIN" )

	return npc
}

ShipStruct function SpawnCrow64( LocalVec ornull pos = null )
{
	array<entity> guys = SpawnSquad64()
	ShipStruct crow = SpawnCrow( pos, CONVOYDIR, guys )
	crow.bug_reproNum = 1

	ShipSetInvulnerable( crow )
	Highlight_SetNeutralHighlight( crow.model, "sp_s2s_crow_outline" )
	Highlight_SetFriendlyHighlight( crow.model, "sp_s2s_crow_outline" )

	AddShipEventCallback( crow, eShipEvents.PLAYER_ONHULL_START, Crow64PlayerOnHullStart )
	AddShipEventCallback( crow, eShipEvents.PLAYER_ONHULL_END, Crow64PlayerOnHullEnd )

	switch( GetCurrentStartPoint() )
	{
		case "Level Start":
		case "Intro":
		case "Gibraltar":
		case "Boss Intro":
		case "Widow Fall":
		case "Barker Ship":
			//do nothing
			break

		default:
			EmitSoundOnEntity( crow.model, "amb_scr_s2s_crow_flight_lp_01" )
			break
	}

	return crow
}

array<entity> function SpawnSquad64( bool alert = false )
{
	array<entity> spawners = GetEntArrayByScriptName( "crowCrew" )
	foreach ( spawner in spawners )
	{
		entity guy = spawner.SpawnEntity()

		if ( alert )
			SetSpawnOption_Alert( guy )

		switch( guy.kv.script_noteworthy )
		{
			case "davis":
				SetSpawnOption_Weapon( guy, "mp_weapon_lstar" )
				DispatchSpawn( guy )
				guy.SetModel( MODEL_DAVIS )
				guy.SetTitle( "#NPC_DAVIS_NAME" )
				file.davis = guy
				break

			case "droz":
				SetSpawnOption_Weapon( guy, "mp_weapon_lstar" )
				DispatchSpawn( guy )
				guy.SetModel( MODEL_DROZ )
				guy.SetTitle( "#NPC_DROZ_NAME" )
				file.droz = guy
				break

			case "anderson":
			case "gates":
				SetSpawnOption_Weapon( guy, "mp_weapon_dmr" )
				DispatchSpawn( guy )
				guy.SetModel( MODEL_GATES )
				guy.SetTitle( "#NPC_GATES_NAME" )
				file.gates = guy
				break

			case "bear":
				SetSpawnOption_Weapon( guy, "mp_weapon_mastiff" )
				DispatchSpawn( guy )
				guy.SetModel( MODEL_BEAR )
				guy.SetTitle( "#NPC_BEAR_NAME" )
				file.bear = guy
				break
		}
		guy.SetSkin( 1 )
		guy.SetInvulnerable()
		guy.DisableHibernation()
		int eHandle = guy.GetEncodedEHandle()
		Remote_CallFunction_NonReplay( file.player, "ServerCallback_SetupJumpJetAnimEvents", eHandle )
	}
	array<entity> guys = [ file.davis, file.droz, file.bear, file.gates ]

	return guys
}

void function ShipIdleAtTargetPos_Teleport( ShipStruct ship, LocalVec origin, vector bounds )
{
	entity mover = ship.mover
	mover.NonPhysicsStop()
	SetOriginLocal( mover, origin )

	thread ShipIdleAtTargetPos( ship, origin, bounds )
}

void function ShipIdleAtTargetEnt_Teleport( ShipStruct ship, entity follow, vector bounds, vector delta, vector offset )
{
	LocalVec origin = GetOriginLocal( follow )
	origin.v += ( delta + offset )

	entity mover = ship.mover
	mover.NonPhysicsStop()
	SetOriginLocal( mover, origin )

	thread ShipIdleAtTargetEnt( ship, follow, bounds, delta, offset )
}

void function ShipIdleAtTargetEnt_M2_Teleport( ShipStruct ship, entity follow, vector bounds, vector delta, vector offset )
{
	LocalVec origin = GetOriginLocal( follow )
	origin.v += ( delta + offset )

	entity mover = ship.mover
	mover.NonPhysicsStop()
	SetOriginLocal( mover, origin )

	thread ShipIdleAtTargetEnt_Method2( ship, follow, bounds, delta, offset )
}

void function PlayerWindFX( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	if ( Flag( "StopWindFx" ) )
		return
	FlagEnd( "StopWindFx" )

	while( 1 )
	{
		FlagWaitClear( "PlayerInside" )

		waitthread CreatePlayerWindFX( player )
	}
}

void function CreatePlayerWindFX( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	if ( Flag( "StopWindFx" ) )
		return
	FlagEnd( "StopWindFx" )

	int fxID = GetParticleSystemIndex( PLAYER_WIND_FX )
	int attachID = player.LookupAttachment( "REF" )
	entity fx = StartParticleEffectOnEntityWithPos_ReturnEntity( player, fxID, FX_PATTACH_POINT_FOLLOW_NOROTATE, attachID, <0,0,0>, CONVOYDIR )

	OnThreadEnd(
	function() : ( fx )
		{
			if ( IsValid( fx ) )
				fx.Destroy()
		}
	)

	FlagWait( "PlayerInside" )
}

void function RecordedAnimSignals( entity guy )
{
	Assert( IsAlive( guy ) )
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnAnimationDone" )

	while( 1 )
	{
		table result = WaitSignal( guy, "animRecordingSignal" )
		string value = expect string( result.value )

		CustomAnimSignals( guy, value )
	}
}

void function HandleCustomSignals( entity guy )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnAnimationDone" )

	while( 1 )
	{
		table result = WaitSignal( guy,	"OnWeaponNpcPrimaryAttack_weapon_DMR",
										"OnWeaponNpcPrimaryAttack_weapon_mastiff",
										"OnWeaponNpcPrimaryAttack_weapon_lstar_start",
										"OnWeaponNpcPrimaryAttack_weapon_lstar",
										"OnWeaponNpcPrimaryAttack_weapon_lstar_end" )

		string value = expect string( result.signal )

		CustomAnimSignals( guy, value )
	}
}

void function CustomAnimSignals( entity guy, string value )
{
	switch( value )
	{
		case "OnWeaponNpcPrimaryAttack_weapon_DMR":
		case "OnWeaponNpcPrimaryAttack_weapon_sniper":
			FireWeapon( guy, OnWeaponNpcPrimaryAttack_weapon_DMR )
			EmitSoundOnEntity( guy, "Weapon_DMR_Fire_NPC" )
			break

		case "OnWeaponNpcPrimaryAttack_weapon_mastiff":
			FireWeapon( guy, OnWeaponNpcPrimaryAttack_weapon_mastiff )
			EmitSoundOnEntity( guy, "Weapon_Mastiff_Fire_3P" )
			break

		case "OnWeaponNpcPrimaryAttack_weapon_lstar_start":
			FireWeapon( guy, OnWeaponNpcPrimaryAttack_weapon_lstar )
			EmitSoundOnEntity( guy, "Weapon_LSTAR_FirstShot_3P" )
			EmitSoundOnEntity( guy, "Weapon_LSTAR_Loop_3P" )
			break

		case "OnWeaponNpcPrimaryAttack_weapon_lstar":
			FireWeapon( guy, OnWeaponNpcPrimaryAttack_weapon_lstar )
			break

		case "OnWeaponNpcPrimaryAttack_weapon_lstar_end":
			FireWeapon( guy, OnWeaponNpcPrimaryAttack_weapon_lstar )
			StopSoundOnEntity( guy, "Weapon_LSTAR_Loop_3P" )
			EmitSoundOnEntity( guy, "Weapon_LSTAR_LoopEnd_3P" )
			break

		default:
			Assert( 0, "animRecordingSignal: " + value + " not setup." )
			break
	}
}

void function FireWeapon( entity guy, var functionref( entity, WeaponPrimaryAttackParams ) OnNPCFire )
{
	entity weapon = guy.GetActiveWeapon()
	WeaponPrimaryAttackParams attackParams

	int attachID = weapon.LookupAttachment( "muzzle_flash" )
	attackParams.pos = weapon.GetAttachmentOrigin( attachID )
	vector angles = AnglesCompose( weapon.GetAttachmentAngles( attachID ), < -20,0,0> ) //pitch up - anims tend to pitch down
	attackParams.dir = AnglesToForward( angles )

	OnNPCFire( weapon, attackParams )
}

var function OnWeaponNpcPrimaryAttack_weapon_DMR( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool shouldCreateProjectile = true
	bool playerFired = false

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	//entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, 15000, damageTypes.largeCaliber, damageTypes.largeCaliber, playerFired, 0 )
	//bolt.kv.gravity = 0.001
	weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.largeCaliber )
}

vector function GetWorldPosRelativeToShip( vector origin, ShipStruct ship, vector offset = <0,0,0> )
{
	vector delta 	= origin - ship.templateOrigin
	entity mover 	= ship.mover

	vector right 	= mover.GetRightVector() 	* ( delta.x + offset.x )
	vector forward 	= mover.GetForwardVector() 	* ( delta.y + offset.y )
	vector up 		= mover.GetUpVector() 		* ( delta.z + offset.z )

	return mover.GetOrigin() + right + forward + up
}

void function HintConvo( string conversation, string enderFlag, float delay = 20 )
{
	if ( Flag( enderFlag ) )
		return
	FlagEnd( enderFlag )

	file.player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : (  )
			{
				if ( IsValid( file.player ) )
					StopConversationNow( file.player )
			}
		)

	AddConversationCallback( conversation, ConvoCallback_HintGeneric )
	while( 1 )
	{
		wait delay

		entity bt = GetBT( file.player )
		if ( !IsAlive( bt ) )
			return

		waitthreadsolo PlayerConversation( conversation, file.player, bt )
	}
}

void function ConvoCallback_HintGeneric( int choice )
{
	if ( choice == 1 )
	{
		Objective_Remind()
		StopConversation( file.player )
	}
}

entity function GetBT( entity player )
{
	entity bt
	if ( player.IsTitan() )
		bt = player
	else
		bt = player.GetPetTitan()
	Assert( IsValid( bt ) )

	return bt
}

/************************************************************************************************\

███████╗██████╗  ██████╗ ███████╗    ███╗   ███╗███████╗██╗     ███████╗███████╗
██╔════╝██╔══██╗██╔════╝ ██╔════╝    ████╗ ████║██╔════╝██║     ██╔════╝██╔════╝
█████╗  ██║  ██║██║  ███╗█████╗      ██╔████╔██║█████╗  ██║     █████╗  █████╗
██╔══╝  ██║  ██║██║   ██║██╔══╝      ██║╚██╔╝██║██╔══╝  ██║     ██╔══╝  ██╔══╝
███████╗██████╔╝╚██████╔╝███████╗    ██║ ╚═╝ ██║███████╗███████╗███████╗███████╗
╚══════╝╚═════╝  ╚═════╝ ╚══════╝    ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝

\************************************************************************************************/
void function DeckTitanOnDamaged( entity titan, var damageInfo )
{
	int damageSourceId 	= DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float damage 		= DamageInfo_GetDamage( damageInfo )
	entity attacker 	= DamageInfo_GetAttacker( damageInfo )

	if ( attacker != file.player )
		return

	if ( !DamageIsTitanMelee( damageSourceId ) )
		return

	vector force = GetMeleeForce( titan )

	if ( !MeleeForceWillKnockOffEdge( titan, force ) )
		return

	//lets make sure we don't die before we can fall off
	/*if ( damage >= titan.GetHealth() )
		damage = titan.GetHealth().tofloat() - 5
	DamageInfo_SetDamage( damageInfo, damage )

	titan.SetInvulnerable()

	//lets go for a ride
	thread DeckTitanFallsOffEdge( titan, force )*/

	file.edgeMeleeForce[ titan ] <- force
	SetDeathFuncName( titan, "DeckTitanFallsOffEdge" )
	DamageInfo_SetDamage( damageInfo, titan.GetMaxHealth() + 1 )
}

bool function DamageIsTitanMelee( int damageSourceId )
{
	if ( damageSourceId == eDamageSourceId.melee_titan_punch )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_punch_ion )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_punch_legion )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_punch_tone )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_punch_scorch )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_punch_northstar )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_punch_fighter )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_sword )
		return true
	else if ( damageSourceId == eDamageSourceId.melee_titan_sword_aoe )
		return true

	return false
}

vector function GetMeleeForce( entity titan )
{
	//are we actually being pushed off?
	float pitch 	= VectorToAngles( Normalize( titan.GetOrigin() - file.player.GetOrigin() ) ).x
	float yaw 		= file.player.EyeAngles().y
	vector angles 	= <pitch - 10, yaw, 0>

	return ( AnglesToForward( angles ) * 400 )
}

bool function MeleeForceWillKnockOffEdge( entity titan, vector force )
{
	vector dropPoint = titan.GetOrigin() + force
	vector up = file.malta.mover.GetUpVector()

	TraceResults traceResult = TraceLine( dropPoint + ( up * 0 ), dropPoint + ( up * -2000 ), [], TRACE_MASK_TITANSOLID, TRACE_COLLISION_GROUP_NONE )

	return ( traceResult.fraction >= 1.0 )
}

void function DeckTitanFallsOffEdge( entity titan )
{
//	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	titan.NotSolid()

	vector force 	= file.edgeMeleeForce[ titan ]
	float mag 		= 1.563
	vector push 	= force * mag
	vector angles 	= FlattenAngles( VectorToAngles( Normalize( force *  -1.0 ) ) )

	titan.SetAngles( angles )

	string anim = "s2s_ogre_fall_death"
	vector origin = HackGetDeltaToRefOnPlane( titan.GetOrigin() + push, angles, titan, anim, file.malta.model.GetUpVector() )
	entity node = CreateScriptMover( origin, angles )
	node.SetParent( file.malta.mover, "", true, 0 )

	float blendTime = 0.9

	OnThreadEnd(
	function() : ( titan, node )
		{
			if ( IsValid( titan ) )
			{
				titan.ClearParent()
				vector velocity = titan.GetVelocity() + <0,0,750> + ( AnglesToForward( CONVOYDIR ) * -200 )
				titan.SetVelocity( velocity )
				titan.BecomeRagdoll( velocity, true )
			}
			if ( IsValid( node ) )
				node.Destroy()
		}
	)

	titan.SetParent( node, "REF", false, blendTime )
	titan.Anim_ScriptedPlay( anim )
	//thread PlayAnim( titan, anim, node, "REF", blendTime )

	float waitTime = 0.4
	wait waitTime

	vector initial = force
	vector gravity = < 0,-800,-750 >

	node.ClearParent()
	node.NonPhysicsMoveWithGravity( initial, gravity )

	wait blendTime - waitTime

	titan.Anim_ScriptedPlay( "s2s_ogre_fall_death_flail" )
	//thread PlayAnim( titan, "s2s_ogre_fall_death_flail", node, "REF", 0.2 )

	wait 4.0
}

/************************************************************************************************\

████████╗███████╗███████╗████████╗
╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
   ██║   █████╗  ███████╗   ██║
   ██║   ██╔══╝  ╚════██║   ██║
   ██║   ███████╗███████║   ██║
   ╚═╝   ╚══════╝╚══════╝   ╚═╝

\************************************************************************************************/
void function EOF_Skip( entity player )
{
	ShipGeoHide( file.malta, "GEO_CHUNK_BACK_FAKE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_BACK" )
	ShipGeoShow( file.malta, "GEO_CHUNK_EXTERIOR_ENGINE" )
	ShipGeoShow( file.malta, "GEO_CHUNK_HANGAR" )
//	ShipGeoShow( file.gibraltar, "GIBRALTAR_CHUNK_INTERIOR" )

	EnableScript( file.malta, "scr_malta_node_3" )

	player.EnableWeapon()
	player.GiveWeapon( "mp_weapon_semipistol" )
	player.UnforceStand()

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	int bodyIndex = bt.FindBodyGroup( "left_arm" )
	bt.SetBodygroup( bodyIndex, 0 )

	BT_ResetLoadout( bt )
}

void function TestBedMain( entity player )
{
	FlagClear( "DriftWorldCenter" )

	//Test_WidowJumpRecordingSetup( player )
	//TEST_HangarIntro( player )
	//TEST_HangarFightRecordingSetup( player )
	//TEST_BreachRecordingSetup( player )
	//TEST_BridgeRecordingSetup( player )
	//TEST_DeckFx( player )
	TEST_GoblinModels( player )
}

void function TEST_GoblinModels( entity player )
{
	entity bt = player.GetPetTitan()
	bt.Destroy()

	SpawnGoblin( CLVec( < -300, 5000, 1000> ) )
	SpawnGoblinLight( CLVec( <300, 5000, 1000> ) )

	WaitForever()
}

void function TEST_DeckFx( entity player )
{
	entity bt = player.GetPetTitan()
	bt.Destroy()

	MaltaDeck_FlapsInit()
	EnableScript( file.malta, "scr_malta_node_5" )
	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart5" ) )

	array<entity> flapsR = GetEntArrayByScriptName( "deck_flap_right" )
	array<entity> flapsL = GetEntArrayByScriptName( "deck_flap_left" )

	foreach ( flap in flapsR )
		thread MaltaDeck_FlapsTest( file.malta, flap )
	foreach ( flap in flapsL )
		thread MaltaDeck_FlapsTest( file.malta, flap )

	WaitForever()
}

void function MaltaDeck_FlapsTest( ShipStruct ship, entity flap )
{
	flap.NonPhysicsSetRotateModeLocal( true )
	vector anglesDown 	= flap.GetLocalAngles()
	vector anglesUp 	= AnglesCompose( anglesDown, < 30,0,0> )
	float rotTime = 2.0

	entity trigger = null
	array<entity> fxNodes = []
	array<entity> links = flap.GetLinkEntArray()

	foreach ( link in links )
	{
		if ( link.GetClassName() == "script_mover_lightweight" )
			fxNodes.append( link )
		else if ( link.GetClassName() == "trigger_multiple" )
			trigger = link
	}

	flap.NonPhysicsRotateTo( anglesUp, rotTime, rotTime * 0.2, rotTime * 0.2 )
	MaltaDeck_PlayFlapFx( fxNodes, rotTime * 0.25 )
}

void function TEST_BridgeRecordingSetup( entity player )
{
	entity bt = player.GetPetTitan()
	bt.Destroy()

	EnableScript( file.malta, "scr_malta_node_4" )
	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart4b" ) )
	AddButtonPressedPlayerInputCallback( player, IN_ATTACK, ButtonPressedAttack )

	MaltaBridge_SetupCrew()
	file.bear.NotSolid()
	file.davis.NotSolid()
	file.droz.NotSolid()
	file.gates.NotSolid()

	WaitForever()
}

void function TEST_BreachRecordingSetup( entity player )
{
	entity bt = player.GetPetTitan()
	bt.Destroy()

	EnableScript( file.malta, "scr_malta_node_4" )
	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart4b" ) )
	AddButtonPressedPlayerInputCallback( player, IN_ATTACK, ButtonPressedAttack )

/*	entity node1 = GetEntByScriptName( "hangar_breach_node1" )
	entity node2 = GetEntByScriptName( "hangar_breach_node2" )
	entity node3 = GetEntByScriptName( "hangar_breach_node3" )

	thread PlayAnimTeleport( file.bear, 	"pt_bridge_breach_Bear_idle", 	node1 )
	thread PlayAnimTeleport( file.davis, 	"pt_bridge_breach_Davis_idle", 	node2 )
	thread PlayAnimTeleport( file.droz, 	"pt_bridge_breach_Droz_idle", 	node2 )
	thread PlayAnimTeleport( file.gates, 	"pt_bridge_breach_Gates_idle", 	node3 )
*/
	file.bear.NotSolid()
	file.davis.NotSolid()
	file.droz.NotSolid()
	file.gates.NotSolid()

	WaitForever()
}

void function TEST_HangarIntro( entity player )
{
	entity bt = player.GetPetTitan()
	bt.Destroy()

	EnableScript( file.malta, "scr_malta_node_3" )
	EnableScript( file.malta, "scr_malta_node_3b" )

	delaythread( 1 ) Hangar_LandBear( file.bear )
	delaythread( 1 ) Hangar_LandDroz( file.droz )
	delaythread( 1 ) Hangar_LandGates( file.gates )
	delaythread( 1 ) Hangar_LandDavis( file.davis )

	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart4" ) )

	Hangar_GearupGuyHandle()
	WaitForever()
}

void function TEST_HangarFightRecordingSetup( entity player )
{
	entity bt = player.GetPetTitan()
	bt.Destroy()

	EnableScript( file.malta, "scr_malta_node_3" )
	EnableScript( file.malta, "scr_malta_node_3b" )

	wait 0.1

	//thread Hangar_LandBear( file.bear )
	thread TEST_RepeatHangerAnim( file.bear, $"anim_recording/s2s_record_hanger_Bear_2a.rpak", Hangar_LandBear, Hangar_RecOut_Bear2 )
	//thread Hangar_LandDroz( file.droz )
	thread TEST_RepeatHangerAnim( file.droz, $"anim_recording/s2s_record_hanger_Droz_2a.rpak", Hangar_LandDroz, Hangar_RecOut_Droz2 )
	//thread Hangar_LandGates( file.gates )
	thread TEST_RepeatHangerAnim( file.gates, $"anim_recording/s2s_record_hanger_Gates_2a.rpak", Hangar_LandGates, Hangar_RecOut_Gates2 )
	//thread Hangar_LandDavis( file.davis )
	thread TEST_RepeatHangerAnim( file.davis, $"anim_recording/s2s_record_hanger_Davis_2a.rpak", Hangar_LandDavis, Hangar_RecOut_Davis2 )

	file.bear.NotSolid()
	file.droz.NotSolid()
	file.gates.NotSolid()
	file.davis.NotSolid()

	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart4" ) )

	wait 0.1

	WaitForever()
}

void function TEST_RepeatHangerAnim( entity guy, asset anim, void functionref(entity) startFunc, void functionref(entity) outFunc = null )
{
	guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	guy.LockEnemy( file.rocketDummy[ TEAM_IMC ] )

	while( 1 )
	{
		FlagClear( "Hangar_IntroReact" )

	//	thread startFunc( guy )

	//	wait 1.5

		FlagSet( "Hangar_IntroReact" )

		waitthread RunToAndPlayRecordedAnim( guy, anim, outFunc )

		wait 1.5
	}
}

void function Test_WidowJumpRecordingSetup( entity player )
{
	entity bt = player.GetPetTitan()
	bt.Destroy()

	EnableScript( file.malta, "scr_malta_node_2" )

	entity maltaRef = file.malta.mover
	entity node 	= GetEntByScriptName( "maltawidowrunRef" )
	vector delta	= GetRelativeDelta( node.GetOrigin(), maltaRef )
	vector offset	= MALTAWIDOW_WIDOW_OFFSET

	LocalVec pos = CLVec( delta + offset )

	file.sarahWidow = SpawnWidow( pos )
	ClearShipBehavior( file.sarahWidow, eBehavior.ENEMY_ONBOARD )

	//thread PlayAnim( file.sarahWidow.model, "wd_landed_idle", file.sarahWidow.mover, null )

	PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart3" ) )
	file.player.kv.gravity = GRAVITYFRAC

	WaitForever()
}

void function DropshipCombatTestMain( entity player )
{
	FlagClear( "DriftWorldCenter" )

	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	bt.DisableHibernation()
	bt.EnableNPCFlag( NPC_IGNORE_ALL )
	bt.SetNoTarget( true )

	LocalVec pos = CLVec( < 1000, 5000, 2000 > )
	ShipStruct ship = SpawnDSCombatTest( pos )
	DisableHullCrossing( ship )
	SetChaseEnemy( ship, player )
	SetBehavior( ship, eBehavior.ENEMY_CHASE )

	pos = CLVec( < -1000, 5000, 2000 > )
	ship = SpawnGoblin( pos )
	DisableHullCrossing( ship )
	SetChaseEnemy( ship, player )
	SetBehavior( ship, eBehavior.ENEMY_CHASE )

	WaitForever()
}

void function LightEditConnect( entity player )
{
	FlagClear( "DriftWorldCenter" )

 	player.SetOrigin( <1000,1500,-200> )
	player.SetAngles( CONVOYDIR )

	file.gibraltar.mover.SetOrigin( file.gibraltar.templateOrigin )

	WaitForever()
}

void function Trailer_Bridge( entity player )
{
	FlagClear( "DriftWorldCenter" )
	file.gibraltar.mover.SetOrigin( file.gibraltar.templateOrigin )

	entity bt = player.GetPetTitan()
	bt.Destroy()

	CreateAirBattle()

	EnableScript( file.malta, "scr_malta_node_4" )
	MaltaDeck_FlapsInit()
	EnableScript( file.malta, "scr_malta_node_5" )
	bool setup = true
	thread MaltaDeck_SetupCrew( setup )

	entity glass = GetEntByScriptName( "bridge_glass_front" )
	glass.SetModel( $"models/s2s/s2s_bridge_glass.mdl" )

	delaythread( 0.2 ) PlayerSetStartPoint( player, GetEntByScriptName( "maltaPlayerStart5" ), <0,-390,0> )
	WaitForever()
}

void function RespawnPlayer_s2s( entity player  )
{
	if ( !IsValid( file.respawnWidow.mover ) )
		return

	if ( GetState() == "None" )
	{
		if ( file.player == player )
			return
		if ( IsValid( player ) && IsAlive( file.player ) && !IsAlive( player ) )
		{
			player.SetOrigin( file.player.GetOrigin() )
			DoRespawnPlayer( player, null )
		}
		return
	}
	else if ( GetState() == "MaltaDeck" )
	{
		if ( !IsValid( player.GetPetTitan() ) )
		{
			CreatePetTitanAtOriginWithTf( player, file.malta.mover.GetOrigin() + <0,5000,1000>, player.GetAngles() )
			entity titan = player.GetPetTitan()
			if ( titan != null )
				titan.kv.alwaysAlert = false
		}
		else
		{
			entity titan = player.GetPetTitan()
			titan.SetOrigin( file.malta.mover.GetOrigin() + <0,5000,1000> )
		}
	}
	else if ( GetState() == "Fall" )
		return

	player.SetOrigin( file.respawnWidow.model.GetOrigin() + < -40,0,300> )
	DoRespawnPlayer( player, null )
	GivePlayerDefaultWeapons( player )

	wait 0.01

	player.SetVelocity( < 800,0,-50> )
}

void function HandleRespawnPlayer_s2s()
{
	vector relativeDelta
	entity refMover = file.malta.mover
	string lastState
	bool moveCloser
	while( IsValid( file.respawnWidow ) && GetState() != "Fall" )
	{
		if ( lastState != GetState() )
		{
			switch( GetState() )
			{
				case "MaltaGuns":
					relativeDelta = <4000,-4000,0>
					lastState = GetState()
					break
				case "MaltaHanger":
					relativeDelta = <3000,500,0>
					lastState = GetState()
					break
				case "MaltaDeck":
					relativeDelta = <1500,5000,1000>
					lastState = GetState()
					break
					
			}
		}
		
		moveCloser = false
		foreach( entity player in GetPlayerArray() )
        {
            if ( IsValid( player ) && IsAlive( player ) && DistanceSqr( player.GetOrigin(), file.respawnWidow.mover.GetOrigin() ) <= 160000.0 )
            {
                moveCloser = true
            }
        }

		if ( moveCloser )
		{
			thread ShipIdleAtTargetEnt_Method2( file.respawnWidow, refMover, <0,0,0>, <0,0,0>, relativeDelta )
		}
		else
		{
			thread ShipIdleAtTargetEnt_Method2( file.respawnWidow, refMover, <0,0,0>, <0,0,0>, relativeDelta + <2000,0,0> )
		}
		wait 0.05
	}
}


#if DEV

/************************************************************************************************\

██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗
██╔══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝
██████╔╝█████╗  ██║     ██║   ██║██████╔╝██║  ██║██║██╔██╗ ██║██║  ███╗
██╔══██╗██╔══╝  ██║     ██║   ██║██╔══██╗██║  ██║██║██║╚██╗██║██║   ██║
██║  ██║███████╗╚██████╗╚██████╔╝██║  ██║██████╔╝██║██║ ╚████║╚██████╔╝
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝

\************************************************************************************************/
void function Record1()
{
	//thread RecordWidowJump( "s2s_record_widowJump1a", "s2s_record_widowJump1b", "s2s_record_widowJump1c" )
	//thread RecordJumpToLand( "s2s_record_hanger_Bear_1a" )
	//thread RecordJumpToLand( "s2s_record_hanger_Bear_2a" )
	//thread RecordStairRun( "s2s_record_breach_Bear_1" )
	//thread RecordStairRun( "s2s_record_bridge_Bear_1" )
	//thread RecordTrinity( "s2s_record_start_Bear_1" )
	thread RecordRampRun( "s2s_dropshipLoad_LD")
}

void function Record2()
{
	//thread RecordWidowJump( "s2s_record_widowJump2a", "s2s_record_widowJump2b", "s2s_record_widowJump2c" )
	//thread RecordJumpToLand( "s2s_record_hanger_Droz_1a" )
	//thread RecordJumpToLand( "s2s_record_hanger_Droz_2a" )
	//thread RecordStairRun( "s2s_record_breach_Droz_1" )
	//thread RecordStairRun( "s2s_record_bridge_Droz_1" )
	//thread RecordTrinity( "s2s_record_start_Gates_1" )
	thread RecordRampRun( "s2s_dropshipLoad_LB")
}

void function Record3()
{
	//thread RecordWidowJump( "s2s_record_widowJump3a", "s2s_record_widowJump3b", "s2s_record_widowJump3c" )
	//thread RecordJumpToLand( "s2s_record_hanger_Gates_1a" )
	//thread RecordJumpToLand( "s2s_record_hanger_Gates_2a" )
	//thread RecordStairRun( "s2s_record_breach_Gates_1" )
	//thread RecordStairRun( "s2s_record_bridge_Gates_1" )
	//thread RecordTrinity( "s2s_record_start_Droz_1" )
	thread RecordRampRun( "s2s_dropshipLoad_LC")
}

void function Record4()
{
	//thread RecordWidowJump( "s2s_record_widowJump4a", "s2s_record_widowJump4b", "s2s_record_widowJump4c" )
	//thread RecordJumpToLand( "s2s_record_hanger_Davis_1a" )
	//thread RecordJumpToLand( "s2s_record_hanger_Davis_2a" )
	//thread RecordStairRun( "s2s_record_breach_Davis_1" )
	//thread RecordStairRun( "s2s_record_bridge_Davis_1" )
	//thread RecordTrinity( "s2s_record_start_Davis_1" )
	thread RecordRampRun( "s2s_dropshipLoad_LA")
}

void function RecordRampRun( string filename )
{
	printt( "READY TO RECORD: " + filename )

	//start recording
//	file.player.WaitSignal( "ButtonPressedAttack" )
	printt( "RECORDING STARTED" )

	entity node = GetEntByScriptName( "trinity_ship64" )

	file.player.StartRecordingAnimation( node.GetOrigin(), node.GetAngles() )

	//stop
	file.player.WaitSignal( "ButtonPressedAttack" )

	var recording = file.player.StopRecordingAnimation()

#if PC_PROG
	SaveRecordedAnimation( recording, filename )
#endif
	printt( "RECORDING DONE" )
}

void function RecordTrinity( string filename )
{
	entity ref = file.trinity.mover

	printt( "READY TO RECORD: " + filename )

	//start recording
	file.player.WaitSignal( "ButtonPressedJump" )
	printt( "RECORDING STARTED" )

	file.player.StartRecordingAnimation( ref.GetOrigin(), ref.GetAngles() )

	//stop
	file.player.WaitSignal( "PME_TouchGround" )

	var recording = file.player.StopRecordingAnimation()

#if PC_PROG
	SaveRecordedAnimation( recording, filename )
#endif
	printt( "RECORDING DONE" )
}

void function RecordStairRun( string filename )
{
	entity maltaRef = file.malta.mover

	printt( "READY TO RECORD: " + filename )

	//start recording
	file.player.WaitSignal( "ButtonPressedJump" )
	printt( "RECORDING STARTED" )

	file.player.StartRecordingAnimation( maltaRef.GetOrigin(), maltaRef.GetAngles() )

	//stop
	file.player.WaitSignal( "ButtonPressedAttack" )
	var recording = file.player.StopRecordingAnimation()

#if PC_PROG
	SaveRecordedAnimation( recording, filename )
#endif
	printt( "RECORDING DONE" )
}

void function RecordJumpToLand( string filename1 )
{
	entity maltaRef = file.malta.mover

printt( "READY TO RECORD" )
	file.player.WaitSignal( "ButtonPressedJump" )

	//start recording
printt( "RECORDING STARTED" )
	file.player.StartRecordingAnimation( maltaRef.GetOrigin(), maltaRef.GetAngles() )

	//jump on wall
	file.player.WaitSignal( "ButtonPressedJump" )

	//dbl jump
//	file.player.WaitSignal( "ButtonPressedJump" )

	//jump off wall
	file.player.WaitSignal( "ButtonPressedJump" )

	//dbl jump
//	file.player.WaitSignal( "ButtonPressedJump" )

	//stop
//	file.player.WaitSignal( "ButtonPressedJump" )

	//land on ground - stop recording
	file.player.WaitSignal( "PME_TouchGround" )
	var recording1 = file.player.StopRecordingAnimation()

#if PC_PROG
	SaveRecordedAnimation( recording1, filename1 )
#endif

printt( "RECORDING DONE" )
}

void function RecordWidowJump( string filename1, string filename2, string filename3 )
{
	entity maltaRef = file.malta.mover
	entity widowRef = file.sarahWidow.model

printt( "RECORDING STARTED" )
	//start recording
	file.player.StartRecordingAnimation( maltaRef.GetOrigin(), maltaRef.GetAngles() )

	//jump on the wall
	file.player.WaitSignal( "ButtonPressedJump" )

	//jump off the wall
	file.player.WaitSignal( "ButtonPressedJump" )

	//double jump - stop and restart on widow
	file.player.WaitSignal( "ButtonPressedJump" )
	var recording1 = file.player.StopRecordingAnimation()

	file.player.StartRecordingAnimation( widowRef.GetOrigin(), widowRef.GetAngles() )

	//jump off widow
	file.player.WaitSignal( "ButtonPressedJump" )

	//double jump - stop and restart back on malta
	file.player.WaitSignal( "ButtonPressedJump" )
	var recording2 = file.player.StopRecordingAnimation()

	file.player.StartRecordingAnimation( maltaRef.GetOrigin(), maltaRef.GetAngles() )

	//land on ground - stop recording
	file.player.WaitSignal( "PME_TouchGround" )
	wait 1.0
	var recording3 = file.player.StopRecordingAnimation()

#if PC_PROG
	SaveRecordedAnimation( recording1, filename1 )
	SaveRecordedAnimation( recording2, filename2 )
	SaveRecordedAnimation( recording3, filename3 )
#endif
printt( "RECORDING DONE" )
}

#endif

void function RunToAndPlayRecordedAnim( entity guy, asset anim, void functionref(entity) outFunc = null )
{
	entity maltaRef = file.malta.mover
	vector origin 	= <0,0,0>
	vector angles 	= <0,0,0>
	var rec 		= LoadRecordedAnimation( anim )

	waitthread RunToRecordedAnimStart( guy, rec, origin, angles, maltaRef )
	thread RecordedAnimSignals( guy )
	waitthread PlayRecordedAnim( guy, rec, origin, angles, maltaRef )

	if ( outFunc != null )
		thread outFunc( guy )
}

void function RunToAnimStartHACK( entity guy, string animation_name, var reference = null, var optionalTag = null, bool disableArrival = true, bool disableAssaultAngles = false )
{
	Assert( IsAlive( guy ) )
	guy.Anim_Stop() // in case we were doing an anim already
	guy.EndSignal( "OnDeath" )

	bool allowFlee = guy.GetNPCFlag( NPC_ALLOW_FLEE )
	bool allowHandSignal = guy.GetNPCFlag( NPC_ALLOW_HAND_SIGNALS )
	bool allowArrivals = guy.GetNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )

	if ( disableArrival )
	{
	//	guy.DisableArrivalOnce( true )
		guy.EnableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )
	}

	guy.DisableNPCFlag( NPC_ALLOW_FLEE | NPC_ALLOW_HAND_SIGNALS )

	string animation = expect string( GetAnim( guy, animation_name ) )
	table animStartPos

	if ( optionalTag )
	{
		if ( typeof( reference ) == "vector" )
		{
			expect vector( reference )
			Assert( typeof( optionalTag ) == "vector", "Expected angles but got " + optionalTag )
			expect vector( optionalTag )
			animStartPos = guy.Anim_GetStartForRefPoint_Old( animation, reference, optionalTag )
		}
		else
		{
			expect entity( reference )
			expect string( optionalTag )
			animStartPos = guy.Anim_GetStartForRefEntity_Old( animation, reference, optionalTag )
			vector ornull clampedPos = NavMesh_ClampPointForAI( expect vector( animStartPos.origin ), guy )
			if ( clampedPos != null )
				animStartPos.origin = clampedPos
		}
	}
	else
	{
		expect entity( reference )
		vector origin = reference.GetOrigin()
		vector angles = reference.GetAngles()
		animStartPos = guy.Anim_GetStartForRefPoint_Old( animation, origin, angles )
	}

	float fightRadius = guy.AssaultGetFightRadius()
	float arrivalTolerance = guy.AssaultGetArrivalTolerance()
	float runtoRadius = 61.16
	guy.AssaultSetFightRadius( runtoRadius )
	guy.AssaultSetArrivalTolerance( runtoRadius )

	bool savedEnableFriendlyFollower = guy.ai.enableFriendlyFollower
	guy.ai.enableFriendlyFollower = false

	guy.AssaultPoint(  expect vector( animStartPos.origin ) )
	if ( !disableAssaultAngles )
		guy.AssaultSetAngles(  expect vector( animStartPos.angles ), true )

	//DebugDrawLine( guy.GetOrigin(), animStartPos.origin, 255, 0, 0, true, 20.0 )
	//DebugDrawAngles( animStartPos.origin, animStartPos.angles )
	//thread DebugAssaultEnt( guy, assaultEnt )
	while( Distance( guy.GetOrigin(), expect vector( animStartPos.origin ) ) > runtoRadius )
		WaitFrame()
	//WaitSignal( guy, "OnFinishedAssault" )

/*
	if ( !disableAssaultAngles )
		guy.AssaultSetAngles( animStartPos.angles, true )

	guy.AssaultPointToAnim( animStartPos.origin, animation, 4.0 )
	WaittillAnimDone( guy )
//	guy.WaitSignal( "OnFinishedAssault" )

*/
	//in case the scripter reset during run, we want to honor the intended change
	if ( guy.AssaultGetFightRadius() == runtoRadius )
		guy.AssaultSetFightRadius( fightRadius )

	if ( guy.AssaultGetArrivalTolerance() == runtoRadius )
		guy.AssaultSetArrivalTolerance( arrivalTolerance )

	guy.SetNPCFlag( NPC_ALLOW_FLEE, allowFlee )
	guy.SetNPCFlag( NPC_ALLOW_HAND_SIGNALS, allowHandSignal )
	guy.SetNPCMoveFlag( NPCMF_DISABLE_ARRIVALS, allowArrivals )

	guy.ai.enableFriendlyFollower = savedEnableFriendlyFollower
}

void function HideHelmet( string name )
{
	array<entity> possible = GetEntArrayByScriptName( name )
	if ( possible.len() < 1 )
		return

	entity helmet = possible[0]
	entity node 	= GetEntByScriptName( "GEO_CHUNK_HIDE_POS" )
	helmet.ClearParent()
	helmet.SetOrigin( node.GetOrigin() )
}

void function StopHelmetSpin( string name )
{
	WaitEndFrame()
	array<entity> possible = GetEntArrayByScriptName( name )
	if ( possible.len() < 1 )
		return

	entity helmet = possible[0]
	helmet.NonPhysicsRotate( < 0, 0, 0 >, 0.0 )
}

entity function CreateShakeExpensive( vector org, float amplitude = 16, float frequency = 150, float duration = 1.5, float radius = 2048 )
{
	entity env_shake = CreateEntity( "env_shake" )
	env_shake.kv.amplitude = amplitude
	env_shake.kv.radius = radius
	env_shake.kv.duration = 5.0
	env_shake.kv.frequency = frequency
	env_shake.kv.spawnflags = SF_SHAKE_INAIR

	DispatchSpawn( env_shake )

	env_shake.SetOrigin( org )

	EntFireByHandle( env_shake, "StartShake", "", 0, null, null )
	//EntFireByHandle( env_shake, "Kill", "", ( duration + 1 ), null, null )

	thread UpdateExpensiveShake( env_shake, duration )
	return env_shake
}

void function UpdateExpensiveShake( entity shake, float duration )
{
	shake.EndSignal( "OnDestroy" )

	float endTime = Time() + duration
	while( endTime > Time() )
	{
		wait 0.1
		if ( IsValid( shake ) )
		{
			EntFireByHandle( shake, "StopShake", "", 0, null, null )
			EntFireByHandle( shake, "StartShake", "", 0, null, null )
		}
	}

	if ( IsValid( shake ) )
	{
		EntFireByHandle( shake, "StopShake", "", 0, null, null )
		shake.Destroy()
	}
}

void function HurtPlayer( entity player, float fraction )
{
	float health = player.GetMaxHealth() * fraction
	player.SetHealth( health.tointeger() )
}

void function PlayerFallingDeath( entity player )
{
	try
	{
	FlagWait( "PlayerFallingDeathFlag" )
	
	// this just brakes it, so I added a try cacth
	// level.nv.ShipTitles = SHIPTITLES_NONE
	player.Die()

	if ( player.IsTitan() )
	{
		player.Anim_Play( "bt_s2s_widow_fall" )
		player.Anim_SetInitialTime( 0.7 )
		player.SetPlaybackRate( 0.5 )
	}
	else
		player.Anim_Play( "pt_skyfall_lean_delta" )

	wait 2
	ScreenFadeToBlackForever( player, 2 )
	}
	catch( exception ){
	}
}