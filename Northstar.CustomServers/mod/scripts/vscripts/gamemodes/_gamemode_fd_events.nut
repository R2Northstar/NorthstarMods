global function CreateSmokeEvent
global function CreateArcTitanEvent
global function CreateWaitForTimeEvent
global function CreateSuperSpectreEvent
global function CreateSuperSpectreEventWithMinion
global function CreateDroppodGruntEvent
global function CreateNukeTitanEvent
global function CreateMortarTitanEvent
global function CreateGenericSpawnEvent
global function CreateGenericTitanSpawnWithAiSettingsEvent
global function CreateDroppodStalkerEvent
global function CreateDroppodSpectreMortarEvent
global function CreateWaitUntilAliveEvent
global function CreateWaitUntilAliveWeightedEvent
global function CreateCloakDroneEvent
global function CreateDroppodTickEvent
global function CreateSpawnDroneEvent
global function CreateToneSniperTitanEvent
global function CreateNorthstarSniperTitanEvent //northstars are always sniper titans
global function CreateIonTitanEvent
global function CreateScorchTitanEvent
global function CreateRoninTitanEvent
global function CreateToneTitanEvent
global function CreateLegionTitanEvent
global function CreateMonarchTitanEvent
global function CreateWarningEvent
global function CreateTitanfallBlockEvent //Careful when using this, it really changes gameplay perspective for players and can make a wave impossible to beat (Use 1 to Block, and 0 to Unblock midwave)
global function CreateGruntDropshipEvent //This one always requires testing after usage because sometimes Grunts wont zipline to the ground, it wont softlock the wave, but makes this odd behavior
global function executeWave
global function restetWaveEvents
global function WinWave

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
	string entityGlobalKey
	bool shouldLoop = false
}

global struct FlowControlEvent{
	float waitTime
	int splitNextEventIndex
	int waitAmount
	int waitEntityType
	array<string> waitGlobalDataKey 
}

global struct SoundEvent{
	string soundEventName
}

global struct WaveEvent{
	void functionref(SmokeEvent,SpawnEvent,FlowControlEvent,SoundEvent) eventFunction
	bool shouldThread
	int executeOnThisCall //will actually be executed when called this many times 
	int timesExecuted
	int nextEventIndex
	SmokeEvent smokeEvent
	SpawnEvent spawnEvent
	FlowControlEvent flowControlEvent
	SoundEvent soundEvent
	
}

global enum FD_IncomingWarnings
{
	CloakDrone,
	ArcTitan,
	Reaper,
	MortarTitan,
	NukeTitan,
	ReaperAlt,
	Ticks,
	Stalkers,
	MortarSpectre,
	ReaperTicks,
	Flyers,
	EliteTitan,
	Infantry,
	CloakDroneIntro,
	EnemyTitansIncoming,
	MortarTitanIntro,
	NukeTitanIntro,
	ArcTitanIntro,
	TitanfallBlocked,
	PreNukeTitan,
	PreMortarTitan,
	PreArcTitan,
	Everything,
	LightWave,
	MediumWave,
	HeavyWave,
	NoMoreTitansInWave,
	ArcTitanAlt
}

global table< string, entity > GlobalEventEntitys
global array< array<WaveEvent> > waveEvents



void function executeWave()
{	
	print( "Wave Start: " + GetGlobalNetInt( "FD_currentWave" ) )
	thread runEvents( 0 )
	while( IsHarvesterAlive( fd_harvester.harvester ) && !allEventsExecuted( GetGlobalNetInt( "FD_currentWave" ) ) && GetGlobalNetInt( "FD_AICount_Current" ) >= 1 )
		WaitFrame()

	waitUntilLessThanAmountAlive( 0 )
	waitUntilLessThanAmountAlive_expensive( 0 )
}

bool function allEventsExecuted( int waveIndex ) 
{
	foreach( WaveEvent e in waveEvents[waveIndex] )
	{
		if( e.executeOnThisCall > e.timesExecuted )
			return false
	}
	return true
}

