global function GamemodeFD_Init
global function RateSpawnpoints_FD
global function startHarvester
global function GetTargetNameForID

global function DisableTitanSelection
global function DisableTitanSelectionForPlayer
global function EnableTitanSelection
global function EnableTitanSelectionForPlayer

struct player_struct_fd{
	bool diedThisRound
	int scoreThisRound
	int totalMVPs
	int mortarUnitsKilled 
	int moneySpend
	int coresUsed
	float longestTitanLife //not implemented yet
	int turretsRepaired //not implemented yet
	int moneyShared
	float timeNearHarvester //dont know how to track
	float longestLife 
	int heals //dont know what to track
	int titanKills 
	float damageDealt
	int harvesterHeals
	float lastRespawn
}

global HarvesterStruct& fd_harvester
global vector shopPosition
global vector shopAngles = <0,0,0>
global table<string,array<vector> > routes
global array<entity> routeNodes
global array<entity> spawnedNPCs




struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<float> harvesterDamageSource
	bool havesterWasDamaged
	bool harvesterShieldDown
	float harvesterDamageTaken
	table<entity,player_struct_fd> players
	entity harvester_info
}file

void function GamemodeFD_Init()
{
	PrecacheModel( MODEL_ATTRITION_BANK )
	PrecacheModel( $"models/humans/grunts/imc_grunt_shield_captain.mdl" )
	PrecacheParticleSystem($"P_smokescreen_FD")

	RegisterSignal( "SniperSwitchedEnemy" ) // for use in SniperTitanThink behavior.
	RegisterSignal("FD_ReachedHarvester")
	RegisterSignal("OnFailedToPath")

	SetRoundBased(true)
	SetShouldUseRoundWinningKillReplay(false)
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	PlayerEarnMeter_SetEnabled(false)
	SetShouldUsePickLoadoutScreen( true )

	//general Callbacks
	AddCallback_EntitiesDidLoad(LoadEntities)
	AddCallback_GameStateEnter(eGameState.Prematch,FD_createHarvester)
	AddCallback_GameStateEnter( eGameState.Playing,startMainGameLoop)
	AddCallback_OnRoundEndCleanup(FD_NPCCleanup)
	AddCallback_OnClientConnected(GamemodeFD_InitPlayer)

	//Damage Callbacks
	AddDamageByCallback("player",FD_DamageByPlayerCallback)
	AddDamageCallback( "player", DamageScaleByDifficulty )
	AddDamageCallback( "npc_titan", DamageScaleByDifficulty )
	AddDamageCallback( "npc_turret_sentry", DamageScaleByDifficulty )
	//Spawn Callbacks
	AddSpawnCallback( "npc_titan", HealthScaleByDifficulty )
	AddSpawnCallback( "npc_super_spectre", HealthScaleByDifficulty )
	AddSpawnCallback( "player", FD_PlayerRespawnCallback )
	AddSpawnCallback("npc_turret_sentry", AddTurretSentry )
	//death Callbacks
	AddCallback_OnNPCKilled(OnNpcDeath)
	AddCallback_OnPlayerKilled(GamemodeFD_OnPlayerKilled)
	
	//Command Callbacks
	AddClientCommandCallback("FD_ToggleReady",ClientCommandCallbackToggleReady)
	AddClientCommandCallback("FD_UseHarvesterShieldBoost",useShieldBoost)

	//shop Callback
	SetBoostPurchaseCallback(FD_BoostPurchaseCallback)
	SetTeamReserveInteractCallback(FD_TeamReserveDepositOrWithdrawCallback)

	//earn meter
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
}

void function FD_BoostPurchaseCallback(entity player,BoostStoreData data) 
{
	file.players[player].moneySpend += data.cost
}

void function FD_PlayerRespawnCallback(entity player)
{
	if(player in file.players)
		file.players[player].lastRespawn = Time()

	Highlight_SetFriendlyHighlight( player, "sp_friendly_hero" )
}

void function FD_TeamReserveDepositOrWithdrawCallback(entity player, string action,int amount)
{
	switch(action)
	{
		case"deposit":
			file.players[player].moneyShared += amount
			break
		case"withdraw":
			file.players[player].moneyShared -= amount
			break
	}
}
void function GamemodeFD_OnPlayerKilled(entity victim, entity attacker, var damageInfo)
{
	file.players[victim].longestLife = Time() - file.players[victim].lastRespawn
	file.players[victim].diedThisRound = true
	array<entity> militiaplayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
	int deaths = 0
	foreach (entity player in militiaplayers)
		if (!IsAlive(player))
			deaths++

	foreach( entity player in GetPlayerArray() )
	{
		if (player == victim || player.GetTeam() != TEAM_MILITIA)
			continue

		if (deaths == 1) // only one pilot died
			PlayFactionDialogueToPlayer( "fd_singlePilotDown", player )
		else if (deaths > 1 && deaths < militiaplayers.len() - 1) // multiple pilots died but at least one alive
			PlayFactionDialogueToPlayer( "fd_multiPilotDown", player )
		else if (deaths == militiaplayers.len() - 1) // ur shit out of luck ur the only survivor
			PlayFactionDialogueToPlayer( "fd_onlyPlayerIsAlive", player )
	}
}

