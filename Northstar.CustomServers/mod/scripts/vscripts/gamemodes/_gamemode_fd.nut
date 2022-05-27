global function GamemodeFD_Init
global function RateSpawnpoints_FD
global function startHarvester
global function createSmokeEvent
global function createArcTitanEvent
global function createWaitForTimeEvent
global function createSuperSpectreEvent
global function createDroppodGruntEvent
global function createNukeTitanEvent
global function createMortarTitanEvent
global function createGenericSpawnEvent
global function createGenericTitanSpawnWithAiSettingsEvent
global function createDroppodStalkerEvent
global function createDroppodSpectreMortarEvent
global function createWaitUntilAliveEvent
global function createCloakDroneEvent
global function CreateTickEvent
global function CreateToneSniperTitanEvent
global function CreateNorthstarSniperTitanEvent
global function CreateScorchTitanEvent
global function CreateToneTitanEvent
global function CreateIonTitanEvent
global function CreateLegionTitanEvent
global function CreateRoninTitanEvent
global function CreateMonarchTitanEvent

global struct SmokeEvent{
	vector position
	float lifetime
}

global struct SpawnEvent{
	vector origin
	vector angles
	string route			//defines route taken by the ai
	int skippedRouteNodes 	//defines how many route nodes will be skipped
	int spawnType			//Just used for Wave Info but can be used for spawn too should contain aid of spawned enemys
	int spawnAmount			//Just used for Wave Info but can be used for spawn too should contain amound of spawned enemys
	string npcClassName
	string aiSettings
}

global struct WaitEvent{
	float amount
}

global struct SoundEvent{
	string soundEventName
}

global struct WaveEvent{
	void functionref(SmokeEvent,SpawnEvent,WaitEvent,SoundEvent) eventFunction
	bool shouldThread
	SmokeEvent smokeEvent
	SpawnEvent spawnEvent
	WaitEvent waitEvent
	SoundEvent soundEvent
}

struct player_struct_fd{
	bool diedThisRound
	float scoreThisRound
	int totalMVPs
	int mortarUnitsKilled //not implemented yet
	int moneySpend
	int coresUsed
	float longestTitanLife //not implemented yet
	int turretsRepaired //not implemented yet
	int moneyShared
	float timeNearHarvester //dont know how to track
	float longestLife //not implemented yet
	int heals //dont know what to track
	int titanKills //not implemented yet
	float damageDealt
	int harvesterHeals
}

global HarvesterStruct& fd_harvester
global vector shopPosition
global array<array<WaveEvent> > waveEvents
global table<string,array<vector> > routes





struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<entity> routeNodes
	array<float> harvesterDamageSource
	bool havesterWasDamaged
	bool harvesterShieldDown
	float harvesterDamageTaken
	array<entity> spawnedNPCs
	table<entity,player_struct_fd> players
	entity harvester_info
}file

void function GamemodeFD_Init()
{
	PrecacheModel( MODEL_ATTRITION_BANK )
	PrecacheParticleSystem($"P_smokescreen_FD")

	RegisterSignal("FD_ReachedHarvester")
	RegisterSignal("OnFailedToPath")
	RegisterSignal("StartCounter") // for use in common AI, will cause OnFailedToPath after an amount of time
	RegisterSignal("SniperSwitchedEnemy") // for use in Sniper Titans behavior, could be useful for other titans as well

	SetRoundBased(true)
	SetShouldUseRoundWinningKillReplay(false)
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	PlayerEarnMeter_SetEnabled(false)
	SetShouldUsePickLoadoutScreen( true )


	AddCallback_EntitiesDidLoad(LoadEntities)
	AddCallback_GameStateEnter(eGameState.Prematch,FD_createHarvester)
	AddCallback_GameStateEnter( eGameState.Playing,startMainGameLoop)
	AddCallback_OnClientConnected(GamemodeFD_InitPlayer)
	AddCallback_OnPlayerKilled(GamemodeFD_OnPlayerKilled)
	AddCallback_OnRoundEndCleanup(FD_NPCCleanup)
	AddDamageByCallback("player",FD_DamageByPlayerCallback)

	AddDamageCallback( "player", DamageScaleByDifficulty )
	AddDamageCallback( "npc_titan", DamageScaleByDifficulty )
	AddDamageCallback( "npc_turret_sentry", DamageScaleByDifficulty )
	AddSpawnCallback( "npc_titan", HealthScaleByDifficulty )
	AddSpawnCallback( "npc_super_spectre", HealthScaleByDifficulty )


	AddCallback_OnNPCKilled(OnNpcDeath)
	AddSpawnCallback("npc_turret_sentry", AddTurretSentry )
	SetUsedCoreCallback(FD_UsedCoreCallback)

	AddClientCommandCallback("FD_ToggleReady",ClientCommandCallbackToggleReady)
	AddClientCommandCallback("FD_UseHarvesterShieldBoost",useShieldBoost)

	//shop Callback
	SetBoostPurchaseCallback(FD_BoostPurchaseCallback)
	SetTeamReserveInteractCallback(FD_TeamReserveDepositOrWithdrawCallback)
}

