global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
    PlaceFDShop( < 1179, 561, 60 > )
	SetFDDropshipSpawn( < 830, -194, 112 >, < 0, 180, 0 > )
	SetFDGroundSpawn( < 1334, -273, 201 >, < 0, 90, 0 > )
	
	AddFDDropPodSpawn( < 2640, 1158, 108 > )
	AddFDDropPodSpawn( < 738, -52, 36 > )
	AddFDDropPodSpawn( < 1442, 1758, 12 > )
	
	AddWaveAnnouncement( "fd_introEasy" )
	AddWaveAnnouncement( "fd_soonNukeTitans" )
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
	WaveSpawn_SmokeWall( wave1, < -2318, -1783, 159 >, 0.3 )
	WaveSpawn_SmokeWall( wave1, < -1896, -3214, 160 >, 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "DropshipGrunt", < -3702, -2366, 121 >, 0.0, "", 1.0, "fd_waveTypeInfantry", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -2951, -3326, 137 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -2675, -2922, 224 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -3666, -2825, 137 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < -1834, 3471, -13 >, -60, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "DropshipGrunt", < -2614, 3932, -135 >, -86, "", 1.0, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -2026, 2598, 0 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1468, 4859, -39 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1899, 4559, -14 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < 2657, 4815, 27 >, -90, "", 1.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -979, 1179, 16 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -461, 1457, 6 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -769, -805, 122 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1194, -578, 98 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1160, -2042, 244 >, 0.0, "", 0.5, "fd_waveTypeStalkers" )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1487, -1875, 243 >, 0.0, "", 1.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 2 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1875, 4550, -19 >, 0.0, "", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 54, 3290, -48 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 387, 3142, -52 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -2717, -1600, 178 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -2575, -1874, 158 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < 297, -2336, 254 >, 90, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "TickReaper", < -4408, -1446, 262 >, 0, "", 1.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -120, 5065, -59 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 182, 4734, -18 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 399, 2965, -54 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -26, 3275, -48 >, 0.0, "", 0.8 )
	WaveSpawn_TitanSpawn( wave1, "Ion", < -1981, 2989, -12 >, -43, "" )
	WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
    array<WaveSpawnEvent> wave2
	WaveSpawn_TitanSpawn( wave2, "Ion", < -1867, -2933, 160 >, 60, "", 1.5, "fd_waveTypeTitanReg" )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -3287, -3334, 135 >, 0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -3327, -1678, 143 >, 0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -593, -685, 129 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -845, 971, 34 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "DropshipGrunt", < -1147, -681, 107 >, -93, "", 1.0, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_Announce( wave2, "PreNukeTitan", 0.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 2 )
	
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -2774, -3192, 183 >, 0.0, "", 0.3, "fd_waveTypeTicks" )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -2661, -1672, 164 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -3200, -2351, 137 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -3287, -3334, 135 >, 0, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Tone", < -3650, -2071, 119 >, 0, "",	0.6 )
	WaveSpawn_TitanSpawn( wave2, "Ronin", < -1892, -3463, 160 >, 90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "DropshipGrunt", < -3777, -2305, 106 >, -5, "", 1.0, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_Announce( wave2, "PreMortarTitan", 0.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 2 )
	
	WaveSpawn_TitanSpawn( wave2, "Nuke", < 285, -2380, 258 >, 90, "",	0.5 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -192, -2409, 241 >, 90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -4270, -2113, 148 >, 0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -197, -2282, 221 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -402, -2006, 170 >, 0.0, "", 2.0 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < 922, -2220, 243 >, 90, "", 1.0, "fd_waveTypeReaperTicks" )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -4331, 156, 132 >, 0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -4584, -2727, 131 >, 0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -4635, -1772, 187 >, 0.0, "", 0.8 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -4486, -2772, 131 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 4 )
	
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -2820, -1801, 151 >, 0, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -2814, -3358, 159 >, 60, "", 2.5 )
	WaveSpawn_TitanSpawn( wave2, "Northstar", < -4269, -2819, 131 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -3226, -1638, 141 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -3708, -2145, 123 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1240, -1957, 243 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -1300, -2936, 203 >, 90, "", 0.5, "fd_waveComboNukeMortar" )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -2061, -3021, 171 >, 45, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -4436, -39, 144 >, 0.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -4178, 1909, 190 >, 0.0, "", 1.0 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -2801, -1570, 185 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Nuke", < -2206, -939, 146 >, 0, "" )
	
	WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave3
	WaveSpawn_TitanSpawn( wave3, "Sniper", < 75, 5262, -59 >, -90.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Scorch", < -206, 5486, -70 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Scorch", < 263, 5483, -12 >, -90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < -3717, 3239, 2560 >, 0.0, "", 1.5, "fd_waveTypeCloakDrone", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 2332, 4558, 34 >, -90, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -1858, 6423, -104 >, -90, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.0 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 1601, 4971, -10 >, -90, "", 0.2, "fd_waveTypeReapers" )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2029, 4709, 23 >, -90, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1118, 3271, 1 >, 0, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1000, 3644, 11 >, 0, "", 0.8 )
	WaveSpawn_TitanSpawn( wave3, "Scorch", < -2563, 2956, -55 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Ion", < -2196, 3600, -66 >, -45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < -2884, 3580, -152 >, -35, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.0 )
	WaveSpawn_InfantrySpawn( wave3, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 3.0 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -1143, 3460, 8 >, 0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -182, 1865, 4 >, 75, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 467, 3264, -51 >, -100, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 299, -2440, 272 >, 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -2274, 2186, 12 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 2023, 4714, 23 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 1571, 4986, -13 >, -90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave3, "CloakDrone", < 942, 4508, 2560 >, 0.0, "", 3.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_Announce( wave3, "EliteTitans", 0.0 )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < -1968, 1751, 15 >, 0, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Ronin", < 73, 5400, -59 >, -90, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Sniper", < -4133, 2150, 186 >, 0, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Sniper", < -3680, 5041, -40 >, 0, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	
	WaveSpawnEvents.append( wave3 )
	
	/*
	 __      __                 _ _  
	 \ \    / /__ _ __ __ ___  | | | 
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_| 
	
	*/
    array<WaveSpawnEvent> wave4
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1957, 1745, 15 >, 0, "", 0.5, "fd_incReaperClump" )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1157, 3358, 3 >, 0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -392, 1393, 7 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -846, 1228, 10 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < -1998, 3000, -13 >, -35, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Ion", < -2260, 2742, -13 >, -35, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Ion", < -1913, 3414, -13 >, -35, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < 2023, 4714, 23 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 1571, 4986, -13 >, -90, "", 3.5 )
	WaveSpawn_InfantrySpawn( wave4, "CloakDrone", < 1801, 4594, 2560 >, 0.0, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )
	
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 488, 3305, -51 >, -110, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 2811, 4636, 54 >, -90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -26, 3275, -48 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 346, 3190, -50 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -827, 1481, 5 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -2770, -1812, 158 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -220, -2390, 237 >, 90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < 97, 4826, -38 >, -90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "CloakDrone", < 97, 5386, 2560 >, 0.0, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 2 )
	
	WaveSpawn_TitanSpawn( wave4, "Legion", < -1998, 3000, -13 >, -35, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Ronin", < -2260, 2742, -13 >, -35, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Ronin", < -1913, 3414, -13 >, -35, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -1966, 2649, 1 >, 0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -1693, 3165, 3 >, 0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -4332, 74, 135 >, 0, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -3573, 5198, -14 >, -45, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -1825, 6377, -102 >, -90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -4215, 1997, 194 >, 0, "", 	1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -4037, 1280, 228 >, 0.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -4122, 768, 205 >, 0.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -4006, 5990, -162 >, -90.0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -3118, 6392, -60 >, -90.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -1333, -2934, 202 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -2025, -2993, 169 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < 287, -2327, 253 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -239, -2371, 232 >, 90, "" )
	
	WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave5
	WaveSpawn_SmokeWall( wave5, < 2064, 4431, -4 >, 0.2 )
	WaveSpawn_SmokeWall( wave5, < 117, 4365, 13 >, 0.4 )
	WaveSpawn_SmokeWall( wave5, < -1503, 2655, 12 >, 0.6 )
	WaveSpawn_SmokeWall( wave5, < -2321, -1784, 159 >, 0.8 )
	WaveSpawn_SmokeWall( wave5, < -1905, -3238, 161 >, 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -182, 1865, 4 >, 75, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 299, -2440, 272 >, 90, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "DropshipGrunt", < -1602, -907, 121 >, -5, "", 1.5, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_InfantrySpawn( wave5, "DropshipGrunt", < -2614, 3932, -135 >, -86, "", 1.5, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -461, 1432, 6 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < -655, -694, 126 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Sniper", < 75, 5262, -59 >, -90, "", 2.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 288, -2361, 257 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2678, 4752, 36 >, -90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < 1801, 4594, 2560 >, 0.0, "", 0.1, "fd_incCloakDroneClump", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 1207, -1974, 244 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Stalker", < 1924, -2125, 286 >, 0.0, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < 1537, -2282, 2560 >, 0.0, "", 1.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -1998, 3000, -13 >, -35, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -2739, -1805, 158 >, 0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -1319, -2979, 203 >, 90, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 3188, 3720, 194 >, 180, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Northstar", < -3753, -2485, 129 >, 0, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -3297, -1772, 128 >, 0, "", 0.8, "fd_waveComboArcNuke" )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1909, -3472, 160 >, 90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 287, -2327, 253 >, 90, "", 0.4 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -239, -2371, 232 >, 90, "", 3.5 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < -2448, -2597, 2560 >, 0.0, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Legion", < 75, 5262, -59 >, -90, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -206, 5486, -70 >, -90, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < 263, 5483, -12 >, -90, "", 3.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -1825, 6377, -102 >, -90, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -4215, 1997, 194 >, 0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave5, "DropshipGrunt", < -3661, -2309, 121 >, -10, "", 2.5, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_InfantrySpawn( wave5, "DropshipGrunt", < -38, 5420, -62 >, 0.0, "", 1.5, "", 0.0, eFDSD.ALL, 6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 287, -2327, 253 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -239, -2371, 232 >, 90, "", 3.5 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < 1537, -2282, 2560 >, 0.0, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 1603, 4951, -14 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 2015, 4716, 21 >, -90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "Drones", < 813, 7910, 128 >, -90, "droneFarmside", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1991, 2615, 1 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1672, 3122, 3 >, -50, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 488, 3305, -51 >, -110, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 2811, 4636, 54 >, -90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 1976, 4717, 11 >, -90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2408, 4537, 40 >, -90, "", 3.5 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < 1801, 4594, 2560 >, 0.0, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	
	WaveSpawnEvents.append( wave5 )
}

void function RegisterCustomFDContent()
{
	array<entity> dropshipSpawns = GetEntArrayByClass_Expensive( "info_spawnpoint_dropship_start" )
	foreach ( entity dropshipSpawn in dropshipSpawns )
		dropshipSpawn.Destroy()

	array<entity> aiPositions = GetEntArrayByClass_Expensive( "info_target" )
	foreach ( entity position in aiPositions )
		if( position.HasKey( "editorclass" ) && position.kv.editorclass == "info_fd_ai_position" && expect string( position.kv.aiType ).tointeger() != eStationaryAIPositionTypes.LAUNCHER_REAPER )
			position.Destroy()
	
	AddFDCustomShipStart( < 1967, 1863, 660 >, < 0, -120, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < 1180, 1863, 660 >, < 0, -90, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < -4614, 3969, 1280 >, < 0, -45, 0 >, TEAM_IMC )
	AddFDCustomShipStart( < -3501, 4923, 1280 >, < 0, -45, 0 >, TEAM_IMC )
	
	AddFDCustomTitanStart( < 1336, 3, 37 >, < 0, 90, 0 > )
	AddFDCustomTitanStart( < 2762, 1840, 72 >, < 0, 180, 0 > )
	
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < 1682, 2485, -8 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < 1672, 2366, -4 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white.mdl", < 1809, 2412, -8 >, < 0, -45, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white.mdl", < 1663, 2368, 90 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < 1793, 2507, 90 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < 1804, 2535, -8 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < 1410, 2501, 182 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/containers/cargo_container_white_separate.mdl", < 1635, 2390, 182 >, < 0, 90, 0 > )
	
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < 2444, 1930, 16 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white.mdl", < 2444, 2033, 16 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < 2444, 1930, 114 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < 2444, 2033, 114 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < 2444, 1983, 212 >, < 0, 45, 0 > )
	AddFDCustomProp( $"models/containers/cargo_container_white_separate.mdl", < 2328, 2020, 4 >, < 0, 0, 0 > )
	
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white.mdl", < 1210, 3017, -5 >, < 0, -45, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < 1329, 3073, 5 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < 1210, 3021, 92 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/containers/cargo_container_white_separate.mdl", < 1311, 3072, 102 >, < 0, 0, 0 > )
	
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -188, 4469, 6 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -310, 4469, 6 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -431, 4469, 6 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -432, 4469, 104 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -309, 4469, 104 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -188, 4469, 104 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -309, 4566, -5 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/containers/cargo_container_white_separate.mdl", < -210, 4473, 203 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/containers/cargo_container_white_separate.mdl", < -172, 4569, -5 >, < 0, 90, 0 > )
	
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -569, -1010, 159 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -569, -1137, 159 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -569, -1010, 257 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white.mdl", < -569, -1137, 257 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -573, -1072, 353 >, < 0, 90, 0 > )
	
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -1142, -1081, 159 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -1269, -1081, 159 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -1396, -1081, 159 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -1142, -978, 142 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -1269, -978, 142 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -1395, -978, 142 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -1142, -1081, 256 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -1269, -1081, 256 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_white_open.mdl", < -1395, -1081, 256 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -1269, -978, 238 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -1394, -978, 238 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -1164, -1084, 352 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/containers/cargo_container_white_separate.mdl", < -1029, -1091, 156 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/containers/cargo_container_white_separate.mdl", < -1369, -1092, 352 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -1406, -868, 115 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_blue.mdl", < -1406, -868, 213 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -1132, -1201, 165 >, < 0, 90, 0 > )
	AddFDCustomProp( $"models/imc_base/cargo_container_imc_01_red.mdl", < -1132, -1201, 264 >, < 0, 90, 0 > )
	
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < 1307, 3816, 157 >, < 0, 180, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < 1181, 3686, 157 >, < 0, -90, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_curved_01.mdl", < 1173, 3738, 157 >, < 0, -90, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_curved_01.mdl", < 1258, 3554, 157 >, < 0, 0, 0 > )
	
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -503, 2807, 157 >, < 0, 160, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -666, 2727, 157 >, < 0, -110, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_curved_01.mdl", < -656, 2779, 157 >, < 0, -110, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_curved_01.mdl", < -639, 2577, 157 >, < 0, -20, 0 > )
	
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -1384, 917, 328 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -1270, 917, 328 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -1156, 917, 328 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -1324, 530, 328 >, < 0, 0, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -1211, 530, 328 >, < 0, 0, 0 > )
	
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -240, -888, 557 >, < 0, 250, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < -161, -1057, 557 >, < 0, -20, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_curved_01.mdl", < -212, -1044, 557 >, < 0, -20, 0 > )
	
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < 37, 3063, 233 >, < 0, 160, 0 > )
	AddFDCustomProp( $"models/barriers/sandbags_large_01.mdl", < 147, 3023, 233 >, < 0, 160, 0 > )
	
	CreateColonyZipline( < 2061, 3294, 590 >, < 1716, 1508, 597 > )
	CreateColonyZipline( < 2061, 3294, 590 >, < 177, 2433, 676 > )
	CreateColonyZipline( < 152, 2377, 804 >, < -1510, 524, 650 > )
	CreateColonyZipline( < -1510, 524, 650 >, < -1728, -1878, 460 > )
	CreateColonyZipline( < 1059, -1708, 860 >, < -1136, -2008, 502 > )
	CreateColonyZipline( < -2921, 5036, 105 >, < -1500, 2791, 542 > )
	CreateColonyZipline( < -1510, 524, 650 >, < -4534, 1180, 563 > )
	
	AddStationaryAIPosition(< -2478, 6083, -92 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -2783, 5964, -55 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -854, 6282, -134 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -524, 6548, -133 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -3707, 808, 122 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -4038, -2909, 136 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -4486, -2159, 164 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	AddStationaryAIPosition(< -3688, 1412, 125 >, eStationaryAIPositionTypes.MORTAR_TITAN)
	
	AddStationaryAIPosition(< 1430, -2443, 526 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< -1410, 717, 328 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< 2334, 5538, 55 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< -4605, -2510, 145 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< -1711, 6043, -100 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	AddStationaryAIPosition(< -1534, -3469, 186 >, eStationaryAIPositionTypes.MORTAR_SPECTRE)
	
	AddStationaryAIPosition(< 2243, -1663, 235 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< 2564, 3061, 15 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -2250, 5372, 56 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -3199, -1855, 118 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -242, -2169, 200 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< 50, 5776, -65 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	AddStationaryAIPosition(< -4160, 1020, 219 >, eStationaryAIPositionTypes.SNIPER_TITAN)
	
	AddStationaryAIPosition(< -3561, -1761, 287 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	AddStationaryAIPosition(< -1069, 5534, 270 >, eStationaryAIPositionTypes.LAUNCHER_REAPER)
	
	routes[ "outskirtCamp" ] <- []
	routes[ "outskirtCamp" ].append( < -3065, -1856, 116 > )
	routes[ "outskirtCamp" ].append( < -1886, -1452, 176 > )
	routes[ "outskirtCamp" ].append( < 862, -1926, 254 > )
	routes[ "outskirtCamp" ].append( < 2036, -1935, 272 > )
	routes[ "outskirtCamp" ].append( < 2159, -292, 165 > )
	routes[ "outskirtCamp" ].append( < 1888, 342, 97 > )
	
	routes[ "outskirtCampCorner" ] <- []
	routes[ "outskirtCampCorner" ].append( < -2559, -3368, 175 > )
	routes[ "outskirtCampCorner" ].append( < -1291, -2700, 204 > )
	routes[ "outskirtCampCorner" ].append( < 715, -1635, 238 > )
	routes[ "outskirtCampCorner" ].append( < 698, -1149, 203 > )
	routes[ "outskirtCampCorner" ].append( < 2003, -1078, 233 > )
	routes[ "outskirtCampCorner" ].append( < 2850, -367, 179 > )
	routes[ "outskirtCampCorner" ].append( < 2508, 565, 278 > )
	routes[ "outskirtCampCorner" ].append( < 2373, 875, 103 > )
	
	routes[ "outskirtMainGateShort" ] <- []
	routes[ "outskirtMainGateShort" ].append( < -2046, 3024, -21 > )
	routes[ "outskirtMainGateShort" ].append( < 167, 1999, 8 > )
	routes[ "outskirtMainGateShort" ].append( < 687, 1140, 17 > )
	routes[ "outskirtMainGateShort" ].append( < 1357, 1000, 3 > )
	
	routes[ "plantationGate1" ] <- []
	routes[ "plantationGate1" ].append( < 92, 4956, -54 > )
	routes[ "plantationGate1" ].append( < 113, 4025, -23 > )
	routes[ "plantationGate1" ].append( < 1047, 3441, -27 > )
	routes[ "plantationGate1" ].append( < 879, 2835, -35 > )
	routes[ "plantationGate1" ].append( < 1237, 2039, 7 > )
	routes[ "plantationGate1" ].append( < 2057, 1467, 13 > )
	
	routes[ "plantationGate2" ] <- []
	routes[ "plantationGate2" ].append( < 1714, 4697, -21 > )
	routes[ "plantationGate2" ].append( < 2225, 4242, 21 > )
	routes[ "plantationGate2" ].append( < 1633, 3857, 14 > )
	routes[ "plantationGate2" ].append( < 1987, 2900, 0 > )
	routes[ "plantationGate2" ].append( < 2077, 1531, 14 > )
	
	routes[ "infantryShortBuilding" ] <- []
	routes[ "infantryShortBuilding" ].append( < 283, 3255, -48 > )
	routes[ "infantryShortBuilding" ].append( < 1224, 2559, 5 > )
	routes[ "infantryShortBuilding" ].append( < 1386, 1223, 15 > )
	
	routes[ "infantryCloseMainGate" ] <- []
	routes[ "infantryCloseMainGate" ].append( < -680, 1367, 5 > )
	routes[ "infantryCloseMainGate" ].append( < -130, 1525, 22 > )
	routes[ "infantryCloseMainGate" ].append( < 42, 1260, 21 > )
	routes[ "infantryCloseMainGate" ].append( < 226, 1052, 19 > )
	routes[ "infantryCloseMainGate" ].append( < 1045, 1278, 31 > )
	routes[ "infantryCloseMainGate" ].append( < 1072, 1566, 31 > )
	routes[ "infantryCloseMainGate" ].append( < 1512, 1557, 31 > )
	routes[ "infantryCloseMainGate" ].append( < 1862, 1392, 14 > )
	
	routes[ "infantryCrateStack" ] <- []
	routes[ "infantryCrateStack" ].append( < -961, -640, 100 > )
	routes[ "infantryCrateStack" ].append( < -502, -240, 99 > )
	routes[ "infantryCrateStack" ].append( < -489, 253, 100 > )
	routes[ "infantryCrateStack" ].append( < 781, 337, 30 > )
	routes[ "infantryCrateStack" ].append( < 1766, 579, 44 > )
	
	routes[ "infantryTickRadioStation" ] <- []
	routes[ "infantryTickRadioStation" ].append( < 1406, -2056, 243 > )
	routes[ "infantryTickRadioStation" ].append( < 1547, -1512, 244 > )
	routes[ "infantryTickRadioStation" ].append( < 1084, -836, 239 > )
	routes[ "infantryTickRadioStation" ].append( < 754, -61, 36 > )
	routes[ "infantryTickRadioStation" ].append( < 1847, 564, 53 > )
	
	routes[ "radioStationMain" ] <- []
	routes[ "radioStationMain" ].append( < -47, -1986, 205 > )
	routes[ "radioStationMain" ].append( < 686, -1376, 207 > )
	routes[ "radioStationMain" ].append( < -10, -343, 92 > )
	routes[ "radioStationMain" ].append( < 138, 317, 36 > )
	routes[ "radioStationMain" ].append( < 1554, 231, 49 > )
	routes[ "radioStationMain" ].append( < 1816, 554, 51 > )
	
	routes[ "insideGrassfield" ] <- []
	routes[ "insideGrassfield" ].append( < -741, 3426, 5 > )
	routes[ "insideGrassfield" ].append( < 149, 3301, -46 > )
	routes[ "insideGrassfield" ].append( < 164, 2543, -1 > )
	routes[ "insideGrassfield" ].append( < 231, 1958, 9 > )
	routes[ "insideGrassfield" ].append( < 672, 1100, 15 > )
	routes[ "insideGrassfield" ].append( < 1441, 1009, 5 > )
	
	routes[ "droneFarmside" ] <- []
	routes[ "droneFarmside" ].append( < 1708, 3068, 128 > )
	routes[ "droneFarmside" ].append( < 2115, 2246, 4 > )
	routes[ "droneFarmside" ].append( < 2142, 315, 267 > )
	routes[ "droneFarmside" ].append( < 1855, -841, 304 > )
	routes[ "droneFarmside" ].append( < 789, -1166, 212 > )
	routes[ "droneFarmside" ].append( < 7, -382, 97 > )
	routes[ "droneFarmside" ].append( < -445, 906, 322 > )
	routes[ "droneFarmside" ].append( < -1148, 2202, 17 > )
	routes[ "droneFarmside" ].append( < -308, 3759, 0 > )
	routes[ "droneFarmside" ].append( < 883, 3721, 128 > )
}

void function CreateColonyZipline( vector startPos, vector endPos )
{
	string startpointName = UniqueString( "rope_startpoint" )
	string endpointName = UniqueString( "rope_endpoint" )

	entity rope_start = CreateEntity( "move_rope" )
	SetTargetName( rope_start, startpointName )
	rope_start.kv.NextKey = endpointName
	rope_start.kv.MoveSpeed = 64
	rope_start.kv.Slack = 0
	rope_start.kv.Subdiv = "4"
	rope_start.kv.Width = "2"
	rope_start.kv.Type = "0"
	rope_start.kv.TextureScale = "1"
	rope_start.kv.RopeMaterial = "cable/zipline.vmt"
	rope_start.kv.PositionInterpolator = 2
	rope_start.kv.Zipline = "1"
	rope_start.kv.ZiplineAutoDetachDistance = "150"
	rope_start.kv.ZiplineSagEnable = "1"
	rope_start.kv.ZiplineSagHeight = "120"
	rope_start.SetOrigin( startPos )

	entity rope_end = CreateEntity( "keyframe_rope" )
	SetTargetName( rope_end, endpointName )
	rope_end.kv.MoveSpeed = 64
	rope_end.kv.Slack = 0
	rope_end.kv.Subdiv = "4"
	rope_end.kv.Width = "2"
	rope_end.kv.Type = "0"
	rope_end.kv.TextureScale = "1"
	rope_end.kv.RopeMaterial = "cable/zipline.vmt"
	rope_end.kv.PositionInterpolator = 2
	rope_end.kv.Zipline = "1"
	rope_end.kv.ZiplineAutoDetachDistance = "150"
	rope_end.kv.ZiplineSagEnable = "1"
	rope_end.kv.ZiplineSagHeight = "120"
	rope_end.SetOrigin( endPos )

	DispatchSpawn( rope_start )
	DispatchSpawn( rope_end )
}