void function FD_UsedCoreCallback(entity titan,entity weapon)
{
	if(!(titan in file.players))
	{
		return
	}
	file.players[titan].coresUsed += 1
}

void function GamemodeFD_InitPlayer(entity player)
{	
	player_struct_fd data
	data.diedThisRound = false
	file.players[player] <- data
	thread SetTurretSettings_threaded(player)
	if(GetGlobalNetInt("FD_currentWave")>1)
		PlayerEarnMeter_AddEarnedAndOwned(player,1.0,1.0)

	if ( GetGlobalNetInt("FD_currentWave") != 0 )
		DisableTitanSelectionForPlayer( player ) // this might need moving to when they exit the titan selection UI when we do that
	else
		EnableTitanSelectionForPlayer( player )

	if ( GetGlobalNetInt("FD_currentWave") != 0 )
		DisableTitanSelectionForPlayer( player ) // this might need moving to when they exit the titan selection UI when we do that
	else
		EnableTitanSelectionForPlayer( player )

}
void function SetTurretSettings_threaded(entity player)
{	//has to be delayed because PlayerConnect callbacks get called in wrong order
	WaitFrame()
	DeployableTurret_SetAISettingsForPlayer_AP(player,"npc_turret_sentry_burn_card_ap_fd")
	DeployableTurret_SetAISettingsForPlayer_AT(player,"npc_turret_sentry_burn_card_at_fd")
}

void function OnNpcDeath( entity victim, entity attacker, var damageInfo )
{	
	if(victim.IsTitan()&&attacker in file.players)
		file.players[attacker].titanKills++
	int victimTypeID = FD_GetAITypeID_ByString(victim.GetTargetName())
	if(victimTypeID == eFD_AITypeIDs.TITAN_MORTAR||victimTypeID == eFD_AITypeIDs.SPECTRE_MORTAR)
		if(attacker in file.players)
			file.players[attacker].mortarUnitsKilled++
	int findIndex = spawnedNPCs.find( victim )
	if ( findIndex != -1 )
	{
		spawnedNPCs.remove( findIndex )

		string netIndex = GetAiNetIdFromTargetName(victim.GetTargetName())
		if(netIndex != "")
			SetGlobalNetInt(netIndex,GetGlobalNetInt(netIndex)-1)
		
		SetGlobalNetInt("FD_AICount_Current",GetGlobalNetInt("FD_AICount_Current")-1)
	}

	if ( victim.GetOwner() == attacker || !attacker.IsPlayer() || attacker == victim || victim.GetBossPlayer() == attacker || victim.GetClassName() == "npc_turret_sentry" )
		return
	
	int playerScore = 0
	int money = 0
	int scriptDamageType = DamageInfo_GetCustomDamageType( damageInfo )
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	if ( victim.IsNPC() )
	{
		string eventName = FD_GetScoreEventName( victim.GetClassName() )
		playerScore = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )

		switch (victim.GetClassName())
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
		foreach(player in GetPlayerArray())
			Remote_CallFunction_NonReplay( player, "ServerCallback_OnTitanKilled", attacker.GetEncodedEHandle(), victim.GetEncodedEHandle(), scriptDamageType, damageSourceId )
	}
	if (money != 0)
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

void function RateSpawnpoints_FD(int _0, array<entity> _1, int _2, entity _3){}

bool function useShieldBoost(entity player,array<string> args)
{
	if((GetGlobalNetTime("FD_harvesterInvulTime")<Time())&&(player.GetPlayerNetInt("numHarvesterShieldBoost")>0))
	{
		fd_harvester.harvester.SetShieldHealth(fd_harvester.harvester.GetShieldHealthMax())
		SetGlobalNetTime("FD_harvesterInvulTime",Time()+5)
		MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_PlayerHealedHarvester, null, player)
		player.SetPlayerNetInt( "numHarvesterShieldBoost", player.GetPlayerNetInt( "numHarvesterShieldBoost" ) - 1 )
		file.players[player].harvesterHeals += 1
	}
	return true
}

void function startMainGameLoop()
{
	thread mainGameLoop()
}

void function mainGameLoop()
{
	startHarvester()

	bool showShop = false
	for(int i = GetGlobalNetInt("FD_currentWave");i<waveEvents.len();i++)
	{
		if(!runWave(i,showShop))
			break

		if(i==0)
		{
			PlayerEarnMeter_SetEnabled(true)
			showShop = true
			foreach(entity player in GetPlayerArray())
			{
				PlayerEarnMeter_AddEarnedAndOwned(player,1.0,1.0)
			}
			DisableTitanSelection()
		}
		else if (i + 1 == waveEvents.len() )
		{
			EnableTitanSelection()
		}

	}


}



