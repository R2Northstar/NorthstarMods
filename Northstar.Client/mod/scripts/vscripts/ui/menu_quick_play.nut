global function MenuQuickPlay_Init

//global function QuickPlaySearch

// keep track of all the servers we have been in (so we dont join the same server over and over)
// this is a table so we can keep track of *when* we last joined the server
// can add a convar later to determine how long to wait before being allowed to rejoin it
// using strings here to match by server name, since the server index may change
global table<string, float> joinedServers

// this struct is stolen from menu_ns_serverbrowser.nut
// maybe make it global in there at some point?
struct serverStruct {
	int serverIndex
	bool serverProtected
	string serverName
	int serverPlayers
	int serverPlayersMax
	string serverMap
	string serverGamemode
	int serverLatency // :pain:
}

struct 
{
    var menu
    int number

    struct 
    {
        string name = ""
        array<string> maps = []
        array<string> modes = []
    } filters

    array<serverStruct> servers
    array<serverStruct> filteredServers

	bool stopQuickPlayConnection = false

    array<string> realMaps
    // temp
    int mapFilterIndex = 0

    array<string> realModes
    // temp
    int modeFilterIndex = 0
} file



// callback from the mod.json
void function MenuQuickPlay_Init()
{
    AddMenu( "QuickPlayMenu", $"resource/ui/menus/quick_play.menu", InitQuickPlayMenu, "#MENU_QUICK_PLAY" )
    file.menu = GetMenu("QuickPlayMenu")
    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnQuickPlayMenuOpened )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_BACK", "#SELECT", ConnectToServer )
}

void function InitQuickPlayMenu()
{
    // loading the filters from the ConVars here?


	file.realMaps = [ "Any", "mp_lobby" ]
	file.realMaps.extend( GetPrivateMatchMaps() )


	/*file.realModes = [ "Any", "private_match" ]
	file.realModes.extend( GetPrivateMatchModes() )
    */
}

void function RefreshServerList( var button )
{
    if ( NSIsRequestingServerList() )
		return
    NSClearRecievedServerList()
    file.servers = []
	NSRequestServerList()

    while ( NSIsRequestingServerList() )
        WaitFrame()

    for ( int i = 0; i < NSGetServerCount(); i++ )
    {
        // create serverStruct
        serverStruct server
        // populate with information about the server
        server.serverIndex = i
        server.serverProtected = NSServerRequiresPassword(i)
        server.serverName = NSGetServerName(i)
        server.serverPlayers = NSGetServerPlayerCount(i)
        server.serverPlayersMax = NSGetServerMaxPlayerCount(i)
        server.serverMap = NSGetServerMap(i)
        server.serverGamemode = GetGameModeDisplayName( NSGetServerPlaylist (i) )
        server.serverLatency = -1 // sadge

        file.servers.append( server )
    }

    FilterServerList( button )
}

void function FilterServerList( var button )
{
    file.filteredServers = []
    foreach ( serverStruct server in file.servers )
    {
        // PASSWORD FILTER
        if ( server.serverProtected )
            continue
        // PLAYERCOUNT FILTERS
        // check if > 80% full
        if ( server.serverPlayers >= server.serverPlayersMax )
            continue
        // NAME FILTERS
        if ( server.serverName != "" && server.serverName.find( file.filters.name ) == -1 )
            continue
        // MAP FILTER
        if ( file.filters.maps.len() > 0 && !file.filters.maps.contains( server.serverMap ) )
            continue
        // MODE FILTER
        if ( file.filters.modes.len() > 0 && !file.filters.modes.contains( server.serverGamemode ) )
            continue

        // server passed all the checks, add it to the filteredServers
        file.filteredServers.append( server )
    }

    printt( "Refreshed filters: " + file.filteredServers.len() + " servers match the current filters")
}

void function OnQuickPlayMenuOpened()
{
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_MAIN )
    thread RefreshServerList( 0 )
}



// THESE FUNCTIONS HANDLE ACTUALLY CONNECTING TO THE SERVER
void function stopQuickPlay()
{
	// make sure we close all the dialogs
	CloseAllDialogs()
	Hud_Hide( uiGlobal.ConfirmMenuMessage )
	Hud_Hide( uiGlobal.ConfirmMenuErrorCode )

	file.stopQuickPlayConnection = true
}

void function ConnectToServer( var button )
{
	//dialog stuff
	CloseAllDialogs()
	Hud_Hide( uiGlobal.ConfirmMenuMessage )
	Hud_Hide( uiGlobal.ConfirmMenuErrorCode )

	DialogData dialogData
	dialogData.menu = GetMenu( "ConnectingDialog" )
	dialogData.header = "#CONNECTING"
	dialogData.showSpinner = true
	AddDialogButton( dialogData, "CANCEL", stopQuickPlay)
	AddDialogFooter( dialogData, "A_BUTTON_SELECT" )
	OpenDialog ( dialogData )

	// refresh the list so we dont join a full server or anything dumb
	thread RefreshServerList( button )

	// get best server
	serverStruct chosenServer
	foreach ( serverStruct server in file.filteredServers )
	{
		try
		{
			if ( Time() - joinedServers[ server.serverName ] < 60 * GetConVarInt( "quickplay_rejoin_time" ) )
				continue
			chosenServer = server
			break
		}
		catch ( ex )
		{
			continue
		}
	}
	thread thread_ConnectToServer( chosenServer )
}

void function thread_ConnectToServer( serverStruct server )
{
	// wait for request to complete
	while ( NSIsRequestingServerList() )
	{
		if( file.stopQuickPlayConnection )
		{
			file.stopQuickPlayConnection = false
			return
		}
		WaitFrame()
	}

	// auth and connect
	if ( NSIsAuthenticatingWithServer() )
		return

	int serverIndex = server.serverIndex
	print( "trying to authenticate with server " + NSGetServerName( serverIndex ))
	NSTryAuthWithServer( serverIndex, "" )

	

	while ( NSIsAuthenticatingWithServer() )
	{
		if( file.stopQuickPlayConnection )
		{
			file.stopQuickPlayConnection = false
			return
		}
		WaitFrame()
	}

	if ( NSWasAuthSuccessful() )
	{
		bool modsChanged

		array<string> requiredMods
		for ( int i = 0; i < NSGetServerRequiredModsCount( serverIndex ); i++ )
			requiredMods.append( NSGetServerRequiredModName( serverIndex, i ) )

		// unload mods we don't need, load necessary ones and reload mods before connecting
		foreach ( string mod in NSGetModNames() )
		{
			if ( NSIsModRequiredOnClient( mod ) )
			{
				modsChanged = modsChanged || NSIsModEnabled( mod ) != requiredMods.contains( mod )
				NSSetModEnabled( mod, requiredMods.contains( mod ) )
			}
		}

		// only actually reload if we need to since the uiscript reset on reload lags hard
		if ( modsChanged )
			ReloadMods()
		// connect 
		// add a second or so of delay to make people think the game is actually thinking about their filters :)
		wait 0.5
		EmitUISound( "menu_campaignsummary_titanunlocked" )
		wait RandomFloat( 1.0 )
		NSConnectToAuthedServer()
	}
	else
	{
		printt("auth failed")
	}
}