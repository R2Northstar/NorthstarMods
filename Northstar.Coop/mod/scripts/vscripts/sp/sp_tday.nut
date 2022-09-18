
global function CodeCallback_MapInit


global const BUDDY_MODEL = $"models/titans/buddy/titan_buddy.mdl"

const bool DEBUG_TITAN_MELEE = false
const float TITAN_RUSH_MELEE_TIMEOUT = 15.0

const MARVIN_MODEL = $"models/robots/marvin/marvin.mdl"
const asset SKYBOX_MILITIA_TITAN_DROP_SHIP_MODEL = $"models/vehicles_r2/spacecraft/trinity/Trinity_1000x.mdl"
const asset SARAH_HUMAN_MODEL = $"models/humans/heroes/mlt_hero_sarah.mdl"
const asset SKYBOX_MALTA = $"models/vehicles_r2/spacecraft/malta/malta_flying_hero_1000x.mdl"
const asset STRATON_MODEL = $"models/vehicle/straton/straton_imc_gunship_01.mdl"
const asset HORNET_MODEL 	= $"models/vehicle/hornet/hornet_fighter.mdl"

const asset DROP_RACK_MODEL = $"models/props/titan_rack/titan_rack_v2.mdl"
const asset MIL_PILOT_MODEL = $"models/Humans/mcor_pilot/male_br/mcor_pilot_male_br.mdl"
const asset PLAYER_DROP_LAND_EFFECT = $"P_impact_dpod_dirt"

// For aircraft strikes
const asset MISSILE_MODEL = $"models/weapons/bullets/rocket_missile.mdl"
const asset MISSILE_TRAIL = $"Rocket_Smoke"
const asset MISSILE_FLASH = $"wpn_muzzleflash_xo_rocket"
const asset MISSILE_EXPLOSION = $"P_impact_exp_lrg"

// For titan missile barrage on wall
const asset ROCKET_MODEL = $"models/weapons/bullets/projectile_rocket_large.mdl"
const asset ROCKET_TRAIL_EFFECT = $"Rocket_Smoke_SMALL_Titan_2"
const float ROCKET_BARRAGE_AIM_OFFSET_MAX = 800.0
const float ROCKET_BARRAGE_TARGET_RAND_OFFSET = 100.0
const int ROCKET_BARRAGE_MIN_SHOTS = 15
const int ROCKET_BARRAGE_MAX_SHOTS = 25
const float ROCKET_BARRAGE_RADIUS_MOD_MIN = 2.8
const float ROCKET_BARRAGE_RADIUS_MOD_MAX = 5.0
const asset ROCKET_BARRAGE_MUZZLE_FLASH_EFFECT = $"P_wpn_muzzleflash_law"

const asset ARK_MODEL = $"models/core_unit/core_unit.mdl"
const asset ARK_BASE_MODEL = $"models/core_unit/core_containment_unit_bottom.mdl"

const asset PILOT_DROZ 		= $"models/humans/pilots/sp_medium_reaper_m.mdl"
const asset PILOT_GATES 	= $"models/humans/pilots/sp_medium_geist_f.mdl"

/*
Play this on the ship that flys by (if it still is) This is also still WIP, I will make it sound cooler.
"TDay_Intro_ShipFlyBy"
*/

struct
{
	entity sarahTitan
	entity sarahPilot
	array<entity> turretDeathTargets
	array<entity> introTurrets
	int numChargeFriendlyDeaths
	int numVTOLFriendlyDeaths
	int numRunwayFriendlyDeaths

	table<string,entity> arkSceneModels

	bool spawningReinforcementFriendlies

	array<entity> friendlyTitanSpawners_Intro
	array<entity> friendlyTitanSpawners_VTOL
	array<entity> friendlyTitanSpawners_Runway
	int idealNumberFriendlyTitans = 6 // Starting default down from 7 -Mackey
	array<entity> friendlyTitans
	int friendlyTitanSkinIndex = 1
	int friendlyTitanPrimaryIndex = 0
	int sideshowTitanPrimaryIndex = 0
	array<string> friendlyTitanPrimaries = [
		"mp_titanweapon_rocketeer_rocketstream",
		"mp_titanweapon_sticky_40mm",
		"mp_titanweapon_particle_accelerator",
		"mp_titanweapon_xo16_shorty" ]

	entity meleeFriendly1
	entity meleeFriendly2
	entity meleeFriendly3

	entity trailerSpawner1
	entity trailerSpawner2
	entity trailerSpawner3
	entity trailerSpawner4
	entity trailerSpawner5

	int superSpectreSpawnCount

	float dvsDefault
} file

void function CodeCallback_MapInit()
{
	FlagSet( "DogFights" )
	FlagSet( "SaveRequires_PlayerIsTitan" )

	ShSpTdayCommonInit()

	AddCallback_EntitiesDidLoad( TDay_EntitiesDidLoad )
	AddDamageCallback( "npc_titan", DamageCallback_NPCTitan )
	AddDeathCallback( "npc_titan", DeathCallback_NPCTitan )
	AddSpawnCallback( "npc_titan", SpawnCallback_NPCTitan )
	AddSpawnCallback( "npc_super_spectre", SpawnCallback_SuperSpectre )

	AddSpawnCallback( "npc_turret_mega", 	EnableMegaTurret )

	AddCallback_OnPlayerInventoryChanged( ExtraSmartAmmoRangeForRockets )

	PrecacheModel( MARVIN_MODEL )
	PrecacheModel( DRACONIS_SKYBOX )
	PrecacheModel( TEAM_MIL_GRUNT_MODEL_SMG )
	PrecacheModel( SARAH_HUMAN_MODEL )
	PrecacheModel( SKYBOX_MILITIA_TITAN_DROP_SHIP_MODEL )
	PrecacheModel( HORNET_MODEL )
	PrecacheModel( MISSILE_MODEL )
	PrecacheModel( ROCKET_MODEL )
	PrecacheModel( SKYBOX_MALTA )
	PrecacheModel( DROP_RACK_MODEL )
	PrecacheModel( MIL_PILOT_MODEL )
	PrecacheModel( STRATON_MODEL )
	PrecacheModel( PILOT_DROZ )
	PrecacheModel( PILOT_GATES )

	// Used for final ark sequence
	PrecacheModel( ARK_MODEL )
	PrecacheModel( ARK_BASE_MODEL )

	PrecacheParticleSystem( MISSILE_TRAIL )
	PrecacheParticleSystem( MISSILE_FLASH )
	PrecacheParticleSystem( MISSILE_EXPLOSION )
	PrecacheParticleSystem( ROCKET_TRAIL_EFFECT )
	PrecacheParticleSystem( PLAYER_DROP_LAND_EFFECT )
	PrecacheParticleSystem( ROCKET_BARRAGE_MUZZLE_FLASH_EFFECT )

	RegisterSignal( "RunwayTitansEngage" )
	RegisterSignal( "NewTurretDeathTarget" )
	RegisterSignal( "TitanfallChargeupSounds" )
	RegisterSignal( "TitanfallDropSounds" )
	RegisterSignal( "KilledTitan" )
	RegisterSignal( "EnemyTitanSpawned" )
	RegisterSignal( "SlamCamEnd" )

	FlagInit( "BadGeoFailsafe" )
	FlagInit( "LevelStartDone" )
	FlagInit( "StartFuelStorage" )
	FlagInit( "StartIntroShipFlyPath" )
	FlagInit( "BigFightDone" )
	FlagInit( "FinaleDone" )
	FlagInit( "TurretsAllowShootRocks" )
	FlagInit( "MissileControlRoom" )
	FlagInit( "TitanFireAtWall" )
	FlagInit( "WallStartPoint" )
	FlagInit( "CrateBlast" )
	FlagInit( "PlayerTitanFallBegin" )
	FlagInit( "PlayerTitanFallEnd" )
	FlagInit( "PlayerTitanfallImpact" )
	FlagInit( "FirstIMCTitansSpawned_Wave1" )
	FlagInit( "FirstIMCTitansSpawned_Wave2" )
	FlagInit( "FirstIMCTitansSpawned_Wave3" )
	FlagInit( "ElevatorUp" )
	FlagInit( "FriendlyPaths_ChargeWall" )
	FlagInit( "FriendlyPaths_MoveToWall" )
	FlagInit( "FriendlyPaths_EnterWall" )
	FlagInit( "FriendlyPaths_VTOL_Advance1" )
	FlagInit( "FriendlyPaths_VTOL_Advance2" )
	FlagInit( "FriendlyPaths_VTOL_Advance3" )
	FlagInit( "FriendlyPaths_VTOL_Advance4" )
	FlagInit( "MissileBarrageHitWall" )
	FlagInit( "ReinforcementsEnabled" )
	FlagInit( "VTOL" )
	FlagInit( "SarahJoinedVTOLBattle" )
	FlagInit( "ElevatorSequenceStarted" )
	FlagInit( "PlayerWarnedAboutTakingCover" )
	FlagInit( "ShipIntroEnded" )

	//AddStartPoint( "Trailer - Drop", 			StartPoint_TrailerDrop )

	AddStartPoint( "Intro", 					StartPoint_TdayIntro, 				StartPoint_Setup_Intro, 					StartPoint_Skipped_Intro )
	AddStartPoint( "Wall Bombardment", 			StartPoint_WallBombardment, 		StartPoint_Setup_WallBombardment, 			StartPoint_Skipped_WallBombardment )
	AddStartPoint( "Militia Big Charge", 		StartPoint_MilitiaBigCharge, 		StartPoint_Setup_MilitiaBigCharge, 			StartPoint_Skipped_MilitiaBigCharge )
	AddStartPoint( "Underground Fuel Storage", 	StartPoint_UndergroundFuelStorage, 	StartPoint_Setup_UndergroundFuelStorage, 	StartPoint_Skipped_UndergroundFuelStorage )
	AddStartPoint( "Elevator", 					StartPoint_Elevator, 				StartPoint_Setup_Elevator, 					StartPoint_Skipped_Elevator )
	AddStartPoint( "VTOL", 						StartPoint_VTOL, 					StartPoint_Setup_VTOL, 						StartPoint_Skipped_VTOL )
	AddStartPoint( "Fire on the Runway", 		StartPoint_FireontheRunway, 		StartPoint_Setup_FireontheRunway, 			StartPoint_Skipped_FireontheRunway )
	AddStartPoint( "OLA Launch", 				StartPoint_OLALaunch, 				StartPoint_Setup_OLALaunch, 				StartPoint_Skipped_OLALaunch )
}

void function TDay_EntitiesDidLoad()
{
	// For trailer
	file.trailerSpawner1 = GetEntByScriptName( "trailer_spawner1" )
	file.trailerSpawner2 = GetEntByScriptName( "trailer_spawner2" )
	file.trailerSpawner3 = GetEntByScriptName( "trailer_spawner3" )
	file.trailerSpawner4 = GetEntByScriptName( "trailer_spawner4" )
	file.trailerSpawner5 = GetEntByScriptName( "trailer_spawner5" )

	file.sarahTitan = GetEntByScriptName( "sarah" )
	Assert( IsValid( file.sarahTitan ) )
	Assert( IsAlive( file.sarahTitan ) )
	file.sarahTitan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
	file.sarahTitan.SetValidHealthBarTarget( false )
	file.sarahTitan.SetInvulnerable()
	file.sarahTitan.kv.WeaponProficiency = eWeaponProficiency.GOOD
	file.sarahTitan.kv.alwaysAlert = true
	MakeMidHealthTitan( file.sarahTitan )
	DisableTitanRodeo( file.sarahTitan )
	thread SetupSarahAfterSpawn()

	// Friendly titan spawners for intro area
	file.friendlyTitanSpawners_Intro.append( GetEntByScriptName( "intro_friendly_titan_spawner1" ) )
	file.friendlyTitanSpawners_Intro.append( GetEntByScriptName( "intro_friendly_titan_spawner2" ) )
	file.friendlyTitanSpawners_Intro.append( GetEntByScriptName( "intro_friendly_titan_spawner3" ) )
	file.friendlyTitanSpawners_Intro.append( GetEntByScriptName( "intro_friendly_titan_spawner4" ) )
	file.friendlyTitanSpawners_Intro.append( GetEntByScriptName( "intro_friendly_titan_spawner5" ) )
	file.friendlyTitanSpawners_Intro.append( GetEntByScriptName( "intro_friendly_titan_spawner6" ) )

	file.friendlyTitanSpawners_VTOL = GetEntArrayByScriptName( "vtol_friendly_titan_spawner" )

	file.friendlyTitanSpawners_Runway = GetEntArrayByScriptName( "runway_friendly_titan_spawner" )

	thread SwapOLAModel()
	thread SkyboxSmoke()
	thread StratonHornetDogfightsIntense()
	thread RunwayFriendlies()

	// Allow navmesh through the open elevator airlock door
	FlagSet( "ElevatorDoor2NavToggle" )
	GetEntByScriptName( "ElevatorClip" ).NotSolid()
	FlagSet( "ElevatorNavSeparation" )
}

void function SetupSarahAfterSpawn()
{
	wait 1.0
	Assert( IsValid( file.sarahTitan ) )
	file.sarahTitan.SetSkin(2)
	file.sarahTitan.SetTitle( "#NPC_SARAH_NAME" )
	ShowName( file.sarahTitan )
}


// -------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------


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

void function IntroDVSOverride( entity player )
{
	thread IntroDVSOverride_Thread()
}

void function IntroDVSOverride_Thread()
{
	WaitFrame(); // savegame callback needs to move to later due to callback sheninanigans

	if ( Flag( "ShipIntroEnded" ) )
		return

	SetConVarFloat( "dvs_scale_min", 1 )
	FlagWait( "ShipIntroEnded" )
	SetConVarFloat( "dvs_scale_min", file.dvsDefault )
}

