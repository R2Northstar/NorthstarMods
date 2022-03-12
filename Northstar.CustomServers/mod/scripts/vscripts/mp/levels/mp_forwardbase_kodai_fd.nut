global function initFrontierDefenseData


void function initFrontierDefenseData()
{
    shopPosition = < -3862.13, 1267.69, 1060.06>



    array<WaveEvent> wave0
    array<WaveEvent> wave1
    array<WaveEvent> wave2
    array<WaveEvent> wave3
    array<WaveEvent> wave4



    //wave0.append(createSmokeEvent(< -12, 1720, 1456>,30))
    // wave0.append(createSmokeEvent(< -64,  964, 1456>,30))
    // wave0.append(createWaitForTimeEvent(10))
    // wave0.append(createSuperSpectreEvent(< -64,  964, 1456>,<0,0,0>,""))

    
    wave0.append(createMortarTitanEvent(< 1632, 4720, 944>,<0,0,0>))
    wave0.append(createCloakDroneEvent(< 1632, 4720, 1200>,<0,0,0>))
    wave0.append(createWaitUntilAliveEvent(0))
    wave1.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>,"hillRouteClose"))
    wave1.append(createWaitUntilAliveEvent(0))
    // wave0.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>,"hillRouteClose"))
    
    //wave0.append(createArcTitanEvent(< -12, 1720, 1456>,<0,0,0>,"hillRouteClose"))
    //wave0.append(createDroppodStalkerEvent(< -12, 1720, 1456>,""))

    waveEvents.append(wave0)
    
    waveEvents.append(wave0)
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