void function runEvents( int firstExecuteIndex )
{	
	print( "Events Start" )
	WaveEvent currentEvent = waveEvents[GetGlobalNetInt( "FD_currentWave" )][firstExecuteIndex]
	
	while(true)
	{	
		currentEvent.timesExecuted++
		if(currentEvent.timesExecuted!=currentEvent.executeOnThisCall)
		{
			print( "not on this call" ) 
			return
		}
		if( !IsHarvesterAlive(fd_harvester.harvester ) )
		{
			print( "harvesterDead" )
			return
		}
		if( currentEvent.shouldThread )
		{
			print( "execute with thread" )
			thread currentEvent.eventFunction( currentEvent.smokeEvent, currentEvent.spawnEvent, currentEvent.flowControlEvent, currentEvent.soundEvent )
		}
		else
		{	
			print( "execute without thread" )
			currentEvent.eventFunction( currentEvent.smokeEvent, currentEvent.spawnEvent, currentEvent.flowControlEvent, currentEvent.soundEvent )
		}
		if( currentEvent.nextEventIndex == 0 )
		{
			print( "zero index reached, finishing wave" )
			return
		}
		currentEvent = waveEvents[GetGlobalNetInt( "FD_currentWave" )][currentEvent.nextEventIndex]
	}
	print( "runEvents End" )
}

