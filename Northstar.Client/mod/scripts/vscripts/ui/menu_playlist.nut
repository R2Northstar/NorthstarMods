untyped

global function GetVisiblePlaylists

global function InitPlaylistMenu
global function SendOpenInvite
global function IsSendOpenInviteTrue
global function GetPlaylistImage
global function GetPlaylistThumbnailImage
global function BuyIntoColiseumTicket
global function UpdatePlaylistButton
global function PlaylistButton_Click_Internal
global function PlaylistShouldShowAsLocked
global function CanPlaylistFitMyParty

struct
{
	bool initialized = false
	GridMenuData gridData
	array<string> playlistNames
	var menu
	var unlockReq

	bool sendOpenInvite = false

	bool showColiseumPartyWarning = true
	array<var> coliseumRefreshButtons
	var coliseumButton
} file

void function InitPlaylistMenu()
{
	var menu = GetMenu( "PlaylistMenu" )

	file.unlockReq = Hud_GetChild( menu, "UnlockReq" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnPlaylistMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnPlaylistMenu_Close )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

bool function PlaylistButtonInit( var button, int elemNum )
{
	var rui = Hud_GetRui( button )
	GridMenuData data = Grid_GetGridDataForButton( button )

	string playlistName = file.playlistNames[ elemNum ]

	string levelName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	string imageName = GetPlaylistVarOrUseValue( playlistName, "image", "default" )
	bool doubleXP = GetPlaylistVarOrUseValue( playlistName, "double_xp_enabled", "0" ) == "1"
	var dataTable = GetDataTable( $"datatable/playlist_items.rpak" )

	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "playlist" ), imageName )
	asset levelImage = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )

	RuiSetImage( rui, "itemImage", levelImage )
	RuiSetString( rui, "title", levelName )
	RuiSetBool( rui, "doubleXP", doubleXP )

	return true
}

asset function GetPlaylistImage( string playlistName )
{
	string imageName = GetPlaylistVarOrUseValue( playlistName, "image", "default" )
	var dataTable = GetDataTable( $"datatable/playlist_items.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "playlist" ), imageName )
	asset levelImage = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )

	return levelImage
}

asset function GetPlaylistThumbnailImage( string playlistName )
{
	string imageName = GetPlaylistVarOrUseValue( playlistName, "image", playlistName )
	var dataTable = GetDataTable( $"datatable/playlist_items.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "playlist" ), imageName )
	if ( row == -1 )
		row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "playlist" ), "default" )
	asset levelImage = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "thumbnail" ) )

	return levelImage
}

void function SendOpenInvite( bool state )
{
	file.sendOpenInvite = state
}

bool function IsSendOpenInviteTrue()
{
	return file.sendOpenInvite
}

void function PlaylistButton_GetFocus( var button, int elemNum )
{
	string playlistName = file.playlistNames[ elemNum ]

	string unlockReq
	if ( IsUnlockValid( playlistName ) )
		unlockReq = GetItemUnlockReqText( playlistName )
	RHud_SetText( file.unlockReq, unlockReq )

	string levelName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	string desc = GetPlaylistVarOrUseValue( playlistName, "description", "#UNKNOWN_PLAYLIST_NAME" )

	file.menu = GetMenu( "PlaylistMenu" )
	file.menu.GetChild( "ContentDescriptionTitle" ).SetText( levelName )
	file.menu.GetChild( "ContentDescription" ).SetText( desc )
	file.menu.GetChild( "PlayerCount" ).SetText( "#PLAYLIST_PLAYERCOUNT_COMBINED", GetPlaylistCountDescForRegion( playlistName ), GetPlaylistCountDescForWorld( playlistName ) )
}

