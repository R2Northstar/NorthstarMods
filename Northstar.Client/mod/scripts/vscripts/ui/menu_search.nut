global function InitSearchMenu
global function Search_UpdateInboxButtons
global function IsWaitingBeforeMatchMaking
global function LocalPlayerIsMixtapeSearching

struct {
	var chatroomMenu
	var chatroomMenu_chatroomWidget

	var firstNetworkSubButton

	int customizeHeaderIndex
	var networksMoreButton

	var pilotButton
	var titanButton
	var boostsButton
	var storeButton
	var factionButton
	var bannerButton
	var patchButton
	var statsButton
	var networksHeader
	var browseNetworkButton
	var settingsHeader
	var storeHeader
	var faqButton
	var dpadCommsButton

	var inboxButton
	int inboxHeaderIndex

	var customizeHeader
	var callsignHeader

	var callsignCard
	bool chatroomWidgetState

	ComboStruct &lobbyComboStruct
} file


void function InitSearchMenu()
{
	var menu = GetMenu( "SearchMenu" )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_BACK, "#BACK_BUTTON_POSTGAME_REPORT", "#POSTGAME_REPORT", OpenPostGameMenu, IsPostGameMenuValid )
	AddMenuFooterOption( menu, MOUSE_MIDDLE, "", "#SKIP_WAIT_BEFORE_MATCHMAKING", SkipMatchMakingWait, IsWaitingBeforeMatchMaking )
	AddMenuFooterOption( menu, BUTTON_Y, "", "", SkipMatchMakingWait, IsWaitingBeforeMatchMaking )
	AddMenuFooterOption( menu, BUTTON_TRIGGER_RIGHT, "#R_TRIGGER_CHAT", "", null, IsVoiceChatPushToTalk )

	InitChatroom( menu )

	file.chatroomMenu = Hud_GetChild( menu, "ChatRoomPanel" )
	file.chatroomMenu_chatroomWidget = Hud_GetChild( file.chatroomMenu, "ChatRoom" )

	CreateButtons( menu )

	file.firstNetworkSubButton = Hud_GetChild( GetMenu( "CommunitiesMenu" ), "BtnBrowse" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnSearchMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnSearchMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnSearchMenu_NavigateBack )

}

void function Mixtape_SearchSkip( var button )
{
	printt( "Mixtape_SearchSkip()" )
	EmitUISound( "Menu.Accept" )
	ClientCommand( "MatchmakingSkipToNext" )
}

bool function LocalPlayerIsMixtapeSearching()
{
	if ( !IsFullyConnected() )
		return false

	if ( !AreWeMatchmaking() )
		return false

	string matchPlaylistVal = GetConVarString( "match_playlist" )
	array<string> playlists = split( matchPlaylistVal, "," )
	if ( playlists.len() <= 1 )
		return false

	if ( AmIPartyMember() )
		return false

	return true
}

