untyped

global function GamemodeFD_Init
global function RateSpawnpoints_FD
global function startHarvester
global function IsHarvesterAlive
global function GetTargetNameForID

global function DisableTitanSelection
global function DisableTitanSelectionForPlayer
global function EnableTitanSelection
global function EnableTitanSelectionForPlayer
global function FD_DropshipSetAnimationOverride
global function HT_BatteryPort
global function AddCallback_RegisterCustomFDContent
global function AddFDCustomProp
global function AddFDCustomShipStart

enum eDropshipState{
	Idle,
	InProgress,
	Returning
	_count_
}

struct player_struct_fd{
	bool diedThisRound
	int assaultScoreThisRound
	int defenseScoreThisRound
	int moneyThisRound
	float lastRespawn
	float lastTitanDrop
}

global HarvesterStruct& fd_harvester
global vector shopPosition
global vector shopAngles = < 0, 0, 0 >
global vector FD_spawnPosition
global vector FD_spawnAngles = < 0, 0, 0 >
global vector FD_groundspawnPosition
global vector FD_groundspawnAngles = < 0, 0, 0 >
global vector FD_CustomHarvesterLocation = < 0, 0, 0 >
global vector FD_DefenseLocation = < 0, 0, 0 >
global array<vector> FD_DropPodSpawns = []
global table< string, array<vector> > routes
global array<entity> routeNodes
global array<entity> spawnedNPCs
global array<string> waveAnnouncement = []
global int difficultyLevel
global bool elitesAllowed
global bool titanfallblockAllowed
global bool arcTitansUsesArcCannon
global bool useCustomFDLoad

const float FD_HARVESTER_PERIMETER_DIST = 1200.0

struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<float> harvesterDamageSource
	bool harvesterWasDamaged
	bool harvesterShieldDown
	bool harvesterHalfHealth
	float harvesterDamageTaken
	table<entity, player_struct_fd> players
	table<entity, table<string, float> > playerAwardStats
	table<string, int> playerHasTitanSelectionLocked
	entity harvester_info
	bool waveRestart = false
	bool easymodeSmartPistol = false
	bool harvesterPerfectWin = true
	bool pilotPerfectWin = true
	bool titanPerfectWin = true
	bool isLiveFireMap = false
	vector harvesterLocationForRespawn = < 0, 0, 0 >
	
	string animationOverride = ""
	int dropshipState
	int playersInShip
	entity dropship
	array<entity> playersInDropship
}file

typedef LoadCustomFDContent void functionref()
array<LoadCustomFDContent> CustomFDContent

const array<string> DROPSHIP_IDLE_ANIMS_POV = [
	"ptpov_ds_coop_side_intro_gen_idle_B",
	"ptpov_ds_coop_side_intro_gen_idle_A",
	"ptpov_ds_coop_side_intro_gen_idle_C",
	"ptpov_ds_coop_side_intro_gen_idle_D"
]

const array<string> DROPSHIP_IDLE_ANIMS = [
	"pt_ds_coop_side_intro_gen_idle_B",
	"pt_ds_coop_side_intro_gen_idle_A",
	"pt_ds_coop_side_intro_gen_idle_C",
	"pt_ds_coop_side_intro_gen_idle_D"
]

const array<string> DROPSHIP_EXIT_ANIMS_POV = [
	"ptpov_ds_coop_side_intro_gen_exit_B",
	"ptpov_ds_coop_side_intro_gen_exit_A",
	"ptpov_ds_coop_side_intro_gen_exit_C",
	"ptpov_ds_coop_side_intro_gen_exit_D"
]

const array<string> DROPSHIP_EXIT_ANIMS = [
	"pt_ds_coop_side_intro_gen_exit_B",
	"pt_ds_coop_side_intro_gen_exit_A",
	"pt_ds_coop_side_intro_gen_exit_C",
	"pt_ds_coop_side_intro_gen_exit_D"
]

void function GamemodeFD_Init()
{
	PrecacheModel( MODEL_ATTRITION_BANK )
	PrecacheModel( MODEL_IMC_SHIELD_CAPTAIN )
	PrecacheModel( $"models/robots/drone_frag/drone_frag.mdl" )
	PrecacheModel( $"models/creatures/prowler/r2_prowler.mdl" )
	PrecacheParticleSystem( $"P_smokescreen_FD" )
	
	RegisterSignal( "FD_ReachedHarvester" )
	RegisterSignal( "BatteryActivate" ) //From Fort War, ported to here to make usage of the Healable Heavy Turret feature

	SetRoundBased( true )
	SetTimerBased( false ) //Disable loss by timer because the wait feature will truly idle servers until people joins
	SetShouldUseRoundWinningKillReplay( false )
	SetKillcamsEnabled( false ) //Only disabling Killcams because it's PvE
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	PlayerEarnMeter_SetEnabled( false )
	SetAllowLoadoutChangeFunc( FD_ShouldAllowChangeLoadout )
	SetGetDifficultyFunc( FD_GetDifficultyLevel )
	
	//Live Fire map check
	if( GetMapName().find( "mp_lf_" ) == null )
	{
		SetShouldUsePickLoadoutScreen( true )
		TeamTitanSelectMenu_Init() // show the titan select menu in this mode
	}
	else
		file.isLiveFireMap = true

	//General Callbacks
	AddCallback_EntitiesDidLoad( LoadEntities )
	AddCallback_GameStateEnter( eGameState.Prematch, FD_createHarvester )
	AddCallback_GameStateEnter( eGameState.Playing, StartFDMatch )
	AddCallback_OnRoundEndCleanup( FD_WaveCleanup )
	AddCallback_OnClientConnected( GamemodeFD_InitPlayer )
	AddCallback_OnClientDisconnected( OnPlayerDisconnectedOrDestroyed )
	AddCallback_OnPlayerGetsNewPilotLoadout( FD_OnPlayerGetsNewPilotLoadout )
	ClassicMP_SetEpilogue( FD_SetupEpilogue )
	AddOnRodeoStartedCallback( FD_PilotStartRodeo )
	AddOnRodeoEndedCallback( FD_PilotEndRodeo )

	//Damage Callbacks
	AddDamageByCallback( "player", FD_DamageByPlayerCallback )
	AddDamageCallback( "player", DamageScaleByDifficulty )
	AddDamageCallback( "npc_titan", DamageScaleByDifficulty )
	AddDamageCallback( "npc_turret_sentry", DamageScaleByDifficulty )
	AddDamageCallback( "npc_turret_sentry", RevivableTurret_DamageCallback )
	AddDamageCallback( "npc_turret_mega", HeavyTurret_DamageCallback )
	AddDamageFinalCallback( "npc_titan", FD_DamageToMoney )
	
	//Spawn Callbacks
	AddSpawnCallback( "npc_titan", HealthScaleByDifficulty )
	AddSpawnCallback( "npc_titan", SpawnCallback_SafeTitanSpawnTime )
	AddSpawnCallback( "npc_super_spectre", HealthScaleByDifficulty )
	AddSpawnCallback( "npc_frag_drone", OnTickSpawn )
	AddCallback_OnPlayerRespawned( FD_PlayerRespawnCallback )
	AddCallback_OnPlayerRespawned( SpawnCallback_SafeTitanSpawnTime )
	AddSpawnCallback( "npc_turret_sentry", AddTurretSentry )
	AddTurretRepairCallback( IncrementPlayerstat_TurretRevives )
	
	//Death Callbacks
	AddCallback_OnNPCKilled( OnNpcDeath )
	AddCallback_NPCLeeched( OnNPCLeechedFD )
	AddCallback_OnPlayerKilled( GamemodeFD_OnPlayerKilled )
	AddDeathCallback( "npc_frag_drone", OnTickDeath ) // ticks dont come up in the other callback because of course they dont

	//Command Callbacks
	AddClientCommandCallback( "FD_ToggleReady", ClientCommandCallbackToggleReady )
	AddClientCommandCallback( "FD_UseHarvesterShieldBoost", useShieldBoost )
	AddClientCommandCallback( "FD_SetTutorialBit", ClientCommand_FDSetTutorialBit )
	AddClientCommandCallback( "dropbattery", ClientCommandCallbackFDDropBattery )

	//Shop Callback
	SetBoostPurchaseCallback( FD_BoostPurchaseCallback )
	SetTeamReserveInteractCallback( FD_TeamReserveDepositOrWithdrawCallback )

	//Data Collection
	AddStunLaserHealCallback( FD_StunLaserHealTeammate )
	SetApplyBatteryCallback( FD_BatteryHealTeammate )
	AddSmokeHealCallback( FD_SmokeHealTeammate )
	SetUsedCoreCallback( FD_UsedCoreCallback )

	//Score Event
	AddArcTrapTriggeredCallback( FD_OnArcTrapTriggered )
	AddArcWaveDamageCallback( FD_OnArcWaveDamage )
	AddOnTetherCallback( FD_OnTetherTrapTriggered )
	AddSonarStartCallback( FD_OnSonarStart )
	ScoreEvent_SetupEarnMeterValuesForFrontierDefense()
	
	difficultyLevel = FD_GetDifficultyLevel() //Refresh this only on map load, to avoid midgame commands messing up with difficulties (i.e setting mp_gamemode fd_hard midgame in a regular match through console on local host would immediately make Stalkers spawns with EPG)
	elitesAllowed = GetConVarBool( "ns_fd_allow_elite_titans" )
	titanfallblockAllowed = GetConVarBool( "ns_fd_allow_titanfall_block" )
	arcTitansUsesArcCannon = GetConVarBool( "ns_fd_arc_titans_uses_arc_cannon" )
	file.easymodeSmartPistol = GetConVarBool( "ns_fd_easymode_smartpistol" )
	SetupGruntSpectreWeapons()
	
	for( int i = 0; i < 20; i++ ) //Setup NPC array for Harvester Damage tracking
		file.harvesterDamageSource.append(0.0)
	
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
			SetAILethality( eAILethality.VeryLow )
			break
		case eFDDifficultyLevel.NORMAL:
			SetAILethality( eAILethality.Low )
			break
		case eFDDifficultyLevel.HARD:
			SetAILethality( eAILethality.Medium )
			break
		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:
			SetAILethality( eAILethality.High )
			break
	}
}

void function ScoreEvent_SetupEarnMeterValuesForFrontierDefense()
{
	ScoreEvent_SetEarnMeterValues( "FDAirDroneKilled", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "FDGruntKilled", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "FDSpectreKilled", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "FDStalkerKilled", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "FDSuperSpectreKilled", 0.0, 0.1 )
	ScoreEvent_SetEarnMeterValues( "Execution", 0.0, 0.1 )
	ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.35 )
	ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 )
	ScoreEvent_SetEarnMeterValues( "LeechSpectre", 0.0, 0.1 )
	
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDAirDroneKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDGruntKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDSpectreKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDStalkerKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDSuperSpectreKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "LeechSpectre" ), eEventDisplayType.MEDAL )
	
	ScoreEvent_SetXPValueWeapon( GetScoreEvent( "Mayhem" ), 1 )
	ScoreEvent_SetXPValueWeapon( GetScoreEvent( "Onslaught" ), 1 )
	ScoreEvent_SetXPValueWeapon( GetScoreEvent( "FDTitanKilled" ), 1 )
	ScoreEvent_SetXPValueTitan( GetScoreEvent( "FDTitanKilled" ), 1 )
	ScoreEvent_SetXPValue( GetScoreEvent( "FDTitanKilled" ), 1 )
	ScoreEvent_SetXPValue( GetScoreEvent( "MatchVictory" ), 1 )
	ScoreEvent_SetXPValue( GetScoreEvent( "MatchComplete" ), 1 )
	
	ScoreEvent_Disable( GetScoreEvent( "KillGrunt" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillDrone" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillDropship" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillProwler" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillSpectre" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillStalker" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillSuperSpectre" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillTitan" ) )
	ScoreEvent_Disable( GetScoreEvent( "KillPilot" ) )
	ScoreEvent_Disable( GetScoreEvent( "TitanKillTitan" ) )
	ScoreEvent_Disable( GetScoreEvent( "LeechDrone" ) )
}

void function UpdateEarnMeter_ByPlayersInMatch()
{
	WaitFrame() //Waitframe because i have no idea why it doesn't update properly in the frame a player leaves
	array<entity> numplayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
	
	switch( numplayers.len() )
	{
		case 1:
			ScoreEvent_SetEarnMeterValues( "FDAirDroneKilled", 0.0, 0.4 )
			ScoreEvent_SetEarnMeterValues( "FDGruntKilled", 0.0, 0.4 )
			ScoreEvent_SetEarnMeterValues( "FDSpectreKilled", 0.0, 0.4 )
			ScoreEvent_SetEarnMeterValues( "FDStalkerKilled", 0.0, 0.4 )
			ScoreEvent_SetEarnMeterValues( "FDSuperSpectreKilled", 0.0, 0.85 )
			ScoreEvent_SetEarnMeterValues( "Execution", 0.0, 1.0 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 1.0 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 1.0 )
			break
		case 2:
			ScoreEvent_SetEarnMeterValues( "FDAirDroneKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDGruntKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDSpectreKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDStalkerKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDSuperSpectreKilled", 0.0, 0.5 )
			ScoreEvent_SetEarnMeterValues( "Execution", 0.0, 0.8 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.8 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.8 )
			break
		case 3:
			ScoreEvent_SetEarnMeterValues( "FDAirDroneKilled", 0.0, 0.1 )
			ScoreEvent_SetEarnMeterValues( "FDGruntKilled", 0.0, 0.1 )
			ScoreEvent_SetEarnMeterValues( "FDSpectreKilled", 0.0, 0.1 )
			ScoreEvent_SetEarnMeterValues( "FDStalkerKilled", 0.0, 0.1 )
			ScoreEvent_SetEarnMeterValues( "FDSuperSpectreKilled", 0.0, 0.2 )
			ScoreEvent_SetEarnMeterValues( "Execution", 0.0, 0.2 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.5 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.5 )
			break
		default:
			ScoreEvent_SetEarnMeterValues( "FDAirDroneKilled", 0.0, 0.05 )
			ScoreEvent_SetEarnMeterValues( "FDGruntKilled", 0.0, 0.05 )
			ScoreEvent_SetEarnMeterValues( "FDSpectreKilled", 0.0, 0.05 )
			ScoreEvent_SetEarnMeterValues( "FDStalkerKilled", 0.0, 0.05 )
			ScoreEvent_SetEarnMeterValues( "FDSuperSpectreKilled", 0.0, 0.1 )
			ScoreEvent_SetEarnMeterValues( "Execution", 0.0, 0.1 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.35 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 )
	}
}

void function AddCallback_RegisterCustomFDContent( LoadCustomFDContent callback )
{
	CustomFDContent.append( callback )
}

void function AddFDCustomProp( asset modelasset, vector origin, vector angles )
{
	entity prop = CreatePropScript( modelasset, origin, angles, 6 )
	ToggleNPCPathsForEntity( prop, false )
	prop.SetAIObstacle( true )
	prop.SetTakeDamageType( DAMAGE_NO )
	prop.SetScriptPropFlags( SPF_DISABLE_CAN_BE_MELEED | SPF_BLOCKS_AI_NAVIGATION | SPF_CUSTOM_SCRIPT_3 )
}

void function AddFDCustomShipStart( vector origin, vector angles, int team )
{
	entity shipspawn = CreateEntity( "info_spawnpoint_dropship_start" )
	shipspawn.SetOrigin( origin )
	shipspawn.SetAngles( angles )
	SetTeam( shipspawn, team )
	DispatchSpawn( shipspawn )
}

void function LoadEntities()
{
	CreateBoostStoreLocation( TEAM_MILITIA, shopPosition, shopAngles )
	
	foreach ( callback in CustomFDContent )
		callback()
	
	foreach ( entity info_target in GetEntArrayByClass_Expensive( "info_target" ) )
	{
		if ( GameModeRemove( info_target ) )
			continue

		if( info_target.HasKey( "editorclass" ) )
		{
			switch( info_target.kv.editorclass )
			{
				case "info_fd_harvester":
					file.harvester_info = info_target
					file.harvesterLocationForRespawn = info_target.GetOrigin()
					break
				case "info_fd_mode_model":
					entity prop = CreatePropScript( info_target.GetModelName(), info_target.GetOrigin(), info_target.GetAngles(), 6 )
					ToggleNPCPathsForEntity( prop, false )
					prop.SetAIObstacle( true )
					prop.SetTakeDamageType( DAMAGE_NO )
					prop.SetScriptPropFlags( SPF_DISABLE_CAN_BE_MELEED | SPF_BLOCKS_AI_NAVIGATION )
					break
				case "info_fd_ai_position":
					AddStationaryAIPosition( info_target.GetOrigin(), int( info_target.kv.aiType ) )
					break
				case "info_fd_route_node":
					routeNodes.append( info_target )
					break
				case "info_fd_smoke_screen":
					file.smokePoints.append( info_target )
					break
			}
		}
	}
	
	if( file.harvester_info == null )
	{
		entity harvester_loc = CreateInfoTarget( FD_CustomHarvesterLocation, < 0, 0, 0 > )
		file.harvester_info = harvester_loc
	}
	
	else if( useCustomFDLoad && FD_CustomHarvesterLocation != < 0, 0, 0 > )
	{
		file.harvester_info.SetOrigin( FD_CustomHarvesterLocation )
		file.harvesterLocationForRespawn = FD_CustomHarvesterLocation
	}
	
	ValidateAndFinalizePendingStationaryPositions()
	initNetVars()
	SetTeam( GetTeamEnt( TEAM_IMC ), TEAM_IMC )
}

void function initNetVars()
{
	SetGlobalNetInt( "FD_totalWaves", waveEvents.len() )
	if( !file.isLiveFireMap )
		SetGlobalNetInt( "burn_turretLimit", 2 )
	else
	{
		SetGlobalNetBool( "titanEjectEnabled", false ) //Disable ejection for Helper Titan
		SetGlobalNetInt( "burn_turretLimit", 3 ) //Live Fire maps are brutal with spawns so, good to have more turrets
	}
		
	if( !FD_HasRestarted() )
	{
		bool showShop = false
		SetGlobalNetInt( "FD_currentWave", WAVE_STATE_NONE )
		if( FD_IsDifficultyLevelOrHigher( eFDDifficultyLevel.INSANE ) )
			FD_SetNumAllowedRestarts( 0 )
		else
			FD_SetNumAllowedRestarts( 2 )
	}
}











/* Main Gamemode Flow
███    ███  █████  ██ ███    ██      ██████   █████  ███    ███ ███████ ███    ███  ██████  ██████  ███████     ███████ ██       ██████  ██     ██ 
████  ████ ██   ██ ██ ████   ██     ██       ██   ██ ████  ████ ██      ████  ████ ██    ██ ██   ██ ██          ██      ██      ██    ██ ██     ██ 
██ ████ ██ ███████ ██ ██ ██  ██     ██   ███ ███████ ██ ████ ██ █████   ██ ████ ██ ██    ██ ██   ██ █████       █████   ██      ██    ██ ██  █  ██ 
██  ██  ██ ██   ██ ██ ██  ██ ██     ██    ██ ██   ██ ██  ██  ██ ██      ██  ██  ██ ██    ██ ██   ██ ██          ██      ██      ██    ██ ██ ███ ██ 
██      ██ ██   ██ ██ ██   ████      ██████  ██   ██ ██      ██ ███████ ██      ██  ██████  ██████  ███████     ██      ███████  ██████   ███ ███  
*/

void function FD_createHarvester()
{
	AllPlayersUnMuteAll()
	fd_harvester = SpawnHarvester( file.harvester_info.GetOrigin(), file.harvester_info.GetAngles(), GetCurrentPlaylistVarInt( "fd_harvester_health", 25000 ), GetCurrentPlaylistVarInt( "fd_harvester_shield", 6000 ), TEAM_MILITIA )
	SetGlobalNetEnt( "FD_activeHarvester", fd_harvester.harvester )
	fd_harvester.harvester.Minimap_SetAlignUpright( true )
	fd_harvester.harvester.Minimap_AlwaysShow( TEAM_IMC, null )
	fd_harvester.harvester.Minimap_AlwaysShow( TEAM_MILITIA, null )
	fd_harvester.harvester.Minimap_SetHeightTracking( true )
	fd_harvester.harvester.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	fd_harvester.harvester.Minimap_SetCustomState( eMinimapObject_prop_script.FD_HARVESTER )
	fd_harvester.harvester.SetTakeDamageType( DAMAGE_EVENTS_ONLY )
	ToggleNPCPathsForEntity( fd_harvester.harvester, false )
	fd_harvester.harvester.SetAIObstacle( true )
	fd_harvester.harvester.SetScriptPropFlags( SPF_DISABLE_CAN_BE_MELEED | SPF_BLOCKS_AI_NAVIGATION )
	fd_harvester.harvester.SetNoTarget( true )
	AddEntityCallback_OnPostShieldDamage( fd_harvester.harvester, HarvesterShieldInvulnCheck )
	AddEntityCallback_OnDamaged( fd_harvester.harvester, OnHarvesterDamaged )
	thread MonitorHarvesterProximity( fd_harvester.harvester )
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_NONE )
	
	SetPlayerDeathsHidden( false )
	if( !file.waveRestart )
		EnableTitanSelection()
	else
		SetGlobalNetInt( "FD_waveState", WAVE_STATE_BREAK )
	
	if( !file.isLiveFireMap )
		SetShouldUsePickLoadoutScreen( true ) //Re-enable it here to midgame joiners pick their Titans
	
	//Some maps have sky battles happening on them
	switch( GetMapName() )
	{
		case "mp_angel_city":
		case "mp_homestead":
		case "mp_colony02":
		case "mp_thaw":
		case "mp_relic02":
		case "mp_crashsite3":
		case "mp_forwardbase_kodai":
		case "mp_black_water_canal":
			thread StratonHornetDogfights()
			break
		case "mp_eden":
		case "mp_complex3":
			thread StratonHornetDogfightsIntense()
	}
}

