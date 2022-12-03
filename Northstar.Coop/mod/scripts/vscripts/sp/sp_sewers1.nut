// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗ ███████╗ ██████╗██╗      █████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
// ██╔══██╗██╔════╝██╔════╝██║     ██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
// ██████╔╝█████╗  ██║     ██║     ███████║██╔████╔██║███████║   ██║   ██║██║   ██║██╔██╗ ██║
// ██╔══██╗██╔══╝  ██║     ██║     ██╔══██║██║╚██╔╝██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
// ██║  ██║███████╗╚██████╗███████╗██║  ██║██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
// ╚═╝  ╚═╝╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
//
// -------------------------------------------------------------------------------------------------------------------------
untyped

const TITAN_PILOT = $"models/humans/pilots/sp_medium_reaper_m.mdl"

global function CodeCallback_MapInit

//---------------------
// Tweakable Variables
//---------------------
const float BT_CORE_START_VALUE_ON_PLAYER_RETURN	= 0.6 // 60%
const float SEWER_DEFEND_TICK_TIMEOUT_MIN			= 55.0
const float SEWER_DEFEND_TICK_TIMEOUT_MAX			= 60.0

//---------------------
// Asset Consts
//---------------------
const asset KANE_MODEL 				= $"models/Humans/heroes/imc_hero_kane.mdl"
const asset KANE_TITAN_MODEL_HD		= $"models/titans/heavy/sp_titan_heavy_ogre_hd.mdl"
const asset HELMET_MODEL 			= $"models/Humans/heroes/imc_hero_kane_helmet.mdl"
const asset STRATON_MODEL			= $"models/vehicle/straton/straton_imc_gunship_01.mdl"

const asset FX_WARNING_LIGHT		= $"warning_light_orange_blink_nowall"
const asset FX_EXP_KANE_DEATH_START = $"P_titan_state_change"
const asset FX_EXP_KANE_DEATH_DONE	= $"xo_exp_death"

const SFX_GATE_OPEN_ALARM 			= "sewers_Boomtown_AboveTheDome_Alarm"		// TEMP: Needs real asset
const SFX_KANE_EXPLOSION			= "Goblin_Dropship_Explode"					// TEMP: Needs real asset
const SFX_SLUDGE_WALL_CURTAIN		= "sewers_emit_sludgecurtain_curtainroom"
const SFX_SLUDGE_WALL_GROUND		= "sewers_emit_sludgecurtain_ground_curtainroom"

const asset FX_BT_BODY_DAMAGED_POP 	= $"xo_spark_med"

struct
{
	entity friendlyTitanFreeborn
	entity friendlyTitanShaver
	entity SewerArena_pumpSwitch
	array<entity> PASpeakers
	int numSpawnGroupsFinished
	string playerCombatState = "idle"
	entity kaneTitan
	Point kaneBodyPoint
	string lastBTweaponName
	float lastBTCoreTime
	bool clearedOnScreenLoadoutHint
} file


global struct EntityLevelStruct
{
	entity mover
}

void function CodeCallback_MapInit()
{
	ShSpSewersCommonInit()
	PrecacheModel( KANE_MODEL )
	PrecacheModel( KANE_TITAN_MODEL_HD )
	PrecacheModel( HELMET_MODEL )
	PrecacheModel( NEUTRAL_SPECTRE_MODEL )
	PrecacheModel( TITAN_PILOT )

	PrecacheParticleSystem( FX_WARNING_LIGHT )
	PrecacheParticleSystem( FX_EXP_KANE_DEATH_START )
	PrecacheParticleSystem( FX_EXP_KANE_DEATH_DONE )

	PrecacheParticleSystem( FX_BT_BODY_DAMAGED_POP )

	AddClientCommandCallback( "UI_Sewers_ClearOnScreenHint", ClientCommand_ClearOnScreenHint )

	if ( reloadingScripts )
		return

	if ( IsMultiplayer() )
		return

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	//------------------
	// Flags
	//------------------
	FlagInit( "intro_sludge_hint" )
	FlagInit( "SewerSplit_OpenGate_Done" )
	FlagInit( "SewerArena_pumps_start_shutdown" )
	FlagInit( "SewerArenaDefendDone" )
	FlagInit( "SewerArena_IntroVO_Done" )
	FlagInit( "SewerArena_SightClipRemoved" )
	FlagInit( "PilotArena_Combat_Done" )
	FlagInit( "PlayerConvo_WhoIsKane" )
	FlagInit( "SludgeFalls_Militia_Stalker_Radio" )
	FlagInit( "stalkerWIthBackTurned_spawn" )
	FlagInit( "Corkscrew_grunts_attack_door_stalker" )
	FlagInit( "Corkscrew_door_stalker_dead" )
	FlagInit( "Corkscrew_greeter2_attacked_stalker" )
	FlagInit( "KaneArena_kane_dead" )
	FlagInit( "KaneArena_kane_pilot_dead" )
	FlagInit( "KaneArena_helmet_ready_for_pickup" )
	FlagInit( "KaneArena_radio_intercept_done")
	FlagInit( "KaneRadioPickup_SequenceStart" )
	FlagInit( "KaneRadioPickup_SkipHighlightingKane" )
	FlagInit( "Sewers_Kane_PA_Line" )

	FlagSet( "DisableDropships" )

	RegisterSignal( "StopFlybys" )
	RegisterSignal( "AnimRadioGet_RadioDetachFromHelmet" )
	RegisterSignal( "AnimRadioGet_PlayRadioTransmission" )
	RegisterSignal( "PlayerCombatStateChanged" )
	RegisterSignal( "PlayerLeftSewerDefend" )
	RegisterSignal( "kane_death_anim_done" )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddCallback_OnPlayerRespawned( PlayerDidRespawn )

	//------------------
	// Start Points
	//------------------
	AddStartPoint( "Channel Mortar Run",	StartPoint_ChannelMortarRun, 	StartPoint_Setup_ChannelMortarRun, 		StartPoint_Skipped_ChannelMortarRun )
	AddStartPoint( "Sewer Split", 			StartPoint_SewerSplit, 			StartPoint_Setup_SewerSplit, 			StartPoint_Skipped_SewerSplit )
	AddStartPoint( "Sludge Falls", 			StartPoint_SludgeFalls, 		StartPoint_Setup_SludgeFalls, 			StartPoint_Skipped_SludgeFalls )
	AddStartPoint( "Corkscrew Room", 		StartPoint_CorkscrewRoom, 		StartPoint_Setup_CorkscrewRoom, 		StartPoint_Skipped_CorkscrewRoom )
	AddStartPoint( "Pipe Room Climb", 		StartPoint_PipeRoomClimb, 		StartPoint_Setup_PipeRoomClimb, 		StartPoint_Skipped_PipeRoomClimb )
	AddStartPoint( "Sewer Arena", 			StartPoint_SewerArena, 			StartPoint_Setup_SewerArena, 			StartPoint_Skipped_SewerArena )
	AddStartPoint( "Sewer Arena Defend", 	StartPoint_SewerArenaDefend,	StartPoint_Setup_SewerArenaDefend, 		StartPoint_Skipped_SewerArenaDefend )
	AddStartPoint( "Kane Arena", 			StartPoint_KaneArena, 			StartPoint_Setup_KaneArena, 			StartPoint_Skipped_KaneArena )

	SewerCommon_Init()
	Sewers1_VO_Init()

	AddMobilityGhost( $"anim_recording/sp_sewers_leap_to_slide.rpak" )
	AddMobilityGhost( $"anim_recording/sp_sewers_leap_to_sniper.rpak" )
	AddMobilityGhost( $"anim_recording/sp_sewers_leap_to_grunts.rpak" )
	AddMobilityGhost( $"anim_recording/sp_sewers_leap_2ndfloor_grunts.rpak" )
	AddMobilityGhost( $"anim_recording/sp_sewers_piperoom_climb.rpak" )
}


void function EntitiesDidLoad()
{
	file.SewerArena_pumpSwitch = GetEntByScriptName( "pilotarena_pump_switch" )
	file.SewerArena_pumpSwitch.SetUsePrompts( "#SEWERS_HINT_DISABLE_SLUDGE", "#SEWERS_HINT_DISABLE_SLUDGE" )

	file.PASpeakers = GetEntArrayByScriptName( "sewers_pa_system_sfx_spot" )

	Objective_InitEntity( GetEntByScriptName( "SewerSplit_gate_switch" ) )
	Objective_InitEntity( GetEntByScriptName( "pilotarena_pump_switch" ) )

	thread SewersSpecialThink()
}


void function PlayerDidRespawn( entity player )
{
	SetPlayer0( player )
	thread TrackPlayerCombatState( player )
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
void function StartPoint_ChannelMortarRun( entity player )
{
	thread ChannelMortarRun_FirstTitanfallGuy( player )
	thread ChannelMortarRun_NewWeaponDialogThink( player )
	thread ChannelMortarRun_SludgeHintThink( player )
	thread ChannelMortarRun_IntroIMCTitans( player )
	thread ChannelMortarRun_MilitiaTitansThink( player )
	thread ChannelMortarRun_DropShipsThink()
	thread ChannelMortarRun_GruntCommentsThink( player )
	thread ChannelMortarRun_SkyShowThink()

	thread PA_SystemThink( player )
	thread Kane_PA_IntroBroadcastThink( player )
	thread Kane_PA_BroadcastThink( player, "KANE_PA_KANES_PLACE", "SludgeFalls_KanePA_1" )
	thread Kane_PA_BroadcastThink( player, "KANE_PA_SRS_TITAN_HERE", "CorkscrewRoom_KanePA_1" )
	thread Kane_PA_BroadcastThink( player, "KANE_PA_IM_COMING_DOWN", "SewerDefend_KanePA_1" )

	player.SetPlayerNetBool( "shouldShowWeaponFlyout", false )

	ShowIntroScreen( player )
	// Remote_CallFunction_NonReplay( player, "ServerCallback_LevelIntroText" )
	StartLevelStartText()
	PlayMusic( "music_reclamation_01_intro" )
	FlagWait( "IntroScreenFading" )
	
	EndEvent()

	wait 2.0

	PlayBTDialogue( "BT_Intro_01" )
	PlayBTDialogue( "BT_Intro_03" )

	wait 1
	thread ChannelMortarRun_BreadcrumbObjectives()

	player.SetPlayerNetBool( "shouldShowWeaponFlyout", true )

	FlagWait( "intro_militia_distant_battle_sfx" )
	entity battleSfxSpot = GetEntByScriptName( "Channel_distant_battle_sfx_spot" )
	EmitSoundAtPosition( TEAM_ANY, battleSfxSpot.GetOrigin(), "sewers_scripted_distanttitanbattle" )

	FlagWait( "intro_militia_radio_broadcast" )
	StopMusicTrack( "music_reclamation_01_intro" )
	PlayMusic( "music_reclamation_02_intobattle" )
	thread ChannelMortarRun_FriendlyRadioBroadcast( player )

	FlagWait( "Channel_player_entered_river" )
	StopMusicTrack( "music_reclamation_02_intobattle" )
	PlayMusic( "music_reclamation_03_jumpintoriver" )

	thread ChannelMortarRun_TeleportBTThink( player )
	thread ChannelMortarRun_FriendlyTitansTalk()

	FlagWait( "Channel_sewer_start_music" )
	StopMusicTrack( "music_reclamation_04_firsttitanbattle" )
	PlayMusic( "music_reclamation_05_enterthesewer" )

	FlagWait( "MortarRunDone" )
}


void function ChannelMortarRun_BreadcrumbObjectives()
{
	entity crumb1 = GetEntByScriptName( "channelRun_first_waypoint" )
	entity crumb2 = GetEntByScriptName( "channelRun_second_waypoint" )

	Objective_WayPointEneable( true )
	Objective_Set( "#SEWERS_OBJ_ENEMY_TERRITORY", crumb1.GetOrigin() )
	FlagWait( "channelRun_first_waypoint_hit" )
	Objective_Clear()

	wait 4.0

	Objective_WayPointEneable( true )
	Objective_Set( "#SEWERS_OBJ_ENEMY_TERRITORY", crumb2.GetOrigin() )
	FlagWait( "channelRun_second_waypoint_hit" )
	Objective_Clear()

	Objective_WayPointEneable( false )
}


void function ChannelMortarRun_TeleportBTThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	if ( player.IsTitan() )
		return

	entity teleportSpot = GetEntByScriptName( "Channel_bt_teleport_spot" )

	while( 1 )
	{
		wait 1.0

		entity titan = player.GetPetTitan()
		if ( !IsValid( titan ) )
			return

		// Make sure player doesn't see the teleport spot or BT
		if ( PlayerCanSee( player, teleportSpot, true, 90 ) )
			continue

		if ( PlayerCanSee( player, titan, true, 90 ) )
			continue

		break
	}

	entity titan = player.GetPetTitan()
	if ( IsValid( titan ) )
		TeleportBT( player, "Channel_bt_teleport_spot" )
}


void function ChannelMortarRun_FriendlyTitansTalk()
{
	if ( IsAlive( file.friendlyTitanFreeborn ) )
		PlayDialogue( "FREEBORN_GOT_A_FRIENDLY", file.friendlyTitanFreeborn )

	wait 0.5

	if ( IsAlive( file.friendlyTitanFreeborn ) )
		PlayDialogue( "SHAVER_IS_IT_BT", file.friendlyTitanShaver )

	wait 1.0

	if ( IsAlive( file.friendlyTitanFreeborn ) )
		PlayDialogue( "SHAVER_USE_YOUR_HELP", file.friendlyTitanFreeborn )
}


void function StartPoint_Setup_ChannelMortarRun( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	TeleportPlayerAndBT( "playerstart_channel_mortar_run", "titanstart_channel_mortar_run" )
}


void function StartPoint_Skipped_ChannelMortarRun( entity player )
{
	thread ChannelMortarRun_SludgeHintThink( player )
	thread ChannelMortarRun_NewWeaponDialogThink( player )

	thread PA_SystemThink( player )
	thread Kane_PA_IntroBroadcastThink( player )
	thread Kane_PA_BroadcastThink( player, "KANE_PA_KANES_PLACE", "SludgeFalls_KanePA_1" )
	thread Kane_PA_BroadcastThink( player, "KANE_PA_SRS_TITAN_HERE", "CorkscrewRoom_KanePA_1" )
	thread Kane_PA_BroadcastThink( player, "KANE_PA_IM_COMING_DOWN", "SewerDefend_KanePA_1" )

	// Grunts report again that a titan is coming
	FlagWait( "intro_hallway_grunts_report_titan" )
	StopMusicTrack( "music_reclamation_05_enterthesewer" )
	PlayMusic( "music_reclamation_06_sewerfirstcontact" )
}


void function ChannelMortarRun_SkyShowThink()
{
	array<entity> ships = GetEntArrayByScriptName( "skyshow_loop_ship" )
	foreach( ship in ships )
		thread FlybyShipThink( ship )
}


