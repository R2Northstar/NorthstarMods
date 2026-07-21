global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddDeathCallback( "player", GlitchDissolveDeadEntity )
	AddDeathCallback( "npc_soldier", GlitchDissolveDeadEntity )
	AddDeathCallback( "npc_pilot_elite", GlitchDissolveDeadEntity )

	// Load Frontier Defense Data
	if ( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

void function GlitchDissolveDeadEntity( entity deadEnt, var damageInfo )
{
	EmitSoundAtPosition( TEAM_UNASSIGNED, deadEnt.GetOrigin(), "Object_Dissolve" )

	if ( ShouldDoDissolveDeath( deadEnt, damageInfo ) )
	{
		if ( deadEnt.IsPlayer() )
			deadEnt.DissolveNonLethal( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 0 )
		else
			deadEnt.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 0 )
	}
}

bool function ShouldDoDissolveDeath( entity guy, var damageInfo )
{
	if ( !guy.IsPlayer() )
		return true

	// can't dissolve players when they're not playing the game, otherwise when the game starts again they're invisible
	int gs = GetGameState()

	if ( gs != eGameState.Playing && gs != eGameState.SuddenDeath && gs != eGameState.Epilogue )
	{
		printt( "Skipping player dissolve death because game is not active ( player:", guy, ")" )
		return false
	}

	return true
}
