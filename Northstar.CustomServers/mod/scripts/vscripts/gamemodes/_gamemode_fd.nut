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

enum eDropshipState{
	Idle,
	InProgress,
	Returning
	_count_
}




struct player_struct_fd{
	bool diedThisRound
	int scoreThisRound
	int moneyThisRound
	array< entity > deployedEntityThisRound
	/*
	int totalMVPs
	int mortarUnitsKilled
	int moneySpend
	int coresUsed
	float longestTitanLife
	int turretsRepaired
	int moneyShared
	float timeNearHarvester //dont know how to track
	float longestLife
	int heals //dont know what to track
	int titanKills
	float damageDealt
	int harvesterHeals
	int turretKills
	*/
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
global table< string, array<vector> > routes
global array<entity> routeNodes
global array<entity> spawnedNPCs




struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<float> harvesterDamageSource
	bool havesterWasDamaged
	bool harvesterShieldDown
	float harvesterDamageTaken
	table<entity, player_struct_fd> players
	table<entity, table<string, float> > playerAwardStats
	entity harvester_info
	bool playersHaveTitans = false
	bool waveRestart = false

	string animationOverride = ""
	int dropshipState
	int playersInShip
	entity dropship
	array<entity> playersInDropship
}file


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
	PrecacheModel( $"models/humans/grunts/imc_grunt_shield_captain.mdl" )
	PrecacheParticleSystem( $"P_smokescreen_FD" )

	RegisterSignal( "SniperSwitchedEnemy" ) // for use in SniperTitanThink behavior.
	RegisterSignal( "FD_ReachedHarvester" )
	RegisterSignal( "OnFailedToPath" )

	SetRoundBased( true )
	SetShouldUseRoundWinningKillReplay( false )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	PlayerEarnMeter_SetEnabled( false )
	SetShouldUsePickLoadoutScreen( true )
	SetAllowLoadoutChangeFunc( FD_ShouldAllowChangeLoadout )
	SetGetDifficultyFunc( FD_GetDifficultyLevel )
	TeamTitanSelectMenu_Init() // show the titan select menu in this mode

	//general Callbacks
	AddCallback_EntitiesDidLoad( LoadEntities )
	AddCallback_GameStateEnter( eGameState.Prematch,FD_createHarvester )
	AddCallback_GameStateEnter( eGameState.Playing, startMainGameLoop )
	AddCallback_OnRoundEndCleanup( FD_NPCCleanup )
	AddCallback_OnClientConnected( GamemodeFD_InitPlayer )
	AddCallback_OnClientDisconnected( OnPlayerDisconnectedOrDestroyed )
	AddCallback_OnPlayerGetsNewPilotLoadout( FD_OnPlayerGetsNewPilotLoadout )
	ClassicMP_SetEpilogue( FD_SetupEpilogue )

	//Damage Callbacks
	AddDamageByCallback( "player", FD_DamageByPlayerCallback)
	AddDamageCallback( "player", DamageScaleByDifficulty )
	AddDamageCallback( "npc_titan", DamageScaleByDifficulty )
	AddDamageCallback( "npc_turret_sentry", DamageScaleByDifficulty )
	AddDamageCallback( "npc_turret_sentry",RevivableTurret_DamageCallback)
	//Spawn Callbacks
	AddSpawnCallback( "npc_titan", HealthScaleByDifficulty )
	AddSpawnCallback( "npc_super_spectre", HealthScaleByDifficulty )
	AddCallback_OnPlayerRespawned( FD_PlayerRespawnCallback )
	AddSpawnCallback("npc_turret_sentry", AddTurretSentry )
	//death Callbacks
	AddCallback_OnNPCKilled( OnNpcDeath )
	AddCallback_OnPlayerKilled( GamemodeFD_OnPlayerKilled )
	AddDeathCallback( "npc_frag_drone", OnTickDeath ) // ticks dont come up in the other callback because of course they dont

	//Command Callbacks
	AddClientCommandCallback( "FD_ToggleReady", ClientCommandCallbackToggleReady )
	AddClientCommandCallback( "FD_UseHarvesterShieldBoost", useShieldBoost )

	//shop Callback
	SetBoostPurchaseCallback( FD_BoostPurchaseCallback )
	SetTeamReserveInteractCallback( FD_TeamReserveDepositOrWithdrawCallback )

	//earn meter
	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	//Data Collection
	AddStunLaserHealCallback( FD_StunLaserHealTeammate )
	AddBatteryHealCallback( FD_BatteryHealTeammate )
	AddSmokeHealCallback( FD_SmokeHealTeammate )
	SetUsedCoreCallback( FD_UsedCoreCallback )

	//todo:are pointValueOverride exist?
	//Score Event
	AddArcTrapTriggeredCallback( FD_OnArcTrapTriggered )
	AddArcWaveDamageCallback( FD_OnArcWaveDamage )
	AddOnTetherCallback( FD_OnTetherTrapTriggered )
	AddSonarStartCallback( FD_OnSonarStart )
}

// this might need updating when we do dropship things
bool function FD_ShouldAllowChangeLoadout( entity player )
{
	return GetGlobalNetTime( "FD_nextWaveStartTime" ) > Time()
}

void function FD_BoostPurchaseCallback( entity player, BoostStoreData data )
{
	file.playerAwardStats[player]["moneySpent"] += float( data.cost )
}

