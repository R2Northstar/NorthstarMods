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
global function CreateWaitUntilAliveWeightedEvent //Ngl but this is confusing af to "guess" how the fuck the weights works, say 15 means 3 Titans, but what if i want only the titans to count? i can't because 15 infantry units may get in the way, this a bad way to control the spawning flow -Zanieon
global function CreateWaitForAllTitansDeadEvent
global function CreateWaitForLessThanTypeIDEvent
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
global function CreateGruntDropshipEvent //This one always requires testing after usage because sometimes Grunts wont zipline to the ground, also good to explicitly set up their route, or they may do some long pathing
global function executeWave
global function restetWaveEvents
global function WinWave
global function SpawnDrozFD
global function SpawnDavisFD
global function SpawnFDHeavyTurret
global function SpawnLFMapTitan

global struct SmokeEvent{
	vector position
	float lifetime
}

global struct SpawnEvent{
	vector origin = < 0, 0, 0 >
	vector angles = < 0, 0, 0 >
	string route			//defines route taken by the ai
	int skippedRouteNodes 	//defines how many route nodes will be skipped
	int spawnType			//Just used for Wave Info but can be used for spawn too should contain aid of spawned enemys
	int spawnAmount			//Just used for Wave Info but can be used for spawn too should contain amound of spawned enemys
	string npcClassName
	string aiSettings
	string entityGlobalKey
	bool shouldLoop = false
	int titanType = 0
	float spawnradius = 0.0
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
	ArcTitanAlt,
	ComboNukeMortar,
	ComboArcMortar,
	ComboArcNuke,
	ComboNukeCloak,
	ComboNukeTrain
}

global enum FD_TitanType
{
	TITAN_COMMON,
	TITAN_ELITE
}

struct {
	vector helperTitanSpawnPos
	vector helperTitanAngles
}file

global table< string, entity > GlobalEventEntitys
global array< array<WaveEvent> > waveEvents

global string Cvar_gruntweapons
global array<string> FD_GruntWeapons
global string Cvar_gruntgrenade
global string Cvar_spectreweapons
global array<string> FD_SpectreWeapons

const FD_TITAN_AOE_REACTTIME = 3 //This is in seconds

void function executeWave()
{	
	int currentWave = GetGlobalNetInt( "FD_currentWave" ) + 1
	int enemyCount
	print( "Wave Start: " + currentWave )
	thread runEvents( 0 )
	
	//Wait for all events to execute
	while( IsHarvesterAlive( fd_harvester.harvester ) && !allEventsExecuted( GetGlobalNetInt( "FD_currentWave" ) ) )
		WaitFrame()
	print( "All events executed, waiting for enemies completion" )
	
	//Do a secondary wait for alive enemies after all events executed
	while( IsHarvesterAlive( fd_harvester.harvester ) && GetGlobalNetInt( "FD_AICount_Current" ) > 0 )
	{
		if( enemyCount != GetGlobalNetInt( "FD_AICount_Current" ) )
		{
			enemyCount = GetGlobalNetInt( "FD_AICount_Current" )
			switch( enemyCount )
			{
				case 10:
				PlayFactionDialogueToTeam( "fd_waveCleanup" , TEAM_MILITIA )
				break
				
				case 5:
				PlayFactionDialogueToTeam( "fd_waveCleanup5" , TEAM_MILITIA )
				break
				
				case 4:
				PlayFactionDialogueToTeam( "fd_waveCleanup4" , TEAM_MILITIA )
				break
				
				case 3:
				PlayFactionDialogueToTeam( "fd_waveCleanup3" , TEAM_MILITIA )
				break
				
				case 2:
				PlayFactionDialogueToTeam( "fd_waveCleanup2" , TEAM_MILITIA )
				break
				
				case 1:
				PlayFactionDialogueToTeam( "fd_waveCleanup1" , TEAM_MILITIA )
				break
			}
		}
		
		if ( GetGlobalNetInt( "FD_AICount_Current" ) >= 10 )
		{
			//Kill Cloak Drones beforehand when a wave is about to end to avoid softlocking
			array<entity> droneArray = GetNPCCloakedDrones()
			foreach( entity cloakedDrone in droneArray )
			{
				if( IsValid( cloakedDrone ) && IsAlive( cloakedDrone ) )
				{
					cloakedDrone.Show()
					cloakedDrone.Solid()
					cloakedDrone.Die()
				}
			}
		}
		
		WaitFrame()
	}
	print( "Enemy pool reached 0, doing a full npc scan" )
	
	//Lastly, ensure everyone is indeed dead to proceed
	waitUntilLessThanAmountAlive( 0 )
	
	//Kill all unwanted Ticks from Reapers
	print( "Purging all remaining Ticks deployed by Reapers" )
	KillLooseTicksFromReapers()
}

void function KillLooseTicksFromReapers()
{
	foreach (entity tick in GetEntArrayByClass_Expensive( "npc_frag_drone" ) )
	{
		if ( IsAlive( tick ) )
			tick.Destroy()
	}
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
			return

		if( !IsHarvesterAlive(fd_harvester.harvester ) )
			return

		if( currentEvent.shouldThread )
			thread currentEvent.eventFunction( currentEvent.smokeEvent, currentEvent.spawnEvent, currentEvent.flowControlEvent, currentEvent.soundEvent )

		else
			currentEvent.eventFunction( currentEvent.smokeEvent, currentEvent.spawnEvent, currentEvent.flowControlEvent, currentEvent.soundEvent )
			
		if( currentEvent.nextEventIndex == 0 )
		{
			print( "Event Index 0 reached, finishing wave" )
			return
		}
		currentEvent = waveEvents[GetGlobalNetInt( "FD_currentWave" )][currentEvent.nextEventIndex]
	}
}

void function restetWaveEvents()
{
	foreach( WaveEvent event in waveEvents[GetGlobalNetInt( "FD_currentWave" )] )
	{
		event.timesExecuted = 0
	}
}

/*
███████╗██╗   ██╗███████╗███╗   ██╗████████╗     ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ████████╗ ██████╗ ██████╗ ███████╗
██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝    ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝
█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║       ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║   ██║   ██║   ██║██████╔╝███████╗
██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║       ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║   ██║   ██║   ██║██╔══██╗╚════██║
███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║       ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║   ██║   ╚██████╔╝██║  ██║███████║
╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝
*/

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