void function FD_BoostPurchaseCallback(entity player,BoostStoreData data)
{
	file.players[player].moneySpend += data.cost
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


}

void function OnNpcDeath( entity victim, entity attacker, var damageInfo )
{
	int findIndex = file.spawnedNPCs.find( victim )
	if ( findIndex != -1 )
	{
		file.spawnedNPCs.remove( findIndex )
		switch(FD_GetAITypeID_ByString(victim.GetTargetName())) //FD_GetAINetIndex_byAITypeID does not support all titan ids
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
				SetGlobalNetInt("FD_AICount_Titan", GetGlobalNetInt("FD_AICount_Titan")-1)
				break
			default:
				string netIndex = FD_GetAINetIndex_byAITypeID(FD_GetAITypeID_ByString(victim.GetTargetName()))
				if(netIndex != "")
					SetGlobalNetInt(netIndex,GetGlobalNetInt(netIndex)-1)
				else
				{
					if (victim.GetTargetName() == "Cloak Drone") // special case for cloak drone, someone in respawn fucked up here
						SetGlobalNetInt( "FD_AICount_Drone_Cloak", GetGlobalNetInt("FD_AICount_Drone_Cloak")-1)
				}
		}
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
		}

	}


}

array<entity> function getRoute(string routeName)
{
	array<entity> ret
	array<entity> currentNode = []
	foreach(entity node in file.routeNodes)
	{
		if(!node.HasKey("route_name"))
			continue
		if(node.kv.route_name==routeName)
		{
			currentNode =  [node]
			break
		}

	}
	if(currentNode.len()==0)
	{
		printt("Route not found")
		return []
	}
	while(currentNode.len()!=0)
	{
		ret.append(currentNode[0])
		currentNode = currentNode[0].GetLinkEntArray()
	}
	return ret
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
	foreach(WaveEvent event in waveEvents[waveIndex])
	{

		if(event.shouldThread)
			thread event.eventFunction(event.smokeEvent,event.spawnEvent,event.waitEvent,event.soundEvent)
		else
			event.eventFunction(event.smokeEvent,event.spawnEvent,event.waitEvent,event.soundEvent)
		if(!IsAlive(fd_harvester.harvester))
			break

	}
	waitUntilLessThanAmountAlive_expensive(0)
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
		file.spawnedNPCs = [] // reset npcs count
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
		float highestScore = 0;
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
		EmitSoundOnEntityOnlyToPlayer(player,player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
	}
	wait 1
	float highestScore = 0;
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

	int difficultyLevel = FD_GetDifficultyLevel()
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL: // easy and normal have no damage scaling
			break

		case eFDDifficultyLevel.HARD:
		{
			DamageInfo_SetDamage( damageInfo, (damageAmount * 1.5) )
			damageAmount = (damageAmount * 1.5) // for use in health calculations below
			break
		}

		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:
		{
			DamageInfo_SetDamage( damageInfo, (damageAmount * 2.5) )
			damageAmount = (damageAmount * 2.5) // for use in health calculations below
			break
		}

		default:
			unreachable

	}


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
	file.players[player].scoreThisRound += damage //TODO NOT HOW SCORE WORKS
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

	int difficultyLevel = FD_GetDifficultyLevel()
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL: // easy and normal have no damage scaling
			break

		case eFDDifficultyLevel.HARD:
			DamageInfo_SetDamage( damageInfo, (damageAmount * 1.5) )
			break

		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:
			DamageInfo_SetDamage( damageInfo, (damageAmount * 2.5) )
			break

		default:
			unreachable

	}

}



void function HealthScaleByDifficulty( entity ent )
{

	if ( ent.GetTeam() != TEAM_IMC )
		return

	if ( ent.IsTitan() )
		if ( IsValid(GetPetTitanOwner( ent ) ) ) // in case we ever want pvp in FD
			return

	int difficultyLevel = FD_GetDifficultyLevel()
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
			if ( ent.IsTitan() )
				ent.SetMaxHealth( ent.GetMaxHealth() - 5000 )
			else
				ent.SetMaxHealth( ent.GetMaxHealth() - 2000 )
			break
		case eFDDifficultyLevel.NORMAL:
			if ( ent.IsTitan() )
				ent.SetMaxHealth( ent.GetMaxHealth() - 2500 )
			else
				ent.SetMaxHealth( ent.GetMaxHealth() - 1000 )
			break

		case eFDDifficultyLevel.HARD: // no changes in Hard Mode
			break

		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:
			if ( ent.IsTitan() )
			{
				entity soul = ent.GetTitanSoul()
				if (IsValid(soul))
				{
					soul.SetShieldHealthMax( 2500 ) // apparently they have 0, costs me some time debugging this ffs
					soul.SetShieldHealth( 2500 )
				}
			}
			break

		default:
			unreachable

	}

}