void function FD_PlayerRespawnCallback( entity player )
{
	if( player in file.players )
		file.players[player].lastRespawn = Time()

	if( GetCurrentPlaylistVarInt( "fd_at_unlimited_ammo", 1 ) )
		FD_GivePlayerInfiniteAntiTitanAmmo( player )

	if ( !file.playersHaveTitans )
	{
		// why in the fuck do i need to WaitFrame() here, this sucks
		thread PlayerEarnMeter_SetMode_Threaded( player, 0 )
	}

	if( file.dropshipState == eDropshipState.Returning )
		return
	if( GetGameState() != eGameState.Playing)
		return

	if( player.GetPersistentVar( "spawnAsTitan" ) )
		return

	player.SetInvulnerable()
	if( file.dropshipState == eDropshipState.Idle )
	{
		thread FD_DropshipSpawnDropship()
	}
	//Attach player
	FirstPersonSequenceStruct idleSequence
	idleSequence.firstPersonAnim = DROPSHIP_IDLE_ANIMS_POV[ file.playersInShip ]
	idleSequence.thirdPersonAnim = DROPSHIP_IDLE_ANIMS[ file.playersInShip++ ]
	idleSequence.attachment = "ORIGIN"
	idleSequence.teleport = true
	idleSequence.viewConeFunction = ViewConeFree
	idleSequence.hideProxy = true
	thread FirstPersonSequence( idleSequence, player, file.dropship )
	file.playersInDropship.append( player )
}


void function PlayerEarnMeter_SetMode_Threaded( entity player, int mode )
{
	WaitFrame()
	if ( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, mode )
}

void function FD_OnPlayerGetsNewPilotLoadout( entity player, PilotLoadoutDef loadout )
{
	if( GetCurrentPlaylistVarInt( "fd_at_unlimited_ammo", 1 ) )
		FD_GivePlayerInfiniteAntiTitanAmmo( player )
}

void function FD_GivePlayerInfiniteAntiTitanAmmo( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
	foreach ( entity weaponEnt in weapons )
	{
		if ( weaponEnt.GetWeaponInfoFileKeyField( "menu_category" ) != "at" )
			continue

		if( !weaponEnt.HasMod( "at_unlimited_ammo" ) )
		{
			array<string> mods = weaponEnt.GetMods()
			mods.append( "at_unlimited_ammo" )
			weaponEnt.SetMods( mods )
		}
	}
}

void function FD_TeamReserveDepositOrWithdrawCallback( entity player, string action, int amount )
{
	switch( action )
	{
		case"deposit":
			file.playerAwardStats[player]["moneyShared"] += float( amount )
			break
		case"withdraw":
			file.playerAwardStats[player]["moneyShared"] -= float( amount ) 
			break
	}
}
void function GamemodeFD_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	//set longest Time alive for end awards
	float timeAlive = Time() - file.players[victim].lastRespawn
	if(timeAlive>file.playerAwardStats[victim]["longestLife"])
		file.playerAwardStats[victim]["longestLife"] = timeAlive

	//set died this round for round end money boni
	file.players[victim].diedThisRound = true

	//play voicelines for amount of players alive
	array<entity> militiaplayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
	int deaths = 0
	foreach ( entity player in militiaplayers )
		if ( !IsAlive( player ) )
			deaths++

	foreach( entity player in GetPlayerArray() )
	{
		if ( player == victim || player.GetTeam() != TEAM_MILITIA )
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
	{
		return
	}
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
	thread SetTurretSettings_threaded( player )
	// only start the highlight when we start playing, not during dropship
	if ( GetGameState() >= eGameState.Playing )
		Highlight_SetFriendlyHighlight( player, "sp_friendly_hero" )

	if( file.playersHaveTitans ) // first wave is index 0
	{
		PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
	}
	// unfortunate that i cant seem to find a nice callback for them exiting that menu but thisll have to do
	thread TryDisableTitanSelectionForPlayerAfterDelay( player, TEAM_TITAN_SELECT_DURATION_MIDGAME )
	thread TrackDeployedArcTrapThisRound( player )
}

void function TrackDeployedArcTrapThisRound( entity player )
{
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
				OnPlayerDisconnectedOrDestroyed( player )
			else
				ClearInValidTurret()
		}
	)

	while( IsValid( player ) )
	{
		entity ArcTrap = expect entity ( player.WaitSignal( "DeployArcTrap" ).projectile )
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
			if( IsValid( player ) )
			{
				DisableTitanSelectionForPlayer( player )
			}
		}
	)

	wait waitAmount
	if ( file.playersHaveTitans )
		DisableTitanSelectionForPlayer( player )
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
}

