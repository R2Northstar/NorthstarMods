// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗  ██████╗  ██████╗ ███╗   ███╗████████╗ ██████╗ ██╗    ██╗███╗   ██╗    ███████╗███╗   ██╗██████╗
// ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║╚══██╔══╝██╔═══██╗██║    ██║████╗  ██║    ██╔════╝████╗  ██║██╔══██╗
// ██████╔╝██║   ██║██║   ██║██╔████╔██║   ██║   ██║   ██║██║ █╗ ██║██╔██╗ ██║    █████╗  ██╔██╗ ██║██║  ██║
// ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║   ██║   ██║   ██║██║███╗██║██║╚██╗██║    ██╔══╝  ██║╚██╗██║██║  ██║
// ██████╔╝╚██████╔╝╚██████╔╝██║ ╚═╝ ██║   ██║   ╚██████╔╝╚███╔███╔╝██║ ╚████║    ███████╗██║ ╚████║██████╔╝
// ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝   ╚═╝    ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝    ╚══════╝╚═╝  ╚═══╝╚═════╝
//
// -------------------------------------------------------------------------------------------------------------------------
global function CodeCallback_MapInit
global function Connector_Think

//---------------------
// Adjustable Variables
//---------------------
const WORLD_RUMBLE_WAIT_MIN 				= 12.0
const WORLD_RUMBLE_WAIT_MAX 				= 17.0
const WORLD_RUMBLE_AMPED_WAIT_MIN 			= 5.0
const WORLD_RUMBLE_AMPED_WAIT_MAX 			= 10.0
const ASHFIGHT_SKYBOX_MOVE_MIN 				= 2.0
const ASHFIGHT_SKYBOX_MOVE_MAX 				= 5.0
const ASHFIGHT_SKYBOX_MOVE_TIME 			= 1.5
const ASHFIGHT_REAPER_HEALTH_PERCENT		= 0.5

//---------------------
// Asset Consts
//---------------------
const asset FX_FLYING_ROCK_TRAIL			= $"P_ash_rock_trail"
const asset FX_BIG_ROCK_EXPLOSION			= $"P_impact_exp_FRAG_concrete"
const asset FX_BIG_SKY_PANEL_EXPLOSION  	= $"P_exp_jumble_hex"

const asset TIMESHIFT_RINGS_SE 				= $"models/props/timeshift_rings/timeshift_rings_broken_SE.mdl"

const SFX_PROWLER_POD_POWER_LOOP 			= "Boomtown_ProwlerPod_PowerLoop"
const SFX_GIANT_PILLAR_ROTATE 				= "Boomtown_GiantPillarRotate_Activate"

const SFX_WORLD_RUMBLE_CLOSE 				= "Boomtown_Explosion_Rumble_Exterior_Close"
const SFX_WORLD_RUMBLE_DISTANT 				= "Boomtown_Explosion_Rumble_Exterior_Dist"
const SFX_WORLD_RUMBLE_CLOSE_SMALL 			= "Boomtown_Explosion_Rumble_Interior_Dist"
const SFX_WORLD_RUMBLE_DISTANT_SMALL		= "Boomtown_Explosion_Rumble_Interior_Dist"
const SFX_DOME_ALARM 						= "Boomtown_AboveTheDome_Alarm"

const DIAG_IMC_TITAN_GUARD_MODE 			= "diag_sp_jumbleRun_BM182_01_01_imc_autoTitan"
const DIAG_IMC_GRUNT_GET_TO_SHIP 			= "diag_sp_jumbleRun_BM182_02_01_imc_grunt7"
const DIAG_PA_RESTOCK_PROWLERS 				= "diag_sp_aboveDome_BM121_01_01_imc_facilityPA"
const DIAG_PA_DETONATE_CHARGES_1 			= "diag_sp_aboveDome_BM122_08_01_imc_facilityPA"
const DIAG_PA_DETONATE_CHARGES_2 			= "diag_sp_aboveDome_BM122_09_01_imc_facilityPA"
const DIAG_PA_DETONATE_EVACUATE 			= "diag_sp_aboveDome_BM122_11_01_imc_facilityPA"
const DIAG_PA_DOOR_OPEN						= "diag_sp_jumbleRun_BM182_06_01_imc_facilityPA"
const DIAG_ASH_GTFO 						= "diag_sp_convo_BM201_04a_02_imc_ash"

struct
{
	string currentAmbientRockFX = ""
	string currentHeavyRockFX = ""
	array<entity> sirenRefs = []
} file