void function FD_createHarvester()
{
	int shieldamount = 6000
	int difficultyLevel = FD_GetDifficultyLevel()
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL: // easy and normal have no shield changes
			break

		case eFDDifficultyLevel.HARD:
			shieldamount = 5000
			break

		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:
			shieldamount = 4000
			break

		default:
			unreachable

	}

	fd_harvester = SpawnHarvester(file.harvester_info.GetOrigin(),file.harvester_info.GetAngles(),25000,shieldamount,TEAM_MILITIA)
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

	CreateBoostStoreLocation(TEAM_MILITIA,shopPosition,<0,0,0>)
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
					file.routeNodes.append(info_target)
					break
				case"info_fd_smoke_screen":
					file.smokePoints.append(info_target)
					break
			}
		}
	}
	AddStationaryAIPosition(< -12, 1720, 1456 >,4)
	ValidateAndFinalizePendingStationaryPositions()
	initNetVars()
}

//┌──────────────┐
//│              │◄──────────┐
//│  AI Pathing  │           │
//│              │    ┌──────┴───────┐   Basic outline of AI goal:
//└──────┬───────┘    │     Wait:    │   1. AI pathing
//       │            │ If no enemy, │      - feed nodes in current path one by one
//       │            │    resume.   │      - stop running if under attack and presuambly return flags like NPC_ALLOW_FLEE
//       │            └──────────────┘
//       │                   ▲           2. Attacked
//       │                   │              - Signal OnFailedToPath
//       │            ┌──────┴───────┐      - cause fallback function to run and not use route nodes anymore
//       │            │ Attacked:    │   3. Wait
//       ├───────────►│ Stop pathing │      - Let a few amount of seconds pass
//       │            │              │      - Check if enemy is still within dist or is still taking continuous damage
//       ▼            └──────────────┘      - If both checks is false, return the AI to pathing thread
//┌──────────────┐
//│              │
//│  Destination │
//│              │
//└──────────────┘

void function CommonAIThink (entity npc, string routeName)
{
	npc.EndSignal( "OnDeath" ) // if dead
	npc.EndSignal( "OnDestroy" ) // if dead
	npc.EndSignal( "OnSyncedMeleeVictim" ) // if getting executed
	npc.EndSignal( "OnFailedToPath" ) // if cant find path or get attacked (not yet implemented)

	waitthread singleNav_thread( npc, routeName )
	// OnFailedToPath would end this function, so assume they reached harvester

	waitthread CheckForInterruption( npc )
	// TODO: continue while(true) checks to see if they get attacked while attacking the harvester
}

