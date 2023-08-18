global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddDeathCallback( "player", GlitchDissolveDeadEntity )	
	AddDeathCallback( "npc_soldier", GlitchDissolveDeadEntity )
	AddDeathCallback( "npc_spectre", GlitchDissolveDeadEntity )
	AddDeathCallback( "npc_pilot_elite", GlitchDissolveDeadEntity )
	
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == "fd" )
		initFrontierDefenseData()
}

void function GlitchDissolveDeadEntity( entity deadEnt, var damageInfo )
{
	if ( deadEnt.IsPlayer() || GamePlayingOrSuddenDeath() || GetGameState() == eGameState.Epilogue )
	{
		deadEnt.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 0 )
		EmitSoundAtPosition( TEAM_UNASSIGNED, deadEnt.GetOrigin(), "Object_Dissolve" )
		
		if ( deadEnt.IsPlayer() )
			thread EnsureGlitchDeathEffectIsClearedForPlayer( deadEnt )
	}
}

void function EnsureGlitchDeathEffectIsClearedForPlayer( entity player )
{
	player.EndSignal( "OnDestroy" )
	
	float startTime = Time()
	while ( player.kv.VisibilityFlags != "0" )
	{
		if ( Time() > startTime + 4.0 ) // if we wait too long, just ignore
			return
	
		WaitFrame() 
	}
	
	player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
}