void function OnPlaylistMenu_Open()
{
	file.showColiseumPartyWarning = true
	StopMatchmaking()

	var menu = GetMenu( "PlaylistMenu" )

	file.playlistNames = GetVisiblePlaylists()
	int numRows = file.playlistNames.len()
	file.gridData.numElements = numRows
	file.gridData.rows = 2
	file.gridData.columns = 4
	file.gridData.paddingVert = 10
	file.gridData.paddingHorz = 10
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = Grid_GetMaxWidthForSettings( menu, file.gridData )

	float tileHeight = ( file.gridData.tileWidth * 9.0 ) / 21.0

	file.gridData.tileHeight = int( tileHeight )

	file.gridData.initCallback = PlaylistButtonInit
	file.gridData.getFocusCallback = PlaylistButton_GetFocus
	file.gridData.clickCallback = PlaylistButton_Click
//	file.gridData.buttonFadeCallback = FadePlaylistButton

	file.gridData.currentPage = 0

	if ( file.initialized )
		Grid_InitPage( menu, file.gridData, true )
	else
		GridMenuInit( menu, file.gridData )

	file.initialized = true

	Hud_SetFocused( Grid_GetButtonAtRowColumn( menu, 0, 0 ) )

	UI_SetPresentationType( ePresentationType.NO_MODELS )

	Grid_RegisterPageNavInputs( menu )

	thread UpdatePlaylistButtons()
}


void function OnPlaylistMenu_Close()
{
	file.showColiseumPartyWarning = true
	var menu = GetMenu( "PlaylistMenu" )
	Grid_DeregisterPageNavInputs( menu )

}

bool function CanPlaylistFitMyParty( string playlistName )
{
	int partySize = GetPartySize()
	int maxPlayers = GetMaxPlayersForPlaylistName( playlistName )
	int maxTeams = GetMaxTeamsForPlaylistName( playlistName )
	int maxPlayersPerTeam = int( max( maxPlayers / maxTeams, 1 ) )
	bool partiesAllowed = GetCurrentPlaylistVarInt( "parties_allowed", 1 ) > 0

	if ( playlistName == "coliseum" )
	{
		if ( partySize == 2 && GetCurrentPlaylistVarInt( "enable_coliseum_party", 0 ) == 1 )
			return true
	}

	if ( partySize > maxPlayersPerTeam )
		return false

	if ( file.sendOpenInvite && maxPlayersPerTeam == 1 )
		return false

	if ( !partiesAllowed )
	{
		if ( partySize > 1 )
			return false

		if ( file.sendOpenInvite )
			return false
	}

	return true
}

bool function PlaylistShouldShowAsLocked( string playlistName )
{
	bool isLocked = false

	if ( playlistName == "private_match" )
	{
		isLocked = false
	}
	else if ( !CanPlaylistFitMyParty( playlistName ) )
	{
		isLocked = true
	}
	else if ( IsUnlockValid( playlistName ) && IsItemLocked( GetUIPlayer(), playlistName ) )
	{
		isLocked = true
	}

	return isLocked
}

void function UpdatePlaylistButton( var button, string playlistName, bool forceLocked )
{
	if ( playlistName == "coliseum" )
	{
		var rui = Hud_GetRui( button )
		RuiSetInt( rui, "specialObjectCount", Player_GetColiseumTicketCount( GetUIPlayer() ) )
		RuiSetImage( rui, "specialObjectIcon", $"rui/menu/common/ticket_icon" )
		RuiSetFloat( rui, "specialAlpha", 1.0 )
	}
	else
	{
		var rui = Hud_GetRui( button )
		RuiSetInt( rui, "specialObjectCount", 0 )
		RuiSetImage( rui, "specialObjectIcon", $"" )
		RuiSetFloat( rui, "specialAlpha", 0.0 )
	}

	int costOverride = -1
	if ( playlistName == "private_match" )
	{
		costOverride = 0
	}
	else if ( !CanPlaylistFitMyParty( playlistName ) )
	{
		costOverride = 0
	}

	bool isLocked = PlaylistShouldShowAsLocked( playlistName )
	Hud_SetLocked( button, (isLocked || forceLocked) )

	if ( IsRefValid( playlistName ) )
		RefreshButtonCost( button, playlistName, "", -1, costOverride )
}