void function OnFailedToPathFallback( entity npc )
{
	// ideally this function should run when they get attacked or after 10 seconds of not pathing to the correct spot
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnSyncedMeleeVictim" )
	npc.EndSignal( "FD_ReachedHarvester" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")
	// ^^^ stop keeping track of this function if they die or reached their goal
	// EndSignal( npc, "OnFailedToPath" ) // credit to @Spoon for telling me this
	print("running failed to path fallback")
	if (!IsAlive(npc))
		return

	waitthread CheckForInterruption( npc ) // first let's make sure they're not being attacked
	print("not being attacked lets keep going")
	// Nuke Titans have their own NukeTitanThink, need to update their pathing as well but for later
	if ( npc.GetTargetName() == "npc_titan_nuke" )
		return

	float checkRadiusSqr = 400 * 400
	float goalRadius = npc.GetMinGoalRadius()

	// we cant use previous route path since they might go back in reverse, so might as well try to figure out if they can go to the harvester manually
	array<vector> pos
	if (npc.IsTitan())
		pos = NavMesh_GetNeighborPositions( fd_harvester.harvester.GetOrigin(), HULL_TITAN, 20 )
	else
		pos = NavMesh_GetNeighborPositions( fd_harvester.harvester.GetOrigin(), HULL_HUMAN, 20 )
	pos = ArrayClosestVector( pos, npc.GetOrigin() )

	array<vector> validPos
	foreach ( point in pos )
	{
		if ( DistanceSqr( fd_harvester.harvester.GetOrigin(), point ) <= checkRadiusSqr && NavMesh_IsPosReachableForAI( npc, point ) )
		{
			validPos.append( point )
			//DebugDrawSphere( point, 32, 255, 0, 0, true, 60 )
		}
	}

	int posLen = validPos.len()

	npc.Signal("StartCounter")
	thread TimeCounter( npc ) // start counting in case of failing to path
	while( posLen >= 1 )
	{
		WaitFrame()
		npc.SetEnemy( fd_harvester.harvester )
		npc.AssaultSetFightRadius( goalRadius )
		thread AssaultOrigin( npc, validPos[0], goalRadius )

		wait 0.5

		if ( DistanceSqr( npc.GetOrigin(), fd_harvester.harvester.GetOrigin() ) > checkRadiusSqr )
			continue

		break
	}
	npc.Signal( "FD_ReachedHarvester" )
	print("titan reached harvester")
}

void function singleNav_thread(entity npc, string routeName,int nodesToScip= 0,float nextDistance = 500.0)
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnSyncedMeleeVictim" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")

	print( "start going through this route" )
	if(!npc.IsNPC())
		return

	bool canwalk = npc.GetNPCMoveFlag( NPCMF_WALK_ALWAYS )
	npc.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS )
	npc.AssaultSetFightRadius( 0 ) // makes them keep moving instead of stopping to shoot you.

	OnThreadEnd(
		function() : ( npc, canwalk )
		{
			if ( !IsValid( npc ) )
				return

			npc.SetNPCMoveFlag( NPCMF_WALK_ALWAYS, canwalk )
		}
	)

	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
	{
		npc.Signal("OnFailedToPath")
		thread OnFailedToPathFallback(npc)
		print("no path in this route")
		return
	}
	int scippedNodes = 0
	foreach(entity node in routeArray)
	{
		if(!IsAlive(fd_harvester.harvester))
			return
		if(scippedNodes < nodesToScip)
		{
			scippedNodes++
			continue
		}
		if( Distance( node.GetOrigin(), fd_harvester.harvester.GetOrigin()) > Distance( npc.GetOrigin(), fd_harvester.harvester.GetOrigin() ))
		{
			print("node seems to go in reverse, ignoring...")
			continue
		}
		npc.Signal("StartCounter") // end any or previous counter
		thread TimeCounter( npc ) // start counting from 0 again
		npc.AssaultPoint(node.GetOrigin())
		npc.AssaultSetGoalRadius( npc.GetMinGoalRadius() )
		table result = npc.WaitSignal("OnFinishedAssault","OnFailedToPath", "OnEnterGoalRadius")
		string signal = expect string( result.signal )
		if (signal == "OnFailedToPath")
		{
			thread OnFailedToPathFallback( npc )
			print("they triggered on failed to path on their own?")
			return
		}
		print("moving to next node")
		// if finished assault they move to next node, if failed to path, this function ends itself and they use fallback function
	}
	print("titan reached harvester")
	npc.Signal("FD_ReachedHarvester")
}

