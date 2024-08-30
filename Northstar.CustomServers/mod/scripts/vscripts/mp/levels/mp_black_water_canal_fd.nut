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
	
	/*
	AddStationaryAIPosition( < -295, 3262, -128>, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < 1844, 4549, -130>, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < 3790, -2236, -128>, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < 485, 2651, -241>, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	*/

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
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -774, 2019, -123 >, 0.0, "", 1.6, "fd_waveTypeMortarSpectre" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -602, -1941, -100 >, 0.0, "", 1.4 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 1370, 2340, -256 >, 0.0, "", 1.2 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1242, -1637, -147 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1805, 163, -384 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 464, -2049, 0 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1132, 447, -369 >, 0.0, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2614, -3115, -179 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1234, 694, -359 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -22, -1934, 96 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1289, -2721, -192 >, 0.0, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 2416, 2803, -222 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2021, 2214, -178 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -511, 933, 2 >, 0.0, "", 0.2 )
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
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 1295, -2779, -190 >, 0.0, "", 0.5 )
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
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < -946, 2488, -123 >, 0.0, "", 0.5 )
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
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < 3454, -2823, -175 >, 0.0, "", 0.5 )
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
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < 2294, 2786, -249 >, 0.0, "" )
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
	
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 4326, -4660, -381 >, 135, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 4076, -4940, -382 >, 135, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 970, 4457, -256 >, -135, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 593, 4903, -251 >, -90, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -843, -2285, -90 >, 90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1178, -2009, -122 >, 90, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1855, 1651, -370 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < -1010, 4734, -260 >, -90, "", 0.6, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < -515, 4717, -260 >, -90, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1855, 146, -373 >, 0.0, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 1324, -5086, -186 >, -45, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 1000, -4711, -198 >, -45, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -809, -1143, -236 >, 0.0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2204, 1643, -382 >, -90, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1688, 1905, -355 >, -90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 872, -4932, -200 >, 45, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -819, 4933, -256 >, -90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1938, 231, -366 >, -20, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2232, 1641, -383 >, -25, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1286, -1639, -142 >, 90, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1220, -1991, -120 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Legion", < 4509, -4418, -384 >, 180, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Legion", < 637, 4923, -251 >, -90, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -1023, -2245, -112 >, -90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -2091, 467, -364 >, 45, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -998, 4710, -257 >, -90, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1058, -1014, -249 >, 0.0, "", 2.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 4308, -4846, -384 >, 135, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -1451, 92, -382 >, 0.0, "", 2.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -538, 4830, -248 >, -90, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -698, -104, -382 >, 0.0, "" )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 3674, -5445, -384 >, -90, "" )
	
	WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave5
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2251, 2429, -382 >, 0, "", 0.6, "fd_waveTypeReapers" )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2144, 3006, -382 >, 0, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -2080, 2655, -382 >, 0, "", 0.4 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -2239, 2685, -381 >, 0, "", 2.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4566, -4426, -384 >, 90, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4630, -3787, -383 >, 90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 3913, -4263, -355 >, 90, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < 4316, -4560, -385 >, 90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 941, 1328, 6 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 2356, -2651, -156 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_Announce( wave5, "Everything", 0.0 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1265, -1658, -141 >, 90, "", 0.6, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1962, 1510, -382 >, -45, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -863, -2221, -99 >, 90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2399, 1343, -382 >, -45, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -920, -1329, -215 >, 90, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1750, 1880, -361 >, -45, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -1198, -2339, -107 >, 90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -2195, 1876, -382 >, -45, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -1768, 143, -383 >, 0.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2070, 456, -363 >, -45, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1055, -2259, -112 >, 90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 897, -4927, -198 >, 45, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1071, 4792, -256 >, -90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 4585, -4410, -384 >, 90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < 4619, -3710, -383 >, 90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 702, 4869, -256 >, -90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < 286, 4965, -253 >, -90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < 1279, -5194, -185 >, 45, "", 0.6, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -311, 4097, -255 >, -90, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4030, -4151, -363 >, 45, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 948, 4473, -255 >, 45, "", 1.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1196, 781, -350 >, -81, "", 1.2, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1655, 1328, -359 >, -55, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -520, -1944, -95 >, 161, "", 1.2, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1218, -1638, -149 >, 62, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < -1352, 11, -384 >, -13, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1244, -1721, -135 >, 65, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1185, 852, -343 >, -83, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1662, 119, -383 >, 0, "", 0.8, "fd_waveComboNukeTrain" )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -761, -1120, -238 >, 90, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1961, 1531, -382 >, -45, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1226, -1350, -187 >, 90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 4550, -4410, -383 >, 135, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 4406, -4621, -383 >, 135, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 544, 4922, -250 >, -90, "", 0.4 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 259, 4846, -255 >, -90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4652, -3711, -384 >, 135, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 4566, -3959, -384 >, 135, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 791, 4603, -255 >, -90, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 280, 4666, -258 >, -90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 1236, -5132, -186 >, 45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 916, -4786, -198 >, 45, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 1366, -4290, -199 >, 45, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 1582, -4708, -187 >, 45, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 1205, -4654, -199 >, 45, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -783, 3943, -255 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -544, 3978, -251 >, -90, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -343, 3774, -254 >, -90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -954, 3758, -254 >, -90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -693, 3654, -252 >, -90, "" )
	
    WaveSpawnEvents.append( wave5 )
}