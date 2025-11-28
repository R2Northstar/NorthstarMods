global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnDrozAndDavisForFD )
	
	PlaceFDShop( < 464, -616, 136 >, < 0, -90, 0 > )
	SetFDGroundSpawn( < 665, -689, 200 >, < 0, 135, 0 > )
	OverrideFDHarvesterLocation( < 823, -1729, 10 > )
	SetFDAIDefenseLocation( < 471, -932, 132 > )
	
	array<vector> infantryspawns = []
	infantryspawns.append( < 201, 2066, 6 > )
	infantryspawns.append( < 835, 2300, 31 > )
	infantryspawns.append( < 425, 1661, 4 > )
	infantryspawns.append( < -190, 1324, 20 > )
	infantryspawns.append( < -773, 822, 10 > )
	infantryspawns.append( < 72, 1413, 28 > )
	infantryspawns.append( < 873, 1731, 14 > )
	infantryspawns.append( < 1123, 2109, 4 > )
	infantryspawns.append( < 1289, 1737, 8 > )
	infantryspawns.append( < 944, 1083, 101 > )
	infantryspawns.append( < 592, 1180, 126 > )
	
	array<vector> titanspawns = []
	titanspawns.append( < -714, 2151, 70 > )
	titanspawns.append( < -243, 2228, 21 > )
	
	int spawnamount
	
	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
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
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	WaveSpawn_TitanSpawn( wave2, "Tone", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	WaveSpawn_TitanSpawn( wave2, "Ion", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	WaveSpawn_TitanSpawn( wave2, "Scorch", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 28 )
	}
	WaveSpawn_InfantrySpawn( wave2, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
	
	WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave3
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_TitanSpawn( wave3, "Tone", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	WaveSpawn_TitanSpawn( wave3, "Monarch", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		WaveSpawn_InfantrySpawn( wave3, "Stalker", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Spectre", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
		WaveSpawn_InfantrySpawn( wave3, "Tick", infantryspawns.getrandom(), 0.0, "", RandomFloatRange( 0.1, 0.6 ) )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 28 )
	}
	WaveSpawn_TitanSpawn( wave3, "Nuke", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_TitanSpawn( wave3, "Monarch", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	WaveSpawn_TitanSpawn( wave3, "Scorch", titanspawns.getrandom(), -90, "titanLane", RandomFloatRange( 0.1, 0.6 ) )
	
	WaveSpawnEvents.append( wave3 )
}

void function SpawnDrozAndDavisForFD()
{
	SpawnDrozFD( < 764, -1943, 25 >, < 0, 90, 0 > )
	SpawnDavisFD( < 933, -1933, 27>, < 0, 90, 0 > )
	SpawnLFMapTitan( < -758, -1613, 17 >, < 0, 35, 0> )
}

void function RegisterCustomFDContent()
{
	AddLoadoutCrate( TEAM_MILITIA, < 344, -716, 136 >, < 0, 0, 0 > )
	SpawnFDHeavyTurret( < 387, -1894, 6 >, < 0, 90, 0 > )
	
	routes[ "mainValley" ] <- []
	routes[ "mainValley" ].append( < -402, 1304, 124 > )
	routes[ "mainValley" ].append( < 27, 831, 13 > )
	routes[ "mainValley" ].append( < -238, -39, 80 > )
	routes[ "mainValley" ].append( < 175, -897, 133 > )
	routes[ "mainValley" ].append( < 777, -1126, 113 > )
	
	routes[ "valleySideway" ] <- []
	routes[ "valleySideway" ].append( < 539, 2044, 7 > )
	routes[ "valleySideway" ].append( < 28, 885, 12 > )
	routes[ "valleySideway" ].append( < 108, -173, 9 > )
	routes[ "valleySideway" ].append( < 995, -194, 12 > )
	routes[ "valleySideway" ].append( < 1249, -1630, 8 > )
	
	routes[ "mainSideway" ] <- []
	routes[ "mainSideway" ].append( < 1009, 1223, 103 > )
	routes[ "mainSideway" ].append( < 1343, 1637, 4 > )
	routes[ "mainSideway" ].append( < 1343, 526, 6 > )
	routes[ "mainSideway" ].append( < 957, -105, 11 > )
	routes[ "mainSideway" ].append( < 1223, -1246, 7 > )
	
	routes[ "titanLane" ] <- []
	routes[ "titanLane" ].append( < -567, 2145, 76 > )
	routes[ "titanLane" ].append( < -238, 1014, 33 > )
	routes[ "titanLane" ].append( < -740, 216, 20 > )
	routes[ "titanLane" ].append( < -746, -1225, 6 > )
	routes[ "titanLane" ].append( < 397, -1561, 16 > )
}