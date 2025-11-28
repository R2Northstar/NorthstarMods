global function initFrontierDefenseData
void function initFrontierDefenseData()
{
    PlaceFDShop( < -710, 210, 408 >, < 0, -90, 0 > )
	SetFDDropshipSpawn( < 2430, 594, 128 >, < 0, 180, 0 > )
	SetFDGroundSpawn( < 961, 845, 409 >, < 0, -130, 0 > )
	
	AddFDDropPodSpawn( < 1403, 1310, 256 > )
	AddFDDropPodSpawn( < -1135, 1450, 224 > )
	AddFDDropPodSpawn( < 1041, -1422, 264 > )
	
	AddWaveAnnouncement( "fd_introEasy" )
	AddWaveAnnouncement( "fd_waveTypeTicks" )
	AddWaveAnnouncement( "fd_waveTypeReaperTicks" )
	AddWaveAnnouncement( "fd_waveTypeFlyers" )
	AddWaveAnnouncement( "fd_waveTypeTitanArc" )
	
	AddFDCustomTitanStart( < 1563, 1481, 256 >, < 0, 180, 0 > )
	AddFDCustomTitanStart( < 258, 144, 404 >, < 0, 0, 0 > )

	AddStationaryAIPosition( < -31, -3695, 335 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -830, 3465, 470 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < 127, 3712, 412 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < 2069, -1881, 256 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	
	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1291, 1519, 256 >, 0.0, "leftNear", 1.5, "fd_waveTypeInfantry" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1844, -2248, 101 >, 0.0, "midHalfway_infantry", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1198, 1588, 208 >, 0.0, "leftHalfway_infantry", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1000, -3102, 127 >, 0.0, "right_infantry", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -375, -2590, 185 >, 0.0, "infantyPerch_right1", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1638, -2005, 240 >, 0.0, "rightHalfway_infantry" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 6 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1000, -3102 , 127 >, 0.0, "midNear", 1.0, "fd_waveTypeStalkers" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 177, 3409, 120 >, 0.0, "leftFar0", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 2295, -2782, -45 >, 0.0, "rightFar02", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2488, 3691, -101 >, 0.0, "leftFar1", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -485, -1377, 256 >, 0.0, "midNear", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -774, -3387, 144 >, 0.0, "midHalfway_infantry" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 6 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1811, 1345, 84 >, 0.0, "leftHalfway_infantry", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 2336, -1184, -75 >, 0.0, "midNear", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1803, 3370, 84 >, 0.0, "leftHalfway_infantry", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 1105, -1909, 240 >, 0.0, "midNear", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -695, 2408, 128 >, 0.0, "leftHalfway_infantry", 1.0 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -591, -1787, 240 >, 0.0, "midNear", 1.0 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < 2720, -3720, -51 >, 90, "rightFar01" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 6 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -354, -1161, 256 >, 0.0, "infantyPerch_right3", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1173, 1859, 258 >, 0.0, "leftNear", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 488, 1548, 256 >, 0.0, "leftNear", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 919, -966, 255 >, 0.0, "midNear", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 728, 3312, 81 >, 0.0, "leftFar1", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -1202, 2671, 74 >, 0.0, "leftFar0", 0.8 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < 211, -3057, 165 >, 0.0, "right_infantry" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 6 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1844, -2248, 101 >, 0.0, "midHalfway_infantry", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1173, 1859, 258 >, 0.0, "leftNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1198, 1588, 208 >, 0.0, "leftHalfway_infantry", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 2488, 3691, -101 >, 0.0, "leftFar1", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1000, -3102, 127 >, 0.0, "right_infantry", 0.5 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < 636, 3499, 81 >, -90, "leftFar0" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 6 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 1291, 1519, 256 >, 0.0, "leftNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -774, -3387, 144 >, 0.0, "midHalfway_infantry", 0.4 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -354, -1161, 256 >, 0.0, "infantyPerch_right3", 0.3 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 488, 1548, 256 >, 0.0, "leftNear", 0.2 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < 177, 3409, 120 >, 0.0, "leftFar0" )
	
	WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
    array<WaveSpawnEvent> wave2
	WaveSpawn_SmokeWall( wave2, < 1236, 2449, 82 >, 1.0 )
	WaveSpawn_SmokeWall( wave2, < -305, 1646, 256 >, 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1605 , 3012 , 86 >, 0.0, "leftFar0", 1.2, "fd_waveTypeTicks" )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 570 , 2765 , 76 >, 0.0, "leftFar0", 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1053 , 3099 , 96 >, 0.0, "leftFar0", 0.8 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1299 , 2639 , 84 >, 0.0, "leftFar0" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 6 )
	
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -1693 , 2672 , 92 >, 0.0, "leftFar0", 0.6 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -2033 , 3516 , 126 >, 0.0, "leftFar0", 0.8 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -1445 , 3084 , 112 >, 0.0, "leftFar0", 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -923 , 3165 , 177 >, 0.0, "leftFar0" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 6 )
	
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1106 , 5144 , 251 >, 0.0, "leftFar0", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1410 , 4322 , 142 >, 0.0, "leftFar0", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 422 , 4292 , 124 >, 0.0, "leftFar0", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 776 , 4689 , 223 >, 0.0, "leftFar0" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 6 )
	
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < -481, -1272, 256 >, 0.0, "midNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1053 , 3099 , 96 >, 0.0, "leftFar0", 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 570 , 2765 , 76 >, 0.0, "leftFar0", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 636, 3499, 81 >, -90, "leftFar0", 2.0 )
	WaveSpawn_TitanSpawn( wave2, "Sniper", < 3313, -527, -70 >, 180, "", 1.5, "fd_waveTypeTitanReg" )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1605 , 3012 , 86 >, 0.0, "leftFar0", 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1299 , 2639 , 84 >, 0.0, "leftFar0" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 4 )
	
	WaveSpawn_InfantrySpawn( wave2, "Stalker", < 1178, 1370, 256 >, 0.0, "leftNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -179 , -1193 , 256 >, 0.0, "midNear", 0.8 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -520 , -1109 , 256 >, 0.0, "midNear", 1.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < 2226, -3592, -64 >, 90, "rightFar02", 2.0 )
	WaveSpawn_TitanSpawn( wave2, "Sniper", < 210, 3401, 120 >, -55, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -467 , -1788 , 240 >, 0.0, "midNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 924 , -1128 , 256 >, 0.0, "midNear" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 4 )
	
	WaveSpawn_TitanSpawn( wave2, "Ronin", < -1809, 1301, 84 >, -90, "rightSwitchShort1", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Ronin", < -1784, -1113, 101 >, -90, "rightSwitchShort1", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1053 , 3099 , 96 >, 0.0, "leftFar0", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1299 , 2639 , 84 >, 0.0, "leftFar0", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < 1638, -2005, 240 >, 0.0, "rightHalfway_infantry", 2.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < 1268, -3696, 144 >, 90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 6 )
	
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1605 , 3012 , 86 >, 0.0, "leftFar0", 0.3 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -179 , -1193 , 256 >, 0.0, "midNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < -1693 , 2672 , 92 >, 0.0, "leftFar0", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -1808, -1112, 101 >, 0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1106 , 5144 , 251 >, 0.0, "leftFar0", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -1820, 1308, 84 >, 0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "Ticks", < 1053 , 3099 , 96 >, 0.0, "leftFar0" )
	
	WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave3
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 1105, -1909, 240 >, 0.0, "midNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -1202, 2671, 74 >, 0.0, "leftFar0", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 211, -3057, 165 >, 0.0, "right_infantry", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 636, 3499, 81 >, -90, "leftFar0", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2226, -3592, -64 >, 90, "rightFar02" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 2 )
	
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 919, -966, 255 >, 0.0, "midNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 1000, -3102 , 127 >, 0.0, "midNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 728, 3312, 81 >, 0.0, "leftFar1", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Monarch", < 3380, 2238, -47 >, 180, "leftFar1", 2.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 2720, -3720, -51 >, 90, "rightFar01", 1.5, "fd_waveTypeReapers" )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 3372, -416, -72 >, -145, "rightFar01", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -1446, 3687, 215 >, -90, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -1900, -2244, 101 >, 0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 2 )
	
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -485, -1377, 256 >, 0.0, "midNear", 0.4 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 2295, -2782, -45 >, 0.0, "rightFar02", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "PodGrunt", < -354, -1161, 256 >, 0.0, "infantyPerch_right3", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -1782, -2253, 101 >, -90, "leftSwitchShort02", 2.5 )
	WaveSpawn_SmokeWall( wave3, < 1236, 2449, 82 >, 0.5 )
	WaveSpawn_SmokeWall( wave3, < -305, 1646, 256 >, 0.5 )
	WaveSpawn_SmokeWall( wave3, < 2181, -963, -39 >, 0.5 )
	WaveSpawn_SmokeWall( wave3, < -523, -2326, 240 >, 0.5 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 2775, -3683, -66 >, 90, "rightFar01", 1.5, "fd_waveComboArcNuke" )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 2704, 3655, -111 >, -90, "leftFar1", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -1225, 3397, 179 >, -90, "leftFar0" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_TitanSpawn( wave3, "Ion", < 1239, -3684, 146 >, 180, "rightFar02", 1.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < 2336, -1184, -75 >, 0.0, "midNear", 3.5 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -442, -3685, 144 >, 90, "rightNear", 1.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -481, -1272, 256 >, 0.0, "midNear", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < 501, -3710, 144 >, -145, "rightNear", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -591, -1787, 240 >, 0.0, "midNear" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 8 )
	
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 2621, 3662, -111 >, -90, "leftFar1", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < 3382, 3304, -47 >, 180, "leftFar1", 5.0 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < 3356, -365, -65 >, -180, "rightFar02", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < 2378, -2216, -72 >, 0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -1883, 3478, 84 >, -90, "rightSwitchShort1", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -363, 1601, 256 >, 0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -1830, -1105, 101 >, 0, "leftSwitchShort02" )
	
	WaveSpawnEvents.append( wave3 )
	
	/*
	 __      __                 _ _  
	 \ \    / /__ _ __ __ ___  | | | 
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_| 
	
	*/
    array<WaveSpawnEvent> wave4
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 3596, -5433, 320 >, 90 , "rightDrone01", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 2563, -5827, 320 >, 90 , "rightDrone01", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 1477, -6026, 320 >, 90 , "rightDrone02", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 62, -6254, 320 >, 90 , "rightDrone03", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < -600, -6465, 320 >, 90 , "rightDrone04" )
	WaveSpawn_SmokeWall( wave4, < 450, -1024, 256 >, 1.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 12 )
	
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 3596, -5433, 320 >, 90 , "rightDrone01", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 2563, -5827, 320 >, 90 , "rightDrone01", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 1477, -6026, 320 >, 90 , "rightDrone02", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 62, -6254, 320 >, 90 , "rightDrone03", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < -600, -6465, 320 >, 90 , "rightDrone04" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 8 )
	
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -1842, 3301, 86 >, -35, "leftFar0", 0.8, "fd_incReaperClump" )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2271, 2787, 152 >, 0, "leftFar0", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -363, 1601, 256 >, 0, "", 1.2 )
	WaveSpawn_TitanSpawn( wave4, "Sniper", < 210, 3401, 120 >, -55, "", 5.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 62, -6254, 320 >, 90 , "rightDrone03", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 2967, -3395, -73 >, 90, "rightFar01", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 2386, -3242, -72 >, 90, "rightFar01", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 351, -3754, 144 >, 90, "", 1.2 )
	WaveSpawn_TitanSpawn( wave4, "Sniper", < 3313, -527, -70 >, 180, "", 5.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 2563, -5827, 320 >, 90 , "rightDrone01", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -442, -3685, 144 >, 90, "rightNear", 4.0 )
	WaveSpawn_InfantrySpawn( wave4, "CloakDrone", < 2629, -5409, 2560 >, 0 , "", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "CloakDrone", < 632, 3000, 2560 >, 0 , "", 2.0 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 1291, 1519, 256 >, 0.0, "leftNear", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 857, 2639, 83 >, 0.0, "leftNear" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 3413, 3326, -48 >, 180, "leftFar1", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 2778, 3681, -112 >, 225, "leftFar1", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -1440, 3731, 216 >, -90, "", 1.2 )
	WaveSpawn_Announce( wave4, "EliteTitans", 0.0 )
	WaveSpawn_TitanSpawn( wave4, "Monarch", < 3397, 2145, -48 >, 180, "leftFar1", 5.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -762, -3475, 144 >, 90, "rightNear", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 255, -2990, 164 >, 180, "rightNear", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -1928, -2201, 103 >, 0, "", 1.2 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 62, -6254, 320 >, 90 , "rightDrone03", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 1477, -6026, 320 >, 90 , "rightDrone02", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < -600, -6465, 320 >, 90 , "rightDrone04", 1.0 )
	WaveSpawn_TitanSpawn( wave4, "Ronin", < -6, -3462, 121 >, 90, "rightNear", 5.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 1000, -3102 , 127 >, 0.0, "midNear", 0.3 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 1105, -1909, 240 >, 0.0, "midNear" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 2573, 3587, -107 >, -90, "leftFar1", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 919, -966, 255 >, 0.0, "midNear", 0.8 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 1018, 3234, 110 >, -90, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < -402, -2545, 188 >, 0.0, "rightNear", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -2026, 3459, 122 >, -90, "leftFar0", 0.8 )
	WaveSpawn_InfantrySpawn( wave4, "Stalker", < 211, -3057, 165 >, 0.0, "right_infantry", 0.6 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 3550, -2110, 0 >, -90, "", 2.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 397, 1701, 256 >, -90, "", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "PodGrunt", < -354, -1161, 256 >, 0.0, "infantyPerch_right3" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )
	
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 3596, -5433, 320 >, 90 , "rightDrone01", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 1477, -6026, 320 >, 90 , "rightDrone02", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 62, -6254, 320 >, 90 , "rightDrone03", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < -600, -6465, 320 >, 90 , "rightDrone04", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 1477, -6026, 320 >, 90 , "rightDrone02" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 10 )
	
	WaveSpawn_TitanSpawn( wave4, "Ion", < 2970, -3597, -68 >, 90, "rightNear", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Ion", < 2521, -3597, -68 >, 90, "rightNear", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 3648, 1286, 0 >, 180, "rightFar01", 0.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 3648, 2037, 0 >, 180, "rightFar01", 1.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 1505, 3090, 95 >, 90, "leftNear", 0.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < 1086, 3090, 96 >, 90, "leftNear", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -1785, -2252, 101 >, 90, "rightNear", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 1477, -6026, 320 >, 90 , "rightDrone02", 1.0 )
	WaveSpawn_InfantrySpawn( wave4, "Drones", < 3596, -5433, 320 >, 90 , "rightDrone01" )
	
	WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
    array<WaveSpawnEvent> wave5
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 1722, -3681, 50 >, 90, "rightFar01", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1867, 3529, 86 >, -90, "leftFar0", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2261, 3078, 152 >, -90, "rightSwitchLong1", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < 3400, 1243, -65 >, 180, "midFar", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ion", < 3644, 2023, 0 >, 180, "midFar", 5.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Legion", < 151, 3402, 121 >, -90, "leftFar1", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Tone", < 613, 3522, 83 >, -90, "leftFar1", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2756, -3626, -71 >, 90, "rightFar01", 4.0 )
	WaveSpawn_InfantrySpawn( wave5, "CloakDrone", < 2756, -3626, 2560 >, 0 , "", 1.0 )
	WaveSpawn_InfantrySpawn( wave5, "PodGrunt", < -1786, -2257, 101 >, 0.0, "midHalfway_infantry", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1867 , 3356 , 96 >, -90 , "rightSwitchShort1", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2203 , 2963 , 164 >, -35 , "rightSwitchShort1", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1858 , 3613 , 96 >, -90 , "rightSwitchShort1" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )
	
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 3417, 3310, -46 >, 180, "rightSwitchLong2", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 3417, 3689, -46 >, 180, "rightSwitchLong2", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -442, -3685, 144 >, 90, "rightNear", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1909, 3657, 85 >, -90, "rightSwitchShort1", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -1909, 3373, 86 >, -90, "rightSwitchShort1", 5.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Sniper", < 3313, -527, -70 >, 180, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Sniper", < 1721, 3440, 95 >, -90, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave5, "PodGrunt", < -354, -1161, 256 >, 0.0, "infantyPerch_right3", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1858 , 3613 , 96 >, -90 , "rightSwitchShort1", 1.2 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2215 , 3278 , 164 >, -90 , "rightSwitchShort1", 1.8 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1443 , 3100 , 124 >, -65 , "rightSwitchShort1" )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -442, -3685, 144 >, 90, "rightNear" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )
	
	WaveSpawn_TitanSpawn( wave5, "Scorch", < 2970, -3597, -68 >, 90, "rightFar01", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < 2521, -3597, -68 >, 90, "rightFar01", 7.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 2970, -3597, -68 >, 90, "rightFar01", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < 2521, -3597, -68 >, 90, "rightFar01", 7.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1909, 3657, 85 >, -90, "rightSwitchLong1", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1909, 3373, 86 >, -90, "rightSwitchLong1", 5.0 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -1007, 3246, 178 >, -90, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 776, 3582, 83 >, -90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < 2621, 3662, -111 >, -90, "leftFar1", 5.0 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -1793, -2237, 101 >, 0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -1784, -1120, 101 >, 0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 4 )
	
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1909, 3657, 85 >, -90, "leftFar0", 1.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1909, 3373, 86 >, -90, "leftFar0", 3.0 )
	WaveSpawn_TitanSpawn( wave5, "Legion", < 2695, -3333, -73 >, 90, "leftSwitchShort01", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < 2854, -3538, -73 >, 90, "leftSwitchShort01", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < 2554, -3538, -73 >, 90, "leftSwitchShort01", 5.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -1793, -2237, 101 >, 0, "rightNear",1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Monarch", < -1784, -1120, 101 >, 0, "rightNear", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1443 , 3100 , 124 >, -65 , "rightSwitchShort1", 2.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1867 , 3356 , 96 >, -90 , "rightSwitchShort1", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2203 , 2963 , 164 >, -35 , "rightSwitchShort1" )
	
    WaveSpawnEvents.append( wave5 )
}