void function OnNpcDeath( entity victim, entity attacker, var damageInfo )
{
	if( attacker.GetClassName() == "npc_turret_sentry" && IsValidPlayer( attacker.GetBossPlayer() ) )
	{
		file.playerAwardStats[ attacker.GetBossPlayer() ]["turretKills"]++
	}
	if( victim.IsTitan() && attacker in file.players )
		file.playerAwardStats[attacker]["titanKills"]++
	int victimTypeID = FD_GetAITypeID_ByString( victim.GetTargetName() )
	if( ( victimTypeID == eFD_AITypeIDs.TITAN_MORTAR ) || ( victimTypeID == eFD_AITypeIDs.SPECTRE_MORTAR ) )
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

	if ( victim.GetOwner() == attacker || !attacker.IsPlayer() || ( attacker == victim ) || ( victim.GetBossPlayer() == attacker ) || victim.GetClassName() == "npc_turret_sentry" )
		return

	int playerScore = 0
	int money = 0
	int scriptDamageType = DamageInfo_GetCustomDamageType( damageInfo )
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	if ( victim.IsNPC() )
	{
		string eventName = FD_GetScoreEventName( victim.GetClassName() )
		playerScore = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )

		switch ( victim.GetClassName() )
		{
			case "npc_soldier":
				money = 5
				break
			case "npc_drone":
			case "npc_spectre":
				money = 10
				break
			case "npc_stalker":
				money = 15
				break
			case "npc_super_spectre":
				money = 20
				break
			default:
				money = 0 // titans seem to total up to 50 money undoomed health
		}
		foreach( player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_OnTitanKilled", attacker.GetEncodedEHandle(), victim.GetEncodedEHandle(), scriptDamageType, damageSourceId )
	}
	if ( money != 0 )
		AddMoneyToPlayer( attacker , money )

	attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, playerScore ) // seems to be how combat score is counted
	file.players[attacker].scoreThisRound += playerScore
	table<int, bool> alreadyAssisted
	foreach( DamageHistoryStruct attackerInfo in victim.e.recentDamageHistory )
	{
		if ( !IsValid( attackerInfo.attacker ) || !attackerInfo.attacker.IsPlayer() || attackerInfo.attacker == victim )
			continue

		bool exists = attackerInfo.attacker.GetEncodedEHandle() in alreadyAssisted ? true : false
		if( attackerInfo.attacker != attacker && !exists )
		{
			alreadyAssisted[attackerInfo.attacker.GetEncodedEHandle()] <- true
			attackerInfo.attacker.AddToPlayerGameStat( PGS_DEFENSE_SCORE, playerScore )		// i assume this is how support score gets added
		}
	}


}

void function RateSpawnpoints_FD( int _0, array<entity> _1, int _2, entity _3 )
{

}