void function TimeCounter( entity npc, int time = 30 )
{
	Assert(IsNewThread(), "Function is not threaded off.")
	npc.Signal("StartCounter") // make sure there's only 1 counter for this entity
	npc.EndSignal("StartCounter") // can be used to make sure only 1 counter or to end the counter
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnSyncedMeleeVictim" )
	npc.EndSignal( "FD_ReachedHarvester" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")
	int count = 0
	while (true)
	{
		if (count >= time)
		{
			print("countdown reached. assume failed to path")
			npc.Signal("OnFailedToPath")
			thread OnFailedToPathFallback( npc ) // enough time elapsed and this function hasn't stopped, assume failed to path
			return
		}

		wait 1
		count++
	}
}

void function CheckForInterruption( entity npc )
{
	// goal: check if there's enemy in the vincinity
	// if not, check if took more than 10% damage towards current health
	Assert( IsNewThread(), "Must be threaded off" )

	npc.EndSignal( "OnSyncedMeleeVictim" )
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")

	entity soul
	if (npc.IsTitan())
	{
		soul = npc.GetTitanSoul()
		soul.EndSignal( "OnDestroy" )
	}

	float playerProximityDistSqr = pow( 256, 2 )
	float healthBreakOff
	if (npc.IsTitan())
		healthBreakOff = ( npc.GetHealth() + soul.GetShieldHealth() ) * 0.9
	else
		healthBreakOff = ( npc.GetHealth() * 0.9 )

	while( true )
	{
		if ( !IsEnemyWithinDist( npc, playerProximityDistSqr ) ) // if there's no enemy within proximity
		{
			if ( IsValid(soul) && ( npc.GetHealth() + soul.GetShieldHealth() ) > healthBreakOff ) // if we never loss more than 90% of our current health
			{
				break // continue pathing in fallback function or just attack harvester
			}
			else if ( npc.GetHealth() > healthBreakOff )
				break
		}
		if (npc.IsTitan())
			healthBreakOff = ( npc.GetHealth() + soul.GetShieldHealth() ) * 0.9
		else
			healthBreakOff = ( npc.GetHealth() * 0.9 )

		print("enemy nearby, waiting")
		wait 3
	}
}

bool function IsEnemyWithinDist( entity titan, float dist )
{
	vector origin = titan.GetOrigin()
	array<entity> players = GetPlayerArrayOfEnemies_Alive( titan.GetTeam() )

	foreach( player in players )
	{
		if ( DistanceSqr( player.GetOrigin(), origin ) < dist )
			return true
	}

	return false
}

void function SquadNav_Thread( array<entity> npcs ,string routeName,int nodesToScip = 0,float nextDistance = 200.0)
{
	//TODO this function wont stop when noone alive anymore also it only works half of the time

	foreach( npc in npcs )
		thread SquadNav_SingleThread(npc, routeName, nodesToScip, nextDistance)
}

void function SquadNav_SingleThread( entity npc, string routeName, int nodesToScip = 0, float nextDistance = 200.0)
{
	fd_harvester.harvester.EndSignal("OnDeath")
	fd_harvester.harvester.EndSignal("OnDestroy")
	npc.EndSignal("OnDeath")
	npc.EndSignal("OnDestroy")

	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
		return

	int nodeIndex = 0
	if (IsStalker(npc))
		routeArray.append( fd_harvester.harvester ) // really dumb fix so that they would run closer to the harvester lmao
	foreach(entity node in routeArray)
	{
		if(!IsAlive(fd_harvester.harvester))
			return
		if(nodeIndex++ < nodesToScip)
			continue

		thread AssaultOrigin(npc,node.GetOrigin(),nextDistance) // this will run thread AssaultOrigin, which waitthread SendAIToAssaultPoint for each separate npc, and if an npc dies, the next iteration in this foreach loop will continue
	}
	npc.Signal("FD_ReachedHarvester")
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

/****************************************************************************************************************\
####### #     # ####### #     # #######     #####  ####### #     # ####### ######     #    ####### ####### ######
#       #     # #       ##    #    #       #     # #       ##    # #       #     #   # #      #    #     # #     #
#       #     # #       # #   #    #       #       #       # #   # #       #     #  #   #     #    #     # #     #
#####   #     # #####   #  #  #    #       #  #### #####   #  #  # #####   ######  #     #    #    #     # ######
#        #   #  #       #   # #    #       #     # #       #   # # #       #   #   #######    #    #     # #   #
#         # #   #       #    ##    #       #     # #       #    ## #       #    #  #     #    #    #     # #    #
#######    #    ####### #     #    #        #####  ####### #     # ####### #     # #     #    #    ####### #     #
\*****************************************************************************************************************/

WaveEvent function createSmokeEvent(vector position,float lifetime)
{
	WaveEvent event
	event.eventFunction = spawnSmoke
	event.shouldThread = true
	event.smokeEvent.position = position
	event.smokeEvent.lifetime = lifetime
	return event
}

WaveEvent function createArcTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = spawnArcTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_ARC
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function createSuperSpectreEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = spawnSuperSpectre
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.REAPER
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function createDroppodGruntEvent(vector origin,string route)
{
	WaveEvent event
	event.eventFunction = spawnDroppodGrunts
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.GRUNT
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.route = route
	return event
}

WaveEvent function createDroppodStalkerEvent(vector origin,string route)
{
	WaveEvent event
	event.eventFunction = spawnDroppodStalker
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.STALKER
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.route = route
	return event
}

WaveEvent function createDroppodSpectreMortarEvent(vector origin,string route)
{
	WaveEvent event
	event.eventFunction = spawnDroppodSpectreMortar
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.SPECTRE_MORTAR
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.route = route
	return event
}

WaveEvent function createWaitForTimeEvent(float amount)
{
	WaveEvent event
	event.shouldThread = false
	event.eventFunction = waitForTime
	event.waitEvent.amount = amount
	return event
}

WaveEvent function createWaitUntilAliveEvent(int amount)
{
	WaveEvent event
	event.eventFunction = waitUntilLessThanAmountAliveEvent
	event.shouldThread = false
	event.waitEvent.amount = amount.tofloat()
	return event
}

WaveEvent function createGenericSpawnEvent(string npcClassName,vector origin,vector angles,string route,int spawnType,int spawnAmount)
{
	WaveEvent event
	event.eventFunction = spawnGenericNPC
	event.shouldThread = true
	event.spawnEvent.npcClassName = npcClassName
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.spawnType = spawnType
	event.spawnEvent.spawnAmount = spawnAmount
	return event
}

WaveEvent function createGenericTitanSpawnWithAiSettingsEvent(string npcClassName,string aiSettings,vector origin,vector angles,string route,int spawnType,int spawnAmount)
{
	WaveEvent event
	event.eventFunction = spawnGenericNPCTitanwithSettings
	event.shouldThread = true
	event.spawnEvent.npcClassName = npcClassName
	event.spawnEvent.aiSettings = aiSettings
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.spawnType = spawnType
	event.spawnEvent.spawnAmount = spawnAmount
	return event
}

WaveEvent function createNukeTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = spawnNukeTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_NUKE
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function createMortarTitanEvent(vector origin,vector angles)
{
	WaveEvent event
	event.eventFunction = spawnMortarTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_MORTAR
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function createCloakDroneEvent(vector origin,vector angles){
	WaveEvent event
	event.eventFunction = fd_spawnCloakDrone
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.DRONE_CLOAK
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function CreateTickEvent( vector origin, vector angles, int amount = 4, string route = "" )
{
	WaveEvent event
	event.eventFunction = SpawnTick
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TICK
	event.spawnEvent.spawnAmount = amount
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function CreateNorthstarSniperTitanEvent(vector origin,vector angles)
{
	WaveEvent event
	event.eventFunction = spawnSniperTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_SNIPER
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function CreateToneSniperTitanEvent(vector origin,vector angles)
{
	WaveEvent event
	event.eventFunction = SpawnToneSniperTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_SNIPER
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function CreateScorchTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = SpawnScorchTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.SCORCH
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function CreateToneTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = SpawnToneTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TONE
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function CreateIonTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = SpawnIonTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.ION
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function CreateLegionTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = SpawnLegionTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.LEGION
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function CreateRoninTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = SpawnRoninTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.RONIN
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function CreateMonarchTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = SpawnMonarchTitan
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.MONARCH
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

/************************************************************************************************************\
####### #     # ####### #     # #######    ####### #     # #     #  #####  ####### ### ####### #     #  #####
#       #     # #       ##    #    #       #       #     # ##    # #     #    #     #  #     # ##    # #     #
#       #     # #       # #   #    #       #       #     # # #   # #          #     #  #     # # #   # #
#####   #     # #####   #  #  #    #       #####   #     # #  #  # #          #     #  #     # #  #  #  #####
#        #   #  #       #   # #    #       #       #     # #   # # #          #     #  #     # #   # #       #
#         # #   #       #    ##    #       #       #     # #    ## #     #    #     #  #     # #    ## #     #
#######    #    ####### #     #    #       #        #####  #     #  #####     #    ### ####### #     #  #####
\************************************************************************************************************/

void function spawnSmoke(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	printt("smoke")
	SmokescreenStruct smokescreen
	smokescreen.smokescreenFX = $"P_smokescreen_FD"
	smokescreen.isElectric = false
	smokescreen.origin = smokeEvent.position + < 0 , 0, 150>
	smokescreen.angles = <0,0,0>
	smokescreen.lifetime = smokeEvent.lifetime
	smokescreen.fxXYRadius = 150
	smokescreen.fxZRadius = 120
	smokescreen.fxOffsets = [ <120.0, 0.0, 0.0>,<0.0, 120.0, 0.0>, <0.0, 0.0, 0.0>,<0.0, -120.0, 0.0>,< -120.0, 0.0, 0.0>, <0.0, 100.0, 0.0>]
	Smokescreen(smokescreen)

}

void function spawnArcTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateArcTitan(TEAM_IMC,spawnEvent.origin,spawnEvent.angles)
	npc.DisableNPCFlag(NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER|NPC_ALLOW_PATROL)
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	SetSpawnOption_AISettings(npc,"npc_titan_stryder_leadwall_arc")
	file.spawnedNPCs.append(npc)
	DispatchSpawn(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc,spawnEvent.route)
	thread EMPTitanThinkConstant(npc)
}

void function waitForTime(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	float waitUntil = Time() + waitEvent.amount
	while(Time()<waitUntil)
	{
		if(!IsAlive(fd_harvester.harvester))
			break
		WaitFrame()
	}
}

void function waitUntilLessThanAmountAliveEvent(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	waitUntilLessThanAmountAlive(int(waitEvent.amount))
}

void function spawnSuperSpectre(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)

	entity npc = CreateSuperSpectre(TEAM_IMC,spawnEvent.origin,spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_super_spectre_fd")
	file.spawnedNPCs.append(npc)

	wait 4.7
	DispatchSpawn(npc)
	thread SuperSpectre_WarpFall(npc)
	// thread ReaperMinionLauncherThink(npc)

	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType))
	npc.WaitSignal("WarpfallComplete")
	AddMinimapForHumans(npc)
	array<entity> guys
	guys.append(npc)
	thread SquadNav_Thread(guys,spawnEvent.route)

}

void function spawnDroppodGrunts(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity pod = CreateDropPod( spawnEvent.origin, <0,0,0> )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, <0,0,0> )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys
	bool adychecked = false
	int difficultyLevel = FD_GetDifficultyLevel()
	bool shieldcaptain = false

    for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
    {
		entity guy = CreateSoldier( TEAM_IMC, spawnEvent.origin,<0,0,0> )

		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL)
		if (!shieldcaptain)
			if (difficultyLevel == eFDDifficultyLevel.MASTER || difficultyLevel == eFDDifficultyLevel.INSANE )
			{
				SetSpawnOption_AISettings( guy, "npc_soldier_shield_captain" )
				shieldcaptain = true
			}
		DispatchSpawn( guy )

		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		guy.AssaultSetFightRadius( 0 ) // makes them keep moving instead of stopping to shoot you.

		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.GRUNT))
		AddMinimapForHumans(guy)
		file.spawnedNPCs.append(guy)
		guys.append( guy )
	}
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL:
			break
		case eFDDifficultyLevel.HARD: // give 2 guys charge rifle on hard
		{
			for( int i = 0; i < 2; i++ )
			{
				guys[i].TakeActiveWeapon()
				guys[i].GiveWeapon( "mp_weapon_defender", [] )
				guys[i].SetActiveWeaponByName( "mp_weapon_defender" )
			}
			break
		}
		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE: // give all charge rifle on master
		{
			foreach(npc in guys)
			{
				npc.TakeActiveWeapon()
				npc.GiveWeapon( "mp_weapon_defender", [] )
				npc.SetActiveWeaponByName( "mp_weapon_defender" )
			}
			break
		}

		default:
			unreachable

	}

	ActivateFireteamDropPod( pod, guys )
	SquadNav_Thread(guys,spawnEvent.route)
}