void function CodeCallback_MapInit()
{
	ShSpBoomtownEndCommonInit()

	PrecacheModel( TIMESHIFT_RINGS_SE )
	PrecacheEffect( FX_FLYING_ROCK_TRAIL )
	PrecacheEffect( FX_BIG_ROCK_EXPLOSION )
	PrecacheEffect( FX_BIG_SKY_PANEL_EXPLOSION )

	if ( reloadingScripts )
		return

	if ( IsMultiplayer() )
		return

	AddCallback_EntitiesDidLoad( BoomtownEnd_EntitiesDidLoad )
	AddSpawnCallback( "trigger_multiple", AshFight_SetupGruntKillTrigger )

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	InitBoomtownDialogue()
	SPBoomtownUtilityInit()

	RegisterSignal( "GhostRecorderWallrunStart" )
	RegisterSignal( "AshEnteredPhaseShift" )

	//------------------
	// Flags
	//------------------
	FlagInit( "fx_prowler_chamber_rotate" )
	FlagInit( "AboveTheDomeDone" )
	FlagInit( "PreBossFightDone" )
	FlagInit( "BossFightDone" )
	FlagInit( "aboveDome_spawn_reapers" )
	FlagInit( "boomtownEnd_start_world_rumble" )
	FlagInit( "boomtownEnd_pause_world_rumble" )
	FlagInit( "ashFight_delete_escaped_grunts" )
	FlagInit( "played_music_boomtown_01_jumblerun" )
	FlagInit( "aboveDome_change_music" )
	FlagInit( "preAshFight_rock_explosion_0a" )


	//------------------
	// Start Points
	//------------------
	AddStartPoint( "Intro Caves",      	  StartPoint_IntroCaves,          StartPoint_Setup_IntroCaves,          StartPoint_Skipped_IntroCaves )
	AddStartPoint( "Prowler Towers",      StartPoint_ProwlerTowers,       StartPoint_Setup_ProwlerTowers,       StartPoint_Skipped_ProwlerTowers )
	AddStartPoint( "Above The Dome",      StartPoint_AboveTheDome,        StartPoint_Setup_AboveTheDome,        StartPoint_Skipped_AboveTheDome )
	AddStartPoint( "Pre Ash Fight",    	  StartPoint_PreBossFight,        StartPoint_Setup_PreBossFight,        StartPoint_Skipped_PreBossFight )
	AddStartPoint( "Ash Fight",           StartPoint_BossFight,           StartPoint_Setup_BossFight,           StartPoint_Skipped_BossFight )
	
	AddMobilityGhost( $"anim_recording/sp_boomtown_end_prowler_cages.rpak", "aboveDome_prowler_cages_done" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_end_prowler_cages2.rpak", "aboveDome_prowler_cages_done" )
	AddMobilityGhost( $"anim_recording/sp_boomtown_end_jump_to_bt.rpak", "", "GhostRecorderWallrunStart" )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗███╗   ██╗████████╗██████╗  ██████╗      ██████╗ █████╗ ██╗   ██╗███████╗███████╗
// ██║████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗    ██╔════╝██╔══██╗██║   ██║██╔════╝██╔════╝
// ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║    ██║     ███████║██║   ██║█████╗  ███████╗
// ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║    ██║     ██╔══██║╚██╗ ██╔╝██╔══╝  ╚════██║
// ██║██║ ╚████║   ██║   ██║  ██║╚██████╔╝    ╚██████╗██║  ██║ ╚████╔╝ ███████╗███████║
// ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝      ╚═════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚══════╝
// -------------------------------------------------------------------------------------------------------------------------

void function StartPoint_IntroCaves( entity player )
{
	thread BTLoadoutSetup( player )
	thread ProwlerTowers_ProwlerPanelThink( player )
	thread BoomtownEnd_WorldRumbleThink( player )
	thread SetupRockExplosions( player )

	BoomtownEnd_SetCurrentRockFX( "aboveDome_fx_rocks_ambient", "aboveDome_fx_rocks_heavy" )

	Objective_Set( "#BOOMTOWN_END_OBJECTIVE_LOCATE_BT", < -10494.8, -10248.8, -2161.4 > )

	StopMusicTrack( "music_boomtown_19_reapertown_humanenemies" )
	PlayMusic( "music_boomtown_20_abovethedome" )

	wait 3.0

	thread IntroCaves_BliskAshRadioIntercept( player )

	FlagWait( "IntroCavesDone" )
}


void function StartPoint_Setup_IntroCaves( entity player )
{
	TeleportPlayerAndBT( "start_player_IntroCaves", "start_bt_AboveTheDome" )
}


void function StartPoint_Skipped_IntroCaves( entity player )
{
	thread BTLoadoutSetup( player )
	thread ProwlerTowers_ProwlerPanelThink( player )
	thread BoomtownEnd_WorldRumbleThink( player )
	thread SetupRockExplosions( player )

	FlagSet( "boomtownEnd_start_world_rumble" )
}


void function SetupRockExplosions( entity player )
{
	thread BoomtownEnd_RockExplosionThink( player, "preAshFight_rock_explosion_0", "preAshFight_rock_exploder_0", "ashFight_rock_explosion_0_lookat", "preAshFight_rock_0", "Boomtown_PreAshFight_RockExplosion", 10 )
	thread BoomtownEnd_RockExplosionThink( player, "preAshFight_rock_explosion_0a", "preAshFight_rock_exploder_0a", "ashFight_rock_explosion_0a_lookat", "preAshFight_rock_0a", "Boomtown_PreAshFight_RockExplosion", 5 )
	thread BoomtownEnd_RockExplosionThink( player, "preAshFight_rock_explosion_0b", "preAshFight_rock_exploder_0b", "ashFight_rock_explosion_0b_lookat", "preAshFight_rock_0b", "Boomtown_PreAshFight_RockExplosion", 5 )
	thread BoomtownEnd_RockExplosionThink( player, "preAshFight_rock_explosion_1", "preAshFight_rock_exploder_1", "ashFight_rock_explosion_1_lookat", "preAshFight_rock_1", "Boomtown_PreAshFight_RockExplosion", 5 )
	thread BoomtownEnd_RockExplosionThink( player, "preAshFight_rock_explosion_2", "preAshFight_rock_exploder_2", "ashFight_rock_explosion_2_lookat", "preAshFight_rock_2", "Boomtown_PreAshFight_RockExplosion", 5 )
	thread BoomtownEnd_RockExplosionThink( player, "preAshFight_rock_explosion_3", "preAshFight_rock_exploder_3", "ashFight_rock_explosion_3_lookat", "preAshFight_rock_3", "Boomtown_PreAshFight_RockExplosion", 5 )
}


// If the player ever picked up the Brute, then give it to BT to start with.
void function BTLoadoutSetup( entity player )
{
	string brutePrimary = "mp_titanweapon_rocketeer_rocketstream"

	array<string> unlockedLoadouts = GetSPTitanLoadoutsUnlocked()
	foreach( loadout in unlockedLoadouts )
	{
		if ( loadout == brutePrimary )
		{
			entity titan = player.GetPetTitan()

			if ( !IsValid( titan ) )
				return

			TitanLoadoutDef loadout = expect TitanLoadoutDef( GetTitanLoadoutForPrimary( brutePrimary ) )
			loadout.setFile = "titan_buddy"
			TakeAllWeapons( titan )
			GiveTitanLoadout( titan, loadout )

			return
		}
	}
}


void function IntroCaves_BliskAshRadioIntercept( entity player )
{
	player.EndSignal( "OnDestroy" )

	waitthread PlayDialogue( "BLISK_Intro_01", player )
	waitthread PlayDialogue( "ASH_Intro_01", player )
	waitthread PlayDialogue( "BLISK_Intro_02", player )
	waitthread PlayDialogue( "ASH_Intro_02", player )
	waitthread PlayDialogue( "BLISK_Intro_03", player )

	wait 0.75

	waitthread PlayDialogue( "ASH_Intro_03", player )
	waitthread PlayDialogue( "BLISK_Intro_04", player )

	wait 1.0

	waitthread BoomtownEnd_BroadcastFacilityMessage( DIAG_PA_DETONATE_CHARGES_1 )

	thread BoomtownEnd_DoBigWorldRumble( player, true )

	wait 2.0

	waitthread BoomtownEnd_BroadcastFacilityMessage( DIAG_ASH_GTFO )

	wait 3.0

	FlagSet( "boomtownEnd_start_world_rumble" )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗ ██████╗  ██████╗ ██╗    ██╗██╗     ███████╗██████╗     ████████╗ ██████╗ ██╗    ██╗███████╗██████╗ ███████╗
// ██╔══██╗██╔══██╗██╔═══██╗██║    ██║██║     ██╔════╝██╔══██╗    ╚══██╔══╝██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝
// ██████╔╝██████╔╝██║   ██║██║ █╗ ██║██║     █████╗  ██████╔╝       ██║   ██║   ██║██║ █╗ ██║█████╗  ██████╔╝███████╗
// ██╔═══╝ ██╔══██╗██║   ██║██║███╗██║██║     ██╔══╝  ██╔══██╗       ██║   ██║   ██║██║███╗██║██╔══╝  ██╔══██╗╚════██║
// ██║     ██║  ██║╚██████╔╝╚███╔███╔╝███████╗███████╗██║  ██║       ██║   ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████║
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝╚══════╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_ProwlerTowers( entity player )
{
	thread ProwlerTowers_ProwlerRobotArmThink()
	thread ProwlerTowers_ProwlerAnimThink( player )
	thread ProwlerTowers_ProwlerCageUnlockThink()
	thread ProwlerTowers_ProwlerCageHum( player )

	// BT radios pilot 1
	FlagWait( "aboveDome_BT_radio_1" )
	PlayBTDialogue( "BT_AboveDome_DoYouRead" )
	CheckPoint_Silent()

	FlagWait( "ProwlerTowersDone" )
}


void function StartPoint_Setup_ProwlerTowers( entity player )
{
	TeleportPlayerAndBT( "start_player_ProwlerTowers", "start_bt_AboveTheDome" )
}


void function StartPoint_Skipped_ProwlerTowers( entity player )
{
}


void function ProwlerTowers_ProwlerPanelThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity panel = GetEntByScriptName( "abovedome_prowler_panel" )
	panel.SetUsePrompts( "#BOOMTOWN_END_PROWLER_HACK_PROMPT", "#BOOMTOWN_END_PROWLER_HACK_PROMPT" )

	FlagWait( "prowler_cage2_rotate" )

	EmitSoundOnEntity( panel, SFX_GIANT_PILLAR_ROTATE )
	EmitSoundOnEntity( panel, DIAG_PA_RESTOCK_PROWLERS )

	FlagSet("fx_prowler_chamber_rotate")

	wait 1.0
	thread CreateShakeRumbleOnly( player.GetOrigin(), 10, 100, 7 )
}


void function ProwlerTowers_ProwlerCageUnlockThink()
{
	FlagWait( "aboveDome_prowler_cages_done" )

	wait 0.25

	array<entity> cages = GetEntArrayByScriptName( "aboveDome_prowler_cage_frame" )
	foreach( cage in cages )
	{
		cage.ClearParent()
		thread PlayAnim( cage, "open" )
		wait RandomFloatRange( 0.0, 0.1 )
	}
}


void function ProwlerTowers_ProwlerCageHum( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "aboveDome_prowler_cages_done" )

	Remote_CallFunction_Replay( player, "ServerCallback_StartProwlerSFX" )
}


void function ProwlerTowers_ProwlerRobotArmThink()
{
	entity ref = GetEntByScriptName( "arm_cage_grabber_ref" )
	entity arm = GetEntByScriptName( "arm_cage_grabber" )
	entity cage = GetEntByScriptName( "cage_goaway" )
	arm.ClearParent()

	thread PlayAnim( arm, "arm_boomtown_tower_armgrab_idle", ref )

	FlagWait( "aboveDome_prowler_cages_done" )

	cage.ClearParent()
	thread PlayAnim( cage, "cage_boomtown_tower_armgrab_idle", ref )
	thread PlayAnim( arm, "arm_boomtown_tower_armgrab", ref )
	thread PlayAnim( cage, "cage_boomtown_tower_armgrab", ref )
}


void function ProwlerTowers_ProwlerAnimThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "aboveDome_prowler_cages_done" )

	array<entity> prowlers = []
	int maxIndex = 4
	for( int prowlerIndex = 1; prowlerIndex <= maxIndex; prowlerIndex++ )
	{
		prowlers = GetEntArrayByScriptName( "prowler_sleeping" + prowlerIndex )
		foreach( prowler in prowlers )
		{
			prowler.ClearParent()
			thread PlayAnim( prowler, "pr_boomtown_sleep_idle_0" + prowlerIndex)
		}
	}

	thread ProwlerTowers_MadProwler1Think()
	thread ProwlerTowers_MadProwler2Think()
	thread ProwlerTowers_FallingProwlerThink( player )
}