bool function useShieldBoost( entity player, array<string> args )
{
	if( ( GetGlobalNetTime( "FD_harvesterInvulTime" ) < Time() ) && ( player.GetPlayerNetInt( "numHarvesterShieldBoost" ) > 0 ) )
	{
		fd_harvester.harvester.SetShieldHealth( fd_harvester.harvester.GetShieldHealthMax() )
		SetGlobalNetTime( "FD_harvesterInvulTime", Time() + 5 )
		AddPlayerScore( player, "FDShieldHarvester" )
		MessageToTeam( TEAM_MILITIA,eEventNotifications.FD_PlayerBoostedHarvesterShield, null, player )
		player.SetPlayerNetInt( "numHarvesterShieldBoost", player.GetPlayerNetInt( "numHarvesterShieldBoost" ) - 1 )
		file.playerAwardStats[player]["harvesterHeals"]++
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
	startHarvester()

	bool showShop = false
	for( int i = GetGlobalNetInt( "FD_currentWave" ); i < waveEvents.len(); i++ )
	{
		if( file.waveRestart )
		{
			showShop = true
			foreach( entity player in GetPlayerArray() )
			{
				SetMoneyForPlayer( player, file.players[player].moneyThisRound )
				player.SetPlayerNetInt( "numHarvesterShieldBoost", 0 )
				player.SetPlayerNetInt( "numSuperRodeoGrenades", 0 )
				PlayerInventory_TakeAllInventoryItems( player )
			}
			SetGlobalNetTime( "FD_nextWaveStartTime", Time() + 75 )
		}

		if( !runWave( i, showShop ) )
			break

		if( i == 0 )
		{
			PlayerEarnMeter_SetEnabled( true )
			showShop = true
			foreach( entity player in GetPlayerArray() )
			{
				PlayerEarnMeter_SetMode( player, 1 ) // show the earn meter
				PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
			}
			file.playersHaveTitans = true
			DisableTitanSelection()
		}
	}

	// end of game
	EnableTitanSelection()

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
	file.havesterWasDamaged = false
	file.harvesterShieldDown = false
	SetEnemyAmountNetVars( waveIndex )
	for( int i = 0; i < 20; i++ )//Number of npc type ids
	{
		file.harvesterDamageSource.append( 0.0 )
	}
	foreach( entity player in GetPlayerArray() )
	{
		file.players[player].diedThisRound = false
		file.players[player].scoreThisRound = 0
		file.players[player].moneyThisRound = GetPlayerMoney( player )
		file.players[ player ].deployedEntityThisRound.clear()
	}
	array<int> enemys = getHighestEnemyAmountsForWave( waveIndex )

	foreach( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FD_AnnouncePreParty", enemys[0], enemys[1], enemys[2], enemys[3], enemys[4], enemys[5], enemys[6], enemys[7], enemys[8] )
	}
	if( file.waveRestart )
	{
		file.waveRestart = false
		MessageToTeam( TEAM_MILITIA,eEventNotifications.FD_WaveRestart )
	}
	if( shouldDoBuyTime )
	{
		SetGlobalNetInt( "FD_waveState", WAVE_STATE_BREAK )
		OpenBoostStores()
		entity parentCrate = GetBoostStores()[0].GetParent()
		parentCrate.Minimap_AlwaysShow( TEAM_MILITIA, null )
		Minimap_PingForTeam( TEAM_MILITIA, shopPosition, 150, 5, TEAM_COLOR_YOU / 255.0, 5 )
		foreach( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_NotifyStoreOpen" )
		while( Time() < GetGlobalNetTime( "FD_nextWaveStartTime" ) )
		{
			if( allPlayersReady() )
				SetGlobalNetTime( "FD_nextWaveStartTime", Time() )
			WaitFrame()
		}
		parentCrate.Minimap_Hide( TEAM_MILITIA, null )
		CloseBoostStores()
		MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_StoreClosing )
	}

	//SetGlobalNetTime("FD_nextWaveStartTime",Time()+10)
	wait 10
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_INCOMING )
	foreach( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FD_ClearPreParty" )
		player.SetPlayerNetBool( "FD_readyForNextWave", false )
	}
	SetGlobalNetBool( "FD_waveActive", true )
	MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_AnnounceWaveStart )
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_BREAK )

	//main wave loop
	thread SetWaveStateReady()
	executeWave()
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_COMPLETE )
	if( !IsHarvesterAlive( fd_harvester.harvester ) )
	{
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

		foreach( entity player in GetPlayerArray() )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_DisplayHarvesterKiller", GetGlobalNetInt( "FD_restartsRemaining" ), getHintForTypeId( highestDamageSource[0] ), highestDamageSource[0], highestDamage[0] / totalDamage, highestDamageSource[1], highestDamage[1] / totalDamage , highestDamageSource[2], highestDamage[2] / totalDamage )
		}

		if( GetGlobalNetInt( "FD_restartsRemaining" ) > 0 )
			FD_DecrementRestarts()
		else
			SetRoundBased(false)

		file.waveRestart = true //wave restart point
		SetWinner( TEAM_IMC )//restart round
		spawnedNPCs = [] // reset npcs count
		restetWaveEvents()
		foreach( player in GetPlayerArray() )
			PlayerEarnMeter_AddEarnedAndOwned( player, 1.0, 1.0 )
		return false
	}


	wait 2
	//wave end

	SetGlobalNetBool( "FD_waveActive", false )
	MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_AnnounceWaveEnd )

	if ( isFinalWave() && IsHarvesterAlive( fd_harvester.harvester ) )
	{
		//Game won code
		MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_AnnounceWaveEnd )
		foreach( entity player in GetPlayerArray() )
		{
			AddPlayerScore( player, "FDTeamWave" )
		}
		wait 1
		int highestScore = 0;
		entity highestScore_player = GetPlayerArray()[0]
		foreach( entity player in GetPlayerArray() )
		{

			if( !file.players[player].diedThisRound )
				AddPlayerScore( player, "FDDidntDie" )
			if( highestScore < file.players[player].scoreThisRound )
			{
				highestScore = file.players[player].scoreThisRound
				highestScore_player = player
			}

		}
		file.playerAwardStats[highestScore_player]["mvp"]++
		AddPlayerScore( highestScore_player, "FDWaveMVP" )
		wait 1
		foreach( entity player in GetPlayerArray() )
			if( !file.havesterWasDamaged )
				AddPlayerScore( player, "FDTeamFlawlessWave" )

		foreach(entity player in GetPlayerArray() )
		{
			if( IsAlive( player ) )
			{
				float timeAlive = Time() - file.players[player].lastRespawn
				if(timeAlive>file.playerAwardStats[player]["longestLife"])
					file.playerAwardStats[player]["longestLife"] = timeAlive
			}
			if( IsValid( player.GetPetTitan ) )
			{
				float timeAlive = Time() - file.players[player].lastTitanDrop
				if(timeAlive>file.playerAwardStats[player]["longestTitanLife"])
					file.playerAwardStats[player]["longestTitanLife"] = timeAlive
			}
		}



		SetRoundBased(false)
		SetWinner(TEAM_MILITIA)
		PlayFactionDialogueToTeam( "fd_matchVictory", TEAM_MILITIA )
		return true
	}

	if(!file.havesterWasDamaged)
	{
		PlayFactionDialogueToTeam( "fd_waveRecapPerfect", TEAM_MILITIA )
		wait 5
	}
	else
	{
		float damagepercent = ( ( file.harvesterDamageTaken / fd_harvester.harvester.GetMaxHealth().tofloat() ) * 100 )
		float healthpercent = ( ( fd_harvester.harvester.GetHealth().tofloat() / fd_harvester.harvester.GetMaxHealth() ) * 100 )
		if ( damagepercent < 5 ) // if less than 5% damage taken
			PlayFactionDialogueToTeam( "fd_waveRecapNearPerfect", TEAM_MILITIA )
		else if ( healthpercent < 15 ) // if less than 15% health remains and more than 5% damage taken
			PlayFactionDialogueToTeam( "fd_waveRecapLowHealth", TEAM_MILITIA )
		wait 5
	}

	if ( isSecondWave() )
	{
		// supposed to add dialogues like "GOOD WORK TEAM" then "YOUR TITAN IS READY"
		// done ^
		PlayFactionDialogueToTeam( "fd_titanReadyNag" , TEAM_MILITIA )
		wait 5
	}

	//Player scoring
	MessageToTeam( TEAM_MILITIA, eEventNotifications.FD_NotifyWaveBonusIncoming )
	wait 2
	foreach( entity player in GetPlayerArray() )
	{
		if ( isSecondWave() )
			PlayFactionDialogueToPlayer( "fd_wavePayoutFirst", player )
		else
			PlayFactionDialogueToPlayer( "fd_wavePayoutAddtnl", player )
		AddPlayerScore( player, "FDTeamWave" )
		AddMoneyToPlayer( player, GetCurrentPlaylistVarInt( "fd_money_per_round", 600 ) )
		// is this in the right place? do we want to be adding for each player?
		// this function is called "Set" but in reality it is "Add"
		SetJoinInProgressBonus( GetCurrentPlaylistVarInt( "fd_money_per_round" ,600 ) )
		EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
	}
	wait 1
	foreach( entity player in GetPlayerArray() )
	{
		if( !file.players[player].diedThisRound )
		{
			AddPlayerScore( player, "FDDidntDie" )
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_DIDNT_DIE )
		}
		AddMoneyToPlayer( player, 100 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
	}
	wait 1
	int highestScore = 0;
	entity highestScore_player = GetPlayerArray()[0]
	foreach( entity player in GetPlayerArray() )
	{
		if( highestScore < file.players[player].scoreThisRound )
		{
			highestScore = file.players[player].scoreThisRound
			highestScore_player = player
		}
	}
	file.playerAwardStats[highestScore_player]["mvp"]++
	AddPlayerScore( highestScore_player, "FDWaveMVP" )
	AddMoneyToPlayer( highestScore_player, 100 )
	highestScore_player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_MVP )
	EmitSoundOnEntityOnlyToPlayer( highestScore_player, highestScore_player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
	foreach( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FD_NotifyMVP", highestScore_player.GetEncodedEHandle() )
	}
	wait 1
	foreach( entity player in GetPlayerArray() )
	{

		if( !file.havesterWasDamaged )
		{
			AddPlayerScore( player, "FDTeamFlawlessWave" )
			AddMoneyToPlayer( player, 100 )
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_TEAM_FLAWLESS_WAVE )
			EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
		}
	}

	wait 1

	if( waveIndex<waveEvents.len() )
		SetGlobalNetTime( "FD_nextWaveStartTime", Time() + 75 )

	return true

}