WaveEvent function CreateArcTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateSuperSpectreEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateSuperSpectreEventWithMinion( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateDroppodGruntEvent( vector origin, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateDroppodStalkerEvent( vector origin, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateDroppodSpectreMortarEvent( vector origin, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
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

WaveEvent function CreateWaitForAllTitansDeadEvent( int amount, int nextEventIndex, int executeOnThisCall = 1 )
{
	WaveEvent event
	event.eventFunction = waitForDeathOfTitansEvent
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = false
	event.flowControlEvent.waitAmount = amount
	return event
}

WaveEvent function CreateWaitForLessThanTypeIDEvent(int aiTypeId,int amount,int nextEventIndex,int executeOnThisCall = 1 )
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

WaveEvent function CreateGenericSpawnEvent( string npcClassName, vector origin, vector angles, string route, int spawnType, int spawnAmount, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateGenericTitanSpawnWithAiSettingsEvent( string npcClassName, string aiSettings, vector origin, vector angles, string route, int spawnType, int spawnAmount, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateNukeTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateMortarTitanEvent( vector origin, vector angles, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
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

WaveEvent function CreateDroppodTickEvent( vector origin, int amount, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
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
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateNorthstarSniperTitanEvent( vector origin, vector angles, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateToneSniperTitanEvent( vector origin, vector angles, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}


WaveEvent function CreateIonTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateScorchTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateRoninTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateToneTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateLegionTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateMonarchTitanEvent( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_COMMON, float spawnradius = 0.0 )
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
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	return event
}

WaveEvent function CreateSpawnDroneEvent(vector origin,vector angles,string route,int nextEventIndex, bool shouldLoop = true, int executeOnThisCall = 1, string entityGlobalKey="" , float spawnradius = 0.0)
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
	event.spawnEvent.spawnradius = spawnradius
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
		
		case FD_IncomingWarnings.ComboNukeMortar:
		event.soundEvent.soundEventName = "fd_waveComboNukeMortar"
		break
		
		case FD_IncomingWarnings.ComboArcMortar:
		event.soundEvent.soundEventName = "fd_waveComboArcMortar"
		break
		
		case FD_IncomingWarnings.ComboArcNuke:
		event.soundEvent.soundEventName = "fd_waveComboArcNuke"
		break
		
		case FD_IncomingWarnings.ComboNukeCloak:
		event.soundEvent.soundEventName = "fd_waveComboNukeCloak"
		break
		
		case FD_IncomingWarnings.ComboNukeTrain:
		event.soundEvent.soundEventName = "fd_waveComboNukeTrain"
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
	event.spawnEvent.angles = angles
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	return event
}

/*
███████╗██╗   ██╗███████╗███╗   ██╗████████╗    ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝    ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║       █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║       ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║       ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝       ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
*/

//Hack by using one of the existing struct vars, hopefully nothing will break
void function BlockFurtherTitanfalls( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	if ( titanfallblockAllowed )
	{
		if ( flowControlEvent.waitAmount == 1 )
		{
			print( "Applying Titanfall Block Event" )
			PlayerEarnMeter_SetEnabled( false )
			thread ShowTitanfallBlockHint()
			foreach( entity player in GetPlayerArray() )
			{
				PlayerEarnMeter_Reset( player )
				ClearTitanAvailable( player )
				#if SERVER
				NSSendAnnouncementMessageToPlayer( player, "Titanfall Block", "Titans cannot be summoned anymore!", < 255, 255, 255 >, 150, 0 )
				#endif
			}
		}
		else
		{
			print( "Removing Titanfall Block Event" )
			PlayerEarnMeter_SetEnabled( true )
		}
	}
}

void function ShowTitanfallBlockHint()
{
	#if SERVER
	wait 10
	foreach( entity player in GetPlayerArray() )
		NSSendLargeMessageToPlayer( player, "Titanfall Block", "Further Titans cannot be summoned until the end of the wave, avoid losing your current Titan!", 60, "rui/callsigns/callsign_94_col" )
	#endif
}

void function PlayWarning( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	if ( !titanfallblockAllowed && soundEvent.soundEventName == "fd_waveNoTitanDrops" || !elitesAllowed && soundEvent.soundEventName == "fd_waveTypeEliteTitan" )
		return
	else
	{
		#if SERVER
		if( soundEvent.soundEventName == "fd_waveTypeEliteTitan" )
		{
			foreach( entity player in GetPlayerArray() )
				NSSendLargeMessageToPlayer( player, "Elite Titan", "Always coated white. Huge health, huge shield, greater aiming, moves faster and can use Core. Drops battery on death.", 60, "rui/callsigns/callsign_17_col" )
		}
		#endif
		PlayFactionDialogueToTeam( soundEvent.soundEventName, TEAM_MILITIA )
	}
}

void function spawnSmoke( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	vector skypos = GetSkyCeiling( smokeEvent.position )
	vector groundpos = OriginToGround( skypos )
	
	printt( "Spawning Smoke at: " + smokeEvent.position )
	SmokescreenStruct smokescreen
	smokescreen.smokescreenFX = $"P_smokescreen_FD"
	smokescreen.isElectric = false
	smokescreen.origin = groundpos
	smokescreen.angles = < 0, 0, 0 >
	smokescreen.fxXYRadius = 160
	smokescreen.fxZRadius = 128
	smokescreen.lifetime = smokeEvent.lifetime
	smokescreen.deploySound1p = "SmokeWall_Activate"
	smokescreen.deploySound3p = "SmokeWall_Activate"
	smokescreen.stopSound1p = "SmokeWall_Stop"
	smokescreen.stopSound3p = "SmokeWall_Stop"
	
	float fxOffset = 200.0
	float fxHeightOffset = 148.0
	
	smokescreen.fxOffsets = [ < -fxOffset, 0.0, 20.0>, <0.0, fxOffset, 20.0>, <0.0, -fxOffset, 20.0>, <0.0, 0.0, fxHeightOffset>, < -fxOffset, 0.0, fxHeightOffset> ]
	
	EmitSoundAtPosition( TEAM_UNASSIGNED, groundpos, "SmokeWall_Launch" )
	
	entity smokenade = CreateEntity( "prop_script" )
	entity mover = CreateOwnedScriptMover( smokenade )
	smokenade.SetValueForModelKey( $"models/weapons/bullets/projectile_rocket_large.mdl" )
	smokenade.kv.spawnflags = 0
	smokenade.kv.solid = 0
	smokenade.kv.fadescale = 0
	smokenade.kv.renderamt = 255
	smokenade.kv.rendercolor = "255 255 255"
	smokenade.SetParent( mover, "", false, 0 )
	mover.SetOrigin( skypos )
	mover.SetAngles( < 90, 0, 0 > )
	DispatchSpawn( smokenade )
	PlayLoopFXOnEntity( $"weapon_kraber_projectile", smokenade, "exhaust" )
	PlayLoopFXOnEntity( $"Rocket_Smoke_Large", smokenade, "exhaust" )
	mover.NonPhysicsMoveTo( groundpos, 1.0, 0, 0 )
	wait 1
	Smokescreen(smokescreen)
	wait 0.2
	smokenade.Destroy()
	mover.Destroy()
}

void function spawnDrones( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Drones at: " + spawnEvent.origin )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString() )

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
    {
		vector offsets = Vector( RandomFloatRange( -40, 40 ), RandomFloatRange( -40, 40 ), RandomFloatRange( -40, 40 ) )
		entity guy = CreateGenericDrone( TEAM_IMC, spawnEvent.origin + offsets, spawnEvent.angles )
		SetSpawnOption_AISettings( guy, "npc_drone_plasma_fd" )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		DispatchSpawn( guy )
		guy.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )
		guy.EnableNPCFlag( NPC_STAY_CLOSE_TO_SQUAD )
		guy.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS | NPCMF_PREFER_SPRINT )
		SetSquad( guy, squadName )
		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.DRONE ) )
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		thread droneNav_thread(guy, spawnEvent.route, 0, 64, spawnEvent.shouldLoop )
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
		WaitFrame()
	}
}

void function waitForLessThanAliveTyped( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{	
	while( IsHarvesterAlive( fd_harvester.harvester ) )
	{
		int amount
		foreach( entity npc in spawnedNPCs )
		{
			if( FD_GetAITypeID_ByString( npc.GetTargetName() ) == flowControlEvent.waitEntityType ) //TODO getaitypeid_bystring does not contain all possible strings
				amount++
		}
		if( amount <= flowControlEvent.waitAmount )
			break
		WaitFrame()
	}
}

void function spawnArcTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Arc Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateArcTitan( TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_arc" )
	spawnedNPCs.append( npc )
	npc.kv.reactChance = 60
	DispatchSpawn( npc )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER | NPC_ALLOW_PATROL )
	npc.SetEnemyChangeCallback( OnFDHarvesterTargeted )
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	if( spawnEvent.entityGlobalKey != "" )
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

void function waitForDeathOfTitansEvent( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	waitForDeathOfTitans( flowControlEvent.waitAmount )
}

void function waitUntilLessThanAmountAliveEventWeighted( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	waitUntilLessThanAmountAliveWeighted( flowControlEvent.waitAmount )
}

void function spawnSuperSpectre( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}
	printt( "Spawning Common Reaper at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5.7 )
	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )
	wait 1.7
	TryAnnounceTitanfallWarningToEnemyTeam( TEAM_IMC, spawnorigin )
	wait 3.0

	entity npc = CreateSuperSpectre( TEAM_IMC, spawnorigin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_super_spectre_fd" )
	spawnedNPCs.append( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	DispatchSpawn( npc )
	npc.SetAllowSpecialJump( true )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) )
	AddMinimapForHumans( npc )
	thread SuperSpectre_WarpFall( npc )
	npc.WaitSignal( "WarpfallComplete" )
	//npc.SetCapabilityFlag( bits_CAP_MOVE_TRAVERSE, true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function spawnSuperSpectreWithMinion( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}
	printt( "Spawning Tick-deployer Reaper at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5.7 )
	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )
	wait 1.7
	TryAnnounceTitanfallWarningToEnemyTeam( TEAM_IMC, spawnorigin )
	wait 3.0

	entity npc = CreateSuperSpectre( TEAM_IMC, spawnorigin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_super_spectre_fd" )
	spawnedNPCs.append( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	DispatchSpawn( npc )
	npc.SetAllowSpecialJump( true )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) )
	AddMinimapForHumans( npc )
	thread SuperSpectre_WarpFall( npc )
	npc.WaitSignal( "WarpfallComplete" )
	//npc.SetCapabilityFlag( bits_CAP_MOVE_TRAVERSE, true )
	thread ReaperMinionLauncherThink( npc )

}

void function spawnDroppodGrunts( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Grunt Drop Pod at: " + spawnEvent.origin )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString() )
	string at_weapon = GetConVarString( "ns_fd_grunt_at_weapon" )
	array<entity> guys

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
    {
		entity guy = CreateSoldier( TEAM_IMC, spawnEvent.origin, < 0, 0, 0 > )
		
		// should this grunt be a shield captain?
		if (i < GetCurrentPlaylistVarInt( "fd_grunt_shield_captains", 0 ) || i == 1 && GetMapName().find( "mp_lf_" ) != null )
		{
			if ( GetConVarBool( "ns_fd_allow_true_shield_captains" ) )
				SetSpawnOption_AISettings( guy, "npc_soldier_shield_captain" )
			else
				thread ActivatePersonalShield( guy )
		}
		
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey+ i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		if ( FD_GruntWeapons.len() > 0 )
		{
			string baseweapon = FD_GruntWeapons[ RandomInt( FD_GruntWeapons.len() ) ]
			SetSpawnOption_Weapon( guy, baseweapon )
			guy.kv.grenadeWeaponName = Cvar_gruntgrenade
		}
		DispatchSpawn( guy )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL )
		guy.SetEfficientMode( true )
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )

		// should this grunt have an anti titan weapon instead of its normal weapon?
		if ( i < GetCurrentPlaylistVarInt( "fd_grunt_at_weapon_users", 0 ) || GetMapName().find( "mp_lf_" ) != null )
			guy.GiveWeapon( at_weapon )

		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.GRUNT ) ) // do shield captains get their own target name in vanilla?
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		guys.append( guy )
	}
	
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	foreach( npc in guys )
	{
		npc.SetEfficientMode( false )
		thread singleNav_thread( npc, spawnEvent.route )
	}
}

