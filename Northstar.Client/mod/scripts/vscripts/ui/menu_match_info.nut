global function AddMatchInfoMenu

struct Server {
    string id = "#INFO_UNAVAILABLE"
    string name = "#INFO_UNAVAILABLE"
    string description = "#INFO_UNAVAILABLE"
    string maxPlayerCount = "-"
    string map = "#INFO_UNAVAILABLE"
    string playlist = "#INFO_UNAVAILABLE"
}

struct {
    var menu
    var serverNameLabel
    var serverDescriptionLabel
    var playerPingLabel
    var maxPlayersLabel
    Server& server
} file

void function AddMatchInfoMenu()
{
    AddMenu( "MatchInfo", $"resource/ui/menus/match_info.menu", InitMatchInfoMenu )
}

void function InitMatchInfoMenu()
{
    file.menu = GetMenu( "MatchInfo" )
    file.serverNameLabel = Hud_GetChild( file.menu, "ServerName" )
    file.serverDescriptionLabel = Hud_GetChild( file.menu, "ServerDescription" )
    file.playerPingLabel = Hud_GetChild( file.menu, "PlayerPing" )
    file.maxPlayersLabel = Hud_GetChild( file.menu, "MaxPlayers" )

    RegisterSignal( "matchInfoClosed" )

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnMatchInfoMenuOpened )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnMatchInfoMenuClosed )

    AddUICallback_OnLevelInit( OnLevelLoaded )
}

void function OnMatchInfoMenuOpened()
{
    UI_SetPresentationType( ePresentationType.NO_MODELS )

    int i
    for ( ; i < NSGetServerCount(); i++ )
    {
        if( NSGetServerID( i ) == GetConVarString( "ns_connected_server" ) )
        {
            break
        }
    }

    Server tempServer

    if( GetConVarString( "ns_connected_server" ).len() )
    {
        tempServer.id = NSGetServerID( i )
        tempServer.name = format("[%s] %s", NSGetServerRegion( i ), NSGetServerName( i ))
        tempServer.description = NSGetServerDescription( i )
        tempServer.maxPlayerCount = string( NSGetServerMaxPlayerCount( i ) )
        tempServer.map = GetActiveLevel() // ms info may be outdated
        tempServer.playlist = NSGetServerPlaylist( i )
    } else {
        tempServer.name = GetConVarString( "ns_server_name" )
        tempServer.description = GetConVarString( "ns_server_desc" )
    }

    file.server = tempServer

    Hud_SetText( file.serverNameLabel, Localize( "#INFO_SERVER_NAME", file.server.name ) )
    Hud_SetText( file.serverDescriptionLabel, Localize( "#INFO_SERVER_DESC", file.server.description ) )
    Hud_SetText( file.maxPlayersLabel, Localize( "#INFO_SERVER_PLAYERS", file.server.maxPlayerCount ) )
    thread ContinuousPingUpdate()
}

void function OnMatchInfoMenuClosed()
{
    Signal( file.menu, "matchInfoClosed" )
}

void function ContinuousPingUpdate()
{
    EndSignal( file.menu, "matchInfoClosed" )
    while( 1 )
    {
        if( uiGlobal.loadingLevel.len() )
        {
            Signal( file.menu, "matchInfoClosed" )
            break
        }
        Hud_SetText( file.playerPingLabel, Localize( "#INFO_SERVER_PING", string( MyPing() ) ) )
        WaitFrame()
    }
}

void function OnLevelLoaded()
{
    if( uiGlobal.previousLevel == "" || uiGlobal.loadedLevel == "" || ( uiGlobal.loadedLevel == "mp_lobby" && !IsPrivateMatch() ) )
        SetConVarString( "ns_connected_server", "" )
}