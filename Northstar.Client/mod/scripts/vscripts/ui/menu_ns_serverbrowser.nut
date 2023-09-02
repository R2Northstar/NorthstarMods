untyped
// Only way to get Hud_GetPos(sliderButton) working was to use untyped

global function AddNorthstarServerBrowserMenu
global function ThreadedAuthAndConnectToServer

global function AddConnectToServerCallback
global function RemoveConnectToServerCallback
global function TriggerConnectToServerCallbacks

// Stop peeking

const int BUTTONS_PER_PAGE = 15 // Number of servers we show
const float DOUBLE_CLICK_TIME_MS = 0.4 // Max time between clicks for double click registering 
const int MAX_NUMBER_OF_LINES = 9 // The total number of ligne in both required mod label and description label befor cut off
const int MAX_LETTER_PER_ROWS = 38

// Stores mouse delta used for scroll bar
struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBufferServerDetail


// Filters
struct {
	bool hideFull = false
	bool hideEmpty = false
	bool hideProtected = false
	bool useSearch = false
	string searchTerm
	string filterMap
	string filterGamemode
	array<string> filterRegions = [ "SWITCH_ANY" ]
	string filterRegion
	string filterMods
	string filterModsTypes
} filterArguments


enum sortingBy
{
	NONE,
	DEFAULT,
	NAME,
	PLAYERS,
	MAP,
	GAMEMODE,
	REGION
}

// Column sort direction, only one of these can be aplied at once
struct {
	// true = alphabeticaly false = reverse
	bool serverName = true
	bool serverPlayers = true
	bool serverMap = true
	bool serverGamemode = true
	bool serverRegion = true
	// 0 = none; 1 = default; 2 = name; 3 = players; 4 = map; 5 = gamemode; 6 = region
	int sortingBy = 1
} filterDirection

struct serverStruct {
	int serverIndex
	bool serverProtected
	string serverName
	int serverPlayers
	int serverPlayersMax
	string serverMap
	string serverGamemode
	string serverRegion
}

struct {
	// UI state vars
	var menu
	int focusedServerIndex = 0
	int scrollOffset = 0
	int serverDetailsScrollOffset = 0
	bool isRequiredModsListShow = false
	bool serverListRequestFailed = false
	float serverSelectedTime = 0
	float serverSelectedTimeLast = 0
	int serverButtonFocusedID = 0
	bool shouldFocus = true
	bool cancelConnection = false

	// Server Details string (description & mods)
	array<string> serverDetailsModsStrings
	array<string> serverDetailsDescriptionStrings

	array<string> serverDetailsActiveStrings
	
	// filtered array of servers
	array<serverStruct> serversArrayFiltered

	array<ServerInfo> filteredServers
	ServerInfo& focusedServer
	ServerInfo& lastSelectedServer
	
	// UI references
	array<var> serverButtons
	array<var> serversName
	array<var> playerCountLabels
	array<var> serversProtected
	array<var> serversMap
	array<var> serversGamemode
	array<var> serversRegion

	array< void functionref( ServerInfo ) > connectCallbacks
} file



bool function FloatsEqual( float arg1, float arg2, float epsilon )
{
	if ( fabs( arg1 - arg2 ) < epsilon ) return true
	
	return false
}


////////////////////////////
// Init
////////////////////////////
void function AddNorthstarServerBrowserMenu()
{
	AddMenu( "ServerBrowserMenu", $"resource/ui/menus/server_browser.menu", InitServerBrowserMenu, "#MENU_SERVER_BROWSER" )
}

void function InitServerBrowserMenu()
{
	file.menu = GetMenu( "ServerBrowserMenu" )

	AddMouseMovementCaptureHandler( Hud_GetChild(file.menu, "MouseMovementCapture"), UpdateMouseDeltaBuffer )
	AddMouseMovementCaptureHandler( Hud_GetChild(file.menu, "MouseMovementCaptureLabel"), UpdateMouseDeltaBuffer_ServerDetail )


	// Get menu stuff
	file.serverButtons = GetElementsByClassname( file.menu, "ServerButton" )
	file.serversName = GetElementsByClassname( file.menu, "ServerName" )
	file.playerCountLabels = GetElementsByClassname( file.menu, "PlayerCount" )
	file.serversProtected = GetElementsByClassname( file.menu, "ServerLock" )
	file.serversMap = GetElementsByClassname( file.menu, "ServerMap" )
	file.serversGamemode = GetElementsByClassname( file.menu, "ServerGamemode" )
	file.serversRegion = GetElementsByClassname( file.menu, "Serverregion" )

	// Event handlers
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseServerBrowserMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnServerBrowserMenuOpened )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( file.menu, BUTTON_Y, PrependControllerPrompts( BUTTON_Y, "#REFRESH_SERVERS" ), "#REFRESH_SERVERS", RefreshServers )

	// Setup server buttons
	var width = 1120.0  * ( GetScreenSize()[1] / 1080.0 )
	foreach ( var button in GetElementsByClassname( file.menu, "ServerButton" ) )
	{
		AddButtonEventHandler( button, UIE_CLICK, OnServerButtonClicked )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnServerButtonFocused )
		Hud_SetWidth( button , width )
	}

	AddButtonEventHandler( Hud_GetChild( file.menu , "BtnServerDummmyTop" ), UIE_GET_FOCUS, OnHitDummyTop )
	AddButtonEventHandler( Hud_GetChild( file.menu , "BtnServerDummmyBottom" ), UIE_GET_FOCUS, OnHitDummyBottom )



	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerJoin"), UIE_CLICK, OnServerSelected )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerListUpArrow"), UIE_CLICK, OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerListDownArrow"), UIE_CLICK, OnDownArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnDummyAfterFilterClear"), UIE_GET_FOCUS, OnHitDummyAfterFilterClear )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnLabelListUpArrow"), UIE_CLICK, ServerDetails_OnUpArrowSelected )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnLabelListDownArrow"), UIE_CLICK, ServerDetails_OnDownArrowSelected )


	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerNameTab"), UIE_CLICK, SortServerListByName_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerPlayersTab"), UIE_CLICK, SortServerListByPlayers_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerMapTab"), UIE_CLICK, SortServerListByMap_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerGamemodeTab"), UIE_CLICK, SortServerListByGamemode_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerRegionTab"), UIE_CLICK, SortServerListByRegion_Activate )

	// Filter Button and switch
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear"), UIE_CLICK, OnBtnFiltersClear_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnMapFiltersClear"), UIE_CLICK, OnBtnMapFiltersClear_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnGamemodeFiltersClear"), UIE_CLICK, OnBtnGamemodeFiltersClear_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnSelectMap"), UIE_CLICK, OnSelectMapButton_Activate )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnSelectGamemode"), UIE_CLICK, OnSelectModeButton_Activate )

	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnSelectRegion"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnSelectMods"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnHideFull"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnHideEmpty"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "SwtBtnHideProtected"), UIE_CHANGE, FilterAndUpdateList )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnSearchLabel"), UIE_CHANGE, FilterAndUpdateList )

	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerSearch"), UIE_CHANGE, FilterAndUpdateList )

	// Server Details
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerDescription"), UIE_CLICK, ShowServerDescription )
	AddButtonEventHandler( Hud_GetChild( file.menu, "BtnServerMods"), UIE_CLICK, ShowServerMods )

	AddButtonEventHandler( Hud_GetChild( file.menu, "ConnectingButton"), UIE_CLICK, ConnectingButton_Activate )


	// Rui is a pain
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "BtnSelectMap") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "BtnSelectGamemode") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnSelectRegion") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnSelectMods") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnHideFull") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnHideEmpty") ), "buttonText", "" )
	RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnHideProtected") ), "buttonText", "" )

	ToggleConnectingHUD(false)
	ToggleServerDetailsSlideBar(false)

	// UI resize stuff
	Hud_SetWidth(Hud_GetChild( file.menu, "BtnServerSearch"), (500 * ( GetScreenSize()[0] / 1920.0 )) - Hud_GetWidth(Hud_GetChild( file.menu, "BtnSearchLabel")) + Hud_GetPos(Hud_GetChild( file.menu, "BtnServerSearch"))[0] - 10 * ( GetScreenSize()[0] / 1920.0 ))
	Hud_SetWidth(Hud_GetChild( file.menu, "BtnSearchLabel"), 500 * ( GetScreenSize()[0] / 1920.0 ))
	
	// UI was cut off on some aspect ratios; not perfect
	UpdateServerInfoBasedOnRes()
}

