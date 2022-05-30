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
    //wave0.append(createDroppodStalkerEvent(< -12, 1720, 1456>,""))

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
