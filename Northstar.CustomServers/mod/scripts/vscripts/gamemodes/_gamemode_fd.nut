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
	array< entity > deployedEntityThisRound
	float lastRespawn
	float lastTitanDrop
	float lastNearHarvester
	bool leaveHarvester
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
global table< string, array<vector> > routes
global array<entity> routeNodes
global array<entity> spawnedNPCs
global array<string> waveAnnouncement = []
global int difficultyLevel
global bool elitesAllowed
global bool titanfallblockAllowed
global bool useCustomFDLoad

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
	SetKillcamsEnabled( false )
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
	AddCallback_GameStateEnter( eGameState.Playing, startMainGameLoop )
	AddCallback_OnRoundEndCleanup( FD_NPCCleanup )
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

	//shop Callback
	SetBoostPurchaseCallback( FD_BoostPurchaseCallback )
	SetTeamReserveInteractCallback( FD_TeamReserveDepositOrWithdrawCallback )

	//Data Collection
	AddStunLaserHealCallback( FD_StunLaserHealTeammate )
	SetApplyBatteryCallback( FD_BatteryHealTeammate )
	AddSmokeHealCallback( FD_SmokeHealTeammate )
	SetUsedCoreCallback( FD_UsedCoreCallback )

	//todo:are pointValueOverride exist?
	//Score Event
	AddArcTrapTriggeredCallback( FD_OnArcTrapTriggered )
	AddArcWaveDamageCallback( FD_OnArcWaveDamage )
	AddOnTetherCallback( FD_OnTetherTrapTriggered )
	AddSonarStartCallback( FD_OnSonarStart )
	ScoreEvent_SetupEarnMeterValuesForFrontierDefense()
	
	difficultyLevel = FD_GetDifficultyLevel() //Refresh this only on map load, to avoid midgame commands messing up with difficulties (i.e setting mp_gamemode fd_hard midgame in a regular match through console on local host would immediately make Stalkers spawns with EPG)
	elitesAllowed = GetConVarBool( "ns_fd_allow_elite_titans" )
	titanfallblockAllowed = GetConVarBool( "ns_fd_allow_titanfall_block" )
	file.easymodeSmartPistol = GetConVarBool( "ns_fd_easymode_smartpistol" )
	
	Cvar_gruntgrenade = GetConVarString( "ns_fd_grunt_grenade" )
	Cvar_gruntweapons = GetConVarString( "ns_fd_grunt_primary_weapon" )
	FD_GruntWeapons = split( Cvar_gruntweapons, "," )
	Cvar_spectreweapons = GetConVarString( "ns_fd_spectre_primary_weapon" )
	FD_SpectreWeapons = split( Cvar_spectreweapons, "," )
	
	for( int i = 0; i < 20; i++ ) //Setup NPC array for Harvester Damage tracking
		file.harvesterDamageSource.append(0.0)
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
	
	ScoreEvent_SetEarnMeterValues( "LeechDrone", 0.0, 0.1 )
	ScoreEvent_SetEarnMeterValues( "LeechSpectre", 0.0, 0.1 )
	
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDAirDroneKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDGruntKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDSpectreKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDStalkerKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "FDSuperSpectreKilled" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "LeechDrone" ), eEventDisplayType.MEDAL )
	ScoreEvent_SetDisplayType( GetScoreEvent( "LeechSpectre" ), eEventDisplayType.MEDAL )
	
	ScoreEvent_SetXPValueWeapon( GetScoreEvent( "Mayhem" ), 1 )
	ScoreEvent_SetXPValueWeapon( GetScoreEvent( "Onslaught" ), 2 )
	
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
}

void function UpdateEarnMeter_ByPlayersInMatch()
{
	array<entity> numplayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
	
	switch( numplayers.len() )
	{
		case 0:
			ScoreEvent_SetEarnMeterValues( "FDAirDroneKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDGruntKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDSpectreKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDStalkerKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "FDSuperSpectreKilled", 0.0, 0.5 )
			ScoreEvent_SetEarnMeterValues( "Execution", 0.0, 0.5 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 1.0 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 1.0 )
			break
		case 1:
			ScoreEvent_SetEarnMeterValues( "FDAirDroneKilled", 0.0, 0.2 )
			ScoreEvent_SetEarnMeterValues( "FDGruntKilled", 0.0, 0.2 )
			ScoreEvent_SetEarnMeterValues( "FDSpectreKilled", 0.0, 0.2 )
			ScoreEvent_SetEarnMeterValues( "FDStalkerKilled", 0.0, 0.2 )
			ScoreEvent_SetEarnMeterValues( "FDSuperSpectreKilled", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "Execution", 0.0, 0.3 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.8 )
			ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.8 )
			break
		case 2:
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

bool function FD_ShouldAllowChangeLoadout( entity player )
{
	return ( !GetGlobalNetBool( "FD_waveActive" ) || player.GetTeam() == TEAM_IMC )
}

void function FD_BoostPurchaseCallback( entity player, BoostStoreData data )
{
	player.s.extracashnag = Time() + 30
	file.playerAwardStats[player]["moneySpent"] += float( data.cost )
}

void function FD_PlayerRespawnCallback( entity player )
{
	thread FD_PlayerRespawnThreaded( player )
}

void function FD_PlayerRespawnThreaded( entity player )
{
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
	
	if ( player.IsTitan() || !IsHarvesterAlive( fd_harvester.harvester ) || player.GetTeam() == TEAM_IMC )
		return
	
	if( file.dropshipState == eDropshipState.Returning || file.playersInShip >=4 || GetGameState() != eGameState.Playing || !GetGlobalNetBool( "FD_waveActive" ) || GetConVarBool( "ns_fd_disable_respawn_dropship" ) || file.isLiveFireMap )
	{
		//Teleport player to a more reliable location if they spawn on ground, some maps picks too far away spawns from the Harvester and Shop (i.e Colony, Homestead, Drydock)
		if( IsValidPlayer( player ) && !player.IsTitan() )
		{
			player.SetOrigin( FD_groundspawnPosition )
			player.SetAngles( FD_groundspawnAngles )
		}
		return
	}
	
	if( IsValidPlayer( player ) && !player.IsTitan() )
	{
		player.Highlight_SetParam( 1, 0, < 0, 0, 0 > )
		player.SetInvulnerable()
		player.SetNoTarget( true )
		ScreenFadeFromBlack( player, 1.5, 0.5 )
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

void function FD_TeamReserveDepositOrWithdrawCallback( entity player, string action, int amount )
{
	player.s.extracashnag = Time() + 30
	switch( action )
	{
		case "deposit":
			file.playerAwardStats[player]["moneyShared"] += float( amount )
			break
		case "withdraw":
			file.playerAwardStats[player]["moneyShared"] -= float( amount ) 
			break
	}
}

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
	if( timeAlive > file.playerAwardStats[victim]["longestLife"] )
		file.playerAwardStats[victim]["longestLife"] = timeAlive
	
	file.pilotPerfectWin = false //Remove perfect win
	
	if( GetGlobalNetInt( "FD_waveState") != WAVE_STATE_BREAK )
		file.players[victim].diedThisRound = true

	//play voicelines for amount of players alive
	array<entity> militiaplayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
	int deaths = 0
	foreach ( entity player in militiaplayers )
		if ( !IsAlive( player ) )
			deaths++

	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if ( player == victim )
			continue

		if ( deaths == 1 ) // only one pilot died
			PlayFactionDialogueToPlayer( "fd_singlePilotDown", player )
		else if ( deaths > 1 && deaths < militiaplayers.len() - 1 ) // multiple pilots died but at least one alive
			PlayFactionDialogueToPlayer( "fd_multiPilotDown", player )
		else if ( deaths == militiaplayers.len() - 1 ) // ur shit out of luck ur the only survivor
			PlayFactionDialogueToPlayer( "fd_onlyPlayerIsAlive", player )
	}
}

void function FD_UsedCoreCallback( entity titan, entity weapon )
{
	if( !( titan in file.players ) )
		return
		
	file.playerAwardStats[titan]["coresUsed"] += 1
}

void function GamemodeFD_InitPlayer( entity player )
{
	player_struct_fd data
	data.diedThisRound = false
	data.leaveHarvester = true
	file.players[player] <- data
	table<string, float> awardStats
	foreach( string statRef in  GetFDStatRefs() )
	{
		awardStats[statRef] <- 0.0
	}
	file.playerAwardStats[player] <- awardStats
	player.s.hasPermenantAmpedWeapons <- false
	player.s.extracashnag <- Time()
	player.s.completedwaves <- 0
	player.s.didthepvpglitch <- false
	player.s.isbeingmonitored <- false
	thread SetTurretSettings_threaded( player )
	
	// only start the highlight when we start playing, not during dropship
	if ( GetGameState() >= eGameState.Playing )
	{
		Highlight_SetFriendlyHighlight( player, "sp_friendly_hero" )
		
		if( GetGlobalNetInt( "FD_waveState") == WAVE_STATE_BREAK ) //Prevent people who joins midgame from not being able to ready up
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_NotifyStoreOpen" )
			player.s.extracashnag = Time() + 30
		}
	}
	//Store current Aegis unlocks
	foreach ( string FDTitan in shTitanXP.titanClasses )
		player.SetPersistentVar( "previousFDUnlockPoints[" + FDTitan + "]", player.GetPersistentVarAsInt( "titanFDUnlockPoints[" + FDTitan + "]" ) )

	// unfortunate that i cant seem to find a nice callback for them exiting that menu but thisll have to do
	thread TryDisableTitanSelectionForPlayerAfterDelay( player, TEAM_TITAN_SELECT_DURATION_MIDGAME )
	thread TrackDeployedArcTrapThisRound( player )
	
	UpdateEarnMeter_ByPlayersInMatch()
	
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
	
	//Reset Tutorial hints to appear only once per match, friendly to newbies learn
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.HARVESTER, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.ARC_TRAP, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.SENTRY_TURRET, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.CORE_OVERLOAD, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.WAVE_BREAK, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_TITAN_ARC, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_TITAN_MORTAR, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_TITAN_NUKE, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_GRUNT, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_SPECTRE_MORTAR, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_STALKER, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_REAPER, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_DRONE, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_DRONE_CLOAK, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.AI_TICK, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.BOOST_STORE_INTRO, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.TEAM_RESERVE, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.FRONTIER_DEFENSE, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.HARD_DIFFICULTY, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.MASTER_DIFFICULTY, 0 )
	SetPersistenceBitfield( player, "fdTutorialBits", eFDTutorials.INSANE_DIFFICULTY, 0 )
}

