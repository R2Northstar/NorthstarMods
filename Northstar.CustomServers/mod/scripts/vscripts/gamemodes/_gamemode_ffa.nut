global function FFA_Init

// modified: for saving player's score in ffa, don't let mid-game joined players get illegal scores
struct FFAScoreStruct
{
	int team
	int score
	int pilotKills
	int titanKills
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

		if ( victim.IsTitan() && victim.IsPlayer() ) // player controlled titan
		{
			file.ffaPlayerScoreTable[ uid ].pilotKills += 1
			file.ffaPlayerScoreTable[ uid ].titanKills += 1
		}
		else if ( victim.IsPlayer() ) // pilot
			file.ffaPlayerScoreTable[ uid ].pilotKills += 1
		else if ( victim.IsTitan() ) // npc titan
			file.ffaPlayerScoreTable[ uid ].titanKills += 1
	}
}

// modified for northstar
void function OnClientConnected( entity player )
{
	string uid = player.GetUID()
	FFAScoreStruct emptyStruct
	if ( !( uid in file.ffaPlayerScoreTable ) ) // first connecting?
		file.ffaPlayerScoreTable[ uid ] <- emptyStruct // init a empty struct
	else // once connected?
	{
		// re-assign score to current team and player!
		AddTeamScore( player.GetTeam(), file.ffaPlayerScoreTable[ uid ].score )
		player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, file.ffaPlayerScoreTable[ uid ].score )
		player.AddToPlayerGameStat( PGS_PILOT_KILLS, file.ffaPlayerScoreTable[ uid ].pilotKills )
		player.AddToPlayerGameStat( PGS_TITAN_KILLS, file.ffaPlayerScoreTable[ uid ].titanKills )
	}

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
		}
	)

	player.WaitSignal( "OnDestroy" ) // this can handle disconnecting
}