global function initFrontierDefenseData


void function initFrontierDefenseData()
{
    shopPosition = < -3862.13, 1267.69, 1060.06>



    array<WaveEvent> wave0
    array<WaveEvent> wave1
    array<WaveEvent> wave2
    array<WaveEvent> wave3
    array<WaveEvent> wave4



    //wave0.append(createSmokeEvent(< -12, 1720, 1556>,30))
    //wave0.append(createSmokeEvent(< -64,  964, 1556>,30))
    //wave0.append(createWaitForTimeEvent(5))
    wave0.append(createSuperSpectreEvent(< -64,  964, 1556>,<0,0,0>,""))
    wave0.append(createArcTitanEvent(< -12, 1720, 1556>,<0,0,0>,""))
    wave0.append(createDroppodGruntEvent(< -12, 1720, 1556>,""))

    waveEvents.append(wave0)
    waveEvents.append(wave1)
    waveEvents.append(wave2)
    waveEvents.append(wave3)
    waveEvents.append(wave4)
}

/*
void function initFrontierDefenseData()
{
    shopPosition = 

    SmokeEvent emptySmokeEvent
    SpawnEvent emptySpawnEvent
    WaitEvent emptyWaitEvent
    SoundEvent emptySoundEvent

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