void function TrackDeployedArcTrapThisRound( entity player )
{
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValidPlayer( player ) )
				OnPlayerDisconnectedOrDestroyed( player )
			else
				ClearInValidTurret()
		}
	)

	while( IsValidPlayer( player ) )
	{
		entity ArcTrap = expect entity ( player.WaitSignal( "DeployArcTrap" ).projectile )
		if( player.GetTeam() == TEAM_IMC ) //Remove the ability of IMC players deploying Arc Traps for the defending players
			ArcTrap.Destroy()
		
		file.players[ player ].deployedEntityThisRound.append( ArcTrap )
		AddEntityDestroyedCallback( ArcTrap, FD_OnEntityDestroyed )
	}
}

void function TryDisableTitanSelectionForPlayerAfterDelay( entity player, float waitAmount )
{
	player.EndSignal( "OnDestroy" )//Do a crash protect when wait delay

	OnThreadEnd(
		function() : ( player )
		{
			if( IsValidPlayer( player ) && PlayerEarnMeter_Enabled() )
				DisableTitanSelectionForPlayer( player )
		}
	)

	wait waitAmount
	int waveNumber = GetGlobalNetInt( "FD_currentWave" )
	
	if ( PlayerEarnMeter_Enabled() )
	{
		DisableTitanSelectionForPlayer( player )
		if( GetGlobalNetInt( "FD_waveState") == WAVE_STATE_BREAK ) //On wave break, let joiners have their Titan instantly
			PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
	}
	
	#if SERVER
	else if ( waveNumber > 0 && !PlayerEarnMeter_Enabled() && !file.isLiveFireMap ) //Lets joiners know why their Titan Meter is not building up if they joined during a Titanfall Block event
	{
		wait 10
		NSSendLargeMessageToPlayer( player, "Titanfall Block Active", "Your titan cannot be summoned, but you can help team mates not losing theirs, steal batteries!", 50, "rui/callsigns/callsign_94_col" )
	}
	#endif
}

void function SetTurretSettings_threaded( entity player )
{	//has to be delayed because PlayerConnect callbacks get called in wrong order
	WaitFrame()
	DeployableTurret_SetAISettingsForPlayer_AP( player, "npc_turret_sentry_burn_card_ap_fd" )
	DeployableTurret_SetAISettingsForPlayer_AT( player, "npc_turret_sentry_burn_card_at_fd" )
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
	else if( victim.GetTeam() == TEAM_MILITIA )
	{
		EmitSoundAtPosition( victim.GetTeam(), victim.GetOrigin(), "ai_reaper_nukedestruct_explo_3p" )
		PlayFX( $"P_sup_spectre_death_nuke", victim.GetOrigin(), victim.GetAngles() )
		for ( int i = 0; i < 20; i++ )
			Explosion_DamageDefSimple( damagedef_frag_drone_throwable_PLAYER, victim.GetOrigin(), victim, victim,  victim.GetOrigin() )
	}
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
	
	if( tick.GetTeam() == TEAM_MILITIA )
	{
		NPC_NoTarget( tick )
		tick.SetAISettings( "npc_frag_drone_fd" )
	}
}

