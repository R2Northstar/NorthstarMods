global function GamemodeAt_Init
global function RateSpawnpoints_AT

void function GamemodeAt_Init()
{
	AddCallback_EntitiesDidLoad( SpawnBanks )
	
	AddCallback_OnNPCKilled( HandleScoreEvent )
	AddCallback_OnPlayerKilled( HandleScoreEvent )
	
	AddCallback_OnClientConnected( OnPlayerConnected )
	
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
}

//------------------------------------------------------

void function OnPlayerConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AT_OnPlayerConnected" )
}

//------------------------------------------------------

void function SpawnBanks()
{
	foreach ( entity spawnpoint in GetEntArrayByClass_Expensive( "info_target" ) )
	{
		if ( !IsBankNode( spawnpoint ) )
			continue
		
		// uhhh
		
		entity prop = CreatePropDynamic( spawnpoint.GetModelName(), spawnpoint.GetOrigin(), spawnpoint.GetAngles(), 6 )
		thread PlayAnim( prop, "mh_inactive_idle" )
		
		prop.SetScriptName("AT_Bank")
	}
}



bool function IsBankNode( entity node )
{
	if( node.HasKey("editorclass") && node.kv.editorclass == "info_attrition_bank" )
		return true
	
	return false
}

void function HandleScoreEvent( entity victim, entity attacker, var damageInfo )
{
  if ( !( attacker.IsPlayer() || attacker.IsTitan() && GetGameState() == eGameState.Playing ) )
    return
  
  int score
  string eventName
  
  if ( victim.IsNPC() && victim.GetClassName() != "npc_marvin" )
  {
    eventName = ScoreEventForNPCKilled( victim, damageInfo )
    if ( eventName != "KillNPCTitan" && eventName != "" )
      score = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )
  }
  
	// Half goes to player, half to team
	score = score / 2
	
  if ( victim.IsPlayer() )
  {
		int stolenScore = victim.GetPlayerGameStat( 7 ) / 2
		victim.SetPlayerGameStat( 7, stolenScore )
		victim.SetPlayerNetInt("AT_bonusPoints", attacker.GetPlayerGameStat( 7 ) )
		score = stolenScore
	}
  
	if ( victim == attacker || attacker == null)
		return
  
  AddTeamScore( attacker.GetTeam(), score )
  attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, score )
	attacker.AddToPlayerGameStat( 7, score )
  attacker.SetPlayerNetInt("AT_bonusPoints", attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) )
}










// Bob leftovers
void function RateSpawnpoints_AT( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	RateSpawnpoints_Generic( checkclass, spawnpoints, team, player ) // temp 
}