void function ProwlerTowers_MadProwler1Think()
{
	entity ref = GetEntByScriptName( "prowler_mad1_ref" )
	entity prowler = GetEntByScriptName( "prowler_mad1" )
	prowler.ClearParent()
	thread PlayAnim( prowler, "pr_boomtown_tower_cage_01_start_idle", ref )

	FlagWait( "prowler_attack1" )

	PlayAnim( prowler, "pr_boomtown_tower_cage_01_charge", ref )
	PlayAnim( prowler, "pr_boomtown_tower_cage_01_end_idle", ref )
}


void function ProwlerTowers_MadProwler2Think()
{
	entity ref = GetEntByScriptName( "prowler_mad3_ref" )
	entity prowler = GetEntByScriptName( "prowler_mad3" )
	prowler.ClearParent()
	thread PlayAnim( prowler, "pr_boomtown_tower_cage_03_start_idle", ref )

	FlagWait( "prowler_attack3" )

	PlayAnim( prowler, "pr_boomtown_tower_cage_02_charge", ref )
	PlayAnim( prowler, "pr_boomtown_tower_cage_03_end_idle", ref )
}


void function ProwlerTowers_FallingProwlerThink( entity player )
{
	player.EndSignal(  "OnDestroy" )

	entity ref = GetEntByScriptName( "prowler_mad2_ref" )
	entity cage = GetEntByScriptName( "prowler_mad2_cage" )
	entity prowler = GetEntByScriptName( "prowler_mad2" )
	prowler.ClearParent()
	cage.ClearParent()
	thread PlayAnim( prowler, "pr_boomtown_tower_cage_02_start_idle", ref )
	thread PlayAnim( cage, "cage_boomtown_tower_prowler_02_start_idle", ref )

	FlagWait( "prowler_attack2" )

	thread BoomtownEnd_DoBigWorldRumble( player )

	EmitSoundOnEntity( cage, SFX_PROWLER_POD_POWER_LOOP )

	thread PlayAnim( cage , "cage_boomtown_tower_prowler_02_fall", ref )
	waitthread PlayAnim( prowler, "pr_boomtown_tower_cage_02_fall", ref )

	prowler.Destroy()
}


// -------------------------------------------------------------------------------------------------------------------------
//
//  █████╗ ██████╗  ██████╗ ██╗   ██╗███████╗    ██████╗  ██████╗ ███╗   ███╗███████╗
// ██╔══██╗██╔══██╗██╔═══██╗██║   ██║██╔════╝    ██╔══██╗██╔═══██╗████╗ ████║██╔════╝
// ███████║██████╔╝██║   ██║██║   ██║█████╗      ██║  ██║██║   ██║██╔████╔██║█████╗
// ██╔══██║██╔══██╗██║   ██║╚██╗ ██╔╝██╔══╝      ██║  ██║██║   ██║██║╚██╔╝██║██╔══╝
// ██║  ██║██████╔╝╚██████╔╝ ╚████╔╝ ███████╗    ██████╔╝╚██████╔╝██║ ╚═╝ ██║███████╗
// ╚═╝  ╚═╝╚═════╝  ╚═════╝   ╚═══╝  ╚══════╝    ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_AboveTheDome( entity player )
{
	thread BoomtownEnd_BTReaperFightThink( player )

	Objective_Update( < -6634.5, -7859.7, -2257.3 > )

	// Attacked by Spectres and Ticks
	FlagWait( "aboveDome_rumble_1" )
	thread BoomtownEnd_DoBigWorldRumble( player )

	// BT radios pilot 2
	FlagWait( "aboveDome_BT_radio_2" )
	waitthread PlayBTDialogue( "BT_AboveDome_UnderAttack" )

	entity bt = player.GetPetTitan()
	Objective_Set( "#BOOMTOWN_END_OBJECTIVE_JOIN_BT", <0,0,0>, bt )

	thread BoomtownEnd_DoBigWorldRumble( player, true )

	FlagWait( "aboveDome_change_music" )

	StopMusicTrack( "music_boomtown_20_abovethedome" )
	PlayMusic( "music_boomtown_21_btcheksin" )

	FlagWait( "AboveTheDomeDone" )
}


