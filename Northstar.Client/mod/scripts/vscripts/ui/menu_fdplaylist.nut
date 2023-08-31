global function InitFDPlaylistMenu
global function SetChecklistButtonSelected
global function GetDifficultyData
global function GetFDDifficultyArray

const int FD_PLAYLIST_EASY 		= 1 << 0
const int FD_PLAYLIST_NORMAL 	= 1 << 1
const int FD_PLAYLIST_HARD 		= 1 << 2
const int FD_PLAYLIST_MASTER 	= 1 << 3
const int FD_PLAYLIST_INSANE 	= 1 << 4

global struct FDDifficultyInfo
{
	string abbrev
	string name
	string playlist
	int difficultyIndex
	int difficultyBits
}

struct
{
	var menu
	var playButton
	var tutorialButton
	var hostButton
	array<var> checklistIconButtons
	array<FDDifficultyInfo> difficulties
	bool isOnPromoButton = false
	bool isOnPlayButton = false
	array<var> titanButtons

	var fdProperties
	var fdPropertiesData
	var selectedTitanButton
	var hintBox
	var hintIcon
	var descriptionBox
	var playHintBox
	var playHintIcon
	var playDescriptionBox
} file


void function InitFDPlaylistMenu()
{
	CreateDifficultyInfo( "fd_easy",	"Easy", 	"#FD_DIFFICULTY_EASY", FD_PLAYLIST_EASY )
	CreateDifficultyInfo( "fd_normal",	"Normal", 	"#FD_DIFFICULTY_NORMAL", FD_PLAYLIST_NORMAL )
	CreateDifficultyInfo( "fd_hard",	"Hard", 	"#FD_DIFFICULTY_HARD", FD_PLAYLIST_HARD )
	CreateDifficultyInfo( "fd_master", 	"Master", 	"#FD_DIFFICULTY_MASTER", FD_PLAYLIST_MASTER )
	CreateDifficultyInfo( "fd_insane",	"Insane", 	"#FD_DIFFICULTY_INSANE", FD_PLAYLIST_INSANE )

	file.menu = GetMenu( "FDMenu" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnFDMenu_NavigateBack )

	file.playButton = Hud_GetChild( file.menu, "PlayButton" )
	AddButtonEventHandler( file.playButton, UIE_CLICK, OnPlayButtonClick )
	AddButtonEventHandler( file.playButton, UIE_GET_FOCUS, OnPlayButtonFocus )
	AddButtonEventHandler( file.playButton, UIE_LOSE_FOCUS, OnPlayButtonFocusLost )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenFDMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseFDMenu )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	for ( int idx = 0; idx < 4; ++idx )
	{
		string buttonName = ("BtnPlaylistIcon" + format( "%02d", idx ))
		var button = Hud_GetChild( file.menu, buttonName )

		AddButtonEventHandler( button, UIE_CLICK, OnChecklistIconButtonClick )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnChecklistIconButtonFocus )
		AddButtonEventHandler( button, UIE_LOSE_FOCUS, OnChecklistIconButtonFocusLost )
		file.checklistIconButtons.append( button )

		var rui = Hud_GetRui( button )
		RuiSetBool( rui, "alwaysShowTitle", true )

		if ( idx==0 )
			SetChecklistButtonSelected( button, true )
	}

	for ( int i=0; i<NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var button = Hud_GetChild( file.menu, "TitanButton" + i )
		file.titanButtons.append( button )
		Hud_AddEventHandler( button, UIE_CLICK, TitanButton_OnClick )
		Hud_AddEventHandler( button, UIE_GET_FOCUS, TitanButton_OnFocused )
		Hud_AddEventHandler( button, UIE_LOSE_FOCUS, TitanButton_OnLoseFocused )
	}

	file.fdProperties = Hud_GetChild( file.menu, "TitanLoadoutFD" )
	file.fdPropertiesData = Hud_GetChild( file.fdProperties, "FDProperties" )

	SetNavLeftRight( file.titanButtons )

	file.hintIcon = Hud_GetChild( file.menu, "HintIcon" )
	var rui = Hud_GetRui( file.hintIcon )
	RuiSetImage( rui, "basicImage", $"rui/hud/gametype_icons/fd/coop_harvester" )

	file.hintBox = Hud_GetChild( file.menu, "HintBackground" )
	rui = Hud_GetRui( file.hintBox )
	RuiSetImage( rui, "basicImage", $"rui/borders/menu_border_button" )
	RuiSetFloat3( rui, "basicImageColor", <0,0,0> )
	RuiSetFloat( rui, "basicImageAlpha", 0.5 )

	file.descriptionBox = Hud_GetChild( file.menu, "LabelDetails" )

	file.playHintIcon = Hud_GetChild( file.menu, "PlayHintIcon" )
	rui = Hud_GetRui( file.playHintIcon )
	RuiSetImage( rui, "basicImage", $"rui/hud/gametype_icons/fd/coop_harvester" )

	file.playHintBox = Hud_GetChild( file.menu, "PlayHintBackground" )
	rui = Hud_GetRui( file.playHintBox )
	RuiSetImage( rui, "basicImage", $"rui/borders/menu_border_button" )
	RuiSetFloat3( rui, "basicImageColor", <0,0,0> )
	RuiSetFloat( rui, "basicImageAlpha", 0.5 )

	file.playDescriptionBox = Hud_GetChild( file.menu, "PlayLabelDetails" )

	file.tutorialButton = Hud_GetChild( file.menu, "TutorialButton" )
	AddButtonEventHandler( file.tutorialButton, UIE_CLICK, OnTutorialButtonClick )
}