void function restetWaveEvents()
{
	foreach( WaveEvent event in waveEvents[GetGlobalNetInt( "FD_currentWave" )] )
	{
		event.timesExecuted = 0
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

WaveEvent function CreateSmokeEvent( vector position, float lifetime, int nextEventIndex, int executeOnThisCall = 1 )
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

WaveEvent function CreateArcTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateSuperSpectreEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateSuperSpectreEventWithMinion( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = spawnSuperSpectreWithMinion
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.REAPER
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateDroppodGruntEvent( vector origin, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateDroppodStalkerEvent( vector origin, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateDroppodSpectreMortarEvent( vector origin, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateWaitForTimeEvent( float waitTime, int nextEventIndex, int executeOnThisCall = 1 )
{
	WaveEvent event
	event.shouldThread = false
	event.eventFunction = waitForTime
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.flowControlEvent.waitTime = waitTime
	return event
}

WaveEvent function CreateWaitUntilAliveEvent( int amount, int nextEventIndex, int executeOnThisCall = 1 )
{
	WaveEvent event
	event.eventFunction = waitUntilLessThanAmountAliveEvent
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = false
	event.flowControlEvent.waitAmount = amount
	return event
}

WaveEvent function CreateWaitUntilAliveWeightedEvent( int amount, int nextEventIndex, int executeOnThisCall = 1 )
{
	WaveEvent event
	event.eventFunction = waitUntilLessThanAmountAliveEventWeighted
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = false
	event.flowControlEvent.waitAmount = amount
	return event
}

WaveEvent function CreateGenericSpawnEvent( string npcClassName, vector origin, vector angles, string route, int spawnType, int spawnAmount, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateGenericTitanSpawnWithAiSettingsEvent( string npcClassName, string aiSettings, vector origin, vector angles, string route, int spawnType, int spawnAmount, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateNukeTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateMortarTitanEvent( vector origin, vector angles, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateCloakDroneEvent( vector origin, vector angles, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateDroppodTickEvent( vector origin, int amount, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = SpawnTick
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TICK
	event.spawnEvent.spawnAmount = amount
	event.spawnEvent.origin = origin
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateNorthstarSniperTitanEvent( vector origin, vector angles, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateToneSniperTitanEvent( vector origin, vector angles, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
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
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}


WaveEvent function CreateIonTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = SpawnIonTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.ION
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateScorchTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = SpawnScorchTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.SCORCH
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateRoninTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = SpawnRoninTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.RONIN
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateToneTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = SpawnToneTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.TONE
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateLegionTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = SpawnLegionTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.LEGION
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateMonarchTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = SpawnMonarchTitan
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.MONARCH
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

WaveEvent function CreateWaitForDeathOfEntitysEvent( array<string> waitGlobalDataKey, int nextEventIndex, int executeOnThisCall = 1 )
{
	WaveEvent event
	event.eventFunction = waitForDeathOfEntitys
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event. shouldThread = false
	event.flowControlEvent.waitGlobalDataKey = waitGlobalDataKey
	return event
}

WaveEvent function CreateWaitForLessThanTypedEvent(int aiTypeId,int amount,int nextEventIndex,int executeOnThisCall = 1 )
{
	WaveEvent event
	event.eventFunction = waitForLessThanAliveTyped
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = false
	event.flowControlEvent.waitAmount = amount
	event.flowControlEvent.waitEntityType = aiTypeId
	return event
}

WaveEvent function CreateSpawnDroneEvent(vector origin,vector angles,string route,int nextEventIndex, bool shouldLoop = true, int executeOnThisCall = 1,string entityGlobalKey="")
{
	WaveEvent event
	event.eventFunction = spawnDrones
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.DRONE
	event.spawnEvent.spawnAmount = 4
	event.spawnEvent.origin = origin
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	event.spawnEvent.route = route
	event.spawnEvent.shouldLoop = shouldLoop
	return event
}

WaveEvent function CreateWarningEvent( int warningType, int nextEventIndex, int executeOnThisCall = 1 )
{
	WaveEvent event
	event.eventFunction = PlayWarning
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = false

	switch(warningType)
	{
		case FD_IncomingWarnings.CloakDrone:
		event.soundEvent.soundEventName = "fd_incCloakDroneClump"
		break
		
		case FD_IncomingWarnings.ArcTitan:
		event.soundEvent.soundEventName = "fd_incArcTitanClump"
		break
		
		case FD_IncomingWarnings.Reaper:
		event.soundEvent.soundEventName = "fd_incReaperClump"
		break
		
		case FD_IncomingWarnings.MortarTitan:
		event.soundEvent.soundEventName = "fd_incTitansMortarClump"
		break
		
		case FD_IncomingWarnings.NukeTitan:
		event.soundEvent.soundEventName = "fd_incTitansNukeClump"
		break
		
		case FD_IncomingWarnings.ReaperAlt:
		event.soundEvent.soundEventName = "fd_waveTypeReapers"
		break
		
		case FD_IncomingWarnings.Ticks:
		event.soundEvent.soundEventName = "fd_waveTypeTicks"
		break
		
		case FD_IncomingWarnings.Stalkers:
		event.soundEvent.soundEventName = "fd_waveTypeStalkers"
		break
		
		case FD_IncomingWarnings.MortarSpectre:
		event.soundEvent.soundEventName = "fd_waveTypeMortarSpectre"
		break
		
		case FD_IncomingWarnings.ReaperTicks:
		event.soundEvent.soundEventName = "fd_waveTypeReaperTicks"
		break
		
		case FD_IncomingWarnings.Flyers:
		event.soundEvent.soundEventName = "fd_waveTypeFlyers"
		break
		
		case FD_IncomingWarnings.EliteTitan:
		event.soundEvent.soundEventName = "fd_waveTypeEliteTitan"
		break
		
		case FD_IncomingWarnings.Infantry:
		event.soundEvent.soundEventName = "fd_waveTypeInfantry"
		break
		
		case FD_IncomingWarnings.CloakDroneIntro:
		event.soundEvent.soundEventName = "fd_waveTypeCloakDrone"
		break
		
		case FD_IncomingWarnings.EnemyTitansIncoming:
		event.soundEvent.soundEventName = "fd_waveTypeTitanReg"
		break
		
		case FD_IncomingWarnings.MortarTitanIntro:
		event.soundEvent.soundEventName = "fd_waveTypeTitanMortar"
		break
		
		case FD_IncomingWarnings.NukeTitanIntro:
		event.soundEvent.soundEventName = "fd_waveTypeTitanNuke"
		break
		
		case FD_IncomingWarnings.ArcTitanIntro:
		event.soundEvent.soundEventName = "fd_waveTypeTitanArc"
		break
		
		case FD_IncomingWarnings.TitanfallBlocked:
		event.soundEvent.soundEventName = "fd_waveNoTitanDrops"
		break
		
		case FD_IncomingWarnings.PreNukeTitan:
		event.soundEvent.soundEventName = "fd_soonNukeTitans"
		break
		
		case FD_IncomingWarnings.PreMortarTitan:
		event.soundEvent.soundEventName = "fd_soonMortarTitans"
		break
		
		case FD_IncomingWarnings.PreArcTitan:
		event.soundEvent.soundEventName = "fd_soonArcTitans"
		break
		
		case FD_IncomingWarnings.Everything:
		event.soundEvent.soundEventName = "fd_waveComboMultiMix"
		break
		
		case FD_IncomingWarnings.LightWave:
		event.soundEvent.soundEventName = "fd_introEasy"
		break
		
		case FD_IncomingWarnings.MediumWave:
		event.soundEvent.soundEventName = "fd_introMedium"
		break
		
		case FD_IncomingWarnings.HeavyWave:
		event.soundEvent.soundEventName = "fd_introHard"
		break
		
		case FD_IncomingWarnings.NoMoreTitansInWave:
		event.soundEvent.soundEventName = "fd_waveNoTitans"
		break
		
		case FD_IncomingWarnings.ArcTitanAlt:
		event.soundEvent.soundEventName = "fd_nagKillTitanEMP"
		break
	}
	
	return event
}

WaveEvent function CreateTitanfallBlockEvent( int amount, int nextEventIndex, int executeOnThisCall = 1 )
{
	WaveEvent event
	event.eventFunction = BlockFurtherTitanfalls
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = false
	event.flowControlEvent.waitAmount = amount
	return event
}

WaveEvent function CreateGruntDropshipEvent( vector origin, vector angles, int amount, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "" )
{
	WaveEvent event
	event.eventFunction = spawnGruntDropship
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.GRUNT
	event.spawnEvent.spawnAmount = amount
	event.spawnEvent.origin = origin
	event.spawnEvent.entityGlobalKey = entityGlobalKey
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

//Hack by using one of the existing struct vars, hopefully nothing will break
void function BlockFurtherTitanfalls( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	if ( flowControlEvent.waitAmount == 1 )
	{
		PlayerEarnMeter_SetEnabled( false )
		foreach( entity player in GetPlayerArray() )
		{
			PlayerEarnMeter_Reset( player )
		}
	}
	else
		PlayerEarnMeter_SetEnabled( true )
}

void function PlayWarning( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PlayFactionDialogueToTeam( soundEvent.soundEventName, TEAM_MILITIA )
}

void function spawnSmoke( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "smoke" )
	SmokescreenStruct smokescreen
	smokescreen.smokescreenFX = $"P_smokescreen_FD"
	smokescreen.isElectric = false
	smokescreen.origin = smokeEvent.position + < 0, 0, 100 >
	smokescreen.angles = < 0, 0, 0 >
	smokescreen.lifetime = smokeEvent.lifetime
	smokescreen.fxXYRadius = 150
	smokescreen.fxZRadius = 120
	smokescreen.fxOffsets = [ < 130.0, 0.0, 0.0 >, < 0.0, 130.0, 0.0 >, < 0.0, 0.0, 0.0 >, < 0.0, -130.0, 0.0 >, < -130.0, 0.0, 0.0 >, < 0.0, 100.0, 0.0 > ]

	Smokescreen(smokescreen)
}

void function spawnDrones( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	//TODO
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	array<vector> offsets = [ < 0, 32, 0 >, < 32, 0, 0 >, < 0, -32, 0 >, < -32, 0, 0 > ]


	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
    {
		entity guy

		guy = CreateGenericDrone( TEAM_IMC, spawnEvent.origin + offsets[i], spawnEvent.angles )
		SetSpawnOption_AISettings( guy, "npc_drone_plasma_fd" )

		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		guy.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )
		guy.EnableNPCFlag( NPC_STAY_CLOSE_TO_SQUAD )
		guy.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS | NPCMF_PREFER_SPRINT )
		DispatchSpawn( guy )

		//guy.GiveWeapon("mp_weapon_engineer_combat_drone")

		SetSquad( guy, squadName )

		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.DRONE ) )
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		thread droneNav_thread(guy, spawnEvent.route, 0, 500, spawnEvent.shouldLoop )
	}


}

void function waitForDeathOfEntitys( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	while( IsHarvesterAlive( fd_harvester.harvester ) )
	{
		bool anyoneAlive = false
		foreach( string key in flowControlEvent.waitGlobalDataKey )
		{
			if( !( key in GlobalEventEntitys ) )
				continue
			if( IsAlive( GlobalEventEntitys[key] ) )
				anyoneAlive = true
		}
		if( !anyoneAlive )
			break
	}
}

void function waitForLessThanAliveTyped( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{	
	while( IsHarvesterAlive( fd_harvester.harvester ) )
	{
		int amount
		foreach( entity npc in spawnedNPCs )
		{
			if( FD_GetAITypeID_ByString( npc.GetTargetName() ) ) //TODO getaitypeid_bystring does not contain all possible strings
				amount++
		}
		if( amount <= flowControlEvent.waitAmount )
			break
		WaitFrame()
	}
	
}

void function spawnArcTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateArcTitan( TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER | NPC_ALLOW_PATROL )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_arc" )
	spawnedNPCs.append( npc )
	DispatchSpawn( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	npc.AssaultSetFightRadius( 0 )
	GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	thread singleNav_thread( npc, spawnEvent.route )
	thread EMPTitanThinkConstant( npc )

}

void function waitForTime( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	float waitUntil = Time() + flowControlEvent.waitTime
	while( Time() < waitUntil )
	{
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
		WaitFrame()
	}
}

void function waitUntilLessThanAmountAliveEvent( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	waitUntilLessThanAmountAlive( flowControlEvent.waitAmount )
}
void function waitUntilLessThanAmountAliveEventWeighted( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	waitUntilLessThanAmountAliveWeighted( flowControlEvent.waitAmount )
}

void function spawnSuperSpectre( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	wait 1.7
	TryAnnounceTitanfallWarningToEnemyTeam( TEAM_IMC, spawnEvent.origin )
	wait 3.0

	entity npc = CreateSuperSpectre( TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_super_spectre_fd" )
	spawnedNPCs.append( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	DispatchSpawn( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) )
	AddMinimapForHumans( npc )
	thread SuperSpectre_WarpFall( npc )
	npc.WaitSignal( "WarpfallComplete" )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function spawnSuperSpectreWithMinion( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	wait 1.7
	TryAnnounceTitanfallWarningToEnemyTeam( TEAM_IMC, spawnEvent.origin )
	wait 3.0

	entity npc = CreateSuperSpectre( TEAM_IMC, spawnEvent.origin,spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_super_spectre_fd" )
	spawnedNPCs.append( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	DispatchSpawn( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) )
	AddMinimapForHumans( npc )
	thread SuperSpectre_WarpFall( npc )
	npc.WaitSignal( "WarpfallComplete" )
	thread ReaperMinionLauncherThink( npc )

}

void function spawnDroppodGrunts( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
    {
		entity guy = CreateSoldier( TEAM_IMC, spawnEvent.origin, < 0, 0, 0 > )
		
		// should this grunt be a shield captain?
		if (i < GetCurrentPlaylistVarInt( "fd_grunt_shield_captains", 0 ) )
			SetSpawnOption_AISettings( guy, "npc_soldier_shield_captain" ) //Actually spawning a true shield captain from campaign to spice things up, for vanilla behavior, just remove this line use the one below
			//thread ActivatePersonalShield( guy )
			
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey+ i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL )
		DispatchSpawn( guy )

		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )

		// should this grunt have an anti titan weapon instead of its normal weapon?
		if ( i < GetCurrentPlaylistVarInt( "fd_grunt_at_weapon_users", 0 ) )
		{
			guy.GiveWeapon( "mp_weapon_defender" ) // do grunts ever get a different anti titan weapon? - yes, TODO
			// atm they arent using their AT weapons ever, but they do in fact get them, in fact some grunts are getting 2 since they already get a rocket_launcher
			// this seems to be a problem elsewhere as opposed to something that is wrong here
		}

		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.GRUNT ) ) // do shield captains get their own target name in vanilla?
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		guys.append( guy )
	}
	
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	thread SquadNav_Thread( guys,spawnEvent.route )
}

//This function is based off the entire function chain called by AiGameModes_SpawnDropShip(), that function uses table data for modularization and while it
//works just fine if we simply use it here, there's no viable way to add the Grunts into the enemy count pool, plus that function also only works at
//specific nodes found in the maps, that is not needed here, full control over the coordinates where the dropship will drop grunts is better.
void function spawnGruntDropship( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{  
	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "DropshipTable" ) )
	
	vector origin 		= spawnEvent.origin
	origin.z 		   += 448 //Expected to people make coordinates in the ground so we add this up for the hover height
	float yaw 			= spawnEvent.angles.y
	int team 			= TEAM_IMC
	string squadname 	= squadName
	int style 			= eDropStyle.ZIPLINE_NPC
	int health 			= 7800
	
	CallinData drop
	InitCallinData( drop )
	SetCallinStyle( drop, style )
	drop.dist 			= 1600
	drop.origin 		= origin
	drop.yaw 			= yaw
	
	SpawnPointFP spawnPoint
	array<string> anims = GetRandomDropshipDropoffAnims()
	string animation
	FlightPath flightPath
	
	foreach ( anim in anims )
	{
		animation = anim
		flightPath = GetAnalysisForModel( DROPSHIP_MODEL, anim )
		spawnPoint = GetSpawnPointForStyle( flightPath, drop )
		if ( spawnPoint.valid )
			break
	}
	
	entity ref = CreateScriptRef()
	ref.SetOrigin( origin )
	ref.SetAngles( < 0, yaw, 0 > )
	
	if ( "nextDropshipAttackedByFlyers" in level && level.nextDropshipAttackedByFlyers )
		animation = FlyersAttackDropship( ref, animation )

	Assert( IsNewThread(), "Must be threaded off" )

	DropTable dropTable
	dropTable.nodes = DropshipFindDropNodes( flightPath, origin, yaw, "both", true, IsLegalFlightPath_OverTime )
	dropTable.valid = true
	
	asset model = GetFlightPathModel( "fp_crow_model" )
	waitthread WarpinEffect( model, animation, ref.GetOrigin(), ref.GetAngles() )
	entity dropship = CreateDropship( team, ref.GetOrigin(), ref.GetAngles() )
	SetSpawnOption_SquadName( dropship, squadname )
	dropship.kv.solid = SOLID_VPHYSICS
	DispatchSpawn( dropship )
	dropship.SetHealth( health )
	dropship.SetMaxHealth( health )
	dropship.EndSignal( "OnDeath" )
	dropship.Signal( "WarpedIn" )
	ref.Signal( "WarpedIn" )
	dropship.Minimap_AlwaysShow( TEAM_IMC, null )
	dropship.Minimap_AlwaysShow( TEAM_MILITIA, null )
	dropship.Minimap_SetHeightTracking( true )

	AddDropshipDropTable( dropship, dropTable )
	string dropshipSound = "Goblin_IMC_TroopDeploy_Flyin"

	OnThreadEnd(
		function() : ( dropship, ref, dropshipSound )
		{
			ref.Destroy()
			if ( IsValid( dropship ) )
				StopSoundOnEntity( dropship, dropshipSound )
			if ( IsAlive( dropship ) )
				dropship.Destroy()
		}
	)
	
	array<entity> guys
	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
    {
		entity guy = CreateSoldier( TEAM_IMC, spawnEvent.origin, < 0, 0, 0 > )
		
		if (i < GetCurrentPlaylistVarInt( "fd_grunt_shield_captains", 0 ) )
			SetSpawnOption_AISettings( guy, "npc_soldier_shield_captain" )
			//thread ActivatePersonalShield( guy )

		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey+ i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL )
		DispatchSpawn( guy )
		
		SetSquad( guy, squadName )
		
		if ( i < GetCurrentPlaylistVarInt( "fd_grunt_at_weapon_users", 0 ) )
			guy.GiveWeapon( "mp_weapon_arc_launcher" )
		
		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.GRUNT ) )
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		guys.append( guy )
		
		int seat 	= i
		table Table = CreateDropshipAnimTable( dropship, "both", seat )
		thread GuyDeploysOffShip( guy, Table )
		thread singleNav_thread( guy, spawnEvent.route ) //Since grunts ziplines far away from each other, it's better them just path individually
	}
	
	dropship.Hide()
	EmitSoundOnEntity( dropship, dropshipSound )
	thread ShowDropship( dropship )
	thread PlayAnimTeleport( dropship, animation, ref, 0 )
	ArrayRemoveDead( guys )
	WaittillAnimDone( dropship )
}

void function ShowDropship( entity dropship )
{
	dropship.EndSignal( "OnDestroy" )
	wait 0.16
	dropship.Show()
}

void function spawnDroppodStalker( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys
	int difficultyLevel = FD_GetDifficultyLevel()

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
	{
		entity guy = CreateStalker( TEAM_IMC, spawnEvent.origin, < 0, 0, 0 > )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL )
		SetSpawnOption_AISettings( guy, "npc_stalker_fd" )
		DispatchSpawn( guy )
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		guy.AssaultSetFightRadius( 0 ) // makes them keep moving instead of stopping to shoot you.
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.STALKER ) )
		guys.append( guy )
	}

	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL: // easy and normal stalkers have no weapons
			foreach( npc in guys )
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
			foreach( npc in guys )
			{
				npc.TakeActiveWeapon()
				npc.GiveWeapon( "mp_weapon_epg", [] )
				npc.SetActiveWeaponByName( "mp_weapon_epg" )
			}
			break

		default:
			unreachable

	}

	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	foreach( npc in guys )
		thread FDStalkerThink( npc , fd_harvester.harvester )
	thread SquadNav_Thread( guys, spawnEvent.route )
}

