global struct GameStateStruct {

    string map
    string mapDisplayname

    string playlist
    string playlistDisplayname

    int currentPlayers
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

global struct RequiredModInfo
{
    string name
    string version
}

global struct ServerInfo
{
    int index
    string id
    string name
    string description
    string map
    string playlist
    int playerCount
    int maxPlayerCount
    bool requiresPassword
    string region
    array< RequiredModInfo > requiredMods
}

global struct MasterServerAuthResult
{
    bool success
    string errorCode
    string errorMessage
}

global enum eModInstallStatus
{
    DOWNLOADING,
    CHECKSUMING,
    EXTRACTING,
    DONE,
    FAILED,
    FAILED_READING_ARCHIVE,
    FAILED_WRITING_TO_DISK,
    MOD_FETCHING_FAILED,
    MOD_CORRUPTED,
    NO_DISK_SPACE_AVAILABLE,
    NOT_FOUND
}

global struct ModInstallState
{
    int status
    int progress
    int total
    float ratio
}
