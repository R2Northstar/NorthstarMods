global function FFA_Init

// modified: for saving player's score in ffa, don't let mid-game joined players get illegal scores
struct FFAScoreStruct
{
	int team
	int score
}

struct
{
	table<string, FFAScoreStruct> ffaPlayerScoreTable // use player's uid!
} file

void function FFA_Init()
{
	ClassicMP_ForceDisableEpilogue( true )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_OnPlayerKilled( OnPlayerKilled )

	// modified for northstar
	AddCallback_OnClientConnected( OnClientConnected )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() && GetGameState() == eGameState.Playing )
	{
		AddTeamScore( attacker.GetTeam(), 1 )
		// why isn't this PGS_SCORE? odd game
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )

		// modified for northstar
		string uid = attacker.GetUID()
		file.ffaPlayerScoreTable[ uid ].score += 1
	}
}

// modified for northstar
void function OnClientConnected( entity player )
{
	string uid = player.GetUID()
	FFAScoreStruct emptyStruct
	if ( !( uid in file.ffaPlayerScoreTable ) )
		file.ffaPlayerScoreTable[ uid ] <- emptyStruct // init a empty struct
	file.ffaPlayerScoreTable[ uid ].score = 0 // start from 0

	thread FFAPlayerScoreThink( player ) // good to have this! instead of DisconnectCallback this could handle a null player
}

void function FFAPlayerScoreThink( entity player )
{
	string uid = player.GetUID()
	file.ffaPlayerScoreTable[ uid ].team = player.GetTeam()

	OnThreadEnd(
		function(): ( uid )
		{
			// take score from this team
			int team = file.ffaPlayerScoreTable[ uid ].team
			int score = file.ffaPlayerScoreTable[ uid ].score

			AddTeamScore( team, -score )
			delete file.ffaPlayerScoreTable[ uid ] // delete existing struct
		}
	)

	player.WaitSignal( "OnDestroy" ) // this can handle disconnecting
}