void function spawnDroppodSpectreMortar( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
		entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys

	for ( int i = 0; i < 4; i++ )
	{
		entity guy = CreateSpectre( TEAM_IMC, spawnEvent.origin,< 0, 0, 0 > )
		SetSpawnOption_AISettings( guy, "npc_spectre_mortar" )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		DispatchSpawn( guy )
		spawnedNPCs.append(guy)
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.SPECTRE_MORTAR))
		AddMinimapForHumans(guy)
		guys.append( guy )
    }

	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
    ActivateFireteamDropPod( pod, guys )
	
	thread MortarSpectreSquadThink( guys, fd_harvester.harvester )
	
}

void function spawnGenericNPC( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPC( spawnEvent.npcClassName, TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	DispatchSpawn( npc )
}

void function spawnGenericNPCTitanwithSettings( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( spawnEvent.npcClassName, TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	if( spawnEvent.aiSettings == "npc_titan_atlas_tracker_fd_sniper" )
		SetTargetName( npc, "npc_titan_atlas_tracker" ) // required for client to create icons
	SetSpawnOption_AISettings( npc, spawnEvent.aiSettings )
	SetSpawnOption_Titanfall( npc )
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
}


void function SpawnIonTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb_boss_fd" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnScorchTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_ogre", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor_boss_fd" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnRoninTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_stryder", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings (npc, "npc_titan_stryder_leadwall_boss_fd" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnToneTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_boss_fd" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnLegionTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_ogre", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_titan_ogre_minigun_boss_fd" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnMonarchTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc,"npc_titan_atlas_vanguard_boss_fd" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function spawnNukeTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_ogre", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_titan_ogre_minigun_nuke" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	npc.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS )
	npc.AssaultSetFightRadius( 0 )
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
	thread NukeTitanThink( npc, fd_harvester.harvester )

}

void function spawnMortarTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_mortar" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread MortarTitanThink( npc, fd_harvester.harvester )
}

void function spawnSniperTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_stryder", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings( npc, "npc_titan_stryder_sniper_fd" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread SniperTitanThink( npc, fd_harvester.harvester )

}