void function FlybyShipThink( entity ship )
{
	string modelRef = "dropship"
	if ( ship.HasKey( "script_noteworthy" ) )
	{
		modelRef = expect string( ship.kv.script_noteworthy )
	}

	table<string,asset> refs = {}
	refs[ "dropship" ] <- DROPSHIP_MODEL
	refs[ "straton" ] <- STRATON_MODEL
	//refs[ "straton_sb" ] <- STRATON_SB_MODEL

	bool loop = false
	float delayMin = 0.0
	float delayMax = 0.0
	if ( ship.HasKey( "script_loop" ) )
	{
		loop = (ship.kv.script_loop == "1")
		delayMin = float( ship.kv.script_delay_min )
		delayMax = float( ship.kv.script_delay_max )
		svGlobal.levelEnt.EndSignal( "StopFlybys" )
	}

	entity dropship = CreatePropDynamic( refs[ modelRef ] )

	OnThreadEnd(
	function() : ( dropship )
		{
			dropship.Destroy()
		}
	)

	while( 1 )
	{
		string animation = string( ship.kv.leveled_animation )

		AnimRefPoint info = GetAnimStartInfo( dropship, animation, ship )
		dropship.SetOrigin( info.origin )
		dropship.SetAngles( info.angles )
		dropship.DisableHibernation()

		float delay = RandomFloatRange( 1, 2 )

		if ( ship.HasKey( "script_delay" ) )
			delay = float( ship.kv.script_delay )

		wait delay

		waitthread PlayAnim( dropship, animation, ship )

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


void function ChannelMortarRun_FirstTitanfallGuy( entity player )
{
	FlagWait( "Channel_spawn_first_titanfall_guy" )

	entity lookAtSpot = GetEntByScriptName( "Channel_spawn_first_titanfall_guy_lookat" )

	WaitTillLookingAt( player, lookAtSpot, true, 30, 3000, 10.0 )

	entity spawner = GetEntByScriptName( "Channel_first_titanfall_guy" )
	entity titan = spawner.SpawnEntity()
	DispatchSpawn( titan )

	StopMusicTrack( "music_reclamation_03_jumpintoriver" )
	PlayMusic( "music_reclamation_04_firsttitanbattle" )
}


void function ChannelMortarRun_NewWeaponDialogThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "FirstTitanLoadoutAcquired" )

	Remote_CallFunction_UI( player, "ServerCallback_ClearFirstTitanLoadoutNagOnOpen" )

	CheckPoint_Silent()

	wait 2.5

	PlayerConversation( "NewWeapon", player )

	wait 1.0

	PlayBTDialogue( "BT_TONE_INTRO" )

	// HACK: Wait duration of diag_sp_extra_GB101_37_01_mcor_bt since we can't get duration on server.
	wait 8.0

	if ( file.clearedOnScreenLoadoutHint == false && player.IsTitan() )
		DisplayOnscreenHint( player, "swap_titan_loadout", 30 )

	// If player disembarks, clear hint.
	while( player.IsTitan() )
	{
		wait 1

		if( !player.IsTitan() )
		{
			ClearOnscreenHint( player )
			return
		}
	}
}


void function ChannelMortarRun_SludgeHintThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "intro_sludge_hint" )

	// Wait until the player is no longer in combat.
	while( 1 )
	{
		if ( file.playerCombatState == "idle" || file.playerCombatState == "alert" )
			break

		player.WaitSignal( "PlayerCombatStateChanged" )
	}

	PlayBTDialogue( "BT_SLUDGE_WARN" )
}


void function ChannelMortarRun_FriendlyRadioBroadcast( entity player )
{
	player.EndSignal( "OnDestroy" )

	PlayDialogue( "MILITIA_RADIO_1", player )
	PlayDialogue( "MILITIA_RADIO_2", player )
}


void function ChannelMortarRun_IntroIMCTitans( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "Channel_spawn_titan_lookout" )

	// Spawn the IMC guys
	array<entity> spawners = GetEntArrayByScriptName( "Channel_titan_lookout" )
	for( int i = 0; i < spawners.len(); i++ )
	{
		entity titan = spawners[i].SpawnEntity()
		DispatchSpawn( titan )
	}
}


void function ChannelMortarRun_MilitiaTitansThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "Channel_spawn_titan_lookout" )

	// Spawn militia titans
	array<string> friendlyNames = [ "#NPC_SHAVER_NAME", "#NPC_FREEBORN_NAME" ]
	array<entity> spawners = GetEntArrayByScriptName( "Channel_friendly_titan" )

	file.friendlyTitanFreeborn = ChannelMortarRun_SpawnFriendlyTitan( spawners[0], "#NPC_FREEBORN_NAME" )
	file.friendlyTitanShaver = ChannelMortarRun_SpawnFriendlyTitan( spawners[1], "#NPC_SHAVER_NAME" )

	FlagWait( "militia_comments_on_area_secure" )

	// Wait till all the enemy titans are dead before the friendlies comment
	array<entity> allTitans = GetNPCArrayByClass( "npc_titan" )
	array<entity> enemyTitans
	foreach( titan in allTitans )
	{
		if ( titan.GetTeam() == TEAM_IMC )
			enemyTitans.append( titan )
	}

	WaitUntilPercentDead_WithTimeout( enemyTitans, 1, 20.0 )

	if ( Flag( "MortarRunDone" ) )
		return

	wait 3.0

	if ( IsAlive( file.friendlyTitanFreeborn ) )
		PlayDialogue( "SHAVER_THANKS_FOR_ASSIST", file.friendlyTitanShaver )
	else if ( IsAlive( file.friendlyTitanShaver ) )
		PlayDialogue( "FREEBORN_THANKS_FOR_ASSIST", file.friendlyTitanFreeborn )

	entity freebornSpot = GetEntByScriptName( "final_spot_freeborn" )
	entity shaverSpot 	= GetEntByScriptName( "final_spot_shaver" )

	// Move them to their final spots
	if ( IsAlive( file.friendlyTitanFreeborn ) )
		AssaultEntity( file.friendlyTitanFreeborn, freebornSpot )
	if( IsAlive( file.friendlyTitanShaver ) )
		AssaultEntity( file.friendlyTitanShaver, shaverSpot )

	// Achievement!
	if( IsAlive( file.friendlyTitanShaver ) && IsAlive( file.friendlyTitanFreeborn ) )
		UnlockAchievement( player, achievements.SAVE_TITANS )
}


entity function ChannelMortarRun_SpawnFriendlyTitan( entity spawner, string name )
{
	entity titan = spawner.SpawnEntity()
	DispatchSpawn( titan )

	titan.SetSkin( 2 ) // 2 = Militia

	titan.kv.alwaysAlert = 1
	titan.SetValidHealthBarTarget( false )
	titan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )

	titan.SetTitle( name )
	ShowName( titan )

	titan.TakeDamage( titan.GetMaxHealth() * 0.5, null, null, { damageSourceId=damagedef_suicide } )

	return titan
}


void function ChannelMortarRun_DropShipsThink()
{
	FlagWait( "Intro_spawn_dropship" )

	array<entity> spawners = GetEntArrayByScriptName( "Intro_dropship" )
	foreach( ship in spawners )
	{
		thread SpawnFromDropship( ship )
		wait 1
	}

	entity sfxSpot = GetEntByScriptName( "Channel_dropship_flyby_sfx_spot" )

	EmitSoundAtPosition( TEAM_ANY, sfxSpot.GetOrigin(), "sewers_scripted_dropship_flyby_1" )
	wait 1
	EmitSoundAtPosition( TEAM_ANY, sfxSpot.GetOrigin(), "sewers_scripted_dropship_flyby_2" )
}


void function ChannelMortarRun_GruntCommentsThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	// Titans call for reinforcements
	FlagWait( "intro_titan_reinforcements" )
	PlayDialogue( "IMC_SEND_TITANS", player )

	// Grunts report ahead a titan is coming
	FlagWait( "intro_grunts_report_titan" )
	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_REPORT_TITAN", TEAM_IMC )

	// Grunts report again that a titan is coming
	FlagWait( "intro_hallway_grunts_report_titan" )
	StopMusicTrack( "music_reclamation_05_enterthesewer" )
	PlayMusic( "music_reclamation_06_sewerfirstcontact" )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ███████╗███████╗██╗    ██╗███████╗██████╗     ███████╗██████╗ ██╗     ██╗████████╗
// ██╔════╝██╔════╝██║    ██║██╔════╝██╔══██╗    ██╔════╝██╔══██╗██║     ██║╚══██╔══╝
// ███████╗█████╗  ██║ █╗ ██║█████╗  ██████╔╝    ███████╗██████╔╝██║     ██║   ██║
// ╚════██║██╔══╝  ██║███╗██║██╔══╝  ██╔══██╗    ╚════██║██╔═══╝ ██║     ██║   ██║
// ███████║███████╗╚███╔███╔╝███████╗██║  ██║    ███████║██║     ███████╗██║   ██║
// ╚══════╝╚══════╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝     ╚══════╝╚═╝   ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_SewerSplit( entity player )
{
	thread SewerSplit_TitanCombatMusicThink()
	thread SewerSplit_PilotCombatMusicThink()
	thread SewerSplit_RumbleOnGateOpen()
	thread Sewers_CleanupNPCsOnFlag( player, "SewerSplit_cleanup_old_ai" )
	thread SewerSplit_TitanInDrain( player )
	thread SewerSplit_TitanFlankedUsComment( player )
	thread SewerSplit_BTThink( player )
	thread SewerSplit_PlayerCollectableThink( player )
	thread SewerSplit_DisembarkHintThink( player )
	thread SewerSplit_GateThink( player )

	// Hide the dead pilot's helmet
	entity pilotBody = GetEntByScriptName( "sewersplit_bluelionpilot" )
	int bodyGroupIndex = pilotBody.FindBodyGroup( "head" )
	pilotBody.SetBodygroup( bodyGroupIndex, 1 )

	FlagWait( "SewerSplit_start_combat" )

	// If player is out of BT, have him charge forward
	entity titan = player.GetPetTitan()
	if ( IsValid( titan ) )
	{
		entity moveTarget = GetEntByScriptName( "SewerSplit_bt_start_spot" )
		AssaultEntity( titan, moveTarget )
	}

	wait 1.5
	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_TITAN_WEAPONS_FREE", TEAM_IMC, "npc_titan" )
	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_TITAN_ROGER_ENGAGING", TEAM_IMC, "npc_titan" )

	FlagWait( "SewerSplitDone" )
}


void function SewerSplit_GateThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "SewerSplit_OpenGate_Start" )

	entity bt = player.GetPetTitan()
	if ( IsValid( bt ) )
		bt.SetInvulnerable()

	StopMusicTrack( "music_reclamation_10_doorupambush" )
	PlayMusic( "music_reclamation_10a_splitup" )

	entity trapDoorSfxSpot = GetEntByScriptName( "SewerSplit_trap_door_sfx_spot" )
	entity gateSfxSpot = GetEntByScriptName( "SewerSplit_gate_sfx_spot" )
	entity button = GetEntByScriptName( "SewerSplit_gate_switch" )

	// tp all to the button's position
	TriggerManualCheckPoint( null, button.GetOrigin() + < -200,0,-20 >, true )

	EmitSoundAtPosition( TEAM_ANY, trapDoorSfxSpot.GetOrigin(), "sewers_scripted_sewersplitroom_ceilingdoor_close" )

	wait 1.0

	array<entity> lights = GetEntArrayByScriptName( "gate_door_light" )
	foreach( light in lights )
		PlayFXOnEntity( FX_WARNING_LIGHT, light )

	vector origin = lights[0].GetOrigin()

	PlayDialogue( "PA_OPEN_GATE", button )

	FlagSet( "SewerSplit_OpenGate" )

	EmitSoundAtPosition( TEAM_ANY, gateSfxSpot.GetOrigin(), "sewers_scripted_sewersplitroom_btdoor_open" )

	thread SewerSplit_TitanGateRumble()

	wait 1.0
	PlayDialogue( "PA_TOXIC_FUMES", button )
	PlayDialogue( "PA_AIRLOCK_ENGAGED", button )
	wait 0.5

	FlagSet( "SewerSplit_OpenControlRoomDoor" )

	wait 1.0

	FlagSet( "SewerSplit_OpenGate_Done" )

	// respawning bt for player0 if gone
	if ( !IsValid( GetPlayer0().GetPetTitan() ) )
		CreatePetTitanAtOrigin( GetPlayer0(), button.GetOrigin() + < 400,0,-20 >, <0,0,0> )
	
	GetPlayer0().GetPetTitan().SetInvulnerable()
}


void function SewerSplit_TitanGateRumble()
{
	wait 2.25
	entity rumbleSpot = GetEntByScriptName( "SewerSplit_gate_rumble_spot" )
	CreateShakeRumbleOnly( rumbleSpot.GetOrigin(), 50, 150, 6.5 )
}


void function SewerSplit_TitanCombatMusicThink()
{
	FlagWait( "SewerSplit_combat_music" )
	StopMusicTrack( "music_reclamation_06_sewerfirstcontact" )
	PlayMusic( "music_reclamation_07_sewerstitanbattle" )

	FlagWait( "SewerSplit_TitansDead" )

	if ( Flag( "SewerSplit_bt_moves_into_position" ) )
		return

	StopMusicTrack( "music_reclamation_07_sewerstitanbattle" )
	PlayMusic( "music_reclamation_08_sewerstitandefeated" )
}


void function SewerSplit_PilotCombatMusicThink()
{
	FlagWait( "SewerSplit_bt_moves_into_position" )
	StopMusicTrack( "music_reclamation_08_sewerstitandefeated" )
	PlayMusic( "music_reclamation_09_onfoot" )

	FlagWait( "SewerSplit_OpenBridgeDoor" )
	StopMusicTrack( "music_reclamation_09_onfoot" )
	PlayMusic( "music_reclamation_10_doorupambush" )
}


void function SewerSplit_RumbleOnGateOpen()
{
	FlagWait( "SewerSplit_OpenBridgeDoor" )

	entity rumbleSpot = GetEntByScriptName( "SewerSplit_door_rumble_spot" )
	CreateShakeRumbleOnly( rumbleSpot.GetOrigin(), 50, 150, 20, 512 )
}


void function SewerSplit_DisembarkHintThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	// Wait till the titans are dead
	FlagWait( "SewerSplit_TitansDead" )

	array<entity> lookAtSpots = GetEntArrayByScriptName( "SewerSplit_disembark_lookat" )
	entity trigger = GetEntByScriptName( "SewerSplit_disembark_trigger" )

	while( 1 )
	{
		local results = trigger.WaitSignal( "OnTrigger" )
		entity guy = expect entity( results.activator )

		if ( !IsValid( guy ) )
			continue

		if ( !guy.IsPlayer() )
			continue

		if ( !guy.IsTitan() )
			continue

		if ( !PlayerCanSeeAnyOfThese( guy, lookAtSpots ) )
			continue

		DisplayOnscreenHint( player, "disembark_hint" )
		wait 3.0
		ClearOnscreenHint( player )
		wait 1.0
	}
}


bool function PlayerCanSeeAnyOfThese( entity player, array<entity> lookAtSpots )
{
	if ( !IsValid( player ) )
		return false

	foreach( spot in lookAtSpots )
	{
		if ( PlayerCanSee( player, spot, true, 45 ) )
			return true
	}

	return false
}


void function StartPoint_Setup_SewerSplit( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	TeleportPlayerAndBT( "playerstart_sewer_split", "titanstart_sewer_split" )
}


void function StartPoint_Skipped_SewerSplit( entity player )
{
	entity titan = player.GetPetTitan()

	if ( IsValid( titan ) )
		titan.Destroy()

	SPTitanLoadout_UnlockLoadout( player, SP_FIRST_TITAN_LOADOUT_KIT )
}