void function StartPoint_TdayIntro( entity player )
{
	// Disable DVS for intro
	file.dvsDefault = GetConVarFloat( "dvs_scale_min" )
	SetConVarFloat( "dvs_scale_min", 1 )
	AddCallback_OnLoadSaveGame( IntroDVSOverride )

	DisableFriendlyHighlight()
	level.disableOutOfBounds <- true

	BTAutoFriendlyFollower( player, false )

	ShowIntroScreen( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_LevelIntroText" )

	FlagWait( "IntroScreenFading" )

	PlayMusic( "music_tday_02_intro" )

	//thread TitanfallTracers()
	thread IntroSequence( player )

	FlagWait( "PlayerTitanFallBegin" )

	thread SidelinesTitansGo()
	thread SpawnIntroDropships( true )
	thread IntroArmada()
	thread IntroAttackHornets()
	thread IntroTurrets( player )

	float delay = 10
	float offset = 0.25

	wait delay - offset

	CheckPoint_ForcedSilent()
	printt( "sarah appears! " + Time() )
	entity groundNode = GetEntByScriptName( "landing_node" )
	thread PlayAnimTeleport( file.sarahTitan, "BT_TDay_drop_sarah_end_V2", groundNode )

	wait offset

	// Stop effects in the interior of the ship
	FlagClear( "fx_tday_ship_interior" )
	FlagClear( "fx_tday_ship_interior_door" )

	SpawnFriendlyIntroTitans( true )

	EnableFriendlyHighlight()
	FlagWait( "PlayerTitanFallEnd" )

	level.disableOutOfBounds = false
}

void function StartPoint_Setup_Intro( entity player )
{
}

void function StartPoint_Skipped_Intro( entity player )
{
	FlagClear( "fx_tday_ship_interior" )
	BTAutoFriendlyFollower( player, false )
	FlagSet( "ShipIntroEnded" )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗    ██╗ █████╗ ██╗     ██╗
// ██║    ██║██╔══██╗██║     ██║
// ██║ █╗ ██║███████║██║     ██║
// ██║███╗██║██╔══██║██║     ██║
// ╚███╔███╔╝██║  ██║███████╗███████╗
//  ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_WallBombardment( entity player )
{
	printt( "Start Point - Wall" )

	Objective_SetSilent( "#TDAY_OBJECTIVE_DESTROY_WALL", GetEntByScriptName( "WallObjectiveLocation" ).GetOrigin() )

	Assert( file.friendlyTitans.len() == 6 )

	thread CreateFakeMissileLockPoints()
	thread TitanWallBombardmentAnims()
	thread WallBombardmentDialogue( player )
	thread MissileBarrageSounds()

	FlagSet( "WallStartPoint" )
	FlagWait( "TitanFireAtWall" )

	wait 6.0

	FlagSet( "WallExplode" )

	wait 2.0
}

void function StartPoint_Setup_WallBombardment( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
	TeleportPlayerAndBT( "start_player_WallBombardment", "start_bt_WallBombardment" )

	thread SidelinesTitansGo()
	thread SpawnIntroDropships( false )
	thread IntroArmada()
	thread IntroAttackHornets()
	thread IntroTurrets( player )
	thread SpawnFriendlyIntroTitans( false )

	FlagSet( "TurretsAllowShootRocks" )
}

void function StartPoint_Skipped_WallBombardment( entity player )
{
	FlagSet( "WallExplode" )
}

void function TitanWallBombardmentAnims( bool isTempTrailerMoment = false )
{
	// Friendly titans
	printt( "FRIENDLY TITANS DOING BOMBARDMENT ANIMS:", file.friendlyTitans.len() )
	foreach( entity titan in file.friendlyTitans )
	{
		entity node
		entity path
		string approachAnim
		string fireAnim
		switch( titan.GetScriptName() )
		{
			case "intro_friendly_titan_spawner1":
				node = GetEntByScriptName( "intro_friendly_node1" )
				path = GetEntByScriptName( "intro_friendly_path1" )
				approachAnim = "BT_titan_cover_runin"
				fireAnim = "BT_titan_cover_fire_B"
				break
			case "intro_friendly_titan_spawner2":
				node = GetEntByScriptName( "intro_friendly_node2" )
				path = GetEntByScriptName( "intro_friendly_path2" )
				approachAnim = "BT_titan_cover_runin"
				fireAnim = "BT_titan_cover_fire_C"
				break
			case "intro_friendly_titan_spawner3":
				node = GetEntByScriptName( "intro_friendly_node3" )
				path = GetEntByScriptName( "intro_friendly_path3" )
				approachAnim = "BT_titan_cover_runin"
				fireAnim = "BT_titan_cover_fire_A"
				break
			case "intro_friendly_titan_spawner4":
				node = GetEntByScriptName( "intro_friendly_node4" )
				path = GetEntByScriptName( "intro_friendly_path4" )
				approachAnim = "BT_titan_cover_runin"
				fireAnim = "BT_titan_cover_fire_A"
				break
			case "intro_friendly_titan_spawner5":
				node = GetEntByScriptName( "intro_friendly_node5" )
				path = GetEntByScriptName( "intro_friendly_path5" )
				approachAnim = "BT_titan_cover_runin"
				fireAnim = "BT_titan_cover_fire_A"
				break
			case "intro_friendly_titan_spawner6":
				node = GetEntByScriptName( "intro_friendly_node6" )
				path = GetEntByScriptName( "intro_friendly_path6" )
				approachAnim = "BT_titan_cover_runin"
				fireAnim = "BT_titan_cover_fire_C"
				break
		}
		Assert( IsValid( node ) )
		Assert( IsValid( path ) )
		thread FriendlyTitanWallBombardmentAnim( titan, node, approachAnim, fireAnim, path )
	}
}

void function FriendlyTitanWallBombardmentAnim( entity titan, entity node, string approachAnim, string fireAnim, entity path )
{
	WaitForHotdropToEnd( titan )
	wait 0.5

	// Run to the cover and do apprach anim
	//printt( "RUN TO AND PLAY COVER ANIM", titan.GetScriptName() )
	RunToAndPlayAnimGravity( titan, approachAnim, node )
	//printt( "GOT THERE!", titan.GetScriptName() )

	// Play cover anim until it's time to shoot
	titan.Anim_EnablePlanting()
	thread PlayAnim( titan, "BT_titan_cover_hide_idle", node )
	titan.Anim_EnablePlanting()

	FlagWait( "TitanFireAtWall" )

	wait RandomFloat( 1.0 )

	// Shoot anim
	thread PlayAnimGravity( titan, fireAnim, node )
	wait 1.0
	thread TitanFireBarrage( titan )

	// Start the path once the sequence is over
	FlagWait( "FriendlyPaths_ChargeWall" )
	titan.Anim_Stop()
	thread AssaultMoveTarget( titan, path )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗ ██╗ ██████╗      ██████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ███████╗
// ██╔══██╗██║██╔════╝     ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝ ██╔════╝
// ██████╔╝██║██║  ███╗    ██║     ███████║███████║██████╔╝██║  ███╗█████╗
// ██╔══██╗██║██║   ██║    ██║     ██╔══██║██╔══██║██╔══██╗██║   ██║██╔══╝
// ██████╔╝██║╚██████╔╝    ╚██████╗██║  ██║██║  ██║██║  ██║╚██████╔╝███████╗
// ╚═════╝ ╚═╝ ╚═════╝      ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_MilitiaBigCharge( entity player )
{
	RemoveExtraSmartAmmoRangeForRockets( player )

	printt( "Start Point - Militia Big Charge" )

	WaitFrame() // this exists to allow friendly titans to be spawned if you skip to this startpoint and the Setup function needs to run

	Objective_SetSilent( "#TDAY_OBJECTIVE_RETRIEVE_ARK",  <9752.58, 10835.8, 4579.26> )

	thread MakeIntroTitansVulnerable()
	thread IntroBattleThink( player )
	thread Wave1Dialogue( player )
	thread Wave2Dialogue( player )
	thread Wave3Dialogue( player )
	thread BlastDoorTitansDialogue( player )
	thread EnterTunnelsDialogue( player )

	FlagWait( "StartFuelStorage" )
}

void function StartPoint_Setup_MilitiaBigCharge( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
	TeleportPlayerAndBT( "start_player_WallBombardment", "start_bt_WallBombardment" )

	thread SpawnFriendlyIntroTitans( false )
}

void function StartPoint_Skipped_MilitiaBigCharge( entity player )
{
	FlagSet( "SwapOLA" )
	FlagSet( "WallExplode" )
	SpawnBatteriesBehindDoor()
	RemoveExtraSmartAmmoRangeForRockets( player )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ███████╗██╗   ██╗███████╗██╗         ███████╗████████╗ ██████╗ ██████╗  █████╗  ██████╗ ███████╗
// ██╔════╝██║   ██║██╔════╝██║         ██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝ ██╔════╝
// █████╗  ██║   ██║█████╗  ██║         ███████╗   ██║   ██║   ██║██████╔╝███████║██║  ███╗█████╗
// ██╔══╝  ██║   ██║██╔══╝  ██║         ╚════██║   ██║   ██║   ██║██╔══██╗██╔══██║██║   ██║██╔══╝
// ██║     ╚██████╔╝███████╗███████╗    ███████║   ██║   ╚██████╔╝██║  ██║██║  ██║╚██████╔╝███████╗
// ╚═╝      ╚═════╝ ╚══════╝╚══════╝    ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_UndergroundFuelStorage( entity player )
{
	printt( "Start Point - Underground Fuel Storage" )

	StopMusicTrack( "music_tday_02_intro" )
	PlayMusic( "music_tday_03_arches" )

	thread FuelStoragePilotKillsDialogue( player )
	thread FuelStorageTitanSpawnedDialogue( player )
	thread FuelStorageSarahDialogue( player )

	FlagWait( "StartElevatorStartPoint" )
}

void function StartPoint_Setup_UndergroundFuelStorage( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
	TeleportPlayerAndBT( "start_player_UndergroundFuelStorage", "start_bt_UndergroundFuelStorage" )

	FlagWait( "EntitiesDidLoad" )
	file.sarahTitan.SetOrigin( < 1595, -4033, 277> )
	AddTriggeredPlayerFollower( player, file.sarahTitan )
}

void function StartPoint_Skipped_UndergroundFuelStorage( entity player )
{
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗
// ██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
// █████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝
// ██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗
// ███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║
// ╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_Elevator( entity player )
{
	printt( "Start Point - Elevator" )

	// Delete guys left outside now and stop reinforcements
	DestroyFriendliesAndStopReinforcements()

	array<entity> elevatorDoorMovers = GetEntArrayByScriptName( "tday_elevator_door_mover" )
	foreach ( mover in elevatorDoorMovers )
	{
		mover.AllowNPCGroundEnt( false )
	}

	waitthread PlayerAndSarahInElevator( player )

	// Enable the elevator clip that prevents you from falling off the elevator platform or leaving through the closing door
	GetEntByScriptName( "ElevatorClip" ).Solid()

	FlagSet( "ElevatorSequenceStarted" )

	// Disconnect navmesh and close the door
	FlagSet( "ElevatorDoor2Close" )
	FlagClear( "ElevatorDoor2NavToggle" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "ElevatorDoorSoundEnt" ).GetOrigin(), "TDay_UnderGroundFuel_HangarDoor_Close" )

	thread ElevatorDialogue( player )

	wait 2.5 // let the doors close a bit before moving the elevator

	FlagSet( "SkyboxSmoke" )

	// Move the elevator up
	waitthread ElevatorUp( player )
}

void function StartPoint_Setup_Elevator( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
	TeleportPlayerAndBT( "start_player_elevator", "start_bt_elevator" )

	FlagWait( "EntitiesDidLoad" )
	entity sarahStart = GetEntByScriptName( "Elevator_Sarah_Start" )
	file.sarahTitan.SetOrigin( sarahStart.GetOrigin() )
	file.sarahTitan.SetAngles( sarahStart.GetAngles() )
	thread AssaultMoveTarget( file.sarahTitan, GetEntByScriptName( "SarahElevatorNode" ) )
}

void function StartPoint_Skipped_Elevator( entity player )
{
	FlagSet( "SkyboxSmoke" )
}

void function ElevatorUp( entity player )
{
	FlagSet( "ElevatorUp" )

	entity topEnt = GetEntByScriptName( "ElevatorUpPos" )
	entity mover = GetEntByScriptName( "ElevatorMover" )
	mover.ChangeNPCPathsOnMove( true )

	entity clip = GetEntByScriptName( "elevator_clip" )

	TransitionNPCPathsForEntity( clip, topEnt.GetOrigin(), false )

	Remote_CallFunction_NonReplay( player, "ServerCallback_ElevatorRumble", 1 )

	EmitSoundOnEntity( mover, "TDay_UnderGroundFuel_Elevator_Start" )
	wait 0.4
	EmitSoundOnEntity( mover, "TDay_UnderGroundFuel_Elevator_Loop" )

	StopMusicTrack( "music_tday_03_arches" )
	PlayMusic( "music_tday_06_elevator" )

	Remote_CallFunction_NonReplay( player, "ServerCallback_ElevatorRumble", 2 )
	mover.NonPhysicsMoveTo( topEnt.GetOrigin(), 20.0, 2.0, 2.0 )

	wait 6.0

	FlagSet( "ElevatorGroundHatchOpen" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "ElevatorHatchSoundEnt" ).GetOrigin(), "TDay_UnderGroundFuel_HangarDoor_Open" )

	wait 13.8
	EmitSoundOnEntity( mover, "TDay_UnderGroundFuel_Elevator_Stop" )
	wait 0.2
	StopSoundOnEntity( mover, "TDay_UnderGroundFuel_Elevator_Loop" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_ElevatorRumble", 3 )

	TransitionNPCPathsForEntity( clip, topEnt.GetOrigin(), true )

	//file.sarahTitan.SetOrigin( < -7415, 3496, 1920 > )
}

void function ElevatorDialogue( entity player )
{
	// Here we go. Get ready, Pilot. Going up.
	waitthread PlayDialogue( "SARAH_GOING_UP", player )

	wait 2.5

	// That was the easy part.
	waitthread PlayDialogue( "SARAH_THAT_WAS_EASY_PART", player )

	wait 5.0

	// Well, you're doing a good job, Cooper. And as far as I'm concerned, you've earned your pilot certification.
	waitthread PlayDialogue( "SARAH_ELEVATOR_TALK1", player )

	wait 4.0

	// Now let's finish this thing and get home.
	waitthread PlayDialogue( "SARAH_ELEVATOR_TALK2", player )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗   ██╗████████╗ ██████╗ ██╗
// ██║   ██║╚══██╔══╝██╔═══██╗██║
// ██║   ██║   ██║   ██║   ██║██║
// ╚██╗ ██╔╝   ██║   ██║   ██║██║
//  ╚████╔╝    ██║   ╚██████╔╝███████╗
//   ╚═══╝     ╚═╝    ╚═════╝ ╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_VTOL( entity player )
{
	printt( "Start Point - VTOL" )

	array<entity> dropships = GetEntArrayByScriptName( "vtol_landed_dropship" )
	foreach( entity spawner in dropships )
		thread VTOL_Landed_Dropship_Think( spawner, player )

	entity ship = GetEntByScriptName( "hero_ola" )
	EmitSoundOnEntity( ship, "TDay_DistantOLA_Idle" )

	thread VTOLDialogue( player )
	thread VTOLBattleThink( player )
	thread VTOL_flyby1()

	FlagWait( "FireOnRunwayStartPoint" )
}

void function StartPoint_Setup_VTOL( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
	TeleportPlayerAndBT( "start_player_VTOL", "start_bt_VTOL" )

	FlagWait( "EntitiesDidLoad" )
	entity sarahStart = GetEntByScriptName( "VTOL_Sarah_Start" )
	file.sarahTitan.SetOrigin( sarahStart.GetOrigin() )
	file.sarahTitan.SetAngles( sarahStart.GetAngles() )
}

void function StartPoint_Skipped_VTOL( entity player )
{
	FlagSet( "VTOL" )
}

void function VTOLBattleThink( entity player )
{
	file.sarahTitan.kv.alwaysAlert = true

	// Reinable reinforcements and use the vtol friendly spawners instead of the intro spawners now
	FlagSet( "VTOL" )
	FlagSet( "ReinforcementsEnabled" )
	SetIdealFriendlyTitanCount( 3 )

	// Sarah does same path as other friendlies for this section
	RemoveTriggeredPlayerFollower( player, file.sarahTitan )
	thread AssaultMoveTarget( file.sarahTitan, GetEntByScriptName( "SarahVTOLPath" ) )

	printt( "--------" )
	printt( " WAVE 1 " )
	printt( "--------" )

	array<entity> enemyReapers
	array<entity> enemyTitans
	enemyReapers = SpawnFromSpawnerArray( GetEntArrayByScriptName( "vtol_reaper_spawner_line1" ) )
	enemyTitans = SpawnFromSpawnerArray( GetEntArrayByScriptName( "vtol_titan_spawner_line1" ) )

	// Enemies wont take any damage from friendlies until the player gets close. This keeps the battle from progressing without the player
	foreach( entity enemy in enemyReapers )
		enemy.ai.invulnerableToNPC = true
	foreach( entity enemy in enemyTitans )
		enemy.ai.invulnerableToNPC = true
	FlagWait( "PlayerEnteringVTOLFight" )
	ArrayRemoveDead( enemyReapers )
	ArrayRemoveDead( enemyTitans )
	foreach( entity enemy in enemyReapers )
		enemy.ai.invulnerableToNPC = false
	foreach( entity enemy in enemyTitans )
		enemy.ai.invulnerableToNPC = false

	CheckPoint()

	// Wait for wave 1 to be mostly killed off
	while( true )
	{
		ArrayRemoveDead( enemyReapers )
		ArrayRemoveDead( enemyTitans )

		//printt( "enemyReapers:", enemyReapers.len() )
		//printt( "enemyTitans:", enemyTitans.len() )

		// Various conditions that will start wave 2

		if ( enemyTitans.len() <= 1 )
			break

		if ( enemyTitans.len() <= 2 && enemyReapers.len() <= 1 )
			break

		if ( Flag( "vtol_player_pushed1" ) )
			break

		WaitFrame()
	}

	printt( "--------" )
	printt( " WAVE 2 " )
	printt( "--------" )

	FlagSet( "FriendlyPaths_VTOL_Advance1" ) // Friendlies move up

	CheckPoint()

	enemyReapers.extend( SpawnFromSpawnerArray( GetEntArrayByScriptName( "vtol_reaper_spawner_line2" ) ) )

	array<entity> wave2TitanSpawners = GetEntArrayByScriptName( "vtol_titan_spawner_line2" )
	wave2TitanSpawners.randomize()
	foreach( entity spawner in wave2TitanSpawners )
	{
		wait 0.2
		entity titan = spawner.SpawnEntity()
		DispatchSpawn( titan )
		enemyTitans.append( titan )
	}

	// Militia Forces, Arm up.
	thread PlayDialogue( "MILITIA_FORCES_ARM_UP", player )

	while( true )
	{
		ArrayRemoveDead( enemyTitans )

		if ( enemyTitans.len() <= 2 )
			break

		if ( Flag( "vtol_player_pushed2" ) )
			break

		WaitFrame()
	}

	printt( "--------" )
	printt( " WAVE 3 " )
	printt( "--------" )

	SetIdealFriendlyTitanCount( 3 )

	FlagSet( "FriendlyPaths_VTOL_Advance2" ) // Friendlies move up

	CheckPoint()

	enemyReapers.extend( SpawnFromSpawnerArray( GetEntArrayByScriptName( "vtol_reaper_spawner_line3" ) ) )
	enemyTitans.extend( SpawnFromSpawnerArray( GetEntArrayByScriptName( "vtol_titan_spawner_line3" ) ) )

	// We got incoming IMC Titans. Repeat. Incoming...
	thread PlayDialogue( "INCOMING_IMC_TITANS", player )

	wait 0.1

	// We're taking hits. We're surrounded.
	thread PlayDialogue( "TAKING_HITS_SURROUNDED", player )

	while( true )
	{
		ArrayRemoveDead( enemyTitans )

		if ( enemyTitans.len() <= 4 )
			FlagSet( "FriendlyPaths_VTOL_Advance3" ) // Friendlies move up

		if ( enemyTitans.len() <= 2 )
			break

		if ( Flag( "vtol_player_pushed3" ) )
			break

		WaitFrame()
	}

	printt( "--------" )
	printt( " WAVE 4 " )
	printt( "--------" )

	SetIdealFriendlyTitanCount( 2 )

	CheckPoint()

	// Sarah follows player again (using trigger system)
	AddTriggeredPlayerFollower( player, file.sarahTitan )

	// advance to 4 when all enemies in vtol are dead and we want to go to the elevated pre-tunnel area
	FlagSet( "FriendlyPaths_VTOL_Advance4" )
}

void function VTOLDialogue( entity player )
{
	FlagEnd( "FireOnRunwayStartPoint" )

	FlagWait( "SarahSeeOLADialogue" )

	// There she is. We still have time to intercept the Ark.
	PlayDialogue( "SARAH_THERES_THE_ARK", player )

	FlagWait( "SarahJoinedVTOLBattle" )

	// Move. Move. Incoming hostiles.
	PlayDialogue( "SARAH_MOVE_INCOMING_HOSTILES", player )

	FlagWait( "PlayerEnteringVTOLFight" )

	// [we got] IMC coming up from the east.
	PlayDialogue( "IMC_COMING_FROM_EAST", player )

	FlagWait( "vtol_player_pushed1" )

	// Keep pushing forward. We cannot let the Ark leave on that ship.
	PlayDialogue( "SARAH_KEEP_PUSHING_FORWARD", player )

	wait 5.0

	// Owl Twelve - taking heavy damage.
	PlayDialogue( "TAKING_HEAVY_DAMAGE", player )

	wait 4.0

	// Nice shooting - Keep moving.
	PlayDialogue( "SARAH_NICE_SHOOTING", player )

	FlagWait( "ClosingInOnDraconisDialogue" )

	StopMusicTrack( "music_tday_06_elevator" )
	StopMusicTrack( "music_tday_07_inbetweenfights" )
	PlayMusic( "music_tday_08_battletoship" )

	// We're closing on the Draconis. Keep going.
	thread PlayDialogue( "SARAH_CLOSING_IN_ON_DRACONIS", player )
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ███████╗██╗██████╗ ███████╗     ██████╗ ███╗   ██╗    ██████╗ ██╗   ██╗███╗   ██╗██╗    ██╗ █████╗ ██╗   ██╗
// ██╔════╝██║██╔══██╗██╔════╝    ██╔═══██╗████╗  ██║    ██╔══██╗██║   ██║████╗  ██║██║    ██║██╔══██╗╚██╗ ██╔╝
// █████╗  ██║██████╔╝█████╗      ██║   ██║██╔██╗ ██║    ██████╔╝██║   ██║██╔██╗ ██║██║ █╗ ██║███████║ ╚████╔╝
// ██╔══╝  ██║██╔══██╗██╔══╝      ██║   ██║██║╚██╗██║    ██╔══██╗██║   ██║██║╚██╗██║██║███╗██║██╔══██║  ╚██╔╝
// ██║     ██║██║  ██║███████╗    ╚██████╔╝██║ ╚████║    ██║  ██║╚██████╔╝██║ ╚████║╚███╔███╔╝██║  ██║   ██║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝     ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_FireontheRunway( entity player )
{
	SwapDraconisWithClientSideModel()
	AddTriggeredPlayerFollower( player, file.sarahTitan )
	thread DamagedTitansOnRunway( player )
	thread RunwayFriendlyDialogue( player )
	thread RunwaySarahDialogue( player )

	entity ship = GetEntByScriptName( "hero_ola" )
	StopSoundOnEntity( ship, "TDay_DistantOLA_Idle" )
	EmitSoundOnEntity( ship, "TDay_Runway_OLA_Idle" )

	CreateArkSequenceModels()

	FlagWait( "OlaLaunchStartPoint" )
}

void function StartPoint_Setup_FireontheRunway( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()
	TeleportPlayerAndBT( "start_player_FireontheRunway", "start_bt_FireontheRunway" )

	entity sarahStart = GetEntByScriptName( "Runway_Sarah_Start" )
	file.sarahTitan.SetOrigin( sarahStart.GetOrigin() )
	file.sarahTitan.SetAngles( sarahStart.GetAngles() )
}

void function StartPoint_Skipped_FireontheRunway( entity player )
{
	SwapDraconisWithClientSideModel()
	CreateArkSequenceModels()
}

void function RunwayFriendlyDialogue( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagWait( "RunwayFriendliesActive" )

	// Cardinal Three Seven, coming up the side.
	PlayDialogue( "FRIENDLY_TITAN_COMING_UP_SIDE", player )

	wait 2.0

	// Move. Move.
	PlayDialogue( "FRIENDLY_TITAN_MOVE_MOVE", player )

	wait 2.0

	// Sparrow 8 - Watch your six.
	PlayDialogue( "FRIENDLY_TITAN_WATCH_SIX", player )

	wait 6.0

	// They're hitting us bad.
	PlayDialogue( "FRIENDLY_TITAN_HITTING_US_BAD", player )

	wait 10.0

	// Cardinal Three Two, I got a lock. Taking the shot.
	PlayDialogue( "FRIENDLY_TITAN_TAKING_SHOT", player )

	wait 3.0

	// Splash...no effect on target. There's just too many of them.
	PlayDialogue( "FRIENDLY_TITAN_TOO_MANY_OF_THEM", player )
}

void function RunwaySarahDialogue( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagEnd( "OlaLaunchStartPoint" )

	// All Militia Forces, move in on the Draconis.
	waitthread PlayDialogue( "SARAH_MIL_FORCES_MOVE_IN", player )

	FlagWait( "OlaThrustersOn" )

	// The Draconis is almost fueled. Move. Move.
	waitthread PlayDialogue( "SARAH_ALMOST_FUELED", player )

	// Their escort is here. We don't have much time.
	waitthread PlayDialogue( "SARAH_ESCORT_IS_HERE", player )

	// They're powering up.
	waitthread PlayDialogue( "FRIENDLY_TITAN_POWERING_UP", player )

	FlagWait( "OlaAfterburnersOn" )

	// Final launch checks complete. All systems go.
	waitthread PlayDialogue( "IMC_PILOT_LAUNCH_CHECKS_COMPLETE", player )

	// They're taking off. We need to get to that ship.
	waitthread PlayDialogue( "SARAH_THEYRE_TAKING_OFF", player )

	// Move. Don't let them get away.
	waitthread PlayDialogue( "FRIENDLY_TITAN_DONT_LET_THEM", player )

	wait 10.0

	// Let’s go Pilot, we have no other options. We NEED to catch that ship.
	thread PlayDialogue( "SARAH_CATCH_THAT_SHIP", player )

	wait 10.0

	// They're getting away.
	thread PlayDialogue( "FRIENDLY_TITAN_GETTING_AWAY", player )
}

void function DamagedTitansOnRunway( entity player )
{
	array<entity> spawners = GetEntArrayByScriptName( "runway_titan_spawner" )
	foreach( entity spawner in spawners )
	{
		entity titan = spawner.SpawnEntity()
		DispatchSpawn( titan )

		entity target = spawner.GetLinkEnt()
		Assert( IsValid( target ) )
		entity bullseye = SpawnBullseye( TEAM_MILITIA )
		bullseye.SetOrigin( target.GetOrigin() )

		thread DamagedRunwayTitanThink( titan, bullseye, player )
	}
}

void function DamagedRunwayTitanThink( entity titan, entity bullseye, entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( titan, "OnDeath" )
	EndSignal( titan, "OnDamaged" )

	EndSignal( level, "RunwayTitansEngage" )

	OnThreadEnd(
		function() : ( titan, bullseye, player )
		{
			printt( "TITAN STOPPING SCRIPTED COMBAT ON RUNWAY" )
			if ( IsValid( bullseye ) )
				bullseye.Destroy()
			Signal( level, "RunwayTitansEngage" )
			if ( IsValid( titan ) && IsValid( player ) )
			{
				titan.SetEnemy( player )
				titan.AssaultSetGoalRadius( 3000 )
			}
		}
	)

	titan.AssaultPoint( titan.GetOrigin() )
	titan.AssaultSetGoalRadius( 256 )
	titan.LockEnemy( bullseye )

	// 1800 units they will stop doing scripted combat
	while( Distance( player.GetOrigin(), titan.GetOrigin() ) > 1800 )
		WaitFrame()
}

void function RunwayFriendlies()
{
	FlagWait( "RunwayFriendliesActive" )

	FlagSet( "ReinforcementsEnabled" )
	SetIdealFriendlyTitanCount( 4 )
}

// -------------------------------------------------------------------------------------------------------------------------
//
//  ██████╗ ██╗      █████╗     ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗
// ██╔═══██╗██║     ██╔══██╗    ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║
// ██║   ██║██║     ███████║    ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║
// ██║   ██║██║     ██╔══██║    ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║
// ╚██████╔╝███████╗██║  ██║    ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║
//  ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_OLALaunch( entity player )
{
	waitthread ArkSequence( player )

	StopMusicTrack( "music_tday_09_downthestep" )
	PlayMusic( "music_tday_10_platform" )

	FlagWaitWithTimeout( "OLATakeoff", 3.0 )

	//thread PlayerBlastedBack( player )
	thread OlaTakeOff( player )
	thread MaltaEscort()
}

void function StartPoint_Setup_OLALaunch( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	entity start_player_OLALaunch = GetEntByScriptName( "start_player_OLALaunch" )
	entity start_bt_OLALaunch = GetEntByScriptName( "start_bt_OLALaunch" )
	start_player_OLALaunch.SetOrigin( start_player_OLALaunch.GetOrigin() + <0,0,32> )
	start_bt_OLALaunch.SetOrigin( start_bt_OLALaunch.GetOrigin() + <0,0,32> )

	TeleportPlayerAndBT( "start_player_OLALaunch", "start_bt_OLALaunch" )

	FlagSet( "OlaThrustersOn" )
	FlagSet( "OlaAfterburnersOn" )
}

void function StartPoint_Skipped_OLALaunch( entity player )
{
}


void function PlayerBlastedBack( entity player )
{
	EndSignal( player, "OnDeath" )

	array<entity> nodes = GetEntArrayByScriptName( "ola_blast_node" )
	entity node = GetClosest( nodes, player.GetOrigin(), 750 )

	bool doBlast = IsValid( node )// && player.IsTitan()

	if ( doBlast )
	{
		player.ContextAction_SetBusy()
		player.DisableWeapon()

		entity animNode = CreateScriptMover()
		animNode.SetOrigin( player.GetOrigin() )
		animNode.SetAngles( player.GetAngles() )

		FirstPersonSequenceStruct sequence

		if ( player.IsTitan() )
		{
			sequence.firstPersonAnim = "btpov_tday_ending_chase"
			sequence.thirdPersonAnim = "BT_TDay_ending_chase"
		}
		else
		{
			sequence.firstPersonAnim = "ptpov_s2s_end_fight_knockback"
			sequence.thirdPersonAnim = "pt_s2s_end_fight_knockback"
		}

		sequence.viewConeFunction = ViewConeTight
		sequence.teleport = true
		sequence.blendTime = 0.0

		float moveTime = 1.5
		animNode.NonPhysicsMoveTo( node.GetOrigin(), moveTime, moveTime, 0.0 )
		animNode.NonPhysicsRotateTo( node.GetAngles(), moveTime, moveTime, 0.0 )

		thread FirstPersonSequence( sequence, player, animNode )
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_BlastedBackRumble" )

	PlayMusic( "music_tday_11_theygotaway" )
	FlagSet( "fx_draconis_blast" )
	FlagSet( "CrateBlast" )

	WaittillAnimDone( player )

	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.ClearParent()
	player.EnableWeapon()
}

void function OlaTakeOff( entity player )
{
	entity ship = GetEntByScriptName( "hero_ola" )
	entity node = GetEntByScriptName( "arc_loading_node" )

	//thread PlayAnim( ship, "draconis_tday_takeoff", node )
	FlagClear( "fx_draconis_coolant" )

	wait 6.6

	// Get to a ship. We're going after 'em.
	waitthread PlayDialogue( "SARAH_GOING_AFTER_THEM", player )

	EndTday()
}

void function SeeBadGeoFailsafe( entity player )
{
	FlagWait( "OlaLaunch_ClimbedRamp" )
	wait 2.0

	EndTday()
}

void function EndTday()
{
	if ( Flag( "BadGeoFailsafe" ) )
		return
	FlagSet( "BadGeoFailsafe" )

	thread PickStartPoint( "sp_s2s", "Level Start" )
}

void function MaltaEscort()
{
	entity startNode = GetEntByScriptName( "malta_track" )
	entity endNode = startNode.GetLinkEnt()
	vector angles = VectorToAngles( endNode.GetOrigin() - startNode.GetOrigin() )

	entity ship = CreateExpensiveScriptMoverModel( SKYBOX_MALTA, startNode.GetOrigin(), angles, 0, 100000 )
	ship.DisableHibernation()

	float speed = 5.0
	float moveTime = Distance( startNode.GetOrigin(), endNode.GetOrigin() ) / speed
	ship.NonPhysicsMoveTo( endNode.GetOrigin(), moveTime, 0.0, 0.0 )
}

// -------------------------------------------------------------------------------------------------------------------------
//
//
// -------------------------------------------------------------------------------------------------------------------------

void function TitanBaySequence( asset titanModel, asset pilotModel, string weaponName, string rackAnim, string titanAnim, string pilotAnim, string marvinAnim )
{
	entity shipNode = GetEntByScriptName( "intro_ship_node" )

	entity pilot
	entity rack = CreatePropDynamic( DROP_RACK_MODEL )
	entity titan = CreatePropDynamic( titanModel )
	titan.SetSkin( 1 )
	if ( pilotAnim != "" )
		pilot = CreatePropDynamic( pilotModel )
	entity marvin = CreatePropDynamic( MARVIN_MODEL )
	asset weaponAsset = GetWeaponInfoFileKeyFieldAsset_Global( weaponName, "playermodel" )
	entity weapon = CreatePropDynamic( weaponAsset )

	weapon.SetParent( titan, "propgun", false, 0.0 )

	thread PlayAnimTeleport( rack, rackAnim, shipNode )
	if ( IsValid( pilot ) )
		thread PlayAnimTeleport( pilot, pilotAnim, shipNode )
	thread PlayAnimTeleport( marvin, marvinAnim, shipNode )
	waitthread PlayAnimTeleport( titan, titanAnim, shipNode )

	rack.Destroy()
	titan.Destroy()
	if ( IsValid( pilot ) )
		pilot.Destroy()
	marvin.Destroy()
	weapon.Destroy()
}

void function IntroSequence( entity player )
{
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	entity shipNode = GetEntByScriptName( "intro_ship_node" )
	entity groundNode = GetEntByScriptName( "landing_node" )
	entity player_rack = CreatePropDynamic( DROP_RACK_MODEL )
	entity grunt = CreatePropDynamic( TEAM_MIL_GRUNT_MODEL_SMG )
	entity marvin = CreatePropDynamic( MARVIN_MODEL )
	marvin.SetSkin(1)
	entity sarahPilot = CreatePropDynamic( SARAH_HUMAN_MODEL )

	// Parent ents to the shipNode so they move with the ship
	array<entity> doorMovers = GetEntArrayByScriptName( "dropship_floor_movers" )
	foreach ( entity doorMover in doorMovers )
	{
		doorMover.SetParent( shipNode, "", true )
	}

	sarahPilot.SetOrigin( file.sarahTitan.GetOrigin() )

	WaitFrame() // why?? -mackey (because game crashes if I remove this.

	if ( GetBugReproNum() != 188170 )
		WaitFrame()

	player.ContextAction_SetBusy()
	player.DisableWeapon()

	EmitSoundOnEntity( player, "TDay_Amb_Int_LaunchBay" )
	Remote_CallFunction_NonReplay( player, "ServerCallback_IntroScreenShakes" )

	thread PlayAnimTeleport( bt, "BT_TDay_drop_player_start", shipNode )
	thread PlayAnimTeleport( player_rack, "rack_TDay_drop_rack", shipNode )
	thread PlayAnimTeleport( grunt, "pt_TDay_drop_grunt_A", shipNode )
	thread PlayAnimTeleport( marvin, "mv_TDay_drop_marvin_A", shipNode )
	thread PlayAnimTeleport( file.sarahTitan, "BT_TDay_drop_sarah", shipNode )
	thread PlayAnimTeleport( sarahPilot, "pt_TDay_drop_sarah", file.sarahTitan, "hijack" )

	// Other titan bays animate
	thread TitanBaySequence( BUDDY_MODEL, PILOT_DROZ, file.friendlyTitanPrimaries[0], "rack_TDay_drop_rack1", "bt_TDay_drop_titan1", "pt_TDay_drop_pilot1", "mv_TDay_drop_marvin1" )
	thread TitanBaySequence( BUDDY_MODEL, PILOT_GATES, file.friendlyTitanPrimaries[1], "rack_TDay_drop_rack2", "bt_TDay_drop_titan2", "pt_TDay_drop_pilot2", "mv_TDay_drop_marvin2" )
	thread TitanBaySequence( BUDDY_MODEL, PILOT_DROZ, file.friendlyTitanPrimaries[2], "rack_TDay_drop_rack3", "bt_TDay_drop_titan3", "", "mv_TDay_drop_marvin3" )
	thread TitanBaySequence( BUDDY_MODEL, PILOT_GATES, file.friendlyTitanPrimaries[3], "rack_TDay_drop_rack4", "bt_TDay_drop_titan4", "", "mv_TDay_drop_marvin4" )

	thread IntroEffectsAndDoors( player )
	thread TitanfallChargeupSounds( player )
	thread TitanfallDropSounds( player )

	//#####################################################
	// Inside the ship sequence
	//#####################################################

	DisableWeapons( player, [] )

	AddCinematicFlag( player, CE_FLAG_INTRO )
	FirstPersonSequenceStruct sequence_start
	sequence_start.firstPersonAnim = "ptpov_TDay_drop_player_start"
	sequence_start.thirdPersonAnim = "pt_TDay_drop_player_start"
	sequence_start.viewConeFunction = ViewConeTDay //ViewConeZeroInstant
	sequence_start.attachment = "hijack"
	sequence_start.teleport = true
	sequence_start.blendTime = 0.0
	sequence_start.useAnimatedRefAttachment = true
	bt.Anim_AdvanceCycleEveryFrame( true )
//	for ( int i = 0; i < 5; i++ )
//	{
//		thread FirstPersonSequence( sequence_start, player, bt )
//		WaitFrame()
//		player.ClearParent()
//		WaitFrame()
//	}

	waitthread FirstPersonSequence( sequence_start, player, bt )

	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.ClearParent()

	// Player becomes the titan when the hatch closes
	ForceScriptedEmbark( player, bt )
	Assert( player.IsTitan() )
	bt.Destroy()
	player.DisableWeapon()
	RemoveCinematicFlag( player, CE_FLAG_INTRO )

	//#####################################################

	FlagSet( "PlayerTitanFallBegin" )

	//#####################################################
	// Drop anim for player and Sarah's titan
	//#####################################################

	float dropAnimDuration = player.GetSequenceDuration( "BT_TDay_drop_player_end_nodelta" )
	float cycleStartDrop = player.GetScriptedAnimEventCycleFrac( "BT_TDay_drop_player_end_nodelta", "drop_start" )
	float startDropTime = dropAnimDuration * cycleStartDrop
	float cycleStopDrop = player.GetScriptedAnimEventCycleFrac( "BT_TDay_drop_player_end_nodelta", "drop_end" )
	float stopDropTime = dropAnimDuration * cycleStopDrop
	float dropDuration = stopDropTime - startDropTime
	Assert( cycleStartDrop >= 0 )
	Assert( cycleStopDrop >= 0 )

	entity mover = CreateScriptMover( shipNode.GetOrigin(), shipNode.GetAngles() )

	FirstPersonSequenceStruct sequence_end
	sequence_end.firstPersonAnim = "BTpov_TDay_drop_player_end_nodelta"
	sequence_end.thirdPersonAnim = "BT_TDay_drop_player_end_nodelta"
	sequence_end.viewConeFunction = ViewConeTDayZero
	sequence_end.blendTime = 0.0
	thread PlayerDropImpactEffect( player )
	thread FirstPersonSequence( sequence_end, player, mover )

	wait startDropTime

	Remote_CallFunction_NonReplay( player, "ServerCallback_DropLaunchScreenShake" )

	player.PlayerCone_SetMinPitch( 10 )

	// Enable DVS again
	SetConVarFloat( "dvs_scale_min", file.dvsDefault )
	FlagSet( "ShipIntroEnded" )

	// drop player down to ground
	vector moverPlayerOffset = player.GetOrigin() - mover.GetOrigin()
	vector moveToPos = groundNode.GetOrigin() - moverPlayerOffset + <0,0,8>
	mover.NonPhysicsMoveTo( moveToPos, dropDuration, 0.0, 0.0 )

	float offset = 0.85

	wait offset

	player.PlayerCone_SetMinPitch( -30 ) // allow look up after we clear the part that has visual defects in the sky -Mackey

	wait dropDuration - offset

	Remote_CallFunction_NonReplay( player, "ServerCallback_LandingImpactScreenShake" )

	// wait for anim to finish
	WaittillAnimDone( player )

	//#####################################################

	FlagSet( "PlayerTitanFallEnd" )

	//#####################################################

	EnableWeapons( player, [] )

	player.ClearParent()
	player.EnableWeapon()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()

	FlagSet( "TurretsAllowShootRocks" )

	//#####################################################
	// Move the ship out of this skybox so we don't see it
	//#####################################################

	entity shipEndNode = GetEntByScriptName( "intro_ship_hide_position" )
	player_rack.Destroy()
	grunt.Destroy()
	marvin.Destroy()
	sarahPilot.Destroy()
	FlagClear( "IntroShipOrangeLightsOn" )
	FlagClear( "IntroShipBlueLightsOn" )
	shipNode.SetOrigin( shipEndNode.GetOrigin() )
}

void function TitanfallChargeupSounds( entity player )
{
	WaitSignal( player, "TitanfallChargeupSounds" )
	EmitSoundOnEntity( player, "TDay_Intro_TitanFall_ChargeUp" )
}

void function TitanfallDropSounds( entity player )
{
	WaitSignal( player, "TitanfallDropSounds" )
	EmitSoundOnEntity( player, "TDay_Intro_TitanFall_Launch" )
	EmitSoundOnEntity( player, "TDay_Intro_TitanFall_Falling" )
}

void function PlayerDropImpactEffect( entity player )
{
	// Wait for signal via anim event
	WaitSignal( player, "PlayerTitanfallImpact" )

	EmitSoundOnEntity( player, "TDay_Intro_TitanFall_Impact" )

	vector drop_offset = player.GetOrigin() + <25,50,0>

	StartParticleEffectInWorld( GetParticleSystemIndex( PLAYER_DROP_LAND_EFFECT ), drop_offset, <0,0,0> )
}

void function IntroEffectsAndDoors( entity player )
{
	entity shipNode = GetEntByScriptName( "intro_ship_node" )

	// Blue lights on
	FlagSet( "IntroShipBlueLightsOn" )

	wait 16.0

	// Blue lights off, orange lights on
	FlagSet( "IntroShipOrangeLightsOn" )
	FlagClear( "IntroShipBlueLightsOn" )

	FlagSet( "StartIntroShipFlyPath" )

	EmitSoundOnEntity( player, "TDay_Intro_LaunchAlarm" )

	wait 2.0

	// Open the drop doors
	FlagSet( "OpenDropDoors" )

	// Door opening effects
	FlagSet( "fx_tday_ship_interior_door" )

	EmitSoundOnEntity( player, "TDay_Intro_LaunchDoor_Open" )
	EmitSoundOnEntity( GetEntByScriptName( "intro_ship_node" ), "TDay_Intro_LaunchDoor_Wind" )
}

void function IntroTurrets( entity player )
{
	array<entity> mainTargets
	mainTargets.extend( GetEntArrayByScriptName( "turret_target_rocks" ) )
	mainTargets.extend( GetEntArrayByScriptName( "turret_target_sky" ) )

	array<entity> leftTargets = GetEntArrayByScriptName( "turret_target_left" )
	array<entity> tunnelTargets = GetEntArrayByScriptName( "turret_target_tunnel" )

	// Spawn each turret
	array<entity> turretSpawners = GetEntArrayByScriptName( "wall_turret_spawner" )
	Assert( turretSpawners.len() > 0 )
	foreach( entity spawner in turretSpawners )
		SpawnIntroTurret( spawner, mainTargets, player, true )

	array<entity> turretSpawnersLeft = GetEntArrayByScriptName( "wall_turret_spawner_left" )
	Assert( turretSpawnersLeft.len() > 0 )
	foreach( entity spawner in turretSpawnersLeft )
		SpawnIntroTurret( spawner, leftTargets, player, true )

	array<entity> turretSpawnersTunnel = GetEntArrayByScriptName( "tunnel_turret" )
	Assert( turretSpawnersTunnel.len() > 0 )
	foreach( entity spawner in turretSpawnersTunnel )
		SpawnIntroTurret( spawner, tunnelTargets, player, false )

	thread TurretsShootPlayer( player )
}

void function TurretsShootPlayer( entity player )
{
	EndSignal( player, "OnDeath" )
	FlagEnd( "WallExplode" )

	while( true )
	{
		FlagWait( "TurretDeadZone" )

		file.turretDeathTargets.append( player )
		Signal( level, "NewTurretDeathTarget" )

		while( Flag( "TurretDeadZone" ) )
		{
			entity turret = file.introTurrets.getrandom()
			player.TakeDamage( player.GetMaxHealth() * 0.085, turret, turret, { damageSourceId=eDamageSourceId.mp_weapon_turretplasma_mega } )
			wait 0.1
		}

		if ( file.turretDeathTargets.contains( player ) )
			file.turretDeathTargets.fastremovebyvalue( player )
	}
}

void function SpawnIntroTurret( entity spawner, array<entity> targets, entity player, bool shootsPlayerAndDestroysOnWallDeath )
{
	entity turret = spawner.SpawnEntity()
	turret.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	turret.SetInvulnerable()
	DispatchSpawn( turret )

	if ( shootsPlayerAndDestroysOnWallDeath )
		file.introTurrets.append( turret )

	// Assign each turret a different weapon mod so they can play different fire sounds to help audio
	table kvs = spawner.GetSpawnEntityKeyValues()
	PrintTable( kvs )
	string weaponMod = "SoundGroupA"
	if ( "soundGroup" in kvs )
	{
		switch ( turret.kv.soundGroup )
		{
			case "a":
				weaponMod = "SoundGroupA"
				break
			case "b":
				weaponMod = "SoundGroupB"
				break
			case "c":
				weaponMod = "SoundGroupC"
				break
			default:
				Assert( 0 )
				break
		}
	}

	thread IntroTurretThink( turret, weaponMod, targets, player, shootsPlayerAndDestroysOnWallDeath )
}

void function IntroTurretThink( entity turret, string weaponMod, array<entity> _targets, entity player, bool shootsPlayerAndDestroysOnWallDeath )
{
	EndSignal( turret, "OnDeath" )
	FlagEnd( "WallExplode" )

	if ( turret.HasKey( "script_noteworthy" ) && turret.GetValueForKey( "script_noteworthy" ) == "destroy_on_wall_explosion" )
		thread TurretExplodesWithWall( turret )

	array<entity> targets = clone _targets

	entity mover = CreateScriptMover()
	entity bullseye = SpawnBullseye( TEAM_MILITIA )
	bullseye.SetParent( mover, "", false )
	mover.SetOrigin( targets.getrandom().GetOrigin() )

	OnThreadEnd(
		function() : ( turret, mover, bullseye, shootsPlayerAndDestroysOnWallDeath )
		{
			if ( shootsPlayerAndDestroysOnWallDeath )
			{
				bullseye.Destroy()
				mover.Destroy()

				if ( IsValid( turret ) )
				{
					turret.ClearInvulnerable()
					turret.TakeDamage( turret.GetHealth() + 1, null, null, null )
				}
			}
		}
	)

	turret.LockEnemy( bullseye )

	turret.SetNoTarget( true )
	turret.SetInvulnerable()
	turret.TakeActiveWeapon()

	turret.GiveWeapon( "mp_weapon_turret_tday", [ weaponMod ] )

	float moveTime
	float holdTime

	while( IsValid( turret ) )
	{
		entity target

		// Shoot at a turret death target if there is one, these have priority
		ArrayRemoveInvalid( file.turretDeathTargets )
		if ( file.turretDeathTargets.len() > 0 )
			target = file.turretDeathTargets.getrandom()

		if ( shootsPlayerAndDestroysOnWallDeath && !Flag( "PlayerIntroCover" ) && Flag( "PlayerWarnedAboutTakingCover" ) )
		{
			target = player
			//DebugDrawLine( turret.GetOrigin(), target.GetOrigin(), 255, 0, 0, true, 0.25 )
			mover.NonPhysicsMoveTo( target.GetWorldSpaceCenter(), 0.2, 0, 0 )
			wait 0.2
			continue
		}

		if ( !IsValid( target ) )
			target = targets.getrandom()

		if ( Flag( "TurretsAllowShootRocks" ) && target.GetScriptName() != "turret_target_rocks" )
		{
			WaitFrame() // this exists just to prevent an infinite loop in the case we keep randomly getting a rock target before the turret is allowed to shoot at them
			continue
		}

		if ( !Flag( "TurretsAllowShootRocks" ) && target.GetScriptName() == "turret_target_rocks" )
		{
			WaitFrame() // this exists just to prevent an infinite loop in the case we keep randomly getting a rock target before the turret is allowed to shoot at them
			continue
		}

		moveTime = RandomFloatRange( 1.0, 3.0 )
		holdTime = RandomFloat( 1.5 )
		mover.NonPhysicsMoveTo( target.GetOrigin(), moveTime, moveTime * 0.33, moveTime * 0.33 )
		//DebugDrawLine( turret.GetOrigin(), target.GetOrigin(), 255, 0, 0, true, moveTime + holdTime )

		waitthread TurretWaitForNextTarget( moveTime + holdTime )
	}
}

void function TurretExplodesWithWall( entity turret )
{
	entity mover = CreateScriptMover( turret.GetOrigin(), <0,0,0> )
	turret.SetParent( mover, "", true )

	FlagWait( "WallExplode" )
	wait 1.0

	float fallTime = 3.0
	mover.NonPhysicsMoveTo( mover.GetOrigin() - <0,0,800>, fallTime, fallTime, 0.0 )
	mover.NonPhysicsRotateTo( mover.GetAngles() + <40, 30, 20>, fallTime, fallTime, 0.0 )
	wait fallTime
	if ( IsValid( turret ) )
		turret.Destroy()

	if ( IsValid( mover ) )
		mover.Destroy()
}

void function TurretWaitForNextTarget( float duration )
{
	EndSignal( level, "NewTurretDeathTarget" )
	wait duration
}

void function SpawnFriendlyIntroTitans( bool hotDrop )
{
	int hotDropValue = hotDrop ? 4 : 0
	foreach ( entity spawner in file.friendlyTitanSpawners_Intro )
	{
		spawner.kv.script_hotdrop = hotDropValue
	}

	// Spawn order: 3, 5, 1, 4, 6, 2
	// index order means: 2, 4, 0, 3, 5, 1
	entity titan

	file.meleeFriendly2 = SpawnFriendlyTitan( file.friendlyTitanSpawners_Intro[2] )
	file.meleeFriendly2.SetInvulnerable()
	if ( hotDrop )
		wait 1.05
	titan = SpawnFriendlyTitan( file.friendlyTitanSpawners_Intro[4] )
	titan.SetInvulnerable()
	if ( hotDrop )
		wait 0.234
	titan = SpawnFriendlyTitan( file.friendlyTitanSpawners_Intro[0] )
	titan.SetInvulnerable()
	if ( hotDrop )
		wait 0.75
	file.meleeFriendly3 = SpawnFriendlyTitan( file.friendlyTitanSpawners_Intro[3] )
	file.meleeFriendly3.SetInvulnerable()
	if ( hotDrop )
		wait 0.191
	titan = SpawnFriendlyTitan( file.friendlyTitanSpawners_Intro[5] )
	titan.SetInvulnerable()
	if ( hotDrop )
		wait 0.226
	file.meleeFriendly1 = SpawnFriendlyTitan( file.friendlyTitanSpawners_Intro[1] )
	file.meleeFriendly1.SetInvulnerable()
}

entity function SpawnFriendlyTitan( entity spawner )
{
	entity titan = spawner.SpawnEntity()
	DispatchSpawn( titan )
	titan.kv.alwaysAlert = 1
	//titan.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	titan.SetValidHealthBarTarget( false )
	titan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )

	titan.kv.WeaponProficiency = eWeaponProficiency.AVERAGE
	MakeMidHealthTitan( titan )

	// Assign a loadout
	string primary = file.friendlyTitanPrimaries[file.friendlyTitanPrimaryIndex]
	TitanLoadoutDef loadout = expect TitanLoadoutDef( GetTitanLoadoutForPrimary( primary ) )
	loadout.setFile = "titan_buddy"
	TakeAllWeapons( titan )
	GiveTitanLoadout( titan, loadout )

	file.friendlyTitanPrimaryIndex++
	if ( file.friendlyTitanPrimaryIndex >= file.friendlyTitanPrimaries.len() )
		file.friendlyTitanPrimaryIndex = 0

	// Skin
	titan.SetSkin( 1 )

	thread DisableTitanName( titan )
	DisableTitanRodeo( titan ) // no rodeo for vanguard class titans (which all friendlies are)

	thread FriendlyTitanDeathDialogue( titan )

	file.friendlyTitans.append( titan )

	return titan
}

void function DisableTitanName( entity titan )
{
	if ( !IsValid( titan ) )
		return

	EndSignal( titan, "OnDeath" )
	EndSignal( titan, "OnDestroy" )

	WaitSignalTimeout( titan, 1.0, "TitanHotDropComplete" )
	titan.SetNameVisibleToFriendly( false )
}

void function SpawnIntroDropships( bool full )
{
	entity spawner1 = GetEntByScriptName( "wallarena_dropship_grunt_M1" ) // strafe
	entity spawner2 = GetEntByScriptName( "wallarena_dropship_grunt_M3" ) // dive

	if ( full )
	{
		thread SpawnFromDropship( spawner1 )
		wait 7.0
	}

	thread ShipForceDeath( spawner2, 7.0 )
	thread SpawnFromDropship( spawner2 )
}

void function ShipForceDeath( entity spawner, float delay )
{
	table dropshipSpawned = WaitSignal( spawner, "OnSpawned" )
	entity dropship = expect entity( dropshipSpawned.dropship )

	if ( !IsValid( dropship ) )
		return

	EndSignal( dropship, "OnDeath" )
	EndSignal( dropship, "OnDestroy" )

	wait delay - 2.5

	file.turretDeathTargets.append( dropship )
	Signal( level, "NewTurretDeathTarget" )

	wait 2.5

	dropship.TakeDamage( dropship.GetHealth() + 1, null, null, null )
}

void function IntroArmada()
{
	array<entity> ships = GetEntArrayByScriptName( "skybox_armada_ship" )
	foreach( entity ship in ships )
	{
		ship.DisableHibernation()
		vector start = ship.GetOrigin() + ( ship.GetForwardVector() * RandomFloatRange( -10, -30 ) )
		vector end = ship.GetOrigin() + ( ship.GetForwardVector() * 500 )
		ship.SetOrigin( start )
		thread ArmadaShipFly( ship, end )
	}
}

void function ArmadaShipFly( entity ship, vector endPos )
{
	float moveSpeed = 5.0 * RandomFloatRange( 0.7, 1.3 )
	float d = Distance( ship.GetOrigin(), endPos )
	float moveTime = d / moveSpeed

	entity mover = CreateScriptMover( ship.GetOrigin() )
	ship.SetParent( mover, "", true )
	mover.NonPhysicsMoveTo( endPos, moveTime, 0.0, 0.0 )
	wait moveTime
	ship.Destroy()
	mover.Destroy()
}

void function IntroAttackHornets()
{
	wait 10
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node1", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 2.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node2", "st_tday_strafe_far", 			"TDay_Stratton_Strafe_Far" )
	wait 3.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node3", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 2.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node1", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 2.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node2", "st_tday_strafe_far", 			"TDay_Stratton_Strafe_Far" )
	wait 2.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node1", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 3.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node2", "st_tday_strafe_far", 			"TDay_Stratton_Strafe_Far" )
	wait 4.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node3", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 2.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node1", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 4.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node2", "st_tday_strafe_far", 			"TDay_Stratton_Strafe_Far" )
	wait 3.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node1", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 2.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node2", "st_tday_strafe_far", 			"TDay_Stratton_Strafe_Far" )
	wait 3.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node3", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
	wait 2.0
	thread AttackShipPlayAnim( HORNET_MODEL, "intro_air_support_node1", "st_tday_strafe_close_alt", 	"TDay_Stratton_Strafe_Close_Alt" )
}

void function AttackShipPlayAnim( asset model, string nodeScriptName, string anim, string soundAlias )
{
	entity node = GetEntByScriptName( nodeScriptName )
	entity ship = CreatePropDynamic( model )

	thread PlayAnimTeleport( ship, anim, node )

	EmitSoundOnEntity( ship, soundAlias )

	// Wait for missile barrage
	WaitSignal( ship, "MissileControlRoom" )

	array<entity> targets = GetEntArrayByScriptName( "wall_missile_target" )
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

	StartParticleEffectInWorld( GetParticleSystemIndex( MISSILE_EXPLOSION ), destination, <0,0,0> )
	EmitSoundAtPosition( TEAM_UNASSIGNED, destination, "Beacon_Straton_MissileFire_RocketExplo" )
	missile.Destroy()
}

/*
void function TitanfallTracers()
{
	FlagEnd( "WallStartPoint" )

	array<entity> tracerStarts = GetEntArrayByScriptName( "turret_pos" )
	vector targetTopPos = GetEntByScriptName( "turret_target_top" ).GetOrigin()
	vector targetBottomPos = GetEntByScriptName( "turret_target_bottom" ).GetOrigin()

	while( true )
	{
		vector start = tracerStarts.getrandom().GetOrigin()
		vector end = < RandomFloatRange( targetBottomPos.x, targetTopPos.x ), RandomFloatRange( targetBottomPos.y, targetTopPos.y ), RandomFloatRange( targetBottomPos.z, targetTopPos.z ) >
		thread TracerFire( start, end )
		wait RandomFloatRange( 0.0, 0.1 )
	}
}
*/

void function TracerFire( vector start, vector end )
{
	vector angles = VectorToAngles( end - start )

	entity projectile = CreateScriptMoverModel( ROCKET_MODEL, start, angles, 0, 99999 )
	projectile.DisableHibernation()
	StartParticleEffectOnEntity( projectile, GetParticleSystemIndex( ROCKET_TRAIL_EFFECT ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	float duration = RandomFloatRange( 2.0, 3.5 )
	projectile.NonPhysicsMoveTo( end, duration, 0.0, 0.0 )
	wait duration
	projectile.Destroy()
}

void function WallBombardmentDialogue( entity player )
{
	// Get to cover Cooper! We're taking down that wall!
	PlayDialogue( "SARAH_GET_TO_COVER_COOPER", player )

	// Watch out for the cannons!
	PlayDialogue( "WATCH_FOR_CANNONS", player )

	FlagSet( "PlayerWarnedAboutTakingCover" )

	// Unless we take out those cannons, we're not getting any closer to that ship!
	PlayDialogue( "SARAH_UNLESS_TAKE_OUT_CANNONS", player )

	// Wilson in position.
	PlayDialogue( "WILSON_IN_POSITION", player )

	// Grenier good to go.
	PlayDialogue( "GRENIER_GOOD_TO_GO", player )

	// All Acolyte pods locked and loaded.
	PlayDialogue( "ACOLYTE_PODS_READY", player )

	// This is Commander Briggs. Go weapons free - Fire!!!!
	thread PlayDialogue( "SARAH_WEAPONS_FREE_FIRE", player )

	wait 2.0
	FlagSet( "TitanFireAtWall" )

	// Open fire!
	PlayDialogue( "OPEN_FIRE", player )
}

void function MissileBarrageSounds()
{
	entity mover = GetEntByScriptName( "MissileBarrageSoundMover" )
	Assert( IsValid( mover ) )

	FlagWait( "TitanFireAtWall" )

	wait 1.5

	EmitSoundOnEntity( mover, "TDay_MilitiaCharge_MissileTrail" )
	FlagSet( "MissileBarrageSoundMoverGo" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "MissileBarrageLeft" ).GetOrigin(), "TDay_MilitiaCharge_MissileBarrage_Left" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "MissileBarrageCenter" ).GetOrigin(), "TDay_MilitiaCharge_MissileBarrage_Middle" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "MissileBarrageRight" ).GetOrigin(), "TDay_MilitiaCharge_MissileBarrage_Right" )

	FlagWait( "MissileBarrageHitWall" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "MissileBarrageExplosions" ).GetOrigin(), "TDay_MilitiaCharge_SmallExplos" )

	FlagWait( "WallExplode" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "MissileBarrageExplosions" ).GetOrigin(), "TDay_MilitiaCharge_BigExplos" )
}

