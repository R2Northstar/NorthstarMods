global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	
    shopPosition = < -9423, -2316, 764 >
	shopAngles = <0, 90, 0>
	FD_spawnPosition = < -8942, -2593, 1755 >
	FD_spawnAngles = < 0, 90, 0 >
	FD_groundspawnPosition = < -8230, -1671, 725 >
	FD_groundspawnAngles = < 0, -100, 0 >
	FD_CustomHarvesterLocation = < -8710, -2372, 691 >
	
	FD_DropPodSpawns.append(< -10389, -1497, 600 >)
	FD_DropPodSpawns.append(< -8705, -3011, 638 >)
	FD_DropPodSpawns.append(< -9712, -2317, 1005 >)

	int index = 1

    array<WaveEvent> wave1
	wave1.append(CreateWaitForTimeEvent( 1.0, 0 ) )
    waveEvents.append(wave1)
	index = 1
	array<WaveEvent> wave2
	wave2.append(CreateWaitForTimeEvent( 1.0, 0 ) )
    waveEvents.append(wave2)
	index = 1
	array<WaveEvent> wave3
	wave3.append(CreateWaitForTimeEvent( 1.0, 0 ) )
    waveEvents.append(wave3)
	index = 1
	array<WaveEvent> wave4
	wave4.append(CreateWaitForTimeEvent( 1.0, 0 ) )
    waveEvents.append(wave4)
	index = 1
	array<WaveEvent> wave5
	wave5.append(CreateWaitForTimeEvent( 1.0, 0 ) )
    waveEvents.append(wave5)
}

void function RegisterCustomFDContent()
{
	array<entity> dropshipSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_dropship_start" )
	foreach ( entity dropshipSpawn in dropshipSpawns )
		dropshipSpawn.Destroy()
	
	AddFDCustomShipStart( < -9153, -1853, 1851 >, < 0, 0, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < -8855, -2728, 1851 >, < 0, 55, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < -655, -1239, 2671 >, < 0, 180, 0 >, TEAM_IMC )
	AddFDCustomShipStart( < -1052, -1799, 2671 >, < 0, 135, 0 >, TEAM_IMC )
	
	entity Prowler1 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -6615, 1631, 1359 >,< 0, 0, 0 > )
	entity Prowler2 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -6545, 1874, 1359 >,< 0, 0, 0 > )
	entity Prowler3 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -6153, 1392, 1365 >,< 0, 0, 0 > )
	entity Prowler4 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -5688, 1545, 1355 >,< 0, 0, 0 > )
	DispatchSpawn( Prowler1 )
	DispatchSpawn( Prowler2 )
	DispatchSpawn( Prowler3 )
	DispatchSpawn( Prowler4 )
	
	SpawnFDHeavyTurret( < -7735, -1932, 965 >, < 0, 30, 0 >, < -7766, -1763, 725 >, < 0, 30, 0 > )
}