////////////////////////////
// Button
////////////////////////////

void function OnSelectMapButton_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	OnCloseServerBrowserMenu()
	AdvanceMenu( GetMenu( "SB_MapsMenu" ) )
}

void function OnSelectModeButton_Activate( var button )
{	
	if ( Hud_IsLocked( button ) )
		return

	OnCloseServerBrowserMenu()
	AdvanceMenu( GetMenu( "SB_ModesMenu" ) )
}

////////////////////////////
// Slider
////////////////////////////
void function UpdateMouseDeltaBuffer( int x, int y )
{
	mouseDeltaBuffer.deltaX += x
	mouseDeltaBuffer.deltaY += y

	SliderBarUpdate()
}

void function FlushMouseDeltaBuffer()
{
	mouseDeltaBuffer.deltaX = 0
	mouseDeltaBuffer.deltaY = 0
}


void function SliderBarUpdate()
{
	if ( file.filteredServers.len() <= BUTTONS_PER_PAGE )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnServerListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnServerListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused( sliderButton )

	float minYPos = -40.0 * ( GetScreenSize()[1] / 1080.0 )
	float maxHeight = 562.0  * ( GetScreenSize()[1] / 1080.0 )
	float maxYPos = minYPos - ( maxHeight - Hud_GetHeight( sliderPanel ) )
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ) )

	float jump = minYPos - ( useableSpace / ( float( file.filteredServers.len() ) ) )

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos( sliderButton )[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( ( newPos - minYPos ) / useableSpace ) * ( file.filteredServers.len() - BUTTONS_PER_PAGE ) )
	UpdateShownPage()
}

void function UpdateListSliderHeight( float servers )
{
	var sliderButton = Hud_GetChild( file.menu , "BtnServerListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnServerListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	float maxHeight = 562.0 * ( GetScreenSize()[1] / 1080.0 )
	float minHeight = 80.0 * ( GetScreenSize()[1] / 1080.0 )

	float height = maxHeight * ( BUTTONS_PER_PAGE / servers )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}


void function UpdateListSliderPosition( int servers )
{
	var sliderButton = Hud_GetChild( file.menu , "BtnServerListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnServerListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	float minYPos = -40.0 * ( GetScreenSize()[1] / 1080.0 )
	float useableSpace = (562.0 * ( GetScreenSize()[1] / 1080.0 ) - Hud_GetHeight( sliderPanel ) )

	float jump = minYPos - ( useableSpace / ( float( servers ) - BUTTONS_PER_PAGE ) * file.scrollOffset )

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnScrollDown( var button )
{	
	if(GetElementsByClassname(file.menu, "ServerDetails").contains( GetFocus() )) {
		ServerDetails_OnDownArrowSelected( button )
	} else {
		if (file.filteredServers.len() <= BUTTONS_PER_PAGE) return
		file.scrollOffset += 5
		if (file.scrollOffset + BUTTONS_PER_PAGE > file.filteredServers.len()) {
			file.scrollOffset = file.filteredServers.len() - BUTTONS_PER_PAGE
		}
		UpdateShownPage()
		UpdateListSliderPosition( file.filteredServers.len() )
	}
}

void function OnScrollUp( var button )
{	
	if(GetElementsByClassname(file.menu, "ServerDetails").contains( GetFocus() )) {
		ServerDetails_OnUpArrowSelected( button )
	} else {
		file.scrollOffset -= 5
		if ( file.scrollOffset < 0 ) {
			file.scrollOffset = 0
		}
		UpdateShownPage()
		UpdateListSliderPosition( file.filteredServers.len() )
	}
}

////////////////////////////
// Connecting pop-up
////////////////////////////
void function ToggleConnectingHUD( bool vis )
{
	foreach (e in GetElementsByClassname( file.menu, "connectingHUD" ) ) {
		Hud_SetEnabled( e, vis )
		Hud_SetVisible( e, vis )
	}

	if ( vis ) Hud_SetFocused( Hud_GetChild( file.menu, "ConnectingButton" ) )
}

void function ConnectingButton_Activate( var button )
{
	file.cancelConnection = true
}

////////////////////////////
// Aspect ratio compensation
////////////////////////////
// No way to get aspect ratio sadly
// This doesn't werk on some obscure resolutions, mostly really small 4:3
void function UpdateServerInfoBasedOnRes()
{
	if ( FloatsEqual( float(GetScreenSize()[0] ) / float( GetScreenSize()[1] ) , 1.6, 0.07 ) ) // 16/10
	{
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerName"), 392)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapImage"), 400)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapBack"), 400)
		Hud_SetWidth( Hud_GetChild(file.menu, "LabelServerDetails"), 360)
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerDetailsPanel"), 400)
	}
	if( FloatsEqual( float( GetScreenSize()[0] ) / float( GetScreenSize()[1] ) , 1.3, 0.055 ) ) // 4/3
	{
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerName"), 292)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapImage"), 300)
		Hud_SetWidth( Hud_GetChild(file.menu, "NextMapBack"), 300)
		Hud_SetWidth( Hud_GetChild(file.menu, "LabelServerDetails"), 260)
		Hud_SetWidth( Hud_GetChild(file.menu, "ServerDetailsPanel"), 300)
	}
}