void function TitanFireBarrage( entity titan )
{
	int numShots = RandomIntRange( ROCKET_BARRAGE_MIN_SHOTS, ROCKET_BARRAGE_MAX_SHOTS )
	vector titanOrigin = titan.GetOrigin()

	// Find targets that have a valid x offset from the titan to minimize cross-fire
	array<entity> allTargets = GetEntArrayByScriptName( "wall_missile_target" )
	array<vector> validTargets
	foreach( entity target in allTargets )
	{
		if ( fabs( target.GetOrigin().x - titanOrigin.x ) <= ROCKET_BARRAGE_AIM_OFFSET_MAX )
			validTargets.append( target.GetOrigin() + < RandomFloatRange( -ROCKET_BARRAGE_TARGET_RAND_OFFSET, ROCKET_BARRAGE_TARGET_RAND_OFFSET ), RandomFloatRange( -ROCKET_BARRAGE_TARGET_RAND_OFFSET, ROCKET_BARRAGE_TARGET_RAND_OFFSET ), 0 > )
	}

	validTargets.randomize()
	Assert( validTargets.len() > 0 )

	array<int> attachIDs
	attachIDs.append( titan.LookupAttachment( "POD_L" ) )
	attachIDs.append( titan.LookupAttachment( "POD_R" ) )

	float timeBetweenShots = 0.1
	int targetIndex = 0
	for ( int i = 0 ; i < numShots ; i++ )
	{
		int attachID = attachIDs[ i % attachIDs.len() ]
		vector pos = titan.GetAttachmentOrigin( attachID )

		StartParticleEffectOnEntity( titan, GetParticleSystemIndex( ROCKET_BARRAGE_MUZZLE_FLASH_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachID )

		thread FireBarrageMissile( pos, validTargets[ targetIndex ] )
		targetIndex++
		if ( targetIndex >= validTargets.len() )
			targetIndex = 0
		wait timeBetweenShots
	}
}

void function FireBarrageMissile( vector start, vector end )
{
	vector midpoint = ( start + end ) / 2.0
	float minRadius = Distance( start, end ) / 2.0
	float radius = minRadius * RandomFloatRange( ROCKET_BARRAGE_RADIUS_MOD_MIN, ROCKET_BARRAGE_RADIUS_MOD_MAX )
	float drop = sqrt( ( radius * radius ) - ( minRadius * minRadius ) )
	vector center = midpoint - < 0, 0, drop >

	//DebugDrawCircle( center, AnglesCompose( VectorToAngles( start - center ), <0,0,90> ), radius, 255, 0, 0, false, 120.0, 32 )

	vector angles = AnglesCompose( VectorToAngles( start - center ), < -90, 0, 0 > )

	entity projectile = CreatePropDynamicLightweight( ROCKET_MODEL, start, angles, 0, 99999 )
	projectile.DisableHibernation()

	entity rotator = CreateScriptMover( center, <0,0,0> )
	projectile.SetParent( rotator, "", true )

	int attachId = projectile.LookupAttachment( "exhaust" )
	StartParticleEffectOnEntity( projectile, GetParticleSystemIndex( ROCKET_TRAIL_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachId )

	// The rocket will fly to the target
	vector rotateVec = AnglesToRight( VectorToAngles( end - start ) )
	float speed = RandomFloatRange( 8.0, 13.0 )
	rotator.NonPhysicsRotate( rotateVec, -speed )

	// Once the rocket has passed the target it explodes and deletes
	while( projectile.GetOrigin().z >= end.z )
		WaitFrame()

	FlagSet( "MissileBarrageHitWall" )
	StartParticleEffectInWorld( GetParticleSystemIndex( MISSILE_EXPLOSION ), end, <0,0,0> )
	projectile.Destroy()
	rotator.Destroy()
}

void function MakeIntroTitansVulnerable()
{
	wait 4.0

	foreach( entity titan in file.friendlyTitans )
	{
		if ( IsValid( titan ) )
			titan.ClearInvulnerable()
	}
}

void function IntroBattleThink( entity player )
{
	EndSignal( player, "OnDeath" )

	FlagSet( "ReinforcementsEnabled" )
	SetIdealFriendlyTitanCount( 5 ) // from 6 -Mackey

	// Friendlies advance to first battle line
	FlagSet( "FriendlyPaths_ChargeWall" )

	printt( "--------" )
	printt( " WAVE 1 " )
	printt( "--------" )

	thread ForceTitanExecution( file.meleeFriendly1, "melee_titan1", "melee_node1", "melee_titan1_normal_node", true )
	thread ForceTitanExecution( file.meleeFriendly2, "melee_titan2", "melee_node2", "melee_titan2_normal_node", true )
	thread ForceTitanExecution( file.meleeFriendly3, "melee_titan3", "melee_node3", "melee_titan3_normal_node", false )

	//wait 4.0

	FlagSet( "FirstIMCTitansSpawned_Wave1" )

	array<entity> enemyReapers
	array<entity> enemyTitans
	enemyReapers = SpawnFromSpawnerArray( GetEntArrayByScriptName( "IntroWave1ReaperSpawner" ) )
	enemyTitans = SpawnFromSpawnerArray( GetEntArrayByScriptName( "IntroWave1TitanSpawner" ) )

	// Wait for wave 1 to be mostly killed off
	while( true )
	{
		ArrayRemoveDead( enemyReapers )
		ArrayRemoveDead( enemyTitans )

		printt( "w1 enemyReapers:", enemyReapers.len() )
		printt( "w1 enemyTitans:", enemyTitans.len() )

		if ( enemyTitans.len() <= 5 )
			SetIdealFriendlyTitanCount( 5 )

		if ( enemyTitans.len() <= 4 )
		{
			SetIdealFriendlyTitanCount( 4 )
			FlagSet( "FriendlyPaths_MoveToWall" ) // Friendlies move up
		}

		// Various conditions that will start wave 2

		if ( enemyTitans.len() <= 3 )
			break

		if ( Flag( "EnteredWall" ) )
			break

		wait 1.0
	}

	printt( "--------" )
	printt( " WAVE 2 " )
	printt( "--------" )

	CheckPoint()

	SetIdealFriendlyTitanCount( 4 )
	FlagSet( "FriendlyPaths_MoveToWall" ) // Friendlies move up
	FlagSet( "FirstIMCTitansSpawned_Wave2" )

	array<entity> wave2Spawners = GetEntArrayByScriptName( "IntroWave2TitanSpawner" )
	wave2Spawners.randomize()
	foreach( entity spawner in wave2Spawners )
	{
		wait 0.2
		entity titan = spawner.SpawnEntity()
		DispatchSpawn( titan )
		enemyTitans.append( titan )
	}

	while( true )
	{
		ArrayRemoveDead( enemyTitans )

		if ( enemyTitans.len() <= 5 )
			SetIdealFriendlyTitanCount( 3 )

		if ( enemyTitans.len() <= 4 )
			FlagSet( "FriendlyPaths_EnterWall" ) // Friendlies enter the wall area

		if ( enemyTitans.len() <= 3 )
			break

		printt( "w2 enemyTitans:", enemyTitans.len() )

		wait 1.0
	}

	printt( "--------" )
	printt( " WAVE 3 " )
	printt( "--------" )

	CheckPoint()

	SetIdealFriendlyTitanCount( 3 )
	FlagSet( "FirstIMCTitansSpawned_Wave3" )
	FlagSet( "FriendlyPaths_EnterWall" ) // Friendlies enter the wall area

	// Wave 3 Reapers
	enemyReapers.extend( SpawnFromSpawnerArray( GetEntArrayByScriptName( "IntroWave3ReaperSpawner" ) ) )

	// Wave 3 Titans
	int numTitansForWave3 = 3
	array<entity> wave3TitanSpawners = GetEntArrayByScriptName( "IntroWave3TitanSpawner" )
	array<entity> chosenSpawners
	wave3TitanSpawners.randomize()
	foreach( entity spawner in wave3TitanSpawners )
	{
		table spawnerKeyValues = spawner.GetSpawnEntityKeyValues()
		vector spawnerOrigin = StringToVector( string( spawnerKeyValues.origin ) )
		if ( Distance( spawnerOrigin, player.GetOrigin() ) < 400 )
			continue
		chosenSpawners.append( spawner )
		if ( chosenSpawners.len() == 3 )
			break
	}
	Assert( chosenSpawners.len() == 3 )
	enemyTitans.extend( SpawnFromSpawnerArray( chosenSpawners ) )

	waitthread WaitUntilDoorsShouldOpen( player, enemyTitans )

	foreach( entity titan in enemyTitans )
	{
		if ( IsValid( titan ) )
		{
			titan.SetEnemy( player )
			titan.AssaultPoint( player.GetOrigin() )
		}
	}

	printt( "------------" )
	printt( " DOOR OPENS " )
	printt( "------------" )

	CheckPoint()
	SetIdealFriendlyTitanCount( 2 )

	// Spawn the titans behind the doors
	//Assert( enemyTitans.len() == 0 )
	enemyTitans.extend( SpawnFromSpawnerArray( GetEntArrayByScriptName( "HallwayEntryDoorTitanSpawner" ) ) )

	// Set friendly titans goal to the courtyard area so they dont go into the tunnel (only player and sarah go in)
	entity friendlyMoveTarget = GetEntByScriptName( "MoveTargetAllFriendlyTitansBeforeDoor" )
	ArrayRemoveDead( file.friendlyTitans )
	foreach( entity titan in file.friendlyTitans )
		thread AssaultMoveTarget( titan, friendlyMoveTarget )

	// Sarah becomes a friendly follower so we can control where she goes with the player better
	AddTriggeredPlayerFollower( player, file.sarahTitan )

	// Open the door
	FlagSet( "HallwayEntryDoorsOpen" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "BaseEntranceDoorSoundEnt" ).GetOrigin(), "TDay_MilitiaCharge_LargeDoorOpen" )

	SpawnBatteriesBehindDoor()

	// wait for the door to open
	wait 1.0

	// Connect navmesh through the now open door
	FlagSet( "HallwayEntryDoorsPathsConnect" )

	// Wait for door titans to be dead
	FlagWaitAny( "HallwayEntryEnemiesDead", "PlayerInHallway" )

	FlagSet( "StartFuelStorage" )

	// Wait for player, BT, and Sarah to be through the door so we can close it
	bool sarahInHallway = false
	bool playerInHallway = false
	bool btInHallway = false
	while( true )
	{
		sarahInHallway = Flag( "SarahInHallway" )
		playerInHallway = Flag( "PlayerInHallway" )
		btInHallway = player.IsTitan() ? playerInHallway : Flag( "BTInHallway" )

		//printt( "sarahInHallway:", sarahInHallway )
		//printt( "playerInHallway:", playerInHallway )
		//printt( "btInHallway:", btInHallway )

		if ( sarahInHallway && playerInHallway && btInHallway )
			break

		WaitFrame()
	}

	// Close the door and disconnect the navmesh
	FlagSet( "HallwayEntryDoorsClose" )
	FlagClear( "HallwayEntryDoorsPathsConnect" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "BaseEntranceDoorSoundEnt" ).GetOrigin(), "TDay_MilitiaCharge_LargeDoorClose" )

	// Elk Four, Stork two - Lock this area down.
	waitthread PlayDialogue( "SARAH_LOCK_AREA_DOWN", player )

	// BT, Pilot Cooper - you're with me. Let's go.
	thread PlayDialogue( "SARAH_COOPER_WITH_ME_LETS_GO", player )
}