void function StartPoint_Setup_AboveTheDome( entity player )
{
	TeleportPlayerAndBT( "start_player_AboveTheDome", "start_bt_AboveTheDome" )
}


void function StartPoint_Skipped_AboveTheDome( entity player )
{
	thread BoomtownEnd_BTReaperFightThink( player )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗ ██████╗ ███████╗     █████╗ ███████╗██╗  ██╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
// ██╔══██╗██╔══██╗██╔════╝    ██╔══██╗██╔════╝██║  ██║    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
// ██████╔╝██████╔╝█████╗      ███████║███████╗███████║    █████╗  ██║██║  ███╗███████║   ██║
// ██╔═══╝ ██╔══██╗██╔══╝      ██╔══██║╚════██║██╔══██║    ██╔══╝  ██║██║   ██║██╔══██║   ██║
// ██║     ██║  ██║███████╗    ██║  ██║███████║██║  ██║    ██║     ██║╚██████╔╝██║  ██║   ██║
// ╚═╝     ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_PreBossFight( entity player )
{
	player.EndSignal( "OnDestroy" )

	thread PreBossFight_GhostRecorderThink()
	thread PreBossFight_WaitTillEmbark( player )
	thread PreBossFight_TitanSquadSpawnThink()
	thread PreBossFight_ProwlerRoomSpawnThink()
	thread PreBossFight_DetonationWarningThink( player, "preAshFight_detonation_warning", DIAG_PA_DETONATE_CHARGES_2 )

	wait 1.0 // We have to wait 1 because sounds starting on frame 1 wont play due to a bug and we need moving panels to have sounds!

	FlagSet( "aboveTheDome_start_moving_panels" )

	FlagWait( "aboveDome_player_enters_dome" )
	Objective_Clear()

	BoomtownEnd_SetCurrentRockFX( "preAshFight_fx_rocks_ambient", "preAshFight_fx_rocks_heavy" )

	FlagSet( "boomtownEnd_pause_world_rumble" )

	thread BoomtownEnd_ScreenShake( player, 5, 10, 3 )
	thread BoomtownEnd_PlayCloseRumbleSFX( player )

	wait 2.0

	FlagSet( "preAshFight_dropTerrain1" )
	FlagClear( "boomtownEnd_pause_world_rumble" )

	waitthread PlayBTDialogue( "BT_DangerousEnv" )

	FlagWait( "preAshFight_2nd_wave_start" )

	if( player.IsTitan() )
		CheckPoint()

	FlagSet( "boomtownEnd_pause_world_rumble" )

	wait 2.0

	waitthread PlayBTDialogue( "BT_ExitAhead" )
	entity exitSpot = GetEntByScriptName( "ashFight_exitSpot1" )
	Objective_Set( "#BOOMTOWN_END_OBJECTIVE_ESCAPE", exitSpot.GetOrigin() )

	wait 1.0

	FlagSet( "preAshFight_dropTerrain2" )
	FlagSet( "preAshFight_rock_explosion_0a" )
	FlagClear( "boomtownEnd_pause_world_rumble" )

	FlagWait( "preAshFight_tunnel_klaxon" )
	thread BoomtownEnd_PlayKlaxons( 4 )

	FlagWait( "PreBossFightDone" )
}


void function PreBossFight_GhostRecorderThink()
{
	while( 1 )
	{
		FlagWait( "preAshFight_start_ghost_recorder" )

		Signal( level, "GhostRecorderWallrunStart" )

		FlagWaitClear( "preAshFight_start_ghost_recorder" )
	}
}


void function PreBossFight_TitanSquadSpawnThink()
{
	FlagWait( "preAshFight_2nd_wave_start" )

	// Spawn the titan squad to come in
	array<entity> titanSpawners = GetEntArrayByScriptName( "preAshFight_titanSquad" )
	array<entity> titans = SpawnFromSpawnerArray( titanSpawners )

	// Make sure the sniper titan always has hover even if it is removed from weak titans in the future
	foreach( titan in titans )
	{
		if ( titan.HasKey( "script_noteworthy" ) && titan.kv.script_noteworthy == "reapertown_spectre_sniper" )
		{
			TitanLoadoutDef loadout = titan.ai.titanSpawnLoadout
			loadout.antirodeo = "mp_titanability_hover"
			TakeAllWeapons( titan )
			GiveTitanLoadout( titan, loadout )

			break
		}
	}

	FlagWait( "titanSquad_dead" )

	StopMusicTrack( "music_boomtown_22_embarkbt" )
	PlayMusic( "music_boomtown_01_jumblerun" )

	FlagSet( "played_music_boomtown_01_jumblerun" )
}


void function PreBossFight_ProwlerRoomSpawnThink()
{
	FlagWait( "preAshFight_spawn_prowler_guys" )

	// Spawn the escaping grunts
	array<entity> gruntSpawners = GetEntArrayByScriptName( "preAshFight_escaping_grunt" )
	array<entity> grunts = SpawnFromSpawnerArray( gruntSpawners )

	// Spawn the titan that defends the grunts from the Prowlers
	entity titanSpawner = GetEntByScriptName( "preAshFight_damaged_titan" )
	entity titan = titanSpawner.SpawnEntity()
	titan.kv.AccuracyMultiplier = 0.1  // I said across her nose, not up it!
	DispatchSpawn( titan )
	WaitSignal( titan, "WeakTitanHealthInitialized" )
	titan.TakeDamage( titan.GetMaxHealth() * 0.50, null, null, { damageSourceId=damagedef_suicide } )
	DeregisterBossTitan( titan )

	FlagWait( "preAshFight_titan_speaks" )

	if( IsAlive( titan ) )
		EmitSoundOnEntity( titan, DIAG_IMC_TITAN_GUARD_MODE )
}


void function StartPoint_Setup_PreBossFight( entity player )
{
	TeleportPlayerAndBT( "start_player_PreBossFight", "start_bt_PreBossFight" )
}


void function StartPoint_Skipped_PreBossFight( entity player )
{
	FlagSet( "PreBossFightDone" )

	thread PreBossFight_GhostRecorderThink()
	thread PreBossFight_DetonationWarningThink( player, "preAshFight_detonation_warning", DIAG_PA_DETONATE_CHARGES_2 )

	entity exitSpot = GetEntByScriptName( "ashFight_exitSpot1" )
	Objective_Set( "#BOOMTOWN_END_OBJECTIVE_ESCAPE", exitSpot.GetOrigin() )
}


void function PreBossFight_WaitTillEmbark( entity player )
{
	WaitSignal( player, "PlayerEmbarkedTitan" )
	PlayMusic( "music_boomtown_22_embarkbt" )
}


void function PreBossFight_DetonationWarningThink( entity player, string triggerflag, string soundAlias = "" )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( triggerflag )

	if ( soundAlias != "" )
		BoomtownEnd_BroadcastFacilityMessage( soundAlias )
}


