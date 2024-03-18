global function initFrontierDefenseData
void function initFrontierDefenseData()
{
    PlaceFDShop( < 3314, -846, -256 >, < 0, -45, 0 > )
	SetFDDropshipSpawn( < 1664, 404, 0 >, < 0, -90, 0 > )
	SetFDGroundSpawn( < 1869, -938, -63 >, < 0, 90, 0 > )
	
	AddFDDropPodSpawn( < 3424, -523, 8 > )
	AddFDDropPodSpawn( < 2266, 584, 56 > )
	AddFDDropPodSpawn( < 3154, -1491, -63 > )
	
	AddWaveAnnouncement( "fd_introEasy" )
	AddWaveAnnouncement( "fd_waveTypeTitanReg" )
	AddWaveAnnouncement( "fd_introMedium" )
	AddWaveAnnouncement( "fd_waveComboNukeMortar" )
	AddWaveAnnouncement( "fd_introHard" )
	
	AddOutOfBoundsTriggerWithParams( < 1935, -752, 1382 >, 160, 512 ) //Add OOB because some "smart" fellas wont stop climbing that water tank tower to snipe with Charge Rifle/Archer and do nothing else
	AddFDCustomProp( $"models/containers/container_medium_tanks_blue.mdl", < 184, 120, -8 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/containers/container_medium_tanks_blue.mdl", < 553, -427, -8 >, < 0, 0, 0 > )
	AddFDCustomTitanStart( < 3668, -174, -347 >, < 0, 135, 0 > )
	AddFDCustomTitanStart( < 432, -1397, 0 >, < 0, 45, 0 > )
	
	AddStationaryAIPosition( < -295, 3262, -128>, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < 1844, 4549, -130>, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < 3790, -2236, -128>, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < 485, 2651, -241>, eStationaryAIPositionTypes.MORTAR_SPECTRE )

	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 386, 2347, -257 >, 0.0, "", 1.4, "fd_waveTypeInfantry" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2465, 2750, -224 >, 0.0, "", 1.6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1351, 2342, -257 >, 0.0, "", 1.8 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 883, 1423, 6 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2718, -2737, -150 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 3792, -2984, -128 >, 0.0, "", 1.4 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 4077, -3882, -373 >, 0.0, "", 1.8 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 4196, -4507, -385 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -648, -1449, 0 >, 0.0, "", 1.8 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 949, 803, -1 >, 0.0, "", 1.6, "fd_waveTypeMortarSpectre" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -602, -1941, -100 >, 0.0, "", 1.4 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -332, 3888, -256 >, 0.0, "", 1.2 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1242, -1637, -147 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1805, 163, -384 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 3418, -2822, -176 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1132, 447, -369 >, 0.0, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 383, -1990, 0 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1234, 694, -359 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -22, -1934, 96 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1289, -2721, -192 >, 0.0, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2697, 3295, -157 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2021, 2214, -178 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -821, 2031, -124 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1748, 1927, -88 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave1, "Northstar", < -1559, 134, -384 >, -21, "" )
	WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
    array<WaveSpawnEvent> wave2
	WaveSpawn_TitanSpawn( wave2, "Tone", < -2224, 1581, -384 >, -24, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Ion", < -1632, 1873, -349 >, -175, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Legion", < -2143, 2096, -384 >, -63, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -317, 4073, -256 >, -121, "", 1.0, "fd_incReaperClump" )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -962, 3699, -256 >, -51, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -664, 4864, -252 >, -90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 1017, 4442, -257 >, -139, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 849, 3811, -257 >, -2, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 1486, 4156, -257 >, -83, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -1901, 130, -366 >, -12, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -2267, 1816, -384 >, -39, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -803, -1142, -237 >, 93, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 2232, 2681, -254 >, 0.0, "", 0.5, "fd_waveTypeStalkers" )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 384, 2359, -257 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 908, 1411, 6 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 0 )
	
	WaveSpawn_TitanSpawn( wave2, "Ion", < -887, -2015, -121 >, 92, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -403, -1996, -64 >, 175, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Monarch", < -1314, -1643, -142 >, 56, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -1001, -2726, -64 >, 94, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Legion", < -1436, -2592, -73 >, 20, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -1351, 242, -384 >, -50, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 4599, -4396, -385 >, 100, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1030, 340, -368 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 4014, -3870, -365 >, 44, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 1317, -2732, -192 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 3935, -4654, -380 >, 63, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 3600, -3070, -128 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 776, 3047, -241 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 0 )
	
	WaveSpawn_TitanSpawn( wave2, "Ronin", < -1256, 257, -384 >, -53, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -1928, 85, -362 >, -1, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 3600, -3070, -128>, 0.0, "", 1.5, "fd_waveTypeTicks" )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -2080, 1907, -384 >, -61, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Ion", < -2163, 2999, -384 >, -79, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1049, 634, -346 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1450, 8, -384 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -1271, -1672, -141 >, 63, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -691, -1929, -114 >, 130, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -667, -1450, 0 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Legion", < -940, -2319, -97 >, 93, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1139, -1621, -156 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -1132, -2205, -123 >, 0.0, "", 5.0 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 2469, 3490, -224 >, 0.0, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 4610, -4392, -385 >, 113, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 4014, -3919, -364>, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 4139, -4615, -385>, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 1355, 2328, -257 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 1591, 2736, -256 >, 0.0, "" )
	
	WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave3
	WaveSpawn_TitanSpawn( wave3, "Sniper", < -1445, 156, -384 >, -23, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Ion", < -1288, 1021, -341 >, -75, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Ion", < -968, -1689, -155 >, 90, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -1425, -2653, -71 >, 64, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -2386, 1491, -384 >, -72, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1994, 1687, -384 >, -54, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -2227, 692, -365 >, -50, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1577, 1895, -343 >, -136, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -572, -1938, -97 >, 165, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1198, -2422, -104 >, 79, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1182, -2522, -101 >, 90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < 2001, 3707, -256 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 503, 2283, -257 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 2087, 2557, -256 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 2 )
	
	WaveSpawn_TitanSpawn( wave3, "Scorch", < -1445, 156, -384 >, -23, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -1288, 1021, -341 >, -75, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -968, -1689, -155 >, 90, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < -1425, -2653, -71 >, 64, "", 1.2 )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < -2386, 1491, -384 >, -72, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -572, -1938, -97 >, 165, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1198, -2422, -104 >, 79, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1182, -2522, -101 >, 90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1577, 1895, -343 >, -136, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -2227, 692, -365 >, -50, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1994, 1687, -384 >, -54, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < 3560, -1987, -64 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -1004, 254, -374 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -1129, -256, -384 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "PodGrunt", < -1803, 171, -384 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 2 )
	
	WaveSpawn_TitanSpawn( wave3, "Ronin", < -761, 4563, -260 >, -90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -477, 4738, -256 >, -91, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -1035, 4759, -256 >, -92, "", 2.5 )
	WaveSpawn_Announce( wave3, "EliteTitans", 0.0 )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -2183, 1800, -384 >, -45, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -1629, 1847, -348 >, -145, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1513, 4552, -255 >, -51, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -91, 4352, -260 >, 180, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1724, 2582, -360 >, -108, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -2382, 1396, -384 >, -72, "", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_Announce( wave3, "PreNukeTitan", 0.0 )
	WaveSpawn_TitanSpawn( wave3, "Ion", < 1163, -4728, -200 >, 45, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < 1111, -5127, -188 >, 45, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < 776, -4803, -192 >, 45, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < 3782, -5270, -385 >, 64, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < 4336, -4715, -385 >, 82, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3896, -4403, -359 >, 76, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 4667, -3768, -385 >, 121, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2110, -4748, -194 >, 71, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 1519, -3988, -192 >, 0, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < -406, 3923, -256 >, 0.0, "" )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 603, 2260, -257 >, 16, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 6 )
	
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -1445, 156, -384 >, -23, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -1229, -1677, -142 >, 65, "", 0.8, "fd_waveTypeTitanNuke" )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -1276, 949, -345 >, -71, "", 0.6 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -803, -2011, -116 >, 107, "", 0.4 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -1762, 1412, -365 >, -49, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "PodGrunt", < -1139, 430, -372 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "PodGrunt", < -410, -1932, -64 >, 0.0, "" )
	
	WaveSpawnEvents.append( wave3 )
	
	/*
	 __      __                 _ _  
	 \ \    / /__ _ __ __ ___  | | | 
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_| 
	
	*/
    array<WaveSpawnEvent> wave4
	WaveSpawn_TitanSpawn( wave4, "Tone", < -1041, 505, -353 >, -94, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -1189, -1453, -177 >, 60, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -2022, 1696, -384 >, 0.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Ion", < -1362, 1050, -347 >, -73, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Ion", < -883, -1918, -133 >, 95, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -948, -2064, -119 >, 0.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Ronin", < -2080, 1613, -384 >, -39, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Ronin", < -1128, -2315, -116 >, 80, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1028, 426, -359 >, 0.0, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -572, -1999, -91 >, 130, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1118, -1876, -131 >, 77, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1851, 128, -374 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -987, -2036, -123 >, 91, "", 1.5, "fd_incTitansNukeClump" )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2097, 458, -365 >, -31, "", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )
	
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -2246, 2066, -384 >, -52, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -2032, 2490, -384 >, -74, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -1689, 1911, -356 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2148, 2847, -384 >, -80, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -330, 4043, -256 >, -115, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1194, 4920, -256 >, -73, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -623, 3839, -253 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < -1010, 4734, -260 >, -90, "", 0.6, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < -515, 4717, -260 >, -90, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1108, 4123, -256 >, 0.0, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -877, 3821, -252 >, -71, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -72, 4403, -260 >, 131, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -765, 4460, -260 >, 0.0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1571, 4103, -256 >, -17, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1358, 4414, -255 >, -60, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -1329, -2467, -91 >, 70, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -952, -2065, -119 >, 88, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -931, -1884, -137 >, 103, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1081, -2732, -74 >, 89, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1700, 96, -384 >, -11, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1061, 565, -351 >, -93, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Legion", < 698, 4769, -252 >, -90, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Legion", < 391, 4771, -256 >, -90, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -518, 4597, -260 >, -90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -917, 4584, -260 >, -90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -1914, 3386, -384 >, -90, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 867, 3952, -257 >, 0.0, "", 2.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -2234, 2289, -384 >, -68, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 913, 4460, -257 >, 0.0, "", 2.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -128, 5025, -256 >, -90, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 2172, 3603, -252 >, 0.0, "" )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 404, 5019, -256 >, -90, "" )
	
	WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave5
	WaveSpawn_Announce( wave5, "Everything", 0.0 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -520, -1944, -95 >, 161, "", 0.6, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1218, -1638, -149 >, 62, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -993, -2116, -121 >, 83, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1322, -2382, -95 >, 72, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -786, -2170, -99 >, 111, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1244, -2891, -70 >, 78, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -1352, 11, -384 >, -13, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1196, 781, -350 >, -81, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1655, 1328, -359 >, -55, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 1304, -2258, -128 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Scorch", < 1187, -4704, -200 >, 43, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 1665, -5467, -188 >, 70, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < 2354, -4595, -188 >, -91, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 3760, -4784, -369 >, 36, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < 208, -3940, -101 >, -45, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < 3926, -5135, -385 >, 80, "", 0.6, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < 4383, -4540, -385 >, 90, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4097, -4459, -375 >, 66, "", 0.6, "fd_waveTypeReapers" )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4648, -3698, -385 >, 120, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 3542, -5153, -385 >, 39, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 1520, -3995, -192 >, -20, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 335, -4452, -154 >, 43, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 909, 1309, 6 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1196, 781, -350 >, -81, "", 1.2, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1655, 1328, -359 >, -55, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -520, -1944, -95 >, 161, "", 1.2, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1218, -1638, -149 >, 62, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < -1352, 11, -384 >, -13, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -811, -1147, -237 >, 98, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1894, 315, -384 >, -35, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2083, 1479, -384 >, -11, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1244, -1721, -135 >, 65, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1185, 852, -343 >, -83, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 3258, -2812, -176 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -598, -1981, -95 >, 128, "", 0.8, "fd_waveComboNukeTrain" )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1178, -1995, -124 >, 78, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1473, 1122, -354 >, -55, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2337, 1553, -384 >, 0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -598, -1981, -95 >, 128, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1178, -1995, -124 >, 78, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1473, 1122, -354 >, -55, "", 0.4 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2337, 1553, -384 >, 0, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -811, -1147, -237 >, 98, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1894, 315, -384 >, -35, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2083, 1479, -384 >, -11, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1034, -3102, -58 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 4327, -4746, -385 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 4147, -4202, -385 >, 90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 3847, -4630, -363 >, 60, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4583, -3852, -385 >, 113, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4558, -4528, -385 >, 103, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 1544, -4056, -192 >, 28, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 1905, -4414, -188 >, 63, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 1625, -4484, -200 >, 55, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 1795, -3736, -192 >, 34, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 975, -4913, -200 >, 45, "" )
	
    WaveSpawnEvents.append( wave5 )
}