////////////////////////////
// Open/close callbacks
////////////////////////////
void function OnCloseServerBrowserMenu()
{
	try
	{	
		printt("Close Server Browser Menu")
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )
		DeregisterButtonPressedCallback( KEY_TAB , OnKeyTabPressed )
		DeregisterButtonPressedCallback( KEY_ENTER, OnEnterPressed )
		DeregisterButtonPressedCallback( KEY_R, OnKeyRPressed )
	}
	catch ( ex ) {}
}

void function OnServerBrowserMenuOpened()
{	
	printt("Open Server Browser Menu")
	Hud_SetText( Hud_GetChild( file.menu, "InGamePlayerLabel" ), Localize( "#INGAME_PLAYERS", "0" ) )
	Hud_SetText( Hud_GetChild( file.menu, "TotalServerLabel" ),  Localize( "#TOTAL_SERVERS", "0" ) )
	Hud_SetText( Hud_GetChild( file.menu, "Title" ), "#MENU_TITLE_SERVER_BROWSER" )
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_MAIN )

	file.scrollOffset = 0
	// dont rerequest if we came from the connect menu
	if ( !NSIsRequestingServerList() && uiGlobal.lastMenuNavDirection != MENU_NAV_BACK )
	{
		NSClearRecievedServerList()
		NSRequestServerList()
	}

	filterDirection.sortingBy = sortingBy.DEFAULT

	thread WaitForServerListRequest()

	RegisterButtonPressedCallback( MOUSE_WHEEL_UP , OnScrollUp )
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN , OnScrollDown )
	RegisterButtonPressedCallback( KEY_TAB , OnKeyTabPressed )
	RegisterButtonPressedCallback( KEY_ENTER, OnEnterPressed )
	RegisterButtonPressedCallback( KEY_R, OnKeyRPressed )
}

////////////////////////////
// Arrow navigation fuckery
////////////////////////////
bool function IsFilterPanelElementFocused()
{
	// get name of focused element
	var focusedElement = GetFocus()

	foreach ( element in GetElementsByClassname( file.menu, "FilterPanelChild" ) )
	{
		if ( element == focusedElement ) return true
	}


	return false;
}

void function OnKeyTabPressed( var button )
{
	try
	{
		// toggle focus between server list and filter panel
		if ( IsFilterPanelElementFocused() )
		{
			Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer1" ) )
		}
		else
		{
			Hud_SetFocused( Hud_GetChild( file.menu, "BtnServerSearch" ) )
			HideServerInfo()
		}
	}
	catch ( ex ) {}
}

void function OnHitDummyTop( var button )
{
	file.scrollOffset -= 1
	if ( file.scrollOffset < 0 )
	{
		// was at top already
		file.scrollOffset = 0
		Hud_SetFocused(Hud_GetChild(file.menu, "BtnServerNameTab"))
	}
	else 
	{
		// only update if list position changed
		UpdateShownPage()
		UpdateListSliderPosition( file.filteredServers.len() )
		DisplayFocusedServerInfo( file.serverButtonFocusedID )
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer1" ) )
	}
}

void function OnHitDummyBottom( var button )
{
	file.scrollOffset += 1
	if ( file.scrollOffset + BUTTONS_PER_PAGE > file.filteredServers.len() )
	{
		// was at bottom already
		file.scrollOffset = file.filteredServers.len() - BUTTONS_PER_PAGE
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServerSearch" ) )
		HideServerInfo()
	}
	else
	{
		// only update if list position changed
		UpdateShownPage()
		UpdateListSliderPosition( file.filteredServers.len() )
		DisplayFocusedServerInfo( file.serverButtonFocusedID )
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer15" ) )
	}
}

void function OnHitDummyAfterFilterClear( var button )
{
	Hud_SetFocused( Hud_GetChild( file.menu, "BtnServerNameTab" ) )
}