void function SewerSplit_BTThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	thread SewerSplit_OpenGateBTThink ( player )

	// BT updates objective
	FlagWait( "SewerSplit_TitansDead" )

	wait 2.5

	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_GAMMA_SQUAD_DEAD", TEAM_IMC )

	wait 1.0

	PlayBTDialogue( "BT_FIND_GATE_CONTROL" )

	entity button = GetEntByScriptName( "SewerSplit_gate_switch" )
	Objective_Set_WithAltHighlight( "#SEWERS_OBJ_OPEN_BT_GATE", <0,0,0>, button )


	// BT Moves into the supressing fire position
	FlagWait( "SewerSplit_bt_moves_into_position" )
	WaitTillPlayerIsDisembarked( player )

	entity moveTarget = GetEntByScriptName( "SewerSplit_BT_supress_spot" )

	entity titan = player.GetPetTitan()  // Get it again in case the player embarked (titan is destroyed on embark)
	if ( IsValid( titan ) )
	{
		titan.EndSignal( "OnDestroy" )
		AssaultEntity( titan, moveTarget )
		titan.SetNPCPriorityOverride_NoThreat()	// Only select soldiers should bother with BT, everyone else should ignore him
	}

	FlagWait( "SewerSplit_bt_starts_supressing" )
	WaitTillPlayerIsDisembarked( player )

	array<entity> grunts = GetEntArrayByScriptName( "SewerSplit_bt_attackers" )
	if ( IsValid( titan ) )
	{
		foreach( grunt in grunts )
		{
			if( !IsAlive( grunt ) )
				continue

			if( grunt.GetClassName() == "npc_soldier" )
				grunt.LockEnemy( titan )
		}
	}

	FlagWait( "SewerSplit_bt_stops_supressing" )
	WaitTillPlayerIsDisembarked( player )

	titan = player.GetPetTitan()
	if ( IsValid( titan ) )
	{
		titan.EndSignal( "OnDestroy" )
		titan.ClearEnemy()
		titan.DisableBehavior( "Assault" )
		titan.ClearNPCPriorityOverride()
	}

	entity bullseye = GetEntByScriptName( "SewerSplit_bt_bullseye" )
	bullseye.Destroy()

	foreach( grunt in grunts )
	{
		if( !IsAlive( grunt ) )
			continue

		if( grunt.GetClassName() == "npc_soldier" )
			grunt.ClearEnemy()
	}


	// BT moves next to the gate
	FlagWait( "SewerSplit_BT_says_open_gate" )

	thread SewerSplit_BTGateNag( player )
	moveTarget = GetEntByScriptName( "SewerSplit_BT_gate_spot" )
	WaitTillPlayerIsDisembarked( player )
	titan = player.GetPetTitan()
	if ( IsValid( titan ) )
	{
		titan.EndSignal( "OnDestroy" )
		titan.kv.alwaysalert = true
		AssaultEntity( titan, moveTarget )
	}
}


void function SewerSplit_OpenGateBTThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	// When the button is pushed, the gate opens and BT talks about splitting up
	FlagWait( "SewerSplit_OpenGate" )

	entity moveTarget = GetEntByScriptName( "SewerSplit_BT_gate_spot" )
	WaitTillPlayerIsDisembarked( player )
	entity titan = player.GetPetTitan()

	// BT is dead, so bail because the game is going to reload anyway
	if ( !IsValid( titan ) )
		return

	AssaultEntity( titan, moveTarget )
	Highlight_ClearOwnedHighlight( titan )

	Objective_Clear()
	wait 1.5

	FlagWait( "SewerSplit_OpenGate_Done" )

	if ( !Flag( "SewerSplitDone" ) )
		PlayerConversation( "SplitUp", player )

	wait 1.0
	FlagSet( "SewerSplit_BT_enters_gate" )

	moveTarget = GetEntByScriptName( "SewerSplit_bt_hide_spot" )
	titan = player.GetPetTitan()
	AssaultEntity( titan, moveTarget )

	FlagWait( "SewerSplit_bt_at_hide_spot" )

	Objective_Set( "#SEWERS_OBJ_FIND_BT" )
}


void function SewerSplit_BTGateNag( entity player )
{
	player.EndSignal( "OnDestroy" )

	while( !Flag( "SewerSplit_OpenGate_Start" ) )
	{
		if ( Flag( "SewerSplit_OpenGate_Start" ) )
			return

		PlayBTDialogue( "BT_FIND_GATE_CONTROL" )
		Objective_Remind()

		wait 20
	}
}


void function SewerSplit_PlayerCollectableThink( entity player )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy" )

	FlagWait( "SewerSplit_player_going_for_collect" )

	entity titan = player.GetPetTitan()
	
	if ( !IsValid( titan ) )
		return
	
	titan.EndSignal( "OnDestroy" )

	entity moveTarget = GetEntByScriptName( "SewerSplit_bt_wait_for_collect_spot" )
	AssaultMoveTarget( titan, moveTarget )

	FlagWait( "SewerSplit_bt_stops_waiting_for_helmet" )
	titan.DisableBehavior( "Assault" )
}


void function SewerSplit_TitanInDrain( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "SewerSplit_send_reinforcements" )
	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_TITAN_IN_DRAIN", TEAM_IMC )
}


void function SewerSplit_TitanFlankedUsComment( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "SewerSplit_titan_supressed_us" )
	entity spot = GetEntByScriptName( "SewerSplit_supressed_us_comment_spot" )
	thread PlayDialogue( "IMC_TITAN_SUPPRESSED_US", spot )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ███████╗██╗     ██╗   ██╗██████╗  ██████╗ ███████╗    ███████╗ █████╗ ██╗     ██╗     ███████╗
// ██╔════╝██║     ██║   ██║██╔══██╗██╔════╝ ██╔════╝    ██╔════╝██╔══██╗██║     ██║     ██╔════╝
// ███████╗██║     ██║   ██║██║  ██║██║  ███╗█████╗      █████╗  ███████║██║     ██║     ███████╗
// ╚════██║██║     ██║   ██║██║  ██║██║   ██║██╔══╝      ██╔══╝  ██╔══██║██║     ██║     ╚════██║
// ███████║███████╗╚██████╔╝██████╔╝╚██████╔╝███████╗    ██║     ██║  ██║███████╗███████╗███████║
// ╚══════╝╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_SludgeFalls( entity player )
{
	thread SludgeFalls_BT_Tracking_Conversation( player )
	thread SludgeFalls_SniperFiringShots()
	thread SludgeFalls_SniperConversation()
	thread SludgeFalls_MilitiaRadioBroadcast( player )
	thread SludgeFalls_ForceSlideThink( player )
	thread SludgeFalls_UnForceSlideThink( player )

	var skyCam = GetEnt( "skybox_cam_level_mid" )
	player.SetSkyCamera( skyCam )

	FlagWait( "SludgeFalls_outside_music" )
	StopMusicTrack( "music_reclamation_10_doorupambush" )
	StopMusicTrack( "music_reclamation_10a_splitup" )
	PlayMusic( "music_reclamation_11_outside" )

	FlagWait( "SludgeFallsDone" )
}


void function StartPoint_Setup_SludgeFalls( entity player )
{
	TeleportPlayerAndBT( "playerstart_sludge_falls", "titanstart_sludge_falls" )
}


void function StartPoint_Skipped_SludgeFalls( entity player )
{
	var skyCam = GetEnt( "skybox_cam_level_mid" )
	player.SetSkyCamera( skyCam )
}


void function SludgeFalls_MilitiaRadioBroadcast( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "SludgeFalls_Militia_Stalker_Radio" )

	PlayDialogue( "MILITIA_CORKSCREW_RADIOINTERCEPT_01", player )
	PlayDialogue( "MILITIA_CORKSCREW_RADIOINTERCEPT_02", player )

	wait 1.0

	PlayBTDialogue( "BT_HELP_MILITIA" )
}


void function SludgeFalls_BT_Tracking_Conversation( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "bt_tracking_converstation" )
	PlayerConversation( "BT_TrackingMe", player )
}


void function SludgeFalls_ForceSlideThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	while( 1 )
	{
		FlagWait( "SludgeFalls_force_slide" )

		player.ForceSlide()

		FlagClear( "SludgeFalls_force_slide" )
		WaitFrame()
	}
}


void function SludgeFalls_UnForceSlideThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	while( 1 )
	{
		FlagWait( "SludgeFalls_unforce_slide" )

		player.UnforceSlide()

		FlagClear( "SludgeFalls_unforce_slide" )
		WaitFrame()
	}
}


void function SludgeFalls_SniperFiringShots()
{
	FlagWait( "SludgeFalls_start_sniper_sfx" )

	entity sfxSpot = GetEntByScriptName( "SludgeFalls_sniper_sfx_spot" )

	while( 1 )
	{
		if ( Flag( "SludgeFalls_stop_sniper_sfx" ) )
			return

		EmitSoundAtPosition( TEAM_ANY, sfxSpot.GetOrigin(), "sewers_scripted_kraber_fire" )

		wait RandomFloatRange( 2.5, 6 )
	}
}


void function SludgeFalls_SniperConversation()
{
	FlagWait( "SludgeFalls_sniper_convo" )
	array<entity> spawners = GetEntArrayByScriptName( "SludgeFalls_talking_sniper" )
	array<entity> guys = SpawnFromSpawnerArray( spawners )
	foreach( guy in guys )
		guy.SetAIObstacle( true )

	array<string> convo = [ "IMC_CONV_01_A", "IMC_CONV_01_B", "IMC_CONV_01_C" ]
	Sewers_PlayInteruptableConversation( guys, convo )
}


// -------------------------------------------------------------------------------------------------------------------------
//
//  ██████╗ ██████╗ ██████╗ ██╗  ██╗ ██████╗███████╗ ██████╗██████╗ ███████╗██╗    ██╗
// ██╔════╝██╔═══██╗██╔══██╗██║ ██╔╝██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝██║    ██║
// ██║     ██║   ██║██████╔╝█████╔╝ ██║     ███████╗██║     ██████╔╝█████╗  ██║ █╗ ██║
// ██║     ██║   ██║██╔══██╗██╔═██╗ ██║     ╚════██║██║     ██╔══██╗██╔══╝  ██║███╗██║
// ╚██████╗╚██████╔╝██║  ██║██║  ██╗╚██████╗███████║╚██████╗██║  ██║███████╗╚███╔███╔╝
//  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_CorkscrewRoom( entity player )
{
	thread CorkscrewRoom_IntroGruntThink( player )
	thread CorkscrewRoom_FriendlyGruntGreeterThink( player )
	thread CorkscrewRoom_FriendlyGruntGreeterThink2( player )
	thread CorkscrewRoom_FriendlyGruntsThink( player )
	thread CorkscrewRoom_FriendlyGruntWaverThink( player )
	thread CorkscrewRoom_BTChatThink( player )
	thread CorkscrewRoom_DeadGruntRadio()
	thread StalkerDoorSkitThink( player )
	thread StalkerCrawlSkitThink()
	thread StalkerWithBackTurnedThink()
	thread StalkerBattleFriendlyGruntChatter( player )
	thread StalkerDoorThink()

	FlagWait( "Corkscrew_grunts_music" )
	StopMusicTrack( "music_reclamation_11_outside" )
	PlayMusic( "music_reclamation_12_friendlies" )

	FlagWait( "CorkscrewRoom_StalkerDoorOpen" )

	// It is def. safe to delete BT by this point so it doesn't mess up the previous conversation
	DeleteBT( player )

	wait 5.0

	Objective_Set( "#SEWERS_OBJ_GO_DEEPER" )

	FlagWait( "Corkscrew_intro_bunker_guys_retreat" )
	PlayMusic( "music_reclamation_15a_corkscrewfight" )

	FlagWait( "CorkscrewRoomDone" )
}


void function StartPoint_Setup_CorkscrewRoom( entity player )
{	
	TriggerSilentCheckPoint( GetEntByScriptName( "playerstart_corkscrew_room" ).GetOrigin(), true )

	TeleportPlayerAndBT( "playerstart_corkscrew_room", "titanstart_corkscrew_room" )
}


void function StartPoint_Skipped_CorkscrewRoom( entity player )
{
}


void function CorkscrewRoom_BTChatThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "CorkscrewRoom_BT_Chat" )

	PlayerConversation( "BT_WalkingForever1", player )
}


void function CorkscrewRoom_DeadGruntRadio()
{
	FlagWait( "corkscrewRoom_dead_grunt_radio_start" )

	entity spot = GetEntByScriptName( "corkscrewRoom_dead_grunt_radio" )

	PlayDialogue( "DEAD_IMC_CHATTER_A_01", spot )
	PlayDialogue( "DEAD_IMC_CHATTER_A_02", spot )
}


void function CorkscrewRoom_IntroGruntThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity ref = GetEntByScriptName( "intro_grunt_ref" )
	entity spawner = GetEntByScriptName( "Corkscrew_intro_grunt" )
	entity guy = spawner.SpawnEntity()
	DispatchSpawn( guy )

	guy.SetTitle( "#NPC_EZZO_NAME" )
	ShowName( guy )

	guy.EndSignal( "OnDestroy" )

	thread PlayAnim( guy, "pt_door_guard_B_start", ref )
}


void function CorkscrewRoom_FriendlyGruntWaverThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity ref = GetEntByScriptName( "waver_grunt_ref" )
	entity spawner = GetEntByScriptName( "Corkscrew_grunt_guard" )
	entity guy = spawner.SpawnEntity()
	DispatchSpawn( guy )

	guy.SetTitle( "#NPC_BABB_NAME" )
	ShowName( guy )
	guy.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )

	guy.SetAIObstacle( true )

	guy.EndSignal( "OnDestroy" )

 	thread PlayAnim( guy, "pt_control_roomB_spotter_start", ref )

	FlagWait( "Corkscrew_intro_grunt_start" )

 	thread PlayAnim( guy, "pt_control_roomB_spotter_scene_talk", ref )
}


void function CorkscrewRoom_FriendlyGruntGreeterThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity ref = GetEntByScriptName( "grunt_greeter_ref" )
	entity spawner = GetEntByScriptName( "Corkscrew_grunt_greeter" )
	entity guy = spawner.SpawnEntity()
	DispatchSpawn( guy )

	guy.SetTitle( "#NPC_ROBERTS_NAME" )
	ShowName( guy )

	guy.EndSignal( "OnDestroy" )

	thread PlayAnim( guy, "pt_beacon_door_welcome_start", ref )

	FlagWait( "Corkscrew_greeter_start" )

 	PlayAnim( guy, "pt_beacon_door_welcome_scene_talk", ref )
	PlayAnim( guy, "pt_beacon_door_welcome_end", ref )
}


void function CorkscrewRoom_TurretGuyMutters( entity guy )
{
	FlagWait( "Corkscrew_greeter_start" )

	guy.EndSignal( "OnDestroy" )

	float waitTime = 15.0

	wait waitTime

	array<string> lines = [ "MILITIA_TURRET_GUY_1", "MILITIA_TURRET_GUY_2", "MILITIA_TURRET_GUY_3" ]
	entity turret = GetEntByScriptName( "SewerSplit_turret_repair" )

	foreach( line in lines )
	{
		waitthread PlayGabbyDialogue( line, guy )
		wait waitTime
	}
}


void function CorkscrewRoom_FriendlyGruntGreeterThink2( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity ref = GetEntByScriptName( "grunt_greeter2_ref" )
	entity spawner = GetEntByScriptName( "Corkscrew_grunt_greeter2" )
	entity guy = spawner.SpawnEntity()
	DispatchSpawn( guy )

	guy.EndSignal( "OnDestroy" )

	thread PlayAnim( guy, "pt_welcome_pilot_help_idle", ref )

	thread CorkscrewRoom_FriendlyGruntGreeterThink2_StalkerAttack( guy )

	FlagWait( "Corkscrew_greeter2_start" )

	if ( Flag( "Corkscrew_greeter2_attacked_stalker" ) )
		return

 	PlayAnim( guy, "pt_welcome_pilot_help_end", ref )
}


void function CorkscrewRoom_FriendlyGruntGreeterThink2_StalkerAttack( entity guy )
{
	guy.EndSignal( "OnDestroy" )

	FlagWait( "Corkscrew_greeter_attacks_stalker" )

	guy.Anim_Stop()

	array<entity> stalkers = GetEntArrayByScriptName( "stalkerWIthBackTurned" )
	foreach( stalker in stalkers )
	{
		if( stalker.GetClassName() == "npc_stalker" )
		{
			guy.SetEnemy( stalker )
		}
	}

	FlagSet( "Corkscrew_greeter2_attacked_stalker" )
}


void function CorkscrewRoom_FriendlyGruntsThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	array<string> gruntNames = [ "#NPC_GARTNER_NAME", "#NPC_BOWIE_NAME"]
	array<entity> spawners = GetEntArrayByScriptName( "Corkscrew_friendly_grunt" )
	array<entity> guys = SpawnFromSpawnerArray( spawners )

	for( int i = 0; i < guys.len(); i++ )
	{
		entity guy = guys[ i ]
		string name = gruntNames[ i ]

		if ( !IsAlive( guy ) )
			continue

		guy.EnableNPCFlag( NPC_IGNORE_ALL )
		guy.SetAIObstacle( true )

		guy.SetTitle( name )
		ShowName( guy )

		if ( guy.HasKey( "script_noteworthy" ) )
		{
			thread PlayAnim( guy, guy.kv.script_noteworthy )

			if ( guy.kv.script_noteworthy == "pt_turret_repair_idle" )
				thread CorkscrewRoom_TurretGuyMutters( guy )
		}
	}

	entity turret = GetEntByScriptName( "SewerSplit_turret_repair" )
	turret.SetAIObstacle( true )
	thread PlayAnim( turret, "turret_repair_idle" )

	FlagWait( "Corkscrew_grunts_notice_pilot" )
	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_SEE_SOMETHING_MOVING", TEAM_MILITIA )
}