void function BoomtownEnd_BTReaperFightThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "aboveDome_spawn_reapers" )

	array<entity> reaperSpawners = GetEntArrayByScriptName( "aboveDome_end_reaper" )
	array<entity> reapers = SpawnFromSpawnerArray( reaperSpawners )
	entity bt = player.GetPetTitan()

	bt.EndSignal( "OnDestroy" )

	// Invincible!
	MakeInvincible( bt )
	foreach( reaper in reapers )
		MakeInvincible( reaper )

	thread MakeReapersVulnerableAfterFlag( reapers )

	FlagWait( "aboveDome_player_joins_fight" )

	// Feels bad to reach BT and have him have no health, so only let him take damage when you finally arrive
	FlagWait( "aboveDome_player_enters_dome" )

	ClearInvincible( bt )
}


// This lets the player hang back and snipe from the ledge if they want
void function MakeReapersVulnerableAfterFlag( array<entity> reapers )
{
	FlagWait( "AboveTheDomeDone" )

	foreach( reaper in reapers )
	{
		if ( IsAlive( reaper ) )
			ClearInvincible( reaper )
	}
}


// -------------------------------------------------------------------------------------------------------------------------
//
//  █████╗ ███████╗██╗  ██╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
// ██╔══██╗██╔════╝██║  ██║    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
// ███████║███████╗███████║    █████╗  ██║██║  ███╗███████║   ██║
// ██╔══██║╚════██║██╔══██║    ██╔══╝  ██║██║   ██║██╔══██║   ██║
// ██║  ██║███████║██║  ██║    ██║     ██║╚██████╔╝██║  ██║   ██║
// ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_BossFight( entity player )
{
	thread AshFight_IntroSpectacleThink( player )
	thread AshFight_SpawnEnemies()

	if ( !Flag( "played_music_boomtown_01_jumblerun" ) )
	{
		StopMusicTrack( "music_boomtown_22_embarkbt" )
		PlayMusic( "music_boomtown_01_jumblerun" )
	}

	BoomtownEnd_SetCurrentRockFX( "ashFight_fx_rocks_ambient", "ashFight_fx_rocks_heavy" )

	FlagSet( "ashFight_openExitDoor" )
	FlagSet( "ashFight_connectExitPath" )

	entity titanClip = GetEntByScriptName( "ashfight_entrance_titan_clip" )
	titanClip.NotSolid()

	FlagWait( "ashFight_startAshIntro" )
	FlagSet( "boomtownEnd_pause_world_rumble" )

	// Kill any titans chasing you into Ash fight
	array<entity> titans = GetNPCArrayEx( "npc_titan", TEAM_IMC, TEAM_ANY, player.GetOrigin(), 20000 )
	foreach ( titan in titans )
	{
		if ( IsValid( titan ) )
			titan.Destroy()
	}

	if ( !player.IsTitan() )
	{
		entity bt = GetPlayerTitanInMap( player )
		if ( IsAlive( bt ) )
		{
			bt.EnableNPCFlag( NPC_IGNORE_ALL )
		}
	}

	StopMusicTrack( "music_boomtown_22_embarkbt" )
	StopMusicTrack( "music_boomtown_01_jumblerun" )
	StopMusicTrack( "music_boomtown_22a_rockfall" )
	PlayMusic( "music_boomtown_23_ashintro" )
	AshFight_BossFightIntro( player, "ashFight_ash" )

	titanClip.Solid()

	if ( !player.IsTitan() )
	{
		entity btTeleportSpot = GetEntByScriptName( "ashFight_bt_teleport_spot" )
		entity bt = GetPlayerTitanInMap( player )
		if ( IsAlive( bt ) )
		{
			bt.SetOrigin( btTeleportSpot.GetOrigin() )
			bt.SetAngles( btTeleportSpot.GetAngles() )
			bt.DisableNPCFlag( NPC_IGNORE_ALL )
		}
	}

	TriggerManualCheckPoint( null, <8270,-1265,-2700>, false )

	AshFight_KillDummyEnemies()

	FlagSet( "ashFight_closeExitDoor" )
	FlagClear( "ashFight_connectExitPath" )
	FlagClear( "boomtownEnd_pause_world_rumble" )

	// Spawn some extra baddies to join the fight.
	thread AshFight_SpawnGuardReapers()
	array<entity> spawnArray = GetEntArrayByScriptName( "ashFight_Spectre_wave2" )
	SpawnFromSpawnerArray( spawnArray )

	Objective_Set( "#BOOMTOWN_END_OBJECTIVE_DEFEAT_ASH", Vector( 0, 0, 0 ) )

	wait 3.0

	FlagSet( "ashFight_delete_escaped_grunts" )

	// Wait until Ash is killed then open the door, spawn a damaged titan to draw your attention to it and play some BT dialogue
	FlagWait( "ashFight_ash_killed" )

	// Achievement!
	UnlockAchievement( player, achievements.BEAT_ASH )

	thread Connector_Think()
	thread AshFight_AshKilledDestroyReapers()
	CheckPoint()

	thread AshFight_ExitObjectiveThink()

	StopMusicTrack( "music_boomtown_23_ashintro" )
	PlayMusic( "music_boomtown_24_ashdefeat" )

	wait 5.0

	FlagSet( "ashFight_openExitDoor" )
	FlagSet( "ashFight_connectExitPath" )

	entity doorSeparator = GetEntByScriptName( "ashFight_exit_door_separator" )
	doorSeparator.NotSolid()

	array<entity> doorModels = GetEntArrayByScriptName( "ashFight_ash_door" )
	foreach( door in doorModels )
		door.Solid()

	waitthread BoomtownEnd_BroadcastFacilityMessage( DIAG_PA_DOOR_OPEN )

	waitthread PlayBTDialogue( "BT_ExitThruTunnel" )

	wait 1.0

	Objective_Remind()

	FlagWait( "ashFight_bt_comments_on_storm" )

	wait 1.5
	waitthread PlayBTDialogue( "BT_NoMoreShortcuts" )

	WaitForever()
}


void function StartPoint_Setup_BossFight( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	TeleportPlayerAndBT( "start_player_BossFight", "start_bt_BossFight" )
}


void function StartPoint_Skipped_BossFight( entity player )
{
}