void function OnDownArrowSelected( var button )
{
	if ( file.filteredServers.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 1
	if ( file.scrollOffset + BUTTONS_PER_PAGE > file.filteredServers.len() )
	{
		file.scrollOffset = file.filteredServers.len() - BUTTONS_PER_PAGE
	}
	
	UpdateShownPage()
	UpdateListSliderPosition( file.filteredServers.len() )
}


void function OnUpArrowSelected( var button )
{
	file.scrollOffset -= 1
	if ( file.scrollOffset < 0 )
	{
		file.scrollOffset = 0
	}
	
	UpdateShownPage()
	UpdateListSliderPosition( file.filteredServers.len() )
}

////////////////////////
// Key Callbacks
////////////////////////
void function OnEnterPressed( arg ) 
{
	// only trigger if a server is focused
	if ( IsServerButtonFocused() ) 
	{
		OnServerSelected(0)
	}
}

void function OnKeyRPressed( arg ) 
{
	if ( !IsSearchBarFocused() ) 
	{
		RefreshServers(0);
	}
}

bool function IsServerButtonFocused() 
{
	var focusedElement = GetFocus()
	if ( focusedElement == null )
		return false
	
	var name = Hud_GetHudName( focusedElement )

	foreach ( element in GetElementsByClassname( file.menu, "ServerButton" ) ) 
	{
		if ( element == focusedElement ) 
			return true
	}

	return false
}

bool function IsSearchBarFocused() 
{
	return Hud_GetChild( file.menu, "BtnServerSearch" ) == GetFocus()
}


////////////////////////////
// Server Details Button
////////////////////////////
void function ShowServerDescription( var button )
{
	file.serverDetailsActiveStrings = file.serverDetailsDescriptionStrings
	file.isRequiredModsListShow = false
	UpdateServerDetails_SliderHeight()
}

void function ShowServerMods( var button )
{
	file.serverDetailsActiveStrings = file.serverDetailsModsStrings
	file.isRequiredModsListShow = true
	UpdateServerDetails_SliderHeight()
}

////////////////////////////
// Server list; filter,update,...
////////////////////////////
void function HideServerInfo()
{
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnServerDescription" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnServerMods" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnServerJoin" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "LabelServerDetails" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextMapImage" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextMapBack" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextMapName" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "ServerName" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextModeIcon" ), false )
	Hud_SetVisible( Hud_GetChild( file.menu, "NextGameModeName" ), false )
}

void function OnBtnFiltersClear_Activate( var button )
{
	Hud_SetText( Hud_GetChild( file.menu, "BtnServerSearch" ), "" )

	SetConVarBool( "filter_hide_empty", false )
	SetConVarBool( "filter_hide_full", false )
	SetConVarBool( "filter_hide_protected", false )
	SetConVarString( "filter_map", "SWITCH_ANY" )
	SetConVarString( "filter_gamemode", "SWITCH_ANY" )
	SetConVarString( "filter_region", "SWITCH_ANY" )
	SetConVarString( "filter_mods", "SWITCH_ANY" )

	FilterAndUpdateList(0)
}

void function OnBtnMapFiltersClear_Activate( var button )
{
	SetConVarString( "filter_map", "SWITCH_ANY" )

	FilterAndUpdateList(0)
}

void function OnBtnGamemodeFiltersClear_Activate( var button )
{
	SetConVarString( "filter_gamemode", "SWITCH_ANY" )

	FilterAndUpdateList(0)
}

void function FilterAndUpdateList( var n )
{
	filterArguments.searchTerm = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnServerSearch" ) )
	if ( filterArguments.searchTerm == "" ) filterArguments.useSearch = false else filterArguments.useSearch = true
	filterArguments.filterMap = GetConVarString("filter_map")
	filterArguments.filterGamemode = GetConVarString("filter_gamemode")
	filterArguments.filterRegion = GetConVarString("filter_region")
	filterArguments.filterMods = GetConVarString("filter_mods")
	filterArguments.hideEmpty = GetConVarBool( "filter_hide_empty" )
	filterArguments.hideFull = GetConVarBool( "filter_hide_full" )
	filterArguments.hideProtected = GetConVarBool( "filter_hide_protected" )

	Hud_SetText( Hud_GetChild( file.menu, "LabelMapSelected" ), "#" + filterArguments.filterMap )
	Hud_SetText( Hud_GetChild( file.menu, "LabelGamemodeSelected" ),"#" + filterArguments.filterGamemode )

	file.scrollOffset = 0
	UpdateListSliderPosition( file.filteredServers.len() )

	HideServerInfo()
	FilterServerList()


	switch ( filterDirection.sortingBy )
	{
		case sortingBy.NONE:
			UpdateShownPage()
			break
		case sortingBy.DEFAULT:
			filterDirection.serverName = !filterDirection.serverName
			SortServerListByDefault_Activate(0)
			break
		case sortingBy.NAME:
			filterDirection.serverName = !filterDirection.serverName
			SortServerListByName_Activate(0)
			break
		case sortingBy.PLAYERS:
			filterDirection.serverPlayers = !filterDirection.serverPlayers
			SortServerListByPlayers_Activate(0)
			break
		case sortingBy.MAP:
			filterDirection.serverMap = !filterDirection.serverMap
			SortServerListByMap_Activate(0)
			break
		case sortingBy.GAMEMODE:
			filterDirection.serverGamemode = !filterDirection.serverGamemode
			SortServerListByGamemode_Activate(0)
			break
		case sortingBy.REGION:
			filterDirection.serverRegion = !filterDirection.serverRegion
			SortServerListByRegion_Activate(0)
			break
		default:
			printt( "How the f did you get here" )
	}

	if ( file.shouldFocus )
	{
		file.shouldFocus = false
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer1" ) )
	}
}


void function RefreshServers( var button )
{
	if ( NSIsRequestingServerList() )
		return

	file.serverListRequestFailed = false
	file.scrollOffset = 0
	NSClearRecievedServerList()
	NSRequestServerList()

	thread WaitForServerListRequest()
}


void function WaitForServerListRequest()
{
	for ( int i = 0; i < BUTTONS_PER_PAGE; i++)
	{
		Hud_SetVisible( file.serversProtected[ i ], false )
		printt(file.serverButtons[ i ])
		Hud_SetVisible( file.serverButtons[ i ], false )
		Hud_SetText( file.serversName[ i ], "" )
		Hud_SetText( file.playerCountLabels[ i ], "" )
		Hud_SetText( file.serversMap[ i ], "" )
		Hud_SetText( file.serversGamemode[ i ], "" )
		Hud_SetText( file.serversRegion[ i ], "" )
	}

	HideServerInfo()

	Hud_SetVisible( file.serversName[ 0 ], true )
	Hud_SetText( file.serversName[ 0 ], "#NS_SERVERBROWSER_WAITINGFORSERVERS" )

	// wait for request to complete
	while ( NSIsRequestingServerList() )
		WaitFrame()

	file.serverListRequestFailed = !NSMasterServerConnectionSuccessful()
	if ( file.serverListRequestFailed )
	{
		Hud_SetText( file.serversName[ 0 ], "#NS_SERVERBROWSER_CONNECTIONFAILED" )
	}
	else
	{
		FilterAndUpdateList(0)
		Hud_SetFocused( Hud_GetChild(file.menu, "BtnServer1" ) )
	}
}



void function FilterServerList()
{
	file.filteredServers.clear()
	int totalPlayers = 0

	array<ServerInfo> servers = NSGetGameServers()

	foreach ( ServerInfo server in servers )
	{
		totalPlayers += server.playerCount

		if(filterArguments.filterRegions.find(server.region) == -1) {
			Hud_DialogList_AddListItem( Hud_GetChild( file.menu, "SwtBtnSelectRegion" ) , server.region,  server.region )
			filterArguments.filterRegions.append(server.region)
		}

		// Filters
		if ( filterArguments.hideEmpty && server.playerCount == 0 )
			continue;
		
		if ( filterArguments.hideFull && server.playerCount == server.maxPlayerCount )
			continue;
		
		if ( filterArguments.hideProtected && server.requiresPassword )
			continue;
		
		if ( filterArguments.filterMap != "SWITCH_ANY" && filterArguments.filterMap != server.map )
			continue;
		
		if ( filterArguments.filterGamemode != "SWITCH_ANY" && filterArguments.filterGamemode != GetGameModeDisplayName(server.playlist) )
			continue;
		
		if ( filterArguments.filterRegion != "SWITCH_ANY" && filterArguments.filterRegion != server.region )
			continue;
	
		// Search
		if ( filterArguments.useSearch )
		{	
			array<string> sName
			sName.append( server.name.tolower() )
			sName.append( Localize( GetMapDisplayName( server.map ) ).tolower() )
			sName.append( server.map.tolower() )
			sName.append( server.playlist.tolower() )
			sName.append( Localize( server.playlist ).tolower() )
			sName.append( server.description.tolower() )
			sName.append( server.region.tolower() )

			string sTerm = filterArguments.searchTerm.tolower()
			
			bool found = false
			for( int j = 0; j < sName.len(); j++ )
			{
				if ( sName[j].find( sTerm ) != null )
					found = true
			}
			
			if ( !found )
				continue;
		}

		if(filterArguments.filterMods != "SWITCH_ANY") {
			bool hasMissingMod = false
			bool hasOutdatedMod = false
			foreach(RequiredModInfo mod in server.requiredMods) {

				if( !NSGetModNames().contains( mod.name ) ) {
					hasMissingMod = true
					continue
				}

				array<int> serverModVersion = StringArrayToIntArray( split( mod.version, ".") )
				array<int> clientModVersion = StringArrayToIntArray( split( NSGetModVersionByModName( mod.name ), "." ))

				if( ( serverModVersion[0] != clientModVersion[0] || serverModVersion[1] > clientModVersion[1] )) {
					hasOutdatedMod = true
					continue
				} 
			}

			if(!hasMissingMod && !hasOutdatedMod && filterArguments.filterMods == "INSTALLED") {
				file.filteredServers.append( server )
				continue
			} else if(hasOutdatedMod && filterArguments.filterMods == "OUTDATED") {
				file.filteredServers.append( server )
				continue
			} else if(hasMissingMod && filterArguments.filterMods == "MISSING") {
				file.filteredServers.append( server )
				continue
			}
		} else {
			file.filteredServers.append( server )
		}
	}
	
	// Update player and server count
	Hud_SetText( Hud_GetChild( file.menu, "InGamePlayerLabel" ), Localize("#INGAME_PLAYERS", string( totalPlayers ) ) )
	Hud_SetText( Hud_GetChild( file.menu, "TotalServerLabel" ),  Localize("#TOTAL_SERVERS", string( NSGetServerCount() ) ) )
}


void function UpdateShownPage()
{

	for ( int i = 0; i < BUTTONS_PER_PAGE; i++ )
	{
		Hud_SetVisible( file.serversProtected[ i ], false )
		Hud_SetVisible( file.serverButtons[ i ], false )
		Hud_SetText( file.serversName[ i ], "" )
		Hud_SetText( file.playerCountLabels[ i ], "" )
		Hud_SetText( file.serversMap[ i ], "" )
		Hud_SetText( file.serversGamemode[ i ], "" )
		Hud_SetText( file.serversRegion[ i ], "" )
	}

	int j = file.filteredServers.len() > BUTTONS_PER_PAGE ? BUTTONS_PER_PAGE : file.filteredServers.len()

	for ( int i = 0; i < j; i++ )
	{
		int buttonIndex = file.scrollOffset + i
		ServerInfo server = file.filteredServers[ buttonIndex ]

		Hud_SetEnabled( file.serverButtons[ i ], true )
		Hud_SetVisible( file.serverButtons[ i ], true )

		Hud_SetVisible( file.serversProtected[ i ], server.requiresPassword )
		Hud_SetText( file.serversName[ i ], server.name )
		Hud_SetText( file.playerCountLabels[ i ], format( "%i/%i", server.playerCount, server.maxPlayerCount ) )
		Hud_SetText( file.serversMap[ i ], GetMapDisplayName( server.map ) )
		Hud_SetText( file.serversGamemode[ i ], GetGameModeDisplayName( server.playlist ) )
		Hud_SetText( file.serversRegion[ i ], server.region )
	}


	if ( NSGetServerCount() == 0 )
	{
		Hud_SetEnabled( file.serverButtons[ 0 ], true )
		Hud_SetVisible( file.serverButtons[ 0 ], true )
		Hud_SetText( file.serversName[ 0 ], "#NS_SERVERBROWSER_NOSERVERS" )
	}
	UpdateListSliderHeight( float( file.filteredServers.len() ) )
}

void function OnServerButtonFocused( var button )
{
	if ( file.scrollOffset < 0 )
		file.scrollOffset = 0
	
	int scriptID = int ( Hud_GetScriptID( button ) )
	file.serverButtonFocusedID = scriptID
	if ( file.filteredServers.len() > 0 )
		// file.focusedServerIndex = file.filteredServers[ file.scrollOffset + scriptID ].serverIndex
		file.focusedServer = file.filteredServers[ file.scrollOffset + scriptID ]
	DisplayFocusedServerInfo( scriptID )

}

void function OnServerButtonClicked(var button)
{
	int scriptID = int ( Hud_GetScriptID( button ) )

	DisplayFocusedServerInfo( scriptID )
	CheckDoubleClick( scriptID, true )
}

void function CheckDoubleClick( int scriptID, bool wasClickNav )
{
	if ( NSGetServerCount() == 0 ) return


	int serverIndex = file.scrollOffset + scriptID

	bool sameServer = false
	if ( file.lastSelectedServer == file.filteredServers[ serverIndex ] ) sameServer = true

	file.serverSelectedTimeLast = file.serverSelectedTime
	file.serverSelectedTime = Time()

	file.lastSelectedServer = file.filteredServers[ serverIndex ]

	if ( wasClickNav && ( file.serverSelectedTime - file.serverSelectedTimeLast < DOUBLE_CLICK_TIME_MS ) && sameServer )
	{
		OnServerSelected(0)
	}
}

void function DisplayFocusedServerInfo( int scriptID )
{
	if ( scriptID == 999 || scriptID == -1 || scriptID == 16 ) return

	if ( NSIsRequestingServerList() || NSGetServerCount() == 0 || file.serverListRequestFailed || file.filteredServers.len() == 0 )
		return

	var menu = GetMenu( "ServerBrowserMenu" )

	int serverIndex = file.scrollOffset + scriptID
	if ( serverIndex < 0 ) serverIndex = 0

	ServerInfo server = file.filteredServers[ serverIndex ]

	Hud_SetVisible( Hud_GetChild( menu, "BtnServerDescription" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "BtnServerMods" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "BtnServerJoin" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "LabelServerDetails" ), true)
	// text panels

	file.serverDetailsDescriptionStrings = split(FormatServerDescriptionLabel(server.description), "\n")
	file.serverDetailsModsStrings = split(FormatServerModsLabel( server.requiredMods ), "\n") 

	if(!file.isRequiredModsListShow) {
		file.serverDetailsActiveStrings = file.serverDetailsDescriptionStrings

	} else {
		file.serverDetailsActiveStrings = file.serverDetailsModsStrings
	}

	UpdateServerDetails_SliderHeight()

	// map name/image/server name
	string map = server.map
	Hud_SetVisible( Hud_GetChild( menu, "NextMapImage" ), true )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapBack" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextMapImage" ) ), "basicImage", GetMapImageForMapName( map ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextMapName" ), true )
	Hud_SetText( Hud_GetChild( menu, "NextMapName" ), GetMapDisplayName( map ) )
	Hud_SetVisible( Hud_GetChild( menu, "ServerName" ), true )
	Hud_SetText( Hud_GetChild( menu, "ServerName" ), server.name )

	// mode name/image
	string mode = server.playlist
	Hud_SetVisible( Hud_GetChild( menu, "NextModeIcon" ), true )
	RuiSetImage( Hud_GetRui( Hud_GetChild( menu, "NextModeIcon" ) ), "basicImage", GetPlaylistThumbnailImage( mode ) )
	Hud_SetVisible( Hud_GetChild( menu, "NextGameModeName" ), true )

	if ( mode.len() != 0 )
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), GetGameModeDisplayName( mode ) )
	else
		Hud_SetText( Hud_GetChild( menu, "NextGameModeName" ), "#NS_SERVERBROWSER_UNKNOWNMODE" )
}