void function StartFDMatch()
{
	// only start the highlight when we start playing, not during dropship
	foreach ( entity player in GetPlayerArray() )
		Highlight_SetFriendlyHighlight( player, "sp_friendly_hero" )

	thread mainGameLoop()
}

void function mainGameLoop()
{
	float warntime
	while( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() <= GetConVarInt( "ns_fd_min_numplayers_to_start" ) - 1 )
	{
		if( Time() > warntime )
		{
			ShowWaitingForMorePlayers()
			warntime = Time() + 45.0
		}
		WaitFrame()
	}
	
	startHarvester()
	int waveNumber = GetGlobalNetInt( "FD_currentWave" )
	
	if( !file.waveRestart )
	{
		if ( waveNumber == 0 && GetCurrentPlaylistVarFloat( "riff_minimap_state", 0 ) == 0 && !file.isLiveFireMap )
		{
			wait 14
			PlayFactionDialogueToTeam( "fd_minimapTip" , TEAM_MILITIA )
			wait 14
		}
		
		else //Still wait 14 seconds to let them to speak about the Harvester being up and running on first wave
			wait 14
	}

	thread FD_AlivePlayersMonitor()
	bool showShop = false
	for( int i = GetGlobalNetInt( "FD_currentWave" ); i < waveEvents.len(); i++ )
	{
		//Wait per wave as well
		while( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() <= GetConVarInt( "ns_fd_min_numplayers_to_start" ) - 1 )
		{
			if( Time() > warntime )
			{
				ShowWaitingForMorePlayers()
				warntime = Time() + 45.0
			}
			WaitFrame()
		}
		
		if( file.waveRestart )
		{
			if( waveNumber > 0 )
				showShop = true
			file.dropshipState = eDropshipState.Idle //In case we get a wave restart and the dropship didn't complete animation previously
			
			foreach( entity player in GetPlayerArray() )
			{
				SetMoneyForPlayer( player, file.players[player].moneyThisRound )
				player.SetPlayerNetInt( "numHarvesterShieldBoost", 0 )
				player.SetPlayerNetInt( "numSuperRodeoGrenades", 0 )
				PlayerInventory_TakeAllInventoryItems( player )
				PlayerEarnMeter_Reset( player )
			}
			SetGlobalNetTime( "FD_nextWaveStartTime", Time() + GetCurrentPlaylistVarFloat( "fd_wave_buy_time", 60 ) )
			thread FD_AttemptToRepairTurrets()
			
			wait 1
			
			if( !file.isLiveFireMap && waveNumber > 0 )
			{
				PlayerEarnMeter_SetEnabled( true )
				foreach( entity player in GetPlayerArray() )
				{
					PlayerEarnMeter_SetMode( player, 1 )
					PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
				}
			}
		}

		if( !runWave( i, showShop ) )
			break

		if( i == 0 )
		{
			showShop = true
			if( !file.isLiveFireMap )
			{
				PlayerEarnMeter_SetEnabled( true )
				foreach( entity player in GetPlayerArray() )
				{
					PlayerEarnMeter_SetMode( player, 1 ) // show the earn meter
					PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
					//Play twice in a row to not make its volume so subtle
					EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_TitanSelected" )
					EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_TitanSelected" )
				}
				DisableTitanSelection()
				PlayFactionDialogueToTeam( "fd_titanReadyNag", TEAM_MILITIA )
				wait 5
			}
		}
	}
}

bool function runWave( int waveIndex, bool shouldDoBuyTime )
{
	SetGlobalNetInt( "FD_currentWave", waveIndex )
	file.harvesterWasDamaged = false
	int highestScore
	entity highestScore_player
	SetEnemyAmountNetVars( waveIndex )

	for( int i = 0; i < 20; i++ )//Number of npc type ids
		file.harvesterDamageSource[i] = 0

	foreach( entity player in GetPlayerArray() )
	{
		file.players[player].diedThisRound = false
		file.players[player].assaultScoreThisRound = 0
		file.players[player].defenseScoreThisRound = 0
		file.players[player].moneyThisRound = GetPlayerMoney( player )
	}
	array<int> enemys = getHighestEnemyAmountsForWave( waveIndex )

	if( waveIndex > 0 )
	{
		foreach( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_AnnouncePreParty", enemys[0], enemys[1], enemys[2], enemys[3], enemys[4], enemys[5], enemys[6], enemys[7], enemys[8] )
	}
	
	if( waveIndex < waveAnnouncement.len() && waveAnnouncement[waveIndex] != "" && !file.waveRestart )
	{
		PlayFactionDialogueToTeam( waveAnnouncement[waveIndex], TEAM_MILITIA )
		if( waveIndex == 0 )
			wait 5
	}
	if( file.waveRestart )
	{
		file.waveRestart = false
		MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_WaveRestart )
	}
	
	if( shouldDoBuyTime )
	{
		print( "Opening Shop" )
		SetGlobalNetInt( "FD_waveState", WAVE_STATE_BREAK )
		OpenBoostStores()
		entity parentCrate = GetBoostStores()[0].GetParent()
		parentCrate.Minimap_AlwaysShow( TEAM_MILITIA, null )
		Minimap_PingForTeam( TEAM_MILITIA, shopPosition, 150, 5, TEAM_COLOR_YOU / 255.0, 5 )
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_NotifyStoreOpen" )
			player.s.extracashnag = Time() + 30
		}
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_IMC ) )
			player.SetPlayerNetBool( "FD_readyForNextWave", true )
		
		while( Time() < GetGlobalNetTime( "FD_nextWaveStartTime" ) )
		{
			if( allPlayersReady() )
				SetGlobalNetTime( "FD_nextWaveStartTime", Time() )
			WaitFrame()
		}
		wait 0.6
		MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_StoreClosing )
		print( "Closing Shop" )
		wait 4
		parentCrate.Minimap_Hide( TEAM_MILITIA, null )
		CloseBoostStores()
	}
	else if ( waveIndex > 0 )
	{
		SetGlobalNetInt( "FD_waveState", WAVE_STATE_BREAK )
		SetGlobalNetTime( "FD_nextWaveStartTime", Time() + 15.0 )
		wait 15
	}
	
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_INCOMING )
	EarnMeterMP_SetPassiveMeterGainEnabled( true )
	foreach( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FD_ClearPreParty" )
		player.SetPlayerNetBool( "FD_readyForNextWave", false )
		if ( file.isLiveFireMap )
			Disembark_Disallow( player )
	}
	SetGlobalNetBool( "FD_waveActive", true )
	FD_UpdateTitanBehavior()
	
	//Droz & Dravis should be mentioning when waves are starting
	if ( waveIndex == 0 )
	{
		foreach( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_AnnouncePreParty", enemys[0], enemys[1], enemys[2], enemys[3], enemys[4], enemys[5], enemys[6], enemys[7], enemys[8] )
			
		PlayFactionDialogueToTeam( "fd_firstWaveStartPrefix" , TEAM_MILITIA )
	}
	else if ( isFinalWave() )
		PlayFactionDialogueToTeam( "fd_finalWaveStartPrefix" , TEAM_MILITIA )
	else
		PlayFactionDialogueToTeam( "fd_newWaveStartPrefix" , TEAM_MILITIA )
		
	MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_AnnounceWaveStart )

	wait 10
	
	if ( waveIndex == 0 )
	{
		foreach( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_ClearPreParty" )
	}
	
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_IN_PROGRESS )
	executeWave()
	
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_COMPLETE )
	EarnMeterMP_SetPassiveMeterGainEnabled( false )
	foreach( entity player in GetPlayerArray() )
	{
		player.s.didthepvpglitch = false //Clear the pvp flag after wave completion
		player.s.isbeingmonitored = false
		if ( file.isLiveFireMap )
			Disembark_Allow( player )
	}
	
	if( !IsHarvesterAlive( fd_harvester.harvester ) )
	{
		print( "Stopping Wave, Harvester Died" )
		SetGlobalNetBool( "FD_waveActive", false )
		float totalDamage = 0.0
		array<float> highestDamage = [ 0.0, 0.0, 0.0 ]
		array<int> highestDamageSource = [ -1, -1, -1 ]
		foreach( index, float damage in file.harvesterDamageSource )
		{
			totalDamage += damage
			if( highestDamage[0] < damage )
			{
				highestDamage[2] = highestDamage[1]
				highestDamageSource[2] = highestDamageSource[1]
				highestDamage[1] = highestDamage[0]
				highestDamageSource[1] = highestDamageSource[0]
				highestDamageSource[0] = index
				highestDamage[0] = damage
			}
			else if( highestDamage[1] < damage )
			{
				highestDamage[2] = highestDamage[1]
				highestDamageSource[2] = highestDamageSource[1]
				highestDamage[1] = damage
				highestDamageSource[1] = index
			}
			else if( highestDamage[2] < damage )
			{
				highestDamage[2] = damage
				highestDamageSource[2] = index
			}
		}
		
		if( waveIndex > 0 && !file.isLiveFireMap )
			SetShouldUsePickLoadoutScreen( false ) //Prevent loadout screen from appearing again post Wave 1 completion

		if( GetGlobalNetInt( "FD_restartsRemaining" ) > 0 )
		{
			PlayFactionDialogueToTeam( "fd_baseDeath", TEAM_MILITIA )
			foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_FD_DisplayHarvesterKiller", GetGlobalNetInt( "FD_restartsRemaining" ), getHintForTypeId( highestDamageSource[0] ), highestDamageSource[0], highestDamage[0] / totalDamage, highestDamageSource[1], highestDamage[1] / totalDamage , highestDamageSource[2], highestDamage[2] / totalDamage )
				player.SetNoTarget( true )
				player.SetInvulnerable()
			}
		}
		else
		{
			SetRoundBased(false)
			print( "Finishing match, no more retries left" )
			RegisterPostSummaryScreenForMatch( false )
		}
		
		file.waveRestart = true //wave restart point
		SetWinner( TEAM_IMC )//restart round
		spawnedNPCs = [] // reset npcs count
		restetWaveEvents()
		SetPlayerDeathsHidden( true )
		
		if( GetGlobalNetInt( "FD_restartsRemaining" ) == 0 ) //This Dialogue only plays if its called after SetWinner function, because the auto-play Faction Dialogue from DialoguePlayWinnerDetermined() in _gamestate_mp
			PlayFactionDialogueToTeam( "fd_matchDefeat" , TEAM_MILITIA )
		
		wait 8
		if( GetGlobalNetInt( "FD_restartsRemaining" ) > 0 )
		{
			FD_DecrementRestarts() //Decrement restarts in here to avoid issues
			foreach( entity player in GetPlayerArray() )
			{
				Highlight_ClearFriendlyHighlight( player ) //Clear Highlight for dropship animation
				PlayerEarnMeter_Reset( player )
				ClearTitanAvailable( player )
				player.ClearInvulnerable()
				player.SetNoTarget( false )
				player.ClearParent() //Dropship parenting causes observer mode crash
				if ( IsAlive( player ) && player.IsTitan() )
					player.Die()
			}
		}
		
		return false
	}

	wait 1
	
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( file.players[player].assaultScoreThisRound > 0 )
		{
			AddPlayerScore( player, "FDDamageBonus", null, "", file.players[player].assaultScoreThisRound )
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, file.players[player].assaultScoreThisRound )
			UpdatePlayerScoreboard( player )
		}
	}
	
	wait 1
	
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( file.players[player].defenseScoreThisRound > 0 )
		{
			AddPlayerScore( player, "FDSupportBonus", null, "", file.players[player].defenseScoreThisRound )
			player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, file.players[player].defenseScoreThisRound )
			UpdatePlayerScoreboard( player )
		}
	}
	
	wait 1
	//wave end
	
	SetGlobalNetBool( "FD_waveActive", false )
	FD_UpdateTitanBehavior()
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		player.s.completedwaves++
		
	if ( isFinalWave() && IsHarvesterAlive( fd_harvester.harvester ) )
	{
		//Game won code
		print( "No more pending Waves, match won" )
		
		if( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() )
		{
			highestScore = 0
			highestScore_player = GetPlayerArrayOfTeam( TEAM_MILITIA )[0]
		}
		
		else
		{
			SetRoundBased( false )
			SetWinner( TEAM_MILITIA )
			return true
		}
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( !file.players[player].diedThisRound )
				AddPlayerScore( player, "FDDidntDie" )
		}
		
		SetRoundBased(false)
		SetWinner(TEAM_MILITIA)
		PlayFactionDialogueToTeam( "fd_matchVictory", TEAM_MILITIA )
		
		wait 1
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			AddPlayerScore( player, "FDTeamWave" )
		
		wait 1
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( highestScore < ( file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound ) )
			{
				highestScore = file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound
				highestScore_player = player
			}
		}
		if( highestScore_player in file.playerAwardStats )
			file.playerAwardStats[highestScore_player]["mvp"] += 1.0
		AddPlayerScore( highestScore_player, "FDWaveMVP" )
		
		wait 1
		
		if( !file.harvesterWasDamaged )
		{
			foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
				AddPlayerScore( player, "FDTeamFlawlessWave" )
		}
		
		wait 1
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			AddPlayerScore( player, "FDTeamFinalWave" )
			
		wait 1
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			AddPlayerScore( player, "MatchVictory" )
			
		wait 1
		
		RegisterPostSummaryScreenForMatch( true )
		
		return true
	}
	
	MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_AnnounceWaveEnd )
	
	wait 2
	
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		UpdatePlayerStat( player, "fd_stats", "wavesComplete" )
		if( player.s.completedwaves == 3 )
			AddPlayerScore( player, "ChallengeFD" )
	}

	if(!file.harvesterWasDamaged)
		PlayFactionDialogueToTeam( "fd_waveRecapPerfect", TEAM_MILITIA )
	else
	{
		float damagepercent = ( ( file.harvesterDamageTaken / fd_harvester.harvester.GetMaxHealth().tofloat() ) * 100 )
		float healthpercent = ( ( fd_harvester.harvester.GetHealth().tofloat() / fd_harvester.harvester.GetMaxHealth() ) * 100 )
		if ( damagepercent < 5 ) // if less than 5% damage taken
			PlayFactionDialogueToTeam( "fd_waveRecapNearPerfect", TEAM_MILITIA )
		else if ( healthpercent < 15 ) // if less than 15% health remains and more than 5% damage taken
			PlayFactionDialogueToTeam( "fd_waveRecapLowHealth", TEAM_MILITIA )
		else
			PlayFactionDialogueToTeam( "fd_waveVictory", TEAM_MILITIA )
	}

	wait 5

	//Player scoring
	MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_NotifyWaveBonusIncoming )
	wait 2
	
	print( "Trying to repair turrets during wave break" )
	thread FD_AttemptToRepairTurrets()
	
	print( "Showing Player Stats: Wave Complete" )
	SetJoinInProgressBonus( GetCurrentPlaylistVarInt( "fd_money_per_round", 600 ) )
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if ( isSecondWave() )
			PlayFactionDialogueToPlayer( "fd_wavePayoutFirst", player )
		else
			PlayFactionDialogueToPlayer( "fd_wavePayoutAddtnl", player )

		AddPlayerScore( player, "FDTeamWave" )
		if( !file.isLiveFireMap )
			AddMoneyToPlayer( player, GetCurrentPlaylistVarInt( "fd_money_per_round", 600 ) )
		else
			AddMoneyToPlayer( player, GetCurrentPlaylistVarInt( "fd_money_per_round", 600 ) * 2 )
		UpdatePlayerScoreboard( player )
		FD_EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
		FD_EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Ticker_Loop_1P" )
	}
	wait 2
	print( "Showing Player Stats: No Deaths This Wave" )
	SetJoinInProgressBonus( 100 )
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( !file.players[player].diedThisRound )
		{
			AddPlayerScore( player, "FDDidntDie" )
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_DIDNT_DIE )
			UpdatePlayerScoreboard( player )
			if( !file.isLiveFireMap )
				AddMoneyToPlayer( player, 100 )
			else
				AddMoneyToPlayer( player, 200 )
			FD_EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
		}
	}
	wait 2
	print( "Showing Player Stats: Wave MVP" )
	SetJoinInProgressBonus( 100 )
	if( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() )
	{
		highestScore = 0
		highestScore_player = GetPlayerArrayOfTeam( TEAM_MILITIA )[0]
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( highestScore < ( file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound ) )
			{
				highestScore = file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound
				highestScore_player = player
			}
		}
		
		if( highestScore_player in file.playerAwardStats )
			file.playerAwardStats[highestScore_player]["mvp"] += 1.0
		AddPlayerScore( highestScore_player, "FDWaveMVP" )
		if( !file.isLiveFireMap )
			AddMoneyToPlayer( highestScore_player, 100 )
		else
			AddMoneyToPlayer( highestScore_player, 200 )
		highestScore_player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_MVP )
		UpdatePlayerScoreboard( highestScore_player )
		FD_EmitSoundOnEntityOnlyToPlayer( highestScore_player, highestScore_player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if ( player == highestScore_player )
				continue
			
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_NotifyMVP", highestScore_player.GetEncodedEHandle() )
		}
	}
	
	wait 2
	print( "Showing Player Stats: Flawless Defense" )
	SetJoinInProgressBonus( 100 )
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( !file.harvesterWasDamaged )
		{
			AddPlayerScore( player, "FDTeamFlawlessWave" )
			if( !file.isLiveFireMap )
				AddMoneyToPlayer( player, 100 )
			else
				AddMoneyToPlayer( player, 200 )
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_TEAM_FLAWLESS_WAVE )
			FD_EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
		}
		UpdatePlayerScoreboard( player )
	}

	wait 2
	
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		FD_EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Successful_1P" )
		StopSoundOnEntity( player, "HUD_MP_BountyHunt_BankBonusPts_Ticker_Loop_1P" )
	}
	
	wait 2

	print( "Waiting buy time" )
	if( waveIndex < waveEvents.len() )
		SetGlobalNetTime( "FD_nextWaveStartTime", Time() + GetCurrentPlaylistVarFloat( "fd_wave_buy_time", 60 ) )

	return true
}