void function UpdatePlaylistButtons()
{
	while ( GetTopNonDialogMenu() == GetMenu( "PlaylistMenu" ) )
	{
		table< int, var > activePageButtons = Grid_GetActivePageButtons( GetMenu( "PlaylistMenu" ) )

		if ( GetUIPlayer() )
		{
			foreach ( buttonIndex, button in activePageButtons )
			{
				string playlistName = file.playlistNames[ buttonIndex ]
				UpdatePlaylistButton( button, playlistName, false )
			}
		}
		WaitFrame()
	}
}

void function CreatePartyAndStartPrivateMatch()
{
	while ( !PartyHasMembers() && !AmIPartyLeader() )
	{
		ClientCommand( "createparty" )
		WaitFrameOrUntilLevelLoaded()
	}
	ClientCommand( "StartPrivateMatchSearch" )
	OpenConnectingDialog()
}

void function StartPrivateMatch()
{
	thread CreatePartyAndStartPrivateMatch()
}

bool function PlaylistButton_Click_Internal( var button, string playlistName, array<var> refreshButtons )
{
	if ( playlistName == "private_match" )
	{
		if ( Hud_IsLocked( button ) )
			return false

		if ( !file.sendOpenInvite )
		{
			if(IsNorthstarServer())
				StartNSPrivateMatch( button )
			else
				StartPrivateMatch()
			return false
		}
	}

	if ( Hud_IsLocked( button ) )
	{
		if ( !CanPlaylistFitMyParty( playlistName ) )
			return false

		if ( ItemDefined( playlistName ) )
			OpenBuyItemDialog( refreshButtons, button, GetItemName( playlistName ), playlistName )
		else
			printt( "Not calling OpenBuyItemDialog() for '" + playlistName + "', because it doesn't exist as an Item." )
		return false
	}

	//DO CHECK HERE TO SEE IF WE ARE TYING TO ENTER COLISEUM
	if ( playlistName == "coliseum" )
	{
		// Does player have a ticket?

		int requiredTickets = 1
		if ( GetPartySize() == 2 )
			requiredTickets = 2

		if ( Player_GetColiseumTicketCount( GetLocalClientPlayer() ) >= requiredTickets )
		{
			ColiseumPlaylist_SpendTicketDialogue( button, requiredTickets )
			return false
		}
		else if ( requiredTickets == 2 ) //&& file.showColiseumPartyWarning )
		{
			ColiseumPlaylist_WarnFriendDialogue( refreshButtons, button )
			return false
		}
		else
		{
			ColiseumPlaylist_OfferToBuyTickets( refreshButtons, button, 1 )
			return false
		}
	}

	if ( playlistName == "fd" )
	{
		AdvanceMenu( GetMenu( "FDMenu" ) )
		return false
	}

	CloseActiveMenu() // playlist selection menu

	printt( "Setting match_playlist to '" + playlistName + "' from playlist menu" )
	if ( file.sendOpenInvite )
		ClientCommand( "openinvite playlist " + playlistName )
	else
		StartMatchmaking( playlistName )

	return true
}

void function PlaylistButton_Click( var button, int elemNum )
{
	string playlistName = file.playlistNames[ elemNum ]
	array<var> refreshButtons = GetElementsByClassname( file.menu, "GridButtonClass" )
	PlaylistButton_Click_Internal( button, playlistName, refreshButtons )
}

