global function CodeCallback_MapInit
global function SwitchComplexRingsSpeed

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( InitComplex )
	
	//Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

void function InitComplex()
{
	entity rings = GetEntByScriptName( "rings_pristine" )
	rings.Anim_Play( "animated_slow" )
}

void function SwitchComplexRingsSpeed( int speed = 0 )
{
	entity rings = GetEntByScriptName( "rings_pristine" )
	
	switch ( speed )
	{
		case 0:
		rings.Anim_Play( "animated_slow" )
		break
		
		case 1:
		rings.Anim_Play( "animated" )
		break
		
		case 2:
		rings.Anim_Play( "animated_damaged_stage_1" )
		break
		
		case 3:
		rings.Anim_Play( "animated_damaged_stage_2" )
		break
		
		case 4:
		rings.Anim_Play( "animated_damaged_stage_3" )
		break
	}
}