void function SpawnToneSniperTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_fd_sniper" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	npc.AssaultSetFightRadius( 0 )
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread SniperTitanThink( npc, fd_harvester.harvester )
}

void function fd_spawnCloakDrone( SmokeEvent smokeEvent, SpawnEvent spawnEvent,FlowControlEvent flowControlEvent,SoundEvent soundEvent )
{
	entity npc = SpawnCloakDrone( TEAM_IMC, spawnEvent.origin, spawnEvent.angles, fd_harvester.harvester.GetOrigin() )
	spawnedNPCs.append( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) )
	AddMinimapForHumans( npc )
}

void function SpawnTick( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString( "ZiplineTable" ) )
	array<entity> guys

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
	{
		entity guy = CreateFragDrone( TEAM_IMC, spawnEvent.origin, < 0, 0, 0 > )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetSpawnOption_AISettings( guy, "npc_frag_drone_fd" )
		SetTeam( guy, TEAM_IMC )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE )
		DispatchSpawn( guy )
		AddMinimapForHumans( guy )
		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.TICK ) )
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		spawnedNPCs.append( guy )
		guy.AssaultSetFightRadius( expect int( guy.Dev_GetAISettingByKeyField( "LookDistDefault_Combat" ) ) ) // make the ticks target players very aggressively
		guys.append( guy )
	}
	
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	thread SquadNav_Thread( guys, spawnEvent.route )
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


