global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnDrozAndDavisForFD )
	
	PlaceFDShop( < 538, 1675, 136 >, < 0, -90, 0 > )
	SetFDGroundSpawn( < -320, 1500, 272 >, < 0, 120, 0 > )
	OverrideFDHarvesterLocation( < 173, 2242, 1 > )
	SetFDAIDefenseLocation( < 172, 1805, 1 > )
	
	array<vector> infantryspawns = []
	infantryspawns.append( < -514, -553, 1 > )
	infantryspawns.append( < -734, -725, 1 > )
	infantryspawns.append( < -847, -1208, 1 > )
	infantryspawns.append( < -714, -1556, 1 > )
	infantryspawns.append( < -641, -1869, 1 > )
	infantryspawns.append( < 79, -1821, 1 > )
	infantryspawns.append( < 491, -1809, 1 > )
	infantryspawns.append( < 826, -1844, 1 > )
	infantryspawns.append( < 925, -1396, 136 > )
	infantryspawns.append( < 829, -1568, 136 > )
	infantryspawns.append( < 211, -1504, 1 > )
	infantryspawns.append( < 7, -1202, 1 > )
	infantryspawns.append( < 198, -970, 1 > )
	infantryspawns.append( < 528, -889, 1 > )
	infantryspawns.append( < 300, -759, 1 > )
	infantryspawns.append( < 658, -667, 1 > )
	infantryspawns.append( < 537, -485, 1 > )
	infantryspawns.append( < 246, -455, 1 > )
	infantryspawns.append( < -84, -519, 1 > )
	infantryspawns.append( < -45, -796, 1 > )
	infantryspawns.append( < -70, -1556, 164 > )
	infantryspawns.append( < -331, -1729, 136 > )
	infantryspawns.append( < -341, 204, 176 > )
	
	array<vector> tickspawns = []
	tickspawns.append( < 140, -472, 1 > )
	tickspawns.append( < -587, -1275, 272 > )
	tickspawns.append( < 242, -1236, 1 > )
	tickspawns.append( < -192, -522, 1 > )
	tickspawns.append( < 298, -188, 1 > )
	tickspawns.append( < 298, -188, 208 > )
	tickspawns.append( < -733, -1369, 1 > )
	tickspawns.append( < 686, -1944, 1 > )
	tickspawns.append( < 419, -1026, 1 > )
	
	array<vector> reaperspawns = []
	reaperspawns.append( < 159, -868, 1 > )
	reaperspawns.append( < -181, -716, 1 > )
	reaperspawns.append( < -476, -477, 1 > )
	reaperspawns.append( < -756, -772, 1 > )
	reaperspawns.append( < -676, -1506, 1 > )
	reaperspawns.append( < 246, -1446, 1 > )
	reaperspawns.append( < 98, -1884, 1 > )
	reaperspawns.append( < 624, -1784, 1 > )
	
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
		WaveSpawn_WaitEnemyAliveAmount( wave1, 20 )
	}
	for( spawnamount = 0; spawnamount < 12; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 20 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 20 )
	}
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 20 )
	}
	WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
	
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
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
		WaveSpawn_InfantrySpawn( wave2, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
	}
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
		WaveSpawn_ReaperSpawn( wave2, "Reaper", reaperspawns.getrandom(), 90, "reapersMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
		WaveSpawn_InfantrySpawn( wave2, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 20 )
	}
	WaveSpawn_ReaperSpawn( wave2, "Reaper", reaperspawns.getrandom(), 90, "reapersMain", RandomFloatRange( 0.1, 0.6 ) )
	
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
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
		WaveSpawn_InfantrySpawn( wave3, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), 90, "reapersMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
		WaveSpawn_InfantrySpawn( wave3, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
	}
	for( spawnamount = 0; spawnamount < 32; spawnamount++ )
	{
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), 90, "reapersMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 32 )
	}
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), 90, "reapersMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
		WaveSpawn_InfantrySpawn( wave3, "Ticks", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
	}
	for( spawnamount = 0; spawnamount < 64; spawnamount++ )
	{
		WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), 90, "reapersMain", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 32 )
	}
	WaveSpawn_ReaperSpawn( wave3, "Reaper", reaperspawns.getrandom(), 90, "reapersMain", RandomFloatRange( 0.1, 0.6 ) )
	
    WaveSpawnEvents.append( wave3 )
}

void function SpawnDrozAndDavisForFD()
{
	SpawnDrozFD( < 317, 1485, 1 >, < 0, -90, 0 > )
	SpawnDavisFD( < 252, 1485, 1 >, < 0, -90, 0 > )
	SpawnLFMapTitan( < 549, 1144, 1 >, < 0, 180, 0 > )
}

void function RegisterCustomFDContent()
{
	AddLoadoutCrate( TEAM_MILITIA, < -464, 1643, 272 >, < 0, 0, 0 > )
	SpawnFDHeavyTurret( < 504, 1616, 272 >, < 0, -135, 0 > )
	
	routes[ "enclosedStairsLong" ] <- []
	routes[ "enclosedStairsLong" ].append( < 574, -1293, 136 > )
	routes[ "enclosedStairsLong" ].append( < 847, -241, 208 > )
	routes[ "enclosedStairsLong" ].append( < 803, 616, 208 > )
	routes[ "enclosedStairsLong" ].append( < 502, 2000, 136 > )
	
	routes[ "underpassStraight" ] <- []
	routes[ "underpassStraight" ].append( < 247, -904, 1 > )
	routes[ "underpassStraight" ].append( < 255, 391, 6 > )
	routes[ "underpassStraight" ].append( < 178, 1870, 1 > )
	
	routes[ "rampsMain" ] <- []
	routes[ "rampsMain" ].append( < -787, -1089, 1 > )
	routes[ "rampsMain" ].append( < -645, -188, 136 > )
	routes[ "rampsMain" ].append( < -293, 2340, 1 > )
	
	routes[ "middleUp" ] <- []
	routes[ "middleUp" ].append( < -242, 208, 176 > )
	routes[ "middleUp" ].append( < -91, 455, 208 > )
	routes[ "middleUp" ].append( < 266, 599, 208 > )
	routes[ "middleUp" ].append( < 1029, 1617, 136 > )
	routes[ "middleUp" ].append( < 554, 1420, 1 > )
	routes[ "middleUp" ].append( < 277, 1865, 1 > )
	
	routes[ "stairsToRamp" ] <- []
	routes[ "stairsToRamp" ].append( < 604, -692, 1 > )
	routes[ "stairsToRamp" ].append( < 960, -1360, 136 > )
	routes[ "stairsToRamp" ].append( < 772, -224, 208 > )
	routes[ "stairsToRamp" ].append( < -77, -28, 208 > )
	routes[ "stairsToRamp" ].append( < -119, 464, 208 > )
	routes[ "stairsToRamp" ].append( < -738, 600, 136 > )
	routes[ "stairsToRamp" ].append( < -354, 1506, 8 > )
	routes[ "stairsToRamp" ].append( < 21, 1690, 1 > )
	
	routes[ "reapersMain" ] <- []
	routes[ "reapersMain" ].append( < -809, -369, 101 > )
	routes[ "reapersMain" ].append( < -760, -116, 136 > )
	routes[ "reapersMain" ].append( < -827, 726, 136 > )
	routes[ "reapersMain" ].append( < -55, 1123, 1 > )
	routes[ "reapersMain" ].append( < 206, 1857, 1 > )
}