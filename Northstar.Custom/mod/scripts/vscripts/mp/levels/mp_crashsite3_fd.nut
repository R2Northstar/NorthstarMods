global function initFrontierDefenseData
void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )
	
    PlaceFDShop( < -9423, -2316, 764 >, < 0, 90, 0 > )
	SetFDDropshipSpawn( < -9105, -2417, 1201 > )
	SetFDGroundSpawn( < -8230, -1671, 725 >, < 0, -100, 0 > )
	OverrideFDHarvesterLocation( < -8751, -2341, 695 >, < 0, 180, 0 > )
	
	AddFDDropPodSpawn( < -10389, -1497, 600 > )
	AddFDDropPodSpawn( < -8705, -3011, 638 > )
	AddFDDropPodSpawn( < -9712, -2317, 1005 > )
	
	AddWaveAnnouncement( "fd_introEasy" )
	AddWaveAnnouncement( "fd_waveTypeTitanReg" )
	AddWaveAnnouncement( "fd_introHard" )
	AddWaveAnnouncement( "fd_waveComboArcNuke" )
	AddWaveAnnouncement( "fd_waveComboNukeTrain" )
	
	array<vector> nukeTitanSpawns = []
	nukeTitanSpawns.append( < -6685, 24, 1294 > )
	nukeTitanSpawns.append( < -6284, -50, 1199 > )
	nukeTitanSpawns.append( < -6089, -375, 1144 > )
	nukeTitanSpawns.append( < -6369, -420, 1111 > )
	nukeTitanSpawns.append( < -5853, -516, 1166 > )
	nukeTitanSpawns.append( < -6133, -161, 1169 > )
	nukeTitanSpawns.append( < -6893, -833, 998 > )
	nukeTitanSpawns.append( < -7130, -770, 1032 > )
	int spawnamount
	
	/*
	 __      __                 _ 
	 \ \    / /__ _ __ __ ___  / |
	  \ \/\/ // _` |\ V // -_) | |
	   \_/\_/ \__,_| \_/ \___| |_|
	
	*/
    array<WaveSpawnEvent> wave1
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -5724, 1552, 1354 >, 0.0, "", 0.5, "fd_waveTypeInfantry" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -5955, 1239, 1359 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -4317, 835, 1038 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -4688, 1223, 1154 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 588, -269, 688 >, 0.0, "", 0.5, "fd_waveTypeMortarSpectre" )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -394, -606, 560 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -525, -2305, 854 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -701, -1477, 696 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -869, -2984, 930 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -1129, -3003, 931 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 4 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -5749, -1566, 915 >, 0.0, "", 0.5, "fd_waveTypeStalkers" )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -5565, -1702, 978 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -6748, -829, 1007 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -7175, -1018, 913 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -6682, -4266, 675 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -6544, -4310, 675 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -4317, 835, 1038 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -4688, 1223, 1154 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -394, -606, 560 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "PodGrunt", < -701, -1477, 696 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < -603, -1523, 734 >, 160, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < -3017, 1378, 637 >, -146, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -6682, -4266, 675 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "Stalker", < -6544, -4310, 675 >, 0.0, "", 1.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < 588, -269, 688 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -525, -2305, 854 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", < -869, -2984, 930 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < -6716, 1767, 1352 >, -14, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave1, "Reaper", < -5640, -1925, 946 >, 76, "" )
	
    WaveSpawnEvents.append( wave1 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  |_  )
	  \ \/\/ // _` |\ V // -_)  / / 
	   \_/\_/ \__,_| \_/ \___| /___|
	
	*/
	array<WaveSpawnEvent> wave2
	WaveSpawn_TitanSpawn( wave2, "Legion", < -1528, -2719, 608 >, 94, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Tone", < -401, -584, 560 >, -174, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -4396, 1409, 1106 >, -132, "", 1.0, "fd_waveTypeReaperTicks" )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -6162, 1976, 1360 >, -86, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -7082, -715, 1018 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -6635, -4263, 675 >, 0.0, "", 2.5 )
	WaveSpawn_SmokeWall( wave2, < -3042, -2384, 688 >, 1.0 )
	WaveSpawn_SmokeWall( wave2, < -5521, -1774, 964 > )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 0 )
	
	WaveSpawn_TitanSpawn( wave2, "Sniper", < -6661, -4246, 675 >, 120, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Tone", < -6617, 1614, 1353 >, -50, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Tone", < -6446, 1898, 1362 >, -32, "", 2.5 )
	WaveSpawn_SmokeWall( wave2, < -5784, 693, 1389 >, 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Scorch", < -4169, 957, 994 >, -66, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -2941, 1326, 628 >, -123, "", 2.0 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -4151, 1187, 1005 >, -76, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", < -996, -3080, 931 >, 126, "", 2.5 )
	WaveSpawn_SmokeWall( wave2, < -4025, 354, 1001 >, 1.0 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < 588, -269, 688 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", < -2972, -2342, 692 >, 0.0, "" )
	WaveSpawn_Announce( wave2, "PreMortarTitan", 0.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 0 )
	
	WaveSpawn_TitanSpawn( wave2, "Sniper", < -1246, -24, 502 >, -122, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Monarch", < -971, -796, 626 >, 60, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Monarch", < -428, -543, 560 >, -145, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -5630, -1894, 937 >, 128, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "Reaper", < -5602, -1631, 971 >, 169, "", 3.0 )
	WaveSpawn_TitanSpawn( wave2, "Sniper", < -5879, -508, 1164 >, 177, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -5735, 1670, 1355 >, -97, "", 0.5 )
	WaveSpawn_TitanSpawn( wave2, "Mortar", < -4456, 1342, 1110 >, -90, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -6682, -4266, 675 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave2, "PodGrunt", < -6544, -4310, 675 >, 0.0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave2, "ArcTitan", < -3711, 481, 895 >, 177, "" )
	
    WaveSpawnEvents.append( wave2 )
	
	/*
	 __      __                 ____
	 \ \    / /__ _ __ __ ___  |__ /
	  \ \/\/ // _` |\ V // -_)  |_ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave3
	WaveSpawn_TitanSpawn( wave3, "Ion", < -2900, -1966, 688 >, -86, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1317, -2072, 601 >, -170, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1471, -2590, 608 >, 150, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -783, -1483, 693 >, -143, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -721, -902, 624 >, -68, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1128, -220, 527 >, -105, "", 2.5 )
	WaveSpawn_TitanSpawn( wave3, "Legion", < -453, -559, 560 >, -176, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -721, -902, 624 >, -68, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -675, -463, 560 >, -124, "", 3.0 )
	WaveSpawn_InfantrySpawn( wave3, "PodGrunt", < -4317, 835, 1038 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave3, "PodGrunt", < -4688, 1223, 1154 >, 0.0, "" )
	WaveSpawn_Announce( wave3, "PreNukeTitan", 0.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -2882, -2044, 696 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -2939, -2392, 701 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave3, "Stalker", < -2494, -2372, 688 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -4396, 1409, 1106 >, -132, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave3, "TickReaper", < -6162, 1976, 1360 >, -86, "", 3.5 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -5735, 1670, 1355 >, -97, "", 0.7 )
	WaveSpawn_TitanSpawn( wave3, "Mortar", < -4456, 1342, 1110 >, -90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 2 )
	
	WaveSpawn_InfantrySpawn( wave3, "Ticks", < -5724, 1552, 1354 >, 0.0, "", 0.4, "fd_waveTypeTicks" )
	WaveSpawn_InfantrySpawn( wave3, "Ticks", < -5955, 1239, 1359 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave3, "Ticks", < -4317, 835, 1038 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave3, "Ticks", < -4688, 1223, 1154 >, 0.0, "", 3.0 )
	WaveSpawn_TitanSpawn( wave3, "Nuke", < -4169, 957, 994 >, -66, "", 0.5 )
	WaveSpawn_TitanSpawn( wave3, "Ion", < -2941, 1326, 628 >, -123, "", 0.6 )
	WaveSpawn_TitanSpawn( wave3, "Ion", < -4151, 1187, 1005 >, -76, "", 0.7 )
	WaveSpawn_TitanSpawn( wave3, "ArcTitan", < -3711, 481, 895 >, 177, "", 5.0 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -675, -463, 560 >, -124, "", 0.3 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1128, -220, 527 >, -105, "", 0.4 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1317, -2072, 601 >, -170, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -721, -902, 624 >, -68, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -1471, -2590, 608 >, 150, "", 0.7 )
	WaveSpawn_ReaperSpawn( wave3, "Reaper", < -721, -902, 624 >, -68, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 4 )
	
	WaveSpawn_Announce( wave3, "EliteTitans", 0.0 )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -783, -1483, 693 >, -143, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -2900, -1966, 688 >, -86, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave3, "Tone", < -453, -559, 560 >, -176, "", 5.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < 588, -269, 688 >, 0.0, "", 0.7, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave3, "Spectre", < -394, -606, 560 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < -525, -2305, 854 >, 0.0, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave3, "Spectre", < -701, -1477, 696 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", < -869, -2984, 930 >, 0.0, "", 0.3, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave3, "Spectre", < -1129, -3003, 931 >, 0.0, "" )
	
    WaveSpawnEvents.append( wave3 )
	
	/*
	 __      __                 _ _  
	 \ \    / /__ _ __ __ ___  | | | 
	  \ \/\/ // _` |\ V // -_) |_  _|
	   \_/\_/ \__,_| \_/ \___|   |_| 
	
	*/
	array<WaveSpawnEvent> wave4
	WaveSpawn_TitanSpawn( wave4, "Tone", < -1102, -304, 535 >, -120, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Tone", < -615, -484, 560 >, -120, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -1501, -2668, 611 >, 145, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Scorch", < -904, -1800, 740 >, 180, "", 2.5 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -117, -704, 601 >, -68, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "Reaper", < -675, -463, 560 >, -124, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -904, -1808, 741 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave4, "Ticks", < -769, -738, 624 >, 0.0, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -580, -2358, 857 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -1064, -3105, 931 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )
	
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -6660, 29, 1293 >, 0, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -6652, 1824, 1359 >, -35, "", 2.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < -6643, 1282, 1366 >, 0, "", 1.0 )
	WaveSpawn_ReaperSpawn( wave4, "TickReaper", < 600, -314, 687 >, 0, "", 3.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -112, -702, 602 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -1100, -286, 534 >, -90, "", 0.6 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -2873, 1320, 626 >, 180, "", 0.7 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -4742, 1492, 1204 >, -90, "", 0.8 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -5343, 13, 1309 >, 180, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -2966, -2102, 688 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -2606, -2294, 688 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )
	
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -4813, 1022, 1093 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -4486, 767, 1083 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -4134, 971, 982 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Sniper", < -2932, -2074, 688 >, 0, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Sniper", < -2745, 629, 479 >, 0, "", 3.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -1102, -304, 535 >, -120, "", 0.5, "fd_waveTypeTitanNuke" )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -615, -484, 560 >, -120, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -1501, -2668, 611 >, 145, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -904, -1800, 740 >, 180, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "MortarSpectre", < 592, -299, 687 >, 0.0, "", 0.3, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave4, "MortarSpectre", < -531, -2281, 852 >, 0.0, "", 0.3, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave4, "MortarSpectre", < -1071, -3113, 931 >, 0.0, "", 0.3, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 4 )
	
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -6626, 1265, 1367 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -6634, 1818, 1359 >, -35, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -5697, 1646, 1356 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -5998, 1874, 1364 >, -90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -1088, -284, 536 >, -135, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -607, -476, 560 >, -120, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -868, -788, 624 >, 145, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -131, -696, 599 >, 180, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -2753, 648, 479 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -3630, 701, 818 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -4133, 1026, 980 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -4251, 629, 1033 >, 0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -1530, -2773, 608 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -894, -1816, 745 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "ArcTitan", < -1582, -2020, 580 >, -45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave4, "Nuke", < -1298, -1508, 622 >, -90, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave4, 6 )
	
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -6626, 1265, 1367 >, 0, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -6634, 1818, 1359 >, -35, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -5697, 1646, 1356 >, -90, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -5998, 1874, 1364 >, -90, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -6636, -4279, 675 >, 0, "", 1.5 )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -1088, -284, 536 >, -135, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -607, -476, 560 >, -120, "", 0.6, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -868, -788, 624 >, 145, "", 0.7, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave4, "Mortar", < -131, -696, 599 >, 180, "", 2.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -7151, -1044, 906 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave4, "Spectre", < -6978, -754, 1008 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave4, "Northstar", < -6636, -4279, 675 >, 0, "" )
	
    WaveSpawnEvents.append( wave4 )
	
	/*
	 __      __                 ___ 
	 \ \    / /__ _ __ __ ___  | __|
	  \ \/\/ // _` |\ V // -_) |__ \
	   \_/\_/ \__,_| \_/ \___| |___/
	
	*/
	array<WaveSpawnEvent> wave5
	WaveSpawn_Announce( wave5, "Everything", 0.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -3630, 701, 818 >, 90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -5697, 1646, 1356 >, -90, "", 0.9 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2753, 648, 479 >, 180, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -894, -1816, 745 >, 180, "", 0.7 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -6634, 1818, 1359 >, -35, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1298, -1508, 622 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -5998, 1874, 1364 >, -90, "", 0.4 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -131, -696, 599 >, 180, "", 0.3 )
	WaveSpawn_TitanSpawn( wave5, "Scorch", < -607, -476, 560 >, -120, "", 0.4 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1582, -2020, 580 >, -45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -868, -788, 624 >, 145, "", 0.6 )
	WaveSpawn_TitanSpawn( wave5, "Tone", < -1088, -284, 536 >, -135, "", 0.7 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -4251, 629, 1033 >, 0, "", 0.8 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -6626, 1265, 1367 >, 0, "", 0.9 )
	WaveSpawn_TitanSpawn( wave5, "Ion", < -1530, -2773, 608 >, 90, "", 1.0 )
	WaveSpawn_TitanSpawn( wave5, "Legion", < -4133, 1026, 980 >, -90, "", 1.0, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_SmokeWall( wave5, < -3042, -2384, 688 >, 1.0 )
	WaveSpawn_SmokeWall( wave5, < -5521, -1774, 964 >, 1.0 )
	WaveSpawn_SmokeWall( wave5, < -5784, 693, 1389 >, 1.0 )
	WaveSpawn_SmokeWall( wave5, < -4025, 354, 1001 > )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < 598, -288, 688 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -1554, -777, 498 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -1049, -3086, 931 >, 0.0, "", 0.4 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -7083, -741, 1010 >, 0.0, "", 0.3 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -6876, -843, 997 >, 0.0, "", 0.2 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -6664, -4323, 675 >, 0.0, "", 1.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < -6643, 1282, 1366 >, 0, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave5, "TickReaper", < 600, -314, 687 >, 0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -6133, -1590, 811 >, 0.0, "", 0.5 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -5868, -1535, 890 >, 0.0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -783, -1483, 693 >, -143, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -2900, -1966, 688 >, -86, "", 0.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_TitanSpawn( wave5, "Ronin", < -453, -559, 560 >, -176, "", 1.5, "", 0.0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -675, -463, 560 >, -124, "", 0.6 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1128, -220, 527 >, -105, "", 0.8 )
	WaveSpawn_ReaperSpawn( wave5, "Reaper", < -1317, -2072, 601 >, -170, "", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -112, -702, 602 >, 180, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -1100, -286, 534 >, -90, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -2873, 1320, 626 >, 180, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -4742, 1492, 1204 >, -90, "", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_TitanSpawn( wave5, "Mortar", < -5343, 13, 1309 >, 180, "", 2.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.INSANE )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -2882, -2044, 696 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -2939, -2392, 701 >, 0.0, "", 0.6 )
	WaveSpawn_InfantrySpawn( wave5, "Spectre", < -2494, -2372, 688 >, 0.0, "" )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 6 )
	
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -6626, 1265, 1367 >, 0, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -6634, 1818, 1359 >, -35, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -5697, 1646, 1356 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -5998, 1874, 1364 >, -90, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1088, -284, 536 >, -135, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -607, -476, 560 >, -120, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -868, -788, 624 >, 145, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -131, -696, 599 >, 180, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -2753, 648, 479 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -3630, 701, 818 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -4133, 1026, 980 >, -90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -4251, 629, 1033 >, 0, "", 2.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1530, -2773, 608 >, 90, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -894, -1816, 745 >, 180, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "ArcTitan", < -1582, -2020, 580 >, -45, "", 0.5 )
	WaveSpawn_TitanSpawn( wave5, "Nuke", < -1298, -1508, 622 >, -90, "", 5.0 )
	WaveSpawn_WaitEnemyAliveAmount( wave5, 0 )
	
	WaveSpawn_NukeTitanMoveStance( wave5, true, 5.0, eFDSD.EXCLUSIVE | eFDSD.EASY )
	WaveSpawn_Announce( wave5, "NukeTitan", 0.0, eFDSD.EXCLUSIVE | eFDSD.EASY )
	for( spawnamount = 0; spawnamount < 83; spawnamount++ )
	{
		WaveSpawn_TitanSpawn( wave5, "Nuke", nukeTitanSpawns.getrandom(), -90, "nukeTrainShort", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.EASY )
		WaveSpawn_WaitEnemyAliveAmount( wave5, 24, eFDHT.ALL, eFDSD.EXCLUSIVE | eFDSD.EASY )
	}
	WaveSpawn_TitanSpawn( wave5, "Nuke", nukeTitanSpawns.getrandom(), -90, "nukeTrainShort", 0.5, "", 0.0, eFDSD.EXCLUSIVE | eFDSD.EASY )
	
    WaveSpawnEvents.append( wave5 )
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
	
	AddFDCustomTitanStart( < -10155, -1483, 600 >, < 0, 0, 0 > )
	AddFDCustomTitanStart( < -8916, -1655, 607 >, < 0, -75, 0 > )
	
	entity Prowler1 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -6615, 1631, 1359 >, < 0, 0, 0 > )
	entity Prowler2 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -6545, 1874, 1359 >, < 0, 0, 0 > )
	entity Prowler3 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -6153, 1392, 1365 >, < 0, 0, 0 > )
	entity Prowler4 = CreateNPC( "npc_prowler", TEAM_DAMAGE_ALL, < -5688, 1545, 1355 >, < 0, 0, 0 > )
	DispatchSpawn( Prowler1 )
	DispatchSpawn( Prowler2 )
	DispatchSpawn( Prowler3 )
	DispatchSpawn( Prowler4 )
	
	SpawnFDHeavyTurret( < -7735, -1932, 965 >, < 0, 30, 0 >, < -7766, -1763, 725 >, < 0, 30, 0 > )
	
	AddStationaryAIPosition( < -449, -621, 560 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -861, -1620, 699 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -708, -1227, 668 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -965, -630, 613 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -6484, 1918, 1360 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -4380, 1322, 1095 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -3374, 1043, 644 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -5964, -498, 1148 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	AddStationaryAIPosition( < -1479, -2072, 573 >, eStationaryAIPositionTypes.MORTAR_TITAN )
	
	AddStationaryAIPosition( < -365, -1221, 888 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -1215, -2906, 964 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -804, -2961, 930 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	AddStationaryAIPosition( < -465, -2229, 852 >, eStationaryAIPositionTypes.MORTAR_SPECTRE )
	
	AddStationaryAIPosition( < -7407, -3515, 678 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -5926, 1682, 1388 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -1563, -2278, 585 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -6247, -203, 1157 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -4614, -2220, 954 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -1617, 827, 590 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -7590, -2901, 637 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < -6752, -846, 997 >, eStationaryAIPositionTypes.SNIPER_TITAN )
	
	AddStationaryAIPosition( < -2967, 240, 881 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -1642, -3104, 950 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -5335, -3499, 966 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -6707, -4475, 675 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -6621, 1657, 1360 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -304, -1026, 895 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	AddStationaryAIPosition( < -976, 719, 535 >, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	
	routes[ "shipHangarMidcross" ] <- []
	routes[ "shipHangarMidcross" ].append( < -1103, -535, 576 > )
	routes[ "shipHangarMidcross" ].append( < -2113, -2363, 688 > )
	routes[ "shipHangarMidcross" ].append( < -3902, -2436, 819 > )
	routes[ "shipHangarMidcross" ].append( < -4821, -2103, 976 > )
	routes[ "shipHangarMidcross" ].append( < -6514, -1245, 752 > )
	routes[ "shipHangarMidcross" ].append( < -7319, -2424, 618 > )
	routes[ "shipHangarMidcross" ].append( < -8398, -2692, 624 > )
	
	routes[ "waterfallCavecross" ] <- []
	routes[ "waterfallCavecross" ].append( < -1202, -2021, 645 > )
	routes[ "waterfallCavecross" ].append( < -2212, -2327, 687 > )
	routes[ "waterfallCavecross" ].append( < -3754, -2434, 796 > )
	routes[ "waterfallCavecross" ].append( < -4690, -2342, 950 > )
	routes[ "waterfallCavecross" ].append( < -5421, -3417, 954 > )
	routes[ "waterfallCavecross" ].append( < -6624, -4209, 676 > )
	routes[ "waterfallCavecross" ].append( < -7688, -3351, 671 > )
	routes[ "waterfallCavecross" ].append( < -8312, -2375, 633 > )
	
	routes[ "cavernShort" ] <- []
	routes[ "cavernShort" ].append( < -6644, -4273, 675 > )
	routes[ "cavernShort" ].append( < -7479, -3493, 680 > )
	routes[ "cavernShort" ].append( < -8356, -2609, 624 > )
	
	routes[ "uphillStraight" ] <- []
	routes[ "uphillStraight" ].append( < -6172, 1524, 1364 > )
	routes[ "uphillStraight" ].append( < -5485, 69, 1260 > )
	routes[ "uphillStraight" ].append( < -6286, -280, 1147 > )
	routes[ "uphillStraight" ].append( < -6486, -1305, 736 > )
	routes[ "uphillStraight" ].append( < -7247, -1987, 623 > )
	routes[ "uphillStraight" ].append( < -7492, -2859, 639 > )
	routes[ "uphillStraight" ].append( < -8400, -2631, 628 > )
	
	routes[ "hillToCave" ] <- []
	routes[ "hillToCave" ].append( < -4136, 931, 983 > )
	routes[ "hillToCave" ].append( < -4064, 210, 1021 > )
	routes[ "hillToCave" ].append( < -3442, -635, 835 > )
	routes[ "hillToCave" ].append( < -3850, -2009, 759 > )
	routes[ "hillToCave" ].append( < -4702, -2377, 949 > )
	routes[ "hillToCave" ].append( < -5394, -3417, 958 > )
	routes[ "hillToCave" ].append( < -6631, -4245, 675 > )
	routes[ "hillToCave" ].append( < -7508, -3382, 680 > )
	routes[ "hillToCave" ].append( < -8248, -2569, 638 > )
	
	routes[ "infantryHillLongcliffs" ] <- []
	routes[ "infantryHillLongcliffs" ].append( < -4515, 1013, 1089 > )
	routes[ "infantryHillLongcliffs" ].append( < -4782, 127, 1253 > )
	routes[ "infantryHillLongcliffs" ].append( < -5356, 31, 1305 > )
	routes[ "infantryHillLongcliffs" ].append( < -5568, -464, 1256 > )
	routes[ "infantryHillLongcliffs" ].append( < -6083, -852, 1100 > )
	routes[ "infantryHillLongcliffs" ].append( < -5620, -1702, 930 > )
	routes[ "infantryHillLongcliffs" ].append( < -6840, -1770, 973 > )
	routes[ "infantryHillLongcliffs" ].append( < -6997, -2641, 867 > )
	routes[ "infantryHillLongcliffs" ].append( < -7627, -3039, 648 > )
	routes[ "infantryHillLongcliffs" ].append( < -8118, -2677, 617 > )
	routes[ "infantryHillLongcliffs" ].append( < -8958, -2743, 627 > )
	
	routes[ "infantryCloseCliff" ] <- []
	routes[ "infantryCloseCliff" ].append( < -6984, -822, 991 > )
	routes[ "infantryCloseCliff" ].append( < -7213, -1400, 934 > )
	routes[ "infantryCloseCliff" ].append( < -7715, -1934, 724 > )
	routes[ "infantryCloseCliff" ].append( < -8201, -1822, 724 > )
	routes[ "infantryCloseCliff" ].append( < -8772, -1910, 623 > )
	
	routes[ "waterfallInfantry" ] <- []
	routes[ "waterfallInfantry" ].append( < -597, -2778, 929 > )
	routes[ "waterfallInfantry" ].append( < -1400, -3043, 965 > )
	routes[ "waterfallInfantry" ].append( < -2292, -2882, 887 > )
	routes[ "waterfallInfantry" ].append( < -3118, -2687, 907 > )
	routes[ "waterfallInfantry" ].append( < -3535, -2877, 895 > )
	routes[ "waterfallInfantry" ].append( < -3948, -2700, 891 > )
	routes[ "waterfallInfantry" ].append( < -4861, -2695, 964 > )
	routes[ "waterfallInfantry" ].append( < -5507, -3436, 955 > )
	routes[ "waterfallInfantry" ].append( < -6519, -4172, 687 > )
	routes[ "waterfallInfantry" ].append( < -7250, -3520, 672 > )
	routes[ "waterfallInfantry" ].append( < -8104, -2846, 644 > )
	
	routes[ "midlaneShort" ] <- []
	routes[ "midlaneShort" ].append( < -5944, -1579, 868 > )
	routes[ "midlaneShort" ].append( < -6664, -1330, 696 > )
	routes[ "midlaneShort" ].append( < -7261, -2031, 623 > )
	routes[ "midlaneShort" ].append( < -7545, -2765, 625 > )
	routes[ "midlaneShort" ].append( < -8388, -2623, 628 > )
	
	routes[ "wreckageMidcross" ] <- []
	routes[ "wreckageMidcross" ].append( < -2634, -2342, 688 > )
	routes[ "wreckageMidcross" ].append( < -3784, -2460, 804 > )
	routes[ "wreckageMidcross" ].append( < -4706, -2292, 952 > )
	routes[ "wreckageMidcross" ].append( < -5726, -1635, 913 > )
	routes[ "wreckageMidcross" ].append( < -6653, -1286, 705 > )
	routes[ "wreckageMidcross" ].append( < -7270, -2023, 623 > )
	routes[ "wreckageMidcross" ].append( < -7499, -2760, 628 > )
	routes[ "wreckageMidcross" ].append( < -8630, -2707, 635 > )
	
	routes[ "nukeTrainShort" ] <- []
	routes[ "nukeTrainShort" ].append( < -6269, -316, 1140 > )
	routes[ "nukeTrainShort" ].append( < -6554, -1252, 740 > )
	routes[ "nukeTrainShort" ].append( < -7271, -2051, 623 > )
	routes[ "nukeTrainShort" ].append( < -7516, -2783, 630 > )
	routes[ "nukeTrainShort" ].append( < -8451, -2586, 639 > )
}