void function AshFight_ExitObjectiveThink()
{
	entity exitSpot = GetEntByScriptName( "ashFight_exitSpot1" )
	Objective_Set( "#BOOMTOWN_END_OBJECTIVE_ESCAPE", exitSpot.GetOrigin() )

	FlagWait( "ashFight_move_objective_to_tunnel" )
	exitSpot = GetEntByScriptName( "ashFight_exitSpot2" )
	Objective_Update( exitSpot.GetOrigin() )

	FlagWait( "ashFight_bt_comments_on_storm" )
	Objective_Update( < 7500, 30059, 1500 > )
	Objective_AddKilometers( 19.3 )
}


void function AshFight_IntroSpectacleThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "ashFight_spawnGuys" )

	// Drop ship dusts off and flies away
	entity ship = GetEntByScriptName( "jumblerun_dropship1" )
	entity ship_ref = GetEntByScriptName( "jumblerun_dropship1_ref" )

	thread PlayAnim( ship, "dropship_boomtown_evac_takoff_A", ship_ref )

	FlagWait( "ashFight_introSpectacle" )

	entity explosionSpot = GetEntByScriptName( "ashFight_explosion_lookat" )
	WaitTillLookingAt( player, explosionSpot, true, 30, 5000, 8.0 )

	// Sky panel explosion
	thread AshFight_SkyPanelExplosion( player )

	// Make grunts stumble due to big explosion
	vector angles = <0,180,0>
	array<entity> guys = GetNPCArrayByClass( "npc_soldier" )
	foreach( guy in guys )
		thread AshFight_GruntStumble( guy, angles )
}


void function AshFight_SpawnEnemies()
{
	FlagWait( "ashFight_spawnGuys" )

	// Spawn the escaping grunts
	array<entity> gruntSpawners = GetEntArrayByScriptName( "ashFight_escapingGrunt" )
	array<entity> grunts = SpawnFromSpawnerArray( gruntSpawners )
	thread AshFight_EscapingGruntsThink( grunts )

	thread AshFight_IntroGruntsYell()

	// Spawn the damaged reaper
	entity reaperSpawner = GetEntByScriptName( "ashFight_damagedReaper" )
	entity reaper = reaperSpawner.SpawnEntity()
	DispatchSpawn( reaper )
	reaper.TakeDamage( reaper.GetMaxHealth() * 0.99, null, null, { damageSourceId=damagedef_suicide } )
	reaper.EnableNPCFlag( NPC_IGNORE_ALL )

	// Spawn the damaged stalkers
	array<entity> stalkerSpawners = GetEntArrayByScriptName( "ashFight_damagedSpectre" )
	array<entity> stalkers = SpawnFromSpawnerArray( stalkerSpawners )
	foreach ( stalker in stalkers )
	{
		stalker.TakeDamage( stalker.GetMaxHealth() * 0.99, null, null, { damageSourceId=damagedef_suicide } )
		stalker.EnableNPCFlag( NPC_IGNORE_ALL )
	}

	// Spawn the normal spectres
	array<entity> spectreSpawners = GetEntArrayByScriptName( "ashFight_Spectre" )
	array<entity> spectres = SpawnFromSpawnerArray( spectreSpawners )
}


void function AshFight_KillDummyEnemies()
{
	array<entity> guys = GetEntArrayByScriptName( "ashFight_damagedSpectre" )
	foreach( guy in guys )
	{
		if ( IsAlive( guy ) )
			guy.TakeDamage( guy.GetMaxHealth() + 1, null, null, { damageSourceId=damagedef_suicide } )
	}
}


void function AshFight_SpawnGuardReapers()
{
	array<entity> spawnArray = GetEntArrayByScriptName( "ashFight_reaper" )
	foreach( spawner in spawnArray )
	{
		if ( Flag( "ashFight_ash_killed" ) )
			return

		entity reaper = spawner.SpawnEntity()
		DispatchSpawn( reaper )
		reaper.TakeDamage( reaper.GetMaxHealth() * ASHFIGHT_REAPER_HEALTH_PERCENT, null, null, { damageSourceId=damagedef_suicide } )

		wait 30
	}
}


void function AshFight_AshKilledDestroyReapers()
{
	array<entity> reapers = GetNPCArrayByClass( "npc_super_spectre" )
	foreach( reaper in reapers )
		reaper.TakeDamage( reaper.GetMaxHealth() + 1, null, null, { damageSourceId=damagedef_suicide } )
}


void function AshFight_EscapingGruntsThink( array<entity> grunts )
{
	foreach ( grunt in grunts )
		grunt.EnableNPCFlag( NPC_IGNORE_ALL )

	FlagWait( "ashFight_closeExitDoor" )

	entity assaultPoint = GetEntByScriptName( "AshFight_stranded_grunt_assault_point" )
	float radius = 1500
	if ( assaultPoint.HasKey( "script_goal_radius" ) )
		radius = float( assaultPoint.kv.script_goal_radius )

	// Have the grunts give up on their dreams of escape and hunker down until their inevitable demise.
	foreach ( grunt in grunts )
	{
		if ( IsAlive( grunt ) )
		{
			grunt.AssaultPoint( assaultPoint.GetOrigin() )
			grunt.AssaultSetGoalRadius( radius )
			grunt.DisableNPCFlag( NPC_IGNORE_ALL )
		}
	}
}


void function AshFight_IntroGruntsYell()
{
	FlagWait( "ashFight_introGruntsYell" )
	entity talkSpot = GetEntByScriptName( "ashFight_introGruntCommentSpot" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, talkSpot.GetOrigin(), DIAG_IMC_GRUNT_GET_TO_SHIP )
}


void function AshFight_SetupGruntKillTrigger( entity trigger )
{
	string name = trigger.GetScriptName()
	if ( name.find( "ashFight_grunt_kill_trigger" ) != 0 )
		return

	trigger.ConnectOutput( "OnStartTouch", AshFight_KillGruntOnTrigger )
}


void function AshFight_KillGruntOnTrigger( entity trigger, entity ent, entity caller, var value )
{
	if ( ent.IsPlayer() )
		return

	thread AshFight_GruntKill( ent )
}


void function AshFight_GruntKill( entity ent )
{
	FlagWait( "ashFight_delete_escaped_grunts" )

	if ( !IsValid( ent ) )
		return

	ent.Destroy()
}


void function AshFight_SkyPanelExplosion( entity player )
{
	entity explosionEnt   = GetEntByScriptName( "ashFight_skyPanelExplosionEnt" )
	entity explosionFXEnt = GetEntByScriptName( "ashFight_skyPanelExplosionFXEnt" )

	array<entity> panels = GetEntArrayByScriptName( "ashFight_flyingPanel" )
	array<entity> physPanels = []
	foreach( panel in panels )
	{
		entity physPanel = TurnEntityIntoPhysEntity( panel, 4500 )
		physPanels.append( physPanel )
	}

	thread BoomtownEnd_StopPhysicsAfterTime( physPanels, 10 )

	CreateExplosionOnEntity( player, explosionEnt, explosionFXEnt, FX_BIG_SKY_PANEL_EXPLOSION, "Boomtown_PreAshfight_DomeWall_BlowOut" )

	thread BoomtownEnd_ScreenShake( player, 5, 10, 3 )
	thread BoomtownEnd_PlayCloseRumbleSFX( player )
}


