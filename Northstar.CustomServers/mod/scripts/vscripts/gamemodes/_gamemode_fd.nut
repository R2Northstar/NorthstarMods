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



global HarvesterStruct& fd_harvester
global vector shopPosition
global array<array<WaveEvent> > waveEvents
global table<string,array<vector> > routes


struct player_struct_fd{
	bool diedThisRound
	float scoreThisRound
	int totalMVPs
	int mortarUnitsKilled
	int moneySpend
	int coresUsed
	float longestTitanLife
	int turretsRepaired
	int moneyShared
	float timeNearHarvester
	float longestLife
	int heals
	int titanKills
	float damageDealt
	int harvesterHeals
}


struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<entity> routeNodes
	array<float> harvesterDamageSource
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


	AddCallback_OnNPCKilled(OnNpcDeath)
	SetUsedCoreCallback(FD_UsedCoreCallback)

	AddClientCommandCallback("FD_ToggleReady",ClientCommandCallbackToggleReady)
	AddClientCommandCallback("FD_UseHarvesterShieldBoost",useShieldBoost)



}


void function GamemodeFD_OnPlayerKilled(entity victim, entity attacker, var damageInfo)
{
	file.players[victim].diedThisRound = true
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
	data.scoreThisRound = 0
	file.players[player] <- data


}

void function OnNpcDeath( entity victim, entity attacker, var damageInfo )
{
	int findIndex = file.spawnedNPCs.find( victim )
	if ( findIndex != -1 )
	{
		file.spawnedNPCs.remove( findIndex )
	}

	if ( victim.GetOwner() == attacker && !attacker.IsPlayer() && attacker == victim )
		return

	int playerScore = 0
	int money = 0
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
			case "npc_spectre": // not sure
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
	}
	if (money != 0)
	{
		AddMoneyToPlayer( attacker , money )
		print("give that fat stash babeeeee")
	}

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
		MessageToTeam(TEAM_MILITIA,eEventNotifications.FD_PlayerHealedHarvester)
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
			case(eFD_AITypeIDs.LEGION):
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
	for(int i = 0; i<20;i++)//Number of npc type ids
	{
		file.harvesterDamageSource.append(0.0)
	}
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
		if(event.shouldThread)
			thread event.eventFunction(event.smokeEvent,event.spawnEvent,event.waitEvent,event.soundEvent)
		else
			event.eventFunction(event.smokeEvent,event.spawnEvent,event.waitEvent,event.soundEvent)
		if(!IsAlive(fd_harvester.harvester))
			break

	}
	waitUntilLessThanAmountAlive_expensive(0)
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
		return false
	}


	wait 2
	//wave end

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
			player_struct_fd data = file.players[player]
			if(!data.diedThisRound)
				AddPlayerScore(player,"FDDidntDie")
			if(highestScore<data.scoreThisRound)
			{
				highestScore = data.scoreThisRound
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
		return true
	}

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
	float highestScore = 0;
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
	wait 10
	return true

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

	if ( harvester.GetShieldHealth() == 0 )
	{
		float newHealth = harvester.GetHealth() - damageAmount
		if( newHealth <= 0 )
		{
			EmitSoundAtPosition(TEAM_UNASSIGNED,fd_harvester.harvester.GetOrigin(),"coop_generator_destroyed")
			newHealth = 0
			fd_harvester.rings.Destroy()
		}
		harvester.SetHealth( newHealth )
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
                isRegening = true
            }

			float newShieldHealth = ( harvester.GetShieldHealthMax() / GENERATOR_SHIELD_REGEN_TIME * deltaTime ) + harvester.GetShieldHealth()

			if ( newShieldHealth >= harvester.GetShieldHealthMax() )
			{
				StopSoundOnEntity(harvester,"coop_generator_shieldrecharge_resume")
				harvester.SetShieldHealth(harvester.GetShieldHealthMax())
				EmitSoundOnEntity(harvester,"coop_generator_shieldrecharge_end")
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

}