void function OnNpcDeath( entity victim, entity attacker, var damageInfo )
{
	//Killing unwanted NPCs instantly causes a crash
	switch ( victim.GetClassName() )
	{
		case "npc_gunship":
		case "npc_dropship":
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
	
	if( IsPlayerControlledTurret( attacker ) )
	{
		file.playerAwardStats[attacker.GetBossPlayer()]["turretKills"]++
		file.players[attacker.GetBossPlayer()].defenseScoreThisRound += 2
	}
	
	if( victim.IsTitan() && attacker in file.players )
		file.playerAwardStats[attacker]["titanKills"]++
		
	int victimTypeID = FD_GetAITypeID_ByString( victim.GetTargetName() )
	
	if( victimTypeID == eFD_AITypeIDs.TITAN_MORTAR || victimTypeID == eFD_AITypeIDs.SPECTRE_MORTAR )
		if( attacker in file.players )
			file.playerAwardStats[attacker]["mortarUnitsKilled"]++
	
	int findIndex = spawnedNPCs.find( victim )
	if ( findIndex != -1 )
	{
		spawnedNPCs.remove( findIndex )
		string netIndex = GetAiNetIdFromTargetName( victim.GetTargetName() )
		if( netIndex != "" )
			SetGlobalNetInt( netIndex, GetGlobalNetInt( netIndex ) - 1 )

		SetGlobalNetInt( "FD_AICount_Current", GetGlobalNetInt( "FD_AICount_Current" ) - 1 )
	}

	if ( victim.GetOwner() == attacker || !attacker.IsPlayer() || attacker == victim || victim.GetBossPlayer() == attacker )
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
			case "npc_frag_drone": //Ticks gives no money due to Reapers being able to spam them
				money = 0
				break
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
				money = 50
				break
			default:
				money = 0
		}
		foreach( player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_OnTitanKilled", attacker.GetEncodedEHandle(), victim.GetEncodedEHandle(), scriptDamageType, damageSourceId )
	}
	
	if ( money != 0 )
		AddMoneyToPlayer( attacker , money )

	if( !IsNPCTitan( attacker ) || !IsPlayerControlledTurret( attacker ) ) //Turret and Auto-Titan kills should not chain killstreaks
	{
		if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
			AddPlayerScore( attacker, "NPCHeadshot" )
			
		attacker.s.currentKillstreak++
		if ( attacker.s.currentKillstreak == 4 )
			AddPlayerScore( attacker, "Mayhem" )
		else if ( attacker.s.currentKillstreak == 8 )
			AddPlayerScore( attacker, "Onslaught" )
		
		if ( Time() - attacker.s.lastKillTime > CASCADINGKILL_REQUIREMENT_TIME )
		{
			attacker.s.currentTimedKillstreak = 0
			attacker.s.currentKillstreak = 0
			attacker.s.lastKillTime = Time()
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
		vector vec = RandomVec( 150 )
		vector origin = victim.GetOrigin() + < 0, 0, 128 >
		switch ( difficultyLevel )
		{
			case eFDDifficultyLevel.EASY:
			case eFDDifficultyLevel.NORMAL:
				entity battery = Rodeo_CreateBatteryPack( victim )
				battery.SetOrigin( origin )
				battery.SetVelocity( < vec.x, vec.y, 400 > )
				break
			case eFDDifficultyLevel.HARD:
			case eFDDifficultyLevel.MASTER:
			case eFDDifficultyLevel.INSANE:
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
				break
		}
	}
	
	if( ( !IsNPCTitan( attacker ) || !IsPlayerControlledTurret( attacker ) ) && ( !attacker.IsTitan() && victim.IsTitan() ) )
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
			#if SERVER
			else if ( attacker.s.currentTimedKillstreak == 6 )
				foreach( entity player in GetPlayerArray() )
					NSSendAnnouncementMessageToPlayer( player, attacker.GetPlayerName(), "Chained a huge titan killstreak as pilot!", < 255, 128, 32 >, 50, 5 )
			#endif
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
		AddPlayerScore( attacker, "LeechSpectre" )
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_SPECTRE )
		AddMoneyToPlayer( attacker, 10 )
	}

	UpdatePlayerScoreboard( attacker )
}

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

bool function useShieldBoost( entity player, array<string> args )
{
	if( ( GetGlobalNetTime( "FD_harvesterInvulTime" ) < Time() ) && ( player.GetPlayerNetInt( "numHarvesterShieldBoost" ) > 0 ) )
	{
		fd_harvester.harvester.SetShieldHealth( fd_harvester.harvester.GetShieldHealthMax() )
		
		//If shield is down and someone uses Shield Boost, Harvester Shield Particle FX wasn't spawning
		if( !IsValid( fd_harvester.particleShield ) )
			generateShieldFX( fd_harvester )
		
		EmitSoundOnEntity( fd_harvester.harvester, "UI_TitanBattery_Pilot_Give_TitanBattery" )
		SetGlobalNetTime( "FD_harvesterInvulTime", Time() + 5 )
		AddPlayerScore( player, "FDShieldHarvester" )
		MessageToTeam( TEAM_MILITIA,eEventNotifications.FD_PlayerBoostedHarvesterShield, player, player )
		player.SetPlayerNetInt( "numHarvesterShieldBoost", player.GetPlayerNetInt( "numHarvesterShieldBoost" ) - 1 )
		file.playerAwardStats[player]["harvesterHeals"]++
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, FD_SCORE_SHIELD_HARVESTER )
		UpdatePlayerScoreboard( player )
	}
	return true
}