//This function is based off the entire function chain called by AiGameModes_SpawnDropShip(), that function uses table data for modularization and while it
//works just fine if we simply use it here, there's no viable way to add the Grunts into the enemy count pool, plus that function also only works at
//specific nodes found in the maps, that is not needed here, full control over the coordinates where the dropship will drop grunts is better.
void function spawnGruntDropship( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{ 
	printt( "Spawning Grunt Dropship at: " + spawnEvent.origin )
	string squadName = MakeSquadName( TEAM_IMC, UniqueString() )
	string at_weapon = GetConVarString( "ns_fd_grunt_at_weapon" )
	
	vector origin 		= spawnEvent.origin
	origin.z 		   += 640 //Expected to people make coordinates in the ground so we add this up for the hover height
	float yaw 			= spawnEvent.angles.y
	int health 			= 7800
	
	CallinData drop
	InitCallinData( drop )
	SetCallinStyle( drop, eDropStyle.ZIPLINE_NPC )
	drop.dist 			= 1800
	drop.origin 		= origin
	drop.yaw 			= yaw
	drop.team 			= TEAM_IMC
	drop.squadname 		= squadName
	
	FlightPath flightPath
	
	flightPath = GetAnalysisForModel( DROPSHIP_MODEL, DROPSHIP_DROP_ANIM )
	entity ref = CreateScriptRef()
	ref.SetOrigin( origin )
	ref.SetAngles( < 0, yaw, 0 > )

	Assert( IsNewThread(), "Must be threaded off" )

	DropTable dropTable
	dropTable.nodes = DropshipFindDropNodes( flightPath, origin, yaw, "both", true, IsLegalFlightPath_OverTime )
	dropTable.valid = true
	
	asset model = GetFlightPathModel( "fp_crow_model" )
	waitthread WarpinEffect( model, DROPSHIP_DROP_ANIM, ref.GetOrigin(), ref.GetAngles() )
	entity dropship = CreateDropship( TEAM_IMC, ref.GetOrigin(), ref.GetAngles() )
	SetSpawnOption_SquadName( dropship, squadName )
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
		{
			if ( GetConVarBool( "ns_fd_allow_true_shield_captains" ) )
				SetSpawnOption_AISettings( guy, "npc_soldier_shield_captain" )
			else
				thread ActivatePersonalShield( guy )
		}

		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey+ i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		if ( FD_GruntWeapons.len() > 0 )
		{
			string baseweapon = FD_GruntWeapons[ RandomInt( FD_GruntWeapons.len() ) ]
			SetSpawnOption_Weapon( guy, baseweapon )
			guy.kv.grenadeWeaponName = Cvar_gruntgrenade
		}
		DispatchSpawn( guy )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL )
		SetSquad( guy, squadName )
		
		if ( i < GetCurrentPlaylistVarInt( "fd_grunt_at_weapon_users", 0 ) )
			guy.GiveWeapon( at_weapon )
		
		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.GRUNT ) )
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		guys.append( guy )
		
		table Table = CreateDropshipAnimTable( dropship, "both", i )
		thread GuyDeploysOffShip( guy, Table )
	}
	
	EmitSoundOnEntity( dropship, dropshipSound )
	thread PlayAnimTeleport( dropship, DROPSHIP_DROP_ANIM, ref, 0 )
	ArrayRemoveDead( guys )
	wait 12
	foreach( guy in guys )
	{
		if ( IsAlive( guy ) )
		{
			if ( guy.GetParent() )
				guy.Die() //Kill grunts that didn't manage to drop off the ship
			else
				thread singleNav_thread( guy, spawnEvent.route )
		}
	}
	WaittillAnimDone( dropship )
}