void function WaitUntilDoorsShouldOpen( entity player, array<entity> enemyTitans )
{
	// Wait until enough are dead
	while ( true )
	{
		if ( Distance( player.GetOrigin(), <1536, -5160, 448> ) < 1500 )
			break

		ArrayRemoveDead( enemyTitans )
		printt( "w3 enemyTitans:", enemyTitans.len() )

		if ( enemyTitans.len() <= 2 )
			break

		wait 1.0
	}

	// early out if player is hanging in this area for too long without doors opening

	float earlyOutTime = Time() + 12.0
	while ( true )
	{
		if ( Time() >= earlyOutTime )
			break

		ArrayRemoveDead( enemyTitans )
		printt( "w3 enemyTitans:", enemyTitans.len() )

		if ( enemyTitans.len() <= 2 )
			break

		wait 1.0
	}
}


void function SpawnBatteriesBehindDoor()
{
	array<entity> batterySpawners = GetEntArrayByScriptName( "BatterySpawnersBehindFirstDoor" )
	foreach( entity spawner in batterySpawners )
	{
		entity battery = spawner.SpawnEntity()
		DispatchSpawn( battery )
	}
}

void function Wave1Dialogue( entity player )
{
	FlagEnd( "FirstIMCTitansSpawned_Wave3" )

	// Wait for first group of enemy Titans to spawn
	FlagWait( "FirstIMCTitansSpawned_Wave1" )

	// We got IMC Titans! Stay alert!
	waitthread PlayDialogue( "IMC_TITANS_STAY_ALERT", player )

	// Move! Move! Move!
	waitthread PlayDialogue( "MOVE_MOVE_MOVE", player )

	// Sparrow eight, lock targets. Suppressing fire.
	waitthread PlayDialogue( "SARAH_SUPPRESSING_FIRE", player )

	wait 3.0

	// Engage! Engage!
	waitthread PlayDialogue( "ENGAGE_ENGAGE", player )

	wait 3.0

	// We got reapers. Elk seven - turn it around.
	waitthread PlayDialogue( "SARAH_WE_GOT_REAPERS", player )

	wait 5.0

	// Pick your targets and focus your fire!
	waitthread PlayDialogue( "FOCUS_FIRE", player )

	wait 6.0

	// Stork two - Watch your six.
	waitthread PlayDialogue( "SARAH_WATCH_SIX", player )

	wait 8.0

	// Got a lot of hostiles up ahead...
	waitthread PlayDialogue( "HOSTILES_UP_AHEAD", player )

	wait 5.0

	// Badger six - Take the sideline.
	waitthread PlayDialogue( "SARAH_TAKE_SIDELINE", player )

	wait 6.0

	// We're pushing 'em back! Keep it up!
	waitthread PlayDialogue( "KEEP_IT_UP", player )

	wait 3.0

	// Watch for hostile Titanfalls!
	waitthread PlayDialogue( "WATCH_FOR_TITANFALLS", player )
}

