global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( InitComplex )
}

void function InitComplex()
{
	entity rings = GetEntByScriptName( "rings_pristine" )
	rings.Anim_Play( "animated_slow" )
	
	/* Apply filter of those trigger hurt only to titans due the bay area which they may get stuck, but disable for pilots, this is mainly because the
	lower floor in the large inner hallway is extremely close to a trigger_hurt and players embarking Titans or mantling in the props in there just
	instantly dies with fall damage */
	
	array<entity> triggerlist = GetEntArrayByClass_Expensive( "trigger_hurt" )
	foreach ( entity trigger in triggerlist )
	{
		if( trigger.GetTargetName() == "trigger_hurt_1" )
			continue
		
		if( trigger.kv.damageSourceName == "fall" )
			trigger.kv.triggerFilterPlayer = "titan"
	}
}