void function FD_AlivePlayersMonitor()
{
	svGlobal.levelEnt.EndSignal( "RoundEnd" )
	
	while( true )
	{
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( IsAlive( player ) && player in file.playerAwardStats )
			{
				file.playerAwardStats[player]["longestLife"] += 1.0
				if( IsValid( GetSoulFromPlayer( player ) ) )
					file.playerAwardStats[player]["longestTitanLife"] += 1.0
			}
		}
		
		wait 1.0
	}
}

void function FD_SetupEpilogue()
{
	AddCallback_GameStateEnter( eGameState.Epilogue, FD_Epilogue )
}

void function FD_Epilogue()
{
	thread FD_Epilogue_threaded()
}

void function FD_Epilogue_threaded()
{
	table<string,entity> awardOwners
	table<string,float> awardValues
	wait 10
	foreach(entity player in GetPlayerArray() )
	{
		ScreenFadeToBlackForever( player, 6.0 )
		AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	}
	wait 2
	AllPlayersMuteAll( 4 )
	wait 5
	AllPlayersUnMuteAll()
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		MuteHalfTime( player )
		player.FreezeControlsOnServer()
		foreach( string ref in GetFDStatRefs() )
		{
			if( !( ref in awardOwners ) )
			{
				awardOwners[ref] <- player
				awardValues[ref] <- file.playerAwardStats[player][ref]
			}
			else if( awardValues[ref] < file.playerAwardStats[player][ref] )
			{
				awardOwners[ref] = player
				awardValues[ref] = file.playerAwardStats[player][ref]
			}
		}
	}
	table<entity, string> awardResults
	table<entity, float> awardResultValues

	foreach( string ref, entity player in awardOwners )
	{
		if( awardValues[ref] > GetFDStatData( ref ).validityCheckValue ) //might be >=
		{
			awardResults[player] <- ref
			awardResultValues[player] <- awardValues[ref]
		}
	}

	int gameMode = PersistenceGetEnumIndexForItemName( "gamemodes", GAMETYPE )
	int map = PersistenceGetEnumIndexForItemName( "maps", GetMapName() )
	int myIndex
	int numPlayers = GetPlayerArray().len()
	if( numPlayers > 4 ) //Cap cuz it crashes summary menu
		numPlayers = 4

	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( !( player in awardResults ) )
		{
			awardResults[player] <- "damageDealt"
			awardResultValues[player] <- file.playerAwardStats[player]["damageDealt"]
		}
	}

	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( !IsValidPlayer( player ) )
			continue

		int i = 0
		myIndex = player.GetPlayerIndex()

		player.SetPersistentVar( "postGameDataFD.gameMode", gameMode )
		player.SetPersistentVar( "postGameDataFD.map", map )
		player.SetPersistentVar( "postGameDataFD.myIndex", myIndex )
		player.SetPersistentVar( "postGameDataFD.numPlayers", numPlayers )	

		foreach( entity medalPlayer, string ref in awardResults )
		{
			if( !IsValidPlayer( medalPlayer ) )
				continue

			if( i == 4 )
				break

			int targetIndex = medalPlayer.GetPlayerIndex()

			string name = medalPlayer.GetPlayerName()
			string xuid = medalPlayer.GetUID()
			int awardId = GetFDStatData( ref ).index
			float awardValue = awardResultValues[medalPlayer]
			int suitIndex = GetPersistentSpawnLoadoutIndex( medalPlayer, "titan" )
			int playerEHandle = medalPlayer.GetEncodedEHandle()

			player.SetPersistentVar( "postGameDataFD.players[" + i + "].name", name )
			player.SetPersistentVar( "postGameDataFD.players[" + i + "].xuid", xuid )
			player.SetPersistentVar( "postGameDataFD.players[" + i + "].awardId", awardId )
			player.SetPersistentVar( "postGameDataFD.players[" + i + "].awardValue", awardValue )
			player.SetPersistentVar( "postGameDataFD.players[" + i + "].suitIndex", suitIndex )
			Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateGameStats", playerEHandle, awardId, awardValue, suitIndex )
			i++
		}
		Remote_CallFunction_NonReplay( player, "ServerCallback_ShowGameStats", Time() + 19 )
	}
	
	wait 20
	SetGameState(eGameState.Postmatch)
}











/* Player Setup
██████  ██       █████  ██    ██ ███████ ██████      ███████ ███████ ████████ ██    ██ ██████  
██   ██ ██      ██   ██  ██  ██  ██      ██   ██     ██      ██         ██    ██    ██ ██   ██ 
██████  ██      ███████   ████   █████   ██████      ███████ █████      ██    ██    ██ ██████  
██      ██      ██   ██    ██    ██      ██   ██          ██ ██         ██    ██    ██ ██      
██      ███████ ██   ██    ██    ███████ ██   ██     ███████ ███████    ██     ██████  ██      
*/

void function GamemodeFD_InitPlayer( entity player )
{
	player_struct_fd data
	data.diedThisRound = false
	file.players[player] <- data
	
	table<string, float> awardStats
	foreach( string statRef in  GetFDStatRefs() )
		awardStats[statRef] <- 0.0
	
	file.playerAwardStats[player] <- awardStats
	
	player.s.hasPermenantAmpedWeapons <- false
	player.s.extracashnag <- Time()
	player.s.completedwaves <- 0
	player.s.didthepvpglitch <- false
	player.s.isbeingmonitored <- false
	thread SetTurretSettings_threaded( player )
	
	// only start the highlight when we start playing, not during dropship
	if ( GetGameState() >= eGameState.Playing )
		Highlight_SetFriendlyHighlight( player, "sp_friendly_hero" )
	
	//Store current Aegis unlocks
	foreach ( string FDTitan in shTitanXP.titanClasses )
		player.SetPersistentVar( "previousFDUnlockPoints[" + FDTitan + "]", player.GetPersistentVarAsInt( "titanFDUnlockPoints[" + FDTitan + "]" ) )

	if( !file.isLiveFireMap )
	{
		thread TryDisableTitanSelectionForPlayerAfterDelay( player )
		
		string playerUID = player.GetUID()
		if( playerUID in file.playerHasTitanSelectionLocked ) //Prevent people from doing the server rejoin exploit to swap titans midmatch after Wave 1
		{
			player.SetPersistentVar( "activeTitanLoadoutIndex", file.playerHasTitanSelectionLocked[ playerUID ]  )
			int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )
			TitanLoadoutDef loadout = GetTitanLoadoutFromPersistentData( player, loadoutIndex )
			SetActiveTitanLoadoutIndex( player, loadoutIndex )
			SetActiveTitanLoadout( player )
			DisableTitanSelectionForPlayer( player )
		}
	}
	thread TrackDeployedArcTrapThisRound( player )
	
	thread UpdateEarnMeter_ByPlayersInMatch()
	
	if( GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_BREAK && Time() + 30.0 > GetGlobalNetTime( "FD_nextWaveStartTime" ) && GetGlobalNetTime( "FD_nextWaveStartTime" ) > Time() )
		SetGlobalNetTime( "FD_nextWaveStartTime", Time() + 40.0 )
	
	//Reset victory summary panel in here because dude just joined and prolly match havent finished
	player.SetPersistentVar( "fd_match[" + eFDXPType.WAVES_COMPLETED + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.WAVES_COMPLETED + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.RETRIES_REMAINING + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.RETRIES_REMAINING + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.WAVES_ATTEMPTED + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.WAVES_ATTEMPTED + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.PERFECT_COMPOSITION + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.PERFECT_COMPOSITION + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.EASY_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.EASY_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.NORMAL_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.NORMAL_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.HARD_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.HARD_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.MASTER_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.MASTER_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_match[" + eFDXPType.INSANE_VICTORY + "]", 0 )
	player.SetPersistentVar( "fd_count[" + eFDXPType.INSANE_VICTORY + "]", 0 )
	player.SetPersistentVar( "isPostGameScoreboardValid", true )
	player.SetPersistentVar( "isFDPostGameScoreboardValid", false )
	if( difficultyLevel >= eFDDifficultyLevel.INSANE )
	{
		player.SetPersistentVar( "fd_match[" + eFDXPType.RETRIES_REMAINING + "]", 0 )
		player.SetPersistentVar( "fd_count[" + eFDXPType.RETRIES_REMAINING + "]", 0 )
	}
	
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.HARVESTER, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.ARC_TRAP, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.SENTRY_TURRET, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.CORE_OVERLOAD, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.WAVE_BREAK, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.FRONTIER_DEFENSE, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.HARD_DIFFICULTY, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.MASTER_DIFFICULTY, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.INSANE_DIFFICULTY, 0 )
}

void function OnPlayerDisconnectedOrDestroyed( entity player )
{
	if( file.playersInDropship.contains( player ) )
		file.playersInDropship.fastremovebyvalue( player )
	
	if ( player in file.playerAwardStats ) //Clear out disconnecting players so the postcards don't show less than 4 when server has more than 4 slots
		delete file.playerAwardStats[player]
	
	foreach ( entity npc in GetNPCArray() )
	{
		entity BossPlayer = npc.GetBossPlayer()
		if ( IsValidPlayer( BossPlayer ) && IsValid( npc ) && npc.GetTeam() == TEAM_MILITIA && ( IsMinion( npc ) || IsFragDrone( npc ) ) )
			npc.Die()
	}
}

bool function FD_ShouldAllowChangeLoadout( entity player )
{
	return ( !GetGlobalNetBool( "FD_waveActive" ) || player.GetTeam() == TEAM_IMC )
}

void function FD_OnPlayerGetsNewPilotLoadout( entity player, PilotLoadoutDef loadout )
{
	if( GetCurrentPlaylistVarInt( "fd_at_unlimited_ammo", 1 ) && !file.isLiveFireMap )
		FD_GivePlayerInfiniteAntiTitanAmmo( player )
	
	if( difficultyLevel == eFDDifficultyLevel.EASY && file.easymodeSmartPistol && player.GetTeam() == TEAM_MILITIA )
		FD_GiveSmartPistol( player )
		
	if( file.isLiveFireMap )
		player.TakeOffhandWeapon( OFFHAND_ORDNANCE )
	
	//If player has bought the Amped Weapons before, keep it for the new weapons
	if ( player.s.hasPermenantAmpedWeapons )
	{
		array<entity> weapons = player.GetMainWeapons()
		weapons.extend( player.GetOffhandWeapons() )
		foreach ( entity weapon in weapons )
		{
			weapon.RemoveMod( "silencer" )
			foreach ( string mod in GetWeaponBurnMods( weapon.GetWeaponClassName() ) )
			{
				try
				{
					weapon.AddMod( mod )
				}
				catch( ex )
				{
					weapons.removebyvalue( weapon )
				}
			}
			weapon.SetScriptFlags0( weapon.GetScriptFlags0() | WEAPONFLAG_AMPED )
		}
	}
}

void function FD_GivePlayerInfiniteAntiTitanAmmo( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
	foreach ( entity weaponEnt in weapons )
	{
		if ( weaponEnt.GetWeaponInfoFileKeyField( "menu_category" ) != "at" )
			continue

		if( !weaponEnt.HasMod( "at_unlimited_ammo" ) )
			weaponEnt.AddMod( "at_unlimited_ammo" )
	}
}

void function FD_GiveSmartPistol( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
	foreach ( entity weaponEnt in weapons )
	{
		if ( weaponEnt.GetWeaponInfoFileKeyField( "menu_category" ) != "pistol" )
			continue
		
		player.TakeWeaponNow( weaponEnt.GetWeaponClassName() )
		player.GiveWeapon( "mp_weapon_smart_pistol", ["og_pilot"] )
	}
}

void function FD_BoostPurchaseCallback( entity player, BoostStoreData data )
{
	player.s.extracashnag = Time() + 30
	if( player in file.playerAwardStats )
		file.playerAwardStats[player]["moneySpent"] += float( data.cost )
}

void function FD_TeamReserveDepositOrWithdrawCallback( entity player, string action, int amount )
{
	player.s.extracashnag = Time() + 30
	switch( action )
	{
		case "deposit":
			if( player in file.playerAwardStats )
				file.playerAwardStats[player]["moneyShared"] += float( amount )
			break
		case "withdraw":
			if( player in file.playerAwardStats )
				file.playerAwardStats[player]["moneyShared"] -= float( amount ) 
			break
	}
}

bool function allPlayersReady()
{
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( player.s.extracashnag < Time() && GetPlayerMoney( player ) >= 100 )
		{
			player.s.extracashnag = Time() + 20
			if( RandomInt( 100 ) > 50 )
				PlayFactionDialogueToPlayer( "fd_playerCashNagSurplus", player )
			else
				PlayFactionDialogueToPlayer( "fd_playerCashNagReg", player )
		}
		if( !player.GetPlayerNetBool( "FD_readyForNextWave" ) )
			return false
	}
	return true
}

bool function ClientCommandCallbackToggleReady( entity player, array<string> args )
{
	if( args[0] == "true" )
	{
		player.SetPlayerNetBool( "FD_readyForNextWave", true )
		MessageToTeam( TEAM_MILITIA,eEventNotifications.FD_PlayerReady, null, player )
	}
	if( args[0] == "false" )
		player.SetPlayerNetBool( "FD_readyForNextWave", false )

	return true
}

bool function ClientCommand_FDSetTutorialBit( entity player, array<string> args )
{
	int fdbits = args[0].tointeger()
	SetPersistenceBitfield( player, "fdTutorialBits", fdbits, -1 )
	return true
}

bool function ClientCommandCallbackFDDropBattery( entity player, array<string> args )
{
	if( !player.IsTitan() && PlayerHasBattery( player ) )
		Rodeo_PilotThrowsBattery( player )

	return true
}

bool function useShieldBoost( entity player, array<string> args )
{
	if( ( GetGlobalNetTime( "FD_harvesterInvulTime" ) < Time() ) && ( player.GetPlayerNetInt( "numHarvesterShieldBoost" ) > 0 ) )
	{
		fd_harvester.harvester.SetShieldHealth( fd_harvester.harvester.GetShieldHealthMax() )
		
		//If shield is down and someone uses Shield Boost, Harvester Shield Particle FX wasn't spawning
		if( !IsValid( fd_harvester.particleShield ) )
			generateShieldFX( fd_harvester )
		
		fd_harvester.lastDamage = Time() - GENERATOR_SHIELD_REGEN_DELAY
		EmitSoundOnEntity( fd_harvester.harvester, "UI_TitanBattery_Pilot_Give_TitanBattery" )
		SetGlobalNetTime( "FD_harvesterInvulTime", Time() + 5 )
		AddPlayerScore( player, "FDShieldHarvester" )
		MessageToTeam( TEAM_MILITIA,eEventNotifications.FD_PlayerBoostedHarvesterShield, player, player )
		player.SetPlayerNetInt( "numHarvesterShieldBoost", player.GetPlayerNetInt( "numHarvesterShieldBoost" ) - 1 )
		if( player in file.playerAwardStats )
			file.playerAwardStats[player]["harvesterHeals"] += 1.0
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, FD_SCORE_SHIELD_HARVESTER )
		UpdatePlayerScoreboard( player )
		UpdatePlayerStat( player, "fd_stats", "harvesterBoosts" )
	}
	return true
}

void function TrackDeployedArcTrapThisRound( entity player )
{
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			thread UpdateEarnMeter_ByPlayersInMatch()
			ClearInvalidFDEntities()
		}
	)

	while( IsValidPlayer( player ) )
	{
		entity ArcTrap = expect entity( player.WaitSignal( "DeployArcTrap" ).projectile )
		UpdatePlayerStat( player, "fd_stats", "arcMinesPlaced" )
		if( player.GetTeam() == TEAM_IMC ) //Remove the ability of IMC players deploying Arc Traps for the defending players
			ArcTrap.Destroy()
		
		if( ArcTrap.e.fd_roundDeployed == -1 )
			ArcTrap.e.fd_roundDeployed = GetGlobalNetInt( "FD_currentWave" )
	}
}

void function TryDisableTitanSelectionForPlayerAfterDelay( entity player )
{
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValidPlayer( player ) && GetGameState() == eGameState.Playing )
			{
				int waveNumber = GetGlobalNetInt( "FD_currentWave" ) + 1
				
				UnMuteAll( player ) //I've got reports of people having problems with muted audio when joining midgame
		
				if( GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_BREAK )
				{
					Remote_CallFunction_NonReplay( player, "ServerCallback_FD_NotifyStoreOpen" )
					player.s.extracashnag = Time() + 30
				}
				else if( GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_IN_PROGRESS || GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_INCOMING ) //Announces which wave players are in right after they leave the Titan Selection Menu, this is to prevent the whole wave not having music for them
				{
					MessageToPlayer( player, eEventNotifications.FD_AnnounceWaveStart )
					if( player.GetParent() ) //Dropship check, because TTS Menu applies and removes player Invulnerability in its own way
						player.SetInvulnerable()
				}
				
				if ( PlayerEarnMeter_Enabled() )
				{
					DisableTitanSelectionForPlayer( player )
					if( GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_BREAK ) //On wave break, let joiners have their Titan instantly
						PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
				}
				else if ( waveNumber > 1 && !PlayerEarnMeter_Enabled() && !file.isLiveFireMap ) //Let joiners know why their Titan Meter is not building up if they joined during a Titanfall Block event
					thread ShowTitanfallBlockHintToPlayer( player )
			}
		}
	)
	
	player.WaitSignal( "StopSendingTTSMenuCommand" )
	wait 0.2 //Ensure to setup stuff after the TTS menu stuff
}

void function SetTurretSettings_threaded( entity player )
{
	WaitFrame()
	DeployableTurret_SetAISettingsForPlayer_AP( player, "npc_turret_sentry_burn_card_ap_fd" )
	DeployableTurret_SetAISettingsForPlayer_AT( player, "npc_turret_sentry_burn_card_at_fd" )
	file.players[player].moneyThisRound = GetPlayerMoney( player ) //Save money in case bro joined midwave and that wave is about to restart
}

void function DisableTitanSelection()
{
	foreach ( entity player in GetPlayerArray() )
		DisableTitanSelectionForPlayer( player )
}

void function EnableTitanSelection()
{
	foreach ( entity player in GetPlayerArray() )
		EnableTitanSelectionForPlayer( player )
}

void function EnableTitanSelectionForPlayer( entity player )
{
	int enumCount = PersistenceGetEnumCount( "titanClasses" )

	if( !IsValidPlayer( player ) )
		return

	for ( int i = 0; i < enumCount; i++ )
	{
		string enumName = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		if ( enumName != "" )
			player.SetPersistentVar( "titanClassLockState[" + enumName + "]", TITAN_CLASS_LOCK_STATE_AVAILABLE )
	}
}

void function DisableTitanSelectionForPlayer( entity player )
{
	int enumCount = PersistenceGetEnumCount( "titanClasses" )

	if( !IsValidPlayer( player ) )
		return

	for ( int i = 0; i < enumCount; i++ )
	{
		string enumName = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		string selectedEnumName = PersistenceGetEnumItemNameForIndex( "titanClasses", GetPersistentSpawnLoadoutIndex( player, "titan" ) )
		if ( enumName != "" && enumName != selectedEnumName )
			player.SetPersistentVar( "titanClassLockState[" + enumName + "]", TITAN_CLASS_LOCK_STATE_LOCKED )
		
		string playerUID = player.GetUID()
		if( !( playerUID in file.playerHasTitanSelectionLocked ) )
		{
			player.SetPersistentVar( "activeTitanLoadoutIndex", GetPersistentSpawnLoadoutIndex( player, "titan" ) - 1 )
			file.playerHasTitanSelectionLocked[ playerUID ] <- player.GetPersistentVarAsInt( "activeTitanLoadoutIndex" )
		}
	}
}

//Change the highlight color of pilots when rodeoing Titans because the voice feedback from Titan OS might not be enough to players awareness
void function FD_PilotStartRodeo( entity pilot, entity titan )
{
	if ( GetConVarBool( "ns_fd_rodeo_highlight" ) )
	{
		pilot.Highlight_SetParam( 1, 0, < 0.5, 2.0, 0.5 > )
		pilot.SetNameVisibleToFriendly( true ) //Disabling it for other gamemodes is alright but this helps seeing friends rodeoing AI
	}
	if ( !PlayerHasPassive( pilot, ePassives.PAS_STEALTH_MOVEMENT ) )
	{
		if( titan.IsNPC() && titan.GetTeam() == TEAM_IMC )
		{
			if( titan.ai.bossTitanType == TITAN_MERC )
				thread EliteTitanElectricSmoke( titan )
			UpdatePlayerStat( pilot, "fd_stats", "rodeos" )
		}
	}
}