void function Wave2Dialogue( entity player )
{
	FlagEnd( "HallwayEntryDoorsOpen" )

	FlagWait( "FirstIMCTitansSpawned_Wave2" )

	// More IMC Titan's moving in.
	waitthread PlayDialogue( "SARAH_TITANS_MOVING_IN", player )

	// Let's bring the war to them. Keep moving forward.
	waitthread PlayDialogue( "SARAH_KEEP_MOVING_FORWARD", player )

	// Go! Go! Go!
	waitthread PlayDialogue( "GO_GO_GO", player )

	wait 6.0

	// Hit 'em hard! Move! Move!
	waitthread PlayDialogue( "HIT_EM_HARD", player )

	// Keep moving. That ship could take off at any moment.
	waitthread PlayDialogue( "SARAH_KEEP_MOVING", player )

	wait 6.0

	// Elk four. I need you up ahead, now.
	waitthread PlayDialogue( "SARAH_NEED_YOU_UP_AHEAD", player )

	wait 10.0

	// Use your cores, people.
	waitthread PlayDialogue( "SARAH_USE_CORES", player )

	// Elk Four - Get to that Underground Entrance.
	waitthread PlayDialogue( "SARAH_GET_TO_ENTRANCE", player )

	wait 2.0

	// Watch for flanking.
	waitthread PlayDialogue( "SARAH_WATCH_FOR_FLANKING", player )
}