void function FD_createHarvester()
{
	fd_harvester = SpawnHarvester(file.harvester_info.GetOrigin(),file.harvester_info.GetAngles(),25000,6000,TEAM_MILITIA)
	AddEntityCallback_OnDamaged( fd_harvester.harvester, OnHarvesterDamaged )
}

bool function isFinalWave()
{
	return ((GetGlobalNetInt("FD_currentWave")+1)==GetGlobalNetInt("FD_totalWaves"))
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

void function titanNav_thread(entity titan, string routeName,float nextDistance = 500.0)
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )


	printt("Start NAV")
	if(!titan.IsNPC())
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
		if(!IsAlive(fd_harvester.harvester))
			return
		if(Distance(fd_harvester.harvester.GetOrigin(),titan.GetOrigin())<Distance(fd_harvester.harvester.GetOrigin(),node.GetOrigin()))
			continue
		titan.AssaultPoint(node.GetOrigin())
		titan.AssaultSetGoalRadius( 100 )
		int i = 0
		while((Distance(titan.GetOrigin(),node.GetOrigin())>nextDistance))
		{
			WaitFrame()
			// printt(Distance(titan.GetOrigin(),node.GetOrigin()))
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

void function HumanNav_Thread( entity npc )
{
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	entity generator = fd_harvester.harvester
	float goalRadius = 100
	float checkRadiusSqr = 400 * 400

	array<vector> pos = NavMesh_GetNeighborPositions( generator.GetOrigin(), HULL_HUMAN, 5 )
	pos = ArrayClosestVector( pos, npc.GetOrigin() )

	array<vector> validPos
	foreach ( point in pos )
	{
		if ( DistanceSqr( generator.GetOrigin(), point ) <= checkRadiusSqr && NavMesh_IsPosReachableForAI( npc, point ) )
		{
			validPos.append( point )
		}
	}

	int posLen = validPos.len()
	while( posLen >= 1 )
	{
		npc.SetEnemy( generator )
		thread AssaultOrigin( npc, validPos[0], goalRadius )
		npc.AssaultSetFightRadius( goalRadius )

		wait 0.5

		if ( DistanceSqr( npc.GetOrigin(), generator.GetOrigin() ) > checkRadiusSqr )
			continue

		break
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

bool function ClientCommandCallbackToggleReady( entity player, array<string> args )
{
	if(args[0]=="true")
		player.SetPlayerNetBool("FD_readyForNextWave",true)
	if(args[0]=="false")
		player.SetPlayerNetBool("FD_readyForNextWave",false)
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
				return "npc_titan_arc"
			case eFD_AITypeIDs.RONIN:
				return "npc_titan_stryder_leadwall"
			case eFD_AITypeIDs.TITAN_MORTAR:
				return "npc_titanmortar"
			case eFD_AITypeIDs.TONE:
				return "npc_titan_atlas_tracker"
			case eFD_AITypeIDs.TITAN_SNIPER:
			case eFD_AITypeIDs.NORTHSTAR:
				return "npc_titan_stryder_sniper"
			case eFD_AITypeIDs.ION:
				return "npc_titan_atlas_stickybomb"
			case eFD_AITypeIDs.SCORCH:
				return "npc_titan_ogre_meteor"
			case eFD_AITypeIDs.MONARCH:
				return "npc_titan_atlas_vanguard"
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
	npc.Minimap_AlwaysShow( TEAM_IMC, null )
	npc.Minimap_AlwaysShow( TEAM_MILITIA, null )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread titanNav_thread(npc,spawnEvent.route)
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
	thread ReaperMinionLauncherThink(npc)
}

void function spawnDroppodGrunts(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	thread CreateTrackedDroppodSoldier(spawnEvent.origin,TEAM_IMC, spawnEvent.route)
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
	if( spawnEvent.aiSettings == "npc_titan_atlas_tracker_fd_sniper" )
		SetTargetName( npc, "npc_titan_atlas_tracker" ) // required for client to create icons
	SetSpawnOption_AISettings( npc, spawnEvent.aiSettings)
	SetSpawnOption_Titanfall(npc)
	DispatchSpawn(npc)
	npc.Minimap_AlwaysShow( TEAM_IMC, null )
	npc.Minimap_AlwaysShow( TEAM_MILITIA, null )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	file.spawnedNPCs.append(npc)
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
	npc.Minimap_AlwaysShow( TEAM_IMC, null )
	npc.Minimap_AlwaysShow( TEAM_MILITIA, null )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread titanNav_thread(npc,spawnEvent.route)
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
	npc.Minimap_AlwaysShow( TEAM_IMC, null )
	npc.Minimap_AlwaysShow( TEAM_MILITIA, null )
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
	npc.Minimap_AlwaysShow( TEAM_IMC, null )
	npc.Minimap_AlwaysShow( TEAM_MILITIA, null )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
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
	npc.Minimap_AlwaysShow( TEAM_IMC, null )
	npc.Minimap_AlwaysShow( TEAM_MILITIA, null )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread SniperTitanThink(npc,fd_harvester.harvester)

}

void function fd_spawnCloakDrone(SmokeEvent smokeEffect,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = SpawnCloakDrone( TEAM_IMC, spawnEvent.origin, spawnEvent.angles, file.harvester_info.GetOrigin() )
	file.spawnedNPCs.append(npc)
}

void function SpawnTick(SmokeEvent smokeEffect,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	for (int i = 0; i < floor(spawnEvent.spawnAmount / 4); i++)
	{
		thread CreateTrackedDroppodTick(spawnEvent.origin, TEAM_IMC, spawnEvent.route)
		wait 0.5
	}
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
void function spawnSuperSpectre_threaded(entity npc)
{

	
}

void function CreateTrackedDroppodSoldier( vector origin, int team, string route = "")
{


    entity pod = CreateDropPod( origin, <0,0,0> )
    SetTeam( pod, team )
    InitFireteamDropPod( pod )
    waitthread LaunchAnimDropPod( pod, "pod_testpath", origin, <0,0,0> )

    string squadName = MakeSquadName( team, UniqueString( "ZiplineTable" ) )
    array<entity> guys
    bool adychecked = false

    for ( int i = 0; i < 4; i++ )
    {
        entity guy = CreateSoldier( team, origin,<0,0,0> )

        SetTeam( guy, team )
        guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS)
        DispatchSpawn( guy )

	guy.SetParent( pod, "ATTACH", true )
	SetSquad( guy, squadName )

	thread HumanNav_Thread(guy)

	guy.Minimap_AlwaysShow( TEAM_IMC, null )
	guy.Minimap_AlwaysShow( TEAM_MILITIA, null )
	file.spawnedNPCs.append(guy)
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

void function CreateTrackedDroppodTick( vector origin, int team, string route = "" )
{
	entity pod = CreateDropPod( origin, <0,0,0> )
	SetTeam( pod, team )
	InitFireteamDropPod( pod )
	waitthread LaunchAnimDropPod( pod, "pod_testpath", origin, <0,0,0> )

	string squadName = MakeSquadName( team, UniqueString( "ZiplineTable" ) )
	array<entity> guys

	for ( int i = 0; i < 4; i++ )
	{
		entity guy = CreateFragDrone( team, origin, <0,0,0> )

		SetSpawnOption_AISettings(guy, "npc_frag_drone_fd")
		SetTeam( guy, team )
		guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
		guy.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS | NPCMF_PREFER_SPRINT)
		DispatchSpawn( guy )
		guy.Minimap_AlwaysShow( TEAM_IMC, null )
		guy.Minimap_AlwaysShow( TEAM_MILITIA, null )
		SetSquad( guy, squadName )

		thread HumanNav_Thread(guy) // not working i think
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
	for (entity npc in npcs)
		if (IsValid(GetPetTitanOwner( npcs[i] )))
			deduct++
	int aliveTitans = npcs.len() - deduct
	while(aliveTitans>amount)
	{
		WaitFrame()
		npcs = GetNPCArray()
		detuct = 0
		foreach(entity npc in npcs)
			if (IsValid(GetPetTitanOwner( npcs[i] )))
				deduct++
		aliveTitans = GetNPCArray().len() - deduct
		if(!IsAlive(fd_harvester.harvester))
			break
	}
}