string function FormatServerDescriptionLabel( string description ) {

	string ret = ""
	int numLetter = 0

	foreach(string word in split(description, " ")) {
		if( numLetter + word.len() + 1 <= MAX_LETTER_PER_ROWS) {
			if(numLetter != 0) {
				ret += " "
				numLetter ++
			}
			numLetter += word.len()
			ret += word
		} else {
			ret += "\n"
			numLetter = word.len()
			ret += word
		}
	}

	return ret
}

string function FormatServerModsLabel( array<RequiredModInfo> mods )
{
	string ret
	string installed_mods = ""
	string disabled_mods = ""
	string outdated_mods = ""
	string missing_mods = ""

	foreach ( RequiredModInfo mod in mods )
	{

		if( !NSGetModNames().contains( mod.name ) ) {
			missing_mods += format( " - %s v%s\n", mod.name, mod.version )
			continue
		}

		array<int> serverModVersion = StringArrayToIntArray( split( mod.version, ".") )
		array<int> clientModVersion = StringArrayToIntArray( split( NSGetModVersionByModName( mod.name ), "." ))

		if( ( serverModVersion.len() != clientModVersion.len() || serverModVersion[0] != clientModVersion[0] || serverModVersion[1] > clientModVersion[1] ) ) {
			outdated_mods += format( " - %s v%s -> v%s\n", mod.name, NSGetModVersionByModName( mod.name ), mod.version )
			continue
		}

		if(NSIsModEnabled( mod.name ) && mod.name != "Northstar.Custom") {
			disabled_mods += format( " - %s v%s\n", mod.name, mod.version )
			continue
		}

		installed_mods += format( " - %s v%s\n", mod.name, mod.version )
	}

	if(installed_mods != "") {
		ret += (Localize("#INSTALLED_MODS") + ":\n" + installed_mods)
	}
	if(disabled_mods != "") {
		ret += (Localize("#DISABLED_MODS") + ":\n" + disabled_mods)
	}
	if(outdated_mods != "") {
		ret += (Localize("#OUTDATED_MODS") + ":\n" + outdated_mods) 
	}
	if(missing_mods != "") {
		ret += (Localize("#MISSING_MODS") + ":\n" + missing_mods)
	}

	return ret
}