void function OnOpenFDMenu()
{
	StopMatchmaking()

	UI_SetPresentationType( ePresentationType.FD_FIND_GAME )

	bool openInviting = IsSendOpenInviteTrue()

	var pbRui = Hud_GetRui( file.playButton )
	RuiSetBool( pbRui, "bigPresentation", false )
	RuiSetImage( pbRui, "itemImage", GetPlaylistImage( "aitdm" ) )
	RuiSetString( pbRui, "title", "#FD_PLAY_BUTTON" )

	SetupDifficultyButtons()
	entity player = GetUIPlayer()
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int loadoutIconCol = GetDataTableColumnByName( dataTable, "loadoutIcon" )
	int titanCol = GetDataTableColumnByName( dataTable, "titanRef" )
	for ( int i=0; i<NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var button = file.titanButtons[i]
		TitanLoadoutDef loadout = GetCachedTitanLoadout( i )
		int row = GetDataTableRowMatchingStringValue( dataTable, titanCol,  loadout.titanClass )

		asset icon = GetDataTableAsset( dataTable, row, loadoutIconCol )
		var rui = Hud_GetRui( button )
		RuiSetImage( rui, "buttonImage", icon )

		if ( !IsTitanLoadoutAvailable( player, loadout.titanClass ) )
		{
			Hud_SetLocked( button, true )
			RefreshButtonCost( button, loadout.titanClass, "", 0, 0 )
		}
		else
		{
			Hud_SetLocked( button, IsItemLocked( player, loadout.titanClass ) )
			RefreshButtonCost( button, loadout.titanClass )
		}

		Hud_SetSelected( button, ( uiGlobal.titanSpawnLoadoutIndex == i ) )
		if ( uiGlobal.titanSpawnLoadoutIndex == i )
			file.selectedTitanButton = button
	}

	UpdateFDPanel( file.fdProperties, uiGlobal.titanSpawnLoadoutIndex, true )

	RefreshCreditsAvailable()
	Lobby_SetFDMode( true )

	if ( GetPlaylistVarOrUseValue( "defaults", "fd_tutorial_url", "" ) != "" )
	{
		var rui = Hud_GetRui( file.tutorialButton )
		RuiSetString( rui, "buttonText", GetPlaylistVarOrUseValue( "defaults", "fd_tutorial_title", "" ) )
		Hud_Show( file.tutorialButton )
	}
	else
	{
		Hud_Hide( file.tutorialButton )
	}
}

void function OnCloseFDMenu()
{
	Lobby_SetFDMode( false )
}

void function SetupDifficultyButtons()
{
	entity player = GetUIPlayer()
	int length = file.checklistIconButtons.len()
	int persistenceBits = GetConVarInt( "fd_playlist_bits" )

	if ( persistenceBits == 0 )
		persistenceBits = 1

	bool selectedSomething = false

	for( int idx = 0; idx < length; ++idx )
	{
		FDDifficultyInfo info = GetDifficultyData( idx )
		var button = file.checklistIconButtons[idx]
		var buttonRui = Hud_GetRui( button )
		asset playlistThumbnail = GetPlaylistThumbnailImage( info.playlist )
		RuiSetImage( buttonRui, "checkImage", playlistThumbnail )
		RuiSetString( buttonRui, "abbreviation", Localize( info.abbrev ) )

		bool locked = IsItemLocked( player, info.playlist )
		Hud_SetLocked( button, locked )

		bool selected = (persistenceBits & info.difficultyBits) > 0
		SetChecklistButtonSelected( button, selected && !locked )

		selectedSomething = selectedSomething || (selected && !locked)
	}

	if ( !selectedSomething )
		SetChecklistButtonSelected( file.checklistIconButtons[0], true )

	thread UpdateDifficultyButtonsThread()
}

