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

global struct SmokeEvent{
	vector position
	float lifetime
}

global struct SpawnEvent{
	vector origin
	vector angles
	string route
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
	SmokeEvent smokeEvent
	SpawnEvent spawnEvent
	WaitEvent waitEvent
	SoundEvent soundEvent
}



global HarvesterStruct fd_harvester
global vector shopPosition
global array<array<WaveEvent> > waveEvents
global table<string,array<vector> > routes


struct player_struct_fd{
	bool diedThisRound
	int scoreThisRound

}


struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<entity> routeNodes
	table<string,float> harvesterDamageSource
	bool havesterWasDamaged
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
	SetRoundBased(true)
	SetShouldUseRoundWinningKillReplay(false)


	AddCallback_EntitiesDidLoad(LoadEntities)
	AddDamageCallback("prop_script",OnDamagedPropScript)
	AddCallback_GameStateEnter(eGameState.Prematch,FD_createHarvester)
	AddCallback_GameStateEnter( eGameState.Playing,startMainGameLoop)
	AddCallback_OnClientConnected(GamemodeFD_InitPlayer)
	AddCallback_OnPlayerKilled(GamemodeFD_OnPlayerKilled)


	AddDeathCallback("npc_titan",OnNpcDeath)
	AddDeathCallback("npc_stalker",OnNpcDeath)
	AddDeathCallback("npc_spectre",OnNpcDeath)
	AddDeathCallback("npc_super_spectre",OnNpcDeath)
	AddDeathCallback("npc_soldier",OnNpcDeath)
	AddDeathCallback("npc_frag_drone",OnNpcDeath)
	AddDeathCallback("npc_drone",OnNpcDeath)

	AddClientCommandCallback("FD_ToggleReady",ClientCommandCallbackToggleReady)
	AddClientCommandCallback("FD_UseHarvesterShieldBoost",useShieldBoost)
}

void function GamemodeFD_OnPlayerKilled(entity victim, entity attacker, var damageInfo)
{
	file.players[victim].diedThisRound = true
}

void function GamemodeFD_InitPlayer(entity player)
{
	player_struct_fd data
	data.diedThisRound = false
	data.scoreThisRound = 0
	file.players[player] <- data
}



void function OnNpcDeath( entity ent, var damageInfo )
{
	int findIndex = file.spawnedNPCs.find( ent )
	if ( findIndex != -1 )
	{
		file.spawnedNPCs.remove( findIndex )
	}
	printt("callback")
}

void function RateSpawnpoints_FD(int _0, array<entity> _1, int _2, entity _3){}

bool function useShieldBoost(entity player,array<string> args)
{
	if((GetGlobalNetTime("FD_harvesterInvulTime")<Time())&&(player.GetPlayerNetInt("numHarvesterShieldBoost")>0))
	{	
		fd_harvester.harvester.SetShieldHealth(fd_harvester.harvester.GetShieldHealthMax())
		SetGlobalNetTime("FD_harvesterInvulTime",Time()+5)
		MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_PlayerHealedHarvester)
		player.SetPlayerNetInt( "numHarvesterShieldBoost", player.GetPlayerNetInt( "numHarvesterShieldBoost" ) - 1 )
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
		showShop = true
	}
	if(IsAlive(fd_harvester.harvester))
	{
		//Game won code
		SetWinner(TEAM_MILITIA)
		return
	}
	//restart round
	SetWinner(TEAM_IMC)
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