void function CorksckrewRoom_GruntFollowerThink( entity guy )
{
	guy.EndSignal( "OnDestroy" )

	// Move to the first stalker skit
	FlagWait( "Corkscrew_grunts_move_out" )
	if ( !IsValid( guy ) )
		return

	guy.Anim_Stop()
	guy.kv.alwaysalert = true
	entity attackSpot = GetEntByScriptName( "Corkscrew_grunts_stalker_attack_spot" )
	thread AssaultEntity( guy, attackSpot )

	// Move up
	FlagWait( "Corkscrew_grunt_moves_forward_1" )
	if ( !IsValid( guy ) )
		return

	attackSpot = GetEntByScriptName( "Corkscrew_grunts_stalker_attack_spot2" )
	thread AssaultEntity( guy, attackSpot )

	// Join the rest of the grunts on the front lines
	FlagWait( "Corkscrew_grunt_moves_forward_2" )
	if ( !IsValid( guy ) )
		return

	attackSpot = GetEntByScriptName( "Corkscrew_grunt_goal_left" )
	thread AssaultEntity( guy, attackSpot )
}


void function StalkerDoorSkitThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "stalkerDoorSkit_start" )

	entity skitRef = GetEntByScriptName( "stalker_door_ref" )
	entity door = GetEntByScriptName( "stalker_door" )
	entity spawner = GetEntByScriptName( "stalker_door_stalker" )
	entity stalker = spawner.SpawnEntity()
	DispatchSpawn( stalker )

	stalker.EndSignal( "OnDestroy" )

	StopMusicTrack( "music_reclamation_12_friendlies" )
	PlayMusic( "music_reclamation_13_stalkerintro" )
	entity sfxSpot = GetEntByScriptName( "Corkscrew_stalker_door_sfx" )
	EmitSoundAtPosition( TEAM_ANY, sfxSpot.GetOrigin(), "sewers_scripted_stalkeropendoor" )

	thread StalkerDoorRumble( sfxSpot.GetOrigin() )

	thread PlayAnim( door, "door_door_spawn_core" )
	waitthread PlayAnim( stalker, "st_door_spawn_core", door )

	stalker.SetEnemy( player )

	if ( IsAlive( stalker ) )
		EmitSoundAtPosition( TEAM_ANY, stalker.GetOrigin(), "sewers_scripted_firststalker_vox" )
}


void function StalkerDoorRumble( vector pos )
{
	wait 1.0
	CreateShakeRumbleOnly( pos, 50, 150, 3.0 )
}


void function StalkerCrawlSkitThink()
{
	FlagWait( "stalkerCrawlSkit_start" )
	entity spawner = GetEntByScriptName( "stalkerCrawlSkit_stalker" )
	entity stalker = spawner.SpawnEntity()
	DispatchSpawn( stalker )

	stalker.EndSignal( "OnDestroy" )

	wait 3

	if ( IsAlive( stalker ) )
		EmitSoundAtPosition( TEAM_ANY, stalker.GetOrigin(), "sewers_scripted_crawlingstalker_vox" )

	wait 6

	if ( IsAlive( stalker ) )
		EmitSoundAtPosition( TEAM_ANY, stalker.GetOrigin(), "sewers_scripted_crawlingstalker_vox" )
}


void function StalkerWithBackTurnedThink()
{
	FlagWait( "stalkerWIthBackTurned_spawn" )
	entity spawner = GetEntByScriptName( "stalkerWIthBackTurned" )
	entity stalker = spawner.SpawnEntity()
	DispatchSpawn( stalker )

	stalker.EndSignal( "OnDestroy" )
	stalker.EnableNPCFlag( NPC_IGNORE_ALL )

	while( 1 )
	{
		if( stalker.GetHealth() <= stalker.GetMaxHealth() * 0.5 )  // half health? turn around!
			break

		wait 0.1
	}

	stalker.DisableNPCFlag( NPC_IGNORE_ALL )
}


void function StalkerKillsGruntSkitThink()
{
	FlagWait( "stalkerKillsGrunt_spawn" )

	entity ref = GetEntByScriptName( "stalkerKillsGrunt_ref" )
	entity spawner = GetEntByScriptName( "stalkerKillsGrunt_grunt" )
	entity grunt = spawner.SpawnEntity()
	DispatchSpawn( grunt )

	Highlight_ClearFriendlyHighlight( grunt )

	spawner  = GetEntByScriptName( "stalkerKillsGrunt_stalker" )
	entity stalker = spawner.SpawnEntity()
	DispatchSpawn( stalker )

	grunt.EndSignal( "OnDestroy" )
	stalker.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( stalker )
		{
			if ( IsValid( stalker ) )
				stalker.DisableNPCFlag( NPC_IGNORE_ALL )
		}
	)

	grunt.EnableNPCFlag( NPC_IGNORE_ALL )
	stalker.EnableNPCFlag( NPC_IGNORE_ALL )
	stalker.SetInvulnerable()

	thread PlayAnim( stalker, "st_synced_melee_B_chestpunch_A_idle", ref )
	thread PlayAnim( grunt, "pt_synced_melee_B_chestpunch_D_idle", ref )

	FlagWait( "stalkerKillsGrunt_start" )

	thread PlayAnim( stalker, "st_synced_melee_B_chestpunch_A", ref )
	waitthread PlayAnim( grunt, "pt_synced_melee_B_chestpunch_D", ref )
	stalker.ClearInvulnerable()
	stalker.DisableNPCFlag( NPC_IGNORE_ALL )

	// Delete the grunt and put a body in it's place
	int bodyGroupIndex = grunt.FindBodyGroup( "head" )
	int bodyGroupState = grunt.GetBodyGroupState( bodyGroupIndex )

	grunt.Destroy()
 	entity gruntBody = CreatePropDynamic( grunt.GetModelName(), grunt.GetOrigin(), grunt.GetAngles() )
	gruntBody.SetBodygroup( bodyGroupIndex, bodyGroupState )

	PlayAnim( gruntBody, "pt_synced_melee_B_chestpunch_D_death_idle", ref )
	WaitForever()
}


void function StalkerBattleFriendlyGruntChatter( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "Corkscrew_reinforcements_chatter" )

	Objective_Set( "#SEWERS_OBJ_DEFEAT_STALKERS" )

	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_REINFORCEMENTS_ON_SIX", TEAM_MILITIA )
	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_ABOUT_TIME", TEAM_MILITIA )

	wait 2
	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_HERE_THEY_COME", TEAM_MILITIA )

	StopMusicTrack( "music_reclamation_13_stalkerintro" )
	PlayMusic( "music_reclamation_14_stalkerswading" )

	wait 1
	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_COMING_THRU_SLUDGE", TEAM_MILITIA )

	wait 4
	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_TOO_MANY", TEAM_MILITIA )
	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_KEEP_FIRING", TEAM_MILITIA )


	FlagWait( "Corkscrew_Stalker_Grunts_Killed" )

	if( Flag( "CorkscrewRoom_StalkerDoorOpen" ) )
		return

	StopMusicTrack( "music_reclamation_14_stalkerswading" )
	StopMusicTrack( "music_reclamation_16_shitshower" )
	PlayMusic( "music_reclamation_15_stalkerbattleend" )

	// Have the militia grunts stay out of the sludge
	array<entity> guys = GetNPCArrayEx( "npc_soldier", TEAM_MILITIA, TEAM_ANY, player.GetOrigin(), 5000 )
	entity attackSpot = GetEntByScriptName( "Corkscrew_grunt_goal_final" )

	foreach( guy in guys )
		thread AssaultEntity( guy, attackSpot )

	wait 5.0

	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_THANKS_FOR_ASSIST", TEAM_MILITIA )
	PlayDialogueOnClosestNPCFromPlayer( player, "MILITIA_GO_AHEAD", TEAM_MILITIA )
}


void function StalkerDoorThink()
{
	FlagWait( "CorkscrewRoom_StalkerDoorOpen" )

	entity sfxSpot = GetEntByScriptName( "Corksckrew_door_sound_ref" )
	EmitSoundAtPosition( TEAM_ANY, sfxSpot.GetOrigin(), "sewers_emit_stalkerroom_exitdoor_open" )

	CreateShakeRumbleOnly( sfxSpot.GetOrigin(), 16, 150, 12 )

	entity doorClip = GetEntByScriptName( "CorkscrewRoom_BigStalkerDoor_Clip" )
	doorClip.NotSolid()

	array<entity> stalkerDoorEnts = GetEntArrayByScriptName( "corkscrew_stalker_door" )
	foreach( door in stalkerDoorEnts )
	{
		door.SetBlocksLOS( true )
		door.Solid()
	}
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ██████╗ ██╗██████╗ ███████╗     ██████╗██╗     ██╗███╗   ███╗██████╗
// ██╔══██╗██║██╔══██╗██╔════╝    ██╔════╝██║     ██║████╗ ████║██╔══██╗
// ██████╔╝██║██████╔╝█████╗      ██║     ██║     ██║██╔████╔██║██████╔╝
// ██╔═══╝ ██║██╔═══╝ ██╔══╝      ██║     ██║     ██║██║╚██╔╝██║██╔══██╗
// ██║     ██║██║     ███████╗    ╚██████╗███████╗██║██║ ╚═╝ ██║██████╔╝
// ╚═╝     ╚═╝╚═╝     ╚══════╝     ╚═════╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_PipeRoomClimb( entity player )
{
	thread PipeRoomClimb_BTSoonConversation( player )
	thread PipeRoomClimb_BTCautions( player )

	FlagWait( "Piperoom_poo_music" )
	StopMusicTrack( "music_reclamation_15a_corkscrewfight" )
	PlayMusic( "music_reclamation_16_shitshower" )

	FlagWait( "PipeRoom_reached_top" )

	entity btSpawnSpot = GetEntByScriptName( "titanstart_sewer_arena" )

	foreach( entity p in GetPlayerArray() )
		SpawnBT( p, btSpawnSpot.GetOrigin() )
	
	foreach( entity p in GetPlayerArray() )
		Highlight_ClearOwnedHighlight( p.GetPetTitan() )

	thread Sewers_CleanupNPCsOnFlag( player, "PipeRoomClimbDone" )

	FlagWait( "PipeRoomClimbDone" )
}


void function StartPoint_Setup_PipeRoomClimb( entity player )
{
	TeleportPlayerAndBT( "playerstart_pipe_room_climb", "titanstart_pipe_room_climb" )
}


void function StartPoint_Skipped_PipeRoomClimb( entity player )
{
	entity btSpawnSpot = GetEntByScriptName( "titanstart_sewer_arena" )
	SpawnBT( player, btSpawnSpot.GetOrigin() )
	Highlight_ClearOwnedHighlight( player.GetPetTitan() )
}


void function PipeRoomClimb_BTCautions( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "PipeRoomClimb_IMC_convo" )
	thread PlayerConversation( "BT_PostStalkerFight", player )
}


void function PipeRoomClimb_BTSoonConversation( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "bt_reunite_soon_conversation" )
	PlayerConversation( "BT_PathsIntersect", player )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ███████╗███████╗██╗    ██╗███████╗██████╗      █████╗ ██████╗ ███████╗███╗   ██╗ █████╗
// ██╔════╝██╔════╝██║    ██║██╔════╝██╔══██╗    ██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗
// ███████╗█████╗  ██║ █╗ ██║█████╗  ██████╔╝    ███████║██████╔╝█████╗  ██╔██╗ ██║███████║
// ╚════██║██╔══╝  ██║███╗██║██╔══╝  ██╔══██╗    ██╔══██║██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║
// ███████║███████╗╚███╔███╔╝███████╗██║  ██║    ██║  ██║██║  ██║███████╗██║ ╚████║██║  ██║
// ╚══════╝╚══════╝ ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_SewerArena( entity player )
{
	thread SewerArena_SludgeWallSFXThink()
	thread SewerArena_InitialCombat( player )
	
	if ( IsValid( player.GetPetTitan() ) )
		thread PlayAnim( player.GetPetTitan(), "bt_casual_idle" )

	FlagWait( "SewerArena_see_bt" )

	entity titan = player.GetPetTitan()
	if ( IsValid( titan ) )
		Highlight_SetOwnedHighlight( titan, "pet_titan_sp" )

	PlayerConversation( "BT_Reunite", player )

	PlayBTDialogue( "BT_DISABLE_SLUDGE" )
	wait 1.0
	Objective_Set_WithAltHighlight( "#SEWERS_OBJ_SEWER_ARENA_ASSAULT", <0,0,0>, file.SewerArena_pumpSwitch )

	FlagWait( "PilotArena_PumpSwitchActivated" )
}


void function StartPoint_Setup_SewerArena( entity player )
{
	TeleportPlayerAndBT( "playerstart_sewer_arena", "titanstart_sewer_arena" )
}


void function StartPoint_Skipped_SewerArena( entity player )
{
	thread SewerArena_SludgeWallSFXThink()

	entity titan = player.GetPetTitan()
	if ( IsValid( titan ) )
		Highlight_SetOwnedHighlight( titan, "pet_titan_sp" )
}


void function SewerArena_SludgeWallSFXThink()
{
	array<entity> curtainEmitters = GetEntArrayByScriptName( "sewers_emit_sludgecurtain" )
	foreach( emitter in curtainEmitters )
		EmitSoundAtPosition( TEAM_ANY, emitter.GetOrigin(), SFX_SLUDGE_WALL_CURTAIN )

	array<entity> groundEmitters = GetEntArrayByScriptName( "sewers_emit_sludgecurtain_ground" )
	foreach( emitter in groundEmitters )
		EmitSoundAtPosition( TEAM_ANY, emitter.GetOrigin(), SFX_SLUDGE_WALL_GROUND )


	// When this flag is cleared, stop the sludge sounds
	FlagWaitClear( "fx_reclamation_arena_sludge" )
	foreach( emitter in curtainEmitters )
		StopSoundAtPosition( emitter.GetOrigin(), SFX_SLUDGE_WALL_CURTAIN )

	foreach( emitter in groundEmitters )
		StopSoundAtPosition( emitter.GetOrigin(), SFX_SLUDGE_WALL_GROUND )
}


void function SewerArena_InitialCombat( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity controlRoomMoveTarget = GetEntByScriptName( "pilotarena_movetarget_controlroom" )

	array<entity> defenderSpawners = GetEntArrayByScriptName( "pilotarena_initial_group" )
	array<entity> defenders = SpawnFromSpawnerArray( defenderSpawners )

	int totalDefenders = defenders.len()
	int numToKill = ( (totalDefenders * 0.7 ) + 0.5 ).tointeger()

	printt( "Defenders:", totalDefenders, "(", numToKill, "kills to progress )")
	WaitUntilNumDead( defenders, numToKill )

	ArrayRemoveDead( defenders )
	if ( defenders.len() )
	{
		foreach ( guy in defenders )
			thread AssaultMoveTarget( guy, controlRoomMoveTarget )
	}

	// Initial combat is done when room is clear or switch is activated
	while ( 1 )
	{
		if ( Flag( "PilotArena_PumpSwitchActivated" ) )
			break

		ArrayRemoveDead( defenders )
		WaitUntilNumDeadWithTimeout( defenders, defenders.len(), 1.0 )
		ArrayRemoveDead( defenders )

		if ( defenders.len() <= 0 )
			break
	}

	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_NEED_REINFORCEMENTS", TEAM_IMC )
	wait 4.0
	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_CALL_FOR_BACKUP", TEAM_IMC )
	wait 4.0

	if ( !Flag( "PilotArena_PumpSwitchActivated" ) )
	{
		thread PlayBTDialogue( "BT_DISABLE_SLUDGE_NAG" )
		Objective_Remind()
	}
}