void function PingMinimap( float x, float y, float duration, float spreadRadius, float ringRadius, int colorIndex )
{
	foreach( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FD_PingMinimap", x, y, duration, spreadRadius, ringRadius, colorIndex )
	}
}

void function waitUntilLessThanAmountAlive( int amount )
{	
	int deduct = 0
	foreach ( entity npc in spawnedNPCs )
	{
		if( !IsValid(npc) )
		{
			deduct++
			continue
		}
		if( IsValid( GetPetTitanOwner( npc ) ) )
		{
			deduct++
			continue
		}
		if( npc.GetTeam() == TEAM_MILITIA )
		{
			deduct++
			continue
		}
	}
	int aliveNPCs = spawnedNPCs.len() - deduct
	while( aliveNPCs > amount )
	{
		WaitFrame()
		deduct = 0
		foreach ( entity npc in spawnedNPCs )
		{
			if( !IsValid( npc ) )
			{
				deduct++
				continue
			}
			if( IsValid( GetPetTitanOwner( npc ) ) )
			{
				deduct++
				continue
			}
			if( npc.GetTeam() == TEAM_MILITIA )
			{
				deduct++
				continue
			}
		}
		aliveNPCs = spawnedNPCs.len() - deduct
		
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
	}
}

void function waitUntilLessThanAmountAliveWeighted( int amount, int humanWeight = 1, int reaperWeight = 3, int titanWeight = 5 )
{

	int aliveNPCsWeighted = 0;
	foreach( npc in spawnedNPCs )
	{	
		if( !IsValid( npc ) )
			continue

		if( IsValid( GetPetTitanOwner( npc ) ) )
			continue
		
		if( npc.GetTeam() == TEAM_MILITIA )
			continue
		
		if( npc.IsTitan() )
			aliveNPCsWeighted += titanWeight
		else if( npc.GetTargetName() == "reaper" )
			aliveNPCsWeighted += reaperWeight
		else
			aliveNPCsWeighted += humanWeight
	}
	while( aliveNPCsWeighted > amount )
	{
		WaitFrame()
			aliveNPCsWeighted = 0;
			foreach( npc in spawnedNPCs )
			{	
				if( !IsValid( npc ) )
					continue
				
				if( IsValid( GetPetTitanOwner( npc ) ) )
					continue
				
				if( npc.GetTeam() == TEAM_MILITIA )
					continue
				
				if( npc.IsTitan() )
					aliveNPCsWeighted += titanWeight
				else if( npc.GetTargetName() == "reaper" )
					aliveNPCsWeighted += reaperWeight
				else
					aliveNPCsWeighted += humanWeight
			}
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
	}
}