void function FD_PilotEndRodeo( entity pilot, entity titan )
{
	if ( GetConVarBool( "ns_fd_rodeo_highlight" ) )
		pilot.Highlight_SetParam( 1, 0, HIGHLIGHT_COLOR_FRIENDLY )
}











/* Player Respawn Logic
██████  ██       █████  ██    ██ ███████ ██████      ██████  ███████ ███████ ██████   █████  ██     ██ ███    ██     ██       ██████   ██████  ██  ██████ 
██   ██ ██      ██   ██  ██  ██  ██      ██   ██     ██   ██ ██      ██      ██   ██ ██   ██ ██     ██ ████   ██     ██      ██    ██ ██       ██ ██      
██████  ██      ███████   ████   █████   ██████      ██████  █████   ███████ ██████  ███████ ██  █  ██ ██ ██  ██     ██      ██    ██ ██   ███ ██ ██      
██      ██      ██   ██    ██    ██      ██   ██     ██   ██ ██           ██ ██      ██   ██ ██ ███ ██ ██  ██ ██     ██      ██    ██ ██    ██ ██ ██      
██      ███████ ██   ██    ██    ███████ ██   ██     ██   ██ ███████ ███████ ██      ██   ██  ███ ███  ██   ████     ███████  ██████   ██████  ██  ██████ 
*/

void function RateSpawnpoints_FD( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	foreach ( entity spawnpoint in spawnpoints )
	{
		float rating
		if( team == TEAM_MILITIA )
			rating = 1.0 - ( Distance2D( spawnpoint.GetOrigin(), file.harvesterLocationForRespawn ) / 1000.0 )
		else
			rating = clamp( ( Distance2D( spawnpoint.GetOrigin(), file.harvesterLocationForRespawn ) / 5000.0 ), 0.0, 1.0 )
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating )
	}
}

void function FD_PlayerRespawnCallback( entity player )
{
	thread FD_PlayerRespawnThreaded( player )
}

void function FD_PlayerRespawnThreaded( entity player )
{
	player.EndSignal( "OnDestroy" )
	WaitFrame()
	
	if( IsValidPlayer( player ) )
	{
		if( player in file.players )
			file.players[player].lastRespawn = Time()
		if( GetCurrentPlaylistVarInt( "fd_at_unlimited_ammo", 1 ) && player.GetTeam() == TEAM_MILITIA && !file.isLiveFireMap )
			FD_GivePlayerInfiniteAntiTitanAmmo( player )
		if( GetGlobalNetInt( "FD_currentWave" ) == 0 || file.isLiveFireMap )
			PlayerEarnMeter_SetMode( player, 0 )
		if( player.GetTeam() == TEAM_IMC )
			player.Minimap_AlwaysShow( TEAM_MILITIA, null )
		else if( player.GetTeam() == TEAM_MILITIA && player.s.didthepvpglitch )
			SetTeam( player, TEAM_IMC )
	}
	else
		return
	
	//Players spawn directly on ground if Dropship already passed the point where players drops from it
	//If the wave is on break joiners can buy stuff with the time remaining
	//Also more than 4 players, additionals will spawn directly on ground
	//Respawning as titan also ignores this because err, makes no sense
	
	if ( player.IsTitan() || !IsHarvesterAlive( fd_harvester.harvester ) || player.GetTeam() == TEAM_IMC || GetGameState() == eGameState.Prematch )
		return
	
	if( IsValidPlayer( player ) && !player.IsTitan() )
	{
		player.Highlight_SetParam( 1, 0, < 0, 0, 0 > )
		player.SetInvulnerable()
		player.SetNoTarget( true )
		ScreenFadeFromBlack( player, 1.5, 0.5 )
	}
	
	if( file.dropshipState == eDropshipState.Returning || file.playersInShip >= 4 || GetGameState() != eGameState.Playing || !GetGlobalNetBool( "FD_waveActive" ) || GetConVarBool( "ns_fd_disable_respawn_dropship" ) || file.isLiveFireMap )
	{
		//Teleport player to a more reliable location if they spawn on ground, some maps picks too far away spawns from the Harvester and Shop (i.e Colony, Homestead, Drydock)
		if( IsValidPlayer( player ) && !player.IsTitan() )
		{
			if( !FD_DropPodSpawns.len() )
			{
				player.SetOrigin( FD_groundspawnPosition )
				player.SetAngles( FD_groundspawnAngles )
				thread FD_PlayerRespawnGrace( player )
			}
			else
				thread FD_SpawnPlayerDroppod( player )
		}
		return
	}
	
	if( file.dropshipState == eDropshipState.Idle )
		thread FD_DropshipSpawnDropship()

	if( IsValidPlayer( player ) && IsValid( file.dropship ) && !player.IsTitan() )
	{
		//Attach player
		FirstPersonSequenceStruct idleSequence
		idleSequence.firstPersonAnim = DROPSHIP_IDLE_ANIMS_POV[ file.playersInShip ]
		idleSequence.thirdPersonAnim = DROPSHIP_IDLE_ANIMS[ file.playersInShip++ ]
		idleSequence.attachment = "ORIGIN"
		idleSequence.teleport = true
		idleSequence.viewConeFunction = ViewConeNarrow
		idleSequence.hideProxy = true
		thread FirstPersonSequence( idleSequence, player, file.dropship )
		file.playersInDropship.append( player )
	}
}











/* Damage Logic
██████   █████  ███    ███  █████   ██████  ███████     ██       ██████   ██████  ██  ██████ 
██   ██ ██   ██ ████  ████ ██   ██ ██       ██          ██      ██    ██ ██       ██ ██      
██   ██ ███████ ██ ████ ██ ███████ ██   ███ █████       ██      ██    ██ ██   ███ ██ ██      
██   ██ ██   ██ ██  ██  ██ ██   ██ ██    ██ ██          ██      ██    ██ ██    ██ ██ ██      
██████  ██   ██ ██      ██ ██   ██  ██████  ███████     ███████  ██████   ██████  ██  ██████ 
*/

void function FD_DamageByPlayerCallback( entity victim, var damageInfo )
{
	entity player = DamageInfo_GetAttacker( damageInfo )
	if( !( player in file.players ) )
		return
	float damage = min( victim.GetHealth(), DamageInfo_GetDamage( damageInfo ) )
	if( player in file.playerAwardStats )
		file.playerAwardStats[player]["damageDealt"] += damage
	file.players[player].assaultScoreThisRound += damage.tointeger() / 100
}

void function FD_DamageToMoney( entity victim, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float damage = min( victim.GetHealth(), DamageInfo_GetDamage( damageInfo ) )
	
	if( attacker.GetTeam() == TEAM_MILITIA && attacker.IsPlayer() )
	{
		if( victim.IsTitan() && victim.GetTeam() == TEAM_IMC )
		{
			if ( !( "moneydamage" in victim.s ) )
				victim.s.moneydamage <- 0.0
			
			entity soul = victim.GetTitanSoul()
			if ( !GetDoomedState( victim ) && soul.GetShieldHealth() <= 0 )
			{
				float moneybuffer = victim.GetMaxHealth() / 50.0
				victim.s.moneydamage += damage
				while( victim.s.moneydamage >= moneybuffer )
				{
					victim.s.moneydamage -= moneybuffer
					AddMoneyToPlayer( attacker, 1 )
				}
			}
		}
	}
}

void function EliteTitanExecutionCheck( entity ent, var damageInfo )
{
	int damageType = DamageInfo_GetCustomDamageType( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsAlive( ent ) || !attacker || ent.GetTeam() != TEAM_MILITIA || attacker == ent || !ent.IsTitan() )
		return
	
	entity soul = ent.GetTitanSoul()
	if( attacker.IsNPC() && attacker.IsTitan() )
	{
		if( IsValid( soul ) && attacker.ai.bossTitanType == TITAN_MERC && (damageType & DF_MELEE) )
		{
			if( CodeCallback_IsValidMeleeExecutionTarget( attacker, ent ) && !GetDoomedState( attacker ) ) //Doomed Elites cant execute
			{
				//If the player is already doomed, then just execute, if the next melee damage brings it to Doom state, wait to execute
				if( GetDoomedState( ent ) )
				{
					thread PlayerTriesSyncedMelee( attacker, ent )
					ent.SetNoTarget( true ) //Prevents other nearby AI Titans from Moshing the victim
				}
				else
					thread EliteExecutionDelayed( attacker, ent )
			}
		}
	}
}

void function EliteExecutionDelayed( entity attacker, entity ent )
{
	wait 0.1
	entity soul = ent.GetTitanSoul()
	if( CodeCallback_IsValidMeleeExecutionTarget( attacker, ent ) && ent.IsTitan() && IsValid( soul ) && !GetDoomedState( attacker ) )
	{
		if( GetDoomedState( ent ) && (!SoulHasPassive( soul, ePassives.PAS_RONIN_AUTOSHIFT ) || !SoulHasPassive( soul, ePassives.PAS_AUTO_EJECT )) ) //Respect Stealth Auto-Eject and Phase-Reflex
		{
			thread PlayerTriesSyncedMelee( attacker, ent )
			ent.SetNoTarget( true ) //Again, no Moshing against the victim
		}
	}
}

void function DamageScaleByDifficulty( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	
	if ( !attacker || ent.GetTeam() != TEAM_MILITIA )
		return
	
	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( !damageSourceID )
		return
	
	//IMC Players being a distraction will do less damage, countermeasure to smoothen the stress put onto the Defending players
	//Also Wave Breaks WILL be respected
	if ( attacker.GetTeam() == TEAM_IMC )
	{
		if ( attacker.IsPlayer() && !GetGlobalNetBool( "FD_waveActive" ) )
		{
			SendHudMessage( attacker, "Do NOT Attack Defending players during Wave Breaks!", -1, 0.4, 255, 0, 0, 255, 0.15, 3.0, 0.5 )
			if( IsAlive( attacker ) )
				attacker.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.damagedef_unknown } )
			if( IsAlive( inflictor ) && inflictor.GetBossPlayer() == attacker )
				inflictor.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.damagedef_unknown } )
			DamageInfo_ScaleDamage( damageInfo, 0.0 )
			return
		}
		else if ( attacker.IsPlayer() )
		{
			switch( damageSourceID )
			{
				case eDamageSourceId.mp_weapon_sniper:
				case eDamageSourceId.mp_weapon_mastiff:
				case eDamageSourceId.mp_weapon_shotgun:
				case eDamageSourceId.mp_weapon_defender:
				case eDamageSourceId.mp_weapon_epg:
				case eDamageSourceId.mp_weapon_softball:
				case eDamageSourceId.mp_weapon_satchel:
				case eDamageSourceId.mp_weapon_pulse_lmg:
				DamageInfo_ScaleDamage( damageInfo, 0.2 )
				break
				
				default:
				DamageInfo_ScaleDamage( damageInfo, 0.4 )
			}
			return
		}
	}
	
	if ( damageSourceID == eDamageSourceId.prowler_melee )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.2 ) //Prowlers being basically hitkill on FD ain't fun
		return
	}
	
	if( attacker.IsNPC() && attacker.IsTitan() && !GetDoomedState( attacker ) && attacker.ai.bossTitanType == TITAN_MERC )
	{
		if( damageSourceID == eDamageSourceId.auto_titan_melee || DamageInfo_GetCustomDamageType( damageInfo ) & DF_MELEE )
		{
			DamageInfo_ScaleDamage( damageInfo, 2.5 )
			
			if( GetTitanCharacterName( attacker ) == "legion" && ent.IsTitan() ) //Elite Legions have Bison melee, but lack feedback about that, so this should tell players their melee hurts alot
			{
				vector endOrigin = ent.GetOrigin()
				endOrigin.z += 128
				vector startOrigin = attacker.GetOrigin()
				startOrigin.z += 128
				vector refVec = endOrigin - startOrigin
				vector refPos = endOrigin - refVec * 0.5
				
				CreateShake( refPos, 10, 105, 1.25, 768 )
				PlayFX( $"P_impact_exp_XLG_metal", refPos )
				EmitSoundAtPosition( attacker.GetTeam(), refPos, "Explo_Satchel_Impact_3P" )
				EmitSoundAtPosition( attacker.GetTeam(), refPos, "Explo_FragGrenade_Impact_3P" )
				EmitSoundAtPosition( attacker.GetTeam(), refPos, "explo_40mm_splashed_impact_3p" )
			}
		}
		
		EliteTitanExecutionCheck( ent, damageInfo )
		return
	}
	
	if ( damageSourceID == eDamageSourceId.damagedef_stalker_powersupply_explosion_large_at && ent.IsPlayer() && ent.IsTitan() ) //Warn Titan players about Stalkers
		PlayFactionDialogueToPlayer( "fd_stalkerExploNag", ent )

	if( difficultyLevel >= eFDDifficultyLevel.MASTER && ( IsMinion( attacker ) || IsStalker( attacker ) || IsFragDrone( attacker ) ) ) //On Vanilla, Light Infantry does not scale damage to players for Hard or below
		return
	
	DamageInfo_ScaleDamage( damageInfo, GetCurrentPlaylistVarFloat( "fd_player_damage_scalar", 1.0 ) )
}

void function HarvesterShieldInvulnCheck( entity harvester, var damageInfo, float actualShieldDamage )
{
	if ( !IsValid( harvester ) || !GetGlobalNetBool( "FD_waveActive" ) )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	if( fd_harvester.harvester != harvester )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	if ( GetGlobalNetTime( "FD_harvesterInvulTime" ) > Time() )
	{
		harvester.SetShieldHealth( harvester.GetShieldHealthMax() )
		actualShieldDamage = 0.0
	}
}

void function OnHarvesterDamaged( entity harvester, var damageInfo )
{
	if ( !IsValid( harvester ) || !GetGlobalNetBool( "FD_waveActive" ) ) //Harvester can only be damaged while waves are active, prevention of AI spawned outside waves or some other shenaningans modders might do
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	if( fd_harvester.harvester != harvester )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}
	
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	
	/*On vanilla, because of the glitch of swapping teams, IMC players could attack the Harvester, i am removing this possibility from them	because FD is a
	PvE	gamemode after all and such should behave accordingly, so what IMC players should do now is actually distract or kill the defending players, assisting
	the AI in actually reach the Harvester for them to do the damage */
	if ( attacker.IsPlayer() && attacker.GetTeam() == TEAM_IMC )
	{
		SendHudMessage( attacker, "You cannot attack the Harvester, only the AI, help the AI attack it!", -1, 0.4, 255, 255, 255, 255, 0.15, 3.0, 0.5 )
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}
	else if ( IsValid( GetPetTitanOwner( attacker ) ) && attacker.GetTeam() == TEAM_IMC )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	int attackerTypeID = FD_GetAITypeID_ByString( attacker.GetTargetName() )
	float damageAmount = DamageInfo_GetDamage( damageInfo )
	
	//Titan smokes triggers damage calls on Harvester somehow
	if( attacker.GetTeam() == TEAM_MILITIA )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}
	
	int PlayersInMatch = GetPlayerArrayOfTeam( TEAM_MILITIA ).len() + 1
	
	if ( PlayersInMatch > 4 ) //Additional players should not be considered
		PlayersInMatch = 4
	
	float MultiplierPerPlayer = 0.25

	if ( !damageSourceID && !damageAmount && !attacker )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	fd_harvester.lastDamage = Time()

	if( difficultyLevel == eFDDifficultyLevel.EASY )
		damageAmount *= 0.8
	else
		damageAmount *= GetCurrentPlaylistVarFloat( "fd_player_damage_scalar", 1.0 )
	damageAmount *= MultiplierPerPlayer * PlayersInMatch
	
	//All of this is factored BEFORE difficulty damage multipliers, so probably on Master and Insane difficulty only one Nuke Titan should almost end the Harvester even with full shields
	//Master and Insane difficulties tends to spawn less enemies as well, so players should be paying attention against those enemies
	//These are approximate values accordingly to vanilla
	if( harvester.GetShieldHealth() > 0 )
	{
		switch( damageSourceID )
		{
			case eDamageSourceId.mp_titancore_laser_cannon:
			damageAmount *= 0.1
			break
			
			case eDamageSourceId.mp_titancore_salvo_core:
			case eDamageSourceId.mp_titanweapon_flightcore_rockets:
			case eDamageSourceId.mp_titancore_flame_wave:
			case eDamageSourceId.mp_titanweapon_sniper:
			damageAmount *= 0.25
			break

			case eDamageSourceId.damagedef_nuclear_core:
			damageAmount *= 6
			break
		
			case eDamageSourceId.damagedef_stalker_powersupply_explosion_small:
			case eDamageSourceId.mp_weapon_super_spectre:
			case eDamageSourceId.super_spectre_melee:
			case eDamageSourceId.mp_titanweapon_arc_cannon:
			damageAmount *= 2
			break
			
			case eDamageSourceId.damagedef_stalker_powersupply_explosion_large:
			case eDamageSourceId.damagedef_frag_drone_explode_FD:
			case eDamageSourceId.mp_titanweapon_rocketeer_rocketstream:
			case eDamageSourceId.mp_weapon_rocket_launcher:
			damageAmount *= 4
			break
			
			case eDamageSourceId.mp_weapon_droneplasma:
			damageAmount *= 10.0
			break
		}
	}
	
	else
	{
		switch( damageSourceID )
		{
			case eDamageSourceId.damagedef_nuclear_core: //A single Nuke Titan should already be a high threat to the Harvester
			case eDamageSourceId.mp_weapon_droneplasma: //Not sure too, Plasma Drones also seems off
			damageAmount *= 10
			break
			
			case eDamageSourceId.damagedef_stalker_powersupply_explosion_large:
			case eDamageSourceId.damagedef_frag_drone_explode_FD: //Not sure, Ticks feels off
			case eDamageSourceId.mp_titanweapon_rocketeer_rocketstream: //Mortar titans also do pose a threat if left unchecked for too long
			case eDamageSourceId.mp_weapon_rocket_launcher: //Idk apparently the Archer that mortar spectres uses has no special damage type
			damageAmount *= 4
			break
		
			case eDamageSourceId.damagedef_stalker_powersupply_explosion_small:
			damageAmount *= 2 //Stalkers should also be able to take a little more from Harvester as in vanilla
			break
			
			//Actually for Cores its better reduce their damage because a single Elite could just disintegrate Harvester within 2 seconds
			case eDamageSourceId.mp_titancore_flame_wave:
			case eDamageSourceId.mp_titancore_salvo_core:
			case eDamageSourceId.mp_titanweapon_flightcore_rockets:
			case eDamageSourceId.mp_titanweapon_sniper:
			damageAmount *= 0.25
			break
			
			case eDamageSourceId.mp_titancore_laser_cannon:
			damageAmount *= 0.05
			break
		}
	}
	
	float shieldPercent = ( ( harvester.GetShieldHealth().tofloat() / harvester.GetShieldHealthMax() ) * 100 )
	if ( shieldPercent < 100 && !file.harvesterShieldDown )
	{
		switch( attackerTypeID )
		{
			case eFD_AITypeIDs.TITAN_ARC:
			PlayFactionDialogueToTeam( "fd_nagTitanArcAtBase", TEAM_MILITIA )
			break
		
			case eFD_AITypeIDs.STALKER:
			PlayFactionDialogueToTeam( "fd_nagKillStalkers", TEAM_MILITIA )
			break
			
			case eFD_AITypeIDs.GRUNT:
			case eFD_AITypeIDs.SPECTRE:
			PlayFactionDialogueToTeam( "fd_nagKillInfantry", TEAM_MILITIA )
			break
			
			case eFD_AITypeIDs.TITAN_MORTAR:
			PlayFactionDialogueToTeam( "fd_nagKillTitansMortar", TEAM_MILITIA )
			break
			
			case eFD_AITypeIDs.SPECTRE_MORTAR:
			PlayFactionDialogueToTeam( "fd_nagKillMortarSpectres", TEAM_MILITIA )
			break
			
			case eFD_AITypeIDs.TITAN_NUKE:
			PlayFactionDialogueToTeam( "fd_nukeTitanNearBase", TEAM_MILITIA )
			break
			
			default:
			PlayFactionDialogueToTeam( "fd_baseShieldTakingDmg", TEAM_MILITIA )
			break
		}
	}

	if ( shieldPercent < 35 && !file.harvesterShieldDown ) // idk i made this up
		PlayFactionDialogueToTeam( "fd_baseShieldLow", TEAM_MILITIA )

	if ( harvester.GetShieldHealth() == 0 )
	{
		file.harvesterDamageTaken += damageAmount // track damage for wave recaps
		
		if ( attackerTypeID > -1 ) //Only track damage from existing ids
			file.harvesterDamageSource[attackerTypeID] += damageAmount
			
		float newHealth = harvester.GetHealth() - damageAmount
		float oldhealthpercent = ( ( harvester.GetHealth().tofloat() / harvester.GetMaxHealth() ) * 100 )
		float healthpercent = ( ( newHealth / harvester.GetMaxHealth() ) * 100 )
		
		if( IsValid( fd_harvester.particleSparks ) )
		{
			vector sparkColor = GetHarvesterBeamTriLerpColor( 1.0 - ( harvester.GetHealth().tofloat() / harvester.GetMaxHealth().tofloat() ) )
			EffectSetControlPointVector( fd_harvester.particleSparks, 1, sparkColor )
		}
		
		if ( healthpercent <= 75 && oldhealthpercent > 75 )
			PlayFactionDialogueToTeam( "fd_baseHealth75", TEAM_MILITIA )

		if ( healthpercent <= 50 && oldhealthpercent > 50 )
		{
			if( !file.harvesterHalfHealth )
			{
				sparksBeamFX( fd_harvester )
				StopSoundOnEntity( harvester, HARVESTER_SND_HEALTHY )
				EmitSoundOnEntity( harvester, HARVESTER_SND_DAMAGED )
				EmitSoundOnEntity( harvester, HARVESTER_SND_UNSTABLE )
				fd_harvester.rings.Anim_Play( HARVESTER_ANIM_ACTIVE_LOWHP )
				file.harvesterHalfHealth = true
			}
			if( RandomInt( 100 ) > 50 )
				PlayFactionDialogueToTeam( "fd_baseHealth50", TEAM_MILITIA )
			else
				PlayFactionDialogueToTeam( "fd_baseHealth50nag", TEAM_MILITIA )
		}

		if ( healthpercent <= 25 && oldhealthpercent > 25 )
		{
			StopSoundOnEntity( harvester, HARVESTER_SND_DAMAGED )
			EmitSoundOnEntity( harvester, HARVESTER_SND_CRITICAL )
			EmitSoundOnEntity( harvester, HARVESTER_SND_UNSTABLE )
			
			if( RandomInt( 100 ) > 50 )
				PlayFactionDialogueToTeam( "fd_baseHealth25", TEAM_MILITIA )
			else
				PlayFactionDialogueToTeam( "fd_baseHealth25nag", TEAM_MILITIA )
		}

		if( healthpercent <= 15 )
		{
			if( RandomInt( 100 ) > 50 )
				PlayFactionDialogueToTeam( "fd_baseLowHealth", TEAM_MILITIA )
			else
				PlayFactionDialogueToTeam( "fd_baseShieldLowHolding", TEAM_MILITIA )
		}

		if( newHealth <= 0 )
		{
			EmitSoundOnEntity( harvester, HARVESTER_SND_DESTROYED )
			newHealth = 1
			harvester.SetInvulnerable()
			DamageInfo_SetDamage( damageInfo, 0.0 )
			fd_harvester.rings.Anim_Play( HARVESTER_ANIM_DESTROYED )
			
			if( IsValid( fd_harvester.particleBeam ) )
				fd_harvester.particleBeam.Destroy()
		}
		harvester.SetHealth( newHealth )
		file.harvesterWasDamaged = true
		file.harvesterPerfectWin = false //Remove perfect win
	}
	
    DamageInfo_SetDamage( damageInfo, damageAmount )
}