// -------------------------------------------------------------------------------------------------------------------------
//
//  █████╗ ██████╗ ███████╗███╗   ██╗ █████╗     ██████╗ ███████╗███████╗███████╗███╗   ██╗██████╗
// ██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗    ██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║██╔══██╗
// ███████║██████╔╝█████╗  ██╔██╗ ██║███████║    ██║  ██║█████╗  █████╗  █████╗  ██╔██╗ ██║██║  ██║
// ██╔══██║██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║    ██║  ██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║██║  ██║
// ██║  ██║██║  ██║███████╗██║ ╚████║██║  ██║    ██████╔╝███████╗██║     ███████╗██║ ╚████║██████╔╝
// ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_SewerArenaDefend( entity player )
{
	thread SewerArena_PumpLightsAndAlarm()

	entity ceilingSfxEmitter = GetEntByScriptName( "SewerArena_ceiling_sfx_emitter" )
	EmitSoundAtPosition( TEAM_ANY, ceilingSfxEmitter.GetOrigin(), "sewers_scripted_curtainoffsequence_beforealarm_lp" )

	thread SewerArena_PumpAudioThink()

	StopMusicTrack( "music_reclamation_16_shitshower" )
	PlayMusic( "music_reclamation_17_activatesluice" )

	entity titan = player.GetPetTitan()
	if ( IsValid( titan ) )
	{
		titan.Anim_Stop()
		titan.kv.alwaysalert = true
	}

	FlagSet( "SewerArena_close_door" )

	wait 1.5

	PlayDialogue( "PA_PUMP_OVERRIDE", ceilingSfxEmitter )

	Objective_Clear()

	CheckPoint()

	wait 1.0

	entity moveTarget = GetEntByScriptName( "SewerArena_bt_move_spot" )

	foreach( entity p in GetPlayerArray() )
	if ( IsValid( p.GetPetTitan() ) )
		AssaultEntity( p.GetPetTitan(), moveTarget )

	thread SewerArena_DefendCombat( player )
	
	AutoFlagWithTimeout( "SewerArenaDefendDone", 120*1.5 )
	FlagWait( "SewerArenaDefendDone" ) // script FlagSet( "SewerArenaDefendDone" )
	thread SewerArena_SludgeWaterfalls_Shutdown()

	Signal( level, "PlayerLeftSewerDefend" )

	Objective_Set( "#SEWERS_OBJ_ENEMY_TERRITORY" )

	waitthread PlayBTDialogue( "BT_PROTO_2" )
	PlayBTDialogue( "BT_RESUME_MISSION" )
}

void function AutoFlagWithTimeout( string FlagName, float WaitTime )
{
	wait WaitTime
	FlagSet( FlagName )
}


void function StartPoint_Setup_SewerArenaDefend( entity player )
{
	file.SewerArena_pumpSwitch.Signal( "OnDeactivate" )
	FlagSet( "PilotArena_PumpSwitchActivated" )

	TeleportPlayerAndBT( "playerstart_sewer_arena_defend", "titanstart_sewer_arena_defend" )
}


void function StartPoint_Skipped_SewerArenaDefend( entity player )
{
}


void function SewerArena_PumpAudioThink()
{
	wait 152  // hard coded to match the pump audio

	entity ceilingSfxEmitter = GetEntByScriptName( "SewerArena_ceiling_sfx_emitter" )
	EmitSoundAtPosition( TEAM_ANY, ceilingSfxEmitter.GetOrigin(), "sewers_scripted_curtainoffsequence_loop_only" )
}


void function SewerArena_DefendCombat( entity player )
{
	// player.EndSignal( "OnDestroy" )

	EndSignal( level, "PlayerLeftSewerDefend" )

	CreateNPCSquad( "northwest" )
	CreateNPCSquad( "northeast" )
	CreateNPCSquad( "west" )
	CreateNPCSquad( "southwest" )
	CreateNPCSquad( "southeast" )

	entity ceilingSfxEmitter = GetEntByScriptName( "SewerArena_ceiling_sfx_emitter" )

	// N = left
	// W = mid
	// S = right
	entity dropshipSpawner_NE = GetEntByScriptName( "pilotarena_dropship_NE" )
	entity dropshipSpawner_NW = GetEntByScriptName( "pilotarena_dropship_NW" )
	entity dropshipSpawner_W = GetEntByScriptName( "pilotarena_dropship_W" )
	entity dropshipSpawner_SW = GetEntByScriptName( "pilotarena_dropship_SW" )
	entity dropshipSpawner_SE = GetEntByScriptName( "pilotarena_dropship_SE" )

	entity moveTargetNW = GetEntByScriptName( "pilotarena_movetarget_NW_finale" )
	entity moveTargetW = GetEntByScriptName( "pilotarena_movetarget_W_finale" )
	entity moveTargetSW = GetEntByScriptName( "pilotarena_movetarget_SW_finale" )

	// arrays to hold guys after they spawn
	array<entity> allSpawned
	array<entity> dropshipSpawners
	int numReqDead


	// ---------------------------------------------------------------
	// PART 1 - Ticks only!
	// ---------------------------------------------------------------

	// Goblin 1-5 releasing Ticks.
	PlayDialogue( "IMC_DROP_TICKS", ceilingSfxEmitter )

	FlagSet( "SewerDefend_tickship_mid" )
	FlagSet( "SewerDefend_tickship_left" )
	FlagSet( "SewerDefend_tickship_right" )

	wait 1.0
	PlayDialogue( "SewerArena_imc_ticksReleased1", ceilingSfxEmitter )
	thread SewerArena_LaunchTicks( "tickspawner_mid", 3, 1, 2 )
	thread SewerArena_LaunchTicks( "tickspawner_left", 3, 1, 2 )
	thread SewerArena_LaunchTicks( "tickspawner_right", 3, 1, 2 )

	wait 1.0
	Objective_Set( "#SEWERS_OBJ_SEWER_ARENA_DEFEND" )

	wait 1.0
	PlayDialogue( "PA_PUMP_SHUTDOWN_20", ceilingSfxEmitter )

	// Give ticks some time to breathe
	array<entity> ticks = GetNPCArrayByClass( "npc_frag_drone" )
	WaitUntilPercentDead_WithTimeout( ticks, 0.25, 10.0 )

	wait 1.0
	if ( IsValid( player ) )
		PlayerConversation( "BT_SludgeCantShoot", player )

	// ---------------------------------------------------------------
	// PART 2 - Ticks then grunts  ( 3 grunts per dropship )
	// ---------------------------------------------------------------

	// ------------------------ CENTER ------------------------
	FlagClear( "DropshipDeploy_W" )
	dropshipSpawners = [ dropshipSpawner_W ]
	file.numSpawnGroupsFinished = 0

	thread SpawnFromDropship_AddToArray( dropshipSpawner_W, allSpawned )
	wait 3.75  // takes this long to reach the deploy spot

	PlayDialogue( "SewerArena_imc_ticksReleased1", ceilingSfxEmitter )
	thread SewerArena_LaunchTicks( "tickspawner_mid", 3, 1, 3 )
	wait 2.0  // wait before letting squad rappel

	FlagSet( "DropshipDeploy_W" )

	PlayDialogue( "SewerArena_imc_reinforce1", ceilingSfxEmitter )

	while ( file.numSpawnGroupsFinished < dropshipSpawners.len() )
		wait 1


	// ------------------------ RIGHT ------------------------
	FlagClear( "DropshipDeploy_NW" )
	dropshipSpawners = [ dropshipSpawner_NW ]
	file.numSpawnGroupsFinished = 0

	thread SpawnFromDropship_AddToArray( dropshipSpawner_NW, allSpawned )
	wait 3.75 // takes this long to reach the deploy spot

	PlayDialogue( "SewerArena_imc_ticksReleased2", ceilingSfxEmitter )
	thread SewerArena_LaunchTicks( "tickspawner_left", 3, 1, 3 )
	wait 2.0  // wait before letting squad rappel

	FlagSet( "DropshipDeploy_NW" )

	PlayDialogue( "SewerArena_imc_reinforce2", ceilingSfxEmitter )

	while ( file.numSpawnGroupsFinished < dropshipSpawners.len() )
		wait 1.0


	// Pump status update
	wait 1.0
	PlayDialogue( "PA_PUMP_SHUTDOWN_40", ceilingSfxEmitter )
	CheckPoint_Silent()

	// ------------------------ LEFT ------------------------
	FlagClear( "DropshipDeploy_SW" )
	dropshipSpawners = [ dropshipSpawner_SW ]
	file.numSpawnGroupsFinished = 0

	thread SpawnFromDropship_AddToArray( dropshipSpawner_SW, allSpawned )
	wait 3.75 // takes this long to reach the deploy spot

	PlayDialogue( "SewerArena_imc_ticksReleased3", ceilingSfxEmitter )
	thread SewerArena_LaunchTicks( "tickspawner_right", 3, 1, 3 )
	wait 2.0  // wait before letting squad rappel

	FlagSet( "DropshipDeploy_SW" )

	// Squad 2 rappelling now!
	PlayDialogue( "SewerArena_imc_reinforce3", ceilingSfxEmitter )

	while ( file.numSpawnGroupsFinished < dropshipSpawners.len() )
		wait 1.0


	// ---------------------------------------------------------------
	// INTERMISSION
	// ---------------------------------------------------------------

	// Wait until % of all grunts dead, or timeout
	WaitUntilPercentDead_WithTimeout( allSpawned, 0.25, 30.0 )

	CheckPoint_Silent()


	// ---------------------------------------------------------------
	// PART 3 - More grunts!  ( 4 grunts per dropship )
	// ---------------------------------------------------------------

	// ------------------------ LEFT ------------------------
	FlagClear( "DropshipDeploy_SE" )
	dropshipSpawners = [ dropshipSpawner_SE ]
	file.numSpawnGroupsFinished = 0

	thread SpawnFromDropship_AddToArray( dropshipSpawner_SE, allSpawned )
	wait 3.75 // takes this long to reach the deploy spot

	PlayDialogue( "SewerArena_imc_ticksReleased3", ceilingSfxEmitter )
	thread SewerArena_LaunchTicks( "tickspawner_right", 3, 1, 3 )
	wait 2.0  // wait before letting squad rappel

	FlagSet( "DropshipDeploy_SE" )

	// Squad 2 rappelling now!
	PlayDialogue( "SewerArena_imc_reinforce3", ceilingSfxEmitter )

	while ( file.numSpawnGroupsFinished < dropshipSpawners.len() )
		wait 1.0


	// ------------------------ RIGHT ------------------------
	FlagClear( "DropshipDeploy_NE" )
	dropshipSpawners = [ dropshipSpawner_NE ]
	file.numSpawnGroupsFinished = 0

	thread SpawnFromDropship_AddToArray( dropshipSpawner_NE, allSpawned )
	wait 3.75 // takes this long to reach the deploy spot

	PlayDialogue( "SewerArena_imc_ticksReleased2", ceilingSfxEmitter )
	thread SewerArena_LaunchTicks( "tickspawner_left", 3, 1, 3 )
	wait 2.0  // wait before letting squad rappel

	FlagSet( "DropshipDeploy_NE" )

	PlayDialogue( "SewerArena_imc_reinforce2", ceilingSfxEmitter )

	while ( file.numSpawnGroupsFinished < dropshipSpawners.len() )
		wait 1.0


	//wait until % of all grunts dead
	WaitUntilPercentDead_WithTimeout( allSpawned, 0.5, 30.0 )

	CheckPoint_Silent()

	wait 4.0


	// ---------------------------------------------------------------
	// PART 4 - More Ticks!
	// ---------------------------------------------------------------
	PlayDialogue( "SewerArena_boss_tickWaveStart", ceilingSfxEmitter )

	FlagSet( "SewerDefend_tickship_mid" )
	FlagSet( "SewerDefend_tickship_left" )
	FlagSet( "SewerDefend_tickship_right" )

	wait 3.0

	thread SewerArena_LaunchTicks( "tickspawner_mid", 4, 1, 2 )
	thread SewerArena_LaunchTicks( "tickspawner_left", 4, 1, 2 )
	thread SewerArena_LaunchTicks( "tickspawner_right", 4, 1, 2 )

	//wait until % of all grunts dead
	WaitUntilPercentDead_WithTimeout( allSpawned, 0.5, 15.0 )

	PlayDialogue( "PA_PUMP_SHUTDOWN_50", ceilingSfxEmitter )
	StopMusicTrack("music_reclamation_17_activatesluice" )
	PlayMusic( "music_reclamation_17a_thingsgetbad" )
	CheckPoint_Silent()

	// ---------------------------------------------------------------
	// PART 5 - EVERYONE!!!!  ( 18 grunts...maybe a bit much... )
	// ---------------------------------------------------------------
	FlagClear( "DropshipDeploy_W" )
	FlagClear( "DropshipDeploy_NW" )
	FlagClear( "DropshipDeploy_SW" )
	FlagClear( "DropshipDeploy_NE" )
	FlagClear( "DropshipDeploy_SE" )
	dropshipSpawners = [ dropshipSpawner_W, dropshipSpawner_NW, dropshipSpawner_SW, dropshipSpawner_NE, dropshipSpawner_SE ]
	file.numSpawnGroupsFinished = 0

	// All dropships deploy immediately
	FlagSet( "DropshipDeploy_W" )
	FlagSet( "DropshipDeploy_NW" )
	FlagSet( "DropshipDeploy_SW" )
	FlagSet( "DropshipDeploy_NE" )
	FlagSet( "DropshipDeploy_SE" )

	thread SpawnFromDropship_AddToArray( dropshipSpawner_SW, allSpawned )
	wait 2.5
	thread SpawnFromDropship_AddToArray( dropshipSpawner_NW, allSpawned )
	wait 5.0
	thread SpawnFromDropship_AddToArray( dropshipSpawner_W, allSpawned )
	wait 5.0
	thread SpawnFromDropship_AddToArray( dropshipSpawner_NE, allSpawned )
	wait 1.0
	thread SpawnFromDropship_AddToArray( dropshipSpawner_SE, allSpawned )

	while ( file.numSpawnGroupsFinished < dropshipSpawners.len() )
		wait 1


	// ---------------------------------------------------------------
	// PART 6 - Grand finale - Pumps shut down, BT cleans up
	// ---------------------------------------------------------------
	PlayDialogue( "PA_PUMP_SHUTDOWN_80", ceilingSfxEmitter )
	PlayMusic( "music_reclamation_18_sluicebuildup" )
	CheckPoint_Silent()

	// "sewers_scripted_curtainoffsequence_alarm" is exactly 29 seconds long and builds up over time and we want to make sure it does that.
	wait 15
	PlayDialogue( "PA_PUMP_SHUTDOWN_90", ceilingSfxEmitter )
	CheckPoint_Silent()
	wait 11.5

	FlagSet( "SewerArena_pumps_start_shutdown" )
	CheckPoint_Silent()

	wait 2.5

	StopSoundAtPosition( ceilingSfxEmitter.GetOrigin(), "sewers_scripted_curtainoffsequence_beforealarm_lp" )
	StopSoundAtPosition( ceilingSfxEmitter.GetOrigin(), "sewers_scripted_curtainoffsequence_loop_only" )
	EmitSoundAtPosition( TEAM_ANY, ceilingSfxEmitter.GetOrigin(), "sewers_scripted_curtainoffsequence_ceilingafter" )

	PlayDialogue( "PA_PUMP_SHUTDOWN_COMPLETE", ceilingSfxEmitter )

	// Send all grunts attack BT area
	SquadAssaultEntity( "northwest", moveTargetNW )
	SquadAssaultEntity( "northeast", moveTargetNW )
	SquadAssaultEntity( "west", moveTargetW )
	SquadAssaultEntity( "southwest", moveTargetSW )
	SquadAssaultEntity( "southeast", moveTargetSW )

	// Sludge curtains removed, BT starts firing into area
	thread SewerArena_SludgeWaterfalls_Shutdown()

	StopMusicTrack( "music_reclamation_17a_thingsgetbad" )
	PlayMusic( "music_reclamation_19_btrejoins" )
	CheckPoint_Silent()

	wait 2.0

	thread SewerArena_SludgeWaterfalls_ShutdownVO( player )

	// Progression wait until player and BT mop up all the reinforcements
	WaitUntilPercentDead_WithTimeout( allSpawned, 1, 30.0 )

	wait 3.0

	// ---------------------------------------------------------------
	// PART 7 - All done. Let's move out.
	// ---------------------------------------------------------------
	FlagSet( "PilotArena_Combat_Done" )
	Objective_Clear()

	SewerArena_BTExit( player )

	// Pilot, that was a difficult battle. You handled yourself well. I have noted it for the record.
	PlayBTDialogue( "BT_HANDLED_YOURSELF_WELL" )

	wait 1.0

	// Pilot, I have identified an exit on this side. This way.
	thread PlayBTDialogue( "BT_EXIT_THIS_WAY" )

	wait 1.0

	entity spot = GetEntByScriptName( "SewerArena_bt_move_spot_final" )
	Objective_Set( "#SEWERS_OBJ_SEWER_ARENA_JOIN_BT", spot.GetOrigin() )

	FlagWait( "SewerArena_Joined_BT" )

	Objective_Clear()

	// Fill up BT's core a bit
	entity soul
	if ( player.IsTitan() )
	{
		soul = player.GetTitanSoul()
	}
	else
	{
		entity titan = player.GetPetTitan()

		if ( titan != null )
			soul = titan.GetTitanSoul()
	}

	SoulTitanCore_SetNextAvailableTime( soul, BT_CORE_START_VALUE_ON_PLAYER_RETURN )

	StopMusicTrack( "music_reclamation_19_btrejoins" )
	PlayMusic( "music_reclamation_20_backwithbt" )
	wait 1.5
}


