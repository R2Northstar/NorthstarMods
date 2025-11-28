global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
    PlaceFDShop( < -913, 3933, 320 >, < 0, -15, 0 > )
	SetFDDropshipSpawn( < -331, 3791, 141 >, < 0, -180, 0 > )
	SetFDGroundSpawn( < -644, 4469, 318 >, < 0, -145, 0 > )
	
	AddFDDropPodSpawn( < -136, 3758, 200 > )
	AddFDDropPodSpawn( < -2374, 4565, 120 > )
	AddFDDropPodSpawn( < -1459, 2416, 399 > )
	
	AddWaveAnnouncement( "fd_introEasy" )
	AddWaveAnnouncement( "fd_waveTypeCloakDrone" )
	AddWaveAnnouncement( "fd_soonNukeTitans" )
	AddWaveAnnouncement( "fd_waveTypeTitanMortar" )
	AddWaveAnnouncement( "fd_incReaperClump" )
	
	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	WaveSpawn_Announce( wave1, "MortarSpectre", 0.0 )
	if( RandomInt( 100 ) >= 50 )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1329, 4456, 141 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2305, 2042, 128 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2464, 3354, 129 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 895, 2330, 122 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 1485, 3100, 200 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 1738, 2588, 56 >, 0.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
		
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 3750, -2068, 200 >, 0.0, "", 1.0 )
		WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 2863, -1938, 200 >, 90, "", 1.5 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1529, -1644, 128 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 3494, -1511, 200 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2874, -1148, 200 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 3359, -2836, 200 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2129, -959, 120 >, 0.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
		
		WaveSpawn_InfantrySpawn( wave1, "Stalker", < 603, -233, 112 >, 0.0, "", 1.0, "fd_waveTypeStalkers" )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -593, -268, 128 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -513, -900, 32 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 97, -2104, 16 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 277, -926, 128 >, 0.0, "", 1.5 )
		WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 1287, -109, 128 >, 90, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 28, 454, 122 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -1392, 162, 128 >, 0.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
		
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -3055, -191, 98 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -3710, 557, 168 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", < -3645, 1859, 120>, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -2642, 1017, 120 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -4376, 1276, 168 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -4373, 2237, 40 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -4990, 345, 128 >, 0.0, "", 1.5 )
		WaveSpawn_ReaperSpawn( wave1, "TickReaper", < -4386, 4153, 51 >, -15, "" )
	}
	else
	{
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 3750, -2068, 200 >, 0.0, "", 1.0 )
		WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 2863, -1938, 200 >, 90, "", 1.5 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1529, -1644, 128 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 3494, -1511, 200 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2874, -1148, 200 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 3359, -2836, 200 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2129, -959, 120 >, 0.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
		
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -3055, -191, 98 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -3710, 557, 168 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", < -3645, 1859, 120>, 0.0, "", 1.0, "fd_waveTypeStalkers" )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -2642, 1017, 120 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -4376, 1276, 168 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -4373, 2237, 40 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -4990, 345, 128 >, 0.0, "", 1.5 )
		WaveSpawn_ReaperSpawn( wave1, "TickReaper", < -4386, 4153, 51 >, -15, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
		
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1329, 4456, 141 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2305, 2042, 128 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2464, 3354, 129 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 895, 2330, 122 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 1485, 3100, 200 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 1738, 2588, 56 >, 0.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
		
		WaveSpawn_InfantrySpawn( wave1, "Stalker", < 603, -233, 112 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -593, -268, 128 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -513, -900, 32 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 97, -2104, 16 >, 0.0, "", 0.6 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 277, -926, 128 >, 0.0, "", 1.5 )
		WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 1287, -109, 128 >, 90, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 28, 454, 122 >, 0.0, "", 1.0 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -1392, 162, 128 >, 0.0, "" )
	}
	
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 984, 1687, 135 >, 180, "", 0.8, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 330, 1195, 104 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -393, 1047, 104 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 516, 2054, 137 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -759, 1753, 128 >, 0.0, "" )
	
	WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
    array<WaveSpawnEvent> wave2
	WaveSpawn_TitanSpawn( wave2, "Tone", < 2445, 2661, 56 >, 180, "", 1.5, "fd_waveTypeTitanReg" )
	WaveSpawn_TitanSpawn( wave2, "Tone", < -881, 692, 120 >, 90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -2805, 385, 176 >, 0.0, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Tone", < 2058, -103, 120 >, 130, "", 2.5 )
	WaveSpawn_TitanSpawn( wave2, "Ion", < -3985, -268, 168 >, 90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 1466, 3266, 200 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 672, -535, 112 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1680, -234, 128 >, 0.0, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -3923, 2719, 120 >, -105, "", 0.8, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < -1541, 794, 2580 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < 2445, 2661, 2580 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < 1669, -1055, 2580 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 8 )
	
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 1311, -197, 128 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Monarch", < 2445, 2661, 56 >, 180, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -3765, -676, 168 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -3985, -268, 168 >, 90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -2092, 1463, 119 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Monarch", < -881, 692, 120 >, 90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -428, 1298, 104 >, -45, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1288, 217, 128 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < -1541, 794, 2580 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < 1669, -1055, 2580 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < -881, 692, 2580 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 8 )
	
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -2669, -933, 97 >, 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -3227, -672, 99 >, 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -4085, -147, 168 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave2, "ArcTitan", < -881, 692, 120 >, 90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -4689, 280, 136 >, 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 1412, 122, 128 >, 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 2105, 1, 120 >, 130, "", 3.5 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < -1541, 794, 2580 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < 1669, -1055, 2580 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "CloakDrone", < 1490, 3130, 2580 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 8 )
	
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -1699, -390, 128 >, 90, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 3738, -1022, 213 >, 125, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 495, 1588, 128 >, 45, "", 1.4 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 2206, 0, 120 >, 180, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1490, 3130, 200 >, 0.0, "" )
	
	WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave3
	WaveSpawn_TitanSpawn( wave3, "Ion", < 3554, 926, 171 >, 180, "", 1.0, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_TitanSpawn( wave3, "Ion", < 1581, -2287, 136 >, 90, "", 1.0, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -2114,- 673, 17 >, 90, "", 2.5, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 3554, 926, 171 >, 180, "", 1.0, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 1581, -2287, 136 >, 90, "", 1.0, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -2114,- 673, 17 >, 90, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 905, -2813, 51 >, 131, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -1295, -289, 128 >, 90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -3765, -644, 168 >, 131, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3738, -1022, 213 >, 125, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 0 )
	
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 3448, 354, 160 >, 135, "", 5.0, "fd_waveTypeTitanNuke" )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 3742, -546, 196 >, 180, "", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 1734, 432, 120 >, 180, "", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 2351, 3434, 141 >, 180, "", 10.0 )
	WaveSpawn_TitanSpawn( wave3, "Sniper", < -1253, -291, 128 >, 90, "", 2.5, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < 2766, 1723, 120 >, 180, "", 2.5, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_TitanSpawn( wave3, "Scorch", < 2035, 3927, 129 >, 180, "", 2.0 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 3567, -1036, 200 >, 180, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 3537, -1442, 200 >, 135, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 2855, -2081, 200 >, 135, "", 5.0, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 0 )
	
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -1246, 186, 128 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -2987, -703, 92 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -3911, -271, 168 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -4492, -187, 168 >, 90, "", 10.0 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -4183, -632, 168 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -2562, -1210, 105 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 2121, -3630, 192 >, 90, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 3667, 1015, 171 >, 180, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 2578, 3266, 132 >, 180, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 0 )
	
	WaveSpawn_Announce( wave3, "EliteTitans", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_TitanSpawn( wave3, "Scorch", < -2892, -1269, 107 >, 90, "", 0.6, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Ion", < -2621, -1261, 107 >, 90, "", 0.5, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Ion", < -3184, -1291, 115 >, 90, "", 1.0, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD, eFDTT.TITAN_ELITE )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 0 )
	
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 3566, -2058, 200 >, 90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 2858, -2095, 200 >, 90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 3791, -993, 210 >, 180, "", 2.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3666, -1772, 200 >, 90, "", 0.2 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2862, -1274, 201 >, 90, "", 0.3 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3432, -1335, 200 >, 90, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3954, -2189, 199 >, 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3465, -1828, 201 >, 90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2601, -2129, 200 >, 90, "", 2.0 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 1729, -2497, 128 >, 90, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3542, -1556, 202 >, 90, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3649, -1110, 201 >, 90, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2875, -1728, 200 >, 90, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 1508, -2593, 128 >, 90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2142, -2629, 193 >, 90, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 3721, -666, 194 >, 90, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3386, -633, 196 >, 90, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3305, -1001, 200 >, 90, "", 0.2 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3643, -2083, 200 >, 90, "", 3.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 3537, -1321, 200 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 3548, -1793, 202 >, 180, "" )
	
	WaveSpawnEvents.append( wave3 )
	
	/*
	 __      __                 _ _  
	 \ \    / /__ _ __ __ ___  | | | 
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_| 
	
	*/
    array<WaveSpawnEvent> wave4
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < 3554, 926, 171 >, 180, "", 0.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < 1581, -2287, 136 >, 90, "", 0.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -2114,- 673, 17 >, 90, "", 1.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 3567, -1036, 200 >, 180, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 1729, -2509, 128 >, 90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -3366, -652, 123 >, 90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 1714, 4170, 129 >, 180, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 308, 935, 103 >, 90, "", 0.5, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 3941, -1996, 200 >, 180, "", 0.5, "", 0.0, eFDSD.EASY | eFDSD.NORMAL | eFDSD.HARD )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 1 )
	
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -1263, -408, 130 >, 90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -881, 692, 120 >, 90, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -2445, 2169, 128 >, 75, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < 1873, 3508, 141 >, 45, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -3366, -652, 123 >, 90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 1714, 4170, 129 >, 180, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 1729, -2509, 128 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 3567, -1036, 200 >, 180, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 3537, -1442, 200 >, 135, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 2855, -2081, 200 >, 135, "", 5.0 )
	WaveSpawn_Announce( wave4, "EliteTitans", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Ion", < 1288, -154, 128 >, 90, "", 0.8, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Ronin", < -2661, -579, 96 >, 90, "", 0.8, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Tone", < 2687, 2571, 56 >, 180, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )
	
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -5017, 681, 128 >, 90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -3725, -521, 168 >, 90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 975, -2801, 58 >, 90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 2121, -3630, 192 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 3667, 1015, 171 >, 180, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 2578, 3266, 132 >, 180, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -490, -719, 19 >, 180, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < 2143, -170, 120 >, 135, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -583, -332, 128 >, 90, "", 0.2 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 495, 1596, 127 >, 75, "" )
	
	WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave5
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.8, "fd_waveTypeReapers", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 0.6, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.8, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4049, -239, 177 >, 90, "", 1.2, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 1.0, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -3760, -564, 168 >, 90, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 0.8, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4049, -239, 177 >, 90, "", 1.0, "", 300.0 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -4185, -564, 168 >, 90, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 3554, 926, 171 >, 180, "", 0.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 0.8, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4049, -239, 177 >, 90, "", 1.0, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.8, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -3346, -660, 118 >, 90, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 1.2, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4049, -239, 177 >, 90, "", 0.8, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.5, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 1581, -2287, 136 >, 90, "", 0.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 3567, -1036, 200 >, 180, "", 1.0, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 1729, -2509, 128 >, 90, "", 1.0, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 1714, 4170, 129 >, 180, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.8, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.8, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 1.0, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -4890, 493, 128 >, 90, "", 0.8, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 0.6, "", 300.0 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -2981, -730, 92 >, 90, "", 0.8, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 0.4, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 1.0, "", 300.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -4511, -81, 168 >, 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -4925, 245, 127 >, 90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 0.8, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4890, 493, 128 >, 90, "", 0.5, "", 300.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4049, -239, 177 >, 90, "", 0.8, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 1.0, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -2952, -667, 93 >, 90, "", 0.8, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -4049, -239, 177 >, 90, "", 0.4, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 1.0, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -3977, -406, 177 >, 135, "", 0.8, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -4049, -239, 177 >, 90, "", 0.6, "", 300.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.5, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2114,- 673, 17 >, 90, "", 1.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -1699, -390, 128 >, 90, "", 1.2, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 3738, -1022, 213 >, 125, "", 0.8, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 495, 1588, 128 >, 45, "", 1.4, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 2206, 0, 120 >, 180, "", 2.5, "", 0.0, eFDSD.MASTER | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2692, -623, 93 >, 180, "", 0.8, "fd_incTitansNukeClump" )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.5, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -3130, -758, 98 >, 90, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.5, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2911, -949, 98 >, 90, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.5, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2667, -1124, 100 >, 180, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.5, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -3105, -657, 96 >, 90, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.5, "", 440.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2798, -981, 97 >, 90, "", 0.6, "", 440.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -3285, -1340, 114 >, 135, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2184, -772, 33 >, 90, "" )
	
	WaveSpawnEvents.append( wave5 )
}

void function RegisterCustomFDContent()
{
	AddFDCustomTitanStart( < -2221, 5230, 128 >, < 0, -105, 0 > )
	AddFDCustomTitanStart( < -3058, 4741, 102 >, < 0, -15, 0 > )
	
	//Add those OOB because some "smart" fellas wont stop climbing these places to snipe with Charge Rifle/Archer and do nothing else
	AddOutOfBoundsTriggerWithParams( < -75, 1146, 1360 >, 160, 320 ) //Center Radio Tower
	AddOutOfBoundsTriggerWithParams( < -1720, 1243, 1360 >, 80, 256 ) //Sea Food building Antenna
}