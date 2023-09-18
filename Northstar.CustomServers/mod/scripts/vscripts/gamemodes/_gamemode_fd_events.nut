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
global function CreateDroppodSpectreEvent
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
global function ShowTitanfallBlockHintToPlayer
global function ShowLargePilotKillStreak
global function ShowWaitingForMorePlayers
global function SetupGruntSpectreWeapons

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
	array<string> FD_GruntWeapons
	string Cvar_gruntgrenade
	array<string> FD_SpectreWeapons
}file

global table< string, entity > GlobalEventEntitys
global array< array<WaveEvent> > waveEvents

const float FD_TITAN_AOE_REACTTIME = 3.0 //This is in seconds

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
		
		if ( GetGlobalNetInt( "FD_AICount_Current" ) <= 10 && GetGlobalNetInt( "FD_AICount_Drone_Cloak" ) > 0  )
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

/* Event Generators
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

WaveEvent function CreateDroppodSpectreEvent( vector origin, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", float spawnradius = 0.0 )
{
	WaveEvent event
	event.eventFunction = spawnDroppodSpectre
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.SPECTRE
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

/* Event Functions
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
			thread AnnounceTitanfallBlock()
			foreach( entity player in GetPlayerArray() )
			{
				PlayerEarnMeter_Reset( player )
				ClearTitanAvailable( player )
			}
		}
		else
		{
			print( "Removing Titanfall Block Event" )
			PlayerEarnMeter_SetEnabled( true )
		}
	}
}

void function AnnounceTitanfallBlock()
{
	#if SERVER
	foreach( entity player in GetPlayerArray() )
		NSSendAnnouncementMessageToPlayer( player, "Titanfall Block", "Titans cannot be summoned anymore!", < 255, 255, 255 >, 150, 0 )
	wait 10
	foreach( entity player in GetPlayerArray() )
		NSSendLargeMessageToPlayer( player, "Titanfall Block", "Further Titans cannot be summoned until the end of the wave, avoid losing your current Titan!", 60, "rui/callsigns/callsign_94_col" )
	#endif
}

void function ShowTitanfallBlockHintToPlayer( entity player )
{
	#if SERVER
	wait 10
	IsValidPlayer( player )
		NSSendLargeMessageToPlayer( player, "Titanfall Block Active", "Your titan cannot be summoned, but you can help team mates not losing theirs, steal batteries!", 60, "rui/callsigns/callsign_14_col" )
	#endif
}

void function ShowLargePilotKillStreak( entity streaker )
{
	#if SERVER
	foreach( entity player in GetPlayerArray() )
		NSSendAnnouncementMessageToPlayer( player, streaker.GetPlayerName(), "Chained a huge titan killstreak as pilot!", < 255, 128, 32 >, 50, 5 )
	#endif
}

void function ShowWaitingForMorePlayers()
{
	#if SERVER
	foreach( entity player in GetPlayerArray() )
		NSSendAnnouncementMessageToPlayer( player, "#HUD_WAITING_FOR_PLAYERS_BASIC", "Minimum of: " + GetConVarInt( "ns_fd_min_numplayers_to_start" ) + " to start", < 255, 255, 255 >, 50, 5 )
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
				thread AnnounceEliteTitansToPlayers( player )
		}
		#endif
		PlayFactionDialogueToTeam( soundEvent.soundEventName, TEAM_MILITIA )
	}
}

void function AnnounceEliteTitansToPlayers( entity player )
{
	#if SERVER
	NSSendLargeMessageToPlayer( player, "Elite Titan", "Prime white chassis. Huge HP, huge shield, greater aiming, moves faster and can use Core. Drops battery on death.", 60, "rui/callsigns/callsign_17_col" )
	wait 10
	IsValidPlayer( player )
		NSSendInfoMessageToPlayer( player, "WARNING: Elite Titans can execute players!" )
	#endif
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
	smokenade.kv.fadedist = 32768
	smokenade.kv.renderamt = 255
	smokenade.kv.rendercolor = "255 255 255"
	smokenade.SetParent( mover, "", false, 0 )
	smokenade.EnableRenderAlways()
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
		guy.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
		SetSquad( guy, squadName )
		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.DRONE ) )
		AddMinimapForHumans( guy )
		spawnedNPCs.append( guy )
		thread droneNav_thread(guy, spawnEvent.route, 0, 160, spawnEvent.shouldLoop )
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
	SetSpawnOption_Alert( npc )
	spawnedNPCs.append( npc )
	DispatchSpawn( npc )
	if ( arcTitansUsesArcCannon ) //SetSpawnOption_Weapon is not working for Arc Titans so take current and give Arc Cannon
	{
		TakeWeaponsForArray( npc, npc.GetMainWeapons() )
		npc.GiveWeapon( "mp_titanweapon_arc_cannon" )
		npc.kv.AccuracyMultiplier = 0.6
	}
	
	npc.kv.reactChance = 50
	npc.kv.WeaponProficiency = eWeaponProficiency.POOR //This is because on Vanilla, Arc Titans don't spam Arc Waves as much and that is related to weapon proficiency
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER | NPC_ALLOW_PATROL )
	npc.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
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
	SetSpawnOption_Alert( npc )
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
	SetSpawnOption_Alert( npc )
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
		SetSpawnflags( guy, SF_NPC_START_EFFICIENT )
		// should this grunt be a shield captain?
		if (i < GetCurrentPlaylistVarInt( "fd_grunt_shield_captains", 0 ) || i == 1 && GetMapName().find( "mp_lf_" ) != null )
		{
			if ( GetConVarBool( "ns_fd_allow_true_shield_captains" ) )
				SetSpawnOption_AISettings( guy, "npc_soldier_shield_captain" )
			else
				thread ActivatePersonalShield( guy )
		}
		SetSpawnOption_Alert( guy )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey+ i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		guy.kv.grenadeWeaponName = file.Cvar_gruntgrenade
		DispatchSpawn( guy )
		SetupGruntBehaviorFlags( guy )
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		if( GetMapName().find( "mp_lf_" ) != null )
			guy.EnableNPCFlag( NPC_NO_WEAPON_DROP )

		GiveMinionFDLoadout( guy )
		// should this grunt have an anti titan weapon instead of its normal weapon?
		if ( i < GetCurrentPlaylistVarInt( "fd_grunt_at_weapon_users", 0 ) || GetMapName().find( "mp_lf_" ) != null )
			guy.GiveWeapon( at_weapon )

		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.GRUNT ) )
		guy.MakeInvisible()
		entity weapon = guy.GetActiveWeapon()
		if ( IsValid( weapon ) )
			weapon.MakeInvisible()
		
		spawnedNPCs.append( guy )
		guys.append( guy )
	}
	
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	foreach( npc in guys )
	{
		AddMinimapForHumans( npc )
		npc.SetEfficientMode( false )
		npc.SetEnemyChangeCallback( GruntTargetsTitan )
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
	int health 			= 10000
	int shield 			= 5000
	
	CallinData drop
	InitCallinData( drop )
	SetCallinStyle( drop, eDropStyle.ZIPLINE_NPC )
	drop.dist 			= 1300
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
	dropship.SetMaxHealth( health )
	dropship.SetHealth( health )
	dropship.SetShieldHealthMax( shield )
	dropship.SetShieldHealth( shield )
	dropship.EndSignal( "OnDeath" )
	dropship.Signal( "WarpedIn" )
	ref.Signal( "WarpedIn" )
	dropship.Minimap_AlwaysShow( TEAM_IMC, null )
	dropship.Minimap_AlwaysShow( TEAM_MILITIA, null )
	dropship.Minimap_SetHeightTracking( true )

	AddDropshipDropTable( dropship, dropTable )
	//string dropshipSound = "Goblin_IMC_TroopDeploy_Flyin"
	string dropshipSound = "Beacon_Flying_3_ships_02"

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
		SetSpawnflags( guy, SF_NPC_START_EFFICIENT )
		if (i < GetCurrentPlaylistVarInt( "fd_grunt_shield_captains", 0 ) )
		{
			if ( GetConVarBool( "ns_fd_allow_true_shield_captains" ) )
				SetSpawnOption_AISettings( guy, "npc_soldier_shield_captain" )
			else
				thread ActivatePersonalShield( guy )
		}
		SetSpawnOption_Alert( guy )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey+ i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		guy.kv.grenadeWeaponName = file.Cvar_gruntgrenade
		DispatchSpawn( guy )
		SetupGruntBehaviorFlags( guy )
		SetSquad( guy, squadName )
		
		GiveMinionFDLoadout( guy )
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
			{
				guy.EnableNPCFlag( NPC_NO_WEAPON_DROP )
				guy.Die( svGlobal.worldspawn, svGlobal.worldspawn, { scriptType = DF_DISSOLVE, damageSourceId = damagedef_crush } ) //Kill grunts that didn't manage to drop off the ship
			}
			else
			{
				guy.SetEfficientMode( false )
				guy.SetEnemyChangeCallback( GruntTargetsTitan )
				thread singleNav_thread( guy, spawnEvent.route )
			}
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
		SetSpawnflags( guy, SF_NPC_START_EFFICIENT )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		SetSpawnOption_AISettings( guy, "npc_stalker_fd" )
		DispatchSpawn( guy )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE | NPC_NO_WEAPON_DROP )
		guy.DisableNPCFlag( NPC_ALLOW_PATROL )
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		guy.AssaultSetFightRadius( 0 ) // makes them keep moving instead of stopping to shoot you.
		guy.MakeInvisible()
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
				npc.GiveWeapon( "mp_weapon_epg", ["slowProjectile"] )
				npc.SetActiveWeaponByName( "mp_weapon_epg" )
				entity weapon = npc.GetActiveWeapon()
				if ( IsValid( weapon ) )
					weapon.MakeInvisible()
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
			npc.GiveWeapon( "mp_weapon_epg", ["slowProjectile"] )
			npc.SetActiveWeaponByName( "mp_weapon_epg" )
			npc.DisableNPCFlag( NPC_DISABLE_SENSING | NPC_IGNORE_ALL )
			
			entity weapon = npc.GetActiveWeapon()
			if ( IsValid( weapon ) )
				weapon.MakeInvisible()
		}
	}

	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	foreach( npc in guys )
	{
		AddMinimapForHumans( npc )
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
		SetSpawnflags( guy, SF_NPC_START_EFFICIENT )
		SetSpawnOption_AISettings( guy, "npc_spectre_mortar" )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		DispatchSpawn( guy )
		GiveMinionFDLoadout( guy )
		spawnedNPCs.append(guy)
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.SPECTRE_MORTAR))
		guy.MakeInvisible()
		guys.append( guy )
    }

	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
    ActivateFireteamDropPod( pod, guys )
	
	foreach( npc in guys )
	{
		AddMinimapForHumans( npc )
		npc.SetEfficientMode( false )
		thread NPCStuckTracker( npc )
	}
	
	thread MortarSpectreSquadThink( guys, fd_harvester.harvester )
}

void function spawnDroppodSpectre( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	printt( "Spawning Spectres Drop Pod at: " + spawnEvent.origin )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
		entity pod = CreateDropPod( spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	SetTeam( pod, TEAM_IMC )
	InitFireteamDropPod( pod )

	string squadName = MakeSquadName( TEAM_IMC, UniqueString() )
	array<entity> guys

	for ( int i = 0; i < 4; i++ )
	{
		entity guy = CreateSpectre( TEAM_IMC, spawnEvent.origin,< 0, 0, 0 > )
		SetSpawnflags( guy, SF_NPC_START_EFFICIENT )
		SetSpawnOption_AISettings( guy, "npc_spectre" )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetTeam( guy, TEAM_IMC )
		guy.kv.reactChance = 100
		DispatchSpawn( guy )
		GiveMinionFDLoadout( guy )
		guy.AssaultSetFightRadius( 0 )
		guy.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER | NPC_ALLOW_PATROL )
		guy.EnableNPCFlag( NPC_NO_WEAPON_DROP )
		spawnedNPCs.append(guy)
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		SetTargetName( guy, GetTargetNameForID(eFD_AITypeIDs.SPECTRE))
		guy.MakeInvisible()
		guys.append( guy )
    }

	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
    ActivateFireteamDropPod( pod, guys )
	
	foreach( npc in guys )
	{
		AddMinimapForHumans( npc )
		npc.SetEfficientMode( false )
		thread NPCStuckTracker( npc )
		thread singleNav_thread( npc, spawnEvent.route )
	}
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
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb_boss_fd_elite" )
		SetTitanAsElite( npc )
		SetSpawnOption_TitanSoulPassive4( npc, "pas_ion_lasercannon" )
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
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_ion"
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
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
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor_boss_fd_elite" )
		SetTitanAsElite( npc )
		SetSpawnOption_TitanSoulPassive4( npc, "pas_scorch_flamecore" )
		SetSpawnOption_TitanSoulPassive5( npc, "pas_scorch_selfdmg" )
	}
	else
	{
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor" )
		else
			SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor_boss_fd" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_scorch_prime"
		
		array<entity> primaryWeapons = npc.GetMainWeapons()
		entity weapon = primaryWeapons[0]
		weapon.AddMod( "fd_wpn_upgrade_2" )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
	{
		npc.kv.reactChance = 60
		npc.kv.AccuracyMultiplier = 0.5
		npc.kv.WeaponProficiency = eWeaponProficiency.AVERAGE
		npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
	}
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
	entity npc = CreateNPCTitan( "titan_stryder", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_boss_fd_elite" )
		SetTitanAsElite( npc )
		SetSpawnOption_TitanSoulPassive4( npc, "pas_ronin_swordcore" )
		SetSpawnOption_TitanSoulPassive5( npc, "pas_ronin_weapon" )
		SetSpawnOption_TitanSoulPassive6( npc, "pas_ronin_phase" )
	}
	else
	{
		if ( difficultyLevel == eFDDifficultyLevel.EASY || difficultyLevel == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall" )
		else
			SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_boss_fd" )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_ronin"
		
		npc.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "fd_sword_upgrade" )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
	{
		npc.kv.AccuracyMultiplier = 0.7
		npc.kv.WeaponProficiency = eWeaponProficiency.AVERAGE
	}
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
	entity npc = CreateNPCTitan( "titan_atlas", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_boss_fd_elite" )
		SetTitanAsElite( npc )
		SetSpawnOption_TitanSoulPassive4( npc, "pas_tone_sonar" )
		SetSpawnOption_TitanSoulPassive5( npc, "pas_tone_wall" )
		SetSpawnOption_TitanSoulPassive6( npc, "pas_tone_rockets" )
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
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_tone"
		
		entity tonesonar = npc.GetOffhandWeapon( OFFHAND_ANTIRODEO )
		tonesonar.AddMod( "fd_sonar_duration" )
		tonesonar.AddMod( "fd_sonar_damage_amp" )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
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
		SetSpawnOption_TitanSoulPassive4( npc, "pas_legion_spinup" )
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
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 15000 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.kv.AccuracyMultiplier = 1.0 //Ironically lowering their accuracy increases the chance of them hitting the enemy
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_random_5"
		
		array<entity> primaryWeapons = npc.GetMainWeapons()
		entity maingun = primaryWeapons[0]
		maingun.AddMod( "fd_closerange_helper" )
		maingun.AddMod( "fd_longrange_helper" )
		maingun.AddMod( "fd_piercing_shots" )
		maingun.AddMod( "fd_gun_shield_redirect" )
		maingun.AddMod( "SiegeMode" )
		
		entity gunshield = npc.GetOffhandWeapon( OFFHAND_SPECIAL )
		gunshield.AddMod( "npc_more_shield" )
		gunshield.AddMod( "npc_infinite_shield" )
		gunshield.AddMod( "fd_gun_shield" )
		gunshield.AddMod( "fd_gun_shield_redirect" )
		gunshield.AddMod( "SiegeMode" )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
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
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_vanguard"
		npc.GetTitanSoul().SetTitanSoulNetInt( "upgradeCount", 3 )
		
		array<entity> primaryWeapons = npc.GetMainWeapons()
		entity maingun = primaryWeapons[0]
		maingun.AddMod( "arc_rounds" )
		maingun.AddMod( "rapid_reload" )
		maingun.AddMod( "fd_vanguard_weapon_1" )
		maingun.AddMod( "fd_vanguard_weapon_2" )
		maingun.AddMod( "fd_vanguard_utility_1" )
		
		npc.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		npc.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE, ["mod_ordnance_core","upgradeCore_MissileRack_Vanguard"] )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
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
	npc.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS | NPCMF_WALK_NONCOMBAT )
	npc.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT )
	npc.DisableNPCFlag( NPC_DIRECTIONAL_MELEE )
	npc.AssaultSetFightRadius( 0 )
	SlowEnemyMovementBasedOnDifficulty( npc )
	npc.SetDangerousAreaReactionTime( 15 ) //Lasts longer than any AoE the game has
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
	SetSpawnOption_Alert( npc )
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetSkin( 2 )
	npc.SetCamo( 1 )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )
	npc.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
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
	entity npc = CreateNPCTitan( "titan_stryder", TEAM_IMC, spawnEvent.origin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	SetSpawnOption_Alert( npc )
	npc.kv.AccuracyMultiplier = 2
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_stryder_sniper_boss_fd_elite" )
		SetTitanAsElite( npc )
		SetSpawnOption_TitanSoulPassive4( npc, "pas_northstar_cluster" )
		SetSpawnOption_TitanSoulPassive5( npc, "pas_northstar_trap" )
	}
	else
	{
		SetSpawnOption_AISettings( npc, "npc_titan_stryder_sniper_fd" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_random_2"
		
		entity tethertrap = npc.GetOffhandWeapon( OFFHAND_SPECIAL )
		tethertrap.AddMod( "fd_explosive_trap" )
		tethertrap.AddMod( "fd_trap_charges" )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
		npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )
	npc.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
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
		SetSpawnOption_TitanSoulPassive4( npc, "pas_tone_sonar" )
		SetSpawnOption_TitanSoulPassive5( npc, "pas_tone_wall" )
		SetSpawnOption_TitanSoulPassive6( npc, "pas_tone_rockets" )
	}
	else
	{
		SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_fd_sniper" )
		SlowEnemyMovementBasedOnDifficulty( npc )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	if ( spawnEvent.titanType == 1 && elitesAllowed )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_tone_prime"
		
		entity tonesonar = npc.GetOffhandWeapon( OFFHAND_ANTIRODEO )
		tonesonar.AddMod( "fd_sonar_duration" )
		tonesonar.AddMod( "fd_sonar_damage_amp" )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
	{
		npc.SetSkin( 8 )
		npc.SetCamo( -1 )
		npc.SetDangerousAreaReactionTime( FD_TITAN_AOE_REACTTIME )
	}
	npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE )
	npc.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
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
		SetSpawnflags( guy, SF_NPC_START_EFFICIENT )
		if( spawnEvent.entityGlobalKey != "" )
			GlobalEventEntitys[ spawnEvent.entityGlobalKey + i.tostring() ] <- guy
		SetSpawnOption_AISettings( guy, "npc_frag_drone_fd" )
		SetSpawnOption_Alert( guy )
		SetTeam( guy, TEAM_IMC )
		DispatchSpawn( guy )
		guy.EnableNPCFlag(  NPC_ALLOW_INVESTIGATE )
		if( GetConVarBool( "ns_fd_differentiate_ticks" ) )
			guy.SetModel( $"models/robots/drone_frag/drone_frag.mdl" )
		SetTargetName( guy, GetTargetNameForID( eFD_AITypeIDs.TICK ) )
		guy.SetParent( pod, "ATTACH", true )
		SetSquad( guy, squadName )
		spawnedNPCs.append( guy )
		guy.MakeInvisible()
		guy.AssaultSetFightRadius( expect int( guy.Dev_GetAISettingByKeyField( "LookDistDefault_Combat" ) ) ) // make the ticks target players very aggressively
		guys.append( guy )
	}
	
	waitthread LaunchAnimDropPod( pod, "pod_testpath", spawnEvent.origin, < 0, RandomIntRange( 0, 359 ), 0 > )
	ActivateFireteamDropPod( pod, guys )
	foreach( guy in guys )
	{
		if( IsValid( guy ) )
		{
			guy.MakeVisible()
			guy.Anim_Stop() //Intentionally cancel the Drop Pod exiting animation for Ticks because it doesnt work for them
			guy.SetEfficientMode( false )
			AddMinimapForHumans( guy )
			thread singleNav_thread( guy, spawnEvent.route )
		}
	}
}


/* Event Helpers
███████╗██╗   ██╗███████╗███╗   ██╗████████╗    ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝    ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║       ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║       ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║       ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝
*/