/* Spawn Logic
███████ ██████   █████  ██     ██ ███    ██     ██       ██████   ██████  ██  ██████ 
██      ██   ██ ██   ██ ██     ██ ████   ██     ██      ██    ██ ██       ██ ██      
███████ ██████  ███████ ██  █  ██ ██ ██  ██     ██      ██    ██ ██   ███ ██ ██      
     ██ ██      ██   ██ ██ ███ ██ ██  ██ ██     ██      ██    ██ ██    ██ ██ ██      
███████ ██      ██   ██  ███ ███  ██   ████     ███████  ██████   ██████  ██  ██████ 
*/

void function HealthScaleByDifficulty( entity ent )
{
	if ( ent.GetTeam() != TEAM_IMC )
		return


	if ( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) ) // in case we ever want pvp in FD
		return

	if ( ent.IsTitan() && ent.ai.bossTitanType == 0 )
	{
		ent.SetMaxHealth( ent.GetMaxHealth() + GetCurrentPlaylistVarInt( "fd_titan_health_adjust", 0 ) )
		ent.e.hasDefaultEnemyHighlight = false
		Highlight_ClearEnemyHighlight( ent )
	}
	else if( IsSuperSpectre( ent ) )
		ent.SetMaxHealth( ent.GetMaxHealth() + GetCurrentPlaylistVarInt( "fd_reaper_health_adjust", 0 ) )
	

	if( GetCurrentPlaylistVarInt( "fd_pro_titan_shields", 0 ) && ent.IsTitan() || ent.IsTitan() && GetAiNetIdFromTargetName( ent.GetTargetName() ) == "FD_AICount_Titan_Nuke" ) //Nuke Titans always spawn with shields regardless difficulty
	{
		entity soul = ent.GetTitanSoul()
		if( IsValid( soul ) )
		{
			soul.SetShieldHealthMax( 2500 )
			soul.SetShieldHealth( 2500 )
		}
	}
}

void function SpawnCallback_SafeTitanSpawnTime( entity ent )
{
	if( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) && ent.GetTeam() == TEAM_MILITIA )
	{
		Highlight_SetFriendlyHighlight( ent, "sp_friendly_hero" ) //Friendly Titans should have highlight overlays
		ent.EnableNPCFlag( NPCMF_PREFER_SPRINT | NPC_ALLOW_INVESTIGATE | NPC_IGNORE_FRIENDLY_SOUND | NPC_NEW_ENEMY_FROM_SOUND | NPC_TEAM_SPOTTED_ENEMY | NPC_AIM_DIRECT_AT_ENEMY | NPC_ALLOW_HAND_SIGNALS )
		if( !GetGlobalNetBool( "FD_waveActive" ) )
			ent.EnableNPCMoveFlag( NPCMF_WALK_NONCOMBAT | NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_DISABLE_DANGEROUS_AREA_DISPLACEMENT )
		entity player = GetPetTitanOwner( ent )
		file.players[player].lastTitanDrop = Time()
		SetSquad( ent, "TLRPlayers" )
	}
	else if( ent.IsTitan() && ent.GetTeam() == TEAM_MILITIA && ent in file.players )
		file.players[ent].lastTitanDrop = Time()
	
	if( ent.GetTeam() == TEAM_IMC )
		ent.Minimap_AlwaysShow( TEAM_MILITIA, null )
}

void function OnTickSpawn( entity tick )
{
	thread TickSpawnThreaded( tick )
}

void function TickSpawnThreaded( entity tick )
{
	WaitFrame()
	if( GetGameState() != eGameState.Playing || !IsHarvesterAlive( fd_harvester.harvester ) || tick.GetParent() ) //Parented Ticks are Drop Pod ones, and those are handled by the function there itself
		return

	else if ( GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_IN_PROGRESS )
	{
		tick.kv.alwaysalert = 1
		tick.Minimap_SetAlignUpright( true )
		tick.Minimap_AlwaysShow( TEAM_IMC, null )
		tick.Minimap_AlwaysShow( TEAM_MILITIA, null )
		tick.Minimap_SetHeightTracking( true )
		tick.Minimap_SetCustomState( eMinimapObject_npc.AI_TDM_AI )
		tick.EnableNPCFlag( NPC_ALLOW_INVESTIGATE )
		if( tick.GetTeam() == TEAM_IMC )
			thread singleNav_thread( tick, "" )
	}
	else
	{
		if ( IsAlive( tick ) && tick.GetTeam() == TEAM_IMC ) //In case you wonder, this is to immediately kill Ticks spawned by Reapers AFTER wave completion
			tick.Destroy()
	}
}

void function AddTurretSentry( entity turret )
{
	entity player = turret.GetBossPlayer()
	if( player != null && player.GetTeam() == TEAM_MILITIA )
	{
		UpdatePlayerStat( player, "fd_stats", "turretsPlaced" )
		
		turret.Minimap_AlwaysShow( TEAM_MILITIA, null )
		turret.Minimap_SetHeightTracking( true )
		turret.Minimap_SetCustomState( eMinimapObject_npc.FD_TURRET )
		turret.SetMaxHealth( DEPLOYABLE_TURRET_HEALTH )
		turret.SetHealth( DEPLOYABLE_TURRET_HEALTH )
		turret.kv.AccuracyMultiplier = DEPLOYABLE_TURRET_ACCURACY_MULTIPLIER
		turret.ai.buddhaMode = true
		SetPreventSmartAmmoLock( turret, true ) //Prevents enemy Legion Smart Core to target them automatically
		Highlight_SetFriendlyHighlight( turret , "sp_friendly_hero" )
		Highlight_SetOwnedHighlight( turret , "sp_friendly_hero" )
		turret.Highlight_SetParam( 1, 0, < 0, 0, 0 > )
		turret.Highlight_SetParam( 3, 0, HIGHLIGHT_COLOR_INTERACT )
		
		if( turret.e.fd_roundDeployed == -1 )
			turret.e.fd_roundDeployed = GetGlobalNetInt( "FD_currentWave" )
		
		thread TurretRefundThink( turret )
		
		array<entity> primaryWeapons = turret.GetMainWeapons()
		entity turretgun = primaryWeapons[0]
		turretgun.AddMod( "fd" )
	}
	else if( player != null && player.GetTeam() == TEAM_IMC )
		turret.Destroy() //IMC Players shall not deploy turrets
}











/* Death Logic
██████  ███████  █████  ████████ ██   ██     ██       ██████   ██████  ██  ██████ 
██   ██ ██      ██   ██    ██    ██   ██     ██      ██    ██ ██       ██ ██      
██   ██ █████   ███████    ██    ███████     ██      ██    ██ ██   ███ ██ ██      
██   ██ ██      ██   ██    ██    ██   ██     ██      ██    ██ ██    ██ ██ ██      
██████  ███████ ██   ██    ██    ██   ██     ███████  ██████   ██████  ██  ██████ 
*/

void function GamemodeFD_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if( !IsHarvesterAlive( fd_harvester.harvester ) || GetGameState() != eGameState.Playing )
		return
	
	victim.s.currentKillstreak = 0
	victim.s.lastKillTime = 0.0
	victim.s.currentTimedKillstreak = 0
	victim.s.hasPermenantAmpedWeapons = false
	
	if( victim.GetTeam() == TEAM_IMC && attacker.IsPlayer() && attacker.GetTeam() == TEAM_MILITIA && GetGlobalNetBool( "FD_waveActive" ) ) //Give money to Militia players killing IMC players
	{
		PlayerEarnMeter_AddEarnedFrac( attacker, 0.15 )
		AddMoneyToPlayer( attacker, 25 )
		victim.s.didthepvpglitch = true //Flag the player to force it to stay on IMC side for the whole wave as punishment
		if( !victim.s.isbeingmonitored )
			thread PvPGlitchMonitor( victim )
		return
	}
	
	DeathCallback_CalculateTitanAliveTime( victim )
		
	if( FD_PlayerInDropship( victim ) )
	{
		victim.ClearParent()
		ClearPlayerAnimViewEntity( victim )
		victim.ClearInvulnerable()
	}
	//set longest Time alive for end awards
	float timeAlive = Time() - file.players[victim].lastRespawn
	if( victim in file.playerAwardStats && timeAlive > file.playerAwardStats[victim]["longestLife"] )
		file.playerAwardStats[victim]["longestLife"] = timeAlive
	
	file.pilotPerfectWin = false //Remove perfect win
	
	if( GetGlobalNetInt( "FD_waveState") != WAVE_STATE_BREAK )
		file.players[victim].diedThisRound = true

	//play voicelines for amount of players alive
	array<entity> militiaplayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
	int deaths = 0
	foreach ( entity player in militiaplayers )
		if ( !IsAlive( player ) || player.GetParent() && player.GetParent().GetClassName() == "npc_dropship" )
			deaths++

	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( player == victim )
			continue
		
		if( player.GetParent() && player.GetParent().GetClassName() == "npc_dropship" )
			continue

		if( deaths == 1 ) // only one pilot died
			PlayFactionDialogueToPlayer( "fd_singlePilotDown", player )
		else if( deaths > 1 && deaths < militiaplayers.len() - 1 ) // multiple pilots died but at least one alive
			PlayFactionDialogueToPlayer( "fd_multiPilotDown", player )
		else if( deaths == militiaplayers.len() - 1 ) // ur shit out of luck ur the only survivor
			PlayFactionDialogueToPlayer( "fd_onlyPlayerIsAlive", player )
	}
}

void function OnNpcDeath( entity victim, entity attacker, var damageInfo )
{
	vector vec = RandomVec( 150 )
	vector origin = victim.GetOrigin()
	vector ornull clampedPos = NavMesh_ClampPointForHullWithExtents( origin, HULL_TITAN, < 96, 96, 96 > )
	
	if ( clampedPos != null )
	{
		expect vector( clampedPos )
		origin = clampedPos
	}
	
	//Killing unwanted NPCs instantly causes a crash
	switch ( victim.GetClassName() )
	{
		case "npc_gunship":
		case "npc_dropship": //Actually gonna make Dropship drop a "candy" if players manage to destroy it as a reward for that
			entity battery = Rodeo_CreateBatteryPack()
			battery.SetSkin( 2 )
			battery.SetOrigin( origin )
			battery.SetVelocity( < vec.x, vec.y, 400 > )
			foreach( fx in battery.e.fxArray )
				EffectStop( fx )
			battery.e.fxArray.clear()
			int attachID = battery.LookupAttachment( "fx_center" )
			asset fx = BATTERY_FX_AMPED
			if( IsValid( battery ) )
				battery.e.fxArray.append( StartParticleEffectOnEntity_ReturnEntity( battery, GetParticleSystemIndex( fx ), FX_PATTACH_POINT_FOLLOW, attachID ) )
			return
		case "npc_marvin":
		case "npc_prowler":
		case "npc_pilot_elite":
		case "npc_turret_sentry":
			return
	}
	
	if( attacker.IsPlayer() && attacker.GetTeam() == TEAM_IMC ) //Give nothing for IMC players
		return
	
	if( victim.IsTitan() && victim.GetTeam() == TEAM_MILITIA && victim.GetBossPlayer() )
	{
		file.titanPerfectWin = false //Remove perfect win
		DeathCallback_CalculateTitanAliveTime( victim )
	}
	
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	int victimTypeID = FD_GetAITypeID_ByString( victim.GetTargetName() )
	int findIndex = spawnedNPCs.find( victim )
	
	if( IsPlayerControlledTurret( inflictor ) && inflictor.GetBossPlayer() == attacker && attacker in file.players )
	{
		if( attacker in file.playerAwardStats )
			file.playerAwardStats[attacker]["turretKills"] += 1.0
		file.players[attacker].defenseScoreThisRound += 2
		UpdatePlayerStat( attacker, "fd_stats", "turretKills" )
	}
	
	if( victim.IsTitan() && attacker in file.playerAwardStats )
		file.playerAwardStats[attacker]["titanKills"] += 1.0
	
	if( victimTypeID == eFD_AITypeIDs.TITAN_MORTAR || victimTypeID == eFD_AITypeIDs.SPECTRE_MORTAR )
		if( attacker in file.playerAwardStats )
			file.playerAwardStats[attacker]["mortarUnitsKilled"] += 1.0
	
	if ( findIndex != -1 )
	{
		spawnedNPCs.remove( findIndex )
		string netIndex = GetAiNetIdFromTargetName( victim.GetTargetName() )
		if( netIndex != "" )
			SetGlobalNetInt( netIndex, GetGlobalNetInt( netIndex ) - 1 )

		SetGlobalNetInt( "FD_AICount_Current", GetGlobalNetInt( "FD_AICount_Current" ) - 1 )
	}

	if ( victim.GetOwner() == attacker || !attacker.IsPlayer() || attacker == victim || victim.GetBossPlayer() == attacker || !IsValid( attacker ) )
		return

	int money = 0
	int scriptDamageType = DamageInfo_GetCustomDamageType( damageInfo )
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	if ( victim.IsNPC() )
	{
		//Play the subtle kill sound and immediately sets NPCs as nonsolid to prevent them bodyblocking further shots from hitting alive allies behind
		EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "HUD_Grunt_Killed_Indicator" )
		victim.NotSolid()
		victim.Minimap_Hide( TEAM_IMC, null )
		victim.Minimap_Hide( TEAM_MILITIA, null )
		
		if ( victim.IsTitan() )
			victim.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", false )
		
		switch ( victim.GetClassName() )
		{
			case "npc_soldier":
				AddPlayerScore( attacker, "FDGruntKilled" )
				attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_GRUNT )
				money = 5
				break
			case "npc_drone":
				if( !IsAttackDrone( victim ) ) //ignore worker drones
					break
				AddPlayerScore( attacker, "FDAirDroneKilled" )
				attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_AIR_DRONE )
				money = 10
				break
			case "npc_spectre":
				AddPlayerScore( attacker, "FDSpectreKilled" )
				attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_SPECTRE )
				money = 10
				break
			case "npc_stalker":
				AddPlayerScore( attacker, "FDStalkerKilled" )
				attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_STALKER )
				money = 15
				break
			case "npc_super_spectre":
				AddPlayerScore( attacker, "FDSuperSpectreKilled" )
				attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_SUPER_SPECTRE )
				money = 20
				break
			case "npc_titan":
				AddPlayerScore( attacker, "FDTitanKilled" )
				attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_TITAN )
				break
			default:
				money = 0
		}
		foreach( player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_OnTitanKilled", attacker.GetEncodedEHandle(), victim.GetEncodedEHandle(), scriptDamageType, damageSourceId )
		
		if( damageSourceId == eDamageSourceId.rodeo_forced_titan_eject )
			UpdatePlayerStat( attacker, "fd_stats", "rodeoNukes" )
	}
	
	if ( money != 0 )
		AddMoneyToPlayer( attacker , money )

	if( IsValid( inflictor ) )
	{
		if( !inflictor.IsNPC() && attacker.IsPlayer() ) //Turret and Auto-Titan kills should not give xp awards
		{
			if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
				AddPlayerScore( attacker, "NPCHeadshot" )
			
			entity weapon = attacker.GetActiveWeapon()
			bool canWeaponEarnXp = IsValid( weapon ) && ShouldTrackXPForWeapon( weapon.GetWeaponClassName() ) ? true : false
			
			attacker.s.currentKillstreak++
			if ( attacker.s.currentKillstreak == 8 && canWeaponEarnXp )
				AddWeaponXP( attacker, 1 )
			
			if ( Time() - attacker.s.lastKillTime > CASCADINGKILL_REQUIREMENT_TIME )
			{
				attacker.s.currentTimedKillstreak = 0
				attacker.s.currentKillstreak = 0
				attacker.s.lastKillTime = Time()
			}
		}
	}

	UpdatePlayerScoreboard( attacker )
	
	if( victim.IsTitan() )
	{
		entity soul = victim.GetTitanSoul()
		if ( IsValid( soul ) )
		{
			table<int, bool> alreadyAssisted
			foreach( DamageHistoryStruct attackerInfo in soul.e.recentDamageHistory )
			{
				if ( !IsValid( attackerInfo.attacker ) || !attackerInfo.attacker.IsPlayer() || attackerInfo.attacker == soul )
					continue
					
				bool exists = attackerInfo.attacker.GetEncodedEHandle() in alreadyAssisted ? true : false
				if( attackerInfo.attacker != attacker && !exists )
				{
					alreadyAssisted[attackerInfo.attacker.GetEncodedEHandle()] <- true
					AddPlayerScore(attackerInfo.attacker, "TitanAssist" )
					file.players[attackerInfo.attacker].defenseScoreThisRound += 5
					Remote_CallFunction_NonReplay( attackerInfo.attacker, "ServerCallback_SetAssistInformation", attackerInfo.damageSourceId, attacker.GetEncodedEHandle(), soul.GetEncodedEHandle(), attackerInfo.time ) 
				}
			}
		}
	}
	
	attacker.s.lastKillTime = Time()
	
	//Elite Titan battery drop code, they drops Amped Batteries on higher difficulties as reward
	if ( victim.IsTitan() && victim.ai.bossTitanType == TITAN_MERC )
	{
		switch ( difficultyLevel )
		{
			case eFDDifficultyLevel.EASY:
			case eFDDifficultyLevel.NORMAL:
				entity battery = Rodeo_CreateBatteryPack( victim )
				battery.SetOrigin( origin + < 0, 0, 128 > )
				battery.SetVelocity( < vec.x, vec.y, 400 > )
				break
			case eFDDifficultyLevel.HARD:
			case eFDDifficultyLevel.MASTER:
			case eFDDifficultyLevel.INSANE:
				entity battery = Rodeo_CreateBatteryPack()
				battery.SetSkin( 2 )
				battery.SetOrigin( origin + < 0, 0, 128 > )
				battery.SetVelocity( < vec.x, vec.y, 400 > )
				foreach( fx in battery.e.fxArray )
					EffectStop( fx )
				battery.e.fxArray.clear()
				int attachID = battery.LookupAttachment( "fx_center" )
				asset fx = BATTERY_FX_AMPED
				if( IsValid( battery ) )
					battery.e.fxArray.append( StartParticleEffectOnEntity_ReturnEntity( battery, GetParticleSystemIndex( fx ), FX_PATTACH_POINT_FOLLOW, attachID ) )
				break
		}
	}
	
	if( IsValid( inflictor ) )
	{
		if( !inflictor.IsNPC() && !attacker.IsTitan() && victim.IsTitan() )
		{
			string titanCharacterName = GetTitanCharacterName( victim )
			
			if ( Time() - attacker.s.lastKillTime <= CASCADINGKILL_REQUIREMENT_TIME )
			{
				attacker.s.currentTimedKillstreak++
				
				if ( attacker.s.currentTimedKillstreak == DOUBLEKILL_REQUIREMENT_KILLS )
					AddPlayerScore( attacker, "DoubleKill" )
				else if ( attacker.s.currentTimedKillstreak == TRIPLEKILL_REQUIREMENT_KILLS )
					AddPlayerScore( attacker, "TripleKill" )
				else if ( attacker.s.currentTimedKillstreak == MEGAKILL_REQUIREMENT_KILLS )
					AddPlayerScore( attacker, "MegaKill" )
				else if ( attacker.s.currentTimedKillstreak == 6 )
					ShowLargePilotKillStreak( attacker )
			}

			switch( titanCharacterName )
			{
				case "ion":
					PlayFactionDialogueToPlayer( "kc_pilotkillIon", attacker )
					break
				case "tone":
					PlayFactionDialogueToPlayer( "kc_pilotkillTone", attacker )
					break
				case "legion":
					PlayFactionDialogueToPlayer( "kc_pilotkillLegion", attacker )
					break
				case "scorch":
					PlayFactionDialogueToPlayer( "kc_pilotkillScorch", attacker )
					break
				case "ronin":
					PlayFactionDialogueToPlayer( "kc_pilotkillRonin", attacker )
					break
				case "northstar":
					PlayFactionDialogueToPlayer( "kc_pilotkillNorthstar", attacker )
					break
				default:
					PlayFactionDialogueToPlayer( "kc_pilotkilltitan", attacker )
					break
			}
		}
	}
}

