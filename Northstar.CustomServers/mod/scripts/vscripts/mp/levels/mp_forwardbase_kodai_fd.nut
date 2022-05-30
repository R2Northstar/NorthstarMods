global function initFrontierDefenseData


void function initFrontierDefenseData()
{
    shopPosition = < -3862.13, 1267.69, 1060.06 >

    array<WaveEvent> wave0
    array<WaveEvent> wave1
    array<WaveEvent> wave2
    array<WaveEvent> wave3
    array<WaveEvent> wave4

    //wave0.append(createSuperSpectreEvent(< -64,  964, 1456>, <0,0,0 >, "hillRouteClose"))
    
    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose",1))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose",2))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose",3))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose",4))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose",5))

    wave0.append(createSmokeEvent(< -12, 1720, 1456>,30,6))
    wave0.append(createSmokeEvent(< -64,  964, 1456>,30,7))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(16))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodStalkerEvent( < 2193, 434, 955>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodStalkerEvent( < 909, 3094, 968>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(16))

    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
   wave0.append(createWaitUntilAliveEvent(16))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodStalkerEvent( < 2193, 434, 955>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodStalkerEvent( < 909, 3094, 968>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(16))

    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(16))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose"))
    wave0.append(createWaitUntilAliveEvent(16))
    wave0.append(CreateToneSniperTitanEvent( < 1373, 1219, 1314>, <0,179,0>))

    wave0.append(createWaitUntilAliveEvent(0))

    // WAVE 2: 12 TITANS, 32 TICKS, 22 REAPERS, 8 MORTAR SPECTRES, 56 GRUNTS

    wave1.append(createSmokeEvent(< -12, 1720, 1456>,30))
    wave1.append(createSmokeEvent(< -64,  964, 1456>,30))
    wave1.append(CreateTickEvent( < 865, 694, 1372>, <0,179,0>, 4, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateTickEvent( < 885, 1722, 1370>, <0,179,0>, 4, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateTickEvent( < 1226, 1391, 1355>, <0,179,0>, 4, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateTickEvent( < 1258, 922, 1331>, <0,179,0>, 4, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1)) // 16 npcs

    // Davis: "we got more enemy titans coming your way"

    wave1.append(CreateToneSniperTitanEvent( < 1373, 1219, 1314>, <0,179,0>))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateToneSniperTitanEvent( < 1209, 580, 1332>, <0,179,0>))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateToneTitanEvent( <2476, -3544, 810>, <0,179,0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateToneTitanEvent( <2665, 4456, 961>, <0,179,0>, "cliffRouteLeft")) // 20 npcs

    wave1.append(createWaitForTimeEvent(15))
    wave1.append(createWaitUntilAliveEvent(16)) // 4 ticks die

    wave1.append(createDroppodSpectreMortarEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave1.append(createDroppodSpectreMortarEvent( < 885, 1722, 1377>, "hillRouteClose")) // 24 npcs
    wave1.append(createWaitUntilAliveEvent(20))
    wave1.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose"))
    wave1.append(createWaitUntilAliveEvent(20))
    wave1.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose"))
    wave1.append(createWaitUntilAliveEvent(20))
    wave1.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose")) // 24 npcs

    wave1.append(createWaitForTimeEvent(15))
    wave1.append(createWaitUntilAliveEvent(20))

    wave1.append(createSmokeEvent(< -3398.31, 1251.5, 1099.44>,30))

    wave1.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(3))
    wave1.append(createWaitUntilAliveEvent(20))
    wave1.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(3))
    wave1.append(createWaitUntilAliveEvent(20))
    wave1.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(3))
    wave1.append(createWaitUntilAliveEvent(12)) // weird part, not supposed to use this i believe

    // when all titans die, spawn two tone titans again
    // when all soldiers except mortar spectres die, spawn reapers with the tone titans

    wave1.append(CreateToneTitanEvent( <2476, -3544, 810>, <0,179,0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateToneTitanEvent( <2665, 4456, 961>, <0,179,0>, "cliffRouteLeft"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2680, -2997, 800>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<3123, 4202, 954>, <0, 179, 0>, "cliffRouteLeft"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<1818, -3586, 1814>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<1325, 4820, 938>, <0, 179, 0>, "cliffRouteLeft"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2651.56, -3216, 785.469>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2614.63, 4771.56, 948.031>, <0, 179, 0>, "cliffRouteLeft"))  // 20 npcs
    wave1.append(createWaitForTimeEvent(7))
    wave1.append(createWaitUntilAliveEvent(12)) // when 8 mortar spectre dies

    wave1.append(createSmokeEvent(<2684, 1252, 1092>,30))
    wave1.append(createSmokeEvent(<2452, 1812, 1092>,30))
    wave1.append(createSmokeEvent(<2336, 636, 1092>,30))

    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateTickEvent( <3249, 161, 947>, <0, 179, 0>, 4, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateTickEvent( <3157, 2267, 947>, <0, 179, 0>, 4, "hillRouteClose")) // 20 npcs

    // these ticks are supposed to spawn after one reaper dies
    wave1.append(createWaitForTimeEvent(3))
    wave1.append(createWaitUntilAliveEvent(19))
    wave1.append(CreateTickEvent( <3249, 161, 947>, <0, 179, 0>, 4, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(3))
    wave1.append(createWaitUntilAliveEvent(22))
    wave1.append(CreateTickEvent( <3157, 2267, 947>, <0, 179, 0>, 4, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(3))
    wave1.append(createWaitUntilAliveEvent(25))

    wave1.append(CreateToneTitanEvent( <4466, 1470, 947>, <0,179,0>, "platformRouteCenter"))

    wave1.append(createWaitUntilAliveEvent(25)) // when a reaper/Tone dies
    wave1.append(createDroppodGruntEvent( <3249, 161, 947>, "hillRouteClose"))
    wave1.append(createWaitUntilAliveEvent(28)) // when a reaper/tone dies
    wave1.append(createDroppodGruntEvent( <3157, 2267, 947>, "hillRouteClose"))
    wave1.append(createWaitUntilAliveEvent(31)) // when a reaper/tone dies
    wave1.append(createDroppodGruntEvent( <3249, 161, 947>, "underRouteShort"))
    wave1.append(createWaitUntilAliveEvent(34)) // when a reaper/tone dies
    wave1.append(createDroppodGruntEvent( <3157, 2267, 947>, "underRouteShort"))

    wave1.append(createWaitUntilAliveEvent(20))
    wave1.append(createSuperSpectreEvent(<4466.06, 1469.63, 944.281>, <0, 179, 0>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<4452.91, 964.906, 944.281>, <0, 179, 0>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<3866.44, 1445.81, 944.281>, <0, 179, 0>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<4277.28, 1771.63, 944.281>, <0, 179, 0>, "hillRouteClose"))

    wave1.append(createWaitUntilAliveEvent(4))
    wave1.append(createDroppodGruntEvent( <2457.31, -2563.63, 781.75>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2476, -3544, 807.188>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createDroppodGruntEvent( <1935.84, 3727.84, 924.188>, "cliffRouteLeft"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2664.78, 4456.16, 957.688>, <0, 179, 0>, "cliffRouteLeft"))

    wave1.append(createWaitForTimeEvent(3))
    wave1.append(createWaitUntilAliveEvent(12))

    wave1.append(createDroppodGruntEvent( <1045.34, -2843.31, 797.344>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2476, -3544, 807.188>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createDroppodGruntEvent( <2111.84, 3295.84, 931.563>, "cliffRouteLeft"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2664.78, 4456.16, 957.688>, <0, 179, 0>, "cliffRouteLeft"))

    wave1.append(createWaitUntilAliveEvent(2))

    wave1.append(createSuperSpectreEvent(<2476, -3544, 807.188>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2664.78, 4456.16, 957.688>, <0, 179, 0>, "cliffRouteLeft"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<2821.44, -2936.5, 824.938>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<3123, 4201.72, 951.281>, <0, 179, 0>, "cliffRouteLeft"))
    wave1.append(CreateIonTitanEvent( <1817.56, -3585.72, 810.875>, <0,179,0>, "cliffRouteRight"))
    wave1.append(CreateIonTitanEvent( <1324, 4820, 934.531>, <0,179,0>, "cliffRouteLeft"))

    wave1.append(createWaitUntilAliveEvent(0))

    wave1.append(CreateLegionTitanEvent( <4466.06, 1469.63, 944.281>, <0,179,0>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<4466.06, 1469.63, 944.281>, <0, 179, 0>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(createSuperSpectreEvent(<3866.44, 1445.81, 944.281>, <0, 179, 0>, "hillRouteClose"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateScorchTitanEvent( <2821.44, -2936.5, 824.938>, <0,179,0>, "cliffRouteRight"))
    wave1.append(createSuperSpectreEvent(<2476, -3544, 807.188>, <0, 179, 0>, "cliffRouteRight"))
    wave1.append(createWaitForTimeEvent(0.1))
    wave1.append(CreateScorchTitanEvent( <3123, 4201.72, 951.281>, <0,179,0>, "cliffRouteLeft"))
    wave1.append(createSuperSpectreEvent(<2664.78, 4456.16, 957.688>, <0, 179, 0>, "cliffRouteLeft"))

    wave1.append(createWaitUntilAliveEvent(0))

    // WAVE 3: 20 TITANS, 8 REAPERS, 4 CLOAK DRONES, 4 DRONES, 48 GRUNTS

    wave2.append(CreateRoninTitanEvent( <1764, -1608, 806.906>, <0,179,0>, "underRouteShort"))
    wave2.append(createSmokeEvent(< -2264, -2096, 928>,30))
    wave2.append(createSmokeEvent(< -3132, -1904, 928>,30))
    wave2.append(createSmokeEvent(< -1548, -2240, 928>,30))
    wave2.append(createSuperSpectreEvent(<2476, -3544, 807.188>, <0, 179, 0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createSuperSpectreEvent(<2821.44, -2936.5, 824.938>, <0, 179, 0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createSuperSpectreEvent(<1504, -3600, 810.656>, <0, 179, 0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createSuperSpectreEvent(<1560, -2024, 800.031>, <0, 179, 0>, "cliffRouteRight"))
    wave2.append(createCloakDroneEvent(<1925, -1598.99, 1108>,<0,179,0>)) // needs voiceline saying there's cloak drones
    wave2.append(createDroppodGruntEvent( <2457.31, -2563.63, 781.75>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createDroppodGruntEvent( <1045.34, -2843.31, 797.344>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createDroppodGruntEvent( <346.313, -2838.63, 796.5>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createDroppodGruntEvent( <1418.31, -2254.63, 802.563>, "cliffRouteRight")) // 22 npcs

    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitForTimeEvent(15))

    wave2.append(CreateScorchTitanEvent( <2476, -3544, 807.188>, <0,179,0>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateIonTitanEvent( <2821.44, -2936.5, 824.938>, <0,179,0>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(2))
    wave2.append(CreateIonTitanEvent( <1504, -3600, 810.656>, <0,179,0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateIonTitanEvent( <1504, -3600, 810.656>, <0,179,0>, "cliffRouteRight")) // 26 npcs

    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(22))

    // no drones event here
    // drone coords, <2457.31, -2591.38, 5762.82>
    wave2.append(createDroppodGruntEvent( <2457.31, -2563.63, 781.75>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(22))
    wave2.append(createDroppodGruntEvent( <1045.34, -2843.31, 797.344>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createDroppodGruntEvent( <346.313, -2838.63, 796.5>, "cliffRouteRight")) // 30 npcs

    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(15))
    // voicelines = incoming titans
    wave2.append(createDroppodGruntEvent( <1045.34, -2843.31, 797.344>, "cliffRouteRight"))
    wave2.append(CreateToneSniperTitanEvent( <4466.06, 1469.63, 944.281>, <0,179,0>))
    wave2.append(CreateMonarchTitanEvent( <4452.91, 964.906, 944.281>, <0,179,0>, "hillRouteClose"))

    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(16))

    wave2.append(CreateRoninTitanEvent( <1764, -1608, 806.906>, <0,179,0>, "underRouteShort"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateRoninTitanEvent( <2360, -1596, 799.719>, <0,179,0>, "underRouteShort"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createSuperSpectreEvent(<1817.56, -3585.72, 810.875>, <0, 179, 0>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateToneTitanEvent( <2476, -3544, 807.188>, <0,179,0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createSuperSpectreEvent(<1180.06, -3631.56, 814.188>, <0, 179, 0>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateToneTitanEvent( <2821.44, -2936.5, 824.938>, <0,179,0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createSuperSpectreEvent(<1560, -2024, 800.031>, <0, 179, 0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateLegionTitanEvent( <1764, -1608, 806.906>, <0,179,0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createSuperSpectreEvent(<2412, -1108, 800.375>, <0, 179, 0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateLegionTitanEvent( <1504, -3600, 810.656>, <0,179,0>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateScorchTitanEvent( <2476, -3544, 807.188>, <0,179,0>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateScorchTitanEvent( <2821.44, -2936.5, 824.938>, <0,179,0>, "cliffRouteRightNear")) // 28 npcs

    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(24))

    wave2.append(createDroppodGruntEvent( <2457.31, -2563.63, 781.75>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(24))
    wave2.append(createDroppodGruntEvent( <1045.34, -2843.31, 797.344>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createDroppodGruntEvent( <346.313, -2838.63, 796.5>, "cliffRouteRight")) // 32 npcs

    // at this point even with the dump i can't keep track of what goes where so allow me to take some liberty here

    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(28))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createDroppodGruntEvent( <1418.31, -2254.63, 802.563>, "cliffRouteRight"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateIonTitanEvent( <1764, -1608, 806.906>, <0,179,0>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateIonTitanEvent( <2360, -1596, 799.719>, <0,179,0>, "cliffRouteRightNear"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createCloakDroneEvent(<1894, -1627, 1108>,<0,179,0>))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(createCloakDroneEvent(<1894.99, -1626.99, 1235.99>,<0,179,0>))

    wave2.append(createWaitForTimeEvent(7))
    wave2.append(createWaitUntilAliveEvent(30))
    wave2.append(CreateLegionTitanEvent( <4466.06, 1469.63, 944.281>, <0,179,0>, "hillRouteClose"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateLegionTitanEvent( <4452.91, 964.906, 944.281>, <0,179,0>, "hillRouteClose"))
    wave2.append(createWaitForTimeEvent(0.1))
    wave2.append(CreateMonarchTitanEvent( <3866.44, 1445.81, 944.281>, <0,179,0>, "hillRouteClose"))

    wave2.append(createWaitUntilAliveEvent(0))

    // WAVE 4: 10 Nuke Titans, 2 Arc Titans, 2 Mortar Titans, 15 Titans, 12 Reapers, 1 Cloak Drone, 52 Stalkers
    // 1155.28 Time()


    /* //wave0.append(createDroppodStalkerEvent(< -12, 1720, 1456>,"hillRouteClose"))
    wave0.append(createSuperSpectreEvent(< -12, 1720, 1456>, <0, 179, 0>, "hillRouteClose"))
    //wave0.append(CreateScorchTitanEvent( < 1309, 2122, 1324>, <0,179,0>, "platformRouteCenter"))
    //wave0.append(CreateScorchTitanEvent( < 985, -110, 1369>, <0,179,0>, "cliffRouteRight"))
    //wave0.append(CreateScorchTitanEvent( < 264, 2840, 968>, <0,179,0>, "cliffRouteLeft"))
    wave0.append(createSuperSpectreEvent(< -64,  964, 1456>, <0,0,0 >, "hillRouteClose"))
    wave0.append(createSuperSpectreEvent( <1580.66, -1793.66, 799.853>, <0,90,0>, "underRouteShort"))
    wave0.append(createWaitForTimeEvent(5))
    //wave0.append(createArcTitanEvent( <1580.66, -1793.66, 799.853>, <0,90,0>, "cliffRouteRightNear"))
    wave0.append(createWaitForTimeEvent(10))

    wave0.append(createWaitUntilAliveEvent(0))


    wave1.append(createArcTitanEvent(< -12, 1720, 1456>,<0,179,0>, "hillRouteClose"))
    wave1.append(createNukeTitanEvent( < -64,  964, 1456>,<0,179,0>, "hillRouteClose"))
    wave1.append(createCloakDroneEvent(< 1632, 4720, 1200>,<0,179,0>))
    wave1.append(createWaitUntilAliveEvent(0))
    wave0.append(createWaitForTimeEvent(7,8))
    wave0.append(createWaitUntilAliveEvent(1,9))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose",10))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose",11))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose",12))
    wave0.append(createDroppodStalkerEvent( < 2193, 434, 955>, "hillRouteClose",13))
    wave0.append(createDroppodStalkerEvent( < 909, 3094, 968>, "hillRouteClose",14))

    wave0.append(createWaitForTimeEvent(7,15))
    wave0.append(createWaitUntilAliveEvent(1,16))

    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose",17))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose",18))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose",19))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose",20))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose",21))

    wave0.append(createWaitForTimeEvent(7,22))
    wave0.append(createWaitUntilAliveEvent(1,23))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose",24))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose",25))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose",26))
    wave0.append(createDroppodStalkerEvent( < 2193, 434, 955>, "hillRouteClose",27))
    wave0.append(createDroppodStalkerEvent( < 909, 3094, 968>, "hillRouteClose",28))

    wave0.append(createWaitForTimeEvent(7,29))
    wave0.append(createWaitUntilAliveEvent(1,30))

    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose",31))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose",32))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose",33))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose",34))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose",35))

    wave0.append(createWaitForTimeEvent(7,36))
    wave0.append(createWaitUntilAliveEvent(1,37))
    
    //wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose"))
    //wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose"))
    //wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose"))
    wave0.append(CreateToneSniperTitanEvent( < 1373, 1219, 1314>, <0,0,0>,0))
    // wave0.append(CreateTickEvent( < -64, 964, 1458>, <0,0,0>, 4, "hillRouteClose" ))


    // wave0.append(CreateTickEvent( < -64, 964, 1458>, <0,0,0>, 56, "hillRouteClose" ))
    //wave0.append(createMortarTitanEvent(< 1632, 4720, 944>,<0,0,0>))

    //wave1.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>, "hillRouteClose"))
    //wave1.append(createNukeTitanEvent( < -64,  964, 1456>,<0,0,0>, "hillRouteClose"))
    //wave1.append(createCloakDroneEvent(< 1632, 4720, 1200>,<0,0,0>))
    //wave1.append(createWaitUntilAliveEvent(0))
    // wave0.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>,"hillRouteClose"))

    //wave0.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>,"hillRouteClose"))

    wave2.append(createNukeTitanEvent( < -12, 1720, 1456>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 865, 694, 1380>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1226, 1391, 1355>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1309, 2122, 1324>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 985, -110, 1369>,<0,179,0>, "hillRouteClose"))
    wave2.append(createWaitUntilAliveEvent(2))
    wave2.append(createNukeTitanEvent( < -12, 1720, 1456>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 865, 694, 1380>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1226, 1391, 1355>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1309, 2122, 1324>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 985, -110, 1369>,<0,179,0>, "hillRouteClose"))
    wave2.append(createWaitUntilAliveEvent(2))
    wave2.append(createNukeTitanEvent( < -12, 1720, 1456>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 865, 694, 1380>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1226, 1391, 1355>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1309, 2122, 1324>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 985, -110, 1369>,<0,179,0>, "hillRouteClose"))
    wave2.append(createWaitUntilAliveEvent(2))
    wave2.append(createNukeTitanEvent( < -12, 1720, 1456>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 865, 694, 1380>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1226, 1391, 1355>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 1309, 2122, 1324>,<0,179,0>, "hillRouteClose"))
    wave2.append(createNukeTitanEvent( < 985, -110, 1369>,<0,179,0>, "hillRouteClose"))
    wave2.append(createWaitUntilAliveEvent(0)) */
    waveEvents.append(wave0)

    //waveEvents.append(wave0)
    //waveEvents.append(wave1)
    //waveEvents.append(wave2)
    //waveEvents.append(wave3)
    //waveEvents.append(wave4)
}

/*
void function initFrontierDefenseData()
{
    shopPosition =


    array<WaveEvent> wave0
    array<WaveEvent> wave1
    array<WaveEvent> wave2
    array<WaveEvent> wave3
    array<WaveEvent> wave4






    waveEvents.append(wave0)
    waveEvents.append(wave1)
    waveEvents.append(wave2)
    waveEvents.append(wave3)
    waveEvents.append(wave4)
}*/

// underRoute
// underRouteShort
// hillRouteClose
// cliffRouteLeft
// cliffRouteRight
// cliffRouteRightNear
// platformRouteCenter
//wave0.append(CreateTickEvent( < -64, 964, 1458>, <0,0,0>, 56, "hillRouteClose" ))
//wave0.append(createMortarTitanEvent(< 1632, 4720, 944>,<0,0,0>))
//wave0.append(CreateTickEvent( < -64, 964, 1458>, <0,0,0>, 4, "hillRouteClose" ))
