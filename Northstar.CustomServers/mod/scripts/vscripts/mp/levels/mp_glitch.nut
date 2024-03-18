global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddDeathCallback( "player", GlitchDissolveDeadEntity )	
	AddDeathCallback( "npc_soldier", GlitchDissolveDeadEntity )
	AddDeathCallback( "npc_pilot_elite", GlitchDissolveDeadEntity )
	
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

void function GlitchDissolveDeadEntity( entity deadEnt, var damageInfo )
{
	EmitSoundAtPosition( TEAM_UNASSIGNED, deadEnt.GetOrigin(), "Object_Dissolve" )
	
	if ( deadEnt.IsPlayer() )
		deadEnt.DissolveNonLethal( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 500 )
	else
		deadEnt.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 500 )
}