void function Wave3Dialogue( entity player )
{
	FlagEnd( "HallwayEntryDoorsOpen" )

	FlagWait( "FirstIMCTitansSpawned_Wave3" )

	// IMC Titans! Take 'em out!
	waitthread PlayDialogue( "IMC_TITANS_TAKE_EM_OUT", player )

	wait 5.0

	// Hit 'em hard! Move! Move!
	waitthread PlayDialogue( "HIT_EM_HARD", player )

	wait 5.0

	// Take out those Titans! Fire! Fire!
	waitthread PlayDialogue( "TAKE_OUT_THOSE_TITANS", player )
}

void function BlastDoorTitansDialogue( entity player )
{
	FlagWait( "HallwayEntryDoorsOpen" )

	// We got more IMC! Watch out!
	waitthread PlayDialogue( "MORE_IMC_WATCH_OUT", player )

	wait 1.0

	// Spread out! Titans at the blast door!
	waitthread PlayDialogue( "TITANS_AT_BLAST_DOOR", player )

	// Incoming enemy Titans!
	waitthread PlayDialogue( "INCOMING_ENEMY_TITANS", player )
}

void function EnterTunnelsDialogue( entity player )
{
	FlagWait( "HallwayEntryDoorsOpen" )

	// Cooper. You're with me.
	waitthread PlayDialogue( "SARAH_COOPER_WITH_ME", player )

	// Into the tunnels!
	waitthread PlayDialogue( "SARAH_INTO_THE_TUNNELS", player )
}

