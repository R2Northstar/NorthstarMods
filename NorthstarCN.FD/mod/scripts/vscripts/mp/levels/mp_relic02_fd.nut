global function initFrontierDefenseData
void function initFrontierDefenseData()
{
    shopPosition = < 1767.61, -4959.83 , 2244>
	shopAngles = < 0, 0, 0 >
	FD_spawnPosition = < 2919.59, -4426.63, 2242 >
	FD_spawnAngles = < 0, 0, 0 >

	int index = 1


    array<WaveEvent> wave1
	wave1.append(CreateWaitForTimeEvent( 5.0, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 7253 , -4638 , 2237 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 1.0, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 7087 , -4282 , 2240 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 1.0, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 6179 , -4601 , 2236 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 5.0, index++ ) )
	wave1.append(CreateWaitUntilAliveEvent( 4, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 8272 , -4063 , 2133 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 1.0, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 8181 , -4273 , 2114 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 1.0, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 8181 , -4273 , 2114 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 5.0, index++ ) )
	wave1.append(CreateWaitUntilAliveEvent( 4, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 5810 , -6334 , 2242 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 1.0, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 5499 , -1884 , 2236 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 1.0, index++ ) )
	wave1.append(CreateDroppodGruntEvent(< 6497 , -3318 , 2240 >,"",index++))
	wave1.append(CreateWaitForTimeEvent( 5.0, index++ ) )
	wave1.append(CreateWaitUntilAliveEvent( 4, index++ ) )
	wave1.append(CreateMonarchTitanEvent(< 8500 , -3465 , 2228 >,< 0 , 180 , 0 >,"",0))
    waveEvents.append(wave1)
	index = 1
	array<WaveEvent> wave2
	
    waveEvents.append(wave2)
	index = 1
	array<WaveEvent> wave3
	
    waveEvents.append(wave3)
	index = 1
	array<WaveEvent> wave4
	
    waveEvents.append(wave4)
	index = 1
	array<WaveEvent> wave5
	
    waveEvents.append(wave5)
	index = 1
	array<WaveEvent> wave6
	
    waveEvents.append(wave6)
}