void function SpawnFromDropship_AddToArray( entity dropshipSpawner, array<entity> spawned )
{
	thread SpawnFromDropship( dropshipSpawner )
	table dropshipSpawned = dropshipSpawner.WaitSignal( "OnSpawned" )  // This fires when the dropship AND all the passengers have spawned

	foreach ( guy in dropshipSpawned.riders )
		spawned.append( expect entity( guy ) )

	file.numSpawnGroupsFinished++
}


array<entity> function SpawnFromSpawnerArray_SewerArena( array<entity> spawners )
{
	array<entity> spawned = SpawnFromSpawnerArray( spawners, SewerArena_SetGruntSpawnOptions )
	return spawned
}


void function SewerArena_SetGruntSpawnOptions( entity npc )
{
	Assert( npc.GetClassName() == "npc_soldier" )

	npc.mySpawnOptions_alert = true
}


void function SewerArena_SludgeWaterfalls_ShutdownVO( entity player )
{
	player.EndSignal( "OnDestroy" )
	EndSignal( level, "PlayerLeftSewerDefend" )

	// Nobody to fight? Skip the VO
	array<entity> guys = GetNPCArrayEx( "npc_soldier", TEAM_IMC, TEAM_ANY, player.GetOrigin(), 3000 )
	if ( guys.len() <= 0 )
		return

	// Visual contact reestablished with Pilot. Commencing support fire.
	PlayBTDialogue( "SewerArena_bt_joinsFight" )

	wait 1.0

	PlayDialogueOnClosestNPCFromPlayer( player, "SewerArena_imc_reaxToTitan1", TEAM_IMC )
	PlayDialogueOnClosestNPCFromPlayer( player, "IMC_FOCUS_FIRE_TITAN", TEAM_IMC )
}


void function SewerArena_SludgeWaterfalls_Shutdown()
{
	EndSignal( level, "PlayerLeftSewerDefend" )

	const float SLUDGEFALL_HEIGHT 	= 1320.0
	const float MOVETIME_MIN 		= 8.0
	const float MOVETIME_MAX 		= 10.0
	const float WAITTIME_MIN 		= 2.5
	const float WAITTIME_MAX 		= 4.5
	const float MOVE_ACCEL_FRAC 	= 0.4
	const float MOVE_DECEL_FRAC 	= 0.1

	vector moveOrg
	float moveTime
	float accelTime
	float decelTime

	// This is the order the waterfalls will shut off.  If looking at them from control room, they are indexed 0-6 from left to right.
	array<int> shuttoffIndexOrder = [ 6, 0, 5, 1, 4, 2, 3 ]

	// Turn off waterfall FX
	FlagClear( "fx_reclamation_arena_sludge" )

	// Move all collision and damage brushes.  Play sludge off SFX.
	foreach( idx, sludgeIndex in shuttoffIndexOrder )
	{
		if ( sludgeIndex == 4 )
		{
			entity btSightClip = GetEntByScriptName( "pilotarena_titan_clipwall" )
			btSightClip.Destroy()
			FlagSet( "SewerArena_SightClipRemoved" )
		}

		string str_sludgeIndex = string( sludgeIndex )
		entity sludgeBrush = SafeGetEnt( "SewerArena_sludge_wall_clip_" + str_sludgeIndex )
		entity hurtTrigger = SafeGetEnt( "SewerArena_sludge_wall_hurt_trigger_" + str_sludgeIndex )

		hurtTrigger.Destroy()
		sludgeBrush.Destroy()

		// Play the SFX for this waterfall turning off
		string sfxName = "sewers_emit_sludgecurtain_off_" + str_sludgeIndex
		entity sfxEmitter = GetEntByScriptName( sfxName )
		thread EmitSoundAtPosition( TEAM_ANY, sfxEmitter.GetOrigin(), sfxName )

		//wait RandomFloatRange( WAITTIME_MIN, WAITTIME_MAX )

		wait 0.5
	}
}

entity function SafeGetEnt( string name )
{
	array<entity> ent = GetEntArrayByScriptName( name )

	if ( ent.len() == 0 )
		return CreateScriptMover()
	return ent[0]
}

void function SewerArena_BTExit( entity player )
{
	if ( player.IsTitan() == false )
	{
		entity moveTarget = GetEntByScriptName( "SewerArena_bt_move_spot_final" )
		entity titan = player.GetPetTitan()
		AssaultEntity( titan, moveTarget )
	}
}


void function SewerArena_LaunchTicks( string spawnerName, float tickCount, float minDelay, float maxDelay )
{
	// Grab the tick spawn locations and randomize them
	array<entity> spawners = GetEntArrayByScriptName( spawnerName )
	spawners.randomize()

	// Spawn an invisible Reaper to spawn the Ticks from
	vector origin = spawners[0].GetOrigin()
	vector angles = spawners[0].GetAngles()
	entity anchor = CreateScriptMover( origin, angles )
	entity dummy = CreateSuperSpectre( TEAM_IMC, origin, angles )
	DispatchSpawn( dummy )
	dummy.SetInvulnerable()
	dummy.SetEfficientMode( true )
	dummy.NotSolid()
	dummy.Hide()
	dummy.SetParent( anchor, "REF" )
	thread PlayAnim( dummy, "sspec_idle", anchor, "REF" )

	// Launch and spawn the ticks!
	foreach ( index, spawner in spawners )
	{
		thread SewerArena_LaunchTick( dummy, anchor, spawner, minDelay, maxDelay )
		wait RandomFloatRange( 0.25, 0.5 )

		if ( index >= tickCount - 1 )
			break
	}

	wait 0.5
	anchor.Destroy()
	dummy.Destroy()
}


void function SewerArena_LaunchTick( entity npc, entity anchor, entity spawner, float minDelay, float maxDelay )
{
	entity weapon      = npc.GetOffhandWeapon( 0 )
	Assert ( IsValid( weapon ) )

	vector vec 			= spawner.GetUpVector()
	vector launchPos	= spawner.GetOrigin()
	vector vel 			= vec * RandomFloatRange( 500, 1100 )
	vector angularVel 	= <200,0,0>
	float armTime 		= 2

	anchor.SetOrigin( spawner.GetOrigin() )
	anchor.SetAngles( spawner.GetAngles() )

	entity nade = weapon.FireWeaponGrenade( launchPos, vel, angularVel, armTime, damageTypes.explosive, damageTypes.explosive, PROJECTILE_NOT_PREDICTED, true, true )
	nade.SetOwner( npc )
	nade.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( nade, minDelay, maxDelay )
		{
			vector origin = nade.GetOrigin()
			vector angles = nade.GetAngles()

			vector ornull clampedPos = NavMesh_ClampPointForHullWithExtents( origin, HULL_HUMAN, < 100, 100, 100 > )
			if ( clampedPos == null )
				return

			entity drone = CreateFragDroneCan( TEAM_IMC, expect vector( clampedPos ), Vector( 0, angles.y, 0 ) )

			drone.kv.script_name = "SewerArena_tick"
			DispatchSpawn( drone )

			array<entity> players = GetPlayerArray()
			if ( players.len() > 0 )
			{
				entity player = players[0]
				 if ( IsAlive( player ) )
				 	drone.SetEnemy( player )
			}

			thread FragDroneDeplyAnimation( drone, minDelay, maxDelay )
			thread SewerArena_TickTimeout( drone )
		}
	)

	Grenade_Init( nade, weapon )

	EmitSoundAtPosition( TEAM_MILITIA, launchPos, "SpectreLauncher_AI_WpnFire" )

	while( 1 )
	{
		if ( nade.IsOnGround() )
			return

		wait 0.1
	}

	WaitForever()
}


void function SewerArena_TickTimeout( entity drone )
{
	drone.EndSignal( "OnDestroy" )
	drone.EndSignal( "OnDeath" )

	wait RandomFloatRange( SEWER_DEFEND_TICK_TIMEOUT_MIN, SEWER_DEFEND_TICK_TIMEOUT_MAX )

	drone.Die()
}


void function SewerArena_PumpLightsAndAlarm()
{
	FlagWait( "SewerArena_pumps_start_shutdown" )

	array<entity> lights = GetEntArrayByScriptName( "sludge_pump_light" )
	foreach( light in lights )
	{
		PlayFXOnEntity( FX_WARNING_LIGHT, light )
		thread SewerArena_PlayPumpAlarm( light )
	}

	WaitForever()
}


void function SewerArena_PlayPumpAlarm( entity light )
{
	vector origin = light.GetOrigin()
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, SFX_GATE_OPEN_ALARM )
	wait 2.5
	StopSoundAtPosition( origin, SFX_GATE_OPEN_ALARM )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ██╗  ██╗ █████╗ ███╗   ██╗███████╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
// ██║ ██╔╝██╔══██╗████╗  ██║██╔════╝    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
// █████╔╝ ███████║██╔██╗ ██║█████╗      █████╗  ██║██║  ███╗███████║   ██║
// ██╔═██╗ ██╔══██║██║╚██╗██║██╔══╝      ██╔══╝  ██║██║   ██║██╔══██║   ██║
// ██║  ██╗██║  ██║██║ ╚████║███████╗    ██║     ██║╚██████╔╝██║  ██║   ██║
// ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function StartPoint_KaneArena( entity player )
{
	printt("StartPoint_KaneArena")

	FlagSet( "kaneArena_connect_stairs_path" )

	TriggerSilentCheckPoint( < -6384, -6723, 2900 >, false )

	FlagWait( "KaneArena_spawn_kane" )

	printt("KaneArena_spawn_kane flag set")

	thread KaneArena_BTDisableMeleeThink( player )
	thread KaneArena_PickupHelmetSequence( player )

	entity titan = KaneArena_BossFightIntro( player, "KaneArena_kane" )
	Assert( IsValid( titan ) )
	file.kaneTitan = titan

	thread KaneArena_KaneDoomMonitor( player ) 		// When doomed, Kane plays a custom death anim and dies.

	FlagSet( "KaneArena_spawn_kane_buddy" )

	Objective_Set( "#SEWERS_OBJ_DEFEAT_KANE" )

	thread KaneArena_BT_ThermiteHintThink( player )
	thread KaneArena_StairsThink()

	FlagWait( "KaneArena_level_end" )
	
	Coop_LoadMapFromStartPoint( "sp_boomtown_start", "Intro" )
}


void function StartPoint_Setup_KaneArena( entity player )
{
	entity titan = player.GetPetTitan()
	PilotBecomesTitan( player, titan )
	titan.Destroy()

	TeleportPlayerAndBT( "playerstart_kane_arena", "titanstart_kane_arena" )
}


void function StartPoint_Skipped_KaneArena( entity player )
{
}


void function KaneArena_StairsThink()
{
	FlagWaitClear( "kaneArena_connect_stairs_path" )

	array<entity> stairSeparators = GetEntArrayByScriptName( "kaneArena_connect_stairs_path_separator" )
	foreach( separator in stairSeparators )
		separator.NotSolid()
}

void function KaneArena_BTDisableMeleeThink( entity player )
{
	return // crashes too much

	player.EndSignal( "OnDestroy" )

	while( 1 )
	{
		// Do this instead of deailing with PlayerDisembarked signal which is on the titan soul instead of player
		if( player.IsTitan() )
		{
			wait 0.1
			continue
		}

		printt("Disabling BT's synced melee because it breaks the Kane death & radio sequence.")

		entity bt = player.GetPetTitan()
		bt.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2, false )
		bt.SetCapabilityFlag( bits_CAP_INITIATE_SYNCED_MELEE, false )

		WaitSignal( player, "PlayerEmbarkedTitan" )
	}
}


entity function KaneArena_BT_ThermiteHintThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	wait 15.0  // Plenty of time for Kane to fire at least once

	if ( CoinFlip() )
		PlayBTDialogue( "BT_THERMITE_WARN_1" )
	else
		PlayBTDialogue( "BT_THERMITE_WARN_2" )
}


entity function KaneArena_BossFightIntro( entity player, string spawnerName )
{
	printt("KaneArena_BossFightIntro")

	player.EndSignal( "OnDestroy" )

	// Don't allow embark or disembark during titan intro because it causes issues if you're doing a sequence at the time
	Embark_Disallow( player )
	Disembark_Disallow( player )

	player.FreezeControlsOnServer()

	printt("spawning kane")

	StopMusicTrack( "music_reclamation_20_backwithbt" )
	PlayMusic( "music_reclamation_21_kaneslamcam" )

	// Spawn Boss
	entity titanSpawner = GetEntByScriptName( spawnerName )
	table spawnerKeyValues = titanSpawner.GetSpawnEntityKeyValues()
	entity titan = titanSpawner.SpawnEntity()
	DispatchSpawn( titan )
	titan.SetTitle( "#BOSSNAME_KANE" )
	HideName( titan )
	HideCrit( titan )
	titan.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
	titan.EnableNPCFlag( NPC_IGNORE_ALL )
	titan.GetOffhandWeapon( OFFHAND_EQUIPMENT ).AllowUse( false ) // Disable core

	printt("spawning militia titan")

	// Spawn militia titan
	entity ref = GetEntByScriptName( "KaneArena_intro_ref" )
	titanSpawner = GetEntByScriptName( "KaneArena_militia_titan" )
	entity militiaTitan = titanSpawner.SpawnEntity()
	DispatchSpawn( militiaTitan )

	militiaTitan.SetSkin( 2 )  // militia skin
	militiaTitan.SetInvulnerable()
	militiaTitan.ContextAction_SetBusy()
	militiaTitan.EnableNPCFlag( NPC_IGNORE_ALL )
	militiaTitan.SetNoTarget( true )
	militiaTitan.SetAIObstacle( true )
	Highlight_ClearFriendlyHighlight( militiaTitan )
	DisableTitanRodeo( militiaTitan )
	HideName( militiaTitan )

	thread DisableDoomFX( militiaTitan, 2.0 )

	printt("waiting for BossTitanStartAnim")

	//WaitSignal( svGlobal.levelEnt, "BossTitanStartAnim" )

	printt( "playing mt_Kane_boss_intro_mt" )
	thread PlayAnim( militiaTitan, "mt_Kane_boss_intro_mt", ref )

	printt("spawning militia pilot")

	// Spawn the militia pilot
	entity pilot = CreatePropDynamic( TITAN_PILOT, militiaTitan.GetOrigin(), militiaTitan.GetAngles(), 6, 20000 )
	thread PlayAnim( pilot, "pt_Kane_boss_intro_pilot", ref )

	printt("teleporting player")

	thread KaneArena_BossIntroMovePlayerAndBT( player )

	printt("waiting for BossTitanIntroEnded")

	WaitSignal( titan, "BossTitanIntroEnded" )

	FlagSet( "KaneArena_shut_door" )
	FlagClear( "KaneArena_door_navmesh_flag" )

	thread PlayAnim( militiaTitan, "mt_Kane_boss_intro_mt_idle", ref )

	titan.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS )
	titan.DisableNPCFlag( NPC_IGNORE_ALL )

	printt("destryoing militia titan & cleaning up")
	local fx = GetParticleSystemIndex( FX_EXP_KANE_DEATH_DONE )
	StartParticleEffectInWorld( fx, < -4391, -6446, 3322 >, <0, 0, 0> )  // Play it exactly where we need it to cover the model delete.
	militiaTitan.Destroy()

	// Re-enable all weapons
	titan.SetTitle( "#BOSSNAME_KANE" )
	ShowName( titan )
	ShowCrit( titan )

	titan.SetEnemy( player )

	Embark_Allow( player )
	Disembark_Allow( player )
	player.UnfreezeControlsOnServer()

	printt("returning titan!")

	return titan
}


