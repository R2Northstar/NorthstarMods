global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	
    PlaceFDShop( < 3037, -3930, 192 > )
	
	SetFDDropshipSpawn( < 3400, -4119, 520 >, < 0, 20, 0 > )
	SetFDGroundSpawn( < 2343, -5258, 128 >, < 0, 135, 0 > )
	
	AddFDDropPodSpawn( < 2677, -5238, 127 > )
	AddFDDropPodSpawn( < 5106, -4429, 143 > )
	AddFDDropPodSpawn( < 3306, -3815, 644 > )
	
	AddWaveAnnouncement( "fd_introEasy" )
	AddWaveAnnouncement( "fd_waveTypeTitanReg" )
	AddWaveAnnouncement( "fd_waveTypeFlyers" )
	AddWaveAnnouncement( "fd_introMedium" )
	AddWaveAnnouncement( "fd_waveComboMultiMix" )

	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 2524, -1974, 42 >, 0.0, "cliffClose", 0.6, "fd_waveTypeStalkers" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1167, -3639, 217 >, 0.0, "closeInfantrySafeA", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 2764, -1997, 37 >, 0.0, "cliffClose", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1452, -3330, 137 >, 0.0, "closeInfantrySafeA" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1291, -5011, 130 >, 0.0, "closeInfantrySafeB", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1774, -5971, 137 >, 0.0, "hillClose", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1241, -4654, 119 >, 0.0, "closeInfantrySafeB", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 2282, -6223, 161 >, 0.0, "hillClose" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < -2694, -2097, 371 >, -10, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1475, -3202, -4 >, 0.0, "longInfantryShipB", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1354, -3026, -26 >, 0.0, "longInfantryShipB", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1599, -4254, 192 >, 0.0, "longInfantryShipA", 0.5 )
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < -1402, -4729, 165 >, 90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 6 )
	
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 1384, -2596, 133 >, 0.0,"", 0.5, "fd_waveTypeMortarSpectre" )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 1934, -5820, 136 >, 0.0,"", 2.5 )
	WaveSpawn_TitanSpawn( wave1, "Ronin", < 214, -2525, 439 >, -106, "" )
	
    WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
	array<WaveSpawnEvent> wave2
	WaveSpawn_TitanSpawn( wave2, "Monarch", < -1950, -4592, 261 >, 40, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Monarch", < -2766, -2484, 468 >, -20, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -1475, -3202, -4 >, 0.0, "longInfantryShipB", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -1354, -3026, -26 >, 0.0, "longInfantryShipB", 0.4 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -1599, -4254, 192 >, 0.0, "longInfantryShipA", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -3846, -1799, 393 >, 117, "", 1.0, "fd_waveTypeReapers" )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -1337, -4795, 156 >, 101, "", 2.0 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 1384, -2596, 133 >, 0.0,"", 0.4 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 1934, -5820, 136 >, 0.0,"", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 1873, -1833, 15 >, 0.0,"" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 2 )
	
	WaveSpawn_Announce( wave2, "PreMortarTitan", 0.1 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1167, -3639, 217 >, 0.0, "closeInfantrySafeA", 0.6 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1452, -3330, 137 >, 0.0, "closeInfantrySafeA", 0.4 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1291, -5011, 130 >, 0.0, "closeInfantrySafeB", 0.2 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1241, -4654, 119 >, 0.0, "closeInfantrySafeB", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 2723, -5826, 89 >, 0.0,"", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -3091, -4647, 459 >, 32, "infantryReaperShipStraight", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -3146, -4024, 474 >, -34, "infantryReaperShipStraight", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -2902, -1197, 164 >, -33, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 220, -2569, 433 >, -105, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Northstar", < -3683, -1100, 448 >, -23, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Northstar", < -3009, -4702, 442 >, 52, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 2 )
	
	WaveSpawn_TitanSpawn( wave2, "Ion", < -2013, -1649, 10 >, -40, "", 0.3 )
	WaveSpawn_TitanSpawn( wave2, "Ion", < 171, -2565, 434 >, -85, "", 2.0 )
	WaveSpawn_TitanSpawn( wave2, "Tone", < -3474, -4626, 477 >, 90, "", 0.3 )
	WaveSpawn_TitanSpawn( wave2, "Tone", < -1670, -3201, 28 >, 0, "", 2.0 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < -3908, -3518, 479 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < -5105, -2956, 302 >, 0.0,"", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -5192, -2363, 278 >, -26, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < 171, -4495, 296 >, 45, "", 1.0, "fd_waveTypeTitanMortar" )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -3844, -3510, 485 >, 180, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -4716, -1118, 335 >, -90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -5570, -2555, 307 >, -6, "", 5.0 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < 1824, -1917, 29 >, -90, "" )
	
    WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave3
	WaveSpawn_TitanSpawn( wave3, "Legion", < -1950, -4592, 261 >, 40, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -2766, -2484, 468 >, -20, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 793, -6024, 2000 >, -90, "droneCliffSide", 1.0 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 793, -6024, 2000 >, -90, "droneCliffSide", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -1621, -3176, 18 >, 0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 220, -2569, 433 >, -105, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1655, -4722, 163 >, 90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_Announce( wave3, "EliteTitans", 0.0 )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < -2013, -1649, 10 >, -40, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < 171, -2565, 434 >, -85, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 197, -4412, 299 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -7, -2649, 421 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave3, "Sniper", < -3683, -1100, 448 >, -23, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -3917, -2910, 465 >, -95, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -3091, -4647, 459 >, 32, "infantryReaperShipStraight", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -3146, -4024, 474 >, -34, "infantryReaperShipStraight", 0.8 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -2902, -1197, 164 >, -33, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide", 1.0 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 2269, -6180, 150 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 1862, -5979, 134 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < 171, -4495, 296 >, 45, "", 0.6 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -3844, -3510, 485 >, 180, "", 0.8 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -4716, -1118, 335 >, -90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -5570, -2555, 307 >, -6, "" )
	
    WaveSpawnEvents.append( wave3 )
	
	/*
	 __      __                 _ _  
	 \ \    / /__ _ __ __ ___  | | | 
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_| 
	
	*/
	array<WaveSpawnEvent> wave4 
	WaveSpawn_TitanSpawn( wave4, "Monarch", < 164, -2552, 436 >, -95, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -2807, -2442, 459 >, -28, "",  1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -1222, -4107, 126 >, 180, "", 1.0, "fd_waveTypeReaperTicks" )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -3806, -1743, 389 >, 88, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 1839, -6113, 130 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "MortarSpectre", < 1894, -1839, 16 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 2716, -1926, 29 >, -125, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 1788, -1920, 29 >, -90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 2719, -1911, 26 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "MortarSpectre", < 1318, -5027, 134 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 2387, -2624, 147 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "MortarSpectre", < 2372, -5841, 115 >, 0.0,"", 2.0 )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < 1385, -5033, 140 >, 106, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -210, -4496, 307 >, 10, "", 3.5 )
	WaveSpawn_InfantrySpawn( wave4, "CloakDrone", < 1278, -4350, 2560 >, 0.0, "", 0.0, "fd_waveTypeCloakDrone" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_TitanSpawn( wave4, "Tone", < -2457, -4571, 363 >, 16, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Ion", < -3258, -2804, 489 >, -16, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -2256, -1788, 134 >, -16, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 793, -6024, 2000 >, -90, "droneCliffSide", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 793, -6024, 2000 >, -90, "droneCliffSide", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 1156, -3564, 229 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "MortarSpectre", < -4050, -3593, 467 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "CloakDrone", < -2664, -2716, 2560 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 8 )
	
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < 1848, -6396, 235 >, 90, "", 0.3 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 2230, -6287, 178 >, 90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < 2745, -1896, 23 >, -90, "", 0.3 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 2992, -1990, 29 >, -90, "" )
	
    WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave5
	WaveSpawn_Announce( wave5, "HeavyWave", 0.0 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -2457, -4571, 363 >, 16, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -3258, -2804, 489 >, -16, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -2256, -1788, 134 >, -16, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -3783, -4540, 518 >, 53, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -4287, -3175, 470 >, 10, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 2716, -1926, 29 >, -125, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 1788, -1920, 29 >, -90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )
	
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -3091, -4647, 459 >, 32, "infantryReaperShipStraight", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -3146, -4024, 474 >, -34, "infantryReaperShipStraight", 1.0 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < 1688, -5792, 152 >, 0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 4134, 1001, 2000 >, 0, "droneHillSide", 2.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 1251, -4961, 122 >, 0.0,"", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 1627, -3331, 121 >, 0.0,"", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Sniper", < -2605, -2956, 466 >, 173, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Sniper", < 1794, -6388, 242 >, 43, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < 1385, -5033, 140 >, 106, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < -210, -4496, 307 >, 10, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -1740, -2152, -37 >, 0, "", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 1848, -6396, 235 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2230, -6287, 178 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 2745, -1896, 23 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2992, -1990, 29 >, -90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )
	
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -3783, -4540, 518 >, 53, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -4287, -3175, 470 >, 10, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < 214, -2525, 439 >, -106, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -4262, -1184, 388 >, -55, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "MortarSpectre", < 1894, -1839, 16 >, 0.0,"", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -4870, -3613, 346 >, 0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "MortarSpectre", < 1318, -5027, 134 >, 0.0,"", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -1494, -4658, 177 >, 107, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "MortarSpectre", < 2372, -5841, 115 >, 0.0,"", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < -2664, -2716, 2560 >, 0.0,"", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < -3033, -4379, 2560 >, 0.0,"", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -3667, -4514, 493 >, 45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -5370, -2440, 258 >, 12, "" )
	
    WaveSpawnEvents.append( wave5 )
}

