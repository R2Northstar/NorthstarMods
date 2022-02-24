global function initFrontierDefenseData


void function initFrontierDefenseData()
{
    shopPosition = < -5165.42, -679.285, 384.031> //only aproximate position



    array<WaveEvent> wave0
    array<WaveEvent> wave1
    array<WaveEvent> wave2
    array<WaveEvent> wave3
    array<WaveEvent> wave4



    //wave0.append(createSmokeEvent(< -12, 1720, 1556>,30))
    // wave0.append(createSmokeEvent(< -64,  964, 1556>,30))
    // wave0.append(createWaitForTimeEvent(10))
    // wave0.append(createSuperSpectreEvent(< -64,  964, 1556>,<0,0,0>,""))

    // for(int i = 0; i<2;i++){
    //     wave0.append(createNukeTitanEvent(< -12, 1720, 1556>,<0,0,0>,"hillRouteClose"))
    //     wave0.append(createWaitForTimeEvent(3))
    // }
    // wave0.append(createWaitUntilAliveEvent(0))
    // for(int i = 0; i<3;i++){
    //     wave1.append(createNukeTitanEvent(< -12, 1720, 1556>,<0,0,0>,"hillRouteClose"))
    //     wave1.append(createWaitForTimeEvent(3))
    // }
    // wave1.append(createWaitUntilAliveEvent(0))
    // wave0.append(createArcTitanEvent(< -12, 1720, 1556>,<0,0,0>,"hillRouteClose"))
    
    //wave0.append(createArcTitanEvent(< -12, 1720, 1556>,<0,0,0>,"hillRouteClose"))
    // wave0.append(createDroppodStalkerEvent(< -12, 1720, 1556>,""))

    waveEvents.append(wave0)
    waveEvents.append(wave1)
    waveEvents.append(wave2)
    waveEvents.append(wave3)
    waveEvents.append(wave4)
}