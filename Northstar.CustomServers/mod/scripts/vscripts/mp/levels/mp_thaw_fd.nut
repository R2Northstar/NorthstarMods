global function initFrontierDefenseData
void function initFrontierDefenseData()
{
    PlaceFDShop( < -2405, -3182, -541 >, < 0, 17, 0 > )
	SetFDDropshipSpawn( < -1736, -1505, 261 >, < 0, 180, 0 > )
	SetFDGroundSpawn( < -1340, -1989, -192 >, < 0, -15, 0 > )
	
	AddFDDropPodSpawn( < -1700, -4005, -206 > )
	AddFDDropPodSpawn( < -2970, -1257, -65 > )
	AddFDDropPodSpawn( < -1212, -1564, 328 > )
	
	AddWaveAnnouncement( "fd_introEasy" )
	AddWaveAnnouncement( "fd_waveTypeReapers" )
	AddWaveAnnouncement( "fd_soonNukeTitans" )
	AddWaveAnnouncement( "fd_waveTypeFlyers" )
	AddWaveAnnouncement( "fd_waveComboNukeMortar" )
	
	AddFDCustomTitanStart( < -2776, -1603, -364 >, < 0, -45, 0 > )
	AddFDCustomTitanStart( < -1960, -3785, -467 >, < 0, 90, 0 > )

	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -877, 699, -290 >, 0.0, "", 1.0, "fd_waveTypeInfantry" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 586, 100, -191 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -52, 2281, -349 >, 0.0, "", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1518, -3368, -249 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1174, -2721, -253 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2097, -2461, -95 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1940, -4357, -238 >, 0.0, "", 0.6, "fd_waveTypeStalkers" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2371, 1085, -300 >, 0.0, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1994, 2572, 79 >, 0.0, "left_infantry", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1529, 2559, 99 >, 0.0, "left_infantry", 1.2 )
	WaveSpawn_InfantrySpawn( wave1, "DropshipGrunt", < -118, -3714, -250 >, -43, "", 0.5, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 2433, -3137, -305 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2068, -223, -127 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1458, 110, -243 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 2164, -735, 16 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1584, -183, -210 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -881, 642, -289 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -868, 1613, -319 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -562, -169, -234 >, 0.0, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "DropshipGrunt", < 3681, -2573, -336 >, 190, "", 2.0, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1972, 2066, -332 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -96, -3675, -200 >, 0.0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 2872, -2388, -378 >, -176, "", 1.3 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 350, -4402, -194 >, 0.0, "", 1.6 )
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < -922, 2236, -362 >, -172, "", 2.0 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1049, -3360, -246 >, 0.0, "" )
	
	WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
    array<WaveSpawnEvent> wave2
	WaveSpawn_InfantrySpawn( wave2, "DropshipGrunt", < -50, -1004, -422 >,40, "", 1.5, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 3648, -3017, -306 >, 180, "", 0.6, "fd_waveTypeReapers" )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 3687, -1981, -353 >, 180, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 3682, -2563, -328 >, 180, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 3313, -2788, -334 >, 180, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 2984, 450, -313 >, -125, "", 2.0 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1486, -2911, -246 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 1571, -43, -221 >, 0.0, "", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 2 )
	
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 2718, 1120, -280 >, -132, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 1787, 2052, -313 >, 158, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 1018, 2858, -363 >, -156, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 646, -4515, -222 >, 128, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 1895, -4598, -216 >, 86, "", 2.0 )
	WaveSpawn_InfantrySpawn( wave2, "DropshipGrunt", < -118, -3714, -250 >, -43, "", 2.5, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_InfantrySpawn( wave2, "Drones", < 3056, -2845, 2816 >, 0.0, "midDrone" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 2 )
	
	WaveSpawn_TitanSpawn( wave2, "Sniper", < 4241, -17, -390 >, -159, "", 2.5, "fd_waveTypeTitanReg" )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 4323, -362, -405 >, 167, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 4165, 146, -380 >, -163, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 4014, -111, -417 >, -158, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 2413, 1934, -331 >, -176, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 2183, 1783, -321 >, -51, "", 2.5 )
	WaveSpawn_TitanSpawn( wave2, "Ion", < 3459, -2928, -301 >, 173, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 2147, 2549, 74 >, 0.0, "left_infantry", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1473, 2426, 93 >, 0.0, "left_infantry", 0.4 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -258, -141, -209 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 4 )
	
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 2848, -4144, -328 >, 160, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 2182, -4263, -287 >, 135, "", 1.4 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 2004, -4563, -218 >, 86, "", 1.3 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -2369, 1961, -393 >, -39, "", 1.2 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -2073, 1489, -349 >, -31, "", 2.0 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -2269, 2679, -475 >, -45, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -1090, 3374, -425 >, -98, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -10, 2062, -327 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 559, 99, -194 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "Drones", < -2898, 3657, 2560 >, 0.0, "closeDrone1" )
	
	WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave3
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 1940, -4357, -238 >, 0.0, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 812, -4289, -214 >, 132, "", 1.5 )
	WaveSpawn_Announce( wave3, "EliteTitans", 0.0 )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < 3673, -2540, -332 >, 175, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 2433, -3137, -305 >, 0.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < 3197, -3281, -324 >, 148, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -881, 642, -289 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Legion", < 3752, -1068, -417 >, 164, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 449, -4423, -197 >, 149, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 2164, -735, 16 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 2 )
	
	WaveSpawn_TitanSpawn( wave3, "Scorch", < -2416, 2457, -439 >, -50, "", 1.5 )
	WaveSpawn_TitanSpawn( wave3, "Scorch", < -813, 3976, -473 >, -88, "", 1.5 )
	WaveSpawn_TitanSpawn( wave3, "Scorch", < -2057, 3627, -482 >, -50, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 1972, 2066, -332 >, 0.0, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 580, -590, -286 >, -171, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -868, 1613, -319 >, 0.0, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 618, 70, -192 >, -177, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -501, 2750, -386 >, 123, "", 0.5, "fd_waveTypeTitanMortar" )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -1424, 4142, -437 >, -91, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -2547, 3096, -473 >, -61, "", 3.0 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < -2898, 3657, 2560 >, 0.0, "closeDrone1", 1.0 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < -896, 4959, 2560 >, 0.0, "farDrone1", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 6 )
	
	WaveSpawn_TitanSpawn( wave3, "Ion", < 3748, -1859, -359 >, 170, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Ion", < 3708, -1242, -413 >, 165, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 1066, 2832, -359 >, -135, "", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < 4013, 100, -397 >, -165, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < 4114, -291, -415 >, -173, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 957, 2210, -330 >, 179, "", 5.0 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 1049, -3360, -246 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 3056, -2845, 2560 >, 0.0, "midDrone", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -96, -3675, -200 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 2548, -4935, 2560 >, 0.0, "closeDrone2", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 1280, -5518, -144 >, 0.0, "", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 4204, -308, -357 >, 180, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 729, -4295, -215 >,91, "", 2.5, "fd_waveTypeTitanNuke" )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 4043, 77, -344 >, -165, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 2013, -4526, -224 >, 87, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 4098, -87, -405 >, -165, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 2624, -4138, -313 >, 122, "", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -93, -914, -404 >, 5, "" )
	
	WaveSpawnEvents.append( wave3 )
	
	/*
	 __      __                 _ _  
	 \ \    / /__ _ __ __ ___  | | | 
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_| 
	
	*/
    array<WaveSpawnEvent> wave4
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 2316, -4487, -293 >, 104, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 1025, 2841, -361 >, -146, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 1962, -4542, -214 >, 102, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -197, 3952, -447 >, -155, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 2079, -4227, -272 >,93, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -1539, 4136, -437 >, -73, "", 5.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 3056, -2845, 2560 >, 0.0, "midDrone", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 2548, -4935, 2560 >, 0.0, "closeDrone2", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 3056, -2845, 2560 >, 0.0, "rightDrone", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -501, 2750, -386 >, 123, "", 1.5, "fd_incTitansMortarClump" )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -1424, 4142, -437 >, -91, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -2547, 3096, -473 >, -61, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 3905, 52, -419 >, -159, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Ronin", < 2660, 1057, -285 >, -94, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 3814, 231, -400 >, -167, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 3818, -897, -422 >, 177, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 4136, 89, -388 >, -156, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Legion", < 3615, -2674, -325 >, -168, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 38, -820, -382 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 74, -4479, -237 >, 0.0, "", 5.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < -896, 4959, 2560 >, 0.0, "farDrone1", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < -2898, 3657, 2560 >, 0.0, "closeDrone1", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < -896, 4959, 2560 >, 0.0, "farDrone1" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1725, 2522, -403 >, -89, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 3319, -3133, -320 >, 177, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -1337, 2796, -399 >, -73, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 2796, -4140, -330 >, 140, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1100, 3355, -424 >, -49, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 2151, -4485, -270 >, 102, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 483, -4278, -218 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -185, -159, -208 >, 0.0, "", 5.0 )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < 586, 135, -192 >, 180, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -93, -914, -404 >,5, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 2445, -4363, -323 >, 125, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 4218, -286, -408 >, -171, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 4123, 162, -381 >, -161, "", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < 3707, -2056, -355 >, 168, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 510, -4507, -231 >, 119, "" )
	
	WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave5
	WaveSpawn_Announce( wave5, "MediumWave", 0.0 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < 3472, -2986, -302 >, 176, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Legion", < 3749, -2088, -354 >, 166, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 4202, 42, -388 >, -151, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 670, -4362, -220 >, 90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 0 )
	
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1904, 2592, -433 >, -55, "", 1.4, "fd_incTitansNukeClump" )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1161, 3367, -422 >, -54, "", 1.2 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2153, -4379, -278 >, 131, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2810, -4170, -332 >, 138, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 2394, 1975, -334 >, -143, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )
	
	WaveSpawn_TitanSpawn( wave5, "Legion", < 3427, -3299, -303 >, 147, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < 4219, -42, -393 >, -158, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -613, 3681, -444 >, -79, "", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1905, 3665, -478 >, -67, "", 1.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1838, 2537, -421 >, -52, "", 1.3 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -2166, 1661, -368 >, -34, "", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -1207, 4138, -449 >, -81, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -227, 3983, -448 >, -132, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 0 )
	
	WaveSpawn_TitanSpawn( wave5, "Scorch", < 3427, -3299, -303 >, 147, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 3721, -1174, -415 >, -177, "", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 3657, -2016, -354 >, -175, "", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2714, -4188, -333 >, 127, "", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 1933, -4395, -234 >, 88, "", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 4106, 100, -389 >, -141, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 2419, 1885, -328 >, 180, "", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < 586, 135, -192 >, 180, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < -896, 4959, 2560 >, 0.0, "farDrone1", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < -2898, 3657, 2560 >, 0.0, "closeDrone1", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < -896, 4959, 2560 >, 0.0, "farDrone1" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 4 )
	
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 4053, -83, -410 >, -156, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 3795, -1990, -350 >, -179, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 3708, -2992, -305 >, 164, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 552, -4475, -227 >, 134, "", 0.4 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1985, 2467, -425 >, -61, "", 0.2 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1054, 3271, -422 >, -95, "", 5.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 3056, -2845, 2560 >, 0.0, "midDrone", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 2548, -4935, 2560 >, 0.0, "closeDrone2", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 3056, -2845, 2560 >, 0.0, "rightDrone", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -1491, 3937, -471 >, -74, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -2393, 3087, -470 >, -59, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 2660, 1079, -285 >, -104, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < 3851, 224, -397 >, -139, "" )
	
    WaveSpawnEvents.append( wave5 )
}