void function spawnDroppodStalker( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Stalker Drop Pod at: " + spawnEvent.origin )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString() )
	array<entity> guys

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
	{
		entity guy = CreateStalker( TEAM_IMC, spawnEvent.origin, < 0, 0, 0 > )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		SetSpawnOption_AISettings( guy, "npc_stalker_fd" )
		DispatchSpawn( guy )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL )
		guy.SetEfficientMode( true )
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
				npc.EnableNPCFlag( NPC_DISABLE_SENSING | NPC_IGNORE_ALL )
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
	
	if( GetMapName().find( "mp_lf_" ) != null )
	{
		foreach( npc in guys )
		{
			npc.TakeActiveWeapon()
			npc.GiveWeapon( "mp_weapon_epg", [] )
			npc.SetActiveWeaponByName( "mp_weapon_epg" )
			npc.DisableNPCFlag( NPC_DISABLE_SENSING | NPC_IGNORE_ALL )
		}
	}

	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	foreach( npc in guys )
	{
		npc.SetEfficientMode( false )
		thread FDStalkerThink( npc , fd_harvester.harvester )
		thread singleNav_thread( npc, spawnEvent.route )
	}
}

void function spawnDroppodSpectreMortar( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Mortar Spectre Drop Pod at: " + spawnEvent.origin )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
		entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString() )
	array<entity> guys

	for ( int i = 0; i < 4; i++ )
	{
		entity guy = CreateSpectre( TEAM_IMC, spawnEvent.origin,< 0, 0, 0 > )
		SetSpawnOption_AISettings( guy, "npc_spectre_mortar" )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		if ( FD_SpectreWeapons.len() > 0 )
		{
			string baseweapon = FD_SpectreWeapons[ RandomInt( FD_SpectreWeapons.len() ) ]
			SetSpawnOption_Weapon( guy, baseweapon )
		}
		guy.kv.reactChance = 100
		DispatchSpawn( guy )
		guy.AssaultSetFightRadius( 0 )
		guy.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER | NPC_ALLOW_PATROL )
		guy.EnableNPCFlag( NPC_NO_WEAPON_DROP )
		spawnedNPCs.append(guy)
		guy.SetEfficientMode( true )
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.SPECTRE_MORTAR))
		AddMinimapForHumans(guy)
		guys.append( guy )
    }

	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
    ActivateFireteamDropPod( pod, guys )
	
	foreach( npc in guys )
	{
		npc.SetEfficientMode( false )
		thread NPCStuckTracker( npc )
	}
	
	thread MortarSpectreSquadThink( guys, fd_harvester.harvester )
}

