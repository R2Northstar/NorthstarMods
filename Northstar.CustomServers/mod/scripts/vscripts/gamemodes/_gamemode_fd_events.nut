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
global function executeWave


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
	int executeOnThisCall //will actually be executed when called this many times 
	int timesExecuted
	int nextEventIndex
	SmokeEvent smokeEvent
	SpawnEvent spawnEvent
	WaitEvent waitEvent
	SoundEvent soundEvent
}




global array<array<WaveEvent> > waveEvents



void function executeWave()
{	
	print("executeWave Start")
	thread runEvents(0)
	while(IsAlive(fd_harvester.harvester)&&(!allEventsExecuted(GetGlobalNetInt("FD_currentWave"))))
		WaitFrame()
	waitUntilLessThanAmountAlive(0)
	waitUntilLessThanAmountAlive_expensive(0)
}

bool function allEventsExecuted(int waveIndex) 
{
	foreach(WaveEvent e in waveEvents[waveIndex])
	{
		if(e.executeOnThisCall>e.timesExecuted)
			return false
	}
	return true
}

void function runEvents(int firstExecuteIndex)
{	
	print("runEvents Start")
	WaveEvent currentEvent = waveEvents[GetGlobalNetInt("FD_currentWave")][firstExecuteIndex]
	
	while(true)
	{	
		currentEvent.timesExecuted++
		if(currentEvent.timesExecuted!=currentEvent.executeOnThisCall)
		{
			print("not on this call")
			return
		}
		if(!IsAlive(fd_harvester.harvester))
		{
			print("harvesterDead")
			return
		}
		if(currentEvent.shouldThread)
		{
			print("execute with thread")
			thread currentEvent.eventFunction(currentEvent.smokeEvent,currentEvent.spawnEvent,currentEvent.waitEvent,currentEvent.soundEvent)
		}
		else
		{	
			print("execute without thread")
			currentEvent.eventFunction(currentEvent.smokeEvent,currentEvent.spawnEvent,currentEvent.waitEvent,currentEvent.soundEvent)
		}
		if(currentEvent.nextEventIndex==0)
		{
			print("zero index")
			return
		}
		currentEvent = waveEvents[GetGlobalNetInt("FD_currentWave")][currentEvent.nextEventIndex]
	}
	print("runEvents End")
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

WaveEvent function createSmokeEvent(vector position,float lifetime,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnSmoke
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.smokeEvent.position = position
	event.smokeEvent.lifetime = lifetime
	return event
}

WaveEvent function createArcTitanEvent(vector origin,vector angles,string route,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnArcTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_ARC
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function createSuperSpectreEvent(vector origin,vector angles,string route,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnSuperSpectre
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.REAPER
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function createDroppodGruntEvent(vector origin,string route,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnDroppodGrunts
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.GRUNT
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.route = route
	return event
}

WaveEvent function createDroppodStalkerEvent(vector origin,string route,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnDroppodStalker
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.STALKER
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.route = route
	return event
}

WaveEvent function createDroppodSpectreMortarEvent(vector origin,string route,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnDroppodSpectreMortar
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.SPECTRE_MORTAR
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.route = route
	return event
}

WaveEvent function createWaitForTimeEvent(float amount,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.shouldThread = false
	event.eventFunction = waitForTime
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.waitEvent.amount = amount
	return event
}

WaveEvent function createWaitUntilAliveEvent(int amount,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = waitUntilLessThanAmountAliveEvent
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = false
	event.waitEvent.amount = amount.tofloat()
	return event
}

WaveEvent function createGenericSpawnEvent(string npcClassName,vector origin,vector angles,string route,int spawnType,int spawnAmount,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnGenericNPC
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.npcClassName = npcClassName
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.spawnType = spawnType
	event.spawnEvent.spawnAmount = spawnAmount
	return event
}

WaveEvent function createGenericTitanSpawnWithAiSettingsEvent(string npcClassName,string aiSettings,vector origin,vector angles,string route,int spawnType,int spawnAmount,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnGenericNPCTitanwithSettings
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
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

WaveEvent function createNukeTitanEvent(vector origin,vector angles,string route,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnNukeTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_NUKE
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	return event
}

WaveEvent function createMortarTitanEvent(vector origin,vector angles,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnMortarTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_MORTAR
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function createCloakDroneEvent(vector origin,vector angles,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = fd_spawnCloakDrone
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.DRONE_CLOAK
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function CreateTickEvent( vector origin, vector angles, int amount, string route,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = SpawnTick
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TICK
	event.spawnEvent.spawnAmount = amount
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function CreateNorthstarSniperTitanEvent(vector origin,vector angles,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = spawnSniperTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TITAN_SNIPER
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	return event
}

WaveEvent function CreateToneSniperTitanEvent(vector origin,vector angles,int nextEventIndex,int executeOnThisCall = 1)
{
	WaveEvent event
	event.eventFunction = SpawnToneSniperTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
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


}

void function spawnArcTitan(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	PingMinimap(spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0)
	entity npc = CreateArcTitan(TEAM_IMC,spawnEvent.origin,spawnEvent.angles)
	npc.DisableNPCFlag(NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER|NPC_ALLOW_PATROL)
	SetSpawnOption_Titanfall(npc)
	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType)) // required for client to create icons
	SetSpawnOption_AISettings(npc,"npc_titan_stryder_leadwall_arc")
	spawnedNPCs.append(npc)
	DispatchSpawn(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	npc.AssaultSetFightRadius(0)
	thread singleNav_thread(npc,spawnEvent.route)
	thread EMPTitanThinkConstant(npc)

}

void function waitForTime(SmokeEvent smokeEvent,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	float waitUntil = Time() + waitEvent.amount
	while(Time()<waitUntil)
	{
		if(!IsAlive(fd_harvester.harvester))
			return
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
	spawnedNPCs.append(npc)

	wait 4.7
	DispatchSpawn(npc)
	AddMinimapForHumans(npc)
	thread SuperSpectre_WarpFall(npc)
	thread ReaperMinionLauncherThink(npc)

	SetTargetName( npc, GetTargetNameForID(spawnEvent.spawnType))
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

    for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
    {
		entity guy = CreateSoldier( TEAM_IMC, spawnEvent.origin,<0,0,0> )

		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL)
		DispatchSpawn( guy )

	guy.SetParent( pod, "ATTACH", true )
	SetSquad( guy, squadName )

	SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.GRUNT))
	AddMinimapForHumans(guy)
	spawnedNPCs.append(guy)
	guys.append( guy )
	}

	ActivateFireteamDropPod( pod, guys )
	thread SquadNav_Thread(guys,spawnEvent.route)
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
	spawnedNPCs.append(npc)
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
	npc.AssaultSetFightRadius(0)
	DispatchSpawn(npc)
	spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread(npc,spawnEvent.route)
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
	spawnedNPCs.append(npc)
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
	spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
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
	npc.AssaultSetFightRadius(0)
	spawnedNPCs.append(npc)
	AddMinimapForTitans(npc)
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread SniperTitanThink(npc,fd_harvester.harvester)
}

void function fd_spawnCloakDrone(SmokeEvent smokeEffect,SpawnEvent spawnEvent,WaitEvent waitEvent,SoundEvent soundEvent)
{
	entity npc = SpawnCloakDrone( TEAM_IMC, spawnEvent.origin, spawnEvent.angles, fd_harvester.harvester.GetOrigin() )
	spawnedNPCs.append(npc)
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
		guy.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS | NPCMF_PREFER_SPRINT)
		DispatchSpawn( guy )
		AddMinimapForHumans(guy)
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.TICK))
		SetSquad( guy, squadName )

		guys.append( guy )
	}

	ActivateFireteamDropPod( pod, guys )
	thread SquadNav_Thread(guys,spawnEvent.route)
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

	int aliveTitans = spawnedNPCs.len()
	while(aliveTitans>amount)
	{
		WaitFrame()
		aliveTitans = spawnedNPCs.len()
		if(!IsAlive(fd_harvester.harvester))
			return
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
			return
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