array<int> function getHighestEnemyAmountsForWave(int waveIndex)
{
	table<int,int> npcs
	npcs[eFD_AITypeIDs.TITAN]<-0
	npcs[eFD_AITypeIDs.TITAN_NUKE]<-0
	npcs[eFD_AITypeIDs.TITAN_ARC]<-0
	npcs[eFD_AITypeIDs.TITAN_MORTAR]<-0
	npcs[eFD_AITypeIDs.GRUNT]<-0
	npcs[eFD_AITypeIDs.SPECTRE]<-0
	npcs[eFD_AITypeIDs.SPECTRE_MORTAR]<-0
	npcs[eFD_AITypeIDs.STALKER]<-0
	npcs[eFD_AITypeIDs.REAPER]<-0
	npcs[eFD_AITypeIDs.TICK]<-0
	npcs[eFD_AITypeIDs.DRONE]<-0
	npcs[eFD_AITypeIDs.DRONE_CLOAK]<-0
	// npcs[eFD_AITypeIDs.RONIN]<-0
	// npcs[eFD_AITypeIDs.NORTHSTAR]<-0
	// npcs[eFD_AITypeIDs.SCORCH]<-0
	// npcs[eFD_AITypeIDs.LEGION]<-0
	// npcs[eFD_AITypeIDs.TONE]<-0
	// npcs[eFD_AITypeIDs.ION]<-0
	// npcs[eFD_AITypeIDs.MONARCH]<-0
	// npcs[eFD_AITypeIDs.TITAN_SNIPER]<-0


	foreach(WaveEvent e in waveEvents[waveIndex])
	{
		if(e.spawnEvent.spawnAmount==0)
			continue
		switch(e.spawnEvent.spawnType)
		{
			case(eFD_AITypeIDs.TITAN):
			case(eFD_AITypeIDs.RONIN):
			case(eFD_AITypeIDs.NORTHSTAR):
			case(eFD_AITypeIDs.SCORCH):
			case(eFD_AITypeIDs.TONE):
			case(eFD_AITypeIDs.ION):
			case(eFD_AITypeIDs.MONARCH):
			case(eFD_AITypeIDs.LEGION):
			case(eFD_AITypeIDs.TITAN_SNIPER):
				npcs[eFD_AITypeIDs.TITAN]+=e.spawnEvent.spawnAmount
				break
			default:
				npcs[e.spawnEvent.spawnType]+=e.spawnEvent.spawnAmount
		}
	}
	array<int> ret = [-1,-1,-1,-1,-1,-1,-1,-1,-1]
	foreach(int key,int value in npcs)
	{
		if(value==0)
			continue
		int lowestArrayIndex = 0
		bool keyIsSet = false
		foreach(index,int arrayValue in ret)
		{
			if(arrayValue==-1)
			{
				ret[index] = key
				keyIsSet = true
				break
			}
			if(npcs[ret[lowestArrayIndex]]>npcs[ret[index]])
				lowestArrayIndex = index
		}
		if((!keyIsSet)&&(npcs[ret[lowestArrayIndex]]<value))
			ret[lowestArrayIndex] = key
	}
	foreach(int val in ret){
		printt("ArrayVal",val)
	}
	return ret

}
void function SetEnemyAmountNetVars(int waveIndex)
{
	int total = 0
	table<int,int> npcs
	npcs[eFD_AITypeIDs.TITAN]<-0
	npcs[eFD_AITypeIDs.TITAN_NUKE]<-0
	npcs[eFD_AITypeIDs.TITAN_ARC]<-0
	npcs[eFD_AITypeIDs.TITAN_MORTAR]<-0
	npcs[eFD_AITypeIDs.GRUNT]<-0
	npcs[eFD_AITypeIDs.SPECTRE]<-0
	npcs[eFD_AITypeIDs.SPECTRE_MORTAR]<-0
	npcs[eFD_AITypeIDs.STALKER]<-0
	npcs[eFD_AITypeIDs.REAPER]<-0
	npcs[eFD_AITypeIDs.TICK]<-0
	npcs[eFD_AITypeIDs.DRONE]<-0
	npcs[eFD_AITypeIDs.DRONE_CLOAK]<-0
	// npcs[eFD_AITypeIDs.RONIN]<-0
	// npcs[eFD_AITypeIDs.NORTHSTAR]<-0
	// npcs[eFD_AITypeIDs.SCORCH]<-0
	// npcs[eFD_AITypeIDs.LEGION]<-0
	// npcs[eFD_AITypeIDs.TONE]<-0
	// npcs[eFD_AITypeIDs.ION]<-0
	// npcs[eFD_AITypeIDs.MONARCH]<-0
	// npcs[eFD_AITypeIDs.TITAN_SNIPER]<-0


	foreach(WaveEvent e in waveEvents[waveIndex])
	{
		if(e.spawnEvent.spawnAmount==0)
			continue
		switch(e.spawnEvent.spawnType)
		{
			case(eFD_AITypeIDs.TITAN):
			case(eFD_AITypeIDs.RONIN):
			case(eFD_AITypeIDs.NORTHSTAR):
			case(eFD_AITypeIDs.SCORCH):
			case(eFD_AITypeIDs.TONE):
			case(eFD_AITypeIDs.ION):
			case(eFD_AITypeIDs.MONARCH):
			case(eFD_AITypeIDs.LEGION):
			case(eFD_AITypeIDs.TITAN_SNIPER):
				npcs[eFD_AITypeIDs.TITAN]+=e.spawnEvent.spawnAmount
				break
			default:
				npcs[e.spawnEvent.spawnType]+=e.spawnEvent.spawnAmount
				
		}
		total+= e.spawnEvent.spawnAmount
	}
	SetGlobalNetInt("FD_AICount_Titan",npcs[eFD_AITypeIDs.TITAN])
	SetGlobalNetInt("FD_AICount_Titan_Nuke",npcs[eFD_AITypeIDs.TITAN_NUKE])
	SetGlobalNetInt("FD_AICount_Titan_Mortar",npcs[eFD_AITypeIDs.TITAN_MORTAR])
	SetGlobalNetInt("FD_AICount_Titan_Arc",npcs[eFD_AITypeIDs.TITAN_ARC])
	SetGlobalNetInt("FD_AICount_Grunt",npcs[eFD_AITypeIDs.GRUNT])
	SetGlobalNetInt("FD_AICount_Spectre",npcs[eFD_AITypeIDs.SPECTRE])
	SetGlobalNetInt("FD_AICount_Spectre_Mortar",npcs[eFD_AITypeIDs.SPECTRE_MORTAR])
	SetGlobalNetInt("FD_AICount_Stalker",npcs[eFD_AITypeIDs.STALKER])
	SetGlobalNetInt("FD_AICount_Reaper",npcs[eFD_AITypeIDs.REAPER])
	SetGlobalNetInt("FD_AICount_Ticks",npcs[eFD_AITypeIDs.TICK])
	SetGlobalNetInt("FD_AICount_Drone",npcs[eFD_AITypeIDs.DRONE])
	SetGlobalNetInt("FD_AICount_Drone_Cloak",npcs[eFD_AITypeIDs.DRONE_CLOAK])
	SetGlobalNetInt("FD_AICount_Current",total)
	SetGlobalNetInt("FD_AICount_Total",total)

}