void function OnServerSelected( var button )
{
	if ( NSIsRequestingServerList() || NSGetServerCount() == 0 || file.serverListRequestFailed )
		return

	ServerInfo server = file.focusedServer

	file.lastSelectedServer = server

	foreach ( RequiredModInfo mod in server.requiredMods )
	{
		if ( !NSGetModNames().contains( mod.name ) )
		{
			DialogData dialogData
			dialogData.header = "#ERROR"
			dialogData.message = format( "Missing mod \"%s\" v%s", mod.name, mod.version )
			dialogData.image = $"ui/menu/common/dialog_error"

			#if PC_PROG
				AddDialogButton( dialogData, "#DISMISS" )

				AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
			#endif // PC_PROG
			AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

			OpenDialog( dialogData )

			return
		}
		else
		{
			// this uses semver https://semver.org
			array<string> serverModVersion = split( mod.name, "." )
			array<string> clientModVersion = split( NSGetModVersionByModName( mod.name ), "." )

			bool semverFail = false
			// if server has invalid semver don't bother checking
			if ( serverModVersion.len() == 3 )
			{
				// bad client semver
				if ( clientModVersion.len() != serverModVersion.len() )
					semverFail = true
				// major version, don't think we should need to check other versions
				else if ( clientModVersion[ 0 ] != serverModVersion[ 0 ] )
					semverFail = true
			}

			if ( semverFail )
			{
				DialogData dialogData
				dialogData.header = "#ERROR"
				dialogData.message = format( "Server has mod \"%s\" v%s while we have v%s", mod.name, mod.version, NSGetModVersionByModName( mod.name ) )
				dialogData.image = $"ui/menu/common/dialog_error"

				#if PC_PROG
					AddDialogButton( dialogData, "#DISMISS" )

					AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
				#endif // PC_PROG
				AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

				OpenDialog( dialogData )

				return
			}
		}
	}

	if ( server.requiresPassword )
	{
		OnCloseServerBrowserMenu()
		AdvanceMenu( GetMenu( "ConnectWithPasswordMenu" ) )
	}
	else
	{
		TriggerConnectToServerCallbacks()
		thread ThreadedAuthAndConnectToServer()
	}
}


