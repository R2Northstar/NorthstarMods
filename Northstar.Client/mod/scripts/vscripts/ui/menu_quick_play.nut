global function MenuQuickPlay_Init

//for reference
struct serverStruct {
	int serverIndex
	bool serverProtected
	string serverName
	int serverPlayers
	int serverPlayersMax
	string serverMap
	string serverGamemode
}

struct
{
	var menu
	array< serverStruct > servers
	array< serverStruct > filteredServers

	bool stopQuickPlayConnection = false

	// filter things

	// how full the server is
	float minPlayersFrac = 0
	float maxPlayersFrac  = 1

	// the server's max player count
	int minMaxPlayers = 0
	int maxMaxPlayers = 24

	// map filter
	bool mapsFilterIsWhitelist = false
	array<string> mapsFilter = []

	// mode filter
	bool gamemodesFilterIsWhitelist = false
	array<string> gamemodesFilter = []

	// this filter has to be a whitelist (at least until autodownloading)
	array<string> requiredModsFilter = []

	// :Copium:
	bool regionFilterIsWhitelist = false
	array<string> regionFilter = []

	// name filter
	bool nameFilterIsWhitelist = true // it makes more sense for name filter to default to being a whitelist
	string nameFilter = ""

} file



// callback from the mod.json
void function MenuQuickPlay_Init()
{
    AddMenu( "QuickPlayMenu", $"resource/ui/menus/quick_play.menu", InitQuickPlayMenu, "#MENU_QUICK_PLAY" )
    file.menu = GetMenu( "QuickPlayMenu" )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnQuickPlayMenuOpened )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_BACK", "#SELECT", ConnectToServer )
}

void function InitQuickPlayMenu()
{

}

void function OnQuickPlayMenuOpened()
{
	ImportFiltersFromConVars()
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_MAIN )
	file.stopQuickPlayConnection = false
    thread RefreshServerList( 0 )
}

void function ImportFiltersFromConVars()
{
	// modes
	file.gamemodesFilter = split( GetConVarString( "quickplay_filter_modes" ), " " )
	file.gamemodesFilterIsWhitelist = GetConVarBool( "quickplay_filter_modes_whitelist" )

	// maps
	file.mapsFilter = split( GetConVarString( "quickplay_filter_maps" ), " " )
	file.mapsFilterIsWhitelist = GetConVarBool( "quickplay_filter_maps_whitelist" )

	// name
	file.nameFilter = GetConVarString( "quickplay_filter_name" )
	file.nameFilterIsWhitelist = GetConVarBool( "quickplay_filter_name_whitelist" )

	// mods
	file.requiredModsFilter = split( GetConVarString( "quickplay_filter_mods" ), "\n" ) // using \n here because mods can have spaces in their name

	// maxplayers
	file.maxMaxPlayers = GetConVarInt( "quickplay_filter_max_maxplayers" )
	file.minMaxPlayers = GetConVarInt( "quickplay_filter_min_maxplayers" )

	// players
	file.maxPlayersFrac = GetConVarFloat( "quickplay_filter_max_players_frac" )
	file.minPlayersFrac = GetConVarFloat( "quickplay_filter_min_players_frac" )
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
        server.serverMap = NSGetServerMap(i) // GetMapDisplayName
        server.serverGamemode = NSGetServerPlaylist(i) // GetGameModeDisplayName

        file.servers.append( server )
    }

    FilterServerList( button )
}

void function FilterServerList( var button )
{
    file.filteredServers = []
    foreach ( serverStruct server in file.servers )
    {
        // PASSWORD FILTER - cant quickplay to join a password protected server, tough shit
        if ( server.serverProtected )
			continue

		// PLAYERCOUNT FILTERS
		// server full
		if ( server.serverPlayers >= server.serverPlayersMax )
			continue
		// too many players
		if ( server.serverPlayers.tofloat() / server.serverPlayersMax.tofloat() > file.maxPlayersFrac )
			continue
		// too few players
		if ( server.serverPlayers.tofloat() / server.serverPlayersMax.tofloat() < file.minPlayersFrac )
			continue
		// too many max players
		if ( server.serverPlayersMax > file.maxMaxPlayers )
			continue
		// too few max players
		if ( server.serverPlayersMax < file.minMaxPlayers )
			continue
		
		// GAMEMODES FILTER
		if ( file.gamemodesFilterIsWhitelist != file.gamemodesFilter.contains( server.serverGamemode ) )
			continue

		// MAPS FILTER
		if ( file.mapsFilterIsWhitelist != file.mapsFilter.contains( server.serverMap ) )
			continue

		// NAME FILTER
		if ( file.nameFilter != "" && file.nameFilterIsWhitelist != ( server.serverName.find( file.nameFilter ) != null ) )
			continue

		// MODS FILTER
		bool shouldContinue = false
		for ( int i = 0; i < NSGetServerRequiredModsCount( server.serverIndex ); i++ )
		{
			string requiredMod = NSGetServerRequiredModName( server.serverIndex, i )
			if ( !file.requiredModsFilter.contains( requiredMod ) )
			{
				//shouldContinue = true
				break
			}
		}
		if ( shouldContinue )
			continue

        // server passed all the checks, add it to filteredServers
        file.filteredServers.append( server )
    }

    printt( "Refreshed filters: " + file.filteredServers.len() + " servers match the current filters")
}

// THESE FUNCTIONS HANDLE ACTUALLY CONNECTING TO THE SERVER
void function StopQuickPlay()
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

	DialogData connectingDialog
	connectingDialog.menu = GetMenu( "ConnectingDialog" )
	connectingDialog.header = "#CONNECTING"
	connectingDialog.showSpinner = true
	AddDialogButton( connectingDialog, "CANCEL", StopQuickPlay )
	OpenDialog ( connectingDialog )

	// refresh the list so we dont join a full server or anything dumb
	thread RefreshServerList( button )

	if ( file.filteredServers.len() == 0 )
	{
		// oh no there are no servers that match the filters
		CloseAllDialogs()
		
		Hud_Hide( uiGlobal.ConfirmMenuMessage )
		Hud_Hide( uiGlobal.ConfirmMenuErrorCode )

		DialogData noServersDialog
		noServersDialog.menu = GetMenu( "Dialog" )
		noServersDialog.header = "#NS_SERVERBROWSER_NOSERVERS"
		noServersDialog.message = "#DIALOG_NO_SERVERS"
		noServersDialog.image = $"ui/menu/common/dialog_error"
		AddDialogButton( noServersDialog, "OK", StopQuickPlay )
		OpenDialog ( noServersDialog )
		return
	}

	// choose a random server
	serverStruct chosenServer = file.filteredServers[ RandomInt( file.filteredServers.len() ) ]

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

	// wait a random amount of time to make people think we are like searching for a match
	wait RandomFloatRange( 0.8, 1.4 )
	if( file.stopQuickPlayConnection )
	{
		file.stopQuickPlayConnection = false
		return
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