void function waitUntilLessThanAmountAlive_expensive( int amount )
{

	array<entity> npcs = GetNPCArray()
	int deduct = 0
	foreach ( entity npc in npcs )
	{
		if( IsValid( GetPetTitanOwner( npc ) ) )
		{
			deduct++
			continue
		}
		if( npc.GetTeam() == TEAM_MILITIA )
		{
			deduct++
			continue
		}
	}
	foreach( entity ent in GetEntArrayByClass_Expensive( "npc_drone" ) )
	{
		if ( IsAlive( ent ) )
			ent.Die()
	}
	
	//Kill all unadressed Ticks that was left behind in the wave by Reapers
	foreach (entity tick in GetEntArrayByClass_Expensive( "npc_frag_drone" ) )
	{
		if ( IsAlive( tick ) )
			tick.Die()
	}
		
	int aliveTitans = npcs.len() - deduct
	while( aliveTitans > amount )
	{
		WaitFrame()
		npcs = GetNPCArray()
		deduct = 0
		foreach( entity npc in npcs )
		{
			if( IsValid( GetPetTitanOwner( npc ) ) )
			{
				deduct++
				continue
			}
			if( npc.GetTeam() == TEAM_MILITIA )
			{
				deduct++
				continue
			}
		}
		aliveTitans = GetNPCArray().len() - deduct
		if( !IsHarvesterAlive( fd_harvester.harvester ) )
			return
	}
}

void function AddMinimapForTitans( entity titan )
{
	titan.Minimap_SetAlignUpright( true )
	titan.Minimap_AlwaysShow( TEAM_IMC, null )
	titan.Minimap_AlwaysShow( TEAM_MILITIA, null )
	titan.Minimap_SetHeightTracking( true )
	titan.Minimap_SetCustomState( eMinimapObject_npc_titan.AT_BOUNTY_BOSS )
}

// including drones
void function AddMinimapForHumans( entity human )
{
	human.Minimap_SetAlignUpright( true )
	human.Minimap_AlwaysShow( TEAM_IMC, null )
	human.Minimap_AlwaysShow( TEAM_MILITIA, null )
	human.Minimap_SetHeightTracking( true )
	human.Minimap_SetCustomState( eMinimapObject_npc.AI_TDM_AI )
}



void function WinWave()
{
	foreach( WaveEvent e in waveEvents[GetGlobalNetInt( "FD_currentWave" )] )
	{
		e.timesExecuted = e.executeOnThisCall	
	}
}