void function startMainGameLoop()
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
			#if SERVER
			foreach( entity player in GetPlayerArray() )
				NSSendAnnouncementMessageToPlayer( player, "#HUD_WAITING_FOR_PLAYERS_BASIC", "Minimum of: " + GetConVarInt( "ns_fd_min_numplayers_to_start" ) + " to start", < 255, 255, 255 >, 50, 5 )
			#endif
			warntime = Time() + 45.0
		}
		WaitFrame()
	}
	
	if( !file.waveRestart )
		PlayFactionDialogueToTeam( "fd_modeDesc", TEAM_MILITIA )
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

	bool showShop = false
	for( int i = GetGlobalNetInt( "FD_currentWave" ); i < waveEvents.len(); i++ )
	{
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
			FD_AttemptToRepairTurrets()
			
			wait 1
			
			if( !file.isLiveFireMap )
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

array<int> function getHighestEnemyAmountsForWave( int waveIndex )
{
	table<int,int> npcs
	npcs[eFD_AITypeIDs.TITAN] <- 0
	npcs[eFD_AITypeIDs.TITAN_NUKE] <- 0
	npcs[eFD_AITypeIDs.TITAN_ARC] <- 0
	npcs[eFD_AITypeIDs.TITAN_MORTAR] <- 0
	npcs[eFD_AITypeIDs.GRUNT] <- 0
	npcs[eFD_AITypeIDs.SPECTRE] <- 0
	npcs[eFD_AITypeIDs.SPECTRE_MORTAR] <- 0
	npcs[eFD_AITypeIDs.STALKER] <- 0
	npcs[eFD_AITypeIDs.REAPER] <- 0
	npcs[eFD_AITypeIDs.TICK] <- 0
	npcs[eFD_AITypeIDs.DRONE] <- 0
	npcs[eFD_AITypeIDs.DRONE_CLOAK] <- 0
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
	array<int> ret = [ -1, -1, -1, -1, -1, -1, -1, -1, -1 ]
	foreach( int key, int value in npcs )
	{
		if( value == 0 )
			continue
		int lowestArrayIndex = 0
		bool keyIsSet = false
		foreach( index, int arrayValue in ret )
		{
			if( arrayValue == -1 )
			{
				ret[index] = key
				keyIsSet = true
				break
			}
			if( npcs[ ret[lowestArrayIndex] ] > npcs[ ret[index] ] )
				lowestArrayIndex = index
		}
		if( ( !keyIsSet ) && ( npcs[ ret[lowestArrayIndex] ] < value ) )
			ret[lowestArrayIndex] = key
	}
	foreach( int val in ret )
	{
		printt( "ArrayVal", val )
	}
	return ret

}

void function SetEnemyAmountNetVars( int waveIndex )
{
	int total = 0
	table<int,int> npcs
	npcs[eFD_AITypeIDs.TITAN] <- 0
	npcs[eFD_AITypeIDs.TITAN_NUKE] <- 0
	npcs[eFD_AITypeIDs.TITAN_ARC] <- 0
	npcs[eFD_AITypeIDs.TITAN_MORTAR] <- 0
	npcs[eFD_AITypeIDs.GRUNT] <- 0
	npcs[eFD_AITypeIDs.SPECTRE] <- 0
	npcs[eFD_AITypeIDs.SPECTRE_MORTAR] <- 0
	npcs[eFD_AITypeIDs.STALKER] <- 0
	npcs[eFD_AITypeIDs.REAPER] <- 0
	npcs[eFD_AITypeIDs.TICK] <- 0
	npcs[eFD_AITypeIDs.DRONE] <- 0
	npcs[eFD_AITypeIDs.DRONE_CLOAK] <- 0
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
	SetGlobalNetInt( "FD_AICount_Titan", npcs[eFD_AITypeIDs.TITAN] )
	SetGlobalNetInt( "FD_AICount_Titan_Nuke", npcs[eFD_AITypeIDs.TITAN_NUKE] )
	SetGlobalNetInt( "FD_AICount_Titan_Mortar", npcs[eFD_AITypeIDs.TITAN_MORTAR] )
	SetGlobalNetInt( "FD_AICount_Titan_Arc", npcs[eFD_AITypeIDs.TITAN_ARC] )
	SetGlobalNetInt( "FD_AICount_Grunt", npcs[eFD_AITypeIDs.GRUNT] )
	SetGlobalNetInt( "FD_AICount_Spectre", npcs[eFD_AITypeIDs.SPECTRE] )
	SetGlobalNetInt( "FD_AICount_Spectre_Mortar", npcs[eFD_AITypeIDs.SPECTRE_MORTAR] )
	SetGlobalNetInt( "FD_AICount_Stalker", npcs[eFD_AITypeIDs.STALKER] )
	SetGlobalNetInt( "FD_AICount_Reaper", npcs[eFD_AITypeIDs.REAPER] )
	SetGlobalNetInt( "FD_AICount_Ticks", npcs[eFD_AITypeIDs.TICK] )
	SetGlobalNetInt( "FD_AICount_Drone", npcs[eFD_AITypeIDs.DRONE] )
	SetGlobalNetInt( "FD_AICount_Drone_Cloak", npcs[eFD_AITypeIDs.DRONE_CLOAK] )
	SetGlobalNetInt( "FD_AICount_Current", total )
	SetGlobalNetInt( "FD_AICount_Total", total )
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
		file.players[player].deployedEntityThisRound.clear()
	}
	array<int> enemys = getHighestEnemyAmountsForWave( waveIndex )

	if( waveIndex > 0 )
	{
		foreach( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_AnnouncePreParty", enemys[0], enemys[1], enemys[2], enemys[3], enemys[4], enemys[5], enemys[6], enemys[7], enemys[8] )
	}
	
	if( waveIndex < waveAnnouncement.len() && waveAnnouncement[waveIndex] != "" && !file.waveRestart )
	{
		PlayFactionDialogueToTeam( waveAnnouncement[waveIndex] , TEAM_MILITIA )
		if( waveIndex == 0 )
			wait 5
	}
	if( file.waveRestart )
	{
		file.waveRestart = false
		MessageToTeam( TEAM_MILITIA,eEventNotifications.FD_WaveRestart )
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
		parentCrate.Minimap_Hide( TEAM_MILITIA, null )
		CloseBoostStores()
		MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_StoreClosing )
		print( "Closing Shop" )
	}
	
	else
	{
		SetGlobalNetInt( "FD_waveState", WAVE_STATE_BREAK )
		SetGlobalNetTime( "FD_nextWaveStartTime", Time() )
		wait 5
	}
	
	if ( waveIndex > 0 )
		wait 4
	
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
		foreach(index,float damage in file.harvesterDamageSource)
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
			PlayFactionDialogueToTeam( "fd_matchDefeat" , TEAM_MILITIA )
			print( "Finishing match, no more retries left" )
			foreach( entity player in GetPlayerArray() )
				AddPlayerScore( player, "MatchComplete" )
			RegisterPostSummaryScreenForMatch( false )
		}
		
		file.waveRestart = true //wave restart point
		SetWinner( TEAM_IMC )//restart round
		spawnedNPCs = [] // reset npcs count
		restetWaveEvents()
		SetPlayerDeathsHidden( true )
		
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
				if ( IsAlive( player ) )
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
		
		if( GetPlayerArray().len() > 0 )
		{
			highestScore = 0;
			highestScore_player = GetPlayerArray()[0]
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
			if( highestScore < ( file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound ) )
			{
				highestScore = file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound
				highestScore_player = player
			}
		}
		
		SetRoundBased(false)
		SetWinner(TEAM_MILITIA)
		PlayFactionDialogueToTeam( "fd_matchVictory", TEAM_MILITIA )
		
		wait 1
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			AddPlayerScore( player, "FDTeamWave" )
		
		wait 1
		
		file.playerAwardStats[highestScore_player]["mvp"]++
		AddPlayerScore( highestScore_player, "FDWaveMVP" )
		
		wait 1
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( !file.harvesterWasDamaged )
				AddPlayerScore( player, "FDTeamFlawlessWave" )
		}
		
		wait 1
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
			AddPlayerScore( player, "MatchVictory" )
			
		wait 1
		
		foreach(entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			AddPlayerScore( player, "MatchComplete" )
			if( IsAlive( player ) )
			{
				float timeAlive = Time() - file.players[player].lastRespawn
				if( timeAlive > file.playerAwardStats[player]["longestLife"] )
					file.playerAwardStats[player]["longestLife"] = timeAlive
			}
			if( IsValid( player.GetPetTitan() ) )
			{
				float timeAlive = Time() - file.players[player].lastTitanDrop
				if( timeAlive > file.playerAwardStats[player]["longestTitanLife"] )
					file.playerAwardStats[player]["longestTitanLife"] = timeAlive
			}
		}
		
		RegisterPostSummaryScreenForMatch( true )
		
		return true
	}
	
	MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_AnnounceWaveEnd )
	
	wait 2
	
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
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
	FD_AttemptToRepairTurrets()
	
	print( "Showing Player Stats: Wave Complete" )
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
		SetJoinInProgressBonus( GetCurrentPlaylistVarInt( "fd_money_per_round" ,600 ) )
		FD_EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
		FD_EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Ticker_Loop_1P" )
	}
	wait 2
	print( "Showing Player Stats: No Deaths This Wave" )
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
	
	if( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() > 0 )
	{
		highestScore = 0;
		highestScore_player = GetPlayerArray()[0]
	}
	
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
	{
		if( highestScore < ( file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound ) )
		{
			highestScore = file.players[player].assaultScoreThisRound + file.players[player].defenseScoreThisRound
			highestScore_player = player
		}
	}
	
	file.playerAwardStats[highestScore_player]["mvp"]++
	AddPlayerScore( highestScore_player, "FDWaveMVP" )
	if( !file.isLiveFireMap )
		AddMoneyToPlayer( highestScore_player, 100 )
	else
		AddMoneyToPlayer( highestScore_player, 200 )
	highestScore_player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_MVP )
	UpdatePlayerScoreboard( highestScore_player )
	FD_EmitSoundOnEntityOnlyToPlayer( highestScore_player, highestScore_player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		Remote_CallFunction_NonReplay( player, "ServerCallback_FD_NotifyMVP", highestScore_player.GetEncodedEHandle() )
	
	wait 2
	print( "Showing Player Stats: Flawless Defense" )
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
	if( waveIndex<waveEvents.len() )
		SetGlobalNetTime( "FD_nextWaveStartTime", Time() + GetCurrentPlaylistVarFloat( "fd_wave_buy_time", 60 ) )

	return true
}