void function SetWaveStateReady()
{
	wait 5
	SetGlobalNetInt( "FD_waveState", WAVE_STATE_IN_PROGRESS )
}

void function FD_StunLaserHealTeammate( entity player, entity target, int shieldRestoreAmount )
{
	if( IsValid( player ) && player in file.players ){
		file.playerAwardStats[player]["heals"] += float( shieldRestoreAmount )
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, shieldRestoreAmount / 100 )
		file.players[ player ].scoreThisRound += shieldRestoreAmount / 100
	}
}

void function FD_SmokeHealTeammate( entity player, entity target, int shieldRestoreAmount )
{
	if( IsValid( player ) && player in file.players ){
		file.playerAwardStats[player]["heals"] += float( shieldRestoreAmount )
		player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, shieldRestoreAmount / 100 )
		file.players[ player ].scoreThisRound += shieldRestoreAmount / 100
	}
}

void function FD_BatteryHealTeammate( entity battery, entity titan, int shieldRestoreAmount, int healthRestoreAmount )
{
	if( !IsValid( battery ) )
		return

	entity BatteryParent = battery.GetParent()
	entity TargetTitan
	int currentHeal
	int currentHealScore
	
	if( titan.IsPlayer() )
		TargetTitan = titan
	else if( titan.GetBossPlayer() != null )
		TargetTitan = titan.GetBossPlayer()
	else
		return

	if( BatteryParent == TargetTitan )
		return

	if( IsValid( BatteryParent ) && BatteryParent in file.players ){
		AddPlayerScore( BatteryParent, "FDTeamHeal" )
		currentHeal = shieldRestoreAmount + healthRestoreAmount
		currentHealScore = currentHeal / 100
		file.playerAwardStats[BatteryParent]["heals"] += float( currentHeal )
		BatteryParent.AddToPlayerGameStat( PGS_DEFENSE_SCORE, currentHealScore )
		file.players[ BatteryParent ].scoreThisRound += currentHealScore
	}
}

void function FD_OnArcTrapTriggered( entity victim, var damageInfo )
{
	entity owner = DamageInfo_GetAttacker( damageInfo )

	if( !IsValidPlayer( owner ) )
		return

	AddPlayerScore( owner, "FDArcTrapTriggered" )
}

void function FD_OnArcWaveDamage( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if( !IsValidPlayer( attacker ) )
		return

	AddPlayerScore( attacker, "FDArcWave" )
}

void function FD_OnTetherTrapTriggered( entity owner, entity endEnt )
{
	if( !IsValidPlayer( owner ) )
		return

	AddPlayerScore( owner, "FDTetherTriggered" )
}