void function FriendlyTitanDeathDialogue( entity titan )
{
	// When the friendly titan dies he plays dialogue. Once all lines are used no more are played.
	entity player = GetPlayerArray()[0]
	EndSignal( player, "OnDeath" )

	if ( !Flag( "VTOL" ) )
	{
		if ( Flag( "HallwayEntryDoorsClose" ) )
			return
		FlagEnd( "HallwayEntryDoorsClose" )
	}

	// Wait for the titan to die
	WaitSignal( titan, "OnDeath" )

	array<string> lines
	if ( Flag( "RunwayFriendliesActive" ) )
	{
		if ( file.numRunwayFriendlyDeaths >= 2 )
			return

		switch( file.numRunwayFriendlyDeaths )
		{
			case 0:
				lines.append( "FRIENDLY_TITAN_WE_LOST_SPARROW" )	// We just lost Sparrow 8...
				break
			case 1:
				lines.append( "FRIENDLY_TITAN_CARDINAL_DOWN" )		// Cardinal Two is down.
				break
			case 2:
				lines.append( "FRIENDLY_TITAN_PICKING_US_OFF" )		// They're picking us off one by one.
				break
		}
		file.numRunwayFriendlyDeaths++
	}
	else if ( Flag( "VTOL" ) )
	{
		if ( file.numVTOLFriendlyDeaths >= 5 )
			return

		switch( file.numVTOLFriendlyDeaths )
		{
			case 0:
				lines.append( "TITAN_DEATH_NED_BACKUP_AHH" )	// Back up. I need back up. Aaaaaaah.
				break
			case 1:
				lines.append( "TITAN_DEATH_STANDBY" )			// Standby for Titanf-- (explosion)
				break
			case 2:
				lines.append( "TITAN_DEATH_GOING_DOWN" )		// We're going down.
				break
			case 3:
				lines.append( "TITAN_DEATH_I_GOT_ONE" )			// I got one.  ....NO.
				break
			case 4:
				lines.append( "TITAN_DEATH_FRIENDLY_DOWN" )		// Friendly down.
				break
			case 5:
				lines.append( "TITAN_DEATH_EJECT_EJECT" )		// Eject. Eject.
				break
		}
		file.numVTOLFriendlyDeaths++
	}
	else
	{
		if ( file.numChargeFriendlyDeaths >= 3 )
			return

		switch( file.numChargeFriendlyDeaths )
		{
			case 0:
				lines.append( "TITAN_DEATH_HATCH_JAMMED" )	// I'm hit! My hatch is jammed! Noooooo!
				lines.append( "SARAH_ELK_NINE_UGH" )		// Elk nine - Come in. Ugh. Keep moving.
				break
			case 1:
				lines.append( "TITAN_DEATH_NEED_BACKUP" )	// I need back up! Taking fire taking fire AAAAAAA!!!
				break
			case 2:
				lines.append( "TITAN_DEATH_WEAPONS_DOWN" )	// Shark Two One my weapon's down! Cover me cover [me]
				break
			case 3:
				lines.append( "TITAN_DEATH_IM_HIT" )		// I'm hit! Taking major fire from all [sides!]
				break
		}
		file.numChargeFriendlyDeaths++
	}

	foreach( string line in lines )
	{
		thread PlayDialogue( line, player )
		WaitFrame()
	}
}

void function DamageCallback_NPCTitan( entity titan, var damageInfo )
{
	// Throttles how many friendly titans we have remaining based on what the level thinks there should be. If there are more titans than we want then the damage is increased to cause them to die off

	if ( !IsValid( titan ) )
		return

	if ( titan.GetTeam() != TEAM_MILITIA )
		return

	if ( titan.IsInvulnerable() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if ( titan == file.sarahTitan )
		return

	if ( !file.friendlyTitans.contains( titan ) )
		return

	ArrayRemoveDead( file.friendlyTitans )
	int numFriendlyTitans = file.friendlyTitans.len() + 1 // add 1 for sarah who's not in this array

	//printt( "Titan damaged. Ideal count:", file.idealNumberFriendlyTitans, "Actual:", numFriendlyTitans )

	// If actual number is above ideal, then kill this friendly
	if ( numFriendlyTitans > file.idealNumberFriendlyTitans )
	{
		//printt( "Killing Friendly" )
		DamageInfo_SetDamage( damageInfo, titan.GetHealth() + 1 )
		DamageInfo_SetForceKill( damageInfo, true )
		//DebugDrawSphere( titan.GetOrigin(), 32.0, 255, 0, 0, true, 2.0 )
		return
	}

	//DebugDrawSphere( titan.GetOrigin(), 32.0, 128, 128, 0, true, 2.0 )
}

void function PeriodicallySpawnFriendlyTitan()
{
	if ( !Flag( "ReinforcementsEnabled" ) )
		return

	FlagClearEnd( "ReinforcementsEnabled" )

	OnThreadEnd(
	function() : (  )
		{
			file.spawningReinforcementFriendlies = false
		}
	)

	file.spawningReinforcementFriendlies = true

	for ( ;; )
	{
		int numFriendlyTitans = file.friendlyTitans.len() + 1 // add 1 for sarah who's not in this array

		// if actual number is below ideal, then spawn a reinforcement
		if ( numFriendlyTitans >= file.idealNumberFriendlyTitans )
		{
			wait 2
			continue
		}

		SpawnReinforcements( 1 )
		//DebugDrawSphere( titan.GetOrigin(), 32.0, 255, 0, 0, true, 2.0 )
		//DebugDrawLine( titan.GetOrigin(), StringToVector( string( spawner.GetSpawnEntityKeyValues().origin ) ), 255, 0, 0, true, 2.0 )

		// dont spam field with Titans
		wait RandomFloatRange( 2, 5 )
	}
}

void function SpawnReinforcements( int count )
{
	Assert( Flag( "ReinforcementsEnabled" ) )

	array<entity> spawners
	if ( Flag( "RunwayFriendliesActive" ) )
		spawners = clone file.friendlyTitanSpawners_Runway
	else if ( Flag( "VTOL" ) )
		spawners = clone file.friendlyTitanSpawners_VTOL
	else
		spawners = clone file.friendlyTitanSpawners_Intro

	spawners.randomize()

	int index = 0
	for ( int i = 0 ; i < count ; i++ )
	{
		SpawnFriendlyTitan( spawners[ index ] )
		index++
		if ( index >= spawners.len() )
			index = 0
	}
}

void function SetIdealFriendlyTitanCount( int count )
{
	printt( "Friendly count changing from", file.idealNumberFriendlyTitans, "to", count )
	file.idealNumberFriendlyTitans = count

	ArrayRemoveDead( file.friendlyTitans )

	if ( !Flag( "ReinforcementsEnabled" ) )
		return

	int numFriendlyTitans = file.friendlyTitans.len() + 1 // add 1 for sarah who's not in this array
	if ( numFriendlyTitans < file.idealNumberFriendlyTitans )
		SpawnReinforcements( file.idealNumberFriendlyTitans - numFriendlyTitans )

	if ( !file.spawningReinforcementFriendlies )
	{
		thread PeriodicallySpawnFriendlyTitan()
	}
}

void function ForceTitanExecution( entity friendlyTitan, string enemyTitanSpawnerName, string meetNode, string normalNode, bool friendlyWins )
{
	// Wait a frame because this titan is being told to go to his path chain on the same frame but we want to make sure this happens after that
	WaitFrame()

	entity enemySpawner = GetEntByScriptName( enemyTitanSpawnerName )
	entity enemyTitan = enemySpawner.SpawnEntity()
	DispatchSpawn( enemyTitan )

	entity assaultNode = GetEntByScriptName( meetNode )
	Assert( IsValid( assaultNode ) )

	entity normalNode = GetEntByScriptName( normalNode )
	Assert( IsValid( normalNode ) )

	if ( IsAlive( friendlyTitan ) && IsAlive( enemyTitan ) )
	{
		thread SetupTitanForForcedExecutionSequence( friendlyTitan, assaultNode, enemyTitan, normalNode, !friendlyWins )
		thread SetupTitanForForcedExecutionSequence( enemyTitan, assaultNode, friendlyTitan, normalNode, friendlyWins )
	}

	if ( DEBUG_TITAN_MELEE )
	{
		EndSignal( friendlyTitan, "OnDeath" )
		EndSignal( enemyTitan, "OnDeath" )
		EndSignal( friendlyTitan, "OnSyncedMeleeBegin" )
		EndSignal( enemyTitan, "OnSyncedMeleeBegin" )

		float endTime = Time() + TITAN_RUSH_MELEE_TIMEOUT
		while( Time() <= endTime )
		{
			if ( IsValid( friendlyTitan ) )
				DebugDrawLine( friendlyTitan.GetOrigin(), assaultNode.GetOrigin(), 255, 0, 0, true, 0.1 )
			if ( IsValid( enemyTitan ) )
				DebugDrawLine( enemyTitan.GetOrigin(), assaultNode.GetOrigin(), 255, 0, 0, true, 0.1 )
			WaitFrame()
		}
	}
}

void function SetupTitanForForcedExecutionSequence( entity titan, entity node, entity enemy, entity normalNode, bool isVictim )
{
	OnThreadEnd(
		function() : ( titan, enemy, normalNode )
		{
			if ( IsAlive( titan ) )
				thread TitanExecutionOverSetup( titan, normalNode )
			if ( IsAlive( enemy ) )
				thread TitanExecutionOverSetup( enemy, normalNode )
		}
	)

	EndSignal( titan, "OnDeath" )
	EndSignal( enemy, "OnDeath" )
	EndSignal( titan, "OnSyncedMeleeBegin" )
	EndSignal( enemy, "OnSyncedMeleeBegin" )

	// Tell titan to run to the meet up point
	Signal( titan, "StopAssaultMoveTarget" )
	titan.AssaultPoint( node.GetOrigin() )
	titan.AssaultSetGoalRadius( 256 )
	titan.AssaultSetFightRadius( 200 )

	// Make the titans not shoot at anything, just run to each other
	titan.kv.allowShoot = false
	//titan.SetNoTarget( true )

	// Don't let them attempt unsynced melees
	titan.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2, false )

	// Sprint to each other
	titan.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )

	// Make them a low priority to everyone else
	titan.SetNPCPriorityOverride_NoThreat()

	// Force their enemy
	titan.LockEnemy( enemy )

	if ( isVictim )
	{
		titan.SetCapabilityFlag( bits_CAP_INITIATE_SYNCED_MELEE, false )

		titan.TakeOffhandWeapon( 0 )
		titan.TakeOffhandWeapon( 1 )

		WaitFrame()
		if ( IsAlive( titan ) )
			titan.SetHealth( 1000 )
	}

	wait TITAN_RUSH_MELEE_TIMEOUT
}

void function TitanExecutionOverSetup( entity titan, entity node )
{
	titan.kv.allowShoot = true
	//titan.SetNoTarget( false )
	titan.ClearEnemy()
	titan.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2, true )
	titan.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	titan.ClearNPCPriorityOverride()
	titan.SetCapabilityFlag( bits_CAP_INITIATE_SYNCED_MELEE, true )

	// Rejoin the friendly move paths
	AssaultMoveTarget( titan, node )
}

void function SwapOLAModel()
{
	entity heroModel = GetEntByScriptName( "hero_ola" )
	entity skyboxModel = GetEntByScriptName( "skybox_model_ship" )
	heroModel.DisableHibernation()
	skyboxModel.DisableHibernation()

	thread PlayAnim( heroModel, "ve_arc_loading_draconis_idle", GetEntByScriptName( "arc_loading_node" ) )

	skyboxModel.Show()
	heroModel.Hide()

	FlagWait( "SwapOLA" )

	if ( level.nv.netvar_draconis_flying_status == DRACONIS_NONE )
		heroModel.Show()
	skyboxModel.Destroy()

	FlagSet( "fx_draconis_coolant" )
}

void function SkyboxSmoke()
{
	entity smokeModel = GetEntByScriptName( "skybox_model_smoke" )
	smokeModel.DisableHibernation()
	smokeModel.Hide()

	FlagWait( "SkyboxSmoke" )

	smokeModel.Show()
}

void function EnableMegaTurret( entity turret )
{
	turret.EnableTurret()
}

void function DestroyFriendliesAndStopReinforcements()
{
	FlagClear( "ReinforcementsEnabled" )
	for ( int i = file.friendlyTitans.len() - 1 ; i >= 0 ; i-- )
	{
		if ( IsValid( file.friendlyTitans[i] ) )
			file.friendlyTitans[i].Destroy()
	}
}

void function VTOL_Landed_Dropship_Think( entity spawner, entity player )
{
	entity ship = spawner.SpawnEntity()
	DispatchSpawn( ship )

	EndSignal( player, "OnDeath" )
	EndSignal( ship, "OnDeath" )

	thread PlayAnim( ship, "idle" )

	float radius = float( ship.GetValueForKey( "script_goal_radius" ) )
	string anim = ship.GetValueForKey( "takeoff_anim" )
	Assert( anim != "" )
	vector p = ship.GetOrigin()

	while( Distance( p, player.GetOrigin() ) > radius )
		wait 1.0

	PlayAnim( ship, anim )
	ship.Destroy()
}

void function VTOL_flyby1()
{
	FlagWait( "VTOL_flyby1" )

	array<entity> nodes = GetEntArrayByScriptName( "vtol_flyby1" )
	foreach( int i, entity node in nodes )
		thread VTOL_Flyby( node, i )
}

void function VTOL_Flyby( entity node, int index )
{
	entity ship = CreatePropDynamic( STRATON_MODEL )
	ship.DisableHibernation()
	EmitSoundOnEntity( ship, "TDay_CloseShip_FlyBy_" + (index + 1) )
	PlayAnimTeleport( ship, node.GetValueForKey( "leveled_animation" ), node )
	ship.Destroy()
}

void function DraconisSpeakerFollowsShip( entity ship, entity dragonicSpeaker )
{
	ship.EndSignal( "OnDestroy" )
	dragonicSpeaker.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		dragonicSpeaker.SetOrigin( ship.GetOrigin() )
		WaitFrame()
	}
}

void function SwapDraconisWithClientSideModel()
{
	entity ship = GetEntByScriptName( "hero_ola" )
	ship.Hide()
	ship.DisableHibernation()
	level.nv.netvar_draconis_flying_status = DRACONIS_IDLING
}

void function CreateArkSequenceModels()
{
	string boss = "Slone"
	int sloneIndex = GetBossTitanID( boss )

	// get slone's model
	asset sloneModel = GetMercCharacterModel( sloneIndex )
	TitanLoadoutDef ornull bossLoadout = GetTitanLoadoutForBossCharacter( boss )
	expect TitanLoadoutDef( bossLoadout )

	// get slone's titan model
	asset bossTitanModel = GetPlayerSettingsAssetForClassName( bossLoadout.setFile, "bodymodel" )


	// get some ogre and stryder models from the models we have loaded. If we stop using these guys then we'll get a late precache.
	asset ogreTitanModel = GetPlayerSettingsAssetForClassName( "titan_ogre_meteor", "bodymodel" )
	asset stryderTitanModel = GetPlayerSettingsAssetForClassName( "titan_stryder_sniper", "bodymodel" )

	entity titan1 = CreatePropDynamic( ogreTitanModel )
	titan1.DisableHibernation()

	entity titan2 = CreatePropDynamic( ogreTitanModel )
	titan2.DisableHibernation()

	entity titan3 = CreatePropDynamic( stryderTitanModel )
	titan3.DisableHibernation()
	titan3.SetSkin( 1 ) // boss skin!

	entity sloneTitan = CreatePropDynamic( bossTitanModel )
	sloneTitan.DisableHibernation()
	sloneTitan.SetSkin( 1 ) // boss skin!

	entity sloneHuman = CreatePropDynamic( sloneModel )
	sloneHuman.DisableHibernation()

	entity ark = CreatePropDynamic( ARK_MODEL )
	ark.DisableHibernation()

	entity arkBase = CreatePropDynamic( ARK_BASE_MODEL )
	arkBase.DisableHibernation()
	arkBase.SetParent( ark, "rack", false )

	entity node = GetEntByScriptName( "arc_loading_node" )

	thread PlayAnimTeleport( titan1, "ht_arc_loading_ht1_IDLE", node )
	thread PlayAnimTeleport( titan2, "ht_arc_loading_ht2_IDLE", node )
	thread PlayAnimTeleport( titan3, "lt_arc_loading_stryder_IDLE", node )
	thread PlayAnimTeleport( sloneTitan, "mt_arc_loading_slone_IDLE", node )
	thread PlayAnimTeleport( sloneHuman, "pt_arc_loading_slone_IDLE", node )
	thread PlayAnimTeleport( ark, "cu_arc_loading_arc_IDLE", node )

	file.arkSceneModels[ "titan1" ] <- titan1
	file.arkSceneModels[ "titan2" ] <- titan2
	file.arkSceneModels[ "titan3" ] <- titan3
	file.arkSceneModels[ "sloneTitan" ] <- sloneTitan
	file.arkSceneModels[ "sloneHuman" ] <- sloneHuman
	file.arkSceneModels[ "ark" ] <- ark
	file.arkSceneModels[ "arkBase" ] <- arkBase
}

