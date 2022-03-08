global function GamemodeAITdm_Init

const SQUADS_PER_TEAM = 3

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
  thread SpawnIntroBatch()
}

void function OnPlayerConnected( entity player )
{
  Remote_CallFunction_NonReplay( player, "ServerCallback_AITDM_OnPlayerConnected" )
}

//------------------------------------------------------

void function SpawnIntroBatch()
{
  array<entity> dropPodNodes = GetEntArrayByClass_Expensive("info_spawnpoint_droppod_start")
  array<entity> dropShipNodes = GetValidIntroDropShipSpawn( dropPodNodes )  
  
  array<entity> militiaPodNodes
  array<entity> imcPodNodes
  
  array<entity> militiaShipNodes
  array<entity> imcShipNodes
  
  // Sort per team
  foreach ( node in dropPodNodes )
  {
    if ( node.GetTeam() == TEAM_MILITIA )
      militiaPodNodes.append( node )
    else
      imcPodNodes.append( node )
  }
  
  foreach ( node in dropShipNodes )
  {
    if ( node.GetTeam() == TEAM_MILITIA )
      militiaShipNodes.append( node )
    else
      imcShipNodes.append( node )
  }
  
  // Spawn logic
  int militia_index = 0
  int imc_index = 0
  bool first = true
  entity node
  
  int militiaPods = RandomInt( militiaPodNodes.len() + 1 )
  int imcPods = RandomInt( imcPodNodes.len() + 1 )
  
  int militiaShips = militiaShipNodes.len()
  int imcShips = imcShipNodes.len()
  
  for ( int i = 0; i < SQUADS_PER_TEAM; i++ )
  {
    // MILITIA
    if ( militiaPods != 0 || militiaShips == 0 )
    {
      int index = i
      
      if ( index > militiaPodNodes.len() - 1 )
        index = RandomInt( militiaPodNodes.len() )
      
      node = militiaPodNodes[ index ]
      thread SpawnDropPod( node.GetOrigin(), node.GetAngles(), TEAM_MILITIA, "npc_soldier", SquadHandler )
      
      militiaPods--
    }
    else
    {
      if ( militia_index == 0 ) 
        militia_index = i // save where we started
      
      node = militiaShipNodes[ i - militia_index ]
      thread SpawnDropShip( node.GetOrigin(), node.GetAngles(), TEAM_MILITIA, 4, SquadHandler )
      
      militiaShips--
    }
    
    // IMC
    if ( imcPods != 0 || imcShips == 0 )
    {
      int index = i
      
      if ( index > imcPodNodes.len() - 1 )
        index = RandomInt( imcPodNodes.len() )
      
      node = imcPodNodes[ index ]
      thread SpawnDropPod( node.GetOrigin(), node.GetAngles(), TEAM_IMC, "npc_soldier", SquadHandler )
      
      imcPods--
    }
    else
    {
      if ( imc_index == 0 ) 
        imc_index = i // save where we started
      
      node = imcShipNodes[ i - imc_index ]
      thread SpawnDropShip( node.GetOrigin(), node.GetAngles(), TEAM_IMC, 4, SquadHandler )
      
      imcShips--
    }
    
    // Vanilla has a delay after first spawn
    if ( first )
      wait 2
    
    first = false
  }
  
  wait 15
  //thread Spawner( TEAM_MILITIA )
  //thread Spawner( TEAM_IMC )
}

//------------------------------------------------------

void function SquadHandler( string squad )
{
  array< entity > guys
  array< entity > points = GetEntArrayByClass_Expensive( "assault_assaultpoint" )
  
  vector point
  
  // We need to try catch this since some dropships fail to spawn
  try
  {
    guys = GetNPCArrayBySquad( squad )
    
    point = points[ RandomInt( points.len() ) ].GetOrigin()
    
    array<entity> players = GetPlayerArrayOfEnemies( guys[0].GetTeam() )
    
    // Setup AI
    foreach ( guy in guys )
    {
      guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
      guy.AssaultPoint( point )
      guy.AssaultSetGoalRadius( 100 )
      
      // show on enemy radar
      foreach ( player in players )
    	{
    		guy.Minimap_AlwaysShow( 0, player )
    	}
    }
    
    // Every 15 secs change AssaultPoint
    for( ;; )
    {
      guys = GetNPCArrayBySquad( squad )
      point = points[ RandomInt( points.len() ) ].GetOrigin()
      
      foreach ( guy in guys )
      {
        guy.AssaultPoint( point )
      }
      
      wait 15
    }
  }
  catch (ex)
  {
    printt("Squad doesn't exist or has been killed off")
  }
}

void function ReaperHandler( entity reaper )
{
  array<entity> players = GetPlayerArrayOfEnemies( reaper.GetTeam() )
  foreach ( player in players )
  {
    reaper.Minimap_AlwaysShow( 0, player )
  }
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