array<string> function GetVisiblePlaylists()
{
	int numPlaylists = GetPlaylistCount()

	array<string> list = []

	bool rearrangeForAngelCity = false

	for ( int i=0; i<numPlaylists; i++ )
	{
		string name = string( GetPlaylistName(i) )
		bool visible = GetPlaylistVarOrUseValue( name, "visible", "0" ) == "1"

		if ( visible )
		{
			// printt( name )
			if ( IsItemInEntitlementUnlock( name ) && IsValid( GetUIPlayer() ) )
	 		{
	 			if ( IsItemLocked( GetUIPlayer(), name ) )
	 			{
	 				continue
	 			}
	 			else if ( name == "angel_city_247" )
	 			{
	 				rearrangeForAngelCity = true
	 			}
	 		}

			list.append( name )
		}
	}

	if ( rearrangeForAngelCity )
	{
		string playlistReplacement = GetCurrentPlaylistVarString( "angel_city_replacement", "" )
		int playlistReplacementIdx = GetCurrentPlaylistVarInt( "angel_city_replacement_index", 3 )
		if ( playlistReplacement != "" && list.contains( playlistReplacement ) )
		{
			int idx = list.find( playlistReplacement )
			list.remove( idx )
			list.insert( playlistReplacementIdx, playlistReplacement )
		}
	}

	return list
}

void function FadePlaylistButton( var elem, int fadeTarget, float fadeTime )
{
	var rui = Hud_GetRui( elem )
	RuiSetFloat( rui, "mAlpha", ( fadeTarget / 255.0 ) )
	RuiSetGameTime( rui, "fadeStartTime", Time() )
	RuiSetGameTime( rui, "fadeEndTime", Time() + fadeTime )
}

void function ColiseumPlaylist_WarnFriendDialogue( array<var> refreshButtons, var button )
{
	DialogData dialogData
	dialogData.header = "#COLISEUM_WARN_HEADER_INVITE"
	dialogData.message = "#COLISEUM_WARN_MESSAGE_INVITE"

	file.coliseumRefreshButtons = refreshButtons
	file.coliseumButton = button

	AddDialogButton( dialogData, "#YES", ColiseumPlaylist_OfferToBuyTicketAfterWarn )
	AddDialogButton( dialogData, "#NO" )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function ColiseumPlaylist_SpendTicketDialogue( var button, int numTickets = 1 )
{
	DialogData dialogData
	if ( numTickets == 1 )
	{
		dialogData.header = "#COLISEUM_PAY_HEADER"
		dialogData.message = "#COLISEUM_PAY_MESSAGE"
		AddDialogButton( dialogData, "#YES", BuyIntoColiseumTicket )
	}
	else
	{
		dialogData.header = "#COLISEUM_PAY_HEADER_INVITE"
		dialogData.message = "#COLISEUM_PAY_MESSAGE_INVITE"
		AddDialogButton( dialogData, "#YES", BuyIntoColiseumTicketParty )
	}

	AddDialogButton( dialogData, "#NO" )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function ColiseumPlaylist_OfferToBuyTicketAfterWarn()
{
	file.showColiseumPartyWarning = false

	int requiredTickets = 1
	if ( GetPartySize() == 2 )
		requiredTickets = 2

	int ticketsToBuy = requiredTickets - Player_GetColiseumTicketCount( GetLocalClientPlayer() )

	if ( ticketsToBuy > 0 )
		ColiseumPlaylist_OfferToBuyTickets( file.coliseumRefreshButtons, file.coliseumButton, ticketsToBuy )
}

void function ColiseumPlaylist_OfferToBuyTickets( array<var> refreshButtons, var button, int numTickets )
{
	OpenBuyTicketDialog( refreshButtons, button, numTickets )
}

void function BuyIntoColiseumTicketParty()
{
	string playlistName = "coliseum"
	CloseActiveMenu() // playlist selection menu
	AdvanceMenu( GetMenu( "SearchMenu" ) )
	ClientCommand( "MarkForDoubleColiseumTicket" )

	StartMatchmaking( playlistName )
}

void function BuyIntoColiseumTicket()
{
	string playlistName = "coliseum"
	CloseActiveMenu() // playlist selection menu
	AdvanceMenu( GetMenu( "SearchMenu" ) )

	StartMatchmaking( playlistName )
}
