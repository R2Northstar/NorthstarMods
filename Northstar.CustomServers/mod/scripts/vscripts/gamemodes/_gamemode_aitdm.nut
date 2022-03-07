global function GamemodeAITdm_Init


void function GamemodeAITdm_Init()
{
  AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
  AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )
  
  AddCallback_OnNPCKilled( HandleScoreEvent )
  AddCallback_OnPlayerKilled( HandleScoreEvent )
  
  AddCallback_OnClientConnected( OnPlayerConnected )
  
  ScoreEvent_SetupEarnMeterValuesForMixedModes()
}

//------------------------------------------------------

void function OnPrematchStart()
{
  thread StratonHornetDogfightsIntense()
}

void function OnPlaying()
{
  
}

void function OnPlayerConnected( entity player )
{
  Remote_CallFunction_NonReplay( player, "ServerCallback_AITDM_OnPlayerConnected" )
}

//------------------------------------------------------

void function HandleScoreEvent( entity victim, entity attacker, var damageInfo )
{
  if ( !( victim != attacker && attacker.IsPlayer() || attacker.IsTitan() && GetGameState() == eGameState.Playing ) )
    return
  
  int score
  string eventName
  
  if ( victim.IsNPC() && victim.GetClassName() != "npc_marvin" )
  {
    eventName = ScoreEventForNPCKilled( victim, damageInfo )
    if ( eventName != "KillNPCTitan" )
      score = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )
  } // I dont like the brackets, but squirrel shits it self without them
  
  if ( victim.IsPlayer() )
    score = 5
  
  // Player ejecting triggers this without the extra check
  if ( victim.IsTitan() && victim.GetBossPlayer() != attacker )
    score += 10
  
  AddTeamScore( attacker.GetTeam(), score )
  attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, score )
  attacker.SetPlayerNetInt("AT_bonusPoints", attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) )
}