void function OnNPCLeechedFD( entity victim, entity attacker )
{
	int findIndex = spawnedNPCs.find( victim )
	if ( findIndex != -1 )
	{
		spawnedNPCs.remove( findIndex )
		string netIndex = GetAiNetIdFromTargetName( victim.GetTargetName() )
		if( netIndex != "" )
			SetGlobalNetInt( netIndex, GetGlobalNetInt( netIndex ) - 1 )

		SetGlobalNetInt( "FD_AICount_Current", GetGlobalNetInt( "FD_AICount_Current" ) - 1 )
	}
	
	if ( victim.IsNPC() && victim.GetClassName() == "npc_spectre" )
	{
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_SPECTRE )
		AddMoneyToPlayer( attacker, 10 )
	}
	
	UpdatePlayerScoreboard( attacker )
}

void function DeathCallback_CalculateTitanAliveTime( entity ent )
{
	if( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) && ent.GetTeam() == TEAM_MILITIA )
	{
		entity player = GetPetTitanOwner( ent )
		float aliveTime = file.players[player].lastTitanDrop - Time()
		if( player in file.playerAwardStats && aliveTime > file.playerAwardStats[player]["longestTitanLife"] )
			file.playerAwardStats[player]["longestTitanLife"] = aliveTime
	}
	else if( ent.IsTitan() && ent.GetTeam() == TEAM_MILITIA && ent in file.players )
	{
		float aliveTime = file.players[ent].lastTitanDrop - Time()
		if( ent in file.playerAwardStats && aliveTime > file.playerAwardStats[ent]["longestTitanLife"] )
			file.playerAwardStats[ent]["longestTitanLife"] = aliveTime
	}
}

void function OnTickDeath( entity victim, var damageInfo )
{
	int findIndex = spawnedNPCs.find( victim )
	if ( findIndex != -1 )
	{
		spawnedNPCs.remove( findIndex )
		SetGlobalNetInt( "FD_AICount_Ticks", GetGlobalNetInt( "FD_AICount_Ticks" ) -1 )
		SetGlobalNetInt( "FD_AICount_Current", GetGlobalNetInt( "FD_AICount_Current" ) -1 )
	}
}

void function ClearInvalidFDEntities()
{
	foreach ( projectile in GetProjectileArray() )
	{
		if ( projectile instanceof CProjectile || projectile instanceof CBaseGrenade )
		{
			if( !IsValidPlayer( projectile.GetOwner() ) )
				projectile.Destroy()
		}
	}
	foreach( entity turret in GetNPCArrayByClass( "npc_turret_sentry" ) )
	{
		if ( !IsValidPlayer( turret.GetBossPlayer() ) && IsValid( turret ) && turret.GetAISettingsName() == "npc_turret_sentry_burn_card_ap_fd" )
			turret.Destroy()
	}
}











/* Harvester Logic
██   ██  █████  ██████  ██    ██ ███████ ███████ ████████ ███████ ██████      ██       ██████   ██████  ██  ██████ 
██   ██ ██   ██ ██   ██ ██    ██ ██      ██         ██    ██      ██   ██     ██      ██    ██ ██       ██ ██      
███████ ███████ ██████  ██    ██ █████   ███████    ██    █████   ██████      ██      ██    ██ ██   ███ ██ ██      
██   ██ ██   ██ ██   ██  ██  ██  ██           ██    ██    ██      ██   ██     ██      ██    ██ ██    ██ ██ ██      
██   ██ ██   ██ ██   ██   ████   ███████ ███████    ██    ███████ ██   ██     ███████  ██████   ██████  ██  ██████ 
*/

void function startHarvester()
{
	thread HarvesterThink()
	thread HarvesterAlarm()
}

void function HarvesterAlarm()
{
	while( IsHarvesterAlive( fd_harvester.harvester ) )
	{
		if( fd_harvester.harvester.GetShieldHealth() == 0 )
			wait EmitSoundOnEntity( fd_harvester.harvester, HARVESTER_SND_KLAXON )
		else
			WaitFrame()
	}
}

void function HarvesterThink()
{
	entity harvester = fd_harvester.harvester
	float lastTime = Time()
	wait 2
	EmitSoundOnEntity( harvester, HARVESTER_SND_STARTUP )
	fd_harvester.rings.Anim_Play( HARVESTER_ANIM_ACTIVATING )
	wait 4
	harvester.SetNoTarget( false )
	fd_harvester.rings.Anim_Play( HARVESTER_ANIM_ACTIVE )
	int lastShieldHealth = harvester.GetShieldHealth()
	generateBeamFX( fd_harvester )
	generateShieldFX( fd_harvester )
	EmitSoundOnEntity( harvester, HARVESTER_SND_HEALTHY )
	bool isRegening = false // stops the regenning sound to keep stacking on top of each other
	int shieldregenpercent

	while ( IsHarvesterAlive( harvester ) )
	{
		float currentTime = Time()
		float deltaTime = currentTime -lastTime

		if ( IsValid( fd_harvester.particleShield ) )
		{
			vector shieldColor = GetShieldTriLerpColor( 1.0 - ( harvester.GetShieldHealth().tofloat() / harvester.GetShieldHealthMax().tofloat() ) )
			if( GetGlobalNetTime( "FD_harvesterInvulTime" ) > Time() )
				EffectSetControlPointVector( fd_harvester.particleShield, 1, < 255, 192, 96 > )
			else
				EffectSetControlPointVector( fd_harvester.particleShield, 1, shieldColor )
		}

		if( IsValid( fd_harvester.particleBeam ) )
		{
			vector beamColor = GetHarvesterBeamTriLerpColor( 1.0 - ( harvester.GetHealth().tofloat() / harvester.GetMaxHealth().tofloat() ) )
			if( harvester.GetHealth() > 1 )
				EffectSetControlPointVector( fd_harvester.particleBeam, 1, beamColor )
		}

		if ( fd_harvester.harvester.GetShieldHealth() == 0 )
			if( IsValid( fd_harvester.particleShield ) )
				fd_harvester.particleShield.Destroy()

		if ( ( ( currentTime-fd_harvester.lastDamage ) >= GENERATOR_SHIELD_REGEN_DELAY ) && ( harvester.GetShieldHealth() < harvester.GetShieldHealthMax() ) )
		{
			if( !IsValid( fd_harvester.particleShield ) )
				generateShieldFX( fd_harvester )

			//printt((currentTime-fd_harvester.lastDamage))

			if( file.harvesterShieldDown )
				EmitSoundOnEntity( harvester, HARVESTER_SND_SHIELDFROMZERO )

			if (!isRegening)
			{
				if( !file.harvesterShieldDown )
				{
					EmitSoundOnEntity( harvester, HARVESTER_SND_SHIELDFROMMID )
					EmitSoundOnEntity( harvester, HARVESTER_SND_SHIELDREGENLOOP )
				}
				file.harvesterShieldDown = false
				if ( GetGlobalNetBool( "FD_waveActive" ) && harvester.GetShieldHealth() < harvester.GetShieldHealthMax() / 2 )
				{
					if( RandomInt( 100 ) > 50 )
						PlayFactionDialogueToTeam( "fd_baseShieldRecharging", TEAM_MILITIA )
					else
						PlayFactionDialogueToTeam( "fd_baseShieldRechargingShort", TEAM_MILITIA )
				}
				shieldregenpercent = harvester.GetShieldHealth()
				isRegening = true
			}

			float newShieldHealth = ( harvester.GetShieldHealthMax() / GENERATOR_SHIELD_REGEN_TIME * deltaTime ) + harvester.GetShieldHealth()

			if ( newShieldHealth >= harvester.GetShieldHealthMax() )
			{
				StopSoundOnEntity( harvester, HARVESTER_SND_SHIELDREGENLOOP )
				harvester.SetShieldHealth( harvester.GetShieldHealthMax() )
				EmitSoundOnEntity( harvester, HARVESTER_SND_SHIELDFULL )
				if( GetGlobalNetBool( "FD_waveActive" ) && shieldregenpercent <= ( harvester.GetShieldHealthMax() * 0.85 ) ) //Only talk about Harvester shield back up if shield drops below 85% and during waves, prevents too much dialogue cutting just for this
					PlayFactionDialogueToTeam( "fd_baseShieldUp", TEAM_MILITIA )
				isRegening = false
			}
			
			else
				harvester.SetShieldHealth( newShieldHealth )
		}
		
		else if ( ( ( currentTime-fd_harvester.lastDamage ) < GENERATOR_SHIELD_REGEN_DELAY ) && ( harvester.GetShieldHealth() < harvester.GetShieldHealthMax() ) )
			isRegening = false

		if ( lastShieldHealth > 0 && harvester.GetShieldHealth() == 0 )
		{
			EmitSoundOnEntity( harvester, HARVESTER_SND_SHIELDBREAK )
			PlayFactionDialogueToTeam( "fd_baseShieldDown", TEAM_MILITIA )
			file.harvesterShieldDown = true
		}

		lastShieldHealth = harvester.GetShieldHealth()
		lastTime = currentTime
		WaitFrame()
	}
}

bool function IsHarvesterAlive( entity harvester )
{
	if ( harvester == null )
		return false
	if ( !harvester.IsValidInternal() )
		return false
	if( !harvester.IsEntAlive() )
		return false

	return harvester.GetHealth() > 1
}

void function MonitorHarvesterProximity( entity harvester )
{
	harvester.EndSignal( "OnDestroy" )
	
	while( IsHarvesterAlive( harvester ) )
	{
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( IsAlive( player ) && Distance( player.GetOrigin(), harvester.GetOrigin() ) <= FD_HARVESTER_PERIMETER_DIST )
			{
				if( player in file.playerAwardStats )
					file.playerAwardStats[player]["timeNearHarvester"] += 1.0
			}
		}
		
		wait 1
	}
}










												  
/* Dropship Functions
██████  ██████   ██████  ██████  ███████ ██   ██ ██ ██████      ███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████ 
██   ██ ██   ██ ██    ██ ██   ██ ██      ██   ██ ██ ██   ██     ██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██      
██   ██ ██████  ██    ██ ██████  ███████ ███████ ██ ██████      █████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████ 
██   ██ ██   ██ ██    ██ ██           ██ ██   ██ ██ ██          ██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██ 
██████  ██   ██  ██████  ██      ███████ ██   ██ ██ ██          ██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████ 
*/

bool function FD_PlayerInDropship( entity player )
{
	if( !IsValid( file.dropship ) )
		return false

	if( !IsValidPlayer( player ) )
		return false

	foreach ( entity dropshipPlayer in file.playersInDropship )
		if ( dropshipPlayer == player )
			return true

	return false
}

void function FD_SpawnPlayerDroppod( entity player )
{
	vector PodOrigin = FD_DropPodSpawns[ RandomInt( FD_DropPodSpawns.len() ) ]
	int PodAngle = RandomIntRange( 0, 359 )
	
	entity pod = CreateDropPod( PodOrigin, < 0, 0, 0 > )
	SetTeam( pod, TEAM_MILITIA )
	InitFireteamDropPod( pod )
	player.SetOrigin( PodOrigin )
	player.SetAngles( < 0, PodAngle, 0 > )
	player.SetParent( pod, "ATTACH", true )
	player.MakeInvisible()
	HolsterAndDisableWeapons( player )
	player.DisableWeaponViewModel()
	
	waitthread LaunchAnimDropPod( pod, "pod_testpath", PodOrigin, < 0, PodAngle, 0 > )
	thread DropPodActiveThink( pod )
	pod.NotSolid()
	if( IsValidPlayer( player ) )
	{
		player.MakeVisible()
		player.ClearParent()
		player.EnableWeaponViewModel()
		DeployAndEnableWeapons( player )
		thread FD_PlayerRespawnGrace( player )
	}
}

void function FD_DropshipSpawnDropship()
{
	array<string> anims = GetRandomDropshipDropoffAnims()
	asset model = GetFlightPathModel( "fp_crow_model" )
	
	file.playersInShip = 0
	file.dropshipState = eDropshipState.InProgress
	file.dropship = CreateDropship( TEAM_MILITIA, FD_spawnPosition , FD_spawnAngles )

	file.dropship.SetModel( $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" )
	file.dropship.SetValueForModelKey( $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" )

	DispatchSpawn( file.dropship )
	file.dropship.SetModel( $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" )
	file.dropship.SetInvulnerable()
	NPC_NoTarget( file.dropship )

	//waitthread WarpinEffect( model, anims[0], FD_spawnPosition , FD_spawnAngles ) This doesnt work because it requires waitthread and if we do it, players doesnt respawn on dropship at all
	thread PlayAnim( file.dropship, FD_DropshipGetAnimation() )
	file.dropship.Anim_ScriptedAddGestureSequence( "dropship_coop_respawn", true )
	file.dropship.WaitSignal( "deploy" )
	file.dropshipState = eDropshipState.Returning
	
	foreach( int i, entity player in file.playersInDropship )
	{
		if( IsValid( player ) )
			thread FD_DropshipDropPlayer( player, i )
	}
	
	if ( file.playersInDropship.len() > 0 && GetGameState() == eGameState.Playing ) //Only one player in dropship is needed to warn about them respawning
	{
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( file.playersInDropship.contains( player ) )
				continue
			else
				PlayFactionDialogueToPlayer( "fd_pilotRespawn", player )
		}
	}
	
	wait 4
	
	//file.dropship.Anim_ScriptedAddGestureSequence( "dropship_close_doorR", false )
	
	wait 4
	
	file.playersInDropship.clear()
	file.playersInShip = 0 //Do it again in here to avoid dropship not appearing anymore after a while if theres too many players in a match
	file.dropshipState = eDropshipState.Idle
}

void function FD_DropshipDropPlayer( entity player, int playerDropshipIndex )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	//check the player
	if( IsValid( player ) && !player.IsTitan() )
	{
		FirstPersonSequenceStruct jumpSequence
		jumpSequence.firstPersonAnim = DROPSHIP_EXIT_ANIMS_POV[ playerDropshipIndex ]
		jumpSequence.thirdPersonAnim = DROPSHIP_EXIT_ANIMS[ playerDropshipIndex ]
		jumpSequence.attachment = "ORIGIN"
		jumpSequence.blendTime = 0.0
		jumpSequence.hideProxy = true
		jumpSequence.viewConeFunction = ViewConeNarrow

		#if BATTLECHATTER_ENABLED
		if( playerDropshipIndex == 0 )
			PlayBattleChatterLine( player, "bc_pIntroChat" )
		#endif
		
		thread FirstPersonSequence( jumpSequence, player, file.dropship )
		WaittillAnimDone( player )
		
		if( IsValid( player ) ) //Check again because the delay
		{
			player.ClearParent()
			ClearPlayerAnimViewEntity( player )
			thread FD_PlayerRespawnGrace( player )
		}
	}
}

void function FD_PlayerRespawnGrace( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd( function() : ( player )
	{
		if ( IsValid( player ) )
		{
			player.Highlight_SetParam( 1, 0, HIGHLIGHT_COLOR_FRIENDLY )
			player.ClearInvulnerable()
			player.SetNoTarget( false )
		}
	})
	
	wait 0.1
	player.ConsumeDoubleJump() //Dropship case scenario
	wait 5.0
}

void function FD_DropshipSetAnimationOverride(string animation)
{
	file.animationOverride = animation
}

string function FD_DropshipGetAnimation()
{
	if(file.animationOverride!="")
	return file.animationOverride

	switch( GetMapName() )
	{
		case "mp_homestead":
			return "dropship_coop_respawn_homestead" //Homestead Flight path has a very very jank coordinate where the drop point actually is
		case "mp_colony02":
			return "dropship_coop_respawn_lagoon" //Could use the default animation, but this one works nicely for Colony
		case "mp_complex3":
		case "mp_grave":
			return "dropship_coop_respawn_outpost" //Boomtown has low ceiling and this one matches perfectly for it (default clips alot into ceiling geo)
		case "mp_thaw":
			return "dropship_coop_respawn_overlook"
			
		/* Those here doesn't even fit any map, theyre just legacy assets from Titanfall 1 since those map names are from there
		case "mp_wargames": Despite this one literally saying wargames, the flight path it does clips into the buildings
			return "dropship_coop_respawn_wargames"
		case "mp_digsite":
			return "dropship_coop_respawn_digsite" */
	}
	return "dropship_coop_respawn"
}











/* Score System
███████  ██████  ██████  ██████  ███████     ███████ ██    ██ ███████ ████████ ███████ ███    ███ 
██      ██      ██    ██ ██   ██ ██          ██       ██  ██  ██         ██    ██      ████  ████ 
███████ ██      ██    ██ ██████  █████       ███████   ████   ███████    ██    █████   ██ ████ ██ 
     ██ ██      ██    ██ ██   ██ ██               ██    ██         ██    ██    ██      ██  ██  ██ 
███████  ██████  ██████  ██   ██ ███████     ███████    ██    ███████    ██    ███████ ██      ██ 
*/

void function UpdatePlayerScoreboard( entity player )
{
	player.SetPlayerGameStat( PGS_DETONATION_SCORE, player.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + player.GetPlayerGameStat( PGS_DEFENSE_SCORE ) )
}

void function FD_UsedCoreCallback( entity titan, entity weapon )
{
	if( !( titan in file.players ) )
		return
		
	if( titan in file.playerAwardStats )
		file.playerAwardStats[titan]["coresUsed"] += 1.0
}

void function FD_StunLaserHealTeammate( entity player, entity target, int shieldRestoreAmount )
{
	if( IsValidPlayer( player ) && player in file.players )
	{
		if( player in file.playerAwardStats )
			file.playerAwardStats[player]["heals"] += float( shieldRestoreAmount )
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, shieldRestoreAmount / 100 )
		UpdatePlayerScoreboard( player )
	}
}