void function spawnDroppodStalker(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity pod = CreateDropPod( spawnEvent.origin, <0,0,0> )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, <0,0,0> )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys
	int difficultyLevel = FD_GetDifficultyLevel()

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
	{
		entity guy = CreateStalker( TEAM_IMC, spawnEvent.origin,<0,0,0> )

		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL)
		SetSpawnOption_AISettings( guy, "npc_stalker_fd" )
		DispatchSpawn( guy )

		SetSquad( guy, squadName )
		guy.AssaultSetFightRadius( 0 ) // makes them keep moving instead of stopping to shoot you.
		AddMinimapForHumans(guy)
		file.spawnedNPCs.append(guy)
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.STALKER))
		thread FDStalkerThink( guy , fd_harvester.harvester )
		guys.append( guy )
    }

	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL: // easy and normal stalkers have no weapons
			foreach(npc in guys)
			{
				npc.TakeActiveWeapon()
				npc.SetNoTarget( false )
				npc.EnableNPCFlag( NPC_DISABLE_SENSING | NPC_IGNORE_ALL )
				npc.SetEnemy( fd_harvester.harvester )
			}
			break
		case eFDDifficultyLevel.HARD:
		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE: // give all EPGs
			foreach(npc in guys)
			{
				npc.TakeActiveWeapon()
				npc.GiveWeapon( "mp_weapon_epg", [] )
				npc.SetActiveWeaponByName( "mp_weapon_epg" )
			}
			break

		default:
			unreachable

	}

    ActivateFireteamDropPod( pod, guys )
	SquadNav_Thread(guys,spawnEvent.route)

}