void function FD_StunLaserHealTeammate( entity player, entity target, int shieldRestoreAmount )
{
	if( IsValidPlayer( player ) && player in file.players )
	{
		file.playerAwardStats[player]["heals"] += float( shieldRestoreAmount )
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, shieldRestoreAmount / 100 )
		UpdatePlayerScoreboard( player )
	}
}

void function FD_SmokeHealTeammate( entity player, entity target, int shieldRestoreAmount )
{
	if( IsValidPlayer( player ) && player in file.players )
	{
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
		file.playerAwardStats[rider]["heals"] += float( TotalHealing )
		rider.AddToPlayerGameStat( PGS_DEFENSE_SCORE, HealScore )
		rider.SetPlayerGameStat( PGS_DETONATION_SCORE, rider.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + rider.GetPlayerGameStat( PGS_DEFENSE_SCORE ) )
	}
}

void function FD_OnArcTrapTriggered( entity victim, var damageInfo )
{
	entity owner = DamageInfo_GetAttacker( damageInfo )

	if( !IsValidPlayer( owner ) )
		return

	AddPlayerScore( owner, "FDArcTrapTriggered" )
	file.players[owner].defenseScoreThisRound++
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
		ScreenFadeToBlackForever( player, 6.0 )
	wait 2
	AllPlayersMuteAll( 4 )
	wait 5
	AllPlayersUnMuteAll()
	foreach(entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
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

	foreach(string ref,entity player in awardOwners)
	{
		if( awardValues[ref] >  GetFDStatData( ref ).validityCheckValue ) //might be >=
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
			if( !IsValid( medalPlayer ) )
				continue

			if( i == numPlayers )
				break

			int targetIndex = medalPlayer.GetPlayerIndex()
			if( targetIndex >= 4 )
				continue

			string name = medalPlayer.GetPlayerName()
			string xuid = medalPlayer.GetUID()
			int awardId = GetFDStatData( ref ).index
			float awardValue = awardResultValues[medalPlayer]
			int suitIndex = GetPersistentSpawnLoadoutIndex( medalPlayer, "titan" )
			int playerEHandle = medalPlayer.GetEncodedEHandle()

			player.SetPersistentVar( "postGameDataFD.players[" + targetIndex + "].name", name )
			player.SetPersistentVar( "postGameDataFD.players[" + targetIndex + "].xuid", xuid )
			player.SetPersistentVar( "postGameDataFD.players[" + targetIndex + "].awardId", awardId )
			player.SetPersistentVar( "postGameDataFD.players[" + targetIndex + "].awardValue", awardValue )
			player.SetPersistentVar( "postGameDataFD.players[" + targetIndex + "].suitIndex", suitIndex )
			Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateGameStats", playerEHandle, awardId, awardValue, suitIndex )
			i++
		}
		Remote_CallFunction_NonReplay( player, "ServerCallback_ShowGameStats", Time() + 19 )
	}
	
	wait 20
	SetGameState(eGameState.Postmatch)
}

void function IncrementPlayerstat_TurretRevives( entity turret, entity player, entity owner )
{
	if( IsValidPlayer( owner ) )
	{
		file.playerAwardStats[player]["turretsRepaired"]++
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_RepairTurret" )
		AddPlayerScore( player, "FDRepairTurret" )
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, FD_SCORE_REPAIR_TURRET )
		UpdatePlayerScoreboard( player )
		
		if( player != owner )
			MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_TurretRepair, null, player, owner.GetEncodedEHandle() )
	}
}

void function SpawnCallback_SafeTitanSpawnTime( entity ent )
{
	if( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) && ent.GetTeam() == TEAM_MILITIA )
	{
		Highlight_SetFriendlyHighlight( ent, "sp_friendly_hero" ) //Friendly Titans should have highlight overlays
		ent.EnableNPCFlag( NPCMF_PREFER_SPRINT | NPC_ALLOW_INVESTIGATE | NPC_IGNORE_FRIENDLY_SOUND | NPC_NEW_ENEMY_FROM_SOUND | NPC_TEAM_SPOTTED_ENEMY | NPC_AIM_DIRECT_AT_ENEMY )
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

void function DeathCallback_CalculateTitanAliveTime( entity ent )
{
	if( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) && ent.GetTeam() == TEAM_MILITIA )
	{
		entity player = GetPetTitanOwner( ent )
		float aliveTime = file.players[player].lastTitanDrop - Time()
		if( aliveTime > file.playerAwardStats[player]["longestTitanLife"] )
			file.playerAwardStats[player]["longestTitanLife"] = aliveTime
	}
	else if( ent.IsTitan() && ent.GetTeam() == TEAM_MILITIA && ent in file.players )
	{
		float aliveTime = file.players[ent].lastTitanDrop - Time()
		if( aliveTime > file.playerAwardStats[ent]["longestTitanLife"] )
			file.playerAwardStats[ent]["longestTitanLife"] = aliveTime
	}	
}