bool function runWave(int waveIndex,bool shouldDoBuyTime)
{

	SetGlobalNetInt("FD_currentWave",waveIndex)
	file.havesterWasDamaged = false
	file.harvesterShieldDown = false
	SetEnemyAmountNetVars(waveIndex)
	for(int i = 0; i<20;i++)//Number of npc type ids
	{
		file.harvesterDamageSource.append(0.0)
	}
	foreach(entity player in GetPlayerArray())
	{
		file.players[player].diedThisRound = false
		file.players[player].scoreThisRound = 0
	}
	array<int> enemys = getHighestEnemyAmountsForWave(waveIndex)

	foreach(entity player in GetPlayerArray())
	{
		Remote_CallFunction_NonReplay(player,"ServerCallback_FD_AnnouncePreParty",enemys[0],enemys[1],enemys[2],enemys[3],enemys[4],enemys[5],enemys[6],enemys[7],enemys[8])
	}
	if(shouldDoBuyTime)
	{
		SetGlobalNetInt("FD_waveState",WAVE_STATE_BREAK)
		OpenBoostStores()
		foreach(entity player in GetPlayerArray())
			Remote_CallFunction_NonReplay(player,"ServerCallback_FD_NotifyStoreOpen")
		while(Time()<GetGlobalNetTime("FD_nextWaveStartTime"))
		{
			if(allPlayersReady())
				SetGlobalNetTime("FD_nextWaveStartTime",Time())
			WaitFrame()
		}

		CloseBoostStores()
		MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_StoreClosing)
	}
	
	//SetGlobalNetTime("FD_nextWaveStartTime",Time()+10)
	wait 10
	SetGlobalNetInt("FD_waveState",WAVE_STATE_INCOMING)
	foreach(entity player in GetPlayerArray())
	{
		Remote_CallFunction_NonReplay(player,"ServerCallback_FD_ClearPreParty")
		player.SetPlayerNetBool("FD_readyForNextWave",false)
	}
	SetGlobalNetBool("FD_waveActive",true)
	MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_AnnounceWaveStart)
	SetGlobalNetInt("FD_waveState",WAVE_STATE_BREAK)
	
	//main wave loop
	thread SetWaveStateReady()
	executeWave()
	SetGlobalNetInt("FD_waveState",WAVE_STATE_COMPLETE)
	if(!IsAlive(fd_harvester.harvester))
	{
		float totalDamage = 0.0
		array<float> highestDamage = [0.0,0.0,0.0]
		array<int> highestDamageSource = [-1,-1,-1]
		foreach(index,float damage in file.harvesterDamageSource)
		{
			totalDamage += damage
			if(highestDamage[0]<damage)
			{
				highestDamage[2] = highestDamage[1]
				highestDamageSource[2] = highestDamageSource[1]
				highestDamage[1] = highestDamage[0]
				highestDamageSource[1] = highestDamageSource[0]
				highestDamageSource[0] = index
				highestDamage[0] = damage
			}
			else if(highestDamage[1]<damage)
			{
				highestDamage[2] = highestDamage[1]
				highestDamageSource[2] = highestDamageSource[1]
				highestDamage[1] = damage
				highestDamageSource[1] = index
			}
			else if(highestDamage[2]<damage)
			{
				highestDamage[2] = damage
				highestDamageSource[2] = index
			}
		}

		foreach(entity player in GetPlayerArray())
		{
			Remote_CallFunction_NonReplay(player,"ServerCallback_FD_DisplayHarvesterKiller",GetGlobalNetInt("FD_restartsRemaining"),getHintForTypeId(highestDamageSource[0]),highestDamageSource[0],highestDamage[0]/totalDamage,highestDamageSource[1],highestDamage[1]/totalDamage,highestDamageSource[2],highestDamage[2]/totalDamage)
		}

		if(GetGlobalNetInt("FD_restartsRemaining")>0)
			FD_DecrementRestarts()
		else
			SetRoundBased(false)
		SetWinner(TEAM_IMC)//restart round
		spawnedNPCs = [] // reset npcs count
		restetWaveEvents()
		foreach(player in GetPlayerArray())
			PlayerEarnMeter_AddEarnedAndOwned(player,1.0,1.0)
		return false
	}


	wait 2
	//wave end

	SetGlobalNetBool("FD_waveActive",false)
	MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_AnnounceWaveEnd)

	if ( isFinalWave() && IsAlive( fd_harvester.harvester ) )
	{
		//Game won code
		MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_AnnounceWaveEnd)
		foreach(entity player in GetPlayerArray())
		{
			AddPlayerScore(player,"FDTeamWave")
		}
		wait 1
		int highestScore = 0;
		entity highestScore_player = GetPlayerArray()[0]
		foreach(entity player in GetPlayerArray())
		{
			
			if(!file.players[player].diedThisRound)
				AddPlayerScore(player,"FDDidntDie")
			if(highestScore<file.players[player].scoreThisRound)
			{
				highestScore = file.players[player].scoreThisRound
				highestScore_player = player
			}

		}
		file.players[highestScore_player].totalMVPs += 1
		AddPlayerScore(highestScore_player,"FDWaveMVP")
		wait 1
		foreach(entity player in GetPlayerArray())
			if(!file.havesterWasDamaged)
				AddPlayerScore(player,"FDTeamFlawlessWave")



		
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
		if (damagepercent < 5) // if less than 5% damage taken
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
	MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_NotifyWaveBonusIncoming)
	wait 2
	foreach(entity player in GetPlayerArray())
	{
		if (isSecondWave())
			PlayFactionDialogueToPlayer( "fd_wavePayoutFirst", player )
		else
			PlayFactionDialogueToPlayer( "fd_wavePayoutAddtnl", player )
		AddPlayerScore(player,"FDTeamWave")
		AddMoneyToPlayer(player,GetCurrentPlaylistVarInt("fd_money_per_round",600))
		// this function is called "Set" but in reality it is "Add"
		SetJoinInProgressBonus( GetCurrentPlaylistVarInt("fd_money_per_round",600) )
		EmitSoundOnEntityOnlyToPlayer(player,player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
	}
	wait 1
	int highestScore = 0;
	entity highestScore_player = GetPlayerArray()[0]
	foreach(entity player in GetPlayerArray())
	{
		if(!file.players[player].diedThisRound)
		{
			AddPlayerScore(player,"FDDidntDie")
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_DIDNT_DIE )
		}
		AddMoneyToPlayer(player,100)
		EmitSoundOnEntityOnlyToPlayer(player,player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
		if(highestScore<file.players[player].scoreThisRound)
		{
			highestScore = file.players[player].scoreThisRound
			highestScore_player = player
		}

	}
	wait 1
	file.players[highestScore_player].totalMVPs += 1
	AddPlayerScore(highestScore_player,"FDWaveMVP")
	AddMoneyToPlayer(highestScore_player,100)
	highestScore_player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_MVP )
	EmitSoundOnEntityOnlyToPlayer(highestScore_player,highestScore_player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
	foreach(entity player in GetPlayerArray())
	{
		Remote_CallFunction_NonReplay(player,"ServerCallback_FD_NotifyMVP",highestScore_player.GetEncodedEHandle())
	}
	wait 1
	foreach(entity player in GetPlayerArray())
	{

		if(!file.havesterWasDamaged)
		{
			AddPlayerScore(player,"FDTeamFlawlessWave")
			AddMoneyToPlayer(player,100)
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, FD_SCORE_TEAM_FLAWLESS_WAVE )
			EmitSoundOnEntityOnlyToPlayer(player,player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
		}
	}

	wait 1

	if(waveIndex<waveEvents.len())
		SetGlobalNetTime("FD_nextWaveStartTime",Time()+75)

	return true

}