void function spawnGenericNPC( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Generic NPC at: ", spawnEvent.origin )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPC( spawnEvent.npcClassName, TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	DispatchSpawn( npc )
}

void function spawnGenericNPCTitanwithSettings( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Generic NPC Titan at: " + spawnEvent.origin )
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
	printt( "Spawning Ion Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb_boss_fd_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb" )
		else
			SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb_boss_fd" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetEnemyChangeCallback( OnFDHarvesterTargeted )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
		npc.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	}
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
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
	printt( "Spawning Scorch Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_ogre", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor_boss_fd_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		/* I don't wanna know if this is vanilla behavior or not, i stopped accepting Scorches should aimbot the moment i got killed in the frame the respawn
		dropship made me and another guy vulnerable and this motherfucker simply decided to snipe us midair, not even Northstars does this all the time but
		this son of a bitch does whenever he has the chance, so now i made sure hes a drunk guy who cant handle shit even on his face */
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor" )
		else
			SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor_boss_fd" )
		npc.kv.AccuracyMultiplier = 0.5
		npc.kv.WeaponProficiency = eWeaponProficiency.AVERAGE
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetEnemyChangeCallback( OnFDHarvesterTargeted )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
		npc.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	}
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
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
	printt( "Spawning Ronin Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_stryder", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings (npc, "npc_titan_stryder_leadwall_boss_fd_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings (npc, "npc_titan_stryder_leadwall" )
		else
			SetSpawnOption_AISettings (npc, "npc_titan_stryder_leadwall_boss_fd" )
		
		npc.kv.AccuracyMultiplier = 0.7
		npc.kv.WeaponProficiency = eWeaponProficiency.AVERAGE
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
		npc.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	}
	else
		npc.SetEnemyChangeCallback( OnFDHarvesterTargeted )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnToneTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Tone Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_boss_fd" )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_boss_fd_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker" )
		else
			SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_boss_fd" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetEnemyChangeCallback( OnFDHarvesterTargeted )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
		npc.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	}
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
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
	printt( "Spawning Legion Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_ogre", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_ogre_minigun_boss_fd_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc, "npc_titan_ogre_minigun" )
		else
			SetSpawnOption_AISettings( npc, "npc_titan_ogre_minigun_boss_fd" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetEnemyChangeCallback( OnFDHarvesterTargeted )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
		npc.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	}
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
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
	printt( "Spawning Monarch Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc,"npc_titan_atlas_vanguard_boss_fd_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc,"npc_titan_atlas_vanguard" )
		else
			SetSpawnOption_AISettings( npc,"npc_titan_atlas_vanguard_boss_fd" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetEnemyChangeCallback( OnFDHarvesterTargeted )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
		npc.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	}
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
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
	printt( "Spawning Nuke Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_ogre", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_titan_ogre_minigun_nuke" )
	SetSpawnOption_Melee( npc, "null" )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS | NPCMF_WALK_NONCOMBAT | NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_DISABLE_DANGEROUS_AREA_DISPLACEMENT )
	npc.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_FOLLOW_SAFE_PATHS )
	npc.DisableNPCFlag( NPC_DIRECTIONAL_MELEE )
	npc.AssaultSetFightRadius( 0 )
	SlowEnemyMovementBasedOnDifficulty( npc )
	npc.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2 | bits_CAP_SYNCED_MELEE_ATTACK , false )
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
	printt( "Spawning Mortar Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_mortar" )
	SetSpawnOption_Titanfall( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetSkin( 2 )
	npc.SetCamo( 1 )
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
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
	printt( "Spawning Northstar Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_stryder", TEAM_IMC, spawnEvent.origin, spawnEvent.angles)
	SetSpawnOption_Titanfall( npc )
	npc.kv.AccuracyMultiplier = 2
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_stryder_sniper_boss_fd_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		SetSpawnOption_AISettings( npc, "npc_titan_stryder_sniper_fd" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	npc.AssaultSetFightRadius( 0 )
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	thread SniperTitanThink( npc, fd_harvester.harvester )

}

void function SpawnToneSniperTitan( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Sniper Tone Titan at: " + spawnEvent.origin )
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.AccuracyMultiplier = 2
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_fd_sniper_elite" )
		SetTitanAsElite( npc )
	}
	else
	{
		SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_fd_sniper" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )
	if ( spawnEvent.titanType == 0 )
	{
		npc.SetSkin( 8 )
		npc.SetCamo( -1 )
	}
	npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
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
	printt( "Spawning Cloak Drone at: " + spawnEvent.origin )
	entity npc = SpawnCloakDrone( TEAM_IMC, spawnEvent.origin, spawnEvent.angles, fd_harvester.harvester.GetOrigin() )
	spawnedNPCs.append( npc )
	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) )
	AddMinimapForHumans( npc )
}

void function SpawnTick( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Tick Drop Pod at: " + spawnEvent.origin )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString() )
	array<entity> guys

	for ( int i = 0; i < spawnEvent.spawnAmount; i++ )
	{
		entity guy = CreateFragDrone( TEAM_IMC, spawnEvent.origin, < 0, 0, 0 > )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetSpawnOption_AISettings( guy, "npc_frag_drone_fd" )
		SetSpawnOption_Alert( guy )
		SetTeam( guy, TEAM_IMC )
		DispatchSpawn( guy )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE )
		if( GetConVarBool( "ns_fd_differentiate_ticks" ) )
			guy.SetModel( $"models/robots/drone_frag/drone_frag.mdl" )
		guy.SetEfficientMode( true )
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
	foreach( guy in guys )
	{
		if( IsValid( guy ) )
		{
			guy.Anim_Stop() //Intentionally cancel the Drop Pod exiting animation for Ticks because it doesnt work for them
			guy.SetEfficientMode( false )
			thread singleNav_thread( guy, spawnEvent.route )
		}
	}
}


/*
███████╗██╗   ██╗███████╗███╗   ██╗████████╗    ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝    ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║       ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║       ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║       ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝
*/

