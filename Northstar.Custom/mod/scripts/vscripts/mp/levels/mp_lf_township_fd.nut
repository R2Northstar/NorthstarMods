global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnDrozAndDavisForFD )
	
	PlaceFDShop( < 360, -1504, 264 >, < 0, 90, 0 > )
	SetFDGroundSpawn( < 248, -1979, 8 >, < 0, 90, 0 > )
	OverrideFDHarvesterLocation( < 512, -762, 1 > )
	SetFDAIDefenseLocation( < 822, -880, 1 > )
	
	array<vector> infantryspawns = []
	infantryspawns.append( < -675, 1509, 1 > )
	infantryspawns.append( < -364, 1530, 1 > )
	infantryspawns.append( < -419, 1840, 1 > )
	infantryspawns.append( < -233, 2273, 1 > )
	infantryspawns.append( < -571, 2179, 1 > )
	infantryspawns.append( < -777, 1969, 1 > )
	infantryspawns.append( < -718, 1642, 1 > )
	infantryspawns.append( < 48, 1394, 1 > )
	infantryspawns.append( < 1290, 1246, 1 > )
	infantryspawns.append( < 1000, 1472, 1 > )
	infantryspawns.append( < 1253, 2039, 1 > )
	infantryspawns.append( < 987, 2235, 1 > )
	infantryspawns.append( < 945, 1906, 1 > )
	infantryspawns.append( < 1383, 1976, 1 > )
	infantryspawns.append( < 170, 2339, 1 > )
	infantryspawns.append( < 553, 2247, 1 > )
	infantryspawns.append( < 275, 693, 1 > )
	infantryspawns.append( < 101, 396, 1 > )
	infantryspawns.append( < 1176, -125, 6 > )
	infantryspawns.append( < 1127, 500, 2 > )
	infantryspawns.append( < -691, 800, 1 > )
	infantryspawns.append( < -856, 1125, 1 > )
	infantryspawns.append( < -706, 1082, 1 > )
	infantryspawns.append( < 487, 2049, 265 > )
	
	array<vector> tickspawns = []
	tickspawns.append( < -623, 1602, 1 > )
	tickspawns.append( < -302, 2259, 1 > )
	tickspawns.append( < -651, 1962, 1 > )
	tickspawns.append( < 408, 2340, 8 > )
	tickspawns.append( < 1105, 2148, 1 > )
	tickspawns.append( < 925, 947, 13 > )
	tickspawns.append( < 911, 1714, 8 > )
	tickspawns.append( < 724, 2040, 265 > )
	
	array<vector> reaperspawns = []
	reaperspawns.append( < -480, 1675, 1 > )
	reaperspawns.append( < -795, 1754, 1 > )
	reaperspawns.append( < -811, 2049, 1 > )
	reaperspawns.append( < -451, 2250, 1 > )
	reaperspawns.append( < -226, 1891, 8 > )
	reaperspawns.append( < 1051, 1503, 1 > )
	reaperspawns.append( < 920, 1723, 8 > )
	reaperspawns.append( < 1231, 1967, 1 > )
	reaperspawns.append( < 964, 2251, 1 > )
	reaperspawns.append( < 1221, 2155, 1 > )
	reaperspawns.append( < 1349, 1284, 1 > )
	reaperspawns.append( < 1067, 1056, 1 > )
	reaperspawns.append( < 790, 1259, 1 > )
	
	array<vector> titanspawns = []
	titanspawns.append( < 1200, 1180, 1 > )
	titanspawns.append( < 822, 1040, 11 > )
	titanspawns.append( < 1114, 2102, 1 > )
	titanspawns.append( < -340, 2249, 1 > )
	titanspawns.append( < -776, 2050, 1 > )
	titanspawns.append( < -582, 1572, 1 > )
	
	int spawnamount
	
	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
	}
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
		WaveSpawn_InfantrySpawn( wave1, "Drones", reaperspawns.getrandom() + < 0, 0, 128>, 90, "dronesPathing", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
		WaveSpawn_InfantrySpawn( wave1, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
	}
	WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "" )
	
    WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
	array<WaveSpawnEvent> wave2
	for( spawnamount = 0; spawnamount < 10; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	for( spawnamount = 0; spawnamount < 10; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Drones", infantryspawns.getrandom(), 0.0, "dronesPathing", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	for( spawnamount = 0; spawnamount < 12; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Drones", infantryspawns.getrandom(), 0.0, "dronesPathing", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_ReaperSpawn( wave2, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	WaveSpawn_TitanSpawn( wave2, "ArcTitan", titanspawns.getrandom(), -90, "titanMain" )
	
    WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave3
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Drones", infantryspawns.getrandom(), 0.0, "dronesPathing", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Drones", infantryspawns.getrandom(), 0.0, "dronesPathing", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Drones", infantryspawns.getrandom(), 0.0, "dronesPathing", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Drones", infantryspawns.getrandom(), 0.0, "dronesPathing", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	
	for( spawnamount = 0; spawnamount < 80; spawnamount++ )
	{
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", titanspawns.getrandom(), -90, "titanMain", RandomFloatRange( 0.1, 0.6 ) )
    WaveSpawnEvents.append( wave3 )
}

void function SpawnDrozAndDavisForFD()
{
	SpawnDrozFD( < 934, -1743, 1 >, < 0, 90, 0 > )
	SpawnDavisFD( < 1133, -1743, 1 >, < 0, 90, 0 > )
	SpawnLFMapTitan( < 1202, -850, 1 >, < 0, 180, 0 > )
}

void function RegisterCustomFDContent()
{
	AddLoadoutCrate( TEAM_MILITIA, < 150, -1482, 16 >, < 0, -90, 0 > )
	SpawnFDHeavyTurret( < 975, -1240, 1 >, < 0, 135, 0 > )
	
	routes[ "cornerGardenShort" ] <- []
	routes[ "cornerGardenShort" ].append( < 166, 550, 4 > )
	routes[ "cornerGardenShort" ].append( < 674, 319, 8 > )
	routes[ "cornerGardenShort" ].append( < 628, -346, 8 > )
	routes[ "cornerGardenShort" ].append( < 705, -778, 1 > )
	
	routes[ "backGardenShort" ] <- []
	routes[ "backGardenShort" ].append( < 1194, 132, 4 > )
	routes[ "backGardenShort" ].append( < 696, -143, 8 > )
	routes[ "backGardenShort" ].append( < 705, -778, 1 > )
	
	routes[ "farCratesMain" ] <- []
	routes[ "farCratesMain" ].append( < 998, 1432, 1 > )
	routes[ "farCratesMain" ].append( < -271, 943, 1 > )
	routes[ "farCratesMain" ].append( < -116, -564, 2 > )
	routes[ "farCratesMain" ].append( < 237, -504, 8 > )
	
	routes[ "truckBehind" ] <- []
	routes[ "truckBehind" ].append( < -791, 900, 1 > )
	routes[ "truckBehind" ].append( < -890, -704, 1 > )
	routes[ "truckBehind" ].append( < -373, -1137, 128 > )
	
	routes[ "sunCratesMain" ] <- []
	routes[ "sunCratesMain" ].append( < -520, 1835, 1 > )
	routes[ "sunCratesMain" ].append( < -271, 943, 1 > )
	routes[ "sunCratesMain" ].append( < -278, -693, 1 > )
	routes[ "sunCratesMain" ].append( < 143, -929, 8 > )
	
	routes[ "titanMain" ] <- []
	routes[ "titanMain" ].append( < -280, -28, 1 > )
	routes[ "titanMain" ].append( < -265, -669, 1 > )
	routes[ "titanMain" ].append( < -35, -769, 1 > )
	
	routes[ "dronesPathing" ] <- []
	routes[ "dronesPathing" ].append( < -175, -630, 1 > )
	routes[ "dronesPathing" ].append( < 494, -993, 8 > )
	routes[ "dronesPathing" ].append( < 1043, -710, 1 > )
	routes[ "dronesPathing" ].append( < 977, 1010, 8 > )
	routes[ "dronesPathing" ].append( < -130, 1026, 2 > )
}