void function OnHarvesterDamaged( entity harvester, var damageInfo )
{
	if ( !IsValid( harvester ) )
		return

	if( fd_harvester.harvester != harvester )
		return

	if ( GetGlobalNetTime( "FD_harvesterInvulTime" ) > Time() )
	{
		harvester.SetShieldHealth( harvester.GetShieldHealthMax() )
		return
	}
	
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	
	/*On vanilla, because of the glitch of swapping teams, IMC players could attack the Harvester, i am removing this possibility from them	because FD is a
	PvE	gamemode after all and such should behave accordingly, so what IMC players should do now is actually distract or kill the defending players, assisting
	the AI in actually reach the Harvester for them to do the damage */
	if ( ( attacker.IsPlayer() || IsValid( GetPetTitanOwner( attacker ) ) ) && attacker.GetTeam() == TEAM_IMC )
	{
		SendHudMessage( attacker, "You cannot attack the Harvester, only the AI, help the AI attack it!", -1, 0.4, 255, 255, 255, 255, 0.15, 3.0, 0.5 )
		return
	}

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	int attackerTypeID = FD_GetAITypeID_ByString( attacker.GetTargetName() )
	float damageAmount = DamageInfo_GetDamage( damageInfo )
	
	//Titan smokes triggers damage calls on Harvester somehow
	if( attacker.GetTeam() == TEAM_MILITIA )
		return
	
	int PlayersInMatch = GetPlayerArrayOfTeam( TEAM_MILITIA ).len()
	
	if ( PlayersInMatch > 4 ) //Additional players should not be considered
		PlayersInMatch = 4
	
	float MultiplierPerPlayer = 0.25

	if ( !damageSourceID && !damageAmount && !attacker )
		return

	fd_harvester.lastDamage = Time()

	damageAmount = ( damageAmount * GetCurrentPlaylistVarFloat( "fd_player_damage_scalar", 1.0 ) )
	damageAmount *= MultiplierPerPlayer * PlayersInMatch
	
	//All of this is factored after difficulty damage multipliers, so probably on Master and Insane difficulty only one Nuke Titan should almost end the Harvester even with full shields
	//Master and Insane difficulties tends to spawn less enemies as well, so players should be paying attention against those enemies
	//These are approximate values accordingly to vanilla
	switch( damageSourceID )
	{
		case eDamageSourceId.damagedef_nuclear_core:
    	damageAmount *= 10 //A single Nuke Titan should already be a high threat to the Harvester
		break
	
		case eDamageSourceId.damagedef_stalker_powersupply_explosion_small:
		case eDamageSourceId.mp_weapon_super_spectre:
		case eDamageSourceId.super_spectre_melee:
    	damageAmount *= 2 //Stalkers should also be able to take a little more from Harvester as in vanilla
		break
		
		case eDamageSourceId.damagedef_stalker_powersupply_explosion_large:
		case eDamageSourceId.damagedef_frag_drone_explode_FD: //Not sure, Ticks feels off
		case eDamageSourceId.mp_weapon_droneplasma: //Not sure too, Plasma Drones also seems off
    	damageAmount *= 4
		break
		
		case eDamageSourceId.mp_titanweapon_rocketeer_rocketstream: //Mortar titans also do pose a threat if left unchecked for too long
		case eDamageSourceId.mp_weapon_rocket_launcher: //Idk apparently the Archer that mortar spectres uses has no special damage type
    	damageAmount *= 4
		break
		
		//Actually for Cores its better reduce their damage because a single Elite could just disintegrate Harvester within 2 seconds
		case eDamageSourceId.mp_titancore_laser_cannon:
		case eDamageSourceId.mp_titancore_flame_wave:
		case eDamageSourceId.mp_titancore_salvo_core:
		case eDamageSourceId.mp_titanweapon_flightcore_rockets:
		case eDamageSourceId.mp_titanweapon_sniper:
    	damageAmount *= 0.25
		break
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
		
		if (attackerTypeID > -1 ) //Only track damage from existing ids
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
	
	//Repeat filters for shields, these are approximate values accordingly to vanilla
	switch( damageSourceID )
	{
		//Laser core does absurd damage against Harvester shield
		case eDamageSourceId.mp_titancore_laser_cannon:
		DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) / 10 )
		break
		
		//Other cores kinda does too but not as much
		case eDamageSourceId.mp_titancore_salvo_core:
		case eDamageSourceId.mp_titanweapon_flightcore_rockets:
		case eDamageSourceId.mp_titancore_flame_wave:
		case eDamageSourceId.mp_titanweapon_sniper:
		DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) / 4 )
		break

		case eDamageSourceId.damagedef_nuclear_core: //Multiplier for Nuke Titans against shield is lower because the discrepancy between Harvester health pool and Shield amount pool
    	DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) * 6 )
		break
	
		case eDamageSourceId.damagedef_stalker_powersupply_explosion_small:
		case eDamageSourceId.mp_weapon_super_spectre:
		case eDamageSourceId.super_spectre_melee:
    	DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) * 2 )
		break
		
		case eDamageSourceId.damagedef_stalker_powersupply_explosion_large:
		case eDamageSourceId.damagedef_frag_drone_explode_FD:
    	DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) * 4 )
		break
		
		case eDamageSourceId.mp_weapon_droneplasma:
    	DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) * 10 )
		break
		
		case eDamageSourceId.mp_titanweapon_rocketeer_rocketstream:
		case eDamageSourceId.mp_weapon_rocket_launcher:
    	DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) * 4 )
		break
	}

	/*
	if ( attacker.IsPlayer() )
		attacker.NotifyDidDamage( harvester, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	*/
}

void function FD_NPCCleanup()
{
	foreach( entity player in GetPlayerArray() )
	{
		foreach ( entity ent in file.players[ player ].deployedEntityThisRound )
		{
			if ( IsValid( ent ) )
				ent.Destroy()
		}
	}
	foreach ( entity npc in GetEntArrayByClass_Expensive( "C_AI_BaseNPC" ) )
	{
		entity BossPlayer = npc.GetBossPlayer()
		if( IsValidPlayer( BossPlayer ) && !file.players[ BossPlayer ].deployedEntityThisRound.contains( npc ) || npc.GetClassName() == "npc_turret_mega" )
			continue
		if ( IsValid( npc ) )
			npc.Destroy()
	}
	if( IsValid( fd_harvester.harvester ) )
		fd_harvester.harvester.Destroy() //Destroy harvester after match over
}

void function HarvesterThink()
{
	entity harvester = fd_harvester.harvester
	float lastTime = Time()
	wait 2
	EmitSoundOnEntity( harvester, HARVESTER_SND_STARTUP )
	fd_harvester.rings.Anim_Play( HARVESTER_ANIM_ACTIVATING )
	wait 4
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

void function initNetVars()
{
	SetGlobalNetInt( "FD_totalWaves", waveEvents.len() )
	if( !file.isLiveFireMap )
		SetGlobalNetInt( "burn_turretLimit", 2 )
	else
		SetGlobalNetInt( "burn_turretLimit", 3 ) //Live Fire maps are brutal with spawns so, good to have more turrets
	if(!FD_HasRestarted())
	{
		bool showShop = false
		SetGlobalNetInt( "FD_currentWave", 0 )
		if( FD_IsDifficultyLevelOrHigher( eFDDifficultyLevel.INSANE ) )
			FD_SetNumAllowedRestarts( 0 )
		else
			FD_SetNumAllowedRestarts( 2 )
	}
}

void function FD_DamageByPlayerCallback( entity victim, var damageInfo )
{
	entity player = DamageInfo_GetAttacker( damageInfo )
	if( !( player in file.players ) )
		return
	float damage = min( victim.GetMaxHealth(), DamageInfo_GetDamage( damageInfo ) )
	file.playerAwardStats[player]["damageDealt"] += damage
	file.players[player].assaultScoreThisRound += damage.tointeger() / 100
	
	if( victim.IsTitan() && victim.GetShieldHealth() <= 0 )
	{
		//Money Damage goes here
		bool isDoomed = GetDoomedState( victim )
		if ( !isDoomed )
		{
			
		}
	}
}

void function DamageScaleByDifficulty( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !attacker )
		return

	if ( ent.GetTeam() != TEAM_MILITIA )
		return

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )

	if ( !damageSourceID && !damageAmount )
		return
	
	//IMC Players being a distraction will do less damage, countermeasure to smoothen the stress put onto the Defending players
	if ( ( attacker.IsPlayer() || IsValid( GetPetTitanOwner( attacker ) ) ) && attacker.GetTeam() == TEAM_IMC )
	{
		DamageInfo_SetDamage( damageInfo, damageAmount * 0.5 )
		return
	}

	if ( attacker == ent ) // dont scale self damage
		return
	
	//Arc Waves and Charge Rifles do not scale (Both Arc/Ronin Titans and Grunts can chomp too much health if they land these attacks on the player)
	if ( damageSourceID == eDamageSourceId.mp_titanweapon_arc_wave || damageSourceID == eDamageSourceId.mp_weapon_defender || damageSourceID == eDamageSourceId.mp_weapon_rocket_launcher || damageSourceID == eDamageSourceId.mp_weapon_arc_launcher )
		return
		
	if ( damageSourceID == eDamageSourceId.prowler_melee ) //Prowlers being basically hitkill on FD ain't fun
	{
		DamageInfo_SetDamage( damageInfo, damageAmount * 0.2 )
		return
	}
	
	if ( damageSourceID == eDamageSourceId.damagedef_stalker_powersupply_explosion_large_at && ent.IsPlayer() && ent.IsTitan() ) //Warn Titan players about Stalkers
		PlayFactionDialogueToPlayer( "fd_stalkerExploNag", ent )

	DamageInfo_SetDamage( damageInfo, damageAmount * GetCurrentPlaylistVarFloat( "fd_player_damage_scalar", 1.0 ) )
}

