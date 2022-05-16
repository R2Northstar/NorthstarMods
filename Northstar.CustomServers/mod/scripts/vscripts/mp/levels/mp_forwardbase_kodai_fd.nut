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
    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose"))

    wave0.append(createSmokeEvent(< -12, 1720, 1456>,30))
    wave0.append(createSmokeEvent(< -64,  964, 1456>,30))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(1))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose"))
    wave0.append(createDroppodStalkerEvent( < 2193, 434, 955>, "hillRouteClose"))
    wave0.append(createDroppodStalkerEvent( < 909, 3094, 968>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(1))

    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(1))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose"))
    wave0.append(createDroppodStalkerEvent( < 2193, 434, 955>, "hillRouteClose"))
    wave0.append(createDroppodStalkerEvent( < 909, 3094, 968>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(1))

    wave0.append(createDroppodGruntEvent( < 865, 694, 1380>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 885, 1722, 1377>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1226, 1391, 1355>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1258, 922, 1331>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 1117, 330, 1372>, "hillRouteClose"))

    wave0.append(createWaitForTimeEvent(7))
    wave0.append(createWaitUntilAliveEvent(1))

    wave0.append(createDroppodGruntEvent( < 1309, 2122, 1324>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 985, -110, 1369>, "hillRouteClose"))
    wave0.append(createDroppodGruntEvent( < 264, 2840, 968>, "hillRouteClose"))
    wave0.append(CreateToneSniperTitanEvent( < 1373, 1219, 1314>, <0,0,0>))
    // wave0.append(CreateTickEvent( < -64, 964, 1458>, <0,0,0>, 4, "hillRouteClose" ))
    wave0.append(createWaitForTimeEvent(10))

    // wave0.append(CreateTickEvent( < -64, 964, 1458>, <0,0,0>, 56, "hillRouteClose" ))
    //wave0.append(createMortarTitanEvent(< 1632, 4720, 944>,<0,0,0>))
    wave0.append(createWaitUntilAliveEvent(0))
    wave1.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>, "hillRouteClose"))
    wave1.append(createNukeTitanEvent( < -64,  964, 1456>,<0,0,0>, "hillRouteClose"))
    wave1.append(createCloakDroneEvent(< 1632, 4720, 1200>,<0,0,0>))
    wave1.append(createWaitUntilAliveEvent(0))
    // wave0.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>,"hillRouteClose"))

    //wave0.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>,"hillRouteClose"))
    //wave0.append(createDroppodStalkerEvent(< -12, 1720, 1456>,""))

    waveEvents.append(wave0)

    //waveEvents.append(wave0)
    waveEvents.append(wave1)
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
