global function GamemodeFD_Init
global function RateSpawnpoints_FD
global function startHarvester
global function createSmokeEvent
global function createArcTitanEvent
global function createWaitForTimeEvent
global function createSuperSpectreEvent
global function createDroppodGruntEvent

global struct SmokeEvent{
	vector position
	float lifetime
}

global struct SpawnEvent{
	vector origin
	vector angles
	string route
	int spawnType			//Just used for Wave Info but can be used for spawn too should contain aid of spawned enemys
	int spawnAmount			//Just used for Wave Info but can be used for spawn too should contain amount of spawned enemys
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

struct {
	array<entity> aiSpawnpoints
	array<entity> smokePoints
	array<entity> routeNodes
	table<string,float> harvesterDamageSource
	bool haversterWasDamaged
}file

void function GamemodeFD_Init()
{
	PrecacheModel( MODEL_ATTRITION_BANK )
	PrecacheParticleSystem($"P_smokescreen_FD")
	AddCallback_EntitiesDidLoad(LoadEntities)
	AddDamageCallback("prop_script",OnDamagedPropScript)
	AddCallback_GameStateEnter( eGameState.Playing,startMainGameLoop)
	AddClientCommandCallback("FD_UseHarvesterShieldBoost",useShieldBoost)
}

void function RateSpawnpoints_FD(int _0, array<entity> _1, int _2, entity _3)
{
	
}

bool function useShieldBoost(entity player,array<string> args)
{
	if((GetGlobalNetTime("FD_harvesterInvulTime")<Time())&&(player.GetPlayerNetInt("numHarvesterShieldBoost")>0))
	{	
		fd_harvester.harvester.SetShieldHealth(fd_harvester.harvester.GetShieldHealthMax())
		SetGlobalNetTime("FD_harvesterInvulTime",Time()+5)
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
	runWave(0)

}






array<entity> function getRoute(string routeName)
{
	foreach(entity node in file.routeNodes)
	{
		if(!node.HasKey("route_name"))
			continue
		if(node.kv.route_name==routeName)
			return node.GetLinkEntArray()
	}
	printt("Route not found")
	return []
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

void function runWave(int waveIndex)
{
	file.haversterWasDamaged = false
	array<int> enemys = getEnemyTypesForWave(waveIndex)
	
	SetGlobalNetInt("FD_currentWave",waveIndex)
	SetGlobalNetBool("FD_waveActive",true)


	foreach(entity player in GetPlayerArray())
	{
		
		Remote_CallFunction_NonReplay(player,"ServerCallback_FD_AnnouncePreParty",enemys[0],enemys[1],enemys[2],enemys[3],enemys[4],enemys[5],enemys[6],enemys[7],enemys[8])
	}
	foreach(WaveEvent event in waveEvents[waveIndex])
	{
		event.eventFunction(event.smokeEvent,event.spawnEvent,event.waitEvent,event.soundEvent)
	}

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
		file.haversterWasDamaged = true
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
void function startHarvester(){
	
	thread HarvesterThink()
	thread HarvesterAlarm()

}


void function HarvesterAlarm()
{
	while(IsAlive(fd_harvester.harvester))
	{
		if(fd_harvester.harvester.GetShieldHealth()==0)
		{
			EmitSoundOnEntity(fd_harvester.harvester,"coop_generator_underattack_alarm")
			wait 2.5
		}
		else
		{
			WaitFrame()
		}
	}
}
void function initNetVars(){
	SetGlobalNetInt("FD_totalWaves",waveEvents.len())
	if(GetCurrentPlaylistVarInt("fd_difficulty",0)>=5)
		SetGlobalNetInt("FD_restartsRemaining",0)
	else	
		SetGlobalNetInt("FD_restartsRemaining",2)
	
}


void function LoadEntities() 
{	
	initNetVars()
	CreateBoostStoreLocation(TEAM_MILITIA,shopPosition,<0,0,0>)
	OpenBoostStores()



	foreach ( entity info_target in GetEntArrayByClass_Expensive("info_target") )
	{
		
		if ( GameModeRemove( info_target ) )
			continue
		
		if(info_target.HasKey("editorclass")){
			switch(info_target.kv.editorclass){
				case"info_fd_harvester":
					HarvesterStruct ret = SpawnHarvester(info_target.GetOrigin(),info_target.GetAngles(),25000,6000,TEAM_IMC)
					fd_harvester.harvester = ret.harvester
					fd_harvester.rings = ret.rings
					fd_harvester.lastDamage = ret.lastDamage
					
					break
				case"info_fd_mode_model":
					entity prop = CreatePropDynamic( info_target.GetModelName(), info_target.GetOrigin(), info_target.GetAngles(), 6 )
					break
				case"info_fd_ai_position":
					file.aiSpawnpoints.append(info_target)
					if(info_target.kv.aiType=="3")
						CreatePropDynamic($"models/vehicle/escape_pod/escape_pod.mdl",info_target.GetOrigin(),info_target.GetAngles(),6)

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

WaveEvent function createWaitForTimeEvent(float amount)
{
	WaveEvent event
	event.eventFunction = waitForTime
	event.waitEvent.amount = amount
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
	smokescreen.origin = smokeEvent.position
	smokescreen.angles = <0,0,0>
	smokescreen.lifetime = smokeEvent.lifetime
	smokescreen.fxXYRadius = 150
	smokescreen.fxZRadius = 120
	smokescreen.fxOffsets = [ <120.0, 0.0, 0.0>,<0.0, 120.0, 0.0>, <0.0, 0.0, 0.0>,<0.0, -120.0, 0.0>,< -120.0, 0.0, 0.0>, <0.0, 100.0, 0.0>]
	Smokescreen(smokescreen)
}

void function spawnArcTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = CreateArcTitan(TEAM_IMC,spawnEvent.origin,spawnEvent.angles)
	DispatchSpawn(npc)
}

void function waitForTime(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	wait waitEvent.amount
}

void function waitUntil(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	wait waitEvent.amount
}

void function spawnSuperSpectre(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = CreateSuperSpectre(TEAM_IMC,spawnEvent.origin,spawnEvent.angles)
	DispatchSpawn(npc)
}

void function spawnDroppodGrunts(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	CreateTrackedDroppod(spawnEvent.origin,TEAM_IMC)
}
void function spawnGenericNPC(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = CreateNPC( spawnEvent.npcClassName, TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	DispatchSpawn(npc)
}
void function spawnGenericNPCTitanwithSettings(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = CreateNPCTitan( spawnEvent.npcClassName, TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, spawnEvent.aiSettings)
	DispatchSpawn(npc)
}
void function spawnNukeTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = CreateNPCTitan("titan_ogre",TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings(npc,"npc_titan_minigun_nuke")
	DispachSpawn(npc)
}

/********************************************************************************************************************\
#     # ####### #       ######  ####### ######     ####### #     # #     #  #####  ####### ### ####### #     #  #####  
#     # #       #       #     # #       #     #    #       #     # ##    # #     #    #     #  #     # ##    # #     # 
#     # #       #       #     # #       #     #    #       #     # # #   # #          #     #  #     # # #   # #       
####### #####   #       ######  #####   ######     #####   #     # #  #  # #          #     #  #     # #  #  #  #####  
#     # #       #       #       #       #   #      #       #     # #   # # #          #     #  #     # #   # #       # 
#     # #       #       #       #       #    #     #       #     # #    ## #     #    #     #  #     # #    ## #     # 
#     # ####### ####### #       ####### #     #    #        #####  #     #  #####     #    ### ####### #     #  #####  
\********************************************************************************************************************/


void function CreateTrackedDroppod( vector origin, int team , )
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