void function HealthScaleByDifficulty( entity ent )
{
	if ( ent.GetTeam() != TEAM_IMC )
		return


	if ( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) ) // in case we ever want pvp in FD
		return

	if ( ent.IsTitan() && ent.ai.bossTitanType == TITAN_MERC && elitesAllowed )
	{
		if( ent.GetAISettingsName() == "npc_titan_ogre_minigun_boss_fd_elite" )
			ent.SetMaxHealth( ent.GetMaxHealth() + 15000 )
		else
			ent.SetMaxHealth( ent.GetMaxHealth() + 7500 )
		ent.SetHealth( ent.GetMaxHealth() )
		entity soul = ent.GetTitanSoul()
		if( IsValid( soul ) )
		{
			soul.SetShieldHealthMax( 7500 )
			soul.SetShieldHealth( 7500 )
		}
	}
	else if ( ent.IsTitan() && ent.ai.bossTitanType == 0 )
		ent.SetMaxHealth( ent.GetMaxHealth() + GetCurrentPlaylistVarInt( "fd_titan_health_adjust", 0 ) )
	else
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
	AddEntityCallback_OnDamaged( fd_harvester.harvester, OnHarvesterDamaged )
	thread CreateHarvesterHintTrigger( fd_harvester.harvester )
	
	SetPlayerDeathsHidden( false )
	if( !file.waveRestart )
		EnableTitanSelection()
	
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
			thread StratonHornetDogfights()
			break
		case "mp_black_water_canal":
		case "mp_eden":
			thread StratonHornetDogfightsIntense()
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

void function CreateHarvesterHintTrigger( entity harvester )
{
	entity trig = CreateEntity( "trigger_cylinder" )
	trig.SetRadius( 1024 )
	trig.SetAboveHeight( 1024 )
	trig.SetBelowHeight( 1024 )
	trig.SetOrigin( harvester.GetOrigin() )
	trig.kv.triggerFilterNpc = "none"
	trig.kv.triggerFilterPlayer = "all"

	SetTeam( trig, harvester.GetTeam() )
	DispatchSpawn( trig )
	trig.SetEnterCallback( OnEnterNearHarvesterTrigger )
	trig.SetLeaveCallback( OnLeaveNearHarvesterTrigger )

	harvester.EndSignal( "OnDestroy" )
	trig.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( trig )
		{
			if ( IsValid( trig ) )
				trig.Destroy()
		}
	)

	WaitForever()
}

void function OnEnterNearHarvesterTrigger( entity trig, entity activator )
{
	if( GetGameState() != eGameState.Playing )
		return
		
	if( !( activator in file.players ) )
		return
		
	if( !IsHarvesterAlive( fd_harvester.harvester ) )
		return
		
	if( !GetGlobalNetBool( "FD_waveActive" ) )
		return

	if ( activator != null && activator.IsPlayer() && activator.GetTeam() == trig.GetTeam() && file.players[activator].leaveHarvester == true )
	{
		file.players[activator].lastNearHarvester = Time()
		file.players[activator].leaveHarvester = false
	}
}

void function OnLeaveNearHarvesterTrigger( entity trig, entity activator )
{
	if( GetGameState() != eGameState.Playing )
		return
		
	if( !( activator in file.players ) )
		return
		
	if( !IsHarvesterAlive( fd_harvester.harvester ) )
		return
		
	if( !GetGlobalNetBool( "FD_waveActive" ) )
		return

	float CurrentTime = Time() - file.players[activator].lastNearHarvester

	if ( activator != null && activator.IsPlayer() && activator.GetTeam() == trig.GetTeam() && file.players[activator].leaveHarvester == false )
	{
		file.playerAwardStats[activator]["timeNearHarvester"] += CurrentTime
		file.players[activator].leaveHarvester = true
	}
}

bool function isFinalWave()
{
	return ( ( GetGlobalNetInt( "FD_currentWave" ) + 1 ) == GetGlobalNetInt( "FD_totalWaves" ) )
}

bool function isSecondWave()
{
	return ( (GetGlobalNetInt( "FD_currentWave" ) + 1 ) == 1 )
}

void function AddCallback_RegisterCustomFDContent( LoadCustomFDContent callback )
{
	CustomFDContent.append( callback )
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
					entity prop = CreatePropDynamicLightweight( info_target.GetModelName(), info_target.GetOrigin(), info_target.GetAngles(), 6 )
					ToggleNPCPathsForEntity( prop, false )
					prop.SetAIObstacle( true )
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

void function AddTurretSentry( entity turret )
{
	entity player = turret.GetBossPlayer()
	if( player != null && player.GetTeam() == TEAM_MILITIA )
	{
		turret.Minimap_AlwaysShow( TEAM_MILITIA, null )
		turret.Minimap_SetHeightTracking( true )
		turret.Minimap_SetCustomState( eMinimapObject_npc.FD_TURRET )
		turret.SetMaxHealth( DEPLOYABLE_TURRET_HEALTH )
		turret.SetHealth( DEPLOYABLE_TURRET_HEALTH )
		turret.kv.AccuracyMultiplier = DEPLOYABLE_TURRET_ACCURACY_MULTIPLIER
		turret.ai.buddhaMode = true
		turret.SetNoTargetSmartAmmo( true ) //Prevents enemy Legion Smart Core to target them automatically
		Highlight_SetFriendlyHighlight( turret , "sp_friendly_hero" )
		Highlight_SetOwnedHighlight( turret , "sp_friendly_hero" )
		turret.Highlight_SetParam( 1, 0, < 0, 0, 0 > )
		turret.Highlight_SetParam( 3, 0, HIGHLIGHT_COLOR_INTERACT )
		file.players[ player ].deployedEntityThisRound.append( turret )
		AddEntityDestroyedCallback( turret, FD_OnEntityDestroyed )
		thread TurretRefundThink( turret )
	}
	else if( player != null && player.GetTeam() == TEAM_IMC )
		turret.Destroy() //IMC Players shall not deploy turrets
}

function FD_OnEntityDestroyed( ent )
{
	expect entity( ent )

	Assert( ent.IsValidInternal() )
	entity player = IsTurret( ent ) ? ent.GetBossPlayer() : ent.GetOwner()

	if( !IsValidPlayer( player ) )
		return

	if( file.players[ player ].deployedEntityThisRound.contains( ent ) )
		file.players[ player ].deployedEntityThisRound.fastremovebyvalue( ent )
}

void function OnPlayerDisconnectedOrDestroyed( entity player )
{
	file.players[ player ].deployedEntityThisRound.clear()
	if( file.playersInDropship.contains( player ) )
		file.playersInDropship.fastremovebyvalue( player )
	
	UpdateEarnMeter_ByPlayersInMatch()
	
	foreach ( entity npc in GetEntArrayByClass_Expensive( "C_AI_BaseNPC" ) )
	{
		entity BossPlayer = npc.GetBossPlayer()
		if ( IsValidPlayer( BossPlayer ) && IsValid( npc ) && player == BossPlayer )
			npc.Destroy()
	}
	
	if( !IsValidPlayer( player ) )
	{
		ClearInValidTurret()
		return
	}
}

void function ClearInValidTurret()
{
	foreach( entity turret in GetNPCArrayByClass( "npc_turret_sentry" ) )
	{
		entity BossPlayer = turret.GetBossPlayer()
		if ( !IsValidPlayer( BossPlayer ) && IsValid( turret ) && turret.GetAISettingsName() == "npc_turret_sentry_burn_card_ap_fd" )
			turret.Destroy()
	}
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
		string selectedEnumName = PersistenceGetEnumItemNameForIndex( "titanClasses", player.GetPersistentVarAsInt("activeTitanLoadoutIndex") )
		if ( enumName != "" && enumName != selectedEnumName )
			player.SetPersistentVar( "titanClassLockState[" + enumName + "]", TITAN_CLASS_LOCK_STATE_LOCKED )
	}
}

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
	thread PlayAnim(file.dropship, FD_DropshipGetAnimation())
	file.dropship.WaitSignal( "deploy" )
	file.dropshipState = eDropshipState.Returning
	
	foreach( int i, entity player in file.playersInDropship )
		thread FD_DropshipDropPlayer( player, i )
	
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
	
	wait 8
	
	file.playersInDropship.clear()
	file.playersInShip = 0 //Do it again in here to avoid dropship not appearing anymore after a while if theres too many players in a match
	file.dropshipState = eDropshipState.Idle
}