void function PingMinimap( float x, float y, float duration, float spreadRadius, float ringRadius, int colorIndex )
{
	foreach( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_FD_PingMinimap", x, y, duration, spreadRadius, ringRadius, colorIndex )
		EmitSoundOnEntityOnlyToPlayer( player, player, "coop_minimap_ping" )
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

void function waitForDeathOfTitans( int amount )
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
		if( !npc.IsTitan() )
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
			if( !npc.IsTitan() )
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

void function SlowEnemyMovementBasedOnDifficulty( entity npc )
{
	//This is not exact vanilla behavior i think, but enemies definetely moves slower on Frontier Defense than player autotitans
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL:
			npc.SetNPCMoveSpeedScale( 0.75 )
			break
		case eFDDifficultyLevel.HARD:
		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:
			npc.SetNPCMoveSpeedScale( 0.5 )
			break
	}
}

void function SetTitanAsElite( entity npc )
{
	if( GetGameState() != eGameState.Playing || !IsHarvesterAlive( fd_harvester.harvester ) )
		return
	
	if ( npc.IsTitan() && elitesAllowed )
	{
		thread MonitorEliteTitanCore( npc )
		SetSpawnOption_NPCTitan( npc, TITAN_MERC )
		SetSpawnOption_TitanSoulPassive1( npc, "pas_enhanced_titan_ai" )
		npc.kv.disable_vdu = 1
		npc.kv.skip_boss_intro = 1
		npc.kv.AccuracyMultiplier = 5
		npc.kv.reactChance = 100
		npc.kv.WeaponProficiency = eWeaponProficiency.PERFECT
	}
}

void function MonitorEliteTitanCore( entity npc )
{
	wait 6
	
	if( GetGameState() != eGameState.Playing || !IsHarvesterAlive( fd_harvester.harvester ) )
		return
	
	AddCreditToTitanCoreBuilder( npc, 1.0 )
	GiveOffhandElectricSmoke( npc )
	entity soul = npc.GetTitanSoul()
	if ( IsValid( soul ) )
		SetCoreCharged( soul )
}

void function Drop_Spawnpoint( vector origin, int team, float impactTime )
{
	array<entity> targetEffects = []
	vector surfaceNormal = < 0, 0, 1 >

	int index = GetParticleSystemIndex( $"P_ar_titan_droppoint" )

	entity effectEnemy = StartParticleEffectInWorld_ReturnEntity( index, origin, surfaceNormal )
	SetTeam( effectEnemy, team )
	EffectSetControlPointVector( effectEnemy, 1, < 255, 64, 16 > )
	effectEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	targetEffects.append( effectEnemy )
	
	wait impactTime

	foreach( entity targetEffect in targetEffects )
	{
		if ( IsValid( targetEffect ) )
			EffectStop( targetEffect )
	}
}

void function OnFDHarvesterTargeted( entity titan )
{
	entity enemy = titan.GetEnemy()
	if ( enemy == fd_harvester.harvester )
	{
		titan.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2 | bits_CAP_SYNCED_MELEE_ATTACK, false )
		titan.DisableNPCFlag( NPC_DIRECTIONAL_MELEE )
	}
	else
	{
		titan.EnableNPCFlag( NPC_DIRECTIONAL_MELEE )
		titan.SetCapabilityFlag( bits_CAP_INNATE_MELEE_ATTACK1 | bits_CAP_INNATE_MELEE_ATTACK2 | bits_CAP_SYNCED_MELEE_ATTACK, true )
	}
}

vector function GetSkyCeiling( vector point )
{
	vector skyOrigin = Vector( point.x, point.y, MAX_WORLD_COORD )
	vector traceFromPos = point

	while ( true )
	{
		TraceResults traceResult = TraceLine( traceFromPos, skyOrigin, null, (TRACE_MASK_SHOT), TRACE_COLLISION_GROUP_NONE )

		if ( traceResult.hitSky )
		{
			skyOrigin = traceResult.endPos
			skyOrigin.z -= 1
			break
		}

		traceFromPos = traceResult.endPos
		traceFromPos.z += 1
	}

	return skyOrigin
}

void function WinWave()
{
	foreach( WaveEvent e in waveEvents[GetGlobalNetInt( "FD_currentWave" )] )
	{
		e.timesExecuted = e.executeOnThisCall
	}
}

/*
███████╗██╗  ██╗████████╗██████╗  █████╗      ██████╗ ██████╗ ███╗   ██╗████████╗███████╗███╗   ██╗████████╗
██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗██╔══██╗    ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝
█████╗   ╚███╔╝    ██║   ██████╔╝███████║    ██║     ██║   ██║██╔██╗ ██║   ██║   █████╗  ██╔██╗ ██║   ██║   
██╔══╝   ██╔██╗    ██║   ██╔══██╗██╔══██║    ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██║╚██╗██║   ██║   
███████╗██╔╝ ██╗   ██║   ██║  ██║██║  ██║    ╚██████╗╚██████╔╝██║ ╚████║   ██║   ███████╗██║ ╚████║   ██║   
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   
*/

void function SpawnDrozFD( vector spawnpos, vector angles )
{
	entity Droz = CreateEntity( "npc_pilot_elite" )
	SetTargetName( Droz, "#NPC_DROZ_NAME" )
	Droz.SetTitle( "#NPC_DROZ_NAME" )
	Droz.SetOrigin( spawnpos )
	Droz.SetAngles( angles )
	SetSpawnOption_AISettings( Droz, "npc_pilot_elite" )
	SetSpawnOption_NotAlert( Droz )
	Droz.kv.grenadeWeaponName = "mp_weapon_grenade_emp"
	Droz.kv.physdamagescale = 1.0
	SetSpawnOption_SquadName( Droz, "TLRDD" )
	SetSpawnOption_Special( Droz, "mp_ability_holopilot", ["pas_power_cell"] )
	SetSpawnOption_Weapon( Droz, "mp_weapon_arena1" )
	SetSpawnOption_Sidearm( Droz, "mp_weapon_semipistol" )
	SetTeam( Droz, TEAM_MILITIA )
	DispatchSpawn( Droz )
	NPC_NoTarget( Droz )
	Droz.SetModel( FD_MODEL_DROZ )
	Droz.SetSkin( 2 )
	Droz.EnableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_NO_PAIN | NPC_NO_GESTURE_PAIN | NPC_ALLOW_PATROL | NPC_IGNORE_FRIENDLY_SOUND | NPC_NEW_ENEMY_FROM_SOUND | NPC_TEAM_SPOTTED_ENEMY | NPC_AIM_DIRECT_AT_ENEMY )
	Droz.DisableNPCFlag( NPC_ALLOW_FLEE )
	Droz.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_WALK_NONCOMBAT | NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_DISABLE_DANGEROUS_AREA_DISPLACEMENT )
	Droz.ai.buddhaMode = true //Plot Armor going hard
	Droz.kv.AccuracyMultiplier = 10.0
	Droz.kv.reactChance = 100
	Droz.kv.WeaponProficiency = eWeaponProficiency.PERFECT
	Droz.SetBehaviorSelector( "behavior_pilot_elite_assassin_cqb" )
	Droz.AssaultSetGoalRadius( 640 )
	Droz.AssaultSetGoalHeight( 1024 )
	Droz.AssaultSetFightRadius( 640 )
	Droz.AssaultPointClamped( FD_DefenseLocation )
}