void function FD_OnSonarStart( entity ent, vector position, int sonarTeam, entity sonarOwner )
{
	if( !IsValidPlayer( sonarOwner ) )
		return

	AddPlayerScore( sonarOwner, "FDSonarPulse" )//should only triggered once during sonar time?
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
	wait 5
	foreach(entity player in GetPlayerArray() )
	{
		player.FreezeControlsOnServer()
		ScreenFadeToBlackForever( player, 6.0 )

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

	foreach( entity player in GetPlayerArray() )
	{
		if( !( player in awardResults ) )
		{
			awardResults[player] <- "damageDealt"
			awardResultValues[player] <- file.playerAwardStats[player]["damageDealt"]
		}
	}

	foreach( entity player in GetPlayerArray() )
	{
		if( !IsValid( player ) )
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
	/* //debugging prints
	foreach( entity player, table< string, float > data in file.playerAwardStats)
	{
		printt("Stats for", player)
		foreach( string ref, float val in data )
		{
			printt("    ",ref,val)
		}
	}
	foreach( string ref, entity player in awardOwners )
	{
		printt( player, ref, awardValues[ref] )
	}
	*/
	wait 20
	SetGameState(eGameState.Postmatch)
}

void function IncrementPlayerstat_TurretRevives( entity player )
{
	file.playerAwardStats[player]["turretsRepaired"]++
}

void function SpawnCallback_SafeTitanSpawnTime( entity ent )
{
	if( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) )
	{
		entity player = GetPetTitanOwner( ent )
		file.players[player].lastTitanDrop = Time()
	}
}

void function DeathCallback_CalculateTitanAliveTime( entity ent )
{
	if( ent.IsTitan() && IsValid( GetPetTitanOwner( ent ) ) )
	{
		entity player = GetPetTitanOwner( ent )
		float aliveTime = file.players[player].lastTitanDrop - Time()
		if( aliveTime > file.playerAwardStats[player]["longestTitanLife"] )
			file.playerAwardStats[player]["longestTitanLife"] = aliveTime
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

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )

	if ( !damageSourceID && !damageAmount && !attacker )
		return

	fd_harvester.lastDamage = Time()

	damageAmount = ( damageAmount * GetCurrentPlaylistVarFloat( "fd_player_damage_scalar", 1.0 ) )



	float shieldPercent = ( ( harvester.GetShieldHealth().tofloat() / harvester.GetShieldHealthMax() ) * 100 )
	if ( shieldPercent < 100 && !file.harvesterShieldDown )
		PlayFactionDialogueToTeam( "fd_baseShieldTakingDmg", TEAM_MILITIA )

	if ( shieldPercent < 35 && !file.harvesterShieldDown ) // idk i made this up
		PlayFactionDialogueToTeam( "fd_baseShieldLow", TEAM_MILITIA )

	if ( harvester.GetShieldHealth() == 0 )
	{
		if( !file.harvesterShieldDown )
		{
			PlayFactionDialogueToTeam( "fd_baseShieldDown", TEAM_MILITIA )
			file.harvesterShieldDown = true // prevent shield dialogues from repeating
		}
		file.harvesterDamageTaken = file.harvesterDamageTaken + damageAmount // track damage for wave recaps
		float newHealth = harvester.GetHealth() - damageAmount
		float oldhealthpercent = ( ( harvester.GetHealth().tofloat() / harvester.GetMaxHealth() ) * 100 )
		float healthpercent = ( ( newHealth / harvester.GetMaxHealth() ) * 100 )

		if ( healthpercent <= 75 && oldhealthpercent > 75 ) // we don't want the dialogue to keep saying "Harvester is below 75% health" everytime they take additional damage
			PlayFactionDialogueToTeam( "fd_baseHealth75", TEAM_MILITIA )

		if ( healthpercent <= 50 && oldhealthpercent > 50 )
			PlayFactionDialogueToTeam( "fd_baseHealth50", TEAM_MILITIA )

		if ( healthpercent <= 25 && oldhealthpercent > 25 )
			PlayFactionDialogueToTeam( "fd_baseHealth25", TEAM_MILITIA )

		if( healthpercent <= 10 )
			PlayFactionDialogueToTeam( "fd_baseLowHealth", TEAM_MILITIA )

		if( newHealth <= 0 )
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, fd_harvester.harvester.GetOrigin(), "coop_generator_destroyed" )
			newHealth = 1
			harvester.SetInvulnerable()
			DamageInfo_SetDamage( damageInfo, 0.0 )
			PlayFactionDialogueToTeam( "fd_baseDeath", TEAM_MILITIA )
			fd_harvester.rings.Anim_Stop()
		}
		harvester.SetHealth( newHealth )
		file.havesterWasDamaged = true
	}

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_titancore_laser_cannon )
    	DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) / 10 ) // laser core shreds super well for some reason

	if ( attacker.IsPlayer() )
		attacker.NotifyDidDamage( harvester, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
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
		if( IsValidPlayer( BossPlayer ) && !file.players[ BossPlayer ].deployedEntityThisRound.contains( npc ) )
			continue

		if ( IsValid( npc ) )
			npc.Destroy()
	}
	if( IsValid( fd_harvester.harvester ) )
		fd_harvester.harvester.Destroy()//Destroy harvester after match over
}

void function HarvesterThink()
{
	entity harvester = fd_harvester.harvester


	EmitSoundOnEntity( harvester, "coop_generator_startup" )

	float lastTime = Time()
	wait 4
	int lastShieldHealth = harvester.GetShieldHealth()
	generateBeamFX( fd_harvester )
	generateShieldFX( fd_harvester )

	EmitSoundOnEntity( harvester, "coop_generator_ambient_healthy" )

	bool isRegening = false // stops the regenning sound to keep stacking on top of each other

	while ( IsHarvesterAlive( harvester ) )
	{
		float currentTime = Time()
		float deltaTime = currentTime -lastTime

		if ( IsValid( fd_harvester.particleShield ) )
		{
			vector shieldColor = GetShieldTriLerpColor( 1.0 - ( harvester.GetShieldHealth().tofloat() / harvester.GetShieldHealthMax().tofloat() ) )
			EffectSetControlPointVector( fd_harvester.particleShield, 1, shieldColor )
		}

		if( IsValid( fd_harvester.particleBeam ) )
		{
			vector beamColor = GetShieldTriLerpColor( 1.0 - ( harvester.GetHealth().tofloat() / harvester.GetMaxHealth().tofloat() ) )
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

			if( harvester.GetShieldHealth() == 0 )
				EmitSoundOnEntity( harvester, "coop_generator_shieldrecharge_start" )

			if (!isRegening)
			{
				EmitSoundOnEntity( harvester, "coop_generator_shieldrecharge_resume" )
				file.harvesterShieldDown = false
				if (GetGlobalNetBool( "FD_waveActive" ) )
					PlayFactionDialogueToTeam( "fd_baseShieldRecharging", TEAM_MILITIA )
				else
					PlayFactionDialogueToTeam( "fd_baseShieldRechargingShort", TEAM_MILITIA )
						isRegening = true
			}

			float newShieldHealth = ( harvester.GetShieldHealthMax() / GENERATOR_SHIELD_REGEN_TIME * deltaTime ) + harvester.GetShieldHealth()

			if ( newShieldHealth >= harvester.GetShieldHealthMax() )
			{
				StopSoundOnEntity( harvester, "coop_generator_shieldrecharge_resume" )
				harvester.SetShieldHealth( harvester.GetShieldHealthMax() )
				EmitSoundOnEntity( harvester, "coop_generator_shieldrecharge_end" )
				if( GetGlobalNetBool( "FD_waveActive" ) )
					PlayFactionDialogueToTeam( "fd_baseShieldUp", TEAM_MILITIA )
				isRegening = false
			}
			else
			{
				harvester.SetShieldHealth( newShieldHealth )
			}
		} else if ( ( ( currentTime-fd_harvester.lastDamage ) < GENERATOR_SHIELD_REGEN_DELAY ) && ( harvester.GetShieldHealth() < harvester.GetShieldHealthMax() ) )
			isRegening = false

		if ( ( lastShieldHealth > 0 ) && ( harvester.GetShieldHealth() == 0 ) )
			EmitSoundOnEntity( harvester, "coop_generator_shielddown" )

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
		{
			wait EmitSoundOnEntity( fd_harvester.harvester, "coop_generator_underattack_alarm" )
		}
		else
		{
			WaitFrame()
		}
	}
}