void function ArkSequence( entity player )
{
	SetGlobalNetBool( "titanOSDialogueEnabled", false )

	entity ship = GetEntByScriptName( "hero_ola" )

	FlagWait( "OlaLaunchStartPoint" )
	level.nv.netvar_draconis_flying_status = DRACONIS_AFTERBURNERS

	entity dragonicSpeaker = CreateEntity( "info_target" )
	dragonicSpeaker.kv.spawnflags = 2 // appear on client
	dragonicSpeaker.SetScriptName( "draconis_speaker" )
	DispatchSpawn( dragonicSpeaker )
	EmitSoundOnEntity( dragonicSpeaker, "TDay_Runway_OLA_IntroWarmUp" )

	// speaker follows the ship, so the sound comes from the ship origin, until the ship reaches the edge of the map and deletes
	thread DraconisSpeakerFollowsShip( ship, dragonicSpeaker )

	FlagClear( "AutomaticCheckpointsEnabled" )
	FlagClear( "SaveGame_Enabled" )

	thread SeeBadGeoFailsafe( player )

	entity node = GetEntByScriptName( "arc_loading_node" )

	entity titan1 = file.arkSceneModels[ "titan1" ]
	entity titan2 = file.arkSceneModels[ "titan2" ]
	entity titan3 = file.arkSceneModels[ "titan3" ]
	entity sloneTitan = file.arkSceneModels[ "sloneTitan" ]
	entity sloneHuman = file.arkSceneModels[ "sloneHuman" ]
	entity ark = file.arkSceneModels[ "ark" ]
	entity arkBase = file.arkSceneModels[ "arkBase" ]

	SetTeam( titan1, TEAM_IMC )
	SetTeam( titan2, TEAM_IMC )
	SetTeam( titan3, TEAM_IMC )
	SetTeam( sloneTitan, TEAM_IMC )

	StopMusicTrack( "music_tday_08_battletoship" )
	PlayMusic( "music_tday_09_downthestep" )

	FlagSet( "fx_draconis_ignite" )
	FlagClear( "fx_draconis_coolant" )
	FlagSet( "fx_draconis_blast" )

	waitthread SarahTellsYouToGetArk( player, ark )

	Objective_Set( "#TDAY_OBJECTIVE_RETRIEVE_ARK", <0,0,0>, ark )

	EmitSoundOnEntity( dragonicSpeaker, "TDay_Runway_OLA_SlamZoomSequence" )

	foreach ( index, enemy in GetNPCArrayOfTeam( TEAM_IMC ) )
	{
		if ( IsAlive( enemy ) )
			thread DelayedEnemyKill( index * RandomFloat( 0.4 ), enemy )
	}

	thread PlayAnimTeleport( titan1, "ht_arc_loading_ht1", node )
	thread PlayAnimTeleport( titan2, "ht_arc_loading_ht2", node )
	thread PlayAnimTeleport( titan3, "lt_arc_loading_stryder", node )
	thread PlayAnimTeleport( sloneTitan, "mt_arc_loading_slone", node )
	thread PlayAnimTeleport( sloneHuman, "pt_arc_loading_slone", node )

	//event AE_CL_PLAYSOUND 10 "diag_sp_launch_TD161_01_01_imc_slone"
	delaythread(3.15) PlayDialogue( "SLONE_ARC_HEADED_YOUR_WAY", player )

	thread PlayAnimTeleport( ark, "cu_arc_loading_arc", node )

	level.nv.netvar_draconis_flying_status = DRACONIS_FLYING
	thread PlayAnim( ship, "ve_arc_loading_draconis", node )
	thread DraconisTakeoffShakeAndRumble( ship, player )
	thread ShipBlowsUpSoItDoesntCrashTheGame( ship )

	//asset weaponAsset = GetWeaponInfoFileKeyFieldAsset_Global( weaponName, "playermodel" )
	//entity weapon = CreatePropDynamic( weaponAsset )
	//weapon.SetParent( titan, "propgun", false, 0.0 )

	player.FreezeControlsOnServer()
	player.DisableWeapon()
	player.SetNoTarget( true )
	player.SetInvulnerable()
	FlagSet( "BossTitanViewFollow" )
	AddCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )
	Remote_CallFunction_NonReplay( player, "ServerCallback_BossTitanIntro_Start", sloneTitan.GetEncodedEHandle(), 0, false, false )

	thread BossTitanPlayerView( player, sloneTitan, node, "vehicle_driver_eyes" )
	svGlobal.levelEnt.Signal( "BossTitanStartAnim" )

	UnlockAchievement( player, achievements.LOCATE_ARK )

	wait 8.85

	//WaittillAnimDone( sloneTitan )
	//WaitSignal( titan4, "SlamCamEnd" )

	FlagClear( "BossTitanViewFollow" )

	// Move it. We got 'em, Cooper!
//	thread PlayDialogue( "SARAH_WE_GOT_EM_COOPER", player )

	wait SLAMZOOM_TIME

	player.EnableWeapon()
	player.UnfreezeControlsOnServer()
	player.SetNoTarget( false )
	player.ClearInvulnerable()
	RemoveCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )
	Remote_CallFunction_NonReplay( player, "ServerCallback_BossTitanIntro_End", sloneTitan.GetEncodedEHandle(), false )

	array<entity> destroyEnts
	destroyEnts.append( sloneHuman )
	destroyEnts.append( arkBase )
	destroyEnts.append( ark )
	destroyEnts.append( titan1 )
	destroyEnts.append( titan2 )
	destroyEnts.append( titan3 )
	destroyEnts.append( sloneTitan )
	thread DestroyArcSequenceEntities( destroyEnts, 0.0 )
}

void function DraconisTakeoffShakeAndRumble( entity ship, entity player )
{
	EndSignal( player, "OnDeath" )

	vector origin = ship.GetOrigin()

	wait 10.0
	CreateShake( origin, 100, 50, 8.0, 13000 )
	CreateAirShakeRumbleOnly( origin, 2500, 150, 8.0, 13000 )
	wait 5.0
	CreateShake( origin, 150, 50, 5.0, 13000 )
	CreateAirShakeRumbleOnly( origin, 5000, 150, 5.0, 13000 )
}

void function ShipBlowsUpSoItDoesntCrashTheGame( entity ship )
{
	float startTime = Time()
	float endTime = Time() + DRACONIS_ESCAPE_TIME
	for ( ;; )
	{
		//printt( "flying time " + ( Time() - startTime ) )
		if ( Time() >= endTime )
			break
		WaitFrame()
	}

	ship.Destroy()
}

void function SarahTellsYouToGetArk( entity player, entity ark )
{
	if ( Flag( "OlaLaunch_StartSlamZoom" ) )
		return
	FlagEnd( "OlaLaunch_StartSlamZoom" )

	thread StartSlamZoomIfPlayerAimsAtArk( player, ark )
	// Don't let them get away. Get to that ramp.
	waitthread PlayDialogue( "SARAH_GET_TO_RAMP", player )
	wait 0.5
}

void function StartSlamZoomIfPlayerAimsAtArk( entity player, entity ark )
{
	FlagEnd( "OlaLaunch_StartSlamZoom" )
	if ( !IsAlive( player ) )
		return
	player.EndSignal( "OnDeath" )
	ark.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		WaitFrame()
		if ( player.GetZoomFrac() <= 0 )
			continue
		if ( VectorDot_EntToEnt( player, ark ) > 0.75 )
			break
	}

	wait 0.8

	FlagSet( "OlaLaunch_StartSlamZoom" )
}

void function DestroyArcSequenceEntities( array<entity> destroyEnts, float delay )
{
	wait delay

	// Delete all the guys that are now inside the ship
	foreach( entity ent in destroyEnts )
	{
		if ( IsValid( ent ) )
			ent.Destroy()
	}
}

void function DelayedEnemyKill( float delay, entity enemy )
{
	Assert( IsAlive( enemy ) )
	enemy.EndSignal( "OnDeath" )
	wait delay
	enemy.Die()
}

void function PlayerAndSarahInElevator( entity player )
{
	thread ElevatorNags( player )

	// Wait for player, BT, and Sarah to be on the elevator platform
	bool sarahInElevator = false
	bool playerInElevator = false
	bool btInElevator = false
	while( true )
	{
		sarahInElevator = Flag( "SarahInElevator" )
		playerInElevator = Flag( "PlayerInElevator" )
		btInElevator = player.IsTitan() ? playerInElevator : Flag( "BTInElevator" )

		if ( sarahInElevator && playerInElevator && btInElevator )
			break

		WaitFrame()
	}
}

void function ElevatorNags( entity player )
{
	FlagEnd( "ElevatorUp" )
	FlagEnd( "ElevatorSequenceStarted" )

	EndSignal( player, "OnDeath" )

	FlagWait( "SarahInElevator" )


	if ( player.GetOrigin().x > file.sarahTitan.GetOrigin().x )
	{
		// C'mon, Coop. Follow me.
		thread PlayDialogue( "SARAH_FOLLOW_ME", player )
	}

	wait 30.0

	if ( player.GetOrigin().x > file.sarahTitan.GetOrigin().x )
	{
		// This way, Cooper.
		thread PlayDialogue( "SARAH_THIS_WAY_COOPER", player )
	}

	wait 60.0

	// We gotta keep movin, Cooper. Follow me.
	thread PlayDialogue( "SARAH_WE_GOTTA_KEEP_MOVIN", player )
}

void function SidelinesTitansGo()
{
	array<entity> spawnersLeft = GetEntArrayByScriptName( "intro_titan_leftside" )
	spawnersLeft.randomize()
	foreach( entity spawner in spawnersLeft )
		thread SidelinesTitanFightsAndDestroys( spawner )

	array<entity> spawnersRight = GetEntArrayByScriptName( "intro_titan_rightside" )
	spawnersRight.randomize()
	foreach( entity spawner in spawnersRight )
		thread SidelinesTitanFightsAndDestroys( spawner )
}

void function SidelinesTitanFightsAndDestroys( entity spawner )
{
	wait RandomFloat( 2.0 )

	entity titan = spawner.SpawnEntity()
	DispatchSpawn( titan )
	titan.kv.alwaysAlert = 1
	titan.SetValidHealthBarTarget( false )
	titan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
	titan.AssaultSetFightRadius( 16 )

	// Assign a loadout
	string primary = file.friendlyTitanPrimaries[file.sideshowTitanPrimaryIndex]
	TitanLoadoutDef loadout = expect TitanLoadoutDef( GetTitanLoadoutForPrimary( primary ) )
	loadout.setFile = "titan_buddy"
	TakeAllWeapons( titan )
	GiveTitanLoadout( titan, loadout )

	file.sideshowTitanPrimaryIndex++
	if ( file.sideshowTitanPrimaryIndex >= file.friendlyTitanPrimaries.len() )
		file.sideshowTitanPrimaryIndex = 0

	thread DisableTitanName( titan )
	DisableTitanRodeo( titan ) // no rodeo for vanguard class titans (which all friendlies are)

	if ( CoinFlip() )
	{
		titan.ai.buddhaMode = true
		//titan.SetInvulnerable()
	}

	EndSignal( titan, "OnDeath" )
	EndSignal( titan, "OnDestroy" )

	WaitSignal( titan, "OnFinishedAssaultChain" )

	if ( IsValid( titan ) )
		titan.Destroy()
}

void function CreateFakeMissileLockPoints()
{
	array<entity> allTargets = GetEntArrayByScriptName( "wall_missile_target" )
	foreach( entity target in allTargets )
	{
		SetCustomSmartAmmoTarget( target, true )
		target.SetSmartAmmoLockType( SALT_SMALL )
	}

	FlagWait( "WallExplode" )

	foreach( entity target in allTargets )
		SetCustomSmartAmmoTarget( target, false )
}

void function FuelStoragePilotKillsDialogue( entity player )
{
	FlagEnd( "ElevatorSequenceStarted" )
	EndSignal( player, "OnDeath" )

	WaitSignal( player, "KilledTitan" )

	wait 1.5

	// Nice shot, Pilot Cooper. We need to keep moving.
	thread PlayDialogue( "SARAH_NICE_SHOT", player )

	WaitSignal( player, "KilledTitan" )

	wait 1.5

	// Good take down, Pilot. Let's keep moving.
	thread PlayDialogue( "SARAH_GOOD_TAKE_DOWN", player )
}

void function FuelStorageSarahDialogue( entity player )
{
	FlagEnd( "ElevatorSequenceStarted" )
	FlagEnd( "SarahInElevator" )
	EndSignal( player, "OnDeath" )

	FlagWait( "FuelStorageHalfWay" )

	// We've got to get to that ship before it takes off.
	thread PlayDialogue( "SARAH_GET_TO_THAT_SHIP", player )

	FlagWait( "SarahMentionLiftAhead" )

	// Follow me, there's a lift up ahead.
	thread PlayDialogue( "SARAH_LIFT_AHEAD", player )

	wait 50.0

	// You still with me, Pilot? The lift's up ahead. Hurry.
	thread PlayDialogue( "SARAH_NAG_LIFT_AHEAD", player )
}

void function FuelStorageTitanSpawnedDialogue( entity player )
{
	FlagEnd( "ElevatorSequenceStarted" )
	EndSignal( player, "OnDeath" )

	WaitSignal( level, "EnemyTitanSpawned" )
	wait 1.5

	// Watch out. IMC Titans' up ahead.
	waitthread PlayDialogue( "SARAH_WATCH_OUT_TITANS", player )

	// Go. Go. Go.
	waitthread PlayDialogue( "SARAH_GO_GO_GO", player )

	WaitSignal( level, "EnemyTitanSpawned" )
	wait 1.5

	// Take those Titan's out, Pilot.
	waitthread PlayDialogue( "SARAH_TAKE_THOSE_TITANS_OUT", player )

	// Move it, Pilot. Move it.
	waitthread PlayDialogue( "SARAH_MOVE_IT_PILOT", player )

	WaitSignal( level, "EnemyTitanSpawned" )
	wait 1.5

	// Watch out. We've got more company.
	thread PlayDialogue( "SARAH_WATCH_OUT_MORE_COMPANY", player )
}

void function ExtraSmartAmmoRangeForRockets( entity player )
{
	if ( !Flag( "WallExplode" ) )
		AddOffhandWeaponMod_IfPlayerHas( player, OFFHAND_ORDNANCE, "mp_titanweapon_shoulder_rockets", "extended_smart_ammo_range" )
}

void function RemoveExtraSmartAmmoRangeForRockets( entity player )
{
	Assert ( Flag( "WallExplode" ) )
	RemoveOffhandWeaponMod_IfPlayerHas( player, OFFHAND_ORDNANCE, "mp_titanweapon_shoulder_rockets", "extended_smart_ammo_range" )
}

void function DeathCallback_NPCTitan( entity titan, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( attacker.IsPlayer() )
		Signal( attacker, "KilledTitan" )
}



void function SpawnCallback_SuperSpectre( entity npc )
{
	file.superSpectreSpawnCount++
	npc.ai.superSpectreEnableFragDrones = file.superSpectreSpawnCount % 3 == 0
}


void function SpawnCallback_NPCTitan( entity titan )
{
	if ( titan.GetTeam() == TEAM_IMC )
		Signal( level, "EnemyTitanSpawned" )
}