array<int> function getEnemyTypesForWave(int wave)
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
	

	foreach(WaveEvent e in waveEvents[wave])
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
			case(eFD_AITypeIDs.TITAN_SNIPER):
				npcs[eFD_AITypeIDs.TITAN]+=e.spawnEvent.spawnAmount
				break
			default:
				npcs[e.spawnEvent.spawnType]+=e.spawnEvent.spawnAmount
		}
	}
	array<int> ret = [-1,-1,-1,-1,-1,-1,-1,-1,-1]
	foreach(int key,int value in npcs){
		printt("Key",key,"has value",value)
		SetGlobalNetInt(FD_GetAINetIndex_byAITypeID(key),value)
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

bool function runWave(int waveIndex,bool shouldDoBuyTime)
{	




	SetGlobalNetInt("FD_currentWave",waveIndex)
	file.havesterWasDamaged = false
	foreach(player_struct_fd player in file.players)
	{
		player.diedThisRound = false
		player.scoreThisRound = 0
	}	
	array<int> enemys = getEnemyTypesForWave(waveIndex)
	foreach(entity player in GetPlayerArray())
	{
		Remote_CallFunction_NonReplay(player,"ServerCallback_FD_AnnouncePreParty",enemys[0],enemys[1],enemys[2],enemys[3],enemys[4],enemys[5],enemys[6],enemys[7],enemys[8])
	}
	if(shouldDoBuyTime)
	{
		
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

	foreach(entity player in GetPlayerArray())
	{
		Remote_CallFunction_NonReplay(player,"ServerCallback_FD_ClearPreParty")
		player.SetPlayerNetBool("FD_readyForNextWave",false)
	}
	SetGlobalNetBool("FD_waveActive",true)
	MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_AnnounceWaveStart)


	//main wave loop
	
	foreach(WaveEvent event in waveEvents[waveIndex])
	{
		event.eventFunction(event.smokeEvent,event.spawnEvent,event.waitEvent,event.soundEvent)
		if(!IsAlive(fd_harvester.harvester))
			return false
		waitUntilLessThanAmountAlive(0)
	}
	
	
	


	wait 2
	//wave end
	SetGlobalNetBool("FD_waveActive",false)
	MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_AnnounceWaveEnd)
	if(waveIndex<waveEvents.len())
		SetGlobalNetTime("FD_nextWaveStartTime",Time()+75)
	
	//Player scoring
	MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_NotifyWaveBonusIncoming)
	wait 2
	foreach(entity player in GetPlayerArray())
	{
		AddPlayerScore(player,"FDTeamWave")
		AddMoneyToPlayer(player,GetCurrentPlaylistVarInt("fd_money_per_round",600))
		EmitSoundOnEntityOnlyToPlayer(player,player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
	}
	wait 1
	int highestScore = 0;
	entity highestScore_player = GetPlayerArray()[0]
	foreach(entity player in GetPlayerArray())
	{	
		player_struct_fd data = file.players[player]
		if(!data.diedThisRound)
			AddPlayerScore(player,"FDDidntDie")
			AddMoneyToPlayer(player,100)
			EmitSoundOnEntityOnlyToPlayer(player,player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
		if(highestScore<data.scoreThisRound)
		{
			highestScore = data.scoreThisRound
			highestScore_player = player
		}
		
	}
	wait 1
	AddPlayerScore(highestScore_player,"FDWaveMVP")
	AddMoneyToPlayer(highestScore_player,100)
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
			EmitSoundOnEntityOnlyToPlayer(player,player,"HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P")
		}
	}
	wait 10
	return true
	
}

void function OnDamagedPropScript(entity prop,var damageInfo)
{	
	
	if(!IsValid(fd_harvester.harvester))
		return
	
	if(!IsValid(prop))
		return
	
	if(fd_harvester.harvester!=prop)
		return
	
	if(GetGlobalNetTime("FD_harvesterInvulTime")>Time())
	{
		prop.SetShieldHealth(prop.GetShieldHealthMax())
		return
	}

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )
	
	if ( !damageSourceID )
		return

	if ( !damageAmount )
		return

	if ( !attacker )
		return
	//TODO Log damage source for round lose screen
	
	fd_harvester.lastDamage = Time()
	if(prop.GetShieldHealth()==0)
	{
		
		float newHealth = prop.GetHealth()-damageAmount
		if(newHealth<0)
		{	
			EmitSoundAtPosition(TEAM_UNASSIGNED,fd_harvester.harvester.GetOrigin(),"coop_generator_destroyed")
			newHealth=0
			fd_harvester.rings.Destroy()
		}
		
		prop.SetHealth(newHealth)
		file.havesterWasDamaged = true
	}

	
	
}

void function FD_NPCCleanup()
{
	foreach(entity npc in file.spawnedNPCs){
		if(IsValid(npc))
			npc.Destroy()
	}
}