void function SetWaveStateReady(){
	wait 5
	SetGlobalNetInt("FD_waveState",WAVE_STATE_IN_PROGRESS)
}

void function gameWonMedals(){
	table<string,entity> medals
	//most mvps
}


void function OnHarvesterDamaged(entity harvester, var damageInfo)
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

	damageAmount = (damageAmount * GetCurrentPlaylistVarFloat("fd_player_damage_scalar",1.0))



	float shieldPercent = ( (harvester.GetShieldHealth().tofloat() / harvester.GetShieldHealthMax()) * 100 )
	if ( shieldPercent < 100 && !file.harvesterShieldDown)
		PlayFactionDialogueToTeam( "fd_baseShieldTakingDmg", TEAM_MILITIA )

	if ( shieldPercent < 35 && !file.harvesterShieldDown) // idk i made this up
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

		if (healthpercent <= 75 && oldhealthpercent > 75) // we don't want the dialogue to keep saying "Harvester is below 75% health" everytime they take additional damage
			PlayFactionDialogueToTeam( "fd_baseHealth75", TEAM_MILITIA )

		if (healthpercent <= 50 && oldhealthpercent > 50)
			PlayFactionDialogueToTeam( "fd_baseHealth50", TEAM_MILITIA )

		if (healthpercent <= 25 && oldhealthpercent > 25)
			PlayFactionDialogueToTeam( "fd_baseHealth25", TEAM_MILITIA )

		if (healthpercent <= 10)
			PlayFactionDialogueToTeam( "fd_baseLowHealth", TEAM_MILITIA )

		if( newHealth <= 0 )
		{
			EmitSoundAtPosition(TEAM_UNASSIGNED,fd_harvester.harvester.GetOrigin(),"coop_generator_destroyed")
			newHealth = 0
			PlayFactionDialogueToTeam( "fd_baseDeath", TEAM_MILITIA )
			fd_harvester.rings.Anim_Stop()
		}
		harvester.SetHealth( newHealth )
		file.havesterWasDamaged = true
	}

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_titancore_laser_cannon )
    	DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo )/10 ) // laser core shreds super well for some reason

	if ( attacker.IsPlayer() )
		attacker.NotifyDidDamage( harvester, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
}

