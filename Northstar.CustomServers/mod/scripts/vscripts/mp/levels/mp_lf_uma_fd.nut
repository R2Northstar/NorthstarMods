global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnDrozAndDavisForFD )
	
	shopPosition = < -169, -1558, 160 >
	shopAngles = < 0, 0, 0 >
	FD_groundspawnPosition = < -612, -1573, 160 >
	FD_groundspawnAngles = < 0, -45, 0 >
	FD_CustomHarvesterLocation = < 1200, -1765, 4 >
	FD_DefenseLocation = < 906, -1438, 70 >
	
	int index = 1
	
	array<vector> infantryspawns = []
	infantryspawns.append(< 1074, 2047, 4 >)
	infantryspawns.append(< 1305, 2160, 6 >)
	infantryspawns.append(< 1163, 1763, 136 >)
	infantryspawns.append(< 1006, 1565, 136 >)
	infantryspawns.append(< 593, 1718, 11 >)
	infantryspawns.append(< 669, 2226, 15 >)
	infantryspawns.append(< 262, 2090, 4 >)
	infantryspawns.append(< 30, 2322, 4 >)
	infantryspawns.append(< 2, 1830, 8 >)
	infantryspawns.append(< 205, 1638, 4 >)
	infantryspawns.append(< -245, 1318, 8 >)
	infantryspawns.append(< -356, 1523, 20 >)
	infantryspawns.append(< -13, 1850, 11 >)
	infantryspawns.append(< 110, 1634, 4 >)
	
	array<vector> reaperspawns = []
	reaperspawns.append(< -705, 1128, 160 >)
	reaperspawns.append(< -833, 1295, 160 >)
	reaperspawns.append(< -675, 1526, 160 >)
	reaperspawns.append(< 481, 706, 6 >)
	reaperspawns.append(< 743, 583, 5 >)
	reaperspawns.append(< 875, 768, 17 >)
	reaperspawns.append(< 962, 515, 10 >)
	reaperspawns.append(< -52, 1715, 10 >)
	reaperspawns.append(< -370, 1489, 18 >)
	reaperspawns.append(< -195, 1397, 32 >)
	reaperspawns.append(< -297, 1135, 20 >)
	
	int spawnamount
	
    array<WaveEvent> wave1
	for( spawnamount = 0; spawnamount < 8; spawnamount++ )
	{
		wave1.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave1.append(CreateDroppodSpectreEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave1.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave1.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave1.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave1.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave1.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	wave1.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",0))
	waveEvents.append(wave1)
	index = 1
	array<WaveEvent> wave2
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave2.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"bridgeFlank",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave2.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"bridgeFlank",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave2.append(CreateDroppodSpectreEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"bridgeFlank",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave2.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",index++))
		wave2.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave2.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	wave2.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",0))
	waveEvents.append(wave2)
	index = 1
	array<WaveEvent> wave3
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave3.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"lowerTunnelStraight",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateDroppodStalkerEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"centerAlley",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave3.append(CreateDroppodGruntEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"centerAlley",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 64; spawnamount++ )
	{
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 16; spawnamount++ )
	{
		wave3.append(CreateDroppodSpectreEvent( infantryspawns[ RandomInt( infantryspawns.len() ) ] ,"upperTunnelStraight",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	for( spawnamount = 0; spawnamount < 128; spawnamount++ )
	{
		wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",index++))
		wave3.append(CreateWaitForTimeEvent( RandomFloatRange( 0.1, 0.6 ),index++))
		wave3.append(CreateWaitUntilAliveEvent( 20, index++ ) )
	}
	wave3.append(CreateSuperSpectreEvent( reaperspawns[ RandomInt( reaperspawns.len() ) ] , < 0, 90, 0> ,"",0))
	waveEvents.append(wave3)
}

void function SpawnDrozAndDavisForFD()
{
	SpawnDrozFD( < -101, -1598, 24 >, < 0, 0, 0 > )
	SpawnDavisFD( < -148, -1598, 24 >, < 0, 0, 0 > )
	SpawnLFMapTitan( < 262, -1896, 19 >, < 0, 90, 0 > )
}

void function RegisterCustomFDContent()
{
	AddLoadoutCrate( TEAM_MILITIA, < -425, -1630, 160 >, < 0, 90, 0 > )
	SpawnFDHeavyTurret( < 728, -1359, 328 >, < 0, 90, 0 > )
	
	routes[ "bridgeFlank" ] <- []
	routes[ "bridgeFlank" ].append( < 1115, 2068, 4 > )
	routes[ "bridgeFlank" ].append( < 690, 1073, 136 > )
	routes[ "bridgeFlank" ].append( <  913, -214, 136 > )
	routes[ "bridgeFlank" ].append( < 1270, -921, 136 > )
	
	routes[ "centerAlley" ] <- []
	routes[ "centerAlley" ].append( < 569, 1827, 16 > )
	routes[ "centerAlley" ].append( < 336, 839, 20 > )
	routes[ "centerAlley" ].append( < 877, 365, 11 > )
	routes[ "centerAlley" ].append( < 557, -714, 25 > )
	routes[ "centerAlley" ].append( < 1248, -1298, 4 > )
	
	routes[ "lowerTunnelStraight" ] <- []
	routes[ "lowerTunnelStraight" ].append( < -484, 1326, 26 > )
	routes[ "lowerTunnelStraight" ].append( < -328, 768, 14 > )
	routes[ "lowerTunnelStraight" ].append( < -326, -386, 52 > )
	routes[ "lowerTunnelStraight" ].append( < 154, -1185, 6 > )
	routes[ "lowerTunnelStraight" ].append( < 733, -1876, 5 > )
	
	routes[ "lowerTunnelStraight2" ] <- []
	routes[ "lowerTunnelStraight2" ].append( < -7, 1741, 4 > )
	routes[ "lowerTunnelStraight2" ].append( < -328, 768, 14 > )
	routes[ "lowerTunnelStraight2" ].append( < -326, -386, 52 > )
	routes[ "lowerTunnelStraight2" ].append( < 154, -1185, 6 > )
	routes[ "lowerTunnelStraight2" ].append( < 733, -1876, 5 > )
	
	routes[ "upperTunnelStraight" ] <- []
	routes[ "upperTunnelStraight" ].append( < -602, 1299, 160 > )
	routes[ "upperTunnelStraight" ].append( < -660, 354, 160 > )
	routes[ "upperTunnelStraight" ].append( < -811, -1136, 160 > )
	routes[ "upperTunnelStraight" ].append( < 244, -1308, 4 > )
	routes[ "upperTunnelStraight" ].append( < 751, -1773, 4 > )
	
	routes[ "centerTruck" ] <- []
	routes[ "centerTruck" ].append( < 698, 357, 102 > )
	routes[ "centerTruck" ].append( < 548, -725, 29 > )
	routes[ "centerTruck" ].append( < 1244, -1414, 4 > )
	
	routes[ "longwayBridge" ] <- []
	routes[ "longwayBridge" ].append( < 1142, 1476, 136 > )
	routes[ "longwayBridge" ].append( < 697, 1055, 136 > )
	routes[ "longwayBridge" ].append( < 913, -214, 136 > )
	routes[ "longwayBridge" ].append( < 1114, -905, 136 > )
	routes[ "longwayBridge" ].append( < 473, -1241, 10 > )
	routes[ "longwayBridge" ].append( < 526, -1831, 51 > )
}