void function OnSearchMenu_Open()
{
	UI_SetPresentationType( ePresentationType.SEARCH )

	thread UpdateCachedNewItems()

	if ( !Console_HasPermissionToPlayMultiplayer() )
	{
		ClientCommand( "disconnect" )
		return
	}

	if ( IsFullyConnected() )
	{
		entity player = GetUIPlayer()
		if ( !IsValid( player ) )
			return

		while ( player.GetPersistentVarAsInt( "initializedVersion" ) < PERSISTENCE_INIT_VERSION )
		{
			WaitFrame()
		}
		if ( !IsPersistenceAvailable() )
			return

		// if not in FD mode, try to see if we should be in FD mode
		if ( !Lobby_IsFDMode() )
		{
			string playlistList = GetMyMatchmakingStatusParam( 5 )
			Lobby_SetFDModeBasedOnSearching( playlistList )
			Lobby_RefreshButtons()
		}

		if ( Lobby_IsFDMode() )
			UI_SetPresentationType( ePresentationType.FD_SEARCH )

		string buttonString = Lobby_IsFDMode() ? "" : "#MENU_TITLE_BOOSTS"
		Hud_SetEnabled( file.boostsButton, !Lobby_IsFDMode() )
		ComboButton_SetText( file.boostsButton, buttonString )

		buttonString = Lobby_IsFDMode() ? "#MENU_TITLE_STATS" : "#MENU_TITLE_FACTION"
		ComboButton_SetText( file.factionButton, buttonString )

		buttonString = Lobby_IsFDMode() ? "" : "#MENU_TITLE_STATS"
		Hud_SetEnabled( file.statsButton, !Lobby_IsFDMode() )
		ComboButton_SetText( file.statsButton, buttonString )

		UpdateCallsignElement( file.callsignCard )
		RefreshCreditsAvailable()

		bool emotesAreEnabled = EmotesEnabled()
		// "Customize"
		{
			bool anyNewPilotItems = HasAnyNewPilotItems( player )
			bool anyNewTitanItems = HasAnyNewTitanItems( player )
			bool anyNewBoosts = HasAnyNewBoosts( player )
			bool anyNewCommsIcons = false // emotesAreEnabled ? HasAnyNewDpadCommsIcons( player ) : false
			bool anyNewCustomizeHeader = (anyNewPilotItems || anyNewTitanItems || anyNewBoosts || anyNewCommsIcons)

			RuiSetBool( Hud_GetRui( file.customizeHeader ), "isNew", anyNewCustomizeHeader )
			ComboButton_SetNew( file.pilotButton, anyNewPilotItems )
			ComboButton_SetNew( file.titanButton, anyNewTitanItems )
			ComboButton_SetNew( file.boostsButton, anyNewBoosts )
			ComboButton_SetNew( file.dpadCommsButton, anyNewCommsIcons )

			if ( !emotesAreEnabled )
			{
				Hud_Hide( file.dpadCommsButton )
				ComboButtons_ResetColumnFocus( file.lobbyComboStruct )
			}
			else
			{
				Hud_Show( file.dpadCommsButton )
			}
		}

		// "Store"
		{
			bool storeIsNew = DLCStoreShouldBeMarkedAsNew()
			var headerRui = Hud_GetRui( file.storeHeader )
			RuiSetBool( headerRui, "isNew", storeIsNew )
			ComboButton_SetNew( file.storeButton, storeIsNew )
			RuiSetBool( headerRui, "isTitleTint", true )
		}

		// "Callsign"
		{
			bool anyNewBanners = HasAnyNewCallsignBanners( player )
			bool anyNewPatches = HasAnyNewCallsignPatches( player )
			bool anyNewFactions = HasAnyNewFactions( player )
			bool anyNewCallsignHeader = (anyNewBanners || anyNewPatches || anyNewFactions)

			RuiSetBool( Hud_GetRui( file.callsignHeader ), "isNew", anyNewCallsignHeader )
			ComboButton_SetNew( file.bannerButton, anyNewBanners )
			ComboButton_SetNew( file.patchButton, anyNewPatches )
			ComboButton_SetNew( file.factionButton, anyNewFactions )
		}

		Search_UpdateInboxButtons()
	}
}

void function OnSearchMenu_Close()
{
	if ( GetUIPlayer() )
		StopMatchmaking()
}

void function OnSearchMenu_NavigateBack()
{
	LeaveDialog()
}

void function OnCommunityButton_Activate( var button )
{
	void functionref( var ) handlerFunc = AdvanceMenuEventHandler( GetMenu( "CommunitiesMenu" ) )
	handlerFunc( button )
	Hud_SetFocused( file.firstNetworkSubButton )
}

void function Search_UpdateInboxButtons()
{
	var menu = GetMenu( "SearchMenu" )
	if ( GetUIPlayer() == null )
		return

	bool hasNewMail = (Inbox_HasUnreadMessages() && Inbox_GetTotalMessageCount() > 0) || PlayerRandomUnlock_GetTotal( GetUIPlayer() ) > 0
	if ( hasNewMail )
	{
		int messageCount = Inbox_GetTotalMessageCount()
		int lootCount = PlayerRandomUnlock_GetTotal( GetUIPlayer() )
		int totalCount = messageCount + lootCount

		string countString
		if ( totalCount >= MAX_MAIL_COUNT )
			countString = MAX_MAIL_COUNT + "+"
		else
			countString = string( totalCount )

		SetComboButtonHeaderTitle( menu, file.inboxHeaderIndex, Localize( "#MENU_HEADER_NETWORKS_NEW_MSGS", countString )  )
		ComboButton_SetText( file.inboxButton, Localize( "#MENU_TITLE_INBOX_NEW_MSGS", countString ) )
	}
	else
	{
		SetComboButtonHeaderTitle( menu, file.inboxHeaderIndex, Localize( "#MENU_HEADER_NETWORKS" )  )
		ComboButton_SetText( file.inboxButton, Localize( "#MENU_TITLE_READ" ) )
	}

	ComboButton_SetNewMail( file.inboxButton, hasNewMail )
}