void function initNetVars()
{
	SetGlobalNetInt( "FD_totalWaves", waveEvents.len() )
	SetGlobalNetInt( "burn_turretLimit", 2 )
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
	float damage = DamageInfo_GetDamage( damageInfo )
	file.playerAwardStats[player]["damageDealt"] += damage
	file.players[ player ].scoreThisRound += damage.tointeger() //TODO NOT HOW SCORE WORKS
	if( victim.IsTitan() )
	{
		//TODO Money and score for titan damage
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

	if ( attacker.IsPlayer() && attacker.GetTeam() == TEAM_IMC ) // in case we ever want a PvP in Frontier Defense, don't scale their damage
		return


	if ( attacker == ent ) // dont scale self damage
		return


	DamageInfo_SetDamage( damageInfo, ( damageAmount * GetCurrentPlaylistVarFloat( "fd_player_damage_scalar", 1.0 ) ) )



}



void function HealthScaleByDifficulty( entity ent )
{

	if ( ent.GetTeam() != TEAM_IMC )
		return


	if (ent.IsTitan()&& IsValid(GetPetTitanOwner( ent ) ) ) // in case we ever want pvp in FD
		return

	if ( ent.IsTitan() )
		ent.SetMaxHealth( ent.GetMaxHealth() + GetCurrentPlaylistVarInt( "fd_titan_health_adjust", 0 ) )
	else
		ent.SetMaxHealth( ent.GetMaxHealth() + GetCurrentPlaylistVarInt( "fd_reaper_health_adjust", 0 ) )

	if( GetCurrentPlaylistVarInt( "fd_pro_titan_shields", 0 ) && ent.IsTitan() )
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

	fd_harvester = SpawnHarvester( file.harvester_info.GetOrigin(), file.harvester_info.GetAngles(), GetCurrentPlaylistVarInt( "fd_harvester_health", 25000 ), GetCurrentPlaylistVarInt( "fd_harvester_shield", 6000 ), TEAM_MILITIA )
	fd_harvester.harvester.Minimap_SetAlignUpright( true )
	fd_harvester.harvester.Minimap_AlwaysShow( TEAM_IMC, null )
	fd_harvester.harvester.Minimap_AlwaysShow( TEAM_MILITIA, null )
	fd_harvester.harvester.Minimap_SetHeightTracking( true )
	fd_harvester.harvester.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	fd_harvester.harvester.Minimap_SetCustomState( eMinimapObject_prop_script.FD_HARVESTER )
	AddEntityCallback_OnDamaged( fd_harvester.harvester, OnHarvesterDamaged )
	thread CreateHarvesterHintTrigger( fd_harvester.harvester )
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
	trig.SetRadius( 1000 )	//Test setting
	trig.SetAboveHeight( 2500 )	//Test setting
	trig.SetBelowHeight( 2500 )	//Test setting
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
	if( !( activator in file.players ) )
		return
		
	if( GetGlobalNetInt( "FD_waveState" ) != WAVE_STATE_IN_PROGRESS )
		return

	if ( activator != null && activator.IsPlayer() && activator.GetTeam() == trig.GetTeam() && file.players[activator].leaveHarvester == true )
	{
		file.players[activator].lastNearHarvester = Time()
		file.players[activator].leaveHarvester = false
	}
}

void function OnLeaveNearHarvesterTrigger( entity trig, entity activator )
{
	if( !( activator in file.players ) )
		return
		
	if( GetGlobalNetInt( "FD_waveState" ) != WAVE_STATE_IN_PROGRESS )
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

void function LoadEntities()
{
	CreateBoostStoreLocation( TEAM_MILITIA, shopPosition, shopAngles )
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
					break
				case "info_fd_mode_model":
					entity prop = CreatePropDynamic( info_target.GetModelName(), info_target.GetOrigin(), info_target.GetAngles(), 6 )
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
	ValidateAndFinalizePendingStationaryPositions()
	initNetVars()
	SetTeam( GetTeamEnt( TEAM_IMC ), TEAM_IMC )
}


bool function allPlayersReady()
{
	foreach( entity player in GetPlayerArray() )
	{
		if( !player.GetPlayerNetBool( "FD_readyForNextWave" ) )
			return false
	}
	return true
}

void function CheckLastPlayerReady()
{
	int readyplayers = 0
	entity notready
	foreach( entity player in GetPlayerArray() )
	{
		if( player.GetPlayerNetBool( "FD_readyForNextWave" ) )
			readyplayers++
		else
			notready = player // keep a track of this player
	}
	if ( readyplayers == GetPlayerArray().len() - 1 )
		PlayFactionDialogueToPlayer( "fd_playerNeedsToReadyUp", notready ) // ready up i swear there's one player like this in every match i've played
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

	CheckLastPlayerReady()
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
	turret.Minimap_AlwaysShow( TEAM_IMC, null )
	turret.Minimap_AlwaysShow( TEAM_MILITIA, null )
	turret.Minimap_SetHeightTracking( true )
	turret.Minimap_SetCustomState( eMinimapObject_npc.FD_TURRET )
	entity player = turret.GetBossPlayer()
	file.players[ player ].deployedEntityThisRound.append( turret )
	AddEntityDestroyedCallback( turret, FD_OnEntityDestroyed )
	thread TurretRefundThink( turret )
}

function FD_OnEntityDestroyed( ent )
{
	expect entity( ent )

	Assert( ent.IsValidInternal() )
	entity player = IsTurret( ent ) ? ent.GetBossPlayer() : ent.GetOwner()

	if( !IsValid( player ) )
		return

	if( file.players[ player ].deployedEntityThisRound.contains( ent ) )
		file.players[ player ].deployedEntityThisRound.fastremovebyvalue( ent )
}

void function OnPlayerDisconnectedOrDestroyed( entity player )
{
	if( !IsValid( player ) )
	{
		ClearInValidTurret()
		return
	}

	foreach ( entity npc in GetEntArrayByClass_Expensive( "C_AI_BaseNPC" ) )
	{
		entity BossPlayer = npc.GetBossPlayer()
		if ( IsValidPlayer( BossPlayer ) && IsValid( npc ) && player == BossPlayer )
			npc.Destroy()
	}
	file.players[ player ].deployedEntityThisRound.clear()
}

void function ClearInValidTurret()
{
	foreach( entity turret in GetNPCArrayByClass( "npc_turret_sentry" ) )
	{
		entity BossPlayer = turret.GetBossPlayer()
		if ( !IsValidPlayer( BossPlayer ) && IsValid( turret ) )
			turret.Destroy()
	}
}

void function DisableTitanSelection()
{
	foreach ( entity player in GetPlayerArray() )
	{
		DisableTitanSelectionForPlayer( player )
	}
}

void function EnableTitanSelection()
{
	foreach ( entity player in GetPlayerArray() )
	{
		EnableTitanSelectionForPlayer( player )
	}
}

void function EnableTitanSelectionForPlayer( entity player )
{
	int enumCount = PersistenceGetEnumCount( "titanClasses" )

	if( !IsValid( player ) )
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

	if( !IsValid( player ) )
		return

	for ( int i = 0; i < enumCount; i++ )
	{
		string enumName = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		string selectedEnumName = PersistenceGetEnumItemNameForIndex( "titanClasses", player.GetPersistentVarAsInt("activeTitanLoadoutIndex") )
		if ( enumName != "" && enumName != selectedEnumName )
			player.SetPersistentVar( "titanClassLockState[" + enumName + "]", TITAN_CLASS_LOCK_STATE_LOCKED )
	}
}




void function FD_DropshipSpawnDropship()
{
	file.playersInShip = 0
	file.dropshipState = eDropshipState.InProgress
	file.dropship = CreateDropship( TEAM_MILITIA, FD_spawnPosition , FD_spawnAngles )


	file.dropship.SetModel( $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" )
	file.dropship.SetValueForModelKey( $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" )

	DispatchSpawn( file.dropship )
	file.dropship.SetModel( $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" )
	file.dropship.SetInvulnerable()
	file.dropship.SetNoTarget( true )

	thread PlayAnim(file.dropship, FD_DropshipGetAnimation())

	array<string> anims = GetRandomDropshipDropoffAnims()

	//thread WarpinEffect( $"models/vehicle/crow_dropship/crow_dropship.mdl", anims[0], file.dropship.GetOrigin(),f ile.dropship.GetAngles() ) //this does not work
	file.dropship.WaitSignal( "deploy" )
	file.dropshipState = eDropshipState.Returning
	foreach(int i,entity player in file.playersInDropship)
	{
		thread FD_DropshipDropPlayer( player, i )
	}
	file.playersInDropship.clear()

	wait 8
	file.dropshipState = eDropshipState.Idle
}

void function FD_DropshipDropPlayer(entity player,int playerDropshipIndex)
{
	player.EndSignal( "OnDestroy" )
	FirstPersonSequenceStruct jumpSequence
	jumpSequence.firstPersonAnim = DROPSHIP_EXIT_ANIMS_POV[ playerDropshipIndex ]
	jumpSequence.thirdPersonAnim = DROPSHIP_EXIT_ANIMS[ playerDropshipIndex ]
	jumpSequence.attachment = "ORIGIN"
	jumpSequence.blendTime = 0.0
	jumpSequence.viewConeFunction = ViewConeFree

	thread FirstPersonSequence( jumpSequence, player, file.dropship )

	//check the player
	if( IsValid( player ) )
	{
		WaittillAnimDone( player )
		player.ClearParent()
		ClearPlayerAnimViewEntity( player )
		player.ClearInvulnerable()
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
		return "dropship_coop_respawn_homestead"
	case "mp_lagoon":
		return "dropship_coop_respawn_lagoon"
	case "mp_overlook":
		return "dropship_coop_respawn_overlook"
	case "mp_outpost":
		return "dropship_coop_respawn_outpost"
	case "mp_wargames":
		return "dropship_coop_respawn_wargames"
	case "mp_digsite":
		return "dropship_coop_respawn_digsite"
	}
	return "dropship_coop_respawn"
}