void function spawnDroppodSpectreMortar(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
		entity pod = CreateDropPod( spawnEvent.origin, <0,0,0> )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, <0,0,0> )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys

	for ( int i = 0; i < 4; i++ )
	{
		entity guy = CreateSpectre( TEAM_IMC, spawnEvent.origin,<0,0,0> )

		SetTeam( guy, TEAM_IMC )
		DispatchSpawn( guy )

		SetSquad( guy, squadName )
		guy.AssaultSetFightRadius( 0 ) // makes them keep moving instead of stopping to shoot you.
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.SPECTRE_MORTAR))
		AddMinimapForHumans(guy)
		guys.append( guy )
    }

    ActivateFireteamDropPod( pod, guys )
}

void function spawnGenericNPC(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPC( spawnEvent.npcClassName, TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	DispatchSpawn(npc)
}

void function spawnGenericNPCTitanwithSettings(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan( spawnEvent.npcClassName, TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	if( spawnEvent.aiSettings == "npc_titan_atlas_tracker_fd_sniper" )
		SetTargetName( npc, "npc_titan_atlas_tracker" ) // required for client to create icons
	SetSpawnOption_AISettings( npc, spawnEvent.aiSettings)
	SetSpawnOption_Titanfall(npc)
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
}

void function spawnNukeTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_ogre",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_ogre_minigun_nuke")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	npc.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS)
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc,spawnEvent.route)
	thread NukeTitanThink(npc,fd_harvester.harvester)

}

void function spawnMortarTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{

	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_atlas",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_atlas_tracker_mortar")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread MortarTitanThink(npc,fd_harvester.harvester)
}

void function spawnSniperTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_stryder",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_stryder_sniper_fd")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE ) // dont want to try to let them move around their assault point
	thread SniperTitanThink(npc,fd_harvester.harvester)

}

void function SpawnToneSniperTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_atlas",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_atlas_tracker_fd_sniper")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn( npc )
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE ) // dont want to try to let them move around their assault point
	thread SniperTitanThink(npc,fd_harvester.harvester)

}

void function SpawnScorchTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_ogre",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_ogre_meteor_boss_fd")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn( npc )
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc, spawnEvent.route)
}