void function KaneArena_BossIntroMovePlayerAndBT( entity player )
{
	player.EndSignal( "OnDeath" )
	FlagWait( "BossTitanViewFollow" )
	wait 1.0
	TeleportPlayerAndBT( "KaneArena_fight_player_start_spot", "KaneArena_fight_bt_start_spot" )

	entity bt = player.GetPetTitan()
	if ( IsValid( bt ) )
	{
		bt.DisableBehavior( "Assault" )
		entity spot = GetEntByScriptName( "KaneArena_fight_bt_start_spot" )
		AssaultEntity( bt, spot, 256 )
	}
}


void function WaitTillHealthAtPercentage( entity npc, int targetHealthPercent )
{
	int startHealth 	= npc.GetHealth()
	int healthThreshold = ( startHealth * targetHealthPercent ) / 100

	while ( 1 )
	{
		if ( npc.GetHealth() <= healthThreshold )
			return

		wait 0.1
	}
}

void function KaneArena_KaneDoomMonitor( entity player )
{
	printt("KaneArena_KaneDoomMonitor")

	player.EndSignal( "OnDestroy" )
	file.kaneTitan.EndSignal( "OnDestroy" )

	// Wait until Kane is doomed
	file.kaneTitan.WaitSignal( "Doomed" )

	file.kaneTitan.SetInvulnerable()
	file.kaneTitan.ContextAction_SetBusy()
	file.kaneTitan.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
	file.kaneTitan.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	file.kaneTitan.SetEfficientMode( true )
	DisableTitanRodeo( file.kaneTitan )

	// Move Kane into position to avoid him falling into geo
	array<entity> finalDeathSpots = GetEntArrayByScriptName( "KaneArena_final_death_spot" )
	array<entity> deathSpots = GetEntArrayByScriptName( "KaneArena_death_spot" )
	finalDeathSpots.extend( deathSpots )
	entity spot = GetClosest( finalDeathSpots, file.kaneTitan.GetOrigin() )

	// Kane attemps to walk there before giving up and just sliding into position.
	AssaultEntity( file.kaneTitan, spot, 256.0 )
	file.kaneTitan.AssaultSetArrivalTolerance( 4 )

	waitthread WaitSignalOrTimeout( file.kaneTitan, 1.5, "OnFinishedAssault" )

 	spot = GetClosest( finalDeathSpots, file.kaneTitan.GetOrigin() )
	printt("-------------------------------------------")
	printt("MOVING KANE TO NODE AT:", spot.GetOrigin() )
	printt("-------------------------------------------")

	entity mover = CreateScriptMover( file.kaneTitan.GetOrigin(), file.kaneTitan.GetAngles() )
	file.kaneTitan.SetParent( mover )

	float slideDuration = 1.0
	mover.NonPhysicsMoveTo( spot.GetOrigin(), slideDuration, slideDuration*0.4, slideDuration*0.4 )
	mover.NonPhysicsRotateTo( spot.GetAngles(), slideDuration, slideDuration*0.4, slideDuration*0.4 )

	// Have Kane face the player
	// vector v = Normalize( player.GetViewForward() - spot.GetOrigin() )
	// vector a = VectorToAngles( v )
	// vector angles = < 0, a.y, 0 >

	wait slideDuration

	// If he hasn't gotten there, pop him there anyway!
	file.kaneTitan.ClearParent()
	file.kaneTitan.SetOrigin( spot.GetOrigin() )
	file.kaneTitan.SetAngles( spot.GetAngles() )

	// Get rid of any weapon locks on Kane
	entity ordnanceWeapon = player.GetOffhandWeapon( OFFHAND_ORDNANCE )
	if ( IsValid( ordnanceWeapon ) )
		ordnanceWeapon.SmartAmmo_UntrackEntity( file.kaneTitan )
	file.kaneTitan.SetNoTarget( true )
	file.kaneTitan.SetNoTargetSmartAmmo( false )
	HideName( file.kaneTitan )
	HideCrit( file.kaneTitan )
	SetTeam( file.kaneTitan, TEAM_UNASSIGNED )
	file.kaneTitan.SetAIObstacle( true )

	string name = file.kaneTitan.ai.bossCharacterName == "" ? "Generic1" : file.kaneTitan.ai.bossCharacterName
	Remote_CallFunction_NonReplay( player, "ServerCallback_BossTitanDeath", file.kaneTitan.GetEncodedEHandle(), GetBossTitanID( name ) )

	CreateShake( file.kaneTitan.GetOrigin(), 16, 150, 2, 6000 )

	local fx = GetParticleSystemIndex( FX_EXP_KANE_DEATH_START )
	local attachID = file.kaneTitan.LookupAttachment( "exp_torso_main" )
	StartParticleEffectOnEntity( file.kaneTitan, fx, FX_PATTACH_POINT_FOLLOW, attachID )

	AddAnimEvent( file.kaneTitan, "kane_death_anim_done", FinalizeKaneDeath )
	PlayAnim( file.kaneTitan, "ht_Kane_death_ht" )
}


void function FinalizeKaneDeath( entity titan )
{
	printt("FinalizeKaneDeath")

	vector kanePos = file.kaneTitan.GetOrigin()
	vector kaneAng = file.kaneTitan.GetAngles()

	// Drop the body's location to the ground and store it off for use later by objective system
	entity ref = CreateScriptRef( kanePos, kaneAng )
	ref.SetOrigin( ref.GetOrigin() + < 0, 0, 100 > )  // Put it up in the air a bit before we drop to ground otherwise it can trace down thru to the bottom of the world
	DropToGround( ref )

	file.kaneBodyPoint.origin = ref.GetOrigin()
	file.kaneBodyPoint.angles = ref.GetAngles()

	local fx = GetParticleSystemIndex( FX_EXP_KANE_DEATH_DONE )
	StartParticleEffectInWorld( fx, file.kaneBodyPoint.origin, file.kaneBodyPoint.angles )

	CreateShake( file.kaneBodyPoint.origin, 20, 150, 2, 6000 )

	EmitSoundAtPosition( TEAM_ANY, file.kaneBodyPoint.origin, SFX_KANE_EXPLOSION )

	TakeAllWeapons( file.kaneTitan )
	DeregisterBossTitan( file.kaneTitan )

	printt("FinalizeKaneDeath - setting flag: KaneArena_helmet_ready_for_pickup")

	FlagSet( "KaneArena_helmet_ready_for_pickup" )

	ref.Destroy()
}


void function KaneArena_PickupHelmetSequence( entity player )
{
	player.EndSignal( "OnDestroy" )

	printt( "KaneArena_PickupHelmetSequence - waiting for KaneArena_helmet_ready_for_pickup" )

	FlagWait( "KaneArena_helmet_ready_for_pickup" )

	// Achievement!
	UnlockAchievement( player, achievements.BEAT_KANE )

	printt("KaneArena_PickupHelmetSequence - start" )

	thread KaneArena_PickupHelmetThink( player )

	FlagWait( "KaneArena_kane_buddy_dead" )

	StopMusicTrack( "music_reclamation_21_kaneslamcam" )
	PlayMusic ( "music_reclamation_22_kanedefeated" )

	printt("KaneArena_PickupHelmetSequence - moving on")

	Objective_Clear()

	wait 5.5

	PlayBTDialogue( "BT_WellDone" )

	wait 0.5

	thread KaneArena_HighlightKaneObjective( player )

	wait 2.0

	thread KaneArena_AmbientKaneRadioBroadcast( player )

	thread KaneArena_DisembarkNag( player )

	FlagWait( "KaneArena_radio_intercept_done" )
	Objective_Clear()

	Coop_LoadMapFromStartPoint( "sp_boomtown_start", "Intro" )

	wait 1.0

	PlayBTDialogue( "BT_WE_HAVE_ADVANTAGE" )
	PlayBTDialogue( "BT_KEEP_MOVING" )

	FlagSet( "KaneArena_level_end" )
	
	// setnext map
	Coop_LoadMapFromStartPoint( "sp_boomtown_start", "Intro" )
}


void function KaneArena_HighlightKaneObjective( entity player )
{
	player.EndSignal( "OnDestroy" )

	PlayBTDialogue( "BT_GetRadio" )
	Objective_Set( "#SEWERS_OBJ_TAKE_HELMET", file.kaneBodyPoint.origin + < 0, 0, 100 > )
	Highlight_SetNeutralHighlight( file.kaneTitan, OBJECTIVE_HIGHLIGHT )

	FlagWait( "KaneRadioPickup_SequenceStart" )
	Highlight_ClearNeutralHighlight( file.kaneTitan )
	Objective_Clear()
}

void function KaneArena_PickupHelmetThink( entity player )
{
	printt("KaneArena_PickupHelmetThink")

	thread KaneArena_FirstRadioTransmission( player )

 	entity kanePilotBody = CreatePropDynamic( KANE_MODEL, file.kaneBodyPoint.origin, file.kaneBodyPoint.angles, SOLID_VPHYSICS )
 	entity kaneHelmet = CreatePropDynamic( HELMET_MODEL, file.kaneBodyPoint.origin, file.kaneBodyPoint.angles, SOLID_VPHYSICS )
 	entity ref = CreateScriptRef( file.kaneBodyPoint.origin, file.kaneBodyPoint.angles )

	file.kaneTitan.SetModel( KANE_TITAN_MODEL_HD )
	MakeTitanLookDamaged( file.kaneTitan )
	file.kaneTitan.SetSkin( 1 ) // Boss skin
	HideCrit( file.kaneTitan )

	thread CreateTitanBodyDamagedFX( file.kaneTitan )

 	// Play titan death idle
	thread PlayAnimTeleport( file.kaneTitan, "ht_Kane_boss_helmet_grab_idle_ht", ref )
	thread PlayAnimTeleport( kanePilotBody, "pt_Kane_boss_helmet_grab_kane_idle", ref )
	thread PlayAnimTeleport( kaneHelmet, "kane_sewers_helmet_grab_idle", ref )

	// Move the Kane torso blocking block
	int attachID = file.kaneTitan.LookupAttachment( "HATCH_PANEL" )
	vector blockSpot = file.kaneTitan.GetAttachmentOrigin( attachID )
	entity block = GetEntByScriptName( "KaneArena_kane_collision_brush" )
	block.SetOrigin( blockSpot )
	block.SetAngles( file.kaneTitan.GetAngles() )

	FlagWait( "KaneArena_kane_buddy_dead" )

 	// Setup the use dummy
	entity useDummy = CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, file.kaneBodyPoint.origin, file.kaneBodyPoint.angles, 2 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	useDummy.SetOrigin( file.kaneBodyPoint.origin + < 0, 0, 50 > )
	useDummy.SetUsable()
	useDummy.SetUsableRadius( 200 )
	useDummy.Hide()
	useDummy.SetUsableByGroup( "pilot" )
	useDummy.SetUsePrompts( "#SEWERS_HINT_TAKE_HELMET" , "#SEWERS_HINT_TAKE_HELMET_PC" )

	local playerActivator
	while( true )
	{
		playerActivator = useDummy.WaitSignal( "OnPlayerUse" ).player
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() && !playerActivator.IsTitan() )
		{
			player = expect entity( useDummy.WaitSignal( "OnPlayerUse" ).player )
			break
		}
	}

	useDummy.UnsetUsable()
	useDummy.Destroy()

	FlagSet( "KaneRadioPickup_SequenceStart" )

	Embark_Disallow( player )

	thread KaneArena_BTMovesOutOfTheWay( player )

	// Animate all the props
	thread PlayAnimTeleport( file.kaneTitan, "ht_Kane_boss_helmet_grab_ht", ref )
	thread PlayAnimTeleport( kanePilotBody, "pt_Kane_boss_helmet_grab_kane", ref )
	thread PlayAnimTeleport( kaneHelmet, "kane_sewers_helmet_grab", ref )

 	// First person anim
	player.DisableWeapon()
	player.SetInvulnerable()
	player.ContextAction_SetBusy()

	entity mover = CreateOwnedScriptMover( ref ) //need a mover for first person sequence

	FirstPersonSequenceStruct getHelmetSeq
	getHelmetSeq.attachment = "ref"
	getHelmetSeq.firstPersonAnim = "ptpov_Kane_boss_helmet_grab_pilot"
	getHelmetSeq.thirdPersonAnim = "pt_Kane_boss_helmet_grab_pilot"
	getHelmetSeq.viewConeFunction = ViewConeTight

	waitthread FirstPersonSequence( getHelmetSeq, player, mover )

	if ( !IsValid( player ) )
		return

	thread PlayAnimTeleport( file.kaneTitan, "ht_Kane_boss_helmet_grab_after_idle_ht", ref )

	player.ClearInvulnerable()
	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.EnableWeapon()


	// Check to see if the animation ended the player in geo and if so, move them to the nearest valid space on the navmesh
	vector newPos = player.GetOrigin()
	if ( PlayerPosInSolid( player, newPos ) )
	{
		printt( "PLAYER'S TARGET POS IS IN A SOLID!" )

		vector ornull clampedPos = NavMesh_ClampPointForHullWithExtents( newPos, HULL_HUMAN, < 100, 100, 100 > )
		if ( clampedPos == null )
			printt( "ERROR! - Player in solid at and has no navmesh spot to go to!" )
		else
			newPos = expect vector( clampedPos )

		newPos.z += 25
	}

	player.SetOrigin( newPos )

	wait 0.5

	CreateShakeRumbleOnly( newPos, 12, 150, 1 )
}


void function KaneArena_BTMovesOutOfTheWay( entity player )
{
	entity bt = player.GetPetTitan()
	vector btSpot = bt.GetOrigin()

	if ( !IsValid( bt ) )
		return

	int numPositions = 5
	float distanceBehindPlayer = 300
	float maxDistanceFromSearchSpot = distanceBehindPlayer * 0.25

	vector playerPos = player.GetOrigin()
	vector playerForwardVec = player.GetViewForward()
	vector posBehindPlayer = playerPos - ( playerForwardVec * distanceBehindPlayer )

	posBehindPlayer += < 0, 0, 500 >  // Put it up in the air to compensate for the ramp in this room.
	posBehindPlayer = OriginToGround( posBehindPlayer )

	//DebugDrawSphere( posBehindPlayer, 25.0, 255, 0, 0, true, 5.0 )

	vector ornull clampedPos = NavMesh_ClampPointForHullWithExtents( posBehindPlayer, HULL_TITAN, < 1000, 1000, 1000 > )
	if ( clampedPos != null )
	{
		// Find some valid spots on on the navmesh for BT and move him to the first one.
		array<vector> randomSpots = NavMesh_RandomPositions( expect vector( clampedPos ), HULL_TITAN, numPositions, 0, maxDistanceFromSearchSpot )
		if( randomSpots.len() > 0 )
		{
			printt("BT Teleport: Found ", randomSpots.len(), "spots to teleport BT to.")
			btSpot = randomSpots[0]

			//DebugDrawSphere( btSpot, 25.0, 0, 255, 0, true, 60.0 )

			bt.SetOrigin( btSpot )
			DropToGround( bt )
		}
		else
		{
			printt("BT Teleport: No navmesh spots found to teleport BT!")
		}
	}
	else
	{
		printt("BT Teleport: NO NAVMESH CLAMP")
	}


	// Have BT face the player and play an idle anim always
	vector v = Normalize( playerPos - btSpot )
	vector a = VectorToAngles( v )
	bt.SetAngles( < 0, a.y, 0 > )
	
	if ( IsValid( bt ) )
		thread PlayAnim( bt, "bt_casual_idle" )
}