void function FD_NPCCleanup()
{
	foreach ( entity npc in GetEntArrayByClass_Expensive("C_AI_BaseNPC") )
		if ( IsValid( npc ) )
			npc.Destroy()
}

void function HarvesterThink()
{
	entity harvester = fd_harvester.harvester


	EmitSoundOnEntity( harvester,"coop_generator_startup" )

	float lastTime = Time()
	wait 4
	int lastShieldHealth = harvester.GetShieldHealth()
	generateBeamFX( fd_harvester )
	generateShieldFX( fd_harvester )

	EmitSoundOnEntity( harvester, "coop_generator_ambient_healthy" )

	bool isRegening = false // stops the regenning sound to keep stacking on top of each other

	while ( IsAlive( harvester ) )
	{
		float currentTime = Time()
		float deltaTime = currentTime -lastTime

		if ( IsValid( fd_harvester.particleShield ) )
		{
			vector shieldColor = GetShieldTriLerpColor(1.0-(harvester.GetShieldHealth().tofloat()/harvester.GetShieldHealthMax().tofloat()))
			EffectSetControlPointVector( fd_harvester.particleShield, 1, shieldColor )
		}

		if( IsValid( fd_harvester.particleBeam ) )
		{
			vector beamColor = GetShieldTriLerpColor( 1.0 - (harvester.GetHealth().tofloat() / harvester.GetMaxHealth().tofloat() ) )
			EffectSetControlPointVector( fd_harvester.particleBeam, 1, beamColor )
		}

		if ( fd_harvester.harvester.GetShieldHealth() == 0 )
			if( IsValid( fd_harvester.particleShield ) )
				fd_harvester.particleShield.Destroy()

		if ( ( ( currentTime-fd_harvester.lastDamage) >= GENERATOR_SHIELD_REGEN_DELAY ) && ( harvester.GetShieldHealth() < harvester.GetShieldHealthMax() ) )
		{
			if( !IsValid(fd_harvester.particleShield) )
				generateShieldFX(fd_harvester)

			//printt((currentTime-fd_harvester.lastDamage))

			if(harvester.GetShieldHealth()==0)
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_start")

			if (!isRegening)
			{
				EmitSoundOnEntity( harvester,"coop_generator_shieldrecharge_resume" )
				file.harvesterShieldDown = false
				if (GetGlobalNetBool("FD_waveActive"))
					PlayFactionDialogueToTeam( "fd_baseShieldRecharging", TEAM_MILITIA )
				else
					PlayFactionDialogueToTeam( "fd_baseShieldRechargingShort", TEAM_MILITIA )
						isRegening = true
			}

			float newShieldHealth = ( harvester.GetShieldHealthMax() / GENERATOR_SHIELD_REGEN_TIME * deltaTime ) + harvester.GetShieldHealth()

			if ( newShieldHealth >= harvester.GetShieldHealthMax() )
			{
				StopSoundOnEntity(harvester,"coop_generator_shieldrecharge_resume")
				harvester.SetShieldHealth(harvester.GetShieldHealthMax())
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_end")
				if (GetGlobalNetBool("FD_waveActive"))
					PlayFactionDialogueToTeam( "fd_baseShieldUp", TEAM_MILITIA )
				isRegening = false
			}
			else
			{
				harvester.SetShieldHealth(newShieldHealth)
			}
		} else if ( ( ( currentTime-fd_harvester.lastDamage) < GENERATOR_SHIELD_REGEN_DELAY ) && ( harvester.GetShieldHealth() < harvester.GetShieldHealthMax() ) )
			isRegening = false

		if ( ( lastShieldHealth > 0 ) && ( harvester.GetShieldHealth() == 0 ) )
			EmitSoundOnEntity(harvester,"coop_generator_shielddown")

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
	while(IsAlive(fd_harvester.harvester))
	{
		if(fd_harvester.harvester.GetShieldHealth()==0)
		{
			wait EmitSoundOnEntity(fd_harvester.harvester,"coop_generator_underattack_alarm")
		}
		else
		{
			WaitFrame()
		}
	}
}

void function initNetVars()
{
	SetGlobalNetInt("FD_totalWaves",waveEvents.len())
	SetGlobalNetInt("burn_turretLimit",2)
	if(!FD_HasRestarted())
	{
		bool showShop = false
		SetGlobalNetInt("FD_currentWave",0)
		if(FD_IsDifficultyLevelOrHigher(eFDDifficultyLevel.INSANE))
			FD_SetNumAllowedRestarts(0)
		else
			FD_SetNumAllowedRestarts(2)
	}
	

}

void function FD_DamageByPlayerCallback(entity victim,var damageInfo)
{
	entity player = DamageInfo_GetAttacker(damageInfo)
	if(!(player in file.players))
		return
	float damage = DamageInfo_GetDamage(damageInfo)
	file.players[player].damageDealt += damage
	file.players[player].scoreThisRound += damage.tointeger() //TODO NOT HOW SCORE WORKS
	if(victim.IsTitan())
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


	DamageInfo_SetDamage( damageInfo, (damageAmount * GetCurrentPlaylistVarFloat("fd_player_damage_scalar",1.0)) )
	


}



void function HealthScaleByDifficulty( entity ent )
{

	if ( ent.GetTeam() != TEAM_IMC )
		return


	if (ent.IsTitan()&& IsValid(GetPetTitanOwner( ent ) ) ) // in case we ever want pvp in FD
		return
	
	if ( ent.IsTitan() )
		ent.SetMaxHealth( ent.GetMaxHealth() + GetCurrentPlaylistVarInt("fd_titan_health_adjust",0) )
	else
		ent.SetMaxHealth( ent.GetMaxHealth() + GetCurrentPlaylistVarInt("fd_reaper_health_adjust",0) )
	
	if(GetCurrentPlaylistVarInt("fd_pro_titan_shields",0)&&ent.IsTitan()){
		entity soul = ent.GetTitanSoul()
		if(IsValid(soul)){
			soul.SetShieldHealthMax(2500)
			soul.SetShieldHealth(2500)
		}
	}


}

void function FD_createHarvester()
{

	fd_harvester = SpawnHarvester(file.harvester_info.GetOrigin(),file.harvester_info.GetAngles(),GetCurrentPlaylistVarInt("fd_harvester_health",25000),GetCurrentPlaylistVarInt("fd_harvester_shield",6000),TEAM_MILITIA)
	fd_harvester.harvester.Minimap_SetAlignUpright( true )
	fd_harvester.harvester.Minimap_AlwaysShow( TEAM_IMC, null )
	fd_harvester.harvester.Minimap_AlwaysShow( TEAM_MILITIA, null )
	fd_harvester.harvester.Minimap_SetHeightTracking( true )
	fd_harvester.harvester.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	fd_harvester.harvester.Minimap_SetCustomState( eMinimapObject_prop_script.FD_HARVESTER )
	AddEntityCallback_OnDamaged( fd_harvester.harvester, OnHarvesterDamaged )
}

bool function isFinalWave()
{
	return ((GetGlobalNetInt("FD_currentWave")+1)==GetGlobalNetInt("FD_totalWaves"))
}

bool function isSecondWave()
{
	return ((GetGlobalNetInt("FD_currentWave")+1)==1)
}

void function LoadEntities()
{
	CreateBoostStoreLocation(TEAM_MILITIA,shopPosition,shopAngles)
	foreach ( entity info_target in GetEntArrayByClass_Expensive("info_target") )
	{

		if ( GameModeRemove( info_target ) )
			continue

		if(info_target.HasKey("editorclass")){
			switch(info_target.kv.editorclass){
				case"info_fd_harvester":
					file.harvester_info = info_target
					break
				case"info_fd_mode_model":
					entity prop = CreatePropDynamic( info_target.GetModelName(), info_target.GetOrigin(), info_target.GetAngles(), 6 )
					break
				case"info_fd_ai_position":
					AddStationaryAIPosition(info_target.GetOrigin(),int(info_target.kv.aiType))
					break
				case"info_fd_route_node":
					routeNodes.append(info_target)
					break
				case"info_fd_smoke_screen":
					file.smokePoints.append(info_target)
					break
			}
		}
	}
	ValidateAndFinalizePendingStationaryPositions()
	initNetVars()
	SetTeam(GetTeamEnt(TEAM_IMC),TEAM_IMC)
}


bool function allPlayersReady()
{
	foreach(entity player in GetPlayerArray())
	{
		if(!player.GetPlayerNetBool("FD_readyForNextWave"))
			return false
	}
	return true
}

void function CheckLastPlayerReady()
{
	int readyplayers = 0
	entity notready
	foreach(entity player in GetPlayerArray())
	{
		if(player.GetPlayerNetBool("FD_readyForNextWave"))
			readyplayers++
		else
			notready = player // keep a track of this player
	}
	if (readyplayers == GetPlayerArray().len() - 1)
		PlayFactionDialogueToPlayer( "fd_playerNeedsToReadyUp", notready ) // ready up i swear there's one player like this in every match i've played
}

bool function ClientCommandCallbackToggleReady( entity player, array<string> args )
{
	if(args[0]=="true")
		player.SetPlayerNetBool("FD_readyForNextWave",true)
	if(args[0]=="false")
		player.SetPlayerNetBool("FD_readyForNextWave",false)

	CheckLastPlayerReady()
	return true
}

int function getHintForTypeId(int typeId)
{
	//this is maybe a bit of an naive aproch
	switch(typeId)
		{
			case eFD_AITypeIDs.TITAN_NUKE:
				return (348 +RandomIntRangeInclusive(0,1))
			case eFD_AITypeIDs.TITAN_ARC:
				return (350 +RandomIntRangeInclusive(0,1))
			case eFD_AITypeIDs.TITAN_MORTAR:
				return (352 +RandomIntRangeInclusive(0,1))
			case eFD_AITypeIDs.GRUNT:
				return 354
			case eFD_AITypeIDs.SPECTRE:
				return 355
			case eFD_AITypeIDs.SPECTRE_MORTAR:
				return (356 +RandomIntRangeInclusive(0,1))
			case eFD_AITypeIDs.STALKER:
				if(RandomIntRangeInclusive(0,1)==0)
					return 358
				else
					return 361
			case eFD_AITypeIDs.REAPER:
				return (359 +RandomIntRangeInclusive(0,1))
			case eFD_AITypeIDs.DRONE:
				return 362
			case eFD_AITypeIDs.TITAN_SNIPER:
				return (371 +RandomIntRangeInclusive(0,2))
			default:
				return (363+RandomIntRangeInclusive(0,7))
		}
	unreachable
}

string function GetTargetNameForID(int typeId)
{
	switch(typeId)
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

string function GetAiNetIdFromTargetName(string targetName)
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
		case "Cloaked Drone":
			return "FD_AICount_Drone_Cloak"
		case "tick":
			return "FD_AICount_Ticks"
	}
	printt("unknown target name ",targetName)
	return ""
}