void function FD_DropshipDropPlayer(entity player,int playerDropshipIndex)
{
	player.EndSignal( "OnDestroy" )
	//check the player
	if( IsValid( player ) && !player.IsTitan() )
	{
		FirstPersonSequenceStruct jumpSequence
		jumpSequence.firstPersonAnim = DROPSHIP_EXIT_ANIMS_POV[ playerDropshipIndex ]
		jumpSequence.thirdPersonAnim = DROPSHIP_EXIT_ANIMS[ playerDropshipIndex ]
		jumpSequence.attachment = "ORIGIN"
		jumpSequence.blendTime = 0.0
		jumpSequence.viewConeFunction = ViewConeNarrow

		thread FirstPersonSequence( jumpSequence, player, file.dropship )
		WaittillAnimDone( player )
		
		if( IsValid( player ) ) //Check again because the delay
		{
			player.ClearParent()
			ClearPlayerAnimViewEntity( player )
			player.ClearInvulnerable()
			player.SetNoTarget( false )
			player.Highlight_SetParam( 1, 0, HIGHLIGHT_COLOR_FRIENDLY )
			
			#if BATTLECHATTER_ENABLED
			if( playerDropshipIndex == 0 )
				PlayBattleChatterLine( player, "bc_pIntroChat" )
			#endif
		}
	}
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

//Change the highlight color of pilots when rodeoing Titans because the voice feedback from Titan OS might not be enough to players awareness
void function FD_PilotStartRodeo( entity pilot, entity titan )
{
	if ( GetConVarBool( "ns_fd_rodeo_highlight" ) )
		pilot.Highlight_SetParam( 1, 0, < 0.5, 2.0, 0.5 > )
}

void function FD_PilotEndRodeo( entity pilot, entity titan )
{
	if ( GetConVarBool( "ns_fd_rodeo_highlight" ) )
		pilot.Highlight_SetParam( 1, 0, HIGHLIGHT_COLOR_FRIENDLY )
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
			
			PlayerEarnMeter_AddOwnedFrac( player, 0.1 ) //At least make them buildup titan meter faster since they gain nothing for killing the defending players
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

    return ( PlayerHasBattery( player ) && player.GetTeam() == turret.GetTeam() )
}

function HTUseBatteryFunc( batteryPortvar, playervar )
{
	entity batteryPort = expect entity( batteryPortvar )
	entity player = expect entity( playervar )
    entity turret = expect entity( batteryPort.s.relatedTurret )
	
	if( !IsValid( player ) || turret.GetHealth() == turret.GetMaxHealth() )
		return
	
	file.playerAwardStats[player]["turretsRepaired"]++
	AddPlayerScore( player, "FDRepairTurret" )
	PlayerEarnMeter_AddEarnedAndOwned( player, 0.0, 0.5 )
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

void function UpdatePlayerScoreboard( entity player )
{
	player.SetPlayerGameStat( PGS_DETONATION_SCORE, player.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + player.GetPlayerGameStat( PGS_DEFENSE_SCORE ) )
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
	
	int Composition = 0
	
	if( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() >= 2 && !file.isLiveFireMap )
	{
		entity player1titan = GetPlayerArrayOfTeam( TEAM_MILITIA )[0]
		entity player2titan = GetPlayerArrayOfTeam( TEAM_MILITIA )[1]
		int suitIndex1 = GetPersistentSpawnLoadoutIndex( player1titan, "titan" )
		int suitIndex2 = GetPersistentSpawnLoadoutIndex( player2titan, "titan" )
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			int suitIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )
			if( suitIndex == suitIndex1 && player == player1titan || suitIndex == suitIndex2 && player == player2titan )
				continue
			if( suitIndex != suitIndex1 || suitIndex != suitIndex2 )
				Composition = 1
		}
	}
	
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
			
			foreach( entity otherplayer in GetPlayerArray() )
				Remote_CallFunction_NonReplay( player, "ServerCallback_SquadLeaderBonus", otherplayer.GetEncodedEHandle() )
				
			switch( difficultyLevel )
			{
				case eFDDifficultyLevel.EASY:
					player.SetPersistentVar( "fd_match[" + eFDXPType.EASY_VICTORY + "]", FD_XP_EASY_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.EASY_VICTORY + "]", FD_XP_EASY_WIN )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_EASY_BONUS_SCALE )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_EASY_BONUS_SCALE )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_EASY_WAVE_BONUS )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_EASY_WAVE_BONUS )
					fdXPamount += FD_XP_EASY_WIN
					break
				case eFDDifficultyLevel.NORMAL:
					player.SetPersistentVar( "fd_match[" + eFDXPType.NORMAL_VICTORY + "]", FD_XP_NORMAL_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.NORMAL_VICTORY + "]", FD_XP_NORMAL_WIN )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_NORMAL_BONUS_SCALE )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_NORMAL_BONUS_SCALE )
					//player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_NORMAL_WAVE_BONUS )
					//player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_NORMAL_WAVE_BONUS )
					fdXPamount += FD_XP_NORMAL_WIN
					break
				case eFDDifficultyLevel.HARD:
					player.SetPersistentVar( "fd_match[" + eFDXPType.HARD_VICTORY + "]", FD_XP_HARD_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.HARD_VICTORY + "]", FD_XP_HARD_WIN )
					player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_HARD_BONUS_SCALE )
					player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_HARD_BONUS_SCALE )
					player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_HARD_WAVE_BONUS )
					player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_HARD_WAVE_BONUS )
					fdXPamount += FD_XP_HARD_WIN + FD_XP_HARD_WAVE_BONUS + FD_XP_HARD_BONUS_SCALE
					break
				case eFDDifficultyLevel.MASTER:
					player.SetPersistentVar( "fd_match[" + eFDXPType.MASTER_VICTORY + "]", FD_XP_MASTER_WIN )
					player.SetPersistentVar( "fd_count[" + eFDXPType.MASTER_VICTORY + "]", FD_XP_MASTER_WIN )
					player.SetPersistentVar( "fd_match[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_MASTER_BONUS_SCALE )
					player.SetPersistentVar( "fd_count[" + eFDXPType.DIFFICULTY_BONUS + "]", FD_XP_MASTER_BONUS_SCALE )
					player.SetPersistentVar( "fd_match[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_MASTER_WAVE_BONUS )
					player.SetPersistentVar( "fd_count[" + eFDXPType.WARPAINT_BONUS + "]", FD_XP_MASTER_WAVE_BONUS )
					fdXPamount += FD_XP_MASTER_WIN + FD_XP_MASTER_WAVE_BONUS + FD_XP_MASTER_BONUS_SCALE
					break
				case eFDDifficultyLevel.INSANE:
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
	}
	SetUIVar( level, "showGameSummary", true )
}