void function SpawnDavisFD( vector spawnpos, vector angles )
{
	entity Davis = CreateEntity( "npc_pilot_elite" )
	SetTargetName( Davis, "#NPC_DAVIS_NAME" )
	Davis.SetTitle( "#NPC_DAVIS_NAME" )
	Davis.SetOrigin( spawnpos )
	Davis.SetAngles( angles )
	SetSpawnOption_AISettings( Davis, "npc_pilot_elite" )
	SetSpawnOption_NotAlert( Davis )
	Davis.kv.grenadeWeaponName = "mp_weapon_grenade_emp"
	Davis.kv.physdamagescale = 1.0
	SetSpawnOption_SquadName( Davis, "TLRDD" )
	SetSpawnOption_Special( Davis, "mp_ability_shifter_super", ["pas_power_cell"] )
	SetSpawnOption_Weapon( Davis, "mp_weapon_arena1" )
	SetSpawnOption_Sidearm( Davis, "mp_weapon_semipistol" )
	SetTeam( Davis, TEAM_MILITIA )
	DispatchSpawn( Davis )
	NPC_NoTarget( Davis )
	Davis.SetModel( FD_MODEL_DAVIS )
	Davis.EnableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_NO_PAIN | NPC_NO_GESTURE_PAIN | NPC_ALLOW_PATROL | NPC_IGNORE_FRIENDLY_SOUND | NPC_NEW_ENEMY_FROM_SOUND | NPC_TEAM_SPOTTED_ENEMY | NPC_AIM_DIRECT_AT_ENEMY )
	Davis.DisableNPCFlag( NPC_ALLOW_FLEE )
	Davis.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_WALK_NONCOMBAT | NPCMF_IGNORE_CLUSTER_DANGER_TIME | NPCMF_DISABLE_DANGEROUS_AREA_DISPLACEMENT )
	Davis.ai.buddhaMode = true //Plot Armor going hard
	Davis.kv.AccuracyMultiplier = 10.0
	Davis.kv.reactChance = 100
	Davis.kv.WeaponProficiency = eWeaponProficiency.PERFECT
	Davis.SetBehaviorSelector( "behavior_pilot_elite_assassin_cqb" )
	Davis.AssaultSetGoalRadius( 640 )
	Davis.AssaultSetGoalHeight( 1024 )
	Davis.AssaultSetFightRadius( 640 )
	Davis.AssaultPointClamped( FD_DefenseLocation )
}

void function SpawnFDHeavyTurret( vector spawnpos, vector angles, vector ornull battportpos = null, vector ornull battportangles = null )
{
	entity HeavyTurret = CreateEntity( "npc_turret_mega" )
	HeavyTurret.SetTitle( "Small Frankie" )
	HeavyTurret.SetOrigin( spawnpos )
	HeavyTurret.SetAngles( angles )
	SetSpawnOption_AISettings( HeavyTurret, "npc_turret_mega_frontierdefense" )
	SetSpawnOption_Alert( HeavyTurret )
	SetTeam( HeavyTurret, TEAM_MILITIA )
	DispatchSpawn( HeavyTurret )
	HeavyTurret.ai.buddhaMode = true
	HeavyTurret.SetMaxHealth( 10000 )
	HeavyTurret.SetHealth( 10000 )
	HeavyTurret.SetShieldHealth( 2500 )
	HeavyTurret.kv.AccuracyMultiplier = 100.0
	HeavyTurret.kv.reactChance = 100
	HeavyTurret.kv.WeaponProficiency = eWeaponProficiency.PERFECT
	HeavyTurret.SetNoTarget( false )
	
	if ( battportpos != null && battportangles != null )
	{
		entity TurretBatteryPort = CreatePropScript( $"models/props/battery_port/battery_port_animated.mdl", expect vector( battportpos ) + < 0, 0, 12 >, battportangles, 6 )
		entity TurretBatteryPortBase = CreatePropDynamicLightweight( $"models/props/turret_base/turret_base.mdl", battportpos, battportangles, 6 )
		HT_BatteryPort( TurretBatteryPort, HeavyTurret )
	}
	
	else
	{
		NPC_NoTarget( HeavyTurret )
		HeavyTurret.SetInvulnerable()
	}
}

void function SpawnLFMapTitan( vector spawnpos, vector angles )
{
	thread SpawnLFMapTitan_Threaded( spawnpos, angles )
}