void function AddTurretSentry(entity turret)
{
	turret.Minimap_AlwaysShow( TEAM_IMC, null )
	turret.Minimap_AlwaysShow( TEAM_MILITIA, null )
	turret.Minimap_SetHeightTracking( true )
	turret.Minimap_SetCustomState( eMinimapObject_npc.FD_TURRET )
}

void function DisableTitanSelection( )
{
	foreach ( entity player in GetPlayerArray() )
	{
		DisableTitanSelectionForPlayer( player )
	}
}

void function EnableTitanSelection( )
{
	foreach ( entity player in GetPlayerArray() )
	{
		EnableTitanSelectionForPlayer( player )
	}
}

void function EnableTitanSelectionForPlayer( entity player )
{
	int enumCount =	PersistenceGetEnumCount( "titanClasses" )
	for ( int i = 0; i < enumCount; i++ )
	{
		string enumName = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		if ( enumName != "" )
			player.SetPersistentVar( "titanClassLockState[" + enumName + "]", TITAN_CLASS_LOCK_STATE_AVAILABLE )

	}
}

void function DisableTitanSelectionForPlayer( entity player )
{
	int enumCount =	PersistenceGetEnumCount( "titanClasses" )
	for ( int i = 0; i < enumCount; i++ )
	{
		string enumName = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		string selectedEnumName = PersistenceGetEnumItemNameForIndex( "titanClasses", player.GetPersistentVarAsInt("activeTitanLoadoutIndex") )
		if ( enumName != "" && enumName != selectedEnumName )
			player.SetPersistentVar( "titanClassLockState[" + enumName + "]", TITAN_CLASS_LOCK_STATE_LOCKED )
	}
}