void function ThreadedAuthAndConnectToServer( string password = "" )
{
	if ( NSIsAuthenticatingWithServer() )
		return

	NSTryAuthWithServer( file.lastSelectedServer.index, password )

	ToggleConnectingHUD( true )

	while ( NSIsAuthenticatingWithServer() && !file.cancelConnection )
	{
		WaitFrame()
	}

	ToggleConnectingHUD( false )

	if ( file.cancelConnection )
	{
		file.cancelConnection = false
		// re-focus server list
		Hud_SetFocused( Hud_GetChild( file.menu, "BtnServer" + ( file.serverButtonFocusedID + 1 ) ) )
		return
	}

	file.cancelConnection = false

	if ( NSWasAuthSuccessful() )
	{
		bool modsChanged = false

		// disable all RequiredOnClient mods that are not required by the server and are currently enabled
		foreach ( string modName in NSGetModNames() )
		{
			if ( NSIsModRequiredOnClient( modName ) && NSIsModEnabled( modName ) )
			{
				// find the mod name in the list of server required mods
				bool found = false
				foreach ( RequiredModInfo mod in file.lastSelectedServer.requiredMods )
				{
					if (mod.name == modName)
					{
						found = true
						break
					}
				}
				// if we didnt find the mod name, disable the mod
				if (!found)
				{
					modsChanged = true
					NSSetModEnabled( modName, false )
				}
			}
		}

		// enable all RequiredOnClient mods that are required by the server and are currently disabled
		foreach ( RequiredModInfo mod in file.lastSelectedServer.requiredMods )
		{
			if ( NSIsModRequiredOnClient( mod.name ) && !NSIsModEnabled( mod.name ))
			{
				modsChanged = true
				NSSetModEnabled( mod.name, true )
			}
		}

		// only actually reload if we need to since the uiscript reset on reload lags hard
		if ( modsChanged )
			ReloadMods()

		NSConnectToAuthedServer()
	}
	else
	{
		string reason = NSGetAuthFailReason()

		DialogData dialogData
		dialogData.header = "#ERROR"
		dialogData.message = reason
		dialogData.image = $"ui/menu/common/dialog_error"

		#if PC_PROG
			AddDialogButton( dialogData, "#DISMISS" )

			AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
		#endif // PC_PROG
		AddDialogFooter( dialogData, "#B_BUTTON_DISMISS_RUI" )

		OpenDialog( dialogData )
	}
}

//////////////////////////////////////
// Shadow realm
//////////////////////////////////////
int function ServerSortLogic ( ServerInfo a, ServerInfo b )
{
	var aTemp
	var bTemp

	bool direction

	// We can hard code this cause adding entire columns isn't as easy
	switch ( filterDirection.sortingBy )
	{
		case sortingBy.DEFAULT:
			aTemp = a.playerCount
			bTemp = b.playerCount

			// `1000` is assumed to always be higher than `serverPlayersMax`
			if (aTemp + 1 < a.maxPlayerCount)
				aTemp = aTemp+2000
			if (bTemp + 1 < b.maxPlayerCount)
				bTemp = bTemp+2000
			if (aTemp + 1 == a.maxPlayerCount)
				aTemp = aTemp+1000
			if (bTemp + 1 == b.maxPlayerCount)
				bTemp = bTemp+1000

			direction = filterDirection.serverName
			break;
		case sortingBy.NAME:
			aTemp = a.name.tolower()
			bTemp = b.name.tolower()
			direction = filterDirection.serverName
			break;
		case sortingBy.PLAYERS:
			aTemp = a.playerCount
			bTemp = b.playerCount
			direction = filterDirection.serverPlayers
			break;
		case sortingBy.MAP:
			aTemp = Localize( a.map ).tolower()
			bTemp = Localize( b.map ).tolower()
			direction = filterDirection.serverMap
			break;
		case sortingBy.GAMEMODE:
			aTemp = Localize( a.playlist ).tolower()
			bTemp = Localize( b.playlist ).tolower()
			direction = filterDirection.serverGamemode
			break;
		case sortingBy.REGION:
			aTemp = a.region
			bTemp = b.region
			direction = filterDirection.serverRegion
			break;
		default:
			return 0
	}

	int invert = direction == true ? 1 : -1

	if ( aTemp > bTemp )
		return 1 * invert

	if ( aTemp < bTemp )
		return -1 * invert

	return 0
}

void function SortServerListByDefault_Activate ( var button )
{
	filterDirection.sortingBy = sortingBy.DEFAULT

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverName = !filterDirection.serverName

	UpdateShownPage()
}


void function SortServerListByName_Activate ( var button )
{
	filterDirection.sortingBy = sortingBy.NAME

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverName = !filterDirection.serverName

	UpdateShownPage()
}


void function SortServerListByPlayers_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.PLAYERS

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverPlayers = !filterDirection.serverPlayers

	UpdateShownPage()
}