void function SpawnLFMapTitan_Threaded( vector spawnpos, vector angles )
{
	file.helperTitanSpawnPos = spawnpos
	file.helperTitanAngles = angles
	entity npc = CreateNPCTitan( "titan_atlas_tracker", TEAM_MILITIA, spawnpos, angles, ["turbo_titan","pas_dash_recharge"] )
	SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker" )
	SetSpawnOption_Warpfall( npc )
	DispatchSpawn( npc )
	entity soul = npc.GetTitanSoul()
	npc.ClearBossPlayer()
	soul.ClearBossPlayer()
	soul.capturable = true
	if( IsValid( soul ) )
		thread LFTitanShieldAndHealthRegenThink( soul )
	thread MonitorPublicTitan( npc )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_ALLOW_PATROL )
	npc.DisableBehavior("Follow")
	DisableTitanRodeo( npc )
	
	TakeWeaponsForArray( npc, npc.GetMainWeapons() )
	npc.TakeOffhandWeapon( OFFHAND_ORDNANCE )
	npc.TakeOffhandWeapon( OFFHAND_SPECIAL )
	npc.TakeOffhandWeapon( OFFHAND_ANTIRODEO )
	
	npc.GiveWeapon( "mp_titanweapon_xo16_vanguard", ["arc_rounds","rapid_reload","fd_vanguard_weapon_1","fd_vanguard_weapon_2"] )
	npc.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets", OFFHAND_SPECIAL )
	npc.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE )
	npc.GiveOffhandWeapon( "mp_titanability_laser_trip", OFFHAND_ANTIRODEO, ["pas_ion_tripwire"] )
	
	array<entity> primaryWeapons = npc.GetMainWeapons()
	entity weapon = primaryWeapons[0]
	weapon.SetSkin( 1 )
	weapon.SetCamo( 31 )
	
	npc.WaitSignal( "TitanHotDropComplete" )
	thread TitanKneel( npc )
}

void function MonitorPublicTitan( entity titan )
{
	entity soul = titan.GetTitanSoul()
	entity trig = CreateEntity( "trigger_cylinder" )
	trig.SetRadius( 192 )
	trig.SetAboveHeight( 192 )
	trig.SetBelowHeight( 32 )
	trig.SetOrigin( titan.GetOrigin() )
	trig.SetParent( titan )
	trig.kv.triggerFilterNpc = "none"
	trig.kv.triggerFilterPlayer = "all"
	SetTeam( trig, TEAM_MILITIA )
	DispatchSpawn( trig )
	trig.SetEnterCallback( OnNearbyLFTitan )
	trig.SetLeaveCallback( OnAwayFromLFTitan )

	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( trig )
		{
			if ( IsValid( trig ) )
				trig.Destroy()
			thread SetRespawnOfHelperTitan()
		}
	)

	WaitForever()
}

void function SetRespawnOfHelperTitan()
{
	svGlobal.levelEnt.EndSignal( "CleanUpEntitiesForRoundEnd" ) //Stop respawn because it gonna respawn through the wave restart code itself
	
	wait 120
	if( GetGameState() == eGameState.Playing )
		thread SpawnLFMapTitan( file.helperTitanSpawnPos, file.helperTitanAngles )
}

void function OnNearbyLFTitan( entity trig, entity activator )
{
	if( !IsValidPlayer( activator ) )
		return
	
	if( activator.GetTeam() != TEAM_MILITIA || activator.IsTitan() )
		return
	
	entity titan = trig.GetParent()
	entity soul = titan.GetTitanSoul()
	if( !titan.IsPlayer() && !IsValid( GetPetTitanOwner( titan ) ) && Distance2D( activator.GetOrigin(), titan.GetOrigin() ) > 191 )
	{
		activator.SetPetTitan( titan )
		titan.SetBossPlayer( activator )
	}
}

void function OnAwayFromLFTitan( entity trig, entity activator )
{
	if( !IsValidPlayer( activator ) )
		return
	
	if( activator.GetTeam() != TEAM_MILITIA || activator.IsTitan() )
		return
	
	entity titan = trig.GetParent()
	entity soul = titan.GetTitanSoul()
	if( !titan.IsPlayer() && Distance2D( titan.GetOrigin(), activator.GetOrigin() ) > 192 )
	{
		titan.ClearBossPlayer()
		soul.ClearBossPlayer()
		activator.SetPetTitan( null )
		thread LFTitanHideEarnMeterOnLeaveProximity( activator )
	}
}

void function LFTitanHideEarnMeterOnLeaveProximity( entity player )
{
	WaitFrame()
	if( IsValidPlayer( player ) )
		PlayerEarnMeter_SetMode( player, 0 )
}

void function LFTitanShieldAndHealthRegenThink( entity soul )
{
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )

	soul.SetShieldHealthMax( 2500 )
	soul.SetShieldHealth( 2500 )

	int lastShieldHealth = soul.GetShieldHealth()
	bool shieldHealthSound = false
	bool fullhp = true
	int maxShield = soul.GetShieldHealthMax()
	float lastTime = Time()

	while ( true )
	{
		entity titan = soul.GetTitan()
		if ( !IsValid( titan ) )
			return

		int shieldHealth = soul.GetShieldHealth()
		Assert( titan )

		if ( lastShieldHealth <= 0 && shieldHealth && titan.IsPlayer() )
		{
		 	EmitSoundOnEntityOnlyToPlayer( titan, titan, "titan_energyshield_up_1P" )
		 	shieldHealthSound = true
		 	if ( titan.IsTitan() )
		 		GiveFriendlyRodeoPlayerProtection( titan )
		}
		else if ( shieldHealthSound && shieldHealth == soul.GetShieldHealthMax() )
			shieldHealthSound = false

		else if ( lastShieldHealth > shieldHealth && shieldHealthSound )
		{
		 	StopSoundOnEntity( titan, "titan_energyshield_up_1P" )
		 	shieldHealthSound = false
		}

		if ( Time() >= soul.nextRegenTime )
		{
			float shieldRegenRate = maxShield / ( GetShieldRegenTime( soul ) / SHIELD_REGEN_TICK_TIME )
			float frameTime = max( 0.0, Time() - lastTime )
			shieldRegenRate = shieldRegenRate * frameTime / SHIELD_REGEN_TICK_TIME
			soul.SetShieldHealth( minint( soul.GetShieldHealthMax(), int( shieldHealth + shieldRegenRate ) ) )
		}
		
		if( IsAlive( titan ) && titan.GetHealth() <= titan.GetMaxHealth() )
		{
			fullhp = false
			titan.SetHealth( min( titan.GetMaxHealth(), titan.GetHealth() + 10 ) )
		}
		
		if( IsAlive( titan ) && titan.GetHealth() >= ( titan.GetMaxHealth() - 10 ) && !soul.IsDoomed() && !fullhp )
		{
			fullhp = true
			UndoomTitan_Body( titan )
		}
		
		lastShieldHealth = shieldHealth
		lastTime = Time()
		titan.SetTitle( "Helper Titan" )
		WaitFrame()
	}
}