void function HarvesterThink()
{	
	entity harvester = fd_harvester.harvester

	
	EmitSoundOnEntity(harvester,"coop_generator_startup")
	float lastTime = Time()
	wait 4
	int lastShieldHealth = harvester.GetShieldHealth()
	generateBeamFX(fd_harvester)
	generateShieldFX(fd_harvester)
	
	EmitSoundOnEntity(harvester,"coop_generator_ambient_healthy")
	
	


	while(IsAlive(harvester)){
		float currentTime = Time()
		float deltaTime = currentTime -lastTime
		if(IsValid(fd_harvester.particleShield))
		{
			vector shieldColor = GetShieldTriLerpColor(1.0-(harvester.GetShieldHealth().tofloat()/harvester.GetShieldHealthMax().tofloat()))
			EffectSetControlPointVector( fd_harvester.particleShield, 1, shieldColor )
		}
		if(IsValid(fd_harvester.particleBeam))
		{
			vector beamColor = GetShieldTriLerpColor(1.0-(harvester.GetHealth().tofloat()/harvester.GetMaxHealth().tofloat()))
			EffectSetControlPointVector( fd_harvester.particleBeam, 1, beamColor )
		}
		if(fd_harvester.harvester.GetShieldHealth()==0)
			if(IsValid(fd_harvester.particleShield))
				fd_harvester.particleShield.Destroy()
		if(((currentTime-fd_harvester.lastDamage)>=GENERATOR_SHIELD_REGEN_DELAY)&&(harvester.GetShieldHealth()<harvester.GetShieldHealthMax()))
		{	
			if(!IsValid(fd_harvester.particleShield))
				generateShieldFX(fd_harvester)
			//printt((currentTime-fd_harvester.lastDamage))
			if(harvester.GetShieldHealth()==0)
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_start")
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_resume")
			float newShieldHealth = (harvester.GetShieldHealthMax()/GENERATOR_SHIELD_REGEN_TIME*deltaTime)+harvester.GetShieldHealth()
			if(newShieldHealth>=harvester.GetShieldHealthMax())
			{
				StopSoundOnEntity(harvester,"coop_generator_shieldrecharge_resume")
				harvester.SetShieldHealth(harvester.GetShieldHealthMax())
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_end")
				
			}
			else
			{
				harvester.SetShieldHealth(newShieldHealth)
			}
		}
		if((lastShieldHealth>0)&&(harvester.GetShieldHealth()==0))
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
		if(GetCurrentPlaylistVarInt("fd_difficulty",0)>=5)
			FD_SetNumAllowedRestarts(0)
		else	
			FD_SetNumAllowedRestarts(2)
	}
	
}

void function FD_createHarvester()
{
	HarvesterStruct ret = SpawnHarvester(file.harvester_info.GetOrigin(),file.harvester_info.GetAngles(),1,1,TEAM_IMC)//,25000,6000,TEAM_MILITIA)
	fd_harvester.harvester = ret.harvester
	fd_harvester.rings = ret.rings
	fd_harvester.lastDamage = ret.lastDamage
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
	ValidateAndFinalizePendingStationaryPositions()
	initNetVars()
}

void function titanNav_thread(entity titan, string routeName)
{	
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )


	printt("Start NAV")
	if((!titan.IsTitan())||(!titan.IsNPC()))
		return
	
	
	array<entity> routeArray = getRoute(routeName)
	WaitFrame()//so other code setting up what happens on signals is run before this
	if(routeArray.len()==0)
	{	
		
		titan.Signal("OnFailedToPath")
		return
	}

	foreach(entity node in routeArray)
	{	
		
		if(Distance(fd_harvester.harvester.GetOrigin(),titan.GetOrigin())<Distance(fd_harvester.harvester.GetOrigin(),node.GetOrigin()))
			continue
		titan.AssaultPoint(node.GetOrigin())
		int i = 0
		while((Distance(titan.GetOrigin(),node.GetOrigin())>5000))
		{
			WaitFrame()
			printt(Distance(titan.GetOrigin(),node.GetOrigin()))
			// i++
			// if(i>1200)
			// {
			// 	titan.Signal("OnFailedToPath")
			// 	return
			// }
		}
	}
	titan.Signal("FD_ReachedHarvester")
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

bool function ClientCommandCallbackToggleReady( entity player, array<string> args )
{
	if(args[0]=="true")
		player.SetPlayerNetBool("FD_readyForNextWave",true)
	if(args[0]=="flase")
		player.SetPlayerNetBool("FD_readyForNextWave",false)
	return true
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
	event.smokeEvent.position = position
	event.smokeEvent.lifetime = lifetime
	return event
}

WaveEvent function createArcTitanEvent(vector origin,vector angles,string route)
{
	WaveEvent event
	event.eventFunction = spawnArcTitan
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
	event.spawnEvent.spawnType= eFD_AITypeIDs.SPECTRE_MORTAR
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.route = route
	return event
}

WaveEvent function createWaitForTimeEvent(float amount)
{
	WaveEvent event
	event.eventFunction = waitForTime
	event.waitEvent.amount = amount
	return event
}

WaveEvent function createWaitUntilAliveEvent(int amount)
{
	WaveEvent event
	event.eventFunction = waitUntilLessThanAmountAliveEvent
	event.waitEvent.amount = amount.tofloat()
	return event
}

WaveEvent function createGenericSpawnEvent(string npcClassName,vector origin,vector angles,string route,int spawnType,int spawnAmount)
{
	WaveEvent event
	event.eventFunction = spawnGenericNPC
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
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_MORTAR
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function createCloakDroneEvent(vector origin,vector angles){
		WaveEvent event
	event.eventFunction = fd_spawnCloakDrone
	event.spawnEvent.spawnType= eFD_AITypeIDs.DRONE_CLOAK
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
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
	thread titanNav_thread(npc,spawnEvent.route)
	SetSpawnOption_Titanfall(npc)
	npc.DisableNPCFlag(NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER|NPC_ALLOW_PATROL)
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)	
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
	SetSpawnOption_Titanfall(npc)
	DispatchSpawn(npc)
}