void function FD_SmokeHealTeammate( entity player, entity target, int shieldRestoreAmount )
{
	if( IsValidPlayer( player ) && player in file.players )
	{
		if( player in file.playerAwardStats )
			file.playerAwardStats[player]["heals"] += float( shieldRestoreAmount )
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, shieldRestoreAmount / 100 )
		UpdatePlayerScoreboard( player )
	}
}

void function FD_BatteryHealTeammate( entity rider, entity titan, entity battery )
{
	entity BatteryParent = battery.GetParent()
	entity TargetTitan
	entity soul = titan.GetTitanSoul()
	int healingAmount = GetSegmentHealthForTitan( titan )
	int shieldHealth = soul.GetShieldHealth()
	int shieldMaxHealth = soul.GetShieldHealthMax()
	int shieldDifference = shieldMaxHealth - shieldHealth
	bool batteryIsAmped = IsAmpedBattery( battery )
	float ampedHealthSegmentFrac = GetCurrentPlaylistVarFloat( "amped_battery_health_frac", 2.0 )
	float healthSegmentFrac = GetCurrentPlaylistVarFloat( "battery_health_frac", 0.5 )
	float frac = batteryIsAmped ? ampedHealthSegmentFrac : healthSegmentFrac
	int addHealth = int( healingAmount * frac )
	int totalHealth = minint( titan.GetMaxHealth(), titan.GetHealth() + addHealth )
	int TotalHealing = shieldDifference + totalHealth
	int HealScore = TotalHealing / 100
	
	if( titan.IsPlayer() )
		TargetTitan = titan
	else if( titan.GetBossPlayer() != null )
		TargetTitan = titan.GetBossPlayer()
	else
		return

	if( BatteryParent == TargetTitan )
		return

	if( IsValidPlayer( rider ) )
	{
		AddPlayerScore( rider, "FDTeamHeal" )
		if( rider in file.playerAwardStats )
			file.playerAwardStats[rider]["heals"] += float( TotalHealing )
		rider.AddToPlayerGameStat( PGS_DEFENSE_SCORE, HealScore )
		UpdatePlayerScoreboard( rider )
	}
}

void function FD_OnArcTrapTriggered( entity victim, var damageInfo )
{
	entity owner = DamageInfo_GetAttacker( damageInfo )

	if( !IsValidPlayer( owner ) )
		return

	AddPlayerScore( owner, "FDArcTrapTriggered" )
	file.players[owner].defenseScoreThisRound++
	UpdatePlayerStat( owner, "fd_stats", "arcMineZaps" )
}

void function FD_OnArcWaveDamage( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if( !IsValidPlayer( attacker ) )
		return

	AddPlayerScore( attacker, "FDArcWave" )
	file.players[attacker].defenseScoreThisRound++
}

void function FD_OnTetherTrapTriggered( entity owner, entity endEnt )
{
	if( !IsValidPlayer( owner ) )
		return

	AddPlayerScore( owner, "FDTetherTriggered" )
	file.players[owner].defenseScoreThisRound++
}

void function FD_OnSonarStart( entity ent, vector position, int sonarTeam, entity sonarOwner )
{
	if( !IsValidPlayer( sonarOwner ) )
		return

	AddPlayerScore( sonarOwner, "FDSonarPulse" )//Triggers for every enemy revealed
	file.players[sonarOwner].defenseScoreThisRound++
}

void function IncrementPlayerstat_TurretRevives( entity turret, entity player, entity owner )
{
	if( IsValidPlayer( owner ) )
	{
		if( player in file.playerAwardStats )
			file.playerAwardStats[player]["turretsRepaired"]++
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_RepairTurret" )
		AddPlayerScore( player, "FDRepairTurret" )
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, FD_SCORE_REPAIR_TURRET )
		UpdatePlayerScoreboard( player )
		
		if( player != owner )
			MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_TurretRepair, null, player, owner.GetEncodedEHandle() )
	}
}










/* Tool functions
████████  ██████   ██████  ██          ███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████ 
   ██    ██    ██ ██    ██ ██          ██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██      
   ██    ██    ██ ██    ██ ██          █████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████ 
   ██    ██    ██ ██    ██ ██          ██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██ 
   ██     ██████   ██████  ███████     ██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████ 
*/

bool function isFinalWave()
{
	return ( ( GetGlobalNetInt( "FD_currentWave" ) + 1 ) == GetGlobalNetInt( "FD_totalWaves" ) )
}

bool function isSecondWave()
{
	return ( (GetGlobalNetInt( "FD_currentWave" ) + 1 ) == 1 )
}

//Idk the precise behavior of the summary panel in vanilla, but this is the closest i got so far
//IMC players gains nothing because PvP on FD is an exploit and should actually reward nothing for these "clever" people
void function RegisterPostSummaryScreenForMatch( bool matchwon )
{
	//50% of enemies defeated in a wave counts a Milestone for the current wave
	int WaveMilestone = GetGlobalNetInt( "FD_AICount_Current" )
	if( WaveMilestone <= GetGlobalNetInt( "FD_AICount_Total" ) / 2 )
		WaveMilestone = 1
	else
		WaveMilestone = 0
	
	int Composition = 1
	
	if( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() >= 1 && !file.isLiveFireMap )
	{
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			int suitIndex1 = GetPersistentSpawnLoadoutIndex( player, "titan" )
			foreach( entity otherplayer in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			{
				int suitIndex2 = GetPersistentSpawnLoadoutIndex( otherplayer, "titan" )
				if( player == otherplayer )
					continue
				
				if( suitIndex2 == suitIndex1 )
					Composition = 0
			}
		}
	}
	else
		Composition = 0
	
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		int fdXPamount = 0
		int suitIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )
		string titanRef = GetItemRefOfTypeByIndex( eItemTypes.TITAN, suitIndex )
		int matchesplayed = player.GetPersistentVarAsInt( "titanStats[" + titanRef + "].matchesByDifficulty[" + difficultyLevel + "]" )
		player.SetPersistentVar( "titanStats[" + titanRef + "].matchesByDifficulty[" + difficultyLevel + "]", matchesplayed + 1 )
		
		int matchdiff = player.GetPersistentVarAsInt( "mapStats[" + GetMapName() + "].matchesByDifficulty[" + difficultyLevel + "]" )
		player.SetPersistentVar( "mapStats[" + GetMapName() + "].matchesByDifficulty[" + difficultyLevel + "]", matchdiff + 1 )
		
		player.SetPersistentVar( "matchWin", matchwon )
		player.SetPersistentVar( "matchComplete", true )
		player.SetPersistentVar( "isPostGameScoreboardValid", false )
		player.SetPersistentVar( "isFDPostGameScoreboardValid", true )
		player.SetPersistentVar( "lastFDDifficulty", difficultyLevel )
		player.SetPersistentVar( "lastFDTitanRef", titanRef )
		
		player.SetPersistentVar( "fd_match[" + eFDXPType.WAVES_COMPLETED + "]", expect int( player.s.completedwaves ) )
		player.SetPersistentVar( "fd_match[" + eFDXPType.WAVES_ATTEMPTED + "]", GetGlobalNetInt( "FD_currentWave" ) + WaveMilestone )
		player.SetPersistentVar( "fd_match[" + eFDXPType.PERFECT_COMPOSITION + "]", Composition )
		player.SetPersistentVar( "fd_match[" + eFDXPType.RETRIES_REMAINING + "]", GetGlobalNetInt( "FD_restartsRemaining" ) )
		
		player.SetPersistentVar( "fd_count[" + eFDXPType.WAVES_COMPLETED + "]", GetGlobalNetInt( "FD_totalWaves" ) )
		player.SetPersistentVar( "fd_count[" + eFDXPType.WAVES_ATTEMPTED + "]", GetGlobalNetInt( "FD_totalWaves" ) )
		player.SetPersistentVar( "fd_count[" + eFDXPType.PERFECT_COMPOSITION + "]", Composition )
		player.SetPersistentVar( "fd_count[" + eFDXPType.RETRIES_REMAINING + "]", 2 )
		
		fdXPamount += GetGlobalNetInt( "FD_restartsRemaining" )
		fdXPamount += expect int( player.s.completedwaves ) + Composition
		fdXPamount += GetGlobalNetInt( "FD_currentWave" ) + WaveMilestone
		
		if( matchwon )
		{
			int matchwins = player.GetPersistentVarAsInt( "mapStats[" + GetMapName() + "].winsByDifficulty[" + difficultyLevel + "]" )
			player.SetPersistentVar( "mapStats[" + GetMapName() + "].winsByDifficulty[" + difficultyLevel + "]", matchwins + 1 )
			
			if( file.titanPerfectWin && file.pilotPerfectWin && file.harvesterPerfectWin )
			{
				int matchperf = player.GetPersistentVarAsInt( "mapStats[" + GetMapName() + "].perfectMatchesByDifficulty[" + difficultyLevel + "]" )
				player.SetPersistentVar( "mapStats[" + GetMapName() + "].perfectMatchesByDifficulty[" + difficultyLevel + "]", matchperf + 1 )
			}
			
			Remote_CallFunction_NonReplay( player, "ServerCallback_SquadLeaderBonus", player.GetEncodedEHandle() )
			foreach( entity otherplayer in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			{
				if( player == otherplayer )
					continue
				
				Remote_CallFunction_NonReplay( player, "ServerCallback_SquadLeaderBonus", otherplayer.GetEncodedEHandle() )
			}
				
			switch( difficultyLevel )
			{
				case eFDDifficultyLevel.EASY:
					UpdatePlayerStat( player, "fd_stats", "easyWins" )
					player.SetPersistentVar( "fd_match[" + eFDXPType.EASY_VICTORY + "]", FD_XP_EASY_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.EASY_VICTORY + "]", FD_XP_EASY_WIN )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_EASY_BONUS_SCALE )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_EASY_BONUS_SCALE )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_EASY_WAVE_BONUS )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_EASY_WAVE_BONUS )
					fdXPamount += FD_XP_EASY_WIN
					break
				case eFDDifficultyLevel.NORMAL:
					UpdatePlayerStat( player, "fd_stats", "normalWins" )
					player.SetPersistentVar( "fd_match[" + eFDXPType.NORMAL_VICTORY + "]", FD_XP_NORMAL_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.NORMAL_VICTORY + "]", FD_XP_NORMAL_WIN )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_NORMAL_BONUS_SCALE )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_NORMAL_BONUS_SCALE )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_NORMAL_WAVE_BONUS )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_NORMAL_WAVE_BONUS )
					fdXPamount += FD_XP_NORMAL_WIN
					break
				case eFDDifficultyLevel.HARD:
					UpdatePlayerStat( player, "fd_stats", "hardWins" )
					player.SetPersistentVar( "fd_match[" + eFDXPType.HARD_VICTORY + "]", FD_XP_HARD_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.HARD_VICTORY + "]", FD_XP_HARD_WIN )
					player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_HARD_BONUS_SCALE )
					player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_HARD_BONUS_SCALE )
					player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_HARD_WAVE_BONUS )
					player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_HARD_WAVE_BONUS )
					fdXPamount += FD_XP_HARD_WIN + FD_XP_HARD_WAVE_BONUS + FD_XP_HARD_BONUS_SCALE
					break
				case eFDDifficultyLevel.MASTER:
					UpdatePlayerStat( player, "fd_stats", "masterWins" )
					player.SetPersistentVar( "fd_match[" + eFDXPType.MASTER_VICTORY + "]", FD_XP_MASTER_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.MASTER_VICTORY + "]", FD_XP_MASTER_WIN )
					player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_MASTER_BONUS_SCALE )
					player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_MASTER_BONUS_SCALE )
					player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_MASTER_WAVE_BONUS )
					player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_MASTER_WAVE_BONUS )
					fdXPamount += FD_XP_MASTER_WIN + FD_XP_MASTER_WAVE_BONUS + FD_XP_MASTER_BONUS_SCALE
					break
				case eFDDifficultyLevel.INSANE:
					UpdatePlayerStat( player, "fd_stats", "insaneWins" )
					player.SetPersistentVar( "fd_match[" + eFDXPType.INSANE_VICTORY + "]", FD_XP_INSANE_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.INSANE_VICTORY + "]", FD_XP_INSANE_WIN )
					player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_INSANE_BONUS_SCALE )
					player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_INSANE_BONUS_SCALE )
					player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_INSANE_WAVE_BONUS )
					player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_INSANE_WAVE_BONUS )
					player.SetPersistentVar( "fd_match[" + eFDXPType.RETRIES_REMAINING + "]", 0 )
					player.SetPersistentVar( "fd_count[" + eFDXPType.RETRIES_REMAINING + "]", 0 )
					fdXPamount += FD_XP_INSANE_WIN + FD_XP_INSANE_WAVE_BONUS + FD_XP_INSANE_BONUS_SCALE
					break
				unreachable
			}
		}
		
		player.SetPersistentVar( "fdTitanXP[" + titanRef + "]", FD_TitanGetPreviousXP( player, titanRef ) + fdXPamount )
		int startingLevel = FD_TitanGetLevelForXP( titanRef, FD_TitanGetPreviousXP( player, titanRef ) )
		int endingLevel = FD_TitanGetLevelForXP( titanRef, FD_TitanGetXP( player, titanRef ) )
		Player_GiveFDUnlockPoints( player, endingLevel - startingLevel )
		TitanLoadoutDef loadout = GetActiveTitanLoadout( player )
		AwardRandomItemsForFDTitanLevels( player, loadout.titanClass, startingLevel, endingLevel )
	}
	SetUIVar( level, "showGameSummary", true )
}

array<int> function getHighestEnemyAmountsForWave( int waveIndex )
{
	table<int,int> npcs
	npcs[eFD_AITypeIDs.TITAN_NUKE] <- 0
	npcs[eFD_AITypeIDs.TITAN_ARC] <- 0
	npcs[eFD_AITypeIDs.TITAN_MORTAR] <- 0
	npcs[eFD_AITypeIDs.TITAN] <- 0
	npcs[eFD_AITypeIDs.TICK] <- 0
	npcs[eFD_AITypeIDs.REAPER] <- 0
	npcs[eFD_AITypeIDs.SPECTRE_MORTAR] <- 0
	npcs[eFD_AITypeIDs.DRONE_CLOAK] <- 0
	npcs[eFD_AITypeIDs.SPECTRE] <- 0
	npcs[eFD_AITypeIDs.STALKER] <- 0
	npcs[eFD_AITypeIDs.DRONE] <- 0
	npcs[eFD_AITypeIDs.GRUNT] <- 0
	// npcs[eFD_AITypeIDs.RONIN] <- 0
	// npcs[eFD_AITypeIDs.NORTHSTAR] <- 0
	// npcs[eFD_AITypeIDs.SCORCH] <- 0
	// npcs[eFD_AITypeIDs.LEGION] <- 0
	// npcs[eFD_AITypeIDs.TONE] <- 0
	// npcs[eFD_AITypeIDs.ION] <- 0
	// npcs[eFD_AITypeIDs.MONARCH] <- 0
	// npcs[eFD_AITypeIDs.TITAN_SNIPER] <- 0


	foreach( WaveEvent e in waveEvents[waveIndex] )
	{
		if( e.spawnEvent.spawnAmount == 0 )
			continue
		switch( e.spawnEvent.spawnType )
		{
			case( eFD_AITypeIDs.TITAN ):
			case( eFD_AITypeIDs.RONIN ):
			case( eFD_AITypeIDs.NORTHSTAR ):
			case( eFD_AITypeIDs.SCORCH ):
			case( eFD_AITypeIDs.TONE ):
			case( eFD_AITypeIDs.ION ):
			case( eFD_AITypeIDs.MONARCH ):
			case( eFD_AITypeIDs.LEGION ):
			case( eFD_AITypeIDs.TITAN_SNIPER ):
				npcs[eFD_AITypeIDs.TITAN] += e.spawnEvent.spawnAmount
				break
			default:
				npcs[e.spawnEvent.spawnType] += e.spawnEvent.spawnAmount
		}
	}
	
	array<int> ret = []
	
	if( npcs[eFD_AITypeIDs.TITAN_NUKE] > 0 )
		ret.append( eFD_AITypeIDs.TITAN_NUKE )
		
	if( npcs[eFD_AITypeIDs.TITAN_ARC] > 0 )
		ret.append( eFD_AITypeIDs.TITAN_ARC )
		
	if( npcs[eFD_AITypeIDs.TITAN_MORTAR] > 0 )
		ret.append( eFD_AITypeIDs.TITAN_MORTAR )
		
	if( npcs[eFD_AITypeIDs.TITAN] > 0 )
		ret.append( eFD_AITypeIDs.TITAN )
		
	if( npcs[eFD_AITypeIDs.TICK] > 0 )
		ret.append( eFD_AITypeIDs.TICK )
		
	if( npcs[eFD_AITypeIDs.REAPER] > 0 )
		ret.append( eFD_AITypeIDs.REAPER )
		
	if( npcs[eFD_AITypeIDs.SPECTRE_MORTAR] > 0 )
		ret.append( eFD_AITypeIDs.SPECTRE_MORTAR )
		
	if( npcs[eFD_AITypeIDs.DRONE_CLOAK] > 0 )
		ret.append( eFD_AITypeIDs.DRONE_CLOAK )
		
	if( npcs[eFD_AITypeIDs.SPECTRE] > 0 )
		ret.append( eFD_AITypeIDs.SPECTRE )
		
	if( npcs[eFD_AITypeIDs.STALKER] > 0 )
		ret.append( eFD_AITypeIDs.STALKER )
		
	if( npcs[eFD_AITypeIDs.DRONE] > 0 )
		ret.append( eFD_AITypeIDs.DRONE )
		
	if( npcs[eFD_AITypeIDs.GRUNT] > 0 )
		ret.append( eFD_AITypeIDs.GRUNT )
	
	while( ret.len() < 9 ) //Fill empty slots for return
		ret.append( -1 )
	
	print( "ENEMIES ON THIS WAVE:" )
	foreach( int val in ret )
	{
		if( val == eFD_AITypeIDs.TITAN_NUKE )
			printt( "Nuke Titans:", GetGlobalNetInt( "FD_AICount_Titan_Nuke" ) )
		if( val == eFD_AITypeIDs.TITAN_ARC )
			printt( "Arc Titans:", GetGlobalNetInt( "FD_AICount_Titan_Arc" ) )
		if( val == eFD_AITypeIDs.TITAN_MORTAR )
			printt( "Mortar Titans:", GetGlobalNetInt( "FD_AICount_Titan_Mortar" ) )
		if( val == eFD_AITypeIDs.TITAN )
			printt( "Titans:", GetGlobalNetInt( "FD_AICount_Titan" ) )
		if( val == eFD_AITypeIDs.TICK )
			printt( "Ticks:", GetGlobalNetInt( "FD_AICount_Ticks" ) )
		if( val == eFD_AITypeIDs.REAPER )
			printt( "Reapers:", GetGlobalNetInt( "FD_AICount_Reaper" ) )
		if( val == eFD_AITypeIDs.SPECTRE_MORTAR )
			printt( "Mortar Spectres:", GetGlobalNetInt( "FD_AICount_Spectre_Mortar" ) )
		if( val == eFD_AITypeIDs.DRONE_CLOAK )
			printt( "Cloak Drones:", GetGlobalNetInt( "FD_AICount_Drone_Cloak" ) )
		if( val == eFD_AITypeIDs.SPECTRE )
			printt( "Spectres:", GetGlobalNetInt( "FD_AICount_Spectre" ) )
		if( val == eFD_AITypeIDs.STALKER )
			printt( "Stalkers:", GetGlobalNetInt( "FD_AICount_Stalker" ) )
		if( val == eFD_AITypeIDs.DRONE )
			printt( "Drones:", GetGlobalNetInt( "FD_AICount_Drone" ) )
		if( val == eFD_AITypeIDs.GRUNT )
			printt( "Grunts:", GetGlobalNetInt( "FD_AICount_Grunt" ) )
	}
	return ret
}

