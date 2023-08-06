global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnDrozAndDavisForFD )
	
	shopPosition = < 360, -1504, 264 >
	shopAngles = < 0, 90, 0 >
	FD_groundspawnPosition = < 248, -1979, 8 >
	FD_groundspawnAngles = < 0, 90, 0 >
	FD_CustomHarvesterLocation = < 512, -762, 1 >
	FD_DefenseLocation = < 822, -880, 1 >
	
	int index = 1
	array<vector> infantryspawns = []
	infantryspawns.append(< -675, 1509, 1 >)
	infantryspawns.append(< -364, 1530, 1 >)
	infantryspawns.append(< -419, 1840, 1 >)
	infantryspawns.append(< -233, 2273, 1 >)
	infantryspawns.append(< -571, 2179, 1 >)
	infantryspawns.append(< -777, 1969, 1 >)
	infantryspawns.append(< -718, 1642, 1 >)
	infantryspawns.append(< 48, 1394, 1 >)
	infantryspawns.append(< 1290, 1246, 1 >)
	infantryspawns.append(< 1000, 1472, 1 >)
	infantryspawns.append(< 1253, 2039, 1 >)
	infantryspawns.append(< 987, 2235, 1 >)
	infantryspawns.append(< 945, 1906, 1 >)
	infantryspawns.append(< 1383, 1976, 1 >)
	infantryspawns.append(< 170, 2339, 1 >)
	infantryspawns.append(< 553, 2247, 1 >)
	infantryspawns.append(< 275, 693, 1 >)
	infantryspawns.append(< 101, 396, 1 >)
	infantryspawns.append(< 1176, -125, 6 >)
	infantryspawns.append(< 1127, 500, 2 >)
	infantryspawns.append(< -691, 800, 1 >)
	infantryspawns.append(< -856, 1125, 1 >)
	infantryspawns.append(< -706, 1082, 1 >)
	infantryspawns.append(< 487, 2049, 265 >)
	
	array<vector> tickspawns = []
	tickspawns.append(< -623, 1602, 1 >)
	tickspawns.append(< -302, 2259, 1 >)
	tickspawns.append(< -651, 1962, 1 >)
	tickspawns.append(< 408, 2340, 8 >)
	tickspawns.append(< 1105, 2148, 1 >)
	tickspawns.append(< 925, 947, 13 >)
	tickspawns.append(< 911, 1714, 8 >)
	tickspawns.append(< 724, 2040, 265 >)
	
	array<vector> reaperspawns = []
	reaperspawns.append(< -480, 1675, 1 >)
	reaperspawns.append(< -795, 1754, 1 >)
	reaperspawns.append(< -811, 2049, 1 >)
	reaperspawns.append(< -451, 2250, 1 >)
	reaperspawns.append(< -226, 1891, 8 >)
	reaperspawns.append(< 1051, 1503, 1 >)
	reaperspawns.append(< 920, 1723, 8 >)
	reaperspawns.append(< 1231, 1967, 1 >)
	reaperspawns.append(< 964, 2251, 1 >)
	reaperspawns.append(< 1221, 2155, 1 >)
	reaperspawns.append(< 1349, 1284, 1 >)
	reaperspawns.append(< 1067, 1056, 1 >)
	reaperspawns.append(< 790, 1259, 1 >)
	
	array<vector> titanspawns = []
	titanspawns.append(< 1200, 1180, 1 >)
	titanspawns.append(< 822, 1040, 11 >)
	titanspawns.append(< 1114, 2102, 1 >)
	titanspawns.append(< -340, 2249, 1 >)
	titanspawns.append(< -776, 2050, 1 >)
	titanspawns.append(< -582, 1572, 1 >)
	
	int spawnamount
	
    array<WaveEvent> wave1
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		wave1.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		wave1.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave1.append(CreateSpawnDroneEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] + < 0, 0, 128>, < 0, 90, 0 > ,"dronesPathing",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave1.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave1.append(CreateDroppodSpectreEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave1.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	wave1.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",0))
    waveEvents.append(wave1)
	index = 1
	array<WaveEvent> wave2
	for( spawnamount = 0; spawnamount < 12; spawnamount++ )
	{
		wave2.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 12; spawnamount++ )
	{
		wave2.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateSpawnDroneEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] + < 0, 0, 128>, < 0, 90, 0 > ,"dronesPathing",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 12; spawnamount++ )
	{
		wave2.append(CreateDroppodSpectreEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateSpawnDroneEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] + < 0, 0, 128>, < 0, 90, 0 > ,"dronesPathing",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateDroppodTickEvent( tickspawns[ RandomInt( tickspawns.len() ) ],4,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, -90, 0> ,"titanMain",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 64; spawnamount++ )
	{
		wave2.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	wave2.append(CreateArcTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",0))
    waveEvents.append(wave2)
	index = 1
	array<WaveEvent> wave3
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		wave3.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSpawnDroneEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] + < 0, 0, 128>, < 0, 90, 0 > ,"dronesPathing",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodTickEvent( tickspawns[ RandomInt( tickspawns.len() ) ],4,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, -90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	
	wave3.append(CreateArcTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		wave3.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, -90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	
	wave3.append(CreateArcTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		wave3.append(CreateDroppodSpectreEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSpawnDroneEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] + < 0, 0, 128>, < 0, 90, 0 > ,"dronesPathing",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodTickEvent( tickspawns[ RandomInt( tickspawns.len() ) ],4,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, -90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	
	wave3.append(CreateNukeTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		wave3.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSpawnDroneEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] + < 0, 0, 128>, < 0, 90, 0 > ,"dronesPathing",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodTickEvent( tickspawns[ RandomInt( tickspawns.len() ) ],4,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, -90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	
	wave3.append(CreateNukeTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	wave3.append(CreateNukeTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	
	for( spawnamount = 0; spawnamount < 4; spawnamount++ )
	{
		wave3.append(CreateDroppodSpectreEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSpawnDroneEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] + < 0, 0, 128>, < 0, 90, 0 > ,"dronesPathing",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodTickEvent( tickspawns[ RandomInt( tickspawns.len() ) ],4,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, -90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	
	wave3.append(CreateNukeTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	wave3.append(CreateNukeTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	wave3.append(CreateNukeTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
	wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
	wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	
	for( spawnamount = 0; spawnamount < 80; spawnamount++ )
	{
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateNukeTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	
	wave3.append(CreateArcTitanEvent( titanspawns[ RandomInt( titanspawns.len() ) ] , < 0, 90, 0> ,"titanMain",0))
    waveEvents.append(wave3)
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