void function SortServerListByMap_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.MAP

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverMap = !filterDirection.serverMap

	UpdateShownPage()
}

void function SortServerListByGamemode_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.GAMEMODE

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverGamemode = !filterDirection.serverGamemode

	UpdateShownPage()
}

void function SortServerListByRegion_Activate( var button )
{
	filterDirection.sortingBy = sortingBy.REGION

	file.filteredServers.sort( ServerSortLogic )

	filterDirection.serverRegion = !filterDirection.serverRegion

	UpdateShownPage()
}

//////////////////////////////////////
// Callbacks
//////////////////////////////////////

void function AddConnectToServerCallback( void functionref( ServerInfo ) callback )
{
	if ( file.connectCallbacks.find( callback ) >= 0 )
		throw "ConnectToServerCallback has been registered twice. Duplicate callbacks are not allowed."
	file.connectCallbacks.append( callback )
}

void function RemoveConnectToServerCallback( void functionref( ServerInfo ) callback )
{
	file.connectCallbacks.fastremovebyvalue( callback )
}

void function TriggerConnectToServerCallbacks( ServerInfo ornull targetServer = null )
{
	ServerInfo server;
	if (targetServer == null)
	{
		targetServer = file.lastSelectedServer
	}

	foreach( callback in file.connectCallbacks )
	{
		callback( expect ServerInfo( targetServer ) )
	}
}

//////////////////////////////////////
// Mix
//////////////////////////////////////

array<int> function StringArrayToIntArray(array<string> stringArray) {
	array<int> intarray = []
	foreach (string str in stringArray) {
		intarray.append( str.tointeger())
	}
	return intarray
}

//////////////////////////////////////
// Server Details Slider
//////////////////////////////////////

void function ServerDetailSliderBarUpdate()
{
	if ( file.serverDetailsActiveStrings.len() <= MAX_NUMBER_OF_LINES )
	{
		FlushMouseDeltaBuffer_ServerDetail()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnLabelListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnLabelListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCaptureLabel" )

	Hud_SetFocused(sliderButton)

	float minYPos = 0.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 180.0 * (GetScreenSize()[1] / 1080.0)
	float maxYPos = minYPos + (maxHeight - Hud_GetHeight( sliderPanel )) 
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos + mouseDeltaBufferServerDetail.deltaY
	FlushMouseDeltaBuffer_ServerDetail()

	if ( newPos > maxYPos ) newPos = maxYPos
	if ( newPos < minYPos ) newPos = minYPos


	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.serverDetailsScrollOffset = int( ( (newPos - minYPos) / useableSpace ) * ( file.serverDetailsActiveStrings.len() - MAX_NUMBER_OF_LINES) )
	UpdateServerDetails_Label()
}

void function UpdateServerDetails_SliderHeight()
{	
	var sliderButton = Hud_GetChild( file.menu , "BtnLabelListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnLabelListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCaptureLabel" )

	float maxHeight = 180.0 * ( GetScreenSize()[1] / 1080.0 )
	float minHeight = 40.0 * ( GetScreenSize()[1] / 1080.0 )

	float height = maxHeight * ( MAX_NUMBER_OF_LINES / float( file.serverDetailsActiveStrings.len() ) )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )

	Hud_SetPos( sliderButton , 2, 0 )
	Hud_SetPos( sliderPanel , 2, 0 )
	Hud_SetPos( movementCapture , 2, 0 )

	file.serverDetailsScrollOffset = 0

	UpdateServerDetails_Label()

}

void function FlushMouseDeltaBuffer_ServerDetail()
{
	mouseDeltaBufferServerDetail.deltaX = 0
	mouseDeltaBufferServerDetail.deltaY = 0
}

void function UpdateMouseDeltaBuffer_ServerDetail(int x, int y)
{
	mouseDeltaBufferServerDetail.deltaX += x
	mouseDeltaBufferServerDetail.deltaY += y

	ServerDetailSliderBarUpdate()
}

void function UpdateServerDetails_Label() {
	string texteToDisplay

	if(file.serverDetailsActiveStrings.len() > MAX_NUMBER_OF_LINES) {
		ToggleServerDetailsSlideBar(true)

		for( int i = 0; i < MAX_NUMBER_OF_LINES; i++) {
			texteToDisplay += (file.serverDetailsActiveStrings[i + file.serverDetailsScrollOffset] + "\n")
		}

	} else {
		ToggleServerDetailsSlideBar(false)

		foreach(string text in file.serverDetailsActiveStrings) {
			texteToDisplay += (text + "\n") 
		}
		
	}

	Hud_SetText(Hud_GetChild( file.menu, "LabelServerDetails" ), texteToDisplay)

}

void function ToggleServerDetailsSlideBar(bool value) {
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnLabelListUpArrow" ), value )
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnLabelListUpArrowPanel" ), value )

	Hud_SetVisible( Hud_GetChild( file.menu, "BtnLabelListSlider" ), value )
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnLabelListSliderPanel" ), value )

	Hud_SetVisible( Hud_GetChild( file.menu, "BtnLabelListDownArrow" ), value )
	Hud_SetVisible( Hud_GetChild( file.menu, "BtnLabelListDownArrowPanel" ), value )

	Hud_SetVisible( Hud_GetChild( file.menu, "MouseMovementCaptureLabel" ), value )
}

void function ServerDetails_OnDownArrowSelected( var button )
{
	if ( ( file.serverDetailsScrollOffset + MAX_NUMBER_OF_LINES ) >= file.serverDetailsActiveStrings.len()) return

	file.serverDetailsScrollOffset += 1

	UpdateServerDetails_SliderPosition()
}


void function ServerDetails_OnUpArrowSelected( var button )
{
	if ( file.serverDetailsScrollOffset  == 0) return

	file.serverDetailsScrollOffset -= 1

	UpdateServerDetails_SliderPosition()
}

void function UpdateServerDetails_SliderPosition()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnLabelListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnLabelListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCaptureLabel" )

	float minYPos = 0.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 180.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = ( maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = ((useableSpace - minYPos) / float( file.serverDetailsActiveStrings.len() - MAX_NUMBER_OF_LINES)) *  float( file.serverDetailsScrollOffset )

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )

	UpdateServerDetails_Label()
}