void function UpdateDifficultyButtonsThread()
{
	while ( GetTopNonDialogMenu() == GetMenu( "FDMenu" ) )
	{
		if ( GetUIPlayer() )
		{
			int length = file.checklistIconButtons.len()
			for( int idx = 0; idx < length; ++idx )
			{
				var panel = file.checklistIconButtons[idx]
				var panelRui = Hud_GetRui( panel )

				bool isMuted = (file.isOnPromoButton)
				RuiSetBool( panelRui, "isMuted", isMuted )

				bool isGlowing = (file.isOnPlayButton)
				RuiSetBool( panelRui, "isGlowing", isGlowing )
			}
		}
		WaitFrame()
	}
}

array<string> function GetFDDifficultyArray()
{
	array<string> difficulties

	foreach ( info in file.difficulties )
		difficulties.append( info.playlist )

	return difficulties
}

FDDifficultyInfo function GetDifficultyDataFromPlaylistName( string playlist )
{
	foreach ( data in file.difficulties )
	{
		if ( playlist == data.playlist )
			return data
	}

	unreachable
}

FDDifficultyInfo function GetDifficultyData( int idx )
{
	return file.difficulties[idx]
}

void function CreateDifficultyInfo( string playlist, string name, string abbrev, int bits )
{
	FDDifficultyInfo data
	data.name = name
	data.playlist = playlist
	data.abbrev = abbrev
	data.difficultyIndex = file.difficulties.len()
	data.difficultyBits = bits
	file.difficulties.append( data )
}


void function OnChecklistIconButtonFocus( var button )
{
	Hud_Show( file.hintIcon )
	Hud_Show( file.hintBox )

	string desc

	for ( int i=0; i<file.checklistIconButtons.len(); i++ )
	{
		var b = file.checklistIconButtons[i]
		if ( button == b )
		{
			string ref = file.difficulties[i].playlist
			if ( Hud_IsLocked( button ) )
			{
				desc = GetItemUnlockReqText( ref )
			}
			else
			{
				desc = GetPlaylistVarOrUseValue( ref, "description", "#UNKNOWN_PLAYLIST_NAME" )
			}

			break
		}
	}

	var rui = Hud_GetRui( file.descriptionBox )
	RuiSetString( rui, "messageText", desc )
}

void function OnChecklistIconButtonFocusLost( var button )
{
	Hud_Hide( file.hintIcon )
	Hud_Hide( file.hintBox )

	var rui = Hud_GetRui( file.descriptionBox )
	RuiSetString( rui, "messageText", "" )
}

void function OnChecklistIconButtonClick( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	bool selected = !Hud_IsSelected(button)
	SetChecklistButtonSelected( button, selected )
	SetFDPlaylistBits()
}

void function SetChecklistButtonSelected( var button, bool selected )
{
	Hud_SetSelected( button, selected )
	var buttonRui = Hud_GetRui( button )
	RuiSetBool( buttonRui, "isChecked", selected )
}

void function SetFDPlaylistBits()
{
	int bits = 0

	for ( int i=0; i<file.checklistIconButtons.len(); i++ )
	{
		var button = file.checklistIconButtons[i]
		if ( Hud_IsSelected( button ) )
		{
			int bit = file.difficulties[i].difficultyBits
			bits = bits | bit
		}
	}

	SetConVarInt( "fd_playlist_bits", bits )
}

void function OnTutorialButtonClick( var button )
{
	string link = GetPlaylistVarOrUseValue( "defaults", "fd_tutorial_url", "" )
	if ( link == "" )
		return

	LaunchExternalWebBrowser( link, WEBBROWSER_FLAG_MUTEGAME )
}

void function OnPlayButtonClick( var button )
{
	array<string> selectedDifficulties = GetSelectedPlaylists()

	if ( selectedDifficulties.len() == 0 )
	{
		Hud_SetFocused( file.checklistIconButtons[0] )
		return
	}
	
	if ( Hud_IsLocked( button ) )
		return
	
	CloseActiveMenu()
	Lobby_SetFDMode( true )
	thread StartNSMatchmaking( selectedDifficulties )
}