void function SetEnemyAmountNetVars( int waveIndex )
{
	int total = 0
	table<int,int> npcs
	npcs[eFD_AITypeIDs.TITAN_NUKE] <- 0
	npcs[eFD_AITypeIDs.TITAN_ARC] <- 0
	npcs[eFD_AITypeIDs.TITAN_MORTAR] <- 0
	npcs[eFD_AITypeIDs.TITAN] <- 0
	npcs[eFD_AITypeIDs.TICK] <- 0
	npcs[eFD_AITypeIDs.REAPER] <- 0
	npcs[eFD_AITypeIDs.SPECTRE_MORTAR] <- 0
	npcs[eFD_AITypeIDs.DRONE_CLOAK] <- 0
	npcs[eFD_AITypeIDs.SPECTRE] <- 0
	npcs[eFD_AITypeIDs.STALKER] <- 0
	npcs[eFD_AITypeIDs.DRONE] <- 0
	npcs[eFD_AITypeIDs.GRUNT] <- 0
	// npcs[eFD_AITypeIDs.RONIN] <- 0
	// npcs[eFD_AITypeIDs.NORTHSTAR] <- 0
	// npcs[eFD_AITypeIDs.SCORCH] <- 0
	// npcs[eFD_AITypeIDs.LEGION] <- 0
	// npcs[eFD_AITypeIDs.TONE] <- 0
	// npcs[eFD_AITypeIDs.ION] <- 0
	// npcs[eFD_AITypeIDs.MONARCH] <- 0
	// npcs[eFD_AITypeIDs.TITAN_SNIPER] <- 0


	foreach( WaveEvent e in waveEvents[waveIndex] )
	{
		if( e.spawnEvent.spawnAmount == 0 )
			continue
		
		switch( e.spawnEvent.spawnType )
		{
			case( eFD_AITypeIDs.TITAN ):
			case( eFD_AITypeIDs.RONIN ):
			case( eFD_AITypeIDs.NORTHSTAR ):
			case( eFD_AITypeIDs.SCORCH ):
			case( eFD_AITypeIDs.TONE ):
			case( eFD_AITypeIDs.ION ):
			case( eFD_AITypeIDs.MONARCH ):
			case( eFD_AITypeIDs.LEGION ):
			case( eFD_AITypeIDs.TITAN_SNIPER ):
				npcs[eFD_AITypeIDs.TITAN] += e.spawnEvent.spawnAmount
				break
			default:
				npcs[e.spawnEvent.spawnType] += e.spawnEvent.spawnAmount

		}
		total+= e.spawnEvent.spawnAmount
	}
	SetGlobalNetInt( "FD_AICount_Titan_Nuke", npcs[eFD_AITypeIDs.TITAN_NUKE] )
	SetGlobalNetInt( "FD_AICount_Titan_Arc", npcs[eFD_AITypeIDs.TITAN_ARC] )
	SetGlobalNetInt( "FD_AICount_Titan_Mortar", npcs[eFD_AITypeIDs.TITAN_MORTAR] )
	SetGlobalNetInt( "FD_AICount_Titan", npcs[eFD_AITypeIDs.TITAN] )
	SetGlobalNetInt( "FD_AICount_Ticks", npcs[eFD_AITypeIDs.TICK] )
	SetGlobalNetInt( "FD_AICount_Reaper", npcs[eFD_AITypeIDs.REAPER] )
	SetGlobalNetInt( "FD_AICount_Spectre_Mortar", npcs[eFD_AITypeIDs.SPECTRE_MORTAR] )
	SetGlobalNetInt( "FD_AICount_Drone_Cloak", npcs[eFD_AITypeIDs.DRONE_CLOAK] )
	SetGlobalNetInt( "FD_AICount_Spectre", npcs[eFD_AITypeIDs.SPECTRE] )
	SetGlobalNetInt( "FD_AICount_Stalker", npcs[eFD_AITypeIDs.STALKER] )
	SetGlobalNetInt( "FD_AICount_Drone", npcs[eFD_AITypeIDs.DRONE] )
	SetGlobalNetInt( "FD_AICount_Grunt", npcs[eFD_AITypeIDs.GRUNT] )
	SetGlobalNetInt( "FD_AICount_Current", total )
	SetGlobalNetInt( "FD_AICount_Total", total )
}

void function FD_WaveCleanup()
{
	foreach ( projectile in GetProjectileArray() ) //Arc Trap Handling
	{
		if ( projectile instanceof CProjectile || projectile instanceof CBaseGrenade )
		{
			if( projectile.e.fd_roundDeployed == GetGlobalNetInt( "FD_currentWave" ) )
				projectile.Destroy()
		}
	}
	
	foreach ( entity npc in GetNPCArray() ) //Turret Handling
	{
		if( IsValidPlayer( npc.GetBossPlayer() ) && npc.e.fd_roundDeployed != GetGlobalNetInt( "FD_currentWave" ) || npc.GetClassName() == "npc_turret_mega" )
			continue
		if ( IsValid( npc ) )
			npc.Destroy()
	}
	
	if( IsValid( fd_harvester.harvester ) )
		fd_harvester.harvester.Destroy() //Destroy harvester after match over
}

int function getHintForTypeId( int typeId )
{
	//this is maybe a bit of an naive aproch
	switch( typeId )
		{
			case eFD_AITypeIDs.TITAN_NUKE:
				return ( 348 + RandomIntRangeInclusive( 0, 1 ) )
			case eFD_AITypeIDs.TITAN_ARC:
				return ( 350 + RandomIntRangeInclusive( 0, 1 ) )
			case eFD_AITypeIDs.TITAN_MORTAR:
				return ( 352 + RandomIntRangeInclusive( 0, 1 ) )
			case eFD_AITypeIDs.GRUNT:
				return 354
			case eFD_AITypeIDs.SPECTRE:
				return 355
			case eFD_AITypeIDs.SPECTRE_MORTAR:
				return ( 356 + RandomIntRangeInclusive( 0, 1 ) )
			case eFD_AITypeIDs.STALKER:
				if( RandomIntRangeInclusive( 0, 1 ) == 0 )
					return 358
				else
					return 361
			case eFD_AITypeIDs.REAPER:
				return ( 359 + RandomIntRangeInclusive( 0, 1 ) )
			case eFD_AITypeIDs.DRONE:
				return 362
			case eFD_AITypeIDs.TITAN_SNIPER:
				return ( 371 + RandomIntRangeInclusive( 0, 2 ) )
			default:
				return ( 363 + RandomIntRangeInclusive( 0, 7 ) )
		}
	unreachable
}

string function GetTargetNameForID( int typeId )
{
	switch( typeId )
		{
			case eFD_AITypeIDs.TITAN_NUKE:
				return "npc_titan_nuke"
			case eFD_AITypeIDs.LEGION:
				return "npc_titan_ogre_minigun"
			case eFD_AITypeIDs.TITAN_ARC:
				return "empTitan"
			case eFD_AITypeIDs.RONIN:
				return "npc_titan_stryder_leadwall"
			case eFD_AITypeIDs.TITAN_MORTAR:
				return "npc_titan_mortar"
			case eFD_AITypeIDs.TONE:
				return "npc_titan_atlas_tracker"
			case eFD_AITypeIDs.TITAN_SNIPER:
				return "npc_titan_sniper"
			case eFD_AITypeIDs.NORTHSTAR:
				return "npc_titan_stryder_sniper"
			case eFD_AITypeIDs.ION:
				return "npc_titan_atlas_stickybomb"
			case eFD_AITypeIDs.SCORCH:
				return "npc_titan_ogre_meteor"
			case eFD_AITypeIDs.MONARCH:
				return "npc_titan_atlas_vanguard"
			case eFD_AITypeIDs.GRUNT:
				return "grunt"
			case eFD_AITypeIDs.SPECTRE:
				return "spectre"
			case eFD_AITypeIDs.SPECTRE_MORTAR:
				return "mortar_spectre"
			case eFD_AITypeIDs.STALKER:
				return "stalker"
			case eFD_AITypeIDs.REAPER:
				return "reaper"
			case eFD_AITypeIDs.TICK:
				return "tick"
			case eFD_AITypeIDs.DRONE:
				return "drone"
			case eFD_AITypeIDs.DRONE_CLOAK:
				return "Cloak Drone" // have to be like this for some reason in cl_gamemode_fd
			default:
				return "titan"
		}
	unreachable
}

string function GetAiNetIdFromTargetName( string targetName )
{
	switch ( targetName )
	{
		case "titan":
		case "sniperTitan":
		case "npc_titan_ogre_meteor_boss_fd":
		case "npc_titan_ogre_meteor":
		case "npc_titan_ogre_minigun_boss_fd":
		case "npc_titan_ogre_minigun":
		case "npc_titan_atlas_stickybomb_boss_fd":
		case "npc_titan_atlas_stickybomb":
		case "npc_titan_atlas_tracker_boss_fd":
		case "npc_titan_atlas_tracker":
		case "npc_titan_stryder_leadwall_boss_fd":
		case "npc_titan_stryder_leadwall":
		case "npc_titan_stryder_sniper_boss_fd":
		case "npc_titan_stryder_sniper":
		case "npc_titan_sniper":
		case "npc_titan_sniper_tone":
		case "npc_titan_atlas_vanguard_boss_fd":
		case "npc_titan_atlas_vanguard":
			return "FD_AICount_Titan"
		case "empTitan":
		case "npc_titan_arc":
			return "FD_AICount_Titan_Arc"
		case "mortarTitan":
		case "npc_titan_mortar":
			return "FD_AICount_Titan_Mortar"
		case "nukeTitan":
		case "npc_titan_nuke":
			return "FD_AICount_Titan_Nuke"
		case "npc_soldier":
		case "grunt":
			return "FD_AICount_Grunt"
		case "spectre":
			return "FD_AICount_Spectre"
		case "mortar_spectre":
			return "FD_AICount_Spectre_Mortar"
		case "npc_stalker":
		case "stalker":
			return "FD_AICount_Stalker"
		case "npc_super_spectre":
		case "reaper":
			return "FD_AICount_Reaper"
		case "npc_drone":
		case "drone":
			return "FD_AICount_Drone"
		case "cloakedDrone":
		case "Cloak Drone":
			return "FD_AICount_Drone_Cloak"
		case "tick":
			return "FD_AICount_Ticks"
	}
	printt( "unknown target name ", targetName )
	return ""
}

void function FD_EmitSoundOnEntityOnlyToPlayer( entity targetEntity, entity player, string alias )
{
	if( !IsValid( targetEntity ) )
		return

	if( !IsValidPlayer( player ) )
		return

	EmitSoundOnEntityOnlyToPlayer( targetEntity, player, alias )
}

function FD_AttemptToRepairTurrets()
{
	//Repair turret on here rather than in the executeWave(), softlocking reasons
	foreach (entity turret in GetEntArrayByClass_Expensive( "npc_turret_sentry" ) )
		RepairTurret_WaveBreak( turret )
}

void function PvPGlitchMonitor( entity player )
{
	player.EndSignal( "OnDestroy" )
	
	player.s.isbeingmonitored = true
	while( IsValidPlayer( player ) && player.s.didthepvpglitch && player.s.isbeingmonitored && GetGlobalNetBool( "FD_waveActive" ) )
	{
		if( IsAlive( player ) )
		{
			if( player.GetTeam() == TEAM_MILITIA ) //Ensure this player who tried to be "funny" and went into the IMC side stays there for the whole wave
				SetTeam( player, TEAM_IMC )
			
			PlayerEarnMeter_AddOwnedFrac( player, 0.02 ) //At least make them buildup titan meter faster since they gain nothing for killing the defending players
		}
		
		wait 1
	}
}

function FD_UpdateTitanBehavior()
{
	if( !GetGlobalNetBool( "FD_waveActive" ) )
	{
		foreach (entity titan in GetEntArrayByClass_Expensive( "npc_titan" ) )
		{
			if( titan.GetTeam() == TEAM_MILITIA )
				titan.EnableNPCMoveFlag( NPCMF_WALK_NONCOMBAT | NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_DISABLE_DANGEROUS_AREA_DISPLACEMENT )
		}
	}
	else
	{
		foreach (entity titan in GetEntArrayByClass_Expensive( "npc_titan" ) )
		{
			if( titan.GetTeam() == TEAM_MILITIA )
				titan.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT | NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_DISABLE_DANGEROUS_AREA_DISPLACEMENT )
		}
	}
}

void function EliteTitanElectricSmoke( entity titan )
{
	Assert( IsValid( titan ) && titan.IsTitan(), "Entity is not a Titan: " + titan )
	
	entity soul = titan.GetTitanSoul()
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	
	wait RandomFloatRange( 1.0, 2.0 )
	
	if( IsValid( titan ) && IsValid( soul ) && !titan.ContextAction_IsMeleeExecution() )
	{
		GiveOffhandElectricSmoke( titan )
		entity smokeinventory = titan.GetOffhandWeapon( OFFHAND_INVENTORY )
		if ( smokeinventory != null )
		{
			if( GetTitanCharacterName( titan ) == "vanguard" && !smokeinventory.HasMod( "maelstrom" ) )
				smokeinventory.AddMod( "maelstrom" )
			
			EliteTitanSmokescreen( titan, smokeinventory )
		}
	}
}

void function EliteTitanSmokescreen( entity ent, entity weapon )
{
	SmokescreenStruct smokescreen
	array<entity> primaryWeapons = ent.GetMainWeapons()
	
	if( !primaryWeapons.len() )
		return
		
	entity maingun = primaryWeapons[0]
	if ( IsValid( maingun ) && maingun.HasMod( "fd_vanguard_utility_1" ) )
		smokescreen.smokescreenFX = FX_ELECTRIC_SMOKESCREEN_HEAL
	smokescreen.isElectric = true
	smokescreen.ownerTeam = ent.GetTeam()
	smokescreen.attacker = ent
	smokescreen.inflictor = ent
	smokescreen.weaponOrProjectile = weapon
	smokescreen.damageInnerRadius = 320.0
	smokescreen.damageOuterRadius = 375.0
	smokescreen.dangerousAreaRadius = 1.0
	if ( weapon.HasMod( "maelstrom" ) )
	{
		smokescreen.dpsPilot = 90
		smokescreen.dpsTitan = 1350
		smokescreen.deploySound1p = SFX_SMOKE_DEPLOY_BURN_1P
		smokescreen.deploySound3p = SFX_SMOKE_DEPLOY_BURN_3P
	}
	else
	{
		smokescreen.dpsPilot = 45
		smokescreen.dpsTitan = 450
	}
	smokescreen.damageDelay = 1.0
	smokescreen.blockLOS = false

	vector eyeAngles = <0.0, ent.EyeAngles().y, 0.0>
	smokescreen.angles = eyeAngles

	vector forward = AnglesToForward( eyeAngles )
	vector testPos = ent.GetOrigin() + forward * 240.0
	vector basePos = testPos

	float trace = TraceLineSimple( ent.EyePosition(), testPos, ent )
	if ( trace != 1.0 )
		basePos = ent.GetOrigin()

	float fxOffset = 200.0
	float fxHeightOffset = 148.0

	smokescreen.origin = basePos

	smokescreen.fxOffsets = [ < -fxOffset, 0.0, 20.0>,
							  <0.0, fxOffset, 20.0>,
							  <0.0, -fxOffset, 20.0>,
							  <0.0, 0.0, fxHeightOffset>,
							  < -fxOffset, 0.0, fxHeightOffset> ]

	Smokescreen( smokescreen )
}











/* NS Extra Content
███    ██ ███████     ███████ ██   ██ ████████ ██████   █████       ██████  ██████  ███    ██ ████████ ███████ ███    ██ ████████ 
████   ██ ██          ██       ██ ██     ██    ██   ██ ██   ██     ██      ██    ██ ████   ██    ██    ██      ████   ██    ██    
██ ██  ██ ███████     █████     ███      ██    ██████  ███████     ██      ██    ██ ██ ██  ██    ██    █████   ██ ██  ██    ██    
██  ██ ██      ██     ██       ██ ██     ██    ██   ██ ██   ██     ██      ██    ██ ██  ██ ██    ██    ██      ██  ██ ██    ██    
██   ████ ███████     ███████ ██   ██    ██    ██   ██ ██   ██      ██████  ██████  ██   ████    ██    ███████ ██   ████    ██    
*/

void function HT_BatteryPort( entity batteryPort, entity turret )
{
	batteryPort.kv.fadedist = 16384
	InitTurretBatteryPort( batteryPort )

	SetTeam( batteryPort, turret.GetTeam() )
	batteryPort.s.relatedTurret <- turret
	batteryPort.s.isUsable <- HTBatteryPortUseCheck
	batteryPort.s.useBattery <- HTUseBatteryFunc
	batteryPort.s.hackAvaliable = false
	batteryPort.SetUsableByGroup( "friendlies pilot" )
}

function HTBatteryPortUseCheck( batteryPortvar, playervar )
{	
	entity batteryPort = expect entity( batteryPortvar )
	entity player = expect entity( playervar )
	entity turret = expect entity( batteryPort.s.relatedTurret )
    if( !IsValid( turret ) )
        return false

    return ( PlayerHasBattery( player ) && player.GetTeam() == turret.GetTeam() && turret.GetHealth() < turret.GetMaxHealth() )
}

function HTUseBatteryFunc( batteryPortvar, playervar )
{
	entity batteryPort = expect entity( batteryPortvar )
	entity player = expect entity( playervar )
    entity turret = expect entity( batteryPort.s.relatedTurret )
	
	if( !IsValid( player ) || turret.GetHealth() == turret.GetMaxHealth() )
		return
	
	if ( PlayerEarnMeter_Enabled() )
		PlayerEarnMeter_SetOwnedFrac( player, clamp( PlayerEarnMeter_GetOwnedFrac( player ) + 0.5, 0.0, 1.0 ) )
	
	if( player in file.playerAwardStats )
		file.playerAwardStats[player]["turretsRepaired"]++
	AddPlayerScore( player, "FDRepairTurret" )
	player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, FD_SCORE_REPAIR_TURRET )
	UpdatePlayerScoreboard( player )
	
	if ( turret.GetHealth() == 1 )
	{
		turret.EnableTurret()
		turret.DisableNPCFlag( NPC_IGNORE_ALL )
		MakeTurretVulnerable( turret )
	}
	
	turret.SetHealth( turret.GetMaxHealth() )
    turret.SetShieldHealth( 2500 )
}