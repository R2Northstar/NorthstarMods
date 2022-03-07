global function GamemodeAITdm_Init

void function GamemodeAITdm_Init()
{
  AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
}

//------------------------------------------------------

void function OnPrematchStart()
{
    thread StratonHornetDogfightsIntense()
}