void function OnPlayButtonFocus( var button )
{
	file.isOnPlayButton = true

	Hud_Show( file.playHintIcon )
	Hud_Show( file.playHintBox )

	array<string> selectedDifficulties = GetSelectedPlaylists()

	string desc = BuildPlayWarningMessageTop( selectedDifficulties )

	var rui = Hud_GetRui( file.playDescriptionBox )
	RuiSetString( rui, "messageText", desc )
}


string function BuildPlayWarningMessageTop( array<string> pl )
{
	int playlistCount = pl.len()
	switch ( playlistCount )
	{
		case 0:
		return Localize( "#MENU_FD_DIFFICULTY_SEARCH_0" )
		case 1:
		return Localize( "#MENU_FD_DIFFICULTY_SEARCH_1", pldn(pl,0) )
		case 2:
		return Localize( "#MENU_FD_DIFFICULTY_SEARCH_2", pldn(pl,0), pldn(pl,1) )
		case 3:
		return Localize( "#MENU_FD_DIFFICULTY_SEARCH_3", pldn(pl,0), pldn(pl,1), pldn(pl,2) )
		case 4:
		return Localize( "#MENU_FD_DIFFICULTY_SEARCH_4", pldn(pl,0), pldn(pl,1), pldn(pl,2), pldn(pl,3) )
	}
	unreachable
}

string function pldn( array<string> pl, int index )
{
	string playlistName = pl[index]
	FDDifficultyInfo data = GetDifficultyDataFromPlaylistName( playlistName )
	return Localize( data.abbrev )
}

void function OnPlayButtonFocusLost( var button )
{
	file.isOnPlayButton = false

	Hud_Hide( file.playHintIcon )
	Hud_Hide( file.playHintBox )

	var rui = Hud_GetRui( file.playDescriptionBox )
	RuiSetString( rui, "messageText", "" )
}


void function OnHostButtonClick( var button )
{
	AdvanceMenu( GetMenu( "FDHostMatchMenu" ) )
}

void function OnHostButtonFocus( var button )
{
	file.isOnPromoButton = true
}

void function OnHostButtonFocusLost( var button )
{
	file.isOnPromoButton = false
}

array<string> function GetSelectedPlaylists()
{
	array<string> pl = []
	for ( int i=0; i<file.checklistIconButtons.len(); i++ )
	{
		var button = file.checklistIconButtons[i]
		if ( Hud_IsSelected( button ) )
		{
			pl.append( file.difficulties[i].playlist )
		}
	}

	return pl
}

void function TitanButton_OnClick( var button )
{
	int scriptID = int( Hud_GetScriptID( button ) )
	if ( Hud_IsLocked( button ) )
	{
		TitanLoadoutDef loadout = GetCachedTitanLoadout( scriptID )
		if ( !IsTitanLoadoutAvailable( GetUIPlayer(), loadout.titanClass ) )
			return

		OpenBuyItemDialog( file.titanButtons, button, GetItemName( loadout.titanClass ), loadout.titanClass )
		return
	}

	uiGlobal.titanSpawnLoadoutIndex = scriptID
	SetEditLoadout( "titan", scriptID )
	RunMenuClientFunction( "SetEditingTitanLoadoutIndex", scriptID )
	AdvanceMenu( GetMenu( "EditTitanLoadoutMenu" ) )
}

void function TitanButton_OnLoseFocused( var button )
{
	RunMenuClientFunction( "UpdateTitanModel", uiGlobal.titanSpawnLoadoutIndex )
	UpdateFDPanel( file.fdProperties, uiGlobal.titanSpawnLoadoutIndex, true )
}

void function TitanButton_OnFocused( var button )
{
	int scriptID = int( Hud_GetScriptID( button ) )

	RunMenuClientFunction( "UpdateTitanModel", scriptID )
	RunMenuClientFunction( "SetEditingTitanLoadoutIndex", scriptID )
	UpdateFDPanel( file.fdProperties, scriptID, true )
	uiGlobal.titanSpawnLoadoutIndex = scriptID
}

void function OnFDMenu_NavigateBack()
{
	if ( !IsDifficultyOrTitanButtonSelected() )
		CloseActiveMenu()
	else
		Hud_SetFocused( file.playButton )
}

bool function IsDifficultyOrTitanButtonSelected()
{
	foreach ( button in file.titanButtons )
		if ( Hud_IsFocused( button ) )
			return true

	foreach ( button in file.checklistIconButtons )
		if ( Hud_IsFocused( button ) )
			return true

	return false
}