void function KaneArena_AmbientKaneRadioBroadcast( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity proxy = player.GetFirstPersonProxy()
	EndSignal( proxy, "AnimRadioGet_RadioDetachFromHelmet" )

	entity ref = CreateScriptRef( file.kaneBodyPoint.origin, file.kaneBodyPoint.angles )
	array<string> ambientRadioLines = [ "KANE_HELMET_AMBIENT_1", "KANE_HELMET_AMBIENT_2", "KANE_HELMET_AMBIENT_3", "KANE_HELMET_AMBIENT_4" ]

	while( 1 )
	{
		foreach( line in ambientRadioLines )
		{
			PlayDialogue( line, ref )
			wait 5.0
		}
	}
}


void function KaneArena_FirstRadioTransmission( entity player )
{
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			FlagSet( "KaneArena_radio_intercept_done" )
		}
	)

	entity proxy = player.GetFirstPersonProxy()
	WaitSignal( proxy, "AnimRadioGet_PlayRadioTransmission" )

	Remote_CallFunction_NonReplay( player, "ServerCallback_SewersRadioInterfaceSeq" )

	wait 16.5

	PlayDialogue( "RadioIntercept_01", player )
	PlayDialogue( "RadioIntercept_02", player )
	PlayDialogue( "RadioIntercept_03", player )
	PlayDialogue( "RadioIntercept_04", player )
	PlayDialogue( "RadioIntercept_05", player )
	PlayDialogue( "RadioIntercept_06", player )

	FlagSet( "KaneArena_radio_intercept_done" )
}


void function KaneArena_DisembarkNag( entity player )
{
	player.EndSignal( "OnDestroy" )

	float nagWaitTime = 30.0

	while( player.IsTitan()  )
	{
		wait nagWaitTime

		if( !player.IsTitan() )
			return

		thread PlayBTDialogue( "BT_GetRadio" )
		Remote_CallFunction_Replay( player, "ServerCallback_ShowDisembarkHint", 3.5 )
	}
}


// -------------------------------------------------------------------------------------------------------------------------
// Custome version to time out the player conversation afterwards
void function Kane_PA_IntroBroadcastThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "SludgeFalls_KanePA_ListenUp" )

	array<entity> speakers = GetEntArrayByScriptName( "sewers_pa_system_sfx_spot_kane_intro" )

	foreach( speaker in speakers )
		thread PlayDialogue( "KANE_PA_LISTEN_UP_01", speaker )

	// HACK: Workaround for the server not having the ability to GetSoundDuration().
	// This is the duration of diag_kanePa_SE_811_01_01_imc_kane.
	wait 17.5

	PlayerConversation( "BT_KaneInfo", player )
}


void function Kane_PA_BroadcastThink( entity player, string dialogLine, string waitFlag )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( waitFlag )

	PlayDialogueAtPASpeakers( dialogLine )
}


void function PA_SystemThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	array<string> dialogLines = [ "PA_WARNING_01", "PA_WARNING_02", "PA_WARNING_03", "PA_WARNING_04", "PA_WARNING_05", "PA_WARNING_06" ]

	foreach ( line in dialogLines )
	{
		FlagWait( "Sewers_Kane_PA_Line" )
		PlayDialogueAtPASpeakers( line )
		FlagClear( "Sewers_Kane_PA_Line" )
	}
}

void function PlayDialogueAtPASpeakers( string dialogLine )
{
	// The sound events will only play the nearest speakers so we can safely play on all of them without distance checks.
	foreach( speaker in file.PASpeakers )
		thread PlayDialogue( dialogLine, speaker )
}


// -------------------------------------------------------------------------------------------------------------------------
//
// ███╗   ███╗██╗███████╗ ██████╗
// ████╗ ████║██║██╔════╝██╔════╝
// ██╔████╔██║██║███████╗██║
// ██║╚██╔╝██║██║╚════██║██║
// ██║ ╚═╝ ██║██║███████║╚██████╗
// ╚═╝     ╚═╝╚═╝╚══════╝ ╚═════╝
//
// -------------------------------------------------------------------------------------------------------------------------
void function DisableDoomFX( entity titan, float delay = 0.0 )
{
	titan.EndSignal( "OnDestroy" )

	if ( delay >= 0.0 )
		wait delay

	int eHandle = titan.GetEncodedEHandle()
	array<entity> players = GetPlayerArray()
	foreach ( player in players )
		Remote_CallFunction_Replay( player, "ServerCallback_SewersHideDoomFX", eHandle )
}


void function SewersSpecialThink()
{
	while( 1 )
	{
		FlagClear( "Sewers_special_trigger_4" )
		WaitFrame()

		FlagWait( "Sewers_special_trigger_4" )

		if ( !Flag( "Sewers_special_trigger_1" ) )
			continue
		if ( !Flag( "Sewers_special_trigger_2" ) )
			continue
		if ( !Flag( "Sewers_special_trigger_3" ) )
			continue

		array<entity> players = GetPlayerArray()

		if ( players.len() <= 0 )
			return

		entity player = players[0]

		if ( !IsValid( player ) )
			continue

		TeleportPlayerAndBT( "Sewers_special_target_spot" )
		wait 2.0
		FlagSet( "Sewers_special_turn_around" )
		wait 4.0
		TeleportPlayerAndBT( "Sewers_special_return_spot" )

		return
	}
}


void function Sewers_CleanupNPCsOnFlag( entity player, string flag )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( flag )

	array<entity> npcs = GetNPCArray()
	
	array<entity> bts
	foreach( player in GetPlayerArray() )
		bts.append( player.GetPetTitan() )

	foreach( npc in npcs )
	{
		if( bts.contains( npc ) )
			continue
		
		if ( npc.IsPlayer() )
			continue

		if( npc.GetClassName() == "npc_bullseye" )
			continue

		if( npc.GetClassName() == "npc_marvin" )
			continue

		if( npc.GetClassName() == "npc_drone" )
			continue
		
		npc.Destroy()
	}
}


void function WaitTillPlayerIsDisembarked( entity player )
{
	player.EndSignal( "OnDestroy" )

	while( 1 )
	{
		if ( !player.IsTitan() )
			return

		WaitFrame()
	}
}


void function Sewers_PlayInteruptableConversation( array<entity> guys, array<string> dialogLines )
{
	OnThreadEnd(
	function() : (  )
		{
			SetGlobalForcedDialogueOnly( false )
		}
	)

	foreach( guy in guys )
	{
		guy.EndSignal( "OnStateChange" )
		guy.EndSignal( "OnNoticePotentialEnemy" )
		guy.EndSignal( "OnDeath" )
		guy.EndSignal( "OnDestroy" )
		guy.EndSignal( "OnFoundEnemy" )
		guy.EndSignal( "OnSeeEnemy" )
	}

	int guyIndex = 0
	foreach( line in dialogLines )
	{
		PlayDialogue( line, guys[ guyIndex ] )

		if( guyIndex >= guys.len() - 1 )
			guyIndex = 0
		else
			guyIndex++
	}
}


void function PlayDialogueOnClosestNPCFromPlayer( entity player, string dialogLine, int team = TEAM_UNASSIGNED, string classname = "npc_soldier" )
{
	array<entity> guys

	if ( team == TEAM_UNASSIGNED )
		guys = GetNPCArray()
	else
		guys = GetNPCArrayEx( classname, team, TEAM_ANY, player.GetOrigin(), 5000 )

	if ( guys.len() > 0 )
	{
		entity guy = GetClosest( guys, player.GetOrigin() )
		PlayDialogue( dialogLine, guy )
	}
}


// Sets up an interactive spot and returns when interacted with
void function InteractiveSpotThink( entity player, string entName, string usePrompt, string usePromptPC )
{
	player.EndSignal( "OnDestroy" )

	entity node = GetEntByScriptName( entName )
	vector origin = node.GetOrigin()
	vector angles = node.GetAngles()

	entity useDummy = CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, origin, angles, 2 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	useDummy.SetOrigin( origin )
	useDummy.SetUsable()
	useDummy.Hide()
	useDummy.SetUsableByGroup( "pilot titan" )
	useDummy.SetUsePrompts( usePrompt , usePromptPC )

	local playerActivator
	while( true )
	{
		playerActivator = useDummy.WaitSignal( "OnPlayerUse" ).player
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() )
			break
	}

	useDummy.UnsetUsable()
	useDummy.Destroy()
}


void function SquadAssaultEntity( string squadname, entity assaultEnt )
{
	if ( GetNPCSquadSize( squadname ) == 0 )
		return

	array<entity> squad = GetNPCArrayBySquad( squadname )
	if ( !IsValid( squad ) || squad.len() == 0 )
		return

	foreach ( guy in squad )
		AssaultEntity( guy, assaultEnt )
}


void function AssaultEntity( entity guy, entity target, float radius = 1024 )
{
	vector origin = target.GetOrigin()
	vector angles = target.GetAngles()
	if ( target.HasKey( "script_goal_radius" ) )
		radius = float( target.kv.script_goal_radius )

	if ( !IsValid( guy ) )
		return

	guy.AssaultPoint( origin )
	guy.AssaultSetGoalRadius( radius )

	if ( target.HasKey( "face_angles" ) && target.kv.face_angles == "1" )
		guy.AssaultSetAngles( angles, true )
}


void function TeleportBT( entity player, string titanstartName )
{
	entity bt = GetPlayerTitanInMap( player )
	entity titanref = GetEntByScriptName( titanstartName )
	bt.SetOrigin( titanref.GetOrigin() )
	bt.SetAngles( titanref.GetAngles() )
}


void function WaitUntilPercentDead( array<entity> npcs, float percentFrac )
{
	//ArrayRemoveDead( npcs )
	int totalNPCs = npcs.len()
	int numReqDead = ((totalNPCs * percentFrac) + 0.5).tointeger()
	printt( "Waiting for", numReqDead, "of", totalNPCs, "to die" )
	WaitUntilNumDead( npcs, numReqDead )

	printt( "Finished waiting for", numReqDead, "of", totalNPCs, "to die" )
}


void function WaitUntilPercentDead_WithTimeout( array<entity> npcs, float percentFrac, float timeout )
{
	//ArrayRemoveDead( npcs )
	int totalNPCs = npcs.len()
	int numReqDead = ((totalNPCs * percentFrac) + 0.5).tointeger()
	printt( "Waiting for", numReqDead, "of", totalNPCs, "to die, OR timeout:", timeout, "secs" )
	float endTime = Time() + timeout
	WaitUntilNumDeadWithTimeout( npcs, numReqDead, timeout )

	if ( Time() >= endTime )
		printt( "TIMED OUT when waiting for", numReqDead, "of", totalNPCs,"to die" )
}


void function TrackPlayerCombatState( entity player )
{
	player.EndSignal( "OnDestroy" )

	array<entity> enemies
	string currState = ""
	string lastState = "idle"

	while ( 1 )
	{
		wait 1.0

		if ( !IsAlive( player ) )
			continue

		enemies = GetNPCArray()

		ArrayRemovePlayerTeam( TEAM_MILITIA, enemies )
		ArrayRemoveDead( enemies )

		currState = "idle"

		foreach ( npc in enemies )
		{
			if ( !IsAlive( npc ) )
				continue

			if ( npc.GetNPCState() == "alert" && currState != "combat" )
				currState = "alert"
			else if ( npc.GetNPCState() == "combat" && npc.GetEnemy() == player )
				currState = "combat"

			if ( currState == "combat" )
				break
		}

		if ( currState == lastState )
			continue

		lastState = currState

		file.playerCombatState = currState
		printt( "PlayerCombatStateChanged:", currState )
		player.Signal( "PlayerCombatStateChanged" )
	}
}


void function ArrayRemovePlayerTeam( int playerTeam, array<entity> entArray )
{
	for ( int i = entArray.len() - 1; i >= 0; i-- )
	{
		if ( entArray[ i ].GetTeam() == playerTeam )
			entArray.remove( i )
	}
}


void function DeleteBT( entity player )
{
	player.EndSignal( "OnDestroy" )

	if ( player.IsTitan() )
		return

	entity bt = player.GetPetTitan()
	if ( !IsValid( bt ) )
		return

	StoreLastBTLoadout( player )
	bt.Destroy()
}


entity function SpawnBT( entity player, vector origin )
{
	if ( IsValid( player.GetPetTitan() ) )
	{
		player.GetPetTitan().SetOrigin( origin )
		return
	}

	vector angles = < 0, 0, 0 >

	TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()
	entity npcTitan = CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, origin, angles )

	SetSpawnOption_AISettings( npcTitan, "npc_titan_buddy" )
	DispatchSpawn( npcTitan )
	SetPlayerPetTitan( player, npcTitan )

	SoulTitanCore_SetNextAvailableTime( npcTitan.GetTitanSoul(), 1.0 ) // Give BT a full core for max effect

	if ( file.lastBTweaponName != "" )
	{
		TitanLoadoutDef loadout = expect TitanLoadoutDef( GetTitanLoadoutForPrimary( file.lastBTweaponName ) )
		loadout.setFile = "titan_buddy"
		TakeAllWeapons( npcTitan )
		GiveTitanLoadout( npcTitan, loadout )
	}

	return npcTitan
}


void function StoreLastBTLoadout( entity player )
{
	if ( IsValid( player.p.lastPrimaryWeaponEnt ) )
		file.lastBTweaponName = player.p.lastPrimaryWeaponEnt.GetWeaponClassName()
	else
		file.lastBTweaponName = ""
}


bool function ClientCommand_ClearOnScreenHint( entity player, array<string> args )
{
	file.clearedOnScreenLoadoutHint = true

	array<entity> players = GetPlayerArray()
	if ( players.len() > 0 )
	{
		entity player = players[0]
		ClearOnscreenHint( player )
	}

	return true
}


void function CreateTitanBodyDamagedFX( entity titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

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
	"FX_HAND_L",
	"HATCH_PANEL",
	"exp_L_shoulder",
	"exp_R_shoulder",
	"HATCH_BOLT1",
	"FX_ARM_SOCKET_R",
	"FX_ARM_SOCKET_L",
	"vent_left_front",
	"vent_right_front",
	"vent_left",
	"dam_vents",
	"exp_R_elbow",
	"exp_L_elbow",
	"exp_R_knee",
	"exp_L_knee",
	"dam_L_thigh_front",
	"dam_R_thigh_front"
	]

	while( 1 )
	{
		int attachID = titan.LookupAttachment( tags.getrandom() )

		StartParticleEffectOnEntity( titan, fx_large, FX_PATTACH_POINT_FOLLOW, attachID )
		EmitSoundOnEntity( titan, "skyway_scripted_tortureroom_bt_orange_spark" )
		wait RandomFloatRange(0.05,0.2)
	}
}


void function MakeTitanLookDamaged( entity ent )
{
	array<string> bodyGroupArray = [ "torso", "hip", "left_arm", "right_arm", "left_leg", "right_leg" ]
	foreach( bodyGroup in bodyGroupArray )
	{
		int bodyGroupIndex = ent.FindBodyGroup( bodyGroup )
		if ( bodyGroupIndex == -1 )
			continue
		ent.SetBodygroup( bodyGroupIndex, 1 )
	}
}
