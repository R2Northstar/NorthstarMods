global struct GameStateStruct {

    string map
    string mapDisplayname

    string playlist
    string playlistDisplayname

    int current_players
    int maxPlayers
    int ownScore
    int otherHighestScore
    int maxScore
    float timeEnd
}

global struct UIPresenceStruct {
	bool isLoading
	bool isLobby
	string loadingLevel
	string loadedLevel
}