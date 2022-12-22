global struct GameStateStruct {

    string map
    string map_displayname

    string playlist
    string playlist_displayname

    int current_players
    int max_players
    int own_score
    int other_highest_score
    int max_score
    float time_end
}

global struct UIPresenceStruct {
	bool isLoading
	bool isLobby
	string loadingLevel
	string loadedLevel
}