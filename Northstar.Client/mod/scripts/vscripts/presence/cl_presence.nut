untyped
globalize_all_functions

void function NorthstarCodeCallback_GenerateGameState() {

    GameStateStruct gs

    int highest_score = 0
    int second_highest = 0

    foreach ( player in GetPlayerArray() )
    {
        if ( GameRules_GetTeamScore( player.GetTeam() ) >= highest_score )
        {
            highest_score = GameRules_GetTeamScore( player.GetTeam() )
        }
        else if ( GameRules_GetTeamScore( player.GetTeam() ) > second_highest )
        {
            second_highest = GameRules_GetTeamScore( player.GetTeam() )
        }
    }

    gs.map = GetMapName()
    gs.map_displayname = Localize(GetMapDisplayName(GetMapName()))

    gs.playlist = GetCurrentPlaylistName()
    gs.playlist_displayname = Localize("#PL_"+GetCurrentPlaylistName())

    gs.current_players = GetPlayerArray().len()
    gs.max_players = GetCurrentPlaylistVarInt( "max_players", -1 )

    if ( IsValid( GetLocalClientPlayer() ) )
		gs.own_score = GameRules_GetTeamScore( GetLocalClientPlayer().GetTeam() )

    gs.other_highest_score = gs.own_score == highest_score ? second_highest : highest_score

    gs.max_score = IsRoundBased() ? GetCurrentPlaylistVarInt( "roundscorelimit", 0 ) : GetCurrentPlaylistVarInt( "scorelimit", 0 )

	if ( GetServerVar( "roundBased" ) )
		gs.time_end = expect float(level.nv.roundEndTime - Time())
	else
		gs.time_end = expect float(level.nv.gameEndTime - Time())

    NSPushGameStateData(gs)
}