entity function AshFight_BossFightIntro( entity player, string spawnerName )
{
	player.EndSignal( "OnDestroy" )

	// Don't allow embark or disembark during titan intro because it causes issues if you're doing a sequence at the time
	Embark_Disallow( player )
	Disembark_Disallow( player )
	wait 1.0

	// Spawn Boss
	entity titanSpawner = GetEntByScriptName( spawnerName )
	table spawnerKeyValues = titanSpawner.GetSpawnEntityKeyValues()
	entity titan = titanSpawner.SpawnEntity()
	DispatchSpawn( titan )
	titan.SetTitle( "#BOSSNAME_ASH" )
	HideName( titan )
	titan.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS )

	// Store off Ash's weapon and give it back later in the animation
	entity weapon = titan.GetActiveWeapon()
	array<string> mods = weapon.GetMods()
	string weaponName = weapon.GetWeaponClassName()
	titan.TakeActiveWeapon()

	// Get spawn a dummy weapon model that is holstered
	string attachTag    = "RIFLE_HOLSTER"
	asset weaponModel   = weapon.GetModelName()
	int attachID 		= titan.LookupAttachment( attachTag )
	vector attachPos    = titan.GetAttachmentOrigin( attachID )
	vector attachAngles = titan.GetAttachmentAngles( attachID )
	entity dummyGun	    = CreatePropDynamic( weaponModel, attachPos, attachAngles )
	dummyGun.SetParent( titan, attachTag, false, 0 )

	WaitSignal( titan, "AshEnteredPhaseShift" )

	PhaseShift( titan, 0, 1.5 )

	wait 1.0

	entity phaseSpot = AshFight_GetPhaseSpot()

	titan.SetOrigin( phaseSpot.GetOrigin() )
	titan.SetAngles( phaseSpot.GetAngles() )

	AssaultEntity( titan, phaseSpot )

	// thread PlayAnim( titan, "lt_boomtown_boss_intro_end" )

	// Re-enable real weapon & destroy the dummy prop
	titan.GiveWeapon( weaponName, mods )
	dummyGun.Destroy()

	titan.SetTitle( "#BOSSNAME_ASH" )
	ShowName( titan )

	titan.SetEnemy( player )

	Embark_Allow( player )
	Disembark_Allow( player )

	return titan
}


entity function AshFight_GetPhaseSpot()
{
	string entName = "ashFight_ash_phase_spot_north"
	entity ent = GetEntByScriptName( "ashFight_ash_phase_spot_north" )
	return ent
}


void function AshFight_GruntStumble( entity guy, vector angles )
{
	if ( !IsAlive( guy ) )
		return
	guy.EndSignal( "OnDeath" )

	if ( !guy.IsInterruptable() )
		return
	if ( guy.Anim_IsActive() )
		return
	if ( !( guy.IsOnGround() ) )
		return

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

void function Connector_Think()
{
	FlagWait( "ashFight_bt_comments_on_storm" )

	entity node = GetEntByScriptName( "connecter_rings" )
	entity rings = CreatePropDynamic( TIMESHIFT_RINGS_SE, node.GetOrigin(), node.GetAngles() )
	rings.DisableHibernation()
	rings.EnableRenderAlways()

	FlagSet( "boomtownEnd_pause_world_rumble" )

	entity skyboxCamLevel = GetEnt( "skybox_cam_level" )
	skyboxCamLevel.ClearParent()
	entity mover = CreateOwnedScriptMover( skyboxCamLevel )
	skyboxCamLevel.SetParent( mover )
	//mover.NonPhysicsRotateTo( < 0, 0, -5.5 >, ASHFIGHT_SKYBOX_MOVE_TIME, 0.5, 0.5 )
	mover.NonPhysicsRotateTo( < 0, 0, -4 >, ASHFIGHT_SKYBOX_MOVE_TIME, 0.5, 0.5 )
	level.mover <- mover
}

// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
// ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
// ██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
// ██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
// ╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
//  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function BoomtownEnd_RockExplosionThink( entity player, string flagName, string exploderName, string lookAtName, string rockName, string sfxName, float physicsTime )
{
	player.EndSignal(  "OnDestroy" )

	FlagWait( flagName )

	entity explosionSpot = GetEntByScriptName( exploderName )
	entity lookAtSpot = GetEntByScriptName( lookAtName )
	array<entity> rocks = GetEntArrayByScriptName( rockName )

	WaitTillLookingAt( player, lookAtSpot, true, 30, 5000, 5.0 )

	FlagSet( "boomtownEnd_pause_world_rumble" )

	// HACK:  Hard code this music cue for this explosion because it will be too risky at this point to change this entire system to support it.
	if( flagName == "preAshFight_rock_explosion_2" )
	{
		StopMusicTrack( "music_boomtown_22_embarkbt" )
		StopMusicTrack( "music_boomtown_01_jumblerun" )
		PlayMusic( "music_boomtown_22a_rockfall" )
		wait 1.9  // music_boomtown_22a_rockfall has a 1.9 second buildup before the event when the explosion happens.
	}

	array<entity> physRocks = []
	foreach( rock in rocks )
	{
		entity physRock = TurnEntityIntoPhysEntity( rock )
		PlayFXOnEntity( FX_FLYING_ROCK_TRAIL, physRock )
		physRocks.append( physRock )
	}

	thread BoomtownEnd_StopPhysicsAfterTime( physRocks, physicsTime )

	CreateExplosionOnEntity( player, explosionSpot, explosionSpot, FX_BIG_ROCK_EXPLOSION, sfxName )

	thread BoomtownEnd_DoBigWorldRumble( player )

	FlagClear( "boomtownEnd_pause_world_rumble" )
}


void function BoomtownEnd_StopPhysicsAfterTime( array<entity> ents, float waitTime = 5.0 )
{
	wait waitTime

	foreach( ent in ents )
	{
		if ( IsValid( ent ) )
			ent.StopPhysics()
	}
}


void function BoomtownEnd_SetCurrentRockFX( string ambientFlag, string heavyFlag )
{
	if ( file.currentAmbientRockFX != "" )
		FlagClear( file.currentAmbientRockFX )

	if ( file.currentHeavyRockFX != "" )
		FlagClear( file.currentHeavyRockFX )

	file.currentAmbientRockFX = ambientFlag
	file.currentHeavyRockFX = heavyFlag

	FlagSet( file.currentAmbientRockFX )
}


void function BoomtownEnd_BroadcastFacilityMessage( string soundAlias )
{
	float soundDuration = 0.0

	foreach( siren in file.sirenRefs )
		soundDuration = EmitSoundAtPosition( TEAM_UNASSIGNED, siren.GetOrigin(), soundAlias )

	wait soundDuration
}


void function BoomtownEnd_PlayKlaxons( int count )
{
	float waitTime = 2.25

	for( int i = 0; i < count; i++ )
	{
		foreach( siren in file.sirenRefs )
			thread KlaxonPlayAndStop( siren, waitTime )

		wait waitTime
	}
}


void function KlaxonPlayAndStop( entity siren, float waitTime )
{
	EmitSoundAtPosition( TEAM_UNASSIGNED, siren.GetOrigin(), SFX_DOME_ALARM )
	wait waitTime
	StopSoundAtPosition( siren.GetOrigin(), SFX_DOME_ALARM )
}


void function BoomtownEnd_PlayCloseRumbleSFX( entity player )
{
	if ( Flag( "player_in_small_area" ) )
		EmitSoundOnEntity( player, SFX_WORLD_RUMBLE_CLOSE_SMALL )
	else
		EmitSoundOnEntity( player, SFX_WORLD_RUMBLE_CLOSE )
}


void function BoomtownEnd_PlayDistantRumbleSFX( entity player )
{
	if ( Flag( "player_in_small_area" ) )
		EmitSoundOnEntity( player, SFX_WORLD_RUMBLE_DISTANT_SMALL )
	else
		EmitSoundOnEntity( player, SFX_WORLD_RUMBLE_DISTANT )
}


void function BoomtownEnd_WorldRumbleThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "boomtownEnd_start_world_rumble" )

	vector startAngles = < 0, -90, 0 >  // For some reason, skyboxCamLevel.GetAngles() returns 0,0,0 even though it is 0,-90,0
	entity skyboxCamLevel = GetEnt( "skybox_cam_level" )
	entity mover = CreateScriptMover()
	mover.SetOrigin( skyboxCamLevel.GetOrigin() )
	mover.SetAngles( startAngles )
	skyboxCamLevel.SetParent( mover )

	float waitTime
	while( 1 )
	{
		if ( Flag( "boomtownEnd_pause_world_rumble" ) )
		{
			wait 1.0
			continue
		}

		//printt("RUMBLE!!!!")

		float moveAmount = RandomFloatRange( ASHFIGHT_SKYBOX_MOVE_MIN, ASHFIGHT_SKYBOX_MOVE_MAX ) * -1
		BoomtownEnd_DoSmallWorldRumble( player, mover, moveAmount )

		// Amp it up once we start heading to the boss and do more frequent rumbles.

		if( Flag( "PreBossFightDone" ) )
			waitTime = RandomFloatRange( WORLD_RUMBLE_AMPED_WAIT_MIN, WORLD_RUMBLE_AMPED_WAIT_MAX )
		else
			waitTime = RandomFloatRange( WORLD_RUMBLE_WAIT_MIN, WORLD_RUMBLE_WAIT_MAX )

		//printt("WAITING: ", waitTime )

		wait waitTime

		BoomtownEnd_DoSmallWorldRumble( player, mover, 0 )
	}
}