void function SpawnToneTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_atlas",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_atlas_tracker_boss_fd")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn( npc )
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc, spawnEvent.route)
}

void function SpawnIonTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_atlas",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_atlas_stickybomb_boss_fd")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn( npc )
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc, spawnEvent.route)
}

void function SpawnLegionTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_ogre",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_ogre_minigun_boss_fd")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn( npc )
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc, spawnEvent.route)
}

void function SpawnRoninTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_stryder",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_stryder_leadwall_boss_fd")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn( npc )
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc, spawnEvent.route)
}

void function SpawnMonarchTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_atlas",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_atlas_vanguard_boss_fd")
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	DispatchSpawn( npc )
	file.spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread CommonAIThink(npc, spawnEvent.route)
}

void function fd_spawnCloakDrone(SmokeEvent smokeEffect,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = SpawnCloakDrone( TEAM_IMC, spawnEvent.origin, spawnEvent.angles, file.harvester_info.GetOrigin() )
	file.spawnedNPCs.append(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType))
	AddMinimapForHumans(npc)
}

void function SpawnTick(SmokeEvent smokeEffect,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity pod = CreateDropPod( spawnEvent.origin, <0,0,0> )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, <0,0,0> )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
	{
		entity guy = CreateFragDrone( TEAM_IMC, spawnEvent.origin, <0,0,0> )

		SetSpawnOption_AISettings(guy, "npc_frag_drone_fd")
		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE )
		DispatchSpawn( guy )
		AddMinimapForHumans(guy)
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.TICK))
		SetSquad( guy, squadName )

		guys.append( guy )
	}

	ActivateFireteamDropPod( pod, guys )
	SquadNav_Thread(guys,spawnEvent.route)
}

/****************************************************************************************\
####### #     # ####### #     # #######    #     # ####### #       ######  ####### ######
#       #     # #       ##    #    #       #     # #       #       #     # #       #     #
#       #     # #       # #   #    #       #     # #       #       #     # #       #     #
#####   #     # #####   #  #  #    #       ####### #####   #       ######  #####   ######
#        #   #  #       #   # #    #       #     # #       #       #       #       #   #
#         # #   #       #    ##    #       #     # #       #       #       #       #    #
#######    #    ####### #     #    #       #     # ####### ####### #       ####### #     #
\****************************************************************************************/


void function PingMinimap(float x, float y, float duration, float spreadRadius, float ringRadius, int colorIndex)
{
	foreach(entity player in GetPlayerArray())
	{
		Remote_CallFunction_NonReplay(player, "ServerCallback_FD_PingMinimap", x, y, duration, spreadRadius, ringRadius, colorIndex)
	}
}

void function waitUntilLessThanAmountAlive(int amount)
{

	int aliveTitans = file.spawnedNPCs.len()
	while(aliveTitans>amount)
	{
		WaitFrame()
		aliveTitans = file.spawnedNPCs.len()
		if(!IsAlive(fd_harvester.harvester))
			break
	}
}

void function waitUntilLessThanAmountAlive_expensive(int amount)
{

	array<entity> npcs = GetNPCArray()
	int deduct = 0
	foreach (entity npc in npcs)
		if (IsValid(GetPetTitanOwner( npc )))
			deduct++
	int aliveTitans = npcs.len() - deduct
	while(aliveTitans>amount)
	{
		WaitFrame()
		npcs = GetNPCArray()
		deduct = 0
		foreach(entity npc in npcs)
			if (IsValid(GetPetTitanOwner( npc )))
				deduct++
		aliveTitans = GetNPCArray().len() - deduct
		if(!IsAlive(fd_harvester.harvester))
			break
	}
}

void function AddMinimapForTitans(entity titan)
{
	titan.Minimap_SetAlignUpright( true )
	titan.Minimap_AlwaysShow( TEAM_IMC, null )
	titan.Minimap_AlwaysShow( TEAM_MILITIA, null )
	titan.Minimap_SetHeightTracking( true )
	titan.Minimap_SetCustomState( eMinimapObject_npc_titan.AT_BOUNTY_BOSS )
}

// including drones
void function AddMinimapForHumans(entity human)
{
	human.Minimap_SetAlignUpright( true )
	human.Minimap_AlwaysShow( TEAM_IMC, null )
	human.Minimap_AlwaysShow( TEAM_MILITIA, null )
	human.Minimap_SetHeightTracking( true )
	human.Minimap_SetCustomState( eMinimapObject_npc.AI_TDM_AI )
}

void function AddTurretSentry(entity turret)
{
	turret.Minimap_AlwaysShow( TEAM_IMC, null )
	turret.Minimap_AlwaysShow( TEAM_MILITIA, null )
	turret.Minimap_SetHeightTracking( true )
	turret.Minimap_SetCustomState( eMinimapObject_npc.FD_TURRET )
}