void function spawnDroppodGrunts(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	thread CreateTrackedDroppodSoldier(spawnEvent.origin,TEAM_IMC)
}

void function spawnDroppodStalker(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{	
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	thread CreateTrackedDroppodStalker(spawnEvent.origin,TEAM_IMC)
}

void function spawnDroppodSpectreMortar(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{	
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	thread CreateTrackedDroppodSpectreMortar(spawnEvent.origin,TEAM_IMC)
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
	SetSpawnOption_AISettings( npc, spawnEvent.aiSettings)
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
}

void function spawnNukeTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_ogre",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_ogre_minigun_nuke")
	thread titanNav_thread(npc,spawnEvent.route)
	SetSpawnOption_Titanfall(npc)
	npc.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS)
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
	thread NukeTitanThink(npc,fd_harvester.harvester)
	
}

void function spawnMortarTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_atlas",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_atlas_tracker_mortar")
	SetSpawnOption_Titanfall(npc)
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
	thread MortarTitanThink(npc,fd_harvester.harvester)
	
}

void function spawnSniperTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateNPCTitan("titan_stryder",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_atlas_tracker_mortar")
	SetSpawnOption_Titanfall(npc)
	DispatchSpawn(npc)
	file.spawnedNPCs.append(npc)
	thread MortarTitanThink(npc,fd_harvester.harvester)
	
}
void function fd_spawnCloakDrone(SmokeEvent smokeEffect,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = SpawnCloakDrone( TEAM_IMC, spawnEvent.origin, spawnEvent.angles, file.harvester_info.GetOrigin() )
	file.spawnedNPCs.append(npc)
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


void function CreateTrackedDroppodSoldier( vector origin, int team)
{
    
    
    entity pod = CreateDropPod( origin, <0,0,0> )
    SetTeam( pod, team )
    InitFireteamDropPod( pod )
    waitthread LaunchAnimDropPod( pod, "pod_testpath", origin, <0,0,0> )
    
    string squadName = MakeSquadName( team, UniqueString( "ZiplineTable" ) )
    array<entity> guys
    
    for ( int i = 0; i < 4; i++ ) 
    {
        entity guy = CreateSoldier( team, origin,<0,0,0> )
        
        SetTeam( guy, team )
        guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
        DispatchSpawn( guy )
        
        SetSquad( guy, squadName )
        guys.append( guy )
    }
    
    ActivateFireteamDropPod( pod, guys )
}

void function CreateTrackedDroppodSpectreMortar( vector origin, int team)
{
    
    
    entity pod = CreateDropPod( origin, <0,0,0> )
    SetTeam( pod, team )
    InitFireteamDropPod( pod )
    waitthread LaunchAnimDropPod( pod, "pod_testpath", origin, <0,0,0> )
    
    string squadName = MakeSquadName( team, UniqueString( "ZiplineTable" ) )
    array<entity> guys
    
    for ( int i = 0; i < 4; i++ ) 
    {
        entity guy = CreateSpectre( team, origin,<0,0,0> )
        
        SetTeam( guy, team )
        guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
        DispatchSpawn( guy )
        
        SetSquad( guy, squadName )
        guys.append( guy )
    }
    
    ActivateFireteamDropPod( pod, guys )
}
void function CreateTrackedDroppodStalker( vector origin, int team)
{
    
    
    entity pod = CreateDropPod( origin, <0,0,0> )
    SetTeam( pod, team )
    InitFireteamDropPod( pod )
    waitthread LaunchAnimDropPod( pod, "pod_testpath", origin, <0,0,0> )
    
    string squadName = MakeSquadName( team, UniqueString( "ZiplineTable" ) )
    array<entity> guys
    
    for ( int i = 0; i < 4; i++ ) 
    {
        entity guy = CreateStalker( team, origin,<0,0,0> )
        
        SetTeam( guy, team )
        guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
        DispatchSpawn( guy )
        
        SetSquad( guy, squadName )
        guys.append( guy )
    }
    
    ActivateFireteamDropPod( pod, guys )
}

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
		printt("Titans alive",aliveTitans,amount)
		WaitFrame()
		aliveTitans = file.spawnedNPCs.len()
		if(!IsAlive(fd_harvester.harvester))
			break
		
	}
	printt("Titans alive end",aliveTitans,amount)
}