void function RegisterCustomFDContent()
{
	array<entity> aiPositions = GetEntArrayByClass_Expensive( "info_target" )
	foreach ( entity position in aiPositions )
		if( position.HasKey( "editorclass" ) && position.kv.editorclass == "info_fd_ai_position" )
			position.Destroy()
	
	AddFDCustomTitanStart( < 4858, -4093, 173 >, < 0, 180, 0 > )
	AddFDCustomTitanStart( < 4748, -5300, 21 >, < 0, 180, 0 > )
	
	AddStationaryAIPosition(< -4425, -1440, 341 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -5544, -2340, 279 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -4394, -3911, 402 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -2652, -3300, 472 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -4335, -2627, 417 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -3079, -4631, 460 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -182, -2449, 452 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -283, -4515, 291 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -2249, -2556, 456 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	
	AddStationaryAIPosition(< 1054, -1702, 340 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< 1084, -2689, 336 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< 1932, -5168, 343 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< 1773, -6518, 261 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< 2213, -2993, 531 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< 2327, -5167, 344 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< -5609, -1495, 198 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< -5255, -3605, 343 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	
	AddStationaryAIPosition(< 348, -4272, 304 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< 3078, -6403, 119 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< 3777, -2374, 45 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< 1419, -4552, 127 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -2712, -1717, 367 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -1467, -2573, 515 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -1508, -4575, 181 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -4274, -3306, 465 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	
	AddStationaryAIPosition(< -3114, -1930, 696 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< -3582, -2539, 696 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< 1671, -1371, 184 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< 1022, -1868, 344 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< -664, -4040, 372 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< -4754, -3119, 485 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< -3360, -1102, 448 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< 2087, -6461, 223 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	
	routes[ "bridgeMainShip" ] <- []
	routes[ "bridgeMainShip" ].append( < -2671, -2742, 460 > )
	routes[ "bridgeMainShip" ].append( < -18, -2710, 408 > )
	routes[ "bridgeMainShip" ].append( < 298, -4172, 318 > )
	routes[ "bridgeMainShip" ].append( < 3937, -4650, 7 > )
	
	routes[ "altInShip" ] <- []
	routes[ "altInShip" ].append( < -3100, -4277, 493 > )
	routes[ "altInShip" ].append( < -2645, -2723, 459 > )
	routes[ "altInShip" ].append( < -93, -2536, 444 > )
	routes[ "altInShip" ].append( < 271, -4184, 317 > )
	routes[ "altInShip" ].append( < 1678, -4491, 120 > )
	routes[ "altInShip" ].append( < 3802, -4581, -11 > )
	
	routes[ "farInShip" ] <- []
	routes[ "farInShip" ].append( < -3913, -3130, 471 > )
	routes[ "farInShip" ].append( < -2565, -2610, 454 > )
	routes[ "farInShip" ].append( < -51, -2543, 442 > )
	routes[ "farInShip" ].append( < 283, -4176, 318 > )
	routes[ "farInShip" ].append( < 1192, -4453, 160 > )
	routes[ "farInShip" ].append( < 1258, -6193, 152 > )
	routes[ "farInShip" ].append( < 3058, -6084, 104 > )
	routes[ "farInShip" ].append( < 4082, -4993, 12 > )
	
	routes[ "longInfantryShipA" ] <- []
	routes[ "longInfantryShipA" ].append( < -1598, -4071, 138 > )
	routes[ "longInfantryShipA" ].append( < -69, -4138, 210 > )
	routes[ "longInfantryShipA" ].append( < 509, -3499, 406 > )
	routes[ "longInfantryShipA" ].append( < 1898, -3000, 167 > )
	routes[ "longInfantryShipA" ].append( < 2969, -2994, 143 > )
	routes[ "longInfantryShipA" ].append( < 3019, -3992, 56 > )
	routes[ "longInfantryShipA" ].append( < 3410, -3984, 56 > )
	routes[ "longInfantryShipA" ].append( < 3800, -4510, -3 > )
	
	routes[ "longInfantryShipB" ] <- []
	routes[ "longInfantryShipB" ].append( < -1559, -3202, 4 > )
	routes[ "longInfantryShipB" ].append( < -595, -2662, -23 > )
	routes[ "longInfantryShipB" ].append( < 621, -2499, -79 > )
	routes[ "longInfantryShipB" ].append( < 1107, -2694, 151 > )
	routes[ "longInfantryShipB" ].append( < 1898, -3000, 167 > )
	routes[ "longInfantryShipB" ].append( < 2969, -2994, 143 > )
	routes[ "longInfantryShipB" ].append( < 3019, -3992, 56 > )
	routes[ "longInfantryShipB" ].append( < 3484, -4304, 48 > )
	
	routes[ "closeInfantrySafeA" ] <- []
	routes[ "closeInfantrySafeA" ].append( < 1481, -3369, 137 > )
	routes[ "closeInfantrySafeA" ].append( < 1916, -3989, 160 > )
	routes[ "closeInfantrySafeA" ].append( < 2453, -4127, 120 > )
	routes[ "closeInfantrySafeA" ].append( < 3122, -3988, 55 > )
	routes[ "closeInfantrySafeA" ].append( < 3921, -4509, 15 > )
	
	routes[ "closeInfantrySafeB" ] <- []
	routes[ "closeInfantrySafeB" ].append( < 1207, -4814, 133 > )
	routes[ "closeInfantrySafeB" ].append( < 1762, -4962, 128 > )
	routes[ "closeInfantrySafeB" ].append( < 2440, -5477, 128 > )
	routes[ "closeInfantrySafeB" ].append( < 2742, -5756, 94 > )
	routes[ "closeInfantrySafeB" ].append( < 3672, -5017, 30 > )
	
	routes[ "cliffClose" ] <- []
	routes[ "cliffClose" ].append( < 2550, -2108, 66 > )
	routes[ "cliffClose" ].append( < 3724, -2627, 94 > )
	routes[ "cliffClose" ].append( < 4221, -4126, 57 > )
	
	routes[ "hillClose" ] <- []
	routes[ "hillClose" ].append( < 1875, -6113, 131 > )
	routes[ "hillClose" ].append( < 3617, -5881, 43 > )
	routes[ "hillClose" ].append( < 4146, -4977, 20 > )
	
	routes[ "mainUnderpass" ] <- []
	routes[ "mainUnderpass" ].append( < -1771, -2087, -33 > )
	routes[ "mainUnderpass" ].append( < 1014, -2051, -87 > )
	routes[ "mainUnderpass" ].append( < 2518, -2204, 88 > )
	routes[ "mainUnderpass" ].append( < 3804, -2704, 78 > )
	routes[ "mainUnderpass" ].append( < 4193, -4122, 56 > )
	
	routes[ "altUnderpass" ] <- []
	routes[ "altUnderpass" ].append( < -2107, -4548, 304 > )
	routes[ "altUnderpass" ].append( < -1247, -2024, -192 > )
	routes[ "altUnderpass" ].append( < 1423, -2119, 15 > )
	routes[ "altUnderpass" ].append( < 3541, -2445, 85 > )
	routes[ "altUnderpass" ].append( < 4297, -4043, 61 > )
	
	routes[ "altUnderpass2" ] <- []
	routes[ "altUnderpass2" ].append( < -1391, -3497, 16 > )
	routes[ "altUnderpass2" ].append( < -1247, -2024, -192 > )
	routes[ "altUnderpass2" ].append( < 1423, -2119, 15 > )
	routes[ "altUnderpass2" ].append( < 3541, -2445, 85 > )
	routes[ "altUnderpass2" ].append( < 4297, -4043, 61 > )
	
	routes[ "farUnderpass" ] <- []
	routes[ "farUnderpass" ].append( < -4444, -1766, 341 > )
	routes[ "farUnderpass" ].append( < -3006, -1346, 255 > )
	routes[ "farUnderpass" ].append( < -1381, -2060, -167 > )
	routes[ "farUnderpass" ].append( < 157, -1236, -238 > )
	routes[ "farUnderpass" ].append( < 1523, -2235, 56 > )
	routes[ "farUnderpass" ].append( < 1497, -3317, 131 > )
	routes[ "farUnderpass" ].append( < 2545, -3328, 107 > )
	routes[ "farUnderpass" ].append( < 3825, -3467, 61 > )
	routes[ "farUnderpass" ].append( < 4224, -4119, 58 > )
	
	routes[ "insideShipA" ] <- []
	routes[ "insideShipA" ].append( < 87, -4252, 312 > )
	routes[ "insideShipA" ].append( < 1179, -4251, 170 > )
	routes[ "insideShipA" ].append( < 1588, -3338, 129 > )
	routes[ "insideShipA" ].append( < 2582, -3358, 104 > )
	routes[ "insideShipA" ].append( < 3744, -3474, 60 > )
	routes[ "insideShipA" ].append( < 4357, -4079, 72 > )
	
	routes[ "insideShipB" ] <- []
	routes[ "insideShipB" ].append( < -43, -2516, 445 > )
	routes[ "insideShipB" ].append( < 469, -4293, 298 > )
	routes[ "insideShipB" ].append( < 1201, -4481, 155 > )
	routes[ "insideShipB" ].append( < 1234, -6186, 160 > )
	routes[ "insideShipB" ].append( < 3402, -6058, 65 > )
	routes[ "insideShipB" ].append( < 4255, -5030, 9 > )
	
	routes[ "droneCliffSide" ] <- []
	routes[ "droneCliffSide" ].append( < 3467, -6004, 59 > )
	routes[ "droneCliffSide" ].append( < 5078, -5539, 19 > )
	routes[ "droneCliffSide" ].append( < 5800, -4222, 60 > )
	routes[ "droneCliffSide" ].append( < 4658, -3256, 86 > )
	routes[ "droneCliffSide" ].append( < 3008, -1867, 11 > )
	routes[ "droneCliffSide" ].append( < 1225, -2843, 525 > )
	routes[ "droneCliffSide" ].append( < 1482, -5185, 639 > )
	routes[ "droneCliffSide" ].append( < 1524, -6117, 768 > )
	
	routes[ "droneHillSide" ] <- []
	routes[ "droneHillSide" ].append( < 3972, -3000, 83 > )
	routes[ "droneHillSide" ].append( < 4049, -4589, 28 > )
	routes[ "droneHillSide" ].append( < 3525, -5825, 59 > )
	routes[ "droneHillSide" ].append( < 3525, -5825, 256 > )
	routes[ "droneHillSide" ].append( < 2532, -5460, 500 > )
	routes[ "droneHillSide" ].append( < 1685, -4169, 723 > )
	routes[ "droneHillSide" ].append( < 1277, -2847, 525 > )
	routes[ "droneHillSide" ].append( < 2392, -1935, 42 > )
	
	routes[ "infantryReaperShipStraight" ] <- []
	routes[ "infantryReaperShipStraight" ].append( < -1220, -4554, 225 > )
	routes[ "infantryReaperShipStraight" ].append( < -719, -4557, 296 > )
	routes[ "infantryReaperShipStraight" ].append( < 543, -4291, 296 > )
	routes[ "infantryReaperShipStraight" ].append( < 1640, -4456, 120 > )
	routes[ "infantryReaperShipStraight" ].append( < 3883, -4633, -1 > )
}