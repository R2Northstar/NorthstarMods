global function CodeCallback_MatchIsOver

void function CodeCallback_MatchIsOver()
{
	if ( !IsPrivateMatch() && IsMatchmakingServer() )
		SetUIVar( level, "putPlayerInMatchmakingAfterDelay", true )
	else
		SetUIVar( level, "putPlayerInMatchmakingAfterDelay", false )

	array<entity> players = GetPlayerArray()

	foreach ( entity player in players )
		AddXPCredits( player )

	if ( ShouldReturnToLobby() )
	{
		SetCurrentPlaylist( "private_match" ) // needed for private lobby to load

		if ( IsSingleplayer() )
			GameRules_ChangeMap( "mp_lobby", "tdm" ) // need to change back to mp playlist or loadouts will break in lobby
		else
			GameRules_ChangeMap( "mp_lobby", GAMETYPE )
	}
	else
	{
		// iterate over all gamemodes/maps in current playlist, choose map/mode combination that's directly after our current one
		// if we reach the end, go back to the first map/mode
		bool changeOnNextIteration = false

		for ( int i = 0; i < GetCurrentPlaylistGamemodesCount(); i++ )
		{
			if ( GetCurrentPlaylistGamemodeByIndex( i ) == GAMETYPE )
			{
				for ( int j = 0; j < GetCurrentPlaylistGamemodeByIndexMapsCount( i ); j++ )
				{
					if ( changeOnNextIteration )
					{
						GameRules_ChangeMap( GetCurrentPlaylistGamemodeByIndexMapByIndex( i, j ), GetCurrentPlaylistGamemodeByIndex( i ) )
						return
					}

					if ( GetCurrentPlaylistGamemodeByIndexMapByIndex( i, j ) == GetMapName() )
						changeOnNextIteration = true // change to next map/mode we iterate over
				}
			}
		}

		// go back to first map/mode
		GameRules_ChangeMap( GetCurrentPlaylistGamemodeByIndexMapByIndex( 0, 0 ), GetCurrentPlaylistGamemodeByIndex( 0 ) )
	}
	// #if DEV
	// 	if ( !IsMatchmakingServer() )
	// 		GameRules_ChangeMap( "mp_lobby", GAMETYPE )
	// #endif // #if DEV
}