void function CreateButtons( var menu )
{
	ComboStruct comboStruct = ComboButtons_Create( menu )
	file.lobbyComboStruct = comboStruct

	int headerIndex = 0
	int buttonIndex = 0
	file.customizeHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_LOADOUTS" )
	file.customizeHeaderIndex = headerIndex
	var pilotButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PILOT" )
	file.pilotButton = pilotButton

	Hud_AddEventHandler( pilotButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditPilotLoadoutsMenu" ) ) )
	var titanButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_TITAN" )
	file.titanButton = titanButton
	Hud_AddEventHandler( titanButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditTitanLoadoutsMenu" ) ) )
	file.boostsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_BOOSTS" )
	Hud_AddEventHandler( file.boostsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "BurnCardMenu" ) ) )
	file.dpadCommsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_COMMS" )
	Hud_AddEventHandler( file.dpadCommsButton, UIE_CLICK, OnDpadCommsButton_Activate )
//	file.storeButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STORE" )
//	Hud_AddEventHandler( file.storeButton, UIE_CLICK, OnStoreButton_Activate )
//	var armoryButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_ARMORY" )
//	file.armoryButton = armoryButton
//	Hud_AddEventHandler( armoryButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ArmoryMenu" ) ) )


	// var networksMoreButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#COMMUNITY_MORE" )
	// Hud_AddEventHandler( networksMoreButton, UIE_CLICK, OnCommunityButton_Activate )
	// file.networksMoreButton = networksMoreButton

	headerIndex++
	buttonIndex = 0
	file.callsignHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_CALLSIGN" )
	file.bannerButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_BANNER" )
	Hud_AddEventHandler( file.bannerButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignCardSelectMenu" ) ) )
	file.patchButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PATCH" )
	Hud_AddEventHandler( file.patchButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignIconSelectMenu" ) ) )
	file.factionButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_FACTION" )
	Hud_AddEventHandler( file.factionButton, UIE_CLICK, Lobby_CallsignButton3EventHandler )
	file.statsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STATS" )
	Hud_AddEventHandler( file.statsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStatsMenu" ) ) )

	file.callsignCard = Hud_GetChild( menu, "CallsignCard" )

	headerIndex++
	buttonIndex = 0
	file.networksHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_NETWORKS" )
	file.inboxHeaderIndex = headerIndex
	var networksInbox = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_INBOX" )
	file.inboxButton = networksInbox
	Hud_AddEventHandler( networksInbox, UIE_CLICK, OnInboxButton_Activate )
	var switchButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#COMMUNITY_SWITCHCOMMUNITY" )
	Hud_AddEventHandler( switchButton, UIE_CLICK, OnSwitchButton_Activate )
	var browseButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#COMMUNITY_BROWSE_NETWORKS" )
//	file.lobbyButtons.append( browseButton )
	Hud_AddEventHandler( browseButton, UIE_CLICK, OnBrowseNetworksButton_Activate )
	file.browseNetworkButton = browseButton

	headerIndex++
	buttonIndex = 0
	file.storeHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_STORE" )
	file.storeButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STORE_BROWSE" )
	Hud_AddEventHandler( file.storeButton, UIE_CLICK, OnStoreButton_Activate )
	var storeNewReleasesButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STORE_NEW_RELEASES" )
	Hud_AddEventHandler( storeNewReleasesButton, UIE_CLICK, OnStoreNewReleasesButton_Activate )
	var storeBundlesButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_STORE_BUNDLES" )
	Hud_AddEventHandler( storeBundlesButton, UIE_CLICK, OnStoreBundlesButton_Activate )

	headerIndex++
	buttonIndex = 0
	file.settingsHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_SETTINGS" )
	var controlsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CONTROLS" )
	Hud_AddEventHandler( controlsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ControlsMenu" ) ) )
	#if CONSOLE_PROG
		var avButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO_VIDEO" )
		Hud_AddEventHandler( avButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioVideoMenu" ) ) )
	#elseif PC_PROG
		var videoButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO" )
		Hud_AddEventHandler( videoButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioMenu" ) ) )
		var soundButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#VIDEO" )
		Hud_AddEventHandler( soundButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "VideoMenu" ) ) )
	#endif

	// MODS
	var modsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_MODS" )
	Hud_AddEventHandler( modsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ModListMenu" ) ) )

	//var dataCenterButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#DATA_CENTER" )
	//Hud_AddEventHandler( dataCenterButton, UIE_CLICK, OpenDataCenterDialog )

	comboStruct.navUpButtonDisabled = true
	comboStruct.navDownButton = file.chatroomMenu_chatroomWidget

	ComboButtons_Finalize( comboStruct )
}

void function SkipMatchMakingWait( var button )
{
	Signal( uiGlobal.signalDummy, "BypassWaitBeforeRestartingMatchmaking" )
	UpdateFooterOptions()
}

bool function IsWaitingBeforeMatchMaking()
{
	if ( IsOpenInviteVisible() )
		return false

	if ( AmIPartyMember() )
		return false

	return GetTimeToRestartMatchMaking() > 0.0
}