void function BoomtownEnd_DoSmallWorldRumble( entity player, entity mover = null, float moveAmount = 0 )
{
	vector skyboxMoveVector = < moveAmount, -90, 0 >

	// Special case for above the dome FX where you get to see them a lot more.  Always make them play!
	if( file.currentHeavyRockFX == "aboveDome_fx_rocks_heavy" )
		thread BoomtownEnd_AboveDomeHeavyRocks()

	thread BoomtownEnd_ScreenShake( player, 1, 5, 3 )
	thread BoomtownEnd_PlayDistantRumbleSFX( player )

	if ( mover != null )
		mover.NonPhysicsRotateTo( skyboxMoveVector, ASHFIGHT_SKYBOX_MOVE_TIME, 0.5, 0.5 )

	thread CreateShakeRumbleOnly( player.GetOrigin(), 10, 105, 3 )
}


void function BoomtownEnd_DoBigWorldRumble( entity player, bool doKlaxon = false )
{
	if ( file.currentHeavyRockFX != "" )
		FlagSet( file.currentHeavyRockFX )

	if( doKlaxon )
	{
		thread BoomtownEnd_PlayKlaxons( 4 )
		wait 1.0
	}

	thread BoomtownEnd_ScreenShake( player, 5, 10, 3 )
	thread BoomtownEnd_PlayCloseRumbleSFX( player )

	if ( file.currentHeavyRockFX != "" )
		FlagClear( file.currentHeavyRockFX )

	thread CreateShakeRumbleOnly( player.GetOrigin(), 20, 150, 3 )

}


void function BoomtownEnd_AboveDomeHeavyRocks()
{
	FlagSet( file.currentHeavyRockFX )

	wait WORLD_RUMBLE_WAIT_MIN - 3

	FlagClear( file.currentHeavyRockFX )
}


void function BoomtownEnd_ScreenShake( entity player, float amplitude, float frequency, float duration )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_BoomtownScreenShake", amplitude, frequency, duration )
}


entity function TurnEntityIntoPhysEntity( entity ent, float fadedist = 99999 )
{
	entity physEnt = CreatePropPhysics( ent.GetModelName(), ent.GetOrigin(), ent.GetAngles() )
	physEnt.kv.solid = SOLID_VPHYSICS
	physEnt.kv.fadedist = fadedist

	ent.Destroy()

	return physEnt
}


void function CreateExplosionOnEntity( entity player, entity ent, entity fxEnt, asset fx, string sfxName )
{
	Explosion(
		ent.GetOrigin(),
		player,						// attacker
		player,						// inflictor
		1000, 						// normal damage
		1000, 						// heavy armor damage
		512, 						// inner radius
		512,  						// outer radius
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,
		ent.GetOrigin(),
		25000,						// force
		damageTypes.explosive,
		eDamageSourceId.burn,
		"" )

	PlayFX( fx, fxEnt.GetOrigin() )
	EmitSoundAtPosition( TEAM_UNASSIGNED, ent.GetOrigin(), sfxName )
}


void function AssaultEntity( entity guy, entity target, float radius = 1024 )
{
	vector origin = target.GetOrigin()
	vector angles = target.GetAngles()
	if ( target.HasKey( "script_goal_radius" ) )
		radius = float( target.kv.script_goal_radius )

	guy.AssaultPoint( origin )
	guy.AssaultSetGoalRadius( radius )

	if ( target.HasKey( "face_angles" ) && target.kv.face_angles == "1" )
		guy.AssaultSetAngles( angles, true )
}


// -------------------------------------------------------------------------------------------------------------------------
//
//  ██████╗ █████╗ ██╗     ██╗     ██████╗  █████╗  ██████╗██╗  ██╗███████╗
// ██╔════╝██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝
// ██║     ███████║██║     ██║     ██████╔╝███████║██║     █████╔╝ ███████╗
// ██║     ██╔══██║██║     ██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ╚════██║
// ╚██████╗██║  ██║███████╗███████╗██████╔╝██║  ██║╚██████╗██║  ██╗███████║
//  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function BoomtownEnd_EntitiesDidLoad()
{
	file.sirenRefs = GetEntArrayByScriptName( "ref_siren" )
}
