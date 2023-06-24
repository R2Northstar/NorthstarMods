global function Progression_Init
global function ProgressionEnabledForPlayer
#if SERVER
#else
global function Progression_SetPreference
global function Progression_GetPreference
#endif

#if SERVER
struct {
    table<entity, bool> progressionEnabled
} file
#endif


void function Progression_Init()
{
    #if SERVER
    AddCallback_OnClientDisconnected(OnClientDisconnected)
    AddClientCommandCallback( "ns_progression", ClientCommand_SetProgression )
    #elseif CLIENT
    AddCallback_OnClientScriptInit(OnClientScriptInit)
    #endif
}

bool function ProgressionEnabledForPlayer(entity player)
{
    #if SERVER
    if (player in file.progressionEnabled)
        return file.progressionEnabled[player]
    
    printt("Player " + player.GetPlayerName() + " has not sent a progression preference")
    return false
    #else
    return GetConVarBool("ns_progression_enabled")
    #endif
}

#if SERVER

void function OnClientDisconnected(entity player)
{
    // cleanup table when player leaves
    if (player in file.progressionEnabled)
        delete file.progressionEnabled[player]
}

bool function ClientCommand_SetProgression( entity player, array<string> args )
{
    if (args.len() != 1)
        return false
    if (args[0] != "0" && args[0] != "1")
        return false
    
    file.progressionEnabled[player] <- args[0] == "1"
    return true
}

#else // CLIENT || UI

#if CLIENT

void function OnClientScriptInit(entity player)
{
    // unsure if this is needed, just being safe
    if (player != GetLocalClientPlayer())
        return

    Progression_SetPreference(GetConVarBool("ns_progression_enabled"))
}

#endif

void function Progression_SetPreference(bool enabled)
{
    SetConVarBool( "ns_progression_enabled", enabled )

    #if CLIENT
    GetLocalClientPlayer().ClientCommand("ns_progression " + enabled.tointeger())
    #elseif UI
    ClientCommand( "ns_progression " + enabled.tointeger())
    #endif
}

bool function Progression_GetPreference()
{
    return GetConVarBool("ns_progression_enabled")
}

#endif