void function PingMinimap( float x, float y, float duration, float spreadRadius, float ringRadius, int colorIndex )
{
	foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
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
		if( !IsValid( npc ) || IsValid( GetPetTitanOwner( npc ) ) || npc.GetTeam() == TEAM_MILITIA )
		{
			deduct++
			continue
		}
		if( IsAirDrone( npc ) && GetDroneType( npc ) == "drone_type_cloaked" )
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
			if( !IsValid( npc ) || IsValid( GetPetTitanOwner( npc ) ) || npc.GetTeam() == TEAM_MILITIA )
			{
				deduct++
				continue
			}
			if( IsAirDrone( npc ) && GetDroneType( npc ) == "drone_type_cloaked" )
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
		if( !IsValid( npc ) || IsValid( GetPetTitanOwner( npc ) ) || npc.GetTeam() == TEAM_MILITIA )
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
	int aliveNPCs = spawnedNPCs.len() - deduct
	while( aliveNPCs > amount )
	{
		WaitFrame()
		deduct = 0
		foreach ( entity npc in spawnedNPCs )
		{
			if( !IsValid( npc ) || IsValid( GetPetTitanOwner( npc ) ) || npc.GetTeam() == TEAM_MILITIA )
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
		if( !IsValid( npc ) || IsValid( GetPetTitanOwner( npc ) ) || npc.GetTeam() == TEAM_MILITIA )
			continue
		
		if( IsAirDrone( npc ) && GetDroneType( npc ) == "drone_type_cloaked" )
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
				if( !IsValid( npc ) || IsValid( GetPetTitanOwner( npc ) ) || npc.GetTeam() == TEAM_MILITIA )
					continue
					
				if( IsAirDrone( npc ) && GetDroneType( npc ) == "drone_type_cloaked" )
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


/* NPC Functions
███╗   ██╗██████╗  ██████╗    ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
████╗  ██║██╔══██╗██╔════╝    ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
██╔██╗ ██║██████╔╝██║         █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
██║╚██╗██║██╔═══╝ ██║         ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
██║ ╚████║██║     ╚██████╗    ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
╚═╝  ╚═══╝╚═╝      ╚═════╝    ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
*/

void function SetupGruntSpectreWeapons()
{
	file.Cvar_gruntgrenade = GetConVarString( "ns_fd_grunt_grenade" )
	
	string Cvar_gruntweapons = GetConVarString( "ns_fd_grunt_primary_weapon" )
	file.FD_GruntWeapons = split( Cvar_gruntweapons, "," )
	
	string Cvar_spectreweapons = GetConVarString( "ns_fd_spectre_primary_weapon" )
	file.FD_SpectreWeapons = split( Cvar_spectreweapons, "," )
}

void function GiveMinionFDLoadout( entity npc )
{
	Assert( IsValid( npc ) && IsMinion( npc ), "Entity is not a spectre or grunt: " + npc )
	string className = npc.GetClassName()
	
	if( className == "npc_soldier" )
	{
		npc.SetBehaviorSelector( "behavior_sp_soldier" ) //So they can use grenades and secondaries
		if ( file.FD_GruntWeapons.len() > -1 )
		{
			TakeAllWeapons( npc )
			string baseweapon = file.FD_GruntWeapons[ RandomInt( file.FD_GruntWeapons.len() ) ]
			npc.GiveWeapon( baseweapon )
			npc.GiveWeapon( "mp_weapon_wingman" )
			npc.kv.grenadeWeaponName = file.Cvar_gruntgrenade
		}
	}
	
	else if( className == "npc_spectre" )
	{
		if ( file.FD_SpectreWeapons.len() > -1 )
		{
			TakeAllWeapons( npc )
			string baseweapon = file.FD_SpectreWeapons[ RandomInt( file.FD_SpectreWeapons.len() ) ]
			npc.GiveWeapon( baseweapon )
		}
	}
}

void function SlowEnemyMovementBasedOnDifficulty( entity npc )
{
	//This is not exact vanilla behavior i think, but enemies definetely moves slower on Frontier Defense than player autotitans
	Assert( IsValid( npc ) && npc.IsNPC(), "Tried to set up movespeed scale in non-NPC entity: " + npc )
	
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
			npc.SetNPCMoveSpeedScale( 1.0 )
			break
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

void function SetupGruntBehaviorFlags( entity npc )
{
	Assert( IsValid( npc ) && IsGrunt( npc ), "Entity is not a Grunt: " + npc )
	
	switch ( difficultyLevel )
	{
		case eFDDifficultyLevel.EASY:
		case eFDDifficultyLevel.NORMAL:
			npc.EnableNPCFlag( NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE | NPC_USE_SHOOTING_COVER )
			npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_ALLOW_PATROL )
			break
		case eFDDifficultyLevel.HARD:
		case eFDDifficultyLevel.MASTER:
		case eFDDifficultyLevel.INSANE:
			npc.EnableNPCFlag( NPC_ALLOW_HAND_SIGNALS )
			npc.DisableNPCFlag( NPC_ALLOW_INVESTIGATE | NPC_ALLOW_PATROL | NPC_ALLOW_FLEE | NPC_USE_SHOOTING_COVER )
			break
	}
}

void function GruntTargetsTitan( entity npc )
{
	Assert( IsValid( npc ) && IsGrunt( npc ), "Entity is not a Grunt: " + npc )
	
	OnEnemyChanged_MinionSwitchToHeavyArmorWeapon( npc )
	
	entity enemy = npc.GetEnemy()
	if( enemy != null )
	{
		switch ( difficultyLevel )
		{
			case eFDDifficultyLevel.EASY:
			case eFDDifficultyLevel.NORMAL:
				if( enemy.IsTitan() )
					npc.AssaultSetFightRadius( 800 )
				else
					npc.AssaultSetFightRadius( 0 )
				break
			case eFDDifficultyLevel.HARD:
			case eFDDifficultyLevel.MASTER:
			case eFDDifficultyLevel.INSANE:
				npc.AssaultSetFightRadius( 0 )
				break
		}
	}
}

void function SetTitanAsElite( entity npc )
{
	if( GetGameState() != eGameState.Playing || !IsHarvesterAlive( fd_harvester.harvester ) )
		return
	
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
	if ( npc.IsTitan() && elitesAllowed )
	{
		SetSpawnOption_NPCTitan( npc, TITAN_MERC )
		SetSpawnOption_TitanSoulPassive1( npc, "pas_enhanced_titan_ai" )
		SetSpawnOption_TitanSoulPassive2( npc, "pas_defensive_core" )
		SetSpawnOption_TitanSoulPassive3( npc, "pas_assault_reactor" )
		//SetSpawnflags( npc, SF_TITAN_SOUL_NO_DOOMED_EVASSIVE_COMBAT )
	}
}

void function SetEliteTitanPostSpawn( entity npc )
{
	if( GetGameState() != eGameState.Playing || !IsHarvesterAlive( fd_harvester.harvester ) )
		return
	
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
	if ( npc.IsTitan() && elitesAllowed )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN | NPC_NEW_ENEMY_FROM_SOUND ) //NPC_AIM_DIRECT_AT_ENEMY
		npc.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
		npc.DisableNPCFlag( NPC_PAIN_IN_SCRIPTED_ANIM )
		npc.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
		npc.SetCapabilityFlag( bits_CAP_NO_HIT_SQUADMATES, false )
		npc.SetDefaultSchedule( "SCHED_ALERT_WALK" )
		npc.kv.AccuracyMultiplier = 5.0
		npc.kv.WeaponProficiency = eWeaponProficiency.PERFECT
		SetTitanWeaponSkin( npc )
		HideCrit( npc )
		npc.SetTitle( npc.GetSettingTitle() )
		ShowName( npc )
		
		entity soul = npc.GetTitanSoul()
		if( IsValid( soul ) )
		{
			soul.SetPreventCrits( true )
			soul.SetShieldHealthMax( 7500 )
			soul.SetShieldHealth( 7500 )
		}
		
		thread MonitorEliteTitanCore( npc )
	}
}

void function MonitorEliteTitanCore( entity npc )
{
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
	entity soul = npc.GetTitanSoul()
	if ( !IsValid( soul ) )
		return
	
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	
	while( true )
	{
		SoulTitanCore_SetNextAvailableTime( soul, 1.0 )
		
		npc.WaitSignal( "CoreBegin" )
		wait 0.1
		
		soul.SetShieldHealthMax( 2500 )
		soul.SetShieldHealth( 2500 )
		
		entity meleeWeapon = npc.GetMeleeWeapon()
		if( meleeWeapon.HasMod( "super_charged" ) || meleeWeapon.HasMod( "super_charged_SP" ) ) //Hack for Elite Ronin
			npc.SetAISettings( "npc_titan_stryder_leadwall_shift_core_elite" )
		
		npc.WaitSignal( "CoreEnd" )
		switch ( difficultyLevel )
		{
			case eFDDifficultyLevel.EASY:
			case eFDDifficultyLevel.NORMAL:
			case eFDDifficultyLevel.HARD:
				wait RandomFloatRange( 20.0, 40.0 )
				break
			case eFDDifficultyLevel.MASTER:
			case eFDDifficultyLevel.INSANE:
				wait RandomFloatRange( 40.0, 60.0 )
				break
		}
	}
}

void function WinWave()
{
	foreach( WaveEvent e in waveEvents[GetGlobalNetInt( "FD_currentWave" )] )
	{
		e.timesExecuted = e.executeOnThisCall
	}
}


/* Extra Content
███████╗██╗  ██╗████████╗██████╗  █████╗      ██████╗ ██████╗ ███╗   ██╗████████╗███████╗███╗   ██╗████████╗
██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗██╔══██╗    ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝
█████╗   ╚███╔╝    ██║   ██████╔╝███████║    ██║     ██║   ██║██╔██╗ ██║   ██║   █████╗  ██╔██╗ ██║   ██║   
██╔══╝   ██╔██╗    ██║   ██╔══██╗██╔══██║    ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██║╚██╗██║   ██║   
███████╗██╔╝ ██╗   ██║   ██║  ██║██║  ██║    ╚██████╗╚██████╔╝██║ ╚████║   ██║   ███████╗██║ ╚████║   ██║   
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   
*/

void function Drop_Spawnpoint( vector origin, int team, float impactTime )
{
	vector surfaceNormal = < 0, 0, 1 >

	int index = GetParticleSystemIndex( $"P_ar_titan_droppoint" )

	entity effectEnemy = StartParticleEffectInWorld_ReturnEntity( index, origin, surfaceNormal )
	SetTeam( effectEnemy, team )
	EffectSetControlPointVector( effectEnemy, 1, < 255, 64, 16 > )
	effectEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	
	wait impactTime
	
	EffectStop( effectEnemy )
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

void function SetTitanWeaponSkin( entity npc, int skinindex = 1, int camoindex = 31 )
{
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan: " + npc )
	
	if ( npc.IsTitan() )
	{
		array<entity> primaryWeapons = npc.GetMainWeapons()
		entity weapon = primaryWeapons[0]
		weapon.SetSkin( skinindex )
		weapon.SetCamo( camoindex )
	}
}

void function SpawnDrozFD( vector spawnpos, vector angles )
{
	entity Droz = CreateEntity( "npc_pilot_elite" )
	SetTargetName( Droz, "NPCPilotDroz" )
	Droz.SetTitle( "#NPC_DROZ_NAME" )
	Droz.SetOrigin( spawnpos )
	Droz.SetAngles( angles )
	SetSpawnOption_AISettings( Droz, "npc_pilot_elite" )
	SetSpawnOption_NotAlert( Droz )
	Droz.kv.grenadeWeaponName = "mp_weapon_grenade_emp"
	Droz.kv.physdamagescale = 1.0
	SetSpawnOption_SquadName( Droz, "TLRDD" )
	SetSpawnOption_Special( Droz, "mp_ability_holopilot", ["pas_power_cell"] )
	SetSpawnOption_Weapon( Droz, "mp_weapon_epg", ["extended_ammo"] )
	SetSpawnOption_Sidearm( Droz, "mp_weapon_shotgun_pistol" )
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
	//Droz.SetBehaviorSelector( "behavior_pilot_elite_assassin_cqb" )
	Droz.SetBehaviorSelector( "behavior_sp_soldier" )
	Droz.AssaultSetGoalRadius( 640 )
	Droz.AssaultSetGoalHeight( 1024 )
	Droz.AssaultSetFightRadius( 640 )
	Droz.AssaultPointClamped( FD_DefenseLocation )
}

void function SpawnDavisFD( vector spawnpos, vector angles )
{
	entity Davis = CreateEntity( "npc_pilot_elite" )
	SetTargetName( Davis, "NPCPilotDavis" )
	Davis.SetTitle( "#NPC_DAVIS_NAME" )
	Davis.SetOrigin( spawnpos )
	Davis.SetAngles( angles )
	SetSpawnOption_AISettings( Davis, "npc_pilot_elite" )
	SetSpawnOption_NotAlert( Davis )
	Davis.kv.grenadeWeaponName = "mp_weapon_grenade_emp"
	Davis.kv.physdamagescale = 1.0
	SetSpawnOption_SquadName( Davis, "TLRDD" )
	SetSpawnOption_Special( Davis, "mp_ability_shifter_super", ["pas_power_cell"] )
	SetSpawnOption_Weapon( Davis, "mp_weapon_epg", ["extended_ammo"] )
	SetSpawnOption_Sidearm( Davis, "mp_weapon_shotgun_pistol" )
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
	//Davis.SetBehaviorSelector( "behavior_pilot_elite_assassin_cqb" )
	Davis.SetBehaviorSelector( "behavior_sp_soldier" )
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
	npc.DisableBehavior( "Follow" )
	DisableTitanRodeo( npc )
	npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_vanguard"
	TakeWeaponsForArray( npc, npc.GetMainWeapons() )
	npc.TakeOffhandWeapon( OFFHAND_ORDNANCE )
	npc.TakeOffhandWeapon( OFFHAND_SPECIAL )
	npc.TakeOffhandWeapon( OFFHAND_ANTIRODEO )
	
	npc.GiveWeapon( "mp_titanweapon_xo16_vanguard", ["arc_rounds","rapid_reload","fd_vanguard_weapon_1","fd_vanguard_weapon_2"] )
	npc.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets", OFFHAND_SPECIAL )
	npc.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE )
	npc.GiveOffhandWeapon( "mp_titanability_laser_trip", OFFHAND_ANTIRODEO, ["pas_ion_tripwire"] )
	
	SetTitanWeaponSkin( npc )
	
	npc.WaitSignal( "TitanHotDropComplete" )
	thread TitanKneel( npc )
}

void function MonitorPublicTitan( entity monitoredtitan )
{
	entity soul = monitoredtitan.GetTitanSoul()
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )
	
	OnThreadEnd(
		function () : ( soul )
		{
			thread SetRespawnOfHelperTitan()
		}
	)
	
	while( true )
	{
		entity titan = soul.GetTitan()
		entity titanowner = GetPetTitanOwner( titan )
		
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			if( !titan.IsPlayer() )
			{
				if( !IsValid( titanowner ) && Distance( player.GetOrigin(), titan.GetOrigin() ) < 191 )
				{
					player.SetPetTitan( titan )
					titan.SetBossPlayer( player )
				}
			}
		}
		
		if( IsValid( titanowner ) && Distance( titanowner.GetOrigin(), titan.GetOrigin() ) > 192 )
		{
			titan.ClearBossPlayer()
			soul.ClearBossPlayer()
			titanowner.SetPetTitan( null )
			thread LFTitanHideEarnMeterOnLeaveProximity( titanowner )
		}
		
		wait 0.25
	}
}

void function SetRespawnOfHelperTitan()
{
	svGlobal.levelEnt.EndSignal( "CleanUpEntitiesForRoundEnd" ) //Stop respawn because it gonna respawn through the wave restart code itself
	
	wait 120
	if( GetGameState() == eGameState.Playing )
		thread SpawnLFMapTitan( file.helperTitanSpawnPos, file.helperTitanAngles )
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

	soul.SetShieldHealthMax( 3750 )
	soul.SetShieldHealth( 3750 )

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
		ShowName( titan )
		WaitFrame()
	}
}